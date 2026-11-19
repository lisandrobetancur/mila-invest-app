import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../services/i_wallet_service.dart';

/// Servicio de wallet. Lo implementa el módulo por override.
final Provider<IWalletService> walletServiceProvider = Provider<IWalletService>(
  (Ref ref) => throw UnimplementedError('walletServiceProvider'),
);

/// Cuentas del usuario, de solo lectura.
///
/// Lo muestran la billetera, el ticket de orden y el depósito. Quien hace
/// una escritura que mueve saldo (una orden, un depósito) lo invalida con
/// `ref.invalidate(accountsProvider)`; las vistas con movimientos lo
/// escuchan como aviso de que el dinero cambió.
final FutureProvider<List<Account>> accountsProvider =
    FutureProvider<List<Account>>(
      (Ref ref) => throw UnimplementedError('accountsProvider'),
    );
