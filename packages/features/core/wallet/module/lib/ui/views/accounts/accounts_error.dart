part of 'accounts.dart';

class _AccountsError extends StatelessWidget {
  const _AccountsError({required this.state, required this.onRetry});

  final AccountsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ErrorState(
    id: WalletIds.accountsStateError,
    messageId: WalletIds.accountsErrorText,
    message: context.tr(state.errorKey ?? WalletErrorCode.unknown.messageKey),
    retryId: WalletIds.accountsRetryButton,
    retryLabel: context.tr('wallet.common.retry'),
    icon: state.isNetworkError ? AppIcons.offline : AppIcons.error,
    onRetry: onRetry,
  );
}
