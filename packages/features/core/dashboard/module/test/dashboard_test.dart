import 'dart:async';

import 'package:authentication_typing/authentication_typing.dart';
import 'package:dashboard/core/data/dashboard_remote_data_source.dart';
import 'package:dashboard/core/service/service.dart';
import 'package:dashboard/dashboard.dart';
import 'package:dashboard/ui/views/home/home.dart';
import 'package:dashboard_constants/dashboard_constants.dart';
import 'package:dashboard_typing/dashboard_typing.dart';
import 'package:fake_backend/fake_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:navigator/navigator.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';
import 'package:wallet_typing/wallet_typing.dart';

import 'support/harness.dart';

class _MockService extends Mock implements IDashboardService {}

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

Future<DashboardService> _serviceOnFake(FakeSeed seed) async {
  final InMemoryTokenStore store = InMemoryTokenStore();
  final FakeApiClient client = FakeApiClient(
    tokenStore: store,
    sessionEvents: SessionEvents(),
    clock: FixedClock(DateTime.utc(2026, 11, 18, 14, 42)),
    seed: seed,
  );
  final JsonReader tokens = JsonReader.of(
    (await client.post(
      '/auth/login',
      body: <String, Object?>{
        'email': FakeDemoAccount.email,
        'password': FakeDemoAccount.password,
      },
    )).body,
  );
  await store.save(
    AuthTokens(
      accessToken: tokens.string('access_token'),
      refreshToken: tokens.string('refresh_token'),
    ),
  );
  return DashboardService(dataSource: DashboardRemoteDataSource(client));
}

final class _Doubles {
  _Doubles(this.answer) {
    when(() => navigation.push<void>(any())).thenAnswer((_) async {});
    when(service.summary).thenAnswer((_) => answer());
  }

  final Future<DashboardSummary> Function() answer;
  final _MockService service = _MockService();
  final _MockNavigation navigation = _MockNavigation();

  List<Override> overrides() => <Override>[
    dashboardServiceProvider.overrideWithValue(service),
    navigationManagerProvider.overrideWithValue(navigation),
    loggerProvider.overrideWithValue(const SilentAppLogger()),
    sessionProvider.overrideWithValue(const SessionState.authenticated(_user)),
    accountsProvider.overrideWith((Ref ref) async => <Account>[]),
  ];
}

void main() {
  late DashboardSummary demo;
  late DashboardSummary empty;

  setUpAll(() async {
    demo = await (await _serviceOnFake(FakeSeed.demo)).summary();
    empty = await (await _serviceOnFake(FakeSeed.empty)).summary();
  });

  group('DashboardIds y traducciones', () {
    test('ids válidos y únicos; es y en con las mismas claves', () {
      for (final String id in DashboardIds.all) {
        expect(identifierPattern.hasMatch(id), isTrue, reason: id);
      }
      expect(DashboardIds.all.toSet().length, DashboardIds.all.length);
      final Set<String> es = translationKeys(dashboardLanguages['es']!);
      final Set<String> en = translationKeys(dashboardLanguages['en']!);
      expect(es.difference(en), isEmpty);
      expect(en.difference(es), isEmpty);
      for (final DashboardErrorCode code in DashboardErrorCode.values) {
        expect(es, contains(code.messageKey));
      }
    });
  });

  group('DashboardService contra el backend falso', () {
    test('lee portafolio, top movers y últimos 5 movimientos', () {
      expect(demo.portfolio.baseCurrency, Currency.cop);
      expect(demo.gainers.first.id, 'ECOPETROL-CO');
      expect(demo.losers, hasLength(3));
      expect(demo.recentTransactions, hasLength(5));
      expect(demo.isNewUser, isFalse);
      expect(empty.isNewUser, isTrue);
    });
  });

  group('DashboardHomeView', () {
    Future<void> show(
      WidgetTester tester,
      _Doubles doubles, {
      Size size = const Size(390, 844),
      double textScale = 1,
    }) async {
      await pumpView(
        tester,
        MediaQueryTextScale(scale: textScale, child: const DashboardHomeView()),
        languages: dashboardLanguages,
        overrides: doubles.overrides(),
        size: size,
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('loading', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await show(tester, _Doubles(() => Completer<DashboardSummary>().future));

      expect(find.bySemanticsIdentifier(DashboardIds.homeView), findsOneWidget);
      expect(
        find.bySemanticsIdentifier(DashboardIds.homeStateLoading),
        findsOneWidget,
      );
      expect(labelOf(tester, DashboardIds.homeGreetingText), 'Hola, Camila');
      expect(labelOf(tester, DashboardIds.homeSimulatedText), 'Simulado');
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('data: total, distribución, movers y recientes', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles(() async => demo);
      await show(tester, doubles);

      expect(
        find.bySemanticsIdentifier(DashboardIds.homeStateData),
        findsOneWidget,
      );
      expect(
        labelOf(tester, DashboardIds.homeTotalText),
        endsWith('pesos colombianos'),
      );
      expect(
        find.bySemanticsIdentifier(DashboardIds.moverItem('ECOPETROL-CO')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(
          DashboardIds.recentItem(demo.recentTransactions.first.id),
        ),
        findsOneWidget,
      );
      expectNoDuplicateIdentifiers(tester);

      await tester.tap(
        find.bySemanticsIdentifier(DashboardIds.homeWalletIconButton),
      );
      verify(() => doubles.navigation.push<void>('/wallet')).called(1);
      await tester.tap(
        find.bySemanticsIdentifier(DashboardIds.homeSettingsIconButton),
      );
      verify(() => doubles.navigation.push<void>('/settings')).called(1);
      final Finder seeAll = find.bySemanticsIdentifier(
        DashboardIds.homeRecentAllButton,
      );
      await tester.ensureVisible(seeAll);
      await tester.tap(seeAll);
      verify(() => doubles.navigation.go('/activity')).called(1);
      handle.dispose();
    });

    testWidgets('empty: el usuario nuevo ve "Haz tu primer depósito"', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles(() async => empty);
      await show(tester, doubles);

      expect(
        labelOf(tester, DashboardIds.homeEmptyTitleText),
        'Haz tu primer depósito',
      );
      await tester.tap(
        find.bySemanticsIdentifier(DashboardIds.homeEmptyDepositButton),
      );
      verify(
        () => doubles.navigation.push<void>('/wallet/deposit/COP'),
      ).called(1);
      handle.dispose();
    });

    testWidgets('error: mensaje y "Reintentar"', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await show(
        tester,
        _Doubles(
          () async =>
              throw const DashboardException(DashboardErrorCode.network),
        ),
      );

      expect(
        find.bySemanticsIdentifier(DashboardIds.homeStateError),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(DashboardIds.homeRetryButton),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('grilla de 3 columnas en web ancho y sin desbordes al 200 %', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await show(
        tester,
        _Doubles(() async => demo),
        size: const Size(1440, 900),
      );
      await tester.pumpAndSettle();
      final Offset total = tester.getTopLeft(
        find.bySemanticsIdentifier(DashboardIds.homeTotalTile),
      );
      final Offset allocation = tester.getTopLeft(
        find.bySemanticsIdentifier(DashboardIds.homeAllocationChart),
      );
      expect(allocation.dx, greaterThan(total.dx));
      expect(tester.takeException(), isNull);

      await show(
        tester,
        _Doubles(() async => demo),
        size: const Size(360, 800),
        textScale: 2,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      handle.dispose();
    });
  });
}
