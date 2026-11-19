import 'portfolio_error_code.dart';

/// Excepción tipada de portfolio.
class PortfolioException implements Exception {
  /// Crea la excepción.
  const PortfolioException(this.code);

  /// Código del error.
  final PortfolioErrorCode code;

  @override
  String toString() => 'PortfolioException(${code.name})';
}
