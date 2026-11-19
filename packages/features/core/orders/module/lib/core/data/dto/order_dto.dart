import 'package:network/network.dart';
import 'package:orders_typing/orders_typing.dart';
import 'package:typing/typing.dart';

/// `order` del contrato.
class OrderDto {
  /// Crea el DTO.
  const OrderDto({
    required this.id,
    required this.instrumentId,
    required this.side,
    required this.type,
    required this.quantity,
    required this.status,
    required this.currency,
    required this.createdAt,
    this.executedPrice,
    this.gross,
    this.commission,
    this.total,
    this.rejectCode,
    this.filledAt,
  });

  /// Lee el DTO. Lanza [FormatException] si el JSON no cumple el contrato.
  ///
  /// Los montos son opcionales (una orden rechazada no los tiene), pero si
  /// vienen tienen que ser strings decimales.
  factory OrderDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json);
    final Currency currency = reader.currency('currency');
    return OrderDto(
      id: reader.string('id'),
      instrumentId: reader.string('instrument_id'),
      side: reader.enumValue<OrderSide>('side', OrderSide.tryFromApiCode),
      type: reader.enumValue<OrderType>('type', OrderType.tryFromApiCode),
      quantity: reader.integer('quantity'),
      status: reader.enumValue<OrderStatus>(
        'status',
        OrderStatus.tryFromApiCode,
      ),
      currency: currency,
      createdAt: reader.dateTime('created_at'),
      executedPrice: reader.moneyOrNull('executed_price', currency),
      gross: reader.moneyOrNull('gross', currency),
      commission: reader.moneyOrNull('commission', currency),
      total: reader.moneyOrNull('total', currency),
      rejectCode: reader.stringOrNull('reject_code'),
      filledAt: reader.dateTimeOrNull('filled_at'),
    );
  }

  /// Id.
  final String id;

  /// Instrumento.
  final String instrumentId;

  /// Lado.
  final OrderSide side;

  /// Tipo.
  final OrderType type;

  /// Cantidad.
  final int quantity;

  /// Estado.
  final OrderStatus status;

  /// Moneda.
  final Currency currency;

  /// Creación.
  final DateTime createdAt;

  /// Precio de ejecución.
  final Money? executedPrice;

  /// Bruto.
  final Money? gross;

  /// Comisión.
  final Money? commission;

  /// Total.
  final Money? total;

  /// Código de rechazo, tal como llega.
  final String? rejectCode;

  /// Ejecución.
  final DateTime? filledAt;

  /// Convierte a dominio.
  Order toDomain() {
    final String? reject = rejectCode;
    return Order(
      id: id,
      instrumentId: instrumentId,
      side: side,
      type: type,
      quantity: quantity,
      status: status,
      currency: currency,
      createdAt: createdAt,
      executedPrice: executedPrice,
      gross: gross,
      commission: commission,
      total: total,
      rejectCode: reject == null ? null : OrdersErrorCode.fromApiCode(reject),
      filledAt: filledAt,
    );
  }
}
