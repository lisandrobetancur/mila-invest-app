import 'package:app_cross_typing/app_cross_typing.dart';
import 'package:authentication_typing/authentication_typing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mila_invest_app/router/app_redirect.dart';
import 'package:navigator/navigator.dart';
import 'package:typing/typing.dart';

const User _user = User(
  id: 'usr_1',
  email: 'demo@milainvest.app',
  fullName: 'Camila Demo',
  country: Country.co,
  baseCurrency: Currency.cop,
  documentType: DocumentType.cc,
  documentLast4: '5678',
);

String? _resolve(
  String location, {
  required BootstrapGate gate,
  SessionState session = const SessionState.unauthenticated(),
  bool onboardingSeen = true,
}) => AppRedirect(
  gate: gate,
  session: session,
  preferences: AppPreferences(onboardingSeen: onboardingSeen),
).resolve(Uri.parse(location));

void main() {
  test('mientras arranca, todo va al splash y la ubicación se estaciona', () {
    final BootstrapGate gate = BootstrapGate();

    expect(_resolve('/market/instrument/BAP-PE', gate: gate), '/');
    expect(_resolve('/', gate: gate), isNull);
    expect(gate.parkedLocation, '/market/instrument/BAP-PE');
  });

  test('sin sesión y sin onboarding visto, va al onboarding', () {
    final BootstrapGate gate = BootstrapGate()..markReady();

    expect(_resolve('/', gate: gate, onboardingSeen: false), '/onboarding');
    expect(_resolve('/onboarding', gate: gate, onboardingSeen: false), isNull);
  });

  test('sin sesión, una ruta protegida va al login y se estaciona', () {
    final BootstrapGate gate = BootstrapGate()..markReady();

    expect(_resolve('/portfolio', gate: gate), '/login');
    expect(gate.parkedLocation, '/portfolio');
    expect(_resolve('/register', gate: gate), isNull);
    expect(_resolve('/', gate: gate), '/login');
  });

  test('con sesión, las rutas públicas van a lo estacionado o al inicio', () {
    final BootstrapGate gate = BootstrapGate()
      ..markReady()
      ..park('/market/instrument/BAP-PE');
    const SessionState session = SessionState.authenticated(_user);

    expect(
      _resolve('/login', gate: gate, session: session),
      '/market/instrument/BAP-PE',
    );
    expect(_resolve('/login', gate: gate, session: session), '/home');
    expect(_resolve('/portfolio', gate: gate, session: session), isNull);
  });

  group('qué se estaciona', () {
    const List<String> publicRoutes = <String>[
      '/',
      '/onboarding',
      '/login',
      '/register',
    ];
    const List<String> protectedRoutes = <String>[
      '/home',
      '/market/instrument/ECOPETROL-CO',
      '/wallet',
      '/activity',
    ];

    for (final bool ready in <bool>[false, true]) {
      final String gateLabel = ready ? 'gate abierto' : 'gate cerrado';

      for (final String route in publicRoutes) {
        test('$route ($gateLabel) no se estaciona', () {
          final BootstrapGate gate = BootstrapGate();
          if (ready) {
            gate.markReady();
          }

          _resolve(route, gate: gate);

          expect(gate.parkedLocation, isNull);
        });
      }

      for (final String route in protectedRoutes) {
        test('$route ($gateLabel) se estaciona', () {
          final BootstrapGate gate = BootstrapGate();
          if (ready) {
            gate.markReady();
          }

          _resolve(route, gate: gate);

          expect(gate.parkedLocation, route);
        });
      }
    }
  });

  test('abrir /login mientras arranca y autenticarse va al inicio, no al '
      'login', () {
    final BootstrapGate gate = BootstrapGate();
    const SessionState session = SessionState.authenticated(_user);

    expect(_resolve('/login', gate: gate), '/');
    gate.markReady();
    expect(_resolve('/', gate: gate), '/login');
    expect(_resolve('/login', gate: gate), isNull);
    expect(_resolve('/login', gate: gate, session: session), '/home');
  });

  test('un deep link protegido abierto mientras arranca vuelve después del '
      'login', () {
    final BootstrapGate gate = BootstrapGate();
    const SessionState session = SessionState.authenticated(_user);

    expect(_resolve('/market/instrument/ISA-CO', gate: gate), '/');
    gate.markReady();
    expect(_resolve('/', gate: gate), '/login');
    expect(
      _resolve('/login', gate: gate, session: session),
      '/market/instrument/ISA-CO',
    );
  });

  test('un deep link con el scheme propio se normaliza', () {
    final BootstrapGate gate = BootstrapGate()..markReady();

    expect(
      _resolve('milainvest://market/instrument/ECOPETROL-CO', gate: gate),
      '/market/instrument/ECOPETROL-CO',
    );
  });
}
