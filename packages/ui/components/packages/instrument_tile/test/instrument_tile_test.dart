import 'package:decimal/decimal.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instrument_tile/instrument_tile.dart';
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

const String _id = 'market_list_instrument_item_ECOPETROL-CO';

Widget _tile({VoidCallback? onTap}) => SizedBox(
  width: 340,
  child: InstrumentTile(
    id: _id,
    ticker: 'ECOPETROL',
    name: 'Ecopetrol S.A.',
    country: Country.co,
    countryName: 'Colombia',
    price: Money.parse('2385', Currency.cop),
    changePercent: Decimal.parse('1.49'),
    onTap: onTap ?? () {},
  ),
);

void main() {
  testWidgets('la raíz es tocable y cada parte conserva su id', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    int taps = 0;
    await _pump(tester, _tile(onTap: () => taps++));

    final SemanticsData root = tester
        .getSemantics(find.bySemanticsIdentifier(_id))
        .getSemanticsData();
    expect(root.flagsCollection.isButton, isTrue);
    expect(root.hasAction(SemanticsAction.tap), isTrue);
    expect(
      _label(tester, InstrumentTile.priceIdOf(_id)),
      '2.385 pesos colombianos',
    );
    expect(
      _label(tester, InstrumentTile.changeIdOf(_id)),
      'sube 1,49 por ciento',
    );
    expect(_label(tester, InstrumentTile.countryIdOf(_id)), 'Colombia');
    expect(find.text('ECOPETROL'), findsOneWidget);
    expect(find.text('Ecopetrol S.A.'), findsOneWidget);

    await tester.tap(find.bySemanticsIdentifier(_id));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('los ids de las partes derivan del id del ítem', (
    WidgetTester tester,
  ) async {
    expect(InstrumentTile.priceIdOf(_id), '${_id}_price_text');
    expect(InstrumentTile.changeIdOf(_id), '${_id}_change_text');
    expect(InstrumentTile.countryIdOf(_id), '${_id}_country_text');
  });

  testWidgets('con el texto al 200 % pasa a dos líneas sin desbordar', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _tile(), textScale: 2);

    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('\$ 2.385 COP')).dy,
      greaterThan(tester.getBottomLeft(find.text('Ecopetrol S.A.')).dy - 1),
    );
  });
}
