import 'package:network/network.dart';
import 'package:orders_typing/orders_typing.dart';
import 'package:typing/typing.dart';

import '../data/dto/order_dto.dart';
import '../data/dto/order_request_dto.dart';
import '../data/orders_remote_data_source.dart';

/// Implementación de [IOrdersService].
///
/// Es dueña de la regla de idempotencia: una `Idempotency-Key` por intento
/// del usuario. Si el envío falló por red (o la respuesta llegó rota) y el
/// usuario reintenta la misma orden, se reutiliza la clave: el backend
/// devuelve la misma respuesta en vez de ejecutar dos veces. Si la orden
/// cambió, o el intento anterior terminó (bien o con un rechazo de
/// negocio), la clave es nueva.
class OrdersService implements IOrdersService {
  /// Crea el service.
  OrdersService({
    required OrdersRemoteDataSource dataSource,
    required IdGenerator idGenerator,
  }) : _dataSource = dataSource,
       _idGenerator = idGenerator;

  final OrdersRemoteDataSource _dataSource;
  final IdGenerator _idGenerator;
  OrderRequest? _pendingRequest;
  String? _pendingKey;

  @override
  Future<Order> order(String id) =>
      _guard(() async => (await _dataSource.order(id)).toDomain());

  @override
  Future<Paginated<Order>> orders({
    OrderStatus? status,
    String? cursor,
    int? limit,
  }) => _guard(() async {
    final Paginated<OrderDto> page = await _dataSource.orders(
      status: status?.apiCode,
      cursor: cursor,
      limit: limit,
    );
    return Paginated<Order>(
      items: page.items
          .map((OrderDto dto) => dto.toDomain())
          .toList(growable: false),
      nextCursor: page.nextCursor,
    );
  });

  @override
  Future<OrderPreview> preview(OrderRequest request) => _guard(
    () async => (await _dataSource.preview(
      OrderRequestDto.fromDomain(request),
    )).toDomain(),
  );

  @override
  Future<Order> submit(OrderRequest request) async {
    final String key = _pendingRequest == request && _pendingKey != null
        ? _pendingKey!
        : _idGenerator.newId();
    _pendingRequest = request;
    _pendingKey = key;
    try {
      final OrderDto order = await _dataSource.submit(
        OrderRequestDto.fromDomain(request),
        idempotencyKey: key,
      );
      _clearPending();
      return order.toDomain();
    } on ApiException catch (error) {
      if (!error.isNetwork) {
        _clearPending();
      }
      throw _translate(error);
    } on FormatException {
      throw const OrdersException(OrdersErrorCode.unexpectedResponse);
    }
  }

  void _clearPending() {
    _pendingRequest = null;
    _pendingKey = null;
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw _translate(error);
    } on FormatException {
      throw const OrdersException(OrdersErrorCode.unexpectedResponse);
    }
  }

  OrdersException _translate(ApiException error) => OrdersException(
    OrdersErrorCode.fromApiCode(error.code),
    fieldCodes: <String, String>{
      for (final ApiFieldError field in error.fieldErrors)
        field.field: field.code,
    },
  );
}
