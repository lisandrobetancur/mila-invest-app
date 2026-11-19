part of 'market_list.dart';

class _MarketListError extends ConsumerWidget {
  const _MarketListError({required this.state});

  final MarketListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ErrorState(
    id: MarketIds.listStateError,
    messageId: MarketIds.listErrorText,
    message: context.tr(state.errorKey ?? 'market.error.unknown'),
    retryId: MarketIds.listRetryButton,
    retryLabel: context.tr('market.common.retry'),
    icon: state.isNetworkError ? AppIcons.offline : AppIcons.error,
    onRetry: ref.read(marketListViewModelProvider.notifier).refresh,
  );
}
