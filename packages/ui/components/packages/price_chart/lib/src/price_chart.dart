import 'package:decimal/decimal.dart';
import 'package:design_system/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

/// Un punto de un [PriceChart].
@immutable
class PriceChartPoint {
  /// Crea un punto.
  const PriceChartPoint({required this.time, required this.price});

  /// Instante del precio, en UTC.
  final DateTime time;

  /// Precio.
  final Decimal price;
}

/// Gráfico de línea de precios.
///
/// La línea es `gain` si el rango cierra por encima del primer punto y
/// `loss` si cierra por debajo, con un área en gradiente al 12 %. Al tocar
/// muestra precio y hora. Sin grilla vertical; ejes en `labelSmall`.
///
/// Es, junto con `allocation_donut`, el único lugar donde un precio se
/// convierte a `double`: solo para entregarle los puntos a `fl_chart`.
class PriceChart extends StatelessWidget {
  /// Crea el gráfico.
  const PriceChart({
    required this.id,
    required this.points,
    required this.currency,
    required this.semanticLabel,
    required this.timeLabel,
    this.height = 220,
    this.loading = false,
    super.key,
  });

  /// Identificador semántico y `Key` de la raíz del gráfico.
  final String id;

  /// Puntos de la serie, en orden cronológico.
  final List<PriceChartPoint> points;

  /// Moneda de los precios.
  final Currency currency;

  /// Resumen textual para lectores de pantalla ("Ecopetrol, último mes, de
  /// 2.210 a 2.385 pesos, sube 7,9 %").
  final String semanticLabel;

  /// Formatea un instante para el tooltip y los extremos del eje.
  final String Function(DateTime time) timeLabel;

  /// Alto del gráfico. El shimmer de carga usa el mismo.
  final double height;

  /// Muestra el shimmer en lugar del gráfico.
  final bool loading;

  /// Signo del rango: positivo si cierra arriba del primer punto.
  int get trend =>
      points.length < 2 ? 0 : (points.last.price - points.first.price).sign;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle axisStyle = AppTypography.tabular(
      AppTypography.labelSmall,
    ).copyWith(color: theme.colorScheme.onSurfaceVariant);
    final Widget content;
    if (loading) {
      content = AppShimmer(child: AppShimmerBox(height: height, radius: 12));
    } else if (points.length < 2) {
      content = SizedBox(height: height);
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: height - 20, child: _chart(context, axisStyle)),
          SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Text(
                    timeLabel(points.first.time),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: axisStyle,
                  ),
                ),
                Flexible(
                  child: Text(
                    timeLabel(points.last.time),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: axisStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Identified(
      id: id,
      label: semanticLabel,
      replaceChildSemantics: true,
      child: content,
    );
  }

  Widget _chart(BuildContext context, TextStyle axisStyle) {
    final ThemeData theme = Theme.of(context);
    final Color color = theme.market.foregroundFor(trend);
    final List<FlSpot> spots = <FlSpot>[
      for (int index = 0; index < points.length; index++)
        FlSpot(index.toDouble(), points[index].price.toDouble()),
    ];
    double minY = spots.first.y;
    double maxY = spots.first.y;
    for (final FlSpot spot in spots) {
      minY = spot.y < minY ? spot.y : minY;
      maxY = spot.y > maxY ? spot.y : maxY;
    }
    final double span = maxY - minY;
    final double padding = span == 0 ? maxY.abs() * 0.01 + 1 : span * 0.12;
    final bool still = MediaQuery.disableAnimationsOf(context);

    return LineChart(
      duration: still ? Duration.zero : const Duration(milliseconds: 200),
      curve: AppDurations.curve,
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        clipData: const FlClipData.all(),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: (span + 2 * padding) / 3,
          getDrawingHorizontalLine: (double value) =>
              FlLine(color: theme.colorScheme.outline, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          bottomTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 76,
              interval: (span + 2 * padding) / 3,
              getTitlesWidget: (double value, TitleMeta meta) =>
                  value <= meta.min || value >= meta.max
                  ? const SizedBox.shrink()
                  : SideTitleWidget(
                      meta: meta,
                      child: Text(
                        _priceLabel(value, abbreviated: true),
                        maxLines: 1,
                        style: axisStyle,
                      ),
                    ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (LineBarSpot spot) => theme.colorScheme.onSurface,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (List<LineBarSpot> touched) => <LineTooltipItem>[
              for (final LineBarSpot spot in touched)
                LineTooltipItem(
                  '${Formatters.price(Money(points[spot.spotIndex].price, currency))}\n',
                  AppTypography.tabular(
                    AppTypography.labelLarge,
                  ).copyWith(color: theme.colorScheme.surface),
                  children: <TextSpan>[
                    TextSpan(
                      text: timeLabel(points[spot.spotIndex].time),
                      style: AppTypography.labelSmall.copyWith(
                        color: theme.colorScheme.surface,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: spots,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  color.withValues(alpha: 0.12),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _priceLabel(double value, {required bool abbreviated}) {
    final Money money = Money(
      Decimal.parse(value.toStringAsFixed(2)),
      currency,
    );
    return abbreviated && money.amount >= Decimal.fromInt(100000)
        ? Formatters.money(money, compact: true)
        : Formatters.price(money);
  }
}
