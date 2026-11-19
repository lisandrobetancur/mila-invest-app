import 'package:market_typing/market_typing.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';

/// Respuesta de `GET /instruments/{id}/prices`.
class PriceSeriesDto {
  /// Crea el DTO.
  const PriceSeriesDto({
    required this.range,
    required this.currency,
    required this.points,
  });

  /// Lee el DTO. Lanza [FormatException] si el JSON no cumple el contrato.
  factory PriceSeriesDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json);
    return PriceSeriesDto(
      range: reader.enumValue<PriceRange>('range', PriceRange.tryFromApiCode),
      currency: reader.currency('currency'),
      points: <PricePoint>[
        for (final JsonReader point in reader.objects('points'))
          PricePoint(time: point.dateTime('t'), price: point.decimal('price')),
      ],
    );
  }

  /// Rango.
  final PriceRange range;

  /// Moneda.
  final Currency currency;

  /// Puntos.
  final List<PricePoint> points;

  /// Convierte a dominio, con los puntos en orden cronológico.
  PriceSeries toDomain() => PriceSeries(
    range: range,
    currency: currency,
    points: <PricePoint>[...points]
      ..sort((PricePoint a, PricePoint b) => a.time.compareTo(b.time)),
  );
}
