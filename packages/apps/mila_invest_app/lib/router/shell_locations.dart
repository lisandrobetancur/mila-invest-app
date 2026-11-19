import 'package:market_typing/market_typing.dart';
import 'package:orders_typing/orders_typing.dart';

/// Ubicaciones propias del shell.
abstract final class ShellLocations {
  /// Inicio de la app con sesión.
  static const String home = MarketRoutes.listPath;

  /// Entrada de la tab Actividad.
  static const String activity = OrdersRoutes.historyPath;
}
