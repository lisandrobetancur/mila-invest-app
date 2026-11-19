import 'package:app_cross_typing/app_cross_typing.dart';
import 'package:authentication_typing/authentication_typing.dart';
import 'package:navigator/navigator.dart';

import 'shell_locations.dart';

/// Decide a dónde va cada navegación según el arranque, el onboarding y la
/// sesión. Es una función pura de su entrada, para poder testearla sin
/// widgets.
class AppRedirect {
  /// Crea el redirect.
  const AppRedirect({
    required this.gate,
    required this.session,
    required this.preferences,
  });

  /// Donde se estaciona la ubicación pedida.
  final BootstrapGate gate;

  /// Estado de la sesión.
  final SessionState session;

  /// Preferencias (para saber si el onboarding ya se vio).
  final AppPreferences preferences;

  static const Set<String> _authPaths = <String>{
    AuthRoutes.loginPath,
    AuthRoutes.registerPath,
  };

  /// Ubicación a la que hay que ir en lugar de [uri], o `null` para seguir.
  String? resolve(Uri uri) {
    if (DeepLinks.isAppLink(uri)) {
      return DeepLinks.normalize(uri);
    }
    final String path = uri.path.isEmpty ? '/' : uri.path;
    final String location = uri.toString();
    final bool isSplash = path == AppCrossRoutes.splashPath;
    final bool isOnboarding = path == AppCrossRoutes.onboardingPath;
    final bool isAuth = _authPaths.contains(path);
    final bool isPublic = isSplash || isOnboarding || isAuth;

    if (!gate.isReady) {
      if (isSplash) {
        return null;
      }
      gate.park(location);
      return AppCrossRoutes.splashPath;
    }

    if (session.isAuthenticated) {
      return isPublic ? gate.take() ?? ShellLocations.home : null;
    }

    if (!isPublic) {
      gate.park(location);
    }
    if (!preferences.onboardingSeen) {
      return isOnboarding ? null : AppCrossRoutes.onboardingPath;
    }
    return isAuth ? null : AuthRoutes.loginPath;
  }
}
