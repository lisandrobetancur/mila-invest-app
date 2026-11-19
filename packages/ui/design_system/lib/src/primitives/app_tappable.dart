import 'package:flutter/material.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

/// Superficie tocable con identificador: ítems de lista y tarjetas-acción.
///
/// La raíz lleva el identificador, `isButton` y la acción de tap. A
/// diferencia de `Identified.control`, **no** funde a sus hijos: las partes
/// verificables de adentro conservan su propio nodo e identificador.
class AppTappable extends StatelessWidget {
  /// Crea una superficie tocable.
  const AppTappable({
    required this.id,
    required this.onTap,
    required this.child,
    this.semanticLabel,
    this.borderRadius = AppRadius.lgAll,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  /// Identificador semántico y `Key` de la raíz.
  final String id;

  /// Acción al tocar.
  final VoidCallback? onTap;

  /// Contenido.
  final Widget child;

  /// Etiqueta accesible de la raíz; se traduce.
  final String? semanticLabel;

  /// Radio del efecto de tinta.
  final BorderRadius borderRadius;

  /// Padding interno.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => KeyedSubtree(
    key: ValueKey<String>(id),
    child: Semantics(
      identifier: id,
      container: true,
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    ),
  );
}
