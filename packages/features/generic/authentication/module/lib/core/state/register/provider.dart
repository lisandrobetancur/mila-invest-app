part of 'register.dart';

/// Provider del controller del registro.
final AutoDisposeNotifierProvider<RegisterViewModel, RegisterState>
registerViewModelProvider =
    NotifierProvider.autoDispose<RegisterViewModel, RegisterState>(
      RegisterViewModel.new,
    );
