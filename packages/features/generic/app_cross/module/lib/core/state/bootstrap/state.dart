part of 'bootstrap.dart';

/// Estado del arranque de la app.
class BootstrapState extends Equatable {
  /// Crea el estado.
  const BootstrapState({
    this.status = ViewStatus.loading,
    this.errorKey,
    this.isNetworkError = false,
  });

  static const Object _unset = Object();

  /// `loading` mientras arranca, `data` al terminar y `error` si falló.
  final ViewStatus status;

  /// Clave de traducción del error, si hubo.
  final String? errorKey;

  /// `true` si el error fue de red.
  final bool isNetworkError;

  /// Copia el estado. `errorKey: null` borra el error.
  BootstrapState copyWith({
    ViewStatus? status,
    Object? errorKey = _unset,
    bool? isNetworkError,
  }) => BootstrapState(
    status: status ?? this.status,
    errorKey: identical(errorKey, _unset) ? this.errorKey : errorKey as String?,
    isNetworkError: isNetworkError ?? this.isNetworkError,
  );

  @override
  List<Object?> get props => <Object?>[status, errorKey, isNetworkError];
}
