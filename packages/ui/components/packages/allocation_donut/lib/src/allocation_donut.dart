import 'package:decimal/decimal.dart';
import 'package:design_system/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

/// Una porción de un [AllocationDonut].
@immutable
class AllocationSlice {
  /// Crea una porción.
  const AllocationSlice({
    required this.id,
    required this.label,
    required this.percent,
  });

  /// Identificador semántico y `Key` de la fila de la leyenda.
  final String id;

  /// Nombre de la porción, ya traducido ("Acciones").
  final String label;

  /// Participación (`62.4` es 62,4 %).
  final Decimal percent;
}

/// Torta de distribución por tipo de producto.
///
/// La leyenda dice cada porción con texto y porcentaje, no solo con color.
/// La conversión a `double` ocurre únicamente al entregarle los valores a
/// `fl_chart`.
class AllocationDonut extends StatelessWidget {
  /// Crea la torta.
  const AllocationDonut({
    required this.id,
    required this.slices,
    required this.currency,
    required this.semanticLabel,
    this.compact = false,
    super.key,
  });

  /// Identificador semántico y `Key` de la raíz del gráfico.
  final String id;

  /// Porciones, en orden de presentación.
  final List<AllocationSlice> slices;

  /// Moneda base: define el separador decimal de los porcentajes.
  final Currency currency;

  /// Resumen textual para lectores de pantalla.
  final String semanticLabel;

  /// Versión chica, para el dashboard.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Color> palette = <Color>[
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.market.info,
      theme.colorScheme.onSurfaceVariant,
      theme.market.gain,
    ];
    final double size = compact ? 88 : 132;
    final bool still = MediaQuery.disableAnimationsOf(context);
    return Identified(
      id: id,
      label: semanticLabel,
      child: Row(
        children: <Widget>[
          ExcludeSemantics(
            child: SizedBox.square(
              dimension: size,
              child: PieChart(
                duration: still
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                curve: AppDurations.curve,
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 2,
                  centerSpaceRadius: size * 0.3,
                  pieTouchData: PieTouchData(enabled: false),
                  sections: <PieChartSectionData>[
                    for (int index = 0; index < slices.length; index++)
                      PieChartSectionData(
                        value: slices[index].percent.toDouble(),
                        color: palette[index % palette.length],
                        radius: size * 0.18,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int index = 0; index < slices.length; index++)
                  _LegendRow(
                    slice: slices[index],
                    color: palette[index % palette.length],
                    currency: currency,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.slice,
    required this.color,
    required this.currency,
  });

  final AllocationSlice slice;
  final Color color;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Identified(
      id: slice.id,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Row(
          children: <Widget>[
            SizedBox.square(
              dimension: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(child: Text(slice.label, style: textTheme.bodyMedium)),
            const SizedBox(width: AppSpacing.xs),
            Text(
              Formatters.share(slice.percent, currency: currency),
              style: AppTypography.tabular(
                AppTypography.labelLarge,
              ).copyWith(color: textTheme.titleMedium?.color),
            ),
          ],
        ),
      ),
    );
  }
}
