import 'package:flutter/material.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'identified.dart';

/// Un segmento de [AppSegmentedControl].
@immutable
class AppSegment<T> {
  /// Crea un segmento.
  const AppSegment({
    required this.id,
    required this.value,
    required this.label,
    this.selectedColor,
  });

  /// Identificador semántico y `Key` del segmento.
  final String id;

  /// Valor que representa.
  final T value;

  /// Texto del segmento.
  final String label;

  /// Color de fondo cuando está seleccionado; por defecto, `primary`.
  final Color? selectedColor;
}

/// Selector de una opción entre pocas, todas visibles.
///
/// Lleva un identificador en la raíz y uno por segmento.
class AppSegmentedControl<T> extends StatelessWidget {
  /// Crea un selector segmentado.
  const AppSegmentedControl({
    required this.id,
    required this.segments,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// Identificador semántico y `Key` de la raíz.
  final String id;

  /// Segmentos, en orden de presentación.
  final List<AppSegment<T>> segments;

  /// Valor seleccionado.
  final T selected;

  /// Aviso de cambio de selección.
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Identified(
      id: id,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: AppRadius.mdAll,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxs),
          child: Row(
            children: <Widget>[
              for (final AppSegment<T> segment in segments)
                Expanded(
                  child: _Segment<T>(
                    segment: segment,
                    isSelected: segment.value == selected,
                    onChanged: onChanged,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.segment,
    required this.isSelected,
    required this.onChanged,
  });

  final AppSegment<T> segment;
  final bool isSelected;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final ValueChanged<T>? callback = onChanged;
    final Color background = isSelected
        ? segment.selectedColor ?? scheme.primary
        : Colors.transparent;
    final Color foreground = isSelected ? scheme.onPrimary : scheme.onSurface;
    return Identified.control(
      id: segment.id,
      child: Semantics(
        button: true,
        selected: isSelected,
        inMutuallyExclusiveGroup: true,
        enabled: callback != null,
        child: Material(
          color: background,
          borderRadius: AppRadius.smAll,
          child: InkWell(
            onTap: callback == null ? null : () => callback(segment.value),
            borderRadius: AppRadius.smAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTouchTarget - AppSpacing.xs,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    segment.label,
                    textAlign: TextAlign.center,
                    style: AppTypography.labelLarge.copyWith(color: foreground),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
