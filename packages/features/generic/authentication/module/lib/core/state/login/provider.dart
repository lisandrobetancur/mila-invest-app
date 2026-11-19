part of 'login.dart';

/// Provider del controller del login.
final AutoDisposeNotifierProvider<LoginViewModel, LoginState>
loginViewModelProvider =
    NotifierProvider.autoDispose<LoginViewModel, LoginState>(
      LoginViewModel.new,
    );
