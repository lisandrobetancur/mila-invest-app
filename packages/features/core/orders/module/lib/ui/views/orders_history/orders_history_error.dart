part of 'orders_history.dart';

class _OrdersHistoryError extends ConsumerWidget {
  const _OrdersHistoryError({required this.state});

  final OrdersHistoryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ErrorState(
    id: OrdersIds.historyStateError,
    messageId: OrdersIds.historyErrorText,
    message: context.tr(state.errorKey ?? OrdersErrorCode.unknown.messageKey),
    retryId: OrdersIds.historyRetryButton,
    retryLabel: context.tr('orders.common.retry'),
    icon: state.isNetworkError ? AppIcons.offline : AppIcons.error,
    onRetry: ref.read(ordersHistoryViewModelProvider.notifier).refresh,
  );
}
