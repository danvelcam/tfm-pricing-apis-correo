# -*- coding: utf-8 -*-
"""
Figura de la curva de capacidad C(t) para el capítulo 5 (§5.3, OBJ-04, D-021).

Todo lo que se ve lo produce PRIME4API (TFM de Gavira Sánchez), ejecutado como biblioteca
sobre las Datasheets reales del catálogo:
  - `DatasheetEvaluatorService.get_curve_scenarios` lee el YAML y construye los escenarios
    (rate, cuota y CRF por endpoint);
  - `CapacityCurveService.render_inflection_point_curve_html` calcula la curva del
    BoundedRate y la dibuja con el renderizador Plotly del propio motor
    (`app/utils/plotly_renderer.py`, el que sirven sus endpoints /chart/*).
Este script solo captura la figura Plotly que el motor construye y la guarda en JSON
(`fig.to_json()`), sin tocar trazas, colores ni ejes. La rasterización a PNG se hace aparte
con `plotly.io.write_image` (kaleido + Chromium), en la máquina que tenga Chrome.

Uso, fase 1 (donde esté el clon de PRIME4API que deja verificar_prime4api.py):
    python3 05_salida/_herramientas/gen_fig_capacidad.py dump 05_salida/_cap5/capacidad_figs/
Fase 2 (donde haya Chrome/Chromium; pip install plotly kaleido):
    python3 05_salida/_herramientas/gen_fig_capacidad.py png 05_salida/_cap5/capacidad_figs/ 02_overleaf/proyecto/fig/

Dependencias fase 1: las de verificar_prime4api.py (fastapi pydantic pyyaml numpy plotly).

Fase «servicio» (2026-09-07): los paneles de PANELES (entonces cuatro; hoy los ocho de la Figura 5.1
y la escalera de la 5.2) pedidos por REST al PRIME4API que despliega
SPHERE (imagen rgavira123/prime4api, puerto 8003 del compose de testing), guardando el HTML del
motor y los puntos, y comparando las trazas Plotly con las del `dump`. Hasta D-035 (2026-09-14)
SendGrid se pedía dos veces, porque su Datasheet repetía quota y rate en el endpoint y el motor
los sumaba; con la regla B8 la Datasheet ya no los repite y la variante deja de existir.
    python3 05_salida/_herramientas/gen_fig_capacidad.py servicio 05_salida/_cap5/capacidad_figs/ [http://localhost:8003]
Dependencias: requests.

Fase «extraer» + «png» sobre el servicio (2026-09-07, noche; el autor: «tenemos que meterlo en la memoria»):
la Figura 5.1 pasa a ser la que dibuja el PRIME4API de SPHERE. `extraer` saca de cada HTML del
servicio la figura Plotly (data + layout de `Plotly.newPlot`) a `sphere/png/<nombre>.json`, sin
tocarla. `png` la rasteriza; como el servicio deja
`width` en autosize, se exporta a 1000×460 (el `height` del propio motor) con scale=2.
    python3 05_salida/_herramientas/gen_fig_capacidad.py extraer 05_salida/_cap5/capacidad_figs/
    docker run --rm -v "$PWD":/w -w /w python:3.12-slim sh -c 'pip install -q plotly==5.24.1 kaleido==0.2.1 && \
        python3 05_salida/_herramientas/gen_fig_capacidad.py png 05_salida/_cap5/capacidad_figs/sphere/png/ 02_overleaf/proyecto/fig/'

Fase «png_es» (2026-10-25, revisión del PDF): la misma rasterización con rótulos en español y
letra legible al tamaño impreso, a ficheros con fecha junto a los anteriores (ver `rotulos_es`).
    docker run --rm -v "$PWD":/w -w /w python:3.12-slim sh -c 'pip install -q plotly==5.24.1 kaleido==0.2.1 && \
        python3 05_salida/_herramientas/gen_fig_capacidad.py png_es 05_salida/_cap5/capacidad_figs/sphere/png/ 02_overleaf/proyecto/fig/ 2026-10-25'

Alias de estado (D-025, 2026-09-10): una Datasheet con aliases devuelve una curva por alias,
así que el panel dice cuál dibuja. Por defecto `healthy_reputation` (constante `ALIAS`), el
estado nominal y el de la Figura 5.1; `--alias NOMBRE` lo cambia en `dump` y en `servicio`, y
`--alias ""` deja pasar todos los aliases. Las Datasheets sin aliases (Resend, SendGrid) no
llevan filtro: el motor aborta si se filtra por alias un endpoint que no tiene ninguno.
"""
import sys, io, os, json, contextlib

# (slug, plan, endpoint, crf, intervalo que hace visible el codo, dimensión, nombre)
# Los de dimensión `emails` (ocho) son los de la Figura 5.1; el de `requests` es la escalera de la Figura 5.2.
PANELES = [
    ("resend",   "pro",        "/emails",       1.0,    "3 hours",    "emails", "resend_pro_k1"),
    ("resend",   "pro",        "/emails",       50.0,   "5 minutes",  "emails", "resend_pro_k50"),
    ("sendgrid", "essentials", "/v3/mail/send", 1.0,    "15 seconds", "emails", "sendgrid_essentials_k1"),
    ("sendgrid", "essentials", "/v3/mail/send", 1000.0, "5 seconds",  "emails", "sendgrid_essentials_k1000"),
    # MailerSend (2026-09-08): primer plan de pago Hobby, /v1/email, k = 1 y k máx (50 to + 10 cc + 10 bcc)
    ("mailersend", "hobby",    "/v1/email",     1.0,    "1 hour",     "emails", "mailersend_hobby_k1"),
    ("mailersend", "hobby",    "/v1/email",     70.0,   "1 minute",   "emails", "mailersend_hobby_k70"),
    # D-036 (2026-09-14): el mismo plan, la misma llamada y la dimensión `requests`, donde sí
    # entra la cuota diaria de 1.000 peticiones del plan (H1). A k = 1 una petición es un correo,
    # así que la escalera se lee en correos. Va con H1 en §5.4, fuera de la Figura 5.1.
    ("mailersend", "hobby",    "/v1/email",     1.0,    "5 days",   "requests", "mailersend_hobby_k1_peticiones"),
    # Amazon SES (2026-09-22): el entorno de pruebas, único estado que el proveedor cifra.
    # k = 1 y k = 50 (el tope de destinatarios por mensaje sumando to, cc y bcc). Los cuatro
    # planes devuelven la misma curva, así que el panel dibuja `pro`, el primero con precio.
    ("ses",        "pro",       "/v2/email/outbound-emails", 1.0,  "10 minutes", "emails", "ses_pro_k1"),
    ("ses",        "pro",       "/v2/email/outbound-emails", 50.0, "15 seconds", "emails", "ses_pro_k50"),
]
VENTANA = "1 month"   # para el JSON de puntos sobre la ventana completa (30 días en el motor)

# Paneles cuyo HTML trae más de una figura: qué contenedor del documento del motor se extrae.
# Con `show_derived_requests` el motor dibuja una figura por CRF del rango (crf_0, crf_1, …)
# más la superpuesta (crf_ov), y el panel de la escalera es el primer CRF, k = 1.
CONTENEDOR = {"mailersend_hobby_k1_peticiones": "dim_requests_crf_0"}

# Alias de estado de cuenta que dibujan los paneles cuando la Datasheet los declara (D-025:
# MailerSend trae healthy_reputation, under_review_reputation y unapproved_account, y el motor
# devuelve una curva por alias). Por defecto `healthy_reputation`, el estado nominal y el de la
# Figura 5.1 del capítulo 5; se cambia con --alias NOMBRE, y --alias "" quita el filtro.
ALIAS = "healthy_reputation"
# El alias no se llama igual en todas las Datasheets, y `ALIAS` es uno solo para toda la
# tanda. Este diccionario lo sobreescribe por API: SES llama `sandbox` a su estado de
# pruebas, que es el único que el proveedor cifra. Las que no aparecen usan `ALIAS`.
ALIAS_POR_SLUG = {"ses": "sandbox"}
# `_KNOWN_ENDPOINT_KEYS` del motor (app/services/datasheet_evaluator_service.py): todo sub-dict
# del endpoint que no sea uno de estos es un alias.
CLAVES_ENDPOINT = {"rate", "quota", "workload", "cost_per_request"}


def uuid_de_contenedor(html, sufijo):
    """`id` del div de Plotly que vive dentro del contenedor cuyo `id` acaba en `sufijo`.

    El HTML del motor trae una figura por CRF más la superpuesta (`crf_ov`), todas en el
    mismo documento, así que no vale con quedarse con la primera.
    """
    import re
    m = re.search(r'<div id="[^"]*' + re.escape(sufijo) + r'"', html)
    if not m:
        raise LookupError(f"el HTML no trae ningún contenedor que acabe en `{sufijo}`")
    g = re.search(r'<div id="([^"]+)" class="plotly-graph-div"', html[m.end():])
    if not g:
        raise LookupError(f"el contenedor `{sufijo}` no trae ninguna figura de Plotly")
    return g.group(1)


def escenario_de(escenarios, unidad, crf, alias):
    """El escenario del motor que pide un panel: dimensión, CRF y alias.

    La dimensión es del panel y no una constante: la Datasheet de MailerSend declara la
    cuota diaria del plan en `requests` y la mensual del endpoint en `emails`, y el motor
    devuelve una curva por dimensión sin cruzarlas (hallazgo H1).
    """
    for s in escenarios:
        if (s.get("dimension") == unidad and float(s["crf"]) == float(crf)
                and s.get("alias") == alias):
            return s
    raise LookupError(f"sin escenario para dimension={unidad} crf={crf} alias={alias}; "
                      f"hay {sorted({(s.get('dimension'), s.get('alias')) for s in escenarios})}")


def fijar_alias(pedido):
    """Fija `ALIAS = pedido` y vacía `ALIAS_POR_SLUG` (la opción --alias)."""
    global ALIAS
    ALIAS = pedido
    ALIAS_POR_SLUG.clear()


def alias_de(slug, endpoint):
    """El alias de esa API si ese endpoint lo declara; None si la Datasheet no usa aliases."""
    quiero = ALIAS_POR_SLUG.get(slug, ALIAS)
    if not quiero:
        return None
    import yaml
    with io.open(f"03_datos/apis/{slug}/datasheet.yaml", encoding="utf-8") as f:
        y = yaml.safe_load(f) or {}
    declarados = set()
    for plan in (y.get("plans") or {}).values():
        ep = ((plan or {}).get("endpoints") or {}).get(endpoint) or {}
        declarados |= {k for k, v in ep.items() if isinstance(v, dict) and k not in CLAVES_ENDPOINT}
    if declarados and quiero not in declarados:
        sys.exit(f"El endpoint {endpoint} de «{slug}» no declara el alias «{quiero}»; "
                 f"declara: {sorted(declarados)}")
    return quiero if declarados else None


def dump(outdir):
    CACHE = os.path.expanduser("~/.cache/atf/prime4api")
    sys.path.insert(0, CACHE)
    import plotly.graph_objects as go
    capturadas = []
    _orig = go.Figure.to_html
    def _cap(self, *a, **k):            # el renderizador del motor devuelve HTML; se captura la figura
        capturadas.append(self)
        return _orig(self, *a, **k)
    go.Figure.to_html = _cap

    from app.services.datasheet_evaluator_service import DatasheetEvaluatorService
    from app.services.capacity_curve_service import CapacityCurveService
    from app.schemas.datasheet import EvaluateDatasheetRequest
    from app.utils.yaml_utils import load_yaml_source
    SVC, CURVE = DatasheetEvaluatorService(), CapacityCurveService()

    os.makedirs(outdir, exist_ok=True)
    puntos = []
    for slug, plan, ep, crf, intervalo, unidad, nombre in PANELES:
        with io.open(f"03_datos/apis/{slug}/datasheet.yaml", encoding="utf-8") as f:
            y = load_yaml_source(f.read())
        alias = alias_de(slug, ep)
        req = EvaluateDatasheetRequest(datasheet_source="-", operation="limits",
                                       plan_names=[plan], endpoint_path=ep, alias=alias)
        with contextlib.redirect_stdout(io.StringIO()):
            sc = escenario_de(SVC.get_curve_scenarios(y, req), unidad, crf, alias)
            capturadas.clear()
            # Listas completas, como hace el servicio REST: un escenario puede traer más de una
            # cuota (Hobby en `requests` lleva la diaria del plan y la mensual del endpoint).
            html = CURVE.render_inflection_point_curve_html(intervalo, sc["rates"], sc["quotas"])
            pts = CURVE.get_inflection_point_capacity_curve(VENTANA, sc["rates"], sc["quotas"])
        fig = capturadas[0]
        with io.open(os.path.join(outdir, nombre + ".json"), "w", encoding="utf-8") as f:
            f.write(fig.to_json())
        with io.open(os.path.join(outdir, nombre + ".html"), "w", encoding="utf-8") as f:
            f.write(html)
        techo = max(q.value for q in sc["quotas"])
        t = [x / 1000.0 for x in pts.t_ms]
        puntos.append({"api": slug, "plan": plan, "endpoint": ep, "alias": alias, "k": crf,
                       "dimension": unidad, "intervalo_figura": intervalo,
                       "rates": [r.value for r in sc["rates"]],
                       "quotas": [q.value for q in sc["quotas"]], "ventana_s": 2592000,
                       "t_s": t, "capacity": list(pts.capacity),
                       "t_min_s": next((tt for tt, cc in zip(t, pts.capacity) if cc >= techo), None)})
        print(f"  {nombre}: alias={alias} t_min={puntos[-1]['t_min_s']} s (ventana {VENTANA}), "
              f"figura sobre {intervalo}")
    with io.open(os.path.join(outdir, "capacidad_puntos.json"), "w", encoding="utf-8") as f:
        json.dump({"generado_por": "PRIME4API DatasheetEvaluatorService + CapacityCurveService (biblioteca, local)",
                   "renderizador": "app/utils/plotly_renderer.render_capacity_curve_html",
                   "ventana_puntos": VENTANA, "paneles": puntos}, f, ensure_ascii=False, indent=1)
    print("escrito", outdir)


def png(indir, figdir, solo=()):
    """Rasteriza los paneles; `solo` limita a los nombres que se le pasen."""
    import plotly.io as pio
    for *_, nombre in PANELES:
        if solo and nombre not in solo:
            continue
        with io.open(os.path.join(indir, nombre + ".json"), encoding="utf-8") as f:
            fig = pio.from_json(f.read())
        out = os.path.join(figdir, f"capacidad_{nombre}.png")
        if fig.layout.width is None:      # figura del servicio: autosize; tamaño solo para la exportación
            fig.write_image(out, width=1000, height=fig.layout.height or 460, scale=2)
        else:                             # figura de la biblioteca: 1000×600 ya fijados por el motor
            fig.write_image(out, scale=2)
        print("escrito", out)


# Revisión del PDF (2026-10-25, A7 y M3): los rótulos del motor salen en inglés y con letra de
# 12 px sobre un lienzo de 1000 px, que en la página mide unos 3 pt. `png_es` exporta los mismos
# paneles con los rótulos en español y la letra a tamaño de lectura. Solo toca el `layout`
# (textos, tamaños, separadores y márgenes); las trazas salen tal como las dibujó el motor.
ROTULOS_ES = {"Capacity": "Capacidad", "Time (h)": "Tiempo (h)", "Time (min)": "Tiempo (min)",
              "Time (s)": "Tiempo (s)", "Time (day)": "Tiempo (días)"}
# Ancho y alto de exportación en px por panel: el de la Figura 5.1 entra a 0,42\textwidth y la
# escalera a 0,72\textwidth. Con LETRA_ES px sobre ese ancho la letra impresa ronda los 8 pt.
# Los ocho paneles van a 520 × 245 para que la Figura 5.1 quepa en una página con su pie.
ANCHO_ES = {"mailersend_hobby_k1_peticiones": (900, 400)}
ANCHO_ES_DEFECTO, LETRA_ES = (520, 245), 23


def rotulos_es(layout, letra=LETRA_ES):
    """Devuelve una copia del layout (dict) con rótulos en español y letra de `letra` px."""
    out = json.loads(json.dumps(layout))
    for eje in ("xaxis", "yaxis"):
        t = out.setdefault(eje, {}).setdefault("title", {})
        t["text"] = ROTULOS_ES.get(t.get("text"), t.get("text"))
        t["font"] = {"size": letra}
        out[eje]["tickfont"] = {"size": letra}
    out["yaxis"]["ticksuffix"] = " "    # separa los números del eje y del 0 del eje x
    out["yaxis"]["tickformat"] = ",d"  # 5.000 y 50.000, con punto de miles (revisión del PDF, R1)
    titulo = out.get("title") or {}
    if titulo.get("text", "").startswith("CRF = "):
        crf = float(titulo["text"][6:])
        titulo["text"] = "CRF = " + (f"{crf:,.0f}".replace(",", ".") if crf.is_integer() else str(crf).replace(".", ","))
    titulo["font"] = {"size": letra}
    out["title"] = titulo
    out["font"] = {"size": letra}
    out["separators"] = ",."
    out["margin"] = {"t": int(letra * 2.2), "b": int(letra * 2.8), "l": int(letra * 5.2), "r": int(letra * 0.8)}
    return out


def png_es(indir, figdir, fecha, solo=()):
    """Como `png`, con `rotulos_es`, a `capacidad_<nombre>_<fecha>.png` junto a la anterior."""
    import plotly.io as pio
    for *_, nombre in PANELES:
        if solo and nombre not in solo:
            continue
        with io.open(os.path.join(indir, nombre + ".json"), encoding="utf-8") as f:
            d = json.load(f)
        d["layout"] = rotulos_es(d["layout"])
        fig = pio.from_json(json.dumps(d))
        out = os.path.join(figdir, f"capacidad_{nombre}_{fecha}.png")
        ancho, alto = ANCHO_ES.get(nombre, ANCHO_ES_DEFECTO)
        fig.write_image(out, width=ancho, height=alto, scale=3)
        print("escrito", out)


def _trazas(html):
    import re
    m = re.search(r"Plotly\.newPlot\(\s*[^,]+,\s*(\[.*?\])\s*,\s*\{", html, re.S)
    return [(t.get("x"), t.get("y")) for t in json.loads(m.group(1))] if m else None


def servicio(figdir, base="http://localhost:8003"):
    import requests, re
    U = base + "/api/v1/datasheet/capacity-curves"
    out = os.path.join(figdir, "sphere")
    os.makedirs(out, exist_ok=True)
    yamls = {}
    for slug in {p[0] for p in PANELES}:
        yamls[slug] = io.open(f"03_datos/apis/{slug}/datasheet.yaml", encoding="utf-8").read()
    for slug, plan, ep, crf, intervalo, unidad, nombre in PANELES:
        alias = alias_de(slug, ep)
        body = {"datasheet_source": yamls[slug], "plan_names": [plan], "endpoint_path": ep}
        if alias:
            body["alias"] = alias
        chart = {"time_interval": intervalo, "capacity_request_factor": crf, "capacity_unit": unidad}
        datos = {"time_interval": VENTANA, "capacity_request_factor": crf, "capacity_unit": unidad}
        if unidad == "requests":
            # El renderizador del motor oculta por defecto la dimensión `requests` derivada de
            # un workload (`show_derived_requests` en plotly_renderer); sin esto devuelve un
            # documento sin ninguna figura. El endpoint de datos no la oculta.
            chart["show_derived_requests"] = "true"
        h = requests.post(U + "/chart/inflection", params=chart, json=body, timeout=120)
        d = requests.post(U + "/data/inflection", params=datos, json=body, timeout=120)
        h.raise_for_status(); d.raise_for_status()
        io.open(os.path.join(out, nombre + ".html"), "w", encoding="utf-8").write(h.text)
        with io.open(os.path.join(out, nombre + "_data.json"), "w", encoding="utf-8") as f:
            json.dump(d.json(), f, indent=1)
        ruta_ref = os.path.join(figdir, nombre + ".json")
        ref = _trazas_json(ruta_ref) if os.path.exists(ruta_ref) else None
        srv = _trazas(h.text)
        series = d.json()["series"]
        s = next(x for x in series if float(x.get("capacity_request_factor", crf)) == crf)
        if srv is None:
            cotejo = "sin trazas en el HTML"
        elif ref is None:
            cotejo = "sin dump de referencia"
        else:
            cotejo = "sí" if srv == ref else "NO"
        print(f"  {nombre}: alias={s.get('alias')} dim={s.get('dimension')} series={len(series)} "
              f"rates={len(s['rates'])} quotas={len(s['quotas'])} "
              f"trazas iguales a dump={cotejo} "
              f"puntos={[(t/1000, c) for t, c in zip(s['t_ms'], s['capacity'])]}")


def extraer(figdir):
    """HTML del servicio → JSON de la figura Plotly (data + layout), sin modificarla."""
    import re
    src = os.path.join(figdir, "sphere")
    out = os.path.join(src, "png")
    os.makedirs(out, exist_ok=True)
    for slug, *_, nombre in PANELES:
        fichero = nombre + ".html"
        html = io.open(os.path.join(src, fichero), encoding="utf-8").read()
        if nombre in CONTENEDOR:
            uid = uuid_de_contenedor(html, CONTENEDOR[nombre])
            patron = r'Plotly\.newPlot\(\s*"' + re.escape(uid) + r'"\s*,\s*(\[.*?\])\s*,\s*(\{.*?\})\s*,\s*\{'
        else:
            patron = r"Plotly\.newPlot\(\s*[^,]+,\s*(\[.*?\])\s*,\s*(\{.*?\})\s*,\s*\{"
        m = re.search(patron, html, re.S)
        fig = {"data": json.loads(m.group(1)), "layout": json.loads(m.group(2))}
        with io.open(os.path.join(out, nombre + ".json"), "w", encoding="utf-8") as f:
            json.dump(fig, f, ensure_ascii=False)
        print(f"  {nombre}: {fichero} → png/{nombre}.json (trazas={len(fig['data'])}, título={fig['layout'].get('title',{}).get('text')})")


def _trazas_json(path):
    with io.open(path, encoding="utf-8") as f:
        return [(t.get("x"), t.get("y")) for t in json.load(f)["data"]]


def _opcion(args, nombre, defecto):
    """--nombre valor (o --nombre=valor) dentro de args; lo elimina de la lista."""
    for j, a in enumerate(args):
        if a == nombre and j + 1 < len(args):
            v = args[j + 1]; del args[j:j + 2]; return v
        if a.startswith(nombre + "="):
            v = a.split("=", 1)[1]; del args[j]; return v
    return defecto


if __name__ == "__main__":
    argv = sys.argv[1:]
    pedido = _opcion(argv, "--alias", None)   # «» = sin filtro: una curva por alias
    if pedido is not None:
        fijar_alias(pedido)
    solo = _opcion(argv, "--solo", "")        # nombres de panel separados por comas
    if solo:
        quiero = set(solo.split(","))
        PANELES[:] = [p for p in PANELES if p[-1] in quiero]
        if not PANELES:
            sys.exit(f"--solo {solo} no casa con ningún panel")
    sys.argv = [sys.argv[0]] + argv
    if sys.argv[1] == "dump":
        dump(sys.argv[2])
    elif sys.argv[1] == "servicio":
        servicio(sys.argv[2], *sys.argv[3:4])
    elif sys.argv[1] == "extraer":
        extraer(sys.argv[2])
    elif sys.argv[1] == "png":
        png(sys.argv[2], sys.argv[3], tuple(sys.argv[4:]))
    elif sys.argv[1] == "png_es":
        png_es(sys.argv[2], sys.argv[3], sys.argv[4], tuple(sys.argv[5:]))
    else:
        print(__doc__)
