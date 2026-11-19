import 'package:app_cross_constants/app_cross_constants.dart';
import 'package:authentication_constants/authentication_constants.dart';
import 'package:dashboard_constants/dashboard_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_constants/market_constants.dart';
import 'package:mila_invest_app/i18n/mila_invest_translations_loader.dart';
import 'package:mila_invest_app/shell_ids.dart';
import 'package:orders_constants/orders_constants.dart';
import 'package:portfolio_constants/portfolio_constants.dart';
import 'package:transactions_constants/transactions_constants.dart';
import 'package:wallet_constants/wallet_constants.dart';

final RegExp _pattern = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');

const Map<String, List<String>> _byFeature = <String, List<String>>{
  'shell': ShellIds.all,
  'app_cross': AppCrossIds.all,
  'authentication': AuthIds.all,
  'market': MarketIds.all,
  'orders': OrdersIds.all,
  'wallet': WalletIds.all,
  'portfolio': PortfolioIds.all,
  'transactions': TransactionsIds.all,
  'dashboard': DashboardIds.all,
};

void main() {
  test('ningún id choca entre features y todos cumplen la convención', () {
    final Map<String, String> owner = <String, String>{};
    for (final MapEntry<String, List<String>> feature in _byFeature.entries) {
      for (final String id in feature.value) {
        expect(_pattern.hasMatch(id), isTrue, reason: id);
        expect(
          owner.containsKey(id),
          isFalse,
          reason: '$id está en ${owner[id]} y en ${feature.key}',
        );
        owner[id] = feature.key;
      }
    }
  });

  test('las traducciones mergeadas no pisan claves entre features', () {
    for (final String language in <String>['es', 'en']) {
      final Set<String> roots = <String>{};
      for (final Map<String, Map<String, Object?>> source
          in MilaInvestTranslationsLoader.sources) {
        for (final String root in source[language]!.keys) {
          expect(roots.add(root), isTrue, reason: '$language: $root');
        }
      }
    }
  });
}
