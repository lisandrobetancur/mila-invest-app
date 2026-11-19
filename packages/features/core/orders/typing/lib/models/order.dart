import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

import '../enums/order_side.dart';
import '../enums/order_status.dart';
import '../enums/order_type.dart';
import '../errors/orders_error_code.dart';

/// Una orden enviada.
class Order extends Equatable {
  /// Crea una orden.
  const Order({
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

  /// Id de la orden.
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

  /// Moneda de la orden.
  final Currency currency;

  /// Instante de creación, en UTC.
  final DateTime createdAt;

  /// Precio de ejecución; `null` si no se ejecutó.
  final Money? executedPrice;

  /// Monto bruto; `null` si no se ejecutó.
  final Money? gross;

  /// Comisión; `null` si no se ejecutó.
  final Money? commission;

  /// Total; `null` si no se ejecutó.
  final Money? total;

  /// Motivo del rechazo; `null` salvo en `REJECTED`.
  final OrdersErrorCode? rejectCode;

  /// Instante de ejecución, en UTC.
  final DateTime? filledAt;

  /// `true` si se ejecutó.
  bool get isFilled => status == OrderStatus.filled;

  /// `true` si fue rechazada.
  bool get isRejected => status == OrderStatus.rejected;

  /// Ticker, deducido del id del instrumento (`<TICKER>-<PAÍS>`).
  String get ticker {
    final int dash = instrumentId.lastIndexOf('-');
    return dash <= 0 ? instrumentId : instrumentId.substring(0, dash);
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    instrumentId,
    side,
    type,
    quantity,
    status,
    currency,
    createdAt,
    executedPrice,
    gross,
    commission,
    total,
    rejectCode,
    filledAt,
  ];
}
