part of 'instrument_detail.dart';

/// Estado del detalle de un instrumento.
///
/// `empty` significa que el instrumento no existe: la vista muestra "no
/// encontrado".
class InstrumentDetailState extends Equatable {
  /// Crea el estado.
  const InstrumentDetailState({
    this.status = ViewStatus.loading,
    this.detail,
    this.range = PriceRange.day,
    this.series,
    this.chartLoading = false,
    this.chartErrorKey,
    this.position,
    this.market,
    this.flashSign = 0,
    this.flashTick = 0,
    this.errorKey,
    this.isNetworkError = false,
  });

  static const Object _unset = Object();

  /// Estado de la vista.
  final ViewStatus status;

  /// Detalle del instrumento.
  final InstrumentDetail? detail;

  /// Rango elegido del gráfico.
  final PriceRange range;

  /// Serie del rango elegido.
  final PriceSeries? series;

  /// `true` mientras se carga la serie de un rango nuevo.
  final bool chartLoading;

  /// Error de la serie, si lo hubo.
  final String? chartErrorKey;

  /// Posición del usuario en este instrumento, si tiene.
  final Position? position;

  /// Estado del mercado del país del instrumento.
  final CountryMarket? market;

  /// Signo del último cambio de precio (para el destello).
  final int flashSign;

  /// Cuenta los cambios de precio: la vista destella cuando cambia.
  final int flashTick;

  /// Clave del error de carga, si lo hubo.
  final String? errorKey;

  /// `true` si el error fue de red.
  final bool isNetworkError;

  /// `true` si se puede operar: el mercado no está cerrado.
  ///
  /// Si el estado del mercado no se pudo leer, no se bloquea: el backend
  /// rechaza con `MARKET_CLOSED` si corresponde.
  bool get canTrade => market?.isOpen ?? true;

  /// `true` si hay posición para vender.
  bool get canSell => (position?.quantity ?? 0) > 0;

  /// Copia el estado. Los campos nullable aceptan `null` explícito.
  InstrumentDetailState copyWith({
    ViewStatus? status,
    Object? detail = _unset,
    PriceRange? range,
    Object? series = _unset,
    bool? chartLoading,
    Object? chartErrorKey = _unset,
    Object? position = _unset,
    Object? market = _unset,
    int? flashSign,
    int? flashTick,
    Object? errorKey = _unset,
    bool? isNetworkError,
  }) => InstrumentDetailState(
    status: status ?? this.status,
    detail: identical(detail, _unset)
        ? this.detail
        : detail as InstrumentDetail?,
    range: range ?? this.range,
    series: identical(series, _unset) ? this.series : series as PriceSeries?,
    chartLoading: chartLoading ?? this.chartLoading,
    chartErrorKey: identical(chartErrorKey, _unset)
        ? this.chartErrorKey
        : chartErrorKey as String?,
    position: identical(position, _unset)
        ? this.position
        : position as Position?,
    market: identical(market, _unset) ? this.market : market as CountryMarket?,
    flashSign: flashSign ?? this.flashSign,
    flashTick: flashTick ?? this.flashTick,
    errorKey: identical(errorKey, _unset) ? this.errorKey : errorKey as String?,
    isNetworkError: isNetworkError ?? this.isNetworkError,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    detail,
    range,
    series,
    chartLoading,
    chartErrorKey,
    position,
    market,
    flashSign,
    flashTick,
    errorKey,
    isNetworkError,
  ];
}
