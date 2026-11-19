part of 'deposit.dart';

/// Provider del controller del depósito, por moneda preseleccionada.
final AutoDisposeNotifierProviderFamily<
  DepositViewModel,
  DepositState,
  Currency
>
depositViewModelProvider = NotifierProvider.autoDispose
    .family<DepositViewModel, DepositState, Currency>(DepositViewModel.new);
