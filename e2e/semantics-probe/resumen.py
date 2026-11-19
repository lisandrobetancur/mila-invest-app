#!/usr/bin/env python3
"""Agrega results/*.jsonl en un resumen por caso y modo (results/resumen.txt).

No interpreta nada: cuenta cuántas de las N corridas dieron cada resultado.
"""
import collections, json, pathlib, re, sys

R = pathlib.Path(__file__).parent / "results"
filas = []
for f in sorted(R.glob("*.jsonl")):
    for l in f.read_text().splitlines():
        filas.append(json.loads(l))

def cuenta(rs, f):
    c = collections.Counter(json.dumps(f(r), ensure_ascii=False, sort_keys=True) for r in rs)
    n = len(rs)
    return " ; ".join(f"{k} → {v}/{n}" for k, v in c.most_common())

def grupo(pred):
    g = collections.defaultdict(list)
    for r in filas:
        if pred(r):
            g[(r["caso"], r["mode"])].append(r)
    return g

out = []
P = out.append

# ---------- A1..A5: matriz gap × delay ----------
ok = {
    "A1": lambda r: r["email"] == "demo@milainvest.app" and r["pass"] == "Demo1234!" and r["url"] == "/home",
    "A2": lambda r: r["final"] == {"name": "Ana Prueba", "email": "ana.prueba@example.com", "document": "1020304050", "password": "Clave1234"},
    "A3": lambda r: r["lecturas"]["+1000"]["campo"] == "eco" and r["lecturas"]["+1000"]["url"] == "/market?q=eco",
    "A3b": lambda r: r["final"] == "grupo aval",
    "A4": lambda r: re.sub(r"\D", "", r["final"] or "") == "250000",
    "A5": lambda r: r["final"] == "12",
}
dato = {
    "A1": lambda r: [r["email"], r["pass"], r["url"], r["focoTrasClick"], r["focoTrasEmail"], r["focoTrasPass"]],
    "A2": lambda r: [r["final"], r["focos"], r["focosTrasEnter"]],
    "A3": lambda r: r["lecturas"],
    "A3b": lambda r: [r["antesDeLaPausa"], r["trasLaPausa"], r["urlTrasLaPausa"], r["alTerminar"], r["final"], r["url"]],
    "A4": lambda r: [r["focoTrasClick"], r["alTerminar"], r["final"], r["foco"]],
    "A5": lambda r: [r["focoTrasClick"], r["antes"], r["alTerminar"], r["final"], r["foco"]],
}
for caso in ["A1", "A2", "A3", "A3b", "A4", "A5"]:
    P(f"\n===== {caso} =====")
    for mode in ["on", "off"]:
        rs = [r for r in filas if r["caso"] == caso and r["mode"] == mode]
        variantes = sorted({(r["gap"], r["delay"], r.get("gapEnter", False)) for r in rs})
        P(f"-- {mode}: texto completo, n/N por variante (gap, delay{', gapEnter' if caso == 'A2' else ''})")
        for v in variantes:
            sub = [r for r in rs if (r["gap"], r["delay"], r.get("gapEnter", False)) == v]
            n = sum(1 for r in sub if ok[caso](r))
            P(f"   gap={v[0]:>3} delay={v[1]:>2}{' +Enter' if v[2] else ''}: {n}/{len(sub)} completo")
            if n < len(sub) or (v[0], v[1]) in [(0, 0), (500, 50)]:
                P(f"        {cuenta(sub, dato[caso])}")
        ms = [r["msHastaElClick"] for r in rs if "msHastaElClick" in r]
        if ms:
            P(f"   ms hasta el click al campo: min {min(ms)} mediana {sorted(ms)[len(ms)//2]} max {max(ms)}")
        lay = collections.Counter(json.dumps(r["layout"], sort_keys=True) for r in rs)
        P(f"   layout ON vs OFF: {dict(lay)}")
        ap = collections.Counter(r.get("apagado") for r in rs)
        P(f"   árbol apagado al final: {dict(ap)}")

# ---------- A6..A10 ----------
for (caso, mode), rs in sorted(grupo(lambda r: re.match(r"A(6|7|8|9|10)", r["caso"])).items()):
    P(f"\n===== {caso} [{mode}] n={len(rs)} =====")
    if caso == "A8":
        P("   " + cuenta(rs, lambda r: {"antes": r["antes"], "trasClick": r["trasClick"], "trasX": r["trasX"]}))
    else:
        P("   " + cuenta(rs, lambda r: {"antes": r["antes"], "trasClick": r["trasClick"], "tecleado": r["tecleado"], "tipo": [r.get("tipoAntes"), r.get("tipoDespues")]}))
    P("   layout final ON vs OFF: " + cuenta(rs, lambda r: {k: round(v, 4) for k, v in r["layout"].items()}))

# ---------- B ----------
for (caso, mode), rs in sorted(grupo(lambda r: r["caso"].startswith("B")).items()):
    P(f"\n===== {caso} [{mode}] n={len(rs)} vp={rs[0]['vp']} =====")
    if "dys" in rs[0]:
        P("   " + cuenta(rs, lambda r: {"dys": r["dys"], "tops": r["tops"] if mode == "on" else None, "saltos": r["saltos"], "noScrollea": r["noScrollea"]}))
    elif "msUpANavegacion" in rs[0]:
        ms = sorted(r["msUpANavegacion"] for r in rs if r["msUpANavegacion"] is not None)
        P(f"   ms pointerup → pushState: {ms} ; url: {cuenta(rs, lambda r: r['url'])}")
    else:
        P("   " + cuenta(rs, lambda r: {"abrioDetalle": r["abrioDetalle"], "retencionPx": r["retencionPx"], "primerMovimiento_dedo": r["primerMovimiento"] and r["primerMovimiento"]["dedo"]}))
        P(f"   t primer movimiento (ms): {sorted(r['primerMovimiento']['t'] for r in rs if r['primerMovimiento'])} ; lista al soltar: {[r['listaAlSoltar'] for r in rs]} ; lista final: {[r['listaFinal'] for r in rs]} ; ms del gesto: {[r['msDelGesto'] for r in rs]}")
    P("   layout: " + cuenta(rs, lambda r: {k: round(v, 4) for k, v in r["layout"].items()}))

# ---------- C ----------
g = collections.defaultdict(list)
for r in filas:
    if r["caso"].startswith("C"):
        g[(r["caso"], r["mode"], r.get("entrega", "-"), r.get("objetivo", "-"))].append(r)
for k, rs in sorted(g.items()):
    P(f"\n===== {k[0]} [{k[1]}] entrega={k[2]} objetivo={k[3]} n={len(rs)} =====")
    quita = {"caso", "test", "mode", "vp", "rep", "layout", "idsConModal", "tappables", "entrega", "objetivo", "msDesdeElSnackbar", "cajaSinModal"}
    P("   " + cuenta(rs, lambda r: {a: b for a, b in r.items() if a not in quita}))
    if "idsConModal" in rs[0]:
        P("   ids con el modal abierto: " + cuenta(rs, lambda r: r["idsConModal"]))

# ---------- D1 ----------
for (caso, mode), rs in sorted(grupo(lambda r: r["caso"].startswith("D1")).items()):
    P(f"\n===== {caso} [{mode}] n={len(rs)} =====")
    quita = {"caso", "test", "mode", "vp", "rep", "layout"}
    P("   " + cuenta(rs, lambda r: {a: (round(b, 3) if isinstance(b, float) else b) for a, b in r.items() if a not in quita}))

# ---------- D2 ----------
d2 = R / "D2.json"
if d2.exists():
    d = json.loads(d2.read_text())
    doc = (pathlib.Path(__file__).parent / "../../docs/semantics-ids.md").read_text()
    inv = re.findall(r"^\| `([^`]+)` \|", doc, re.M)
    vistos = set(i for v in d["vistos"].values() for i in v)
    est = [i for i in inv if "<" not in i]
    din = [i for i in inv if "<" in i]
    P("\n===== D2 =====")
    P(f"   inventario: {len(est)} estáticos, {len(din)} dinámicos ; ids distintos en el DOM: {len(vistos)} ; pasos fallidos: {d['fallos']}")
    falt = [i for i in est if i not in vistos]
    P(f"   estáticos que no aparecieron ({len(falt)}):")
    for i in falt:
        P(f"      {i}")
    P("   dinámicos:")
    for patron in din:
        if patron.startswith("<…>"):
            suf = patron.replace("<…>", "")
            n = sum(1 for v in vistos if v.endswith(suf))
            P(f"      {patron}: {n} ids con ese sufijo")
        else:
            rx = re.compile("^" + re.sub(r"<[^>]+>", "(.+)", re.escape(patron).replace(r"\<", "<").replace(r"\>", ">")) + "$")
            n = [v for v in vistos if rx.match(v) and not re.search(r"_(text)$", v)]
            P(f"      {patron}: {len(n)} ids")
    extra = sorted(v for v in vistos if v not in est and not any(v.startswith(p.split('<')[0]) for p in din if not p.startswith('<…>')) and not v.endswith("_error_text"))
    P(f"   en el DOM y no en el inventario: {extra}")
    P("   ids por estado: " + json.dumps({k: len(v) for k, v in d["vistos"].items()}, ensure_ascii=False))

(R / "resumen.txt").write_text("\n".join(out) + "\n")
print("\n".join(out))
