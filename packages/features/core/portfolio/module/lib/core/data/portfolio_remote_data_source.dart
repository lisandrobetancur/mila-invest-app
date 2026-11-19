import 'package:network/network.dart';

import 'dto/portfolio_dto.dart';

/// Habla con `/portfolio`. Devuelve DTOs.
class PortfolioRemoteDataSource {
  /// Crea el data source.
  const PortfolioRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /portfolio`.
  Future<PortfolioDto> portfolio() async {
    final ApiResponse response = await _client.get('/portfolio');
    return PortfolioDto.fromJson(response.json);
  }
}
