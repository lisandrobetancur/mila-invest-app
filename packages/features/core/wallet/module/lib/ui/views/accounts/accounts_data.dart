part of 'accounts.dart';

class _AccountsData extends ConsumerWidget {
  const _AccountsData({required this.state});

  final AccountsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AccountsViewModel viewModel = ref.read(
      accountsViewModelProvider.notifier,
    );
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Identified(
      id: WalletIds.accountsStateData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final Account account in state.accounts)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Identified(
                id: WalletIds.accountItem(account.currency.code),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        context.tr(
                          'wallet.accounts.account_'
                          '${account.currency.code.toLowerCase()}',
                        ),
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.tr('wallet.accounts.available'),
                        style: textTheme.bodySmall,
                      ),
                      MoneyText(
                        id: WalletIdsOf.available(account.currency),
                        money: account.available,
                        size: MoneyTextSize.large,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Text(
                            context.tr('wallet.accounts.reserved'),
                            style: textTheme.bodySmall,
                          ),
                          MoneyText(
                            id: WalletIdsOf.reserved(account.currency),
                            money: account.reserved,
                            size: MoneyTextSize.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AppButton(
                          id: WalletIdsOf.deposit(account.currency),
                          label: context.tr('wallet.accounts.deposit'),
                          icon: AppIcons.deposit,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => viewModel.deposit(account.currency),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
