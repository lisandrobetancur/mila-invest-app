import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../tokens/app_radius.dart';

/// Efecto de carga. Existe solo mientras una vista está en `loading`.
///
/// Si el sistema pide no animar (`MediaQuery.disableAnimations`, que es lo
/// que activan `FAST_ANIMATIONS` y los tests), muestra los bloques quietos:
/// así no queda ninguna animación infinita corriendo.
class AppShimmer extends StatelessWidget {
  /// Envuelve [child] (bloques [AppShimmerBox]) con el efecto.
  const AppShimmer({required this.child, super.key});

  /// Bloques de carga.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Widget content = ExcludeSemantics(child: child);
    if (MediaQuery.disableAnimationsOf(context)) {
      return content;
    }
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surface,
      child: content,
    );
  }
}

/// Bloque rectangular de un [AppShimmer].
class AppShimmerBox extends StatelessWidget {
  /// Crea un bloque de carga.
  const AppShimmerBox({
    this.width,
    this.height = 16,
    this.radius = AppRadius.sm,
    super.key,
  });

  /// Ancho; `null` ocupa todo el disponible.
  final double? width;

  /// Alto.
  final double height;

  /// Radio de las esquinas.
  final double radius;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    ),
  );
}
