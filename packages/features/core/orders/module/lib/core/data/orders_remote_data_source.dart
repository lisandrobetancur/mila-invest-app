import 'package:network/network.dart';
import 'package:typing/typing.dart';

import 'dto/order_dto.dart';
import 'dto/order_preview_dto.dart';
import 'dto/order_request_dto.dart';

/// Habla con `/orders`. Devuelve DTOs.
class OrdersRemoteDataSource {
  /// Crea el data source.
  const OrdersRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /orders/{id}`.
  Future<OrderDto> order(String id) async {
    final ApiResponse response = await _client.get(
      '/orders/${Uri.encodeComponent(id)}',
    );
    return OrderDto.fromJson(response.json);
  }

  /// `GET /orders`.
  Future<Paginated<OrderDto>> orders({
    String? status,
    String? cursor,
    int? limit,
  }) async {
    final ApiResponse response = await _client.get(
      '/orders',
      query: <String, Object?>{
        'status': status,
        'cursor': cursor,
        'limit': limit,
      },
    );
    return JsonReader(
      response.json,
    ).paginated<OrderDto>((JsonReader item) => OrderDto.fromJson(item.raw));
  }

  /// `POST /orders/preview`.
  Future<OrderPreviewDto> preview(OrderRequestDto request) async {
    final ApiResponse response = await _client.post(
      '/orders/preview',
      body: request.toJson(),
    );
    return OrderPreviewDto.fromJson(response.json);
  }

  /// `POST /orders`, con `Idempotency-Key`.
  Future<OrderDto> submit(
    OrderRequestDto request, {
    required String idempotencyKey,
  }) async {
    final ApiResponse response = await _client.post(
      '/orders',
      body: request.toJson(),
      headers: <String, String>{ApiHeaders.idempotencyKey: idempotencyKey},
    );
    return OrderDto.fromJson(response.json);
  }
}
