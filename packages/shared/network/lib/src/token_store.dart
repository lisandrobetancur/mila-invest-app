import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Par de tokens de una sesión.
class AuthTokens extends Equatable {
  /// Crea un par de tokens.
  const AuthTokens({required this.accessToken, required this.refreshToken});

  /// Access token (vive 15 min).
  final String accessToken;

  /// Refresh token (vive 7 días y rota en cada refresh).
  final String refreshToken;

  @override
  List<Object?> get props => <Object?>[accessToken, refreshToken];

  /// Nunca expone los tokens: evita que terminen en un log por accidente.
  @override
  String toString() => 'AuthTokens(***)';
}

/// Almacén de los tokens de la sesión.
abstract interface class TokenStore {
  /// Tokens guardados, o `null` si no hay sesión.
  Future<AuthTokens?> read();

  /// Guarda (o reemplaza) los tokens.
  Future<void> save(AuthTokens tokens);

  /// Borra los tokens.
  Future<void> clear();
}

/// Almacén en memoria: tests y `API_MODE=fake`.
final class InMemoryTokenStore implements TokenStore {
  /// Crea un almacén en memoria, opcionalmente con una sesión inicial.
  InMemoryTokenStore([this._tokens]);

  AuthTokens? _tokens;

  @override
  Future<void> clear() async => _tokens = null;

  @override
  Future<AuthTokens?> read() async => _tokens;

  @override
  Future<void> save(AuthTokens tokens) async => _tokens = tokens;
}

/// Provider del almacén de tokens. Lo sobrescribe el shell.
final Provider<TokenStore> tokenStoreProvider = Provider<TokenStore>(
  (Ref ref) => throw UnimplementedError('tokenStoreProvider'),
);
