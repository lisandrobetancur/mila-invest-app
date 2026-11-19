import 'package:decimal/decimal.dart';
import 'package:market_typing/market_typing.dart';
import 'package:network/network.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:typing/typing.dart';

/// Respuesta de `GET /portfolio`, ya convertida a dominio con lectura
/// estricta.
///
/// El `instrument` anidado de cada posición se lee aquí mismo: el DTO de
/// instrumento de market es privado de su módulo.
class PortfolioDto {
  /// Crea el DTO.
  const PortfolioDto({
    required this.summary,
    required this.positions,
    required this.fxRates,
  });

  /// Lee el DTO. Lanza [FormatException] si el JSON no cumple el contrato.
  factory PortfolioDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json);
    return PortfolioDto(
      summary: summaryFrom(reader),
      positions: <Position>[
        for (final JsonReader position in reader.objects('positions'))
          _position(position),
      ],
      fxRates: reader.has('fx_rates_used')
          ? <FxRate>[
              for (final JsonReader rate in reader.objects('fx_rates_used'))
                FxRate(
                  from: rate.currency('from'),
                  to: rate.currency('to'),
                  rate: rate.decimal('rate'),
                  asOf: rate.dateTime('as_of'),
                ),
            ]
          : const <FxRate>[],
    );
  }

  /// Totales.
  final PortfolioSummary summary;

  /// Posiciones.
  final List<Position> positions;

  /// Tipos de cambio usados.
  final List<FxRate> fxRates;

  /// Lee los totales (los comparte `GET /dashboard/summary`).
  static PortfolioSummary summaryFrom(JsonReader reader) {
    final Currency base = reader.currency('base_currency');
    return PortfolioSummary(
      baseCurrency: base,
      totalValue: reader.money('total_value', base),
      cashValue: reader.money('cash_value', base),
      investedValue: reader.money('invested_value', base),
      dayChange: reader.money('day_change', base),
      dayChangePercent: reader.decimal('day_change_pct'),
      allocation: <AllocationEntry>[
        for (final JsonReader slice in reader.objects('allocation'))
          AllocationEntry(
            type: AllocationType.fromApiCode(slice.string('type')),
            value: slice.money('value', base),
            percent: slice.decimal('pct'),
          ),
      ],
    );
  }

  /// Convierte a dominio.
  Portfolio toDomain() =>
      Portfolio(summary: summary, positions: positions, fxRates: fxRates);

  static Instrument _instrument(JsonReader reader) {
    final Currency currency = reader.currency('currency');
    return Instrument(
      id: reader.string('id'),
      ticker: reader.string('ticker'),
      name: reader.string('name'),
      country: reader.enumValue<Country>('country', Country.tryFromCode),
      type: reader.enumValue<InstrumentType>(
        'type',
        InstrumentType.tryFromApiCode,
      ),
      lastPrice: reader.money('last_price', currency),
      change: reader.money('change', currency),
      changePercent: reader.decimal('change_pct'),
      updatedAt: reader.dateTime('updated_at'),
    );
  }

  static Position _position(JsonReader reader) {
    final Currency currency = reader.currency('currency');
    final Decimal pnlPct = reader.decimal('unrealized_pnl_pct');
    return Position(
      instrument: _instrument(reader.object('instrument')),
      quantity: reader.integer('quantity'),
      avgCost: reader.money('avg_cost', currency),
      marketValue: reader.money('market_value', currency),
      unrealizedPnl: reader.money('unrealized_pnl', currency),
      unrealizedPnlPercent: pnlPct,
    );
  }
}
