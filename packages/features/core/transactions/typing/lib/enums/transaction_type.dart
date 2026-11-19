/// Tipo de movimiento de dinero.
enum TransactionType {
  /// Depósito virtual.
  deposit('DEPOSIT'),

  /// Compra (por el monto bruto).
  buy('BUY'),

  /// Venta (por el monto bruto).
  sell('SELL'),

  /// Comisión de una orden.
  fee('FEE'),

  /// Un tipo que esta versión de la app todavía no conoce.
  other('OTHER');

  const TransactionType(this.apiCode);

  /// Resuelve un código de API; uno desconocido es [other].
  static TransactionType fromApiCode(String code) {
    for (final TransactionType type in values) {
      if (type.apiCode == code) {
        return type;
      }
    }
    return TransactionType.other;
  }

  /// Tipos por los que se puede filtrar.
  static const List<TransactionType> filterable = <TransactionType>[
    deposit,
    buy,
    sell,
    fee,
  ];

  /// Código en la API.
  final String apiCode;
}
