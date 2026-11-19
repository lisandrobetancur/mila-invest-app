import 'wallet_error_code.dart';

/// Excepción tipada de wallet.
class WalletException implements Exception {
  /// Crea la excepción.
  const WalletException(this.code);

  /// Código del error.
  final WalletErrorCode code;

  @override
  String toString() => 'WalletException(${code.name})';
}
