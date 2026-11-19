import 'package:typing/typing.dart';

import '../enums/order_status.dart';
import '../models/order.dart';
import '../models/order_preview.dart';
import '../models/order_request.dart';

/// Servicio de orders. Sus métodos lanzan `OrdersException`.
abstract interface class IOrdersService {
  /// Cotiza [request] sin ejecutarla.
  Future<OrderPreview> preview(OrderRequest request);

  /// Envía [request] con `Idempotency-Key`.
  ///
  /// La clave se genera una vez por intento del usuario: si el intento
  /// anterior falló por red y [request] es el mismo, se reutiliza; si
  /// cambió, se genera otra. Nunca se reintenta solo.
  Future<Order> submit(OrderRequest request);

  /// Una página del historial, opcionalmente filtrada por [status].
  Future<Paginated<Order>> orders({
    OrderStatus? status,
    String? cursor,
    int? limit,
  });

  /// Una orden por su id.
  Future<Order> order(String id);
}
