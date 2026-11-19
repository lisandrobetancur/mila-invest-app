/// Códigos de error de portfolio.
enum PortfolioErrorCode {
  /// Demasiadas peticiones.
  rateLimited,

  /// Sin conexión o timeout.
  network,

  /// La respuesta no tiene la forma del contrato.
  unexpectedResponse,

  /// Cualquier otro error.
  unknown;

  /// Mapea un `code` del contrato. Uno desconocido es [unknown].
  static PortfolioErrorCode fromApiCode(String code) => switch (code) {
    'RATE_LIMITED' => PortfolioErrorCode.rateLimited,
    'NETWORK_UNAVAILABLE' || 'NETWORK_TIMEOUT' => PortfolioErrorCode.network,
    'UNEXPECTED_RESPONSE' => PortfolioErrorCode.unexpectedResponse,
    _ => PortfolioErrorCode.unknown,
  };

  /// `true` si el error es de red.
  bool get isNetwork => this == PortfolioErrorCode.network;

  /// Clave de traducción del mensaje.
  String get messageKey => switch (this) {
    PortfolioErrorCode.rateLimited => 'portfolio.error.rate_limited',
    PortfolioErrorCode.network => 'portfolio.error.network',
    PortfolioErrorCode.unexpectedResponse => 'portfolio.error.unexpected',
    PortfolioErrorCode.unknown => 'portfolio.error.unknown',
  };
}
