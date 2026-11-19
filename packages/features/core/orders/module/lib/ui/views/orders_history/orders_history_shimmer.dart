part of 'orders_history.dart';

class _OrdersHistoryShimmer extends StatelessWidget {
  const _OrdersHistoryShimmer();

  @override
  Widget build(BuildContext context) => Identified(
    id: OrdersIds.historyStateLoading,
    child: AppShimmer(
      child: Column(
        children: <Widget>[
          for (int row = 0; row < 5; row++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: AppShimmerBox(height: 64, radius: 12),
            ),
        ],
      ),
    ),
  );
}
