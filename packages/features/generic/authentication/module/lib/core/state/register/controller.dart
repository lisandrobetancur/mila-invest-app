part of 'register.dart';

/// Controller del registro.
class RegisterViewModel extends AutoDisposeViewModel<RegisterState> {
  late IAuthenticationService _service;
  late SessionViewModel _session;
  late AuthNavigator _navigator;
  late AppLogger _logger;

  @override
  RegisterState initState() => const RegisterState();

  @override
  void postInit() {
    _service = ref.read(authenticationServiceProvider);
    _session = ref.read(sessionViewModelProvider.notifier);
    _navigator = ref.read(authNavigatorProvider.notifier);
    _logger = ref.read(loggerProvider);
  }

  /// Va al login.
  void goToLogin() => _navigator.goToLogin();

  /// Marca o desmarca la aceptación del aviso de simulación.
  void setAccepted({required bool accepted}) =>
      state = state.copyWith(accepted: accepted);

  /// Cambia el país: actualiza los tipos de documento y limpia el número.
  void setCountry(Country country) {
    if (country == state.country) {
      return;
    }
    state = state.copyWith(
      country: country,
      documentType: country.documentTypes.first,
      documentNumber: '',
      serverFieldErrors: _without(<AuthField>{
        AuthField.country,
        AuthField.documentType,
        AuthField.documentNumber,
      }),
    );
  }

  /// Cambia el tipo de documento y limpia el número.
  void setDocumentType(DocumentType type) {
    if (type == state.documentType) {
      return;
    }
    state = state.copyWith(
      documentType: type,
      documentNumber: '',
      serverFieldErrors: _without(<AuthField>{
        AuthField.documentType,
        AuthField.documentNumber,
      }),
    );
  }

  /// Actualiza el número de documento.
  void setDocumentNumber(String value) => state = state.copyWith(
    documentNumber: value,
    serverFieldErrors: _without(<AuthField>{AuthField.documentNumber}),
  );

  /// Actualiza el email.
  void setEmail(String value) => state = state.copyWith(
    email: value,
    serverFieldErrors: _without(<AuthField>{AuthField.email}),
  );

  /// Actualiza el nombre completo.
  void setFullName(String value) => state = state.copyWith(
    fullName: value,
    serverFieldErrors: _without(<AuthField>{AuthField.fullName}),
  );

  /// Actualiza la contraseña.
  void setPassword(String value) => state = state.copyWith(
    password: value,
    serverFieldErrors: _without(<AuthField>{AuthField.password}),
  );

  /// Envía el formulario. Un segundo toque en vuelo no hace nada.
  Future<void> submit() async {
    if (state.submitStatus.isSubmitting) {
      return;
    }
    state = state.copyWith(showValidation: true, errorKey: null);
    if (!state.canSubmit) {
      return;
    }
    final Object key = mountedKey;
    state = state.copyWith(submitStatus: SubmitStatus.submitting);
    try {
      final User user = await _service.register(state.toData());
      if (!isMounted(key)) {
        return;
      }
      state = state.copyWith(submitStatus: SubmitStatus.success);
      _session.authenticate(user);
    } on AuthException catch (error, stackTrace) {
      _logger.error('authentication.register', error, stackTrace);
      if (!isMounted(key)) {
        return;
      }
      final bool inline =
          error.code.isFieldError && error.fieldMessageKeys.isNotEmpty;
      state = state.copyWith(
        submitStatus: SubmitStatus.failure,
        serverFieldErrors: error.fieldMessageKeys,
        errorKey: inline ? null : error.code.messageKey,
        isNetworkError: error.code.isNetwork,
      );
    }
  }

  /// Muestra u oculta la contraseña.
  void toggleObscure() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  Map<AuthField, String> _without(Set<AuthField> fields) => <AuthField, String>{
    for (final MapEntry<AuthField, String> entry
        in state.serverFieldErrors.entries)
      if (!fields.contains(entry.key)) entry.key: entry.value,
  };
}
