import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

/// Comprobante de un depósito virtual.
class DepositReceipt extends Equatable {
  /// Crea el comprobante.
  const DepositReceipt({
    required this.transactionId,
    required this.amount,
    required this.createdAt,
  });

  /// Id del movimiento creado.
  final String transactionId;

  /// Monto depositado.
  final Money amount;

  /// Instante del depósito, en UTC.
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[transactionId, amount, createdAt];
}
