#!/usr/bin/env python3
"""Sirve el build web con fallback de SPA (para pruebas locales y E2E).

Uso: python3 scripts/serve_web.py [puerto] [directorio] [host]

Por defecto escucha solo en 127.0.0.1. Con host `0.0.0.0` queda accesible
desde otros equipos de la red local (http://<IP-de-esta-PC>:<puerto>).

Cualquier ruta que no sea un archivo existente devuelve `index.html`, igual
que debe hacer el hosting real; así un F5 o un deep link en una ruta profunda
(`/market/instrument/ECOPETROL-CO`) no da 404.
"""
import functools
import http.server
import os
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
ROOT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "..",
    "packages",
    "apps",
    "mila_invest_app",
    "build",
    "web",
)
HOST = sys.argv[3] if len(sys.argv) > 3 else "127.0.0.1"


class SpaHandler(http.server.SimpleHTTPRequestHandler):
    def send_head(self):
        path = self.translate_path(self.path)
        if not os.path.exists(path) or (
            os.path.isdir(path) and not os.path.exists(os.path.join(path, "index.html"))
        ):
            self.path = "/index.html"
        return super().send_head()


if __name__ == "__main__":
    handler = functools.partial(SpaHandler, directory=os.path.abspath(ROOT))
    with http.server.ThreadingHTTPServer((HOST, PORT), handler) as server:
        print(f"MILA Invest web en http://{HOST}:{PORT} (sirviendo {ROOT})")
        server.serve_forever()
