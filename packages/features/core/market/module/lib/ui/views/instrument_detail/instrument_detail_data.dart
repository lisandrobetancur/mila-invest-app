part of 'instrument_detail.dart';

class _InstrumentDetailData extends StatelessWidget {
  const _InstrumentDetailData({
    required this.state,
    required this.instrumentId,
  });

  final InstrumentDetailState state;
  final String instrumentId;

  @override
  Widget build(BuildContext context) {
    final InstrumentDetail detail = state.detail!;
    final Position? position = state.position;
    final bool compact = AppLayout.of(context).isCompact;
    final List<Widget> main = <Widget>[
      _PriceHeader(state: state),
      const SizedBox(height: AppSpacing.lg),
      _ChartSection(state: state, instrumentId: instrumentId),
      const SizedBox(height: AppSpacing.lg),
      _StatsCard(detail: detail),
      const SizedBox(height: AppSpacing.lg),
      _AboutSection(description: detail.description),
    ];
    final List<Widget> side = <Widget>[
      if (position != null) ...<Widget>[
        _PositionCard(position: position),
        const SizedBox(height: AppSpacing.md),
      ],
      if (!compact)
        AppCard(
          child: _TradeButtons(state: state, instrumentId: instrumentId),
        ),
    ];
    return Identified(
      id: MarketIds.detailStateData,
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ...main.take(3),
                const SizedBox(height: AppSpacing.lg),
                ...side,
                ...main.skip(3),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: main,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: side,
                  ),
                ),
              ],
            ),
    );
  }
}
