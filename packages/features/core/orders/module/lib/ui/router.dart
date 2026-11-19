import 'package:flutter/widgets.dart';
import 'package:navigator/navigator.dart';
import 'package:orders_typing/orders_typing.dart';

import 'views/order_detail/order_detail.dart';
import 'views/order_ticket/order_ticket.dart';
import 'views/orders_history/orders_history.dart';

/// Rutas full-screen de orders: el ticket, como hoja modal.
final List<AppRoute> ordersFullScreenRoutes = <AppRoute>[
  AppRoute(
    OrderTicketView.route,
    name: OrderTicketView.name,
    presentation: AppRoutePresentation.modal,
    widget: (BuildContext context, AppRouteParams params) => OrderTicketView(
      instrumentId: params.path(OrdersRoutes.instrumentIdParam),
      side: OrderSide.fromRouteValue(params.path(OrdersRoutes.sideParam)),
    ),
  ),
];

/// Rutas de orders dentro del shell (tab Actividad).
final List<AppRoute> ordersShellRoutes = <AppRoute>[
  AppRoute(
    OrdersHistoryView.route,
    name: OrdersHistoryView.name,
    widget: (BuildContext context, AppRouteParams params) =>
        OrdersHistoryView(params: params),
    routes: <AppRoute>[
      AppRoute(
        OrderDetailView.route,
        name: OrderDetailView.name,
        widget: (BuildContext context, AppRouteParams params) =>
            OrderDetailView(orderId: params.path(OrdersRoutes.orderIdParam)),
      ),
    ],
  ),
];
