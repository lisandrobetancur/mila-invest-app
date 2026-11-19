part of 'order_ticket.dart';

class _OrderTicketEmpty extends StatelessWidget {
  const _OrderTicketEmpty({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => EmptyState(
    id: OrdersIds.ticketStateEmpty,
    titleId: OrdersIds.ticketNotFoundTitleText,
    icon: AppIcons.notFound,
    title: context.tr('orders.ticket.not_found_title'),
    action: EmptyStateAction(
      id: OrdersIds.ticketNotFoundCloseButton,
      label: context.tr('orders.common.close'),
      onPressed: onClose,
    ),
  );
}
