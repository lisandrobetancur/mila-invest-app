import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_store.dart';

/// Almacén de tokens sobre `flutter_secure_storage`.
///
/// En Android usa el Keystore y en iOS el Keychain. **Limitación conocida:**
/// en web el plugin guarda en el almacenamiento del navegador, que no es un
/// almacén seguro; es aceptable porque la app es una simulación sin dinero
/// real.
final class SecureTokenStore implements TokenStore {
  /// Crea un almacén seguro.
  SecureTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessKey = 'mila_invest.access_token';
  static const String _refreshKey = 'mila_invest.refresh_token';

  final FlutterSecureStorage _storage;
  AuthTokens? _cache;
  bool _loaded = false;

  @override
  Future<void> clear() async {
    _cache = null;
    _loaded = true;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  @override
  Future<AuthTokens?> read() async {
    if (_loaded) {
      return _cache;
    }
    final String? access = await _storage.read(key: _accessKey);
    final String? refresh = await _storage.read(key: _refreshKey);
    _cache = access == null || refresh == null
        ? null
        : AuthTokens(accessToken: access, refreshToken: refresh);
    _loaded = true;
    return _cache;
  }

  @override
  Future<void> save(AuthTokens tokens) async {
    _cache = tokens;
    _loaded = true;
    await _storage.write(key: _accessKey, value: tokens.accessToken);
    await _storage.write(key: _refreshKey, value: tokens.refreshToken);
  }
}
