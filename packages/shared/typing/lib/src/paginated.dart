import 'package:equatable/equatable.dart';

/// Una página de resultados paginados por cursor.
class Paginated<T> extends Equatable {
  /// Crea una página.
  const Paginated({required this.items, this.nextCursor});

  /// Página vacía y sin continuación.
  const Paginated.empty() : items = const <Never>[], nextCursor = null;

  /// Elementos de esta página, en el orden que entregó la API.
  final List<T> items;

  /// Cursor de la página siguiente, o `null` si no hay más.
  final String? nextCursor;

  /// `true` si queda al menos una página por cargar.
  bool get hasMore => nextCursor != null;

  /// `true` si la página no trae elementos.
  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => <Object?>[items, nextCursor];

  /// Concatena [next] a esta página descartando duplicados.
  ///
  /// El desempate es por el id que devuelve [idOf], no por posición: si la
  /// API repite un elemento entre páginas, se conserva el primero.
  Paginated<T> append(Paginated<T> next, {required String Function(T) idOf}) {
    final Set<String> seen = items.map(idOf).toSet();
    return Paginated<T>(
      items: <T>[
        ...items,
        ...next.items.where((T item) => seen.add(idOf(item))),
      ],
      nextCursor: next.nextCursor,
    );
  }

  /// Copia la página con otros elementos y/o otro cursor.
  Paginated<T> copyWith({List<T>? items, String? nextCursor}) => Paginated<T>(
    items: items ?? this.items,
    nextCursor: nextCursor ?? this.nextCursor,
  );
}
