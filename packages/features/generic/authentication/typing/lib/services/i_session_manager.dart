/// Acciones sobre la sesión que otras features pueden pedir.
///
/// El splash pide [restore] y los ajustes piden [signOut], sin conocer el
/// módulo de authentication.
abstract interface class ISessionManager {
  /// Resuelve la sesión al arrancar. Lanza `AuthException` de red si no se
  /// pudo consultar el servidor.
  Future<void> restore();

  /// Cierra la sesión por decisión del usuario.
  Future<void> signOut();
}
