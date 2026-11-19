part of 'market_list.dart';

/// Controller de la lista de instrumentos.
///
/// La vista lo arranca con [start] y los filtros que trae la URL. Cada
/// cambio de filtro recarga la primera página (el buscador, con debounce) y
/// se refleja en la URL. Una respuesta vieja que llega después de una más
/// nueva se descarta.
class MarketListViewModel extends AutoDisposeViewModel<MarketListState> {
  late IMarketService _service;
  late MarketNavigator _navigator;
  late AppLogger _logger;
  late Debouncer _debouncer;
  bool _started = false;
  int _request = 0;

  @override
  MarketListState initState() => const MarketListState();

  @override
  void postInit() {
    _service = ref.read(marketServiceProvider);
    _navigator = ref.read(marketNavigatorProvider.notifier);
    _logger = ref.read(loggerProvider);
    _debouncer = Debouncer(ref.read(marketSearchDebounceProvider));
    ref.onDispose(_debouncer.dispose);
  }

  /// Aplica filtros que llegan desde la URL (un deep link o un F5).
  ///
  /// La vista lo llama mientras se reconstruye, así que el cambio de estado
  /// se difiere al microtask siguiente.
  void applyRouteFilter(InstrumentFilter filter) {
    if (!_started) {
      start(filter);
      return;
    }
    runPostBuild(() async {
      if (filter != state.filter) {
        state = state.copyWith(filter: filter);
        _debouncer.cancel();
        await _reload();
      }
    });
  }

  /// Quita todos los filtros.
  void clearFilters() => _changeFilter(const InstrumentFilter());

  /// Abre el detalle de [instrument].
  void openInstrument(Instrument instrument) =>
      _navigator.goToInstrument(instrument.id);

  /// Pide la página siguiente, si corresponde.
  Future<void> loadMore() async {
    if (!state.canLoadMore) {
      return;
    }
    final int request = _request;
    final Object key = mountedKey;
    state = state.copyWith(loadingMore: true, loadMoreErrorKey: null);
    try {
      final Paginated<Instrument> next = await _service.instruments(
        state.filter,
        cursor: state.instruments.nextCursor,
        limit: MarketLimits.pageSize,
      );
      if (!isMounted(key) || request != _request) {
        return;
      }
      state = state.copyWith(
        loadingMore: false,
        instruments: state.instruments.append(
          next,
          idOf: (Instrument instrument) => instrument.id,
        ),
      );
    } on MarketException catch (error, stackTrace) {
      _logger.error('market.list.load_more', error, stackTrace);
      if (isMounted(key) && request == _request) {
        state = state.copyWith(
          loadingMore: false,
          loadMoreErrorKey: error.code.messageKey,
        );
      }
    }
  }

  /// Reintenta la página siguiente después de un error.
  Future<void> retryLoadMore() async {
    state = state.copyWith(loadMoreErrorKey: null);
    await loadMore();
  }

  /// Recarga la primera página (reintentar o pull-to-refresh).
  ///
  /// Con [silent] los datos actuales quedan en pantalla mientras carga.
  Future<void> refresh({bool silent = false}) => _reload(silent: silent);

  /// Filtra por país; `null` es "Todos".
  void setCountry(Country? country) =>
      _changeFilter(state.filter.copyWith(country: country));

  /// Busca por ticker o nombre, con debounce.
  void setQuery(String query) {
    if (query == state.filter.query) {
      return;
    }
    state = state.copyWith(filter: state.filter.copyWith(query: query));
    _debouncer.run(() {
      _navigator.replaceListQuery(state.filter);
      _reload();
    });
  }

  /// Filtra por tipo; tocar el tipo activo lo quita.
  void toggleType(InstrumentType type) => _changeFilter(
    state.filter.copyWith(type: state.filter.type == type ? null : type),
  );

  /// Primera carga. Llamarlo más de una vez no hace nada.
  ///
  /// La vista lo llama desde `initState`, así que todo cambio de estado se
  /// difiere al microtask siguiente.
  void start([InstrumentFilter filter = const InstrumentFilter()]) {
    if (_started) {
      return;
    }
    _started = true;
    runPostBuild(() async {
      state = state.copyWith(filter: filter);
      await Future.wait(<Future<void>>[_reload(), _loadMarkets()]);
    });
  }

  void _changeFilter(InstrumentFilter filter) {
    if (filter == state.filter) {
      return;
    }
    _debouncer.cancel();
    state = state.copyWith(filter: filter);
    _navigator.replaceListQuery(filter);
    _reload();
  }

  Future<void> _loadMarkets() async {
    final Object key = mountedKey;
    try {
      final List<CountryMarket> markets = await ref.read(
        countryMarketsProvider.future,
      );
      if (isMounted(key)) {
        state = state.copyWith(markets: markets);
      }
    } on Exception catch (error) {
      _logger.warn('market.list.markets', error);
    }
  }

  Future<void> _reload({bool silent = false}) async {
    final int request = ++_request;
    final Object key = mountedKey;
    state = state.copyWith(
      status: silent && state.status.isData
          ? ViewStatus.data
          : ViewStatus.loading,
      errorKey: null,
      loadingMore: false,
      loadMoreErrorKey: null,
    );
    try {
      final Paginated<Instrument> page = await _service.instruments(
        state.filter,
        limit: MarketLimits.pageSize,
      );
      if (!isMounted(key) || request != _request) {
        return;
      }
      state = state.copyWith(
        status: page.isEmpty ? ViewStatus.empty : ViewStatus.data,
        instruments: page,
      );
    } on MarketException catch (error, stackTrace) {
      _logger.error('market.list.load', error, stackTrace);
      if (!isMounted(key) || request != _request) {
        return;
      }
      state = state.copyWith(
        status: ViewStatus.error,
        errorKey: error.code.messageKey,
        isNetworkError: error.code.isNetwork,
      );
    }
  }
}
