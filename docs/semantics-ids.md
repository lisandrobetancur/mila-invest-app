# Inventario de identificadores semánticos

Contrato público para automatización black-box (§11.1 del prompt de
arquitectura). Se actualiza en el **mismo PR** que agrega o cambia un id.
Renombrar un id existente rompe el contrato y se anota aquí.

Fuente única: `<feature>_constants/lib/<feature>_ids.dart` y, en el shell,
`shell_ids.dart`. La `Key` de un widget es `ValueKey<String>(<id>)` con el
mismo string.

| Plataforma | Atributo expuesto |
|---|---|
| Android | `resource-id` |
| iOS | `accessibilityIdentifier` |
| Web | `flt-semantics-identifier` (requiere `ENABLE_SEMANTICS=true`) |

Convención: la parte estática cumple `^[a-z][a-z0-9]*(_[a-z0-9]+)*$`; la parte
dinámica es el id de la entidad tal como lo da la API
(`market_instrument_item_ECOPETROL-CO`), nunca un índice ni texto traducido.

<!-- Las tablas por feature se completan junto con cada feature. -->
