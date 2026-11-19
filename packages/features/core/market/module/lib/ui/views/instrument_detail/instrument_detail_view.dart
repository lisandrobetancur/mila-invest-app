part of 'instrument_detail.dart';

/// Detalle de un instrumento: precio con variación, gráfico por rango,
/// estadísticas del día, tu posición y los botones de comprar y vender.
class InstrumentDetailView extends ConsumerWidget {
  /// Crea el detalle de [instrumentId].
  const InstrumentDetailView({required this.instrumentId, super.key});

  /// Path de la ruta, relativo a la lista.
  static const String route = MarketRoutes.detailSubPath;

  /// Nombre de la ruta.
  static const String name = MarketRoutes.detailName;

  /// Parámetro de path con el id.
  static const String idParam = MarketRoutes.idParam;

  /// Id del instrumento.
  final String instrumentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final InstrumentDetailState state = ref.watch(
      instrumentDetailViewModelProvider(instrumentId),
    );
    final InstrumentDetailViewModel viewModel = ref.read(
      instrumentDetailViewModelProvider(instrumentId).notifier,
    );
    final bool compact = AppLayout.of(context).isCompact;
    final InstrumentDetail? detail = state.detail;
    return AppScaffold(
      id: MarketIds.detailView,
      title: state.status.isData ? detail?.instrument.ticker : null,
      leading: AppIconButton(
        id: MarketIds.detailBackIconButton,
        icon: AppIcons.back,
        tooltip: context.tr('market.common.back'),
        onPressed: viewModel.back,
      ),
      badge: AppBadge(
        id: MarketIds.detailSimulatedText,
        label: context.tr('market.common.simulated'),
        tone: AppBadgeTone.accent,
      ),
      onRefresh: state.status.isData ? viewModel.load : null,
      bottomBar: state.status.isData && compact
          ? _TradeButtons(state: state, instrumentId: instrumentId)
          : null,
      body: switch (state.status) {
        ViewStatus.loading => const _InstrumentDetailShimmer(),
        ViewStatus.data => _InstrumentDetailData(
          state: state,
          instrumentId: instrumentId,
        ),
        ViewStatus.empty => _InstrumentDetailEmpty(onBack: viewModel.goToList),
        ViewStatus.error => _InstrumentDetailError(
          state: state,
          onRetry: viewModel.load,
        ),
      },
    );
  }
}
