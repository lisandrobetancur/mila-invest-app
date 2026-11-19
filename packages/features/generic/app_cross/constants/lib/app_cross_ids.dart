/// Identificadores semánticos de app_cross: splash, onboarding y ajustes.
abstract final class AppCrossIds {
  /// Raíz del splash.
  static const String splashView = 'splash_view';

  /// Splash arrancando.
  static const String splashStateLoading = 'splash_state_loading';

  /// Splash con error de arranque.
  static const String splashStateError = 'splash_state_error';

  /// Mensaje de error del splash.
  static const String splashErrorText = 'splash_error_text';

  /// "Reintentar" del splash.
  static const String splashRetryButton = 'splash_retry_button';

  /// Raíz del onboarding.
  static const String onboardingView = 'onboarding_view';

  /// Título del paso visible.
  static const String onboardingStepTitleText = 'onboarding_step_title_text';

  /// Texto del paso visible.
  static const String onboardingStepBodyText = 'onboarding_step_body_text';

  /// Indicador "Paso 2 de 3".
  static const String onboardingProgressText = 'onboarding_progress_text';

  /// Aviso de simulación del onboarding.
  static const String onboardingDisclaimerText = 'onboarding_disclaimer_text';

  /// Botón "Saltar".
  static const String onboardingSkipButton = 'onboarding_skip_button';

  /// Botón "Siguiente".
  static const String onboardingNextButton = 'onboarding_next_button';

  /// Botón "Empezar" del último paso.
  static const String onboardingStartButton = 'onboarding_start_button';

  /// Raíz de ajustes.
  static const String settingsView = 'settings_view';

  /// Volver desde ajustes.
  static const String settingsBackIconButton = 'settings_back_icon_button';

  /// Badge "Simulado" de ajustes.
  static const String settingsSimulatedText = 'settings_simulated_text';

  /// Selector de tema.
  static const String settingsThemeMenu = 'settings_theme_menu';

  /// Tema del sistema.
  static const String settingsThemeSystemSegment =
      'settings_theme_system_segment';

  /// Tema claro.
  static const String settingsThemeLightSegment =
      'settings_theme_light_segment';

  /// Tema oscuro.
  static const String settingsThemeDarkSegment = 'settings_theme_dark_segment';

  /// Selector de idioma.
  static const String settingsLanguageMenu = 'settings_language_menu';

  /// Idioma español.
  static const String settingsLanguageEsSegment =
      'settings_language_es_segment';

  /// Idioma inglés.
  static const String settingsLanguageEnSegment =
      'settings_language_en_segment';

  /// Nombre del titular de la cuenta.
  static const String settingsAccountNameText = 'settings_account_name_text';

  /// Email de la cuenta.
  static const String settingsAccountEmailText = 'settings_account_email_text';

  /// País de la cuenta.
  static const String settingsAccountCountryText =
      'settings_account_country_text';

  /// Documento enmascarado.
  static const String settingsAccountDocumentText =
      'settings_account_document_text';

  /// Botón "Cerrar sesión".
  static const String settingsLogoutButton = 'settings_logout_button';

  /// Diálogo de confirmación de cierre de sesión.
  static const String settingsLogoutDialog = 'settings_logout_dialog';

  /// Confirmar el cierre de sesión.
  static const String settingsLogoutConfirmButton =
      'settings_logout_confirm_button';

  /// Cancelar el cierre de sesión.
  static const String settingsLogoutCancelButton =
      'settings_logout_cancel_button';

  /// Versión de la app.
  static const String settingsVersionText = 'settings_version_text';

  /// Modo de API activo (solo fuera de release).
  static const String settingsApiModeText = 'settings_api_mode_text';

  /// Aviso de simulación de ajustes.
  static const String settingsDisclaimerText = 'settings_disclaimer_text';

  /// Todos los ids estáticos, para el test de unicidad y formato.
  static const List<String> all = <String>[
    splashView,
    splashStateLoading,
    splashStateError,
    splashErrorText,
    splashRetryButton,
    onboardingView,
    onboardingStepTitleText,
    onboardingStepBodyText,
    onboardingProgressText,
    onboardingDisclaimerText,
    onboardingSkipButton,
    onboardingNextButton,
    onboardingStartButton,
    settingsView,
    settingsBackIconButton,
    settingsSimulatedText,
    settingsThemeMenu,
    settingsThemeSystemSegment,
    settingsThemeLightSegment,
    settingsThemeDarkSegment,
    settingsLanguageMenu,
    settingsLanguageEsSegment,
    settingsLanguageEnSegment,
    settingsAccountNameText,
    settingsAccountEmailText,
    settingsAccountCountryText,
    settingsAccountDocumentText,
    settingsLogoutButton,
    settingsLogoutDialog,
    settingsLogoutConfirmButton,
    settingsLogoutCancelButton,
    settingsVersionText,
    settingsApiModeText,
    settingsDisclaimerText,
  ];
}
