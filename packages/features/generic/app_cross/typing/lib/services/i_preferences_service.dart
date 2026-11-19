import '../enums/app_language.dart';
import '../enums/app_theme_preference.dart';
import '../models/app_preferences.dart';

/// Servicio de preferencias del usuario.
///
/// Sus métodos lanzan `AppCrossException`.
abstract interface class IPreferencesService {
  /// Lee las preferencias guardadas (o las de por defecto).
  Future<AppPreferences> load();

  /// Guarda el tema elegido.
  Future<void> saveTheme(AppThemePreference theme);

  /// Guarda el idioma elegido.
  Future<void> saveLanguage(AppLanguage language);

  /// Marca el onboarding como visto.
  Future<void> markOnboardingSeen();
}
