import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lo que comparten [ViewModel] y [AutoDisposeViewModel].
///
/// * [initState] y [postInit], que separan "cuál es el estado inicial" de
///   "qué dependencias necesito"; [postInit] es sincrónico y corre durante
///   `build()`, antes de que nadie pueda invocar un método del controller.
/// * [runPostBuild], que dispara la carga inicial en el microtask siguiente,
///   porque Riverpod prohíbe escribir `state` durante `build()`.
/// * [mountedKey], el token que se captura antes de un `await` para saber,
///   al volver, si el controller se destruyó en el medio.
mixin ViewModelCore<T> {
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

  T _start(Ref ref) {
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
}

/// Base de los controllers que viven toda la app (sesión, preferencias).
///
/// Es un [Notifier] con lo que agrega [ViewModelCore].
abstract class ViewModel<T> extends Notifier<T> with ViewModelCore<T> {
  @override
  T build() => _start(ref);
}

/// Base de los controllers de una vista.
///
/// Igual que [ViewModel], pero se destruye cuando nadie lo observa: ahí se
/// cancelan sus timers y sus peticiones dejan de escribir estado.
abstract class AutoDisposeViewModel<T> extends AutoDisposeNotifier<T>
    with ViewModelCore<T> {
  @override
  T build() => _start(ref);
}

/// Base de los controllers de una vista que depende de un argumento (por
/// ejemplo, el id del instrumento del detalle).
///
/// Dentro de [initState] y [postInit] el argumento está en `arg`.
abstract class AutoDisposeFamilyViewModel<T, A>
    extends AutoDisposeFamilyNotifier<T, A>
    with ViewModelCore<T> {
  @override
  T build(A arg) => _start(ref);
}
