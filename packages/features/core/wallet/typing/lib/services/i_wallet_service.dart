import 'package:typing/typing.dart';

import '../models/account.dart';
import '../models/deposit_receipt.dart';

/// Servicio de wallet. Sus métodos lanzan `WalletException`.
abstract interface class IWalletService {
  /// Cuentas del usuario (COP, MXN y PEN en la fase 1).
  Future<List<Account>> accounts();

  /// Deposita [amount] virtual en la cuenta de su moneda.
  ///
  /// Lleva `Idempotency-Key`: una por intento del usuario. Si el intento
  /// anterior falló por red y [amount] es el mismo, se reutiliza la clave.
  Future<DepositReceipt> deposit(Money amount);
}
