import '../models/registration_data.dart';
import '../models/user.dart';

/// Servicio de authentication.
///
/// Sus métodos lanzan `AuthException`.
abstract interface class IAuthenticationService {
  /// Inicia sesión, guarda los tokens y devuelve el usuario.
  Future<User> login({required String email, required String password});

  /// Registra un usuario, guarda los tokens y lo devuelve.
  Future<User> register(RegistrationData data);

  /// Recupera la sesión guardada: `null` si no hay tokens o ya no valen.
  ///
  /// Lanza `AuthException` de red si no se pudo consultar: en ese caso la
  /// sesión no se descarta.
  Future<User?> restoreSession();

  /// Cierra la sesión en el servidor (si se puede) y borra los tokens.
  Future<void> logout();
}
