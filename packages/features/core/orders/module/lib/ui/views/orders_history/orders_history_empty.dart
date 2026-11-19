part of 'orders_history.dart';

class _OrdersHistoryEmpty extends StatelessWidget {
  const _OrdersHistoryEmpty({required this.filtered, required this.onExplore});

  final bool filtered;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) => EmptyState(
    id: OrdersIds.historyStateEmpty,
    titleId: OrdersIds.historyEmptyTitleText,
    icon: AppIcons.emptyList,
    title: context.tr(
      filtered
          ? 'orders.history.empty_filtered_title'
          : 'orders.history.empty_title',
    ),
    message: filtered ? null : context.tr('orders.history.empty_body'),
    action: filtered
        ? null
        : EmptyStateAction(
            id: OrdersIds.historyExploreButton,
            label: context.tr('orders.history.explore'),
            onPressed: onExplore,
          ),
  );
}
