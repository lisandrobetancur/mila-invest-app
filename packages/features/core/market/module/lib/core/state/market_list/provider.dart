part of 'market_list.dart';

/// Provider del controller de la lista.
final AutoDisposeNotifierProvider<MarketListViewModel, MarketListState>
marketListViewModelProvider =
    NotifierProvider.autoDispose<MarketListViewModel, MarketListState>(
      MarketListViewModel.new,
    );
