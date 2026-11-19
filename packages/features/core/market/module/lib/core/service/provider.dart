import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_constants/market_constants.dart';
import 'package:market_typing/market_typing.dart';
import 'package:network/network.dart';

import '../data/market_remote_data_source.dart';
import 'service.dart';

/// Liga el contrato del servicio con su implementación.
final Override marketServiceProviderOverride = marketServiceProvider
    .overrideWith(
      (Ref ref) => MarketService(
        dataSource: MarketRemoteDataSource(ref.read(apiClientProvider)),
      ),
    );

/// Implementa el estado de mercado por país con el servicio.
final Override countryMarketsProviderOverride = countryMarketsProvider
    .overrideWith(
      (Ref ref) => ref.read(marketServiceProvider).countryMarkets(),
    );

/// Espera del buscador. Los tests la ponen en cero.
final Provider<Duration> marketSearchDebounceProvider = Provider<Duration>(
  (Ref ref) => MarketLimits.searchDebounce,
);

/// Overrides que market aporta al shell.
final List<Override> marketOverrides = <Override>[
  marketServiceProviderOverride,
  countryMarketsProviderOverride,
];
