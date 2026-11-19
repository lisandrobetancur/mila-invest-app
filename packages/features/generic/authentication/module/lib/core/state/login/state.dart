part of 'login.dart';

/// Estado del formulario de login.
class LoginState extends Equatable {
  /// Crea el estado.
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.submitStatus = SubmitStatus.idle,
    this.showValidation = false,
    this.errorKey,
    this.isNetworkError = false,
  });

  static const Object _unset = Object();

  /// Email escrito.
  final String email;

  /// Contraseña escrita.
  final String password;

  /// `true` si la contraseña se muestra oculta.
  final bool obscurePassword;

  /// Estado del envío.
  final SubmitStatus submitStatus;

  /// `true` después del primer intento de envío: desde ahí se muestran los
  /// errores de campo.
  final bool showValidation;

  /// Clave de traducción del error general, si hay.
  final String? errorKey;

  /// `true` si el error general fue de red.
  final bool isNetworkError;

  /// Clave del error del campo email, o `null` si es válido.
  String? get emailErrorKey {
    if (!showValidation) {
      return null;
    }
    return Validators.isEmail(email) ? null : 'auth.field_error.email_invalid';
  }

  /// Clave del error del campo contraseña, o `null` si es válido.
  String? get passwordErrorKey => showValidation && password.isEmpty
      ? 'auth.field_error.password_required'
      : null;

  /// `true` si el formulario se puede enviar.
  bool get isValid => Validators.isEmail(email) && password.isNotEmpty;

  /// Copia el estado. `errorKey: null` borra el error general.
  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    SubmitStatus? submitStatus,
    bool? showValidation,
    Object? errorKey = _unset,
    bool? isNetworkError,
  }) => LoginState(
    email: email ?? this.email,
    password: password ?? this.password,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    submitStatus: submitStatus ?? this.submitStatus,
    showValidation: showValidation ?? this.showValidation,
    errorKey: identical(errorKey, _unset) ? this.errorKey : errorKey as String?,
    isNetworkError: isNetworkError ?? this.isNetworkError,
  );

  @override
  List<Object?> get props => <Object?>[
    email,
    password,
    obscurePassword,
    submitStatus,
    showValidation,
    errorKey,
    isNetworkError,
  ];

  /// Nunca expone la contraseña.
  @override
  String toString() => 'LoginState(${submitStatus.name})';
}
