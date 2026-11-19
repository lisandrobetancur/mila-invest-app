import 'package:flutter/widgets.dart';
import 'package:navigator/navigator.dart';

import 'views/home/home.dart';

/// Rutas de dashboard dentro del shell (tab Inicio).
final List<AppRoute> dashboardShellRoutes = <AppRoute>[
  AppRoute(
    DashboardHomeView.route,
    name: DashboardHomeView.name,
    widget: (BuildContext context, AppRouteParams params) =>
        const DashboardHomeView(),
  ),
];
