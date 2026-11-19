import 'dart:async';

/// Agrupa ráfagas de eventos en una sola acción.
///
/// Con [duration] en cero la acción corre de inmediato, que es lo que hacen
/// los tests y los builds con `FAST_ANIMATIONS`.
final class Debouncer {
  /// Crea un debouncer con la ventana [duration].
  Debouncer(this.duration);

  /// Ventana de espera.
  final Duration duration;

  Timer? _timer;

  /// `true` si hay una acción pendiente.
  bool get isPending => _timer?.isActive ?? false;

  /// Cancela la acción pendiente, si hay una.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Libera el timer. Se llama desde `ref.onDispose`.
  void dispose() => cancel();

  /// Programa [action], descartando la anterior si estaba pendiente.
  void run(void Function() action) {
    cancel();
    if (duration == Duration.zero) {
      action();
      return;
    }
    _timer = Timer(duration, action);
  }
}
