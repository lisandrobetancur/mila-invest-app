import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

import 'fake_database.dart';
import 'fake_instruments.dart';
import 'fake_prices.dart';
import 'fake_seed.dart';

/// Cómo se comportan los mercados del backend falso.
enum FakeMarketMode {
  /// Siempre abiertos: el flujo demo funciona a cualquier hora.
  alwaysOpen,

  /// Siempre cerrados: para recorrer `MARKET_CLOSED`.
  closed,
}

/// Una petición recibida por el backend falso, para inspeccionar en tests.
typedef FakeRequest = ({
  String method,
  String path,
  Map<String, String> query,
  Map<String, Object?> body,
  Map<String, String> headers,
});

typedef _Planned = ({String? method, String? path, ApiException error});
typedef _Stored = ({String fingerprint, int status, Object? body});
typedef _Result = (int status, Object? body);

/// Backend falso en memoria (`API_MODE=fake`).
///
/// Responde las rutas de la fase 1 del contrato, con las mismas formas y
/// los mismos códigos de error, a partir de un seed determinístico. Imita
/// también lo que el cliente real hace con los tokens: lee el access token
/// del [TokenStore] y, si no es válido, cierra la sesión.
final class FakeApiClient implements ApiClient {
  /// Crea el backend falso.
  FakeApiClient({
    required TokenStore tokenStore,
    required SessionEvents sessionEvents,
    required Clock clock,
    FakeSeed seed = FakeSeed.demo,
    this.marketMode = FakeMarketMode.alwaysOpen,
    this.latency = Duration.zero,
    bool liveTicks = false,
  }) : _tokenStore = tokenStore,
       _sessionEvents = sessionEvents,
       _clock = clock,
       _db = FakeDatabase(clock: clock, seed: seed, liveTicks: liveTicks);

  /// Cantidad máxima de una orden.
  static const int maxQuantity = 1000000;

  /// Monto máximo de un depósito virtual.
  static final Decimal maxDeposit = Decimal.fromInt(1000000000);

  static const int _defaultLimit = 20;
  static const int _maxLimit = 100;

  /// Comportamiento de los mercados.
  FakeMarketMode marketMode;

  /// Demora artificial de cada respuesta, para que se vean los shimmer.
  final Duration latency;

  /// Peticiones recibidas, en orden.
  final List<FakeRequest> requests = <FakeRequest>[];

  final TokenStore _tokenStore;
  final SessionEvents _sessionEvents;
  final Clock _clock;
  final FakeDatabase _db;
  final List<_Planned> _plannedFailures = <_Planned>[];
  final Map<String, _Stored> _idempotency = <String, _Stored>{};

  @override
  Future<ApiResponse> delete(
    String path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => _dispatch('DELETE', path, query: query, headers: headers);

  /// Hace fallar la próxima petición que coincida con [method] y [path].
  ///
  /// Sirve para recorrer estados de error en tests de controllers y vistas.
  void failNext(ApiException error, {String? method, String? path}) =>
      _plannedFailures.add((method: method, path: path, error: error));

  @override
  Future<ApiResponse> get(
    String path, {
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => _dispatch('GET', path, query: query, headers: headers);

  @override
  Future<ApiResponse> post(
    String path, {
    Map<String, Object?>? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => _dispatch('POST', path, body: body, query: query, headers: headers);

  @override
  Future<ApiResponse> put(
    String path, {
    Map<String, Object?>? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) => _dispatch('PUT', path, body: body, query: query, headers: headers);

  Map<String, Object?> _countryJson(Country country) {
    final DateTime now = _clock.nowUtc();
    final DateTime local = now.add(country.utcOffset);
    DateTime session(DateTime day, int hour, int minute) => DateTime.utc(
      day.year,
      day.month,
      day.day,
      hour,
      minute,
    ).subtract(country.utcOffset);
    DateTime nextWeekday(DateTime day) {
      DateTime next = day.add(const Duration(days: 1));
      while (next.weekday > DateTime.friday) {
        next = next.add(const Duration(days: 1));
      }
      return next;
    }

    final bool isOpen = marketMode == FakeMarketMode.alwaysOpen;
    final DateTime todayClose = session(local, 16, 0);
    final DateTime closeDay = isOpen && now.isBefore(todayClose)
        ? local
        : nextWeekday(local);
    final DateTime openDay = isOpen ? local : nextWeekday(local);
    return <String, Object?>{
      'code': country.code,
      'currency': country.currency.code,
      'time_zone': country.timeZoneName,
      'document_types': <String>[
        for (final DocumentType type in country.documentTypes) type.code,
      ],
      'market': <String, Object?>{
        'status': isOpen ? 'OPEN' : 'CLOSED',
        'opens_at': FakeDatabase.iso(session(openDay, 9, 30)),
        'closes_at': FakeDatabase.iso(session(closeDay, 16, 0)),
      },
    };
  }

  Future<FakeUser> _authenticate() async {
    final AuthTokens? tokens = await _tokenStore.read();
    final FakeUser? user = tokens == null
        ? null
        : _db.userByAccessToken(tokens.accessToken);
    if (user == null) {
      await _tokenStore.clear();
      _sessionEvents.notifyExpired();
      throw const ApiException(
        status: 401,
        code: ApiErrorCodes.authTokenInvalid,
      );
    }
    return user;
  }

  _Result _deposit(
    FakeUser user,
    String currencyCode,
    Map<String, Object?> body,
    Map<String, String> headers,
  ) {
    final Currency? currency = Currency.tryFromCode(currencyCode);
    if (currency == null ||
        !FakeDatabase.accountCurrencies.contains(currency)) {
      _invalid(<String, String>{'currency': 'INVALID'});
    }
    final Object? raw = body['amount'];
    final Decimal? amount = raw is String ? Decimal.tryParse(raw) : null;
    if (amount == null) {
      _invalid(<String, String>{'amount': 'INVALID_FORMAT'});
    }
    if (amount <= Decimal.zero) {
      _invalid(<String, String>{'amount': 'TOO_SMALL'});
    }
    if (amount > maxDeposit) {
      _invalid(<String, String>{'amount': 'TOO_LARGE'});
    }
    return _idempotent(
      user,
      'deposit:$currencyCode',
      body,
      headers,
      () => (201, _db.deposit(user.id, currency, amount)),
    );
  }

  Future<ApiResponse> _dispatch(
    String method,
    String path, {
    Map<String, Object?>? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
  }) async {
    final Map<String, String> params = <String, String>{
      for (final MapEntry<String, Object?> entry
          in (query ?? const <String, Object?>{}).entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };
    final Map<String, Object?> payload = body ?? const <String, Object?>{};
    final Map<String, String> extra = headers ?? const <String, String>{};
    requests.add((
      method: method,
      path: path,
      query: params,
      body: payload,
      headers: extra,
    ));
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
    final ApiException? planned = _takePlannedFailure(method, path);
    if (planned != null) {
      throw planned;
    }
    final List<String> segments = path
        .split('/')
        .where((String segment) => segment.isNotEmpty)
        .toList();
    final (int status, Object? result) = await _route(
      method,
      segments,
      params,
      payload,
      extra,
    );
    // Ida y vuelta por JSON: el cuerpo llega con la misma forma (y los mismos
    // tipos en runtime) que cuando lo decodifica el cliente real.
    return ApiResponse(
      statusCode: status,
      body: result == null ? null : jsonDecode(jsonEncode(result)),
    );
  }

  FakeInstrument _instrument(Object? id) {
    for (final FakeInstrument instrument in fakeInstruments) {
      if (instrument.id == id) {
        return instrument;
      }
    }
    throw const ApiException(
      status: 404,
      code: ApiErrorCodes.instrumentNotFound,
    );
  }

  Map<String, Object?> _instrumentDetail(FakeInstrument instrument) {
    final int last = _db.priceOf(instrument);
    final List<FakePricePoint> day = FakePrices.series(
      instrument,
      '1D',
      _clock.nowUtc(),
      last,
    );
    int high = last;
    int low = last;
    for (final FakePricePoint point in day) {
      high = point.cents > high ? point.cents : high;
      low = point.cents < low ? point.cents : low;
    }
    String price(int cents) =>
        FakeDatabase.money(FakeDatabase.centsToDecimal(cents));
    return <String, Object?>{
      ..._db.instrumentJson(instrument),
      'open': price(day.first.cents),
      'high': price(high),
      'low': price(low),
      'prev_close': price(instrument.prevCloseCents),
      'volume': instrument.volume,
      'description': instrument.description,
    };
  }

  _Result _instruments(Map<String, String> query) {
    final String? country = query['country'];
    final String? type = query['type'];
    final String search = (query['q'] ?? '').trim().toLowerCase();
    return (
      200,
      _paginate(<Map<String, Object?>>[
        for (final FakeInstrument instrument in fakeInstruments)
          if ((country == null || instrument.country.code == country) &&
              (type == null || instrument.type == type) &&
              (search.isEmpty ||
                  instrument.ticker.toLowerCase().contains(search) ||
                  instrument.name.toLowerCase().contains(search)))
            _db.instrumentJson(instrument),
      ], query),
    );
  }

  _Result _idempotent(
    FakeUser user,
    String scope,
    Map<String, Object?> body,
    Map<String, String> headers,
    _Result Function() run,
  ) {
    final String? key = headers[ApiHeaders.idempotencyKey];
    if (key == null || key.isEmpty) {
      _invalid(<String, String>{'idempotency_key': 'REQUIRED'});
    }
    final String storeKey = '${user.id}|$key';
    final String fingerprint = '$scope|${jsonEncode(body)}';
    final _Stored? previous = _idempotency[storeKey];
    if (previous != null) {
      if (previous.fingerprint != fingerprint) {
        throw const ApiException(
          status: 409,
          code: ApiErrorCodes.idempotencyConflict,
        );
      }
      return (previous.status, previous.body);
    }
    final (int status, Object? result) = run();
    _idempotency[storeKey] = (
      fingerprint: fingerprint,
      status: status,
      body: result,
    );
    return (status, result);
  }

  Never _invalid(Map<String, String> fields) => throw ApiException(
    status: 422,
    code: ApiErrorCodes.validationError,
    fieldErrors: <ApiFieldError>[
      for (final MapEntry<String, String> field in fields.entries)
        ApiFieldError(field: field.key, code: field.value),
    ],
  );

  _Result _login(Map<String, Object?> body) {
    final Object? email = body['email'];
    final Object? password = body['password'];
    final FakeUser? user = email is String
        ? _db.userByEmail(Validators.normalizeEmail(email))
        : null;
    if (user == null || user.password != password) {
      throw const ApiException(
        status: 401,
        code: ApiErrorCodes.authInvalidCredentials,
      );
    }
    return (200, _db.createSession(user.id));
  }

  _Result _order(
    FakeUser user,
    Map<String, Object?> body,
    Map<String, String> headers, {
    required bool execute,
  }) {
    final FakeInstrument instrument = _instrument(body['instrument_id']);
    final Object? side = body['side'];
    final Object? quantity = body['quantity'];
    if (side != 'BUY' && side != 'SELL') {
      _invalid(<String, String>{'side': 'INVALID'});
    }
    if (body['type'] != 'MARKET') {
      _invalid(<String, String>{'type': 'INVALID'});
    }
    if (quantity is! int) {
      _invalid(<String, String>{'quantity': 'INVALID_FORMAT'});
    }
    if (quantity < 1) {
      _invalid(<String, String>{'quantity': 'TOO_SMALL'});
    }
    if (quantity > maxQuantity) {
      _invalid(<String, String>{'quantity': 'TOO_LARGE'});
    }
    if (marketMode == FakeMarketMode.closed) {
      throw const ApiException(status: 422, code: ApiErrorCodes.marketClosed);
    }
    final String orderSide = side! as String;
    final FakeQuote quote = _db.quote(
      user.id,
      instrument,
      side: orderSide,
      quantity: quantity,
    );
    final Currency currency = instrument.currency;
    final Decimal available = _db.availableOf(user.id, currency);
    if (orderSide == 'BUY' && quote.total > available) {
      throw ApiException(
        status: 422,
        code: ApiErrorCodes.insufficientFunds,
        detail: 'Available ${FakeDatabase.money(available)} ${currency.code}',
        fieldErrors: const <ApiFieldError>[
          ApiFieldError(field: 'quantity', code: 'TOO_LARGE'),
        ],
      );
    }
    final int held = _db.positionOf(user.id, instrument.id);
    if (orderSide == 'SELL' && quantity > held) {
      throw ApiException(
        status: 422,
        code: ApiErrorCodes.insufficientPosition,
        detail: 'Position $held ${instrument.ticker}',
        fieldErrors: const <ApiFieldError>[
          ApiFieldError(field: 'quantity', code: 'TOO_LARGE'),
        ],
      );
    }
    if (!execute) {
      final Decimal lowBalance = (available * Decimal.parse('0.05')).round(
        scale: 2,
      );
      return (
        200,
        <String, Object?>{
          'estimated_price': FakeDatabase.money(quote.price),
          'gross': FakeDatabase.money(quote.gross),
          'commission': FakeDatabase.money(quote.commission),
          'total': FakeDatabase.money(quote.total),
          'currency': currency.code,
          'available_after': FakeDatabase.money(quote.availableAfter),
          'warnings': <String>[
            if (orderSide == 'BUY' && quote.availableAfter < lowBalance)
              'LOW_BALANCE',
          ],
        },
      );
    }
    return _idempotent(
      user,
      'order',
      body,
      headers,
      () => (
        201,
        _db.fill(
          user.id,
          instrument,
          side: orderSide,
          quantity: quantity,
          priceCents: _db.priceOf(instrument),
        ),
      ),
    );
  }

  _Result _orders(FakeUser user, Map<String, String> query) {
    final String? status = query['status'];
    return (
      200,
      _paginate(<Map<String, Object?>>[
        for (final Map<String, Object?> order in _db.ordersOf(user.id))
          if (status == null || order['status'] == status) order,
      ], query),
    );
  }

  Map<String, Object?> _paginate(
    List<Map<String, Object?>> all,
    Map<String, String> query,
  ) {
    final int requested = int.tryParse(query['limit'] ?? '') ?? _defaultLimit;
    final int limit = requested.clamp(1, _maxLimit);
    final String? cursor = query['cursor'];
    final int offset = cursor == null
        ? 0
        : int.tryParse(cursor.replaceFirst('o:', '')) ?? 0;
    final int end = offset + limit;
    return <String, Object?>{
      'items': all.skip(offset).take(limit).toList(),
      'next_cursor': end < all.length ? 'o:$end' : null,
    };
  }

  _Result _prices(FakeInstrument instrument, Map<String, String> query) {
    final String range = query['range'] ?? '1D';
    if (!FakePrices.ranges.contains(range)) {
      _invalid(<String, String>{'range': 'INVALID'});
    }
    return (
      200,
      <String, Object?>{
        'range': range,
        'currency': instrument.currency.code,
        'points': <Map<String, Object?>>[
          for (final FakePricePoint point in FakePrices.series(
            instrument,
            range,
            _clock.nowUtc(),
            _db.priceOf(instrument),
          ))
            <String, Object?>{
              't': FakeDatabase.iso(point.t),
              'price': FakeDatabase.money(
                FakeDatabase.centsToDecimal(point.cents),
              ),
            },
        ],
      },
    );
  }

  _Result _register(Map<String, Object?> body) {
    String text(String key) {
      final Object? value = body[key];
      return value is String ? value : '';
    }

    final String email = Validators.normalizeEmail(text('email'));
    final String password = text('password');
    final String fullName = text('full_name').trim();
    final Country? country = Country.tryFromCode(text('country'));
    final DocumentType? type = DocumentType.tryFromCode(text('document_type'));
    final String document = type == null
        ? text('document_number')
        : Validators.normalizeDocument(type, text('document_number'));
    final Map<String, String> errors = <String, String>{
      if (!Validators.isEmail(email)) 'email': 'INVALID_FORMAT',
      if (!Validators.isPassword(password)) 'password': 'TOO_WEAK',
      if (!Validators.isFullName(fullName)) 'full_name': 'INVALID_LENGTH',
      if (country == null) 'country': 'INVALID',
      if (type == null ||
          country == null ||
          !country.documentTypes.contains(type))
        'document_type': 'INVALID'
      else if (!Validators.isDocumentNumber(
        country: country,
        type: type,
        raw: document,
      ))
        'document_number': 'INVALID_FORMAT',
    };
    if (errors.isNotEmpty || country == null || type == null) {
      _invalid(errors);
    }
    if (_db.userByEmail(email) != null) {
      throw const ApiException(
        status: 409,
        code: ApiErrorCodes.authEmailTaken,
        fieldErrors: <ApiFieldError>[
          ApiFieldError(field: 'email', code: 'TAKEN'),
        ],
      );
    }
    if (_db.userByDocument(type, document) != null) {
      throw const ApiException(
        status: 409,
        code: ApiErrorCodes.authDocumentTaken,
        fieldErrors: <ApiFieldError>[
          ApiFieldError(field: 'document_number', code: 'TAKEN'),
        ],
      );
    }
    final FakeUser user = _db.addUser(
      email: email,
      password: password,
      fullName: fullName,
      country: country,
      documentType: type,
      documentNumber: document,
    );
    return (
      201,
      <String, Object?>{
        'user': _db.meJson(user),
        'tokens': _db.createSession(user.id),
      },
    );
  }

  Future<_Result> _route(
    String method,
    List<String> segments,
    Map<String, String> query,
    Map<String, Object?> body,
    Map<String, String> headers,
  ) async {
    switch ((method, segments)) {
      case ('POST', <String>['auth', 'register']):
        return _register(body);
      case ('POST', <String>['auth', 'login']):
        return _login(body);
      case ('POST', <String>['auth', 'refresh']):
        return (200, _db.refresh('${body['refresh_token']}'));
      case ('POST', <String>['auth', 'logout']):
        _db.logout('${body['refresh_token']}');
        return (204, null);
      case ('GET', <String>['meta', 'countries']):
        return (
          200,
          <Map<String, Object?>>[
            for (final Country country in Country.values) _countryJson(country),
          ],
        );
      case _:
        break;
    }

    final FakeUser user = await _authenticate();
    switch ((method, segments)) {
      case ('GET', <String>['me']):
        return (200, _db.meJson(user));
      case ('GET', <String>['accounts']):
        return (200, _db.accountsJson(user.id));
      case ('POST', <String>['accounts', final String currency, 'deposits']):
        return _deposit(user, currency, body, headers);
      case ('GET', <String>['instruments']):
        return _instruments(query);
      case ('GET', <String>['instruments', final String id]):
        return (200, _instrumentDetail(_instrument(id)));
      case ('GET', <String>['instruments', final String id, 'prices']):
        return _prices(_instrument(id), query);
      case ('POST', <String>['orders', 'preview']):
        return _order(user, body, headers, execute: false);
      case ('POST', <String>['orders']):
        return _order(user, body, headers, execute: true);
      case ('GET', <String>['orders']):
        return _orders(user, query);
      case ('GET', <String>['orders', final String id]):
        for (final Map<String, Object?> order in _db.ordersOf(user.id)) {
          if (order['id'] == id) {
            return (200, order);
          }
        }
        throw const ApiException(
          status: 404,
          code: ApiErrorCodes.orderNotFound,
        );
      case ('GET', <String>['portfolio']):
        return (200, _db.portfolioJson(user));
      case ('GET', <String>['transactions']):
        return _transactions(user, query);
      case ('GET', <String>['dashboard', 'summary']):
        return (200, _db.dashboardJson(user));
      case _:
        throw const ApiException(
          status: 404,
          code: ApiErrorCodes.internalError,
          detail: 'Ruta no implementada en el backend falso',
        );
    }
  }

  ApiException? _takePlannedFailure(String method, String path) {
    for (int index = 0; index < _plannedFailures.length; index++) {
      final _Planned planned = _plannedFailures[index];
      if ((planned.method == null || planned.method == method) &&
          (planned.path == null || planned.path == path)) {
        _plannedFailures.removeAt(index);
        return planned.error;
      }
    }
    return null;
  }

  _Result _transactions(FakeUser user, Map<String, String> query) {
    final String? type = query['type'];
    final DateTime? from = DateTime.tryParse(query['from'] ?? '');
    final DateTime? to = DateTime.tryParse(query['to'] ?? '');
    bool inRange(Map<String, Object?> transaction) {
      final DateTime created = DateTime.parse(
        transaction['created_at']! as String,
      );
      return (from == null || !created.isBefore(from)) &&
          (to == null || !created.isAfter(to));
    }

    return (
      200,
      _paginate(<Map<String, Object?>>[
        for (final Map<String, Object?> transaction in _db.transactionsOf(
          user.id,
        ))
          if ((type == null || transaction['type'] == type) &&
              inRange(transaction))
            transaction,
      ], query),
    );
  }
}
