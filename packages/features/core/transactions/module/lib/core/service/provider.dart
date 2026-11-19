import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:transactions_typing/transactions_typing.dart';
import 'package:typing/typing.dart';

import '../data/transactions_remote_data_source.dart';
import 'service.dart';

/// Liga el contrato del servicio con su implementación.
final Override transactionsServiceProviderOverride = transactionsServiceProvider
    .overrideWith(
      (Ref ref) => TransactionsService(
        dataSource: TransactionsRemoteDataSource(ref.read(apiClientProvider)),
        clock: ref.read(clockProvider),
      ),
    );

/// Overrides que transactions aporta al shell.
final List<Override> transactionsOverrides = <Override>[
  transactionsServiceProviderOverride,
];
