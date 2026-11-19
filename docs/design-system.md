# Sistema de diseño

## Dirección visual

Confianza, calma y claridad: los números son protagonistas, sin ruido
decorativo. Sobrio y preciso, con un acento cálido que evita el look de banco
genérico.

- Superficies planas con bordes finos de 1 px en vez de sombras; una sola
  elevación, para bottom sheets y diálogos.
- Densidad media; jerarquía por tamaño y peso tipográfico, no por color.
- El color se reserva para significado: ganancia, pérdida, acción principal,
  estado de mercado.
- **Nunca se comunica ganancia o pérdida solo con color**: siempre signo +/−
  y flecha ▲/▼.
- Sin banderas emoji: los países se muestran con `country_chip` (`CO` / `MX`
  / `PE` en una píldora).
- Sin ilustraciones de stock: los estados vacíos usan un ícono de línea
  grande, un título y un botón.

## Color (`app_colors.dart`)

El `ColorScheme` se construye con `ColorScheme.fromSeed(seedColor: navy)` y
se sobrescriben los roles de la tabla. Los colores de mercado viven en un
`ThemeExtension<MarketColors>` (`gain`, `gainContainer`, `loss`,
`lossContainer`, `neutral`, `marketOpen`, `marketClosed`) con `lerp`.

| Token | Light | Dark | Uso |
|---|---|---|---|
| `primary` | `#16325C` | `#9DBCF0` | acciones principales, tab activa, links |
| `onPrimary` | `#FFFFFF` | `#0B1A33` | texto sobre primary |
| `secondary` | `#C98A12` | `#F2C14E` | acento puntual: badge "Simulado" |
| `background` | `#F6F7F9` | `#0B1220` | fondo de pantalla |
| `surface` | `#FFFFFF` | `#121A2B` | tarjetas, sheets |
| `surfaceVariant` | `#EEF1F5` | `#1A2438` | inputs, chips sin seleccionar |
| `outline` | `#D5DAE1` | `#2A3550` | bordes de tarjetas y divisores |
| `textPrimary` | `#0E1726` | `#E7ECF3` | texto principal y cifras |
| `textSecondary` | `#5B6575` | `#9AA6B8` | etiquetas, metadatos |
| `gain` | `#127A45` | `#34C77B` | variación positiva |
| `gainContainer` | `#E3F4EA` | `#123323` | chips positivos y destello |
| `loss` | `#C2303A` | `#FF6B6B` | variación negativa |
| `lossContainer` | `#FBE7E8` | `#3A1619` | chips negativos y destello |
| `neutral` | `#5B6575` | `#9AA6B8` | variación 0 |
| `warning` | `#B26A00` | `#F5A524` | avisos |
| `error` | `#B3261E` | `#F2B8B5` | errores |
| `info` | `#1F6FD1` | `#7FB2FF` | mensajes informativos |

Todo par texto/fondo cumple **WCAG AA** (4,5:1 normal, 3:1 grande). El test
`color_contrast_test.dart` del design system falla por debajo del umbral.

## Tipografía (`app_typography.dart`)

Dos familias empaquetadas como assets en `assets/fonts/` con sus licencias
OFL: **Manrope** (600, 700) para títulos y cifras grandes, **Inter** (400,
500, 600) para cuerpo y cifras en listas. **Toda cifra usa
`FontFeature.tabularFigures()`.**

| Rol | Familia | Tamaño / alto | Peso | Uso |
|---|---|---|---|---|
| `displayLarge` | Manrope | 40 / 48 | 700 | valor total del portafolio |
| `headlineMedium` | Manrope | 28 / 36 | 700 | precio en detalle |
| `titleLarge` | Manrope | 20 / 28 | 600 | títulos de pantalla |
| `titleMedium` | Inter | 16 / 24 | 600 | títulos de tarjeta, ticker |
| `bodyLarge` | Inter | 16 / 24 | 400 | texto general |
| `bodyMedium` | Inter | 14 / 20 | 400 | texto secundario |
| `labelLarge` | Inter | 14 / 20 | 600 | botones |
| `labelSmall` | Inter | 12 / 16 | 600 | chips, badges, ejes |

Escalado de texto hasta 200 % sin overflow: las cifras grandes usan
`FittedBox` con `scaleDown`.

## Espaciado, radios, movimiento

- `AppSpacing`: `xxs 4, xs 8, sm 12, md 16, lg 24, xl 32, xxl 48`;
  `pagePadding` 16 mobile / 24 web; `maxContentWidth 1200`;
  `webBreakpoint 768`; `wideBreakpoint 1100`.
- `AppRadius`: `sm 8`, `md 12`, `lg 16`, `xl 24`, `pill 999`.
- `AppDurations` vía `durationsProvider`: `fast 120`, `normal 200`,
  `slow 320`, `priceFlash 400`; curva `Curves.easeOutCubic`. Todo colapsa a
  cero con `FAST_ANIMATIONS` o `MediaQuery.disableAnimations`.
- Áreas táctiles mínimas de 48 × 48.
- Íconos: Material Symbols outlined, peso 400, desde `AppIcons`.

## Primitivas

`AppScaffold`, `AppButton` (`primary`, `secondary`, `text`, `buy`, `sell`),
`AppTextField`, `AppCard`, `AppDialog`, `AppBottomSheet`, `AppBadge`,
`AppChip`, `AppSegmentedControl`, `AppShimmer`, `AppSnackbar`, `Identified`.

Toda primitiva interactiva o que muestre un valor verificable recibe
`required String id`, que se aplica como `ValueKey<String>(id)` +
`Semantics(identifier: id)`. Las que tienen partes accionables reciben un id
por parte (`AppDialog`: `id`, `confirmId`, `cancelId`).

Las variantes `buy`/`sell` son la única excepción a "el color es solo
significado": comprar es `gain` y vender es `loss`, con texto explícito.

## Componentes

| Componente | Qué hace |
|---|---|
| `money_text` | `Money` con el formato por moneda, tabular, tamaños `display`/`large`/`body`/`compact` |
| `price_change` | Variación con signo, flecha y color; variantes `text` y `chip` |
| `instrument_tile` | Ticker + nombre + país + precio + variación |
| `country_chip` | Píldora con el código del país |
| `price_chart` | Línea de `fl_chart`, color según el rango, área al 12 %, tooltip |
| `allocation_donut` | Torta por tipo de producto con leyenda accesible |
| `stat_tile` | Etiqueta + cifra + variación opcional |
| `empty_state` | Ícono + título + texto + acción |
| `error_state` | Mensaje traducido + "Reintentar" |
| `disclaimer_banner` | Aviso de simulación (`inline` y `compact`) |
| `order_summary` | Precio / bruto / comisión / total / saldo resultante |

## Tono del texto

Español neutro con **tú**, frases cortas, sin jerga sin explicar. Los botones
dicen la acción concreta ("Confirmar compra", no "Aceptar"). Los errores dicen
qué pasó y qué hacer. Inglés con el mismo tono.

## Accesibilidad

La etiqueta (`label`) es para personas y se traduce; el identificador
(`identifier`) es para máquinas, nunca se traduce. Un nodo lleva los dos.
Los gráficos exponen un resumen textual.
