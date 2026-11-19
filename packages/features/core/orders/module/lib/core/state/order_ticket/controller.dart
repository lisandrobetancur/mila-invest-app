part of 'order_ticket.dart';

/// Controller del ticket de orden: editar → revisar → resultado.
///
/// Cada cambio de lado o cantidad pide un preview nuevo con debounce de
/// 400 ms; una cotización vieja que llega tarde se descarta. Al ejecutarse
/// una orden invalida `accountsProvider` y `portfolioProvider`.
class OrderTicketViewModel
    extends AutoDisposeFamilyViewModel<OrderTicketState, OrderTicketArgs> {
  late IOrdersService _orders;
  late IMarketService _market;
  late OrdersNavigator _navigator;
  late AppLogger _logger;
  late Debouncer _debouncer;
  int _previewRequest = 0;

  @override
  OrderTicketState initState() => OrderTicketState(side: arg.side);

  @override
  void postInit() {
    _orders = ref.read(ordersServiceProvider);
    _market = ref.read(marketServiceProvider);
    _navigator = ref.read(ordersNavigatorProvider.notifier);
    _logger = ref.read(loggerProvider);
    _debouncer = Debouncer(ref.read(orderPreviewDebounceProvider));
    ref
      ..onDispose(_debouncer.dispose)
      ..listen<AsyncValue<List<Account>>>(accountsProvider, (
        AsyncValue<List<Account>>? previous,
        AsyncValue<List<Account>> next,
      ) {
        final List<Account>? accounts = next.valueOrNull;
        if (accounts != null && isMounted(mountedKey)) {
          _applyAccounts(accounts);
          if (state.step == TicketStep.edit) {
            _schedulePreview();
          }
        }
      });
    runPostBuild(load);
  }

  /// Vuelve de la confirmación al ticket.
  void backToEdit() => state = state.copyWith(
    step: TicketStep.edit,
    submitStatus: SubmitStatus.idle,
    submitErrorCode: null,
  );

  /// Cierra el ticket.
  void close() => _navigator.closeTicket(arg.instrumentId);

  /// Envía la orden. Un segundo toque en vuelo no hace nada.
  ///
  /// Un error de red deja al usuario en la confirmación para reintentar
  /// (con la misma `Idempotency-Key`); un rechazo de negocio lleva al
  /// resultado con el motivo.
  Future<void> confirm() async {
    final OrderRequest? request = state.request;
    if (state.submitStatus.isSubmitting || request == null) {
      return;
    }
    final Object key = mountedKey;
    state = state.copyWith(
      submitStatus: SubmitStatus.submitting,
      submitErrorCode: null,
    );
    try {
      final Order order = await _orders.submit(request);
      ref
        ..invalidate(accountsProvider)
        ..invalidate(portfolioProvider);
      if (!isMounted(key)) {
        return;
      }
      state = state.copyWith(
        submitStatus: SubmitStatus.success,
        order: order,
        step: TicketStep.result,
      );
    } on OrdersException catch (error, stackTrace) {
      _logger.error('orders.submit', error, stackTrace);
      if (!isMounted(key)) {
        return;
      }
      state = error.code.isNetwork
          ? state.copyWith(
              submitStatus: SubmitStatus.failure,
              submitErrorCode: error.code,
            )
          : state.copyWith(
              submitStatus: SubmitStatus.failure,
              rejectionCode: error.code,
              step: TicketStep.result,
            );
    }
  }

  /// Resta una unidad.
  void decrement() {
    final int value = state.quantity ?? OrdersLimits.minQuantity;
    setQuantityText(
      '${(value - 1).clamp(OrdersLimits.minQuantity, OrdersLimits.maxQuantity)}',
    );
  }

  /// Abre el depósito en la moneda del instrumento.
  void deposit() {
    final Instrument? instrument = state.instrument;
    if (instrument != null) {
      _navigator.openDeposit(instrument.currency);
    }
  }

  /// Va al portafolio después de una orden ejecutada.
  void goToPortfolio() => _navigator.goToPortfolio();

  /// Suma una unidad.
  void increment() {
    final int value = state.quantity ?? 0;
    setQuantityText(
      '${(value + 1).clamp(OrdersLimits.minQuantity, OrdersLimits.maxQuantity)}',
    );
  }

  /// Carga el instrumento, el saldo, la posición y el estado del mercado.
  Future<void> load() async {
    final Object key = mountedKey;
    state = state.copyWith(status: ViewStatus.loading, errorKey: null);
    try {
      final InstrumentDetail detail = await _market.instrument(
        arg.instrumentId,
      );
      if (!isMounted(key)) {
        return;
      }
      state = state.copyWith(instrument: detail.instrument);
      await Future.wait(<Future<void>>[
        _loadAccounts(),
        _loadPosition(),
        _loadMarket(detail.instrument.country),
      ]);
      if (!isMounted(key)) {
        return;
      }
      state = state.copyWith(status: ViewStatus.data);
      _schedulePreview(immediate: true);
    } on MarketException catch (error, stackTrace) {
      _logger.error('orders.ticket.load', error, stackTrace);
      if (!isMounted(key)) {
        return;
      }
      state = state.copyWith(
        status: error.code.isNotFound ? ViewStatus.empty : ViewStatus.error,
        errorKey: error.code.isNetwork
            ? OrdersErrorCode.network.messageKey
            : OrdersErrorCode.unknown.messageKey,
        isNetworkError: error.code.isNetwork,
      );
    }
  }

  /// Pasa a la confirmación, si el preview es válido.
  void review() {
    if (state.canReview) {
      state = state.copyWith(step: TicketStep.confirm);
    }
  }

  /// Cambia la cantidad.
  void setQuantityText(String value) {
    if (value == state.quantityText) {
      return;
    }
    state = state.copyWith(quantityText: value, previewErrorCode: null);
    _schedulePreview();
  }

  /// Cambia el lado.
  void setSide(OrderSide side) {
    if (side == state.side) {
      return;
    }
    state = state.copyWith(side: side, previewErrorCode: null);
    _schedulePreview(immediate: true);
  }

  void _applyAccounts(List<Account> accounts) {
    final Currency? currency = state.instrument?.currency;
    final Account? account = currency == null
        ? null
        : accounts.inCurrency(currency);
    state = state.copyWith(available: account?.available);
  }

  Future<void> _loadAccounts() async {
    final Object key = mountedKey;
    try {
      final List<Account> accounts = await ref.read(accountsProvider.future);
      if (isMounted(key)) {
        _applyAccounts(accounts);
      }
    } on Exception catch (error) {
      _logger.warn('orders.ticket.accounts', error);
    }
  }

  Future<void> _loadMarket(Country country) async {
    final Object key = mountedKey;
    try {
      final List<CountryMarket> markets = await ref.read(
        countryMarketsProvider.future,
      );
      for (final CountryMarket market in markets) {
        if (market.country == country && isMounted(key)) {
          state = state.copyWith(market: market);
        }
      }
    } on Exception catch (error) {
      _logger.warn('orders.ticket.market', error);
    }
  }

  Future<void> _loadPosition() async {
    final Object key = mountedKey;
    try {
      final Portfolio portfolio = await ref.read(portfolioProvider.future);
      if (isMounted(key)) {
        state = state.copyWith(
          heldQuantity: portfolio.quantityOf(arg.instrumentId),
        );
      }
    } on Exception catch (error) {
      _logger.warn('orders.ticket.position', error);
    }
  }

  Future<void> _runPreview(OrderRequest request) async {
    final int ticket = ++_previewRequest;
    final Object key = mountedKey;
    state = state.copyWith(
      previewStatus: PreviewStatus.loading,
      previewErrorCode: null,
    );
    try {
      final OrderPreview preview = await _orders.preview(request);
      if (!isMounted(key) || ticket != _previewRequest) {
        return;
      }
      state = state.copyWith(
        previewStatus: PreviewStatus.ready,
        preview: preview,
        previewFor: request,
      );
    } on OrdersException catch (error, stackTrace) {
      _logger.error('orders.preview', error, stackTrace);
      if (!isMounted(key) || ticket != _previewRequest) {
        return;
      }
      state = state.copyWith(
        previewStatus: PreviewStatus.failed,
        previewErrorCode: error.code,
        preview: null,
        previewFor: null,
      );
    }
  }

  void _schedulePreview({bool immediate = false}) {
    _debouncer.cancel();
    final OrderRequest? request = state.request;
    if (request == null || !state.canTrade) {
      _previewRequest++;
      state = state.copyWith(
        previewStatus: PreviewStatus.idle,
        preview: null,
        previewFor: null,
      );
      return;
    }
    if (immediate) {
      _runPreview(request);
    } else {
      state = state.copyWith(previewStatus: PreviewStatus.loading);
      _debouncer.run(() => _runPreview(request));
    }
  }
}
