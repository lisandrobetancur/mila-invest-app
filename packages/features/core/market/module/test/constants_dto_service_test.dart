import 'package:fake_backend/fake_backend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market/core/data/dto/country_market_dto.dart';
import 'package:market/core/data/dto/instrument_detail_dto.dart';
import 'package:market/core/data/dto/instrument_dto.dart';
import 'package:market/core/data/dto/price_series_dto.dart';
import 'package:market/core/data/market_remote_data_source.dart';
import 'package:market/core/service/service.dart';
import 'package:market/market.dart';
import 'package:market_constants/market_constants.dart';
import 'package:market_typing/market_typing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';

import 'support/harness.dart';

class _MockApiClient extends Mock implements ApiClient {}

const Map<String, Object?> _instrumentJson = <String, Object?>{
  'id': 'ECOPETROL-CO',
  'ticker': 'ECOPETROL',
  'name': 'Ecopetrol S.A.',
  'country': 'CO',
  'type': 'STOCK',
  'currency': 'COP',
  'last_price': '2385.00',
  'change': '35.00',
  'change_pct': '1.49',
  'updated_at': '2026-11-18T14:42:00Z',
};

Future<MarketService> _serviceOnFake() async {
  final InMemoryTokenStore store = InMemoryTokenStore();
  final FakeApiClient client = FakeApiClient(
    tokenStore: store,
    sessionEvents: SessionEvents(),
    clock: FixedClock(DateTime.utc(2026, 11, 18, 14, 42)),
  );
  final ApiResponse login = await client.post(
    '/auth/login',
    body: <String, Object?>{
      'email': FakeDemoAccount.email,
      'password': FakeDemoAccount.password,
    },
  );
  final JsonReader tokens = JsonReader.of(login.body);
  await store.save(
    AuthTokens(
      accessToken: tokens.string('access_token'),
      refreshToken: tokens.string('refresh_token'),
    ),
  );
  return MarketService(dataSource: MarketRemoteDataSource(client));
}

Matcher _marketError(MarketErrorCode code) => throwsA(
  isA<MarketException>().having((MarketException e) => e.code, 'code', code),
);

void main() {
  group('MarketIds y traducciones', () {
    test('los ids cumplen la convención, no se repiten y el ítem usa el id '
        'de la API', () {
      for (final String id in MarketIds.all) {
        expect(identifierPattern.hasMatch(id), isTrue, reason: id);
      }
      expect(MarketIds.all.toSet().length, MarketIds.all.length);
      expect(
        MarketIds.listInstrumentItem('ECOPETROL-CO'),
        'market_list_instrument_item_ECOPETROL-CO',
      );
    });

    test('es y en tienen las mismas claves y todos los errores', () {
      final Set<String> es = translationKeys(marketLanguages['es']!);
      final Set<String> en = translationKeys(marketLanguages['en']!);

      expect(es.difference(en), isEmpty);
      expect(en.difference(es), isEmpty);
      for (final MarketErrorCode code in MarketErrorCode.values) {
        expect(es, contains(code.messageKey));
      }
      for (final PriceRange range in PriceRange.values) {
        final String key = range.apiCode.toLowerCase();
        expect(es, contains('market.detail.range_$key'));
        expect(es, contains('market.detail.range_name_$key'));
      }
    });

    test('MarketRoutes arma las ubicaciones del detalle', () {
      expect(
        MarketRoutes.detailLocation('BAP-PE'),
        '/market/instrument/BAP-PE',
      );
    });
  });

  group('DTOs', () {
    test('InstrumentDto parsea el ejemplo del contrato', () {
      final Instrument parsed = InstrumentDto.fromJson(
        _instrumentJson,
      ).toDomain();

      expect(parsed.id, 'ECOPETROL-CO');
      expect(parsed.country, Country.co);
      expect(parsed.type, InstrumentType.stock);
      expect(parsed.lastPrice, Money.parse('2385', Currency.cop));
      expect(parsed.changePercent.toString(), '1.49');
      expect(parsed.updatedAt, DateTime.utc(2026, 11, 18, 14, 42));
    });

    test('rechaza un precio que llega como número JSON', () {
      expect(
        () => InstrumentDto.fromJson(<String, Object?>{
          ..._instrumentJson,
          'last_price': 2385.0,
        }),
        throwsFormatException,
      );
    });

    test('rechaza un campo requerido ausente o un tipo desconocido', () {
      expect(
        () => InstrumentDto.fromJson(
          Map<String, Object?>.of(_instrumentJson)..remove('ticker'),
        ),
        throwsFormatException,
      );
      expect(
        () => InstrumentDto.fromJson(<String, Object?>{
          ..._instrumentJson,
          'type': 'BOND',
        }),
        throwsFormatException,
      );
    });

    test('InstrumentDetailDto agrega las estadísticas', () {
      final InstrumentDetail parsed =
          InstrumentDetailDto.fromJson(<String, Object?>{
            ..._instrumentJson,
            'open': '2360.00',
            'high': '2400.00',
            'low': '2350.00',
            'prev_close': '2350.00',
            'volume': 12450300,
            'description': 'Petrolera.',
          }).toDomain();

      expect(parsed.prevClose, Money.parse('2350', Currency.cop));
      expect(parsed.volume, 12450300);
    });

    test('PriceSeriesDto ordena los puntos cronológicamente', () {
      final PriceSeries parsed = PriceSeriesDto.fromJson(
        const <String, Object?>{
          'range': '1D',
          'currency': 'COP',
          'points': <Object?>[
            <String, Object?>{'t': '2026-11-18T14:40:00Z', 'price': '2385.00'},
            <String, Object?>{'t': '2026-11-18T14:35:00Z', 'price': '2380.00'},
          ],
        },
      ).toDomain();

      expect(parsed.range, PriceRange.day);
      expect(parsed.points.first.price.toString(), '2380');
      expect(parsed.changePercent.toString(), '0.2');
    });

    test('CountryMarketDto lee el mercado anidado', () {
      final CountryMarket parsed = CountryMarketDto.fromJson(
        const <String, Object?>{
          'code': 'PE',
          'currency': 'PEN',
          'time_zone': 'America/Lima',
          'document_types': <Object?>['DNI', 'CE'],
          'market': <String, Object?>{
            'status': 'CLOSED',
            'opens_at': '2026-11-19T14:30:00Z',
            'closes_at': '2026-11-19T21:00:00Z',
          },
        },
      ).toDomain();

      expect(parsed.country, Country.pe);
      expect(parsed.isOpen, isFalse);
    });
  });

  group('MarketService', () {
    test('lista y filtra instrumentos contra el backend falso', () async {
      final MarketService service = await _serviceOnFake();

      final Paginated<Instrument> all = await service.instruments(
        const InstrumentFilter(),
        limit: 5,
      );
      final Paginated<Instrument> etfs = await service.instruments(
        const InstrumentFilter(type: InstrumentType.etf),
      );
      final Paginated<Instrument> search = await service.instruments(
        const InstrumentFilter(country: Country.mx, query: ' walmex '),
      );

      expect(all.items, hasLength(5));
      expect(all.hasMore, isTrue);
      expect(etfs.items.single.id, 'ICOLCAP-CO');
      expect(search.items.single.id, 'WALMEX-MX');
    });

    test('detalle, precios y mercados contra el backend falso', () async {
      final MarketService service = await _serviceOnFake();

      final InstrumentDetail detail = await service.instrument('BAP-PE');
      final PriceSeries prices = await service.prices(
        'BAP-PE',
        PriceRange.month,
      );
      final List<CountryMarket> markets = await service.countryMarkets();

      expect(detail.instrument.currency, Currency.pen);
      expect(prices.range, PriceRange.month);
      expect(prices.isDrawable, isTrue);
      expect(markets.map((CountryMarket m) => m.country), Country.values);
    });

    test('un instrumento inexistente es instrumentNotFound', () async {
      final MarketService service = await _serviceOnFake();

      await expectLater(
        service.instrument('NOPE-CO'),
        _marketError(MarketErrorCode.instrumentNotFound),
      );
    });

    test('traduce errores de red y respuestas con otra forma', () async {
      final _MockApiClient client = _MockApiClient();
      when(
        () => client.get(any(), query: any(named: 'query')),
      ).thenThrow(const ApiException.networkTimeout());
      when(() => client.get('/meta/countries')).thenAnswer(
        (_) async => const ApiResponse(
          statusCode: 200,
          body: <String, Object?>{'no': 'lista'},
        ),
      );
      final MarketService service = MarketService(
        dataSource: MarketRemoteDataSource(client),
      );

      await expectLater(
        service.instruments(const InstrumentFilter()),
        _marketError(MarketErrorCode.network),
      );
      await expectLater(
        service.countryMarkets(),
        _marketError(MarketErrorCode.unexpectedResponse),
      );
    });
  });
}
