import 'package:typing/typing.dart';
import 'package:uuid/uuid.dart';

/// Generador de ids basado en UUID v4.
///
/// Es la implementación con la que el shell sobrescribe
/// `idGeneratorProvider`.
final class UuidIdGenerator implements IdGenerator {
  /// Crea un generador de UUID v4.
  const UuidIdGenerator({Uuid uuid = const Uuid()}) : _uuid = uuid;

  final Uuid _uuid;

  @override
  String newId() => _uuid.v4();
}
