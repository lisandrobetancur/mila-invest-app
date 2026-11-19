import 'package:app_cross/app_cross.dart';
import 'package:app_cross/core/data/dto/preferences_dto.dart';
import 'package:app_cross/core/data/preferences_local_data_source.dart';
import 'package:app_cross/core/service/service.dart';
import 'package:app_cross_typing/app_cross_typing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilities/utilities.dart';

class _MockService extends Mock implements IPreferencesService {}

ProviderContainer _container(IPreferencesService service) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      preferencesServiceProvider.overrideWithValue(service),
      appPreferencesProviderOverride,
      loggerProvider.overrideWithValue(const SilentAppLogger()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('PreferencesDto', () {
    test('convierte a dominio con valores por defecto donde falta algo', () {
      expect(
        PreferencesDto.fromJson(const <String, Object?>{}).toDomain(),
        const AppPreferences(),
      );
      expect(
        PreferencesDto.fromJson(const <String, Object?>{
          PreferencesDto.themeKey: 'dark',
          PreferencesDto.languageKey: 'en',
          PreferencesDto.onboardingSeenKey: true,
        }).toDomain(),
        const AppPreferences(
          theme: AppThemePreference.dark,
          language: AppLanguage.en,
          onboardingSeen: true,
        ),
      );
    });

    test('rechaza un valor con tipo inesperado', () {
      expect(
        () => PreferencesDto.fromJson(const <String, Object?>{
          PreferencesDto.onboardingSeenKey: 'si',
        }),
        throwsFormatException,
      );
    });
  });

  group('PreferencesService sobre shared_preferences', () {
    test('guarda y vuelve a leer tema, idioma y onboarding', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final PreferencesService service = PreferencesService(
        dataSource: PreferencesLocalDataSource(),
      );

      expect(await service.load(), const AppPreferences());
      await service.saveTheme(AppThemePreference.dark);
      await service.saveLanguage(AppLanguage.en);
      await service.markOnboardingSeen();

      expect(
        await service.load(),
        const AppPreferences(
          theme: AppThemePreference.dark,
          language: AppLanguage.en,
          onboardingSeen: true,
        ),
      );
    });

    test('traduce un fallo del dispositivo a AppCrossException', () async {
      final PreferencesService service = PreferencesService(
        dataSource: PreferencesLocalDataSource(
          open: () async => throw Exception('disco lleno'),
        ),
      );

      await expectLater(
        service.load(),
        throwsA(
          isA<AppCrossException>().having(
            (AppCrossException e) => e.code,
            'code',
            AppCrossErrorCode.storage,
          ),
        ),
      );
    });
  });

  group('PreferencesViewModel', () {
    test('carga y expone las preferencias por el provider derivado', () async {
      final _MockService service = _MockService();
      when(service.load).thenAnswer(
        (_) async => const AppPreferences(theme: AppThemePreference.dark),
      );
      final ProviderContainer container = _container(service);

      expect(container.read(appPreferencesProvider), const AppPreferences());
      await container.read(preferencesViewModelProvider.notifier).load();

      expect(
        container.read(appPreferencesProvider).theme,
        AppThemePreference.dark,
      );
      expect(container.read(preferencesViewModelProvider).loaded, isTrue);
    });

    test('si no puede leer, quedan las preferencias por defecto', () async {
      final _MockService service = _MockService();
      when(
        service.load,
      ).thenThrow(const AppCrossException(AppCrossErrorCode.storage));
      final ProviderContainer container = _container(service);

      await container.read(preferencesViewModelProvider.notifier).load();

      expect(container.read(appPreferencesProvider), const AppPreferences());
      expect(container.read(preferencesViewModelProvider).loaded, isTrue);
    });

    test('cambiar tema e idioma es optimista y se persiste', () async {
      final _MockService service = _MockService();
      when(
        () => service.saveTheme(AppThemePreference.light),
      ).thenAnswer((_) async {});
      when(
        () => service.saveLanguage(AppLanguage.en),
      ).thenThrow(const AppCrossException(AppCrossErrorCode.storage));
      final ProviderContainer container = _container(service);
      final PreferencesViewModel viewModel = container.read(
        preferencesViewModelProvider.notifier,
      );

      await viewModel.setTheme(AppThemePreference.light);
      await viewModel.setLanguage(AppLanguage.en);
      await viewModel.setLanguage(AppLanguage.en);

      expect(
        container.read(appPreferencesProvider),
        const AppPreferences(
          theme: AppThemePreference.light,
          language: AppLanguage.en,
        ),
      );
      verify(() => service.saveTheme(AppThemePreference.light)).called(1);
      verify(() => service.saveLanguage(AppLanguage.en)).called(1);
    });
  });
}
