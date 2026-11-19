import 'package:network/network.dart';
import 'package:transactions_typing/transactions_typing.dart';

/// `transaction` del contrato.
class TransactionDto {
  /// Crea el DTO.
  const TransactionDto(this._transaction);

  /// Lee el DTO. Lanza [FormatException] si el JSON no cumple el contrato.
  factory TransactionDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json);
    return TransactionDto(
      Transaction(
        id: reader.string('id'),
        type: TransactionType.fromApiCode(reader.string('type')),
        amount: reader.money('amount', reader.currency('currency')),
        description: reader.string('description'),
        orderId: reader.stringOrNull('order_id'),
        createdAt: reader.dateTime('created_at'),
      ),
    );
  }

  final Transaction _transaction;

  /// Convierte a dominio.
  Transaction toDomain() => _transaction;
}
