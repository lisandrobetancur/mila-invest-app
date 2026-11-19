import 'package:country_chip/country_chip.dart';
import 'package:decimal/decimal.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:money_text/money_text.dart';
import 'package:price_change/price_change.dart';
import 'package:typing/typing.dart';

/// Fila de un instrumento: ticker, nombre, país, último precio y variación.
///
/// La raíz lleva el identificador del ítem (por ejemplo
/// `market_list_instrument_item_ECOPETROL-CO`) y cada parte verificable el
/// suyo, derivado del de la raíz.
class InstrumentTile extends StatelessWidget {
  /// Crea la fila de un instrumento.
  const InstrumentTile({
    required this.id,
    required this.ticker,
    required this.name,
    required this.country,
    required this.countryName,
    required this.price,
    required this.changePercent,
    required this.onTap,
    super.key,
  });

  /// Identificador semántico y `Key` del ítem.
  final String id;

  /// Ticker.
  final String ticker;

  /// Nombre del emisor.
  final String name;

  /// País del mercado.
  final Country country;

  /// Nombre del país, ya traducido.
  final String countryName;

  /// Último precio.
  final Money price;

  /// Variación porcentual del día.
  final Decimal changePercent;

  /// Acción al tocar la fila.
  final VoidCallback? onTap;

  /// Identificador del precio del ítem [itemId].
  static String priceIdOf(String itemId) => '${itemId}_price_text';

  /// Identificador de la variación del ítem [itemId].
  static String changeIdOf(String itemId) => '${itemId}_change_text';

  /// Identificador del país del ítem [itemId].
  static String countryIdOf(String itemId) => '${itemId}_country_text';

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    // Con el texto muy ampliado la fila pasa a dos líneas en vez de recortar
    // las cifras.
    final bool stacked = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final Widget identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Text(
                ticker,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            CountryChip(
              id: countryIdOf(id),
              country: country,
              name: countryName,
            ),
          ],
        ),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium,
        ),
      ],
    );
    final Widget figures = Column(
      crossAxisAlignment: stacked
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MoneyText(
          id: priceIdOf(id),
          money: price,
          isPrice: true,
          size: MoneyTextSize.compact,
        ),
        const SizedBox(height: AppSpacing.xxs),
        PriceChange(
          id: changeIdOf(id),
          currency: price.currency,
          percent: changePercent,
          variant: PriceChangeVariant.chip,
          style: AppTypography.labelSmall,
        ),
      ],
    );
    return AppTappable(
      id: id,
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                identity,
                const SizedBox(height: AppSpacing.xs),
                figures,
              ],
            )
          : Row(
              children: <Widget>[
                Expanded(child: identity),
                const SizedBox(width: AppSpacing.sm),
                figures,
              ],
            ),
    );
  }
}
