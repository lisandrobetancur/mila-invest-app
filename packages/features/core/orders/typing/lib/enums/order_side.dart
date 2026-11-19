/// Lado de una orden.
enum OrderSide {
  /// Compra.
  buy(apiCode: 'BUY', routeValue: 'buy'),

  /// Venta.
  sell(apiCode: 'SELL', routeValue: 'sell');

  const OrderSide({required this.apiCode, required this.routeValue});

  /// Busca un lado por su código de API, o `null` si no existe.
  static OrderSide? tryFromApiCode(String code) {
    for (final OrderSide side in values) {
      if (side.apiCode == code) {
        return side;
      }
    }
    return null;
  }

  /// Resuelve el valor del parámetro de ruta; uno desconocido es [buy].
  static OrderSide fromRouteValue(String? value) =>
      value == OrderSide.sell.routeValue ? OrderSide.sell : OrderSide.buy;

  /// Código en la API (`BUY` / `SELL`).
  final String apiCode;

  /// Valor en el path de la ruta del ticket (`buy` / `sell`).
  final String routeValue;

  /// `true` si es una compra.
  bool get isBuy => this == OrderSide.buy;
}
