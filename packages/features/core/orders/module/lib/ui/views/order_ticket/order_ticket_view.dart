part of 'order_ticket.dart';

/// Ticket de orden: bottom sheet en mobile y diálogo en web ancho.
///
/// Tiene tres pasos dentro de la misma ruta: editar (con preview
/// automático), confirmar y resultado.
class OrderTicketView extends ConsumerWidget {
  /// Crea el ticket de [instrumentId] con el lado [side].
  const OrderTicketView({
    required this.instrumentId,
    required this.side,
    super.key,
  });

  /// Path de la ruta.
  static const String route = OrdersRoutes.ticketPath;

  /// Nombre de la ruta.
  static const String name = OrdersRoutes.ticketName;

  /// Instrumento.
  final String instrumentId;

  /// Lado inicial.
  final OrderSide side;

  /// Argumento del controller.
  OrderTicketArgs get args =>
      OrderTicketArgs(instrumentId: instrumentId, side: side);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OrderTicketState state = ref.watch(
      orderTicketViewModelProvider(args),
    );
    final OrderTicketViewModel viewModel = ref.read(
      orderTicketViewModelProvider(args).notifier,
    );
    final ThemeData theme = Theme.of(context);
    final String ticker = state.instrument?.ticker ?? '';
    return Identified(
      id: OrdersIds.ticketView,
      child: Material(
        color: theme.colorScheme.surface,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xxs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              if (ticker.isNotEmpty)
                                Text(
                                  context.tr(
                                    state.side.isBuy
                                        ? 'orders.ticket.title_buy'
                                        : 'orders.ticket.title_sell',
                                    namedArgs: <String, String>{
                                      'ticker': ticker,
                                    },
                                  ),
                                  style: theme.textTheme.titleLarge,
                                ),
                              AppBadge(
                                id: OrdersIds.ticketSimulatedText,
                                label: context.tr('orders.common.simulated'),
                                tone: AppBadgeTone.accent,
                              ),
                            ],
                          ),
                        ),
                        AppIconButton(
                          id: OrdersIds.ticketCloseIconButton,
                          icon: AppIcons.close,
                          tooltip: context.tr('orders.common.close'),
                          onPressed: viewModel.close,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    switch (state.status) {
                      ViewStatus.loading => const _OrderTicketShimmer(),
                      ViewStatus.data => switch (state.step) {
                        TicketStep.edit => _OrderTicketData(args: args),
                        TicketStep.confirm => _OrderTicketConfirm(args: args),
                        TicketStep.result => _OrderTicketResult(args: args),
                      },
                      ViewStatus.empty => _OrderTicketEmpty(
                        onClose: viewModel.close,
                      ),
                      ViewStatus.error => _OrderTicketError(
                        state: state,
                        onRetry: viewModel.load,
                      ),
                    },
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

OrderSummaryLabels _summaryLabels(
  BuildContext context, {
  required OrderSide side,
  required bool executed,
}) => OrderSummaryLabels(
  price: context.tr(
    executed
        ? 'orders.summary.executed_price'
        : 'orders.summary.estimated_price',
  ),
  gross: context.tr('orders.summary.gross'),
  commission: context.tr('orders.summary.commission'),
  total: context.tr(
    side.isBuy ? 'orders.summary.total_buy' : 'orders.summary.total_sell',
  ),
  availableAfter: context.tr('orders.summary.available_after'),
);

const OrderSummaryIds _summaryIds = OrderSummaryIds(
  root: OrdersIds.summaryPanel,
  price: OrdersIds.summaryPriceText,
  gross: OrdersIds.summaryGrossText,
  commission: OrdersIds.summaryCommissionText,
  total: OrdersIds.summaryTotalText,
  availableAfter: OrdersIds.summaryAvailableAfterText,
);
