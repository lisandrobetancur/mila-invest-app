import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

import 'instrument.dart';

/// Instrumento con las estadísticas del día.
class InstrumentDetail extends Equatable {
  /// Crea el detalle.
  const InstrumentDetail({
    required this.instrument,
    required this.open,
    required this.high,
    required this.low,
    required this.prevClose,
    required this.volume,
    required this.description,
  });

  /// Instrumento.
  final Instrument instrument;

  /// Apertura.
  final Money open;

  /// Máximo del día.
  final Money high;

  /// Mínimo del día.
  final Money low;

  /// Cierre anterior.
  final Money prevClose;

  /// Volumen del día.
  final int volume;

  /// Descripción del emisor.
  final String description;

  @override
  List<Object?> get props => <Object?>[
    instrument,
    open,
    high,
    low,
    prevClose,
    volume,
    description,
  ];
}
