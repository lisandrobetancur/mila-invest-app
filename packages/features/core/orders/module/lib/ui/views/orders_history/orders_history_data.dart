part of 'orders_history.dart';

class _OrdersHistoryData extends ConsumerWidget {
  const _OrdersHistoryData({required this.state});

  final OrdersHistoryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OrdersHistoryViewModel viewModel = ref.read(
      ordersHistoryViewModelProvider.notifier,
    );
    final String? loadMoreError = state.loadMoreErrorKey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Identified(
          id: OrdersIds.historyStateData,
          child: Column(
            children: <Widget>[
              for (final Order order in state.orders.items)
                _OrderTile(
                  order: order,
                  onTap: () => viewModel.openOrder(order),
                ),
            ],
          ),
        ),
        if (state.loadingMore)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Identified(
              id: OrdersIds.historyLoadingMoreText,
              label: context.tr('orders.history.loading_more'),
              child: const Center(
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        if (loadMoreError != null)
          AppBanner(
            id: OrdersIds.historyLoadMoreErrorText,
            message: context.tr(loadMoreError),
            tone: AppBannerTone.error,
            action: AppButton(
              id: OrdersIds.historyLoadMoreRetryButton,
              label: context.tr('orders.common.retry'),
              variant: AppButtonVariant.text,
              onPressed: viewModel.retryLoadMore,
            ),
          ),
      ],
    );
  }
}

class _OrderTile extends ConsumerWidget {
  const _OrderTile({required this.order, required this.onTap});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Country zone = ref.watch(sessionProvider).user?.country ?? Country.co;
    final Money? total = order.total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: AppTappable(
        id: OrdersIds.historyItem(order.id),
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  context.tr(
                    'orders.history.item',
                    namedArgs: <String, String>{
                      'side': context.tr(
                        order.side.isBuy
                            ? 'orders.common.buy'
                            : 'orders.common.sell',
                      ),
                      'quantity': Formatters.quantity(
                        order.quantity,
                        locale: order.currency.formatLocale,
                      ),
                      'ticker': order.ticker,
                    },
                  ),
                  style: textTheme.titleMedium,
                ),
                Text(
                  Formatters.dateTime(
                    order.createdAt,
                    country: zone,
                    locale: context.languageCode,
                  ),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                OrderStatusBadge(
                  id: OrdersIds.historyItemStatusText(order.id),
                  status: order.status,
                ),
                if (total != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxs),
                  MoneyText(
                    id: OrdersIds.historyItemTotalText(order.id),
                    money: total,
                    size: MoneyTextSize.compact,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
