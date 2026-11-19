import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_summary/order_summary.dart';
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

const OrderSummaryIds _ids = OrderSummaryIds(
  root: 'test_summary',
  price: 'test_summary_price_text',
  gross: 'test_summary_gross_text',
  commission: 'test_summary_commission_text',
  total: 'test_summary_total_text',
  availableAfter: 'test_summary_available_after_text',
);

const OrderSummaryLabels _labels = OrderSummaryLabels(
  price: 'Precio estimado',
  gross: 'Monto bruto',
  commission: 'Comisión',
  total: 'Total',
  availableAfter: 'Saldo resultante',
);

Money _cop(String value) => Money.parse(value, Currency.cop);

void main() {
  testWidgets('muestra cada fila con su id y su formato', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(
      tester,
      SizedBox(
        width: 340,
        child: OrderSummary(
          ids: _ids,
          labels: _labels,
          price: _cop('2385'),
          gross: _cop('23850'),
          commission: _cop('5000'),
          total: _cop('28850'),
          availableAfter: _cop('7419890'),
        ),
      ),
    );

    expect(find.bySemanticsIdentifier('test_summary'), findsOneWidget);
    expect(find.text(r'$ 2.385 COP'), findsOneWidget);
    expect(find.text(r'$ 23.850 COP'), findsOneWidget);
    expect(find.text(r'$ 5.000 COP'), findsOneWidget);
    expect(find.text(r'$ 28.850 COP'), findsOneWidget);
    expect(find.text(r'$ 7.419.890 COP'), findsOneWidget);
    expect(
      _label(tester, 'test_summary_total_text'),
      '28.850 pesos colombianos',
    );
    expect(
      _label(tester, 'test_summary_commission_text'),
      '5.000 pesos colombianos',
    );
    handle.dispose();
  });

  testWidgets('el saldo resultante negativo se pinta de error', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      SizedBox(
        width: 340,
        child: OrderSummary(
          ids: _ids,
          labels: _labels,
          price: _cop('2385'),
          gross: _cop('23850'),
          commission: _cop('5000'),
          total: _cop('28850'),
          availableAfter: _cop('-850'),
        ),
      ),
    );

    final Text text = tester.widget<Text>(find.text('−\$ 850 COP'));
    expect(text.style?.color, AppColors.errorLight);
  });

  testWidgets('sin saldo resultante oculta la fila', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      SizedBox(
        width: 340,
        child: OrderSummary(
          ids: _ids,
          labels: _labels,
          price: _cop('2386'),
          gross: _cop('23860'),
          commission: _cop('5000'),
          total: _cop('28860'),
        ),
      ),
    );

    expect(find.text('Saldo resultante'), findsNothing);
  });
}
