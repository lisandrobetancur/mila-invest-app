import 'package:authentication_typing/authentication_typing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

import '../data/authentication_remote_data_source.dart';
import '../state/session/session.dart';
import 'service.dart';

/// Liga el contrato del servicio con su implementación.
final Override authenticationServiceProviderOverride =
    authenticationServiceProvider.overrideWith(
      (Ref ref) => AuthenticationService(
        dataSource: AuthenticationRemoteDataSource(ref.read(apiClientProvider)),
        tokenStore: ref.read(tokenStoreProvider),
      ),
    );

/// Estado de la sesión como provider derivado de solo lectura.
final Override sessionProviderOverride = sessionProvider.overrideWith(
  (Ref ref) => ref.watch(sessionViewModelProvider),
);

/// Acciones sobre la sesión para otras features.
final Override sessionManagerProviderOverride = sessionManagerProvider
    .overrideWith(
      (Ref ref) => SessionManager(ref.read(sessionViewModelProvider.notifier)),
    );

/// Overrides que authentication aporta al shell.
final List<Override> authenticationOverrides = <Override>[
  authenticationServiceProviderOverride,
  sessionProviderOverride,
  sessionManagerProviderOverride,
];
