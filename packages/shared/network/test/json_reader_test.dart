import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';

void main() {
  group('JsonReader', () {
    const JsonReader reader = JsonReader(<String, Object?>{
      'id': 'ECOPETROL-CO',
      'quantity': 120,
      'open': true,
      'last_price': '2385.00',
      'as_number': 2385.0,
      'currency': 'COP',
      'updated_at': '2026-11-18T14:42:00Z',
      'reject_code': null,
      'tags': <Object?>['a', 'b'],
      'market': <String, Object?>{'status': 'OPEN'},
      'items': <Object?>[
        <String, Object?>{'id': 'a'},
        <String, Object?>{'id': 'b'},
      ],
      'next_cursor': 'c2',
    });

    test('lee los tipos básicos', () {
      expect(reader.string('id'), 'ECOPETROL-CO');
      expect(reader.integer('quantity'), 120);
      expect(reader.boolean('open'), isTrue);
      expect(reader.strings('tags'), <String>['a', 'b']);
      expect(reader.object('market').string('status'), 'OPEN');
      expect(reader.stringOrNull('reject_code'), isNull);
      expect(reader.has('reject_code'), isFalse);
      expect(reader.has('id'), isTrue);
    });

    test('lee dinero desde string decimal', () {
      expect(reader.decimal('last_price'), Decimal.parse('2385'));
      expect(
        reader.money('last_price', reader.currency('currency')),
        Money.parse('2385.00', Currency.cop),
      );
    });

    test('rechaza un monto que llega como número JSON', () {
      expect(() => reader.decimal('as_number'), throwsFormatException);
      expect(
        () => reader.money('as_number', Currency.cop),
        throwsFormatException,
      );
    });

    test('rechaza un campo requerido ausente', () {
      expect(() => reader.string('ticker'), throwsFormatException);
      expect(() => reader.integer('volume'), throwsFormatException);
      expect(() => reader.object('instrument'), throwsFormatException);
    });

    test('rechaza un tipo inesperado', () {
      expect(() => reader.string('quantity'), throwsFormatException);
      expect(() => reader.integer('id'), throwsFormatException);
      expect(() => reader.stringOrNull('open'), throwsFormatException);
    });

    test('las fechas se devuelven en UTC', () {
      final DateTime parsed = reader.dateTime('updated_at');

      expect(parsed, DateTime.utc(2026, 11, 18, 14, 42));
      expect(parsed.isUtc, isTrue);
      expect(reader.dateTimeOrNull('reject_code'), isNull);
      expect(() => reader.dateTime('id'), throwsFormatException);
    });

    test('rechaza monedas y enums desconocidos', () {
      const JsonReader bad = JsonReader(<String, Object?>{
        'currency': 'EUR',
        'country': 'AR',
      });

      expect(() => bad.currency('currency'), throwsFormatException);
      expect(
        () => bad.enumValue<Country>('country', Country.tryFromCode),
        throwsFormatException,
      );
    });

    test('lee una página paginada', () {
      final Paginated<String> page = reader.paginated<String>(
        (JsonReader item) => item.string('id'),
      );

      expect(page.items, <String>['a', 'b']);
      expect(page.nextCursor, 'c2');
    });

    test('of y listOf rechazan cuerpos con otra forma', () {
      expect(() => JsonReader.of(<Object?>[]), throwsFormatException);
      expect(() => JsonReader.listOf('x'), throwsFormatException);
      expect(
        JsonReader.listOf(<Object?>[
          <String, Object?>{'id': 'a'},
        ]).single.string('id'),
        'a',
      );
    });
  });

  group('ApiResponse', () {
    test('json y jsonList rechazan cuerpos con otra forma', () {
      const ApiResponse object = ApiResponse(
        statusCode: 200,
        body: <String, Object?>{'a': 1},
      );
      const ApiResponse list = ApiResponse(statusCode: 200, body: <Object?>[1]);

      expect(object.json, <String, Object?>{'a': 1});
      expect(() => object.jsonList, throwsFormatException);
      expect(list.jsonList, <Object?>[1]);
      expect(() => list.json, throwsFormatException);
    });
  });

  group('AuthTokens', () {
    test('toString nunca expone los tokens', () {
      const AuthTokens tokens = AuthTokens(
        accessToken: 'secreto-1',
        refreshToken: 'secreto-2',
      );

      expect(tokens.toString(), isNot(contains('secreto')));
    });
  });
}
