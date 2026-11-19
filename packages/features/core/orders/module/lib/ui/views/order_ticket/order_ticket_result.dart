part of 'order_ticket.dart';

class _OrderTicketResult extends ConsumerWidget {
  const _OrderTicketResult({required this.args});

  final OrderTicketArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OrderTicketState state = ref.watch(
      orderTicketViewModelProvider(args),
    );
    final OrderTicketViewModel viewModel = ref.read(
      orderTicketViewModelProvider(args).notifier,
    );
    final ThemeData theme = Theme.of(context);
    final Order? order = state.order;
    final OrderStatus status = order?.status ?? OrderStatus.rejected;
    final OrdersErrorCode? rejection = state.resultRejection;
    final Money? difference = state.priceDifference;
    final Money? executed = order?.executedPrice;
    final Money? gross = order?.gross;
    final Money? commission = order?.commission;
    final Money? total = order?.total;
    return Identified(
      id: OrdersIds.resultView,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                state.isFilled ? AppIcons.success : AppIcons.error,
                color: state.isFilled
                    ? theme.market.gain
                    : theme.colorScheme.error,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  context.tr('orders.result.title_${status.name}'),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              OrderStatusBadge(id: OrdersIds.resultStatusText, status: status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (executed != null &&
              gross != null &&
              commission != null &&
              total != null)
            AppCard(
              child: OrderSummary(
                ids: _summaryIds,
                labels: _summaryLabels(
                  context,
                  side: state.side,
                  executed: true,
                ),
                price: executed,
                gross: gross,
                commission: commission,
                total: total,
              ),
            ),
          if (difference != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            AppBanner(
              id: OrdersIds.resultPriceDifferenceText,
              message: context.tr(
                'orders.result.price_difference',
                namedArgs: <String, String>{
                  'difference': Formatters.signedMoney(difference),
                },
              ),
            ),
          ],
          if (rejection != null && !state.isFilled) ...<Widget>[
            AppBanner(
              id: OrdersIds.resultRejectReasonText,
              message: context.tr(rejection.messageKey),
              tone: AppBannerTone.error,
            ),
            if (rejection.suggestsDeposit) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                id: OrdersIds.resultSuggestedActionButton,
                label: context.tr('orders.result.deposit'),
                icon: AppIcons.deposit,
                variant: AppButtonVariant.secondary,
                expanded: true,
                onPressed: viewModel.deposit,
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.md),
          if (state.isFilled) ...<Widget>[
            AppButton(
              id: OrdersIds.resultPortfolioButton,
              label: context.tr('orders.result.portfolio'),
              expanded: true,
              onPressed: viewModel.goToPortfolio,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          AppButton(
            id: OrdersIds.resultDoneButton,
            label: context.tr('orders.result.done'),
            variant: state.isFilled
                ? AppButtonVariant.text
                : AppButtonVariant.primary,
            expanded: true,
            onPressed: viewModel.close,
          ),
        ],
      ),
    );
  }
}
