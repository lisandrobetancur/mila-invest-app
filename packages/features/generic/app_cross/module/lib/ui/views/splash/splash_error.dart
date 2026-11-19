part of 'splash.dart';

class _SplashError extends ConsumerWidget {
  const _SplashError({required this.state});

  final BootstrapState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ErrorState(
    id: AppCrossIds.splashStateError,
    messageId: AppCrossIds.splashErrorText,
    message: context.tr(state.errorKey ?? AppCrossErrorCode.unknown.messageKey),
    retryId: AppCrossIds.splashRetryButton,
    retryLabel: context.tr('app_cross.common.retry'),
    icon: state.isNetworkError ? AppIcons.offline : AppIcons.error,
    onRetry: ref.read(bootstrapViewModelProvider.notifier).start,
  );
}
