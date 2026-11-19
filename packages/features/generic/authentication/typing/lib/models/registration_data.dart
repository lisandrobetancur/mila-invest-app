import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

/// Datos del formulario de registro, ya normalizados.
class RegistrationData extends Equatable {
  /// Crea los datos de registro.
  const RegistrationData({
    required this.email,
    required this.password,
    required this.fullName,
    required this.country,
    required this.documentType,
    required this.documentNumber,
  });

  /// Email, en minúsculas.
  final String email;

  /// Contraseña. Viaja tal cual: el cliente no la hashea.
  final String password;

  /// Nombre completo.
  final String fullName;

  /// País de registro.
  final Country country;

  /// Tipo de documento.
  final DocumentType documentType;

  /// Número de documento.
  final String documentNumber;

  @override
  List<Object?> get props => <Object?>[
    email,
    password,
    fullName,
    country,
    documentType,
    documentNumber,
  ];

  /// Nunca expone la contraseña ni el documento.
  @override
  String toString() => 'RegistrationData(${country.code})';
}
