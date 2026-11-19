part of 'home.dart';

class _HomeError extends StatelessWidget {
  const _HomeError({required this.state, required this.onRetry});

  final DashboardHomeState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ErrorState(
    id: DashboardIds.homeStateError,
    messageId: DashboardIds.homeErrorText,
    message: context.tr(
      state.errorKey ?? DashboardErrorCode.unknown.messageKey,
    ),
    retryId: DashboardIds.homeRetryButton,
    retryLabel: context.tr('dashboard.common.retry'),
    icon: state.isNetworkError ? AppIcons.offline : AppIcons.error,
    onRetry: onRetry,
  );
}
