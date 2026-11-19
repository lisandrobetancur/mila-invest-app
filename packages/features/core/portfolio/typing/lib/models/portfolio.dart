import 'package:equatable/equatable.dart';

import 'fx_rate.dart';
import 'portfolio_summary.dart';
import 'position.dart';

/// Portafolio completo: totales, posiciones y tipos de cambio usados.
class Portfolio extends Equatable {
  /// Crea el portafolio.
  const Portfolio({
    required this.summary,
    required this.positions,
    required this.fxRates,
  });

  /// Totales en moneda base.
  final PortfolioSummary summary;

  /// Posiciones, en el orden de la API.
  final List<Position> positions;

  /// Tipos de cambio usados para totalizar.
  final List<FxRate> fxRates;

  /// `true` si no hay posiciones.
  bool get hasNoPositions => positions.isEmpty;

  /// Posición en [instrumentId], o `null` si no hay.
  Position? positionOf(String instrumentId) {
    for (final Position position in positions) {
      if (position.instrument.id == instrumentId) {
        return position;
      }
    }
    return null;
  }

  /// Cantidad en posición de [instrumentId]; cero si no hay.
  int quantityOf(String instrumentId) =>
      positionOf(instrumentId)?.quantity ?? 0;

  @override
  List<Object?> get props => <Object?>[summary, positions, fxRates];
}
