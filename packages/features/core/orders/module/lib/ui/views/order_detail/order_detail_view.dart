part of 'order_detail.dart';

/// Detalle de una orden.
class OrderDetailView extends ConsumerWidget {
  /// Crea el detalle de [orderId].
  const OrderDetailView({required this.orderId, super.key});

  /// Path de la ruta, relativo al historial.
  static const String route = OrdersRoutes.detailSubPath;

  /// Nombre de la ruta.
  static const String name = OrdersRoutes.detailName;

  /// Id de la orden.
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OrderDetailState state = ref.watch(
      orderDetailViewModelProvider(orderId),
    );
    final OrderDetailViewModel viewModel = ref.read(
      orderDetailViewModelProvider(orderId).notifier,
    );
    return AppScaffold(
      id: OrdersIds.detailView,
      title: context.tr('orders.detail.title'),
      maxWidth: 640,
      leading: AppIconButton(
        id: OrdersIds.detailBackIconButton,
        icon: AppIcons.back,
        tooltip: context.tr('orders.common.back'),
        onPressed: viewModel.back,
      ),
      body: switch (state.status) {
        ViewStatus.loading => const _OrderDetailShimmer(),
        ViewStatus.data => _OrderDetailData(order: state.order!),
        ViewStatus.empty => _OrderDetailEmpty(onBack: viewModel.goToHistory),
        ViewStatus.error => _OrderDetailError(
          state: state,
          onRetry: viewModel.load,
        ),
      },
    );
  }
}
