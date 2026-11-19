import 'package:network/network.dart';

/// Par de tokens que devuelven login, registro y refresh.
class TokensDto {
  /// Crea el DTO.
  const TokensDto({required this.accessToken, required this.refreshToken});

  /// Lee el DTO. Lanza [FormatException] si falta un campo.
  factory TokensDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json);
    return TokensDto(
      accessToken: reader.string('access_token'),
      refreshToken: reader.string('refresh_token'),
    );
  }

  /// Access token.
  final String accessToken;

  /// Refresh token.
  final String refreshToken;

  /// Convierte a los tokens que guarda el `TokenStore`.
  AuthTokens toDomain() =>
      AuthTokens(accessToken: accessToken, refreshToken: refreshToken);

  @override
  String toString() => 'TokensDto(***)';
}
