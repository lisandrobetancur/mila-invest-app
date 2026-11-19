import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:navigator/navigator.dart';
import 'package:network/network.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';
import 'package:wallet/core/data/wallet_remote_data_source.dart';
import 'package:wallet/core/service/service.dart';
import 'package:wallet/ui/views/accounts/accounts.dart';
import 'package:wallet/ui/views/deposit/deposit.dart';
import 'package:wallet/wallet.dart';
import 'package:wallet_constants/wallet_constants.dart';
import 'package:wallet_typing/wallet_typing.dart';

import 'support/harness.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockService extends Mock implements IWalletService {}

class _MockNavigation extends Mock implements NavigationManager {}

Money _cop(String value) => Money.parse(value, Currency.cop);

List<Account> _accounts({String cop = '7448740'}) => <Account>[
  Account(
    id: 'a1',
    currency: Currency.cop,
    available: _cop(cop),
    reserved: _cop('0'),
  ),
  Account(
    id: 'a2',
    currency: Currency.mxn,
    available: Money.parse(cop == '0' ? '0' : '22120', Currency.mxn),
    reserved: Money.zero(Currency.mxn),
  ),
  Account(
    id: 'a3',
    currency: Currency.pen,
    available: Money.parse(cop == '0' ? '0' : '5570', Currency.pen),
    reserved: Money.zero(Currency.pen),
  ),
];

const Map<String, Object?> _receipt = <String, Object?>{
  'id': 'txn_1',
  'type': 'DEPOSIT',
  'amount': '100000.00',
  'currency': 'COP',
  'description': 'Depósito virtual',
  'order_id': null,
  'created_at': '2026-11-18T14:42:00Z',
};

final class _Doubles {
  _Doubles({Future<List<Account>> Function()? accounts}) {
    when(navigation.canPop).thenReturn(true);
    when(() => navigation.push<void>(any())).thenAnswer((_) async {});
    _accounts0 = accounts ?? () async => _accounts();
  }

  final _MockService service = _MockService();
  final _MockNavigation navigation = _MockNavigation();
  late Future<List<Account>> Function() _accounts0;
  int fetches = 0;

  List<Override> overrides() => <Override>[
    walletServiceProvider.overrideWithValue(service),
    navigationManagerProvider.overrideWithValue(navigation),
    loggerProvider.overrideWithValue(const SilentAppLogger()),
    accountsProvider.overrideWith((Ref ref) {
      fetches++;
      return _accounts0();
    }),
  ];
}

Future<void> _settle() async {
  for (int i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUpAll(() => registerFallbackValue(_cop('1')));

  group('WalletIds y traducciones', () {
    test('ids válidos y únicos; es y en con las mismas claves', () {
      for (final String id in WalletIds.all) {
        expect(identifierPattern.hasMatch(id), isTrue, reason: id);
      }
      expect(WalletIds.all.toSet().length, WalletIds.all.length);
      final Set<String> es = translationKeys(walletLanguages['es']!);
      final Set<String> en = translationKeys(walletLanguages['en']!);
      expect(es.difference(en), isEmpty);
      expect(en.difference(es), isEmpty);
      for (final WalletErrorCode code in WalletErrorCode.values) {
        expect(es, contains(code.messageKey));
      }
    });
  });

  group('WalletService', () {
    test(
      'lee las cuentas y deposita con Idempotency-Key reutilizable',
      () async {
        final _MockApiClient client = _MockApiClient();
        final List<String> keys = <String>[];
        int call = 0;
        when(() => client.get('/accounts')).thenAnswer(
          (_) async => const ApiResponse(
            statusCode: 200,
            body: <Object?>[
              <String, Object?>{
                'id': 'a1',
                'currency': 'COP',
                'available': '100.00',
                'reserved': '0.00',
              },
            ],
          ),
        );
        when(
          () => client.post(
            '/accounts/COP/deposits',
            body: any(named: 'body'),
            headers: any(named: 'headers'),
          ),
        ).thenAnswer((Invocation invocation) async {
          keys.add(
            (invocation.namedArguments[#headers]!
                as Map<String, String>)[ApiHeaders.idempotencyKey]!,
          );
          if (call++ == 0) {
            throw const ApiException.networkTimeout();
          }
          return const ApiResponse(statusCode: 201, body: _receipt);
        });
        final WalletService service = WalletService(
          dataSource: WalletRemoteDataSource(client),
          idGenerator: SequentialIdGenerator(prefix: 'k-'),
        );

        final List<Account> accounts = await service.accounts();
        await expectLater(
          service.deposit(_cop('100000')),
          throwsA(isA<WalletException>()),
        );
        final DepositReceipt receipt = await service.deposit(_cop('100000'));
        await service.deposit(_cop('100000'));

        expect(accounts.single.available, _cop('100'));
        expect(receipt.amount, _cop('100000'));
        expect(keys, <String>['k-1', 'k-1', 'k-2']);
        verify(
          () => client.post(
            '/accounts/COP/deposits',
            body: <String, Object?>{'amount': '100000'},
            headers: any(named: 'headers'),
          ),
        ).called(3);
      },
    );

    test('un monto que llega como número es un contrato roto', () async {
      final _MockApiClient client = _MockApiClient();
      when(() => client.get('/accounts')).thenAnswer(
        (_) async => const ApiResponse(
          statusCode: 200,
          body: <Object?>[
            <String, Object?>{
              'id': 'a1',
              'currency': 'COP',
              'available': 100,
              'reserved': '0.00',
            },
          ],
        ),
      );
      final WalletService service = WalletService(
        dataSource: WalletRemoteDataSource(client),
        idGenerator: SequentialIdGenerator(),
      );

      await expectLater(
        service.accounts(),
        throwsA(
          isA<WalletException>().having(
            (WalletException e) => e.code,
            'code',
            WalletErrorCode.unexpectedResponse,
          ),
        ),
      );
    });
  });

  group('DepositState', () {
    test('valida el monto y acepta coma decimal', () {
      const DepositState state = DepositState(currency: Currency.pen);

      expect(
        state.copyWith(amountText: '1.234,5').amountErrorKey,
        'wallet.deposit.amount_invalid',
      );
      expect(
        state.copyWith(amountText: '1234,5').amount,
        Money.parse('1234.5', Currency.pen),
      );
      expect(
        state.copyWith(amountText: '0').amountErrorKey,
        'wallet.deposit.amount_min',
      );
      expect(
        state.copyWith(amountText: '2000000000').amountErrorKey,
        'wallet.deposit.amount_max',
      );
      expect(state.copyWith(amountText: '500').amountErrorKey, isNull);
      expect(state.visibleAmountErrorKey, isNull);
      expect(state.suggestions, <String>['500', '1000', '5000']);
      expect(
        state.copyWith(errorKey: 'x').copyWith(errorKey: null).errorKey,
        isNull,
      );
    });
  });

  group('DepositViewModel', () {
    test(
      'un doble toque deposita una vez e invalida accountsProvider',
      () async {
        final _Doubles doubles = _Doubles();
        final Completer<DepositReceipt> gate = Completer<DepositReceipt>();
        when(
          () => doubles.service.deposit(any()),
        ).thenAnswer((_) => gate.future);
        final ProviderContainer container = ProviderContainer(
          overrides: doubles.overrides(),
        );
        addTearDown(container.dispose);
        final ProviderSubscription<DepositState> state = container.listen(
          depositViewModelProvider(Currency.cop),
          (_, _) {},
        );
        await _settle();
        expect(state.read().available, _cop('7448740'));
        final int fetches = doubles.fetches;
        final DepositViewModel viewModel = container.read(
          depositViewModelProvider(Currency.cop).notifier,
        )..useSuggestion('500000');

        final Future<bool> first = viewModel.submit();
        final Future<bool> second = viewModel.submit();
        gate.complete(
          DepositReceipt(
            transactionId: 't1',
            amount: _cop('500000'),
            createdAt: DateTime.utc(2026),
          ),
        );

        expect(await first, isTrue);
        expect(await second, isFalse);
        verify(() => doubles.service.deposit(_cop('500000'))).called(1);
        await container.read(accountsProvider.future);
        expect(doubles.fetches, greaterThan(fetches));
      },
    );

    test('un monto inválido no envía y un error se muestra', () async {
      final _Doubles doubles = _Doubles();
      when(
        () => doubles.service.deposit(any()),
      ).thenThrow(const WalletException(WalletErrorCode.network));
      final ProviderContainer container = ProviderContainer(
        overrides: doubles.overrides(),
      );
      addTearDown(container.dispose);
      final ProviderSubscription<DepositState> state = container.listen(
        depositViewModelProvider(Currency.cop),
        (_, _) {},
      );
      final DepositViewModel viewModel = container.read(
        depositViewModelProvider(Currency.cop).notifier,
      );

      expect(await viewModel.submit(), isFalse);
      expect(
        state.read().visibleAmountErrorKey,
        'wallet.deposit.amount_invalid',
      );
      verifyNever(() => doubles.service.deposit(any()));

      viewModel.setAmountText('1000');
      expect(await viewModel.submit(), isFalse);
      expect(state.read().errorKey, WalletErrorCode.network.messageKey);
    });
  });

  group('AccountsView', () {
    Future<void> show(WidgetTester tester, _Doubles doubles) async {
      await pumpView(
        tester,
        const AccountsView(),
        languages: walletLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('loading', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await show(
        tester,
        _Doubles(accounts: () => Completer<List<Account>>().future),
      );

      expect(
        find.bySemanticsIdentifier(WalletIds.accountsView),
        findsOneWidget,
      );
      expect(
        find.bySemanticsIdentifier(WalletIds.accountsStateLoading),
        findsOneWidget,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('data: una tarjeta por cuenta y depositar', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      await show(tester, doubles);

      expect(
        find.bySemanticsIdentifier(WalletIds.accountsStateData),
        findsOneWidget,
      );
      expect(
        labelOf(tester, WalletIds.copAvailableText),
        '7.448.740 pesos colombianos',
      );
      expect(labelOf(tester, WalletIds.penAvailableText), '5,570.00 soles');
      expect(
        find.bySemanticsIdentifier(WalletIds.accountItem('MXN')),
        findsOneWidget,
      );
      expectNoDuplicateIdentifiers(tester);
      final Finder deposit = find.bySemanticsIdentifier(
        WalletIds.penDepositButton,
      );
      await tester.ensureVisible(deposit);
      await tester.tap(deposit);
      verify(
        () => doubles.navigation.push<void>('/wallet/deposit/PEN'),
      ).called(1);
      handle.dispose();
    });

    testWidgets('empty: sin saldo ofrece depositar', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await show(tester, _Doubles(accounts: () async => _accounts(cop: '0')));

      expect(
        labelOf(tester, WalletIds.accountsEmptyTitleText),
        'Aún no tienes saldo',
      );
      expect(
        find.bySemanticsIdentifier(WalletIds.accountsEmptyDepositButton),
        findsOneWidget,
      );
      expectNoDuplicateIdentifiers(tester);
      handle.dispose();
    });

    testWidgets('error: mensaje y "Reintentar"', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await show(
        tester,
        _Doubles(
          accounts: () async =>
              throw const WalletException(WalletErrorCode.network),
        ),
      );

      expect(
        find.bySemanticsIdentifier(WalletIds.accountsStateError),
        findsOneWidget,
      );
      expect(
        labelOf(tester, WalletIds.accountsErrorText),
        startsWith('No pudimos conectar'),
      );
      expect(
        find.bySemanticsIdentifier(WalletIds.accountsRetryButton),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('DepositView', () {
    testWidgets('elige moneda, usa un sugerido y deposita', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _Doubles doubles = _Doubles();
      when(() => doubles.service.deposit(any())).thenAnswer(
        (Invocation invocation) async => DepositReceipt(
          transactionId: 't1',
          amount: invocation.positionalArguments.first as Money,
          createdAt: DateTime.utc(2026),
        ),
      );
      await pumpView(
        tester,
        const Scaffold(body: DepositView(currency: Currency.cop)),
        languages: walletLanguages,
        overrides: doubles.overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsIdentifier(WalletIds.depositView), findsOneWidget);
      expect(
        tester
            .getSemantics(
              find.bySemanticsIdentifier(WalletIds.depositAmountField),
            )
            .getSemanticsData()
            .flagsCollection
            .isTextField,
        isTrue,
      );
      expect(
        labelOf(tester, WalletIds.depositAvailableText),
        r'Disponible: $ 7.448.740 COP',
      );
      expectNoDuplicateIdentifiers(tester);

      await tester.tap(
        find.bySemanticsIdentifier(WalletIds.depositCurrencyMxnSegment),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.bySemanticsIdentifier(WalletIds.suggestedItem('5000')),
      );
      await tester.pump();
      expect(find.text('5000'), findsOneWidget);

      final Finder submit = find.bySemanticsIdentifier(
        WalletIds.depositSubmitButton,
      );
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      verify(
        () => doubles.service.deposit(Money.parse('5000', Currency.mxn)),
      ).called(1);
      expect(
        labelOf(tester, WalletIds.depositSuccessSnackbar),
        r'Depositamos $5,000.00 MXN en tu billetera.',
      );
      verify(() => doubles.navigation.pop<void>()).called(1);
      handle.dispose();
    });

    testWidgets('un monto inválido muestra el error del campo', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpView(
        tester,
        const Scaffold(body: DepositView(currency: Currency.cop)),
        languages: walletLanguages,
        overrides: _Doubles().overrides(),
      );
      await tester.pumpAndSettle();

      final Finder submit = find.bySemanticsIdentifier(
        WalletIds.depositSubmitButton,
      );
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();

      expect(
        labelOf(tester, '${WalletIds.depositAmountField}_error_text'),
        'Escribe un monto válido.',
      );
      handle.dispose();
    });
  });
}
