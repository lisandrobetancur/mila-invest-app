import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_typing/market_typing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:navigator/navigator.dart';
import 'package:orders/orders.dart';
import 'package:orders_typing/orders_typing.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';
import 'package:wallet_typing/wallet_typing.dart';

import 'support/fixtures.dart';

class _MockOrders extends Mock implements IOrdersService {}

class _MockMarket extends Mock implements IMarketService {}

class _MockNavigation extends Mock implements NavigationManager {}

const OrderTicketArgs _buy = OrderTicketArgs(
  instrumentId: 'ECOPETROL-CO',
  side: OrderSide.buy,
);

const OrderTicketArgs _sell = OrderTicketArgs(
  instrumentId: 'ECOPETROL-CO',
  side: OrderSide.sell,
);

final class _Harness {
  _Harness({bool open = true, int held = 120, String cash = '100000'}) {
    when(() => navigation.push<void>(any())).thenAnswer((_) async {});
    when(navigation.canPop).thenReturn(true);
    when(
      () => market.instrument('ECOPETROL-CO'),
    ).thenAnswer((_) async => detail());
    when(() => orders.preview(any())).thenAnswer((_) async => preview());
    accountsFetches = 0;
    container = ProviderContainer(
      overrides: <Override>[
        ordersServiceProvider.overrideWithValue(orders),
        marketServiceProvider.overrideWithValue(market),
        navigationManagerProvider.overrideWithValue(navigation),
        orderPreviewDebounceProvider.overrideWithValue(Duration.zero),
        loggerProvider.overrideWithValue(const SilentAppLogger()),
        accountsProvider.overrideWith((Ref ref) async {
          accountsFetches++;
          return accounts(cop: cash);
        }),
        portfolioProvider.overrideWith(
          (Ref ref) async => portfolio(quantity: held),
        ),
        countryMarketsProvider.overrideWith(
          (Ref ref) async => <CountryMarket>[market0(open: open)],
        ),
      ],
    );
    addTearDown(container.dispose);
  }

  final _MockOrders orders = _MockOrders();
  final _MockMarket market = _MockMarket();
  final _MockNavigation navigation = _MockNavigation();
  int accountsFetches = 0;
  late final ProviderContainer container;

  ProviderSubscription<T> keep<T>(ProviderListenable<T> provider) =>
      container.listen<T>(provider, (T? previous, T next) {});

  OrderTicketViewModel ticket(OrderTicketArgs args) =>
      container.read(orderTicketViewModelProvider(args).notifier);
}

CountryMarket market0({bool open = true}) => market(open: open);

Future<void> _settle() async {
  for (int i = 0; i < 12; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const OrderRequest(instrumentId: 'x', side: OrderSide.buy, quantity: 1),
    );
  });

  group('OrderTicketState', () {
    test('valida la cantidad según §7.6', () {
      OrderTicketState state(String text, {OrderSide side = OrderSide.buy}) =>
          OrderTicketState(
            side: side,
            instrument: instrument(),
            quantityText: text,
            heldQuantity: 5,
          );

      expect(state('1').quantityErrorKey, isNull);
      expect(state('0').quantityErrorKey, 'orders.ticket.quantity_min');
      expect(state('1000001').quantityErrorKey, 'orders.ticket.quantity_max');
      expect(state('1.5').quantityErrorKey, 'orders.ticket.quantity_invalid');
      expect(state('').quantityErrorKey, 'orders.ticket.quantity_invalid');
      expect(
        state('6', side: OrderSide.sell).quantityErrorKey,
        'orders.ticket.quantity_position',
      );
      expect(state('5', side: OrderSide.sell).request?.quantity, 5);
      expect(state('0').request, isNull);
    });

    test('canReview exige preview vigente, saldo y mercado abierto', () {
      const OrderRequest request = OrderRequest(
        instrumentId: 'ECOPETROL-CO',
        side: OrderSide.buy,
        quantity: 1,
      );
      final OrderTicketState ready = OrderTicketState(
        side: OrderSide.buy,
        instrument: instrument(),
        previewStatus: PreviewStatus.ready,
        preview: preview(),
        previewFor: request,
      );

      expect(ready.canReview, isTrue);
      expect(ready.copyWith(quantityText: '2').canReview, isFalse);
      expect(ready.copyWith(market: market(open: false)).canReview, isFalse);
      final OrderTicketState short = ready.copyWith(
        preview: preview(after: '-850'),
      );
      expect(short.canReview, isFalse);
      expect(short.needsDeposit, isTrue);
      expect(
        ready
            .copyWith(
              previewStatus: PreviewStatus.failed,
              previewErrorCode: OrdersErrorCode.insufficientFunds,
            )
            .needsDeposit,
        isTrue,
      );
    });

    test('calcula la diferencia de precio y copyWith usa sentinel', () {
      final OrderTicketState state = OrderTicketState(
        side: OrderSide.buy,
        preview: preview(),
        order: filledOrder(price: '2386'),
        rejectionCode: OrdersErrorCode.marketClosed,
      );

      expect(state.priceDifference, cop('1'));
      expect(
        state.copyWith(order: filledOrder(price: '2385')).priceDifference,
        isNull,
      );
      expect(state.copyWith(rejectionCode: null).rejectionCode, isNull);
      expect(state.copyWith(), state);
    });
  });

  group('OrderTicketViewModel', () {
    test('carga instrumento, saldo, posición y mercado, y cotiza', () async {
      final _Harness harness = _Harness();
      final ProviderSubscription<OrderTicketState> state = harness.keep(
        orderTicketViewModelProvider(_buy),
      );

      expect(state.read().status, ViewStatus.loading);
      await _settle();

      expect(state.read().status, ViewStatus.data);
      expect(state.read().instrument, instrument());
      expect(state.read().available, cop('100000'));
      expect(state.read().heldQuantity, 120);
      expect(state.read().market, market());
      expect(state.read().previewStatus, PreviewStatus.ready);
      expect(state.read().canReview, isTrue);
    });

    test('un instrumento inexistente queda en empty', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.market.instrument('NOPE-CO'),
      ).thenThrow(const MarketException(MarketErrorCode.instrumentNotFound));
      const OrderTicketArgs args = OrderTicketArgs(
        instrumentId: 'NOPE-CO',
        side: OrderSide.buy,
      );
      final ProviderSubscription<OrderTicketState> state = harness.keep(
        orderTicketViewModelProvider(args),
      );
      await _settle();

      expect(state.read().status, ViewStatus.empty);
    });

    test(
      'un error de red al cargar queda en error y se puede reintentar',
      () async {
        final _Harness harness = _Harness();
        when(
          () => harness.market.instrument('ECOPETROL-CO'),
        ).thenThrow(const MarketException(MarketErrorCode.network));
        final ProviderSubscription<OrderTicketState> state = harness.keep(
          orderTicketViewModelProvider(_buy),
        );
        await _settle();
        expect(state.read().status, ViewStatus.error);
        expect(state.read().isNetworkError, isTrue);

        when(
          () => harness.market.instrument('ECOPETROL-CO'),
        ).thenAnswer((_) async => detail());
        await harness.ticket(_buy).load();

        expect(state.read().status, ViewStatus.data);
      },
    );

    test('cambiar la cantidad vuelve a cotizar y una cotización vieja se '
        'descarta', () async {
      final _Harness harness = _Harness();
      final ProviderSubscription<OrderTicketState> state = harness.keep(
        orderTicketViewModelProvider(_buy),
      );
      await _settle();
      final Completer<OrderPreview> slow = Completer<OrderPreview>();
      when(() => harness.orders.preview(any())).thenAnswer((
        Invocation invocation,
      ) {
        final OrderRequest request =
            invocation.positionalArguments.first as OrderRequest;
        return request.quantity == 2
            ? slow.future
            : Future<OrderPreview>.value(preview(total: '33333'));
      });

      harness.ticket(_buy)
        ..setQuantityText('2')
        ..setQuantityText('3');
      await _settle();
      slow.complete(preview(total: '11111'));
      await _settle();

      expect(state.read().preview?.total, cop('33333'));
      expect(state.read().previewFor?.quantity, 3);
      expect(state.read().isPreviewCurrent, isTrue);
    });

    test('una cantidad inválida no cotiza y deshabilita "Revisar"', () async {
      final _Harness harness = _Harness();
      final ProviderSubscription<OrderTicketState> state = harness.keep(
        orderTicketViewModelProvider(_buy),
      );
      await _settle();
      clearInteractions(harness.orders);

      harness.ticket(_buy).setQuantityText('0');
      await _settle();

      expect(state.read().previewStatus, PreviewStatus.idle);
      expect(state.read().canReview, isFalse);
      verifyNever(() => harness.orders.preview(any()));
    });

    test('el stepper respeta los límites', () async {
      final _Harness harness = _Harness();
      final ProviderSubscription<OrderTicketState> state = harness.keep(
        orderTicketViewModelProvider(_buy),
      );
      await _settle();
      final OrderTicketViewModel viewModel = harness.ticket(_buy)..decrement();
      expect(state.read().quantityText, '1');

      viewModel
        ..increment()
        ..increment();
      expect(state.read().quantityText, '3');
    });

    test('sin saldo suficiente ofrece depositar en la moneda del '
        'instrumento', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.orders.preview(any()),
      ).thenThrow(const OrdersException(OrdersErrorCode.insufficientFunds));
      final ProviderSubscription<OrderTicketState> state = harness.keep(
        orderTicketViewModelProvider(_buy),
      );
      await _settle();

      expect(state.read().needsDeposit, isTrue);
      expect(state.read().canReview, isFalse);
      harness.ticket(_buy).deposit();
      verify(
        () => harness.navigation.push<void>('/wallet/deposit/COP'),
      ).called(1);
    });

    test('con el mercado cerrado no cotiza ni deja revisar', () async {
      final _Harness harness = _Harness(open: false);
      final ProviderSubscription<OrderTicketState> state = harness.keep(
        orderTicketViewModelProvider(_buy),
      );
      await _settle();

      expect(state.read().canTrade, isFalse);
      expect(state.read().canReview, isFalse);
      verifyNever(() => harness.orders.preview(any()));
    });

    test('vender más de lo que se tiene no es válido', () async {
      final _Harness harness = _Harness(held: 5);
      final ProviderSubscription<OrderTicketState> state = harness.keep(
        orderTicketViewModelProvider(_sell),
      );
      await _settle();

      harness.ticket(_sell).setQuantityText('6');
      await _settle();

      expect(state.read().quantityErrorKey, 'orders.ticket.quantity_position');
      expect(state.read().canReview, isFalse);
    });

    test('confirmar: un doble toque envía una sola orden e invalida saldo y '
        'portafolio', () async {
      final _Harness harness = _Harness();
      final Completer<Order> gate = Completer<Order>();
      when(() => harness.orders.submit(any())).thenAnswer((_) => gate.future);
      final ProviderSubscription<OrderTicketState> state = harness.keep(
        orderTicketViewModelProvider(_buy),
      );
      await _settle();
      final int fetchesBefore = harness.accountsFetches;
      final OrderTicketViewModel viewModel = harness.ticket(_buy)..review();
      expect(state.read().step, TicketStep.confirm);

      final Future<void> first = viewModel.confirm();
      final Future<void> second = viewModel.confirm();
      expect(state.read().submitStatus, SubmitStatus.submitting);
      gate.complete(filledOrder());
      await Future.wait(<Future<void>>[first, second]);
      await _settle();

      verify(() => harness.orders.submit(any())).called(1);
      expect(state.read().step, TicketStep.result);
      expect(state.read().isFilled, isTrue);
      expect(state.read().priceDifference, cop('1'));
      expect(harness.accountsFetches, greaterThan(fetchesBefore));
    });

    test('un error de red deja reintentar desde la confirmación', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.orders.submit(any()),
      ).thenThrow(const OrdersException(OrdersErrorCode.network));
      final ProviderSubscription<OrderTicketState> state = harness.keep(
        orderTicketViewModelProvider(_buy),
      );
      await _settle();
      final OrderTicketViewModel viewModel = harness.ticket(_buy)..review();

      await viewModel.confirm();

      expect(state.read().step, TicketStep.confirm);
      expect(state.read().submitErrorCode, OrdersErrorCode.network);

      when(
        () => harness.orders.submit(any()),
      ).thenAnswer((_) async => filledOrder());
      await viewModel.confirm();

      expect(state.read().step, TicketStep.result);
      final List<OrderRequest> sent = verify(
        () => harness.orders.submit(captureAny()),
      ).captured.cast<OrderRequest>();
      expect(sent.first, sent.last);
    });

    test('un rechazo de negocio lleva al resultado con el motivo', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.orders.submit(any()),
      ).thenThrow(const OrdersException(OrdersErrorCode.marketClosed));
      final ProviderSubscription<OrderTicketState> state = harness.keep(
        orderTicketViewModelProvider(_buy),
      );
      await _settle();
      final OrderTicketViewModel viewModel = harness.ticket(_buy)..review();

      await viewModel.confirm();

      expect(state.read().step, TicketStep.result);
      expect(state.read().resultRejection, OrdersErrorCode.marketClosed);
      expect(state.read().isFilled, isFalse);
    });

    test('un depósito (accountsProvider invalidado) actualiza el saldo y '
        'recotiza', () async {
      String cash = '100';
      final _Harness harness = _Harness();
      harness.container.updateOverrides(<Override>[
        ordersServiceProvider.overrideWithValue(harness.orders),
        marketServiceProvider.overrideWithValue(harness.market),
        navigationManagerProvider.overrideWithValue(harness.navigation),
        orderPreviewDebounceProvider.overrideWithValue(Duration.zero),
        loggerProvider.overrideWithValue(const SilentAppLogger()),
        accountsProvider.overrideWith((Ref ref) async => accounts(cop: cash)),
        portfolioProvider.overrideWith((Ref ref) async => portfolio()),
        countryMarketsProvider.overrideWith(
          (Ref ref) async => <CountryMarket>[market()],
        ),
      ]);
      final ProviderSubscription<OrderTicketState> state = harness.keep(
        orderTicketViewModelProvider(_buy),
      );
      await _settle();
      expect(state.read().available, cop('100'));
      clearInteractions(harness.orders);

      cash = '500000';
      harness.container.invalidate(accountsProvider);
      await _settle();

      expect(state.read().available, cop('500000'));
      verify(() => harness.orders.preview(any())).called(1);
    });

    test('cerrar y "Ver portafolio" navegan', () async {
      final _Harness harness = _Harness()
        ..keep(orderTicketViewModelProvider(_buy));
      await _settle();

      harness.ticket(_buy)
        ..close()
        ..goToPortfolio();

      verify(() => harness.navigation.pop<void>()).called(1);
      verify(() => harness.navigation.go('/portfolio')).called(1);
    });
  });

  group('OrdersHistoryViewModel', () {
    test('carga, filtra por estado y refleja el filtro en la URL', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.orders.orders(
          status: any(named: 'status'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((Invocation invocation) async {
        final OrderStatus? status =
            invocation.namedArguments[#status] as OrderStatus?;
        return Paginated<Order>(
          items: <Order>[
            if (status != OrderStatus.rejected) filledOrder(),
            if (status != OrderStatus.filled) rejectedOrder(),
          ],
        );
      });
      final ProviderSubscription<OrdersHistoryState> state = harness.keep(
        ordersHistoryViewModelProvider,
      );
      final OrdersHistoryViewModel viewModel = harness.container.read(
        ordersHistoryViewModelProvider.notifier,
      )..start();
      await _settle();
      expect(state.read().status, ViewStatus.data);
      expect(state.read().orders.items, hasLength(2));

      viewModel.setFilter(OrderStatus.rejected);
      await _settle();

      expect(state.read().orders.items.single.id, 'ord_2');
      verify(
        () => harness.navigation.go('/activity/orders?status=REJECTED'),
      ).called(1);
    });

    test('sin órdenes queda en empty; un error, en error', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.orders.orders(
          status: any(named: 'status'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Paginated<Order>.empty());
      final ProviderSubscription<OrdersHistoryState> state = harness.keep(
        ordersHistoryViewModelProvider,
      );
      final OrdersHistoryViewModel viewModel = harness.container.read(
        ordersHistoryViewModelProvider.notifier,
      )..start();
      await _settle();
      expect(state.read().status, ViewStatus.empty);

      when(
        () => harness.orders.orders(
          status: any(named: 'status'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const OrdersException(OrdersErrorCode.network));
      await viewModel.refresh();

      expect(state.read().status, ViewStatus.error);
      expect(state.read().isNetworkError, isTrue);
    });

    test('se recarga cuando una escritura invalida accountsProvider', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.orders.orders(
          status: any(named: 'status'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => Paginated<Order>(items: <Order>[filledOrder()]),
      );
      harness
        ..keep(ordersHistoryViewModelProvider)
        ..container.read(ordersHistoryViewModelProvider.notifier).start();
      await _settle();
      clearInteractions(harness.orders);

      harness.container.invalidate(accountsProvider);
      await _settle();

      verify(
        () => harness.orders.orders(
          status: any(named: 'status'),
          limit: any(named: 'limit'),
        ),
      ).called(1);
    });
  });

  group('OrderDetailViewModel', () {
    test('carga la orden; una inexistente queda en empty', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.orders.order('ord_1'),
      ).thenAnswer((_) async => filledOrder());
      when(
        () => harness.orders.order('ord_x'),
      ).thenThrow(const OrdersException(OrdersErrorCode.orderNotFound));
      final ProviderSubscription<OrderDetailState> found = harness.keep(
        orderDetailViewModelProvider('ord_1'),
      );
      final ProviderSubscription<OrderDetailState> missing = harness.keep(
        orderDetailViewModelProvider('ord_x'),
      );
      await _settle();

      expect(found.read().status, ViewStatus.data);
      expect(found.read().order, filledOrder());
      expect(missing.read().status, ViewStatus.empty);

      harness.container
          .read(orderDetailViewModelProvider('ord_1').notifier)
          .openInstrument();
      verify(
        () => harness.navigation.push<void>('/market/instrument/ECOPETROL-CO'),
      ).called(1);
    });
  });
}
