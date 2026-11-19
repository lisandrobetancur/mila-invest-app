part of 'order_detail.dart';

class _OrderDetailShimmer extends StatelessWidget {
  const _OrderDetailShimmer();

  @override
  Widget build(BuildContext context) => const Identified(
    id: OrdersIds.detailStateLoading,
    child: AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppShimmerBox(width: 120, height: 24),
          SizedBox(height: AppSpacing.md),
          AppShimmerBox(height: 120, radius: 16),
          SizedBox(height: AppSpacing.md),
          AppShimmerBox(height: 160, radius: 16),
        ],
      ),
    ),
  );
}
