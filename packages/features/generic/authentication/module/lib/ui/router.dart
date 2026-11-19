import 'package:flutter/widgets.dart';
import 'package:navigator/navigator.dart';

import 'views/login/login.dart';
import 'views/register/register.dart';

/// Rutas full-screen de authentication: fuera del shell de navegación.
final List<AppRoute> authenticationFullScreenRoutes = <AppRoute>[
  AppRoute(
    LoginView.route,
    name: LoginView.name,
    widget: (BuildContext context, AppRouteParams params) => const LoginView(),
  ),
  AppRoute(
    RegisterView.route,
    name: RegisterView.name,
    widget: (BuildContext context, AppRouteParams params) =>
        const RegisterView(),
  ),
];
