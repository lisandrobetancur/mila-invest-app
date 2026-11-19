# Auditoría — exposición a los problemas de semantics en Flutter web

Fecha: 2026-11-19 · Commit auditado: `e5ec0e3` (`main`) · Alcance: solo lectura de código.
No se modificó código de producción ni se ejecutó la app en un navegador.

Rutas relativas a la raíz del repo. Las referencias `engine:` y `framework:` apuntan al SDK
instalado en esta máquina (`~/fvm/versions/3.41.9`), que es la misma versión que fija el CI:

- `engine:` = `engine/src/flutter/lib/web_ui/lib/src/engine/`
- `framework:` = `packages/flutter/lib/src/`

## Resumen

| | |
|---|---|
| Problemas con el patrón PRESENTE | **P3, P4, P5, P6, P7** |
| PARCIAL | **P2, P8** |
| AUSENTE | **P1** |
| Hallazgo que condiciona el entregable B | **No existe ninguna suite de Playwright** en este repo (ni en el directorio hermano `../app_demo`). Ver §4. |
| Control "árbol apagado" | **Disponible**: el árbol solo se enciende con un `--dart-define`. Con salvedades (§1.5). |

---

## 1. Terreno (Fase 1)

### 1.1 Versión de Flutter y Dart

| Fuente | Valor | Archivo |
|---|---|---|
| CI | Flutter `3.41.9`, canal `stable` | `.github/workflows/ci.yml:19-20` |
| README | Flutter `3.41.9`, Dart `3.11.5` | `README.md:12` |
| `pubspec` (root y app) | `sdk: ^3.11.5` (solo Dart, sin restricción de Flutter) | `pubspec.yaml:7`, `packages/apps/mila_invest_app/pubspec.yaml:8` |
| `pubspec.lock` | `dart: ">=3.11.5 <4.0.0"`, `flutter: ">=3.38.4"` | `pubspec.lock:862-863` |
| `.metadata` | revisión `00b0c91f06…` (= framework de 3.41.9) | `packages/apps/mila_invest_app/.metadata:7` |
| Máquina local | Flutter `3.41.9`, Dart `3.11.5`, engine `42d3d75a56` (vía `fvm` global) | `flutter --version` |
| `.fvmrc` / `.tool-versions` | **no existen** | — |

Las fuentes **coinciden** en 3.41.9 / 3.11.5. La salvedad: fuera del CI nada obliga a esa versión.
No hay `.fvmrc`, y el lockfile acepta cualquier Flutter `>=3.38.4`. Hoy la máquina local coincide
solo porque el default global de `fvm` es 3.41.9. Como estos problemas son del motor web y cambian
entre versiones, conviene que quien corra las mediciones registre `flutter --version` en el informe.

### 1.2 ¿Se enciende el árbol de semantics?

Sí, **solo** con un dart-define de compilación:

- `packages/apps/mila_invest_app/lib/config/app_config.dart:50` — `enableSemantics: const bool.fromEnvironment('ENABLE_SEMANTICS')`.
- `packages/apps/mila_invest_app/lib/main.dart:19-23` — si es `true`, `SemanticsBinding.instance.ensureSemantics()` antes de `runApp`, y el handle se retiene de por vida (`qaSemanticsHandle`).
- No hay query param ni código propio que lo encienda de otra forma (grep de `ensureSemantics` en `packages/`: única coincidencia fuera de tests).
- Ninguna de las 104 dependencias de terceros resueltas llama a `ensureSemantics`.

Sin el define, el árbol arranca **apagado** y queda el placeholder estándar del motor
(`flt-semantics-placeholder`, botón "Enable accessibility" — `engine:semantics/semantics_helper.dart:187`).
Un click sobre ese placeholder enciende el árbol en caliente. O sea: un usuario real con lector de
pantalla **sí** termina con el árbol encendido en un build de producción.

### 1.3 ¿El build de pruebas y el de producción son el mismo artefacto?

**No, por diseño.** `ENABLE_SEMANTICS` es una constante de compilación: el build de QA
(`--dart-define=ENABLE_SEMANTICS=true`) y el de producción (sin el define) son binarios distintos.
`docs/semantics-ids.md:18` lo documenta como requisito para que existan los
`flt-semantics-identifier` en web.

Además, **el repo no define ningún build web**: el CI solo corre `melos run lint` y
`melos run test` (`.github/workflows/ci.yml:22-25`); no hay `flutter build web`, ni deploy, ni
job de navegador. "Build de producción" hoy es lo que alguien compile a mano.

Consecuencia para las mediciones: lo que se observe en el build de QA no describe al build de
producción para un usuario sin tecnología asistiva, y sí describe (aproximadamente) al usuario
con lector de pantalla.

### 1.4 ¿CanvasKit o wasm?

**dart2js + CanvasKit** (el default de `flutter build web`). Evidencia:

- Ningún `--wasm` en el repo (grep de `wasm|canvaskit|skwasm|web-renderer` en `.dart/.yml/.md/.html/.py/.json`: sin coincidencias propias).
- `packages/apps/mila_invest_app/web/index.html:44` usa el `flutter_bootstrap.js` estándar, sin configuración de renderer.
- El build local existente (`packages/apps/mila_invest_app/build/web`, no versionado) declara
  `"compileTarget":"dart2js","renderer":"canvaskit"` y no contiene `main.dart.wasm`.

No está fijado en CI porque el CI no compila web.

### 1.5 ¿Se puede correr la app con el árbol apagado?

**Sí.** Compilar sin `ENABLE_SEMANTICS` da el control. Cuatro salvedades que hay que respetar o
el control deja de serlo:

1. **Con el árbol apagado no hay `flt-semantics-identifier` en el DOM.** Los ids son el único
   contrato de automatización del proyecto (`docs/decisions.md` §13). Una suite que localice por
   id no puede correr en OFF sin otra estrategia (coordenadas tomadas de la corrida ON, teclado).
2. **El placeholder enciende el árbol.** En OFF, la suite no puede hacerle click ni activarlo
   con teclado; un `getByRole('button')` genérico lo puede encontrar.
3. **El build local existente no sirve como referencia**: no se puede saber leyendo
   `main.dart.js` con qué defines se compiló. Hay que recompilar ambos.
4. **`FAST_ANIMATIONS` y `PRICE_REFRESH_SECONDS` cambian tiempos** (`README.md:64-65`). Tienen
   que ser idénticos en ON y OFF, o las diferencias de tiempo (P3, P6) no son atribuibles.

---

## 2. Patrones de riesgo (Fase 2)

Antes de la tabla, los mecanismos tal como están en el motor de **esta** versión. Los verifiqué
en el código del SDK 3.41.9 para no auditar contra un comportamiento de otra versión:

| # | Dónde está en 3.41.9 |
|---|---|
| P1 | El `<input>` semántico escucha `click` solo para enfocarse y **no detiene la propagación** (`engine:semantics/text_field.dart:300-305`). Cada nodo tappable escucha `click` en su elemento (`engine:semantics/tappable.dart:47-50`) y, si no hubo `pointerdown` previo, lo convierte en tap (`engine:pointer_binding.dart:273`, rama `!isDebouncing`). |
| P3 | El campo se "activa" recién cuando llega una actualización de semantics con `hasFocus` (`engine:semantics/text_field.dart:323-330`); el `focus` del DOM solo manda `SemanticsAction.focus` al framework y espera la vuelta (`:287-299`). |
| P4 | El scroll del DOM se reenvía como `SemanticsAction.scrollToOffset` con el `scrollTop` crudo (`engine:semantics/scrollable.dart:55-89`). |
| P5 | El tap sale como `invokeOnSemanticsAction(viewId, semanticsNodeId, SemanticsAction.tap)` — por id, sin coordenadas (`engine:pointer_binding.dart:313-317`). |
| P6 | `pointerdown` sobre un elemento con `flt-tappable` arranca un debounce (`engine:pointer_binding.dart:336`) de **200 ms** (`:389`) durante el que los eventos de puntero se encolan. Solo con semantics encendido (`:246`). |
| P7 | `pointer-events: all` o `none` según el rol (`engine:semantics/semantics.dart:1957-1960`); en modo `defer` solo lo aceptan los comportamientos que devuelven `shouldAcceptPointerEvents` (`:635-650`): `Tappable`, `SemanticTextField`, `SemanticIncrementable`. |
| P8 | Al fusionar, el primer identifier gana: `if (_identifier == '') _identifier = child._identifier` (`framework:semantics/semantics.dart:6754-6756`). |
| P2 | **No pude ubicar el mecanismo leyendo.** El foco de `flutter-view` se mueve en `engine:platform_dispatcher/view_focus_binding.dart:41-52`, pero qué secuencia lo dispara desde un `TextFieldTapRegion` requiere ejecutar (ver P2 abajo). |

Novedad de esta versión que afecta a P5/P7: existe `SemanticsHitTestBehavior` y los diálogos y
bottom sheets de Material lo usan (`framework:material/dialog.dart`, `material/bottom_sheet.dart`),
así que sus superficies son opacas a punteros en el DOM. Lo que se sepa de versiones anteriores
sobre modales puede no aplicar.

### 2.1 Tabla

| # | Estado | Evidencia | Flujo afectado | A quién afectaría |
|---|---|---|---|---|
| **P1** | **AUSENTE** | Ningún campo tiene un ancestro que capture taps. Los únicos 4 `InkWell` del repo no contienen campos: `app_tappable.dart:52`, `app_segmented_control.dart:116`, `app_checkbox.dart:34`, `app_navigation_shell.dart:124`. Cero `GestureDetector`, `onTapOutside`, `unfocus`, `FocusScope`. | — | Nadie |
| **P2** | **PARCIAL** | Sin uso propio ni de terceros. Pero todo `TextField` es por dentro un `TextFieldTapRegion` (`framework:material/text_field.dart:1789`, `widgets/editable_text.dart:5712`), y hay tappables **encima o pegados** a campos que quedan fuera de esa región: sufijo superpuesto `app_text_field.dart:179-185` (usado en `login_view.dart:94`, `register_view.dart:154`, `market_list_header.dart:47`), steppers `order_ticket_data.dart:90,109`, chips de monto `deposit_view.dart:173`. | Login y registro (mostrar/ocultar contraseña), búsqueda de mercado (limpiar), ticket (±), depósito (sugeridos) | A determinar; si aparece, ambos |
| **P3** | **PRESENTE** | Los 9 campos de la app, todos vía `app_text_field.dart:149`: `login_view.dart:71,82` · `register_view.dart:95,105,135,147` · `market_list_header.dart:39` · `deposit_view.dart:151` · `order_ticket_data.dart:97`. Foco encadenado con `TextInputAction.next`: `login_view.dart:76`, `register_view.dart:99,109,141`. | Login (email ⏎ contraseña), registro, búsqueda de instrumentos, monto del depósito, cantidad del ticket | **Ambos**: automatización siempre (escribe apenas enfoca); usuario real con el árbol encendido al tipear rápido tras ⏎/Tab o al abrir un modal |
| **P4** | **PRESENTE** | Scrollables con campo adentro: `app_scaffold.dart:91` (login, registro) · `market_list_view.dart:91-103` (buscador en `SliverToBoxAdapter`) · `deposit_view.dart:83` · `order_ticket_view.dart:46`. Scrollables con otros nodos propios: todos los demás (`movements_view.dart:85`, `orders_history_view.dart:70`, y cada vista con `AppScaffold`). | Registro (formulario largo), lista de mercado, ticket y depósito en viewport chico, y cualquier vista con scroll | **Ambos**: usuario con el árbol encendido (rueda / trackpad); automatización (`scrollIntoView`, `mouse.wheel`) |
| **P5** | **PRESENTE** | Cuatro formas, detalladas en §2.2: (a) tappables fuera del viewport que siguen en el árbol — `app_scaffold.dart:91`, `deposit_view.dart:83`, `order_ticket_view.dart:46`; (b) snackbar flotante sobre contenido tappable — `app_theme.dart:264` + `deposit_view.dart:65-74`; (c) botón superpuesto al campo — `app_text_field.dart:179-185`; (d) modales sobre páginas — `app_route.dart:133,147`, `settings_view.dart:29`, con la excepción de `app_navigation_shell.dart:69`. | Registro ("Crear cuenta" bajo el pliegue), depósito → vuelta a billetera/inicio, contraseña y búsqueda, ticket y depósito abiertos sobre el detalle o la billetera, diálogo de logout | **Solo automatización** en (a) y (d): falsos verdes. **Ambos** en (b) y (c) si el orden del DOM difiere del pintado |
| **P6** | **PRESENTE** | Listas de ítems tappables (`AppTappable`, `app_tappable.dart:44-62`): `market_list_data.dart:25` · `home_data.dart:140` · `movements_data.dart:111` · `orders_history_data.dart:73` · `overview_data.dart:191`. Filas de chips: `market_list_header.dart:64-83`, `movements_view.dart:122,138`. | Lista de mercado (casi toda la superficie es tappable), inicio, Actividad, historial de órdenes, portafolio | **Ambos** con el árbol encendido: el usuario nota el retardo del tap y el scroll que no arranca; la automatización ve tiempos distintos a OFF |
| **P7** | **PRESENTE** (inherente) | Interacciones de la app que **no** son tap, campo ni slider: tooltip táctil del gráfico `price_chart.dart:111-114,174` (en `instrument_detail_parts.dart:175`, bajo un nodo con `replaceChildSemantics`) · pull-to-refresh `app_scaffold.dart:96-98` (7 vistas) · arrastre del bottom sheet para cerrar (`app_route.dart:147`, `app_theme.dart:259`) · tap fuera del modal · tooltip por hover `country_chip.dart:34`. No hay sliders ni switches (grep). | Detalle de instrumento (gráfico), refresco en inicio/mercado/portafolio/actividad/billetera, cierre de modales | **Solo automatización** (el puntero real atraviesa los nodos inertes y llega al canvas). También todo nodo `*_text`, `*_view`, `*_state_*`: se pueden leer, no accionar |
| **P8** | **PARCIAL** | El patrón está en todos lados y es deliberado: `identified.dart:90-95` (`MergeSemantics` en `.control` y `.field`), contenedores anidados en cada vista. Está mitigado por diseño (`identified.dart:9-23`, `app_text_field.dart:9-15`) y cubierto por tests de widget. La duda en §2.2. | Cualquier vista | **Solo automatización** (un id que falta); usuario no |

### 2.2 Detalle por problema

#### P1 — AUSENTE

Qué busqué para concluirlo:

- `GestureDetector|InkWell|InkResponse|RawGestureDetector|Listener|Dismissible|TapRegion|TextFieldTapRegion` en todo `packages/` excluyendo tests: 4 coincidencias, todas `InkWell`, ninguna con un campo como descendiente.
- `onTapOutside|unfocus(|requestFocus(|FocusScope|FocusManager`: cero.
- La cadena de ancestros de los 9 call sites de `AppTextField` hasta el `Scaffold`: `Column`, `AutofillGroup`, `Padding`, `Row`, `Expanded`, `Stack`, `SliverToBoxAdapter`, `SingleChildScrollView`, `Material`, `SafeArea`, `Identified` (contenedor sin acción). Ninguno tappable.
- Ancestros que pone el framework: el `ModalBottomSheetRoute` del ticket y del depósito envuelve el contenido en un detector de **arrastre vertical** (`framework:material/bottom_sheet.dart:422-425`), no de tap. El `Dialog` no agrega ninguno.
- El botón de sufijo es **hermano** del campo en un `Stack` (`app_text_field.dart:145-186`), no ancestro: un click que burbujea desde el `<input>` no pasa por él.

La app no tiene el clásico "tocar afuera para cerrar el teclado". No está expuesta a P1.

#### P2 — PARCIAL

- **Uso explícito: ausente.** Grep de `TextFieldTapRegion` en `packages/` y en las 104 dependencias resueltas de `.dart_tool/package_config.json`: cero.
- **Uso implícito: en cada campo.** El `TextField` de Material se envuelve a sí mismo en uno.
- **La duda.** No pude determinar leyendo si el problema necesita una región *explícita que agrupe
  otros widgets con el campo*, o si alcanza con un click que caiga dentro de la región propia del
  campo pero no sobre el `<input>`. En esta app el `<input>` mide lo mismo que el nodo
  (`engine:semantics/text_field.dart:283-284`) y `Identified.field` hace que el nodo sea el campo
  entero, así que no debería quedar hueco. Pero el botón de sufijo está **geométricamente encima**
  de la región del campo (el `TextField` reserva el lugar con un `SizedBox` en `suffixIcon`,
  `app_text_field.dart:170-174`, y el botón real se superpone).
- **Qué habría que ejecutar:** con un campo enfocado y texto a medio escribir, hacer click en
  cada uno de esos tappables (toggle de contraseña, limpiar búsqueda, `+`/`−`, chip de monto),
  registrar `document.activeElement` y seguir escribiendo. Comparar ON contra OFF.

Efecto colateral que **no** depende de semantics y conviene no confundir con P2: en web de
escritorio, un tap fuera del campo lo desenfoca por defecto (`framework:widgets/editable_text.dart:5538`,
acción en `:6739`). Como el sufijo queda fuera de la región, mostrar/ocultar la contraseña o
limpiar la búsqueda probablemente saque el foco del campo también con el árbol apagado.

#### P3 — PRESENTE

Ningún campo usa `autofocus` (el parámetro existe en `app_text_field.dart:29` pero ningún call site lo pasa),
así que no hay "aparece enfocado y se escribe". Los flujos donde sí se escribe apenas se enfoca:

| Flujo | Campo(s) | Por qué se escribe enseguida |
|---|---|---|
| Login | `auth_login_email_field` → `auth_login_password_field` | ⏎ en email mueve el foco (`TextInputAction.next`) |
| Registro | `auth_register_name_field` → `_email_field` → `_document_field` → `_password_field` | ídem; además `_document_field` aparece recién al elegir país (`register_view.dart:114`) |
| Búsqueda | `market_list_search_field` | tipeo continuo con debounce de 300 ms (`market_limits.dart:4`) |
| Depósito | `wallet_deposit_amount_field` | el modal se abre y el usuario tipea el monto |
| Ticket | `orders_ticket_quantity_field` | ídem; el campo ya trae texto inicial |

**Confusores propios de la app** — producen el mismo síntoma ("se perdió lo que tecleé") sin
relación con semantics. El control ON/OFF es lo que los separa:

1. **Búsqueda de mercado reescribe el campo desde la URL.** Tras el debounce, el filtro se manda a
   la URL con `trim()` (`market/module/lib/core/navigator.dart:30`) y la vista, al recibir la ruta
   nueva, pisa el texto si difiere (`market_list_view.dart:52-54`). Leyendo el código: un espacio
   final se borra a los 300 ms (escribir `grupo aval` con una pausa después de `grupo ` daría
   `grupoaval`), y un carácter tecleado entre el debounce y la reconstrucción puede perderse.
   Es una hipótesis de lectura; hay que ejecutarla.
2. **Depósito y ticket reescriben el controller desde el estado** (`deposit_view.dart:51-53`,
   `order_ticket_data.dart:36-38`). Solo cuando difieren, pero al hacerlo el cursor se resetea.
3. **Filtros de entrada y `maxLength`** en los campos numéricos (`app_text_field.dart:66-71`,
   `order_ticket_data.dart:102`): el framework corrige el valor después de que el motor lo mandó.

#### P4 — PRESENTE

Nada que agregar a la tabla salvo el caso más expuesto: `MarketListView` tiene el buscador, dos
filas de chips y la lista de ítems tappables en un único `CustomScrollView`
(`market_list_view.dart:91-121`). Es la vista donde el puntero pasa por más tipos de hijo
durante un mismo scroll.

No se puede saber leyendo si el salto ocurre ni de cuánto es. Hay que medir el offset paso a paso.

#### P5 — PRESENTE

**(a) Tappables fuera del viewport que siguen en el árbol.** `SingleChildScrollView` declara como
recorte semántico **todo** su contenido, no solo lo visible
(`framework:widgets/single_child_scroll_view.dart:678-686`). Cada tappable de una vista con
`AppScaffold` (`app_scaffold.dart:91`) y de los dos modales está en el árbol aunque esté scrolleado
fuera de pantalla. Un `click()` de DOM sobre `auth_register_submit_button` sin scrollear dispararía
el envío. Los tests de widget actuales siempre hacen `ensureVisible` antes de tocar
(`app_flow_test.dart:59-65`), o sea que este caso nunca se ejercitó.
Las listas perezosas (`ListView` en `movements_view.dart:85` y `orders_history_view.dart:70`,
`SliverList` en `market_list_data.dart:18`) solo exponen lo cercano al viewport.

**(b) Snackbar flotante sobre contenido tappable.** `SnackBarBehavior.floating`
(`app_theme.dart:264`). El depósito muestra el snackbar y cierra el modal en el mismo paso
(`deposit_view.dart:65-74`), así que flota varios segundos sobre la parte baja de la pantalla de
atrás (billetera o inicio), donde hay ítems y botones. El test de flujo ya lo esquiva con una
espera fija (§4).

**(c) Botón superpuesto al campo.** El toggle de contraseña y el "limpiar búsqueda" son nodos
tappables encima del rectángulo del `<input>`. Que el botón reciba el click depende del orden de
apilado que arme el motor, no del orden de pintado de Flutter.

**(d) Modales sobre páginas.** El ticket y el depósito se presentan como `DialogRoute` (≥ 768 px)
o `ModalBottomSheetRoute` (`app_route.dart:130-152`), y el logout como `showDialog`
(`settings_view.dart:29`). Lo que queda debajo debería salir del árbol por el `BlockSemantics` de
la barrera (`framework:widgets/modal_barrier.dart:264`). Dos motivos para no darlo por hecho:

- El shell **ya tuvo que esquivar** ese `BlockSemantics` con un contenedor propio para que el
  rail no desapareciera (`app_navigation_shell.dart:66-69`). Hay que verificar que ese contenedor
  no deje vivos los tabs del rail debajo de un modal en layout ancho.
- La barrera expone un nodo "cerrar" solo si la plataforma es Android, iOS o macOS
  (`framework:widgets/modal_barrier.dart:210-221`). En web eso depende del sistema del navegador:
  **el árbol no es el mismo en una Mac de desarrollo que en el `ubuntu-latest` del CI.**

**Sub-forma ausente:** las tabs inactivas. `StatefulShellRoute.indexedStack` deja las ramas
montadas, pero `go_router` 17.3.0 las envuelve en `Offstage` (`go_router/lib/src/route.dart:1695`),
que las saca del árbol semántico.

#### P6 — PRESENTE

Sin matices. En la lista de mercado casi cualquier punto donde arranque un scroll es un ítem
tappable o un chip.

#### P7 — PRESENTE (inherente al motor)

No es un defecto de la app: es el límite de lo que la automatización por id puede hacer. Lo
relevante es saber qué flujos **no** se pueden cubrir por id — los de la tabla — para que una
suite no los "cubra" con `force: true` y reporte un verde que no significa nada.

#### P8 — PARCIAL

El diseño conoce el problema y lo evita: el error del campo y el sufijo se dibujan **fuera** del
nodo fusionado precisamente por esto (`app_text_field.dart:9-15`), y `Identified.control` documenta
que su subárbol no puede contener otros ids (`identified.dart:14-17`). No encontré ningún sitio
que viole esa regla.

Las dudas, y por qué queda en PARCIAL y no en AUSENTE:

1. **Los tests que lo verifican corren en la VM, no en un navegador.** Comprueban el árbol del
   framework (`find.bySemanticsIdentifier`). Que cada id llegue al DOM como
   `flt-semantics-identifier` (`engine:semantics/semantics.dart:863`) no está verificado por nada.
2. **Sitios donde un widget de Material trae semántica propia dentro de un `Identified.control`**
   y el resultado depende de cómo fusione: `NavigationDestination` (`app_navigation_shell.dart:80-86`)
   y `Checkbox` dentro de un `InkWell` (`app_checkbox.dart:32-48`).
3. **La regla es una convención, no una restricción del compilador.** Nada impide que mañana
   alguien ponga un `Identified` dentro de un `AppButton`.

Qué habría que ejecutar: por cada vista, contar los `flt-semantics-identifier` del DOM contra
`docs/semantics-ids.md`.

---

## 3. Cambios mínimos para hacer observables los AUSENTES y PARCIALES (Fase 3)

> ### ⛔ NO MERGEABLE
> Lo que sigue va en una **rama desechable** (`lab/semantics-repro`) que **no se mergea jamás**
> a `main` ni a ninguna rama de producto. Se borra al terminar la medición.
> **No está aplicado**: este repo no fue modificado. Tampoco fue compilado.

Sirve para una sola cosa: confirmar que los mecanismos de P1, P2 y P8 **se disparan en Flutter
3.41.9** antes de sacar conclusiones sobre los patrones presentes. No mide el riesgo de la app —
para P1 ese riesgo no existe.

El cambio es **un archivo nuevo** con su propio `main`, sin tocar ningún archivo existente: ni el
router, ni el redirect, ni un flujo real. Usa los primitivos reales del design system para que el
árbol resultante sea el de la app.

```diff
--- /dev/null
+++ b/packages/apps/mila_invest_app/lib/main_semantics_lab.dart
@@ -0,0 +1,83 @@
+// ⛔ RAMA DESECHABLE lab/semantics-repro — NO MERGEAR JAMÁS.
+// Pantalla aislada para comprobar que P1, P2 y P8 se disparan en esta
+// versión de Flutter. No forma parte de ningún flujo de la app.
+import 'package:design_system/design_system.dart';
+import 'package:flutter/material.dart';
+import 'package:flutter/semantics.dart';
+
+SemanticsHandle? _labSemanticsHandle;
+
+void main() {
+  WidgetsFlutterBinding.ensureInitialized();
+  if (const bool.fromEnvironment('ENABLE_SEMANTICS')) {
+    _labSemanticsHandle = SemanticsBinding.instance.ensureSemantics();
+  }
+  runApp(
+    const MaterialApp(
+      home: Scaffold(body: SafeArea(child: _SemanticsLab())),
+    ),
+  );
+}
+
+class _SemanticsLab extends StatefulWidget {
+  const _SemanticsLab();
+
+  @override
+  State<_SemanticsLab> createState() => _SemanticsLabState();
+}
+
+class _SemanticsLabState extends State<_SemanticsLab> {
+  int _ancestorTaps = 0;
+  int _insideTaps = 0;
+
+  @override
+  Widget build(BuildContext context) => Padding(
+    padding: const EdgeInsets.all(16),
+    child: Column(
+      crossAxisAlignment: CrossAxisAlignment.stretch,
+      children: <Widget>[
+        // P1: un campo con un ancestro que captura taps.
+        Semantics(
+          container: true,
+          identifier: 'lab_p1_wrapper',
+          child: GestureDetector(
+            behavior: HitTestBehavior.opaque,
+            onTap: () => setState(() => _ancestorTaps++),
+            child: const Padding(
+              padding: EdgeInsets.all(24),
+              child: AppTextField(id: 'lab_p1_field', label: 'P1'),
+            ),
+          ),
+        ),
+        Identified(id: 'lab_p1_taps_text', child: Text('$_ancestorTaps')),
+        const SizedBox(height: 24),
+        // P2: un botón agrupado con el campo en un TextFieldTapRegion.
+        TextFieldTapRegion(
+          child: Row(
+            children: <Widget>[
+              const Expanded(
+                child: AppTextField(id: 'lab_p2_field', label: 'P2'),
+              ),
+              AppIconButton(
+                id: 'lab_p2_inside_button',
+                icon: Icons.add,
+                tooltip: 'Dentro de la región',
+                onPressed: () => setState(() => _insideTaps++),
+              ),
+            ],
+          ),
+        ),
+        Identified(id: 'lab_p2_taps_text', child: Text('$_insideTaps')),
+        const SizedBox(height: 24),
+        // P8: un id dentro de un ancestro fusionado que ya trae el suyo.
+        Identified.control(
+          id: 'lab_p8_outer_button',
+          child: FilledButton(
+            onPressed: () {},
+            child: const Identified(id: 'lab_p8_inner_text', child: Text('P8')),
+          ),
+        ),
+      ],
+    ),
+  );
+}
```

Cómo se compila (dos veces, mismo código):

```bash
cd packages/apps/mila_invest_app
flutter build web -t lib/main_semantics_lab.dart --dart-define=ENABLE_SEMANTICS=true -o build/web_lab_on
flutter build web -t lib/main_semantics_lab.dart -o build/web_lab_off
```

Qué mirar en cada panel:

| Panel | Acción | El mecanismo se dispara si… | Control |
|---|---|---|---|
| P1 | `[flt-semantics-identifier="lab_p1_field"] input` → `el.click()` desde `page.evaluate` (click sin eventos de puntero) y después teclear `abc` | `lab_p1_taps_text` pasa de `0` a `1`, y/o el campo no tiene foco, y/o no queda `abc` | Mismo paso con `page.mouse.click` en el centro del campo: el contador debe quedar en `0`. En OFF, click en el borde del padding: debe subir (prueba que el ancestro funciona) |
| P2 | Enfocar `lab_p2_field`, teclear `ab`, click real en `lab_p2_inside_button`, teclear `cd` | `document.activeElement` es `flutter-view` (o no es el `<input>`) y el campo queda en `ab` | Misma secuencia en OFF: el campo debe quedar en `abcd` |
| P8 | Contar `[flt-semantics-identifier^="lab_p8_"]` | Hay **uno** solo (`lab_p8_outer_button`) y `lab_p8_inner_text` no existe | — (en OFF no hay ids; no aplica) |

Si un panel **no** dispara su mecanismo en 3.41.9, ese problema no aplica a esta versión y se
anota así. Es un resultado tan válido como el contrario.

---

## 4. Esperas, reintentos e inestabilidad ya presentes en la suite

### 4.1 No hay suite de navegador

- **No existe ningún test de Playwright** en el repo: ni `playwright.config.*`, ni `*.spec.*`, ni
  `package.json`, ni carpeta `e2e/` o `integration_test/`. Tampoco en `../app_demo`.
- `docs/decisions.md` §13 lo dice explícitamente: *"La suite E2E vendrá después, en su propio paquete"*.
- `scripts/serve_web.py` menciona E2E en su docstring, pero solo sirve el build.

Los 55 archivos de test son `flutter test` en la VM de Dart. **Ninguno de los ocho problemas
puede manifestarse ahí**: son del motor web y la VM no lo ejecuta. Por lo tanto, hoy no hay
inestabilidad atribuible a estos problemas — no porque no exista, sino porque nada la mide.

### 4.2 Lo que hay en los tests de widget y se va a trasladar al navegador

No encontré `retry:`, `skip:`, `Timeout`, ni marcas de test inestable (grep). Sí encontré estos
puntos, que son los primeros candidatos a volverse esperas o flakes cuando exista la suite real:

| Dónde | Qué hace | Con qué problema se cruza |
|---|---|---|
| `packages/apps/mila_invest_app/test/app_flow_test.dart:114-116` — test *"flujo completo: login demo → depósito → mercado → comprar → portafolio → Actividad → inicio actualizado"* | Espera fija de **5 s** con el comentario *"El snackbar del depósito dura unos segundos sobre la pantalla"* | **P5 (b)**. Es la única espera fija de la suite y existe para dejar pasar un overlay que tapa contenido |
| `app_flow_test.dart:59-65`, helper `_tap` (también `orders/module/test/views_test.dart:78`, y `ensureVisible` sueltos en `dashboard_test.dart:189`, `portfolio_test.dart:279`, `transactions_test.dart:271,299`, `wallet_test.dart:360`) | Cada tap es `ensureVisible` + `pumpAndSettle` + `tap` + `pumpAndSettle` | **P4** y **P5 (a)**: todos los taps scrollean antes. En navegador ese scroll pasa por el DOM, y nunca se probó tocar algo no visible |
| `app_flow_test.dart` — los 8 tests | **Ningún test de flujo teclea.** El login usa `auth_login_demo_button` (`:73-77`), el depósito un chip sugerido (`:112`), el ticket la cantidad por defecto | **P3** y **P2**: los flujos con teclado no están cubiertos de punta a punta. `enterText` solo aparece en `authentication/module/test/views_test.dart` (12 usos) y `design_system/test/primitives_identifier_test.dart` (3) |
| `packages/features/core/wallet/module/test/wallet_test.dart:466` — *"elige moneda, usa un sugerido y deposita"* | `pump(500 ms)` después de enviar | Tiempo de envío; candidato a espera en navegador |
| `packages/ui/design_system/test/primitives_identifier_test.dart:566` | `pump(1 s)` para que aparezca el snackbar | **P5 (b)** |
| `pumpAndSettle` | 61 usos: `orders/views_test` 13, `market/views_test` 11, `app_flow_test` 8, `app_cross/views_test` 8, `navigator_test` 6, `authentication/views_test` 4, `primitives_identifier_test` 4, `wallet_test` 3, `dashboard_test` 2, `portfolio_test` 2 | No tiene equivalente en Playwright. Cada uno es una espera implícita que habrá que hacer explícita |

### 4.3 Comportamientos de la app que se van a confundir con estos problemas

No son de semantics, pero un test los va a ver como "se perdió texto" o "se fue el foco". Hay que
tenerlos identificados antes de medir, o se atribuyen mal:

1. Reescritura del buscador de mercado desde la URL, con `trim()` (detalle en P3).
2. Desenfoque del campo al tocar su propio botón de sufijo en web de escritorio (detalle en P2).
3. Árbol distinto según el sistema operativo del navegador, por la barrera de los modales
   (detalle en P5 d). Una suite que pase en macOS puede fallar en el CI de Linux, o al revés.

---

## 5. Lo que esta auditoría no puede afirmar

Todo lo anterior sale de leer código. Sin ejecutar no se puede saber:

| Pregunta | Qué hay que ejecutar |
|---|---|
| ¿P3, P4 y P6 se manifiestan, y con qué magnitud? | Los flujos de la tabla, dos veces (ON / OFF), midiendo texto final, offset y tiempos |
| ¿P2 se dispara con los tappables pegados a los campos? | La secuencia de P2 en §2.2, y el panel P2 del lab |
| ¿Qué queda en el árbol debajo de un modal, y cambia entre macOS y Linux? | Abrir ticket / depósito / logout y listar los ids presentes, en ambos sistemas y en ambos anchos |
| ¿"Crear cuenta" queda bajo el pliegue a 390×844? | Leer su `boundingBox` contra el viewport |
| ¿Todos los ids de `docs/semantics-ids.md` llegan al DOM? | Conteo por vista |
| ¿P1, P2 y P8 existen en 3.41.9? | El lab de §3 |

El prompt para hacerlo está en `PROMPT-TESTS.md`.
