/// Identificadores semánticos de market (§11.1).
abstract final class MarketIds {
  /// Raíz de la lista.
  static const String listView = 'market_list_view';

  /// Lista cargando.
  static const String listStateLoading = 'market_list_state_loading';

  /// Lista con datos.
  static const String listStateData = 'market_list_state_data';

  /// Lista sin resultados.
  static const String listStateEmpty = 'market_list_state_empty';

  /// Lista con error.
  static const String listStateError = 'market_list_state_error';

  /// Badge "Simulado" de la lista.
  static const String listSimulatedText = 'market_list_simulated_text';

  /// Buscador.
  static const String listSearchField = 'market_list_search_field';

  /// Limpiar el buscador.
  static const String listSearchClearIconButton =
      'market_list_search_clear_icon_button';

  /// Chip de país: todos.
  static const String listCountryAllChip = 'market_list_country_all_chip';

  /// Chip de país: Colombia.
  static const String listCountryCoChip = 'market_list_country_co_chip';

  /// Chip de país: México.
  static const String listCountryMxChip = 'market_list_country_mx_chip';

  /// Chip de país: Perú.
  static const String listCountryPeChip = 'market_list_country_pe_chip';

  /// Chip de tipo: acciones.
  static const String listTypeStockChip = 'market_list_type_stock_chip';

  /// Chip de tipo: ETFs.
  static const String listTypeEtfChip = 'market_list_type_etf_chip';

  /// Estado del mercado de Colombia.
  static const String listStatusCoText = 'market_list_status_co_text';

  /// Estado del mercado de México.
  static const String listStatusMxText = 'market_list_status_mx_text';

  /// Estado del mercado de Perú.
  static const String listStatusPeText = 'market_list_status_pe_text';

  /// Indicador de la página siguiente cargando.
  static const String listLoadingMoreText = 'market_list_loading_more_text';

  /// Error al cargar la página siguiente.
  static const String listLoadMoreErrorText =
      'market_list_load_more_error_text';

  /// Reintentar la página siguiente.
  static const String listLoadMoreRetryButton =
      'market_list_load_more_retry_button';

  /// Título del estado vacío.
  static const String listEmptyTitleText = 'market_list_empty_title_text';

  /// "Limpiar filtros".
  static const String listClearFiltersButton =
      'market_list_clear_filters_button';

  /// Mensaje de error de la lista.
  static const String listErrorText = 'market_list_error_text';

  /// "Reintentar" de la lista.
  static const String listRetryButton = 'market_list_retry_button';

  /// Raíz del detalle.
  static const String detailView = 'market_detail_view';

  /// Detalle cargando.
  static const String detailStateLoading = 'market_detail_state_loading';

  /// Detalle con datos.
  static const String detailStateData = 'market_detail_state_data';

  /// Instrumento no encontrado.
  static const String detailStateEmpty = 'market_detail_state_empty';

  /// Detalle con error.
  static const String detailStateError = 'market_detail_state_error';

  /// Volver desde el detalle.
  static const String detailBackIconButton = 'market_detail_back_icon_button';

  /// Badge "Simulado" del detalle.
  static const String detailSimulatedText = 'market_detail_simulated_text';

  /// Ticker.
  static const String detailTickerText = 'market_detail_ticker_text';

  /// Nombre del emisor.
  static const String detailNameText = 'market_detail_name_text';

  /// País del instrumento.
  static const String detailCountryText = 'market_detail_country_text';

  /// Último precio.
  static const String detailPriceText = 'market_detail_price_text';

  /// Variación del día.
  static const String detailChangeText = 'market_detail_change_text';

  /// Estado del mercado del instrumento.
  static const String detailStatusText = 'market_detail_status_text';

  /// Raíz del gráfico de precios.
  static const String detailChart = 'market_detail_chart';

  /// Error del gráfico.
  static const String detailChartErrorText = 'market_detail_chart_error_text';

  /// Selector de rango del gráfico.
  static const String detailRangeMenu = 'market_detail_range_menu';

  /// Rango 1D.
  static const String detailRange1dSegment = 'market_detail_range_1d_segment';

  /// Rango 1S.
  static const String detailRange1wSegment = 'market_detail_range_1w_segment';

  /// Rango 1M.
  static const String detailRange1mSegment = 'market_detail_range_1m_segment';

  /// Rango 3M.
  static const String detailRange3mSegment = 'market_detail_range_3m_segment';

  /// Rango 1A.
  static const String detailRange1ySegment = 'market_detail_range_1y_segment';

  /// Apertura.
  static const String detailOpenText = 'market_detail_open_text';

  /// Máximo del día.
  static const String detailHighText = 'market_detail_high_text';

  /// Mínimo del día.
  static const String detailLowText = 'market_detail_low_text';

  /// Cierre anterior.
  static const String detailPrevCloseText = 'market_detail_prev_close_text';

  /// Volumen.
  static const String detailVolumeText = 'market_detail_volume_text';

  /// Descripción del emisor.
  static const String detailDescriptionText = 'market_detail_description_text';

  /// Cantidad en posición.
  static const String detailPositionQuantityText =
      'market_detail_position_quantity_text';

  /// Valor de mercado de la posición.
  static const String detailPositionValueText =
      'market_detail_position_value_text';

  /// P&L no realizado de la posición.
  static const String detailPositionPnlText = 'market_detail_position_pnl_text';

  /// Botón "Comprar".
  static const String detailBuyButton = 'market_detail_buy_button';

  /// Botón "Vender".
  static const String detailSellButton = 'market_detail_sell_button';

  /// Motivo por el que no se puede operar (mercado cerrado).
  static const String detailClosedReasonText =
      'market_detail_closed_reason_text';

  /// Título del estado "no encontrado".
  static const String detailNotFoundTitleText =
      'market_detail_not_found_title_text';

  /// Volver al mercado desde "no encontrado".
  static const String detailBackToMarketButton =
      'market_detail_back_to_market_button';

  /// Mensaje de error del detalle.
  static const String detailErrorText = 'market_detail_error_text';

  /// "Reintentar" del detalle.
  static const String detailRetryButton = 'market_detail_retry_button';

  /// Ítem de la lista para el instrumento [instrumentId].
  static String listInstrumentItem(String instrumentId) =>
      'market_list_instrument_item_$instrumentId';

  /// Todos los ids estáticos, para el test de unicidad y formato.
  static const List<String> all = <String>[
    listView,
    listStateLoading,
    listStateData,
    listStateEmpty,
    listStateError,
    listSimulatedText,
    listSearchField,
    listSearchClearIconButton,
    listCountryAllChip,
    listCountryCoChip,
    listCountryMxChip,
    listCountryPeChip,
    listTypeStockChip,
    listTypeEtfChip,
    listStatusCoText,
    listStatusMxText,
    listStatusPeText,
    listLoadingMoreText,
    listLoadMoreErrorText,
    listLoadMoreRetryButton,
    listEmptyTitleText,
    listClearFiltersButton,
    listErrorText,
    listRetryButton,
    detailView,
    detailStateLoading,
    detailStateData,
    detailStateEmpty,
    detailStateError,
    detailBackIconButton,
    detailSimulatedText,
    detailTickerText,
    detailNameText,
    detailCountryText,
    detailPriceText,
    detailChangeText,
    detailStatusText,
    detailChart,
    detailChartErrorText,
    detailRangeMenu,
    detailRange1dSegment,
    detailRange1wSegment,
    detailRange1mSegment,
    detailRange3mSegment,
    detailRange1ySegment,
    detailOpenText,
    detailHighText,
    detailLowText,
    detailPrevCloseText,
    detailVolumeText,
    detailDescriptionText,
    detailPositionQuantityText,
    detailPositionValueText,
    detailPositionPnlText,
    detailBuyButton,
    detailSellButton,
    detailClosedReasonText,
    detailNotFoundTitleText,
    detailBackToMarketButton,
    detailErrorText,
    detailRetryButton,
  ];
}
