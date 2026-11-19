import 'package:allocation_donut/allocation_donut.dart';
import 'package:decimal/decimal.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
  testWidgets('la leyenda dice cada porción con texto y porcentaje', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(
      tester,
      SizedBox(
        width: 340,
        child: AllocationDonut(
          id: 'test_allocation_chart',
          currency: Currency.cop,
          semanticLabel: 'Distribución: acciones 62,4 %, efectivo 37,6 %',
          slices: <AllocationSlice>[
            AllocationSlice(
              id: 'test_allocation_stock_text',
              label: 'Acciones',
              percent: Decimal.parse('62.4'),
            ),
            AllocationSlice(
              id: 'test_allocation_cash_text',
              label: 'Efectivo',
              percent: Decimal.parse('37.6'),
            ),
          ],
        ),
      ),
    );

    expect(
      _label(tester, 'test_allocation_chart'),
      contains('Distribución: acciones 62,4 %'),
    );
    expect(_label(tester, 'test_allocation_stock_text'), contains('Acciones'));
    expect(_label(tester, 'test_allocation_stock_text'), contains('62,4 %'));
    expect(_label(tester, 'test_allocation_cash_text'), contains('37,6 %'));
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('con texto al 200 % la leyenda va debajo y no desborda', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      SizedBox(
        width: 328,
        child: AllocationDonut(
          id: 'test_allocation_chart',
          currency: Currency.cop,
          semanticLabel: 'Distribución',
          slices: <AllocationSlice>[
            AllocationSlice(
              id: 'test_allocation_stock_text',
              label: 'Acciones',
              percent: Decimal.parse('28.62'),
            ),
            AllocationSlice(
              id: 'test_allocation_cash_text',
              label: 'Efectivo',
              percent: Decimal.parse('71.38'),
            ),
          ],
        ),
      ),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
