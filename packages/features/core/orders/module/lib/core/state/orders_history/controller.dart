part of 'orders_history.dart';

/// Controller del historial de órdenes.
///
/// Escucha `accountsProvider`: cuando una orden o un depósito mueven saldo,
/// el historial se recarga sin mostrar el shimmer.
class OrdersHistoryViewModel extends AutoDisposeViewModel<OrdersHistoryState> {
  late IOrdersService _service;
  late OrdersNavigator _navigator;
  late AppLogger _logger;
  bool _started = false;
  int _request = 0;

  @override
  OrdersHistoryState initState() => const OrdersHistoryState();

  @override
  void postInit() {
    _service = ref.read(ordersServiceProvider);
    _navigator = ref.read(ordersNavigatorProvider.notifier);
    _logger = ref.read(loggerProvider);
    ref.listen<AsyncValue<List<Account>>>(accountsProvider, (
      AsyncValue<List<Account>>? previous,
      AsyncValue<List<Account>> next,
    ) {
      if (_started && previous != null && !next.isLoading && next.hasValue) {
        refresh(silent: true);
      }
    });
  }

  /// Aplica el filtro que llega desde la URL.
  void applyRouteFilter(OrderStatus? status) {
    if (!_started) {
      start(status);
      return;
    }
    runPostBuild(() async {
      if (status != state.filter) {
        state = state.copyWith(filter: status);
        await _reload();
      }
    });
  }

  /// Va a los movimientos.
  void goToMovements() => _navigator.goToMovements();

  /// Va al mercado (desde el estado vacío).
  void goToMarket() => _navigator.goToMarket();

  /// Pide la página siguiente, si corresponde.
  Future<void> loadMore() async {
    if (!state.canLoadMore) {
      return;
    }
    final int request = _request;
    final Object key = mountedKey;
    state = state.copyWith(loadingMore: true, loadMoreErrorKey: null);
    try {
      final Paginated<Order> next = await _service.orders(
        status: state.filter,
        cursor: state.orders.nextCursor,
        limit: OrdersLimits.pageSize,
      );
      if (!isMounted(key) || request != _request) {
        return;
      }
      state = state.copyWith(
        loadingMore: false,
        orders: state.orders.append(next, idOf: (Order order) => order.id),
      );
    } on OrdersException catch (error, stackTrace) {
      _logger.error('orders.history.load_more', error, stackTrace);
      if (isMounted(key) && request == _request) {
        state = state.copyWith(
          loadingMore: false,
          loadMoreErrorKey: error.code.messageKey,
        );
      }
    }
  }

  /// Abre el detalle de [order].
  void openOrder(Order order) => _navigator.openOrder(order.id);

  /// Recarga la primera página.
  Future<void> refresh({bool silent = false}) => _reload(silent: silent);

  /// Reintenta la página siguiente.
  Future<void> retryLoadMore() async {
    state = state.copyWith(loadMoreErrorKey: null);
    await loadMore();
  }

  /// Filtra por estado; `null` es "Todas".
  void setFilter(OrderStatus? status) {
    if (status == state.filter) {
      return;
    }
    state = state.copyWith(filter: status);
    _navigator.replaceHistoryQuery(status);
    _reload();
  }

  /// Primera carga. Llamarlo más de una vez no hace nada.
  void start([OrderStatus? status]) {
    if (_started) {
      return;
    }
    _started = true;
    runPostBuild(() async {
      state = state.copyWith(filter: status);
      await _reload();
    });
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
      final Paginated<Order> page = await _service.orders(
        status: state.filter,
        limit: OrdersLimits.pageSize,
      );
      if (!isMounted(key) || request != _request) {
        return;
      }
      state = state.copyWith(
        status: page.isEmpty ? ViewStatus.empty : ViewStatus.data,
        orders: page,
      );
    } on OrdersException catch (error, stackTrace) {
      _logger.error('orders.history.load', error, stackTrace);
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
