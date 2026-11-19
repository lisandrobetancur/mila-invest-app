import 'package:equatable/equatable.dart';

import '../enums/order_side.dart';
import '../enums/order_type.dart';

/// Lo que el usuario pide en el ticket. Es igual para el preview y para la
/// orden: dos pedidos iguales son el mismo intento.
class OrderRequest extends Equatable {
  /// Crea un pedido.
  const OrderRequest({
    required this.instrumentId,
    required this.side,
    required this.quantity,
    this.type = OrderType.market,
  });

  /// Instrumento.
  final String instrumentId;

  /// Lado.
  final OrderSide side;

  /// Cantidad entera.
  final int quantity;

  /// Tipo; en la fase 1, siempre a mercado.
  final OrderType type;

  @override
  List<Object?> get props => <Object?>[instrumentId, side, quantity, type];
}
