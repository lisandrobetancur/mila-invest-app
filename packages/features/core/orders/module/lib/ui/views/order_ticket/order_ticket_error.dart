part of 'order_ticket.dart';

class _OrderTicketError extends StatelessWidget {
  const _OrderTicketError({required this.state, required this.onRetry});

  final OrderTicketState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ErrorState(
    id: OrdersIds.ticketStateError,
    messageId: OrdersIds.ticketErrorText,
    message: context.tr(state.errorKey ?? OrdersErrorCode.unknown.messageKey),
    retryId: OrdersIds.ticketRetryButton,
    retryLabel: context.tr('orders.common.retry'),
    icon: state.isNetworkError ? AppIcons.offline : AppIcons.error,
    onRetry: onRetry,
  );
}
