import 'package:decimal/decimal.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';

import 'fake_instruments.dart';
import 'fake_prices.dart';
import 'fake_seed.dart';

/// Usuario del backend falso.
class FakeUser {
  /// Crea un usuario.
  const FakeUser({
    required this.id,
    required this.email,
    required this.password,
    required this.fullName,
    required this.country,
    required this.documentType,
    required this.documentNumber,
  });

  /// Id del usuario.
  final String id;

  /// Email, en minúsculas.
  final String email;

  /// Contraseña en claro: es un backend de mentira, en memoria.
  final String password;

  /// Nombre completo.
  final String fullName;

  /// País de registro.
  final Country country;

  /// Tipo de documento.
  final DocumentType documentType;

  /// Número de documento.
  final String documentNumber;
}

/// Posición de un usuario en un instrumento.
class FakePosition {
  /// Crea una posición.
  FakePosition({required this.quantity, required this.avgCost});

  /// Cantidad en posición.
  int quantity;

  /// Costo promedio por unidad.
  Decimal avgCost;
}

/// Cotización de una orden a mercado.
typedef FakeQuote = ({
  Decimal price,
  Decimal gross,
  Decimal commission,
  Decimal total,
  Decimal availableAfter,
});

/// Estado en memoria del backend falso, con sus reglas de negocio.
///
/// Las mismas operaciones que usan las rutas (`deposit`, `fill`) construyen
/// el seed `demo`, así los saldos, las posiciones y el historial sembrados
/// son coherentes entre sí por construcción.
class FakeDatabase {
  /// Crea la base y la siembra con [seed].
  FakeDatabase({
    required this.clock,
    required FakeSeed seed,
    this.liveTicks = false,
  }) {
    final FakeUser demo = addUser(
      email: FakeDemoAccount.email,
      password: FakeDemoAccount.password,
      fullName: FakeDemoAccount.fullName,
      country: Country.co,
      documentType: DocumentType.cc,
      documentNumber: FakeDemoAccount.documentNumber,
    );
    if (seed == FakeSeed.demo) {
      _seedDemo(demo);
    }
  }

  /// Tasa de comisión: 0,30 % del monto bruto.
  static final Decimal commissionRate = Decimal.parse('0.003');

  static final Decimal _hundred = Decimal.fromInt(100);

  static final Map<Currency, Decimal> _minCommission = <Currency, Decimal>{
    Currency.cop: Decimal.fromInt(5000),
    Currency.mxn: Decimal.fromInt(25),
    Currency.pen: Decimal.fromInt(5),
    Currency.usd: Decimal.fromInt(1),
  };

  /// Tipos de cambio simulados, expresados en COP por unidad.
  static final Map<Currency, Decimal> _copPerUnit = <Currency, Decimal>{
    Currency.cop: Decimal.one,
    Currency.mxn: Decimal.fromInt(215),
    Currency.pen: Decimal.fromInt(1090),
    Currency.usd: Decimal.fromInt(4050),
  };

  /// Monedas de las cuentas de la fase 1.
  static const List<Currency> accountCurrencies = <Currency>[
    Currency.cop,
    Currency.mxn,
    Currency.pen,
  ];

  /// Reloj del backend.
  final Clock clock;

  /// Si los precios oscilan con el reloj.
  final bool liveTicks;

  final Map<String, FakeUser> _users = <String, FakeUser>{};
  final Map<String, String> _accessTokens = <String, String>{};
  final Map<String, String> _refreshTokens = <String, String>{};
  final Map<String, Map<Currency, Decimal>> _balances =
      <String, Map<Currency, Decimal>>{};
  final Map<String, Map<String, FakePosition>> _positions =
      <String, Map<String, FakePosition>>{};
  final Map<String, List<Map<String, Object?>>> _orders =
      <String, List<Map<String, Object?>>>{};
  final Map<String, List<Map<String, Object?>>> _transactions =
      <String, List<Map<String, Object?>>>{};
  int _sequence = 0;

  /// Convierte centavos enteros en un decimal exacto.
  static Decimal centsToDecimal(int cents) => Decimal.fromInt(cents).shift(-2);

  /// Instante en el formato del contrato (`2026-11-18T14:42:00Z`).
  static String iso(DateTime instant) =>
      '${instant.toUtc().toIso8601String().split('.').first}Z';

  /// Monto como string decimal con 2 decimales.
  static String money(Decimal value) => value.toStringAsFixed(2);

  /// Porcentaje de [part] sobre [whole], con 2 decimales.
  static Decimal percent(Decimal part, Decimal whole) => whole == Decimal.zero
      ? Decimal.zero
      : (part * _hundred / whole)
            .toDecimal(scaleOnInfinitePrecision: 8)
            .round(scale: 2);

  /// Órdenes de [userId], de la más nueva a la más vieja.
  List<Map<String, Object?>> ordersOf(String userId) =>
      _orders[userId] ?? <Map<String, Object?>>[];

  /// Movimientos de [userId], del más nuevo al más viejo.
  List<Map<String, Object?>> transactionsOf(String userId) =>
      _transactions[userId] ?? <Map<String, Object?>>[];

  /// Registra un usuario con sus tres cuentas en cero.
  FakeUser addUser({
    required String email,
    required String password,
    required String fullName,
    required Country country,
    required DocumentType documentType,
    required String documentNumber,
  }) {
    final FakeUser user = FakeUser(
      id: _nextId('usr_'),
      email: email,
      password: password,
      fullName: fullName,
      country: country,
      documentType: documentType,
      documentNumber: documentNumber,
    );
    _users[user.id] = user;
    _balances[user.id] = <Currency, Decimal>{
      for (final Currency currency in accountCurrencies) currency: Decimal.zero,
    };
    _positions[user.id] = <String, FakePosition>{};
    _orders[user.id] = <Map<String, Object?>>[];
    _transactions[user.id] = <Map<String, Object?>>[];
    return user;
  }

  /// Saldo disponible de [userId] en [currency].
  Decimal availableOf(String userId, Currency currency) =>
      _balances[userId]?[currency] ?? Decimal.zero;

  /// Cuentas de [userId] con la forma del contrato.
  List<Map<String, Object?>> accountsJson(String userId) =>
      <Map<String, Object?>>[
        for (final Currency currency in accountCurrencies)
          <String, Object?>{
            'id': 'acc_${userId}_${currency.code}',
            'currency': currency.code,
            'available': money(availableOf(userId, currency)),
            'reserved': money(Decimal.zero),
          },
      ];

  /// Comisión de una orden por [gross] en [currency].
  Decimal commission(Currency currency, Decimal gross) {
    final Decimal byRate = (gross * commissionRate).round(scale: 2);
    final Decimal minimum = _minCommission[currency] ?? Decimal.zero;
    return byRate > minimum ? byRate : minimum;
  }

  /// Convierte [amount] de [from] a [to] con los tipos de cambio simulados.
  Decimal convert(Decimal amount, Currency from, Currency to) =>
      from == to ? amount : (amount * fxRate(from, to)).round(scale: 2);

  /// Emite un par nuevo de tokens para [userId].
  Map<String, Object?> createSession(String userId) {
    final String access = _nextId('fake-access-');
    final String refresh = _nextId('fake-refresh-');
    _accessTokens[access] = userId;
    _refreshTokens[refresh] = userId;
    return <String, Object?>{
      'access_token': access,
      'refresh_token': refresh,
      'token_type': 'bearer',
      'expires_in': 900,
    };
  }

  /// Resumen del dashboard de [user].
  Map<String, Object?> dashboardJson(FakeUser user) {
    final List<Map<String, Object?>> instruments = <Map<String, Object?>>[
      for (final FakeInstrument instrument in fakeInstruments)
        instrumentJson(instrument),
    ];
    Decimal pctOf(Map<String, Object?> json) =>
        Decimal.parse(json['change_pct']! as String);
    final List<Map<String, Object?>> gainers =
        instruments
            .where((Map<String, Object?> json) => pctOf(json) > Decimal.zero)
            .toList()
          ..sort(
            (Map<String, Object?> a, Map<String, Object?> b) =>
                pctOf(b).compareTo(pctOf(a)),
          );
    final List<Map<String, Object?>> losers =
        instruments
            .where((Map<String, Object?> json) => pctOf(json) < Decimal.zero)
            .toList()
          ..sort(
            (Map<String, Object?> a, Map<String, Object?> b) =>
                pctOf(a).compareTo(pctOf(b)),
          );
    final Map<String, Object?> summary = portfolioJson(user)
      ..remove('positions')
      ..remove('fx_rates_used');
    return <String, Object?>{
      'portfolio_summary': summary,
      'top_movers': <String, Object?>{
        'gainers': gainers.take(3).toList(),
        'losers': losers.take(3).toList(),
      },
      'recent_transactions': transactionsOf(user.id).take(5).toList(),
    };
  }

  /// Acredita un depósito virtual y devuelve su `transaction`.
  Map<String, Object?> deposit(
    String userId,
    Currency currency,
    Decimal amount, {
    DateTime? at,
  }) {
    _balances[userId]![currency] = availableOf(userId, currency) + amount;
    return _addTransaction(
      userId,
      type: 'DEPOSIT',
      amount: amount,
      currency: currency,
      description: 'Depósito virtual',
      at: at,
    );
  }

  /// Ejecuta una orden a mercado a [priceCents] y devuelve su `order`.
  ///
  /// Registra además el movimiento de compra o venta (por el bruto) y el de
  /// la comisión. No valida saldo ni posición: eso lo hace quien la llama.
  Map<String, Object?> fill(
    String userId,
    FakeInstrument instrument, {
    required String side,
    required int quantity,
    required int priceCents,
    DateTime? at,
  }) {
    final DateTime when = at ?? clock.nowUtc();
    final bool isBuy = side == 'BUY';
    final Currency currency = instrument.currency;
    final Decimal price = centsToDecimal(priceCents);
    final Decimal gross = price * Decimal.fromInt(quantity);
    final Decimal fee = commission(currency, gross);
    final Decimal total = isBuy ? gross + fee : gross - fee;
    final Map<String, FakePosition> positions = _positions[userId]!;
    final FakePosition? held = positions[instrument.id];

    _balances[userId]![currency] =
        availableOf(userId, currency) + (isBuy ? -total : total);
    if (isBuy) {
      final int newQuantity = (held?.quantity ?? 0) + quantity;
      final Decimal cost =
          (held?.avgCost ?? Decimal.zero) *
              Decimal.fromInt(held?.quantity ?? 0) +
          gross;
      positions[instrument.id] = FakePosition(
        quantity: newQuantity,
        avgCost: (cost / Decimal.fromInt(newQuantity))
            .toDecimal(scaleOnInfinitePrecision: 8)
            .round(scale: 4),
      );
    } else if (held != null) {
      held.quantity -= quantity;
      if (held.quantity <= 0) {
        positions.remove(instrument.id);
      }
    }

    final Map<String, Object?> order = <String, Object?>{
      'id': _nextId('ord_'),
      'instrument_id': instrument.id,
      'side': side,
      'type': 'MARKET',
      'quantity': quantity,
      'status': 'FILLED',
      'executed_price': money(price),
      'gross': money(gross),
      'commission': money(fee),
      'total': money(total),
      'currency': currency.code,
      'reject_code': null,
      'created_at': iso(when),
      'filled_at': iso(when),
    };
    _orders[userId]!.insert(0, order);
    _addTransaction(
      userId,
      type: side,
      amount: isBuy ? -gross : gross,
      currency: currency,
      description:
          '${isBuy ? 'Compra' : 'Venta'} $quantity ${instrument.ticker}',
      orderId: order['id']! as String,
      at: when,
    );
    _addTransaction(
      userId,
      type: 'FEE',
      amount: -fee,
      currency: currency,
      description: 'Comisión ${instrument.ticker}',
      orderId: order['id']! as String,
      at: when,
    );
    return order;
  }

  /// Tipo de cambio simulado de [from] a [to].
  Decimal fxRate(Currency from, Currency to) =>
      (_copPerUnit[from]! / _copPerUnit[to]!)
          .toDecimal(scaleOnInfinitePrecision: 10)
          .round(scale: 8);

  /// `instrument` con la forma del contrato y el precio vigente.
  Map<String, Object?> instrumentJson(FakeInstrument instrument) {
    final Decimal last = centsToDecimal(priceOf(instrument));
    final Decimal previous = centsToDecimal(instrument.prevCloseCents);
    final Decimal change = last - previous;
    return <String, Object?>{
      'id': instrument.id,
      'ticker': instrument.ticker,
      'name': instrument.name,
      'country': instrument.country.code,
      'type': instrument.type,
      'currency': instrument.currency.code,
      'last_price': money(last),
      'change': money(change),
      'change_pct': money(percent(change, previous)),
      'updated_at': iso(clock.nowUtc()),
    };
  }

  /// Invalida la sesión dueña de [refreshToken].
  void logout(String refreshToken) {
    final String? userId = _refreshTokens.remove(refreshToken);
    if (userId != null) {
      _accessTokens.removeWhere((String _, String owner) => owner == userId);
    }
  }

  /// `/me` de [user].
  Map<String, Object?> meJson(FakeUser user) => <String, Object?>{
    'id': user.id,
    'email': user.email,
    'full_name': user.fullName,
    'country': user.country.code,
    'base_currency': user.country.currency.code,
    'document_type': user.documentType.code,
    'document_last4': user.documentNumber.length <= 4
        ? user.documentNumber
        : user.documentNumber.substring(user.documentNumber.length - 4),
  };

  /// Portafolio de [user], totalizado en su moneda base.
  Map<String, Object?> portfolioJson(FakeUser user) {
    final Currency base = user.country.currency;
    final Set<Currency> converted = <Currency>{};
    Decimal toBase(Decimal amount, Currency from) {
      if (from != base && amount != Decimal.zero) {
        converted.add(from);
      }
      return convert(amount, from, base);
    }

    Decimal cash = Decimal.zero;
    for (final Currency currency in accountCurrencies) {
      cash += toBase(availableOf(user.id, currency), currency);
    }

    Decimal invested = Decimal.zero;
    Decimal dayChange = Decimal.zero;
    final Map<String, Decimal> byType = <String, Decimal>{};
    final List<Map<String, Object?>> positions = <Map<String, Object?>>[];
    final Map<String, FakePosition> held = _positions[user.id]!;
    for (final FakeInstrument instrument in fakeInstruments) {
      final FakePosition? position = held[instrument.id];
      if (position == null) {
        continue;
      }
      final Decimal quantity = Decimal.fromInt(position.quantity);
      final Decimal last = centsToDecimal(priceOf(instrument));
      final Decimal marketValue = last * quantity;
      final Decimal cost = position.avgCost * quantity;
      final Decimal pnl = marketValue - cost;
      final Decimal valueInBase = toBase(marketValue, instrument.currency);
      invested += valueInBase;
      dayChange += toBase(
        (last - centsToDecimal(instrument.prevCloseCents)) * quantity,
        instrument.currency,
      );
      byType[instrument.type] =
          (byType[instrument.type] ?? Decimal.zero) + valueInBase;
      positions.add(<String, Object?>{
        'instrument': instrumentJson(instrument),
        'quantity': position.quantity,
        'avg_cost': money(position.avgCost),
        'market_value': money(marketValue),
        'unrealized_pnl': money(pnl),
        'unrealized_pnl_pct': money(percent(pnl, cost)),
        'currency': instrument.currency.code,
      });
    }

    final Decimal total = cash + invested;
    final Map<String, Decimal> slices = <String, Decimal>{
      ...byType,
      'CASH': cash,
    };
    return <String, Object?>{
      'base_currency': base.code,
      'total_value': money(total),
      'cash_value': money(cash),
      'invested_value': money(invested),
      'day_change': money(dayChange),
      'day_change_pct': money(percent(dayChange, total - dayChange)),
      'positions': positions,
      'allocation': <Map<String, Object?>>[
        for (final MapEntry<String, Decimal> slice in slices.entries)
          if (slice.value > Decimal.zero)
            <String, Object?>{
              'type': slice.key,
              'value': money(slice.value),
              'pct': money(percent(slice.value, total)),
            },
      ],
      'fx_rates_used': <Map<String, Object?>>[
        for (final Currency currency in accountCurrencies)
          if (converted.contains(currency))
            <String, Object?>{
              'from': currency.code,
              'to': base.code,
              'rate': fxRate(currency, base).toString(),
              'as_of': iso(clock.nowUtc()),
            },
      ],
    };
  }

  /// Cantidad que [userId] tiene de [instrumentId].
  int positionOf(String userId, String instrumentId) =>
      _positions[userId]?[instrumentId]?.quantity ?? 0;

  /// Precio vigente de [instrument], en centavos.
  int priceOf(FakeInstrument instrument) =>
      FakePrices.currentCents(instrument, clock.nowUtc(), live: liveTicks);

  /// Cotiza una orden a mercado, sin ejecutarla.
  FakeQuote quote(
    String userId,
    FakeInstrument instrument, {
    required String side,
    required int quantity,
  }) {
    final Decimal price = centsToDecimal(priceOf(instrument));
    final Decimal gross = price * Decimal.fromInt(quantity);
    final Decimal fee = commission(instrument.currency, gross);
    final bool isBuy = side == 'BUY';
    final Decimal total = isBuy ? gross + fee : gross - fee;
    final Decimal available = availableOf(userId, instrument.currency);
    return (
      price: price,
      gross: gross,
      commission: fee,
      total: total,
      availableAfter: isBuy ? available - total : available + total,
    );
  }

  /// Rota el refresh token: devuelve un par nuevo e invalida el anterior.
  Map<String, Object?> refresh(String refreshToken) {
    final String? userId = _refreshTokens.remove(refreshToken);
    if (userId == null) {
      throw const ApiException(
        status: 401,
        code: ApiErrorCodes.authRefreshInvalid,
      );
    }
    _accessTokens.removeWhere((String _, String owner) => owner == userId);
    return createSession(userId);
  }

  /// Registra una orden rechazada (solo la usa el seed).
  Map<String, Object?> reject(
    String userId,
    FakeInstrument instrument, {
    required String side,
    required int quantity,
    required String rejectCode,
    required DateTime at,
  }) {
    final Map<String, Object?> order = <String, Object?>{
      'id': _nextId('ord_'),
      'instrument_id': instrument.id,
      'side': side,
      'type': 'MARKET',
      'quantity': quantity,
      'status': 'REJECTED',
      'executed_price': null,
      'gross': null,
      'commission': null,
      'total': null,
      'currency': instrument.currency.code,
      'reject_code': rejectCode,
      'created_at': iso(at),
      'filled_at': null,
    };
    _orders[userId]!.insert(0, order);
    return order;
  }

  /// Usuario dueño de [accessToken], o `null` si el token no es válido.
  FakeUser? userByAccessToken(String accessToken) =>
      _users[_accessTokens[accessToken]];

  /// Usuario con ese documento, o `null`.
  FakeUser? userByDocument(DocumentType type, String number) {
    for (final FakeUser user in _users.values) {
      if (user.documentType == type && user.documentNumber == number) {
        return user;
      }
    }
    return null;
  }

  /// Usuario con ese email, o `null`.
  FakeUser? userByEmail(String email) {
    for (final FakeUser user in _users.values) {
      if (user.email == email) {
        return user;
      }
    }
    return null;
  }

  Map<String, Object?> _addTransaction(
    String userId, {
    required String type,
    required Decimal amount,
    required Currency currency,
    required String description,
    String? orderId,
    DateTime? at,
  }) {
    final Map<String, Object?> transaction = <String, Object?>{
      'id': _nextId('txn_'),
      'type': type,
      'amount': money(amount),
      'currency': currency.code,
      'description': description,
      'order_id': orderId,
      'created_at': iso(at ?? clock.nowUtc()),
    };
    _transactions[userId]!.insert(0, transaction);
    return transaction;
  }

  String _nextId(String prefix) {
    _sequence++;
    return '$prefix${_sequence.toString().padLeft(6, '0')}';
  }

  void _seedDemo(FakeUser user) {
    final DateTime now = clock.nowUtc();
    final DateTime funded = now.subtract(const Duration(days: 3));
    final DateTime bought = now.subtract(const Duration(days: 2));
    FakeInstrument byId(String id) => fakeInstruments.firstWhere(
      (FakeInstrument instrument) => instrument.id == id,
    );

    deposit(user.id, Currency.cop, Decimal.fromInt(8000000), at: funded);
    deposit(user.id, Currency.mxn, Decimal.fromInt(25000), at: funded);
    deposit(user.id, Currency.pen, Decimal.fromInt(6500), at: funded);
    fill(
      user.id,
      byId('ECOPETROL-CO'),
      side: 'BUY',
      quantity: 120,
      priceCents: 221050,
      at: bought,
    );
    fill(
      user.id,
      byId('ICOLCAP-CO'),
      side: 'BUY',
      quantity: 20,
      priceCents: 1380000,
      at: bought.add(const Duration(minutes: 5)),
    );
    fill(
      user.id,
      byId('WALMEX-MX'),
      side: 'BUY',
      quantity: 50,
      priceCents: 5710,
      at: bought.add(const Duration(minutes: 12)),
    );
    fill(
      user.id,
      byId('BAP-PE'),
      side: 'BUY',
      quantity: 5,
      priceCents: 18500,
      at: bought.add(const Duration(minutes: 20)),
    );
    reject(
      user.id,
      byId('ECOPETROL-CO'),
      side: 'SELL',
      quantity: 500,
      rejectCode: ApiErrorCodes.insufficientPosition,
      at: now.subtract(const Duration(days: 1)),
    );
  }
}
