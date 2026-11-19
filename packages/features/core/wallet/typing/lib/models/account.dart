import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

/// Cuenta del usuario en una moneda.
class Account extends Equatable {
  /// Crea una cuenta.
  const Account({
    required this.id,
    required this.currency,
    required this.available,
    required this.reserved,
  });

  /// Id de la cuenta.
  final String id;

  /// Moneda de la cuenta.
  final Currency currency;

  /// Saldo disponible para operar.
  final Money available;

  /// Saldo reservado por órdenes pendientes.
  final Money reserved;

  /// `true` si la cuenta no tiene saldo de ningún tipo.
  bool get isEmpty => available.isZero && reserved.isZero;

  @override
  List<Object?> get props => <Object?>[id, currency, available, reserved];
}

/// Búsquedas sobre la lista de cuentas.
extension AccountList on List<Account> {
  /// Cuenta en [currency], o `null` si no existe.
  Account? inCurrency(Currency currency) {
    for (final Account account in this) {
      if (account.currency == currency) {
        return account;
      }
    }
    return null;
  }

  /// `true` si ninguna cuenta tiene saldo.
  bool get allEmpty => every((Account account) => account.isEmpty);
}
