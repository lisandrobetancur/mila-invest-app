import 'package:decimal/decimal.dart';
import 'package:market_typing/market_typing.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';

/// `instrument` del contrato.
class InstrumentDto {
  /// Crea el DTO.
  const InstrumentDto({
    required this.id,
    required this.ticker,
    required this.name,
    required this.country,
    required this.type,
    required this.currency,
    required this.lastPrice,
    required this.change,
    required this.changePercent,
    required this.updatedAt,
  });

  /// Lee el DTO. Lanza [FormatException] si el JSON no cumple el contrato.
  factory InstrumentDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json);
    final Currency currency = reader.currency('currency');
    return InstrumentDto(
      id: reader.string('id'),
      ticker: reader.string('ticker'),
      name: reader.string('name'),
      country: reader.enumValue<Country>('country', Country.tryFromCode),
      type: reader.enumValue<InstrumentType>(
        'type',
        InstrumentType.tryFromApiCode,
      ),
      currency: currency,
      lastPrice: reader.money('last_price', currency),
      change: reader.money('change', currency),
      changePercent: reader.decimal('change_pct'),
      updatedAt: reader.dateTime('updated_at'),
    );
  }

  /// Id.
  final String id;

  /// Ticker.
  final String ticker;

  /// Nombre.
  final String name;

  /// País.
  final Country country;

  /// Tipo.
  final InstrumentType type;

  /// Moneda.
  final Currency currency;

  /// Último precio.
  final Money lastPrice;

  /// Variación absoluta.
  final Money change;

  /// Variación porcentual.
  final Decimal changePercent;

  /// Instante del precio.
  final DateTime updatedAt;

  /// Convierte a dominio.
  Instrument toDomain() => Instrument(
    id: id,
    ticker: ticker,
    name: name,
    country: country,
    type: type,
    lastPrice: lastPrice,
    change: change,
    changePercent: changePercent,
    updatedAt: updatedAt,
  );
}
