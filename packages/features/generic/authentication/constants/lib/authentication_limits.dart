/// Límites de negocio de authentication (§7.2).
abstract final class AuthLimits {
  /// Largo mínimo de la contraseña.
  static const int passwordMinLength = 8;

  /// Largo mínimo del nombre completo.
  static const int nameMinLength = 3;

  /// Largo máximo del nombre completo.
  static const int nameMaxLength = 80;

  /// Largo máximo que acepta el campo de documento (el CURP, 18).
  static const int documentMaxLength = 18;
}
