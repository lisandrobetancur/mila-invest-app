part of 'instrument_detail.dart';

class _InstrumentDetailShimmer extends StatelessWidget {
  const _InstrumentDetailShimmer();

  @override
  Widget build(BuildContext context) => const Identified(
    id: MarketIds.detailStateLoading,
    child: AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppShimmerBox(width: 120, height: 20),
          SizedBox(height: AppSpacing.xs),
          AppShimmerBox(width: 200, height: 14),
          SizedBox(height: AppSpacing.lg),
          AppShimmerBox(width: 180, height: 36),
          SizedBox(height: AppSpacing.lg),
          AppShimmerBox(height: MarketLimits.chartHeight, radius: 12),
          SizedBox(height: AppSpacing.lg),
          AppShimmerBox(height: 96, radius: 16),
        ],
      ),
    ),
  );
}
