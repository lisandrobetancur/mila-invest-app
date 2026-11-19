import 'package:flutter/material.dart';

/// Tipografía de MILA Invest (§10.3).
///
/// Manrope para títulos y cifras grandes, Inter para el resto. Las dos son
/// fuentes variables empaquetadas como assets de este paquete, así que cada
/// rol declara el peso con `fontWeight` y con el eje `wght`.
abstract final class AppTypography {
  /// Familia de títulos y cifras grandes.
  static const String manrope = 'Manrope';

  /// Familia de cuerpo, etiquetas y cifras en listas.
  static const String inter = 'Inter';

  /// Paquete que declara las fuentes.
  static const String fontPackage = 'design_system';

  /// Feature de cifras tabulares: los números no "bailan" al cambiar.
  static const List<FontFeature> tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  /// Valor total del portafolio. Manrope 40 / 48, 700.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: manrope,
    package: fontPackage,
    fontSize: 40,
    height: 48 / 40,
    fontWeight: FontWeight.w700,
    fontVariations: <FontVariation>[FontVariation('wght', 700)],
    letterSpacing: -0.5,
  );

  /// Precio en el detalle de instrumento. Manrope 28 / 36, 700.
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: manrope,
    package: fontPackage,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    fontVariations: <FontVariation>[FontVariation('wght', 700)],
    letterSpacing: -0.25,
  );

  /// Títulos de pantalla. Manrope 20 / 28, 600.
  static const TextStyle titleLarge = TextStyle(
    fontFamily: manrope,
    package: fontPackage,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    fontVariations: <FontVariation>[FontVariation('wght', 600)],
  );

  /// Títulos de tarjeta y ticker en listas. Inter 16 / 24, 600.
  static const TextStyle titleMedium = TextStyle(
    fontFamily: inter,
    package: fontPackage,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    fontVariations: <FontVariation>[FontVariation('wght', 600)],
  );

  /// Texto general. Inter 16 / 24, 400.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: inter,
    package: fontPackage,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    fontVariations: <FontVariation>[FontVariation('wght', 400)],
  );

  /// Texto secundario y nombres de instrumento. Inter 14 / 20, 400.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: inter,
    package: fontPackage,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    fontVariations: <FontVariation>[FontVariation('wght', 400)],
  );

  /// Botones. Inter 14 / 20, 600.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: inter,
    package: fontPackage,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    fontVariations: <FontVariation>[FontVariation('wght', 600)],
  );

  /// Chips, badges y ejes del gráfico. Inter 12 / 16, 600, +0,2.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: inter,
    package: fontPackage,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    fontVariations: <FontVariation>[FontVariation('wght', 600)],
    letterSpacing: 0.2,
  );

  /// Devuelve [style] con cifras tabulares.
  static TextStyle tabular(TextStyle style) =>
      style.copyWith(fontFeatures: tabularFigures);

  /// `TextTheme` de Material con los roles de la tabla.
  ///
  /// Los roles que la tabla no define se derivan del más cercano, para que
  /// ningún widget nativo caiga en la tipografía por defecto.
  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) => TextTheme(
    displayLarge: displayLarge.copyWith(color: primary),
    displayMedium: headlineMedium.copyWith(color: primary, fontSize: 34),
    displaySmall: headlineMedium.copyWith(color: primary),
    headlineLarge: headlineMedium.copyWith(color: primary, fontSize: 32),
    headlineMedium: headlineMedium.copyWith(color: primary),
    headlineSmall: titleLarge.copyWith(color: primary, fontSize: 24),
    titleLarge: titleLarge.copyWith(color: primary),
    titleMedium: titleMedium.copyWith(color: primary),
    titleSmall: labelLarge.copyWith(color: primary),
    bodyLarge: bodyLarge.copyWith(color: primary),
    bodyMedium: bodyMedium.copyWith(color: secondary),
    bodySmall: bodyMedium.copyWith(color: secondary, fontSize: 12),
    labelLarge: labelLarge.copyWith(color: primary),
    labelMedium: labelSmall.copyWith(color: secondary),
    labelSmall: labelSmall.copyWith(color: secondary),
  );
}
