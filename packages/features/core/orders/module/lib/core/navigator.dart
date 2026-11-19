import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_typing/market_typing.dart';
import 'package:navigator/navigator.dart';
import 'package:orders_typing/orders_typing.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:transactions_typing/transactions_typing.dart';
import 'package:typing/typing.dart';
import 'package:wallet_typing/wallet_typing.dart';

/// Navigator de orders.
class OrdersNavigator extends FeatureNavigator {
  /// Vuelve desde el detalle de una orden.
  void backFromDetail() {
    if (navigation.canPop()) {
      navigation.pop<void>();
    } else {
      navigation.go(OrdersRoutes.historyPath);
    }
  }

  /// Cierra el ticket: atrás, o al detalle del instrumento si se abrió en
  /// frío desde un deep link.
  void closeTicket(String instrumentId) {
    if (navigation.canPop()) {
      navigation.pop<void>();
    } else {
      navigation.go(MarketRoutes.detailLocation(instrumentId));
    }
  }

  /// Va al historial de órdenes.
  void goToHistory() => navigation.go(OrdersRoutes.historyPath);

  /// Va a la lista de instrumentos.
  void goToMarket() => navigation.go(MarketRoutes.listPath);

  /// Va a los movimientos (sección hermana de la tab Actividad).
  void goToMovements() => navigation.go(TransactionsRoutes.movementsPath);

  /// Cierra el ticket y va al portafolio.
  void goToPortfolio() => navigation.go(PortfolioRoutes.overviewPath);

  /// Abre el detalle de la orden [orderId].
  void openOrder(String orderId) =>
      navigation.push<void>(OrdersRoutes.detailLocation(orderId));

  /// Abre el depósito en [currency], encima del ticket.
  void openDeposit(Currency currency) =>
      navigation.push<void>(WalletRoutes.depositLocation(currency.code));

  /// Abre el detalle del instrumento [instrumentId].
  void openInstrument(String instrumentId) =>
      navigation.push<void>(MarketRoutes.detailLocation(instrumentId));

  /// Refleja el filtro de estado del historial en la URL.
  void replaceHistoryQuery(OrderStatus? status) => navigation.go(
    status == null
        ? OrdersRoutes.historyPath
        : Uri(
            path: OrdersRoutes.historyPath,
            queryParameters: <String, String>{
              OrdersRoutes.statusQuery: status.apiCode,
            },
          ).toString(),
  );
}

/// Provider del navigator de orders.
final NotifierProvider<OrdersNavigator, void> ordersNavigatorProvider =
    NotifierProvider<OrdersNavigator, void>(OrdersNavigator.new);
