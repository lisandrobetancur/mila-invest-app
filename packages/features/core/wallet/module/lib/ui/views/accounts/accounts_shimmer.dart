part of 'accounts.dart';

class _AccountsShimmer extends StatelessWidget {
  const _AccountsShimmer();

  @override
  Widget build(BuildContext context) => Identified(
    id: WalletIds.accountsStateLoading,
    child: AppShimmer(
      child: Column(
        children: <Widget>[
          for (int card = 0; card < 3; card++)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: AppShimmerBox(height: 132, radius: 16),
            ),
        ],
      ),
    ),
  );
}
