import 'package:authentication_typing/authentication_typing.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';

/// Usuario tal como lo entrega `GET /me` y el registro.
class UserDto {
  /// Crea el DTO.
  const UserDto({
    required this.id,
    required this.email,
    required this.fullName,
    required this.country,
    required this.baseCurrency,
    required this.documentType,
    required this.documentLast4,
  });

  /// Lee el DTO. Lanza [FormatException] si falta un campo o tiene otro tipo.
  factory UserDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json);
    return UserDto(
      id: reader.string('id'),
      email: reader.string('email'),
      fullName: reader.string('full_name'),
      country: reader.enumValue<Country>('country', Country.tryFromCode),
      baseCurrency: reader.currency('base_currency'),
      documentType: reader.enumValue<DocumentType>(
        'document_type',
        DocumentType.tryFromCode,
      ),
      documentLast4: reader.string('document_last4'),
    );
  }

  /// Id.
  final String id;

  /// Email.
  final String email;

  /// Nombre completo.
  final String fullName;

  /// País.
  final Country country;

  /// Moneda base.
  final Currency baseCurrency;

  /// Tipo de documento.
  final DocumentType documentType;

  /// Últimos 4 del documento.
  final String documentLast4;

  /// Convierte a dominio.
  User toDomain() => User(
    id: id,
    email: email,
    fullName: fullName,
    country: country,
    baseCurrency: baseCurrency,
    documentType: documentType,
    documentLast4: documentLast4,
  );
}
