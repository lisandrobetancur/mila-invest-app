import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import 'package:orders_constants/orders_constants.dart';
import 'package:orders_typing/orders_typing.dart';
import 'package:typing/typing.dart';

import '../data/orders_remote_data_source.dart';
import 'service.dart';

/// Liga el contrato del servicio con su implementación.
final Override ordersServiceProviderOverride = ordersServiceProvider
    .overrideWith(
      (Ref ref) => OrdersService(
        dataSource: OrdersRemoteDataSource(ref.read(apiClientProvider)),
        idGenerator: ref.read(idGeneratorProvider),
      ),
    );

/// Espera del preview automático. Los tests la ponen en cero.
final Provider<Duration> orderPreviewDebounceProvider = Provider<Duration>(
  (Ref ref) => OrdersLimits.previewDebounce,
);

/// Overrides que orders aporta al shell.
final List<Override> ordersOverrides = <Override>[
  ordersServiceProviderOverride,
];
