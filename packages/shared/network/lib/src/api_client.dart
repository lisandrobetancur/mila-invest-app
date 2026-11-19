import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_response.dart';

/// Nombres de headers propios del contrato.
abstract final class ApiHeaders {
  /// Clave de idempotencia de las peticiones que mueven dinero o posiciones.
  static const String idempotencyKey = 'Idempotency-Key';

  /// Segundos de espera que acompaña a un 429.
  static const String retryAfter = 'retry-after';
}

/// Cliente de la API de MILA Invest.
///
/// Las features dependen de esta interfaz, nunca de `dio`. Todos los métodos
/// reciben un path relativo a la base (`/instruments`) y lanzan
/// `ApiException` ante cualquier respuesta no 2xx o error de transporte.
abstract interface class ApiClient {
  /// `GET` idempotente. Es el único verbo que se reintenta solo.
  Future<ApiResponse> get(
    String path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
  });

  /// `POST`. Nunca se reintenta automáticamente.
  Future<ApiResponse> post(
    String path, {
    Map<String, Object?>? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  });

  /// `PUT`.
  Future<ApiResponse> put(
    String path, {
    Map<String, Object?>? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  });

  /// `DELETE`.
  Future<ApiResponse> delete(
    String path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
  });
}

/// Provider del cliente de la API.
///
/// Lo sobrescribe el shell con `DioApiClient` o con `FakeApiClient`, según
/// `API_MODE`. Ninguna feature sabe con cuál de los dos habla.
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>(
  (Ref ref) => throw UnimplementedError('apiClientProvider'),
);
