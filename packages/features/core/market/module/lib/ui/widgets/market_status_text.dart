import 'package:authentication_typing/authentication_typing.dart';
import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_typing/market_typing.dart';
import 'package:typing/typing.dart';
import 'package:utilities/utilities.dart';

/// Chip del estado del mercado de un país.
///
/// "Abierto · cierra 4:00 p. m." / "Cerrado · abre lun 9:30 a. m.", con la
/// hora en la zona del país del usuario (§7.4).
class MarketStatusText extends ConsumerWidget {
  /// Crea el chip de [market].
  const MarketStatusText({
    required this.id,
    required this.market,
    this.showCountry = false,
    super.key,
  });

  /// Identificador semántico y `Key` del chip.
  final String id;

  /// Estado del mercado.
  final CountryMarket market;

  /// Antepone el código del país (en la lista, donde hay varios).
  final bool showCountry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Country zone =
        ref.watch(sessionProvider).user?.country ?? market.country;
    final String locale = context.languageCode;
    final String time = market.isOpen
        ? Formatters.time(market.closesAt, country: zone, locale: locale)
        : Formatters.weekdayTime(market.opensAt, country: zone, locale: locale);
    final String label = context.tr(
      market.isOpen ? 'market.status.open' : 'market.status.closed',
      namedArgs: <String, String>{'time': time},
    );
    return AppBadge(
      id: id,
      label: showCountry ? '${market.country.code} · $label' : label,
      icon: AppIcons.schedule,
      tone: market.isOpen ? AppBadgeTone.positive : AppBadgeTone.neutral,
    );
  }
}
