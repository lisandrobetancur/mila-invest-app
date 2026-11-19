part of 'market_list.dart';

class _MarketListEmpty extends StatelessWidget {
  const _MarketListEmpty({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => EmptyState(
    id: MarketIds.listStateEmpty,
    titleId: MarketIds.listEmptyTitleText,
    icon: AppIcons.emptySearch,
    title: context.tr('market.list.empty_title'),
    message: context.tr('market.list.empty_body'),
    action: EmptyStateAction(
      id: MarketIds.listClearFiltersButton,
      label: context.tr('market.list.clear_filters'),
      onPressed: onClear,
    ),
  );
}
