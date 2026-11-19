import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typing/typing.dart';

class _CounterViewModel extends ViewModel<int> {
  final List<String> calls = <String>[];
  late Object keyBeforeAwait;

  @override
  int initState() {
    calls.add('initState');
    return 0;
  }

  @override
  void postInit() => calls.add('postInit');

  void start() => runPostBuild(() async {
    calls.add('postBuild');
    keyBeforeAwait = mountedKey;
    await Future<void>.delayed(Duration.zero);
    if (!isMounted(keyBeforeAwait)) {
      calls.add('abandonado');
      return;
    }
    state = state + 1;
  });
}

class _ScreenViewModel extends AutoDisposeViewModel<int> {
  static int disposed = 0;

  @override
  int initState() => 0;

  @override
  void postInit() => ref.onDispose(() => disposed++);

  void increment() => state = state + 1;
}

final AutoDisposeNotifierProvider<_ScreenViewModel, int> _screenProvider =
    NotifierProvider.autoDispose<_ScreenViewModel, int>(_ScreenViewModel.new);

final NotifierProvider<_CounterViewModel, int> _provider =
    NotifierProvider<_CounterViewModel, int>(_CounterViewModel.new);

void main() {
  group('ViewModel', () {
    test('resuelve dependencias en postInit antes de exponer estado', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(_provider), 0);
      expect(container.read(_provider.notifier).calls, <String>[
        'initState',
        'postInit',
      ]);
    });

    test(
      'runPostBuild corre después del build y puede escribir estado',
      () async {
        final ProviderContainer container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(_provider.notifier).start();
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(container.read(_provider), 1);
      },
    );

    test(
      'mountedKey detecta que el controller se destruyó en el await',
      () async {
        final ProviderContainer container = ProviderContainer();
        final _CounterViewModel notifier = container.read(_provider.notifier)
          ..start();

        await Future<void>.delayed(Duration.zero);
        container.dispose();
        await Future<void>.delayed(Duration.zero);

        expect(notifier.calls, contains('abandonado'));
      },
    );
  });

  group('AutoDisposeViewModel', () {
    test('se destruye cuando nadie lo observa y avisa en onDispose', () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      _ScreenViewModel.disposed = 0;

      final ProviderSubscription<int> subscription = container.listen<int>(
        _screenProvider,
        (int? previous, int next) {},
      );
      container.read(_screenProvider.notifier).increment();
      expect(container.read(_screenProvider), 1);

      subscription.close();
      await container.pump();

      expect(_ScreenViewModel.disposed, 1);
      expect(container.read(_screenProvider), 0);
    });
  });
}
