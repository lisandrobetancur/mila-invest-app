part of 'instrument_detail.dart';

class _InstrumentDetailEmpty extends StatelessWidget {
  const _InstrumentDetailEmpty({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => EmptyState(
    id: MarketIds.detailStateEmpty,
    titleId: MarketIds.detailNotFoundTitleText,
    icon: AppIcons.notFound,
    title: context.tr('market.detail.not_found_title'),
    message: context.tr('market.detail.not_found_body'),
    action: EmptyStateAction(
      id: MarketIds.detailBackToMarketButton,
      label: context.tr('market.detail.back_to_market'),
      onPressed: onBack,
    ),
  );
}
