part of 'settings.dart';

/// Provider del controller de ajustes.
final AutoDisposeNotifierProvider<SettingsViewModel, SettingsState>
settingsViewModelProvider =
    NotifierProvider.autoDispose<SettingsViewModel, SettingsState>(
      SettingsViewModel.new,
    );
