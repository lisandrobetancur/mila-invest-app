/// Estado de la sesión del usuario.
enum SessionStatus {
  /// Todavía no se sabe: la app está arrancando.
  unknown,

  /// Hay un usuario con sesión válida.
  authenticated,

  /// No hay sesión.
  unauthenticated,
}
