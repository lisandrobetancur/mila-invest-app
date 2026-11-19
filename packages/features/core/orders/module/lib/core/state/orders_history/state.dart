part of 'orders_history.dart';

/// Estado del historial de órdenes.
class OrdersHistoryState extends Equatable {
  /// Crea el estado.
  const OrdersHistoryState({
    this.status = ViewStatus.loading,
    this.filter,
    this.orders = const Paginated<Order>.empty(),
    this.loadingMore = false,
    this.loadMoreErrorKey,
    this.errorKey,
    this.isNetworkError = false,
  });

  static const Object _unset = Object();

  /// Estado de la vista.
  final ViewStatus status;

  /// Filtro por estado; `null` es "Todas".
  final OrderStatus? filter;

  /// Órdenes cargadas.
  final Paginated<Order> orders;

  /// `true` mientras se pide la página siguiente.
  final bool loadingMore;

  /// Error de la página siguiente.
  final String? loadMoreErrorKey;

  /// Clave del error de la carga.
  final String? errorKey;

  /// `true` si el error fue de red.
  final bool isNetworkError;

  /// `true` si conviene pedir la página siguiente.
  bool get canLoadMore =>
      status.isData &&
      orders.hasMore &&
      !loadingMore &&
      loadMoreErrorKey == null;

  /// Copia el estado. Los campos nullable aceptan `null` explícito.
  OrdersHistoryState copyWith({
    ViewStatus? status,
    Object? filter = _unset,
    Paginated<Order>? orders,
    bool? loadingMore,
    Object? loadMoreErrorKey = _unset,
    Object? errorKey = _unset,
    bool? isNetworkError,
  }) => OrdersHistoryState(
    status: status ?? this.status,
    filter: identical(filter, _unset) ? this.filter : filter as OrderStatus?,
    orders: orders ?? this.orders,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreErrorKey: identical(loadMoreErrorKey, _unset)
        ? this.loadMoreErrorKey
        : loadMoreErrorKey as String?,
    errorKey: identical(errorKey, _unset) ? this.errorKey : errorKey as String?,
    isNetworkError: isNetworkError ?? this.isNetworkError,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    filter,
    orders,
    loadingMore,
    loadMoreErrorKey,
    errorKey,
    isNetworkError,
  ];
}
