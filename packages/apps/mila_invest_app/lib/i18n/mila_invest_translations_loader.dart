import 'dart:ui';

import 'package:app_cross/app_cross.dart';
import 'package:authentication/authentication.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:market/market.dart';
import 'package:orders/orders.dart';
import 'package:wallet/wallet.dart';

import 'shell_languages.dart';

/// `AssetLoader` que mergea las traducciones en código de cada feature.
///
/// El `path` que pide easy_localization es un placeholder que nunca se lee.
class MilaInvestTranslationsLoader extends AssetLoader {
  /// Crea el loader.
  const MilaInvestTranslationsLoader();

  /// Placeholder del `path` de easy_localization.
  static const String placeholderPath = 'i18n';

  /// Mapas de cada feature, en el orden en que se mergean.
  static const List<Map<String, Map<String, Object?>>> sources =
      <Map<String, Map<String, Object?>>>[
        shellLanguages,
        appCrossLanguages,
        authenticationLanguages,
        marketLanguages,
        ordersLanguages,
        walletLanguages,
      ];

  /// Traducciones mergeadas de [languageCode].
  static Map<String, Object?> merged(String languageCode) {
    final Map<String, Object?> result = <String, Object?>{};
    for (final Map<String, Map<String, Object?>> source in sources) {
      result.addAll(source[languageCode] ?? const <String, Object?>{});
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      merged(locale.languageCode);
}
