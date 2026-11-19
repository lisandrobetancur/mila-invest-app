import 'package:dio/dio.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

import '../api_exception.dart';

/// Loguea método, path, status y duración de cada petición.
///
/// **Nunca** loguea headers (ahí viaja el token), ni la query, ni cuerpos:
/// los de `/auth/*` llevan contraseñas y los de registro, documentos.
final class ApiLogInterceptor extends Interceptor {
  /// Crea el interceptor.
  ApiLogInterceptor({required AppLogger logger, required Clock clock})
    : _logger = logger,
      _clock = clock;

  static const String _startedKey = 'mila_invest.started_at';

  final AppLogger _logger;
  final Clock _clock;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final Object? inner = err.error;
    final String code = inner is ApiException ? inner.code : err.type.name;
    _logger.warn(
      '${_describe(err.requestOptions)} '
      '${err.response?.statusCode ?? 0} $code',
    );
    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedKey] = _clock.nowUtc();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug(
      '${_describe(response.requestOptions)} ${response.statusCode}',
    );
    handler.next(response);
  }

  String _describe(RequestOptions options) {
    final Object? started = options.extra[_startedKey];
    final String elapsed = started is DateTime
        ? ' ${_clock.nowUtc().difference(started).inMilliseconds}ms'
        : '';
    return '${options.method} ${options.path}$elapsed';
  }
}
