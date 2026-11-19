part of 'orders_history.dart';

/// Provider del controller del historial.
final AutoDisposeNotifierProvider<OrdersHistoryViewModel, OrdersHistoryState>
ordersHistoryViewModelProvider =
    NotifierProvider.autoDispose<OrdersHistoryViewModel, OrdersHistoryState>(
      OrdersHistoryViewModel.new,
    );
