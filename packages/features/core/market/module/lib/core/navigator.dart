import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_typing/market_typing.dart';
import 'package:navigator/navigator.dart';
import 'package:orders_typing/orders_typing.dart';

/// Navigator de market.
class MarketNavigator extends FeatureNavigator {
  /// Vuelve desde el detalle: atrás, o a la lista si se abrió en frío.
  void back() {
    if (navigation.canPop()) {
      navigation.pop<void>();
    } else {
      navigation.go(MarketRoutes.listPath);
    }
  }

  /// Va a la lista de instrumentos.
  void goToList() => navigation.go(MarketRoutes.listPath);

  /// Abre el detalle del instrumento [instrumentId].
  void goToInstrument(String instrumentId) =>
      navigation.push<void>(MarketRoutes.detailLocation(instrumentId));

  /// Abre el ticket de orden de [instrumentId] para [side].
  void openOrderTicket(String instrumentId, OrderSide side) => navigation
      .push<void>(OrdersRoutes.ticketLocation(instrumentId, side.routeValue));

  /// Refleja [filter] en la URL, para que la lista se pueda compartir.
  void replaceListQuery(InstrumentFilter filter) {
    final String query = filter.query.trim();
    final Map<String, String> parameters = <String, String>{
      if (filter.country != null)
        MarketRoutes.countryQuery: filter.country!.code,
      if (filter.type != null) MarketRoutes.typeQuery: filter.type!.apiCode,
      if (query.isNotEmpty) MarketRoutes.searchQuery: query,
    };
    navigation.go(
      parameters.isEmpty
          ? MarketRoutes.listPath
          : Uri(
              path: MarketRoutes.listPath,
              queryParameters: parameters,
            ).toString(),
    );
  }
}

/// Provider del navigator de market.
final NotifierProvider<MarketNavigator, void> marketNavigatorProvider =
    NotifierProvider<MarketNavigator, void>(MarketNavigator.new);
