import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router_provider.dart';

/// Fachada sobre `go_router`.
///
/// Los `FeatureNavigator` navegan a través de ella, por nombre o path de
/// ruta, y los tests la reemplazan con un doble.
class NavigationManager {
  /// Crea la fachada sobre [_router].
  NavigationManager(this._router);

  final GoRouter _router;

  /// Ubicación actual, con su query.
  String get location => _router.state.uri.toString();

  /// `true` si hay algo a lo que volver.
  bool canPop() => _router.canPop();

  /// Reemplaza la pila por [location].
  void go(String location) => _router.go(location);

  /// Reemplaza la pila por la ruta [name].
  void goNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
  }) => _router.goNamed(
    name,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
  );

  /// Ubicación de la ruta [name] con sus parámetros.
  String namedLocation(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
  }) => _router.namedLocation(
    name,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
  );

  /// Parámetro de path de la ubicación actual, o `null` si no existe.
  String? pathParamOf(String name) => _router.state.pathParameters[name];

  /// Vuelve a la pantalla anterior, si hay una.
  void pop<T extends Object?>([T? result]) {
    if (_router.canPop()) {
      _router.pop<T>(result);
    }
  }

  /// Apila [location] sobre la pantalla actual.
  Future<T?> push<T extends Object?>(String location) =>
      _router.push<T>(location);

  /// Apila la ruta [name] sobre la pantalla actual.
  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
  }) => _router.pushNamed<T>(
    name,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
  );

  /// Vuelve a evaluar el `redirect` (por ejemplo, tras un cambio de sesión).
  void refresh() => _router.refresh();
}

/// Provider de la fachada de navegación.
final Provider<NavigationManager> navigationManagerProvider =
    Provider<NavigationManager>(
      (Ref ref) => NavigationManager(ref.watch(goRouterProvider)),
    );
