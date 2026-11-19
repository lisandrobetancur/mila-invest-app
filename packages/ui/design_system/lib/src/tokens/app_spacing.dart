/// Escala de espaciado de 4 pt y breakpoints (§10.4).
abstract final class AppSpacing {
  /// 4 pt.
  static const double xxs = 4;

  /// 8 pt.
  static const double xs = 8;

  /// 12 pt.
  static const double sm = 12;

  /// 16 pt.
  static const double md = 16;

  /// 24 pt.
  static const double lg = 24;

  /// 32 pt.
  static const double xl = 32;

  /// 48 pt.
  static const double xxl = 48;

  /// Padding de página en mobile.
  static const double pagePaddingMobile = 16;

  /// Padding de página desde el breakpoint web.
  static const double pagePaddingWeb = 24;

  /// Ancho máximo del contenido centrado.
  static const double maxContentWidth = 1200;

  /// Desde acá se usa navigation rail en vez de bottom bar.
  static const double webBreakpoint = 768;

  /// Desde acá el dashboard pasa a tres columnas.
  static const double wideBreakpoint = 1100;

  /// Área táctil mínima.
  static const double minTouchTarget = 48;
}
