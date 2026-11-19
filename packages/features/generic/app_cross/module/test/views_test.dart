import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:app_cross/app_cross.dart';
import 'package:app_cross/ui/views/onboarding/onboarding.dart';
import 'package:app_cross/ui/views/settings/settings.dart';
import 'package:app_cross/ui/views/splash/splash.dart';
import 'package:app_cross_constants/app_cross_constants.dart';
import 'package:app_cross_typing/app_cross_typing.dart';
import 'package:authentication_typing/authentication_typing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:navigator/navigator.dart';
import 'package:typing/typing.dart';

import 'support/harness.dart';

class _MockPreferencesService extends Mock implements IPreferencesService {}

class _MockSessionManager extends Mock implements ISessionManager {}

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
    when(preferences.load).thenAnswer((_) async => const AppPreferences());
    when(preferences.markOnboardingSeen).thenAnswer((_) async {});
    when(() => preferences.saveTheme(any())).thenAnswer((_) async {});
    when(() => preferences.saveLanguage(any())).thenAnswer((_) async {});
    when(session.restore).thenAnswer((_) async {});
    when(session.signOut).thenAnswer((_) async {});
    when(navigation.canPop).thenReturn(true);
  }

  final _MockPreferencesService preferences = _MockPreferencesService();
  final _MockSessionManager session = _MockSessionManager();
  final _MockNavigation navigation = _MockNavigation();

  List<Override> overrides({bool showApiMode = true}) => <Override>[
    preferencesServiceProvider.overrideWithValue(preferences),
    appPreferencesProviderOverride,
    sessionManagerProvider.overrideWithValue(session),
    sessionProvider.overrideWithValue(const SessionState.authenticated(_user)),
    navigationManagerProvider.overrideWithValue(navigation),
    appInfoProvider.overrideWithValue(
      AppInfo(version: '0.1.0', apiMode: 'fake', showApiMode: showApiMode),
    ),
  ];
}

void main() {
  setUpAll(() {
    registerFallbackValue(AppThemePreference.system);
    registerFallbackValue(AppLanguage.es);
  });

  group('SplashView', () {
    testWidgets('loading: raíz de la vista y del estado', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(doubles.session.restore).thenAnswer((_) => Completer<void>().future);

      await pumpView(
        tester,
        const SplashView(),
        languages: appCrossLanguages,
        overrides: doubles.overrides(),
      );

      expect(
        find.bySemanticsIdentifier(AppCrossIds.splashView),
        findsOneWidget,
      );
      expect(
        labelOf(tester, AppCrossIds.splashStateLoading),
        contains('Preparando tu simulador'),
      );
      expect(
        find.bySemanticsIdentifier(AppCrossIds.splashStateError),
        findsNothing,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('error: mensaje traducido y "Reintentar" que rearranca', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        doubles.session.restore,
      ).thenThrow(const AuthException(AuthErrorCode.network));

      await pumpView(
        tester,
        const SplashView(),
        languages: appCrossLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(AppCrossIds.splashStateError),
        findsOneWidget,
      );
      expect(
        labelOf(tester, AppCrossIds.splashErrorText),
        'No pudimos conectar. Revisa tu conexión e inténtalo de nuevo.',
      );
      final SemanticsData retry = tester
          .getSemantics(
            find.bySemanticsIdentifier(AppCrossIds.splashRetryButton),
          )
          .getSemanticsData();
      expect(retry.flagsCollection.isButton, isTrue);
      expect(retry.hasAction(SemanticsAction.tap), isTrue);
      expectNoDuplicateIdentifiers(tester);

      when(doubles.session.restore).thenAnswer((_) async {});
      await tester.tap(
        find.bySemanticsIdentifier(AppCrossIds.splashRetryButton),
      );
      await tester.pumpAndSettle();

      verify(doubles.navigation.refresh).called(1);
      handle.dispose();
    });
  });

  group('OnboardingView', () {
    testWidgets('recorre los tres pasos y termina en el login', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      await pumpView(
        tester,
        const OnboardingView(),
        languages: appCrossLanguages,
        overrides: doubles.overrides(),
      );

      expect(
        find.bySemanticsIdentifier(AppCrossIds.onboardingView),
        findsOneWidget,
      );
      expect(
        labelOf(tester, AppCrossIds.onboardingStepTitleText),
        'Aprende a invertir sin arriesgar',
      );
      expect(
        labelOf(tester, AppCrossIds.onboardingProgressText),
        'Paso 1 de 3',
      );
      expect(
        labelOf(tester, AppCrossIds.onboardingDisclaimerText),
        'Simulación con fines educativos. No es asesoría financiera.',
      );
      expect(
        find.bySemanticsIdentifier(AppCrossIds.onboardingSkipButton),
        findsOneWidget,
      );
      expectNoDuplicateIdentifiers(tester);

      await tester.tap(
        find.bySemanticsIdentifier(AppCrossIds.onboardingNextButton),
      );
      await tester.pump();
      expect(
        labelOf(tester, AppCrossIds.onboardingStepTitleText),
        'Todo es dinero virtual',
      );
      await tester.tap(
        find.bySemanticsIdentifier(AppCrossIds.onboardingNextButton),
      );
      await tester.pump();

      expect(
        labelOf(tester, AppCrossIds.onboardingProgressText),
        'Paso 3 de 3',
      );
      expect(
        find.bySemanticsIdentifier(AppCrossIds.onboardingNextButton),
        findsNothing,
      );
      await tester.tap(
        find.bySemanticsIdentifier(AppCrossIds.onboardingStartButton),
      );
      await tester.pumpAndSettle();

      verify(doubles.preferences.markOnboardingSeen).called(1);
      verify(() => doubles.navigation.go(AuthRoutes.loginPath)).called(1);
      handle.dispose();
    });

    testWidgets('"Saltar" termina el onboarding desde el primer paso', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      await pumpView(
        tester,
        const OnboardingView(),
        languages: appCrossLanguages,
        overrides: doubles.overrides(),
      );

      await tester.tap(
        find.bySemanticsIdentifier(AppCrossIds.onboardingSkipButton),
      );
      await tester.pumpAndSettle();

      verify(() => doubles.navigation.go(AuthRoutes.loginPath)).called(1);
      handle.dispose();
    });

    testWidgets('en inglés muestra el mismo contenido traducido', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpView(
        tester,
        const OnboardingView(),
        languages: appCrossLanguages,
        overrides: _Doubles().overrides(),
        language: 'en',
      );

      expect(
        labelOf(tester, AppCrossIds.onboardingStepTitleText),
        'Learn to invest without the risk',
      );
      expect(
        labelOf(tester, AppCrossIds.onboardingProgressText),
        'Step 1 of 3',
      );
      handle.dispose();
    });
  });

  group('SettingsView', () {
    testWidgets('muestra tema, idioma, cuenta y datos del build', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpView(
        tester,
        const SettingsView(),
        languages: appCrossLanguages,
        overrides: _Doubles().overrides(),
      );

      for (final String id in <String>[
        AppCrossIds.settingsView,
        AppCrossIds.settingsBackIconButton,
        AppCrossIds.settingsThemeMenu,
        AppCrossIds.settingsThemeSystemSegment,
        AppCrossIds.settingsThemeLightSegment,
        AppCrossIds.settingsThemeDarkSegment,
        AppCrossIds.settingsLanguageMenu,
        AppCrossIds.settingsLanguageEsSegment,
        AppCrossIds.settingsLanguageEnSegment,
        AppCrossIds.settingsLogoutButton,
      ]) {
        expect(find.bySemanticsIdentifier(id), findsOneWidget, reason: id);
      }
      expect(labelOf(tester, AppCrossIds.settingsSimulatedText), 'Simulado');
      expect(
        labelOf(tester, AppCrossIds.settingsAccountNameText),
        'Camila Demo',
      );
      expect(
        labelOf(tester, AppCrossIds.settingsAccountEmailText),
        'demo@milainvest.app',
      );
      expect(
        labelOf(tester, AppCrossIds.settingsAccountCountryText),
        'Colombia',
      );
      expect(
        labelOf(tester, AppCrossIds.settingsAccountDocumentText),
        'CC ••••••5678',
      );
      expect(labelOf(tester, AppCrossIds.settingsVersionText), 'Versión 0.1.0');
      expect(
        labelOf(tester, AppCrossIds.settingsApiModeText),
        'Modo de API: fake',
      );
      expect(
        tester
            .getSemantics(
              find.bySemanticsIdentifier(
                AppCrossIds.settingsThemeSystemSegment,
              ),
            )
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('en release no muestra el modo de API', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpView(
        tester,
        const SettingsView(),
        languages: appCrossLanguages,
        overrides: _Doubles().overrides(showApiMode: false),
      );

      expect(
        find.bySemanticsIdentifier(AppCrossIds.settingsApiModeText),
        findsNothing,
      );
      handle.dispose();
    });

    testWidgets('cambiar tema e idioma actualiza las preferencias', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      await pumpView(
        tester,
        const SettingsView(),
        languages: appCrossLanguages,
        overrides: doubles.overrides(),
      );

      await tester.tap(
        find.bySemanticsIdentifier(AppCrossIds.settingsThemeDarkSegment),
      );
      await tester.tap(
        find.bySemanticsIdentifier(AppCrossIds.settingsLanguageEnSegment),
      );
      await tester.pump();

      verify(
        () => doubles.preferences.saveTheme(AppThemePreference.dark),
      ).called(1);
      verify(() => doubles.preferences.saveLanguage(AppLanguage.en)).called(1);
      expect(
        tester
            .getSemantics(
              find.bySemanticsIdentifier(AppCrossIds.settingsThemeDarkSegment),
            )
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
      handle.dispose();
    });

    testWidgets('cerrar sesión pide confirmación', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      await pumpView(
        tester,
        const SettingsView(),
        languages: appCrossLanguages,
        overrides: doubles.overrides(),
      );
      final Finder logout = find.bySemanticsIdentifier(
        AppCrossIds.settingsLogoutButton,
      );

      await tester.ensureVisible(logout);
      await tester.tap(logout);
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsIdentifier(AppCrossIds.settingsLogoutDialog),
        findsOneWidget,
      );
      await tester.tap(
        find.bySemanticsIdentifier(AppCrossIds.settingsLogoutCancelButton),
      );
      await tester.pumpAndSettle();
      verifyNever(doubles.session.signOut);

      await tester.tap(logout);
      await tester.pumpAndSettle();
      await tester.tap(
        find.bySemanticsIdentifier(AppCrossIds.settingsLogoutConfirmButton),
      );
      await tester.pumpAndSettle();

      verify(doubles.session.signOut).called(1);
      handle.dispose();
    });

    testWidgets('volver cierra los ajustes', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      await pumpView(
        tester,
        const SettingsView(),
        languages: appCrossLanguages,
        overrides: doubles.overrides(),
      );

      await tester.tap(
        find.bySemanticsIdentifier(AppCrossIds.settingsBackIconButton),
      );

      verify(() => doubles.navigation.pop<void>()).called(1);
      handle.dispose();
    });

    testWidgets('no desborda en 360 px con el texto al 200 %', (
      WidgetTester tester,
    ) async {
      await pumpView(
        tester,
        const MediaQueryTextScale(scale: 2, child: SettingsView()),
        languages: appCrossLanguages,
        overrides: _Doubles().overrides(),
        size: const Size(360, 800),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
