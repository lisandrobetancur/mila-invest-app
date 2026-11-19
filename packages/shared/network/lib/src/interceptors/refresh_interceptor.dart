import 'package:dio/dio.dart';

import '../api_exception.dart';
import '../json_reader.dart';
import '../session_events.dart';
import '../token_store.dart';
import 'auth_interceptor.dart';
import 'problem_parser.dart';

enum _RefreshOutcome { refreshed, rejected, unreachable }

/// Refresca la sesión ante un 401 `AUTH_TOKEN_EXPIRED` y reintenta.
///
/// *Single-flight*: si varias peticiones fallan a la vez, todas esperan el
/// mismo refresh. Si el servidor rechaza el refresh, limpia los tokens y
/// emite "sesión expirada". Un fallo de red durante el refresh **no** cierra
/// la sesión: la petición original falla con el error de red.
final class RefreshInterceptor extends Interceptor {
  /// Crea el interceptor.
  ///
  /// [dio] reintenta la petición original (con toda la cadena);
  /// [refreshDio] no tiene interceptores y solo llama a `/auth/refresh`.
  RefreshInterceptor({
    required Dio dio,
    required Dio refreshDio,
    required TokenStore tokenStore,
    required SessionEvents sessionEvents,
  }) : _dio = dio,
       _refreshDio = refreshDio,
       _tokenStore = tokenStore,
       _sessionEvents = sessionEvents;

  static const String _retriedKey = 'mila_invest.retried_after_refresh';

  final Dio _dio;
  final Dio _refreshDio;
  final TokenStore _tokenStore;
  final SessionEvents _sessionEvents;

  Future<_RefreshOutcome>? _inFlight;
  DioException? _lastTransportError;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions options = err.requestOptions;
    final String? code = ProblemParser.codeOf(err.response);
    final bool isAuthRoute = AuthInterceptor.isAuthPath(options.path);

    if (err.response?.statusCode != 401 || isAuthRoute) {
      handler.next(err);
      return;
    }
    if (code == ApiErrorCodes.authTokenInvalid ||
        code == ApiErrorCodes.authRefreshInvalid) {
      await _expireSession();
      handler.next(err);
      return;
    }
    if (code != ApiErrorCodes.authTokenExpired ||
        options.extra[_retriedKey] == true) {
      handler.next(err);
      return;
    }

    final _RefreshOutcome outcome = await _refreshOnce();
    switch (outcome) {
      case _RefreshOutcome.rejected:
        handler.next(err);
      case _RefreshOutcome.unreachable:
        handler.next(_lastTransportError ?? err);
      case _RefreshOutcome.refreshed:
        options.extra[_retriedKey] = true;
        try {
          handler.resolve(await _dio.fetch<Object?>(options));
        } on DioException catch (retryError) {
          handler.reject(retryError);
        }
    }
  }

  Future<void> _expireSession() async {
    await _tokenStore.clear();
    _sessionEvents.notifyExpired();
  }

  Future<_RefreshOutcome> _refresh() async {
    final AuthTokens? current = await _tokenStore.read();
    if (current == null) {
      await _expireSession();
      return _RefreshOutcome.rejected;
    }
    try {
      final Response<Object?> response = await _refreshDio.post<Object?>(
        '/auth/refresh',
        data: <String, Object?>{'refresh_token': current.refreshToken},
      );
      final JsonReader json = JsonReader.of(response.data);
      await _tokenStore.save(
        AuthTokens(
          accessToken: json.string('access_token'),
          refreshToken: json.string('refresh_token'),
        ),
      );
      return _RefreshOutcome.refreshed;
    } on DioException catch (error) {
      if (error.response == null) {
        _lastTransportError = error;
        return _RefreshOutcome.unreachable;
      }
      await _expireSession();
      return _RefreshOutcome.rejected;
    } on FormatException {
      await _expireSession();
      return _RefreshOutcome.rejected;
    }
  }

  Future<_RefreshOutcome> _refreshOnce() =>
      _inFlight ??= _refresh().whenComplete(() => _inFlight = null);
}
