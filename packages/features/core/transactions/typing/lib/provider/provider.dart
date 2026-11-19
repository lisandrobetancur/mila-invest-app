import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/i_transactions_service.dart';

/// Servicio de transactions. Lo implementa el módulo por override.
final Provider<ITransactionsService> transactionsServiceProvider =
    Provider<ITransactionsService>(
      (Ref ref) => throw UnimplementedError('transactionsServiceProvider'),
    );
