part of 'overview.dart';

/// Portafolio: valor total en moneda base, variación del día, efectivo vs
/// invertido, distribución y posiciones.
class PortfolioOverviewView extends ConsumerWidget {
  /// Crea la vista.
  const PortfolioOverviewView({super.key});

  /// Path de la ruta.
  static const String route = PortfolioRoutes.overviewPath;

  /// Nombre de la ruta.
  static const String name = PortfolioRoutes.overviewName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PortfolioOverviewState state = ref.watch(
      portfolioOverviewViewModelProvider,
    );
    final PortfolioOverviewViewModel viewModel = ref.read(
      portfolioOverviewViewModelProvider.notifier,
    );
    return AppScaffold(
      id: PortfolioIds.overviewView,
      title: context.tr('portfolio.overview.title'),
      badge: AppBadge(
        id: PortfolioIds.overviewSimulatedText,
        label: context.tr('portfolio.common.simulated'),
        tone: AppBadgeTone.accent,
      ),
      onRefresh: viewModel.load,
      body: switch (state.status) {
        ViewStatus.loading => const _OverviewShimmer(),
        ViewStatus.data => _OverviewData(portfolio: state.portfolio!),
        ViewStatus.empty => _OverviewEmpty(onExplore: viewModel.goToMarket),
        ViewStatus.error => _OverviewError(
          state: state,
          onRetry: viewModel.load,
        ),
      },
    );
  }
}

String _sliceLabel(BuildContext context, AllocationType type) =>
    context.tr('portfolio.allocation.${type.name}');
