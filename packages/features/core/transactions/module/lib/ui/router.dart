import 'package:flutter/widgets.dart';
import 'package:navigator/navigator.dart';

import 'views/movements/movements.dart';

/// Rutas de transactions dentro del shell (tab Actividad).
final List<AppRoute> transactionsShellRoutes = <AppRoute>[
  AppRoute(
    MovementsView.route,
    name: MovementsView.name,
    widget: (BuildContext context, AppRouteParams params) =>
        MovementsView(params: params),
  ),
];
