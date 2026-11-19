import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:money_text/money_text.dart';
import 'package:typing/typing.dart';

/// Identificadores de cada parte de un [OrderSummary].
@immutable
class OrderSummaryIds {
  /// Crea el juego de identificadores.
  const OrderSummaryIds({
    required this.root,
    required this.price,
    required this.gross,
    required this.commission,
    required this.total,
    required this.availableAfter,
  });

  /// Raíz del resumen.
  final String root;

  /// Precio estimado o de ejecución.
  final String price;

  /// Monto bruto.
  final String gross;

  /// Comisión.
  final String commission;

  /// Total.
  final String total;

  /// Saldo resultante.
  final String availableAfter;
}

/// Textos de cada fila de un [OrderSummary], ya traducidos.
@immutable
class OrderSummaryLabels {
  /// Crea el juego de textos.
  const OrderSummaryLabels({
    required this.price,
    required this.gross,
    required this.commission,
    required this.total,
    required this.availableAfter,
  });

  /// "Precio estimado" o "Precio de ejecución".
  final String price;

  /// "Monto bruto".
  final String gross;

  /// "Comisión".
  final String commission;

  /// "Total".
  final String total;

  /// "Saldo resultante".
  final String availableAfter;
}

/// Filas precio / bruto / comisión / total / saldo resultante de una orden.
///
/// La comisión la calcula el backend: este componente solo la muestra. El
/// total va destacado; el saldo resultante se pinta de error si es negativo.
class OrderSummary extends StatelessWidget {
  /// Crea el resumen.
  const OrderSummary({
    required this.ids,
    required this.labels,
    required this.price,
    required this.gross,
    required this.commission,
    required this.total,
    this.availableAfter,
    super.key,
  });

  /// Identificadores de las partes.
  final OrderSummaryIds ids;

  /// Textos de las filas.
  final OrderSummaryLabels labels;

  /// Precio estimado o de ejecución.
  final Money price;

  /// Monto bruto.
  final Money gross;

  /// Comisión.
  final Money commission;

  /// Total.
  final Money total;

  /// Saldo resultante; `null` oculta la fila (orden ya ejecutada).
  final Money? availableAfter;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Money? after = availableAfter;
    return Identified(
      id: ids.root,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Row(
            label: labels.price,
            value: MoneyText(
              id: ids.price,
              money: price,
              isPrice: true,
              size: MoneyTextSize.compact,
            ),
          ),
          _Row(
            label: labels.gross,
            value: MoneyText(
              id: ids.gross,
              money: gross,
              size: MoneyTextSize.compact,
            ),
          ),
          _Row(
            label: labels.commission,
            value: MoneyText(
              id: ids.commission,
              money: commission,
              size: MoneyTextSize.compact,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Divider(),
          ),
          _Row(
            label: labels.total,
            emphasized: true,
            value: MoneyText(id: ids.total, money: total),
          ),
          if (after != null)
            _Row(
              label: labels.availableAfter,
              value: MoneyText(
                id: ids.availableAfter,
                money: after,
                size: MoneyTextSize.compact,
                color: after.isNegative ? theme.colorScheme.error : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final Widget value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        children: <Widget>[
          Text(
            label,
            style: emphasized ? textTheme.titleMedium : textTheme.bodyMedium,
          ),
          value,
        ],
      ),
    );
  }
}
