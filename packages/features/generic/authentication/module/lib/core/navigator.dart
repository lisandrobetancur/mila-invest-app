import 'package:authentication_typing/authentication_typing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/navigator.dart';

/// Navigator de authentication.
///
/// A dónde ir después de un login o de un logout lo decide el `redirect`
/// del shell, a partir del estado de la sesión: este navigator solo cubre
/// los saltos entre login y registro.
class AuthNavigator extends FeatureNavigator {
  /// Olvida la ubicación estacionada antes de un logout voluntario, para no
  /// volver a esta pantalla en el próximo login.
  void forgetCurrentLocation() =>
      ref.read(bootstrapGateProvider).forget(ignoring: navigation.location);

  /// Va al login.
  void goToLogin() => navigation.go(AuthRoutes.loginPath);

  /// Va al registro.
  void goToRegister() => navigation.go(AuthRoutes.registerPath);
}

/// Provider del navigator de authentication.
final NotifierProvider<AuthNavigator, void> authNavigatorProvider =
    NotifierProvider<AuthNavigator, void>(AuthNavigator.new);
