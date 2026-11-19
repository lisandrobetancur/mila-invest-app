import 'package:flutter/material.dart';

import '../tokens/app_icons.dart';
import '../tokens/app_spacing.dart';
import 'identified.dart';

/// Tono de un snackbar.
enum AppSnackbarTone {
  /// Mensaje neutro.
  neutral,

  /// Operación exitosa.
  success,

  /// Error.
  error,
}

/// Helper para mostrar snackbars con identificador.
abstract final class AppSnackbar {
  /// Muestra [message], ya traducido, reemplazando el snackbar visible.
  static void show(
    BuildContext context, {
    required String id,
    required String message,
    AppSnackbarTone tone = AppSnackbarTone.neutral,
  }) {
    final ThemeData theme = Theme.of(context);
    final IconData? icon = switch (tone) {
      AppSnackbarTone.neutral => null,
      AppSnackbarTone.success => AppIcons.success,
      AppSnackbarTone.error => AppIcons.error,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Identified(
            id: id,
            liveRegion: true,
            child: Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(
                    icon,
                    size: 20,
                    color: theme.snackBarTheme.contentTextStyle?.color,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Expanded(child: Text(message)),
              ],
            ),
          ),
        ),
      );
  }
}
