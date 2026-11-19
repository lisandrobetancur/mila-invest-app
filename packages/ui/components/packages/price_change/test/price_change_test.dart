import 'package:decimal/decimal.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:price_change/price_change.dart';
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

Color? _color(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

void main() {
  testWidgets('positiva: flecha, signo, color de ganancia y forma hablada', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(
      tester,
      PriceChange(
        id: 'test_change_text',
        currency: Currency.cop,
        percent: Decimal.parse('2.35'),
      ),
    );

    expect(find.text('▲ +2,35 %'), findsOneWidget);
    expect(_color(tester, '▲ +2,35 %'), AppColors.gainLight);
    expect(_label(tester, 'test_change_text'), 'sube 2,35 por ciento');
    handle.dispose();
  });

  testWidgets('negativa: flecha hacia abajo, signo menos y color de pérdida', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(
      tester,
      PriceChange(
        id: 'test_change_text',
        currency: Currency.cop,
        percent: Decimal.parse('-1.1'),
      ),
    );

    expect(find.text('▼ −1,10 %'), findsOneWidget);
    expect(_color(tester, '▼ −1,10 %'), AppColors.lossLight);
    expect(_label(tester, 'test_change_text'), 'baja 1,10 por ciento');
    handle.dispose();
  });

  testWidgets('cero: neutro, sin flecha ni signo', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(
      tester,
      PriceChange(
        id: 'test_change_text',
        currency: Currency.cop,
        percent: Decimal.zero,
      ),
    );

    expect(find.text('0,00 %'), findsOneWidget);
    expect(_color(tester, '0,00 %'), AppColors.neutralLight);
    expect(_label(tester, 'test_change_text'), 'sin cambio');
    handle.dispose();
  });

  testWidgets('absoluta y porcentual juntas, como chip', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(
      tester,
      PriceChange(
        id: 'test_pnl_text',
        currency: Currency.cop,
        amount: Money.parse('20940', Currency.cop),
        percent: Decimal.parse('7.89'),
        variant: PriceChangeVariant.chip,
      ),
    );

    expect(find.text('▲ +\$ 20.940 COP (+7,89 %)'), findsOneWidget);
    expect(
      _label(tester, 'test_pnl_text'),
      'sube 20.940 pesos colombianos, 7,89 por ciento',
    );
    expect(find.byType(DecoratedBox), findsWidgets);
    handle.dispose();
  });

  testWidgets('usa el separador decimal del país de la moneda', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      PriceChange(
        id: 'test_change_text',
        currency: Currency.mxn,
        percent: Decimal.parse('2.35'),
      ),
    );

    expect(find.text('▲ +2.35 %'), findsOneWidget);
  });
}
