import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

import '../enums/price_range.dart';

/// Un punto de una serie de precios.
class PricePoint extends Equatable {
  /// Crea un punto.
  const PricePoint({required this.time, required this.price});

  /// Instante, en UTC.
  final DateTime time;

  /// Precio.
  final Decimal price;

  @override
  List<Object?> get props => <Object?>[time, price];
}

/// Serie de precios de un rango.
class PriceSeries extends Equatable {
  /// Crea una serie.
  const PriceSeries({
    required this.range,
    required this.currency,
    required this.points,
  });

  /// Rango.
  final PriceRange range;

  /// Moneda de los precios.
  final Currency currency;

  /// Puntos, en orden cronológico.
  final List<PricePoint> points;

  /// `true` si hay al menos dos puntos para dibujar una línea.
  bool get isDrawable => points.length >= 2;

  /// Variación porcentual entre el primer y el último punto, con 1 decimal.
  Decimal get changePercent {
    if (!isDrawable || points.first.price == Decimal.zero) {
      return Decimal.zero;
    }
    return ((points.last.price - points.first.price) *
            Decimal.fromInt(100) /
            points.first.price)
        .toDecimal(scaleOnInfinitePrecision: 6)
        .round(scale: 1);
  }

  @override
  List<Object?> get props => <Object?>[range, currency, points];
}
