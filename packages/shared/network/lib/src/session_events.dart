import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Evento de sesión que emite la capa de red.
enum SessionEvent {
  /// La sesión ya no es válida: el refresh falló o el token es inválido.
  expired,
}

/// Canal por el que la red avisa que la sesión expiró.
///
/// El provider de sesión de `authentication` lo escucha; la red no conoce a
/// las features.
final class SessionEvents {
  final StreamController<SessionEvent> _controller =
      StreamController<SessionEvent>.broadcast();

  /// Eventos de sesión.
  Stream<SessionEvent> get stream => _controller.stream;

  /// Cierra el canal.
  Future<void> dispose() => _controller.close();

  /// Avisa que la sesión expiró.
  void notifyExpired() {
    if (!_controller.isClosed) {
      _controller.add(SessionEvent.expired);
    }
  }
}

/// Provider del canal de eventos de sesión.
final Provider<SessionEvents> sessionEventsProvider = Provider<SessionEvents>((
  Ref ref,
) {
  final SessionEvents events = SessionEvents();
  ref.onDispose(events.dispose);
  return events;
});
