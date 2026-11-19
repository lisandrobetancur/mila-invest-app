import 'package:flutter/widgets.dart';
import 'package:navigator/navigator.dart';

import 'views/overview/overview.dart';

/// Rutas de portfolio dentro del shell (tab Portafolio).
final List<AppRoute> portfolioShellRoutes = <AppRoute>[
  AppRoute(
    PortfolioOverviewView.route,
    name: PortfolioOverviewView.name,
    widget: (BuildContext context, AppRouteParams params) =>
        const PortfolioOverviewView(),
  ),
];
