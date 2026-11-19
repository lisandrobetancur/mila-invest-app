/// Códigos de error de authentication.
///
/// Se mapean desde el `code` del `problem+json` (§8.3). Cada uno apunta a
/// la clave de traducción de su mensaje.
enum AuthErrorCode {
  /// Email o contraseña incorrectos.
  invalidCredentials,

  /// El email ya está registrado.
  emailTaken,

  /// El documento ya está registrado.
  documentTaken,

  /// El formulario tiene campos inválidos.
  validation,

  /// Demasiados intentos.
  rateLimited,

  /// Sin conexión o timeout.
  network,

  /// La respuesta no tiene la forma del contrato.
  unexpectedResponse,

  /// Cualquier otro error.
  unknown;

  /// Mapea un `code` del contrato. Uno desconocido es [unknown].
  static AuthErrorCode fromApiCode(String code) => switch (code) {
    'AUTH_INVALID_CREDENTIALS' => AuthErrorCode.invalidCredentials,
    'AUTH_EMAIL_TAKEN' => AuthErrorCode.emailTaken,
    'AUTH_DOCUMENT_TAKEN' => AuthErrorCode.documentTaken,
    'VALIDATION_ERROR' => AuthErrorCode.validation,
    'RATE_LIMITED' => AuthErrorCode.rateLimited,
    'NETWORK_UNAVAILABLE' || 'NETWORK_TIMEOUT' => AuthErrorCode.network,
    'UNEXPECTED_RESPONSE' => AuthErrorCode.unexpectedResponse,
    _ => AuthErrorCode.unknown,
  };

  /// `true` si el error es de red y conviene ofrecer "Reintentar".
  bool get isNetwork => this == AuthErrorCode.network;

  /// `true` si el error se muestra en un campo y no como mensaje general.
  bool get isFieldError =>
      this == AuthErrorCode.emailTaken ||
      this == AuthErrorCode.documentTaken ||
      this == AuthErrorCode.validation;

  /// Clave de traducción del mensaje.
  String get messageKey => switch (this) {
    AuthErrorCode.invalidCredentials => 'auth.error.invalid_credentials',
    AuthErrorCode.emailTaken => 'auth.error.email_taken',
    AuthErrorCode.documentTaken => 'auth.error.document_taken',
    AuthErrorCode.validation => 'auth.error.validation',
    AuthErrorCode.rateLimited => 'auth.error.rate_limited',
    AuthErrorCode.network => 'auth.error.network',
    AuthErrorCode.unexpectedResponse => 'auth.error.unexpected',
    AuthErrorCode.unknown => 'auth.error.unknown',
  };
}
