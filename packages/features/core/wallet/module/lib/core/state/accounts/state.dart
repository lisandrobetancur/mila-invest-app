part of 'accounts.dart';

/// Estado de la billetera. `empty` es "ninguna cuenta tiene saldo".
class AccountsState extends Equatable {
  /// Crea el estado.
  const AccountsState({
    this.status = ViewStatus.loading,
    this.accounts = const <Account>[],
    this.errorKey,
    this.isNetworkError = false,
  });

  static const Object _unset = Object();

  /// Estado de la vista.
  final ViewStatus status;

  /// Cuentas, en el orden de la API.
  final List<Account> accounts;

  /// Clave del error.
  final String? errorKey;

  /// `true` si el error fue de red.
  final bool isNetworkError;

  /// Copia el estado. `errorKey: null` borra el error.
  AccountsState copyWith({
    ViewStatus? status,
    List<Account>? accounts,
    Object? errorKey = _unset,
    bool? isNetworkError,
  }) => AccountsState(
    status: status ?? this.status,
    accounts: accounts ?? this.accounts,
    errorKey: identical(errorKey, _unset) ? this.errorKey : errorKey as String?,
    isNetworkError: isNetworkError ?? this.isNetworkError,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    accounts,
    errorKey,
    isNetworkError,
  ];
}
