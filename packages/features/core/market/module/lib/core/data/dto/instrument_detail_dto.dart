import 'package:market_typing/market_typing.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';

import 'instrument_dto.dart';

/// Respuesta de `GET /instruments/{id}`: `instrument` + estadísticas.
class InstrumentDetailDto {
  /// Crea el DTO.
  const InstrumentDetailDto({
    required this.instrument,
    required this.open,
    required this.high,
    required this.low,
    required this.prevClose,
    required this.volume,
    required this.description,
  });

  /// Lee el DTO. Lanza [FormatException] si el JSON no cumple el contrato.
  factory InstrumentDetailDto.fromJson(Map<String, Object?> json) {
    final InstrumentDto instrument = InstrumentDto.fromJson(json);
    final JsonReader reader = JsonReader(json);
    final Currency currency = instrument.currency;
    return InstrumentDetailDto(
      instrument: instrument,
      open: reader.money('open', currency),
      high: reader.money('high', currency),
      low: reader.money('low', currency),
      prevClose: reader.money('prev_close', currency),
      volume: reader.integer('volume'),
      description: reader.string('description'),
    );
  }

  /// Instrumento.
  final InstrumentDto instrument;

  /// Apertura.
  final Money open;

  /// Máximo.
  final Money high;

  /// Mínimo.
  final Money low;

  /// Cierre anterior.
  final Money prevClose;

  /// Volumen.
  final int volume;

  /// Descripción.
  final String description;

  /// Convierte a dominio.
  InstrumentDetail toDomain() => InstrumentDetail(
    instrument: instrument.toDomain(),
    open: open,
    high: high,
    low: low,
    prevClose: prevClose,
    volume: volume,
    description: description,
  );
}
