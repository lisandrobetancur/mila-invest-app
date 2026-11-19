import 'package:equatable/equatable.dart';
import 'package:typing/typing.dart';

/// Cotización de una orden, antes de confirmarla.
///
/// La comisión la calcula el backend: la app nunca la calcula.
class OrderPreview extends Equatable {
  /// Crea la cotización.
  const OrderPreview({
    required this.estimatedPrice,
    required this.gross,
    required this.commission,
    required this.total,
    required this.availableAfter,
    this.warnings = const <String>[],
  });

  /// Precio estimado de ejecución.
  final Money estimatedPrice;

  /// Monto bruto: precio × cantidad.
  final Money gross;

  /// Comisión.
  final Money commission;

  /// Total a pagar (compra) o a recibir (venta).
  final Money total;

  /// Saldo resultante en la cuenta de la moneda del instrumento.
  final Money availableAfter;

  /// Avisos del backend (`LOW_BALANCE`).
  final List<String> warnings;

  /// Moneda de la orden.
  Currency get currency => total.currency;

  /// `true` si el saldo resultante es negativo.
  bool get leavesNegativeBalance => availableAfter.isNegative;

  /// `true` si el backend avisa que el saldo queda bajo.
  bool get hasLowBalanceWarning => warnings.contains('LOW_BALANCE');

  @override
  List<Object?> get props => <Object?>[
    estimatedPrice,
    gross,
    commission,
    total,
    availableAfter,
    warnings,
  ];
}
