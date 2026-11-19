import 'package:flutter/material.dart';

import '../theme/market_colors.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import 'identified.dart';

/// Variante visual de un [AppButton].
enum AppButtonVariant {
  /// Acción principal de la pantalla.
  primary,

  /// Acción secundaria, con borde.
  secondary,

  /// Acción terciaria, solo texto.
  text,

  /// Comprar. Única excepción, junto con [sell], a "el color es solo
  /// significado": siempre va con texto explícito.
  buy,

  /// Vender.
  sell,
}

/// Botón de la app.
///
/// Mientras [loading] es `true` queda deshabilitado y muestra un indicador,
/// así un segundo toque no dispara otra petición.
class AppButton extends StatelessWidget {
  /// Crea un botón.
  const AppButton({
    required this.id,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expanded = false,
    super.key,
  });

  /// Identificador semántico y `Key` del botón.
  final String id;

  /// Texto del botón: la acción concreta ("Confirmar compra").
  final String label;

  /// Acción. Con `null` el botón queda deshabilitado.
  final VoidCallback? onPressed;

  /// Variante visual.
  final AppButtonVariant variant;

  /// Ícono opcional antes del texto.
  final IconData? icon;

  /// Muestra el indicador y deshabilita el botón.
  final bool loading;

  /// Ocupa todo el ancho disponible.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final VoidCallback? action = loading ? null : onPressed;
    final Widget content = _ButtonContent(
      label: label,
      icon: icon,
      loading: loading,
    );
    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: action,
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: action,
        child: content,
      ),
      AppButtonVariant.text => TextButton(onPressed: action, child: content),
      AppButtonVariant.buy => FilledButton(
        onPressed: action,
        style: _tradeStyle(theme, theme.market.gain),
        child: content,
      ),
      AppButtonVariant.sell => FilledButton(
        onPressed: action,
        style: _tradeStyle(theme, theme.market.loss),
        child: content,
      ),
    };
    return Identified.control(
      id: id,
      child: expanded
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }

  ButtonStyle _tradeStyle(ThemeData theme, Color background) =>
      FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: theme.brightness == Brightness.light
            ? AppColors.onPrimaryLight
            : AppColors.backgroundDark,
      );
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.loading,
  });

  final String label;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final Widget text = Flexible(
      child: Text(label, textAlign: TextAlign.center),
    );
    if (loading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.xs),
          text,
        ],
      );
    }
    if (icon == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[text],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 18),
        const SizedBox(width: AppSpacing.xs),
        text,
      ],
    );
  }
}

/// Botón de ícono con identificador y tooltip obligatorios.
///
/// Se usa para volver, cerrar y cualquier acción sin texto visible.
class AppIconButton extends StatelessWidget {
  /// Crea un botón de ícono.
  const AppIconButton({
    required this.id,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  /// Identificador semántico y `Key` del botón.
  final String id;

  /// Ícono, desde `AppIcons`.
  final IconData icon;

  /// Texto accesible del botón; se traduce.
  final String tooltip;

  /// Acción. Con `null` el botón queda deshabilitado.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Identified.control(
    id: id,
    child: IconButton(onPressed: onPressed, tooltip: tooltip, icon: Icon(icon)),
  );
}
