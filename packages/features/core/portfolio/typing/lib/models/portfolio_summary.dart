import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

import 'allocation_entry.dart';

/// Totales del portafolio en moneda base, sin el detalle de posiciones.
///
/// Es lo que muestra el dashboard.
class PortfolioSummary extends Equatable {
  /// Crea el resumen.
  const PortfolioSummary({
    required this.baseCurrency,
    required this.totalValue,
    required this.cashValue,
    required this.investedValue,
    required this.dayChange,
    required this.dayChangePercent,
    required this.allocation,
  });

  /// Moneda en la que se totaliza.
  final Currency baseCurrency;

  /// Valor total: efectivo + invertido.
  final Money totalValue;

  /// Efectivo, convertido a moneda base.
  final Money cashValue;

  /// Valor de mercado de las posiciones, en moneda base.
  final Money investedValue;

  /// Variación del día.
  final Money dayChange;

  /// Variación del día, en porcentaje.
  final Decimal dayChangePercent;

  /// Distribución por tipo de producto.
  final List<AllocationEntry> allocation;

  /// `true` si el usuario no tiene ni efectivo ni inversiones.
  bool get isEmpty => totalValue.isZero;

  /// `true` si el usuario no tiene inversiones.
  bool get hasNoInvestments => investedValue.isZero;

  @override
  List<Object?> get props => <Object?>[
    baseCurrency,
    totalValue,
    cashValue,
    investedValue,
    dayChange,
    dayChangePercent,
    allocation,
  ];
}
