import 'package:network/network.dart';
import 'package:typing/typing.dart';
import 'package:wallet_typing/wallet_typing.dart';

/// Una cuenta de `GET /accounts`.
class AccountDto {
  /// Crea el DTO.
  const AccountDto({
    required this.id,
    required this.currency,
    required this.available,
    required this.reserved,
  });

  /// Lee el DTO. Lanza [FormatException] si el JSON no cumple el contrato.
  factory AccountDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json);
    final Currency currency = reader.currency('currency');
    return AccountDto(
      id: reader.string('id'),
      currency: currency,
      available: reader.money('available', currency),
      reserved: reader.money('reserved', currency),
    );
  }

  /// Id.
  final String id;

  /// Moneda.
  final Currency currency;

  /// Disponible.
  final Money available;

  /// Reservado.
  final Money reserved;

  /// Convierte a dominio.
  Account toDomain() => Account(
    id: id,
    currency: currency,
    available: available,
    reserved: reserved,
  );
}
