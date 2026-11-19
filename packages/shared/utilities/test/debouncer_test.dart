import 'package:flutter_test/flutter_test.dart';
import 'package:utilities/utilities.dart';

void main() {
  group('Debouncer', () {
    test('con duración cero corre de inmediato', () {
      final Debouncer debouncer = Debouncer(Duration.zero);
      int calls = 0;

      debouncer
        ..run(() => calls++)
        ..run(() => calls++);

      expect(calls, 2);
      expect(debouncer.isPending, isFalse);
    });

    test('agrupa una ráfaga en una sola ejecución', () async {
      final Debouncer debouncer = Debouncer(const Duration(milliseconds: 20));
      int calls = 0;

      debouncer
        ..run(() => calls++)
        ..run(() => calls++)
        ..run(() => calls++);
      expect(calls, 0);
      expect(debouncer.isPending, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(calls, 1);
    });

    test('cancel descarta la acción pendiente', () async {
      final Debouncer debouncer = Debouncer(const Duration(milliseconds: 20));
      int calls = 0;

      debouncer
        ..run(() => calls++)
        ..cancel();
      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(calls, 0);
    });
  });

  group('PlatformGuard', () {
    test('en tests corre como plataforma nativa, no web', () {
      expect(PlatformGuard.isWeb, isFalse);
      expect(PlatformGuard.isRelease, isFalse);
    });
  });

  group('UuidIdGenerator', () {
    test('genera ids distintos con formato UUID', () {
      const UuidIdGenerator generator = UuidIdGenerator();

      final String first = generator.newId();
      final String second = generator.newId();

      expect(first, isNot(second));
      expect(first.length, 36);
    });
  });
}
