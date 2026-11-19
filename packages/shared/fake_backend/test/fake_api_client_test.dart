import 'package:fake_backend/fake_backend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';

final class _Backend {
  _Backend({
    FakeSeed seed = FakeSeed.demo,
    FakeMarketMode marketMode = FakeMarketMode.alwaysOpen,
  }) {
    events.stream.listen(received.add);
    client = FakeApiClient(
      tokenStore: store,
      sessionEvents: events,
      clock: clock,
      seed: seed,
      marketMode: marketMode,
    );
  }

  final InMemoryTokenStore store = InMemoryTokenStore();
  final SessionEvents events = SessionEvents();
  final FixedClock clock = FixedClock(DateTime.utc(2026, 11, 18, 14, 42));
  final List<SessionEvent> received = <SessionEvent>[];
  late final FakeApiClient client;

  Future<void> login() async {
    final ApiResponse response = await client.post(
      '/auth/login',
      body: <String, Object?>{
        'email': FakeDemoAccount.email,
        'password': FakeDemoAccount.password,
      },
    );
    final JsonReader json = JsonReader.of(response.body);
    await store.save(
      AuthTokens(
        accessToken: json.string('access_token'),
        refreshToken: json.string('refresh_token'),
      ),
    );
  }
}

Future<ApiException> _failure(Future<ApiResponse> call) async {
  try {
    await call;
  } on ApiException catch (error) {
    return error;
  }
  fail('Se esperaba una ApiException');
}

Map<String, Object?> _order(String instrumentId, String side, int quantity) =>
    <String, Object?>{
      'instrument_id': instrumentId,
      'side': side,
      'type': 'MARKET',
      'quantity': quantity,
    };

Map<String, String> _key(String key) => <String, String>{
  ApiHeaders.idempotencyKey: key,
};

void main() {
  group('auth', () {
    test('login con la cuenta demo entrega tokens y /me', () async {
      final _Backend backend = _Backend();

      await backend.login();
      final JsonReader me = JsonReader.of(
        (await backend.client.get('/me')).body,
      );

      expect(me.string('email'), FakeDemoAccount.email);
      expect(me.string('country'), 'CO');
      expect(me.string('base_currency'), 'COP');
      expect(me.string('document_type'), 'CC');
      expect(me.string('document_last4'), '5678');
    });

    test('credenciales incorrectas dan AUTH_INVALID_CREDENTIALS', () async {
      final _Backend backend = _Backend();

      final ApiException error = await _failure(
        backend.client.post(
          '/auth/login',
          body: <String, Object?>{
            'email': FakeDemoAccount.email,
            'password': 'incorrecta',
          },
        ),
      );

      expect(error.code, ApiErrorCodes.authInvalidCredentials);
      expect(error.status, 401);
    });

    test('sin token, una ruta protegida cierra la sesión', () async {
      final _Backend backend = _Backend();

      final ApiException error = await _failure(backend.client.get('/me'));
      await Future<void>.delayed(Duration.zero);

      expect(error.code, ApiErrorCodes.authTokenInvalid);
      expect(backend.received, <SessionEvent>[SessionEvent.expired]);
    });

    test('refresh rota los tokens e invalida el refresh anterior', () async {
      final _Backend backend = _Backend();
      await backend.login();
      final AuthTokens old = (await backend.store.read())!;

      final JsonReader fresh = JsonReader.of(
        (await backend.client.post(
          '/auth/refresh',
          body: <String, Object?>{'refresh_token': old.refreshToken},
        )).body,
      );
      final ApiException reused = await _failure(
        backend.client.post(
          '/auth/refresh',
          body: <String, Object?>{'refresh_token': old.refreshToken},
        ),
      );

      expect(fresh.string('refresh_token'), isNot(old.refreshToken));
      expect(reused.code, ApiErrorCodes.authRefreshInvalid);
    });

    test('logout responde 204 e invalida la sesión', () async {
      final _Backend backend = _Backend();
      await backend.login();
      final AuthTokens tokens = (await backend.store.read())!;

      final ApiResponse response = await backend.client.post(
        '/auth/logout',
        body: <String, Object?>{'refresh_token': tokens.refreshToken},
      );
      final ApiException error = await _failure(backend.client.get('/me'));

      expect(response.statusCode, 204);
      expect(response.body, isNull);
      expect(error.code, ApiErrorCodes.authTokenInvalid);
    });

    test('registro crea el usuario con cuentas en cero', () async {
      final _Backend backend = _Backend();

      final ApiResponse response = await backend.client.post(
        '/auth/register',
        body: <String, Object?>{
          'email': 'Nueva@Correo.mx',
          'password': 'Segura123',
          'full_name': 'Saul',
          'country': 'MX',
          'document_type': 'CURP',
          'document_number': 'magl850315mdfrrs09',
        },
      );
      final JsonReader json = JsonReader.of(response.body);
      await backend.store.save(
        AuthTokens(
          accessToken: json.object('tokens').string('access_token'),
          refreshToken: json.object('tokens').string('refresh_token'),
        ),
      );
      final List<JsonReader> accounts = JsonReader.listOf(
        (await backend.client.get('/accounts')).body,
      );

      expect(response.statusCode, 201);
      expect(json.object('user').string('email'), 'nueva@correo.mx');
      expect(json.object('user').string('base_currency'), 'MXN');
      expect(json.object('user').string('document_last4'), 'RS09');
      expect(accounts.map((JsonReader a) => a.string('currency')), <String>[
        'COP',
        'MXN',
        'PEN',
      ]);
      expect(
        accounts.map((JsonReader a) => a.string('available')),
        everyElement('0.00'),
      );
    });

    test('registro valida campos y duplicados', () async {
      final _Backend backend = _Backend();
      Map<String, Object?> body({
        String email = 'otra@correo.co',
        String document = '52345678',
      }) => <String, Object?>{
        'email': email,
        'password': 'Segura123',
        'full_name': 'Daniela',
        'country': 'CO',
        'document_type': 'CC',
        'document_number': document,
      };

      final ApiException invalid = await _failure(
        backend.client.post(
          '/auth/register',
          body: <String, Object?>{
            ...body(document: '12'),
            'password': 'corta',
          },
        ),
      );
      final ApiException emailTaken = await _failure(
        backend.client.post(
          '/auth/register',
          body: body(email: FakeDemoAccount.email),
        ),
      );
      final ApiException documentTaken = await _failure(
        backend.client.post(
          '/auth/register',
          body: body(document: FakeDemoAccount.documentNumber),
        ),
      );

      expect(invalid.code, ApiErrorCodes.validationError);
      expect(invalid.fieldCode('password'), 'TOO_WEAK');
      expect(invalid.fieldCode('document_number'), 'INVALID_FORMAT');
      expect(emailTaken.code, ApiErrorCodes.authEmailTaken);
      expect(documentTaken.code, ApiErrorCodes.authDocumentTaken);
    });
  });

  group('mercado', () {
    test('lista instrumentos con la forma del contrato', () async {
      final _Backend backend = _Backend();
      await backend.login();

      final JsonReader page = JsonReader.of(
        (await backend.client.get(
          '/instruments',
          query: <String, Object?>{'limit': 100},
        )).body,
      );
      final JsonReader first = page.objects('items').first;

      expect(page.objects('items'), hasLength(13));
      expect(page.stringOrNull('next_cursor'), isNull);
      expect(first.string('id'), 'ECOPETROL-CO');
      expect(first.string('last_price'), '2385.00');
      expect(first.string('change'), '35.00');
      expect(first.string('change_pct'), '1.49');
      expect(first.string('updated_at'), '2026-11-18T14:42:00Z');
    });

    test('filtra por país, tipo y búsqueda', () async {
      final _Backend backend = _Backend();
      await backend.login();
      Future<List<String>> ids(Map<String, Object?> query) async =>
          JsonReader.of(
            (await backend.client.get('/instruments', query: query)).body,
          ).objects('items').map((JsonReader i) => i.string('id')).toList();

      expect(await ids(<String, Object?>{'country': 'PE'}), <String>[
        'BAP-PE',
        'SCCO-PE',
        'BVN-PE',
        'FERREYC1-PE',
      ]);
      expect(await ids(<String, Object?>{'type': 'ETF'}), <String>[
        'ICOLCAP-CO',
      ]);
      expect(await ids(<String, Object?>{'q': 'banco'}), <String>[
        'PFBCOLOM-CO',
      ]);
      expect(await ids(<String, Object?>{'q': 'zzz'}), isEmpty);
    });

    test('pagina por cursor sin repetir', () async {
      final _Backend backend = _Backend();
      await backend.login();
      final List<String> seen = <String>[];
      String? cursor;
      do {
        final JsonReader page = JsonReader.of(
          (await backend.client.get(
            '/instruments',
            query: <String, Object?>{'limit': 5, 'cursor': cursor},
          )).body,
        );
        seen.addAll(
          page.objects('items').map((JsonReader i) => i.string('id')),
        );
        cursor = page.stringOrNull('next_cursor');
      } while (cursor != null);

      expect(seen, hasLength(13));
      expect(seen.toSet(), hasLength(13));
    });

    test('detalle agrega estadísticas y un id desconocido da 404', () async {
      final _Backend backend = _Backend();
      await backend.login();

      final JsonReader detail = JsonReader.of(
        (await backend.client.get('/instruments/ECOPETROL-CO')).body,
      );
      final ApiException missing = await _failure(
        backend.client.get('/instruments/NOPE-CO'),
      );

      expect(detail.string('prev_close'), '2350.00');
      expect(detail.integer('volume'), 12450300);
      expect(detail.decimal('high') >= detail.decimal('low'), isTrue);
      expect(detail.decimal('high') >= detail.decimal('last_price'), isTrue);
      expect(detail.string('description'), isNotEmpty);
      expect(missing.code, ApiErrorCodes.instrumentNotFound);
      expect(missing.status, 404);
    });

    test(
      'las series son determinísticas y terminan en el último precio',
      () async {
        final _Backend a = _Backend();
        final _Backend b = _Backend();
        await a.login();
        await b.login();

        for (final String range in <String>['1D', '1W', '1M', '3M', '1Y']) {
          final Object? first = (await a.client.get(
            '/instruments/BAP-PE/prices',
            query: <String, Object?>{'range': range},
          )).body;
          final Object? second = (await b.client.get(
            '/instruments/BAP-PE/prices',
            query: <String, Object?>{'range': range},
          )).body;
          final JsonReader json = JsonReader.of(first);

          expect(first, second, reason: range);
          expect(json.string('range'), range);
          expect(json.string('currency'), 'PEN');
          expect(json.objects('points').last.string('price'), '192.50');
          expect(json.objects('points').length, greaterThan(20));
        }
      },
    );

    test('meta de países trae documentos y estado de mercado', () async {
      final _Backend open = _Backend();
      final _Backend closed = _Backend(marketMode: FakeMarketMode.closed);

      final List<JsonReader> countries = JsonReader.listOf(
        (await open.client.get('/meta/countries')).body,
      );
      final List<JsonReader> closedCountries = JsonReader.listOf(
        (await closed.client.get('/meta/countries')).body,
      );
      final JsonReader co = countries.first;

      expect(countries.map((JsonReader c) => c.string('code')), <String>[
        'CO',
        'MX',
        'PE',
      ]);
      expect(co.strings('document_types'), <String>['CC', 'CE']);
      expect(co.string('time_zone'), 'America/Bogota');
      expect(co.object('market').string('status'), 'OPEN');
      expect(co.object('market').string('closes_at'), '2026-11-18T21:00:00Z');
      expect(closedCountries.first.object('market').string('status'), 'CLOSED');
      expect(
        closedCountries.first.object('market').string('opens_at'),
        '2026-11-19T14:30:00Z',
      );
    });
  });

  group('órdenes', () {
    test('preview calcula bruto, comisión mínima, total y saldo', () async {
      final _Backend backend = _Backend();
      await backend.login();

      final JsonReader preview = JsonReader.of(
        (await backend.client.post(
          '/orders/preview',
          body: _order('ECOPETROL-CO', 'BUY', 10),
        )).body,
      );

      expect(preview.string('estimated_price'), '2385.00');
      expect(preview.string('gross'), '23850.00');
      expect(preview.string('commission'), '5000.00');
      expect(preview.string('total'), '28850.00');
      expect(preview.string('currency'), 'COP');
      expect(preview.string('available_after'), '7419890.00');
      expect(preview.strings('warnings'), isEmpty);
    });

    test(
      'comprar ejecuta, mueve el saldo, la posición y el historial',
      () async {
        final _Backend backend = _Backend();
        await backend.login();

        final ApiResponse response = await backend.client.post(
          '/orders',
          body: _order('ISA-CO', 'BUY', 10),
          headers: _key('k-1'),
        );
        final JsonReader order = JsonReader.of(response.body);
        final JsonReader cop = JsonReader.listOf(
          (await backend.client.get('/accounts')).body,
        ).first;
        final JsonReader portfolio = JsonReader.of(
          (await backend.client.get('/portfolio')).body,
        );
        final List<JsonReader> transactions = JsonReader.of(
          (await backend.client.get('/transactions')).body,
        ).objects('items');

        expect(response.statusCode, 201);
        expect(order.string('status'), 'FILLED');
        expect(order.string('executed_price'), '17800.00');
        expect(order.string('gross'), '178000.00');
        expect(order.string('commission'), '5000.00');
        expect(order.string('total'), '183000.00');
        expect(order.string('filled_at'), '2026-11-18T14:42:00Z');
        expect(cop.string('available'), '7265740.00');
        expect(
          portfolio
              .objects('positions')
              .map((JsonReader p) => p.object('instrument').string('id')),
          contains('ISA-CO'),
        );
        expect(transactions[0].string('type'), 'FEE');
        expect(transactions[0].string('amount'), '-5000.00');
        expect(transactions[1].string('type'), 'BUY');
        expect(transactions[1].string('amount'), '-178000.00');
        expect(transactions[1].string('order_id'), order.string('id'));
      },
    );

    test('vender acredita el bruto menos la comisión', () async {
      final _Backend backend = _Backend();
      await backend.login();

      final JsonReader order = JsonReader.of(
        (await backend.client.post(
          '/orders',
          body: _order('ECOPETROL-CO', 'SELL', 120),
          headers: _key('k-1'),
        )).body,
      );
      final JsonReader portfolio = JsonReader.of(
        (await backend.client.get('/portfolio')).body,
      );

      expect(order.string('gross'), '286200.00');
      expect(order.string('total'), '281200.00');
      expect(
        portfolio
            .objects('positions')
            .map((JsonReader p) => p.object('instrument').string('id')),
        isNot(contains('ECOPETROL-CO')),
      );
    });

    test('la misma Idempotency-Key no ejecuta dos veces', () async {
      final _Backend backend = _Backend();
      await backend.login();

      final ApiResponse first = await backend.client.post(
        '/orders',
        body: _order('GEB-CO', 'BUY', 5),
        headers: _key('k-1'),
      );
      final ApiResponse second = await backend.client.post(
        '/orders',
        body: _order('GEB-CO', 'BUY', 5),
        headers: _key('k-1'),
      );
      final ApiException conflict = await _failure(
        backend.client.post(
          '/orders',
          body: _order('GEB-CO', 'BUY', 6),
          headers: _key('k-1'),
        ),
      );
      final ApiException missing = await _failure(
        backend.client.post('/orders', body: _order('GEB-CO', 'BUY', 5)),
      );
      final List<JsonReader> orders = JsonReader.of(
        (await backend.client.get('/orders')).body,
      ).objects('items');

      expect(second.body, first.body);
      expect(conflict.code, ApiErrorCodes.idempotencyConflict);
      expect(conflict.status, 409);
      expect(missing.code, ApiErrorCodes.validationError);
      expect(
        orders.where((JsonReader o) => o.string('instrument_id') == 'GEB-CO'),
        hasLength(1),
      );
    });

    test(
      'rechaza saldo y posición insuficientes y cantidades inválidas',
      () async {
        final _Backend backend = _Backend();
        await backend.login();

        final ApiException funds = await _failure(
          backend.client.post(
            '/orders/preview',
            body: _order('PFBCOLOM-CO', 'BUY', 1000),
          ),
        );
        final ApiException position = await _failure(
          backend.client.post(
            '/orders',
            body: _order('ECOPETROL-CO', 'SELL', 121),
            headers: _key('k-1'),
          ),
        );
        final ApiException noPosition = await _failure(
          backend.client.post(
            '/orders/preview',
            body: _order('GEB-CO', 'SELL', 1),
          ),
        );
        final ApiException zero = await _failure(
          backend.client.post(
            '/orders/preview',
            body: _order('GEB-CO', 'BUY', 0),
          ),
        );
        final ApiException huge = await _failure(
          backend.client.post(
            '/orders/preview',
            body: _order('GEB-CO', 'BUY', 1000001),
          ),
        );

        expect(funds.code, ApiErrorCodes.insufficientFunds);
        expect(funds.detail, 'Available 7448740.00 COP');
        expect(position.code, ApiErrorCodes.insufficientPosition);
        expect(noPosition.code, ApiErrorCodes.insufficientPosition);
        expect(zero.fieldCode('quantity'), 'TOO_SMALL');
        expect(huge.fieldCode('quantity'), 'TOO_LARGE');
      },
    );

    test('con el mercado cerrado responde MARKET_CLOSED', () async {
      final _Backend backend = _Backend(marketMode: FakeMarketMode.closed);
      await backend.login();

      final ApiException error = await _failure(
        backend.client.post(
          '/orders/preview',
          body: _order('ECOPETROL-CO', 'BUY', 1),
        ),
      );

      expect(error.code, ApiErrorCodes.marketClosed);
    });

    test('historial filtra por estado y un id desconocido da 404', () async {
      final _Backend backend = _Backend();
      await backend.login();

      final List<JsonReader> rejected = JsonReader.of(
        (await backend.client.get(
          '/orders',
          query: <String, Object?>{'status': 'REJECTED'},
        )).body,
      ).objects('items');
      final JsonReader byId = JsonReader.of(
        (await backend.client.get(
          '/orders/${rejected.single.string('id')}',
        )).body,
      );
      final ApiException missing = await _failure(
        backend.client.get('/orders/ord_nope'),
      );

      expect(rejected.single.string('reject_code'), 'INSUFFICIENT_POSITION');
      expect(rejected.single.stringOrNull('executed_price'), isNull);
      expect(byId.string('status'), 'REJECTED');
      expect(missing.code, ApiErrorCodes.orderNotFound);
    });
  });

  group('billetera, portafolio y dashboard', () {
    test('el seed demo es coherente: saldos = depósitos − compras', () async {
      final _Backend backend = _Backend();
      await backend.login();

      final List<JsonReader> accounts = JsonReader.listOf(
        (await backend.client.get('/accounts')).body,
      );

      expect(
        <String, String>{
          for (final JsonReader account in accounts)
            account.string('currency'): account.string('available'),
        },
        <String, String>{
          'COP': '7448740.00',
          'MXN': '22120.00',
          'PEN': '5570.00',
        },
      );
    });

    test('depositar acredita y es idempotente', () async {
      final _Backend backend = _Backend();
      await backend.login();

      final ApiResponse first = await backend.client.post(
        '/accounts/COP/deposits',
        body: <String, Object?>{'amount': '100000'},
        headers: _key('d-1'),
      );
      final ApiResponse retry = await backend.client.post(
        '/accounts/COP/deposits',
        body: <String, Object?>{'amount': '100000'},
        headers: _key('d-1'),
      );
      final ApiException numeric = await _failure(
        backend.client.post(
          '/accounts/COP/deposits',
          body: <String, Object?>{'amount': 100000},
          headers: _key('d-2'),
        ),
      );
      final ApiException negative = await _failure(
        backend.client.post(
          '/accounts/COP/deposits',
          body: <String, Object?>{'amount': '-5'},
          headers: _key('d-3'),
        ),
      );
      final JsonReader cop = JsonReader.listOf(
        (await backend.client.get('/accounts')).body,
      ).first;
      final JsonReader transaction = JsonReader.of(first.body);

      expect(first.statusCode, 201);
      expect(transaction.string('type'), 'DEPOSIT');
      expect(transaction.string('amount'), '100000.00');
      expect(retry.body, first.body);
      expect(numeric.fieldCode('amount'), 'INVALID_FORMAT');
      expect(negative.fieldCode('amount'), 'TOO_SMALL');
      expect(cop.string('available'), '7548740.00');
    });

    test(
      'el portafolio totaliza en la moneda base con tipos de cambio',
      () async {
        final _Backend backend = _Backend();
        await backend.login();

        final JsonReader portfolio = JsonReader.of(
          (await backend.client.get('/portfolio')).body,
        );
        final JsonReader ecopetrol = portfolio.objects('positions').first;

        expect(portfolio.string('base_currency'), 'COP');
        expect(ecopetrol.integer('quantity'), 120);
        expect(ecopetrol.string('avg_cost'), '2210.50');
        expect(ecopetrol.string('market_value'), '286200.00');
        expect(ecopetrol.string('unrealized_pnl'), '20940.00');
        expect(ecopetrol.string('unrealized_pnl_pct'), '7.89');
        expect(
          portfolio.decimal('total_value'),
          portfolio.decimal('cash_value') + portfolio.decimal('invested_value'),
        );
        expect(
          portfolio
              .objects('allocation')
              .map((JsonReader a) => a.string('type')),
          <String>['STOCK', 'ETF', 'CASH'],
        );
        expect(
          portfolio
              .objects('fx_rates_used')
              .map((JsonReader r) => r.string('from')),
          <String>['MXN', 'PEN'],
        );
        expect(portfolio.objects('fx_rates_used').first.string('to'), 'COP');
      },
    );

    test('los movimientos filtran por tipo y por fecha', () async {
      final _Backend backend = _Backend();
      await backend.login();
      Future<List<JsonReader>> list(Map<String, Object?> query) async =>
          JsonReader.of(
            (await backend.client.get('/transactions', query: query)).body,
          ).objects('items');

      final List<JsonReader> deposits = await list(<String, Object?>{
        'type': 'DEPOSIT',
      });
      final List<JsonReader> recent = await list(<String, Object?>{
        'from': '2026-11-16T00:00:00Z',
      });

      expect(deposits, hasLength(3));
      expect(
        deposits.map((JsonReader t) => t.string('type')),
        everyElement('DEPOSIT'),
      );
      expect(recent, hasLength(8));
      expect(await list(<String, Object?>{}), hasLength(11));
    });

    test('el dashboard resume portafolio, top movers y últimos 5', () async {
      final _Backend backend = _Backend();
      await backend.login();

      final JsonReader dashboard = JsonReader.of(
        (await backend.client.get('/dashboard/summary')).body,
      );
      final JsonReader movers = dashboard.object('top_movers');

      expect(dashboard.object('portfolio_summary').has('positions'), isFalse);
      expect(
        dashboard.object('portfolio_summary').objects('allocation'),
        hasLength(3),
      );
      expect(movers.objects('gainers'), hasLength(3));
      expect(movers.objects('losers'), hasLength(3));
      expect(movers.objects('gainers').first.string('id'), 'ECOPETROL-CO');
      expect(movers.objects('losers').first.decimal('change_pct').sign, -1);
      expect(dashboard.objects('recent_transactions'), hasLength(5));
    });
  });

  group('seed empty', () {
    test('el usuario no tiene saldo, posiciones ni historial', () async {
      final _Backend backend = _Backend(seed: FakeSeed.empty);
      await backend.login();

      final List<JsonReader> accounts = JsonReader.listOf(
        (await backend.client.get('/accounts')).body,
      );
      final JsonReader portfolio = JsonReader.of(
        (await backend.client.get('/portfolio')).body,
      );
      final JsonReader dashboard = JsonReader.of(
        (await backend.client.get('/dashboard/summary')).body,
      );

      expect(
        accounts.map((JsonReader a) => a.string('available')),
        everyElement('0.00'),
      );
      expect(portfolio.string('total_value'), '0.00');
      expect(portfolio.string('day_change_pct'), '0.00');
      expect(portfolio.objects('positions'), isEmpty);
      expect(portfolio.objects('allocation'), isEmpty);
      expect(
        JsonReader.of(
          (await backend.client.get('/orders')).body,
        ).objects('items'),
        isEmpty,
      );
      expect(
        JsonReader.of(
          (await backend.client.get('/transactions')).body,
        ).objects('items'),
        isEmpty,
      );
      expect(dashboard.objects('recent_transactions'), isEmpty);
    });
  });

  group('herramientas de test', () {
    test(
      'failNext hace fallar solo la próxima petición que coincide',
      () async {
        final _Backend backend = _Backend();
        await backend.login();
        backend.client.failNext(
          const ApiException.networkUnavailable(),
          path: '/portfolio',
        );

        final ApiResponse other = await backend.client.get('/accounts');
        final ApiException error = await _failure(
          backend.client.get('/portfolio'),
        );
        final ApiResponse recovered = await backend.client.get('/portfolio');

        expect(other.statusCode, 200);
        expect(error.code, ApiErrorCodes.networkUnavailable);
        expect(recovered.statusCode, 200);
      },
    );

    test('registra las peticiones con sus headers', () async {
      final _Backend backend = _Backend();
      await backend.login();

      await backend.client.post(
        '/orders',
        body: _order('GEB-CO', 'BUY', 1),
        headers: _key('k-9'),
      );

      expect(backend.client.requests.last.method, 'POST');
      expect(backend.client.requests.last.path, '/orders');
      expect(
        backend.client.requests.last.headers[ApiHeaders.idempotencyKey],
        'k-9',
      );
    });

    test('FakeSeed.fromName resuelve el flag', () {
      expect(FakeSeed.fromName('empty'), FakeSeed.empty);
      expect(FakeSeed.fromName('demo'), FakeSeed.demo);
      expect(FakeSeed.fromName('otro'), FakeSeed.demo);
    });
  });
}
