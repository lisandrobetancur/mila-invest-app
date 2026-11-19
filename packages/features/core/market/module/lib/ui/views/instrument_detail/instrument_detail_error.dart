part of 'instrument_detail.dart';

class _InstrumentDetailError extends StatelessWidget {
  const _InstrumentDetailError({required this.state, required this.onRetry});

  final InstrumentDetailState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ErrorState(
    id: MarketIds.detailStateError,
    messageId: MarketIds.detailErrorText,
    message: context.tr(state.errorKey ?? 'market.error.unknown'),
    retryId: MarketIds.detailRetryButton,
    retryLabel: context.tr('market.common.retry'),
    icon: state.isNetworkError ? AppIcons.offline : AppIcons.error,
    onRetry: onRetry,
  );
}
