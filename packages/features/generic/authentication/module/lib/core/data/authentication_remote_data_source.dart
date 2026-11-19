import 'package:network/network.dart';

import 'dto/registration_dto.dart';
import 'dto/tokens_dto.dart';
import 'dto/user_dto.dart';

/// Habla con las rutas `/auth/*` y `/me`. Devuelve DTOs.
class AuthenticationRemoteDataSource {
  /// Crea el data source.
  const AuthenticationRemoteDataSource(this._client);

  final ApiClient _client;

  /// `POST /auth/login`.
  Future<TokensDto> login({
    required String email,
    required String password,
  }) async {
    final ApiResponse response = await _client.post(
      '/auth/login',
      body: <String, Object?>{'email': email, 'password': password},
    );
    return TokensDto.fromJson(response.json);
  }

  /// `POST /auth/logout`.
  Future<void> logout(String refreshToken) async {
    await _client.post(
      '/auth/logout',
      body: <String, Object?>{'refresh_token': refreshToken},
    );
  }

  /// `GET /me`.
  Future<UserDto> me() async {
    final ApiResponse response = await _client.get('/me');
    return UserDto.fromJson(response.json);
  }

  /// `POST /auth/register`.
  Future<RegistrationResponseDto> register(
    RegistrationRequestDto request,
  ) async {
    final ApiResponse response = await _client.post(
      '/auth/register',
      body: request.toJson(),
    );
    return RegistrationResponseDto.fromJson(response.json);
  }
}
