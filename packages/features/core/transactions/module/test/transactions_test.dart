import 'dart:async';

import 'package:authentication_typing/authentication_typing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:navigator/navigator.dart';
import 'package:network/network.dart';
import 'package:transactions/core/data/dto/transaction_dto.dart';
import 'package:transactions/core/data/transactions_remote_data_source.dart';
import 'package:transactions/core/service/service.dart';
import 'package:transactions/transactions.dart';
import 'package:transactions/ui/views/movements/movements.dart';
import 'package:transactions_constants/transactions_constants.dart';
import 'package:transactions_typing/transactions_typing.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';
import 'package:wallet_typing/wallet_typing.dart';

import 'support/harness.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockService extends Mock implements ITransactionsService {}

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

Transaction _txn(String id, String amount, DateTime at, {String? order}) =>
    Transaction(
      id: id,
      type: amount.startsWith('-')
          ? TransactionType.buy
          : TransactionType.deposit,
      amount: Money.parse(amount, Currency.cop),
      description: id,
      createdAt: at,
      orderId: order,
    );

final List<Transaction> _sample = <Transaction>[
  _txn('t3', '-23860', DateTime.utc(2026, 11, 18, 14, 43), order: 'ord_1'),
  _txn('t2', '100000', DateTime.utc(2026, 11, 18, 3)),
  _txn('t1', '8000000', DateTime.utc(2026, 11, 15, 15)),
];

final class _Doubles {
  _Doubles() {
    when(() => navigation.push<void>(any())).thenAnswer((_) async {});
  }

  final _MockService service = _MockService();
  final _MockNavigation navigation = _MockNavigation();

  void answer(Future<Paginated<Transaction>> Function() result) => when(
    () => service.transactions(any(), limit: any(named: 'limit')),
  ).thenAnswer((_) => result());

  List<Override> overrides() => <Override>[
    transactionsServiceProvider.overrideWithValue(service),
    navigationManagerProvider.overrideWithValue(navigation),
    loggerProvider.overrideWithValue(const SilentAppLogger()),
    sessionProvider.overrideWithValue(const SessionState.authenticated(_user)),
    accountsProvider.overrideWith((Ref ref) async => <Account>[]),
  ];
}

void main() {
  setUpAll(() => registerFallbackValue(const TransactionFilter()));

  group('TransactionsIds y traducciones', () {
    test('ids válidos y únicos; es y en con las mismas claves', () {
      for (final String id in TransactionsIds.all) {
        expect(identifierPattern.hasMatch(id), isTrue, reason: id);
      }
      expect(TransactionsIds.all.toSet().length, TransactionsIds.all.length);
      final Set<String> es = translationKeys(transactionsLanguages['es']!);
      final Set<String> en = translationKeys(transactionsLanguages['en']!);
      expect(es.difference(en), isEmpty);
      expect(en.difference(es), isEmpty);
      for (final TransactionsErrorCode code in TransactionsErrorCode.values) {
        expect(es, contains(code.messageKey));
      }
      for (final TransactionType type in TransactionType.values) {
        expect(es, contains('transactions.type.${type.name}'));
      }
    });
  });

  group('DTO y service', () {
    test('TransactionDto parsea el ejemplo del contrato y rechaza montos '
        'numéricos', () {
      final Transaction parsed =
          TransactionDto.fromJson(const <String, Object?>{
            'id': 'txn_01H',
            'type': 'BUY',
            'amount': '-23860.00',
            'currency': 'COP',
            'description': 'Compra 10 ECOPETROL',
            'order_id': 'ord_01H',
            'created_at': '2026-11-18T14:43:10Z',
          }).toDomain();

      expect(parsed.type, TransactionType.buy);
      expect(parsed.amount, Money.parse('-23860', Currency.cop));
      expect(parsed.orderId, 'ord_01H');
      expect(
        () => TransactionDto.fromJson(const <String, Object?>{
          'id': 'x',
          'type': 'BUY',
          'amount': -1,
          'currency': 'COP',
          'description': 'x',
          'created_at': '2026-11-18T14:43:10Z',
        }),
        throwsFormatException,
      );
    });

    test('el rango se traduce a `from` con el reloj inyectado', () async {
      final _MockApiClient client = _MockApiClient();
      when(
        () => client.get('/transactions', query: any(named: 'query')),
      ).thenAnswer(
        (_) async => const ApiResponse(
          statusCode: 200,
          body: <String, Object?>{'items': <Object?>[], 'next_cursor': null},
        ),
      );
      final TransactionsService service = TransactionsService(
        dataSource: TransactionsRemoteDataSource(client),
        clock: FixedClock(DateTime.utc(2026, 11, 18, 12)),
      );

      await service.transactions(
        const TransactionFilter(
          type: TransactionType.deposit,
          range: TransactionRange.week,
        ),
      );

      final Map<String, Object?> query =
          verify(
                () => client.get(
                  '/transactions',
                  query: captureAny(named: 'query'),
                ),
              ).captured.single
              as Map<String, Object?>;
      expect(query['type'], 'DEPOSIT');
      expect(query['from'], '2026-11-11T12:00:00.000Z');
    });
  });

  group('MovementsState', () {
    test('agrupa por día en la zona del usuario', () {
      final MovementsState state = MovementsState(
        transactions: Paginated<Transaction>(items: _sample),
      );

      final List<TransactionDay> days = state.groupedBy(Country.co);

      expect(days.map((TransactionDay d) => d.isoDate), <String>[
        '2026-11-18',
        '2026-11-17',
        '2026-11-15',
      ]);
      expect(days.first.transactions.single.id, 't3');
    });
  });

  group('MovementsViewModel', () {
    test('filtrar recarga y refleja el filtro en la URL', () async {
      final _Doubles doubles = _Doubles()
        ..answer(() async => Paginated<Transaction>(items: _sample));
      final ProviderContainer container = ProviderContainer(
        overrides: doubles.overrides(),
      );
      addTearDown(container.dispose);
      container.listen(movementsViewModelProvider, (_, _) {});
      final MovementsViewModel viewModel = container.read(
        movementsViewModelProvider.notifier,
      )..start();
      for (int i = 0; i < 6; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      viewModel
        ..setType(TransactionType.fee)
        ..setRange(TransactionRange.month);

      verify(() => doubles.navigation.go('/activity?type=FEE')).called(1);
      verify(
        () => doubles.navigation.go('/activity?type=FEE&range=30d'),
      ).called(1);
    });
  });

  group('MovementsView', () {
    const AppRouteParams params = AppRouteParams(location: '/activity');

    Future<void> show(WidgetTester tester, _Doubles doubles) async {
      await pumpView(
        tester,
        const MovementsView(params: params),
        languages: transactionsLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('loading', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles()
        ..answer(() => Completer<Paginated<Transaction>>().future);
      await show(tester, doubles);

      expect(
        find.bySemanticsIdentifier(TransactionsIds.listView),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(TransactionsIds.listStateLoading),
        findsOneWidget,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('data: días, montos con signo y abrir la orden', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles()
        ..answer(() async => Paginated<Transaction>(items: _sample));
      await show(tester, doubles);

      expect(
        find.bySemanticsIdentifier(TransactionsIds.dayItem('2026-11-18')),
        findsOneWidget,
      );
      expect(
        labelOf(tester, TransactionsIds.listItemAmountText('t3')),
        '− 23.860 pesos colombianos',
      );
      expect(find.text(r'+$ 100.000 COP'), findsOneWidget);
      for (final String id in <String>[
        TransactionsIds.listMovementsTab,
        TransactionsIds.listOrdersTab,
        TransactionsIds.listTypeAllChip,
        TransactionsIds.listTypeFeeChip,
        TransactionsIds.listRange7dChip,
      ]) {
        expect(find.bySemanticsIdentifier(id), findsOneWidget, reason: id);
      }
      expectNoDuplicateIdentifiers(tester);

      final Finder item = find.bySemanticsIdentifier(
        TransactionsIds.listItem('t3'),
      );
      await tester.ensureVisible(item);
      await tester.tap(item);
      verify(
        () => doubles.navigation.push<void>('/activity/orders/ord_1'),
      ).called(1);

      await tester.tap(
        find.bySemanticsIdentifier(TransactionsIds.listOrdersTab),
      );
      verify(() => doubles.navigation.go('/activity/orders')).called(1);
      handle.dispose();
    });

    testWidgets('empty sin filtros ofrece depositar en la moneda base', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles()
        ..answer(() async => const Paginated<Transaction>.empty());
      await show(tester, doubles);

      expect(
        labelOf(tester, TransactionsIds.listEmptyTitleText),
        'Aún no tienes movimientos',
      );
      final Finder deposit = find.bySemanticsIdentifier(
        TransactionsIds.listEmptyDepositButton,
      );
      await tester.ensureVisible(deposit);
      await tester.tap(deposit);
      verify(
        () => doubles.navigation.push<void>('/wallet/deposit/COP'),
      ).called(1);
      handle.dispose();
    });

    testWidgets('error: mensaje y "Reintentar"', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles()
        ..answer(
          () async =>
              throw const TransactionsException(TransactionsErrorCode.network),
        );
      await show(tester, doubles);

      expect(
        find.bySemanticsIdentifier(TransactionsIds.listStateError),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(TransactionsIds.listRetryButton),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
