import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/navigator.dart';
import 'package:typing/typing.dart';
import 'package:wallet_typing/wallet_typing.dart';

/// Navigator de wallet.
class WalletNavigator extends FeatureNavigator {
  /// Cierra la billetera o el depósito: atrás, o a la billetera si se abrió
  /// en frío.
  void close() {
    if (navigation.canPop()) {
      navigation.pop<void>();
    } else {
      navigation.go(WalletRoutes.accountsPath);
    }
  }

  /// Abre el depósito en [currency].
  void openDeposit(Currency currency) =>
      navigation.push<void>(WalletRoutes.depositLocation(currency.code));
}

/// Provider del navigator de wallet.
final NotifierProvider<WalletNavigator, void> walletNavigatorProvider =
    NotifierProvider<WalletNavigator, void>(WalletNavigator.new);
