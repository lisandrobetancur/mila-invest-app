# Arquitectura

## Capas

```
apps  →  features  →  shared
 │         │            ↑
 │         └────→  ui ──┘
 └──────────────────────┘
```

| Capa | Paquetes | Qué contiene |
|---|---|---|
| `apps` | `mila_invest_app` | shell: wiring, router, DI, i18n, flags |
| `features` | `generic/*`, `core/*` | producto, en tríadas `constants`/`typing`/`module` |
| `ui` | `design_system`, `components/packages/*` | tokens, temas, primitivas y componentes |
| `shared` | `typing`, `network`, `fake_backend`, `navigator`, `utilities` | lógica pura, cero widgets |
| `development` | `lint` | análisis estático compartido |

## Reglas de dependencia

1. `features/*` importa de `shared/*` (menos `fake_backend`), de `ui/*` y del
   `typing/` de otras features. Nunca del `module/` de otra feature.
2. `shared/*` y `ui/*` nunca importan de `features/*` ni de `apps/*`.
3. `ui/design_system` no depende de ningún paquete interno.
4. El `module/` de una feature es privado; solo el shell lo importa, para
   registrar su `Override`, sus rutas y sus traducciones.
5. `shared/fake_backend` solo lo importa el shell.
6. La navegación entre features va por nombre/path de ruta o por el `typing/`
   de la otra feature.
7. Flujo en un solo sentido: `RemoteDataSource → Service → Controller → View`.
   Ninguna vista ni controller toca `ApiClient` ni un DTO.
8. `dio` y `flutter_secure_storage` solo dentro de `shared/network`.
9. Ninguna vista importa `go_router`: navega por su `FeatureNavigator`.
10. `DateTime.now()` e ids solo vía `clockProvider` / `idGeneratorProvider`.
11. Ningún monto, precio ni porcentaje es `double`: `Money` (`Decimal` +
    `Currency`) y `Decimal`. `double` solo al alimentar `fl_chart`.
12. `kIsWeb` / `defaultTargetPlatform` solo en `shared/utilities`
    (`platform_guard.dart`); `dart:io` solo tras import condicional.
13. Nadie usa `print`. Se loguea con `AppLogger` de `loggerProvider`, y nunca
    tokens, contraseñas ni documentos completos.
14. Todo `Semantics.identifier` y toda `Key` salen de `<Feature>Ids`.

## Anatomía de una feature

```
features/<core|generic>/<feature>/
├── constants/    <feature>_constants   ids, rutas, límites
├── typing/       <feature>_typing      modelos, enums, errores, interfaces
└── module/       <feature>             data + service + state + ui
```

```
module/lib/
├── <feature>.dart                 barrel
├── core/
│   ├── data/<feature>_remote_data_source.dart + data/dto/*_dto.dart
│   ├── service/service.dart + service/provider.dart
│   ├── navigator.dart
│   └── state/<sub_estado>/{controller,provider,state}.dart
└── ui/
    ├── languages.dart
    ├── router.dart
    └── views/<vista>/{<vista>_view,_shimmer,_data,_empty,_error}.dart
```

## Flujo de datos

```
ApiClient ──► RemoteDataSource ──► Service ──► Controller ──► View
             (DTOs)            (modelos,     (estado,       (solo
                                reglas)       errores)       render)
```

El estado compartido entre features sale de providers derivados de solo
lectura declarados en el `typing/` de la feature dueña; después de una
escritura, el controller que la hizo los invalida con `ref.invalidate`.
