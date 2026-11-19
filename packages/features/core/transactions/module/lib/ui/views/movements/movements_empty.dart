part of 'movements.dart';

class _MovementsEmpty extends StatelessWidget {
  const _MovementsEmpty({
    required this.filtered,
    required this.onDeposit,
    required this.onClear,
  });

  final bool filtered;
  final VoidCallback onDeposit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => EmptyState(
    id: TransactionsIds.listStateEmpty,
    titleId: TransactionsIds.listEmptyTitleText,
    icon: filtered ? AppIcons.emptySearch : AppIcons.emptyList,
    title: context.tr(
      filtered
          ? 'transactions.list.empty_filtered_title'
          : 'transactions.list.empty_title',
    ),
    message: filtered ? null : context.tr('transactions.list.empty_body'),
    action: filtered
        ? EmptyStateAction(
            id: TransactionsIds.listClearFiltersButton,
            label: context.tr('transactions.list.clear_filters'),
            onPressed: onClear,
          )
        : EmptyStateAction(
            id: TransactionsIds.listEmptyDepositButton,
            label: context.tr('transactions.list.empty_deposit'),
            onPressed: onDeposit,
          ),
  );
}
