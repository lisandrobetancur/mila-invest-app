part of 'order_ticket.dart';

class _OrderTicketConfirm extends ConsumerWidget {
  const _OrderTicketConfirm({required this.args});

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
    final OrderPreview preview = state.preview!;
    final Instrument instrument = state.instrument!;
    final OrdersErrorCode? error = state.submitErrorCode;
    final bool isBuy = state.side.isBuy;
    return Identified(
      id: OrdersIds.confirmView,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppIconButton(
                id: OrdersIds.confirmBackIconButton,
                icon: AppIcons.back,
                tooltip: context.tr('orders.common.back'),
                onPressed: state.submitStatus.isSubmitting
                    ? null
                    : viewModel.backToEdit,
              ),
              Expanded(
                child: Text(
                  context.tr('orders.confirm.title'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Identified(
            id: OrdersIds.confirmOrderText,
            child: Text(
              context.tr(
                isBuy
                    ? 'orders.confirm.order_buy'
                    : 'orders.confirm.order_sell',
                namedArgs: <String, String>{
                  'quantity': Formatters.quantity(
                    state.quantity ?? 0,
                    locale: instrument.currency.formatLocale,
                  ),
                  'ticker': instrument.ticker,
                },
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: OrderSummary(
              ids: _summaryIds,
              labels: _summaryLabels(
                context,
                side: state.side,
                executed: false,
              ),
              price: preview.estimatedPrice,
              gross: preview.gross,
              commission: preview.commission,
              total: preview.total,
              availableAfter: preview.availableAfter,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DisclaimerBanner(
            id: OrdersIds.confirmDisclaimerText,
            text: context.tr('orders.common.disclaimer'),
          ),
          if (error != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            AppBanner(
              id: OrdersIds.confirmErrorText,
              message: context.tr(error.messageKey),
              tone: AppBannerTone.error,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            id: OrdersIds.confirmSubmitButton,
            label: context.tr(
              isBuy
                  ? 'orders.confirm.submit_buy'
                  : 'orders.confirm.submit_sell',
            ),
            variant: isBuy ? AppButtonVariant.buy : AppButtonVariant.sell,
            expanded: true,
            loading: state.submitStatus.isSubmitting,
            onPressed: viewModel.confirm,
          ),
        ],
      ),
    );
  }
}
