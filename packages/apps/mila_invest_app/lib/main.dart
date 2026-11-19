import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utilities/utilities.dart';

import 'config/app_config.dart';
import 'di/app_overrides.dart';
import 'i18n/mila_invest_translations_loader.dart';
import 'mila_invest_app.dart';

/// Handle del árbol semántico forzado por `ENABLE_SEMANTICS`. Se conserva
/// durante toda la vida de la app para que el árbol no se libere.
SemanticsHandle? qaSemanticsHandle;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppConfig config = AppConfig.fromEnvironment();
  if (config.enableSemantics) {
    // Builds de QA: el árbol semántico (y con él los identificadores)
    // existe siempre; en web es lo que hace aparecer los flt-semantics.
    qaSemanticsHandle = SemanticsBinding.instance.ensureSemantics();
  }
  configureUrlStrategy();
  await EasyLocalization.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: buildAppOverrides(config),
      child: EasyLocalization(
        supportedLocales: const <Locale>[Locale('es'), Locale('en')],
        path: MilaInvestTranslationsLoader.placeholderPath,
        assetLoader: const MilaInvestTranslationsLoader(),
        fallbackLocale: const Locale('es'),
        startLocale: const Locale('es'),
        saveLocale: false,
        useOnlyLangCode: true,
        child: const MilaInvestApp(),
      ),
    ),
  );
}
