part of 'preferences.dart';

/// Provider del controller de preferencias.
final NotifierProvider<PreferencesViewModel, PreferencesState>
preferencesViewModelProvider =
    NotifierProvider<PreferencesViewModel, PreferencesState>(
      PreferencesViewModel.new,
    );
