import 'package:fake_backend/fake_backend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network/network.dart';
import 'package:orders/core/data/dto/order_dto.dart';
import 'package:orders/core/data/dto/order_preview_dto.dart';
import 'package:orders/core/data/dto/order_request_dto.dart';
import 'package:orders/core/data/orders_remote_data_source.dart';
import 'package:orders/core/service/service.dart';
import 'package:orders/orders.dart';
import 'package:orders_constants/orders_constants.dart';
import 'package:orders_typing/orders_typing.dart';
import 'package:typing/typing.dart';

import 'support/harness.dart';

class _MockApiClient extends Mock implements ApiClient {}

const Map<String, Object?> _orderJson = <String, Object?>{
  'id': 'ord_01H',
  'instrument_id': 'ECOPETROL-CO',
  'side': 'BUY',
  'type': 'MARKET',
  'quantity': 10,
  'status': 'FILLED',
  'executed_price': '2386.00',
  'gross': '23860.00',
  'commission': '5000.00',
  'total': '28860.00',
  'currency': 'COP',
  'reject_code': null,
  'created_at': '2026-11-18T14:43:10Z',
  'filled_at': '2026-11-18T14:43:10Z',
};

const OrderRequest _request = OrderRequest(
  instrumentId: 'ECOPETROL-CO',
  side: OrderSide.buy,
  quantity: 10,
);

Future<(OrdersService, FakeApiClient)> _onFake() async {
  final InMemoryTokenStore store = InMemoryTokenStore();
  final FakeApiClient client = FakeApiClient(
    tokenStore: store,
    sessionEvents: SessionEvents(),
    clock: FixedClock(DateTime.utc(2026, 11, 18, 14, 42)),
  );
  final JsonReader tokens = JsonReader.of(
    (await client.post(
      '/auth/login',
      body: <String, Object?>{
        'email': FakeDemoAccount.email,
        'password': FakeDemoAccount.password,
      },
    )).body,
  );
  await store.save(
    AuthTokens(
      accessToken: tokens.string('access_token'),
      refreshToken: tokens.string('refresh_token'),
    ),
  );
  return (
    OrdersService(
      dataSource: OrdersRemoteDataSource(client),
      idGenerator: SequentialIdGenerator(prefix: 'key-'),
    ),
    client,
  );
}

Matcher _ordersError(OrdersErrorCode code) => throwsA(
  isA<OrdersException>().having((OrdersException e) => e.code, 'code', code),
);

void main() {
  group('OrdersIds y traducciones', () {
    test('cumplen la convención y no se repiten', () {
      for (final String id in OrdersIds.all) {
        expect(identifierPattern.hasMatch(id), isTrue, reason: id);
      }
      expect(OrdersIds.all.toSet().length, OrdersIds.all.length);
      expect(OrdersIds.historyItem('ord_1'), 'orders_history_item_ord_1');
    });

    test('es y en tienen las mismas claves y todos los errores', () {
      final Set<String> es = translationKeys(ordersLanguages['es']!);
      final Set<String> en = translationKeys(ordersLanguages['en']!);

      expect(es.difference(en), isEmpty);
      expect(en.difference(es), isEmpty);
      for (final OrdersErrorCode code in OrdersErrorCode.values) {
        expect(es, contains(code.messageKey), reason: code.name);
      }
      for (final OrderStatus status in OrderStatus.values) {
        expect(es, contains('orders.status.${status.name}'));
        expect(es, contains('orders.result.title_${status.name}'));
      }
    });

    test('OrdersRoutes arma las ubicaciones', () {
      expect(
        OrdersRoutes.ticketLocation('BAP-PE', 'sell'),
        '/orders/ticket/BAP-PE/sell',
      );
      expect(OrdersRoutes.detailLocation('ord_1'), '/activity/orders/ord_1');
      expect(OrderSide.fromRouteValue('sell'), OrderSide.sell);
      expect(OrderSide.fromRouteValue('x'), OrderSide.buy);
    });
  });

  group('DTOs', () {
    test('OrderDto parsea el ejemplo del contrato', () {
      final Order order = OrderDto.fromJson(_orderJson).toDomain();

      expect(order.side, OrderSide.buy);
      expect(order.status, OrderStatus.filled);
      expect(order.executedPrice, Money.parse('2386', Currency.cop));
      expect(order.total, Money.parse('28860', Currency.cop));
      expect(order.rejectCode, isNull);
      expect(order.ticker, 'ECOPETROL');
    });

    test('una orden rechazada no trae montos y mapea su motivo', () {
      final Order order = OrderDto.fromJson(<String, Object?>{
        ..._orderJson,
        'status': 'REJECTED',
        'executed_price': null,
        'gross': null,
        'commission': null,
        'total': null,
        'reject_code': 'MARKET_CLOSED',
        'filled_at': null,
      }).toDomain();

      expect(order.isRejected, isTrue);
      expect(order.total, isNull);
      expect(order.rejectCode, OrdersErrorCode.marketClosed);
    });

    test('rechaza un monto numérico y un campo requerido ausente', () {
      expect(
        () =>
            OrderDto.fromJson(<String, Object?>{..._orderJson, 'total': 28860}),
        throwsFormatException,
      );
      expect(
        () => OrderDto.fromJson(
          Map<String, Object?>.of(_orderJson)..remove('side'),
        ),
        throwsFormatException,
      );
    });

    test('preview y request respetan el contrato', () {
      final OrderPreview preview = OrderPreviewDto.fromJson(
        const <String, Object?>{
          'estimated_price': '2385.00',
          'gross': '23850.00',
          'commission': '5000.00',
          'total': '28850.00',
          'currency': 'COP',
          'available_after': '-850.00',
          'warnings': <Object?>['LOW_BALANCE'],
        },
      ).toDomain();

      expect(preview.leavesNegativeBalance, isTrue);
      expect(preview.hasLowBalanceWarning, isTrue);
      expect(OrderRequestDto.fromDomain(_request).toJson(), <String, Object?>{
        'instrument_id': 'ECOPETROL-CO',
        'side': 'BUY',
        'type': 'MARKET',
        'quantity': 10,
      });
    });
  });

  group('OrdersService contra el backend falso', () {
    test('cotiza y ejecuta una compra', () async {
      final (OrdersService service, FakeApiClient _) = await _onFake();

      final OrderPreview preview = await service.preview(_request);
      final Order order = await service.submit(_request);

      expect(preview.total, Money.parse('28850', Currency.cop));
      expect(order.isFilled, isTrue);
      expect(order.executedPrice, Money.parse('2385', Currency.cop));
    });

    test('traduce los rechazos de negocio', () async {
      final (OrdersService service, FakeApiClient _) = await _onFake();

      await expectLater(
        service.preview(
          const OrderRequest(
            instrumentId: 'GEB-CO',
            side: OrderSide.sell,
            quantity: 1,
          ),
        ),
        _ordersError(OrdersErrorCode.insufficientPosition),
      );
      await expectLater(
        service.order('ord_nope'),
        _ordersError(OrdersErrorCode.orderNotFound),
      );
    });

    test('pagina el historial y filtra por estado', () async {
      final (OrdersService service, FakeApiClient _) = await _onFake();

      final Paginated<Order> rejected = await service.orders(
        status: OrderStatus.rejected,
      );

      expect(
        rejected.items.single.rejectCode,
        OrdersErrorCode.insufficientPosition,
      );
    });
  });

  group('regla de idempotencia', () {
    late _MockApiClient client;
    late OrdersService service;
    final List<String> keys = <String>[];

    setUp(() {
      keys.clear();
      client = _MockApiClient();
      service = OrdersService(
        dataSource: OrdersRemoteDataSource(client),
        idGenerator: SequentialIdGenerator(prefix: 'key-'),
      );
    });

    void answer(List<Object> outcomes) {
      int call = 0;
      when(
        () => client.post(
          '/orders',
          body: any(named: 'body'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((Invocation invocation) async {
        final Map<String, String> headers =
            invocation.namedArguments[#headers]! as Map<String, String>;
        keys.add(headers[ApiHeaders.idempotencyKey]!);
        final Object outcome = outcomes[call++];
        if (outcome is ApiException) {
          throw outcome;
        }
        return ApiResponse(statusCode: 201, body: outcome);
      });
    }

    test(
      'un reintento manual tras un error de red reutiliza la clave',
      () async {
        answer(<Object>[const ApiException.networkTimeout(), _orderJson]);

        await expectLater(
          service.submit(_request),
          _ordersError(OrdersErrorCode.network),
        );
        await service.submit(_request);

        expect(keys, <String>['key-1', 'key-1']);
      },
    );

    test('si cambia la orden, la clave es nueva', () async {
      answer(<Object>[const ApiException.networkTimeout(), _orderJson]);

      await expectLater(
        service.submit(_request),
        _ordersError(OrdersErrorCode.network),
      );
      await service.submit(
        const OrderRequest(
          instrumentId: 'ECOPETROL-CO',
          side: OrderSide.buy,
          quantity: 11,
        ),
      );

      expect(keys, <String>['key-1', 'key-2']);
    });

    test(
      'después de un éxito o un rechazo de negocio, la clave es nueva',
      () async {
        answer(<Object>[
          _orderJson,
          const ApiException(status: 422, code: ApiErrorCodes.marketClosed),
          _orderJson,
        ]);

        await service.submit(_request);
        await expectLater(
          service.submit(_request),
          _ordersError(OrdersErrorCode.marketClosed),
        );
        await service.submit(_request);

        expect(keys, <String>['key-1', 'key-2', 'key-3']);
      },
    );

    test('un POST nunca se reintenta solo', () async {
      answer(<Object>[const ApiException.networkUnavailable()]);

      await expectLater(
        service.submit(_request),
        _ordersError(OrdersErrorCode.network),
      );

      expect(keys, hasLength(1));
    });
  });
}
