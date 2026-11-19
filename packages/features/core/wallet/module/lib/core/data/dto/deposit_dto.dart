import 'package:network/network.dart';
import 'package:typing/typing.dart';
import 'package:wallet_typing/wallet_typing.dart';

/// Cuerpo de `POST /accounts/{currency}/deposits`.
class DepositRequestDto {
  /// Crea el DTO desde el monto.
  DepositRequestDto.fromDomain(Money amount)
    : currency = amount.currency.code,
      amount = amount.apiValue;

  /// Código de moneda, para el path.
  final String currency;

  /// Monto como string decimal.
  final String amount;

  /// Cuerpo JSON.
  Map<String, Object?> toJson() => <String, Object?>{'amount': amount};
}

/// El `transaction` que devuelve un depósito.
class DepositReceiptDto {
  /// Crea el DTO.
  const DepositReceiptDto({
    required this.transactionId,
    required this.amount,
    required this.createdAt,
  });

  /// Lee el DTO. Lanza [FormatException] si el JSON no cumple el contrato.
  factory DepositReceiptDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json);
    return DepositReceiptDto(
      transactionId: reader.string('id'),
      amount: reader.money('amount', reader.currency('currency')),
      createdAt: reader.dateTime('created_at'),
    );
  }

  /// Id del movimiento.
  final String transactionId;

  /// Monto.
  final Money amount;

  /// Instante.
  final DateTime createdAt;

  /// Convierte a dominio.
  DepositReceipt toDomain() => DepositReceipt(
    transactionId: transactionId,
    amount: amount,
    createdAt: createdAt,
  );
}
