/// Códigos de error de transactions.
enum TransactionsErrorCode {
  /// Demasiadas peticiones.
  rateLimited,

  /// Sin conexión o timeout.
  network,

  /// La respuesta no tiene la forma del contrato.
  unexpectedResponse,

  /// Cualquier otro error.
  unknown;

  /// Mapea un `code` del contrato. Uno desconocido es [unknown].
  static TransactionsErrorCode fromApiCode(String code) => switch (code) {
    'RATE_LIMITED' => TransactionsErrorCode.rateLimited,
    'NETWORK_UNAVAILABLE' || 'NETWORK_TIMEOUT' => TransactionsErrorCode.network,
    'UNEXPECTED_RESPONSE' => TransactionsErrorCode.unexpectedResponse,
    _ => TransactionsErrorCode.unknown,
  };

  /// `true` si el error es de red.
  bool get isNetwork => this == TransactionsErrorCode.network;

  /// Clave de traducción del mensaje.
  String get messageKey => switch (this) {
    TransactionsErrorCode.rateLimited => 'transactions.error.rate_limited',
    TransactionsErrorCode.network => 'transactions.error.network',
    TransactionsErrorCode.unexpectedResponse => 'transactions.error.unexpected',
    TransactionsErrorCode.unknown => 'transactions.error.unknown',
  };
}
