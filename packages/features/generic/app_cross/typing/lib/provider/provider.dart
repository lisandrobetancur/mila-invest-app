import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_info.dart';
import '../models/app_preferences.dart';
import '../services/i_preferences_service.dart';

/// Servicio de preferencias. Lo implementa el módulo por override.
final Provider<IPreferencesService> preferencesServiceProvider =
    Provider<IPreferencesService>(
      (Ref ref) => throw UnimplementedError('preferencesServiceProvider'),
    );

/// Preferencias vigentes, de solo lectura.
///
/// Lo observa el `MaterialApp.router` para el tema y el idioma, y el
/// `redirect` para saber si mostrar el onboarding. Lo implementa el módulo.
final Provider<AppPreferences> appPreferencesProvider =
    Provider<AppPreferences>(
      (Ref ref) => throw UnimplementedError('appPreferencesProvider'),
    );

/// Datos del build. Lo sobrescribe el shell con los flags de entorno.
final Provider<AppInfo> appInfoProvider = Provider<AppInfo>(
  (Ref ref) => throw UnimplementedError('appInfoProvider'),
);
