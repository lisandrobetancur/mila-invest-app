import 'package:flutter/material.dart';

import '../theme/market_colors.dart';
import '../tokens/app_icons.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import 'identified.dart';

/// Tono de un [AppBanner].
enum AppBannerTone {
  /// Informativo.
  info,

  /// Aviso.
  warning,

  /// Error.
  error,

  /// Éxito.
  success,
}

/// Mensaje en línea dentro de una vista (errores de formulario, avisos).
///
/// Es un valor verificable y un mensaje de error, así que lleva
/// identificador y se anuncia a los lectores de pantalla.
class AppBanner extends StatelessWidget {
  /// Crea un banner.
  const AppBanner({
    required this.id,
    required this.message,
    this.tone = AppBannerTone.info,
    this.action,
    super.key,
  });

  /// Identificador semántico y `Key` del banner.
  final String id;

  /// Mensaje ya traducido: qué pasó y qué hacer.
  final String message;

  /// Tono.
  final AppBannerTone tone;

  /// Acción opcional (por ejemplo, un `AppButton` "Reintentar").
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MarketColors market = theme.market;
    final (Color color, IconData icon) = switch (tone) {
      AppBannerTone.info => (market.info, AppIcons.info),
      AppBannerTone.warning => (market.warning, AppIcons.warning),
      AppBannerTone.error => (theme.colorScheme.error, AppIcons.error),
      AppBannerTone.success => (market.gain, AppIcons.success),
    };
    final Widget? trailing = action;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Identified(
                    id: id,
                    liveRegion: true,
                    child: Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (trailing != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    trailing,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
