import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';
import 'package:wallet_typing/wallet_typing.dart';

import '../data/wallet_remote_data_source.dart';
import 'service.dart';

/// Liga el contrato del servicio con su implementación.
final Override walletServiceProviderOverride = walletServiceProvider
    .overrideWith(
      (Ref ref) => WalletService(
        dataSource: WalletRemoteDataSource(ref.read(apiClientProvider)),
        idGenerator: ref.read(idGeneratorProvider),
      ),
    );

/// Implementa las cuentas del usuario con el servicio.
final Override accountsProviderOverride = accountsProvider.overrideWith(
  (Ref ref) => ref.read(walletServiceProvider).accounts(),
);

/// Overrides que wallet aporta al shell.
final List<Override> walletOverrides = <Override>[
  walletServiceProviderOverride,
  accountsProviderOverride,
];
