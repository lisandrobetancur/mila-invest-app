part of 'orders_history.dart';

/// Historial de órdenes, dentro de la tab Actividad.
class OrdersHistoryView extends ConsumerStatefulWidget {
  /// Crea el historial con los parámetros de su ruta (filtro en la query).
  const OrdersHistoryView({required this.params, super.key});

  /// Path de la ruta.
  static const String route = OrdersRoutes.historyPath;

  /// Nombre de la ruta.
  static const String name = OrdersRoutes.historyName;

  /// Parámetros de la ruta.
  final AppRouteParams params;

  /// Filtro de estado que trae la URL.
  static OrderStatus? statusOf(AppRouteParams params) {
    final String? status = params.query(OrdersRoutes.statusQuery);
    return status == null ? null : OrderStatus.tryFromApiCode(status);
  }

  @override
  ConsumerState<OrdersHistoryView> createState() => _OrdersHistoryViewState();
}

class _OrdersHistoryViewState extends ConsumerState<OrdersHistoryView> {
  @override
  void initState() {
    super.initState();
    ref
        .read(ordersHistoryViewModelProvider.notifier)
        .start(OrdersHistoryView.statusOf(widget.params));
  }

  @override
  void didUpdateWidget(OrdersHistoryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final OrderStatus? status = OrdersHistoryView.statusOf(widget.params);
    if (status != OrdersHistoryView.statusOf(oldWidget.params)) {
      ref
          .read(ordersHistoryViewModelProvider.notifier)
          .applyRouteFilter(status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final OrdersHistoryState state = ref.watch(ordersHistoryViewModelProvider);
    final OrdersHistoryViewModel viewModel = ref.read(
      ordersHistoryViewModelProvider.notifier,
    );
    final double padding = AppLayout.of(context).pagePadding;
    return AppScaffold(
      id: OrdersIds.historyView,
      title: context.tr('orders.history.title'),
      scrollable: false,
      padded: false,
      onRefresh: () => viewModel.refresh(silent: true),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          final ScrollMetrics metrics = notification.metrics;
          if (metrics.axis == Axis.vertical &&
              metrics.pixels >=
                  metrics.maxScrollExtent * OrdersLimits.loadMoreThreshold) {
            viewModel.loadMore();
          }
          return false;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: AppSpacing.sm,
          ),
          children: <Widget>[
            AppSegmentedControl<bool>(
              id: OrdersIds.historySectionMenu,
              selected: true,
              onChanged: (bool orders) {
                if (!orders) {
                  viewModel.goToMovements();
                }
              },
              segments: <AppSegment<bool>>[
                AppSegment<bool>(
                  id: OrdersIds.historyMovementsTab,
                  value: false,
                  label: context.tr('orders.history.movements'),
                ),
                AppSegment<bool>(
                  id: OrdersIds.historyOrdersTab,
                  value: true,
                  label: context.tr('orders.history.orders'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                for (final OrderStatus? status in <OrderStatus?>[
                  null,
                  ...OrderStatus.values,
                ])
                  AppChip(
                    id: _statusChipId(status),
                    label: status == null
                        ? context.tr('orders.history.status_all')
                        : context.tr('orders.status.${status.name}'),
                    selected: state.filter == status,
                    onSelected: (_) => viewModel.setFilter(status),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            switch (state.status) {
              ViewStatus.loading => const _OrdersHistoryShimmer(),
              ViewStatus.data => _OrdersHistoryData(state: state),
              ViewStatus.empty => _OrdersHistoryEmpty(
                filtered: state.filter != null,
                onExplore: viewModel.goToMarket,
              ),
              ViewStatus.error => _OrdersHistoryError(state: state),
            },
          ],
        ),
      ),
    );
  }
}

String _statusChipId(OrderStatus? status) => switch (status) {
  null => OrdersIds.historyStatusAllChip,
  OrderStatus.pending => OrdersIds.historyStatusPendingChip,
  OrderStatus.filled => OrdersIds.historyStatusFilledChip,
  OrderStatus.rejected => OrdersIds.historyStatusRejectedChip,
  OrderStatus.cancelled => OrdersIds.historyStatusCancelledChip,
};
