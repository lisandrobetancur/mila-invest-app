import 'package:app_cross_typing/app_cross_typing.dart';

/// Preferencias tal como se guardan en el dispositivo.
class PreferencesDto {
  /// Crea el DTO.
  const PreferencesDto({this.theme, this.language, this.onboardingSeen});

  /// Lee el DTO desde los valores guardados.
  ///
  /// Lanza [FormatException] si un valor tiene un tipo inesperado.
  factory PreferencesDto.fromJson(Map<String, Object?> json) {
    final Object? theme = json[themeKey];
    final Object? language = json[languageKey];
    final Object? onboardingSeen = json[onboardingSeenKey];
    if ((theme != null && theme is! String) ||
        (language != null && language is! String) ||
        (onboardingSeen != null && onboardingSeen is! bool)) {
      throw const FormatException('Preferencias con un tipo inesperado');
    }
    return PreferencesDto(
      theme: theme as String?,
      language: language as String?,
      onboardingSeen: onboardingSeen as bool?,
    );
  }

  /// Clave del tema.
  static const String themeKey = 'mila_invest.theme';

  /// Clave del idioma.
  static const String languageKey = 'mila_invest.language';

  /// Clave de "onboarding visto".
  static const String onboardingSeenKey = 'mila_invest.onboarding_seen';

  /// Tema guardado.
  final String? theme;

  /// Código de idioma guardado.
  final String? language;

  /// Si el onboarding ya se vio.
  final bool? onboardingSeen;

  /// Convierte a dominio, con los valores por defecto donde falte algo.
  AppPreferences toDomain() => AppPreferences(
    theme: AppThemePreference.fromStorage(theme),
    language: AppLanguage.fromCode(language),
    onboardingSeen: onboardingSeen ?? false,
  );

  /// Valores a guardar.
  Map<String, Object?> toJson() => <String, Object?>{
    themeKey: theme,
    languageKey: language,
    onboardingSeenKey: onboardingSeen,
  };
}
