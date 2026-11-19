part of 'order_ticket.dart';

/// Provider del controller del ticket, por instrumento y lado inicial.
final AutoDisposeNotifierProviderFamily<
  OrderTicketViewModel,
  OrderTicketState,
  OrderTicketArgs
>
orderTicketViewModelProvider = NotifierProvider.autoDispose
    .family<OrderTicketViewModel, OrderTicketState, OrderTicketArgs>(
      OrderTicketViewModel.new,
    );
