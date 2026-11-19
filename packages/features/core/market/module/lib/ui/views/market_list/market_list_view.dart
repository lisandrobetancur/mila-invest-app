part of 'market_list.dart';

/// Lista de instrumentos: buscador, filtros por país y tipo, estado de cada
/// mercado y la lista paginada.
class MarketListView extends ConsumerStatefulWidget {
  /// Crea la lista con los parámetros de su ruta (filtros en la query).
  const MarketListView({required this.params, super.key});

  /// Path de la ruta.
  static const String route = MarketRoutes.listPath;

  /// Nombre de la ruta.
  static const String name = MarketRoutes.listName;

  /// Parámetros de la ruta.
  final AppRouteParams params;

  /// Filtros que trae la URL.
  static InstrumentFilter filterOf(AppRouteParams params) {
    final String? country = params.query(MarketRoutes.countryQuery);
    final String? type = params.query(MarketRoutes.typeQuery);
    return InstrumentFilter(
      country: country == null ? null : Country.tryFromCode(country),
      type: type == null ? null : InstrumentType.tryFromApiCode(type),
      query: params.query(MarketRoutes.searchQuery) ?? '',
    );
  }

  @override
  ConsumerState<MarketListView> createState() => _MarketListViewState();
}

class _MarketListViewState extends ConsumerState<MarketListView> {
  late final TextEditingController _search = TextEditingController(
    text: MarketListView.filterOf(widget.params).query,
  );

  @override
  void initState() {
    super.initState();
    ref
        .read(marketListViewModelProvider.notifier)
        .start(MarketListView.filterOf(widget.params));
  }

  @override
  void didUpdateWidget(MarketListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final InstrumentFilter filter = MarketListView.filterOf(widget.params);
    if (filter != MarketListView.filterOf(oldWidget.params)) {
      ref.read(marketListViewModelProvider.notifier).applyRouteFilter(filter);
      if (_search.text != filter.query) {
        _search.text = filter.query;
      }
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MarketListState state = ref.watch(marketListViewModelProvider);
    final MarketListViewModel viewModel = ref.read(
      marketListViewModelProvider.notifier,
    );
    return AppScaffold(
      id: MarketIds.listView,
      title: context.tr('market.list.title'),
      badge: AppBadge(
        id: MarketIds.listSimulatedText,
        label: context.tr('market.common.simulated'),
        tone: AppBadgeTone.accent,
      ),
      scrollable: false,
      padded: false,
      onRefresh: () => viewModel.refresh(silent: true),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          final ScrollMetrics metrics = notification.metrics;
          if (metrics.axis == Axis.vertical &&
              metrics.pixels >=
                  metrics.maxScrollExtent * MarketLimits.loadMoreThreshold) {
            viewModel.loadMore();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: _MarketListHeader(
                state: state,
                search: _search,
                onClearSearch: () {
                  _search.clear();
                  viewModel.setQuery('');
                },
              ),
            ),
            switch (state.status) {
              ViewStatus.loading => const SliverToBoxAdapter(
                child: _MarketListShimmer(),
              ),
              ViewStatus.data => _MarketListData(state: state),
              ViewStatus.empty => SliverToBoxAdapter(
                child: _MarketListEmpty(
                  onClear: () {
                    _search.clear();
                    viewModel.clearFilters();
                  },
                ),
              ),
              ViewStatus.error => SliverToBoxAdapter(
                child: _MarketListError(state: state),
              ),
            },
          ],
        ),
      ),
    );
  }
}
