# Prompt — medir con Playwright los problemas de semantics en MILA Invest (Flutter web)

> Pegalo como primer mensaje de una sesión nueva, abierta en la raíz del repo `mila-invest-app`.
> Es autónomo: no hace falta haber leído ninguna auditoría previa.

---

Vas a medir, con Playwright, cómo se comporta esta app Flutter web **con el árbol de semantics
encendido y apagado**, y a comparar. El entregable es un informe (`RESULTADOS-SEMANTICS.md`) con
una tabla. **No se arregla nada**: ni la app ni los tests.

## Contexto que necesitás

**La app.** MILA Invest, simulador de inversiones. Monorepo Flutter (`melos`), app en
`packages/apps/mila_invest_app`. Flutter `3.41.9` / Dart `3.11.5` (fijado en
`.github/workflows/ci.yml`; registrá `flutter --version` en el informe). Web con dart2js +
CanvasKit. Backend falso en memoria por defecto: no hay que levantar nada, y el estado se
reinicia con cada recarga. Cuenta demo de prueba, del `README.md`: `demo@milainvest.app` /
`Demo1234!`.

**El árbol de semantics** solo se enciende compilando con `--dart-define=ENABLE_SEMANTICS=true`
(`lib/main.dart`). Sin el define arranca apagado. Con el árbol encendido cada control expone
`flt-semantics-identifier="<id>"` en el DOM; el inventario completo está en
`docs/semantics-ids.md`. **Con el árbol apagado esos atributos no existen.**

**Los problemas que se buscan.** Son del motor web de Flutter y solo aparecen con el árbol encendido:

| # | Problema |
|---|---|
| P2 | Un click cerca de un campo mueve el foco del navegador a `flutter-view` y el campo deja de recibir lo que se escribe |
| P3 | Los caracteres escritos antes de que el framework active el campo se pierden |
| P4 | El scroll salta un tramo grande al pasar sobre un hijo no scrollable |
| P5 | El tap se entrega por id de nodo, sin hit-testing: un elemento inalcanzable para el usuario responde igual a la automatización |
| P6 | Hasta 200 ms entre `pointerdown` y `onTap`; un scroll iniciado sobre un tappable queda retenido |
| P7 | Solo tappables, campos de texto y sliders reciben `pointer-events`; el resto del árbol es inerte |
| P8 | El identifier de un nodo hijo se pierde si un ancestro fusionado ya trae el suyo |

(P1 — un `click` sobre el `<input>` que dispara el `onTap` de un ancestro — no aplica: en esta
app ningún campo tiene un ancestro tappable.)

## Paso 0 — Ubicar la suite de Playwright

Buscá `playwright.config.*`, `*.spec.ts|js`, `package.json` con `@playwright/test`, carpetas `e2e/`.

**Al 2026-11-19 (commit `e5ec0e3`) este repo no tenía ninguna suite de Playwright**: los 55
archivos de test son `flutter test` en la VM de Dart, donde estos problemas no pueden aparecer.
`docs/decisions.md` §13 dice que la suite E2E "vendrá después, en su propio paquete".

- **Si ahora existe** (acá o en la ruta que te indique quien te pegó este prompt): usala.
  Listá sus tests, mapeá cada uno a los flujos de la tabla de abajo y corré esos. Lo que ningún
  test existente cubra, anotalo como hueco y agregá la sonda mínima.
- **Si sigue sin existir: decilo en la primera línea del informe** y escribí solo las sondas de
  este prompt en `e2e/semantics-probe/` (paquete propio de Node, sin tocar ningún archivo de
  `packages/`). No construyas una suite E2E general: son sondas de medición.

Como referencia funcional de cada flujo —qué tiene que pasar cuando anda bien— están estos tests
de widget. **No los modifiques.**

| Flujo | Test de referencia |
|---|---|
| Recorrido completo | `packages/apps/mila_invest_app/test/app_flow_test.dart` › *"flujo completo: login demo → depósito → mercado → comprar → portafolio → Actividad → inicio actualizado"* |
| Layout ancho (rail) | mismo archivo › *"en web ancho usa rail lateral con los mismos ids"* |
| Login | `packages/features/generic/authentication/module/test/views_test.dart` › `LoginView` › *"valida en el cliente y muestra los errores de campo"*, *"credenciales incorrectas muestran el banner de error"* |
| Registro | mismo archivo › `RegisterView` › *"completa el formulario, acepta el aviso y se registra"*, *"el indicador de requisitos sigue a la contraseña"* |
| Lista de mercado | `packages/features/core/market/module/test/views_test.dart` › `MarketListView` › *"data: filtros, estado de mercado e ítems con sus partes"* |
| Detalle de instrumento | mismo archivo › `InstrumentDetailView` › *"data: precio, gráfico, estadísticas, posición y botones"* |
| Ticket de orden | `packages/features/core/orders/module/test/views_test.dart` › `OrderTicketView` › *"el stepper cambia la cantidad y vuelve a cotizar"*, *"revisar → confirmar → resultado con precio de ejecución"* |
| Depósito | `packages/features/core/wallet/module/test/wallet_test.dart` › `DepositView` › *"elige moneda, usa un sugerido y deposita"* |

Dato útil: el test de flujo completo **nunca teclea** (entra con el botón demo, deposita con un
chip sugerido, compra con la cantidad por defecto) y hace `ensureVisible` antes de cada tap.
Los flujos con teclado y los taps sobre algo no visible no están cubiertos por nada.

## Paso 1 — Dos builds, idénticos salvo por el árbol

```bash
cd packages/apps/mila_invest_app
flutter build web --dart-define=ENABLE_SEMANTICS=true --dart-define=FAST_ANIMATIONS=true --dart-define=PRICE_REFRESH_SECONDS=0 -o "$PWD/build/web_sem_on"
flutter build web --dart-define=FAST_ANIMATIONS=true --dart-define=PRICE_REFRESH_SECONDS=0 -o "$PWD/build/web_sem_off"
```

Servilos con el script del repo (hace el fallback de SPA que la app necesita), cada uno en su puerto:

```bash
python3 scripts/serve_web.py 8081 packages/apps/mila_invest_app/build/web_sem_on
python3 scripts/serve_web.py 8082 packages/apps/mila_invest_app/build/web_sem_off
```

No reutilices `build/web`: no se sabe con qué defines se compiló.

Configuración de Playwright, igual para los dos: `retries: 0`, `workers: 1`, `trace: 'on'`,
Chromium, `deviceScaleFactor: 1`, locale `es`, **contexto nuevo por test** (la sesión y el
"onboarding visto" se guardan en el almacenamiento del navegador). Dos viewports: **390×844**
(barra inferior, modales como bottom sheet) y **1280×800** (rail lateral, modales como diálogo;
el corte es 768 px). Anotá sistema operativo y versión de Chromium: el árbol de un modal no es el
mismo en macOS que en Linux.

Con contexto nuevo la app arranca en `/` → onboarding (`onboarding_skip_button`) → `/login`.

## Paso 2 — Cómo operar en cada modo

**ON (puerto 8081).** Localizá por `[flt-semantics-identifier="<id>"]`. Antes de asumir nada,
inspeccioná el DOM real de un campo y anotá su estructura (dónde está el `<input>`, qué elemento
lleva el id).

**OFF (puerto 8082).** No hay ids. Entonces:

1. Tomá las coordenadas del centro de cada objetivo en la corrida ON (`boundingBox()`), mismo
   viewport y mismo estado.
2. Antes de usarlas, compará una captura ON contra una OFF de esa pantalla. Si el layout no
   coincide, las coordenadas no valen: reportalo y no sigas con esa pantalla.
3. Accioná con `page.mouse` y `page.keyboard`.
4. Leé el resultado sin encender el árbol: URL (la app refleja la navegación en la URL), capturas,
   y `document.activeElement` (etiqueta, clases, `value`).
5. **No toques el placeholder** `flt-semantics-placeholder` (botón "Enable accessibility") ni lo
   alcances con Tab: enciende el árbol y la corrida deja de ser OFF. Verificá al final de cada
   test OFF que `document.querySelector('flt-semantics')` siga sin existir; si existe, la corrida
   se descarta y se reporta.

Si para alguna medición OFF necesitás leer el árbol, hacelo **como último paso del test**,
activando el placeholder, y marcá ese dato como "leído post-mortem".

## Paso 3 — Qué correr

Cada caso se corre **5 veces en ON y 5 en OFF**. Reportá cuántas de las 5 dieron cada resultado:
una diferencia que aparece 2 de 5 veces es un hallazgo, no ruido.

### A · Campos de texto (P3, P2)

Para cada flujo registrá: **qué quedó escrito** en cada campo, **dónde quedó
`document.activeElement`** después de cada paso, y **la espera mínima** que hizo falta. Para esto
último repetí la secuencia con 0, 50, 100, 250 y 500 ms entre el click y la primera tecla, y con
`keyboard.type` a 0 y a 50 ms por tecla. Reportá el menor valor con el que el texto queda completo.

| Caso | Ruta | Secuencia |
|---|---|---|
| A1 Login | `/login` | click `auth_login_email_field` → teclear `demo@milainvest.app` → `Enter` → teclear `Demo1234!` de inmediato → `Enter`. Debe terminar en `/home` |
| A2 Registro | `/register` | click `auth_register_country_co_chip` → `auth_register_name_field`: `Ana Prueba` → `Enter` → email → `Enter` → documento (`auth_register_document_field` recién existe después de elegir país) → `Enter` → `auth_register_password_field` |
| A3 Búsqueda | `/market` | click `market_list_search_field` → teclear `eco` de corrido. Leer el campo y el `?q=` de la URL a +0, +400 y +1000 ms |
| A3b Búsqueda con pausa | `/market` | teclear `grupo ` (con el espacio), esperar 500 ms, teclear `aval`. Leer el campo |
| A4 Depósito | `/wallet` → `wallet_cop_deposit_button` | apenas aparece `wallet_deposit_view`, click `wallet_deposit_amount_field` → teclear `250000` |
| A5 Ticket | `/market/instrument/ECOPETROL-CO` → `market_detail_buy_button` | apenas aparece `orders_ticket_view`, click `orders_ticket_quantity_field` → seleccionar todo → teclear `12` |

**A3b es un control**, no un caso de semantics: la app reescribe el buscador desde la URL
(`market_list_view.dart`, `didUpdateWidget`) y el filtro pasa por un `trim()`. Si el espacio se
pierde también en OFF, es un defecto de la app y va en una fila aparte, no como P3.

Después, con el campo enfocado y texto a medio escribir, **click en el control vecino y seguir
tecleando `x`**. Registrá `activeElement` antes y después, y si la `x` entra al campo:

| Caso | Campo | Control vecino |
|---|---|---|
| A6 | `auth_login_password_field` | `auth_login_password_toggle` (está superpuesto al campo) |
| A7 | `auth_register_password_field` | `auth_register_password_toggle` |
| A8 | `market_list_search_field` | `market_list_search_clear_icon_button` (aparece al haber texto) |
| A9 | `orders_ticket_quantity_field` | `orders_ticket_quantity_increase_stepper` y `…_decrease_stepper` |
| A10 | `wallet_deposit_amount_field` | `wallet_deposit_suggested_item_1000000` |

En web de escritorio un tap fuera del campo lo desenfoca también con el árbol apagado. Lo que
importa es **si ON y OFF difieren**, no si el foco se va.

### B · Scroll (P4, P6)

Registrá el **offset antes y después de cada paso** y detectá saltos. En ON el offset es el
`scrollTop` del elemento scrollable del árbol (el ancestro que contiene un
`flt-semantics-scroll-overflow`). En OFF medilo por desplazamiento entre capturas consecutivas de
una fila de referencia, o leelo post-mortem.

Secuencia: `page.mouse.move` al punto de partida, después 10 × `mouse.wheel(0, 100)` con 150 ms
entre pasos. **Salto** = un paso cuyo desplazamiento se aparta más de 50 px de los 100 pedidos.
Repetí con el puntero partiendo desde cada tipo de hijo:

| Caso | Ruta (viewport) | Puntero sobre |
|---|---|---|
| B1 | `/market` (390×844) | un ítem `market_list_instrument_item_ECOPETROL-CO` |
| B2 | `/market` | el campo `market_list_search_field` |
| B3 | `/market` | un chip `market_list_country_co_chip` |
| B4 | `/market` | un texto no interactivo (el título de la vista) |
| B5 | `/register` (390×600) | `auth_register_name_field`, y aparte un texto no interactivo |
| B6 | `/home` (390×844) | un ítem `dashboard_mover_item_<id>` |
| B7 | `/activity` | un ítem `transactions_list_item_<id>` |
| B8 | ticket abierto (390×600) | `orders_ticket_quantity_field` |

Para P6, dos mediciones más en `/market`, ON contra OFF:

- **B9 Latencia del tap.** Tiempo entre el `mouse.up` sobre `market_list_instrument_item_ECOPETROL-CO`
  y el cambio de URL a `/market/instrument/ECOPETROL-CO`.
- **B10 Arrastre táctil.** Contexto con `hasTouch: true`. Arrastre vertical de 300 px que
  **empieza sobre un ítem**. Tiempo hasta que la lista se mueve, y si se abre el detalle por
  error. Repetilo empezando sobre un texto no interactivo.

### C · P5 — aserción invertida (tests nuevos)

Ningún test existente hace esto, así que son **tests nuevos**. La lógica es al revés de lo
habitual: se intenta accionar algo que el usuario **no puede** alcanzar, y **el intento tiene que
fallar para que el resultado sea bueno**. El test pasa solo si el tap no produjo efecto. Si el
tap funciona, el test queda rojo y **así se reporta**: es el hallazgo.

Cada caso se prueba con tres formas de entrega, por separado, porque no son equivalentes:
`locator.click()` · `locator.click({ force: true })` · `locator.evaluate(el => el.click())`.
Solo en ON (en OFF no hay nodo que accionar; anotá "no aplica").

| Caso | Preparación | Objetivo que no debería responder | "Sin efecto" significa |
|---|---|---|---|
| C1 Fuera del viewport | `/register` a 390×844, sin scrollear. Confirmá con `boundingBox()` que el botón está fuera del viewport; si no lo está, achicá el alto hasta que lo esté y anotá el valor | `auth_register_submit_button` | No aparece `auth_register_name_field_error_text` ni ningún otro error de validación |
| C2 Debajo de un modal (angosto) | `/market/instrument/ECOPETROL-CO` → abrir el ticket (`market_detail_buy_button`), 390×844 | `market_detail_sell_button`, `nav_market_tab` | El ticket sigue abierto y la URL no cambia. Anotá si esos nodos **existen** en el DOM |
| C3 Debajo de un modal (ancho) | lo mismo a 1280×800 | `nav_market_tab`, `nav_home_tab` (rail lateral) | ídem. Este caso importa: el shell envuelve las tabs en un contenedor semántico propio (`app_navigation_shell.dart`) |
| C4 Debajo del diálogo | `/settings` → `settings_logout_button` | `settings_theme_dark_segment` | El tema no cambia y `settings_logout_dialog` sigue abierto |
| C5 Debajo del snackbar | `/wallet` → depositar con `wallet_deposit_suggested_item_1000000` → `wallet_deposit_submit_button`. Mientras `wallet_deposit_success_snackbar` está visible, buscá qué tappable con id se solapa con su rectángulo | el que se solape (si ninguno, anotalo) | La acción de ese control no ocurre |
| C6 Superposición | `/login`, con texto en la contraseña | click con **mouse real** en el centro de `auth_login_password_toggle` | Este es directo, no invertido: el toggle debe actuar (el `type` del `<input>` cambia) y el campo **no** debe recibir el click |

Además, para C2, C3 y C4 listá **todos** los `flt-semantics-identifier` presentes con el modal
abierto. La lista esperada es solo lo de adentro del modal.

### D · P7 y P8 (solo ON)

- **D1 Nodos inertes.** Intentá, sin `force`: `hover` sobre `market_detail_chart` (el gráfico
  tiene tooltip al tocar), `click` sobre un texto con id (`dashboard_home_total_text`), y un
  pull-to-refresh arrastrando desde arriba en `/home`. Reportá qué hace Playwright en cada uno
  (timeout, "intercepts pointer events", éxito). **No lo resuelvas con `force: true`.**
- **D2 Ids que no llegan al DOM.** En cada vista, y en cada estado alcanzable con `FAKE_SEED=demo`,
  compará los `flt-semantics-identifier` del DOM contra `docs/semantics-ids.md`. Listá los que
  falten. Tené en cuenta que los ids de elementos fuera del viewport en listas largas pueden no
  estar por diseño: scrolleá antes de darlos por faltantes.

## Paso 4 — Informe

`RESULTADOS-SEMANTICS.md`, con:

1. Entorno: `flutter --version`, sistema operativo, versión de Chromium, viewports, y si la suite
   existía o hubo que escribir las sondas.
2. La tabla, una fila por caso:

   | Test | Comportamiento con semantics ON | Con OFF | Diferencia | ¿Explica alguna inestabilidad ya conocida? |
   |---|---|---|---|---|

   En cada celda de comportamiento: resultado, cuántas de 5 corridas, y los datos del caso (texto
   final, `activeElement`, espera mínima, offsets, tiempos).

   Para la última columna, las únicas señales de inestabilidad que hoy existen en el repo son
   estas; decí explícitamente si tu medición las explica o no:
   - la espera fija de 5 s en `app_flow_test.dart` (*"El snackbar del depósito dura unos segundos
     sobre la pantalla"*);
   - el `ensureVisible` antes de **cada** tap en el helper `_tap` del mismo archivo;
   - que ningún test de flujo teclee en un campo;
   - cualquier flake que la suite de Playwright traiga anotado, si existe.
3. Una sección aparte con lo que **no** es de semantics (aparece igual en ON y en OFF).
4. Lo que no se pudo medir, y por qué.

## Reglas

- **Prohibido ajustar un test para que pase.** Nada de subir timeouts, agregar esperas,
  reintentos, `force: true` o cambiar un selector para sacar un rojo. Si falla, se reporta tal
  cual, con el trace.
- Las esperas que este prompt pide medir (A) son **datos**, no arreglos: se reportan, no se dejan
  puestas en ningún test existente.
- No modifiques nada dentro de `packages/` ni los tests de widget.
- Un "no hay diferencia" es un resultado. No lo adornes ni lo omitas.
- Si algo no se puede determinar, decí qué haría falta para saberlo en vez de inferirlo.
- No digas que un problema "no existe" por no haberlo visto en 5 corridas: decí "no observado en
  5 de 5".
