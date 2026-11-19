import 'package:dio/dio.dart';

import '../api_exception.dart';
import 'problem_parser.dart';

/// Convierte toda respuesta no 2xx y todo error de transporte en
/// [ApiException], que viaja en `DioException.error`.
final class ErrorInterceptor extends Interceptor {
  /// Excepción normalizada para [err].
  static ApiException toApiException(DioException err) {
    final Object? inner = err.error;
    if (inner is ApiException) {
      return inner;
    }
    final Response<Object?>? response = err.response;
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => const ApiException.networkTimeout(),
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate ||
      DioExceptionType.cancel => const ApiException.networkUnavailable(),
      DioExceptionType.badResponse || DioExceptionType.unknown =>
        response == null
            ? const ApiException.networkUnavailable()
            : ProblemParser.fromResponse(response),
    };
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: toApiException(err)));
  }
}
