part of 'preferences.dart';

/// Controller de las preferencias: tema, idioma y onboarding visto.
///
/// Guardar es optimista: el estado cambia de inmediato y, si el dispositivo
/// no pudo persistir, se loguea y la preferencia vale hasta cerrar la app.
class PreferencesViewModel extends ViewModel<PreferencesState> {
  late IPreferencesService _service;
  late AppLogger _logger;

  @override
  PreferencesState initState() => const PreferencesState();

  @override
  void postInit() {
    _service = ref.read(preferencesServiceProvider);
    _logger = ref.read(loggerProvider);
  }

  /// Marca el onboarding como visto.
  Future<void> completeOnboarding() async {
    state = state.copyWith(
      preferences: state.preferences.copyWith(onboardingSeen: true),
    );
    await _persist('onboarding', _service.markOnboardingSeen);
  }

  /// Lee las preferencias guardadas. Si falla, quedan las de por defecto.
  Future<void> load() async {
    final Object key = mountedKey;
    try {
      final AppPreferences preferences = await _service.load();
      if (!isMounted(key)) {
        return;
      }
      state = state.copyWith(preferences: preferences, loaded: true);
    } on AppCrossException catch (error, stackTrace) {
      _logger.error('app_cross.preferences.load', error, stackTrace);
      if (isMounted(key)) {
        state = state.copyWith(loaded: true);
      }
    }
  }

  /// Cambia el idioma de la UI.
  Future<void> setLanguage(AppLanguage language) async {
    if (language == state.preferences.language) {
      return;
    }
    state = state.copyWith(
      preferences: state.preferences.copyWith(language: language),
    );
    await _persist('language', () => _service.saveLanguage(language));
  }

  /// Cambia el tema.
  Future<void> setTheme(AppThemePreference theme) async {
    if (theme == state.preferences.theme) {
      return;
    }
    state = state.copyWith(
      preferences: state.preferences.copyWith(theme: theme),
    );
    await _persist('theme', () => _service.saveTheme(theme));
  }

  Future<void> _persist(String what, Future<void> Function() save) async {
    try {
      await save();
    } on AppCrossException catch (error, stackTrace) {
      _logger.error('app_cross.preferences.$what', error, stackTrace);
    }
  }
}
