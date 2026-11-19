import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Única fuente de identificadores generados en el cliente.
///
/// Se usa para las `Idempotency-Key` de las operaciones que mueven dinero y
/// para los ids locales que la app necesita antes de hablar con la API.
abstract interface class IdGenerator {
  /// Devuelve un identificador nuevo.
  String newId();
}

/// Generador secuencial y determinístico, para tests.
final class SequentialIdGenerator implements IdGenerator {
  /// Crea un generador que emite `<prefix><n>` empezando en 1.
  SequentialIdGenerator({String prefix = 'id-'}) : _prefix = prefix;

  final String _prefix;
  int _next = 0;

  @override
  String newId() {
    _next++;
    return '$_prefix$_next';
  }
}

/// Provider del generador de ids.
///
/// Lo sobrescribe el shell con `UuidIdGenerator` (de `shared/utilities`).
final Provider<IdGenerator> idGeneratorProvider = Provider<IdGenerator>(
  (Ref ref) => throw UnimplementedError('idGeneratorProvider'),
);
