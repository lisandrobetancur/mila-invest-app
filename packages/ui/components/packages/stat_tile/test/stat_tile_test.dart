import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stat_tile/stat_tile.dart';

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
  testWidgets('muestra etiqueta, cifra, variación y ayuda', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(
      tester,
      const StatTile(
        id: 'test_pnl_tile',
        label: 'P&L no realizado',
        value: Identified(id: 'test_pnl_value_text', child: Text('+20.940')),
        change: Identified(id: 'test_pnl_change_text', child: Text('+7,89 %')),
        helper: 'Ganancia o pérdida si vendieras hoy',
      ),
    );

    expect(find.bySemanticsIdentifier('test_pnl_tile'), findsOneWidget);
    expect(_label(tester, 'test_pnl_value_text'), '+20.940');
    expect(_label(tester, 'test_pnl_change_text'), '+7,89 %');
    expect(find.text('P&L no realizado'), findsOneWidget);
    expect(find.text('Ganancia o pérdida si vendieras hoy'), findsOneWidget);
    handle.dispose();
  });
}
