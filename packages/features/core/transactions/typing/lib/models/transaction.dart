import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

import '../enums/transaction_type.dart';

/// Un movimiento de dinero en una cuenta.
class Transaction extends Equatable {
  /// Crea un movimiento.
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.orderId,
  });

  /// Id del movimiento.
  final String id;

  /// Tipo.
  final TransactionType type;

  /// Monto con signo: positivo entra a la cuenta, negativo sale.
  final Money amount;

  /// Descripción que entrega la API.
  final String description;

  /// Instante, en UTC.
  final DateTime createdAt;

  /// Orden que lo originó, si hay.
  final String? orderId;

  @override
  List<Object?> get props => <Object?>[
    id,
    type,
    amount,
    description,
    createdAt,
    orderId,
  ];
}
