part of 'overview.dart';

class _OverviewError extends StatelessWidget {
  const _OverviewError({required this.state, required this.onRetry});

  final PortfolioOverviewState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ErrorState(
    id: PortfolioIds.overviewStateError,
    messageId: PortfolioIds.overviewErrorText,
    message: context.tr(
      state.errorKey ?? PortfolioErrorCode.unknown.messageKey,
    ),
    retryId: PortfolioIds.overviewRetryButton,
    retryLabel: context.tr('portfolio.common.retry'),
    icon: state.isNetworkError ? AppIcons.offline : AppIcons.error,
    onRetry: onRetry,
  );
}
