import 'package:design_system/design_system.dart';
import 'package:disclaimer_banner/disclaimer_banner.dart';
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
  const String text =
      'Simulación con fines educativos. No es asesoría financiera.';

  for (final DisclaimerBannerVariant variant
      in DisclaimerBannerVariant.values) {
    testWidgets('variante ${variant.name}: el aviso lleva su id', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        DisclaimerBanner(
          id: 'test_disclaimer_text',
          text: text,
          variant: variant,
        ),
      );

      expect(_label(tester, 'test_disclaimer_text'), text);
      expect(tester.takeException(), isNull);
      handle.dispose();
    });
  }
}
