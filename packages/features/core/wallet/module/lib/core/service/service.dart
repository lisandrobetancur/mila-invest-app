import 'package:network/network.dart';
import 'package:typing/typing.dart';
import 'package:wallet_typing/wallet_typing.dart';

import '../data/dto/account_dto.dart';
import '../data/dto/deposit_dto.dart';
import '../data/wallet_remote_data_source.dart';

/// Implementación de [IWalletService].
///
/// Igual que en orders, es dueña de la regla de idempotencia: una clave por
/// intento del usuario, reutilizada si el intento anterior con el mismo
/// monto falló por red.
class WalletService implements IWalletService {
  /// Crea el service.
  WalletService({
    required WalletRemoteDataSource dataSource,
    required IdGenerator idGenerator,
  }) : _dataSource = dataSource,
       _idGenerator = idGenerator;

  final WalletRemoteDataSource _dataSource;
  final IdGenerator _idGenerator;
  Money? _pendingAmount;
  String? _pendingKey;

  @override
  Future<List<Account>> accounts() async {
    try {
      final List<AccountDto> accounts = await _dataSource.accounts();
      return accounts
          .map((AccountDto dto) => dto.toDomain())
          .toList(growable: false);
    } on ApiException catch (error) {
      throw WalletException(WalletErrorCode.fromApiCode(error.code));
    } on FormatException {
      throw const WalletException(WalletErrorCode.unexpectedResponse);
    }
  }

  @override
  Future<DepositReceipt> deposit(Money amount) async {
    final String key = _pendingAmount == amount && _pendingKey != null
        ? _pendingKey!
        : _idGenerator.newId();
    _pendingAmount = amount;
    _pendingKey = key;
    try {
      final DepositReceiptDto receipt = await _dataSource.deposit(
        DepositRequestDto.fromDomain(amount),
        idempotencyKey: key,
      );
      _clearPending();
      return receipt.toDomain();
    } on ApiException catch (error) {
      if (!error.isNetwork) {
        _clearPending();
      }
      throw WalletException(WalletErrorCode.fromApiCode(error.code));
    } on FormatException {
      throw const WalletException(WalletErrorCode.unexpectedResponse);
    }
  }

  void _clearPending() {
    _pendingAmount = null;
    _pendingKey = null;
  }
}
