import 'package:orders_typing/orders_typing.dart';

/// Cuerpo de `POST /orders/preview` y `POST /orders`.
class OrderRequestDto {
  /// Crea el DTO desde el pedido del ticket.
  OrderRequestDto.fromDomain(OrderRequest request)
    : instrumentId = request.instrumentId,
      side = request.side.apiCode,
      type = request.type.apiCode,
      quantity = request.quantity;

  /// Instrumento.
  final String instrumentId;

  /// Lado (`BUY` / `SELL`).
  final String side;

  /// Tipo (`MARKET`).
  final String type;

  /// Cantidad.
  final int quantity;

  /// Cuerpo JSON.
  Map<String, Object?> toJson() => <String, Object?>{
    'instrument_id': instrumentId,
    'side': side,
    'type': type,
    'quantity': quantity,
  };
}
