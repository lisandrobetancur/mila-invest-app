/// Estado de la sesión de un mercado.
enum MarketSessionStatus {
  /// Abierto: se puede operar.
  open('OPEN'),

  /// Cerrado: comprar y vender quedan deshabilitados.
  closed('CLOSED');

  const MarketSessionStatus(this.apiCode);

  /// Busca un estado por su código de API, o `null` si no existe.
  static MarketSessionStatus? tryFromApiCode(String code) {
    for (final MarketSessionStatus status in values) {
      if (status.apiCode == code) {
        return status;
      }
    }
    return null;
  }

  /// Código en la API.
  final String apiCode;
}
