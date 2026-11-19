part of 'overview.dart';

/// Controller del portafolio.
///
/// Muestra `portfolioProvider`. Si cambian los saldos (un depósito invalida
/// `accountsProvider`), vuelve a pedir el portafolio, porque el efectivo es
/// parte del total.
class PortfolioOverviewViewModel
    extends AutoDisposeViewModel<PortfolioOverviewState> {
  late PortfolioNavigator _navigator;
  late AppLogger _logger;

  @override
  PortfolioOverviewState initState() => const PortfolioOverviewState();

  @override
  void postInit() {
    _navigator = ref.read(portfolioNavigatorProvider.notifier);
    _logger = ref.read(loggerProvider);
    ref
      ..listen<AsyncValue<Portfolio>>(portfolioProvider, (
        AsyncValue<Portfolio>? previous,
        AsyncValue<Portfolio> next,
      ) {
        if (!next.isLoading) {
          _apply(next);
        }
      })
      ..listen<AsyncValue<List<Account>>>(accountsProvider, (
        AsyncValue<List<Account>>? previous,
        AsyncValue<List<Account>> next,
      ) {
        if (previous != null && previous.hasValue && !next.isLoading) {
          ref.invalidate(portfolioProvider);
        }
      });
    runPostBuild(load);
  }

  /// Va al mercado.
  void goToMarket() => _navigator.goToMarket();

  /// Carga (o recarga) el portafolio.
  Future<void> load() async {
    if (!state.status.isData) {
      state = state.copyWith(status: ViewStatus.loading, errorKey: null);
    }
    ref.invalidate(portfolioProvider);
    final Object key = mountedKey;
    try {
      final Portfolio portfolio = await ref.read(portfolioProvider.future);
      if (isMounted(key)) {
        _apply(AsyncData<Portfolio>(portfolio));
      }
    } on PortfolioException catch (error, stackTrace) {
      if (isMounted(key)) {
        _apply(AsyncError<Portfolio>(error, stackTrace));
      }
    }
  }

  /// Abre el detalle del instrumento de [position].
  void openPosition(Position position) =>
      _navigator.openInstrument(position.instrument.id);

  void _apply(AsyncValue<Portfolio> value) {
    switch (value) {
      case AsyncData<Portfolio>(value: final Portfolio portfolio):
        state = state.copyWith(
          status: portfolio.hasNoPositions ? ViewStatus.empty : ViewStatus.data,
          portfolio: portfolio,
          errorKey: null,
        );
      case AsyncError<Portfolio>(:final Object error):
        _logger.error('portfolio.overview', error);
        final PortfolioErrorCode code = error is PortfolioException
            ? error.code
            : PortfolioErrorCode.unknown;
        state = state.copyWith(
          status: ViewStatus.error,
          errorKey: code.messageKey,
          isNetworkError: code.isNetwork,
        );
      case AsyncLoading<Portfolio>():
        break;
    }
  }
}
