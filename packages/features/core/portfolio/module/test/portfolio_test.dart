import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:navigator/navigator.dart';
import 'package:network/network.dart';
import 'package:portfolio/core/data/dto/portfolio_dto.dart';
import 'package:portfolio/core/data/portfolio_remote_data_source.dart';
import 'package:portfolio/core/service/service.dart';
import 'package:portfolio/portfolio.dart';
import 'package:portfolio/ui/views/overview/overview.dart';
import 'package:portfolio_constants/portfolio_constants.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';
import 'package:wallet_typing/wallet_typing.dart';

import 'support/harness.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockNavigation extends Mock implements NavigationManager {}

const Map<String, Object?> _instrument = <String, Object?>{
  'id': 'ECOPETROL-CO',
  'ticker': 'ECOPETROL',
  'name': 'Ecopetrol S.A.',
  'country': 'CO',
  'type': 'STOCK',
  'currency': 'COP',
  'last_price': '2385.00',
  'change': '35.00',
  'change_pct': '1.49',
  'updated_at': '2026-11-18T14:42:00Z',
};

Map<String, Object?> _json({bool positions = true}) => <String, Object?>{
  'base_currency': 'COP',
  'total_value': '1000000.00',
  'cash_value': '713800.00',
  'invested_value': '286200.00',
  'day_change': '4200.00',
  'day_change_pct': '0.42',
  'positions': <Object?>[
    if (positions)
      <String, Object?>{
        'instrument': _instrument,
        'quantity': 120,
        'avg_cost': '2210.50',
        'market_value': '286200.00',
        'unrealized_pnl': '20940.00',
        'unrealized_pnl_pct': '7.89',
        'currency': 'COP',
      },
  ],
  'allocation': <Object?>[
    if (positions)
      <String, Object?>{'type': 'STOCK', 'value': '286200.00', 'pct': '28.62'},
    <String, Object?>{'type': 'CASH', 'value': '713800.00', 'pct': '71.38'},
  ],
  'fx_rates_used': <Object?>[
    <String, Object?>{
      'from': 'MXN',
      'to': 'COP',
      'rate': '215.00000000',
      'as_of': '2026-11-18T14:42:00Z',
    },
  ],
};

Portfolio _portfolio({bool positions = true}) =>
    PortfolioDto.fromJson(_json(positions: positions)).toDomain();

final class _Doubles {
  _Doubles({Future<Portfolio> Function()? load}) {
    when(() => navigation.go(any())).thenReturn(null);
    _load = load ?? () async => _portfolio();
  }

  final _MockNavigation navigation = _MockNavigation();
  late Future<Portfolio> Function() _load;
  int fetches = 0;

  List<Override> overrides() => <Override>[
    navigationManagerProvider.overrideWithValue(navigation),
    loggerProvider.overrideWithValue(const SilentAppLogger()),
    portfolioProvider.overrideWith((Ref ref) {
      fetches++;
      return _load();
    }),
    accountsProvider.overrideWith((Ref ref) async => <Account>[]),
  ];
}

void main() {
  group('PortfolioIds y traducciones', () {
    test('ids válidos y únicos; es y en con las mismas claves', () {
      for (final String id in PortfolioIds.all) {
        expect(identifierPattern.hasMatch(id), isTrue, reason: id);
      }
      expect(PortfolioIds.all.toSet().length, PortfolioIds.all.length);
      expect(
        PortfolioIds.positionPnlText('BAP-PE'),
        'portfolio_position_item_BAP-PE_pnl_text',
      );
      final Set<String> es = translationKeys(portfolioLanguages['es']!);
      final Set<String> en = translationKeys(portfolioLanguages['en']!);
      expect(es.difference(en), isEmpty);
      expect(en.difference(es), isEmpty);
      for (final AllocationType type in AllocationType.values) {
        expect(es, contains('portfolio.allocation.${type.name}'));
      }
      for (final PortfolioErrorCode code in PortfolioErrorCode.values) {
        expect(es, contains(code.messageKey));
      }
    });
  });

  group('PortfolioDto', () {
    test('parsea totales, posiciones, distribución y tipos de cambio', () {
      final Portfolio portfolio = _portfolio();

      expect(
        portfolio.summary.totalValue,
        Money.parse('1000000', Currency.cop),
      );
      expect(portfolio.positions.single.quantity, 120);
      expect(portfolio.quantityOf('ECOPETROL-CO'), 120);
      expect(portfolio.quantityOf('BAP-PE'), 0);
      expect(portfolio.summary.allocation.first.type, AllocationType.stock);
      expect(portfolio.fxRates.single.from, Currency.mxn);
    });

    test('rechaza un monto numérico y un tipo de asignación desconocido es '
        'other', () {
      expect(
        () => PortfolioDto.fromJson(<String, Object?>{
          ..._json(),
          'total_value': 1000000,
        }),
        throwsFormatException,
      );
      final Portfolio portfolio = PortfolioDto.fromJson(<String, Object?>{
        ..._json(),
        'allocation': <Object?>[
          <String, Object?>{'type': 'CDT', 'value': '1.00', 'pct': '1.00'},
        ],
      }).toDomain();
      expect(portfolio.summary.allocation.single.type, AllocationType.other);
    });
  });

  group('PortfolioService', () {
    test('traduce errores', () async {
      final _MockApiClient client = _MockApiClient();
      when(
        () => client.get('/portfolio'),
      ).thenThrow(const ApiException.networkUnavailable());
      final PortfolioService service = PortfolioService(
        dataSource: PortfolioRemoteDataSource(client),
      );

      await expectLater(
        service.portfolio(),
        throwsA(
          isA<PortfolioException>().having(
            (PortfolioException e) => e.code,
            'code',
            PortfolioErrorCode.network,
          ),
        ),
      );
    });
  });

  group('PortfolioOverviewViewModel', () {
    test(
      'un depósito (accountsProvider invalidado) recarga el portafolio',
      () async {
        final _Doubles doubles = _Doubles();
        final ProviderContainer container = ProviderContainer(
          overrides: doubles.overrides(),
        );
        addTearDown(container.dispose);
        final ProviderSubscription<PortfolioOverviewState> state = container
            .listen(portfolioOverviewViewModelProvider, (_, _) {});
        for (int i = 0; i < 10; i++) {
          await Future<void>.delayed(Duration.zero);
        }
        expect(state.read().status, ViewStatus.data);
        final int before = doubles.fetches;

        container.invalidate(accountsProvider);
        for (int i = 0; i < 10; i++) {
          await Future<void>.delayed(Duration.zero);
        }

        expect(doubles.fetches, greaterThan(before));
      },
    );
  });

  group('PortfolioOverviewView', () {
    Future<void> show(
      WidgetTester tester,
      _Doubles doubles, {
      Size? size,
    }) async {
      await pumpView(
        tester,
        const PortfolioOverviewView(),
        languages: portfolioLanguages,
        overrides: doubles.overrides(),
        size: size ?? const Size(390, 844),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('loading', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await show(tester, _Doubles(load: () => Completer<Portfolio>().future));

      expect(
        find.bySemanticsIdentifier(PortfolioIds.overviewView),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(PortfolioIds.overviewStateLoading),
        findsOneWidget,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('data: totales, distribución y posiciones con sus partes', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      await show(tester, doubles);

      expect(
        labelOf(tester, PortfolioIds.overviewTotalText),
        '1.000.000 pesos colombianos',
      );
      expect(
        labelOf(tester, PortfolioIds.overviewDayChangeText),
        'sube 4.200 pesos colombianos, 0,42 por ciento',
      );
      expect(
        labelOf(tester, PortfolioIds.overviewAllocationChart),
        contains('Acciones 28,6 %'),
      );
      expect(
        labelOf(tester, PortfolioIds.allocationItem('CASH')),
        contains('Efectivo'),
      );
      const String id = 'ECOPETROL-CO';
      expect(
        labelOf(tester, PortfolioIds.positionQuantityText(id)),
        '120 unidades',
      );
      expect(
        labelOf(tester, PortfolioIds.positionPnlText(id)),
        'sube 20.940 pesos colombianos, 7,89 por ciento',
      );
      expect(
        labelOf(tester, PortfolioIds.overviewFxText),
        contains('1 MXN = 215 COP'),
      );
      expectNoDuplicateIdentifiers(tester);

      final Finder item = find.bySemanticsIdentifier(
        PortfolioIds.positionItem(id),
      );
      await tester.ensureVisible(item);
      await tester.tap(item);
      verify(
        () => doubles.navigation.go('/market/instrument/ECOPETROL-CO'),
      ).called(1);
      handle.dispose();
    });

    testWidgets('empty: sin inversiones invita a explorar el mercado', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles(
        load: () async => _portfolio(positions: false),
      );
      await show(tester, doubles);

      expect(
        labelOf(tester, PortfolioIds.overviewEmptyTitleText),
        'Aún no tienes inversiones',
      );
      await tester.tap(
        find.bySemanticsIdentifier(PortfolioIds.overviewExploreButton),
      );
      verify(() => doubles.navigation.go('/market')).called(1);
      handle.dispose();
    });

    testWidgets('error: mensaje y "Reintentar"', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await show(
        tester,
        _Doubles(
          load: () async =>
              throw const PortfolioException(PortfolioErrorCode.network),
        ),
      );

      expect(
        find.bySemanticsIdentifier(PortfolioIds.overviewStateError),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(PortfolioIds.overviewRetryButton),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('no desborda en 360 px con el texto al 200 % ni en web', (
      WidgetTester tester,
    ) async {
      await pumpView(
        tester,
        const MediaQueryTextScale(scale: 2, child: PortfolioOverviewView()),
        languages: portfolioLanguages,
        overrides: _Doubles().overrides(),
        size: const Size(360, 800),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await show(tester, _Doubles(), size: const Size(1440, 900));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
