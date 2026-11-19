import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Logger de la app.
///
/// Nadie usa `print`. **Nunca** se loguean tokens, contraseñas ni números de
/// documento completos.
abstract interface class AppLogger {
  /// Detalle de desarrollo.
  void debug(String message, [Object? data]);

  /// Hito normal del flujo.
  void info(String message, [Object? data]);

  /// Algo inesperado pero recuperable.
  void warn(String message, [Object? error]);

  /// Un fallo, con su causa y su traza.
  void error(String message, [Object? error, StackTrace? stackTrace]);
}

/// Implementación por defecto, sobre `package:logger`.
final class ConsoleAppLogger implements AppLogger {
  /// Crea un logger de consola.
  ConsoleAppLogger({Logger? logger})
    : _logger =
          logger ??
          Logger(printer: SimplePrinter(printTime: true, colors: false));

  final Logger _logger;

  @override
  void debug(String message, [Object? data]) =>
      _logger.d(_compose(message, data));

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  @override
  void info(String message, [Object? data]) =>
      _logger.i(_compose(message, data));

  @override
  void warn(String message, [Object? error]) =>
      _logger.w(message, error: error);

  String _compose(String message, Object? data) =>
      data == null ? message : '$message $data';
}

/// Logger que no escribe nada. Útil en tests y en widget tests.
final class SilentAppLogger implements AppLogger {
  /// Crea un logger silencioso.
  const SilentAppLogger();

  @override
  void debug(String message, [Object? data]) {}

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {}

  @override
  void info(String message, [Object? data]) {}

  @override
  void warn(String message, [Object? error]) {}
}

/// Provider del logger de la app.
final Provider<AppLogger> loggerProvider = Provider<AppLogger>(
  (Ref ref) => ConsoleAppLogger(),
);
