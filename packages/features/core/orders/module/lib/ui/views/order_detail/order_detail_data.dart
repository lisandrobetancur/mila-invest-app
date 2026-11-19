part of 'order_detail.dart';

class _OrderDetailData extends ConsumerWidget {
  const _OrderDetailData({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OrderDetailViewModel viewModel = ref.read(
      orderDetailViewModelProvider(order.id).notifier,
    );
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Country zone = ref.watch(sessionProvider).user?.country ?? Country.co;
    final String locale = context.languageCode;
    final DateTime? filledAt = order.filledAt;
    final OrdersErrorCode? rejection = order.rejectCode;
    final Money? executed = order.executedPrice;
    final Money? gross = order.gross;
    final Money? commission = order.commission;
    final Money? total = order.total;
    Widget row(String labelKey, String id, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: AppSpacing.sm,
        children: <Widget>[
          Text(context.tr(labelKey), style: textTheme.bodyMedium),
          Identified(
            id: id,
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: textTheme.titleMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
    return Identified(
      id: OrdersIds.detailStateData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OrderStatusBadge(
              id: OrdersIds.detailStatusText,
              status: order.status,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                row(
                  'orders.detail.instrument',
                  OrdersIds.detailInstrumentText,
                  order.instrumentId,
                ),
                row(
                  'orders.detail.side',
                  OrdersIds.detailSideText,
                  context.tr(
                    order.side.isBuy
                        ? 'orders.common.buy'
                        : 'orders.common.sell',
                  ),
                ),
                row(
                  'orders.detail.quantity',
                  OrdersIds.detailQuantityText,
                  Formatters.quantity(
                    order.quantity,
                    locale: order.currency.formatLocale,
                  ),
                ),
                row(
                  'orders.detail.created',
                  OrdersIds.detailCreatedText,
                  Formatters.dateTime(
                    order.createdAt,
                    country: zone,
                    locale: locale,
                  ),
                ),
                if (filledAt != null)
                  row(
                    'orders.detail.filled',
                    OrdersIds.detailFilledText,
                    Formatters.dateTime(
                      filledAt,
                      country: zone,
                      locale: locale,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (executed != null &&
              gross != null &&
              commission != null &&
              total != null)
            AppCard(
              child: OrderSummary(
                ids: const OrderSummaryIds(
                  root: OrdersIds.summaryPanel,
                  price: OrdersIds.summaryPriceText,
                  gross: OrdersIds.summaryGrossText,
                  commission: OrdersIds.summaryCommissionText,
                  total: OrdersIds.summaryTotalText,
                  availableAfter: OrdersIds.summaryAvailableAfterText,
                ),
                labels: OrderSummaryLabels(
                  price: context.tr('orders.summary.executed_price'),
                  gross: context.tr('orders.summary.gross'),
                  commission: context.tr('orders.summary.commission'),
                  total: context.tr(
                    order.side.isBuy
                        ? 'orders.summary.total_buy'
                        : 'orders.summary.total_sell',
                  ),
                  availableAfter: context.tr('orders.summary.available_after'),
                ),
                price: executed,
                gross: gross,
                commission: commission,
                total: total,
              ),
            ),
          if (rejection != null)
            AppBanner(
              id: OrdersIds.detailRejectReasonText,
              message: context.tr(rejection.messageKey),
              tone: AppBannerTone.error,
            ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            id: OrdersIds.detailInstrumentButton,
            label: context.tr('orders.detail.view_instrument'),
            variant: AppButtonVariant.secondary,
            onPressed: viewModel.openInstrument,
          ),
        ],
      ),
    );
  }
}
