import 'package:app_cross_constants/app_cross_constants.dart';
import 'package:authentication_constants/authentication_constants.dart';
import 'package:dashboard_constants/dashboard_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fake_backend/fake_backend.dart';
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
import 'package:portfolio_constants/portfolio_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transactions_constants/transactions_constants.dart';
import 'package:utilities/utilities.dart';
import 'package:wallet_constants/wallet_constants.dart';

const AppConfig _config = AppConfig(
  fastAnimations: true,
  priceRefreshSeconds: 0,
);

Future<ProviderContainer> _pumpApp(
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
  return ProviderScope.containerOf(tester.element(find.byType(MilaInvestApp)));
}

Future<void> _tap(WidgetTester tester, String id) async {
  final Finder finder = find.bySemanticsIdentifier(id);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

String _label(WidgetTester tester, String id) =>
    tester.getSemantics(find.bySemanticsIdentifier(id)).label;

void _expectView(String id) =>
    expect(find.bySemanticsIdentifier(id), findsOneWidget, reason: id);

Future<void> _loginDemo(WidgetTester tester) async {
  _expectView(AuthIds.loginView);
  await _tap(tester, AuthIds.loginDemoButton);
  await _tap(tester, AuthIds.loginSubmitButton);
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('flujo completo: login demo → depósito → mercado → comprar → '
      'portafolio → Actividad → inicio actualizado', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pumpApp(tester);

    _expectView(AppCrossIds.onboardingView);
    await _tap(tester, AppCrossIds.onboardingSkipButton);
    await _loginDemo(tester);

    _expectView(DashboardIds.homeView);
    _expectView(DashboardIds.homeStateData);
    for (final String tab in <String>[
      ShellIds.homeTab,
      ShellIds.marketTab,
      ShellIds.portfolioTab,
      ShellIds.activityTab,
    ]) {
      _expectView(tab);
    }
    final String totalBefore = _label(tester, DashboardIds.homeTotalText);

    await _tap(tester, DashboardIds.homeWalletIconButton);
    _expectView(WalletIds.accountsView);
    await _tap(tester, WalletIds.copDepositButton);
    _expectView(WalletIds.depositView);
    await _tap(tester, WalletIds.suggestedItem('1000000'));
    await _tap(tester, WalletIds.depositSubmitButton);
    // El snackbar del depósito dura unos segundos sobre la pantalla.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(
      _label(tester, WalletIds.copAvailableText),
      '8.448.740 pesos colombianos',
    );
    await _tap(tester, WalletIds.accountsBackIconButton);

    await _tap(tester, ShellIds.marketTab);
    _expectView(MarketIds.listView);
    await _tap(tester, MarketIds.listInstrumentItem('ISA-CO'));
    _expectView(MarketIds.detailView);
    await _tap(tester, MarketIds.detailBuyButton);
    _expectView(OrdersIds.ticketView);
    await _tap(tester, OrdersIds.ticketQuantityIncreaseStepper);
    await _tap(tester, OrdersIds.ticketReviewButton);
    await _tap(tester, OrdersIds.confirmSubmitButton);
    expect(_label(tester, OrdersIds.resultStatusText), 'Ejecutada');
    await _tap(tester, OrdersIds.resultPortfolioButton);

    _expectView(PortfolioIds.overviewView);
    expect(
      _label(tester, PortfolioIds.positionQuantityText('ISA-CO')),
      '2 unidades',
    );

    await _tap(tester, ShellIds.activityTab);
    _expectView(TransactionsIds.listView);
    expect(find.textContaining('Compra 2 ISA'), findsOneWidget);
    await _tap(tester, TransactionsIds.listOrdersTab);
    _expectView(OrdersIds.historyView);

    await _tap(tester, ShellIds.homeTab);
    await tester.pumpAndSettle();
    _expectView(DashboardIds.homeView);
    expect(_label(tester, DashboardIds.homeTotalText), isNot(totalBefore));
    expect(find.textContaining('Comisión ISA'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('FAKE_SEED=empty: todas las vistas muestran su estado vacío', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'mila_invest.onboarding_seen': true,
    });
    await _pumpApp(
      tester,
      config: const AppConfig(
        fastAnimations: true,
        priceRefreshSeconds: 0,
        fakeSeed: FakeSeed.empty,
      ),
    );
    await _loginDemo(tester);

    _expectView(DashboardIds.homeStateEmpty);
    await _tap(tester, ShellIds.portfolioTab);
    _expectView(PortfolioIds.overviewStateEmpty);
    await _tap(tester, ShellIds.activityTab);
    _expectView(TransactionsIds.listStateEmpty);
    await _tap(tester, TransactionsIds.listOrdersTab);
    _expectView(OrdersIds.historyStateEmpty);
    await _tap(tester, ShellIds.homeTab);
    await _tap(tester, DashboardIds.homeWalletIconButton);
    _expectView(WalletIds.accountsStateEmpty);
    handle.dispose();
  });

  testWidgets('un deep link en frío sin sesión pasa por login y vuelve al '
      'instrumento', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'mila_invest.onboarding_seen': true,
    });
    final ProviderContainer container = await _pumpApp(tester);
    _expectView(AuthIds.loginView);

    container
        .read(goRouterProvider)
        .go('milainvest://market/instrument/BAP-PE');
    await tester.pumpAndSettle();
    await _loginDemo(tester);

    _expectView(MarketIds.detailView);
    expect(_label(tester, MarketIds.detailTickerText), 'BAP');
    handle.dispose();
  });

  testWidgets('un instrumento inexistente cae en "no encontrado" y una ruta '
      'desconocida, en la vista del shell', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'mila_invest.onboarding_seen': true,
    });
    final ProviderContainer container = await _pumpApp(tester);
    await _loginDemo(tester);

    container.read(goRouterProvider).go('/market/instrument/NOPE-CO');
    await tester.pumpAndSettle();
    _expectView(MarketIds.detailStateEmpty);

    container.read(goRouterProvider).go('/esto/no/existe');
    await tester.pumpAndSettle();
    _expectView(ShellIds.notFoundView);
    await _tap(tester, ShellIds.notFoundHomeButton);
    _expectView(DashboardIds.homeView);
    handle.dispose();
  });

  testWidgets('cambiar idioma y tema no reinicia ni cambia el formato de los '
      'montos', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'mila_invest.onboarding_seen': true,
    });
    await _pumpApp(tester);
    await _loginDemo(tester);
    final String total = tester
        .widget<Text>(
          find.descendant(
            of: find.bySemanticsIdentifier(DashboardIds.homeTotalText),
            matching: find.byType(Text),
          ),
        )
        .data!;

    await _tap(tester, DashboardIds.homeSettingsIconButton);
    await _tap(tester, AppCrossIds.settingsLanguageEnSegment);
    await _tap(tester, AppCrossIds.settingsThemeDarkSegment);
    expect(find.text('Settings'), findsOneWidget);
    await _tap(tester, AppCrossIds.settingsBackIconButton);

    expect(find.text('Total value'), findsOneWidget);
    final String after = tester
        .widget<Text>(
          find.descendant(
            of: find.bySemanticsIdentifier(DashboardIds.homeTotalText),
            matching: find.byType(Text),
          ),
        )
        .data!;
    expect(after, total);
    expect(after, endsWith(' COP'));
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.dark,
    );
    handle.dispose();
  });

  testWidgets('cerrar sesión vuelve al login y el próximo login va al inicio', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'mila_invest.onboarding_seen': true,
    });
    await _pumpApp(tester);
    await _loginDemo(tester);

    await _tap(tester, DashboardIds.homeSettingsIconButton);
    await _tap(tester, AppCrossIds.settingsLogoutButton);
    await _tap(tester, AppCrossIds.settingsLogoutConfirmButton);
    _expectView(AuthIds.loginView);

    await _loginDemo(tester);
    _expectView(DashboardIds.homeView);
    handle.dispose();
  });

  testWidgets('en web ancho usa rail lateral con los mismos ids', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'mila_invest.onboarding_seen': true,
    });
    await _pumpApp(tester, size: const Size(1440, 900));
    await _loginDemo(tester);

    expect(find.byType(NavigationBar), findsNothing);
    await _tap(tester, ShellIds.portfolioTab);
    _expectView(PortfolioIds.overviewView);
    expect(tester.takeException(), isNull);
    handle.dispose();
  });
}
