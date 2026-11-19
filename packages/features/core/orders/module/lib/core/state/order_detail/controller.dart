part of 'order_detail.dart';

/// Controller del detalle de una orden (el argumento es su id).
class OrderDetailViewModel
    extends AutoDisposeFamilyViewModel<OrderDetailState, String> {
  late IOrdersService _service;
  late OrdersNavigator _navigator;
  late AppLogger _logger;

  @override
  OrderDetailState initState() => const OrderDetailState();

  @override
  void postInit() {
    _service = ref.read(ordersServiceProvider);
    _navigator = ref.read(ordersNavigatorProvider.notifier);
    _logger = ref.read(loggerProvider);
    runPostBuild(load);
  }

  /// Vuelve atrás.
  void back() => _navigator.backFromDetail();

  /// Vuelve al historial (desde "no encontrada").
  void goToHistory() => _navigator.goToHistory();

  /// Carga la orden.
  Future<void> load() async {
    final Object key = mountedKey;
    state = state.copyWith(status: ViewStatus.loading, errorKey: null);
    try {
      final Order order = await _service.order(arg);
      if (isMounted(key)) {
        state = state.copyWith(status: ViewStatus.data, order: order);
      }
    } on OrdersException catch (error, stackTrace) {
      _logger.error('orders.detail.load', error, stackTrace);
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

  /// Abre el instrumento de la orden.
  void openInstrument() {
    final Order? order = state.order;
    if (order != null) {
      _navigator.openInstrument(order.instrumentId);
    }
  }
}
