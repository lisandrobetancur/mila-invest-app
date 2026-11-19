part of 'deposit.dart';

/// Controller del depósito (el argumento es la moneda preseleccionada).
///
/// Al depositar invalida `accountsProvider`: la billetera, el ticket de orden
/// y las vistas con movimientos se enteran de que el saldo cambió.
class DepositViewModel
    extends AutoDisposeFamilyViewModel<DepositState, Currency> {
  late IWalletService _service;
  late WalletNavigator _navigator;
  late AppLogger _logger;

  @override
  DepositState initState() => DepositState(currency: arg);

  @override
  void postInit() {
    _service = ref.read(walletServiceProvider);
    _navigator = ref.read(walletNavigatorProvider.notifier);
    _logger = ref.read(loggerProvider);
    runPostBuild(_loadAvailable);
  }

  /// Cierra el depósito.
  void close() => _navigator.close();

  /// Cambia la moneda.
  Future<void> setCurrency(Currency currency) async {
    if (currency == state.currency) {
      return;
    }
    state = state.copyWith(
      currency: currency,
      amountText: '',
      available: null,
      showValidation: false,
      errorKey: null,
    );
    await _loadAvailable();
  }

  /// Cambia el monto.
  void setAmountText(String value) =>
      state = state.copyWith(amountText: value, errorKey: null);

  /// Deposita. Un segundo toque en vuelo no hace nada.
  ///
  /// Devuelve `true` si el depósito se hizo.
  Future<bool> submit() async {
    if (state.submitStatus.isSubmitting) {
      return false;
    }
    state = state.copyWith(showValidation: true, errorKey: null);
    final Money? amount = state.amount;
    if (amount == null || state.amountErrorKey != null) {
      return false;
    }
    final Object key = mountedKey;
    state = state.copyWith(submitStatus: SubmitStatus.submitting);
    try {
      final DepositReceipt receipt = await _service.deposit(amount);
      ref.invalidate(accountsProvider);
      if (!isMounted(key)) {
        return true;
      }
      state = state.copyWith(
        submitStatus: SubmitStatus.success,
        receipt: receipt,
      );
      return true;
    } on WalletException catch (error, stackTrace) {
      _logger.error('wallet.deposit', error, stackTrace);
      if (isMounted(key)) {
        state = state.copyWith(
          submitStatus: SubmitStatus.failure,
          errorKey: error.code.messageKey,
        );
      }
      return false;
    }
  }

  /// Usa un monto sugerido.
  void useSuggestion(String amount) => setAmountText(amount);

  Future<void> _loadAvailable() async {
    final Object key = mountedKey;
    final Currency currency = state.currency;
    try {
      final List<Account> accounts = await ref.read(accountsProvider.future);
      if (isMounted(key) && currency == state.currency) {
        state = state.copyWith(
          available: accounts.inCurrency(currency)?.available,
        );
      }
    } on Exception catch (error) {
      _logger.warn('wallet.deposit.available', error);
    }
  }
}
