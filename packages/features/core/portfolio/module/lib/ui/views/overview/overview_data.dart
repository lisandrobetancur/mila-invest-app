part of 'overview.dart';

class _OverviewData extends ConsumerWidget {
  const _OverviewData({required this.portfolio});

  final Portfolio portfolio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PortfolioOverviewViewModel viewModel = ref.read(
      portfolioOverviewViewModelProvider.notifier,
    );
    final PortfolioSummary summary = portfolio.summary;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Currency base = summary.baseCurrency;
    final bool wide = AppLayout.of(context).isWide;
    final Widget totals = StatTile(
      id: PortfolioIds.overviewTotalTile,
      label: context.tr('portfolio.overview.total'),
      value: MoneyText(
        id: PortfolioIds.overviewTotalText,
        money: summary.totalValue,
        size: MoneyTextSize.display,
      ),
      change: PriceChange(
        id: PortfolioIds.overviewDayChangeText,
        currency: base,
        amount: summary.dayChange,
        percent: summary.dayChangePercent,
        variant: PriceChangeVariant.chip,
      ),
    );
    final Widget split = AppCard(
      child: Wrap(
        spacing: AppSpacing.xl,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                context.tr('portfolio.overview.cash'),
                style: textTheme.bodySmall,
              ),
              MoneyText(
                id: PortfolioIds.overviewCashText,
                money: summary.cashValue,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                context.tr('portfolio.overview.invested'),
                style: textTheme.bodySmall,
              ),
              MoneyText(
                id: PortfolioIds.overviewInvestedText,
                money: summary.investedValue,
              ),
            ],
          ),
        ],
      ),
    );
    final Widget allocation = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.tr('portfolio.overview.allocation_title'),
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          AllocationDonut(
            id: PortfolioIds.overviewAllocationChart,
            currency: base,
            semanticLabel: context.tr(
              'portfolio.overview.allocation_summary',
              namedArgs: <String, String>{
                'slices': summary.allocation
                    .map(
                      (AllocationEntry entry) =>
                          '${_sliceLabel(context, entry.type)} '
                          '${Formatters.share(entry.percent, currency: base)}',
                    )
                    .join(', '),
              },
            ),
            slices: <AllocationSlice>[
              for (final AllocationEntry entry in summary.allocation)
                AllocationSlice(
                  id: PortfolioIds.allocationItem(entry.type.apiCode),
                  label: _sliceLabel(context, entry.type),
                  percent: entry.percent,
                ),
            ],
          ),
        ],
      ),
    );
    return Identified(
      id: PortfolioIds.overviewStateData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      totals,
                      const SizedBox(height: AppSpacing.md),
                      split,
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: allocation),
              ],
            )
          else ...<Widget>[
            totals,
            const SizedBox(height: AppSpacing.md),
            split,
            const SizedBox(height: AppSpacing.md),
            allocation,
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.tr('portfolio.overview.positions_title'),
            style: textTheme.titleMedium,
          ),
          Text(
            context.tr('portfolio.overview.pnl_help'),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final Position position in portfolio.positions)
            _PositionTile(
              position: position,
              onTap: () => viewModel.openPosition(position),
            ),
          if (portfolio.fxRates.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Identified(
              id: PortfolioIds.overviewFxText,
              child: Text(
                context.tr(
                  'portfolio.overview.fx_note',
                  namedArgs: <String, String>{
                    'currency': base.code,
                    'rates': portfolio.fxRates
                        .map(
                          (FxRate rate) =>
                              '1 ${rate.from.code} = '
                              '${Formatters.amount(Money(rate.rate.round(scale: 2), rate.to))} '
                              '${rate.to.code}',
                        )
                        .join(' · '),
                  },
                ),
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PositionTile extends StatelessWidget {
  const _PositionTile({required this.position, required this.onTap});

  final Position position;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String id = position.instrument.id;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: AppTappable(
        id: PortfolioIds.positionItem(id),
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(position.instrument.ticker, style: textTheme.titleMedium),
                Identified(
                  id: PortfolioIds.positionQuantityText(id),
                  child: Text(
                    context.tr(
                      'portfolio.overview.quantity',
                      namedArgs: <String, String>{
                        'quantity': Formatters.quantity(
                          position.quantity,
                          locale: position.currency.formatLocale,
                        ),
                      },
                    ),
                    style: textTheme.bodySmall,
                  ),
                ),
                Wrap(
                  spacing: AppSpacing.xxs,
                  children: <Widget>[
                    Text(
                      context.tr('portfolio.overview.avg_cost'),
                      style: textTheme.bodySmall,
                    ),
                    MoneyText(
                      id: PortfolioIds.positionAvgCostText(id),
                      money: position.avgCost,
                      isPrice: true,
                      size: MoneyTextSize.compact,
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MoneyText(
                  id: PortfolioIds.positionValueText(id),
                  money: position.marketValue,
                  size: MoneyTextSize.compact,
                ),
                PriceChange(
                  id: PortfolioIds.positionPnlText(id),
                  currency: position.currency,
                  amount: position.unrealizedPnl,
                  percent: position.unrealizedPnlPercent,
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
