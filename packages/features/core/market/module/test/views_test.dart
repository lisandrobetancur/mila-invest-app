import 'dart:async';

import 'package:authentication_typing/authentication_typing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instrument_tile/instrument_tile.dart';
import 'package:market/market.dart';
import 'package:market/ui/views/instrument_detail/instrument_detail.dart';
import 'package:market/ui/views/market_list/market_list.dart';
import 'package:market_constants/market_constants.dart';
import 'package:market_typing/market_typing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:navigator/navigator.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:typing/typing.dart';

import 'support/fixtures.dart';
import 'support/harness.dart';

class _MockService extends Mock implements IMarketService {}

class _MockNavigation extends Mock implements NavigationManager {}

const User _user = User(
  id: 'usr_1',
  email: 'demo@milainvest.app',
  fullName: 'Camila Demo',
  country: Country.co,
  baseCurrency: Currency.cop,
  documentType: DocumentType.cc,
  documentLast4: '5678',
);

final class _Doubles {
  _Doubles() {
    when(() => navigation.push<void>(any())).thenAnswer((_) async {});
    when(navigation.canPop).thenReturn(true);
  }

  final _MockService service = _MockService();
  final _MockNavigation navigation = _MockNavigation();

  List<Override> overrides({
    List<CountryMarket>? markets,
    Portfolio? holdings,
  }) => <Override>[
    marketServiceProvider.overrideWithValue(service),
    navigationManagerProvider.overrideWithValue(navigation),
    marketSearchDebounceProvider.overrideWithValue(Duration.zero),
    priceRefreshIntervalProvider.overrideWithValue(Duration.zero),
    sessionProvider.overrideWithValue(const SessionState.authenticated(_user)),
    countryMarketsProvider.overrideWith(
      (Ref ref) async => markets ?? <CountryMarket>[market()],
    ),
    portfolioProvider.overrideWith((Ref ref) async => holdings ?? portfolio()),
  ];
}

const AppRouteParams _noFilters = AppRouteParams(location: '/market');

SemanticsData _data(WidgetTester tester, String id) =>
    tester.getSemantics(find.bySemanticsIdentifier(id)).getSemanticsData();

void main() {
  setUpAll(() {
    registerFallbackValue(const InstrumentFilter());
    registerFallbackValue(PriceRange.day);
  });

  group('MarketListView', () {
    testWidgets('loading: raíz de la vista y del estado', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.service.instruments(any(), limit: any(named: 'limit')),
      ).thenAnswer((_) => Completer<Paginated<Instrument>>().future);

      await pumpView(
        tester,
        const MarketListView(params: _noFilters),
        languages: marketLanguages,
        overrides: doubles.overrides(),
      );

      expect(find.bySemanticsIdentifier(MarketIds.listView), findsOneWidget);
      expect(
        find.bySemanticsIdentifier(MarketIds.listStateLoading),
        findsOneWidget,
      );
      expect(labelOf(tester, MarketIds.listSimulatedText), 'Simulado');
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('data: filtros, estado de mercado e ítems con sus partes', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.service.instruments(any(), limit: any(named: 'limit')),
      ).thenAnswer(
        (_) async => Paginated<Instrument>(
          items: <Instrument>[
            instrument(),
            instrument(
              id: 'BAP-PE',
              ticker: 'BAP',
              price: '192.50',
              changePct: '-1.10',
              country: Country.pe,
            ),
          ],
        ),
      );

      await pumpView(
        tester,
        const MarketListView(params: _noFilters),
        languages: marketLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(MarketIds.listStateData),
        findsOneWidget,
      );
      expect(
        _data(tester, MarketIds.listSearchField).flagsCollection.isTextField,
        isTrue,
      );
      for (final String id in <String>[
        MarketIds.listCountryAllChip,
        MarketIds.listCountryCoChip,
        MarketIds.listCountryMxChip,
        MarketIds.listCountryPeChip,
        MarketIds.listTypeStockChip,
        MarketIds.listTypeEtfChip,
      ]) {
        expect(_data(tester, id).flagsCollection.isButton, isTrue, reason: id);
      }
      expect(
        labelOf(tester, MarketIds.listStatusCoText),
        'CO · Abierto · cierra 4:00 p.\u202fm.',
      );
      final String bap = MarketIds.listInstrumentItem('BAP-PE');
      expect(_data(tester, bap).flagsCollection.isButton, isTrue);
      expect(labelOf(tester, InstrumentTile.priceIdOf(bap)), '192.50 soles');
      expect(
        labelOf(tester, InstrumentTile.changeIdOf(bap)),
        'baja 1.10 por ciento',
      );
      expectNoDuplicateIdentifiers(tester);

      await tester.tap(find.bySemanticsIdentifier(bap));
      verify(
        () => doubles.navigation.push<void>('/market/instrument/BAP-PE'),
      ).called(1);
      handle.dispose();
    });

    testWidgets('empty: título y "Limpiar filtros"', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.service.instruments(any(), limit: any(named: 'limit')),
      ).thenAnswer((_) async => const Paginated<Instrument>.empty());

      await pumpView(
        tester,
        const MarketListView(
          params: AppRouteParams(
            location: '/market?q=zzz',
            queryParameters: <String, String>{'q': 'zzz'},
          ),
        ),
        languages: marketLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(MarketIds.listStateEmpty),
        findsOneWidget,
      );
      expect(
        labelOf(tester, MarketIds.listEmptyTitleText),
        'No encontramos instrumentos con esos filtros',
      );
      expect(find.text('zzz'), findsOneWidget);
      expectNoDuplicateIdentifiers(tester);

      await tester.tap(
        find.bySemanticsIdentifier(MarketIds.listClearFiltersButton),
      );
      await tester.pump();
      verify(() => doubles.navigation.go('/market')).called(1);
      expect(find.text('zzz'), findsNothing);
      handle.dispose();
    });

    testWidgets('error: mensaje y "Reintentar"', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.service.instruments(any(), limit: any(named: 'limit')),
      ).thenThrow(const MarketException(MarketErrorCode.network));

      await pumpView(
        tester,
        const MarketListView(params: _noFilters),
        languages: marketLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(MarketIds.listStateError),
        findsOneWidget,
      );
      expect(
        labelOf(tester, MarketIds.listErrorText),
        startsWith('No pudimos cargar el mercado'),
      );
      expect(
        _data(tester, MarketIds.listRetryButton).flagsCollection.isButton,
        isTrue,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('no desborda en 360 px con el texto al 200 %', (
      WidgetTester tester,
    ) async {
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.service.instruments(any(), limit: any(named: 'limit')),
      ).thenAnswer(
        (_) async => Paginated<Instrument>(items: <Instrument>[instrument()]),
      );

      await pumpView(
        tester,
        const MediaQueryTextScale(
          scale: 2,
          child: MarketListView(params: _noFilters),
        ),
        languages: marketLanguages,
        overrides: doubles.overrides(),
        size: const Size(360, 800),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('InstrumentDetailView', () {
    void stub(_Doubles doubles) {
      when(
        () => doubles.service.instrument('ECOPETROL-CO'),
      ).thenAnswer((_) async => detail());
      when(
        () => doubles.service.prices('ECOPETROL-CO', any()),
      ).thenAnswer((_) async => series());
    }

    testWidgets('loading: raíz de la vista y del estado', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.service.instrument(any()),
      ).thenAnswer((_) => Completer<InstrumentDetail>().future);

      await pumpView(
        tester,
        const InstrumentDetailView(instrumentId: 'ECOPETROL-CO'),
        languages: marketLanguages,
        overrides: doubles.overrides(),
      );

      expect(find.bySemanticsIdentifier(MarketIds.detailView), findsOneWidget);
      expect(
        find.bySemanticsIdentifier(MarketIds.detailStateLoading),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(MarketIds.detailBackIconButton),
        findsOneWidget,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('data: precio, gráfico, estadísticas, posición y botones', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      stub(doubles);

      await pumpView(
        tester,
        const InstrumentDetailView(instrumentId: 'ECOPETROL-CO'),
        languages: marketLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(MarketIds.detailStateData),
        findsOneWidget,
      );
      expect(
        labelOf(tester, MarketIds.detailPriceText),
        '2.385 pesos colombianos',
      );
      expect(
        labelOf(tester, MarketIds.detailChangeText),
        'sube 35 pesos colombianos, 1,49 por ciento',
      );
      expect(
        labelOf(tester, MarketIds.detailChart),
        'ECOPETROL S.A., hoy, de 2.210 a 2.385 pesos colombianos, '
        'sube 7,9 %',
      );
      expect(labelOf(tester, MarketIds.detailVolumeText), '12.450.300');
      expect(
        labelOf(tester, MarketIds.detailPositionQuantityText),
        '120 unidades',
      );
      for (final String id in <String>[
        MarketIds.detailRange1dSegment,
        MarketIds.detailRange1wSegment,
        MarketIds.detailRange1mSegment,
        MarketIds.detailRange3mSegment,
        MarketIds.detailRange1ySegment,
        MarketIds.detailBuyButton,
        MarketIds.detailSellButton,
      ]) {
        final SemanticsData data = _data(tester, id);
        expect(data.flagsCollection.isButton, isTrue, reason: id);
        expect(data.hasAction(SemanticsAction.tap), isTrue, reason: id);
      }
      expect(
        find.bySemanticsIdentifier(MarketIds.detailClosedReasonText),
        findsNothing,
      );
      expectNoDuplicateIdentifiers(tester);

      await tester.tap(find.bySemanticsIdentifier(MarketIds.detailBuyButton));
      verify(
        () => doubles.navigation.push<void>('/orders/ticket/ECOPETROL-CO/buy'),
      ).called(1);
      handle.dispose();
    });

    testWidgets('data con el mercado cerrado y sin posición', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      stub(doubles);

      await pumpView(
        tester,
        const InstrumentDetailView(instrumentId: 'ECOPETROL-CO'),
        languages: marketLanguages,
        overrides: doubles.overrides(
          markets: <CountryMarket>[market(open: false)],
          holdings: portfolio(quantity: 0),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        labelOf(tester, MarketIds.detailClosedReasonText),
        startsWith('El mercado está cerrado'),
      );
      expect(
        _data(tester, MarketIds.detailBuyButton).hasAction(SemanticsAction.tap),
        isFalse,
      );
      expect(
        find.bySemanticsIdentifier(MarketIds.detailSellButton),
        findsNothing,
      );
      expect(
        find.bySemanticsIdentifier(MarketIds.detailPositionQuantityText),
        findsNothing,
      );
      handle.dispose();
    });

    testWidgets('empty: "no encontrado" con vuelta al mercado', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.service.instrument('NOPE-CO'),
      ).thenThrow(const MarketException(MarketErrorCode.instrumentNotFound));

      await pumpView(
        tester,
        const InstrumentDetailView(instrumentId: 'NOPE-CO'),
        languages: marketLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(MarketIds.detailStateEmpty),
        findsOneWidget,
      );
      expect(
        labelOf(tester, MarketIds.detailNotFoundTitleText),
        'No encontramos este instrumento',
      );
      expectNoDuplicateIdentifiers(tester);

      await tester.tap(
        find.bySemanticsIdentifier(MarketIds.detailBackToMarketButton),
      );
      verify(() => doubles.navigation.go('/market')).called(1);
      handle.dispose();
    });

    testWidgets('error: mensaje y "Reintentar"', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.service.instrument('ECOPETROL-CO'),
      ).thenThrow(const MarketException(MarketErrorCode.network));

      await pumpView(
        tester,
        const InstrumentDetailView(instrumentId: 'ECOPETROL-CO'),
        languages: marketLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(MarketIds.detailStateError),
        findsOneWidget,
      );
      expect(
        labelOf(tester, MarketIds.detailErrorText),
        startsWith('No pudimos cargar el mercado'),
      );
      stub(doubles);
      await tester.tap(find.bySemanticsIdentifier(MarketIds.detailRetryButton));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(MarketIds.detailStateData),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('en web ancho muestra el gráfico a la izquierda y el panel '
        'de operar a la derecha', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      stub(doubles);

      await pumpView(
        tester,
        const InstrumentDetailView(instrumentId: 'ECOPETROL-CO'),
        languages: marketLanguages,
        overrides: doubles.overrides(),
        size: const Size(1440, 900),
      );
      await tester.pumpAndSettle();

      final Offset chart = tester.getCenter(
        find.bySemanticsIdentifier(MarketIds.detailChart),
      );
      final Offset buy = tester.getCenter(
        find.bySemanticsIdentifier(MarketIds.detailBuyButton),
      );
      expect(buy.dx, greaterThan(chart.dx));
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('no desborda en 360 px con el texto al 200 %', (
      WidgetTester tester,
    ) async {
      final _Doubles doubles = _Doubles();
      stub(doubles);

      await pumpView(
        tester,
        const MediaQueryTextScale(
          scale: 2,
          child: InstrumentDetailView(instrumentId: 'ECOPETROL-CO'),
        ),
        languages: marketLanguages,
        overrides: doubles.overrides(),
        size: const Size(360, 800),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
