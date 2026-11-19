import 'package:flutter/foundation.dart';

/// Único lugar de la app donde se consulta la plataforma.
///
/// Nadie usa `kIsWeb` ni `defaultTargetPlatform` fuera de este archivo.
abstract final class PlatformGuard {
  /// `true` si la app corre en el navegador.
  static bool get isWeb => kIsWeb;

  /// `true` si la app corre en Android nativo.
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// `true` si la app corre en iOS nativo.
  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// `true` si la app corre en un teléfono o tablet nativo.
  static bool get isMobile => isAndroid || isIOS;

  /// `true` si la app corre en un escritorio nativo.
  static bool get isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  /// `true` en builds de release.
  static bool get isRelease => kReleaseMode;
}
