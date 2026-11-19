# MILA Invest

Simulador de inversiones (*paper trading*) para Colombia, México y Perú.
App Flutter multiplataforma (Android, iOS y Web) organizada como monorepo
(`pub workspace` + melos 7).

> **No se mueve dinero real.** Los precios son simulados y la app lo indica
> siempre. Simulación con fines educativos, no es asesoría financiera.

## Requisitos

Flutter `3.41.9` (stable, Dart `3.11.5`) y melos `7.3.0`.

```bash
dart pub global activate melos 7.3.0
melos bootstrap
```

## Correr la app

Desde `packages/apps/mila_invest_app`. Por defecto usa el **backend falso**
en memoria (`API_MODE=fake`): no hace falta levantar la API. Cuenta demo:
`demo@milainvest.app` / `Demo1234!` (botón "Usar cuenta demo" en el login).

```bash
cd packages/apps/mila_invest_app
flutter run -d chrome
```

### En un teléfono

- **Android:** activa la depuración USB, conecta el teléfono y corre
  `flutter run -d <id>` (`flutter devices` lista los ids). `minSdk` es 23;
  Flutter 3.41 lo acepta con un aviso de deprecación.
- **iOS:** requiere Xcode completo y firmar la app con tu Apple ID (con una
  cuenta gratuita el perfil dura 7 días). Al agregar pods, verifica que
  `ios/Podfile` tenga `platform :ios, '13.0'`.

### Contra `mila-invest-api`

```bash
flutter run --dart-define=API_MODE=remote \
            --dart-define=API_BASE_URL=http://<host>:<puerto>/api/v1
```

- Emulador de Android: `<host>` = `10.0.2.2`. Teléfono físico: la IP de tu PC
  en la red local, y la API tiene que escuchar en `0.0.0.0` (Fastify escucha
  solo en `localhost` por defecto).
- HTTP sin TLS solo se permite en builds de debug. En iOS la excepción de ATS
  es solo para `localhost`: para un iPhone físico contra la IP de la PC, usa
  un túnel HTTPS (por ejemplo ngrok o cloudflared) o agrega
  `NSAllowsLocalNetworking` en `ios/Runner/Info-Debug.plist`.
- Si la API no cumple [`docs/api-contract.md`](docs/api-contract.md), la app
  lo muestra como `UNEXPECTED_RESPONSE`. Si el backend real difiere, manda el
  backend: se actualizan el contrato y `shared/fake_backend` en el mismo PR.

### Flags (`--dart-define`)

| Flag | Valores | Efecto |
|---|---|---|
| `API_MODE` | `fake` (default) / `remote` | backend falso en memoria o `DioApiClient` |
| `API_BASE_URL` | URL, default `http://localhost:8000/api/v1` | base del backend real |
| `FAKE_SEED` | `demo` (default) / `empty` | datos sembrados o usuario sin saldo ni posiciones |
| `FAST_ANIMATIONS` | `true` / ausente | todas las duraciones en cero |
| `PRICE_REFRESH_SECONDS` | entero, default `15`; `0` lo apaga | refresco de precios en el detalle |
| `ENABLE_SEMANTICS` | `true` / ausente | fuerza el árbol semántico (en web hace aparecer los `flt-semantics-identifier`) |

### Deep links

`milainvest://market/instrument/ECOPETROL-CO` en Android e iOS; en web, la
URL con path real (`/market/instrument/ECOPETROL-CO`). Sin sesión pasa por el
login y vuelve; un instrumento inexistente muestra "no encontrado".

**Hosting web:** el servidor tiene que devolver `index.html` para cualquier
ruta desconocida (fallback de SPA), o un F5 en una ruta profunda da 404.

## Scripts

| Comando | Qué hace |
|---|---|
| `melos bootstrap` | resuelve el workspace con el lockfile commiteado |
| `melos run lint` | `flutter analyze --no-fatal-infos` (cero issues) |
| `melos run dartFormat` | `dart format . --line-length 80` |
| `melos run test` | tests unitarios y de widget de todos los paquetes |
| `python3 scripts/new_package.py …` | crea un paquete del workspace y lo registra en el root |
| `python3 scripts/semantics_inventory.py` | regenera `docs/semantics-ids.md` desde los `*_ids.dart` |

## Limitaciones conocidas

- En web, `flutter_secure_storage` guarda los tokens en el almacenamiento del
  navegador, que no es un almacén seguro. Es aceptable porque la app es una
  simulación sin dinero real.
- Las fases 2 (órdenes límite, CDTs, fondos, divisas) y 3 (watchlists,
  alertas, ranking) no están implementadas; la estructura deja sus puntos de
  extensión.

## Documentación

- [`docs/architecture.md`](docs/architecture.md): capas, paquetes y reglas de dependencia.
- [`docs/decisions.md`](docs/decisions.md): decisiones tomadas y sus consecuencias.
- [`docs/api-contract.md`](docs/api-contract.md): contrato con `mila-invest-api`.
- [`docs/design-system.md`](docs/design-system.md): tokens, temas y componentes.
- [`docs/semantics-ids.md`](docs/semantics-ids.md): inventario de identificadores semánticos.
