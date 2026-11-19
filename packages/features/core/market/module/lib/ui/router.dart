import 'package:flutter/widgets.dart';
import 'package:navigator/navigator.dart';

import 'views/instrument_detail/instrument_detail.dart';
import 'views/market_list/market_list.dart';

/// Rutas de market dentro del shell de navegación (tab Mercado).
final List<AppRoute> marketShellRoutes = <AppRoute>[
  AppRoute(
    MarketListView.route,
    name: MarketListView.name,
    widget: (BuildContext context, AppRouteParams params) =>
        MarketListView(params: params),
    routes: <AppRoute>[
      AppRoute(
        InstrumentDetailView.route,
        name: InstrumentDetailView.name,
        widget: (BuildContext context, AppRouteParams params) =>
            InstrumentDetailView(
              instrumentId: params.path(InstrumentDetailView.idParam),
            ),
      ),
    ],
  ),
];
