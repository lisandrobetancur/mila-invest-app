import '../models/dashboard_summary.dart';

/// Servicio de dashboard. Sus métodos lanzan `DashboardException`.
abstract interface class IDashboardService {
  /// Resumen del inicio.
  Future<DashboardSummary> summary();
}
