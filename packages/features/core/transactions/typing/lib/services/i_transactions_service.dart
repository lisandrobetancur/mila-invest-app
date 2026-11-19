import 'package:typing/typing.dart';

import '../models/transaction.dart';
import '../models/transaction_filter.dart';

/// Servicio de transactions. Sus métodos lanzan `TransactionsException`.
abstract interface class ITransactionsService {
  /// Una página de movimientos con [filter], del más nuevo al más viejo.
  Future<Paginated<Transaction>> transactions(
    TransactionFilter filter, {
    String? cursor,
    int? limit,
  });
}
