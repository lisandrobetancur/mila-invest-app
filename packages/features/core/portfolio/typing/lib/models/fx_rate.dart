import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

/// Tipo de cambio que el backend usó para totalizar en moneda base.
class FxRate extends Equatable {
  /// Crea el tipo de cambio.
  const FxRate({
    required this.from,
    required this.to,
    required this.rate,
    required this.asOf,
  });

  /// Moneda de origen.
  final Currency from;

  /// Moneda de destino (la base).
  final Currency to;

  /// Unidades de [to] por unidad de [from].
  final Decimal rate;

  /// Instante del tipo de cambio, en UTC.
  final DateTime asOf;

  @override
  List<Object?> get props => <Object?>[from, to, rate, asOf];
}
