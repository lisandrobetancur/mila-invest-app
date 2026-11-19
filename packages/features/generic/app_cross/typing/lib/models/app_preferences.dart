import 'package:equatable/equatable.dart';

import '../enums/app_language.dart';
import '../enums/app_theme_preference.dart';

/// Preferencias del usuario guardadas en el dispositivo.
class AppPreferences extends Equatable {
  /// Crea las preferencias.
  const AppPreferences({
    this.theme = AppThemePreference.system,
    this.language = AppLanguage.es,
    this.onboardingSeen = false,
  });

  /// Tema elegido.
  final AppThemePreference theme;

  /// Idioma de la UI.
  final AppLanguage language;

  /// `true` si el usuario ya vio (o saltó) el onboarding.
  final bool onboardingSeen;

  /// Copia las preferencias cambiando algunos campos.
  AppPreferences copyWith({
    AppThemePreference? theme,
    AppLanguage? language,
    bool? onboardingSeen,
  }) => AppPreferences(
    theme: theme ?? this.theme,
    language: language ?? this.language,
    onboardingSeen: onboardingSeen ?? this.onboardingSeen,
  );

  @override
  List<Object?> get props => <Object?>[theme, language, onboardingSeen];
}
