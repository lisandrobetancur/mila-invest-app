part of 'market_list.dart';

class _MarketListShimmer extends StatelessWidget {
  const _MarketListShimmer();

  @override
  Widget build(BuildContext context) {
    final double padding = AppLayout.of(context).pagePadding;
    return Identified(
      id: MarketIds.listStateLoading,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: AppShimmer(
          child: Column(
            children: <Widget>[
              for (int row = 0; row < 6; row++)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AppShimmerBox(width: 96),
                            SizedBox(height: AppSpacing.xs),
                            AppShimmerBox(width: 160, height: 12),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          AppShimmerBox(width: 88),
                          SizedBox(height: AppSpacing.xs),
                          AppShimmerBox(width: 56, height: 12),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
