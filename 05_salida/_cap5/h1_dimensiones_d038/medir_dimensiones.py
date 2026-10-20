# -*- coding: utf-8 -*-
"""Qué límites entran en cada dimensión de la curva de capacidad (H1, D-038).

Pide al PRIME4API que despliega SPHERE en local (`localhost:8003`, contenedor
`prime4api-sphere`) la curva de MailerSend Hobby `/v1/email`, la única Datasheet del
catálogo con cuotas en dos unidades, y anota qué `rates` y qué `quotas` devuelve cada
dimensión. El motor convierte entre unidades con el CRF del `workload`; lo que se mide
aquí es en qué conversiones lo aplica y en cuál no.

Tres medidas:
  1. `data/inflection` con `capacity_unit` en `emails` y en `requests`, con k = 1 y k = 70,
     que es de donde sale la matriz de conversiones.
  2. `data/inflection` sin `capacity_unit`, la llamada de quien no filtra: devuelve las dos
     dimensiones por CRF.
  3. `chart/inflection`, el mismo documento que sirve el renderizador, con y sin
     `show_derived_requests` y sin filtrar: cuántas figuras trae y de qué dimensión.

Uso (con SPHERE levantado; solo biblioteca estándar):
    python3 05_salida/_cap5/h1_dimensiones_d038/medir_dimensiones.py [salida/] [http://localhost:8003]

Deja un JSON por llamada de datos y escribe el resumen por la salida estándar.
"""
import io
import json
import os
import re
import sys
import urllib.parse
import urllib.request

YAML = "03_datos/apis/mailersend/datasheet.yaml"
PLAN, ENDPOINT, ALIAS = "hobby", "/v1/email", "healthy_reputation"
VENTANA = "1 month"      # ventana de la curva en las medidas de datos
VENTANA_FIG = "5 days"   # la de la Figura 5.2, para el documento del renderizador


def _pedir(base, ruta, cuerpo, params, crudo=False):
    url = "%s/api/v1/datasheet/capacity-curves/%s?%s" % (
        base, ruta, urllib.parse.urlencode(params))
    peticion = urllib.request.Request(
        url, data=json.dumps(cuerpo).encode(),
        headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(peticion, timeout=120) as r:
        return (r.status, r.read().decode()) if crudo else json.load(r)


def _limites(serie):
    """Los límites de una serie, en una línea legible."""
    def _uno(l):
        return "%g %s/%s" % (l["value"], l["unit"], l["period"])
    return "rates: %s | quotas: %s" % (
        ", ".join(_uno(l) for l in serie["rates"]) or "—",
        ", ".join(_uno(l) for l in serie["quotas"]) or "—")


def main(outdir, base):
    cuerpo = {"datasheet_source": io.open(YAML, encoding="utf-8").read(),
              "plan_names": [PLAN], "endpoint_path": ENDPOINT, "alias": ALIAS}
    os.makedirs(outdir, exist_ok=True)

    print("== 1. Una dimensión cada vez (data/inflection)")
    for unidad in ("emails", "requests"):
        for k in (1.0, 70.0):
            d = _pedir(base, "data/inflection", cuerpo,
                       {"time_interval": VENTANA, "capacity_unit": unidad,
                        "capacity_request_factor": k})
            with io.open(os.path.join(outdir, "data_%s_k%g.json" % (unidad, k)),
                         "w", encoding="utf-8") as f:
                json.dump(d, f, indent=1)
            for s in d["series"]:
                if float(s.get("capacity_request_factor", k)) != k:
                    continue
                print("   capacity_unit=%-8s k=%-3g dim=%-8s %s" % (
                    unidad, k, s.get("dimension"), _limites(s)))
                print("      puntos: %s" % [(t / 1000, c) for t, c in
                                            zip(s["t_ms"], s["capacity"])])

    print("== 2. Sin capacity_unit (data/inflection): el motor devuelve todas")
    d = _pedir(base, "data/inflection", cuerpo, {"time_interval": VENTANA})
    with io.open(os.path.join(outdir, "data_sin_filtro.json"), "w", encoding="utf-8") as f:
        json.dump(d, f, indent=1)
    for s in d["series"]:
        print("   dim=%-8s k=%-4s %s" % (s.get("dimension"),
                                         s.get("capacity_request_factor"), _limites(s)))

    print("== 3. El documento del renderizador (chart/inflection)")
    for etiqueta, params in (
            ("sin filtro, por defecto", {"time_interval": VENTANA_FIG}),
            ("sin filtro, show_derived_requests=true",
             {"time_interval": VENTANA_FIG, "show_derived_requests": "true"}),
            ("capacity_unit=requests, por defecto",
             {"time_interval": VENTANA_FIG, "capacity_unit": "requests",
              "capacity_request_factor": 1.0}),
            ("capacity_unit=requests, show_derived_requests=true",
             {"time_interval": VENTANA_FIG, "capacity_unit": "requests",
              "capacity_request_factor": 1.0, "show_derived_requests": "true"})):
        codigo, html = _pedir(base, "chart/inflection", cuerpo, params, crudo=True)
        dims = sorted(set(re.findall(r'id="[^"]*__dim_(emails|requests)_crf_\w+"', html)))
        print("   %-42s HTTP %s  %6d bytes  figuras=%d  dimensiones=%s" % (
            etiqueta, codigo, len(html.encode()), html.count("Plotly.newPlot"),
            ", ".join(dims) or "ninguna"))


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "05_salida/_cap5/h1_dimensiones_d038",
         sys.argv[2] if len(sys.argv) > 2 else "http://localhost:8003")
