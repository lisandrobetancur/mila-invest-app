import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:typing/typing.dart';

/// Formato de dinero, porcentajes, cantidades y fechas.
///
/// El formato depende del **país de la moneda o de la cuenta**, nunca del
/// idioma de la UI: un monto en pesos colombianos se escribe `$ 1.234.567
/// COP` aunque la app esté en inglés. Solo las fechas usan el idioma de la
/// UI para los nombres de mes y el meridiano.
abstract final class Formatters {
  /// Flecha hacia arriba de una variación positiva.
  static const String upArrow = '▲';

  /// Flecha hacia abajo de una variación negativa.
  static const String downArrow = '▼';

  /// Signo menos tipográfico (U+2212), más legible que el guión.
  static const String minusSign = '−';

  static const String _maskChar = '•';

  static final Decimal _thousand = Decimal.fromInt(1000);
  static final Decimal _million = Decimal.fromInt(1000000);

  static bool _dateSymbolsReady = false;

  /// Número de un monto, sin símbolo ni código (`1.234.567`).
  ///
  /// Es la base de las etiquetas habladas: "1.234.567 pesos colombianos".
  static String amount(Money value) => _number(
    value.amount,
    value.currency.displayDecimals,
    value.currency.formatLocale,
  );

  /// Flecha de la variación [value]; cadena vacía si es cero.
  static String arrow(Decimal value) {
    if (value > Decimal.zero) {
      return upArrow;
    }
    return value < Decimal.zero ? downArrow : '';
  }

  /// Fecha corta en la zona horaria de [country] (`18 nov 2026`).
  static String date(
    DateTime instant, {
    required Country country,
    required String locale,
  }) => _formatDate(
    instant,
    country: country,
    locale: locale,
    esPattern: 'd MMM y',
    enPattern: 'MMM d, y',
  );

  /// Fecha y hora en la zona horaria de [country].
  ///
  /// `18 nov 2026, 9:42 a. m.` en español, `Nov 18, 2026, 9:42 AM` en inglés.
  static String dateTime(
    DateTime instant, {
    required Country country,
    required String locale,
  }) => _formatDate(
    instant,
    country: country,
    locale: locale,
    esPattern: 'd MMM y, h:mm a',
    enPattern: 'MMM d, y, h:mm a',
  );

  /// Enmascara un número de documento dejando visibles los últimos 4.
  static String maskDocument(String number) {
    final String value = number.trim();
    if (value.length <= 4) {
      return _maskChar * value.length;
    }
    return _maskChar * (value.length - 4) + value.substring(value.length - 4);
  }

  /// Formatea un monto con el símbolo, los decimales y el código de su
  /// moneda (§7.3).
  ///
  /// Con [compact] usa la forma abreviada de las vistas densas
  /// (`$ 1,2 M COP`).
  static String money(Money value, {bool compact = false}) => _compose(
    value,
    decimals: value.currency.displayDecimals,
    compact: compact,
  );

  /// Variación porcentual con signo (`+2,35 %`, `${minusSign}1,10 %`).
  ///
  /// El cero se muestra `0,00 %`, sin signo.
  static String percent(
    Decimal value, {
    required Currency currency,
    int decimals = 2,
  }) {
    final String number = _number(value, decimals, currency.formatLocale);
    return '${_sign(value)}$number %';
  }

  /// Variación porcentual con flecha y signo (`▲ +2,35 %`).
  static String percentWithArrow(
    Decimal value, {
    required Currency currency,
    int decimals = 2,
  }) {
    final String text = percent(value, currency: currency, decimals: decimals);
    final String symbol = arrow(value);
    return symbol.isEmpty ? text : '$symbol $text';
  }

  /// Formatea el precio de un instrumento.
  ///
  /// COP usa 0 decimales desde 1.000 y 2 por debajo; el resto, 2.
  static String price(Money value) =>
      _compose(value, decimals: _priceDecimals(value));

  /// Cantidad de acciones: entera y con separador de miles.
  static String quantity(int value, {required String locale}) =>
      NumberFormat.decimalPattern(locale).format(value);

  /// Participación porcentual, sin signo (`62,4 %`).
  static String share(
    Decimal value, {
    required Currency currency,
    int decimals = 1,
  }) => '${_number(value, decimals, currency.formatLocale)} %';

  /// Monto con signo explícito (`+$ 35 COP`), para variaciones absolutas.
  ///
  /// El cero no lleva signo.
  static String signedMoney(Money value) {
    final String text = money(value.abs());
    return '${_sign(value.amount)}$text';
  }

  /// Hora en la zona horaria de [country] (`9:42 a. m.`).
  static String time(
    DateTime instant, {
    required Country country,
    required String locale,
  }) => _formatDate(
    instant,
    country: country,
    locale: locale,
    esPattern: 'h:mm a',
    enPattern: 'h:mm a',
  );

  /// Día de la semana y hora (`lun 9:30 a. m.`), para el estado de mercado.
  static String weekdayTime(
    DateTime instant, {
    required Country country,
    required String locale,
  }) => _formatDate(
    instant,
    country: country,
    locale: locale,
    esPattern: 'EEE h:mm a',
    enPattern: 'EEE h:mm a',
  );

  static String _compactNumber(Decimal value, String locale) {
    final Decimal abs = value.abs();
    if (abs >= _million) {
      final Decimal scaled = (abs / _million)
          .toDecimal(scaleOnInfinitePrecision: 4)
          .round(scale: 1);
      return '${_number(scaled, 1, locale)} M';
    }
    if (abs >= _thousand) {
      final Decimal scaled = (abs / _thousand)
          .toDecimal(scaleOnInfinitePrecision: 4)
          .round(scale: 1);
      return '${_number(scaled, 1, locale)} k';
    }
    return _number(abs, 0, locale);
  }

  static String _compose(
    Money value, {
    required int decimals,
    bool compact = false,
  }) {
    final Currency currency = value.currency;
    final String number = compact
        ? _compactNumber(value.amount, currency.formatLocale)
        : _number(value.amount, decimals, currency.formatLocale);
    final String separator = _symbolSpacing(currency);
    final String suffix = currency.showsCode ? ' ${currency.code}' : '';
    final String sign = value.isNegative ? minusSign : '';
    return '$sign${currency.symbol}$separator$number$suffix';
  }

  static void _ensureDateSymbols() {
    if (_dateSymbolsReady) {
      return;
    }
    initializeDateFormatting();
    _dateSymbolsReady = true;
  }

  static String _formatDate(
    DateTime instant, {
    required Country country,
    required String locale,
    required String esPattern,
    required String enPattern,
  }) {
    _ensureDateSymbols();
    final DateTime local = instant.toUtc().add(country.utcOffset);
    final String pattern = locale.startsWith('es') ? esPattern : enPattern;
    return DateFormat(pattern, locale).format(local);
  }

  static String _number(Decimal value, int decimals, String locale) =>
      DecimalFormatter(
        NumberFormat.decimalPatternDigits(
          locale: locale,
          decimalDigits: decimals,
        ),
      ).format(value.abs());

  static int _priceDecimals(Money value) => switch (value.currency) {
    Currency.cop => value.amount.abs() >= _thousand ? 0 : 2,
    Currency.mxn || Currency.pen || Currency.usd => 2,
  };

  static String _sign(Decimal value) {
    if (value > Decimal.zero) {
      return '+';
    }
    return value < Decimal.zero ? minusSign : '';
  }

  static String _symbolSpacing(Currency currency) =>
      currency == Currency.mxn ? '' : ' ';
}
