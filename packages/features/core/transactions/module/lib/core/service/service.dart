import 'package:network/network.dart';
import 'package:transactions_typing/transactions_typing.dart';
import 'package:typing/typing.dart';

import '../data/dto/transaction_dto.dart';
import '../data/transactions_remote_data_source.dart';

/// Implementación de [ITransactionsService].
class TransactionsService implements ITransactionsService {
  /// Crea el service.
  const TransactionsService({
    required TransactionsRemoteDataSource dataSource,
    required Clock clock,
  }) : _dataSource = dataSource,
       _clock = clock;

  final TransactionsRemoteDataSource _dataSource;
  final Clock _clock;

  @override
  Future<Paginated<Transaction>> transactions(
    TransactionFilter filter, {
    String? cursor,
    int? limit,
  }) async {
    try {
      final Paginated<TransactionDto> page = await _dataSource.transactions(
        type: filter.type?.apiCode,
        from: filter.range.fromOf(_clock.nowUtc()),
        cursor: cursor,
        limit: limit,
      );
      return Paginated<Transaction>(
        items: page.items
            .map((TransactionDto dto) => dto.toDomain())
            .toList(growable: false),
        nextCursor: page.nextCursor,
      );
    } on ApiException catch (error) {
      throw TransactionsException(
        TransactionsErrorCode.fromApiCode(error.code),
      );
    } on FormatException {
      throw const TransactionsException(
        TransactionsErrorCode.unexpectedResponse,
      );
    }
  }
}
