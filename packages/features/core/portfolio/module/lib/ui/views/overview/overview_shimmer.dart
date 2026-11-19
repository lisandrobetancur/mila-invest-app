part of 'overview.dart';

class _OverviewShimmer extends StatelessWidget {
  const _OverviewShimmer();

  @override
  Widget build(BuildContext context) => const Identified(
    id: PortfolioIds.overviewStateLoading,
    child: AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppShimmerBox(height: 120, radius: 16),
          SizedBox(height: AppSpacing.md),
          AppShimmerBox(height: 140, radius: 16),
          SizedBox(height: AppSpacing.md),
          AppShimmerBox(height: 72, radius: 12),
          SizedBox(height: AppSpacing.xs),
          AppShimmerBox(height: 72, radius: 12),
        ],
      ),
    ),
  );
}
