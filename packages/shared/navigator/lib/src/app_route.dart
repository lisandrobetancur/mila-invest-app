import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Parámetros ya resueltos de una ruta, sin tipos de `go_router`.
@immutable
class AppRouteParams {
  /// Crea los parámetros de una ruta.
  const AppRouteParams({
    required this.location,
    this.pathParameters = const <String, String>{},
    this.queryParameters = const <String, String>{},
  });

  /// Ubicación completa que resolvió a esta ruta.
  final String location;

  /// Parámetros de path (`:id`).
  final Map<String, String> pathParameters;

  /// Parámetros de query. Solo se usan para filtros de lista.
  final Map<String, String> queryParameters;

  /// Parámetro de path requerido.
  String path(String name) =>
      pathParameters[name] ??
      (throw StateError('La ruta $location no tiene el parámetro :$name'));

  /// Parámetro de query opcional.
  String? query(String name) => queryParameters[name];
}

/// Construye la vista de una ruta a partir de sus parámetros.
typedef AppRouteWidgetBuilder =
    Widget Function(BuildContext context, AppRouteParams params);

/// Cómo se presenta una ruta.
enum AppRoutePresentation {
  /// Página normal.
  page,

  /// Hoja modal: bottom sheet en mobile y diálogo en web ancho.
  ///
  /// Si la ruta se abre en frío, sin nada debajo (un deep link directo), se
  /// presenta como página, para no dejar nunca una pantalla en blanco.
  modal,
}

/// Contrato con el que cada feature declara una ruta.
///
/// Las features exponen `List<AppRoute>` en su `ui/router.dart` y el shell
/// las convierte con [toGoRoute]. Así ninguna feature importa `go_router`.
@immutable
class AppRoute {
  /// Declara una ruta.
  const AppRoute(
    this.path, {
    required this.name,
    required this.widget,
    this.presentation = AppRoutePresentation.page,
    this.routes = const <AppRoute>[],
  });

  /// Ancho desde el que una ruta modal se presenta como diálogo.
  static const double modalDialogBreakpoint = 768;

  /// Ancho máximo del diálogo de una ruta modal.
  static const double modalDialogMaxWidth = 480;

  /// Path de la ruta, con sus parámetros (`/market/instrument/:id`).
  final String path;

  /// Nombre único de la ruta.
  final String name;

  /// Constructor de la vista.
  final AppRouteWidgetBuilder widget;

  /// Presentación de la ruta.
  final AppRoutePresentation presentation;

  /// Rutas hijas.
  final List<AppRoute> routes;

  /// Convierte la ruta, y sus hijas, a `go_router`.
  GoRoute toGoRoute({GlobalKey<NavigatorState>? parentNavigatorKey}) => GoRoute(
    path: path,
    name: name,
    parentNavigatorKey: parentNavigatorKey,
    pageBuilder: _buildPage,
    routes: <RouteBase>[
      for (final AppRoute route in routes)
        route.toGoRoute(parentNavigatorKey: parentNavigatorKey),
    ],
  );

  Page<void> _buildPage(BuildContext context, GoRouterState state) {
    final AppRouteParams params = AppRouteParams(
      location: state.uri.toString(),
      pathParameters: state.pathParameters,
      queryParameters: state.uri.queryParameters,
    );
    Widget build(BuildContext context) => widget(context, params);

    final bool hasPageBelow =
        GoRouter.of(
          context,
        ).routerDelegate.currentConfiguration.matches.length >
        1;
    if (presentation == AppRoutePresentation.modal && hasPageBelow) {
      return AppModalPage<void>(key: state.pageKey, name: name, builder: build);
    }
    return MaterialPage<void>(
      key: state.pageKey,
      name: name,
      child: Builder(builder: build),
    );
  }
}

/// Página que se presenta como bottom sheet o como diálogo, según el ancho.
class AppModalPage<T> extends Page<T> {
  /// Crea una página modal.
  const AppModalPage({required this.builder, super.key, super.name});

  /// Constructor del contenido.
  final WidgetBuilder builder;

  @override
  Route<T> createRoute(BuildContext context) {
    final bool isWide =
        MediaQuery.sizeOf(context).width >= AppRoute.modalDialogBreakpoint;
    if (isWide) {
      return DialogRoute<T>(
        context: context,
        settings: this,
        builder: (BuildContext context) => Dialog(
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppRoute.modalDialogMaxWidth,
            ),
            child: builder(context),
          ),
        ),
      );
    }
    return ModalBottomSheetRoute<T>(
      settings: this,
      isScrollControlled: true,
      useSafeArea: true,
      builder: builder,
    );
  }
}
