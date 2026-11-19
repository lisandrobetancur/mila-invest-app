part of 'order_detail.dart';

/// Estado del detalle de una orden. `empty` es "no encontrada".
class OrderDetailState extends Equatable {
  /// Crea el estado.
  const OrderDetailState({
    this.status = ViewStatus.loading,
    this.order,
    this.errorKey,
    this.isNetworkError = false,
  });

  static const Object _unset = Object();

  /// Estado de la vista.
  final ViewStatus status;

  /// Orden.
  final Order? order;

  /// Clave del error.
  final String? errorKey;

  /// `true` si el error fue de red.
  final bool isNetworkError;

  /// Copia el estado. Los campos nullable aceptan `null` explícito.
  OrderDetailState copyWith({
    ViewStatus? status,
    Object? order = _unset,
    Object? errorKey = _unset,
    bool? isNetworkError,
  }) => OrderDetailState(
    status: status ?? this.status,
    order: identical(order, _unset) ? this.order : order as Order?,
    errorKey: identical(errorKey, _unset) ? this.errorKey : errorKey as String?,
    isNetworkError: isNetworkError ?? this.isNetworkError,
  );

  @override
  List<Object?> get props => <Object?>[status, order, errorKey, isNetworkError];
}
