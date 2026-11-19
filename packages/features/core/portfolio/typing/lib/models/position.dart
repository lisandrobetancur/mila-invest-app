import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:market_typing/market_typing.dart';
import 'package:typing/typing.dart';

/// Posición en un instrumento.
class Position extends Equatable {
  /// Crea una posición.
  const Position({
    required this.instrument,
    required this.quantity,
    required this.avgCost,
    required this.marketValue,
    required this.unrealizedPnl,
    required this.unrealizedPnlPercent,
  });

  /// Instrumento.
  final Instrument instrument;

  /// Cantidad en posición.
  final int quantity;

  /// Costo promedio por unidad.
  final Money avgCost;

  /// Valor de mercado de la posición.
  final Money marketValue;

  /// Ganancia o pérdida si se vendiera hoy.
  final Money unrealizedPnl;

  /// Ganancia o pérdida no realizada, en porcentaje.
  final Decimal unrealizedPnlPercent;

  /// Moneda de la posición.
  Currency get currency => marketValue.currency;

  @override
  List<Object?> get props => <Object?>[
    instrument,
    quantity,
    avgCost,
    marketValue,
    unrealizedPnl,
    unrealizedPnlPercent,
  ];
}
