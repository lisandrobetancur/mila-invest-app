/// Tipo de producto en la distribución del portafolio.
///
/// La fase 2 agregará CDTs y fondos sin tocar a quien lo muestra.
enum AllocationType {
  /// Acciones.
  stock('STOCK'),

  /// ETFs.
  etf('ETF'),

  /// Efectivo.
  cash('CASH'),

  /// Un tipo que esta versión de la app todavía no conoce.
  other('OTHER');

  const AllocationType(this.apiCode);

  /// Resuelve un código de API; uno desconocido es [other].
  static AllocationType fromApiCode(String code) {
    for (final AllocationType type in values) {
      if (type.apiCode == code) {
        return type;
      }
    }
    return AllocationType.other;
  }

  /// Código en la API.
  final String apiCode;
}
