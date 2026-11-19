import 'package:dio/dio.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

import 'api_client.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/log_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';
import 'session_events.dart';
import 'token_store.dart';

/// Implementación real de [ApiClient], sobre `dio`.
///
/// Es el único archivo del repo, junto con sus interceptores, que conoce
/// `package:dio`.
final class DioApiClient implements ApiClient {
  /// Crea el cliente contra [baseUrl] (`API_BASE_URL`).
  ///
  /// Interceptores, en este orden: auth, refresh, errores y log.
  /// [httpClientAdapter] y [delay] existen para los tests.
  factory DioApiClient({
    required String baseUrl,
    required TokenStore tokenStore,
    required SessionEvents sessionEvents,
    required AppLogger logger,
    required Clock clock,
    HttpClientAdapter? httpClientAdapter,
    List<Duration> retryBackoff = defaultRetryBackoff,
    Future<void> Function(Duration duration)? delay,
  }) {
    final Dio dio = Dio(_options(baseUrl));
    final Dio refreshDio = Dio(_options(baseUrl));
    if (httpClientAdapter != null) {
      dio.httpClientAdapter = httpClientAdapter;
      refreshDio.httpClientAdapter = httpClientAdapter;
    }
    dio.interceptors.addAll(<Interceptor>[
      AuthInterceptor(tokenStore),
      RefreshInterceptor(
        dio: dio,
        refreshDio: refreshDio,
        tokenStore: tokenStore,
        sessionEvents: sessionEvents,
      ),
      ErrorInterceptor(),
      ApiLogInterceptor(logger: logger, clock: clock),
    ]);
    return DioApiClient._(dio, retryBackoff, delay ?? _wait);
  }

  DioApiClient._(this._dio, this._retryBackoff, this._delay);

  /// Timeout de conexión.
  static const Duration connectTimeout = Duration(seconds: 10);

  /// Timeout de recepción.
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Esperas entre reintentos de un `GET`: como máximo dos.
  static const List<Duration> defaultRetryBackoff = <Duration>[
    Duration(milliseconds: 500),
    Duration(milliseconds: 1500),
  ];

  final Dio _dio;
  final List<Duration> _retryBackoff;
  final Future<void> Function(Duration duration) _delay;

  @override
  Future<ApiResponse> delete(
    String path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => _send('DELETE', path, query: query, headers: headers);

  @override
  Future<ApiResponse> get(
    String path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await _send('GET', path, query: query, headers: headers);
      } on ApiException catch (error) {
        if (!error.isRetryable || attempt >= _retryBackoff.length) {
          rethrow;
        }
        await _delay(_retryBackoff[attempt]);
        attempt++;
      }
    }
  }

  @override
  Future<ApiResponse> post(
    String path, {
    Map<String, Object?>? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => _send('POST', path, body: body, query: query, headers: headers);

  @override
  Future<ApiResponse> put(
    String path, {
    Map<String, Object?>? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => _send('PUT', path, body: body, query: query, headers: headers);

  static BaseOptions _options(String baseUrl) => BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
    headers: <String, Object?>{'Accept': 'application/json'},
  );

  static Future<void> _wait(Duration duration) =>
      Future<void>.delayed(duration);

  Future<ApiResponse> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) async {
    try {
      final Response<Object?> response = await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: _withoutNulls(query),
        options: Options(method: method, headers: headers),
      );
      return ApiResponse(
        statusCode: response.statusCode ?? 0,
        body: response.data == '' ? null : response.data,
      );
    } on DioException catch (error) {
      throw ErrorInterceptor.toApiException(error);
    }
  }

  Map<String, Object?>? _withoutNulls(Map<String, Object?>? query) {
    if (query == null) {
      return null;
    }
    return <String, Object?>{
      for (final MapEntry<String, Object?> entry in query.entries)
        if (entry.value != null) entry.key: entry.value,
    };
  }
}
