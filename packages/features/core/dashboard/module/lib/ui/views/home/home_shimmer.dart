part of 'home.dart';

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) => const Identified(
    id: DashboardIds.homeStateLoading,
    child: AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppShimmerBox(height: 132, radius: 16),
          SizedBox(height: AppSpacing.md),
          AppShimmerBox(height: 120, radius: 16),
          SizedBox(height: AppSpacing.md),
          AppShimmerBox(height: 180, radius: 16),
        ],
      ),
    ),
  );
}
