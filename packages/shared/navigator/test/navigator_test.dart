import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:navigator/navigator.dart';

GoRouter _router() => GoRouter(
  initialLocation: '/market',
  routes: <RouteBase>[
    AppRoute(
      '/market',
      name: 'market',
      widget: (BuildContext context, AppRouteParams params) =>
          Text('mercado ${params.query('country') ?? '-'}'),
      routes: <AppRoute>[
        AppRoute(
          'instrument/:id',
          name: 'instrument',
          widget: (BuildContext context, AppRouteParams params) =>
              Text('detalle ${params.path('id')}'),
        ),
      ],
    ).toGoRoute(),
    AppRoute(
      '/ticket/:id',
      name: 'ticket',
      presentation: AppRoutePresentation.modal,
      widget: (BuildContext context, AppRouteParams params) =>
          Text('ticket ${params.path('id')}'),
    ).toGoRoute(),
  ],
);

void main() {
  group('DeepLinks.normalize', () {
    test('convierte el scheme propio en una ubicación interna', () {
      expect(
        DeepLinks.normalize(
          Uri.parse('milainvest://market/instrument/ECOPETROL-CO'),
        ),
        '/market/instrument/ECOPETROL-CO',
      );
      expect(
        DeepLinks.normalize(Uri.parse('milainvest://portfolio')),
        '/portfolio',
      );
      expect(DeepLinks.normalize(Uri.parse('milainvest://')), '/');
    });

    test('conserva el path de una URL web y la query', () {
      expect(
        DeepLinks.normalize(
          Uri.parse('https://app.milainvest.app/market?country=CO&type=ETF'),
        ),
        '/market?country=CO&type=ETF',
      );
      expect(
        DeepLinks.normalize(Uri.parse('milainvest://market?country=PE')),
        '/market?country=PE',
      );
    });

    test('reconoce el scheme de la app', () {
      expect(DeepLinks.isAppLink(Uri.parse('milainvest://market')), isTrue);
      expect(DeepLinks.isAppLink(Uri.parse('https://x.y/market')), isFalse);
    });
  });

  group('BootstrapGate', () {
    test('estaciona una ubicación y la entrega una sola vez', () {
      final BootstrapGate gate = BootstrapGate()
        ..park('/market/instrument/ECOPETROL-CO');

      expect(gate.parkedLocation, '/market/instrument/ECOPETROL-CO');
      expect(gate.take(), '/market/instrument/ECOPETROL-CO');
      expect(gate.take(), isNull);
    });

    test('la última ubicación estacionada gana', () {
      final BootstrapGate gate = BootstrapGate()
        ..park('/portfolio')
        ..park('/market');

      expect(gate.take(), '/market');
    });

    test('recuerda que el bootstrap terminó', () {
      final BootstrapGate gate = BootstrapGate();

      expect(gate.isReady, isFalse);
      gate.markReady();

      expect(gate.isReady, isTrue);
    });

    test('tras un logout no estaciona la pantalla desde la que se salió', () {
      final BootstrapGate gate = BootstrapGate()
        ..park('/portfolio')
        ..forget(ignoring: '/settings')
        ..park('/settings')
        ..park('/settings');

      expect(gate.parkedLocation, isNull);

      gate.park('/market/instrument/BAP-PE');
      expect(gate.take(), '/market/instrument/BAP-PE');

      gate.park('/settings');
      expect(gate.take(), '/settings');
    });
  });

  group('AppRoute y NavigationManager', () {
    testWidgets('resuelve path params, query y rutas hijas', (
      WidgetTester tester,
    ) async {
      final GoRouter router = _router();
      addTearDown(router.dispose);
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[goRouterProvider.overrideWithValue(router)],
      );
      addTearDown(container.dispose);
      final NavigationManager navigation = container.read(
        navigationManagerProvider,
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.text('mercado -'), findsOneWidget);

      navigation.go('/market?country=CO');
      await tester.pumpAndSettle();
      expect(find.text('mercado CO'), findsOneWidget);

      navigation.goNamed(
        'instrument',
        pathParameters: <String, String>{'id': 'ECOPETROL-CO'},
      );
      await tester.pumpAndSettle();
      expect(find.text('detalle ECOPETROL-CO'), findsOneWidget);
      expect(navigation.pathParamOf('id'), 'ECOPETROL-CO');
      expect(navigation.location, '/market/instrument/ECOPETROL-CO');
      expect(
        navigation.namedLocation(
          'instrument',
          pathParameters: <String, String>{'id': 'BAP-PE'},
        ),
        '/market/instrument/BAP-PE',
      );

      navigation.pop<void>();
      await tester.pumpAndSettle();
      expect(find.text('mercado -'), findsOneWidget);
    });

    for (final (Size size, Type presentation) in <(Size, Type)>[
      (const Size(360, 800), BottomSheet),
      (const Size(1440, 900), Dialog),
    ]) {
      testWidgets('una ruta modal apilada se presenta como $presentation a '
          '${size.width.toInt()} px', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final GoRouter router = _router();
        addTearDown(router.dispose);
        final NavigationManager navigation = NavigationManager(router);
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        final Future<void> closed = navigation.pushNamed<void>(
          'ticket',
          pathParameters: <String, String>{'id': 'BAP-PE'},
        );
        await tester.pumpAndSettle();

        expect(find.text('ticket BAP-PE'), findsOneWidget);
        expect(find.text('mercado -'), findsOneWidget);
        expect(find.byType(presentation), findsOneWidget);

        navigation.pop<void>();
        await tester.pumpAndSettle();
        await closed;
        expect(find.text('ticket BAP-PE'), findsNothing);
      });
    }

    testWidgets('una ruta modal en frío se presenta como página', (
      WidgetTester tester,
    ) async {
      final GoRouter router = _router();
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      router.go('/ticket/BAP-PE');
      await tester.pumpAndSettle();

      expect(find.text('ticket BAP-PE'), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(Dialog), findsNothing);
    });

    test('AppRouteParams falla claro si falta un path param', () {
      const AppRouteParams params = AppRouteParams(location: '/market');

      expect(() => params.path('id'), throwsStateError);
      expect(params.query('country'), isNull);
    });
  });
}
