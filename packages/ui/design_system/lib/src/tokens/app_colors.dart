import 'package:flutter/material.dart';

/// Paleta de MILA Invest (§10.2).
///
/// El color se reserva para significado: ganancia, pérdida, acción principal
/// y estado de mercado. La jerarquía la dan el tamaño y el peso tipográfico.
abstract final class AppColors {
  /// Semilla del `ColorScheme`.
  static const Color seed = Color(0xFF16325C);

  /// Acciones principales, tab activa y links (claro).
  static const Color primaryLight = Color(0xFF16325C);

  /// Texto sobre `primary` (claro).
  static const Color onPrimaryLight = Color(0xFFFFFFFF);

  /// Acento puntual: badge "Simulado" (claro).
  static const Color secondaryLight = Color(0xFFC98A12);

  /// Texto sobre `secondary` (claro).
  static const Color onSecondaryLight = Color(0xFF2A1C00);

  /// Fondo de pantalla (claro).
  static const Color backgroundLight = Color(0xFFF6F7F9);

  /// Tarjetas y sheets (claro).
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Inputs, chips sin seleccionar y filas alternas (claro).
  static const Color surfaceVariantLight = Color(0xFFEEF1F5);

  /// Bordes de tarjetas y divisores (claro).
  static const Color outlineLight = Color(0xFFD5DAE1);

  /// Texto principal y cifras (claro).
  static const Color textPrimaryLight = Color(0xFF0E1726);

  /// Etiquetas y metadatos (claro).
  static const Color textSecondaryLight = Color(0xFF5B6575);

  /// Variación positiva (claro).
  static const Color gainLight = Color(0xFF127A45);

  /// Fondo de chips positivos y destello (claro).
  static const Color gainContainerLight = Color(0xFFE3F4EA);

  /// Variación negativa (claro).
  static const Color lossLight = Color(0xFFC2303A);

  /// Fondo de chips negativos y destello (claro).
  static const Color lossContainerLight = Color(0xFFFBE7E8);

  /// Variación cero (claro).
  static const Color neutralLight = Color(0xFF5B6575);

  /// Avisos (claro).
  static const Color warningLight = Color(0xFFB26A00);

  /// Errores (claro).
  static const Color errorLight = Color(0xFFB3261E);

  /// Texto sobre `error` (claro).
  static const Color onErrorLight = Color(0xFFFFFFFF);

  /// Mensajes informativos (claro).
  static const Color infoLight = Color(0xFF1F6FD1);

  /// Acciones principales, tab activa y links (oscuro).
  static const Color primaryDark = Color(0xFF9DBCF0);

  /// Texto sobre `primary` (oscuro).
  static const Color onPrimaryDark = Color(0xFF0B1A33);

  /// Acento puntual: badge "Simulado" (oscuro).
  static const Color secondaryDark = Color(0xFFF2C14E);

  /// Texto sobre `secondary` (oscuro).
  static const Color onSecondaryDark = Color(0xFF2A1C00);

  /// Fondo de pantalla (oscuro).
  static const Color backgroundDark = Color(0xFF0B1220);

  /// Tarjetas y sheets (oscuro).
  static const Color surfaceDark = Color(0xFF121A2B);

  /// Inputs, chips sin seleccionar y filas alternas (oscuro).
  static const Color surfaceVariantDark = Color(0xFF1A2438);

  /// Bordes de tarjetas y divisores (oscuro).
  static const Color outlineDark = Color(0xFF2A3550);

  /// Texto principal y cifras (oscuro).
  static const Color textPrimaryDark = Color(0xFFE7ECF3);

  /// Etiquetas y metadatos (oscuro).
  static const Color textSecondaryDark = Color(0xFF9AA6B8);

  /// Variación positiva (oscuro).
  static const Color gainDark = Color(0xFF34C77B);

  /// Fondo de chips positivos y destello (oscuro).
  static const Color gainContainerDark = Color(0xFF123323);

  /// Variación negativa (oscuro).
  static const Color lossDark = Color(0xFFFF6B6B);

  /// Fondo de chips negativos y destello (oscuro).
  static const Color lossContainerDark = Color(0xFF3A1619);

  /// Variación cero (oscuro).
  static const Color neutralDark = Color(0xFF9AA6B8);

  /// Avisos (oscuro).
  static const Color warningDark = Color(0xFFF5A524);

  /// Errores (oscuro).
  static const Color errorDark = Color(0xFFF2B8B5);

  /// Texto sobre `error` (oscuro).
  static const Color onErrorDark = Color(0xFF3A0A08);

  /// Mensajes informativos (oscuro).
  static const Color infoDark = Color(0xFF7FB2FF);
}
