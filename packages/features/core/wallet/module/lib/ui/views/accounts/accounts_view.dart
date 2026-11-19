part of 'accounts.dart';

/// Billetera: una tarjeta por cuenta con disponible y reservado.
class AccountsView extends ConsumerWidget {
  /// Crea la billetera.
  const AccountsView({super.key});

  /// Path de la ruta.
  static const String route = WalletRoutes.accountsPath;

  /// Nombre de la ruta.
  static const String name = WalletRoutes.accountsName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AccountsState state = ref.watch(accountsViewModelProvider);
    final AccountsViewModel viewModel = ref.read(
      accountsViewModelProvider.notifier,
    );
    return AppScaffold(
      id: WalletIds.accountsView,
      title: context.tr('wallet.accounts.title'),
      maxWidth: 720,
      leading: AppIconButton(
        id: WalletIds.accountsBackIconButton,
        icon: AppIcons.back,
        tooltip: context.tr('wallet.common.back'),
        onPressed: viewModel.close,
      ),
      badge: AppBadge(
        id: WalletIds.accountsSimulatedText,
        label: context.tr('wallet.common.simulated'),
        tone: AppBadgeTone.accent,
      ),
      onRefresh: viewModel.load,
      body: switch (state.status) {
        ViewStatus.loading => const _AccountsShimmer(),
        ViewStatus.data => _AccountsData(state: state),
        ViewStatus.empty => _AccountsEmpty(
          onDeposit: () => viewModel.deposit(
            state.accounts.isEmpty
                ? Currency.cop
                : state.accounts.first.currency,
          ),
        ),
        ViewStatus.error => _AccountsError(
          state: state,
          onRetry: viewModel.load,
        ),
      },
    );
  }
}
