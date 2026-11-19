/// Rutas de orders.
abstract final class OrdersRoutes {
  /// Path del ticket de orden (hoja modal, full-screen).
  static const String ticketPath =
      '/orders/ticket/:$instrumentIdParam/:$sideParam';

  /// Nombre de la ruta del ticket.
  static const String ticketName = 'orders.ticket';

  /// Path del historial de órdenes, dentro de la tab Actividad.
  static const String historyPath = '/activity/orders';

  /// Nombre de la ruta del historial.
  static const String historyName = 'orders.history';

  /// Path del detalle de una orden, relativo al historial.
  static const String detailSubPath = ':$orderIdParam';

  /// Nombre de la ruta del detalle.
  static const String detailName = 'orders.detail';

  /// Parámetro con el id del instrumento.
  static const String instrumentIdParam = 'instrumentId';

  /// Parámetro con el lado (`buy` / `sell`).
  static const String sideParam = 'side';

  /// Parámetro con el id de la orden.
  static const String orderIdParam = 'orderId';

  /// Parámetro de query del filtro por estado del historial.
  static const String statusQuery = 'status';

  /// Ubicación del ticket de [instrumentId] para el lado [side].
  static String ticketLocation(String instrumentId, String side) =>
      '/orders/ticket/${Uri.encodeComponent(instrumentId)}/$side';

  /// Ubicación del detalle de la orden [orderId].
  static String detailLocation(String orderId) =>
      '$historyPath/${Uri.encodeComponent(orderId)}';
}
