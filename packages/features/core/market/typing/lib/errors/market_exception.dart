import 'market_error_code.dart';

/// Excepción tipada de market.
class MarketException implements Exception {
  /// Crea la excepción.
  const MarketException(this.code);

  /// Código del error.
  final MarketErrorCode code;

  @override
  String toString() => 'MarketException(${code.name})';
}
