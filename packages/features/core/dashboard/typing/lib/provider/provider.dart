import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/i_dashboard_service.dart';

/// Servicio de dashboard. Lo implementa el módulo por override.
final Provider<IDashboardService> dashboardServiceProvider =
    Provider<IDashboardService>(
      (Ref ref) => throw UnimplementedError('dashboardServiceProvider'),
    );
