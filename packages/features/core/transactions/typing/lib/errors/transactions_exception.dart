import 'transactions_error_code.dart';

/// Excepción tipada de transactions.
class TransactionsException implements Exception {
  /// Crea la excepción.
  const TransactionsException(this.code);

  /// Código del error.
  final TransactionsErrorCode code;

  @override
  String toString() => 'TransactionsException(${code.name})';
}
