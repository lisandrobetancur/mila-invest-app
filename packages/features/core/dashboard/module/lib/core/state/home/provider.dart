part of 'home.dart';

/// Provider del controller del inicio.
final AutoDisposeNotifierProvider<DashboardHomeViewModel, DashboardHomeState>
dashboardHomeViewModelProvider =
    NotifierProvider.autoDispose<DashboardHomeViewModel, DashboardHomeState>(
      DashboardHomeViewModel.new,
    );
