import 'dashboard_error_code.dart';

/// Excepción tipada de dashboard.
class DashboardException implements Exception {
  /// Crea la excepción.
  const DashboardException(this.code);

  /// Código del error.
  final DashboardErrorCode code;

  @override
  String toString() => 'DashboardException(${code.name})';
}
