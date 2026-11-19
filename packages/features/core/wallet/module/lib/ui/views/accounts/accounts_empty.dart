part of 'accounts.dart';

class _AccountsEmpty extends StatelessWidget {
  const _AccountsEmpty({required this.onDeposit});

  final VoidCallback onDeposit;

  @override
  Widget build(BuildContext context) => EmptyState(
    id: WalletIds.accountsStateEmpty,
    titleId: WalletIds.accountsEmptyTitleText,
    icon: AppIcons.wallet,
    title: context.tr('wallet.accounts.empty_title'),
    message: context.tr('wallet.accounts.empty_body'),
    action: EmptyStateAction(
      id: WalletIds.accountsEmptyDepositButton,
      label: context.tr('wallet.accounts.empty_deposit'),
      onPressed: onDeposit,
    ),
  );
}
