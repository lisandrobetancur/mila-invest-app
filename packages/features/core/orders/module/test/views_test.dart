import 'dart:async';

import 'package:authentication_typing/authentication_typing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_typing/market_typing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:navigator/navigator.dart';
import 'package:orders/orders.dart';
import 'package:orders/ui/views/order_detail/order_detail.dart';
import 'package:orders/ui/views/order_ticket/order_ticket.dart';
import 'package:orders/ui/views/orders_history/orders_history.dart';
import 'package:orders_constants/orders_constants.dart';
import 'package:orders_typing/orders_typing.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:typing/typing.dart';
import 'package:wallet_typing/wallet_typing.dart';

import 'support/fixtures.dart';
import 'support/harness.dart';

class _MockOrders extends Mock implements IOrdersService {}

class _MockMarket extends Mock implements IMarketService {}

class _MockNavigation extends Mock implements NavigationManager {}

const User _user = User(
  id: 'usr_1',
  email: 'demo@milainvest.app',
  fullName: 'Camila Demo',
  country: Country.co,
  baseCurrency: Currency.cop,
  documentType: DocumentType.cc,
  documentLast4: '5678',
);

final class _Doubles {
  _Doubles() {
    when(() => navigation.push<void>(any())).thenAnswer((_) async {});
    when(navigation.canPop).thenReturn(true);
    when(
      () => market.instrument('ECOPETROL-CO'),
    ).thenAnswer((_) async => detail());
    when(() => orders.preview(any())).thenAnswer((_) async => preview());
  }

  final _MockOrders orders = _MockOrders();
  final _MockMarket market = _MockMarket();
  final _MockNavigation navigation = _MockNavigation();

  List<Override> overrides({
    bool open = true,
    String cash = '100000',
  }) => <Override>[
    ordersServiceProvider.overrideWithValue(orders),
    marketServiceProvider.overrideWithValue(market),
    navigationManagerProvider.overrideWithValue(navigation),
    orderPreviewDebounceProvider.overrideWithValue(Duration.zero),
    sessionProvider.overrideWithValue(const SessionState.authenticated(_user)),
    accountsProvider.overrideWith((Ref ref) async => accounts(cop: cash)),
    portfolioProvider.overrideWith((Ref ref) async => portfolio()),
    countryMarketsProvider.overrideWith(
      (Ref ref) async => <CountryMarket>[market0(open: open)],
    ),
  ];
}

CountryMarket market0({bool open = true}) => market(open: open);

SemanticsData _data(WidgetTester tester, String id) =>
    tester.getSemantics(find.bySemanticsIdentifier(id)).getSemanticsData();

Future<void> _tap(WidgetTester tester, String id) async {
  final Finder finder = find.bySemanticsIdentifier(id);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

const Widget _buyTicket = OrderTicketView(
  instrumentId: 'ECOPETROL-CO',
  side: OrderSide.buy,
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const OrderRequest(instrumentId: 'x', side: OrderSide.buy, quantity: 1),
    );
  });

  group('OrderTicketView', () {
    testWidgets('loading: raíz de la vista y del estado', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.market.instrument(any()),
      ).thenAnswer((_) => Completer<InstrumentDetail>().future);

      await pumpView(
        tester,
        _buyTicket,
        languages: ordersLanguages,
        overrides: doubles.overrides(),
      );

      expect(find.bySemanticsIdentifier(OrdersIds.ticketView), findsOneWidget);
      expect(
        find.bySemanticsIdentifier(OrdersIds.ticketStateLoading),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(OrdersIds.ticketCloseIconButton),
        findsOneWidget,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('data: lado, cantidad, saldo, preview y "Revisar orden"', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpView(
        tester,
        _buyTicket,
        languages: ordersLanguages,
        overrides: _Doubles().overrides(),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(OrdersIds.ticketStateData),
        findsOneWidget,
      );
      expect(
        _data(
          tester,
          OrdersIds.ticketQuantityField,
        ).flagsCollection.isTextField,
        isTrue,
      );
      for (final String id in <String>[
        OrdersIds.ticketSideBuySegment,
        OrdersIds.ticketSideSellSegment,
        OrdersIds.ticketQuantityDecreaseStepper,
        OrdersIds.ticketQuantityIncreaseStepper,
        OrdersIds.ticketReviewButton,
      ]) {
        expect(_data(tester, id).flagsCollection.isButton, isTrue, reason: id);
      }
      expect(
        labelOf(tester, OrdersIds.ticketAvailableText),
        '100.000 pesos colombianos',
      );
      expect(
        labelOf(tester, OrdersIds.summaryTotalText),
        '28.850 pesos colombianos',
      );
      expect(
        labelOf(tester, OrdersIds.summaryCommissionText),
        '5.000 pesos colombianos',
      );
      expect(
        _data(
          tester,
          OrdersIds.ticketReviewButton,
        ).hasAction(SemanticsAction.tap),
        isTrue,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('el stepper cambia la cantidad y vuelve a cotizar', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      await pumpView(
        tester,
        _buyTicket,
        languages: ordersLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      await _tap(tester, OrdersIds.ticketQuantityIncreaseStepper);

      expect(find.text('2'), findsOneWidget);
      final List<OrderRequest> requests = verify(
        () => doubles.orders.preview(captureAny()),
      ).captured.cast<OrderRequest>();
      expect(requests.last.quantity, 2);
      handle.dispose();
    });

    testWidgets('sin saldo muestra el error y ofrece "Depositar"', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.orders.preview(any()),
      ).thenThrow(const OrdersException(OrdersErrorCode.insufficientFunds));
      await pumpView(
        tester,
        _buyTicket,
        languages: ordersLanguages,
        overrides: doubles.overrides(cash: '1'),
      );
      await tester.pumpAndSettle();

      expect(
        labelOf(tester, OrdersIds.ticketPreviewErrorText),
        startsWith('No tienes saldo suficiente'),
      );
      expect(
        _data(
          tester,
          OrdersIds.ticketReviewButton,
        ).hasAction(SemanticsAction.tap),
        isFalse,
      );
      await _tap(tester, OrdersIds.ticketDepositButton);
      verify(
        () => doubles.navigation.push<void>('/wallet/deposit/COP'),
      ).called(1);
      handle.dispose();
    });

    testWidgets('con el mercado cerrado muestra el motivo', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpView(
        tester,
        _buyTicket,
        languages: ordersLanguages,
        overrides: _Doubles().overrides(open: false),
      );
      await tester.pumpAndSettle();

      expect(
        labelOf(tester, OrdersIds.ticketClosedReasonText),
        startsWith('El mercado está cerrado'),
      );
      handle.dispose();
    });

    testWidgets('revisar → confirmar → resultado con precio de ejecución', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.orders.submit(any()),
      ).thenAnswer((_) async => filledOrder());
      await pumpView(
        tester,
        _buyTicket,
        languages: ordersLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      await _tap(tester, OrdersIds.ticketReviewButton);
      expect(find.bySemanticsIdentifier(OrdersIds.confirmView), findsOneWidget);
      expect(
        labelOf(tester, OrdersIds.confirmOrderText),
        'Vas a comprar 1 ECOPETROL a precio de mercado.',
      );
      expect(
        labelOf(tester, OrdersIds.confirmDisclaimerText),
        startsWith('Simulación con fines educativos'),
      );
      expect(
        _data(tester, OrdersIds.confirmSubmitButton).label,
        'Confirmar compra',
      );
      expectNoDuplicateIdentifiers(tester);

      await _tap(tester, OrdersIds.confirmSubmitButton);

      expect(find.bySemanticsIdentifier(OrdersIds.resultView), findsOneWidget);
      expect(labelOf(tester, OrdersIds.resultStatusText), 'Ejecutada');
      expect(
        labelOf(tester, OrdersIds.summaryPriceText),
        '2.386 pesos colombianos',
      );
      expect(
        labelOf(tester, OrdersIds.resultPriceDifferenceText),
        contains(r'+$ 1 COP'),
      );
      expectNoDuplicateIdentifiers(tester);

      await _tap(tester, OrdersIds.resultPortfolioButton);
      verify(() => doubles.navigation.go('/portfolio')).called(1);
      handle.dispose();
    });

    testWidgets(
      'un error de red en la confirmación se muestra y se reintenta',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        final _Doubles doubles = _Doubles();
        when(
          () => doubles.orders.submit(any()),
        ).thenThrow(const OrdersException(OrdersErrorCode.network));
        await pumpView(
          tester,
          _buyTicket,
          languages: ordersLanguages,
          overrides: doubles.overrides(),
        );
        await tester.pumpAndSettle();
        await _tap(tester, OrdersIds.ticketReviewButton);

        await _tap(tester, OrdersIds.confirmSubmitButton);

        expect(
          labelOf(tester, OrdersIds.confirmErrorText),
          startsWith('No pudimos conectar'),
        );
        expect(
          find.bySemanticsIdentifier(OrdersIds.confirmView),
          findsOneWidget,
        );
        handle.dispose();
      },
    );

    testWidgets('un rechazo muestra el motivo y la acción sugerida', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.orders.submit(any()),
      ).thenThrow(const OrdersException(OrdersErrorCode.insufficientFunds));
      await pumpView(
        tester,
        _buyTicket,
        languages: ordersLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();
      await _tap(tester, OrdersIds.ticketReviewButton);

      await _tap(tester, OrdersIds.confirmSubmitButton);

      expect(labelOf(tester, OrdersIds.resultStatusText), 'Rechazada');
      expect(
        labelOf(tester, OrdersIds.resultRejectReasonText),
        startsWith('No tienes saldo suficiente'),
      );
      expect(
        find.bySemanticsIdentifier(OrdersIds.resultSuggestedActionButton),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(OrdersIds.resultPortfolioButton),
        findsNothing,
      );
      handle.dispose();
    });

    testWidgets('empty: instrumento no encontrado', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.market.instrument('NOPE-CO'),
      ).thenThrow(const MarketException(MarketErrorCode.instrumentNotFound));

      await pumpView(
        tester,
        const OrderTicketView(instrumentId: 'NOPE-CO', side: OrderSide.buy),
        languages: ordersLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(OrdersIds.ticketStateEmpty),
        findsOneWidget,
      );
      expect(
        labelOf(tester, OrdersIds.ticketNotFoundTitleText),
        'No encontramos este instrumento',
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('error: mensaje y "Reintentar"', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.market.instrument('ECOPETROL-CO'),
      ).thenThrow(const MarketException(MarketErrorCode.network));

      await pumpView(
        tester,
        _buyTicket,
        languages: ordersLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(OrdersIds.ticketStateError),
        findsOneWidget,
      );
      expect(
        labelOf(tester, OrdersIds.ticketErrorText),
        startsWith('No pudimos conectar'),
      );
      expect(
        _data(tester, OrdersIds.ticketRetryButton).flagsCollection.isButton,
        isTrue,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('no desborda en 360 px con el texto al 200 %', (
      WidgetTester tester,
    ) async {
      await pumpView(
        tester,
        const MediaQueryTextScale(scale: 2, child: _buyTicket),
        languages: ordersLanguages,
        overrides: _Doubles().overrides(),
        size: const Size(360, 800),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('OrdersHistoryView', () {
    const AppRouteParams params = AppRouteParams(location: '/activity/orders');

    void stub(_Doubles doubles, Future<Paginated<Order>> Function() answer) =>
        when(
          () => doubles.orders.orders(
            status: any(named: 'status'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) => answer());

    testWidgets('loading', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      stub(doubles, () => Completer<Paginated<Order>>().future);

      await pumpView(
        tester,
        const OrdersHistoryView(params: params),
        languages: ordersLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pump();

      expect(find.bySemanticsIdentifier(OrdersIds.historyView), findsOneWidget);
      expect(
        find.bySemanticsIdentifier(OrdersIds.historyStateLoading),
        findsOneWidget,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('data: secciones, filtros e ítems con estado y total', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      stub(
        doubles,
        () async =>
            Paginated<Order>(items: <Order>[filledOrder(), rejectedOrder()]),
      );

      await pumpView(
        tester,
        const OrdersHistoryView(params: params),
        languages: ordersLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsIdentifier(OrdersIds.historyStateData),
        findsOneWidget,
      );
      for (final String id in <String>[
        OrdersIds.historyMovementsTab,
        OrdersIds.historyOrdersTab,
        OrdersIds.historyStatusAllChip,
        OrdersIds.historyStatusPendingChip,
        OrdersIds.historyStatusFilledChip,
        OrdersIds.historyStatusRejectedChip,
        OrdersIds.historyStatusCancelledChip,
        OrdersIds.historyItem('ord_1'),
      ]) {
        expect(_data(tester, id).flagsCollection.isButton, isTrue, reason: id);
      }
      expect(
        labelOf(tester, OrdersIds.historyItemStatusText('ord_1')),
        'Ejecutada',
      );
      expect(
        labelOf(tester, OrdersIds.historyItemTotalText('ord_1')),
        '28.860 pesos colombianos',
      );
      expect(
        labelOf(tester, OrdersIds.historyItemStatusText('ord_2')),
        'Rechazada',
      );
      expect(
        find.bySemanticsIdentifier(OrdersIds.historyItemTotalText('ord_2')),
        findsNothing,
      );
      expectNoDuplicateIdentifiers(tester);

      await _tap(tester, OrdersIds.historyItem('ord_1'));
      verify(
        () => doubles.navigation.push<void>('/activity/orders/ord_1'),
      ).called(1);
      await _tap(tester, OrdersIds.historyMovementsTab);
      verify(() => doubles.navigation.go('/activity')).called(1);
      handle.dispose();
    });

    testWidgets('empty y error', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      stub(doubles, () async => const Paginated<Order>.empty());

      await pumpView(
        tester,
        const OrdersHistoryView(params: params),
        languages: ordersLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      expect(
        labelOf(tester, OrdersIds.historyEmptyTitleText),
        'Aún no tienes órdenes',
      );
      expect(
        find.bySemanticsIdentifier(OrdersIds.historyExploreButton),
        findsOneWidget,
      );

      stub(
        doubles,
        () async => throw const OrdersException(OrdersErrorCode.network),
      );
      await tester.tap(
        find.bySemanticsIdentifier(OrdersIds.historyStatusAllChip),
      );
      await _tap(tester, OrdersIds.historyStatusFilledChip);

      expect(
        find.bySemanticsIdentifier(OrdersIds.historyStateError),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(OrdersIds.historyRetryButton),
        findsOneWidget,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });
  });

  group('OrderDetailView', () {
    testWidgets('loading, data, empty y error', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.orders.order('ord_load'),
      ).thenAnswer((_) => Completer<Order>().future);
      when(
        () => doubles.orders.order('ord_1'),
      ).thenAnswer((_) async => filledOrder());
      when(
        () => doubles.orders.order('ord_2'),
      ).thenAnswer((_) async => rejectedOrder());
      when(
        () => doubles.orders.order('ord_x'),
      ).thenThrow(const OrdersException(OrdersErrorCode.orderNotFound));
      when(
        () => doubles.orders.order('ord_err'),
      ).thenThrow(const OrdersException(OrdersErrorCode.network));

      Future<void> show(String id) async {
        await pumpView(
          tester,
          OrderDetailView(key: ValueKey<String>(id), orderId: id),
          languages: ordersLanguages,
          overrides: doubles.overrides(),
        );
        await tester.pump();
        await tester.pump();
      }

      await show('ord_load');
      expect(
        find.bySemanticsIdentifier(OrdersIds.detailStateLoading),
        findsOneWidget,
      );
      expect(find.bySemanticsIdentifier(OrdersIds.detailView), findsOneWidget);

      await show('ord_1');
      expect(labelOf(tester, OrdersIds.detailStatusText), 'Ejecutada');
      expect(labelOf(tester, OrdersIds.detailSideText), 'Comprar');
      expect(labelOf(tester, OrdersIds.detailQuantityText), '10');
      expect(
        labelOf(tester, OrdersIds.detailCreatedText),
        '18 nov 2026, 9:42 a. m.',
      );
      expect(
        labelOf(tester, OrdersIds.summaryTotalText),
        '28.860 pesos colombianos',
      );
      expectNoDuplicateIdentifiers(tester);

      await show('ord_2');
      expect(
        labelOf(tester, OrdersIds.detailRejectReasonText),
        startsWith('No tienes suficientes unidades'),
      );

      await show('ord_x');
      expect(
        labelOf(tester, OrdersIds.detailNotFoundTitleText),
        'No encontramos esta orden',
      );

      await show('ord_err');
      expect(
        find.bySemanticsIdentifier(OrdersIds.detailStateError),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(OrdersIds.detailRetryButton),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
