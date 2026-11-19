import 'package:typing/typing.dart';
import 'package:wallet_constants/wallet_constants.dart';

/// Identificadores por moneda, desde las constantes de `WalletIds`.
abstract final class WalletIdsOf {
  /// Disponible de la cuenta en [currency].
  static String available(Currency currency) => switch (currency) {
    Currency.mxn => WalletIds.mxnAvailableText,
    Currency.pen => WalletIds.penAvailableText,
    Currency.cop || Currency.usd => WalletIds.copAvailableText,
  };

  /// Depositar en la cuenta en [currency].
  static String deposit(Currency currency) => switch (currency) {
    Currency.mxn => WalletIds.mxnDepositButton,
    Currency.pen => WalletIds.penDepositButton,
    Currency.cop || Currency.usd => WalletIds.copDepositButton,
  };

  /// Reservado de la cuenta en [currency].
  static String reserved(Currency currency) => switch (currency) {
    Currency.mxn => WalletIds.mxnReservedText,
    Currency.pen => WalletIds.penReservedText,
    Currency.cop || Currency.usd => WalletIds.copReservedText,
  };

  /// Segmento de moneda del depósito.
  static String segment(Currency currency) => switch (currency) {
    Currency.mxn => WalletIds.depositCurrencyMxnSegment,
    Currency.pen => WalletIds.depositCurrencyPenSegment,
    Currency.cop || Currency.usd => WalletIds.depositCurrencyCopSegment,
  };
}
