import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Duraciones de animación (§10.4).
///
/// No son estáticas: se inyectan por [durationsProvider], así los tests y
/// los builds con `FAST_ANIMATIONS` las colapsan a cero.
@immutable
class AppDurations {
  /// Duraciones normales.
  const AppDurations({
    this.fast = const Duration(milliseconds: 120),
    this.normal = const Duration(milliseconds: 200),
    this.slow = const Duration(milliseconds: 320),
    this.priceFlash = const Duration(milliseconds: 400),
  });

  /// Todas las duraciones en cero.
  const AppDurations.instant()
    : fast = Duration.zero,
      normal = Duration.zero,
      slow = Duration.zero,
      priceFlash = Duration.zero;

  /// Curva única de la app.
  static const Curve curve = Curves.easeOutCubic;

  /// Transiciones cortas (hover, color de un chip).
  final Duration fast;

  /// Transiciones normales (aparición de contenido).
  final Duration normal;

  /// Transiciones largas (sheets, páginas).
  final Duration slow;

  /// Destello del precio cuando cambia.
  final Duration priceFlash;

  /// `true` si todo está en cero.
  bool get isInstant => normal == Duration.zero;

  /// Devuelve duraciones en cero si el sistema pide no animar.
  AppDurations resolve(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? const AppDurations.instant()
      : this;
}

/// Provider de las duraciones de la app.
final Provider<AppDurations> durationsProvider = Provider<AppDurations>(
  (Ref ref) => const AppDurations(),
);
