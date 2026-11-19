part of 'movements.dart';

class _MovementsError extends ConsumerWidget {
  const _MovementsError({required this.state});

  final MovementsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ErrorState(
    id: TransactionsIds.listStateError,
    messageId: TransactionsIds.listErrorText,
    message: context.tr(
      state.errorKey ?? TransactionsErrorCode.unknown.messageKey,
    ),
    retryId: TransactionsIds.listRetryButton,
    retryLabel: context.tr('transactions.common.retry'),
    icon: state.isNetworkError ? AppIcons.offline : AppIcons.error,
    onRetry: ref.read(movementsViewModelProvider.notifier).refresh,
  );
}
