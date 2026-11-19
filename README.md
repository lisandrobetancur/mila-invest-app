# MILA Invest

Simulador de inversiones (*paper trading*) para Colombia, México y Perú.
App Flutter multiplataforma (Android, iOS y Web) organizada como monorepo
(`pub workspace` + melos).

> **No se mueve dinero real.** Todos los precios son simulados y la app lo
> indica siempre. Simulación con fines educativos, no es asesoría financiera.

## Arrancar

```bash
dart pub global activate melos 7.3.0
melos bootstrap
cd packages/apps/mila_invest_app
flutter run -d chrome            # backend falso en memoria (API_MODE=fake)
```

Contra el backend real (`mila-invest-api`):

```bash
flutter run --dart-define=API_MODE=remote \
            --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

Cuenta demo del backend falso: `demo@milainvest.app` / `Demo1234!`.

## Scripts

| Comando | Qué hace |
|---|---|
| `melos bootstrap` | resuelve el workspace con el lockfile commiteado |
| `melos run lint` | `flutter analyze --no-fatal-infos` |
| `melos run dartFormat` | `dart format . --line-length 80` |
| `melos run test` | tests unitarios de todos los paquetes |

## Documentación

- [`docs/architecture.md`](docs/architecture.md) — capas, paquetes y reglas de dependencia.
- [`docs/decisions.md`](docs/decisions.md) — decisiones tomadas y sus consecuencias.
- [`docs/api-contract.md`](docs/api-contract.md) — contrato con `mila-invest-api`.
- [`docs/design-system.md`](docs/design-system.md) — tokens, temas y componentes.
- [`docs/semantics-ids.md`](docs/semantics-ids.md) — inventario de identificadores semánticos.
