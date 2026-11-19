import 'package:network/network.dart';

import 'dto/dashboard_summary_dto.dart';

/// Habla con `/dashboard/summary`. Devuelve DTOs.
class DashboardRemoteDataSource {
  /// Crea el data source.
  const DashboardRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /dashboard/summary`.
  Future<DashboardSummaryDto> summary() async {
    final ApiResponse response = await _client.get('/dashboard/summary');
    return DashboardSummaryDto.fromJson(response.json);
  }
}
