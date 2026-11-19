import 'app_cross_error_code.dart';

/// Excepción tipada de app_cross.
class AppCrossException implements Exception {
  /// Crea la excepción.
  const AppCrossException(this.code);

  /// Código del error.
  final AppCrossErrorCode code;

  @override
  String toString() => 'AppCrossException(${code.name})';
}
