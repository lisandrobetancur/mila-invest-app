part of 'home.dart';

/// Estado del inicio. `empty` es un usuario nuevo, sin saldo ni inversiones.
class DashboardHomeState extends Equatable {
  /// Crea el estado.
  const DashboardHomeState({
    this.status = ViewStatus.loading,
    this.summary,
    this.errorKey,
    this.isNetworkError = false,
  });

  static const Object _unset = Object();

  /// Estado de la vista.
  final ViewStatus status;

  /// Resumen.
  final DashboardSummary? summary;

  /// Clave del error.
  final String? errorKey;

  /// `true` si el error fue de red.
  final bool isNetworkError;

  /// Copia el estado. Los campos nullable aceptan `null` explícito.
  DashboardHomeState copyWith({
    ViewStatus? status,
    Object? summary = _unset,
    Object? errorKey = _unset,
    bool? isNetworkError,
  }) => DashboardHomeState(
    status: status ?? this.status,
    summary: identical(summary, _unset)
        ? this.summary
        : summary as DashboardSummary?,
    errorKey: identical(errorKey, _unset) ? this.errorKey : errorKey as String?,
    isNetworkError: isNetworkError ?? this.isNetworkError,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    summary,
    errorKey,
    isNetworkError,
  ];
}
