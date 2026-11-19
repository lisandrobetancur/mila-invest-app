part of 'order_detail.dart';

class _OrderDetailEmpty extends StatelessWidget {
  const _OrderDetailEmpty({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => EmptyState(
    id: OrdersIds.detailStateEmpty,
    titleId: OrdersIds.detailNotFoundTitleText,
    icon: AppIcons.notFound,
    title: context.tr('orders.detail.not_found_title'),
    action: EmptyStateAction(
      id: OrdersIds.detailBackToHistoryButton,
      label: context.tr('orders.detail.back_to_history'),
      onPressed: onBack,
    ),
  );
}
