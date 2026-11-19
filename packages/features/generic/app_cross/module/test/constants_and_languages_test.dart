import 'package:app_cross/app_cross.dart';
import 'package:app_cross_constants/app_cross_constants.dart';
import 'package:app_cross_typing/app_cross_typing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  group('AppCrossIds', () {
    test('todos cumplen la convención de nombres', () {
      for (final String id in AppCrossIds.all) {
        expect(identifierPattern.hasMatch(id), isTrue, reason: id);
      }
    });

    test('no se repiten', () {
      expect(AppCrossIds.all.toSet().length, AppCrossIds.all.length);
    });
  });

  group('traducciones', () {
    final Set<String> es = translationKeys(appCrossLanguages['es']!);
    final Set<String> en = translationKeys(appCrossLanguages['en']!);

    test('es y en tienen exactamente las mismas claves', () {
      expect(es.difference(en), isEmpty);
      expect(en.difference(es), isEmpty);
    });

    test('toda clave tiene al menos tres niveles', () {
      for (final String key in es) {
        expect(key.split('.').length, greaterThanOrEqualTo(3), reason: key);
      }
    });

    test('cada código de error tiene su mensaje en los dos idiomas', () {
      for (final AppCrossErrorCode code in AppCrossErrorCode.values) {
        expect(es, contains(code.messageKey));
        expect(en, contains(code.messageKey));
      }
    });

    test('cada paso del onboarding tiene título y texto', () {
      for (int step = 1; step <= AppCrossLimits.onboardingSteps; step++) {
        expect(es, contains('app_cross.onboarding.step${step}_title'));
        expect(es, contains('app_cross.onboarding.step${step}_body'));
      }
    });
  });

  group('tipos', () {
    test(
      'las preferencias guardadas desconocidas caen al valor por defecto',
      () {
        expect(AppThemePreference.fromStorage('dark'), AppThemePreference.dark);
        expect(
          AppThemePreference.fromStorage('otro'),
          AppThemePreference.system,
        );
        expect(AppThemePreference.fromStorage(null), AppThemePreference.system);
        expect(AppLanguage.fromCode('en'), AppLanguage.en);
        expect(AppLanguage.fromCode('fr'), AppLanguage.es);
      },
    );

    test('AppPreferences copia e iguala por valor', () {
      const AppPreferences preferences = AppPreferences();

      expect(preferences.copyWith(onboardingSeen: true).onboardingSeen, isTrue);
      expect(preferences.copyWith(), preferences);
      expect(
        preferences.copyWith(language: AppLanguage.en),
        isNot(preferences),
      );
    });
  });
}
