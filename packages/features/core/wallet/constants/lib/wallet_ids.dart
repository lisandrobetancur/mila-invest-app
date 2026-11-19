/// Identificadores semánticos de wallet (§11.1).
abstract final class WalletIds {
  /// Raíz de la billetera.
  static const String accountsView = 'wallet_accounts_view';

  /// Billetera cargando.
  static const String accountsStateLoading = 'wallet_accounts_state_loading';

  /// Billetera con saldo.
  static const String accountsStateData = 'wallet_accounts_state_data';

  /// Billetera sin saldo.
  static const String accountsStateEmpty = 'wallet_accounts_state_empty';

  /// Billetera con error.
  static const String accountsStateError = 'wallet_accounts_state_error';

  /// Volver desde la billetera.
  static const String accountsBackIconButton =
      'wallet_accounts_back_icon_button';

  /// Badge "Simulado" de la billetera.
  static const String accountsSimulatedText = 'wallet_accounts_simulated_text';

  /// Título del estado vacío.
  static const String accountsEmptyTitleText =
      'wallet_accounts_empty_title_text';

  /// "Hacer un depósito" del estado vacío.
  static const String accountsEmptyDepositButton =
      'wallet_accounts_empty_deposit_button';

  /// Mensaje de error de la billetera.
  static const String accountsErrorText = 'wallet_accounts_error_text';

  /// "Reintentar" de la billetera.
  static const String accountsRetryButton = 'wallet_accounts_retry_button';

  /// Disponible en COP.
  static const String copAvailableText = 'wallet_cop_available_text';

  /// Reservado en COP.
  static const String copReservedText = 'wallet_cop_reserved_text';

  /// Depositar en COP.
  static const String copDepositButton = 'wallet_cop_deposit_button';

  /// Disponible en MXN.
  static const String mxnAvailableText = 'wallet_mxn_available_text';

  /// Reservado en MXN.
  static const String mxnReservedText = 'wallet_mxn_reserved_text';

  /// Depositar en MXN.
  static const String mxnDepositButton = 'wallet_mxn_deposit_button';

  /// Disponible en PEN.
  static const String penAvailableText = 'wallet_pen_available_text';

  /// Reservado en PEN.
  static const String penReservedText = 'wallet_pen_reserved_text';

  /// Depositar en PEN.
  static const String penDepositButton = 'wallet_pen_deposit_button';

  /// Raíz del depósito.
  static const String depositView = 'wallet_deposit_view';

  /// Cerrar el depósito.
  static const String depositCloseIconButton =
      'wallet_deposit_close_icon_button';

  /// Selector de moneda.
  static const String depositCurrencyMenu = 'wallet_deposit_currency_menu';

  /// Moneda COP.
  static const String depositCurrencyCopSegment =
      'wallet_deposit_currency_cop_segment';

  /// Moneda MXN.
  static const String depositCurrencyMxnSegment =
      'wallet_deposit_currency_mxn_segment';

  /// Moneda PEN.
  static const String depositCurrencyPenSegment =
      'wallet_deposit_currency_pen_segment';

  /// Campo del monto.
  static const String depositAmountField = 'wallet_deposit_amount_field';

  /// Saldo disponible en la moneda elegida.
  static const String depositAvailableText = 'wallet_deposit_available_text';

  /// Aviso de simulación del depósito.
  static const String depositDisclaimerText = 'wallet_deposit_disclaimer_text';

  /// Botón "Depositar".
  static const String depositSubmitButton = 'wallet_deposit_submit_button';

  /// Mensaje de error del depósito.
  static const String depositErrorText = 'wallet_deposit_error_text';

  /// Snackbar de depósito realizado.
  static const String depositSuccessSnackbar =
      'wallet_deposit_success_snackbar';

  /// Tarjeta de la cuenta en [currencyCode] (`COP`, `MXN`, `PEN`).
  static String accountItem(String currencyCode) =>
      'wallet_account_item_$currencyCode';

  /// Monto sugerido [amount] (string decimal de la API).
  static String suggestedItem(String amount) =>
      'wallet_deposit_suggested_item_$amount';

  /// Todos los ids estáticos, para el test de unicidad y formato.
  static const List<String> all = <String>[
    accountsView,
    accountsStateLoading,
    accountsStateData,
    accountsStateEmpty,
    accountsStateError,
    accountsBackIconButton,
    accountsSimulatedText,
    accountsEmptyTitleText,
    accountsEmptyDepositButton,
    accountsErrorText,
    accountsRetryButton,
    copAvailableText,
    copReservedText,
    copDepositButton,
    mxnAvailableText,
    mxnReservedText,
    mxnDepositButton,
    penAvailableText,
    penReservedText,
    penDepositButton,
    depositView,
    depositCloseIconButton,
    depositCurrencyMenu,
    depositCurrencyCopSegment,
    depositCurrencyMxnSegment,
    depositCurrencyPenSegment,
    depositAmountField,
    depositAvailableText,
    depositDisclaimerText,
    depositSubmitButton,
    depositErrorText,
    depositSuccessSnackbar,
  ];
}
