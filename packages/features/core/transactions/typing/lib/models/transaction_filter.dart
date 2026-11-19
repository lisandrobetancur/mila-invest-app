import 'package:equatable/equatable.dart';

import '../enums/transaction_range.dart';
import '../enums/transaction_type.dart';

/// Filtros de la lista de movimientos.
class TransactionFilter extends Equatable {
  /// Crea los filtros.
  const TransactionFilter({this.type, this.range = TransactionRange.all});

  static const Object _unset = Object();

  /// Tipo; `null` es "Todos".
  final TransactionType? type;

  /// Rango de fechas.
  final TransactionRange range;

  /// `true` si no hay ningún filtro activo.
  bool get isEmpty => type == null && range == TransactionRange.all;

  /// Copia los filtros. `type: null` lo quita.
  TransactionFilter copyWith({
    Object? type = _unset,
    TransactionRange? range,
  }) => TransactionFilter(
    type: identical(type, _unset) ? this.type : type as TransactionType?,
    range: range ?? this.range,
  );

  @override
  List<Object?> get props => <Object?>[type, range];
}
