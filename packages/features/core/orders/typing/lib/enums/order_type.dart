/// Tipo de orden.
///
/// La fase 1 solo tiene órdenes a mercado; la fase 2 agregará `limit`.
enum OrderType {
  /// A mercado: se ejecuta al último precio.
  market('MARKET');

  const OrderType(this.apiCode);

  /// Busca un tipo por su código de API, o `null` si no existe.
  static OrderType? tryFromApiCode(String code) {
    for (final OrderType type in values) {
      if (type.apiCode == code) {
        return type;
      }
    }
    return null;
  }

  /// Código en la API.
  final String apiCode;
}
