import 'package:country_chip/country_chip.dart';
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
  testWidgets('muestra el código y expone el nombre por semántica', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(
      tester,
      const CountryChip(
        id: 'test_country_text',
        country: Country.pe,
        name: 'Perú',
      ),
    );

    expect(find.text('PE'), findsOneWidget);
    expect(_label(tester, 'test_country_text'), 'Perú');
    expect(find.byTooltip('Perú'), findsOneWidget);
    handle.dispose();
  });
}
