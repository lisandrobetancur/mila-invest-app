import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Acción de un [EmptyState].
@immutable
class EmptyStateAction {
  /// Crea la acción.
  const EmptyStateAction({
    required this.id,
    required this.label,
    required this.onPressed,
  });

  /// Identificador semántico y `Key` del botón.
  final String id;

  /// Texto del botón: la acción concreta ("Explorar mercado").
  final String label;

  /// Acción.
  final VoidCallback onPressed;
}

/// Estado vacío: un ícono de línea grande, un título y un botón.
///
/// Sin ilustraciones de stock.
class EmptyState extends StatelessWidget {
  /// Crea un estado vacío.
  const EmptyState({
    required this.id,
    required this.titleId,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    super.key,
  });

  /// Identificador semántico y `Key` de la raíz del estado.
  final String id;

  /// Identificador del título, que es un valor verificable.
  final String titleId;

  /// Ícono, desde `AppIcons`.
  final IconData icon;

  /// Título.
  final String title;

  /// Texto de apoyo.
  final String? message;

  /// Acción opcional.
  final EmptyStateAction? action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? body = message;
    final EmptyStateAction? button = action;
    return Identified(
      id: id,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ExcludeSemantics(
                  child: Icon(
                    icon,
                    size: 56,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Identified(
                  id: titleId,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                if (body != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                if (button != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    id: button.id,
                    label: button.label,
                    onPressed: button.onPressed,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
