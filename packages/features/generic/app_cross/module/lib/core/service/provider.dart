import 'package:app_cross_typing/app_cross_typing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/preferences_local_data_source.dart';
import '../state/preferences/preferences.dart';
import 'service.dart';

/// Liga el contrato del servicio de preferencias con su implementación.
final Override preferencesServiceProviderOverride = preferencesServiceProvider
    .overrideWith(
      (Ref ref) => PreferencesService(dataSource: PreferencesLocalDataSource()),
    );

/// Expone las preferencias vigentes como provider derivado de solo lectura.
final Override appPreferencesProviderOverride = appPreferencesProvider
    .overrideWith(
      (Ref ref) => ref.watch(
        preferencesViewModelProvider.select(
          (PreferencesState state) => state.preferences,
        ),
      ),
    );

/// Overrides que app_cross aporta al shell.
final List<Override> appCrossOverrides = <Override>[
  preferencesServiceProviderOverride,
  appPreferencesProviderOverride,
];
