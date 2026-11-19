part of 'market_list.dart';

String _countryChipId(Country? country) => switch (country) {
  null => MarketIds.listCountryAllChip,
  Country.co => MarketIds.listCountryCoChip,
  Country.mx => MarketIds.listCountryMxChip,
  Country.pe => MarketIds.listCountryPeChip,
};

String _statusId(Country country) => switch (country) {
  Country.co => MarketIds.listStatusCoText,
  Country.mx => MarketIds.listStatusMxText,
  Country.pe => MarketIds.listStatusPeText,
};

class _MarketListHeader extends ConsumerWidget {
  const _MarketListHeader({
    required this.state,
    required this.search,
    required this.onClearSearch,
  });

  final MarketListState state;
  final TextEditingController search;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketListViewModel viewModel = ref.read(
      marketListViewModelProvider.notifier,
    );
    final double padding = AppLayout.of(context).pagePadding;
    final InstrumentFilter filter = state.filter;
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, AppSpacing.sm, padding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppTextField(
            id: MarketIds.listSearchField,
            label: context.tr('market.list.search'),
            controller: search,
            textInputAction: TextInputAction.search,
            prefix: const Icon(AppIcons.search),
            suffix: filter.query.isEmpty
                ? null
                : AppIconButton(
                    id: MarketIds.listSearchClearIconButton,
                    icon: AppIcons.clear,
                    tooltip: context.tr('market.list.clear_search'),
                    onPressed: onClearSearch,
                  ),
            onChanged: viewModel.setQuery,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              for (final Country? country in <Country?>[
                null,
                ...Country.values,
              ])
                AppChip(
                  id: _countryChipId(country),
                  label: country == null
                      ? context.tr('market.list.country_all')
                      : country.code,
                  selected: filter.country == country,
                  onSelected: (_) => viewModel.setCountry(country),
                ),
              AppChip(
                id: MarketIds.listTypeStockChip,
                label: context.tr('market.list.type_stock'),
                selected: filter.type == InstrumentType.stock,
                onSelected: (_) => viewModel.toggleType(InstrumentType.stock),
              ),
              AppChip(
                id: MarketIds.listTypeEtfChip,
                label: context.tr('market.list.type_etf'),
                selected: filter.type == InstrumentType.etf,
                onSelected: (_) => viewModel.toggleType(InstrumentType.etf),
              ),
            ],
          ),
          if (state.visibleMarkets.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                for (final CountryMarket market in state.visibleMarkets)
                  MarketStatusText(
                    id: _statusId(market.country),
                    market: market,
                    showCountry: true,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
