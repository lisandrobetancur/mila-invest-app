part of 'movements.dart';

/// Los movimientos de un día, en la zona horaria del usuario.
class TransactionDay extends Equatable {
  /// Crea el grupo.
  const TransactionDay({required this.date, required this.transactions});

  /// Día local, a medianoche (UTC como contenedor de la fecha local).
  final DateTime date;

  /// Movimientos del día, del más nuevo al más viejo.
  final List<Transaction> transactions;

  /// Fecha en ISO (`2026-11-18`), para el identificador del encabezado.
  String get isoDate =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => <Object?>[date, transactions];
}

/// Estado de los movimientos.
class MovementsState extends Equatable {
  /// Crea el estado.
  const MovementsState({
    this.status = ViewStatus.loading,
    this.filter = const TransactionFilter(),
    this.transactions = const Paginated<Transaction>.empty(),
    this.loadingMore = false,
    this.loadMoreErrorKey,
    this.errorKey,
    this.isNetworkError = false,
  });

  static const Object _unset = Object();

  /// Estado de la vista.
  final ViewStatus status;

  /// Filtros activos.
  final TransactionFilter filter;

  /// Movimientos cargados.
  final Paginated<Transaction> transactions;

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
      transactions.hasMore &&
      !loadingMore &&
      loadMoreErrorKey == null;

  /// Movimientos agrupados por día en la zona de [country].
  List<TransactionDay> groupedBy(Country country) {
    final List<TransactionDay> days = <TransactionDay>[];
    for (final Transaction transaction in transactions.items) {
      final DateTime local = transaction.createdAt.toUtc().add(
        country.utcOffset,
      );
      final DateTime date = DateTime.utc(local.year, local.month, local.day);
      if (days.isNotEmpty && days.last.date == date) {
        days[days.length - 1] = TransactionDay(
          date: date,
          transactions: <Transaction>[...days.last.transactions, transaction],
        );
      } else {
        days.add(
          TransactionDay(date: date, transactions: <Transaction>[transaction]),
        );
      }
    }
    return days;
  }

  /// Copia el estado. Los campos nullable aceptan `null` explícito.
  MovementsState copyWith({
    ViewStatus? status,
    TransactionFilter? filter,
    Paginated<Transaction>? transactions,
    bool? loadingMore,
    Object? loadMoreErrorKey = _unset,
    Object? errorKey = _unset,
    bool? isNetworkError,
  }) => MovementsState(
    status: status ?? this.status,
    filter: filter ?? this.filter,
    transactions: transactions ?? this.transactions,
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
    transactions,
    loadingMore,
    loadMoreErrorKey,
    errorKey,
    isNetworkError,
  ];
}
