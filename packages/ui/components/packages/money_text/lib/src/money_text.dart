import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

/// Tamaño de un [MoneyText].
enum MoneyTextSize {
  /// Valor total del portafolio (`displayLarge`).
  display,

  /// Precio en el detalle de instrumento (`headlineMedium`).
  large,

  /// Monto dentro de un texto o una tarjeta (`titleMedium`).
  body,

  /// Monto dentro de una fila de lista (`bodyMedium`).
  compact,
}

/// Muestra un [Money] con el formato de su moneda (§7.3).
///
/// Siempre usa cifras tabulares. El formato depende de la moneda, no del
/// idioma de la UI. Por semántica expone la forma hablada del monto
/// ("1.234.567 pesos colombianos").
class MoneyText extends StatelessWidget {
  /// Crea un texto de dinero.
  const MoneyText({
    required this.id,
    required this.money,
    this.size = MoneyTextSize.body,
    this.isPrice = false,
    this.abbreviated = false,
    this.signed = false,
    this.color,
    this.textAlign,
    super.key,
  });

  /// Identificador semántico y `Key` del valor.
  final String id;

  /// Monto a mostrar.
  final Money money;

  /// Tamaño tipográfico.
  final MoneyTextSize size;

  /// Usa las reglas de decimales de un precio de instrumento.
  final bool isPrice;

  /// Usa la forma abreviada de las vistas densas (`$ 1,2 M COP`).
  final bool abbreviated;

  /// Antepone `+` a los montos positivos (variaciones y movimientos).
  final bool signed;

  /// Color del texto; por defecto, el del rol tipográfico.
  final Color? color;

  /// Alineación del texto.
  final TextAlign? textAlign;

  /// Texto visible del monto.
  String get text {
    if (signed) {
      return Formatters.signedMoney(money);
    }
    if (isPrice) {
      return Formatters.price(money);
    }
    return Formatters.money(money, compact: abbreviated);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle? base = switch (size) {
      MoneyTextSize.display => textTheme.displayLarge,
      MoneyTextSize.large => textTheme.headlineMedium,
      MoneyTextSize.body => textTheme.titleMedium,
      MoneyTextSize.compact => textTheme.bodyMedium?.copyWith(
        color: textTheme.titleMedium?.color,
      ),
    };
    final SemanticLabels labels = SemanticLabelsScope.of(context);
    final String sign = money.isNegative ? '${Formatters.minusSign} ' : '';
    final Widget label = Text(
      text,
      maxLines: 1,
      softWrap: false,
      textAlign: textAlign,
      style: AppTypography.tabular(
        base ?? AppTypography.titleMedium,
      ).copyWith(color: color),
    );
    final bool isLarge =
        size == MoneyTextSize.display || size == MoneyTextSize.large;
    return Identified(
      id: id,
      label:
          '$sign${Formatters.amount(money)} '
          '${labels.currencyName(money.currency.code)}',
      replaceChildSemantics: true,
      child: isLarge
          ? FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: label,
            )
          : label,
    );
  }
}
