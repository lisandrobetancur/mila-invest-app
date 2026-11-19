import 'package:design_system/design_system.dart';
import 'package:error_state/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
  testWidgets('identifica la raíz, el mensaje y "Reintentar"', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    int retries = 0;
    await _pump(
      tester,
      ErrorState(
        id: 'test_market_state_error',
        messageId: 'test_market_error_text',
        message: 'No pudimos cargar el mercado. Revisa tu conexión.',
        retryId: 'test_market_retry_button',
        retryLabel: 'Reintentar',
        icon: AppIcons.offline,
        onRetry: () => retries++,
      ),
    );

    expect(
      find.bySemanticsIdentifier('test_market_state_error'),
      findsOneWidget,
    );
    expect(
      _label(tester, 'test_market_error_text'),
      'No pudimos cargar el mercado. Revisa tu conexión.',
    );
    final SemanticsData retry = tester
        .getSemantics(find.bySemanticsIdentifier('test_market_retry_button'))
        .getSemanticsData();
    expect(retry.flagsCollection.isButton, isTrue);
    expect(retry.hasAction(SemanticsAction.tap), isTrue);

    await tester.tap(find.bySemanticsIdentifier('test_market_retry_button'));
    expect(retries, 1);
    handle.dispose();
  });
}
