import 'package:network/network.dart';
import 'package:portfolio_typing/portfolio_typing.dart';

import '../data/portfolio_remote_data_source.dart';

/// Implementación de [IPortfolioService].
class PortfolioService implements IPortfolioService {
  /// Crea el service.
  const PortfolioService({required PortfolioRemoteDataSource dataSource})
    : _dataSource = dataSource;

  final PortfolioRemoteDataSource _dataSource;

  @override
  Future<Portfolio> portfolio() async {
    try {
      return (await _dataSource.portfolio()).toDomain();
    } on ApiException catch (error) {
      throw PortfolioException(PortfolioErrorCode.fromApiCode(error.code));
    } on FormatException {
      throw const PortfolioException(PortfolioErrorCode.unexpectedResponse);
    }
  }
}
