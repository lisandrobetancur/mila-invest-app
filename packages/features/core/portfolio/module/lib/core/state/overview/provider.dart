part of 'overview.dart';

/// Provider del controller del portafolio.
final AutoDisposeNotifierProvider<
  PortfolioOverviewViewModel,
  PortfolioOverviewState
>
portfolioOverviewViewModelProvider =
    NotifierProvider.autoDispose<
      PortfolioOverviewViewModel,
      PortfolioOverviewState
    >(PortfolioOverviewViewModel.new);
