/// Códigos de error de market.
enum MarketErrorCode {
  /// El instrumento no existe: la vista muestra "no encontrado".
  instrumentNotFound,

  /// Demasiadas peticiones.
  rateLimited,

  /// Sin conexión o timeout.
  network,

  /// La respuesta no tiene la forma del contrato.
  unexpectedResponse,

  /// Cualquier otro error.
  unknown;

  /// Mapea un `code` del contrato. Uno desconocido es [unknown].
  static MarketErrorCode fromApiCode(String code) => switch (code) {
    'INSTRUMENT_NOT_FOUND' => MarketErrorCode.instrumentNotFound,
    'RATE_LIMITED' => MarketErrorCode.rateLimited,
    'NETWORK_UNAVAILABLE' || 'NETWORK_TIMEOUT' => MarketErrorCode.network,
    'UNEXPECTED_RESPONSE' => MarketErrorCode.unexpectedResponse,
    _ => MarketErrorCode.unknown,
  };

  /// `true` si el error es de red.
  bool get isNetwork => this == MarketErrorCode.network;

  /// `true` si el instrumento no existe.
  bool get isNotFound => this == MarketErrorCode.instrumentNotFound;

  /// Clave de traducción del mensaje.
  String get messageKey => switch (this) {
    MarketErrorCode.instrumentNotFound => 'market.error.not_found',
    MarketErrorCode.rateLimited => 'market.error.rate_limited',
    MarketErrorCode.network => 'market.error.network',
    MarketErrorCode.unexpectedResponse => 'market.error.unexpected',
    MarketErrorCode.unknown => 'market.error.unknown',
  };
}
