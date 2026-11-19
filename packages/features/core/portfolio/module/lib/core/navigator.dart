import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_typing/market_typing.dart';
import 'package:navigator/navigator.dart';

/// Navigator de portfolio.
class PortfolioNavigator extends FeatureNavigator {
  /// Va al mercado (desde el estado vacío).
  void goToMarket() => navigation.go(MarketRoutes.listPath);

  /// Abre el detalle del instrumento de una posición.
  void openInstrument(String instrumentId) =>
      navigation.go(MarketRoutes.detailLocation(instrumentId));
}

/// Provider del navigator de portfolio.
final NotifierProvider<PortfolioNavigator, void> portfolioNavigatorProvider =
    NotifierProvider<PortfolioNavigator, void>(PortfolioNavigator.new);
