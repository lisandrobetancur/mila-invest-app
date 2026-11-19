import 'package:app_cross_typing/app_cross_typing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_typing/market_typing.dart';
import 'package:navigator/navigator.dart';
import 'package:transactions_typing/transactions_typing.dart';
import 'package:typing/typing.dart';
import 'package:wallet_typing/wallet_typing.dart';

/// Navigator de dashboard.
class DashboardNavigator extends FeatureNavigator {
  /// Va a los movimientos ("Ver todo").
  void goToActivity() => navigation.go(TransactionsRoutes.movementsPath);

  /// Abre el depósito en [currency].
  void openDeposit(Currency currency) =>
      navigation.push<void>(WalletRoutes.depositLocation(currency.code));

  /// Abre el detalle del instrumento [instrumentId].
  void openInstrument(String instrumentId) =>
      navigation.go(MarketRoutes.detailLocation(instrumentId));

  /// Abre ajustes.
  void openSettings() => navigation.push<void>(AppCrossRoutes.settingsPath);

  /// Abre la billetera.
  void openWallet() => navigation.push<void>(WalletRoutes.accountsPath);
}

/// Provider del navigator de dashboard.
final NotifierProvider<DashboardNavigator, void> dashboardNavigatorProvider =
    NotifierProvider<DashboardNavigator, void>(DashboardNavigator.new);
