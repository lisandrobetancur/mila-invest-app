part of 'movements.dart';

/// Provider del controller de movimientos.
final AutoDisposeNotifierProvider<MovementsViewModel, MovementsState>
movementsViewModelProvider =
    NotifierProvider.autoDispose<MovementsViewModel, MovementsState>(
      MovementsViewModel.new,
    );
