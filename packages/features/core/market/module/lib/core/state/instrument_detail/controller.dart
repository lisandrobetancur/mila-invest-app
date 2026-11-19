part of 'instrument_detail.dart';

/// Controller del detalle de un instrumento (el argumento es su id).
///
/// Mientras la vista está visible refresca el precio cada
/// `priceRefreshIntervalProvider`: es el único timer periódico de la app y
/// se cancela al destruir el controller.
class InstrumentDetailViewModel
    extends AutoDisposeFamilyViewModel<InstrumentDetailState, String> {
  late IMarketService _service;
  late MarketNavigator _navigator;
  late AppLogger _logger;
  late Duration _refreshInterval;
  Timer? _refreshTimer;
  int _chartRequest = 0;

  @override
  InstrumentDetailState initState() => const InstrumentDetailState();

  @override
  void postInit() {
    _service = ref.read(marketServiceProvider);
    _navigator = ref.read(marketNavigatorProvider.notifier);
    _logger = ref.read(loggerProvider);
    _refreshInterval = ref.read(priceRefreshIntervalProvider);
    ref
      ..onDispose(() => _refreshTimer?.cancel())
      ..listen<AsyncValue<Portfolio>>(portfolioProvider, (
        AsyncValue<Portfolio>? previous,
        AsyncValue<Portfolio> next,
      ) {
        final Portfolio? portfolio = next.valueOrNull;
        if (!next.isLoading && portfolio != null && isMounted(mountedKey)) {
          state = state.copyWith(position: portfolio.positionOf(arg));
        }
      });
    runPostBuild(load);
  }

  /// `true` si el timer de precios está corriendo (para tests).
  bool get isRefreshing => _refreshTimer?.isActive ?? false;

  /// Vuelve atrás.
  void back() => _navigator.back();

  /// Abre el ticket de compra.
  void buy() {
    if (state.canTrade) {
      _navigator.openOrderTicket(arg, OrderSide.buy);
    }
  }

  /// Vuelve a la lista (desde "no encontrado").
  void goToList() => _navigator.goToList();

  /// Carga el detalle, la serie, la posición y el estado del mercado.
  Future<void> load() async {
    final Object key = mountedKey;
    state = state.copyWith(status: ViewStatus.loading, errorKey: null);
    try {
      final InstrumentDetail detail = await _service.instrument(arg);
      if (!isMounted(key)) {
        return;
      }
      state = state.copyWith(status: ViewStatus.data, detail: detail);
      await Future.wait(<Future<void>>[
        _loadSeries(state.range),
        _loadPosition(),
        _loadMarket(detail.instrument.country),
      ]);
      if (isMounted(key)) {
        _startRefreshTimer();
      }
    } on MarketException catch (error, stackTrace) {
      _logger.error('market.detail.load', error, stackTrace);
      if (!isMounted(key)) {
        return;
      }
      state = state.copyWith(
        status: error.code.isNotFound ? ViewStatus.empty : ViewStatus.error,
        errorKey: error.code.messageKey,
        isNetworkError: error.code.isNetwork,
      );
    }
  }

  /// Consulta el precio de nuevo; si cambió, la vista destella.
  Future<void> refreshPrice() async {
    final InstrumentDetail? current = state.detail;
    if (current == null) {
      return;
    }
    final Object key = mountedKey;
    try {
      final InstrumentDetail fresh = await _service.instrument(arg);
      if (!isMounted(key)) {
        return;
      }
      final int sign =
          (fresh.instrument.lastPrice.amount -
                  current.instrument.lastPrice.amount)
              .sign;
      state = state.copyWith(
        detail: fresh,
        flashSign: sign == 0 ? state.flashSign : sign,
        flashTick: sign == 0 ? state.flashTick : state.flashTick + 1,
      );
    } on MarketException catch (error) {
      _logger.warn('market.detail.refresh', error);
    }
  }

  /// Cambia el rango del gráfico.
  Future<void> selectRange(PriceRange range) async {
    if (range == state.range && state.series != null) {
      return;
    }
    state = state.copyWith(range: range);
    await _loadSeries(range);
  }

  /// Abre el ticket de venta, si hay posición.
  void sell() {
    if (state.canTrade && state.canSell) {
      _navigator.openOrderTicket(arg, OrderSide.sell);
    }
  }

  Future<void> _loadMarket(Country country) async {
    final Object key = mountedKey;
    try {
      final List<CountryMarket> markets = await ref.read(
        countryMarketsProvider.future,
      );
      if (!isMounted(key)) {
        return;
      }
      for (final CountryMarket market in markets) {
        if (market.country == country) {
          state = state.copyWith(market: market);
        }
      }
    } on Exception catch (error) {
      _logger.warn('market.detail.market', error);
    }
  }

  Future<void> _loadPosition() async {
    final Object key = mountedKey;
    try {
      final Portfolio portfolio = await ref.read(portfolioProvider.future);
      if (isMounted(key)) {
        state = state.copyWith(position: portfolio.positionOf(arg));
      }
    } on Exception catch (error) {
      _logger.warn('market.detail.position', error);
    }
  }

  Future<void> _loadSeries(PriceRange range) async {
    final int request = ++_chartRequest;
    final Object key = mountedKey;
    state = state.copyWith(chartLoading: true, chartErrorKey: null);
    try {
      final PriceSeries series = await _service.prices(arg, range);
      if (!isMounted(key) || request != _chartRequest) {
        return;
      }
      state = state.copyWith(series: series, chartLoading: false);
    } on MarketException catch (error, stackTrace) {
      _logger.error('market.detail.prices', error, stackTrace);
      if (isMounted(key) && request == _chartRequest) {
        state = state.copyWith(
          chartLoading: false,
          chartErrorKey: error.code.messageKey,
        );
      }
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    if (_refreshInterval <= Duration.zero) {
      return;
    }
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => refreshPrice());
  }
}
