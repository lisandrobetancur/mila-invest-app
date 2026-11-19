import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shell_ids.dart';
import 'shell_locations.dart';

/// "No encontrado": destino de cualquier ruta desconocida. Nunca una
/// pantalla en blanco.
class NotFoundView extends StatelessWidget {
  /// Crea la vista.
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AppScaffold(
      id: ShellIds.notFoundView,
      maxWidth: 480,
      body: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxl),
        child: Column(
          children: <Widget>[
            ExcludeSemantics(
              child: Icon(
                AppIcons.notFound,
                size: 56,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Identified(
              id: ShellIds.notFoundTitleText,
              child: Text(
                context.tr('shell.not_found.title'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.tr('shell.not_found.body'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              id: ShellIds.notFoundHomeButton,
              label: context.tr('shell.not_found.home'),
              onPressed: () => context.go(ShellLocations.home),
            ),
          ],
        ),
      ),
    );
  }
}
