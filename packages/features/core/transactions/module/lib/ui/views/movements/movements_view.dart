part of 'movements.dart';

/// Movimientos: depósitos, compras, ventas y comisiones agrupados por día,
/// con filtros por tipo y rango de fechas. Es la entrada de la tab
/// Actividad; la sección "Órdenes" vive en orders.
class MovementsView extends ConsumerStatefulWidget {
  /// Crea la vista con los parámetros de su ruta (filtros en la query).
  const MovementsView({required this.params, super.key});

  /// Path de la ruta.
  static const String route = TransactionsRoutes.movementsPath;

  /// Nombre de la ruta.
  static const String name = TransactionsRoutes.movementsName;

  /// Parámetros de la ruta.
  final AppRouteParams params;

  /// Filtros que trae la URL.
  static TransactionFilter filterOf(AppRouteParams params) {
    final String? type = params.query(TransactionsRoutes.typeQuery);
    final TransactionType? parsed = type == null
        ? null
        : TransactionType.fromApiCode(type);
    return TransactionFilter(
      type: parsed == TransactionType.other ? null : parsed,
      range: TransactionRange.fromCode(
        params.query(TransactionsRoutes.rangeQuery),
      ),
    );
  }

  @override
  ConsumerState<MovementsView> createState() => _MovementsViewState();
}

class _MovementsViewState extends ConsumerState<MovementsView> {
  @override
  void initState() {
    super.initState();
    ref
        .read(movementsViewModelProvider.notifier)
        .start(MovementsView.filterOf(widget.params));
  }

  @override
  void didUpdateWidget(MovementsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final TransactionFilter filter = MovementsView.filterOf(widget.params);
    if (filter != MovementsView.filterOf(oldWidget.params)) {
      ref.read(movementsViewModelProvider.notifier).applyRouteFilter(filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MovementsState state = ref.watch(movementsViewModelProvider);
    final MovementsViewModel viewModel = ref.read(
      movementsViewModelProvider.notifier,
    );
    final Currency base =
        ref.watch(sessionProvider).user?.baseCurrency ?? Currency.cop;
    return AppScaffold(
      id: TransactionsIds.listView,
      title: context.tr('transactions.list.title'),
      badge: AppBadge(
        id: TransactionsIds.listSimulatedText,
        label: context.tr('transactions.common.simulated'),
        tone: AppBadgeTone.accent,
      ),
      scrollable: false,
      padded: false,
      onRefresh: () => viewModel.refresh(silent: true),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          final ScrollMetrics metrics = notification.metrics;
          if (metrics.axis == Axis.vertical &&
              metrics.pixels >=
                  metrics.maxScrollExtent *
                      TransactionsLimits.loadMoreThreshold) {
            viewModel.loadMore();
          }
          return false;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: AppLayout.of(context).pagePadding,
            vertical: AppSpacing.sm,
          ),
          children: <Widget>[
            AppSegmentedControl<bool>(
              id: TransactionsIds.listSectionMenu,
              selected: false,
              onChanged: (bool orders) {
                if (orders) {
                  viewModel.goToOrders();
                }
              },
              segments: <AppSegment<bool>>[
                AppSegment<bool>(
                  id: TransactionsIds.listMovementsTab,
                  value: false,
                  label: context.tr('transactions.list.movements'),
                ),
                AppSegment<bool>(
                  id: TransactionsIds.listOrdersTab,
                  value: true,
                  label: context.tr('transactions.list.orders'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                for (final TransactionType? type in <TransactionType?>[
                  null,
                  ...TransactionType.filterable,
                ])
                  AppChip(
                    id: _typeChipId(type),
                    label: context.tr(
                      'transactions.list.type_${type?.name ?? 'all'}',
                    ),
                    selected: state.filter.type == type,
                    onSelected: (_) => viewModel.setType(type),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                for (final TransactionRange range in TransactionRange.values)
                  AppChip(
                    id: _rangeChipId(range),
                    label: context.tr('transactions.list.range_${range.code}'),
                    selected: state.filter.range == range,
                    onSelected: (_) => viewModel.setRange(range),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            switch (state.status) {
              ViewStatus.loading => const _MovementsShimmer(),
              ViewStatus.data => _MovementsData(state: state),
              ViewStatus.empty => _MovementsEmpty(
                filtered: !state.filter.isEmpty,
                onDeposit: () => viewModel.deposit(base),
                onClear: viewModel.clearFilters,
              ),
              ViewStatus.error => _MovementsError(state: state),
            },
          ],
        ),
      ),
    );
  }
}

String _typeChipId(TransactionType? type) => switch (type) {
  null => TransactionsIds.listTypeAllChip,
  TransactionType.deposit => TransactionsIds.listTypeDepositChip,
  TransactionType.buy => TransactionsIds.listTypeBuyChip,
  TransactionType.sell => TransactionsIds.listTypeSellChip,
  TransactionType.fee ||
  TransactionType.other => TransactionsIds.listTypeFeeChip,
};

String _rangeChipId(TransactionRange range) => switch (range) {
  TransactionRange.all => TransactionsIds.listRangeAllChip,
  TransactionRange.week => TransactionsIds.listRange7dChip,
  TransactionRange.month => TransactionsIds.listRange30dChip,
  TransactionRange.quarter => TransactionsIds.listRange90dChip,
};
