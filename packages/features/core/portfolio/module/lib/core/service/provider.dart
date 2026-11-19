import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:portfolio_typing/portfolio_typing.dart';

import '../data/portfolio_remote_data_source.dart';
import 'service.dart';

/// Liga el contrato del servicio con su implementación.
final Override portfolioServiceProviderOverride = portfolioServiceProvider
    .overrideWith(
      (Ref ref) => PortfolioService(
        dataSource: PortfolioRemoteDataSource(ref.read(apiClientProvider)),
      ),
    );

/// Implementa el portafolio con el servicio.
final Override portfolioProviderOverride = portfolioProvider.overrideWith(
  (Ref ref) => ref.read(portfolioServiceProvider).portfolio(),
);

/// Overrides que portfolio aporta al shell.
final List<Override> portfolioOverrides = <Override>[
  portfolioServiceProviderOverride,
  portfolioProviderOverride,
];
