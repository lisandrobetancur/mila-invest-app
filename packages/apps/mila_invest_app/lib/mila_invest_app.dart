import 'package:app_cross_typing/app_cross_typing.dart';
import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigator/navigator.dart';

/// Widget raíz: `MaterialApp.router` con tema e idioma de las preferencias.
///
/// Cambiar el tema o el idioma no reinicia la app ni altera ninguna `Key`,
/// y el idioma no cambia el formato de los montos.
class MilaInvestApp extends ConsumerWidget {
  /// Crea la app.
  const MilaInvestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppPreferences preferences = ref.watch(appPreferencesProvider);
    final GoRouter router = ref.watch(goRouterProvider);
    final bool instant = ref.watch(durationsProvider).isInstant;
    final Locale wanted = Locale(preferences.language.code);
    if (context.locale != wanted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && context.locale != wanted) {
          context.setLocale(wanted);
        }
      });
    }
    return MaterialApp.router(
      title: 'MILA Invest',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (preferences.theme) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      },
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(
          data: instant ? media.copyWith(disableAnimations: true) : media,
          child: SemanticLabelsScope(
            labels: SemanticLabels(
              currencyNames: <String, String>{
                'COP': context.tr('shell.a11y.cop'),
                'MXN': context.tr('shell.a11y.mxn'),
                'PEN': context.tr('shell.a11y.pen'),
                'USD': context.tr('shell.a11y.usd'),
              },
              rises: context.tr('shell.a11y.rises'),
              falls: context.tr('shell.a11y.falls'),
              unchanged: context.tr('shell.a11y.unchanged'),
              percent: context.tr('shell.a11y.percent'),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
