import 'package:dashboard_typing/dashboard_typing.dart';
import 'package:market_typing/market_typing.dart';
import 'package:network/network.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:transactions_typing/transactions_typing.dart';
import 'package:typing/typing.dart';

/// Respuesta de `GET /dashboard/summary`, leída con parseo estricto.
///
/// Los DTOs de portfolio, market y transactions son privados de sus
/// módulos, así que el resumen lee aquí sus formas anidadas.
class DashboardSummaryDto {
  /// Crea el DTO.
  const DashboardSummaryDto(this._summary);

  /// Lee el DTO. Lanza [FormatException] si el JSON no cumple el contrato.
  factory DashboardSummaryDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json);
    final JsonReader movers = reader.object('top_movers');
    return DashboardSummaryDto(
      DashboardSummary(
        portfolio: _summaryFrom(reader.object('portfolio_summary')),
        gainers: movers.objects('gainers').map(_instrument).toList(),
        losers: movers.objects('losers').map(_instrument).toList(),
        recentTransactions: reader
            .objects('recent_transactions')
            .map(_transaction)
            .toList(),
      ),
    );
  }

  final DashboardSummary _summary;

  /// Convierte a dominio.
  DashboardSummary toDomain() => _summary;

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

  static PortfolioSummary _summaryFrom(JsonReader reader) {
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

  static Transaction _transaction(JsonReader reader) => Transaction(
    id: reader.string('id'),
    type: TransactionType.fromApiCode(reader.string('type')),
    amount: reader.money('amount', reader.currency('currency')),
    description: reader.string('description'),
    orderId: reader.stringOrNull('order_id'),
    createdAt: reader.dateTime('created_at'),
  );
}
