part of 'home.dart';

/// Inicio: saludo, valor total con la variación del día, distribución, top
/// movers y últimos movimientos. Billetera y ajustes se abren desde aquí.
class DashboardHomeView extends ConsumerWidget {
  /// Crea el inicio.
  const DashboardHomeView({super.key});

  /// Path de la ruta.
  static const String route = DashboardRoutes.homePath;

  /// Nombre de la ruta.
  static const String name = DashboardRoutes.homeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DashboardHomeState state = ref.watch(dashboardHomeViewModelProvider);
    final DashboardHomeViewModel viewModel = ref.read(
      dashboardHomeViewModelProvider.notifier,
    );
    final User? user = ref.watch(sessionProvider).user;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AppScaffold(
      id: DashboardIds.homeView,
      badge: AppBadge(
        id: DashboardIds.homeSimulatedText,
        label: context.tr('dashboard.common.simulated'),
        tone: AppBadgeTone.accent,
      ),
      actions: <Widget>[
        AppIconButton(
          id: DashboardIds.homeWalletIconButton,
          icon: AppIcons.wallet,
          tooltip: context.tr('dashboard.common.wallet'),
          onPressed: viewModel.openWallet,
        ),
        AppIconButton(
          id: DashboardIds.homeSettingsIconButton,
          icon: AppIcons.settings,
          tooltip: context.tr('dashboard.common.settings'),
          onPressed: viewModel.openSettings,
        ),
      ],
      onRefresh: () => viewModel.load(silent: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Identified(
            id: DashboardIds.homeGreetingText,
            child: Text(
              user == null
                  ? context.tr('dashboard.home.greeting_anonymous')
                  : context.tr(
                      'dashboard.home.greeting',
                      namedArgs: <String, String>{'name': user.firstName},
                    ),
              style: textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          switch (state.status) {
            ViewStatus.loading => const _HomeShimmer(),
            ViewStatus.data => _HomeData(summary: state.summary!),
            ViewStatus.empty => _HomeEmpty(onDeposit: viewModel.deposit),
            ViewStatus.error => _HomeError(
              state: state,
              onRetry: viewModel.load,
            ),
          },
        ],
      ),
    );
  }
}
