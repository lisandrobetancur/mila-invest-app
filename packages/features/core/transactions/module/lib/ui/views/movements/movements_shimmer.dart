part of 'movements.dart';

class _MovementsShimmer extends StatelessWidget {
  const _MovementsShimmer();

  @override
  Widget build(BuildContext context) => Identified(
    id: TransactionsIds.listStateLoading,
    child: AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int day = 0; day < 2; day++) ...<Widget>[
            const AppShimmerBox(width: 120, height: 14),
            const SizedBox(height: AppSpacing.xs),
            for (int row = 0; row < 3; row++)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: AppShimmerBox(height: 56, radius: 12),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    ),
  );
}
