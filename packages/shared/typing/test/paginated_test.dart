import 'package:flutter_test/flutter_test.dart';
import 'package:typing/typing.dart';

void main() {
  group('Paginated', () {
    test('la página vacía no tiene continuación', () {
      const Paginated<String> page = Paginated<String>.empty();

      expect(page.isEmpty, isTrue);
      expect(page.hasMore, isFalse);
    });

    test('append concatena y conserva el cursor nuevo', () {
      const Paginated<String> first = Paginated<String>(
        items: <String>['a', 'b'],
        nextCursor: 'c1',
      );
      const Paginated<String> second = Paginated<String>(
        items: <String>['c'],
        nextCursor: 'c2',
      );

      final Paginated<String> merged = first.append(
        second,
        idOf: (String item) => item,
      );

      expect(merged.items, <String>['a', 'b', 'c']);
      expect(merged.nextCursor, 'c2');
      expect(merged.hasMore, isTrue);
    });

    test('append descarta duplicados por id', () {
      const Paginated<String> first = Paginated<String>(
        items: <String>['a', 'b'],
        nextCursor: 'c1',
      );
      const Paginated<String> second = Paginated<String>(
        items: <String>['b', 'c', 'c'],
      );

      final Paginated<String> merged = first.append(
        second,
        idOf: (String item) => item,
      );

      expect(merged.items, <String>['a', 'b', 'c']);
      expect(merged.hasMore, isFalse);
    });
  });

  group('ViewStatus y SubmitStatus', () {
    test('exponen getters coherentes', () {
      expect(ViewStatus.loading.isLoading, isTrue);
      expect(ViewStatus.data.isData, isTrue);
      expect(ViewStatus.empty.isEmpty, isTrue);
      expect(ViewStatus.error.isError, isTrue);
      expect(ViewStatus.error.isData, isFalse);
      expect(SubmitStatus.idle.isIdle, isTrue);
      expect(SubmitStatus.submitting.isSubmitting, isTrue);
      expect(SubmitStatus.success.isSuccess, isTrue);
      expect(SubmitStatus.failure.isFailure, isTrue);
    });
  });
}
