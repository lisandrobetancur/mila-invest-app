import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base de todos los controllers de la app.
///
/// Es un [Notifier] con tres cosas encima:
///
/// * [initState] y [postInit], que separan "cuál es el estado inicial" de
///   "qué dependencias necesito"; [postInit] es sincrónico y corre durante
///   `build()`, antes de que nadie pueda invocar un método del controller.
/// * [runPostBuild], que dispara la carga inicial en el microtask siguiente,
///   porque Riverpod prohíbe escribir `state` durante `build()`.
/// * [mountedKey], el token que se captura antes de un `await` para saber,
///   al volver, si el controller se destruyó en el medio.
abstract class ViewModel<T> extends Notifier<T> {
  Object _mountedKey = Object();

  /// Token vigente mientras esta instancia esté montada.
  ///
  /// Se captura antes de un `await` y se verifica después con [isMounted].
  Object get mountedKey => _mountedKey;

  /// Estado inicial del controller. Corre antes de [postInit].
  T initState();

  /// Resuelve aquí las dependencias (`service`, `navigator`, `logger`).
  ///
  /// Sincrónico a propósito: cuando termina, el controller ya está listo
  /// para recibir llamadas.
  void postInit();

  @override
  T build() {
    final Object key = Object();
    _mountedKey = key;
    ref.onDispose(() {
      if (identical(_mountedKey, key)) {
        _mountedKey = Object();
      }
    });
    final T initial = initState();
    postInit();
    return initial;
  }

  /// `true` si [key] sigue siendo el token vigente.
  bool isMounted(Object key) => identical(_mountedKey, key);

  /// Corre [action] en el microtask siguiente al `build()`.
  ///
  /// Si el controller se destruye antes, [action] no corre.
  void runPostBuild(FutureOr<void> Function() action) {
    final Object key = _mountedKey;
    unawaited(
      Future<void>.microtask(() async {
        if (!isMounted(key)) {
          return;
        }
        await action();
      }),
    );
  }
}
