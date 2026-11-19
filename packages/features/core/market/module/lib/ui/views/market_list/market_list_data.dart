part of 'market_list.dart';

class _MarketListData extends ConsumerWidget {
  const _MarketListData({required this.state});

  final MarketListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketListViewModel viewModel = ref.read(
      marketListViewModelProvider.notifier,
    );
    final List<Instrument> items = state.instruments.items;
    final double padding = AppLayout.of(context).pagePadding - AppSpacing.sm;
    final String? loadMoreError = state.loadMoreErrorKey;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      sliver: SliverList.list(
        children: <Widget>[
          Identified(
            id: MarketIds.listStateData,
            child: Column(
              children: <Widget>[
                for (final Instrument instrument in items)
                  InstrumentTile(
                    id: MarketIds.listInstrumentItem(instrument.id),
                    ticker: instrument.ticker,
                    name: instrument.name,
                    country: instrument.country,
                    countryName: context.tr(
                      'market.country.${instrument.country.code.toLowerCase()}',
                    ),
                    price: instrument.lastPrice,
                    changePercent: instrument.changePercent,
                    onTap: () => viewModel.openInstrument(instrument),
                  ),
              ],
            ),
          ),
          if (state.loadingMore)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Identified(
                id: MarketIds.listLoadingMoreText,
                label: context.tr('market.list.loading_more'),
                child: const Center(
                  child: SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          if (loadMoreError != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: AppBanner(
                id: MarketIds.listLoadMoreErrorText,
                message: context.tr(loadMoreError),
                tone: AppBannerTone.error,
                action: AppButton(
                  id: MarketIds.listLoadMoreRetryButton,
                  label: context.tr('market.common.retry'),
                  variant: AppButtonVariant.text,
                  onPressed: viewModel.retryLoadMore,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
