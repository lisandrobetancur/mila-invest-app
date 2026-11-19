part of 'order_detail.dart';

class _OrderDetailError extends StatelessWidget {
  const _OrderDetailError({required this.state, required this.onRetry});

  final OrderDetailState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ErrorState(
    id: OrdersIds.detailStateError,
    messageId: OrdersIds.detailErrorText,
    message: context.tr(state.errorKey ?? OrdersErrorCode.unknown.messageKey),
    retryId: OrdersIds.detailRetryButton,
    retryLabel: context.tr('orders.common.retry'),
    icon: state.isNetworkError ? AppIcons.offline : AppIcons.error,
    onRetry: onRetry,
  );
}
