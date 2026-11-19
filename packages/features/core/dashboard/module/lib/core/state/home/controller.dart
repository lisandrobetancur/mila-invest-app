part of 'home.dart';

/// Controller del inicio.
///
/// Escucha `accountsProvider`: después de un depósito o una orden, el
/// resumen se recarga sin shimmer.
class DashboardHomeViewModel extends AutoDisposeViewModel<DashboardHomeState> {
  late IDashboardService _service;
  late DashboardNavigator _navigator;
  late AppLogger _logger;

  @override
  DashboardHomeState initState() => const DashboardHomeState();

  @override
  void postInit() {
    _service = ref.read(dashboardServiceProvider);
    _navigator = ref.read(dashboardNavigatorProvider.notifier);
    _logger = ref.read(loggerProvider);
    ref.listen<AsyncValue<List<Account>>>(accountsProvider, (
      AsyncValue<List<Account>>? previous,
      AsyncValue<List<Account>> next,
    ) {
      if (previous != null && previous.hasValue && !next.isLoading) {
        load(silent: true);
      }
    });
    runPostBuild(load);
  }

  /// Abre el depósito en la moneda base del resumen.
  void deposit() => _navigator.openDeposit(
    state.summary?.portfolio.baseCurrency ?? Currency.cop,
  );

  /// Va a los movimientos.
  void goToActivity() => _navigator.goToActivity();

  /// Carga (o recarga) el resumen. Con [silent] no muestra el shimmer.
  Future<void> load({bool silent = false}) async {
    final Object key = mountedKey;
    if (!(silent && state.status.isData)) {
      state = state.copyWith(status: ViewStatus.loading, errorKey: null);
    }
    try {
      final DashboardSummary summary = await _service.summary();
      if (isMounted(key)) {
        state = state.copyWith(
          status: summary.isNewUser ? ViewStatus.empty : ViewStatus.data,
          summary: summary,
          errorKey: null,
        );
      }
    } on DashboardException catch (error, stackTrace) {
      _logger.error('dashboard.load', error, stackTrace);
      if (isMounted(key)) {
        state = state.copyWith(
          status: ViewStatus.error,
          errorKey: error.code.messageKey,
          isNetworkError: error.code.isNetwork,
        );
      }
    }
  }

  /// Abre el detalle del instrumento [instrumentId].
  void openInstrument(String instrumentId) =>
      _navigator.openInstrument(instrumentId);

  /// Abre ajustes.
  void openSettings() => _navigator.openSettings();

  /// Abre la billetera.
  void openWallet() => _navigator.openWallet();
}
