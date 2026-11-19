import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Variante de un [DisclaimerBanner].
enum DisclaimerBannerVariant {
  /// Tarjeta con ícono, para onboarding y confirmación de orden.
  inline,

  /// Una línea de texto pequeño, para pies de pantalla.
  compact,
}

/// Aviso de simulación: "Simulación con fines educativos. No es asesoría
/// financiera".
class DisclaimerBanner extends StatelessWidget {
  /// Crea el aviso.
  const DisclaimerBanner({
    required this.id,
    required this.text,
    this.variant = DisclaimerBannerVariant.inline,
    super.key,
  });

  /// Identificador semántico y `Key` del aviso.
  final String id;

  /// Texto del aviso, ya traducido.
  final String text;

  /// Variante visual.
  final DisclaimerBannerVariant variant;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return switch (variant) {
      DisclaimerBannerVariant.compact => Identified(
        id: id,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ),
      DisclaimerBannerVariant.inline => DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: scheme.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExcludeSemantics(
                child: Icon(
                  AppIcons.simulated,
                  size: 20,
                  color: scheme.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Identified(
                  id: id,
                  child: Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    };
  }
}
