part of 'bootstrap.dart';

/// Provider del controller del arranque.
final NotifierProvider<BootstrapViewModel, BootstrapState>
bootstrapViewModelProvider =
    NotifierProvider<BootstrapViewModel, BootstrapState>(
      BootstrapViewModel.new,
    );
