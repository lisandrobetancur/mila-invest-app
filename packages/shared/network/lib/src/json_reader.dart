import 'package:decimal/decimal.dart';
import 'package:typing/typing.dart';

/// Lectura estricta de un objeto JSON, para los DTOs.
///
/// Un campo requerido ausente o con un tipo inesperado lanza
/// [FormatException]; el service de cada feature lo traduce a su
/// `unexpectedResponse`. Nada se convierte "por las dudas": un monto que
/// llega como número JSON es un error de contrato, no un `double` aceptado
/// en silencio.
final class JsonReader {
  /// Envuelve un objeto JSON ya decodificado.
  const JsonReader(this._json);

  /// Envuelve [value] si es un objeto JSON; si no, lanza [FormatException].
  factory JsonReader.of(Object? value) {
    if (value is Map<String, Object?>) {
      return JsonReader(value);
    }
    throw FormatException(
      'Se esperaba un objeto JSON y llegó ${value.runtimeType}',
    );
  }

  final Map<String, Object?> _json;

  /// Lee una lista JSON de objetos desde el cuerpo de una respuesta.
  static List<JsonReader> listOf(Object? value) {
    if (value is! List<Object?>) {
      throw FormatException(
        'Se esperaba una lista JSON y llegó ${value.runtimeType}',
      );
    }
    return value.map(JsonReader.of).toList(growable: false);
  }

  /// Booleano requerido.
  bool boolean(String key) => _require<bool>(key, 'bool');

  /// Moneda requerida, por código ISO 4217.
  Currency currency(String key) {
    final String code = string(key);
    return Currency.tryFromCode(code) ??
        (throw FormatException('Moneda desconocida en "$key": $code'));
  }

  /// Instante requerido, en ISO 8601. Se devuelve siempre en UTC.
  DateTime dateTime(String key) => _parseDate(key, string(key));

  /// Instante opcional.
  DateTime? dateTimeOrNull(String key) {
    final String? raw = stringOrNull(key);
    return raw == null ? null : _parseDate(key, raw);
  }

  /// Decimal requerido. **Tiene que llegar como string** (`"1234.56"`).
  Decimal decimal(String key) => _parseDecimal(key, string(key));

  /// Decimal opcional; si viene, tiene que ser un string.
  Decimal? decimalOrNull(String key) {
    final String? raw = stringOrNull(key);
    return raw == null ? null : _parseDecimal(key, raw);
  }

  /// Valor requerido de un enum, resuelto con [lookup].
  T enumValue<T>(String key, T? Function(String code) lookup) {
    final String code = string(key);
    return lookup(code) ??
        (throw FormatException('Valor desconocido en "$key": $code'));
  }

  /// `true` si [key] está presente y no es `null`.
  bool has(String key) => _json[key] != null;

  /// Entero requerido.
  int integer(String key) => _require<int>(key, 'int');

  /// Entero opcional.
  int? integerOrNull(String key) => _optional<int>(key, 'int');

  /// Monto requerido en [currency].
  Money money(String key, Currency currency) => Money(decimal(key), currency);

  /// Monto opcional en [currency].
  Money? moneyOrNull(String key, Currency currency) {
    final Decimal? amount = decimalOrNull(key);
    return amount == null ? null : Money(amount, currency);
  }

  /// Objeto anidado requerido.
  JsonReader object(String key) =>
      JsonReader(_require<Map<String, Object?>>(key, 'object'));

  /// Objeto anidado opcional.
  JsonReader? objectOrNull(String key) {
    final Map<String, Object?>? value = _optional<Map<String, Object?>>(
      key,
      'object',
    );
    return value == null ? null : JsonReader(value);
  }

  /// Lista requerida de objetos.
  List<JsonReader> objects(String key) => _require<List<Object?>>(
    key,
    'list',
  ).map(JsonReader.of).toList(growable: false);

  /// Página paginada por cursor (`{ items, next_cursor }`).
  Paginated<T> paginated<T>(T Function(JsonReader item) parse) => Paginated<T>(
    items: objects('items').map(parse).toList(growable: false),
    nextCursor: stringOrNull('next_cursor'),
  );

  /// String requerido.
  String string(String key) => _require<String>(key, 'string');

  /// String opcional.
  String? stringOrNull(String key) => _optional<String>(key, 'string');

  /// Lista requerida de strings.
  List<String> strings(String key) {
    final List<Object?> raw = _require<List<Object?>>(key, 'list');
    return raw
        .map(
          (Object? item) => item is String
              ? item
              : (throw FormatException(
                  'Se esperaba string en la lista "$key"',
                )),
        )
        .toList(growable: false);
  }

  T? _optional<T extends Object>(String key, String expected) {
    final Object? value = _json[key];
    if (value == null) {
      return null;
    }
    if (value is T) {
      return value;
    }
    throw FormatException(
      'Campo "$key": se esperaba $expected y llegó ${value.runtimeType}',
    );
  }

  DateTime _parseDate(String key, String raw) {
    final DateTime? parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      throw FormatException('Campo "$key": fecha inválida "$raw"');
    }
    return parsed.toUtc();
  }

  Decimal _parseDecimal(String key, String raw) =>
      Decimal.tryParse(raw) ??
      (throw FormatException('Campo "$key": decimal inválido "$raw"'));

  T _require<T extends Object>(String key, String expected) {
    final T? value = _optional<T>(key, expected);
    if (value == null) {
      throw FormatException('Campo requerido ausente: "$key"');
    }
    return value;
  }
}
