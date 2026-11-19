/// Tipo de instrumento negociable en la fase 1.
enum InstrumentType {
  /// Acción.
  stock('STOCK'),

  /// Fondo cotizado.
  etf('ETF');

  const InstrumentType(this.apiCode);

  /// Busca un tipo por su código de API, o `null` si no existe.
  static InstrumentType? tryFromApiCode(String code) {
    for (final InstrumentType type in values) {
      if (type.apiCode == code) {
        return type;
      }
    }
    return null;
  }

  /// Código en la API (`STOCK` / `ETF`).
  final String apiCode;
}
