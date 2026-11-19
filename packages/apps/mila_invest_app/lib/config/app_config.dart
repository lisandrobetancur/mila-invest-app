import 'package:fake_backend/fake_backend.dart';

/// Modo de backend.
enum ApiMode {
  /// Backend falso en memoria (por defecto: `flutter run` funciona sin API).
  fake,

  /// `mila-invest-api` real, vía `DioApiClient`.
  remote;

  /// Resuelve el valor del flag; uno desconocido es [fake].
  static ApiMode fromName(String name) =>
      name.toLowerCase() == 'remote' ? ApiMode.remote : ApiMode.fake;
}

/// Flags de `--dart-define`.
///
/// Es el **único** archivo del repo que lee `String.fromEnvironment` y sus
/// variantes; el resto de la app recibe estos valores por providers.
class AppConfig {
  /// Crea una configuración. En la app se usa [AppConfig.fromEnvironment];
  /// en tests, este constructor.
  const AppConfig({
    this.apiMode = ApiMode.fake,
    this.apiBaseUrl = defaultApiBaseUrl,
    this.fakeSeed = FakeSeed.demo,
    this.fastAnimations = false,
    this.priceRefreshSeconds = 15,
    this.enableSemantics = false,
    this.version = '0.1.0',
  });

  /// Lee los flags con que se compiló la app.
  factory AppConfig.fromEnvironment() => AppConfig(
    apiMode: ApiMode.fromName(
      const String.fromEnvironment('API_MODE', defaultValue: 'fake'),
    ),
    apiBaseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: defaultApiBaseUrl,
    ),
    fakeSeed: FakeSeed.fromName(
      const String.fromEnvironment('FAKE_SEED', defaultValue: 'demo'),
    ),
    fastAnimations: const bool.fromEnvironment('FAST_ANIMATIONS'),
    priceRefreshSeconds: const int.fromEnvironment(
      'PRICE_REFRESH_SECONDS',
      defaultValue: 15,
    ),
    enableSemantics: const bool.fromEnvironment('ENABLE_SEMANTICS'),
    version: const String.fromEnvironment('APP_VERSION', defaultValue: '0.1.0'),
  );

  /// URL por defecto del backend real. En el emulador de Android es
  /// `http://10.0.2.2:8000/api/v1`; en un teléfono físico, la IP de la PC.
  static const String defaultApiBaseUrl = 'http://localhost:8000/api/v1';

  /// `API_MODE`.
  final ApiMode apiMode;

  /// `API_BASE_URL`.
  final String apiBaseUrl;

  /// `FAKE_SEED`.
  final FakeSeed fakeSeed;

  /// `FAST_ANIMATIONS`: todas las duraciones en cero.
  final bool fastAnimations;

  /// `PRICE_REFRESH_SECONDS`: cero apaga el refresco de precios.
  final int priceRefreshSeconds;

  /// `ENABLE_SEMANTICS`: fuerza el árbol semántico (builds de QA).
  final bool enableSemantics;

  /// Versión de la app.
  final String version;

  /// `true` con el backend falso.
  bool get isFake => apiMode == ApiMode.fake;
}
