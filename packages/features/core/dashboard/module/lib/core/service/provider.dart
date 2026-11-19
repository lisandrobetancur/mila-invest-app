import 'package:dashboard_typing/dashboard_typing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

import '../data/dashboard_remote_data_source.dart';
import 'service.dart';

/// Liga el contrato del servicio con su implementación.
final Override dashboardServiceProviderOverride = dashboardServiceProvider
    .overrideWith(
      (Ref ref) => DashboardService(
        dataSource: DashboardRemoteDataSource(ref.read(apiClientProvider)),
      ),
    );

/// Overrides que dashboard aporta al shell.
final List<Override> dashboardOverrides = <Override>[
  dashboardServiceProviderOverride,
];
