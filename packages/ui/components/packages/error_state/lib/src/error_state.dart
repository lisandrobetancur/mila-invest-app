import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Estado de error de una vista: mensaje traducido + "Reintentar".
class ErrorState extends StatelessWidget {
  /// Crea un estado de error.
  const ErrorState({
    required this.id,
    required this.messageId,
    required this.message,
    required this.retryId,
    required this.retryLabel,
    required this.onRetry,
    this.icon = AppIcons.error,
    this.retrying = false,
    super.key,
  });

  /// Identificador semántico y `Key` de la raíz del estado.
  final String id;

  /// Identificador del mensaje de error.
  final String messageId;

  /// Mensaje ya traducido: qué pasó y qué hacer.
  final String message;

  /// Identificador del botón de reintentar.
  final String retryId;

  /// Texto del botón de reintentar.
  final String retryLabel;

  /// Acción de reintentar.
  final VoidCallback onRetry;

  /// Ícono; `AppIcons.offline` para errores de red.
  final IconData icon;

  /// Muestra el botón en estado de carga.
  final bool retrying;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
                  child: Icon(icon, size: 56, color: theme.colorScheme.error),
                ),
                const SizedBox(height: AppSpacing.md),
                Identified(
                  id: messageId,
                  liveRegion: true,
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  id: retryId,
                  label: retryLabel,
                  icon: AppIcons.refresh,
                  variant: AppButtonVariant.secondary,
                  loading: retrying,
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
