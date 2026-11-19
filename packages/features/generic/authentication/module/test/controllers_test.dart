import 'dart:async';

import 'package:authentication/authentication.dart';
import 'package:authentication_typing/authentication_typing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:navigator/navigator.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

class _MockService extends Mock implements IAuthenticationService {}

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

const RegistrationData _anyRegistration = RegistrationData(
  email: 'a@b.co',
  password: 'Segura123',
  fullName: 'Ana',
  country: Country.co,
  documentType: DocumentType.cc,
  documentNumber: '123456',
);

final class _Harness {
  _Harness() {
    when(() => navigation.location).thenReturn('/settings');
    when(service.logout).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: <Override>[
        authenticationServiceProvider.overrideWithValue(service),
        navigationManagerProvider.overrideWithValue(navigation),
        sessionEventsProvider.overrideWithValue(events),
        loggerProvider.overrideWithValue(const SilentAppLogger()),
        sessionProviderOverride,
        sessionManagerProviderOverride,
      ],
    );
    addTearDown(container.dispose);
  }

  final _MockService service = _MockService();
  final _MockNavigation navigation = _MockNavigation();
  final SessionEvents events = SessionEvents();
  late final ProviderContainer container;

  SessionState get session => container.read(sessionProvider);

  ProviderSubscription<T> keep<T>(ProviderListenable<T> provider) =>
      container.listen<T>(provider, (T? previous, T next) {});
}

void main() {
  setUpAll(() => registerFallbackValue(_anyRegistration));

  group('SessionViewModel', () {
    test('empieza unknown y restore resuelve authenticated', () async {
      final _Harness harness = _Harness();
      when(harness.service.restoreSession).thenAnswer((_) async => _user);

      expect(harness.session.isUnknown, isTrue);
      await harness.container.read(sessionManagerProvider).restore();

      expect(harness.session, const SessionState.authenticated(_user));
    });

    test('restore sin sesión queda unauthenticated', () async {
      final _Harness harness = _Harness();
      when(harness.service.restoreSession).thenAnswer((_) async => null);

      await harness.container.read(sessionManagerProvider).restore();

      expect(harness.session, const SessionState.unauthenticated());
    });

    test('restore propaga un error de red y la sesión sigue unknown', () async {
      final _Harness harness = _Harness();
      when(
        harness.service.restoreSession,
      ).thenThrow(const AuthException(AuthErrorCode.network));

      await expectLater(
        harness.container.read(sessionManagerProvider).restore(),
        throwsA(isA<AuthException>()),
      );
      expect(harness.session.isUnknown, isTrue);
    });

    test('el aviso de sesión expirada cierra la sesión', () async {
      final _Harness harness = _Harness()..keep(sessionProvider);
      harness.container
          .read(sessionViewModelProvider.notifier)
          .authenticate(_user);

      harness.events.notifyExpired();
      await Future<void>.delayed(Duration.zero);

      expect(harness.session, const SessionState.unauthenticated());
    });

    test('signOut olvida la ubicación actual y cierra la sesión', () async {
      final _Harness harness = _Harness();
      harness.container.read(bootstrapGateProvider).park('/portfolio');
      harness.container
          .read(sessionViewModelProvider.notifier)
          .authenticate(_user);

      await harness.container.read(sessionManagerProvider).signOut();
      harness.container.read(bootstrapGateProvider).park('/settings');

      expect(harness.session, const SessionState.unauthenticated());
      expect(harness.container.read(bootstrapGateProvider).take(), isNull);
      verify(harness.service.logout).called(1);
    });
  });

  group('LoginViewModel', () {
    test('un formulario inválido no llama al servicio y muestra errores', () {
      final _Harness harness = _Harness();
      final ProviderSubscription<LoginState> state = harness.keep(
        loginViewModelProvider,
      );

      harness.container.read(loginViewModelProvider.notifier)
        ..setEmail('no-es-email')
        ..submit();

      expect(state.read().emailErrorKey, 'auth.field_error.email_invalid');
      expect(
        state.read().passwordErrorKey,
        'auth.field_error.password_required',
      );
      verifyNever(
        () => harness.service.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('inicia sesión con el email normalizado y autentica', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.service.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _user);
      final ProviderSubscription<LoginState> state = harness.keep(
        loginViewModelProvider,
      );
      final LoginViewModel viewModel =
          harness.container.read(loginViewModelProvider.notifier)..useDemo(
            const DemoCredentials(
              email: ' Demo@MilaInvest.app ',
              password: 'Demo1234!',
            ),
          );

      await viewModel.submit();

      expect(state.read().submitStatus, SubmitStatus.success);
      expect(harness.session, const SessionState.authenticated(_user));
      verify(
        () => harness.service.login(
          email: 'demo@milainvest.app',
          password: 'Demo1234!',
        ),
      ).called(1);
    });

    test('un doble toque dispara una sola petición', () async {
      final _Harness harness = _Harness();
      final Completer<User> gate = Completer<User>();
      when(
        () => harness.service.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => gate.future);
      harness.keep(loginViewModelProvider);
      final LoginViewModel viewModel =
          harness.container.read(loginViewModelProvider.notifier)
            ..setEmail('demo@milainvest.app')
            ..setPassword('Demo1234!');

      final Future<void> first = viewModel.submit();
      final Future<void> second = viewModel.submit();
      gate.complete(_user);
      await Future.wait(<Future<void>>[first, second]);

      verify(
        () => harness.service.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).called(1);
    });

    test('credenciales incorrectas guardan la clave del mensaje', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.service.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException(AuthErrorCode.invalidCredentials));
      final ProviderSubscription<LoginState> state = harness.keep(
        loginViewModelProvider,
      );
      final LoginViewModel viewModel =
          harness.container.read(loginViewModelProvider.notifier)
            ..setEmail('demo@milainvest.app')
            ..setPassword('mal');

      await viewModel.submit();

      expect(state.read().submitStatus, SubmitStatus.failure);
      expect(
        state.read().errorKey,
        AuthErrorCode.invalidCredentials.messageKey,
      );
      expect(harness.session.isAuthenticated, isFalse);

      viewModel.setPassword('otra');
      expect(state.read().errorKey, isNull);
    });
  });

  group('RegisterState', () {
    test('copyWith pone en null con el sentinel', () {
      const RegisterState state = RegisterState(
        country: Country.co,
        documentType: DocumentType.cc,
        errorKey: 'auth.error.network',
      );

      expect(state.copyWith().country, Country.co);
      expect(state.copyWith(country: null).country, isNull);
      expect(state.copyWith(errorKey: null).errorKey, isNull);
      expect(state.copyWith(), state);
    });

    test('valida el documento según el país y el tipo', () {
      const RegisterState valid = RegisterState(
        country: Country.mx,
        documentType: DocumentType.curp,
        fullName: 'María López',
        email: 'maria@correo.mx',
        documentNumber: 'magl850315mdfrrs09',
        password: 'Segura123',
        showValidation: true,
      );

      expect(valid.isValid, isTrue);
      expect(valid.canSubmit, isFalse);
      expect(valid.copyWith(accepted: true).canSubmit, isTrue);
      expect(
        valid
            .copyWith(documentNumber: '123')
            .errorKeyOf(AuthField.documentNumber),
        'auth.field_error.document_curp_invalid',
      );
      expect(valid.toData().documentNumber, 'MAGL850315MDFRRS09');
    });

    test(
      'los errores del cliente aparecen solo después de intentar enviar',
      () {
        const RegisterState state = RegisterState();

        expect(state.errorKeyOf(AuthField.country), isNull);
        expect(
          state.copyWith(showValidation: true).errorKeyOf(AuthField.country),
          'auth.field_error.country_required',
        );
        expect(
          state.copyWith(showValidation: true).acceptErrorKey,
          'auth.field_error.accept_required',
        );
      },
    );
  });

  group('RegisterViewModel', () {
    test('cambiar de país actualiza los tipos y limpia el documento', () {
      final _Harness harness = _Harness();
      final ProviderSubscription<RegisterState> state = harness.keep(
        registerViewModelProvider,
      );

      harness.container.read(registerViewModelProvider.notifier)
        ..setCountry(Country.co)
        ..setDocumentNumber('1012345678')
        ..setCountry(Country.pe);

      expect(state.read().documentTypes, <DocumentType>[
        DocumentType.dni,
        DocumentType.ce,
      ]);
      expect(state.read().documentType, DocumentType.dni);
      expect(state.read().documentNumber, isEmpty);
    });

    test('sin aceptar el aviso no envía', () async {
      final _Harness harness = _Harness()..keep(registerViewModelProvider);
      final RegisterViewModel viewModel =
          harness.container.read(registerViewModelProvider.notifier)
            ..setCountry(Country.co)
            ..setFullName('Ana Ruiz')
            ..setEmail('ana@correo.co')
            ..setDocumentNumber('52345678')
            ..setPassword('Segura123');

      await viewModel.submit();

      verifyNever(() => harness.service.register(any()));
    });

    test('registra, autentica y muestra los errores de campo inline', () async {
      final _Harness harness = _Harness();
      when(() => harness.service.register(any())).thenThrow(
        const AuthException(
          AuthErrorCode.emailTaken,
          fieldMessageKeys: <AuthField, String>{
            AuthField.email: 'auth.error.email_taken',
          },
        ),
      );
      final ProviderSubscription<RegisterState> state = harness.keep(
        registerViewModelProvider,
      );
      final RegisterViewModel viewModel =
          harness.container.read(registerViewModelProvider.notifier)
            ..setCountry(Country.co)
            ..setFullName('Ana Ruiz')
            ..setEmail('demo@milainvest.app')
            ..setDocumentNumber('52345678')
            ..setPassword('Segura123')
            ..setAccepted(accepted: true);

      await viewModel.submit();
      expect(
        state.read().errorKeyOf(AuthField.email),
        'auth.error.email_taken',
      );
      expect(state.read().errorKey, isNull);

      viewModel.setEmail('ana@correo.co');
      expect(state.read().errorKeyOf(AuthField.email), isNull);

      when(
        () => harness.service.register(any()),
      ).thenAnswer((_) async => _user);
      await viewModel.submit();

      expect(state.read().submitStatus, SubmitStatus.success);
      expect(harness.session.isAuthenticated, isTrue);
      final RegistrationData sent =
          verify(() => harness.service.register(captureAny())).captured.last
              as RegistrationData;
      expect(sent.email, 'ana@correo.co');
      expect(sent.country, Country.co);
    });

    test('un error de red se muestra como mensaje general', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.service.register(any()),
      ).thenThrow(const AuthException(AuthErrorCode.network));
      final ProviderSubscription<RegisterState> state = harness.keep(
        registerViewModelProvider,
      );
      final RegisterViewModel viewModel =
          harness.container.read(registerViewModelProvider.notifier)
            ..setCountry(Country.co)
            ..setFullName('Ana Ruiz')
            ..setEmail('ana@correo.co')
            ..setDocumentNumber('52345678')
            ..setPassword('Segura123')
            ..setAccepted(accepted: true);

      await viewModel.submit();

      expect(state.read().errorKey, AuthErrorCode.network.messageKey);
      expect(state.read().isNetworkError, isTrue);
    });
  });
}
