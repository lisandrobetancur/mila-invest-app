part of 'home.dart';

class _HomeData extends ConsumerWidget {
  const _HomeData({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DashboardHomeViewModel viewModel = ref.read(
      dashboardHomeViewModelProvider.notifier,
    );
    final PortfolioSummary portfolio = summary.portfolio;
    final Currency base = portfolio.baseCurrency;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int columns = AppLayout.of(context).dashboardColumns;
    final List<Widget> cards = <Widget>[
      StatTile(
        id: DashboardIds.homeTotalTile,
        label: context.tr('dashboard.home.total'),
        value: MoneyText(
          id: DashboardIds.homeTotalText,
          money: portfolio.totalValue,
          size: MoneyTextSize.display,
        ),
        change: PriceChange(
          id: DashboardIds.homeDayChangeText,
          currency: base,
          amount: portfolio.dayChange,
          percent: portfolio.dayChangePercent,
          variant: PriceChangeVariant.chip,
        ),
      ),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              context.tr('dashboard.home.allocation_title'),
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            AllocationDonut(
              id: DashboardIds.homeAllocationChart,
              currency: base,
              compact: true,
              semanticLabel: context.tr(
                'dashboard.home.allocation_summary',
                namedArgs: <String, String>{
                  'slices': portfolio.allocation
                      .map(
                        (AllocationEntry entry) =>
                            '${context.tr('dashboard.allocation.${entry.type.name}')} '
                            '${Formatters.share(entry.percent, currency: base)}',
                      )
                      .join(', '),
                },
              ),
              slices: <AllocationSlice>[
                for (final AllocationEntry entry in portfolio.allocation)
                  AllocationSlice(
                    id: DashboardIds.allocationItem(entry.type.apiCode),
                    label: context.tr(
                      'dashboard.allocation.${entry.type.name}',
                    ),
                    percent: entry.percent,
                  ),
              ],
            ),
          ],
        ),
      ),
      _MoversCard(
        titleId: DashboardIds.homeGainersTitleText,
        titleKey: 'dashboard.home.gainers',
        instruments: summary.gainers,
        onTap: viewModel.openInstrument,
      ),
      _MoversCard(
        titleId: DashboardIds.homeLosersTitleText,
        titleKey: 'dashboard.home.losers',
        instruments: summary.losers,
        onTap: viewModel.openInstrument,
      ),
      _RecentCard(
        transactions: summary.recentTransactions,
        onSeeAll: viewModel.goToActivity,
      ),
    ];
    return Identified(
      id: DashboardIds.homeStateData,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width =
              (constraints.maxWidth - AppSpacing.md * (columns - 1)) / columns;
          return Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: <Widget>[
              for (final Widget card in cards)
                SizedBox(width: width, child: card),
            ],
          );
        },
      ),
    );
  }
}

class _MoversCard extends StatelessWidget {
  const _MoversCard({
    required this.titleId,
    required this.titleKey,
    required this.instruments,
    required this.onTap,
  });

  final String titleId;
  final String titleKey;
  final List<Instrument> instruments;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(AppSpacing.xs),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Identified(
            id: titleId,
            child: Text(
              context.tr(titleKey),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        for (final Instrument instrument in instruments)
          InstrumentTile(
            id: DashboardIds.moverItem(instrument.id),
            ticker: instrument.ticker,
            name: instrument.name,
            country: instrument.country,
            countryName: context.tr(
              'dashboard.country.${instrument.country.code.toLowerCase()}',
            ),
            price: instrument.lastPrice,
            changePercent: instrument.changePercent,
            onTap: () => onTap(instrument.id),
          ),
      ],
    ),
  );
}

class _RecentCard extends ConsumerWidget {
  const _RecentCard({required this.transactions, required this.onSeeAll});

  final List<Transaction> transactions;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Country zone = ref.watch(sessionProvider).user?.country ?? Country.co;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Identified(
                  id: DashboardIds.homeRecentTitleText,
                  child: Text(
                    context.tr('dashboard.home.recent'),
                    style: textTheme.titleMedium,
                  ),
                ),
              ),
              AppButton(
                id: DashboardIds.homeRecentAllButton,
                label: context.tr('dashboard.home.see_all'),
                variant: AppButtonVariant.text,
                onPressed: onSeeAll,
              ),
            ],
          ),
          for (final Transaction transaction in transactions)
            Identified(
              id: DashboardIds.recentItem(transaction.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          transaction.description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: textTheme.titleMedium?.color,
                          ),
                        ),
                        Text(
                          Formatters.dateTime(
                            transaction.createdAt,
                            country: zone,
                            locale: context.languageCode,
                          ),
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                    MoneyText(
                      id: DashboardIds.recentItemAmountText(transaction.id),
                      money: transaction.amount,
                      signed: true,
                      size: MoneyTextSize.compact,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
