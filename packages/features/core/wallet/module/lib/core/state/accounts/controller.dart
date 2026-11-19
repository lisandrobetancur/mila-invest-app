part of 'accounts.dart';

/// Controller de la billetera.
///
/// Muestra `accountsProvider` y se actualiza cuando un depósito o una orden
/// lo invalidan.
class AccountsViewModel extends AutoDisposeViewModel<AccountsState> {
  late WalletNavigator _navigator;
  late AppLogger _logger;

  @override
  AccountsState initState() => const AccountsState();

  @override
  void postInit() {
    _navigator = ref.read(walletNavigatorProvider.notifier);
    _logger = ref.read(loggerProvider);
    ref.listen<AsyncValue<List<Account>>>(accountsProvider, (
      AsyncValue<List<Account>>? previous,
      AsyncValue<List<Account>> next,
    ) {
      if (!next.isLoading) {
        _apply(next);
      }
    });
    runPostBuild(load);
  }

  /// Cierra la billetera.
  void close() => _navigator.close();

  /// Abre el depósito en [currency].
  void deposit(Currency currency) => _navigator.openDeposit(currency);

  /// Carga (o recarga) las cuentas.
  Future<void> load() async {
    state = state.copyWith(status: ViewStatus.loading, errorKey: null);
    ref.invalidate(accountsProvider);
    final Object key = mountedKey;
    try {
      final List<Account> accounts = await ref.read(accountsProvider.future);
      if (isMounted(key)) {
        _apply(AsyncData<List<Account>>(accounts));
      }
    } on WalletException catch (error, stackTrace) {
      if (isMounted(key)) {
        _apply(AsyncError<List<Account>>(error, stackTrace));
      }
    }
  }

  void _apply(AsyncValue<List<Account>> value) {
    switch (value) {
      case AsyncData<List<Account>>(value: final List<Account> accounts):
        state = state.copyWith(
          status: accounts.allEmpty ? ViewStatus.empty : ViewStatus.data,
          accounts: accounts,
          errorKey: null,
        );
      case AsyncError<List<Account>>(:final Object error):
        _logger.error('wallet.accounts', error);
        final WalletErrorCode code = error is WalletException
            ? error.code
            : WalletErrorCode.unknown;
        state = state.copyWith(
          status: ViewStatus.error,
          errorKey: code.messageKey,
          isNetworkError: code.isNetwork,
        );
      case AsyncLoading<List<Account>>():
        break;
    }
  }
}
