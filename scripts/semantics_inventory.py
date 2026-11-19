#!/usr/bin/env python3
"""Genera docs/semantics-ids.md a partir de los archivos *_ids.dart.

Uso: python3 scripts/semantics_inventory.py

Lee cada `static const String x = '...';` (id estático) y cada
`static String x(...) => '...';` (id dinámico), con su comentario `///` como
nota. El tipo de elemento sale del sufijo del id (§11.1).
"""
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
SOURCES = [
    ("Shell", "packages/apps/mila_invest_app/lib/shell_ids.dart"),
    ("app_cross", "packages/features/generic/app_cross/constants/lib/app_cross_ids.dart"),
    ("authentication", "packages/features/generic/authentication/constants/lib/authentication_ids.dart"),
    ("dashboard", "packages/features/core/dashboard/constants/lib/dashboard_ids.dart"),
    ("market", "packages/features/core/market/constants/lib/market_ids.dart"),
    ("orders", "packages/features/core/orders/constants/lib/orders_ids.dart"),
    ("wallet", "packages/features/core/wallet/constants/lib/wallet_ids.dart"),
    ("portfolio", "packages/features/core/portfolio/constants/lib/portfolio_ids.dart"),
    ("transactions", "packages/features/core/transactions/constants/lib/transactions_ids.dart"),
]
TYPES = [
    ("_icon_button", "botón de ícono"),
    ("_button", "botón"),
    ("_field", "campo"),
    ("_toggle", "interruptor"),
    ("_checkbox", "checkbox"),
    ("_chip", "chip"),
    ("_segment", "segmento"),
    ("_tab", "tab"),
    ("_link", "link"),
    ("_stepper", "stepper"),
    ("_menu", "selector"),
    ("_text", "valor / texto"),
    ("_view", "raíz de vista"),
    ("_chart", "gráfico"),
    ("_dialog", "diálogo"),
    ("_sheet", "hoja"),
    ("_snackbar", "snackbar"),
    ("_tile", "tarjeta"),
    ("_panel", "panel"),
]
STATIC = re.compile(
    r"((?:\s*///[^\n]*\n)+)\s*static const String (\w+)\s*=\s*\n?\s*'([^']+)';"
)
DYNAMIC = re.compile(
    r"((?:\s*///[^\n]*\n)+)\s*static String (\w+)\(([^)]*)\)\s*=>\s*\n?\s*'([^']+)';"
)


def kind(identifier: str) -> str:
    if "_state_" in identifier:
        return "raíz de estado"
    if "_item_" in identifier:
        return "ítem / parte de ítem"
    for suffix, label in TYPES:
        if identifier.endswith(suffix):
            return label
    return "contenedor"


def note(comment: str) -> str:
    lines = [line.strip().removeprefix("///").strip() for line in comment.strip().splitlines()]
    return " ".join(line for line in lines if line).replace("|", "\\|")


def screen(identifier: str) -> str:
    parts = identifier.split("_")
    return "_".join(parts[:2]) if len(parts) > 2 else parts[0]


def main() -> None:
    out = [
        "# Inventario de identificadores semánticos",
        "",
        "Contrato público para automatización black-box (§11.1). Se actualiza en el",
        "**mismo PR** que agrega o cambia un id. Renombrar un id existente rompe el",
        "contrato y se anota en la sección *Cambios de contrato*.",
        "",
        "Este archivo se genera con `python3 scripts/semantics_inventory.py` a partir",
        "de los `*_ids.dart`; la nota de cada id es su comentario de documentación.",
        "",
        "Fuente única: `<feature>_constants/lib/<feature>_ids.dart` y, en el shell,",
        "`shell_ids.dart`. La `Key` de un widget es `ValueKey<String>(<id>)` con el",
        "mismo string.",
        "",
        "| Plataforma | Atributo expuesto |",
        "|---|---|",
        "| Android | `resource-id` |",
        "| iOS | `accessibilityIdentifier` |",
        "| Web | `flt-semantics-identifier` (requiere `--dart-define=ENABLE_SEMANTICS=true`) |",
        "",
        "Convención: la parte estática cumple `^[a-z][a-z0-9]*(_[a-z0-9]+)*$`; la parte",
        "dinámica es el id de la entidad tal como lo da la API",
        "(`market_list_instrument_item_ECOPETROL-CO`), nunca un índice ni texto traducido.",
        "",
        "Ids que entregan los componentes a partir del id de su raíz:",
        "",
        "| Componente | Id derivado |",
        "|---|---|",
        "| `AppTextField` | `<id del campo>_error_text` (mensaje de error del campo) |",
        "| `InstrumentTile` | `<id del ítem>_price_text`, `_change_text`, `_country_text` |",
        "",
    ]
    total = 0
    for title, path in SOURCES:
        text = (ROOT / path).read_text()
        out += [f"## {title}", "", f"Fuente: `{path}`", ""]
        rows = []
        for comment, name, value in STATIC.findall(text):
            rows.append((screen(value), f"`{value}`", kind(value), note(comment)))
        for comment, name, params, value in DYNAMIC.findall(text):
            pattern = re.sub(r"\$\{[^}]+\}", "<…>", value)
            pattern = re.sub(r"\$(\w+)", r"<\1>", pattern)
            rows.append((screen(pattern), f"`{pattern}`", kind(pattern), note(comment)))
        current = None
        for scr, ident, typ, nt in rows:
            if scr != current:
                if current is not None:
                    out.append("")
                out += [f"### `{scr}`", "", "| Id | Tipo | Nota |", "|---|---|---|"]
                current = scr
            out.append(f"| {ident} | {typ} | {nt} |")
            total += 1
        out.append("")
    out += [
        "## Cambios de contrato",
        "",
        "| Fecha | Id anterior | Id nuevo | Motivo |",
        "|---|---|---|---|",
        "| — | — | — | Versión inicial del contrato. |",
        "",
        f"_Total: {total} identificadores._",
        "",
    ]
    (ROOT / "docs/semantics-ids.md").write_text("\n".join(out))
    print(f"docs/semantics-ids.md: {total} identificadores")


if __name__ == "__main__":
    main()
