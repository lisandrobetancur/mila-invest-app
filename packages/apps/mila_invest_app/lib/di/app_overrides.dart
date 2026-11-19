import 'dart:math' as math;

import 'package:app_cross/app_cross.dart';
import 'package:app_cross_typing/app_cross_typing.dart';
import 'package:authentication/authentication.dart';
import 'package:authentication_typing/authentication_typing.dart';
import 'package:dashboard/dashboard.dart';
import 'package:design_system/design_system.dart';
import 'package:fake_backend/fake_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market/market.dart';
import 'package:market_typing/market_typing.dart';
import 'package:network/network.dart';
import 'package:orders/orders.dart';
import 'package:portfolio/portfolio.dart';
import 'package:transactions/transactions.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';
import 'package:wallet/wallet.dart';

import '../config/app_config.dart';
import '../router/app_router.dart';

/// Todos los overrides de la app.
///
/// Es el **único** lugar del repo donde la infraestructura y las features se
/// conocen, y el único que decide entre `DioApiClient` y `FakeApiClient`.
List<Override> buildAppOverrides(AppConfig config) => <Override>[
  idGeneratorProvider.overrideWithValue(const UuidIdGenerator()),
  tokenStoreProvider.overrideWith(
    (Ref ref) => config.isFake ? InMemoryTokenStore() : SecureTokenStore(),
  ),
  apiClientProvider.overrideWith(
    (Ref ref) => config.isFake
        ? FakeApiClient(
            tokenStore: ref.read(tokenStoreProvider),
            sessionEvents: ref.read(sessionEventsProvider),
            clock: ref.read(clockProvider),
            seed: config.fakeSeed,
            latency: config.fastAnimations
                ? Duration.zero
                : const Duration(milliseconds: 300),
            liveTicks: config.priceRefreshSeconds > 0,
          )
        : DioApiClient(
            baseUrl: config.apiBaseUrl,
            tokenStore: ref.read(tokenStoreProvider),
            sessionEvents: ref.read(sessionEventsProvider),
            logger: ref.read(loggerProvider),
            clock: ref.read(clockProvider),
          ),
  ),
  durationsProvider.overrideWithValue(
    config.fastAnimations ? const AppDurations.instant() : const AppDurations(),
  ),
  priceRefreshIntervalProvider.overrideWithValue(
    Duration(seconds: math.max(0, config.priceRefreshSeconds)),
  ),
  demoCredentialsProvider.overrideWithValue(
    config.isFake
        ? const DemoCredentials(
            email: FakeDemoAccount.email,
            password: FakeDemoAccount.password,
          )
        : null,
  ),
  appInfoProvider.overrideWithValue(
    AppInfo(
      version: config.version,
      apiMode: config.apiMode.name,
      showApiMode: !PlatformGuard.isRelease,
    ),
  ),
  goRouterProviderOverride,
  ...appCrossOverrides,
  ...authenticationOverrides,
  ...marketOverrides,
  ...ordersOverrides,
  ...walletOverrides,
  ...portfolioOverrides,
  ...transactionsOverrides,
  ...dashboardOverrides,
];
