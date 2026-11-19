import 'package:network/network.dart';
import 'package:typing/typing.dart';

import 'dto/transaction_dto.dart';

/// Habla con `/transactions`. Devuelve DTOs.
class TransactionsRemoteDataSource {
  /// Crea el data source.
  const TransactionsRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /transactions`.
  Future<Paginated<TransactionDto>> transactions({
    String? type,
    DateTime? from,
    DateTime? to,
    String? cursor,
    int? limit,
  }) async {
    final ApiResponse response = await _client.get(
      '/transactions',
      query: <String, Object?>{
        'type': type,
        'from': from?.toUtc().toIso8601String(),
        'to': to?.toUtc().toIso8601String(),
        'cursor': cursor,
        'limit': limit,
      },
    );
    return JsonReader(response.json).paginated<TransactionDto>(
      (JsonReader item) => TransactionDto.fromJson(item.raw),
    );
  }
}
