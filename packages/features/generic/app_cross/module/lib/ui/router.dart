import 'package:flutter/widgets.dart';
import 'package:navigator/navigator.dart';

import 'views/onboarding/onboarding.dart';
import 'views/settings/settings.dart';
import 'views/splash/splash.dart';

/// Rutas full-screen de app_cross: fuera del shell de navegación.
final List<AppRoute> appCrossFullScreenRoutes = <AppRoute>[
  AppRoute(
    SplashView.route,
    name: SplashView.name,
    widget: (BuildContext context, AppRouteParams params) => const SplashView(),
  ),
  AppRoute(
    OnboardingView.route,
    name: OnboardingView.name,
    widget: (BuildContext context, AppRouteParams params) =>
        const OnboardingView(),
  ),
  AppRoute(
    SettingsView.route,
    name: SettingsView.name,
    widget: (BuildContext context, AppRouteParams params) =>
        const SettingsView(),
  ),
];
