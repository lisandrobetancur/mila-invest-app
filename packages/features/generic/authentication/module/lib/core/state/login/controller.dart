part of 'login.dart';

/// Controller del login.
class LoginViewModel extends AutoDisposeViewModel<LoginState> {
  late IAuthenticationService _service;
  late SessionViewModel _session;
  late AuthNavigator _navigator;
  late AppLogger _logger;

  @override
  LoginState initState() => const LoginState();

  @override
  void postInit() {
    _service = ref.read(authenticationServiceProvider);
    _session = ref.read(sessionViewModelProvider.notifier);
    _navigator = ref.read(authNavigatorProvider.notifier);
    _logger = ref.read(loggerProvider);
  }

  /// Va al registro.
  void goToRegister() => _navigator.goToRegister();

  /// Muestra u oculta la contraseña.
  void toggleObscure() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  /// Llena el formulario con la cuenta demo.
  void useDemo(DemoCredentials credentials) => state = state.copyWith(
    email: credentials.email,
    password: credentials.password,
    errorKey: null,
  );

  /// Actualiza el email.
  void setEmail(String value) =>
      state = state.copyWith(email: value, errorKey: null);

  /// Actualiza la contraseña.
  void setPassword(String value) =>
      state = state.copyWith(password: value, errorKey: null);

  /// Envía el formulario. Un segundo toque en vuelo no hace nada.
  ///
  /// Al iniciar sesión, el `redirect` del shell lleva a la ubicación
  /// estacionada o al inicio.
  Future<void> submit() async {
    if (state.submitStatus.isSubmitting) {
      return;
    }
    state = state.copyWith(showValidation: true, errorKey: null);
    if (!state.isValid) {
      return;
    }
    final Object key = mountedKey;
    state = state.copyWith(submitStatus: SubmitStatus.submitting);
    try {
      final User user = await _service.login(
        email: Validators.normalizeEmail(state.email),
        password: state.password,
      );
      if (!isMounted(key)) {
        return;
      }
      state = state.copyWith(submitStatus: SubmitStatus.success);
      _session.authenticate(user);
    } on AuthException catch (error, stackTrace) {
      _logger.error('authentication.login', error, stackTrace);
      if (!isMounted(key)) {
        return;
      }
      state = state.copyWith(
        submitStatus: SubmitStatus.failure,
        errorKey: error.code.messageKey,
        isNetworkError: error.code.isNetwork,
      );
    }
  }
}
