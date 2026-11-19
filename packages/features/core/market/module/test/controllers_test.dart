import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market/market.dart';
import 'package:market_typing/market_typing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:navigator/navigator.dart';
import 'package:orders_typing/orders_typing.dart';
import 'package:portfolio_typing/portfolio_typing.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

import 'support/fixtures.dart';

class _MockService extends Mock implements IMarketService {}

class _MockNavigation extends Mock implements NavigationManager {}

final class _Harness {
  _Harness({
    Duration refresh = Duration.zero,
    Portfolio? holdings,
    List<CountryMarket>? markets,
  }) {
    when(() => navigation.push<void>(any())).thenAnswer((_) async {});
    when(navigation.canPop).thenReturn(true);
    container = ProviderContainer(
      overrides: <Override>[
        marketServiceProvider.overrideWithValue(service),
        navigationManagerProvider.overrideWithValue(navigation),
        marketSearchDebounceProvider.overrideWithValue(Duration.zero),
        priceRefreshIntervalProvider.overrideWithValue(refresh),
        loggerProvider.overrideWithValue(const SilentAppLogger()),
        countryMarketsProvider.overrideWith(
          (Ref ref) async => markets ?? <CountryMarket>[market()],
        ),
        portfolioProvider.overrideWith(
          (Ref ref) async => holdings ?? portfolio(),
        ),
      ],
    );
    addTearDown(container.dispose);
  }

  final _MockService service = _MockService();
  final _MockNavigation navigation = _MockNavigation();
  late final ProviderContainer container;

  ProviderSubscription<T> keep<T>(ProviderListenable<T> provider) =>
      container.listen<T>(provider, (T? previous, T next) {});
}

Future<void> _settle() async {
  for (int i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Paginated<Instrument> _page(List<String> ids, {String? next}) =>
    Paginated<Instrument>(
      items: <Instrument>[
        for (final String id in ids) instrument(id: id, ticker: id),
      ],
      nextCursor: next,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(const InstrumentFilter());
    registerFallbackValue(PriceRange.day);
  });

  group('MarketListViewModel', () {
    test('arranca en loading y pasa a data con la primera página', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.service.instruments(any(), limit: any(named: 'limit')),
      ).thenAnswer((_) async => _page(<String>['A-CO', 'B-CO']));
      final ProviderSubscription<MarketListState> state = harness.keep(
        marketListViewModelProvider,
      );

      harness.container.read(marketListViewModelProvider.notifier).start();
      expect(state.read().status, ViewStatus.loading);
      await _settle();

      expect(state.read().status, ViewStatus.data);
      expect(state.read().instruments.items, hasLength(2));
      expect(state.read().markets, <CountryMarket>[market()]);
    });

    test('sin resultados pasa a empty y limpiar filtros recarga', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.service.instruments(any(), limit: any(named: 'limit')),
      ).thenAnswer((Invocation invocation) async {
        final InstrumentFilter filter =
            invocation.positionalArguments.first as InstrumentFilter;
        return filter.isEmpty ? _page(<String>['A-CO']) : _page(<String>[]);
      });
      final ProviderSubscription<MarketListState> state = harness.keep(
        marketListViewModelProvider,
      );
      final MarketListViewModel viewModel = harness.container.read(
        marketListViewModelProvider.notifier,
      )..start(const InstrumentFilter(query: 'zzz'));
      await _settle();
      expect(state.read().status, ViewStatus.empty);

      viewModel.clearFilters();
      await _settle();

      expect(state.read().status, ViewStatus.data);
      expect(state.read().filter.isEmpty, isTrue);
      verify(() => harness.navigation.go('/market')).called(1);
    });

    test('cambiar país y tipo recarga y refleja el filtro en la URL', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.service.instruments(any(), limit: any(named: 'limit')),
      ).thenAnswer((_) async => _page(<String>['A-CO']));
      harness.keep(marketListViewModelProvider);
      final MarketListViewModel viewModel = harness.container.read(
        marketListViewModelProvider.notifier,
      )..start();
      await _settle();

      viewModel
        ..setCountry(Country.pe)
        ..toggleType(InstrumentType.etf);
      await _settle();
      viewModel.toggleType(InstrumentType.etf);
      await _settle();

      verify(() => harness.navigation.go('/market?country=PE')).called(2);
      verify(
        () => harness.navigation.go('/market?country=PE&type=ETF'),
      ).called(1);
      final List<InstrumentFilter> requested = verify(
        () => harness.service.instruments(
          captureAny(),
          limit: any(named: 'limit'),
        ),
      ).captured.cast<InstrumentFilter>();
      expect(requested.last, const InstrumentFilter(country: Country.pe));
    });

    test('la búsqueda consulta con el texto y lo pone en la URL', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.service.instruments(any(), limit: any(named: 'limit')),
      ).thenAnswer((_) async => _page(<String>['WALMEX-MX']));
      harness.keep(marketListViewModelProvider);
      final MarketListViewModel viewModel = harness.container.read(
        marketListViewModelProvider.notifier,
      )..start();
      await _settle();

      viewModel.setQuery('walmex');
      await _settle();

      verify(() => harness.navigation.go('/market?q=walmex')).called(1);
    });

    test('una respuesta vieja que llega tarde se descarta', () async {
      final _Harness harness = _Harness();
      final Completer<Paginated<Instrument>> slow =
          Completer<Paginated<Instrument>>();
      when(
        () => harness.service.instruments(any(), limit: any(named: 'limit')),
      ).thenAnswer((Invocation invocation) {
        final InstrumentFilter filter =
            invocation.positionalArguments.first as InstrumentFilter;
        return filter.country == Country.mx
            ? Future<Paginated<Instrument>>.value(_page(<String>['MX-MX']))
            : slow.future;
      });
      final ProviderSubscription<MarketListState> state = harness.keep(
        marketListViewModelProvider,
      );
      final MarketListViewModel viewModel = harness.container.read(
        marketListViewModelProvider.notifier,
      )..start();
      await _settle();

      viewModel.setCountry(Country.mx);
      await _settle();
      slow.complete(_page(<String>['VIEJO-CO']));
      await _settle();

      expect(state.read().instruments.items.single.id, 'MX-MX');
    });

    test('loadMore agrega la página siguiente sin duplicados', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.service.instruments(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((Invocation invocation) async {
        final String? cursor = invocation.namedArguments[#cursor] as String?;
        return cursor == null
            ? _page(<String>['A-CO', 'B-CO'], next: 'c1')
            : _page(<String>['B-CO', 'C-CO']);
      });
      final ProviderSubscription<MarketListState> state = harness.keep(
        marketListViewModelProvider,
      );
      final MarketListViewModel viewModel = harness.container.read(
        marketListViewModelProvider.notifier,
      )..start();
      await _settle();

      await Future.wait(<Future<void>>[
        viewModel.loadMore(),
        viewModel.loadMore(),
      ]);

      expect(
        state.read().instruments.items.map((Instrument i) => i.id),
        <String>['A-CO', 'B-CO', 'C-CO'],
      );
      expect(state.read().canLoadMore, isFalse);
      verify(
        () => harness.service.instruments(
          any(),
          cursor: 'c1',
          limit: any(named: 'limit'),
        ),
      ).called(1);
    });

    test('un error pasa a error y reintentar recupera los datos', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.service.instruments(any(), limit: any(named: 'limit')),
      ).thenThrow(const MarketException(MarketErrorCode.network));
      final ProviderSubscription<MarketListState> state = harness.keep(
        marketListViewModelProvider,
      );
      final MarketListViewModel viewModel = harness.container.read(
        marketListViewModelProvider.notifier,
      )..start();
      await _settle();

      expect(state.read().status, ViewStatus.error);
      expect(state.read().errorKey, MarketErrorCode.network.messageKey);
      expect(state.read().isNetworkError, isTrue);

      when(
        () => harness.service.instruments(any(), limit: any(named: 'limit')),
      ).thenAnswer((_) async => _page(<String>['A-CO']));
      await viewModel.refresh();

      expect(state.read().status, ViewStatus.data);
      expect(state.read().errorKey, isNull);
    });

    test('abrir un instrumento navega a su detalle', () async {
      final _Harness harness = _Harness();
      harness.container
          .read(marketListViewModelProvider.notifier)
          .openInstrument(instrument(id: 'BAP-PE'));

      verify(
        () => harness.navigation.push<void>('/market/instrument/BAP-PE'),
      ).called(1);
    });
  });

  group('MarketListState', () {
    test('visibleMarkets sigue al filtro de país y copyWith usa sentinel', () {
      final MarketListState state = MarketListState(
        markets: <CountryMarket>[
          market(),
          market(country: Country.pe),
        ],
        filter: const InstrumentFilter(country: Country.pe),
        loadMoreErrorKey: 'market.error.network',
      );

      expect(state.visibleMarkets.single.country, Country.pe);
      expect(state.copyWith(loadMoreErrorKey: null).loadMoreErrorKey, isNull);
      expect(state.copyWith(), state);
    });
  });

  group('InstrumentDetailViewModel', () {
    void stubDetail(_Harness harness, {String price = '2385.00'}) {
      when(
        () => harness.service.instrument('ECOPETROL-CO'),
      ).thenAnswer((_) async => detail(price: price));
      when(() => harness.service.prices('ECOPETROL-CO', any())).thenAnswer(
        (Invocation invocation) async =>
            series(invocation.positionalArguments[1] as PriceRange),
      );
    }

    test('carga detalle, serie, posición y estado del mercado', () async {
      final _Harness harness = _Harness();
      stubDetail(harness);
      final ProviderSubscription<InstrumentDetailState> state = harness.keep(
        instrumentDetailViewModelProvider('ECOPETROL-CO'),
      );

      expect(state.read().status, ViewStatus.loading);
      await _settle();

      expect(state.read().status, ViewStatus.data);
      expect(state.read().detail, detail());
      expect(state.read().series, series());
      expect(state.read().position?.quantity, 120);
      expect(state.read().market, market());
      expect(state.read().canTrade, isTrue);
      expect(state.read().canSell, isTrue);
    });

    test('un instrumento inexistente queda en empty (no encontrado)', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.service.instrument('NOPE-CO'),
      ).thenThrow(const MarketException(MarketErrorCode.instrumentNotFound));
      final ProviderSubscription<InstrumentDetailState> state = harness.keep(
        instrumentDetailViewModelProvider('NOPE-CO'),
      );
      await _settle();

      expect(state.read().status, ViewStatus.empty);
    });

    test('un error de red queda en error y reintentar carga', () async {
      final _Harness harness = _Harness();
      when(
        () => harness.service.instrument('ECOPETROL-CO'),
      ).thenThrow(const MarketException(MarketErrorCode.network));
      final ProviderSubscription<InstrumentDetailState> state = harness.keep(
        instrumentDetailViewModelProvider('ECOPETROL-CO'),
      );
      await _settle();
      expect(state.read().status, ViewStatus.error);

      stubDetail(harness);
      await harness.container
          .read(instrumentDetailViewModelProvider('ECOPETROL-CO').notifier)
          .load();

      expect(state.read().status, ViewStatus.data);
    });

    test('cambiar de rango pide la serie nueva', () async {
      final _Harness harness = _Harness();
      stubDetail(harness);
      final ProviderSubscription<InstrumentDetailState> state = harness.keep(
        instrumentDetailViewModelProvider('ECOPETROL-CO'),
      );
      await _settle();

      await harness.container
          .read(instrumentDetailViewModelProvider('ECOPETROL-CO').notifier)
          .selectRange(PriceRange.year);

      expect(state.read().range, PriceRange.year);
      expect(state.read().series?.range, PriceRange.year);
    });

    test('con el mercado cerrado no abre el ticket', () async {
      final _Harness harness = _Harness(
        markets: <CountryMarket>[market(open: false)],
      );
      stubDetail(harness);
      final ProviderSubscription<InstrumentDetailState> state = harness.keep(
        instrumentDetailViewModelProvider('ECOPETROL-CO'),
      );
      await _settle();

      harness.container
          .read(instrumentDetailViewModelProvider('ECOPETROL-CO').notifier)
          .buy();

      expect(state.read().canTrade, isFalse);
      verifyNever(() => harness.navigation.push<void>(any()));
    });

    test('sin posición no abre el ticket de venta', () async {
      final _Harness harness = _Harness(holdings: portfolio(quantity: 0));
      stubDetail(harness);
      final ProviderSubscription<InstrumentDetailState> state = harness.keep(
        instrumentDetailViewModelProvider('ECOPETROL-CO'),
      );
      await _settle();
      final InstrumentDetailViewModel viewModel = harness.container.read(
        instrumentDetailViewModelProvider('ECOPETROL-CO').notifier,
      )..sell();

      expect(state.read().canSell, isFalse);
      verifyNever(() => harness.navigation.push<void>(any()));

      viewModel.buy();
      verify(
        () => harness.navigation.push<void>(
          OrdersRoutes.ticketLocation('ECOPETROL-CO', OrderSide.buy.routeValue),
        ),
      ).called(1);
    });

    test('refrescar con un precio distinto dispara el destello', () async {
      final _Harness harness = _Harness();
      stubDetail(harness);
      final ProviderSubscription<InstrumentDetailState> state = harness.keep(
        instrumentDetailViewModelProvider('ECOPETROL-CO'),
      );
      await _settle();

      stubDetail(harness, price: '2390.00');
      await harness.container
          .read(instrumentDetailViewModelProvider('ECOPETROL-CO').notifier)
          .refreshPrice();

      expect(state.read().flashTick, 1);
      expect(state.read().flashSign, 1);
      expect(
        state.read().detail?.instrument.lastPrice,
        Money.parse('2390', Currency.cop),
      );
    });

    test('con PRICE_REFRESH_SECONDS=0 no hay timer', () async {
      final _Harness harness = _Harness();
      stubDetail(harness);
      harness.keep(instrumentDetailViewModelProvider('ECOPETROL-CO'));
      await _settle();

      expect(
        harness.container
            .read(instrumentDetailViewModelProvider('ECOPETROL-CO').notifier)
            .isRefreshing,
        isFalse,
      );
    });

    test('el timer de precios se cancela al destruir el controller', () async {
      final _Harness harness = _Harness(refresh: const Duration(hours: 1));
      stubDetail(harness);
      final ProviderSubscription<InstrumentDetailState> subscription = harness
          .keep(instrumentDetailViewModelProvider('ECOPETROL-CO'));
      await _settle();
      final InstrumentDetailViewModel viewModel = harness.container.read(
        instrumentDetailViewModelProvider('ECOPETROL-CO').notifier,
      );
      expect(viewModel.isRefreshing, isTrue);

      subscription.close();
      await harness.container.pump();

      expect(viewModel.isRefreshing, isFalse);
    });

    test('una orden ejecutada actualiza la posición mostrada', () async {
      int quantity = 120;
      final _Harness harness = _Harness();
      stubDetail(harness);
      harness.container.updateOverrides(<Override>[
        marketServiceProvider.overrideWithValue(harness.service),
        navigationManagerProvider.overrideWithValue(harness.navigation),
        marketSearchDebounceProvider.overrideWithValue(Duration.zero),
        priceRefreshIntervalProvider.overrideWithValue(Duration.zero),
        loggerProvider.overrideWithValue(const SilentAppLogger()),
        countryMarketsProvider.overrideWith(
          (Ref ref) async => <CountryMarket>[market()],
        ),
        portfolioProvider.overrideWith(
          (Ref ref) async => portfolio(quantity: quantity),
        ),
      ]);
      final ProviderSubscription<InstrumentDetailState> state = harness.keep(
        instrumentDetailViewModelProvider('ECOPETROL-CO'),
      );
      await _settle();

      quantity = 130;
      harness.container.invalidate(portfolioProvider);
      await _settle();

      expect(state.read().position?.quantity, 130);
    });
  });
}
