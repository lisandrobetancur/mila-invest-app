part of 'order_ticket.dart';

class _OrderTicketData extends ConsumerStatefulWidget {
  const _OrderTicketData({required this.args});

  final OrderTicketArgs args;

  @override
  ConsumerState<_OrderTicketData> createState() => _OrderTicketDataState();
}

class _OrderTicketDataState extends ConsumerState<_OrderTicketData> {
  late final TextEditingController _quantity = TextEditingController(
    text: ref.read(orderTicketViewModelProvider(widget.args)).quantityText,
  );

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OrderTicketState state = ref.watch(
      orderTicketViewModelProvider(widget.args),
    );
    final OrderTicketViewModel viewModel = ref.read(
      orderTicketViewModelProvider(widget.args).notifier,
    );
    ref.listen<String>(
      orderTicketViewModelProvider(
        widget.args,
      ).select((OrderTicketState next) => next.quantityText),
      (String? previous, String next) {
        if (_quantity.text != next) {
          _quantity.text = next;
        }
      },
    );
    final ThemeData theme = Theme.of(context);
    final MarketColors market = theme.market;
    final Instrument instrument = state.instrument!;
    final String? quantityError = state.quantityErrorKey;
    final Money? available = state.available;
    final OrderPreview? preview = state.isPreviewCurrent ? state.preview : null;
    final OrdersErrorCode? previewError = state.previewErrorCode;
    return Identified(
      id: OrdersIds.ticketStateData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Identified(
            id: OrdersIds.ticketInstrumentText,
            child: Text(
              '${instrument.ticker} · ${instrument.name}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          MoneyText(
            id: OrdersIds.ticketPriceText,
            money: instrument.lastPrice,
            isPrice: true,
            size: MoneyTextSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          AppSegmentedControl<OrderSide>(
            id: OrdersIds.ticketSideMenu,
            selected: state.side,
            onChanged: viewModel.setSide,
            segments: <AppSegment<OrderSide>>[
              AppSegment<OrderSide>(
                id: OrdersIds.ticketSideBuySegment,
                value: OrderSide.buy,
                label: context.tr('orders.common.buy'),
                selectedColor: market.gain,
              ),
              AppSegment<OrderSide>(
                id: OrdersIds.ticketSideSellSegment,
                value: OrderSide.sell,
                label: context.tr('orders.common.sell'),
                selectedColor: market.loss,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppIconButton(
                id: OrdersIds.ticketQuantityDecreaseStepper,
                icon: AppIcons.remove,
                tooltip: context.tr('orders.ticket.decrease'),
                onPressed: viewModel.decrement,
              ),
              Expanded(
                child: AppTextField.numeric(
                  id: OrdersIds.ticketQuantityField,
                  label: context.tr('orders.ticket.quantity'),
                  controller: _quantity,
                  allowDecimal: false,
                  maxLength: 7,
                  errorText: quantityError == null
                      ? null
                      : context.tr(quantityError),
                  onChanged: viewModel.setQuantityText,
                ),
              ),
              AppIconButton(
                id: OrdersIds.ticketQuantityIncreaseStepper,
                icon: AppIcons.add,
                tooltip: context.tr('orders.ticket.increase'),
                onPressed: viewModel.increment,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.side.isBuy && available != null)
            Wrap(
              spacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  context.tr('orders.ticket.available'),
                  style: theme.textTheme.bodyMedium,
                ),
                MoneyText(
                  id: OrdersIds.ticketAvailableText,
                  money: available,
                  size: MoneyTextSize.compact,
                ),
              ],
            ),
          if (!state.side.isBuy)
            Identified(
              id: OrdersIds.ticketPositionText,
              child: Text(
                context.tr(
                  'orders.ticket.position',
                  namedArgs: <String, String>{
                    'quantity': Formatters.quantity(
                      state.heldQuantity,
                      locale: instrument.currency.formatLocale,
                    ),
                  },
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          if (!state.canTrade)
            AppBanner(
              id: OrdersIds.ticketClosedReasonText,
              message: context.tr('orders.ticket.closed_reason'),
              tone: AppBannerTone.warning,
            )
          else if (state.previewStatus == PreviewStatus.loading)
            Identified(
              id: OrdersIds.ticketPreviewLoadingText,
              label: context.tr('orders.ticket.previewing'),
              child: const AppShimmer(
                child: AppShimmerBox(height: 140, radius: 16),
              ),
            )
          else if (preview != null)
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
            )
          else if (previewError != null)
            AppBanner(
              id: OrdersIds.ticketPreviewErrorText,
              message: context.tr(previewError.messageKey),
              tone: AppBannerTone.error,
            ),
          if (preview != null && preview.hasLowBalanceWarning) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            AppBanner(
              id: OrdersIds.ticketLowBalanceText,
              message: context.tr('orders.ticket.low_balance'),
              tone: AppBannerTone.warning,
            ),
          ],
          if (state.needsDeposit) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              id: OrdersIds.ticketDepositButton,
              label: context.tr('orders.ticket.deposit'),
              icon: AppIcons.deposit,
              variant: AppButtonVariant.secondary,
              expanded: true,
              onPressed: viewModel.deposit,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            id: OrdersIds.ticketReviewButton,
            label: context.tr('orders.ticket.review'),
            expanded: true,
            onPressed: state.canReview ? viewModel.review : null,
          ),
        ],
      ),
    );
  }
}
