import 'package:market_typing/market_typing.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';

/// Un país de `GET /meta/countries`, con el estado de su mercado.
class CountryMarketDto {
  /// Crea el DTO.
  const CountryMarketDto({
    required this.country,
    required this.status,
    required this.opensAt,
    required this.closesAt,
  });

  /// Lee el DTO. Lanza [FormatException] si el JSON no cumple el contrato.
  factory CountryMarketDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json);
    final JsonReader market = reader.object('market');
    return CountryMarketDto(
      country: reader.enumValue<Country>('code', Country.tryFromCode),
      status: market.enumValue<MarketSessionStatus>(
        'status',
        MarketSessionStatus.tryFromApiCode,
      ),
      opensAt: market.dateTime('opens_at'),
      closesAt: market.dateTime('closes_at'),
    );
  }

  /// País.
  final Country country;

  /// Estado.
  final MarketSessionStatus status;

  /// Apertura.
  final DateTime opensAt;

  /// Cierre.
  final DateTime closesAt;

  /// Convierte a dominio.
  CountryMarket toDomain() => CountryMarket(
    country: country,
    status: status,
    opensAt: opensAt,
    closesAt: closesAt,
  );
}
