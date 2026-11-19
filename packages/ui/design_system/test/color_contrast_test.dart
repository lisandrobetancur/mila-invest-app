import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contraste WCAG 2.1 entre dos colores opacos.
double contrastRatio(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  const double normalText = 4.5;
  const double largeText = 3;

  for (final ThemeData theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
    final String name = theme.brightness.name;
    final ColorScheme scheme = theme.colorScheme;
    final MarketColors market = theme.market;

    group('contraste WCAG AA, tema $name', () {
      test('texto principal sobre surface y sobre el fondo', () {
        expect(
          contrastRatio(scheme.onSurface, scheme.surface),
          greaterThanOrEqualTo(normalText),
        );
        expect(
          contrastRatio(scheme.onSurface, theme.scaffoldBackgroundColor),
          greaterThanOrEqualTo(normalText),
        );
      });

      test('texto secundario sobre surface', () {
        expect(
          contrastRatio(scheme.onSurfaceVariant, scheme.surface),
          greaterThanOrEqualTo(normalText),
        );
      });

      test('ganancia y pérdida sobre surface', () {
        expect(
          contrastRatio(market.gain, scheme.surface),
          greaterThanOrEqualTo(normalText),
        );
        expect(
          contrastRatio(market.loss, scheme.surface),
          greaterThanOrEqualTo(normalText),
        );
      });

      test('ganancia y pérdida sobre su container (chips y destello)', () {
        expect(
          contrastRatio(market.gain, market.gainContainer),
          greaterThanOrEqualTo(normalText),
        );
        expect(
          contrastRatio(market.loss, market.lossContainer),
          greaterThanOrEqualTo(normalText),
        );
      });

      test('onPrimary sobre primary', () {
        expect(
          contrastRatio(scheme.onPrimary, scheme.primary),
          greaterThanOrEqualTo(normalText),
        );
      });

      test('onSecondary sobre secondary (badge "Simulado")', () {
        expect(
          contrastRatio(scheme.onSecondary, scheme.secondary),
          greaterThanOrEqualTo(normalText),
        );
      });

      test('error, aviso e info sobre surface', () {
        expect(
          contrastRatio(scheme.error, scheme.surface),
          greaterThanOrEqualTo(normalText),
        );
        expect(
          contrastRatio(market.warning, scheme.surface),
          greaterThanOrEqualTo(largeText),
        );
        expect(
          contrastRatio(market.info, scheme.surface),
          greaterThanOrEqualTo(normalText),
        );
      });
    });
  }

  group('MarketColors', () {
    test('lerp interpola entre claro y oscuro', () {
      final MarketColors half = MarketColors.light.lerp(MarketColors.dark, 0.5);

      expect(
        half.gain,
        Color.lerp(AppColors.gainLight, AppColors.gainDark, 0.5),
      );
      expect(MarketColors.light.lerp(null, 0.5), MarketColors.light);
    });

    test('elige color por signo', () {
      expect(MarketColors.light.foregroundFor(1), AppColors.gainLight);
      expect(MarketColors.light.foregroundFor(-1), AppColors.lossLight);
      expect(MarketColors.light.foregroundFor(0), AppColors.neutralLight);
      expect(MarketColors.light.containerFor(0), isNull);
    });
  });

  group('AppLayout', () {
    test('resuelve la clase de ancho por breakpoint', () {
      expect(AppLayout.forWidth(360), AppLayout.compact);
      expect(AppLayout.forWidth(768), AppLayout.medium);
      expect(AppLayout.forWidth(1440), AppLayout.expanded);
      expect(AppLayout.compact.dashboardColumns, 1);
      expect(AppLayout.medium.dashboardColumns, 2);
      expect(AppLayout.expanded.dashboardColumns, 3);
    });
  });

  group('AppDurations', () {
    test('instant colapsa todo a cero', () {
      expect(const AppDurations.instant().isInstant, isTrue);
      expect(
        const AppDurations().priceFlash,
        const Duration(milliseconds: 400),
      );
    });
  });
}
