/// Rango del gráfico de precios.
enum PriceRange {
  /// Un día.
  day('1D'),

  /// Una semana.
  week('1W'),

  /// Un mes.
  month('1M'),

  /// Tres meses.
  threeMonths('3M'),

  /// Un año.
  year('1Y');

  const PriceRange(this.apiCode);

  /// Busca un rango por su código de API, o `null` si no existe.
  static PriceRange? tryFromApiCode(String code) {
    for (final PriceRange range in values) {
      if (range.apiCode == code) {
        return range;
      }
    }
    return null;
  }

  /// Código en la API (`1D`, `1W`, `1M`, `3M`, `1Y`).
  final String apiCode;
}
