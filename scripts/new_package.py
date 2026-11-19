#!/usr/bin/env python3
"""Crea el esqueleto de un paquete del workspace y lo registra en el root.

Uso: new_package.py <ruta> <nombre> "<descripción>" [dep[:versión] ...]
     [--dev dep[:versión] ...] [--assets]

Las dependencias internas van sin versión (se les pone 0.1.0); `flutter`,
`flutter_test` y `lint` se agregan solos.
"""
import pathlib
import sys

PINNED = {
    "collection": "1.19.1",
    "cupertino_icons": "1.0.8",
    "decimal": "3.2.6",
    "dio": "5.11.1",
    "easy_localization": "3.0.8",
    "equatable": "2.1.0",
    "fl_chart": "1.3.1",
    "flutter_riverpod": "2.6.1",
    "flutter_secure_storage": "11.2.0",
    "go_router": "17.3.0",
    "intl": "0.20.2",
    "logger": "2.6.2",
    "mocktail": "1.0.5",
    "shared_preferences": "2.5.3",
    "shimmer": "3.0.0",
    "uuid": "4.5.2",
}
SDK = {"flutter", "flutter_test", "flutter_web_plugins"}


def entry(name: str) -> str:
    if name in SDK:
        return f"  {name}:\n    sdk: flutter"
    return f"  {name}: {PINNED.get(name, '0.1.0')}"


def main() -> None:
    args = sys.argv[1:]
    path, name, description = args[0], args[1], args[2]
    rest = args[3:]
    dev: list[str] = []
    if "--dev" in rest:
        index = rest.index("--dev")
        rest, dev = rest[:index], rest[index + 1 :]
    deps = sorted(set(rest) | {"flutter"})
    dev_deps = sorted(set(dev) | {"flutter_test", "lint"})
    root = pathlib.Path(__file__).resolve().parent.parent
    package = root / path
    (package / "lib").mkdir(parents=True, exist_ok=True)
    (package / "pubspec.yaml").write_text(
        f"name: {name}\n"
        f"description: {description}\n"
        "publish_to: none\n"
        "version: 0.1.0\n"
        "resolution: workspace\n\n"
        "environment:\n  sdk: ^3.11.5\n\n"
        "dependencies:\n" + "\n".join(entry(d) for d in deps) + "\n\n"
        "dev_dependencies:\n" + "\n".join(entry(d) for d in dev_deps) + "\n"
    )
    (package / "analysis_options.yaml").write_text(
        "include: package:lint/analysis_options.yaml\n"
    )
    pubspec = root / "pubspec.yaml"
    lines = pubspec.read_text().split("\n")
    start = lines.index("workspace:") + 1
    end = start
    while end < len(lines) and lines[end].startswith("  - "):
        end += 1
    members = sorted(set(lines[start:end]) | {f"  - {path}"})
    pubspec.write_text("\n".join(lines[:start] + members + lines[end:]))


if __name__ == "__main__":
    main()
