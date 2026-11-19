part of 'order_detail.dart';

/// Provider del controller del detalle, por id de orden.
final AutoDisposeNotifierProviderFamily<
  OrderDetailViewModel,
  OrderDetailState,
  String
>
orderDetailViewModelProvider = NotifierProvider.autoDispose
    .family<OrderDetailViewModel, OrderDetailState, String>(
      OrderDetailViewModel.new,
    );
