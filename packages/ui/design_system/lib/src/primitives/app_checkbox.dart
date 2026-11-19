import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';
import 'identified.dart';

/// Checkbox con su texto, tocable en toda la fila.
class AppCheckbox extends StatelessWidget {
  /// Crea un checkbox con etiqueta.
  const AppCheckbox({
    required this.id,
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Identificador semántico y `Key` del checkbox.
  final String id;

  /// Texto que acompaña al checkbox.
  final String label;

  /// Estado actual.
  final bool value;

  /// Aviso de cambio.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ValueChanged<bool>? callback = onChanged;
    return Identified.control(
      id: id,
      child: InkWell(
        onTap: callback == null ? null : () => callback(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTouchTarget,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: value,
                onChanged: callback == null
                    ? null
                    : (bool? next) => callback(next ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
