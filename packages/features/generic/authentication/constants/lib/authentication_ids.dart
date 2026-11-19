/// Identificadores semánticos de authentication (§11.1).
///
/// Son contrato público para la automatización black-box: de aquí salen el
/// `Semantics.identifier` y la `Key` de cada elemento. Renombrar uno rompe
/// el contrato y se anota en `docs/semantics-ids.md`.
abstract final class AuthIds {
  /// Raíz de la vista de login.
  static const String loginView = 'auth_login_view';

  /// Badge "Simulado" del login.
  static const String loginSimulatedText = 'auth_login_simulated_text';

  /// Campo de email del login.
  static const String loginEmailField = 'auth_login_email_field';

  /// Campo de contraseña del login.
  static const String loginPasswordField = 'auth_login_password_field';

  /// Mostrar/ocultar la contraseña del login.
  static const String loginPasswordToggle = 'auth_login_password_toggle';

  /// Botón "Iniciar sesión".
  static const String loginSubmitButton = 'auth_login_submit_button';

  /// Botón "Usar cuenta demo" (solo en modo fake).
  static const String loginDemoButton = 'auth_login_demo_button';

  /// Link "Crear cuenta".
  static const String loginRegisterLink = 'auth_login_register_link';

  /// Mensaje de error general del login.
  static const String loginErrorText = 'auth_login_error_text';

  /// Aviso de simulación del login.
  static const String loginDisclaimerText = 'auth_login_disclaimer_text';

  /// Raíz de la vista de registro.
  static const String registerView = 'auth_register_view';

  /// Volver desde el registro.
  static const String registerBackIconButton = 'auth_register_back_icon_button';

  /// Badge "Simulado" del registro.
  static const String registerSimulatedText = 'auth_register_simulated_text';

  /// Chip de país Colombia.
  static const String registerCountryCoChip = 'auth_register_country_co_chip';

  /// Chip de país México.
  static const String registerCountryMxChip = 'auth_register_country_mx_chip';

  /// Chip de país Perú.
  static const String registerCountryPeChip = 'auth_register_country_pe_chip';

  /// Campo de nombre completo.
  static const String registerNameField = 'auth_register_name_field';

  /// Campo de email del registro.
  static const String registerEmailField = 'auth_register_email_field';

  /// Chip de tipo de documento CC.
  static const String registerDocumentCcChip = 'auth_register_document_cc_chip';

  /// Chip de tipo de documento CE.
  static const String registerDocumentCeChip = 'auth_register_document_ce_chip';

  /// Chip de tipo de documento CURP.
  static const String registerDocumentCurpChip =
      'auth_register_document_curp_chip';

  /// Chip de tipo de documento DNI.
  static const String registerDocumentDniChip =
      'auth_register_document_dni_chip';

  /// Campo de número de documento.
  static const String registerDocumentField = 'auth_register_document_field';

  /// Campo de contraseña del registro.
  static const String registerPasswordField = 'auth_register_password_field';

  /// Mostrar/ocultar la contraseña del registro.
  static const String registerPasswordToggle = 'auth_register_password_toggle';

  /// Requisito de contraseña: largo mínimo.
  static const String registerRequirementLengthText =
      'auth_register_requirement_length_text';

  /// Requisito de contraseña: al menos una letra.
  static const String registerRequirementLetterText =
      'auth_register_requirement_letter_text';

  /// Requisito de contraseña: al menos un número.
  static const String registerRequirementNumberText =
      'auth_register_requirement_number_text';

  /// Aviso de simulación del registro.
  static const String registerDisclaimerText = 'auth_register_disclaimer_text';

  /// Checkbox de aceptación del aviso de simulación.
  static const String registerAcceptCheckbox = 'auth_register_accept_checkbox';

  /// Botón "Crear cuenta".
  static const String registerSubmitButton = 'auth_register_submit_button';

  /// Link "Ya tengo cuenta".
  static const String registerLoginLink = 'auth_register_login_link';

  /// Mensaje de error general del registro.
  static const String registerErrorText = 'auth_register_error_text';

  /// Todos los ids estáticos, para el test de unicidad y formato.
  static const List<String> all = <String>[
    loginView,
    loginSimulatedText,
    loginEmailField,
    loginPasswordField,
    loginPasswordToggle,
    loginSubmitButton,
    loginDemoButton,
    loginRegisterLink,
    loginErrorText,
    loginDisclaimerText,
    registerView,
    registerBackIconButton,
    registerSimulatedText,
    registerCountryCoChip,
    registerCountryMxChip,
    registerCountryPeChip,
    registerNameField,
    registerEmailField,
    registerDocumentCcChip,
    registerDocumentCeChip,
    registerDocumentCurpChip,
    registerDocumentDniChip,
    registerDocumentField,
    registerPasswordField,
    registerPasswordToggle,
    registerRequirementLengthText,
    registerRequirementLetterText,
    registerRequirementNumberText,
    registerDisclaimerText,
    registerAcceptCheckbox,
    registerSubmitButton,
    registerLoginLink,
    registerErrorText,
  ];
}
