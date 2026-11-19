import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Única fuente de tiempo de la app.
///
/// Nadie llama `DateTime.now()` fuera de este archivo: las vistas, los
/// services y los controllers piden la hora al [Clock] inyectado.
abstract interface class Clock {
  /// Instante actual, siempre en UTC.
  DateTime nowUtc();
}

/// Reloj del sistema, implementación por defecto de [Clock].
final class SystemClock implements Clock {
  /// Crea un reloj del sistema.
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

/// Reloj fijo, para tests y para el backend falso.
final class FixedClock implements Clock {
  /// Crea un reloj detenido en [instant].
  FixedClock(DateTime instant) : _instant = instant.toUtc();

  DateTime _instant;

  /// Mueve el reloj [duration] hacia adelante.
  void advance(Duration duration) => _instant = _instant.add(duration);

  @override
  DateTime nowUtc() => _instant;
}

/// Provider del reloj de la app.
final Provider<Clock> clockProvider = Provider<Clock>(
  (Ref ref) => const SystemClock(),
);
