import 'package:app_cross_typing/app_cross_typing.dart';

import '../data/dto/preferences_dto.dart';
import '../data/preferences_local_data_source.dart';

/// Implementación de [IPreferencesService].
class PreferencesService implements IPreferencesService {
  /// Crea el service.
  const PreferencesService({required PreferencesLocalDataSource dataSource})
    : _dataSource = dataSource;

  final PreferencesLocalDataSource _dataSource;

  @override
  Future<AppPreferences> load() => _guard(() async {
    final PreferencesDto dto = await _dataSource.read();
    return dto.toDomain();
  });

  @override
  Future<void> markOnboardingSeen() =>
      _guard(() => _dataSource.writeOnboardingSeen(seen: true));

  @override
  Future<void> saveLanguage(AppLanguage language) =>
      _guard(() => _dataSource.writeLanguage(language.code));

  @override
  Future<void> saveTheme(AppThemePreference theme) =>
      _guard(() => _dataSource.writeTheme(theme.name));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppCrossException {
      rethrow;
    } on Exception {
      throw const AppCrossException(AppCrossErrorCode.storage);
    }
  }
}
