part of 'overview.dart';

/// Estado del portafolio. `empty` es "aún no tienes inversiones".
class PortfolioOverviewState extends Equatable {
  /// Crea el estado.
  const PortfolioOverviewState({
    this.status = ViewStatus.loading,
    this.portfolio,
    this.errorKey,
    this.isNetworkError = false,
  });

  static const Object _unset = Object();

  /// Estado de la vista.
  final ViewStatus status;

  /// Portafolio.
  final Portfolio? portfolio;

  /// Clave del error.
  final String? errorKey;

  /// `true` si el error fue de red.
  final bool isNetworkError;

  /// Copia el estado. Los campos nullable aceptan `null` explícito.
  PortfolioOverviewState copyWith({
    ViewStatus? status,
    Object? portfolio = _unset,
    Object? errorKey = _unset,
    bool? isNetworkError,
  }) => PortfolioOverviewState(
    status: status ?? this.status,
    portfolio: identical(portfolio, _unset)
        ? this.portfolio
        : portfolio as Portfolio?,
    errorKey: identical(errorKey, _unset) ? this.errorKey : errorKey as String?,
    isNetworkError: isNetworkError ?? this.isNetworkError,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    portfolio,
    errorKey,
    isNetworkError,
  ];
}
