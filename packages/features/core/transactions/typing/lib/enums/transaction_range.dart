/// Rango de fechas del filtro de movimientos.
enum TransactionRange {
  /// Sin límite.
  all(code: 'all', days: null),

  /// Últimos 7 días.
  week(code: '7d', days: 7),

  /// Últimos 30 días.
  month(code: '30d', days: 30),

  /// Últimos 90 días.
  quarter(code: '90d', days: 90);

  const TransactionRange({required this.code, required this.days});

  /// Resuelve el valor de la URL; uno desconocido es [all].
  static TransactionRange fromCode(String? code) {
    for (final TransactionRange range in values) {
      if (range.code == code) {
        return range;
      }
    }
    return TransactionRange.all;
  }

  /// Valor en la URL.
  final String code;

  /// Días hacia atrás; `null` es sin límite.
  final int? days;

  /// Inicio del rango contado desde [now], o `null` si no tiene límite.
  DateTime? fromOf(DateTime now) {
    final int? span = days;
    return span == null ? null : now.subtract(Duration(days: span));
  }
}
