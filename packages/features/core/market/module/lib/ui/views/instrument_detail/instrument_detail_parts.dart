part of 'instrument_detail.dart';

String _rangeSegmentId(PriceRange range) => switch (range) {
  PriceRange.day => MarketIds.detailRange1dSegment,
  PriceRange.week => MarketIds.detailRange1wSegment,
  PriceRange.month => MarketIds.detailRange1mSegment,
  PriceRange.threeMonths => MarketIds.detailRange3mSegment,
  PriceRange.year => MarketIds.detailRange1ySegment,
};

String _rangeKey(PriceRange range) => range.apiCode.toLowerCase();

class _PriceHeader extends StatelessWidget {
  const _PriceHeader({required this.state});

  final InstrumentDetailState state;

  @override
  Widget build(BuildContext context) {
    final Instrument instrument = state.detail!.instrument;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final CountryMarket? market = state.market;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xxs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Identified(
              id: MarketIds.detailTickerText,
              child: Text(instrument.ticker, style: textTheme.titleLarge),
            ),
            CountryChip(
              id: MarketIds.detailCountryText,
              country: instrument.country,
              name: context.tr(
                'market.country.${instrument.country.code.toLowerCase()}',
              ),
            ),
          ],
        ),
        Identified(
          id: MarketIds.detailNameText,
          child: Text(instrument.name, style: textTheme.bodyMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        _FlashingPrice(
          tick: state.flashTick,
          sign: state.flashSign,
          child: MoneyText(
            id: MarketIds.detailPriceText,
            money: instrument.lastPrice,
            isPrice: true,
            size: MoneyTextSize.large,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        PriceChange(
          id: MarketIds.detailChangeText,
          currency: instrument.currency,
          amount: instrument.change,
          percent: instrument.changePercent,
          variant: PriceChangeVariant.chip,
        ),
        if (market != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          MarketStatusText(id: MarketIds.detailStatusText, market: market),
        ],
      ],
    );
  }
}

/// Destello suave del color de ganancia o pérdida cuando cambia el precio.
///
/// Dura `priceFlash` (400 ms) y no corre con `FAST_ANIMATIONS` ni con
/// `MediaQuery.disableAnimations`.
class _FlashingPrice extends ConsumerStatefulWidget {
  const _FlashingPrice({
    required this.tick,
    required this.sign,
    required this.child,
  });

  final int tick;
  final int sign;
  final Widget child;

  @override
  ConsumerState<_FlashingPrice> createState() => _FlashingPriceState();
}

class _FlashingPriceState extends ConsumerState<_FlashingPrice> {
  bool _lit = false;
  Timer? _timer;

  @override
  void didUpdateWidget(_FlashingPrice oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Duration flash = ref
        .read(durationsProvider)
        .resolve(context)
        .priceFlash;
    if (widget.tick != oldWidget.tick && flash > Duration.zero) {
      _timer?.cancel();
      setState(() => _lit = true);
      _timer = Timer(flash ~/ 2, () {
        if (mounted) {
          setState(() => _lit = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppDurations durations = ref
        .watch(durationsProvider)
        .resolve(context);
    final MarketColors market = Theme.of(context).market;
    return AnimatedContainer(
      duration: durations.priceFlash ~/ 2,
      curve: AppDurations.curve,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: _lit
            ? market.containerFor(widget.sign) ?? Colors.transparent
            : Colors.transparent,
        borderRadius: AppRadius.smAll,
      ),
      child: widget.child,
    );
  }
}

class _ChartSection extends ConsumerWidget {
  const _ChartSection({required this.state, required this.instrumentId});

  final InstrumentDetailState state;
  final String instrumentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final InstrumentDetailViewModel viewModel = ref.read(
      instrumentDetailViewModelProvider(instrumentId).notifier,
    );
    final Instrument instrument = state.detail!.instrument;
    final PriceSeries? series = state.series;
    final String? chartError = state.chartErrorKey;
    final Country zone =
        ref.watch(sessionProvider).user?.country ?? instrument.country;
    final String locale = context.languageCode;
    final List<PriceChartPoint> points = <PriceChartPoint>[
      for (final PricePoint point in series?.points ?? const <PricePoint>[])
        PriceChartPoint(time: point.time, price: point.price),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (chartError != null)
          AppBanner(
            id: MarketIds.detailChartErrorText,
            message: context.tr(chartError),
            tone: AppBannerTone.error,
          )
        else
          PriceChart(
            id: MarketIds.detailChart,
            points: points,
            currency: instrument.currency,
            loading: state.chartLoading || series == null,
            height: MarketLimits.chartHeight,
            semanticLabel: _chartSummary(context, instrument, series),
            timeLabel: (DateTime time) => state.range == PriceRange.day
                ? Formatters.time(time, country: zone, locale: locale)
                : Formatters.date(time, country: zone, locale: locale),
          ),
        const SizedBox(height: AppSpacing.sm),
        AppSegmentedControl<PriceRange>(
          id: MarketIds.detailRangeMenu,
          selected: state.range,
          onChanged: viewModel.selectRange,
          segments: <AppSegment<PriceRange>>[
            for (final PriceRange range in PriceRange.values)
              AppSegment<PriceRange>(
                id: _rangeSegmentId(range),
                value: range,
                label: context.tr('market.detail.range_${_rangeKey(range)}'),
              ),
          ],
        ),
      ],
    );
  }

  String _chartSummary(
    BuildContext context,
    Instrument instrument,
    PriceSeries? series,
  ) {
    if (series == null || !series.isDrawable) {
      return instrument.name;
    }
    final SemanticLabels labels = SemanticLabelsScope.of(context);
    final Currency currency = series.currency;
    final Decimal pct = series.changePercent;
    final String pctText = Formatters.share(pct.abs(), currency: currency);
    final String change = pct.sign == 0
        ? context.tr('market.detail.chart_flat')
        : context.tr(
            pct.sign > 0
                ? 'market.detail.chart_rises'
                : 'market.detail.chart_falls',
            namedArgs: <String, String>{'pct': pctText},
          );
    return context.tr(
      'market.detail.chart_summary',
      namedArgs: <String, String>{
        'name': instrument.name,
        'range': context.tr(
          'market.detail.range_name_${_rangeKey(series.range)}',
        ),
        'from': Formatters.amount(Money(series.points.first.price, currency)),
        'to':
            '${Formatters.amount(Money(series.points.last.price, currency))} '
            '${labels.currencyName(currency.code)}',
        'change': change,
      },
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.detail});

  final InstrumentDetail detail;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Currency currency = detail.instrument.currency;
    Widget stat(String labelKey, Widget value) => SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(context.tr(labelKey), style: textTheme.bodySmall),
          value,
        ],
      ),
    );
    MoneyText price(String id, Money money) => MoneyText(
      id: id,
      money: money,
      isPrice: true,
      size: MoneyTextSize.compact,
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.tr('market.detail.stats_title'),
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              stat(
                'market.detail.open',
                price(MarketIds.detailOpenText, detail.open),
              ),
              stat(
                'market.detail.high',
                price(MarketIds.detailHighText, detail.high),
              ),
              stat(
                'market.detail.low',
                price(MarketIds.detailLowText, detail.low),
              ),
              stat(
                'market.detail.prev_close',
                price(MarketIds.detailPrevCloseText, detail.prevClose),
              ),
              stat(
                'market.detail.volume',
                Identified(
                  id: MarketIds.detailVolumeText,
                  child: Text(
                    Formatters.quantity(
                      detail.volume,
                      locale: currency.formatLocale,
                    ),
                    style: AppTypography.tabular(
                      textTheme.bodyMedium ?? AppTypography.bodyMedium,
                    ).copyWith(color: textTheme.titleMedium?.color),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PositionCard extends StatelessWidget {
  const _PositionCard({required this.position});

  final Position position;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.tr('market.detail.position_title'),
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Identified(
            id: MarketIds.detailPositionQuantityText,
            child: Text(
              context.tr(
                'market.detail.position_quantity',
                namedArgs: <String, String>{
                  'quantity': Formatters.quantity(
                    position.quantity,
                    locale: position.currency.formatLocale,
                  ),
                },
              ),
              style: textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.tr('market.detail.position_value'),
            style: textTheme.bodySmall,
          ),
          MoneyText(
            id: MarketIds.detailPositionValueText,
            money: position.marketValue,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.tr('market.detail.position_pnl'),
            style: textTheme.bodySmall,
          ),
          PriceChange(
            id: MarketIds.detailPositionPnlText,
            currency: position.currency,
            amount: position.unrealizedPnl,
            percent: position.unrealizedPnlPercent,
          ),
          Text(
            context.tr('market.detail.position_pnl_help'),
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.tr('market.detail.about_title'),
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Identified(
          id: MarketIds.detailDescriptionText,
          child: Text(description, style: textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _TradeButtons extends ConsumerWidget {
  const _TradeButtons({required this.state, required this.instrumentId});

  final InstrumentDetailState state;
  final String instrumentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final InstrumentDetailViewModel viewModel = ref.read(
      instrumentDetailViewModelProvider(instrumentId).notifier,
    );
    final bool canTrade = state.canTrade;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!canTrade) ...<Widget>[
          Identified(
            id: MarketIds.detailClosedReasonText,
            child: Text(
              context.tr('market.detail.closed_reason'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Row(
          children: <Widget>[
            Expanded(
              child: AppButton(
                id: MarketIds.detailBuyButton,
                label: context.tr('market.detail.buy'),
                variant: AppButtonVariant.buy,
                expanded: true,
                onPressed: canTrade ? viewModel.buy : null,
              ),
            ),
            if (state.canSell) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  id: MarketIds.detailSellButton,
                  label: context.tr('market.detail.sell'),
                  variant: AppButtonVariant.sell,
                  expanded: true,
                  onPressed: canTrade ? viewModel.sell : null,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
