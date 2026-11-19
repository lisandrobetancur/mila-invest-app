import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

void main() {
  group('Formatters.money', () {
    test('formatea cada moneda como la tabla de §7.3', () {
      expect(
        Formatters.money(Money.parse('1234567', Currency.cop)),
        r'$ 1.234.567 COP',
      );
      expect(
        Formatters.money(Money.parse('1234567.89', Currency.mxn)),
        r'$1,234,567.89 MXN',
      );
      expect(
        Formatters.money(Money.parse('1234567.89', Currency.pen)),
        'S/ 1,234,567.89',
      );
      expect(
        Formatters.money(Money.parse('1234.56', Currency.usd)),
        r'US$ 1,234.56',
      );
    });

    test('COP no muestra decimales pero no los pierde en el cálculo', () {
      final Money value = Money.parse('1234567.49', Currency.cop);

      expect(Formatters.money(value), r'$ 1.234.567 COP');
      expect(value.apiValue, '1234567.49');
    });

    test('un monto negativo lleva el signo menos antes del símbolo', () {
      expect(
        Formatters.money(Money.parse('-28860', Currency.cop)),
        '−\$ 28.860 COP',
      );
    });

    test('la forma compacta abrevia miles y millones', () {
      expect(
        Formatters.money(Money.parse('1234567', Currency.cop), compact: true),
        r'$ 1,2 M COP',
      );
      expect(
        Formatters.money(Money.parse('23860', Currency.cop), compact: true),
        r'$ 23,9 k COP',
      );
      expect(
        Formatters.money(Money.parse('850', Currency.cop), compact: true),
        r'$ 850 COP',
      );
    });
  });

  group('Formatters.price', () {
    test('COP usa 0 decimales desde 1.000 y 2 por debajo', () {
      expect(
        Formatters.price(Money.parse('2385.00', Currency.cop)),
        r'$ 2.385 COP',
      );
      expect(
        Formatters.price(Money.parse('999.50', Currency.cop)),
        r'$ 999,50 COP',
      );
    });

    test('MXN, PEN y USD usan 2 decimales', () {
      expect(
        Formatters.price(Money.parse('85.4', Currency.mxn)),
        r'$85.40 MXN',
      );
      expect(Formatters.price(Money.parse('192', Currency.pen)), 'S/ 192.00');
      expect(Formatters.price(Money.parse('12', Currency.usd)), r'US$ 12.00');
    });
  });

  group('Formatters.percent', () {
    test('siempre lleva signo y usa el separador del país', () {
      expect(
        Formatters.percent(Decimal.parse('2.35'), currency: Currency.cop),
        '+2,35 %',
      );
      expect(
        Formatters.percent(Decimal.parse('-1.1'), currency: Currency.cop),
        '−1,10 %',
      );
      expect(
        Formatters.percent(Decimal.parse('2.35'), currency: Currency.usd),
        '+2.35 %',
      );
    });

    test('el cero no lleva signo ni flecha', () {
      expect(
        Formatters.percent(Decimal.zero, currency: Currency.cop),
        '0,00 %',
      );
      expect(Formatters.arrow(Decimal.zero), '');
      expect(
        Formatters.percentWithArrow(Decimal.zero, currency: Currency.cop),
        '0,00 %',
      );
    });

    test('con flecha agrega ▲ o ▼', () {
      expect(
        Formatters.percentWithArrow(
          Decimal.parse('2.35'),
          currency: Currency.cop,
        ),
        '▲ +2,35 %',
      );
      expect(
        Formatters.percentWithArrow(
          Decimal.parse('-1.1'),
          currency: Currency.cop,
        ),
        '▼ −1,10 %',
      );
    });
  });

  group('Formatters de cantidades, fechas y documentos', () {
    test('las cantidades son enteras y con separador de miles', () {
      expect(Formatters.quantity(1200, locale: 'es_CO'), '1.200');
      expect(Formatters.quantity(1200, locale: 'en_US'), '1,200');
    });

    test('la fecha se muestra en la zona del país y el idioma de la UI', () {
      final DateTime utc = DateTime.utc(2026, 11, 18, 14, 42);

      expect(
        Formatters.dateTime(utc, country: Country.co, locale: 'es'),
        '18 nov 2026, 9:42 a.\u202fm.',
      );
      expect(
        Formatters.dateTime(utc, country: Country.co, locale: 'en'),
        'Nov 18, 2026, 9:42 AM',
      );
      expect(
        Formatters.dateTime(utc, country: Country.mx, locale: 'es'),
        '18 nov 2026, 8:42 a.\u202fm.',
      );
      expect(
        Formatters.time(utc, country: Country.pe, locale: 'es'),
        '9:42 a.\u202fm.',
      );
    });

    test('el documento se enmascara salvo los últimos 4', () {
      expect(Formatters.maskDocument('1012345678'), '•' * 6 + '5678');
      expect(Formatters.maskDocument('123'), '•••');
    });
  });
}
