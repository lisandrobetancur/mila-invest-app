import 'dart:convert';

import 'package:dio/dio.dart';

import '../api_client.dart';
import '../api_exception.dart';

/// Convierte un `application/problem+json` en [ApiException].
abstract final class ProblemParser {
  /// `code` crudo del cuerpo de [response], o `null` si no hay.
  static String? codeOf(Response<Object?>? response) {
    final Map<String, Object?>? body = _bodyOf(response);
    final Object? code = body?['code'];
    return code is String ? code : null;
  }

  /// Excepción normalizada para una respuesta no 2xx.
  ///
  /// Un `code` desconocido, o un cuerpo que no es `problem+json`, se trata
  /// como `INTERNAL_ERROR` sin romper la app.
  static ApiException fromResponse(Response<Object?> response) {
    final Map<String, Object?>? body = _bodyOf(response);
    final Object? detail = body?['detail'];
    return ApiException(
      status: response.statusCode ?? 0,
      code: ApiErrorCodes.normalize(codeOf(response)),
      detail: detail is String ? detail : null,
      fieldErrors: _fieldErrorsOf(body),
      retryAfter: _retryAfterOf(response),
    );
  }

  static Map<String, Object?>? _bodyOf(Response<Object?>? response) {
    final Object? data = response?.data;
    if (data is Map<String, Object?>) {
      return data;
    }
    if (data is String && data.isNotEmpty) {
      try {
        final Object? decoded = jsonDecode(data);
        return decoded is Map<String, Object?> ? decoded : null;
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  static List<ApiFieldError> _fieldErrorsOf(Map<String, Object?>? body) {
    final Object? errors = body?['errors'];
    if (errors is! List<Object?>) {
      return const <ApiFieldError>[];
    }
    final List<ApiFieldError> result = <ApiFieldError>[];
    for (final Object? item in errors) {
      if (item is Map<String, Object?>) {
        final Object? field = item['field'];
        final Object? code = item['code'];
        if (field is String && code is String) {
          result.add(ApiFieldError(field: field, code: code));
        }
      }
    }
    return result;
  }

  static Duration? _retryAfterOf(Response<Object?> response) {
    final String? raw = response.headers.value(ApiHeaders.retryAfter);
    final int? seconds = raw == null ? null : int.tryParse(raw);
    return seconds == null ? null : Duration(seconds: seconds);
  }
}
