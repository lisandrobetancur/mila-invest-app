/// Identificadores semánticos de orders (§11.1).
abstract final class OrdersIds {
  /// Raíz del ticket.
  static const String ticketView = 'orders_ticket_view';

  /// Ticket cargando el instrumento.
  static const String ticketStateLoading = 'orders_ticket_state_loading';

  /// Ticket listo para editar.
  static const String ticketStateData = 'orders_ticket_state_data';

  /// Instrumento no encontrado.
  static const String ticketStateEmpty = 'orders_ticket_state_empty';

  /// Ticket con error de carga.
  static const String ticketStateError = 'orders_ticket_state_error';

  /// Cerrar el ticket.
  static const String ticketCloseIconButton = 'orders_ticket_close_icon_button';

  /// Badge "Simulado" del ticket.
  static const String ticketSimulatedText = 'orders_ticket_simulated_text';

  /// Ticker y nombre del instrumento.
  static const String ticketInstrumentText = 'orders_ticket_instrument_text';

  /// Último precio del instrumento.
  static const String ticketPriceText = 'orders_ticket_price_text';

  /// Selector de lado.
  static const String ticketSideMenu = 'orders_ticket_side_menu';

  /// Lado comprar.
  static const String ticketSideBuySegment = 'orders_ticket_side_buy_segment';

  /// Lado vender.
  static const String ticketSideSellSegment = 'orders_ticket_side_sell_segment';

  /// Campo de cantidad.
  static const String ticketQuantityField = 'orders_ticket_quantity_field';

  /// Restar una unidad.
  static const String ticketQuantityDecreaseStepper =
      'orders_ticket_quantity_decrease_stepper';

  /// Sumar una unidad.
  static const String ticketQuantityIncreaseStepper =
      'orders_ticket_quantity_increase_stepper';

  /// Saldo disponible en la moneda del instrumento.
  static const String ticketAvailableText = 'orders_ticket_available_text';

  /// Cantidad en posición.
  static const String ticketPositionText = 'orders_ticket_position_text';

  /// Preview calculándose.
  static const String ticketPreviewLoadingText =
      'orders_ticket_preview_loading_text';

  /// Error del preview.
  static const String ticketPreviewErrorText =
      'orders_ticket_preview_error_text';

  /// Aviso de saldo bajo después de la orden.
  static const String ticketLowBalanceText = 'orders_ticket_low_balance_text';

  /// "Depositar", cuando no alcanza el saldo.
  static const String ticketDepositButton = 'orders_ticket_deposit_button';

  /// Motivo por el que no se puede operar (mercado cerrado).
  static const String ticketClosedReasonText =
      'orders_ticket_closed_reason_text';

  /// "Revisar orden".
  static const String ticketReviewButton = 'orders_ticket_review_button';

  /// Título del estado "no encontrado".
  static const String ticketNotFoundTitleText =
      'orders_ticket_not_found_title_text';

  /// Mensaje de error de carga.
  static const String ticketErrorText = 'orders_ticket_error_text';

  /// "Reintentar" la carga.
  static const String ticketRetryButton = 'orders_ticket_retry_button';

  /// Raíz del resumen de la orden.
  static const String summaryPanel = 'orders_summary_panel';

  /// Precio estimado o de ejecución.
  static const String summaryPriceText = 'orders_summary_price_text';

  /// Monto bruto.
  static const String summaryGrossText = 'orders_summary_gross_text';

  /// Comisión.
  static const String summaryCommissionText = 'orders_summary_commission_text';

  /// Total.
  static const String summaryTotalText = 'orders_summary_total_text';

  /// Saldo resultante.
  static const String summaryAvailableAfterText =
      'orders_summary_available_after_text';

  /// Raíz de la confirmación.
  static const String confirmView = 'orders_confirm_view';

  /// Volver de la confirmación al ticket.
  static const String confirmBackIconButton = 'orders_confirm_back_icon_button';

  /// Lado y cantidad que se confirman.
  static const String confirmOrderText = 'orders_confirm_order_text';

  /// Aviso de simulación de la confirmación.
  static const String confirmDisclaimerText = 'orders_confirm_disclaimer_text';

  /// "Confirmar compra" / "Confirmar venta".
  static const String confirmSubmitButton = 'orders_confirm_submit_button';

  /// Error al enviar la orden.
  static const String confirmErrorText = 'orders_confirm_error_text';

  /// Raíz del resultado.
  static const String resultView = 'orders_result_view';

  /// Estado de la orden (ejecutada, rechazada, pendiente, cancelada).
  static const String resultStatusText = 'orders_result_status_text';

  /// Diferencia entre el precio estimado y el de ejecución.
  static const String resultPriceDifferenceText =
      'orders_result_price_difference_text';

  /// Motivo del rechazo.
  static const String resultRejectReasonText =
      'orders_result_reject_reason_text';

  /// "Ver portafolio".
  static const String resultPortfolioButton = 'orders_result_portfolio_button';

  /// Acción sugerida tras un rechazo (por ejemplo, "Depositar").
  static const String resultSuggestedActionButton =
      'orders_result_suggested_action_button';

  /// "Listo": cierra el ticket.
  static const String resultDoneButton = 'orders_result_done_button';

  /// Raíz del historial.
  static const String historyView = 'orders_history_view';

  /// Historial cargando.
  static const String historyStateLoading = 'orders_history_state_loading';

  /// Historial con órdenes.
  static const String historyStateData = 'orders_history_state_data';

  /// Historial vacío.
  static const String historyStateEmpty = 'orders_history_state_empty';

  /// Historial con error.
  static const String historyStateError = 'orders_history_state_error';

  /// Sección "Movimientos" del selector de Actividad.
  static const String historyMovementsTab = 'orders_history_movements_tab';

  /// Sección "Órdenes" del selector de Actividad.
  static const String historyOrdersTab = 'orders_history_orders_tab';

  /// Filtro: todas.
  static const String historyStatusAllChip = 'orders_history_status_all_chip';

  /// Filtro: pendientes.
  static const String historyStatusPendingChip =
      'orders_history_status_pending_chip';

  /// Filtro: ejecutadas.
  static const String historyStatusFilledChip =
      'orders_history_status_filled_chip';

  /// Filtro: rechazadas.
  static const String historyStatusRejectedChip =
      'orders_history_status_rejected_chip';

  /// Filtro: canceladas.
  static const String historyStatusCancelledChip =
      'orders_history_status_cancelled_chip';

  /// Página siguiente cargando.
  static const String historyLoadingMoreText =
      'orders_history_loading_more_text';

  /// Error al cargar la página siguiente.
  static const String historyLoadMoreErrorText =
      'orders_history_load_more_error_text';

  /// Reintentar la página siguiente.
  static const String historyLoadMoreRetryButton =
      'orders_history_load_more_retry_button';

  /// Título del estado vacío.
  static const String historyEmptyTitleText = 'orders_history_empty_title_text';

  /// "Explorar mercado" del estado vacío.
  static const String historyExploreButton = 'orders_history_explore_button';

  /// Mensaje de error.
  static const String historyErrorText = 'orders_history_error_text';

  /// "Reintentar".
  static const String historyRetryButton = 'orders_history_retry_button';

  /// Raíz del detalle de orden.
  static const String detailView = 'orders_detail_view';

  /// Detalle cargando.
  static const String detailStateLoading = 'orders_detail_state_loading';

  /// Detalle con datos.
  static const String detailStateData = 'orders_detail_state_data';

  /// Orden no encontrada.
  static const String detailStateEmpty = 'orders_detail_state_empty';

  /// Detalle con error.
  static const String detailStateError = 'orders_detail_state_error';

  /// Volver desde el detalle.
  static const String detailBackIconButton = 'orders_detail_back_icon_button';

  /// Estado de la orden.
  static const String detailStatusText = 'orders_detail_status_text';

  /// Instrumento de la orden.
  static const String detailInstrumentText = 'orders_detail_instrument_text';

  /// Lado de la orden.
  static const String detailSideText = 'orders_detail_side_text';

  /// Cantidad de la orden.
  static const String detailQuantityText = 'orders_detail_quantity_text';

  /// Fecha de creación.
  static const String detailCreatedText = 'orders_detail_created_text';

  /// Fecha de ejecución.
  static const String detailFilledText = 'orders_detail_filled_text';

  /// Motivo del rechazo.
  static const String detailRejectReasonText =
      'orders_detail_reject_reason_text';

  /// Ver el instrumento de la orden.
  static const String detailInstrumentButton =
      'orders_detail_instrument_button';

  /// Título del estado "no encontrada".
  static const String detailNotFoundTitleText =
      'orders_detail_not_found_title_text';

  /// Volver al historial desde "no encontrada".
  static const String detailBackToHistoryButton =
      'orders_detail_back_to_history_button';

  /// Mensaje de error del detalle.
  static const String detailErrorText = 'orders_detail_error_text';

  /// "Reintentar" del detalle.
  static const String detailRetryButton = 'orders_detail_retry_button';

  /// Ítem del historial para la orden [orderId].
  static String historyItem(String orderId) => 'orders_history_item_$orderId';

  /// Estado de un ítem del historial.
  static String historyItemStatusText(String orderId) =>
      '${historyItem(orderId)}_status_text';

  /// Total de un ítem del historial.
  static String historyItemTotalText(String orderId) =>
      '${historyItem(orderId)}_total_text';

  /// Todos los ids estáticos, para el test de unicidad y formato.
  static const List<String> all = <String>[
    ticketView,
    ticketStateLoading,
    ticketStateData,
    ticketStateEmpty,
    ticketStateError,
    ticketCloseIconButton,
    ticketSimulatedText,
    ticketInstrumentText,
    ticketPriceText,
    ticketSideMenu,
    ticketSideBuySegment,
    ticketSideSellSegment,
    ticketQuantityField,
    ticketQuantityDecreaseStepper,
    ticketQuantityIncreaseStepper,
    ticketAvailableText,
    ticketPositionText,
    ticketPreviewLoadingText,
    ticketPreviewErrorText,
    ticketLowBalanceText,
    ticketDepositButton,
    ticketClosedReasonText,
    ticketReviewButton,
    ticketNotFoundTitleText,
    ticketErrorText,
    ticketRetryButton,
    summaryPanel,
    summaryPriceText,
    summaryGrossText,
    summaryCommissionText,
    summaryTotalText,
    summaryAvailableAfterText,
    confirmView,
    confirmBackIconButton,
    confirmOrderText,
    confirmDisclaimerText,
    confirmSubmitButton,
    confirmErrorText,
    resultView,
    resultStatusText,
    resultPriceDifferenceText,
    resultRejectReasonText,
    resultPortfolioButton,
    resultSuggestedActionButton,
    resultDoneButton,
    historyView,
    historyStateLoading,
    historyStateData,
    historyStateEmpty,
    historyStateError,
    historyMovementsTab,
    historyOrdersTab,
    historyStatusAllChip,
    historyStatusPendingChip,
    historyStatusFilledChip,
    historyStatusRejectedChip,
    historyStatusCancelledChip,
    historyLoadingMoreText,
    historyLoadMoreErrorText,
    historyLoadMoreRetryButton,
    historyEmptyTitleText,
    historyExploreButton,
    historyErrorText,
    historyRetryButton,
    detailView,
    detailStateLoading,
    detailStateData,
    detailStateEmpty,
    detailStateError,
    detailBackIconButton,
    detailStatusText,
    detailInstrumentText,
    detailSideText,
    detailQuantityText,
    detailCreatedText,
    detailFilledText,
    detailRejectReasonText,
    detailInstrumentButton,
    detailNotFoundTitleText,
    detailBackToHistoryButton,
    detailErrorText,
    detailRetryButton,
  ];
}
