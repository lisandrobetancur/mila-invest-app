import 'package:decimal/decimal.dart';
import 'package:design_system/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:price_chart/price_chart.dart';
import 'package:typing/typing.dart';

Future<void> _pump(WidgetTester tester, Widget child, {double textScale = 1}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(
            disableAnimations: true,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );

String _label(WidgetTester tester, String id) => tester
    .getSemantics(find.bySemanticsIdentifier(id))
    .getSemanticsData()
    .label;

List<PriceChartPoint> _series(List<String> prices) => <PriceChartPoint>[
  for (int index = 0; index < prices.length; index++)
    PriceChartPoint(
      time: DateTime.utc(2026, 11, index + 1),
      price: Decimal.parse(prices[index]),
    ),
];

Widget _chart(List<PriceChartPoint> points, {bool loading = false}) => SizedBox(
  width: 340,
  child: PriceChart(
    id: 'test_price_chart',
    points: points,
    currency: Currency.cop,
    loading: loading,
    semanticLabel: 'Ecopetrol, último mes, de 2.210 a 2.385 pesos, sube 7,9 %',
    timeLabel: (DateTime time) => '${time.day} nov',
  ),
);

Color? _lineColor(WidgetTester tester) => tester
    .widget<LineChart>(find.byType(LineChart))
    .data
    .lineBarsData
    .single
    .color;

void main() {
  testWidgets('la raíz lleva el id y el resumen textual', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(tester, _chart(_series(<String>['2210', '2300', '2385'])));

    expect(
      _label(tester, 'test_price_chart'),
      'Ecopetrol, último mes, de 2.210 a 2.385 pesos, sube 7,9 %',
    );
    expect(find.text('1 nov'), findsOneWidget);
    expect(find.text('3 nov'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('la línea es gain si cierra arriba y loss si cierra abajo', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _chart(_series(<String>['2210', '2300', '2385'])));
    expect(_lineColor(tester), AppColors.gainLight);

    await _pump(tester, _chart(_series(<String>['2385', '2300', '2210'])));
    expect(_lineColor(tester), AppColors.lossLight);

    await _pump(tester, _chart(_series(<String>['2300', '2400', '2300'])));
    expect(_lineColor(tester), AppColors.neutralLight);
  });

  testWidgets('en loading muestra un shimmer de la misma altura', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _chart(const <PriceChartPoint>[], loading: true));
    final double loadingHeight = tester
        .getSize(find.byKey(const ValueKey<String>('test_price_chart')))
        .height;

    await _pump(tester, _chart(_series(<String>['2210', '2385'])));
    final double dataHeight = tester
        .getSize(find.byKey(const ValueKey<String>('test_price_chart')))
        .height;

    expect(loadingHeight, dataHeight);
    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('con menos de dos puntos no dibuja línea ni falla', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _chart(_series(<String>['2210'])));

    expect(find.byType(LineChart), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
