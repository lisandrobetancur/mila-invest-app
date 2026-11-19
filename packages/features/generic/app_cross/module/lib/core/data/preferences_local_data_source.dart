import 'package:shared_preferences/shared_preferences.dart';

import 'dto/preferences_dto.dart';

/// Lee y escribe las preferencias con `shared_preferences`.
///
/// Es el único data source local de la fase 1: guarda tema, idioma y
/// "onboarding visto". No guarda nada de dominio.
class PreferencesLocalDataSource {
  /// Crea el data source. [open] existe para los tests.
  PreferencesLocalDataSource({Future<SharedPreferences> Function()? open})
    : _open = open ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _open;

  /// Lee las preferencias guardadas.
  Future<PreferencesDto> read() async {
    final SharedPreferences preferences = await _open();
    return PreferencesDto.fromJson(<String, Object?>{
      PreferencesDto.themeKey: preferences.get(PreferencesDto.themeKey),
      PreferencesDto.languageKey: preferences.get(PreferencesDto.languageKey),
      PreferencesDto.onboardingSeenKey: preferences.get(
        PreferencesDto.onboardingSeenKey,
      ),
    });
  }

  /// Guarda el idioma.
  Future<void> writeLanguage(String code) async {
    final SharedPreferences preferences = await _open();
    await preferences.setString(PreferencesDto.languageKey, code);
  }

  /// Guarda "onboarding visto".
  Future<void> writeOnboardingSeen({required bool seen}) async {
    final SharedPreferences preferences = await _open();
    await preferences.setBool(PreferencesDto.onboardingSeenKey, seen);
  }

  /// Guarda el tema.
  Future<void> writeTheme(String theme) async {
    final SharedPreferences preferences = await _open();
    await preferences.setString(PreferencesDto.themeKey, theme);
  }
}
