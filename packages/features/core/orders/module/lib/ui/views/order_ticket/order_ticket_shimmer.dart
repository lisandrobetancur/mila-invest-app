part of 'order_ticket.dart';

class _OrderTicketShimmer extends StatelessWidget {
  const _OrderTicketShimmer();

  @override
  Widget build(BuildContext context) => const Identified(
    id: OrdersIds.ticketStateLoading,
    child: AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppShimmerBox(width: 160, height: 20),
          SizedBox(height: AppSpacing.md),
          AppShimmerBox(height: 48, radius: 12),
          SizedBox(height: AppSpacing.md),
          AppShimmerBox(height: 56, radius: 8),
          SizedBox(height: AppSpacing.md),
          AppShimmerBox(height: 140, radius: 16),
        ],
      ),
    ),
  );
}
