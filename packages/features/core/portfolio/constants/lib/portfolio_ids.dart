/// Identificadores semánticos de portfolio (§11.1).
abstract final class PortfolioIds {
  /// Raíz del portafolio.
  static const String overviewView = 'portfolio_overview_view';

  /// Portafolio cargando.
  static const String overviewStateLoading = 'portfolio_overview_state_loading';

  /// Portafolio con datos.
  static const String overviewStateData = 'portfolio_overview_state_data';

  /// Portafolio sin inversiones.
  static const String overviewStateEmpty = 'portfolio_overview_state_empty';

  /// Portafolio con error.
  static const String overviewStateError = 'portfolio_overview_state_error';

  /// Badge "Simulado".
  static const String overviewSimulatedText =
      'portfolio_overview_simulated_text';

  /// Tarjeta del valor total.
  static const String overviewTotalTile = 'portfolio_overview_total_tile';

  /// Valor total en moneda base.
  static const String overviewTotalText = 'portfolio_overview_total_text';

  /// Variación del día.
  static const String overviewDayChangeText =
      'portfolio_overview_day_change_text';

  /// Efectivo.
  static const String overviewCashText = 'portfolio_overview_cash_text';

  /// Invertido.
  static const String overviewInvestedText = 'portfolio_overview_invested_text';

  /// Gráfico de distribución.
  static const String overviewAllocationChart =
      'portfolio_overview_allocation_chart';

  /// Nota de los tipos de cambio usados.
  static const String overviewFxText = 'portfolio_overview_fx_text';

  /// Título del estado vacío.
  static const String overviewEmptyTitleText =
      'portfolio_overview_empty_title_text';

  /// "Explorar mercado".
  static const String overviewExploreButton =
      'portfolio_overview_explore_button';

  /// Mensaje de error.
  static const String overviewErrorText = 'portfolio_overview_error_text';

  /// "Reintentar".
  static const String overviewRetryButton = 'portfolio_overview_retry_button';

  /// Posición en el instrumento [instrumentId].
  static String positionItem(String instrumentId) =>
      'portfolio_position_item_$instrumentId';

  /// Cantidad de una posición.
  static String positionQuantityText(String instrumentId) =>
      '${positionItem(instrumentId)}_quantity_text';

  /// Costo promedio de una posición.
  static String positionAvgCostText(String instrumentId) =>
      '${positionItem(instrumentId)}_avg_cost_text';

  /// Valor de mercado de una posición.
  static String positionValueText(String instrumentId) =>
      '${positionItem(instrumentId)}_value_text';

  /// P&L no realizado de una posición.
  static String positionPnlText(String instrumentId) =>
      '${positionItem(instrumentId)}_pnl_text';

  /// Porción de la distribución de tipo [type] (`STOCK`, `ETF`, `CASH`).
  static String allocationItem(String type) =>
      'portfolio_allocation_item_$type';

  /// Todos los ids estáticos, para el test de unicidad y formato.
  static const List<String> all = <String>[
    overviewView,
    overviewStateLoading,
    overviewStateData,
    overviewStateEmpty,
    overviewStateError,
    overviewSimulatedText,
    overviewTotalTile,
    overviewTotalText,
    overviewDayChangeText,
    overviewCashText,
    overviewInvestedText,
    overviewAllocationChart,
    overviewFxText,
    overviewEmptyTitleText,
    overviewExploreButton,
    overviewErrorText,
    overviewRetryButton,
  ];
}
