import 'package:app_cross_typing/app_cross_typing.dart';
import 'package:authentication_typing/authentication_typing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/navigator.dart';

/// Navigator de app_cross.
class AppCrossNavigator extends FeatureNavigator {
  /// Cierra los ajustes: vuelve atrás o, si se abrieron en frío, al inicio.
  void closeSettings() {
    if (navigation.canPop()) {
      navigation.pop<void>();
    } else {
      navigation.go(AppCrossRoutes.splashPath);
    }
  }

  /// Sigue después del bootstrap: el `redirect` decide a dónde.
  void continueAfterBootstrap() => navigation.refresh();

  /// Va al login al terminar o saltar el onboarding.
  void goToLogin() => navigation.go(AuthRoutes.loginPath);
}

/// Provider del navigator de app_cross.
final NotifierProvider<AppCrossNavigator, void> appCrossNavigatorProvider =
    NotifierProvider<AppCrossNavigator, void>(AppCrossNavigator.new);
