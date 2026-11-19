part of 'home.dart';

class _HomeEmpty extends StatelessWidget {
  const _HomeEmpty({required this.onDeposit});

  final VoidCallback onDeposit;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Identified(
      id: DashboardIds.homeStateEmpty,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ExcludeSemantics(
              child: Icon(
                AppIcons.deposit,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Identified(
              id: DashboardIds.homeEmptyTitleText,
              child: Text(
                context.tr('dashboard.home.empty_title'),
                style: textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.tr('dashboard.home.empty_body'),
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              id: DashboardIds.homeEmptyDepositButton,
              label: context.tr('dashboard.home.empty_deposit'),
              icon: AppIcons.deposit,
              onPressed: onDeposit,
            ),
          ],
        ),
      ),
    );
  }
}
