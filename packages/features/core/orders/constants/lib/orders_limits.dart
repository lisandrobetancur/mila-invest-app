/// Reglas fijas de las órdenes de la fase 1 (§7.6).
abstract final class OrdersLimits {
  /// Cantidad mínima.
  static const int minQuantity = 1;

  /// Cantidad máxima.
  static const int maxQuantity = 1000000;

  /// Espera del preview automático después de cambiar el ticket.
  static const Duration previewDebounce = Duration(milliseconds: 400);

  /// Tamaño de página del historial.
  static const int pageSize = 20;

  /// Fracción del scroll desde la que se pide la página siguiente.
  static const double loadMoreThreshold = 0.8;
}
