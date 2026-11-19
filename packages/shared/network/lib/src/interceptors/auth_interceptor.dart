import 'package:dio/dio.dart';

import '../token_store.dart';

/// Agrega `Authorization: Bearer <access>` salvo en `/auth/*`.
final class AuthInterceptor extends Interceptor {
  /// Crea el interceptor.
  AuthInterceptor(this._tokenStore);

  /// Prefijo de las rutas que no llevan token.
  static const String authPrefix = '/auth/';

  final TokenStore _tokenStore;

  /// `true` si [path] es una ruta de autenticación.
  static bool isAuthPath(String path) => path.startsWith(authPrefix);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!isAuthPath(options.path)) {
      final AuthTokens? tokens = await _tokenStore.read();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }
}
