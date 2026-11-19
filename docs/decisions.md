# Decisiones

Cada decisión: contexto, decisión, consecuencias.

## 1. Dobles de test: `mocktail`

**Contexto.** Hacen falta dobles para services y controllers.
**Decisión.** `mocktail`, pineado, como única librería de dobles.
**Consecuencias.** Sin codegen ni `build_runner`; los dobles se escriben a
mano y el repo no tiene paso de generación.

## 2. Red: `dio` encapsulado

**Contexto.** Hacen falta interceptores (auth, refresh, errores, log).
**Decisión.** `dio` vive solo en `shared/network`, detrás de la interfaz
`ApiClient`. Las features dependen de la interfaz.
**Consecuencias.** Cambiar de cliente HTTP toca un paquete. Ninguna feature
ve `DioException`: solo `ApiException` y las excepciones de su feature.

## 3. Sin SQLite en la Fase 1

**Contexto.** La arquitectura de referencia era offline-first sobre SQLite.
**Decisión.** La API es la única fuente de verdad. En el dispositivo solo se
persisten preferencias (`shared_preferences`) y tokens
(`flutter_secure_storage`).
**Consecuencias.** No hay caché de dominio ni migraciones. Si más adelante
hace falta modo offline, se agrega un paquete de caché detrás de los data
sources, sin tocar services ni controllers.

## 4. Backend falso como modo por defecto

**Contexto.** La app tiene que correr sin levantar el backend.
**Decisión.** `API_MODE=fake` es el default; `shared/fake_backend` responde en
memoria las mismas rutas y los mismos códigos de error, con seed
determinístico (`FAKE_SEED=demo|empty`).
**Consecuencias.** `flutter run` funciona sin backend, los estados vacíos y de
error se recorren a mano y los controllers se prueban contra el fake. El fake
crece en el mismo PR que la feature que lo necesita.

## 5. Dinero con `decimal`, nunca `double`

**Contexto.** `double` pierde precisión en dinero (`0.1 + 0.2 != 0.3`).
**Decisión.** Dinero es `Money` (`Decimal` + `Currency`); los porcentajes son
`Decimal`. `double` solo aparece al pasar puntos a `fl_chart`, dentro de
`price_chart` y `allocation_donut`.
**Consecuencias.** Los montos del JSON llegan como string decimal y se parsean
a `Decimal`; un número JSON en un campo de dinero es un error de contrato. Se
verifica por grep.

## 6. Mapeo DTO ↔ modelo en el módulo

**Contexto.** En el origen el mapeo fila ↔ modelo estaba en dos lugares.
**Decisión.** `fromJson` vive en el DTO (`module/core/data/dto/`) y
`toDomain()` al salir. Los modelos de `typing` no conocen JSON.
**Consecuencias.** Una sola convención en todo el repo; el `typing` de una
feature se puede consumir desde otra sin arrastrar detalles de transporte.

## 7. Estado compartido con providers derivados

**Contexto.** En el origen los services escribían `StateProvider`s.
**Decisión.** Lo que varias vistas necesitan sale de providers derivados de
solo lectura declarados en el `typing` de la feature dueña. Después de una
escritura, el controller llama `ref.invalidate(...)`.
**Consecuencias.** Ningún service escribe providers; el flujo de datos queda
en un solo sentido y las invalidaciones son explícitas y testeables.

## 8. `Equatable` también en estados

**Contexto.** En el origen los estados tenían `==`/`hashCode` a mano y
`copyWith` con flags `clearX`.
**Decisión.** Modelos y estados extienden `Equatable`; `copyWith` usa un
sentinel (`static const Object _unset = Object();`) para poder poner `null`.
**Consecuencias.** Menos código y menos errores de igualdad; Riverpod no
reconstruye de más.

## 9. Logger y duraciones como providers

**Contexto.** En el origen había un `log` global y `AppDurations.fastMode`
estático.
**Decisión.** `loggerProvider` y `durationsProvider` inyectados.
**Consecuencias.** Los tests sobrescriben duraciones a cero y capturan logs
sin estado global.

## 10. `core/` vs `generic/`

**Contexto.** Ocho features en la Fase 1 y más en las siguientes.
**Decisión.** Se mantiene la separación: `generic` = transversal
(`app_cross`, `authentication`); `core` = dominio de inversión.
**Consecuencias.** Las features de las fases 2 y 3 entran en `core/` sin
tocar la arquitectura.

## 11. Tres paquetes por feature

**Contexto.** Una feature necesita consumir el contrato de otra sin ver su
implementación.
**Decisión.** Se mantiene la tríada `constants` / `typing` / `module`.
**Consecuencias.** `dashboard` consume el `typing` de `portfolio`, `market` y
`transactions`; `orders`, el de `wallet` y `market`. El `module` queda
privado por construcción, verificable leyendo los `pubspec.yaml`.

## 12. `pubspec.lock` commiteado y `enforceLockfile: true`

**Contexto.** Reproducibilidad entre máquinas y CI.
**Decisión.** Toda dependencia de terceros se pinea sin caret, el lockfile se
commitea y `melos bootstrap` lo exige.
**Consecuencias.** Subir una dependencia es un cambio explícito y revisable.
`test` es la única sin pinear, porque pinearla pinearía el Flutter SDK de
todo el equipo (`flutter_test` fija `test_api`).

## 13. `Semantics.identifier` en toda la app desde el día uno

**Contexto.** La QA black-box externa no puede depender del copy, del idioma
ni del layout.
**Decisión.** Cada vista, estado, control y valor verificable lleva un
identificador estable, con `<Feature>Ids` como fuente única de los
identificadores y de las `Key`s. El `id` es un parámetro **obligatorio** del
design system, no un agregado opcional para QA.
**Consecuencias.** Ningún control queda sin identificador; renombrar uno es un
cambio de contrato que se anota en `docs/semantics-ids.md`. La suite E2E
vendrá después, en su propio paquete, sin tocar código de producto.
