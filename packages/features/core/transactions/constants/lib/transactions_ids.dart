/// Identificadores semánticos de transactions (§11.1).
abstract final class TransactionsIds {
  /// Raíz de la lista de movimientos.
  static const String listView = 'transactions_list_view';

  /// Movimientos cargando.
  static const String listStateLoading = 'transactions_list_state_loading';

  /// Movimientos con datos.
  static const String listStateData = 'transactions_list_state_data';

  /// Sin movimientos.
  static const String listStateEmpty = 'transactions_list_state_empty';

  /// Movimientos con error.
  static const String listStateError = 'transactions_list_state_error';

  /// Badge "Simulado".
  static const String listSimulatedText = 'transactions_list_simulated_text';

  /// Selector de sección de la tab Actividad.
  static const String listSectionMenu = 'transactions_list_section_menu';

  /// Sección "Movimientos" del selector de Actividad.
  static const String listMovementsTab = 'transactions_list_movements_tab';

  /// Sección "Órdenes" del selector de Actividad.
  static const String listOrdersTab = 'transactions_list_orders_tab';

  /// Filtro de tipo: todos.
  static const String listTypeAllChip = 'transactions_list_type_all_chip';

  /// Filtro de tipo: depósitos.
  static const String listTypeDepositChip =
      'transactions_list_type_deposit_chip';

  /// Filtro de tipo: compras.
  static const String listTypeBuyChip = 'transactions_list_type_buy_chip';

  /// Filtro de tipo: ventas.
  static const String listTypeSellChip = 'transactions_list_type_sell_chip';

  /// Filtro de tipo: comisiones.
  static const String listTypeFeeChip = 'transactions_list_type_fee_chip';

  /// Rango: todo.
  static const String listRangeAllChip = 'transactions_list_range_all_chip';

  /// Rango: últimos 7 días.
  static const String listRange7dChip = 'transactions_list_range_7d_chip';

  /// Rango: últimos 30 días.
  static const String listRange30dChip = 'transactions_list_range_30d_chip';

  /// Rango: últimos 90 días.
  static const String listRange90dChip = 'transactions_list_range_90d_chip';

  /// Página siguiente cargando.
  static const String listLoadingMoreText =
      'transactions_list_loading_more_text';

  /// Error de la página siguiente.
  static const String listLoadMoreErrorText =
      'transactions_list_load_more_error_text';

  /// Reintentar la página siguiente.
  static const String listLoadMoreRetryButton =
      'transactions_list_load_more_retry_button';

  /// Título del estado vacío.
  static const String listEmptyTitleText = 'transactions_list_empty_title_text';

  /// "Depositar" del estado vacío.
  static const String listEmptyDepositButton =
      'transactions_list_empty_deposit_button';

  /// "Limpiar filtros" del estado vacío con filtros.
  static const String listClearFiltersButton =
      'transactions_list_clear_filters_button';

  /// Mensaje de error.
  static const String listErrorText = 'transactions_list_error_text';

  /// "Reintentar".
  static const String listRetryButton = 'transactions_list_retry_button';

  /// Encabezado del día [isoDate] (`2026-11-18`).
  static String dayItem(String isoDate) => 'transactions_day_item_$isoDate';

  /// Movimiento [transactionId].
  static String listItem(String transactionId) =>
      'transactions_list_item_$transactionId';

  /// Monto de un movimiento.
  static String listItemAmountText(String transactionId) =>
      '${listItem(transactionId)}_amount_text';

  /// Descripción de un movimiento.
  static String listItemDescriptionText(String transactionId) =>
      '${listItem(transactionId)}_description_text';

  /// Todos los ids estáticos, para el test de unicidad y formato.
  static const List<String> all = <String>[
    listView,
    listStateLoading,
    listStateData,
    listStateEmpty,
    listStateError,
    listSimulatedText,
    listSectionMenu,
    listMovementsTab,
    listOrdersTab,
    listTypeAllChip,
    listTypeDepositChip,
    listTypeBuyChip,
    listTypeSellChip,
    listTypeFeeChip,
    listRangeAllChip,
    listRange7dChip,
    listRange30dChip,
    listRange90dChip,
    listLoadingMoreText,
    listLoadMoreErrorText,
    listLoadMoreRetryButton,
    listEmptyTitleText,
    listEmptyDepositButton,
    listClearFiltersButton,
    listErrorText,
    listRetryButton,
  ];
}
