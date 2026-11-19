part of 'movements.dart';

/// Controller de los movimientos.
///
/// Escucha `accountsProvider`: un depósito o una orden recargan la lista
/// sin shimmer.
class MovementsViewModel extends AutoDisposeViewModel<MovementsState> {
  late ITransactionsService _service;
  late TransactionsNavigator _navigator;
  late AppLogger _logger;
  bool _started = false;
  int _request = 0;

  @override
  MovementsState initState() => const MovementsState();

  @override
  void postInit() {
    _service = ref.read(transactionsServiceProvider);
    _navigator = ref.read(transactionsNavigatorProvider.notifier);
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

  /// Aplica los filtros que llegan desde la URL.
  void applyRouteFilter(TransactionFilter filter) {
    if (!_started) {
      start(filter);
      return;
    }
    runPostBuild(() async {
      if (filter != state.filter) {
        state = state.copyWith(filter: filter);
        await _reload();
      }
    });
  }

  /// Quita los filtros.
  void clearFilters() => _changeFilter(const TransactionFilter());

  /// Abre el depósito en [currency].
  void deposit(Currency currency) => _navigator.openDeposit(currency);

  /// Va al historial de órdenes.
  void goToOrders() => _navigator.goToOrders();

  /// Pide la página siguiente, si corresponde.
  Future<void> loadMore() async {
    if (!state.canLoadMore) {
      return;
    }
    final int request = _request;
    final Object key = mountedKey;
    state = state.copyWith(loadingMore: true, loadMoreErrorKey: null);
    try {
      final Paginated<Transaction> next = await _service.transactions(
        state.filter,
        cursor: state.transactions.nextCursor,
        limit: TransactionsLimits.pageSize,
      );
      if (!isMounted(key) || request != _request) {
        return;
      }
      state = state.copyWith(
        loadingMore: false,
        transactions: state.transactions.append(
          next,
          idOf: (Transaction transaction) => transaction.id,
        ),
      );
    } on TransactionsException catch (error, stackTrace) {
      _logger.error('transactions.load_more', error, stackTrace);
      if (isMounted(key) && request == _request) {
        state = state.copyWith(
          loadingMore: false,
          loadMoreErrorKey: error.code.messageKey,
        );
      }
    }
  }

  /// Abre la orden que originó [transaction], si hay una.
  void openTransaction(Transaction transaction) {
    final String? orderId = transaction.orderId;
    if (orderId != null) {
      _navigator.openOrder(orderId);
    }
  }

  /// Recarga la primera página.
  Future<void> refresh({bool silent = false}) => _reload(silent: silent);

  /// Reintenta la página siguiente.
  Future<void> retryLoadMore() async {
    state = state.copyWith(loadMoreErrorKey: null);
    await loadMore();
  }

  /// Filtra por rango de fechas.
  void setRange(TransactionRange range) =>
      _changeFilter(state.filter.copyWith(range: range));

  /// Filtra por tipo; `null` es "Todos".
  void setType(TransactionType? type) =>
      _changeFilter(state.filter.copyWith(type: type));

  /// Primera carga. Llamarlo más de una vez no hace nada.
  void start([TransactionFilter filter = const TransactionFilter()]) {
    if (_started) {
      return;
    }
    _started = true;
    runPostBuild(() async {
      state = state.copyWith(filter: filter);
      await _reload();
    });
  }

  void _changeFilter(TransactionFilter filter) {
    if (filter == state.filter) {
      return;
    }
    state = state.copyWith(filter: filter);
    _navigator.replaceQuery(filter);
    _reload();
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
      final Paginated<Transaction> page = await _service.transactions(
        state.filter,
        limit: TransactionsLimits.pageSize,
      );
      if (!isMounted(key) || request != _request) {
        return;
      }
      state = state.copyWith(
        status: page.isEmpty ? ViewStatus.empty : ViewStatus.data,
        transactions: page,
      );
    } on TransactionsException catch (error, stackTrace) {
      _logger.error('transactions.load', error, stackTrace);
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
