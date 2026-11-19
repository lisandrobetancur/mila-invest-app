/// Idioma de la UI.
///
/// Es independiente del formato de los montos, que depende del país de la
/// moneda.
enum AppLanguage {
  /// Español. Idioma por defecto y de fallback.
  es(code: 'es', nativeName: 'Español'),

  /// Inglés.
  en(code: 'en', nativeName: 'English');

  const AppLanguage({required this.code, required this.nativeName});

  /// Resuelve un código de idioma; uno desconocido es [es].
  static AppLanguage fromCode(String? code) {
    for (final AppLanguage language in values) {
      if (language.code == code) {
        return language;
      }
    }
    return AppLanguage.es;
  }

  /// Código ISO 639-1.
  final String code;

  /// Nombre del idioma en el propio idioma. No se traduce.
  final String nativeName;
}
