part of 'movements.dart';

IconData _typeIcon(TransactionType type) => switch (type) {
  TransactionType.deposit => AppIcons.deposit,
  TransactionType.buy => AppIcons.buy,
  TransactionType.sell => AppIcons.sell,
  TransactionType.fee => AppIcons.fee,
  TransactionType.other => AppIcons.activity,
};

class _MovementsData extends ConsumerWidget {
  const _MovementsData({required this.state});

  final MovementsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MovementsViewModel viewModel = ref.read(
      movementsViewModelProvider.notifier,
    );
    final Country zone = ref.watch(sessionProvider).user?.country ?? Country.co;
    final String locale = context.languageCode;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? loadMoreError = state.loadMoreErrorKey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Identified(
          id: TransactionsIds.listStateData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final TransactionDay day in state.groupedBy(
                zone,
              )) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.xxs,
                  ),
                  child: Identified(
                    id: TransactionsIds.dayItem(day.isoDate),
                    child: Text(
                      Formatters.date(
                        day.date.subtract(zone.utcOffset),
                        country: zone,
                        locale: locale,
                      ),
                      style: textTheme.labelSmall,
                    ),
                  ),
                ),
                for (final Transaction transaction in day.transactions)
                  _MovementTile(
                    transaction: transaction,
                    zone: zone,
                    onTap: transaction.orderId == null
                        ? null
                        : () => viewModel.openTransaction(transaction),
                  ),
              ],
            ],
          ),
        ),
        if (state.loadingMore)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Identified(
              id: TransactionsIds.listLoadingMoreText,
              label: context.tr('transactions.list.loading_more'),
              child: const Center(
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        if (loadMoreError != null)
          AppBanner(
            id: TransactionsIds.listLoadMoreErrorText,
            message: context.tr(loadMoreError),
            tone: AppBannerTone.error,
            action: AppButton(
              id: TransactionsIds.listLoadMoreRetryButton,
              label: context.tr('transactions.common.retry'),
              variant: AppButtonVariant.text,
              onPressed: viewModel.retryLoadMore,
            ),
          ),
      ],
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({
    required this.transaction,
    required this.zone,
    required this.onTap,
  });

  final Transaction transaction;
  final Country zone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String id = transaction.id;
    return AppTappable(
      id: TransactionsIds.listItem(id),
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          ExcludeSemantics(
            child: Icon(
              _typeIcon(transaction.type),
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.tr('transactions.type.${transaction.type.name}'),
                  style: theme.textTheme.titleMedium,
                ),
                Identified(
                  id: TransactionsIds.listItemDescriptionText(id),
                  child: Text(
                    '${transaction.description} · '
                    '${Formatters.time(transaction.createdAt, country: zone, locale: context.languageCode)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          MoneyText(
            id: TransactionsIds.listItemAmountText(id),
            money: transaction.amount,
            signed: true,
            size: MoneyTextSize.compact,
          ),
        ],
      ),
    );
  }
}
