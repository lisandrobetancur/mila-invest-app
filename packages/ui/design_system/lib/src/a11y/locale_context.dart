import 'package:flutter/widgets.dart';

/// Idioma de la UI, leído del árbol de widgets.
extension LocaleContext on BuildContext {
  /// Código del idioma de la UI (`es` / `en`).
  ///
  /// Se usa solo para los nombres de mes y el meridiano de las fechas: el
  /// formato de los montos depende del país de la moneda, no del idioma.
  String get languageCode => Localizations.localeOf(this).languageCode;
}
