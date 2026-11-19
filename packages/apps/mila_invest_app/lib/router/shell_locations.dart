import 'package:dashboard_typing/dashboard_typing.dart';
import 'package:market_typing/market_typing.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:transactions_typing/transactions_typing.dart';

/// Ubicaciones propias del shell.
abstract final class ShellLocations {
  /// Inicio de la app con sesión (tab Inicio).
  static const String home = DashboardRoutes.homePath;

  /// Entrada de la tab Mercado.
  static const String market = MarketRoutes.listPath;

  /// Entrada de la tab Portafolio.
  static const String portfolio = PortfolioRoutes.overviewPath;

  /// Entrada de la tab Actividad.
  static const String activity = TransactionsRoutes.movementsPath;
}
