import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

import '../enums/instrument_type.dart';

/// Filtros de la lista de instrumentos.
class InstrumentFilter extends Equatable {
  /// Crea los filtros.
  const InstrumentFilter({this.country, this.type, this.query = ''});

  static const Object _unset = Object();

  /// País; `null` es "Todos".
  final Country? country;

  /// Tipo; `null` es "Todos".
  final InstrumentType? type;

  /// Texto buscado por ticker o nombre.
  final String query;

  /// `true` si no hay ningún filtro activo.
  bool get isEmpty => country == null && type == null && query.trim().isEmpty;

  /// Copia los filtros. `country: null` o `type: null` los quita.
  InstrumentFilter copyWith({
    Object? country = _unset,
    Object? type = _unset,
    String? query,
  }) => InstrumentFilter(
    country: identical(country, _unset) ? this.country : country as Country?,
    type: identical(type, _unset) ? this.type : type as InstrumentType?,
    query: query ?? this.query,
  );

  @override
  List<Object?> get props => <Object?>[country, type, query];
}
