/// Tema elegido por el usuario.
enum AppThemePreference {
  /// Sigue al sistema. Es el valor por defecto.
  system,

  /// Siempre claro.
  light,

  /// Siempre oscuro.
  dark;

  /// Resuelve el valor guardado; uno desconocido es [system].
  static AppThemePreference fromStorage(String? value) {
    for (final AppThemePreference preference in values) {
      if (preference.name == value) {
        return preference;
      }
    }
    return AppThemePreference.system;
  }
}
