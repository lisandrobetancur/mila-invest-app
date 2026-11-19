import 'package:network/network.dart';

import 'dto/account_dto.dart';
import 'dto/deposit_dto.dart';

/// Habla con `/accounts`. Devuelve DTOs.
class WalletRemoteDataSource {
  /// Crea el data source.
  const WalletRemoteDataSource(this._client);

  final ApiClient _client;

  /// `GET /accounts`.
  Future<List<AccountDto>> accounts() async {
    final ApiResponse response = await _client.get('/accounts');
    return JsonReader.listOf(response.body)
        .map((JsonReader item) => AccountDto.fromJson(item.raw))
        .toList(growable: false);
  }

  /// `POST /accounts/{currency}/deposits`, con `Idempotency-Key`.
  Future<DepositReceiptDto> deposit(
    DepositRequestDto request, {
    required String idempotencyKey,
  }) async {
    final ApiResponse response = await _client.post(
      '/accounts/${request.currency}/deposits',
      body: request.toJson(),
      headers: <String, String>{ApiHeaders.idempotencyKey: idempotencyKey},
    );
    return DepositReceiptDto.fromJson(response.json);
  }
}
