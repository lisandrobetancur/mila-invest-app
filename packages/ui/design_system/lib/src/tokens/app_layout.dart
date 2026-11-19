import 'package:flutter/widgets.dart';

import 'app_spacing.dart';

/// Clase de ancho de la ventana.
enum AppLayout {
  /// Menos de 768 px: bottom navigation bar, una columna.
  compact,

  /// Desde 768 px: navigation rail, dos columnas.
  medium,

  /// Desde 1100 px: tres columnas en el dashboard.
  expanded;

  /// Clase de ancho para [width].
  static AppLayout forWidth(double width) {
    if (width >= AppSpacing.wideBreakpoint) {
      return AppLayout.expanded;
    }
    return width >= AppSpacing.webBreakpoint
        ? AppLayout.medium
        : AppLayout.compact;
  }

  /// Clase de ancho de la ventana de [context].
  static AppLayout of(BuildContext context) =>
      forWidth(MediaQuery.sizeOf(context).width);

  /// `true` por debajo del breakpoint web.
  bool get isCompact => this == AppLayout.compact;

  /// `true` desde el breakpoint web.
  bool get isWide => this != AppLayout.compact;

  /// Padding horizontal de página para esta clase de ancho.
  double get pagePadding =>
      isCompact ? AppSpacing.pagePaddingMobile : AppSpacing.pagePaddingWeb;

  /// Columnas de la grilla del dashboard.
  int get dashboardColumns => switch (this) {
    AppLayout.compact => 1,
    AppLayout.medium => 2,
    AppLayout.expanded => 3,
  };
}
