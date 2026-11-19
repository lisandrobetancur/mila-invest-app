import 'package:app_cross_constants/app_cross_constants.dart';
import 'package:authentication_constants/authentication_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_constants/market_constants.dart';
import 'package:mila_invest_app/config/app_config.dart';
import 'package:mila_invest_app/di/app_overrides.dart';
import 'package:mila_invest_app/i18n/mila_invest_translations_loader.dart';
import 'package:mila_invest_app/mila_invest_app.dart';
import 'package:mila_invest_app/shell_ids.dart';
import 'package:navigator/navigator.dart';
import 'package:orders_constants/orders_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilities/utilities.dart';

const AppConfig _config = AppConfig(
  fastAnimations: true,
  priceRefreshSeconds: 0,
);

Future<void> _pumpApp(
  WidgetTester tester, {
  AppConfig config = _config,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        ...buildAppOverrides(config),
        loggerProvider.overrideWithValue(const SilentAppLogger()),
      ],
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
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String id) async {
  final Finder finder = find.bySemanticsIdentifier(id);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('primera vez: onboarding → login demo → mercado → comprar', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pumpApp(tester);

    expect(
      find.bySemanticsIdentifier(AppCrossIds.onboardingView),
      findsOneWidget,
    );
    await _tap(tester, AppCrossIds.onboardingSkipButton);

    expect(find.bySemanticsIdentifier(AuthIds.loginView), findsOneWidget);
    await _tap(tester, AuthIds.loginDemoButton);
    await _tap(tester, AuthIds.loginSubmitButton);

    expect(find.bySemanticsIdentifier(MarketIds.listView), findsOneWidget);
    expect(find.bySemanticsIdentifier(ShellIds.marketTab), findsOneWidget);
    expect(find.bySemanticsIdentifier(ShellIds.activityTab), findsOneWidget);
    await _tap(tester, MarketIds.listInstrumentItem('ISA-CO'));

    expect(find.bySemanticsIdentifier(MarketIds.detailView), findsOneWidget);
    expect(
      find.bySemanticsIdentifier(MarketIds.detailSellButton),
      findsNothing,
    );
    await _tap(tester, MarketIds.detailBuyButton);

    expect(find.bySemanticsIdentifier(OrdersIds.ticketView), findsOneWidget);
    await _tap(tester, OrdersIds.ticketReviewButton);
    await _tap(tester, OrdersIds.confirmSubmitButton);
    expect(
      tester
          .getSemantics(find.bySemanticsIdentifier(OrdersIds.resultStatusText))
          .label,
      'Ejecutada',
    );
    await _tap(tester, OrdersIds.resultDoneButton);

    expect(
      find.bySemanticsIdentifier(MarketIds.detailSellButton),
      findsOneWidget,
    );
    expect(
      tester
          .getSemantics(
            find.bySemanticsIdentifier(MarketIds.detailPositionQuantityText),
          )
          .label,
      '1 unidades',
    );

    await _tap(tester, ShellIds.activityTab);
    expect(find.bySemanticsIdentifier(OrdersIds.historyView), findsOneWidget);
    handle.dispose();
  });

  testWidgets('un deep link sin sesión pasa por login y vuelve al '
      'instrumento', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'mila_invest.onboarding_seen': true,
    });
    await _pumpApp(tester);
    expect(find.bySemanticsIdentifier(AuthIds.loginView), findsOneWidget);

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(MilaInvestApp)),
    );
    container
        .read(goRouterProvider)
        .go('milainvest://market/instrument/BAP-PE');
    await tester.pumpAndSettle();
    expect(find.bySemanticsIdentifier(AuthIds.loginView), findsOneWidget);

    await _tap(tester, AuthIds.loginDemoButton);
    await _tap(tester, AuthIds.loginSubmitButton);

    expect(find.bySemanticsIdentifier(MarketIds.detailView), findsOneWidget);
    expect(
      tester
          .getSemantics(find.bySemanticsIdentifier(MarketIds.detailTickerText))
          .label,
      'BAP',
    );
    handle.dispose();
  });
}
