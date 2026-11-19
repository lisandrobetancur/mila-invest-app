import 'package:flutter/widgets.dart';

/// Pone `Semantics.identifier` y `Key` a un subárbol, desde el mismo string.
///
/// Es el único lugar del design system donde se aplica un identificador
/// (§11.1). El `id` llega como `String` porque el design system no conoce
/// los `<Feature>Ids`.
///
/// Hay tres formas, según dónde tenga que quedar el identificador:
///
/// * [Identified.new], para raíces de vista y de estado, ítems de lista y
///   valores verificables: crea un nodo propio (`container: true`), así los
///   nodos identificados de adentro conservan el suyo.
/// * [Identified.control], para controles nativos (botones, chips,
///   checkboxes): funde el identificador con el nodo que el control ya
///   expone, de modo que el mismo nodo tenga el identificador, `isButton` y
///   la acción de tap. Su subárbol no puede contener otros identificadores.
/// * [Identified.field], para campos de texto: anota el nodo que ya tiene
///   `isTextField` sin fundir a sus hijos, así el mensaje de error y el
///   botón de mostrar/ocultar conservan su propio identificador.
class Identified extends StatelessWidget {
  /// Identifica un contenedor o un valor con un nodo propio.
  const Identified({
    required this.id,
    required this.child,
    this.label,
    this.value,
    this.liveRegion = false,
    this.replaceChildSemantics = false,
    super.key,
  }) : _mode = _IdentifiedMode.container;

  /// Identifica un control nativo fundiéndose con su nodo accionable.
  const Identified.control({required this.id, required this.child, super.key})
    : _mode = _IdentifiedMode.control,
      label = null,
      value = null,
      liveRegion = false,
      replaceChildSemantics = false;

  /// Identifica un campo de texto anotando su propio nodo.
  const Identified.field({required this.id, required this.child, super.key})
    : _mode = _IdentifiedMode.field,
      label = null,
      value = null,
      liveRegion = false,
      replaceChildSemantics = false;

  /// Identificador estable. Sale siempre de una constante de `<Feature>Ids`.
  final String id;

  /// Subárbol identificado.
  final Widget child;

  /// Etiqueta para personas; se traduce. Se suma a la del subárbol salvo
  /// que [replaceChildSemantics] sea `true`.
  final String? label;

  /// Valor accesible del nodo (por ejemplo, un monto ya formateado).
  final String? value;

  /// Anuncia los cambios a los lectores de pantalla (errores, resultados).
  final bool liveRegion;

  /// Usa solo [label] y [value], descartando la semántica del subárbol.
  ///
  /// Sirve para valores cuyo texto visible no es el que conviene leer en
  /// voz alta (`$ 1.234.567 COP` → "1.234.567 pesos colombianos"). El
  /// subárbol no puede contener otros identificadores.
  final bool replaceChildSemantics;

  final _IdentifiedMode _mode;

  @override
  Widget build(BuildContext context) => KeyedSubtree(
    key: ValueKey<String>(id),
    child: switch (_mode) {
      _IdentifiedMode.container => Semantics(
        identifier: id,
        container: true,
        label: label,
        value: value,
        liveRegion: liveRegion,
        excludeSemantics: replaceChildSemantics,
        child: child,
      ),
      _IdentifiedMode.control => MergeSemantics(
        child: Semantics(identifier: id, child: child),
      ),
      _IdentifiedMode.field => Semantics(identifier: id, child: child),
    },
  );
}

enum _IdentifiedMode { container, control, field }
