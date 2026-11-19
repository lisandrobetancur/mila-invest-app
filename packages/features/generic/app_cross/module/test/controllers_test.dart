import 'dart:async';

import 'package:app_cross/app_cross.dart';
import 'package:app_cross_typing/app_cross_typing.dart';
import 'package:authentication_typing/authentication_typing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:navigator/navigator.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

class _MockPreferencesService extends Mock implements IPreferencesService {}

class _MockSessionManager extends Mock implements ISessionManager {}

class _MockNavigation extends Mock implements NavigationManager {}

final class _Harness {
  _Harness() {
    when(preferences.load).thenAnswer((_) async => const AppPreferences());
    when(preferences.markOnboardingSeen).thenAnswer((_) async {});
    when(session.restore).thenAnswer((_) async {});
    when(session.signOut).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: <Override>[
        preferencesServiceProvider.overrideWithValue(preferences),
        sessionManagerProvider.overrideWithValue(session),
        navigationManagerProvider.overrideWithValue(navigation),
        loggerProvider.overrideWithValue(const SilentAppLogger()),
        ...appCrossOverrides.skip(1),
      ],
    );
    addTearDown(container.dispose);
  }

  final _MockPreferencesService preferences = _MockPreferencesService();
  final _MockSessionManager session = _MockSessionManager();
  final _MockNavigation navigation = _MockNavigation();
  late final ProviderContainer container;

  BootstrapGate get gate => container.read(bootstrapGateProvider);
}

Future<void> _settle() async {
  for (int i = 0; i < 6; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('BootstrapViewModel', () {
    test(
      'lee preferencias, resuelve la sesión, abre el gate y sigue',
      () async {
        final _Harness harness = _Harness();

        expect(
          harness.container.read(bootstrapViewModelProvider).status,
          ViewStatus.loading,
        );
        expect(harness.gate.isReady, isFalse);
        await _settle();

        expect(
          harness.container.read(bootstrapViewModelProvider).status,
          ViewStatus.data,
        );
        expect(harness.gate.isReady, isTrue);
        verifyInOrder(<void Function()>[
          harness.preferences.load,
          harness.session.restore,
          harness.navigation.refresh,
        ]);
      },
    );

    test('un fallo de red deja el estado en error y el gate cerrado', () async {
      final _Harness harness = _Harness();
      when(
        harness.session.restore,
      ).thenThrow(const AuthException(AuthErrorCode.network));

      harness.container.read(bootstrapViewModelProvider);
      await _settle();
      final BootstrapState state = harness.container.read(
        bootstrapViewModelProvider,
      );

      expect(state.status, ViewStatus.error);
      expect(state.errorKey, AppCrossErrorCode.network.messageKey);
      expect(state.isNetworkError, isTrue);
      expect(harness.gate.isReady, isFalse);
      verifyNever(harness.navigation.refresh);
    });

    test('reintentar después de un error termina el arranque', () async {
      final _Harness harness = _Harness();
      when(
        harness.session.restore,
      ).thenThrow(const AuthException(AuthErrorCode.unknown));
      harness.container.read(bootstrapViewModelProvider);
      await _settle();
      when(harness.session.restore).thenAnswer((_) async {});

      await harness.container.read(bootstrapViewModelProvider.notifier).start();
      final BootstrapState state = harness.container.read(
        bootstrapViewModelProvider,
      );

      expect(state.status, ViewStatus.data);
      expect(state.errorKey, isNull);
      expect(harness.gate.isReady, isTrue);
    });

    test('dos arranques a la vez resuelven la sesión una sola vez', () async {
      final _Harness harness = _Harness();
      final Completer<void> gate = Completer<void>();
      when(harness.session.restore).thenAnswer((_) => gate.future);
      final BootstrapViewModel viewModel = harness.container.read(
        bootstrapViewModelProvider.notifier,
      );
      await _settle();

      unawaited(viewModel.start());
      unawaited(viewModel.start());
      gate.complete();
      await _settle();

      verify(harness.session.restore).called(1);
    });
  });

  group('BootstrapState', () {
    test('copyWith puede poner el error en null con el sentinel', () {
      const BootstrapState failed = BootstrapState(
        status: ViewStatus.error,
        errorKey: 'app_cross.error.network',
        isNetworkError: true,
      );

      expect(failed.copyWith().errorKey, 'app_cross.error.network');
      expect(failed.copyWith(errorKey: null).errorKey, isNull);
      expect(failed.copyWith(), failed);
    });
  });

  group('OnboardingViewModel', () {
    test('avanza los pasos y al terminar marca visto y va al login', () async {
      final _Harness harness = _Harness();
      final ProviderSubscription<OnboardingState> subscription = harness
          .container
          .listen(onboardingViewModelProvider, (_, _) {});
      final OnboardingViewModel viewModel = harness.container.read(
        onboardingViewModelProvider.notifier,
      );

      expect(subscription.read().stepNumber, 1);
      await viewModel.next();
      await viewModel.next();
      expect(subscription.read().isLastStep, isTrue);
      verifyNever(harness.preferences.markOnboardingSeen);

      await viewModel.next();

      expect(
        harness.container.read(appPreferencesProvider).onboardingSeen,
        isTrue,
      );
      verify(harness.preferences.markOnboardingSeen).called(1);
      verify(() => harness.navigation.go(AuthRoutes.loginPath)).called(1);
    });

    test('saltar termina desde el primer paso, una sola vez', () async {
      final _Harness harness = _Harness();
      harness.container.listen(onboardingViewModelProvider, (_, _) {});
      final OnboardingViewModel viewModel = harness.container.read(
        onboardingViewModelProvider.notifier,
      );

      await Future.wait(<Future<void>>[viewModel.finish(), viewModel.finish()]);

      verify(harness.preferences.markOnboardingSeen).called(1);
      verify(() => harness.navigation.go(AuthRoutes.loginPath)).called(1);
    });
  });

  group('SettingsViewModel', () {
    test('un doble toque en cerrar sesión dispara un solo signOut', () async {
      final _Harness harness = _Harness();
      final Completer<void> gate = Completer<void>();
      when(harness.session.signOut).thenAnswer((_) => gate.future);
      final ProviderSubscription<SettingsState> subscription = harness.container
          .listen(settingsViewModelProvider, (_, _) {});
      final SettingsViewModel viewModel = harness.container.read(
        settingsViewModelProvider.notifier,
      );

      final Future<void> first = viewModel.signOut();
      final Future<void> second = viewModel.signOut();
      expect(subscription.read().logoutStatus, SubmitStatus.submitting);
      gate.complete();
      await Future.wait(<Future<void>>[first, second]);

      expect(subscription.read().logoutStatus, SubmitStatus.success);
      verify(harness.session.signOut).called(1);
    });
  });

  group('AppCrossNavigator', () {
    test('cierra ajustes volviendo atrás, o al inicio si se abrió en frío', () {
      final _Harness harness = _Harness();
      final AppCrossNavigator navigator = harness.container.read(
        appCrossNavigatorProvider.notifier,
      );
      when(harness.navigation.canPop).thenReturn(true);

      navigator.closeSettings();
      verify(() => harness.navigation.pop<void>()).called(1);

      when(harness.navigation.canPop).thenReturn(false);
      navigator.closeSettings();
      verify(() => harness.navigation.go(AppCrossRoutes.splashPath)).called(1);
    });
  });
}
