import 'package:authentication_typing/authentication_typing.dart';
import 'tokens_dto.dart';
import 'user_dto.dart';

/// Cuerpo de `POST /auth/register`.
class RegistrationRequestDto {
  /// Crea el DTO desde el formulario.
  RegistrationRequestDto.fromDomain(RegistrationData data)
    : email = data.email,
      password = data.password,
      fullName = data.fullName,
      country = data.country.code,
      documentType = data.documentType.code,
      documentNumber = data.documentNumber;

  /// Email.
  final String email;

  /// Contraseña.
  final String password;

  /// Nombre completo.
  final String fullName;

  /// Código de país.
  final String country;

  /// Código de tipo de documento.
  final String documentType;

  /// Número de documento.
  final String documentNumber;

  /// Cuerpo JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'email': email,
    'password': password,
    'full_name': fullName,
    'country': country,
    'document_type': documentType,
    'document_number': documentNumber,
  };

  @override
  String toString() => 'RegistrationRequestDto($country)';
}

/// Respuesta de `POST /auth/register`: `{ user, tokens }`.
class RegistrationResponseDto {
  /// Crea el DTO.
  const RegistrationResponseDto({required this.user, required this.tokens});

  /// Lee el DTO. Lanza [FormatException] si falta un campo.
  factory RegistrationResponseDto.fromJson(Map<String, Object?> json) {
    final Object? user = json['user'];
    final Object? tokens = json['tokens'];
    if (user is! Map<String, Object?> || tokens is! Map<String, Object?>) {
      throw const FormatException('Registro sin "user" o sin "tokens"');
    }
    return RegistrationResponseDto(
      user: UserDto.fromJson(user),
      tokens: TokensDto.fromJson(tokens),
    );
  }

  /// Usuario creado.
  final UserDto user;

  /// Tokens de la sesión nueva.
  final TokensDto tokens;
}
