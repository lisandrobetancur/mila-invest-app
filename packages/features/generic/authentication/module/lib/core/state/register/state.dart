part of 'register.dart';

/// Estado del formulario de registro.
class RegisterState extends Equatable {
  /// Crea el estado.
  const RegisterState({
    this.country,
    this.documentType,
    this.fullName = '',
    this.email = '',
    this.documentNumber = '',
    this.password = '',
    this.obscurePassword = true,
    this.accepted = false,
    this.submitStatus = SubmitStatus.idle,
    this.showValidation = false,
    this.serverFieldErrors = const <AuthField, String>{},
    this.errorKey,
    this.isNetworkError = false,
  });

  static const Object _unset = Object();

  /// País elegido. Es lo primero que se pide.
  final Country? country;

  /// Tipo de documento elegido, entre los del país.
  final DocumentType? documentType;

  /// Nombre completo.
  final String fullName;

  /// Email.
  final String email;

  /// Número de documento.
  final String documentNumber;

  /// Contraseña.
  final String password;

  /// `true` si la contraseña se muestra oculta.
  final bool obscurePassword;

  /// `true` si aceptó el aviso de simulación.
  final bool accepted;

  /// Estado del envío.
  final SubmitStatus submitStatus;

  /// `true` después del primer intento de envío.
  final bool showValidation;

  /// Errores de campo que devolvió el servidor (`errors[]`).
  final Map<AuthField, String> serverFieldErrors;

  /// Clave del error general, si hay.
  final String? errorKey;

  /// `true` si el error general fue de red.
  final bool isNetworkError;

  /// Tipos de documento del país elegido.
  List<DocumentType> get documentTypes =>
      country?.documentTypes ?? const <DocumentType>[];

  /// Requisito: largo mínimo de la contraseña.
  bool get passwordHasMinLength => Validators.passwordHasMinLength(password);

  /// Requisito: al menos una letra.
  bool get passwordHasLetter => Validators.passwordHasLetter(password);

  /// Requisito: al menos un número.
  bool get passwordHasNumber => Validators.passwordHasNumber(password);

  /// `true` si el formulario se puede enviar.
  bool get isValid => AuthField.values.every(
    (AuthField field) => _clientErrorKey(field) == null,
  );

  /// `true` si el formulario es válido y aceptó el aviso.
  bool get canSubmit => isValid && accepted;

  /// Clave del error de [field] a mostrar, o `null` si no hay.
  ///
  /// El error del servidor gana; los del cliente aparecen desde el primer
  /// intento de envío.
  String? errorKeyOf(AuthField field) =>
      serverFieldErrors[field] ??
      (showValidation ? _clientErrorKey(field) : null);

  /// Clave del error del checkbox de aceptación.
  String? get acceptErrorKey =>
      showValidation && !accepted ? 'auth.field_error.accept_required' : null;

  /// Datos normalizados para el servicio. Solo si [isValid].
  RegistrationData toData() => RegistrationData(
    email: Validators.normalizeEmail(email),
    password: password,
    fullName: fullName.trim(),
    country: country!,
    documentType: documentType!,
    documentNumber: Validators.normalizeDocument(documentType!, documentNumber),
  );

  /// Copia el estado. Los campos nullable aceptan `null` explícito.
  RegisterState copyWith({
    Object? country = _unset,
    Object? documentType = _unset,
    String? fullName,
    String? email,
    String? documentNumber,
    String? password,
    bool? obscurePassword,
    bool? accepted,
    SubmitStatus? submitStatus,
    bool? showValidation,
    Map<AuthField, String>? serverFieldErrors,
    Object? errorKey = _unset,
    bool? isNetworkError,
  }) => RegisterState(
    country: identical(country, _unset) ? this.country : country as Country?,
    documentType: identical(documentType, _unset)
        ? this.documentType
        : documentType as DocumentType?,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    documentNumber: documentNumber ?? this.documentNumber,
    password: password ?? this.password,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    accepted: accepted ?? this.accepted,
    submitStatus: submitStatus ?? this.submitStatus,
    showValidation: showValidation ?? this.showValidation,
    serverFieldErrors: serverFieldErrors ?? this.serverFieldErrors,
    errorKey: identical(errorKey, _unset) ? this.errorKey : errorKey as String?,
    isNetworkError: isNetworkError ?? this.isNetworkError,
  );

  String? _clientErrorKey(AuthField field) {
    final Country? selected = country;
    final DocumentType? type = documentType;
    return switch (field) {
      AuthField.country =>
        selected == null ? 'auth.field_error.country_required' : null,
      AuthField.fullName =>
        Validators.isFullName(fullName)
            ? null
            : 'auth.field_error.name_invalid',
      AuthField.email =>
        Validators.isEmail(email) ? null : 'auth.field_error.email_invalid',
      AuthField.documentType =>
        selected != null && type == null
            ? 'auth.field_error.document_type_required'
            : null,
      AuthField.documentNumber =>
        selected == null || type == null
            ? null
            : Validators.isDocumentNumber(
                country: selected,
                type: type,
                raw: documentNumber,
              )
            ? null
            : 'auth.field_error.document_${type.code.toLowerCase()}_invalid',
      AuthField.password =>
        Validators.isPassword(password)
            ? null
            : 'auth.field_error.password_invalid',
    };
  }

  @override
  List<Object?> get props => <Object?>[
    country,
    documentType,
    fullName,
    email,
    documentNumber,
    password,
    obscurePassword,
    accepted,
    submitStatus,
    showValidation,
    serverFieldErrors,
    errorKey,
    isNetworkError,
  ];

  /// Nunca expone la contraseña ni el documento.
  @override
  String toString() => 'RegisterState(${country?.code}, ${submitStatus.name})';
}
