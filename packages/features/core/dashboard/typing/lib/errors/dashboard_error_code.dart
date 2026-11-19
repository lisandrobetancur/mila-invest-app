/// Códigos de error de dashboard.
enum DashboardErrorCode {
  /// Demasiadas peticiones.
  rateLimited,

  /// Sin conexión o timeout.
  network,

  /// La respuesta no tiene la forma del contrato.
  unexpectedResponse,

  /// Cualquier otro error.
  unknown;

  /// Mapea un `code` del contrato. Uno desconocido es [unknown].
  static DashboardErrorCode fromApiCode(String code) => switch (code) {
    'RATE_LIMITED' => DashboardErrorCode.rateLimited,
    'NETWORK_UNAVAILABLE' || 'NETWORK_TIMEOUT' => DashboardErrorCode.network,
    'UNEXPECTED_RESPONSE' => DashboardErrorCode.unexpectedResponse,
    _ => DashboardErrorCode.unknown,
  };

  /// `true` si el error es de red.
  bool get isNetwork => this == DashboardErrorCode.network;

  /// Clave de traducción del mensaje.
  String get messageKey => switch (this) {
    DashboardErrorCode.rateLimited => 'dashboard.error.rate_limited',
    DashboardErrorCode.network => 'dashboard.error.network',
    DashboardErrorCode.unexpectedResponse => 'dashboard.error.unexpected',
    DashboardErrorCode.unknown => 'dashboard.error.unknown',
  };
}
