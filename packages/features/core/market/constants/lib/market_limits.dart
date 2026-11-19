/// Valores fijos de market.
abstract final class MarketLimits {
  /// Espera del buscador antes de consultar.
  static const Duration searchDebounce = Duration(milliseconds: 300);

  /// Tamaño de página de la lista de instrumentos.
  static const int pageSize = 20;

  /// Fracción del scroll desde la que se pide la página siguiente.
  static const double loadMoreThreshold = 0.8;

  /// Intervalo de refresco de precios por defecto, en segundos.
  static const int defaultPriceRefreshSeconds = 15;

  /// Alto del gráfico de precios del detalle.
  static const double chartHeight = 240;
}
