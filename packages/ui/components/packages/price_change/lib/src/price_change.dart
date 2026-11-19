import 'package:decimal/decimal.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

/// Variante visual de un [PriceChange].
enum PriceChangeVariant {
  /// Solo texto coloreado.
  text,

  /// Píldora con fondo `gainContainer` / `lossContainer`.
  chip,
}

/// Variación absoluta y/o porcentual.
///
/// Nunca comunica ganancia o pérdida solo con color: siempre lleva signo y
/// flecha (`▲ +2,35 %`). El cero se muestra neutro y sin flecha. Por
/// semántica expone la forma hablada ("sube 2,35 por ciento").
class PriceChange extends StatelessWidget {
  /// Crea una variación. Hace falta [percent], [amount] o los dos.
  const PriceChange({
    required this.id,
    required this.currency,
    this.percent,
    this.amount,
    this.variant = PriceChangeVariant.text,
    this.style,
    super.key,
  }) : assert(
         percent != null || amount != null,
         'PriceChange necesita percent, amount o los dos',
       );

  /// Identificador semántico y `Key` del valor.
  final String id;

  /// Moneda del instrumento o de la cuenta: define el separador decimal.
  final Currency currency;

  /// Variación porcentual (`2.35` es 2,35 %).
  final Decimal? percent;

  /// Variación absoluta.
  final Money? amount;

  /// Variante visual.
  final PriceChangeVariant variant;

  /// Estilo base del texto; por defecto, `labelLarge`.
  final TextStyle? style;

  /// Signo de la variación: positivo, negativo o cero.
  int get sign => (percent ?? amount?.amount ?? Decimal.zero).sign;

  /// Texto visible de la variación.
  String get text {
    final Decimal? pct = percent;
    final Money? absolute = amount;
    final String arrow = Formatters.arrow(
      pct ?? absolute?.amount ?? Decimal.zero,
    );
    final String body = switch ((absolute, pct)) {
      (final Money value, final Decimal rate) =>
        '${Formatters.signedMoney(value)} '
            '(${Formatters.percent(rate, currency: currency)})',
      (final Money value, null) => Formatters.signedMoney(value),
      (null, final Decimal rate) => Formatters.percent(
        rate,
        currency: currency,
      ),
      (null, null) => '',
    };
    return arrow.isEmpty ? body : '$arrow $body';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MarketColors market = theme.market;
    final Color foreground = market.foregroundFor(sign);
    final Widget label = Text(
      text,
      maxLines: 1,
      softWrap: false,
      style: AppTypography.tabular(
        style ?? AppTypography.labelLarge,
      ).copyWith(color: foreground),
    );
    return Identified(
      id: id,
      label: _spoken(SemanticLabelsScope.of(context)),
      replaceChildSemantics: true,
      child: switch (variant) {
        PriceChangeVariant.text => label,
        PriceChangeVariant.chip => DecoratedBox(
          decoration: BoxDecoration(
            color:
                market.containerFor(sign) ??
                theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.smAll,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            child: label,
          ),
        ),
      },
    );
  }

  String _spoken(SemanticLabels labels) {
    if (sign == 0) {
      return labels.unchanged;
    }
    final Decimal? pct = percent;
    final Money? absolute = amount;
    final List<String> parts = <String>[
      if (absolute != null)
        '${Formatters.amount(absolute)} '
            '${labels.currencyName(absolute.currency.code)}',
      if (pct != null)
        '${Formatters.percent(pct.abs(), currency: currency).replaceAll('+', '').replaceAll(' %', '')} '
            '${labels.percent}',
    ];
    return '${labels.verbFor(sign)} ${parts.join(', ')}';
  }
}
