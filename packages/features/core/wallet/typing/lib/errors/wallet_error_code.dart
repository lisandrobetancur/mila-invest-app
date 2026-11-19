/// Códigos de error de wallet.
enum WalletErrorCode {
  /// El monto no es válido.
  validation,

  /// La misma clave de idempotencia con otro cuerpo.
  idempotencyConflict,

  /// Demasiadas peticiones.
  rateLimited,

  /// Sin conexión o timeout.
  network,

  /// La respuesta no tiene la forma del contrato.
  unexpectedResponse,

  /// Cualquier otro error.
  unknown;

  /// Mapea un `code` del contrato. Uno desconocido es [unknown].
  static WalletErrorCode fromApiCode(String code) => switch (code) {
    'VALIDATION_ERROR' => WalletErrorCode.validation,
    'IDEMPOTENCY_CONFLICT' => WalletErrorCode.idempotencyConflict,
    'RATE_LIMITED' => WalletErrorCode.rateLimited,
    'NETWORK_UNAVAILABLE' || 'NETWORK_TIMEOUT' => WalletErrorCode.network,
    'UNEXPECTED_RESPONSE' => WalletErrorCode.unexpectedResponse,
    _ => WalletErrorCode.unknown,
  };

  /// `true` si el error es de red.
  bool get isNetwork => this == WalletErrorCode.network;

  /// Clave de traducción del mensaje.
  String get messageKey => switch (this) {
    WalletErrorCode.validation => 'wallet.error.validation',
    WalletErrorCode.idempotencyConflict => 'wallet.error.idempotency',
    WalletErrorCode.rateLimited => 'wallet.error.rate_limited',
    WalletErrorCode.network => 'wallet.error.network',
    WalletErrorCode.unexpectedResponse => 'wallet.error.unexpected',
    WalletErrorCode.unknown => 'wallet.error.unknown',
  };
}
