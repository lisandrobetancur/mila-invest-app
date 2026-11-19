import 'package:decimal/decimal.dart';
import 'package:market_typing/market_typing.dart';
import 'package:orders_typing/orders_typing.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:typing/typing.dart';
import 'package:wallet_typing/wallet_typing.dart';

final DateTime fixedNow = DateTime.utc(2026, 11, 18, 14, 42);

Money cop(String value) => Money.parse(value, Currency.cop);

Instrument instrument({String price = '2385.00'}) => Instrument(
  id: 'ECOPETROL-CO',
  ticker: 'ECOPETROL',
  name: 'Ecopetrol S.A.',
  country: Country.co,
  type: InstrumentType.stock,
  lastPrice: cop(price),
  change: cop('35'),
  changePercent: Decimal.parse('1.49'),
  updatedAt: fixedNow,
);

InstrumentDetail detail() => InstrumentDetail(
  instrument: instrument(),
  open: cop('2360'),
  high: cop('2400'),
  low: cop('2350'),
  prevClose: cop('2350'),
  volume: 1000,
  description: 'Petrolera.',
);

List<Account> accounts({String cop = '100000'}) => <Account>[
  Account(
    id: 'acc_cop',
    currency: Currency.cop,
    available: Money.parse(cop, Currency.cop),
    reserved: Money.zero(Currency.cop),
  ),
];

Portfolio portfolio({int quantity = 120}) => Portfolio(
  summary: PortfolioSummary(
    baseCurrency: Currency.cop,
    totalValue: cop('1000000'),
    cashValue: cop('700000'),
    investedValue: cop('300000'),
    dayChange: cop('0'),
    dayChangePercent: Decimal.zero,
    allocation: const <AllocationEntry>[],
  ),
  positions: <Position>[
    if (quantity > 0)
      Position(
        instrument: instrument(),
        quantity: quantity,
        avgCost: cop('2210.50'),
        marketValue: cop('286200'),
        unrealizedPnl: cop('20940'),
        unrealizedPnlPercent: Decimal.parse('7.89'),
      ),
  ],
  fxRates: const <FxRate>[],
);

CountryMarket market({bool open = true}) => CountryMarket(
  country: Country.co,
  status: open ? MarketSessionStatus.open : MarketSessionStatus.closed,
  opensAt: DateTime.utc(2026, 11, 19, 14, 30),
  closesAt: DateTime.utc(2026, 11, 18, 21),
);

OrderPreview preview({String total = '28850', String after = '71150'}) =>
    OrderPreview(
      estimatedPrice: cop('2385'),
      gross: cop('23850'),
      commission: cop('5000'),
      total: cop(total),
      availableAfter: cop(after),
    );

Order filledOrder({String price = '2386', String id = 'ord_1'}) => Order(
  id: id,
  instrumentId: 'ECOPETROL-CO',
  side: OrderSide.buy,
  type: OrderType.market,
  quantity: 10,
  status: OrderStatus.filled,
  currency: Currency.cop,
  createdAt: fixedNow,
  executedPrice: cop(price),
  gross: cop('23860'),
  commission: cop('5000'),
  total: cop('28860'),
  filledAt: fixedNow,
);

Order rejectedOrder({String id = 'ord_2'}) => Order(
  id: id,
  instrumentId: 'ECOPETROL-CO',
  side: OrderSide.sell,
  type: OrderType.market,
  quantity: 500,
  status: OrderStatus.rejected,
  currency: Currency.cop,
  createdAt: fixedNow,
  rejectCode: OrdersErrorCode.insufficientPosition,
);
