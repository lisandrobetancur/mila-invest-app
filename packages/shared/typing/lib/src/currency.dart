/// Moneda de cuenta soportada por la app.
enum Currency {
  /// Peso colombiano.
  cop(
    code: 'COP',
    symbol: r'$',
    displayDecimals: 0,
    formatLocale: 'es_CO',
    showsCode: true,
  ),

  /// Peso mexicano.
  mxn(
    code: 'MXN',
    symbol: r'$',
    displayDecimals: 2,
    formatLocale: 'es_MX',
    showsCode: true,
  ),

  /// Sol peruano.
  pen(
    code: 'PEN',
    symbol: 'S/',
    displayDecimals: 2,
    formatLocale: 'es_PE',
    showsCode: false,
  ),

  /// Dólar estadounidense. Cuenta de la fase 2 (cambio de divisas).
  usd(
    code: 'USD',
    symbol: r'US$',
    displayDecimals: 2,
    formatLocale: 'en_US',
    showsCode: false,
  );

  const Currency({
    required this.code,
    required this.symbol,
    required this.displayDecimals,
    required this.formatLocale,
    required this.showsCode,
  });

  /// Busca una moneda por su código ISO 4217, o `null` si no existe.
  static Currency? tryFromCode(String code) {
    final String upper = code.toUpperCase();
    for (final Currency currency in values) {
      if (currency.code == upper) {
        return currency;
      }
    }
    return null;
  }

  /// Código ISO 4217.
  final String code;

  /// Símbolo que se muestra antes del monto.
  final String symbol;

  /// Decimales con los que se muestra un monto (los cálculos no redondean).
  final int displayDecimals;

  /// Locale de `intl` con el que se formatean los montos de esta moneda.
  ///
  /// Es independiente del idioma de la UI: un monto en pesos colombianos se
  /// formatea con `es_CO` aunque la app esté en inglés.
  final String formatLocale;

  /// `true` si el monto se muestra con el código de moneda al final.
  ///
  /// `$` lo usan varias monedas, así que COP y MXN lo necesitan; `S/` y
  /// `US$` no son ambiguos.
  final bool showsCode;
}
