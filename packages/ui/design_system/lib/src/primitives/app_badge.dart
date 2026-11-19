import 'package:flutter/material.dart';

import '../theme/market_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'identified.dart';

/// Tono de un [AppBadge].
enum AppBadgeTone {
  /// Acento ámbar: el badge "Simulado".
  accent,

  /// Neutro.
  neutral,

  /// Positivo (orden ejecutada, mercado abierto).
  positive,

  /// Negativo (orden rechazada).
  negative,

  /// Aviso (orden pendiente).
  warning,

  /// Informativo.
  info,
}

/// Píldora de estado. Es un valor verificable, así que lleva identificador.
class AppBadge extends StatelessWidget {
  /// Crea un badge.
  const AppBadge({
    required this.id,
    required this.label,
    this.tone = AppBadgeTone.neutral,
    this.icon,
    super.key,
  });

  /// Identificador semántico y `Key` del badge.
  final String id;

  /// Texto del badge.
  final String label;

  /// Tono.
  final AppBadgeTone tone;

  /// Ícono opcional.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final MarketColors market = theme.market;
    final (Color background, Color foreground) = switch (tone) {
      AppBadgeTone.accent => (scheme.secondary, scheme.onSecondary),
      AppBadgeTone.neutral => (
        scheme.surfaceContainerHighest,
        scheme.onSurface,
      ),
      AppBadgeTone.positive => (market.gainContainer, market.gain),
      AppBadgeTone.negative => (market.lossContainer, market.loss),
      AppBadgeTone.warning => (scheme.surfaceContainerHighest, market.warning),
      AppBadgeTone.info => (scheme.surfaceContainerHighest, market.info),
    };
    return Identified(
      id: id,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.pillAll,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 14, color: foreground),
                const SizedBox(width: AppSpacing.xxs),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
