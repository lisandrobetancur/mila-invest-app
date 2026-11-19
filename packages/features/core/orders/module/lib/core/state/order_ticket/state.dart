part of 'order_ticket.dart';

/// Argumento del ticket: qué instrumento y con qué lado se abrió.
class OrderTicketArgs extends Equatable {
  /// Crea el argumento.
  const OrderTicketArgs({required this.instrumentId, required this.side});

  /// Instrumento.
  final String instrumentId;

  /// Lado inicial.
  final OrderSide side;

  @override
  List<Object?> get props => <Object?>[instrumentId, side];
}

/// Paso del ticket.
enum TicketStep {
  /// Editar lado y cantidad, con preview automático.
  edit,

  /// Revisar y confirmar, con el aviso de simulación.
  confirm,

  /// Resultado: ejecutada o rechazada.
  result,
}

/// Estado del preview automático.
enum PreviewStatus {
  /// No hay nada que cotizar (cantidad inválida o mercado cerrado).
  idle,

  /// Cotizando.
  loading,

  /// Cotización lista.
  ready,

  /// La cotización falló.
  failed,
}

/// Estado del ticket de orden.
class OrderTicketState extends Equatable {
  /// Crea el estado.
  const OrderTicketState({
    required this.side,
    this.status = ViewStatus.loading,
    this.step = TicketStep.edit,
    this.instrument,
    this.quantityText = '1',
    this.available,
    this.heldQuantity = 0,
    this.market,
    this.previewStatus = PreviewStatus.idle,
    this.preview,
    this.previewFor,
    this.previewErrorCode,
    this.submitStatus = SubmitStatus.idle,
    this.submitErrorCode,
    this.order,
    this.rejectionCode,
    this.errorKey,
    this.isNetworkError = false,
  });

  static const Object _unset = Object();

  /// Lado elegido.
  final OrderSide side;

  /// Estado de la carga del instrumento.
  final ViewStatus status;

  /// Paso visible.
  final TicketStep step;

  /// Instrumento.
  final Instrument? instrument;

  /// Cantidad tal como la escribió el usuario.
  final String quantityText;

  /// Saldo disponible en la moneda del instrumento.
  final Money? available;

  /// Cantidad en posición.
  final int heldQuantity;

  /// Estado del mercado del país del instrumento.
  final CountryMarket? market;

  /// Estado del preview.
  final PreviewStatus previewStatus;

  /// Última cotización.
  final OrderPreview? preview;

  /// Pedido al que corresponde [preview].
  final OrderRequest? previewFor;

  /// Error de la última cotización.
  final OrdersErrorCode? previewErrorCode;

  /// Estado del envío.
  final SubmitStatus submitStatus;

  /// Error de red del envío: el usuario puede reintentar.
  final OrdersErrorCode? submitErrorCode;

  /// Orden enviada.
  final Order? order;

  /// Rechazo del backend sin orden creada (por ejemplo, 422).
  final OrdersErrorCode? rejectionCode;

  /// Clave del error de carga.
  final String? errorKey;

  /// `true` si el error de carga fue de red.
  final bool isNetworkError;

  /// Cantidad como entero, o `null` si no es un entero.
  int? get quantity => int.tryParse(quantityText.trim());

  /// Clave del error de la cantidad, o `null` si es válida (§7.6).
  String? get quantityErrorKey {
    final int? value = quantity;
    if (value == null) {
      return 'orders.ticket.quantity_invalid';
    }
    if (value < OrdersLimits.minQuantity) {
      return 'orders.ticket.quantity_min';
    }
    if (value > OrdersLimits.maxQuantity) {
      return 'orders.ticket.quantity_max';
    }
    if (!side.isBuy && value > heldQuantity) {
      return 'orders.ticket.quantity_position';
    }
    return null;
  }

  /// Pedido actual, o `null` si el ticket todavía no es válido.
  OrderRequest? get request {
    final Instrument? selected = instrument;
    final int? value = quantity;
    if (selected == null || value == null || quantityErrorKey != null) {
      return null;
    }
    return OrderRequest(instrumentId: selected.id, side: side, quantity: value);
  }

  /// `true` si se puede operar: el mercado no está cerrado.
  bool get canTrade => market?.isOpen ?? true;

  /// `true` si la cotización corresponde al pedido actual.
  bool get isPreviewCurrent =>
      previewStatus == PreviewStatus.ready &&
      preview != null &&
      previewFor == request;

  /// `true` si la compra no alcanza con el saldo disponible.
  bool get needsDeposit =>
      side.isBuy &&
      (previewErrorCode == OrdersErrorCode.insufficientFunds ||
          (isPreviewCurrent && preview!.leavesNegativeBalance));

  /// `true` si "Revisar orden" está habilitado.
  bool get canReview =>
      canTrade && isPreviewCurrent && !preview!.leavesNegativeBalance;

  /// Motivo del rechazo, venga en la orden o como error del backend.
  OrdersErrorCode? get resultRejection => order?.rejectCode ?? rejectionCode;

  /// `true` si el resultado es una orden ejecutada.
  bool get isFilled => order?.isFilled ?? false;

  /// Diferencia entre el precio de ejecución y el estimado, si la hubo.
  Money? get priceDifference {
    final Money? executed = order?.executedPrice;
    final Money? estimated = preview?.estimatedPrice;
    if (executed == null ||
        estimated == null ||
        executed.currency != estimated.currency) {
      return null;
    }
    final Money difference = executed - estimated;
    return difference.isZero ? null : difference;
  }

  /// Copia el estado. Los campos nullable aceptan `null` explícito.
  OrderTicketState copyWith({
    OrderSide? side,
    ViewStatus? status,
    TicketStep? step,
    Object? instrument = _unset,
    String? quantityText,
    Object? available = _unset,
    int? heldQuantity,
    Object? market = _unset,
    PreviewStatus? previewStatus,
    Object? preview = _unset,
    Object? previewFor = _unset,
    Object? previewErrorCode = _unset,
    SubmitStatus? submitStatus,
    Object? submitErrorCode = _unset,
    Object? order = _unset,
    Object? rejectionCode = _unset,
    Object? errorKey = _unset,
    bool? isNetworkError,
  }) => OrderTicketState(
    side: side ?? this.side,
    status: status ?? this.status,
    step: step ?? this.step,
    instrument: identical(instrument, _unset)
        ? this.instrument
        : instrument as Instrument?,
    quantityText: quantityText ?? this.quantityText,
    available: identical(available, _unset)
        ? this.available
        : available as Money?,
    heldQuantity: heldQuantity ?? this.heldQuantity,
    market: identical(market, _unset) ? this.market : market as CountryMarket?,
    previewStatus: previewStatus ?? this.previewStatus,
    preview: identical(preview, _unset)
        ? this.preview
        : preview as OrderPreview?,
    previewFor: identical(previewFor, _unset)
        ? this.previewFor
        : previewFor as OrderRequest?,
    previewErrorCode: identical(previewErrorCode, _unset)
        ? this.previewErrorCode
        : previewErrorCode as OrdersErrorCode?,
    submitStatus: submitStatus ?? this.submitStatus,
    submitErrorCode: identical(submitErrorCode, _unset)
        ? this.submitErrorCode
        : submitErrorCode as OrdersErrorCode?,
    order: identical(order, _unset) ? this.order : order as Order?,
    rejectionCode: identical(rejectionCode, _unset)
        ? this.rejectionCode
        : rejectionCode as OrdersErrorCode?,
    errorKey: identical(errorKey, _unset) ? this.errorKey : errorKey as String?,
    isNetworkError: isNetworkError ?? this.isNetworkError,
  );

  @override
  List<Object?> get props => <Object?>[
    side,
    status,
    step,
    instrument,
    quantityText,
    available,
    heldQuantity,
    market,
    previewStatus,
    preview,
    previewFor,
    previewErrorCode,
    submitStatus,
    submitErrorCode,
    order,
    rejectionCode,
    errorKey,
    isNetworkError,
  ];
}
