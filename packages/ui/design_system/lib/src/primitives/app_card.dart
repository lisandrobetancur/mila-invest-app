import 'package:flutter/material.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

/// Tarjeta plana: superficie, borde fino de 1 px y sin sombra.
class AppCard extends StatelessWidget {
  /// Crea una tarjeta.
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    super.key,
  });

  /// Contenido de la tarjeta.
  final Widget child;

  /// Padding interno.
  final EdgeInsetsGeometry padding;

  /// Color de fondo; por defecto, `surface`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: scheme.outline),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
