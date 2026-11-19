import 'package:network/network.dart';
import 'package:orders_typing/orders_typing.dart';
import 'package:typing/typing.dart';

/// Respuesta de `POST /orders/preview`.
class OrderPreviewDto {
  /// Crea el DTO.
  const OrderPreviewDto({
    required this.estimatedPrice,
    required this.gross,
    required this.commission,
    required this.total,
    required this.availableAfter,
    required this.warnings,
  });

  /// Lee el DTO. Lanza [FormatException] si el JSON no cumple el contrato.
  factory OrderPreviewDto.fromJson(Map<String, Object?> json) {
    final JsonReader reader = JsonReader(json);
    final Currency currency = reader.currency('currency');
    return OrderPreviewDto(
      estimatedPrice: reader.money('estimated_price', currency),
      gross: reader.money('gross', currency),
      commission: reader.money('commission', currency),
      total: reader.money('total', currency),
      availableAfter: reader.money('available_after', currency),
      warnings: reader.has('warnings')
          ? reader.strings('warnings')
          : const <String>[],
    );
  }

  /// Precio estimado.
  final Money estimatedPrice;

  /// Bruto.
  final Money gross;

  /// Comisión.
  final Money commission;

  /// Total.
  final Money total;

  /// Saldo resultante.
  final Money availableAfter;

  /// Avisos.
  final List<String> warnings;

  /// Convierte a dominio.
  OrderPreview toDomain() => OrderPreview(
    estimatedPrice: estimatedPrice,
    gross: gross,
    commission: commission,
    total: total,
    availableAfter: availableAfter,
    warnings: warnings,
  );
}
