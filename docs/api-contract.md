# Contrato con `mila-invest-api`

Backend: repo separado `mila-invest-api` (TypeScript + Fastify + Joi +
PostgreSQL), base `/api/v1`.

Si el backend real difiere, **manda el backend**: se actualiza este documento
y `shared/fake_backend` en el mismo PR.

## Convenciones

- Base `/api/v1`, JSON UTF-8, claves en `snake_case`.
- Auth: `Authorization: Bearer <access_token>`. El access token vive 15 min y
  el refresh 7 días, con **rotación**: cada refresh devuelve un par nuevo e
  invalida el refresh anterior.
- Dinero como string decimal (`"1234.56"`) más `currency` en ISO 4217.
  Porcentajes como string decimal (`"2.35"` es 2,35 %).
- Timestamps ISO 8601 UTC (`"2026-11-18T14:42:00Z"`).
- Paginación por cursor: query `cursor` y `limit` (default 20, máximo 100);
  respuesta `{ "items": [...], "next_cursor": "..." | null }`.
- `Idempotency-Key` (UUID) obligatorio en `POST /orders` y
  `POST /accounts/{currency}/deposits`. La misma clave con el mismo cuerpo
  devuelve la misma respuesta; con otro cuerpo, 409 `IDEMPOTENCY_CONFLICT`.
- 429 trae `Retry-After` en segundos.

## Endpoints de la Fase 1

| Método y ruta | Cuerpo / query | Respuesta |
|---|---|---|
| `POST /auth/register` | `email, password, full_name, country, document_type, document_number` | 201 `{ user, tokens }` |
| `POST /auth/login` | `email, password` | `{ access_token, refresh_token, token_type: "bearer", expires_in }` |
| `POST /auth/refresh` | `refresh_token` | par nuevo de tokens |
| `POST /auth/logout` | `refresh_token` | 204 |
| `GET /me` | — | `{ id, email, full_name, country, base_currency, document_type, document_last4 }` |
| `GET /meta/countries` | — | `[{ code, currency, time_zone, document_types, market: { status, opens_at, closes_at } }]` |
| `GET /accounts` | — | `[{ id, currency, available, reserved }]` |
| `POST /accounts/{currency}/deposits` | `amount` (+ `Idempotency-Key`) | 201 `transaction` |
| `GET /instruments` | `country, type (STOCK\|ETF), q, cursor, limit` | paginado de `instrument` |
| `GET /instruments/{id}` | — | `instrument` + `{ open, high, low, prev_close, volume, description }` |
| `GET /instruments/{id}/prices` | `range` = `1D\|1W\|1M\|3M\|1Y` | `{ range, currency, points: [{ t, price }] }` |
| `POST /orders/preview` | `instrument_id, side, type: "MARKET", quantity` | `{ estimated_price, gross, commission, total, currency, available_after, warnings: [] }` |
| `POST /orders` | igual que preview (+ `Idempotency-Key`) | 201 `order` |
| `GET /orders` | `status, cursor, limit` | paginado de `order` |
| `GET /orders/{id}` | — | `order` |
| `GET /portfolio` | — | `{ base_currency, total_value, cash_value, invested_value, day_change, day_change_pct, positions: [...], allocation: [{ type, value, pct }], fx_rates_used: [{ from, to, rate, as_of }] }` |
| `GET /transactions` | `type (DEPOSIT\|BUY\|SELL\|FEE), from, to, cursor, limit` | paginado de `transaction` |
| `GET /dashboard/summary` | — | `{ portfolio_summary, top_movers: { gainers: [...], losers: [...] }, recent_transactions: [...] }` |

### Formas principales

```json
// instrument
{ "id": "ECOPETROL-CO", "ticker": "ECOPETROL", "name": "Ecopetrol S.A.",
  "country": "CO", "type": "STOCK", "currency": "COP",
  "last_price": "2385.00", "change": "35.00", "change_pct": "1.49",
  "updated_at": "2026-11-18T14:42:00Z" }

// position
{ "instrument": { ...instrument }, "quantity": 120, "avg_cost": "2210.50",
  "market_value": "286200.00", "unrealized_pnl": "20940.00",
  "unrealized_pnl_pct": "7.89", "currency": "COP" }

// order
{ "id": "ord_01H...", "instrument_id": "ECOPETROL-CO", "side": "BUY",
  "type": "MARKET", "quantity": 10, "status": "FILLED",
  "executed_price": "2386.00", "gross": "23860.00", "commission": "5000.00",
  "total": "28860.00", "currency": "COP", "reject_code": null,
  "created_at": "2026-11-18T14:43:10Z", "filled_at": "2026-11-18T14:43:10Z" }

// transaction
{ "id": "txn_01H...", "type": "BUY", "amount": "-23860.00", "currency": "COP",
  "description": "Compra 10 ECOPETROL", "order_id": "ord_01H...",
  "created_at": "2026-11-18T14:43:10Z" }
```

Puntos de extensión de la fase 2 (no implementados): `POST /orders` con
`type: "LIMIT"` y `limit_price`, `DELETE /orders/{id}`, `/cdts`, `/funds`,
`/fx/quotes`, `/fx/conversions`.

## Errores

Todo error es `application/problem+json`:

```json
{ "type": "about:blank", "title": "Insufficient funds", "status": 422,
  "code": "INSUFFICIENT_FUNDS", "detail": "Available 12000.00 COP",
  "errors": [{ "field": "quantity", "code": "TOO_LARGE" }] }
```

| `code` | Status | Dónde se espera |
|---|---|---|
| `VALIDATION_ERROR` | 422 | cualquier formulario; trae `errors[]` por campo |
| `AUTH_INVALID_CREDENTIALS` | 401 | login |
| `AUTH_EMAIL_TAKEN` | 409 | registro |
| `AUTH_DOCUMENT_TAKEN` | 409 | registro |
| `AUTH_TOKEN_EXPIRED` | 401 | ruta protegida → refresh |
| `AUTH_TOKEN_INVALID` | 401 | token ausente o malformado → cerrar sesión |
| `AUTH_REFRESH_INVALID` | 401 | refresh → cerrar sesión |
| `INSUFFICIENT_FUNDS` | 422 | preview y orden de compra |
| `INSUFFICIENT_POSITION` | 422 | preview y orden de venta |
| `MARKET_CLOSED` | 422 | preview y orden |
| `INSTRUMENT_NOT_FOUND` | 404 | detalle → vista "no encontrado" |
| `ORDER_NOT_FOUND` | 404 | detalle de orden → vista "no encontrado" |
| `IDEMPOTENCY_CONFLICT` | 409 | orden, depósito |
| `RATE_LIMITED` | 429 | cualquiera |
| `INTERNAL_ERROR` | 500 | cualquiera |

Más los códigos de cliente `NETWORK_UNAVAILABLE`, `NETWORK_TIMEOUT` y
`UNEXPECTED_RESPONSE` (contrato roto). Un `code` desconocido se trata como
`INTERNAL_ERROR`, sin romper la app.
