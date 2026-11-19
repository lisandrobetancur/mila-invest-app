import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typing/typing.dart';

void main() {
  group('Money', () {
    test('no pierde precisión como lo haría un double', () {
      final Money a = Money.parse('0.1', Currency.usd);
      final Money b = Money.parse('0.2', Currency.usd);

      expect(a + b, Money.parse('0.3', Currency.usd));
      expect((a + b).apiValue, '0.3');
    });

    test('suma y resta montos de la misma moneda', () {
      final Money saldo = Money.parse('1000.00', Currency.cop);
      final Money costo = Money.parse('250.50', Currency.cop);

      expect((saldo - costo).apiValue, '749.5');
      expect((saldo + costo).apiValue, '1250.5');
    });

    test('multiplica por una cantidad exacta', () {
      final Money precio = Money.parse('2385.00', Currency.cop);

      expect(
        precio * Decimal.fromInt(10),
        Money.parse('23850.00', Currency.cop),
      );
    });

    test('rechaza operar monedas distintas', () {
      final Money cop = Money.parse('100', Currency.cop);
      final Money mxn = Money.parse('100', Currency.mxn);

      expect(() => cop + mxn, throwsArgumentError);
      expect(() => cop - mxn, throwsArgumentError);
      expect(() => cop < mxn, throwsArgumentError);
      expect(() => cop.compareTo(mxn), throwsArgumentError);
    });

    test('compara montos de la misma moneda', () {
      final Money menor = Money.parse('10', Currency.pen);
      final Money mayor = Money.parse('10.01', Currency.pen);

      expect(menor < mayor, isTrue);
      expect(mayor > menor, isTrue);
      expect(menor <= Money.parse('10.00', Currency.pen), isTrue);
      expect(menor >= Money.parse('10.000', Currency.pen), isTrue);
    });

    test('expone signo y cero', () {
      expect(Money.zero(Currency.cop).isZero, isTrue);
      expect(Money.parse('-1', Currency.cop).isNegative, isTrue);
      expect(Money.parse('-1', Currency.cop).abs().isPositive, isTrue);
      expect((-Money.parse('5', Currency.cop)).apiValue, '-5');
    });

    test('la igualdad ignora los ceros a la derecha', () {
      expect(
        Money.parse('1.50', Currency.mxn),
        Money.parse('1.5', Currency.mxn),
      );
      expect(
        Money.parse('1.50', Currency.mxn),
        isNot(Money.parse('1.50', Currency.cop)),
      );
    });
  });

  group('Currency', () {
    test('resuelve por código y describe su formato', () {
      expect(Currency.tryFromCode('cop'), Currency.cop);
      expect(Currency.tryFromCode('EUR'), isNull);
      expect(Currency.cop.displayDecimals, 0);
      expect(Currency.cop.showsCode, isTrue);
      expect(Currency.pen.showsCode, isFalse);
    });
  });

  group('Country', () {
    test('resuelve por código', () {
      expect(Country.tryFromCode('mx'), Country.mx);
      expect(Country.tryFromCode('AR'), isNull);
    });

    test('cada país tiene moneda, zona y documentos', () {
      expect(Country.co.currency, Currency.cop);
      expect(Country.co.utcOffset, const Duration(hours: -5));
      expect(Country.co.documentTypes, <DocumentType>[
        DocumentType.cc,
        DocumentType.ce,
      ]);
      expect(Country.mx.documentTypes, <DocumentType>[DocumentType.curp]);
      expect(Country.pe.documentTypes, <DocumentType>[
        DocumentType.dni,
        DocumentType.ce,
      ]);
      expect(Country.mx.utcOffset, const Duration(hours: -6));
    });
  });
}
