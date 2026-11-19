part of 'overview.dart';

class _OverviewEmpty extends StatelessWidget {
  const _OverviewEmpty({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) => EmptyState(
    id: PortfolioIds.overviewStateEmpty,
    titleId: PortfolioIds.overviewEmptyTitleText,
    icon: AppIcons.emptyPortfolio,
    title: context.tr('portfolio.overview.empty_title'),
    message: context.tr('portfolio.overview.empty_body'),
    action: EmptyStateAction(
      id: PortfolioIds.overviewExploreButton,
      label: context.tr('portfolio.overview.explore'),
      onPressed: onExplore,
    ),
  );
}
