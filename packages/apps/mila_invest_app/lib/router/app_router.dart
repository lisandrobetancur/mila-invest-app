import 'package:app_cross/app_cross.dart';
import 'package:app_cross_typing/app_cross_typing.dart';
import 'package:authentication/authentication.dart';
import 'package:authentication_typing/authentication_typing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:market/market.dart';
import 'package:navigator/navigator.dart';
import 'package:orders/orders.dart';

import 'app_navigation_shell.dart';
import 'app_redirect.dart';
import 'not_found_view.dart';

/// Avisa al router que vuelva a evaluar el `redirect`.
class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Construye el router de la app con las rutas que aporta cada feature.
final Override goRouterProviderOverride = goRouterProvider.overrideWith((
  Ref ref,
) {
  final _RouterRefresh refresh = _RouterRefresh();
  ref
    ..listen<SessionState>(sessionProvider, (_, _) => refresh.notify())
    ..listen<bool>(
      appPreferencesProvider.select(
        (AppPreferences preferences) => preferences.onboardingSeen,
      ),
      (_, _) => refresh.notify(),
    );

  List<RouteBase> fullScreen(List<AppRoute> routes) => <RouteBase>[
    for (final AppRoute route in routes)
      route.toGoRoute(parentNavigatorKey: _rootNavigatorKey),
  ];

  // En web, `push` también actualiza la URL: el detalle de un instrumento o
  // el ticket quedan con una dirección compartible y un F5 vuelve a ellos.
  GoRouter.optionURLReflectsImperativeAPIs = true;
  final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppCrossRoutes.splashPath,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) => AppRedirect(
      gate: ref.read(bootstrapGateProvider),
      session: ref.read(sessionProvider),
      preferences: ref.read(appPreferencesProvider),
    ).resolve(state.uri),
    errorBuilder: (BuildContext context, GoRouterState state) =>
        const NotFoundView(),
    routes: <RouteBase>[
      ...fullScreen(appCrossFullScreenRoutes),
      ...fullScreen(authenticationFullScreenRoutes),
      ...fullScreen(ordersFullScreenRoutes),
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell shell,
            ) => AppNavigationShell(shell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              for (final AppRoute route in marketShellRoutes) route.toGoRoute(),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              for (final AppRoute route in ordersShellRoutes) route.toGoRoute(),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
