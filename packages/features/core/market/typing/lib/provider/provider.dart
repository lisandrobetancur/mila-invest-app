import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_constants/market_constants.dart';

import '../models/country_market.dart';
import '../services/i_market_service.dart';

/// Servicio de market. Lo implementa el módulo por override.
final Provider<IMarketService> marketServiceProvider = Provider<IMarketService>(
  (Ref ref) => throw UnimplementedError('marketServiceProvider'),
);

/// Estado del mercado de cada país, de solo lectura.
///
/// Lo usan la lista, el detalle y el ticket de orden. Lo implementa el
/// módulo por override.
final FutureProvider<List<CountryMarket>> countryMarketsProvider =
    FutureProvider<List<CountryMarket>>(
      (Ref ref) => throw UnimplementedError('countryMarketsProvider'),
    );

/// Intervalo de refresco de precios de las vistas visibles.
///
/// `Duration.zero` lo apaga. El shell lo sobrescribe con
/// `PRICE_REFRESH_SECONDS`; los tests lo dejan en cero.
final Provider<Duration> priceRefreshIntervalProvider = Provider<Duration>(
  (Ref ref) => const Duration(seconds: MarketLimits.defaultPriceRefreshSeconds),
);
