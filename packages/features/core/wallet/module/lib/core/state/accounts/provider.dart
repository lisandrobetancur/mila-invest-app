part of 'accounts.dart';

/// Provider del controller de la billetera.
final AutoDisposeNotifierProvider<AccountsViewModel, AccountsState>
accountsViewModelProvider =
    NotifierProvider.autoDispose<AccountsViewModel, AccountsState>(
      AccountsViewModel.new,
    );
