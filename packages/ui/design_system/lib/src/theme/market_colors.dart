import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Colores semánticos de mercado (§10.2).
///
/// Viven en un `ThemeExtension` porque Material no tiene roles para
/// ganancia, pérdida ni estado de mercado.
@immutable
class MarketColors extends ThemeExtension<MarketColors> {
  /// Crea la extensión con todos sus roles.
  const MarketColors({
    required this.gain,
    required this.gainContainer,
    required this.loss,
    required this.lossContainer,
    required this.neutral,
    required this.marketOpen,
    required this.marketClosed,
    required this.warning,
    required this.info,
  });

  /// Colores del tema claro.
  static const MarketColors light = MarketColors(
    gain: AppColors.gainLight,
    gainContainer: AppColors.gainContainerLight,
    loss: AppColors.lossLight,
    lossContainer: AppColors.lossContainerLight,
    neutral: AppColors.neutralLight,
    marketOpen: AppColors.gainLight,
    marketClosed: AppColors.neutralLight,
    warning: AppColors.warningLight,
    info: AppColors.infoLight,
  );

  /// Colores del tema oscuro.
  static const MarketColors dark = MarketColors(
    gain: AppColors.gainDark,
    gainContainer: AppColors.gainContainerDark,
    loss: AppColors.lossDark,
    lossContainer: AppColors.lossContainerDark,
    neutral: AppColors.neutralDark,
    marketOpen: AppColors.gainDark,
    marketClosed: AppColors.neutralDark,
    warning: AppColors.warningDark,
    info: AppColors.infoDark,
  );

  /// Variación positiva.
  final Color gain;

  /// Fondo de chips positivos y del destello de precio al subir.
  final Color gainContainer;

  /// Variación negativa.
  final Color loss;

  /// Fondo de chips negativos y del destello de precio al bajar.
  final Color lossContainer;

  /// Variación cero.
  final Color neutral;

  /// Mercado abierto.
  final Color marketOpen;

  /// Mercado cerrado.
  final Color marketClosed;

  /// Avisos (mercado por cerrar, saldo bajo).
  final Color warning;

  /// Mensajes informativos.
  final Color info;

  /// Color de primer plano según el signo de una variación.
  ///
  /// [sign] es positivo, negativo o cero. El color nunca es el único
  /// indicador: quien lo usa agrega además signo y flecha.
  Color foregroundFor(int sign) {
    if (sign > 0) {
      return gain;
    }
    return sign < 0 ? loss : neutral;
  }

  /// Color de fondo (container) según el signo de una variación.
  Color? containerFor(int sign) {
    if (sign > 0) {
      return gainContainer;
    }
    return sign < 0 ? lossContainer : null;
  }

  @override
  MarketColors copyWith({
    Color? gain,
    Color? gainContainer,
    Color? loss,
    Color? lossContainer,
    Color? neutral,
    Color? marketOpen,
    Color? marketClosed,
    Color? warning,
    Color? info,
  }) => MarketColors(
    gain: gain ?? this.gain,
    gainContainer: gainContainer ?? this.gainContainer,
    loss: loss ?? this.loss,
    lossContainer: lossContainer ?? this.lossContainer,
    neutral: neutral ?? this.neutral,
    marketOpen: marketOpen ?? this.marketOpen,
    marketClosed: marketClosed ?? this.marketClosed,
    warning: warning ?? this.warning,
    info: info ?? this.info,
  );

  @override
  MarketColors lerp(ThemeExtension<MarketColors>? other, double t) {
    if (other is! MarketColors) {
      return this;
    }
    return MarketColors(
      gain: Color.lerp(gain, other.gain, t) ?? gain,
      gainContainer:
          Color.lerp(gainContainer, other.gainContainer, t) ?? gainContainer,
      loss: Color.lerp(loss, other.loss, t) ?? loss,
      lossContainer:
          Color.lerp(lossContainer, other.lossContainer, t) ?? lossContainer,
      neutral: Color.lerp(neutral, other.neutral, t) ?? neutral,
      marketOpen: Color.lerp(marketOpen, other.marketOpen, t) ?? marketOpen,
      marketClosed:
          Color.lerp(marketClosed, other.marketClosed, t) ?? marketClosed,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
    );
  }
}

/// Acceso corto a [MarketColors] desde un `ThemeData`.
extension MarketColorsTheme on ThemeData {
  /// Colores de mercado del tema, con el claro como respaldo.
  MarketColors get market => extension<MarketColors>() ?? MarketColors.light;
}
