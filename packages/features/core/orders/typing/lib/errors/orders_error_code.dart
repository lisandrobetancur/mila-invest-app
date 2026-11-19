/// Códigos de error de orders.
enum OrdersErrorCode {
  /// No alcanza el saldo para la compra.
  insufficientFunds,

  /// No alcanza la posición para la venta.
  insufficientPosition,

  /// El mercado está cerrado.
  marketClosed,

  /// El instrumento no existe.
  instrumentNotFound,

  /// La orden no existe.
  orderNotFound,

  /// La misma clave de idempotencia con otra orden.
  idempotencyConflict,

  /// La orden tiene campos inválidos.
  validation,

  /// Demasiadas peticiones.
  rateLimited,

  /// Sin conexión o timeout.
  network,

  /// La respuesta no tiene la forma del contrato.
  unexpectedResponse,

  /// Cualquier otro error.
  unknown;

  /// Mapea un `code` del contrato (o un `reject_code`). Uno desconocido es
  /// [unknown].
  static OrdersErrorCode fromApiCode(String code) => switch (code) {
    'INSUFFICIENT_FUNDS' => OrdersErrorCode.insufficientFunds,
    'INSUFFICIENT_POSITION' => OrdersErrorCode.insufficientPosition,
    'MARKET_CLOSED' => OrdersErrorCode.marketClosed,
    'INSTRUMENT_NOT_FOUND' => OrdersErrorCode.instrumentNotFound,
    'ORDER_NOT_FOUND' => OrdersErrorCode.orderNotFound,
    'IDEMPOTENCY_CONFLICT' => OrdersErrorCode.idempotencyConflict,
    'VALIDATION_ERROR' => OrdersErrorCode.validation,
    'RATE_LIMITED' => OrdersErrorCode.rateLimited,
    'NETWORK_UNAVAILABLE' || 'NETWORK_TIMEOUT' => OrdersErrorCode.network,
    'UNEXPECTED_RESPONSE' => OrdersErrorCode.unexpectedResponse,
    _ => OrdersErrorCode.unknown,
  };

  /// `true` si el error es de red y conviene reintentar.
  bool get isNetwork => this == OrdersErrorCode.network;

  /// `true` si el recurso no existe.
  bool get isNotFound =>
      this == OrdersErrorCode.instrumentNotFound ||
      this == OrdersErrorCode.orderNotFound;

  /// `true` si el error se resuelve depositando.
  bool get suggestsDeposit => this == OrdersErrorCode.insufficientFunds;

  /// Clave de traducción del mensaje.
  String get messageKey => switch (this) {
    OrdersErrorCode.insufficientFunds => 'orders.error.insufficient_funds',
    OrdersErrorCode.insufficientPosition =>
      'orders.error.insufficient_position',
    OrdersErrorCode.marketClosed => 'orders.error.market_closed',
    OrdersErrorCode.instrumentNotFound => 'orders.error.instrument_not_found',
    OrdersErrorCode.orderNotFound => 'orders.error.order_not_found',
    OrdersErrorCode.idempotencyConflict => 'orders.error.idempotency',
    OrdersErrorCode.validation => 'orders.error.validation',
    OrdersErrorCode.rateLimited => 'orders.error.rate_limited',
    OrdersErrorCode.network => 'orders.error.network',
    OrdersErrorCode.unexpectedResponse => 'orders.error.unexpected',
    OrdersErrorCode.unknown => 'orders.error.unknown',
  };
}
