/// Rutas de transactions.
abstract final class TransactionsRoutes {
  /// Path de los movimientos (tab Actividad).
  static const String movementsPath = '/activity';

  /// Nombre de la ruta de movimientos.
  static const String movementsName = 'transactions.movements';

  /// Parámetro de query del filtro por tipo.
  static const String typeQuery = 'type';

  /// Parámetro de query del rango de fechas (`7d`, `30d`, `90d`).
  static const String rangeQuery = 'range';
}
