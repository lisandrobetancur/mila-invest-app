import '../enums/auth_field.dart';
import 'auth_error_code.dart';

/// Excepción tipada de authentication.
///
/// El service la lanza y el controller la captura: nunca cruza a la vista.
class AuthException implements Exception {
  /// Crea la excepción.
  const AuthException(
    this.code, {
    this.fieldMessageKeys = const <AuthField, String>{},
  });

  /// Código del error.
  final AuthErrorCode code;

  /// Clave de traducción del error de cada campo, si el error trae campos.
  final Map<AuthField, String> fieldMessageKeys;

  @override
  String toString() => 'AuthException(${code.name})';
}
