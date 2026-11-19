import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:typing/typing.dart';

/// Píldora con el código de un país (`CO` / `MX` / `PE`).
///
/// No usa banderas emoji: se ven distinto en cada plataforma. El nombre del
/// país va en el tooltip y en la semántica.
class CountryChip extends StatelessWidget {
  /// Crea la píldora de [country].
  const CountryChip({
    required this.id,
    required this.country,
    required this.name,
    super.key,
  });

  /// Identificador semántico y `Key` de la píldora.
  final String id;

  /// País.
  final Country country;

  /// Nombre del país, ya traducido.
  final String name;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Identified(
      id: id,
      label: name,
      replaceChildSemantics: true,
      child: Tooltip(
        message: name,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillAll,
            border: Border.all(color: scheme.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            child: Text(
              country.code,
              style: AppTypography.labelSmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
