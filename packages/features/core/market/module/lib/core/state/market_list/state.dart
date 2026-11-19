part of 'market_list.dart';

/// Estado de la lista de instrumentos.
class MarketListState extends Equatable {
  /// Crea el estado.
  const MarketListState({
    this.status = ViewStatus.loading,
    this.filter = const InstrumentFilter(),
    this.instruments = const Paginated<Instrument>.empty(),
    this.markets = const <CountryMarket>[],
    this.loadingMore = false,
    this.loadMoreErrorKey,
    this.errorKey,
    this.isNetworkError = false,
  });

  static const Object _unset = Object();

  /// Estado de la vista.
  final ViewStatus status;

  /// Filtros activos.
  final InstrumentFilter filter;

  /// Instrumentos cargados hasta ahora.
  final Paginated<Instrument> instruments;

  /// Estado del mercado de cada país.
  final List<CountryMarket> markets;

  /// `true` mientras se pide la página siguiente.
  final bool loadingMore;

  /// Error de la página siguiente, si lo hubo.
  final String? loadMoreErrorKey;

  /// Clave del error de la carga, si lo hubo.
  final String? errorKey;

  /// `true` si el error fue de red.
  final bool isNetworkError;

  /// `true` si conviene pedir la página siguiente.
  bool get canLoadMore =>
      status.isData &&
      instruments.hasMore &&
      !loadingMore &&
      loadMoreErrorKey == null;

  /// Mercados visibles según el filtro de país.
  List<CountryMarket> get visibleMarkets => filter.country == null
      ? markets
      : markets
            .where((CountryMarket market) => market.country == filter.country)
            .toList(growable: false);

  /// Copia el estado. Los campos nullable aceptan `null` explícito.
  MarketListState copyWith({
    ViewStatus? status,
    InstrumentFilter? filter,
    Paginated<Instrument>? instruments,
    List<CountryMarket>? markets,
    bool? loadingMore,
    Object? loadMoreErrorKey = _unset,
    Object? errorKey = _unset,
    bool? isNetworkError,
  }) => MarketListState(
    status: status ?? this.status,
    filter: filter ?? this.filter,
    instruments: instruments ?? this.instruments,
    markets: markets ?? this.markets,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreErrorKey: identical(loadMoreErrorKey, _unset)
        ? this.loadMoreErrorKey
        : loadMoreErrorKey as String?,
    errorKey: identical(errorKey, _unset) ? this.errorKey : errorKey as String?,
    isNetworkError: isNetworkError ?? this.isNetworkError,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    filter,
    instruments,
    markets,
    loadingMore,
    loadMoreErrorKey,
    errorKey,
    isNetworkError,
  ];
}
