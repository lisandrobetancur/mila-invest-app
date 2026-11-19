import 'package:equatable/equatable.dart';

/// Credenciales de la cuenta demo del backend falso.
///
/// Solo existen con `API_MODE=fake`: el shell las entrega y el login ofrece
/// "Usar cuenta demo".
class DemoCredentials extends Equatable {
  /// Crea las credenciales demo.
  const DemoCredentials({required this.email, required this.password});

  /// Email de la cuenta demo.
  final String email;

  /// Contraseña de la cuenta demo.
  final String password;

  @override
  List<Object?> get props => <Object?>[email, password];
}
