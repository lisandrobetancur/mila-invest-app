import 'package:equatable/equatable.dart';

/// Códigos de error del contrato (§8.3) y los que genera el cliente.
abstract final class ApiErrorCodes {
  /// Formulario inválido; trae errores por campo.
  static const String validationError = 'VALIDATION_ERROR';

  /// Credenciales incorrectas en el login.
  static const String authInvalidCredentials = 'AUTH_INVALID_CREDENTIALS';

  /// Email ya registrado.
  static const String authEmailTaken = 'AUTH_EMAIL_TAKEN';

  /// Documento ya registrado.
  static const String authDocumentTaken = 'AUTH_DOCUMENT_TAKEN';

  /// Access token vencido: dispara el refresh.
  static const String authTokenExpired = 'AUTH_TOKEN_EXPIRED';

  /// Token ausente o malformado: cierra la sesión.
  static const String authTokenInvalid = 'AUTH_TOKEN_INVALID';

  /// Refresh token inválido: cierra la sesión.
  static const String authRefreshInvalid = 'AUTH_REFRESH_INVALID';

  /// Saldo insuficiente para una compra.
  static const String insufficientFunds = 'INSUFFICIENT_FUNDS';

  /// Posición insuficiente para una venta.
  static const String insufficientPosition = 'INSUFFICIENT_POSITION';

  /// Mercado cerrado.
  static const String marketClosed = 'MARKET_CLOSED';

  /// Instrumento inexistente.
  static const String instrumentNotFound = 'INSTRUMENT_NOT_FOUND';

  /// Orden inexistente.
  static const String orderNotFound = 'ORDER_NOT_FOUND';

  /// La misma `Idempotency-Key` con otro cuerpo.
  static const String idempotencyConflict = 'IDEMPOTENCY_CONFLICT';

  /// Demasiadas peticiones; trae `Retry-After`.
  static const String rateLimited = 'RATE_LIMITED';

  /// Error interno. También es el destino de un `code` desconocido.
  static const String internalError = 'INTERNAL_ERROR';

  /// Sin red (código del cliente).
  static const String networkUnavailable = 'NETWORK_UNAVAILABLE';

  /// Timeout (código del cliente).
  static const String networkTimeout = 'NETWORK_TIMEOUT';

  /// Contrato roto: la respuesta no tiene la forma esperada (código del
  /// cliente).
  static const String unexpectedResponse = 'UNEXPECTED_RESPONSE';

  /// Códigos que el servidor puede enviar.
  static const Set<String> server = <String>{
    validationError,
    authInvalidCredentials,
    authEmailTaken,
    authDocumentTaken,
    authTokenExpired,
    authTokenInvalid,
    authRefreshInvalid,
    insufficientFunds,
    insufficientPosition,
    marketClosed,
    instrumentNotFound,
    orderNotFound,
    idempotencyConflict,
    rateLimited,
    internalError,
  };

  /// Normaliza un `code`: uno desconocido se trata como [internalError].
  static String normalize(String? code) =>
      code != null && server.contains(code) ? code : internalError;
}

/// Error de validación de un campo (`errors[]` del `problem+json`).
class ApiFieldError extends Equatable {
  /// Crea un error de campo.
  const ApiFieldError({required this.field, required this.code});

  /// Nombre del campo, en `snake_case`, tal como lo nombra la API.
  final String field;

  /// Código del error (`TOO_LARGE`, `INVALID_FORMAT`...).
  final String code;

  @override
  List<Object?> get props => <Object?>[field, code];
}

/// Toda respuesta no 2xx y todo error de transporte, ya normalizados.
class ApiException extends Equatable implements Exception {
  /// Crea una excepción de API.
  const ApiException({
    required this.status,
    required this.code,
    this.detail,
    this.fieldErrors = const <ApiFieldError>[],
    this.retryAfter,
  });

  /// Sin red.
  const ApiException.networkUnavailable()
    : status = 0,
      code = ApiErrorCodes.networkUnavailable,
      detail = null,
      fieldErrors = const <ApiFieldError>[],
      retryAfter = null;

  /// Timeout.
  const ApiException.networkTimeout()
    : status = 0,
      code = ApiErrorCodes.networkTimeout,
      detail = null,
      fieldErrors = const <ApiFieldError>[],
      retryAfter = null;

  /// Código HTTP, o `0` si el error es de transporte.
  final int status;

  /// Código del error, siempre uno de [ApiErrorCodes].
  final String code;

  /// Detalle legible que envía el servidor. No se muestra tal cual al
  /// usuario: la UI traduce a partir de [code].
  final String? detail;

  /// Errores por campo de un `VALIDATION_ERROR`.
  final List<ApiFieldError> fieldErrors;

  /// Espera que pide un 429.
  final Duration? retryAfter;

  /// `true` si el error es de transporte (sin red o timeout).
  bool get isNetwork =>
      code == ApiErrorCodes.networkUnavailable ||
      code == ApiErrorCodes.networkTimeout;

  /// `true` si conviene reintentar un `GET` idempotente.
  bool get isRetryable => code == ApiErrorCodes.networkTimeout || status == 503;

  /// Código del error del campo [field], o `null` si no tiene.
  String? fieldCode(String field) {
    for (final ApiFieldError error in fieldErrors) {
      if (error.field == field) {
        return error.code;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    code,
    detail,
    fieldErrors,
    retryAfter,
  ];

  @override
  String toString() => 'ApiException($status, $code)';
}
