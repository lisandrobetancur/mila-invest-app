import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

import '../enums/allocation_type.dart';

/// Porción de la distribución del portafolio.
class AllocationEntry extends Equatable {
  /// Crea la porción.
  const AllocationEntry({
    required this.type,
    required this.value,
    required this.percent,
  });

  /// Tipo de producto.
  final AllocationType type;

  /// Valor en moneda base.
  final Money value;

  /// Participación (`62.4` es 62,4 %).
  final Decimal percent;

  @override
  List<Object?> get props => <Object?>[type, value, percent];
}
