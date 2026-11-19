import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/navigator.dart';
import 'package:orders_typing/orders_typing.dart';
import 'package:transactions_typing/transactions_typing.dart';
import 'package:typing/typing.dart';
import 'package:wallet_typing/wallet_typing.dart';

/// Navigator de transactions.
class TransactionsNavigator extends FeatureNavigator {
  /// Va al historial de órdenes (sección hermana de Actividad).
  void goToOrders() => navigation.go(OrdersRoutes.historyPath);

  /// Abre el depósito en [currency] (desde el estado vacío).
  void openDeposit(Currency currency) =>
      navigation.push<void>(WalletRoutes.depositLocation(currency.code));

  /// Abre la orden [orderId] que originó un movimiento.
  void openOrder(String orderId) =>
      navigation.push<void>(OrdersRoutes.detailLocation(orderId));

  /// Refleja los filtros en la URL.
  void replaceQuery(TransactionFilter filter) {
    final Map<String, String> parameters = <String, String>{
      if (filter.type != null)
        TransactionsRoutes.typeQuery: filter.type!.apiCode,
      if (filter.range != TransactionRange.all)
        TransactionsRoutes.rangeQuery: filter.range.code,
    };
    navigation.go(
      parameters.isEmpty
          ? TransactionsRoutes.movementsPath
          : Uri(
              path: TransactionsRoutes.movementsPath,
              queryParameters: parameters,
            ).toString(),
    );
  }
}

/// Provider del navigator de transactions.
final NotifierProvider<TransactionsNavigator, void>
transactionsNavigatorProvider = NotifierProvider<TransactionsNavigator, void>(
  TransactionsNavigator.new,
);
