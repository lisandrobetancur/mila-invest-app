import 'package:design_system/design_system.dart';
import 'package:empty_state/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
  testWidgets('identifica la raíz, el título y la acción', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    int taps = 0;
    await _pump(
      tester,
      EmptyState(
        id: 'test_portfolio_state_empty',
        titleId: 'test_portfolio_empty_title_text',
        icon: AppIcons.emptyPortfolio,
        title: 'Aún no tienes inversiones',
        message: 'Explora el mercado y haz tu primera compra.',
        action: EmptyStateAction(
          id: 'test_portfolio_explore_button',
          label: 'Explorar mercado',
          onPressed: () => taps++,
        ),
      ),
    );

    expect(
      find.bySemanticsIdentifier('test_portfolio_state_empty'),
      findsOneWidget,
    );
    expect(
      _label(tester, 'test_portfolio_empty_title_text'),
      'Aún no tienes inversiones',
    );
    await tester.tap(
      find.bySemanticsIdentifier('test_portfolio_explore_button'),
    );
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('sin acción no dibuja botón', (WidgetTester tester) async {
    await _pump(
      tester,
      const EmptyState(
        id: 'test_state_empty',
        titleId: 'test_empty_title_text',
        icon: AppIcons.emptyList,
        title: 'Sin movimientos',
      ),
    );

    expect(find.byType(AppButton), findsNothing);
  });
}
