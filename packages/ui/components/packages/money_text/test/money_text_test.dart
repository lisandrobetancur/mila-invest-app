import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_text/money_text.dart';
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
  testWidgets('muestra el formato de la moneda y la forma hablada', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(
      tester,
      MoneyText(
        id: 'test_total_text',
        money: Money.parse('1234567', Currency.cop),
      ),
    );

    expect(find.text(r'$ 1.234.567 COP'), findsOneWidget);
    expect(_label(tester, 'test_total_text'), '1.234.567 pesos colombianos');
    expect(
      find.byKey(const ValueKey<String>('test_total_text')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('usa cifras tabulares', (WidgetTester tester) async {
    await _pump(
      tester,
      MoneyText(id: 'test_text', money: Money.parse('10', Currency.pen)),
    );

    final Text text = tester.widget<Text>(find.byType(Text));
    expect(text.style?.fontFeatures, AppTypography.tabularFigures);
  });

  testWidgets('precio, abreviado, con signo y negativo', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MoneyText(
            id: 'test_price_text',
            money: Money.parse('999.5', Currency.cop),
            isPrice: true,
          ),
          MoneyText(
            id: 'test_compact_text',
            money: Money.parse('1234567', Currency.cop),
            abbreviated: true,
            size: MoneyTextSize.compact,
          ),
          MoneyText(
            id: 'test_signed_text',
            money: Money.parse('100000', Currency.cop),
            signed: true,
          ),
          MoneyText(
            id: 'test_negative_text',
            money: Money.parse('-28860', Currency.cop),
          ),
        ],
      ),
    );

    expect(find.text(r'$ 999,50 COP'), findsOneWidget);
    expect(find.text(r'$ 1,2 M COP'), findsOneWidget);
    expect(find.text(r'+$ 100.000 COP'), findsOneWidget);
    expect(find.text('−\$ 28.860 COP'), findsOneWidget);
    expect(_label(tester, 'test_negative_text'), '− 28.860 pesos colombianos');
    handle.dispose();
  });

  testWidgets('las cifras grandes no desbordan con el texto al 200 %', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pump(
      tester,
      MoneyText(
        id: 'test_total_text',
        money: Money.parse('1234567890', Currency.cop),
        size: MoneyTextSize.display,
      ),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(FittedBox), findsOneWidget);
  });

  testWidgets('la forma hablada sigue al idioma de la UI', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(
      tester,
      SemanticLabelsScope(
        labels: const SemanticLabels(
          currencyNames: <String, String>{'MXN': 'Mexican pesos'},
          rises: 'up',
          falls: 'down',
          unchanged: 'unchanged',
          percent: 'percent',
        ),
        child: MoneyText(
          id: 'test_text',
          money: Money.parse('1234.5', Currency.mxn),
        ),
      ),
    );

    expect(find.text(r'$1,234.50 MXN'), findsOneWidget);
    expect(_label(tester, 'test_text'), '1,234.50 Mexican pesos');
    handle.dispose();
  });
}
