import 'package:dashboard_typing/dashboard_typing.dart';
import 'package:network/network.dart';

import '../data/dashboard_remote_data_source.dart';

/// Implementación de [IDashboardService].
class DashboardService implements IDashboardService {
  /// Crea el service.
  const DashboardService({required DashboardRemoteDataSource dataSource})
    : _dataSource = dataSource;

  final DashboardRemoteDataSource _dataSource;

  @override
  Future<DashboardSummary> summary() async {
    try {
      return (await _dataSource.summary()).toDomain();
    } on ApiException catch (error) {
      throw DashboardException(DashboardErrorCode.fromApiCode(error.code));
    } on FormatException {
      throw const DashboardException(DashboardErrorCode.unexpectedResponse);
    }
  }
}
