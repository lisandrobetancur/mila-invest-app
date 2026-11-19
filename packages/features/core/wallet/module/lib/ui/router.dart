import 'package:flutter/widgets.dart';
import 'package:navigator/navigator.dart';
import 'package:typing/typing.dart';
import 'package:wallet_typing/wallet_typing.dart';

import 'views/accounts/accounts.dart';
import 'views/deposit/deposit.dart';

/// Rutas full-screen de wallet: la billetera y el depósito (hoja modal).
final List<AppRoute> walletFullScreenRoutes = <AppRoute>[
  AppRoute(
    AccountsView.route,
    name: AccountsView.name,
    widget: (BuildContext context, AppRouteParams params) =>
        const AccountsView(),
  ),
  AppRoute(
    DepositView.route,
    name: DepositView.name,
    presentation: AppRoutePresentation.modal,
    widget: (BuildContext context, AppRouteParams params) => DepositView(
      currency:
          Currency.tryFromCode(params.path(WalletRoutes.currencyParam)) ??
          Currency.cop,
    ),
  ),
];
