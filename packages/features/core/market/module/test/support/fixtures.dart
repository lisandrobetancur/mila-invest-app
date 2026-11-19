import 'package:decimal/decimal.dart';
import 'package:market_typing/market_typing.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:typing/typing.dart';

/// Instante fijo de los tests.
final DateTime fixedNow = DateTime.utc(2026, 11, 18, 14, 42);

Money cop(String value) => Money.parse(value, Currency.cop);

Instrument instrument({
  String id = 'ECOPETROL-CO',
  String ticker = 'ECOPETROL',
  String price = '2385.00',
  String changePct = '1.49',
  Country country = Country.co,
}) => Instrument(
  id: id,
  ticker: ticker,
  name: '$ticker S.A.',
  country: country,
  type: InstrumentType.stock,
  lastPrice: Money.parse(price, country.currency),
  change: Money.parse('35.00', country.currency),
  changePercent: Decimal.parse(changePct),
  updatedAt: fixedNow,
);

InstrumentDetail detail({
  String price = '2385.00',
  String id = 'ECOPETROL-CO',
}) => InstrumentDetail(
  instrument: instrument(price: price, id: id),
  open: cop('2360'),
  high: cop('2400'),
  low: cop('2350'),
  prevClose: cop('2350'),
  volume: 12450300,
  description: 'Petrolera integrada.',
);

PriceSeries series([PriceRange range = PriceRange.day]) => PriceSeries(
  range: range,
  currency: Currency.cop,
  points: <PricePoint>[
    PricePoint(
      time: fixedNow.subtract(const Duration(hours: 2)),
      price: Decimal.parse('2210'),
    ),
    PricePoint(time: fixedNow, price: Decimal.parse('2385')),
  ],
);

CountryMarket market({bool open = true, Country country = Country.co}) =>
    CountryMarket(
      country: country,
      status: open ? MarketSessionStatus.open : MarketSessionStatus.closed,
      opensAt: DateTime.utc(2026, 11, 19, 14, 30),
      closesAt: DateTime.utc(2026, 11, 18, 21),
    );

Portfolio portfolio({int quantity = 120}) => Portfolio(
  summary: PortfolioSummary(
    baseCurrency: Currency.cop,
    totalValue: cop('1000000'),
    cashValue: cop('713800'),
    investedValue: cop('286200'),
    dayChange: cop('4200'),
    dayChangePercent: Decimal.parse('0.42'),
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
