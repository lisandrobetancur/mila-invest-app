import 'dart:ui' show CheckedState, Tristate;

import 'package:authentication/authentication.dart';
import 'package:authentication/ui/views/login/login.dart';
import 'package:authentication/ui/views/register/register.dart';
import 'package:authentication_constants/authentication_constants.dart';
import 'package:authentication_typing/authentication_typing.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:navigator/navigator.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';

import 'support/harness.dart';

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

const DemoCredentials _demo = DemoCredentials(
  email: 'demo@milainvest.app',
  password: 'Demo1234!',
);

final class _Doubles {
  _Doubles() {
    when(() => navigation.location).thenReturn('/login');
  }

  final _MockService service = _MockService();
  final _MockNavigation navigation = _MockNavigation();

  List<Override> overrides({DemoCredentials? demo}) => <Override>[
    authenticationServiceProvider.overrideWithValue(service),
    navigationManagerProvider.overrideWithValue(navigation),
    sessionEventsProvider.overrideWithValue(SessionEvents()),
    demoCredentialsProvider.overrideWithValue(demo),
    sessionProviderOverride,
  ];
}

SemanticsData _data(WidgetTester tester, String id) =>
    tester.getSemantics(find.bySemanticsIdentifier(id)).getSemanticsData();

Future<void> _tap(WidgetTester tester, String id) async {
  final Finder finder = find.bySemanticsIdentifier(id);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  setUpAll(
    () => registerFallbackValue(
      const RegistrationData(
        email: 'a@b.co',
        password: 'x',
        fullName: 'x',
        country: Country.co,
        documentType: DocumentType.cc,
        documentNumber: 'x',
      ),
    ),
  );

  group('LoginView', () {
    testWidgets('muestra sus controles con id en el nodo correcto', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpView(
        tester,
        const LoginView(),
        languages: authenticationLanguages,
        overrides: _Doubles().overrides(),
      );

      expect(find.bySemanticsIdentifier(AuthIds.loginView), findsOneWidget);
      expect(labelOf(tester, AuthIds.loginSimulatedText), 'Simulado');
      expect(
        _data(tester, AuthIds.loginEmailField).flagsCollection.isTextField,
        isTrue,
      );
      expect(
        _data(tester, AuthIds.loginPasswordField).flagsCollection.isTextField,
        isTrue,
      );
      for (final String id in <String>[
        AuthIds.loginSubmitButton,
        AuthIds.loginRegisterLink,
        AuthIds.loginPasswordToggle,
      ]) {
        final SemanticsData data = _data(tester, id);
        expect(data.flagsCollection.isButton, isTrue, reason: id);
        expect(data.hasAction(SemanticsAction.tap), isTrue, reason: id);
      }
      expect(find.bySemanticsIdentifier(AuthIds.loginDemoButton), findsNothing);
      expect(
        labelOf(tester, AuthIds.loginDisclaimerText),
        contains('No es asesoría financiera'),
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('con modo fake ofrece la cuenta demo y entra con ella', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.service.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _user);
      await pumpView(
        tester,
        const LoginView(),
        languages: authenticationLanguages,
        overrides: doubles.overrides(demo: _demo),
      );

      await _tap(tester, AuthIds.loginDemoButton);
      expect(find.text('demo@milainvest.app'), findsOneWidget);
      await _tap(tester, AuthIds.loginSubmitButton);
      await tester.pumpAndSettle();

      verify(
        () => doubles.service.login(
          email: 'demo@milainvest.app',
          password: 'Demo1234!',
        ),
      ).called(1);
      handle.dispose();
    });

    testWidgets('valida en el cliente y muestra los errores de campo', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpView(
        tester,
        const LoginView(),
        languages: authenticationLanguages,
        overrides: _Doubles().overrides(),
      );

      await tester.enterText(
        find.bySemanticsIdentifier(AuthIds.loginEmailField),
        'no-es-email',
      );
      await _tap(tester, AuthIds.loginSubmitButton);

      expect(
        labelOf(tester, AppTextField.errorIdOf(AuthIds.loginEmailField)),
        'Escribe un correo válido, sin espacios.',
      );
      expect(
        labelOf(tester, AppTextField.errorIdOf(AuthIds.loginPasswordField)),
        'Escribe tu contraseña.',
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('credenciales incorrectas muestran el banner de error', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.service.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthException(AuthErrorCode.invalidCredentials));
      await pumpView(
        tester,
        const LoginView(),
        languages: authenticationLanguages,
        overrides: doubles.overrides(),
      );

      await tester.enterText(
        find.bySemanticsIdentifier(AuthIds.loginEmailField),
        'demo@milainvest.app',
      );
      await tester.enterText(
        find.bySemanticsIdentifier(AuthIds.loginPasswordField),
        'mal',
      );
      await _tap(tester, AuthIds.loginSubmitButton);
      await tester.pumpAndSettle();

      expect(
        labelOf(tester, AuthIds.loginErrorText),
        startsWith('El correo o la contraseña no coinciden'),
      );
      handle.dispose();
    });

    testWidgets('"Crear cuenta" lleva al registro', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      await pumpView(
        tester,
        const LoginView(),
        languages: authenticationLanguages,
        overrides: doubles.overrides(),
      );

      await _tap(tester, AuthIds.loginRegisterLink);

      verify(() => doubles.navigation.go(AuthRoutes.registerPath)).called(1);
      handle.dispose();
    });
  });

  group('RegisterView', () {
    testWidgets('pide el país primero y luego muestra sus documentos', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpView(
        tester,
        const RegisterView(),
        languages: authenticationLanguages,
        overrides: _Doubles().overrides(),
      );

      expect(find.bySemanticsIdentifier(AuthIds.registerView), findsOneWidget);
      for (final String id in <String>[
        AuthIds.registerCountryCoChip,
        AuthIds.registerCountryMxChip,
        AuthIds.registerCountryPeChip,
      ]) {
        expect(_data(tester, id).flagsCollection.isButton, isTrue, reason: id);
      }
      expect(
        find.bySemanticsIdentifier(AuthIds.registerDocumentField),
        findsNothing,
      );

      await _tap(tester, AuthIds.registerCountryPeChip);

      expect(
        _data(tester, AuthIds.registerCountryPeChip).flagsCollection.isSelected,
        Tristate.isTrue,
      );
      expect(
        find.bySemanticsIdentifier(AuthIds.registerDocumentDniChip),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(AuthIds.registerDocumentCeChip),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(AuthIds.registerDocumentCcChip),
        findsNothing,
      );
      expect(
        _data(
          tester,
          AuthIds.registerDocumentField,
        ).flagsCollection.isTextField,
        isTrue,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('el indicador de requisitos sigue a la contraseña', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpView(
        tester,
        const RegisterView(),
        languages: authenticationLanguages,
        overrides: _Doubles().overrides(),
      );

      expect(
        labelOf(tester, AuthIds.registerRequirementNumberText),
        'Al menos un número, pendiente',
      );
      await tester.enterText(
        find.bySemanticsIdentifier(AuthIds.registerPasswordField),
        'abc1',
      );
      await tester.pump();

      expect(
        labelOf(tester, AuthIds.registerRequirementNumberText),
        'Al menos un número, cumplido',
      );
      expect(
        labelOf(tester, AuthIds.registerRequirementLengthText),
        'Al menos 8 caracteres, pendiente',
      );
      handle.dispose();
    });

    testWidgets('enviar vacío muestra los errores con sus ids', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      await pumpView(
        tester,
        const RegisterView(),
        languages: authenticationLanguages,
        overrides: doubles.overrides(),
      );

      await _tap(tester, AuthIds.registerSubmitButton);

      expect(
        labelOf(tester, AuthIds.registerCountryErrorText),
        'Elige tu país.',
      );
      expect(
        labelOf(tester, AppTextField.errorIdOf(AuthIds.registerNameField)),
        startsWith('Escribe tu nombre completo'),
      );
      expect(
        labelOf(tester, AuthIds.registerAcceptCheckboxErrorText),
        'Tienes que aceptar el aviso para continuar.',
      );
      verifyNever(() => doubles.service.register(any()));
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('completa el formulario, acepta el aviso y se registra', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.service.register(any()),
      ).thenAnswer((_) async => _user);
      await pumpView(
        tester,
        const RegisterView(),
        languages: authenticationLanguages,
        overrides: doubles.overrides(),
      );

      await _tap(tester, AuthIds.registerCountryMxChip);
      await tester.enterText(
        find.bySemanticsIdentifier(AuthIds.registerNameField),
        'María López',
      );
      await tester.enterText(
        find.bySemanticsIdentifier(AuthIds.registerEmailField),
        'Maria@Correo.mx',
      );
      await tester.enterText(
        find.bySemanticsIdentifier(AuthIds.registerDocumentField),
        'magl850315mdfrrs09',
      );
      await tester.enterText(
        find.bySemanticsIdentifier(AuthIds.registerPasswordField),
        'Segura123',
      );
      await _tap(tester, AuthIds.registerAcceptCheckbox);
      expect(
        _data(tester, AuthIds.registerAcceptCheckbox).flagsCollection.isChecked,
        CheckedState.isTrue,
      );
      await _tap(tester, AuthIds.registerSubmitButton);
      await tester.pumpAndSettle();

      final RegistrationData sent =
          verify(() => doubles.service.register(captureAny())).captured.single
              as RegistrationData;
      expect(sent.email, 'maria@correo.mx');
      expect(sent.documentType, DocumentType.curp);
      expect(sent.documentNumber, 'MAGL850315MDFRRS09');
      handle.dispose();
    });

    testWidgets('un documento repetido se muestra inline en su campo', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(() => doubles.service.register(any())).thenThrow(
        const AuthException(
          AuthErrorCode.documentTaken,
          fieldMessageKeys: <AuthField, String>{
            AuthField.documentNumber: 'auth.error.document_taken',
          },
        ),
      );
      await pumpView(
        tester,
        const RegisterView(),
        languages: authenticationLanguages,
        overrides: doubles.overrides(),
      );

      await _tap(tester, AuthIds.registerCountryCoChip);
      await tester.enterText(
        find.bySemanticsIdentifier(AuthIds.registerNameField),
        'Ana Ruiz',
      );
      await tester.enterText(
        find.bySemanticsIdentifier(AuthIds.registerEmailField),
        'ana@correo.co',
      );
      await tester.enterText(
        find.bySemanticsIdentifier(AuthIds.registerDocumentField),
        '1012345678',
      );
      await tester.enterText(
        find.bySemanticsIdentifier(AuthIds.registerPasswordField),
        'Segura123',
      );
      await _tap(tester, AuthIds.registerAcceptCheckbox);
      await _tap(tester, AuthIds.registerSubmitButton);
      await tester.pumpAndSettle();

      expect(
        labelOf(tester, AppTextField.errorIdOf(AuthIds.registerDocumentField)),
        'Ya existe una cuenta con este documento.',
      );
      expect(
        find.bySemanticsIdentifier(AuthIds.registerErrorText),
        findsNothing,
      );
      handle.dispose();
    });

    testWidgets('no desborda en 360 px con el texto al 200 %', (
      WidgetTester tester,
    ) async {
      await pumpView(
        tester,
        const MediaQueryTextScale(scale: 2, child: RegisterView()),
        languages: authenticationLanguages,
        overrides: _Doubles().overrides(),
        size: const Size(360, 800),
      );
      await _tap(tester, AuthIds.registerCountryCoChip);

      expect(tester.takeException(), isNull);
    });
  });
}
