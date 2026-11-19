/// Identificadores semánticos de dashboard (§11.1).
abstract final class DashboardIds {
  /// Raíz del inicio.
  static const String homeView = 'dashboard_home_view';

  /// Inicio cargando.
  static const String homeStateLoading = 'dashboard_home_state_loading';

  /// Inicio con datos.
  static const String homeStateData = 'dashboard_home_state_data';

  /// Usuario nuevo: sin saldo ni inversiones.
  static const String homeStateEmpty = 'dashboard_home_state_empty';

  /// Inicio con error.
  static const String homeStateError = 'dashboard_home_state_error';

  /// Saludo.
  static const String homeGreetingText = 'dashboard_home_greeting_text';

  /// Badge "Simulado".
  static const String homeSimulatedText = 'dashboard_home_simulated_text';

  /// Abrir la billetera.
  static const String homeWalletIconButton =
      'dashboard_home_wallet_icon_button';

  /// Abrir ajustes.
  static const String homeSettingsIconButton =
      'dashboard_home_settings_icon_button';

  /// Tarjeta del valor total.
  static const String homeTotalTile = 'dashboard_home_total_tile';

  /// Valor total.
  static const String homeTotalText = 'dashboard_home_total_text';

  /// Variación del día.
  static const String homeDayChangeText = 'dashboard_home_day_change_text';

  /// Distribución compacta.
  static const String homeAllocationChart = 'dashboard_home_allocation_chart';

  /// Título de los que más suben.
  static const String homeGainersTitleText =
      'dashboard_home_gainers_title_text';

  /// Título de los que más bajan.
  static const String homeLosersTitleText = 'dashboard_home_losers_title_text';

  /// Título de las últimas transacciones.
  static const String homeRecentTitleText = 'dashboard_home_recent_title_text';

  /// "Ver todo" de las últimas transacciones.
  static const String homeRecentAllButton = 'dashboard_home_recent_all_button';

  /// Título de la tarjeta "Haz tu primer depósito".
  static const String homeEmptyTitleText = 'dashboard_home_empty_title_text';

  /// "Depositar" del usuario nuevo.
  static const String homeEmptyDepositButton =
      'dashboard_home_empty_deposit_button';

  /// Mensaje de error.
  static const String homeErrorText = 'dashboard_home_error_text';

  /// "Reintentar".
  static const String homeRetryButton = 'dashboard_home_retry_button';

  /// Instrumento [instrumentId] entre los que más suben o bajan.
  static String moverItem(String instrumentId) =>
      'dashboard_mover_item_$instrumentId';

  /// Transacción reciente [transactionId].
  static String recentItem(String transactionId) =>
      'dashboard_recent_item_$transactionId';

  /// Monto de una transacción reciente.
  static String recentItemAmountText(String transactionId) =>
      '${recentItem(transactionId)}_amount_text';

  /// Porción de la distribución de tipo [type].
  static String allocationItem(String type) =>
      'dashboard_allocation_item_$type';

  /// Todos los ids estáticos, para el test de unicidad y formato.
  static const List<String> all = <String>[
    homeView,
    homeStateLoading,
    homeStateData,
    homeStateEmpty,
    homeStateError,
    homeGreetingText,
    homeSimulatedText,
    homeWalletIconButton,
    homeSettingsIconButton,
    homeTotalTile,
    homeTotalText,
    homeDayChangeText,
    homeAllocationChart,
    homeGainersTitleText,
    homeLosersTitleText,
    homeRecentTitleText,
    homeRecentAllButton,
    homeEmptyTitleText,
    homeEmptyDepositButton,
    homeErrorText,
    homeRetryButton,
  ];
}
