import 'package:flutter/material.dart';

import 'identified.dart';

/// Chip de filtro seleccionable.
class AppChip extends StatelessWidget {
  /// Crea un chip de filtro.
  const AppChip({
    required this.id,
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  /// Identificador semántico y `Key` del chip.
  final String id;

  /// Texto del chip.
  final String label;

  /// `true` si el filtro está activo.
  final bool selected;

  /// Aviso de cambio de selección.
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) => Identified.control(
    id: id,
    child: FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    ),
  );
}
