import 'package:authentication_typing/authentication_typing.dart';
import 'package:network/network.dart';

import '../data/authentication_remote_data_source.dart';
import '../data/dto/registration_dto.dart';
import '../data/dto/tokens_dto.dart';
import '../data/dto/user_dto.dart';

/// Implementación de [IAuthenticationService].
///
/// Convierte DTOs en modelos, guarda los tokens y traduce `ApiException` a
/// [AuthException].
class AuthenticationService implements IAuthenticationService {
  /// Crea el service.
  const AuthenticationService({
    required AuthenticationRemoteDataSource dataSource,
    required TokenStore tokenStore,
  }) : _dataSource = dataSource,
       _tokenStore = tokenStore;

  final AuthenticationRemoteDataSource _dataSource;
  final TokenStore _tokenStore;

  /// Clave de traducción del error de un campo, según el código de la API.
  static String fieldMessageKey(String apiCode) => switch (apiCode) {
    'INVALID_FORMAT' => 'auth.field_error.invalid_format',
    'TOO_WEAK' => 'auth.field_error.too_weak',
    'INVALID_LENGTH' => 'auth.field_error.invalid_length',
    'REQUIRED' => 'auth.field_error.required',
    _ => 'auth.field_error.invalid',
  };

  @override
  Future<User> login({required String email, required String password}) =>
      _guard(() async {
        final TokensDto tokens = await _dataSource.login(
          email: email,
          password: password,
        );
        await _tokenStore.save(tokens.toDomain());
        final UserDto user = await _dataSource.me();
        return user.toDomain();
      });

  @override
  Future<void> logout() async {
    final AuthTokens? tokens = await _tokenStore.read();
    try {
      if (tokens != null) {
        await _dataSource.logout(tokens.refreshToken);
      }
    } on ApiException {
      // Cerrar sesión siempre funciona en el dispositivo, aunque el servidor
      // no responda: el refresh vence solo.
    } finally {
      await _tokenStore.clear();
    }
  }

  @override
  Future<User> register(RegistrationData data) => _guard(() async {
    final RegistrationResponseDto response = await _dataSource.register(
      RegistrationRequestDto.fromDomain(data),
    );
    await _tokenStore.save(response.tokens.toDomain());
    return response.user.toDomain();
  });

  @override
  Future<User?> restoreSession() async {
    if (await _tokenStore.read() == null) {
      return null;
    }
    try {
      return (await _dataSource.me()).toDomain();
    } on ApiException catch (error) {
      if (error.status == 401) {
        await _tokenStore.clear();
        return null;
      }
      throw _translate(error);
    } on FormatException {
      throw const AuthException(AuthErrorCode.unexpectedResponse);
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw _translate(error);
    } on FormatException {
      throw const AuthException(AuthErrorCode.unexpectedResponse);
    }
  }

  AuthException _translate(ApiException error) {
    final AuthErrorCode code = AuthErrorCode.fromApiCode(error.code);
    final Map<AuthField, String> fields = <AuthField, String>{};
    for (final ApiFieldError fieldError in error.fieldErrors) {
      final AuthField? field = AuthField.tryFromApiName(fieldError.field);
      if (field != null) {
        fields[field] = fieldError.code == 'TAKEN'
            ? code.messageKey
            : fieldMessageKey(fieldError.code);
      }
    }
    if (code == AuthErrorCode.emailTaken) {
      fields.putIfAbsent(AuthField.email, () => code.messageKey);
    }
    if (code == AuthErrorCode.documentTaken) {
      fields.putIfAbsent(AuthField.documentNumber, () => code.messageKey);
    }
    return AuthException(code, fieldMessageKeys: fields);
  }
}
