import 'package:flutter/widgets.dart';

/// Palabras con las que los componentes arman sus etiquetas semánticas.
///
/// La etiqueta (`label`) es para personas y se traduce: "1.234.567 pesos
/// colombianos", "sube 2,35 por ciento". El design system y los componentes
/// no conocen el sistema de traducciones, así que el shell les entrega estas
/// palabras ya traducidas con un [SemanticLabelsScope].
@immutable
class SemanticLabels {
  /// Crea el juego de palabras.
  const SemanticLabels({
    required this.currencyNames,
    required this.rises,
    required this.falls,
    required this.unchanged,
    required this.percent,
  });

  /// Palabras en español: el idioma por defecto de la app.
  static const SemanticLabels spanish = SemanticLabels(
    currencyNames: <String, String>{
      'COP': 'pesos colombianos',
      'MXN': 'pesos mexicanos',
      'PEN': 'soles',
      'USD': 'dólares',
    },
    rises: 'sube',
    falls: 'baja',
    unchanged: 'sin cambio',
    percent: 'por ciento',
  );

  /// Nombre hablado de cada moneda, por código ISO 4217.
  final Map<String, String> currencyNames;

  /// Verbo de una variación positiva.
  final String rises;

  /// Verbo de una variación negativa.
  final String falls;

  /// Texto de una variación cero.
  final String unchanged;

  /// Cómo se dice `%`.
  final String percent;

  /// Nombre hablado de la moneda [code]; si no se conoce, el código.
  String currencyName(String code) => currencyNames[code] ?? code;

  /// Verbo para una variación de signo [sign].
  String verbFor(int sign) {
    if (sign > 0) {
      return rises;
    }
    return sign < 0 ? falls : unchanged;
  }
}

/// Entrega [SemanticLabels] traducidos al subárbol.
class SemanticLabelsScope extends InheritedWidget {
  /// Crea el scope.
  const SemanticLabelsScope({
    required this.labels,
    required super.child,
    super.key,
  });

  /// Palabras traducidas al idioma de la UI.
  final SemanticLabels labels;

  /// Palabras del scope más cercano, o las de español si no hay ninguno.
  static SemanticLabels of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<SemanticLabelsScope>()
          ?.labels ??
      SemanticLabels.spanish;

  @override
  bool updateShouldNotify(SemanticLabelsScope oldWidget) =>
      labels != oldWidget.labels;
}
