/// Valores fijos de transactions.
abstract final class TransactionsLimits {
  /// Tamaño de página.
  static const int pageSize = 20;

  /// Fracción del scroll desde la que se pide la página siguiente.
  static const double loadMoreThreshold = 0.8;
}
