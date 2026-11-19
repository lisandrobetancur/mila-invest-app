import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Tarjeta de un indicador: etiqueta + cifra + variación opcional.
///
/// La cifra y la variación llegan como widgets (`MoneyText`, `PriceChange`)
/// con sus propios identificadores; el [id] es el de la tarjeta.
class StatTile extends StatelessWidget {
  /// Crea un indicador.
  const StatTile({
    required this.id,
    required this.label,
    required this.value,
    this.change,
    this.helper,
    this.framed = true,
    super.key,
  });

  /// Identificador semántico y `Key` de la tarjeta.
  final String id;

  /// Nombre del indicador.
  final String label;

  /// Cifra.
  final Widget value;

  /// Variación de la cifra.
  final Widget? change;

  /// Ayuda corta, para explicar jerga ("Ganancia o pérdida si vendieras
  /// hoy").
  final String? helper;

  /// Dibuja el marco de tarjeta. Sin marco sirve dentro de otra tarjeta.
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Widget? variation = change;
    final String? help = helper;
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xxs),
        value,
        if (variation != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xxs),
          variation,
        ],
        if (help != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xxs),
          Text(help, style: textTheme.bodySmall),
        ],
      ],
    );
    return Identified(
      id: id,
      child: framed ? AppCard(child: content) : content,
    );
  }
}
