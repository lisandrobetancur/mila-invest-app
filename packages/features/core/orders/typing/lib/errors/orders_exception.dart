import 'orders_error_code.dart';

/// Excepción tipada de orders.
class OrdersException implements Exception {
  /// Crea la excepción.
  const OrdersException(
    this.code, {
    this.fieldCodes = const <String, String>{},
  });

  /// Código del error.
  final OrdersErrorCode code;

  /// Códigos de error por campo (`quantity` → `TOO_LARGE`).
  final Map<String, String> fieldCodes;

  @override
  String toString() => 'OrdersException(${code.name})';
}
