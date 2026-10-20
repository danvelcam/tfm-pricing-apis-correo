#!/usr/bin/env python3
"""
Sondeo de caudal de Amazon SES sobre una operación de lectura — COSTE CERO.

PRESUPUESTO DECLARADO (D-046, condición 2): **0 envíos**. Este sondeo no manda correo:
solo lee `GET /v2/email/account`, que es la vía preferente de la condición 3 del mandato.

QUÉ PREGUNTA RESUELVE
---------------------
  DISC-05  el alcance del tope de una petición por segundo. La documentación dice que
           *"All actions (except for SendEmail, SendRawEmail, and SendTemplatedEmail) are
           throttled at one request per second"*, mientras la tabla de cuotas presenta el
           caudal como una cifra ajustable por solicitud. `GetAccount` es una de esas
           «todas las demás acciones», así que el tope debería rechazar la segunda petición
           del mismo segundo.
  DISC-07  el nombre del error de caudal, si se llega a él.
  DISC-08  su código HTTP, si se llega a él.

Dos pasadas, de menos a más, porque el orden importa: una serie **secuencial**, donde el
techo lo pone el tiempo de ida y vuelta, y una **concurrente**, que es la única forma de
pasar de unas pocas peticiones por segundo desde una sola máquina.

DÓNDE ESTÁ LA FRONTERA, Y NO SE CRUZA
-------------------------------------
Esto es un sondeo, no una campaña de carga. Busca el **rechazo publicado**, no el techo
real: en cuanto una petición rebote, para. Si ninguna rebota, el dato es que el tope
publicado no se aplica a este ritmo, y **ahí se queda**. Encontrar el caudal verdadero de
un proveedor que no lo publica es medición formal, que el capítulo 4 deja «preparada, no
comprometida» y que no se inicia por iniciativa propia.

USO
---
    python3 -I 05_salida/_herramientas/probe_ses_caudal_lectura.py 03_datos/apis/ses/evidencias/
"""
import sys, os, json, time, datetime, importlib.util
from concurrent.futures import ThreadPoolExecutor

AQUI = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location(
    "probe_ses_base", os.path.join(AQUI, "probe_ses_cuota_caudal.py"))
BASE = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(BASE)

SECUENCIALES = 12
CONCURRENTES = 30


def _resumen(r, i, dt):
    return {
        "peticion": i,
        "t_desde_inicio_s": dt,
        "http": r["http"],
        "errortype": (r["cabeceras"].get("x-amzn-errortype", "") or "").split(":")[0],
        "cuerpo_si_error": (r["cuerpo"] if r["http"] != 200 else None),
        "cabeceras_de_caudal": {k: v for k, v in r["cabeceras"].items()
                                if "retry" in k or "rate" in k or "errortype" in k},
    }


def main():
    salida_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    env = BASE.carga_env()
    region = env.get("SES_REGION", "")
    if not all(c.isascii() and (c.isalnum() or c == "-") for c in region):
        print("ABORTA: SES_REGION mal formada. Corrige ~/.config/tfm/.env.", file=sys.stderr)
        sys.exit(3)

    print("PRESUPUESTO: 0 envíos. Este sondeo solo lee.\n")

    r0 = BASE.llama("GET", "/v2/email/account", None, env)
    if r0["http"] != 200:
        print(f"ABORTA: la lectura de partida devuelve {r0['http']}.", file=sys.stderr)
        sys.exit(3)
    quota = r0["cuerpo"].get("SendQuota")
    print(f"  caudal que publica la propia API para el envío: "
          f"MaxSendRate = {quota.get('MaxSendRate')} por segundo")
    print(f"  y la documentación capa el resto de acciones a 1 por segundo (DISC-05)\n")

    informe = {"sondeo": "ses_caudal_lectura", "region": region,
               "presupuesto_envios": 0, "envios_gastados": 0,
               "caudal_publicado_por_la_api": quota, "pasadas": {}}

    # ── pasada 1 · secuencial ────────────────────────────────────────────────
    print(f"  -- pasada 1: {SECUENCIALES} peticiones secuenciales --")
    filas, t0, rechazo = [], time.time(), None
    for i in range(1, SECUENCIALES + 1):
        r = BASE.llama("GET", "/v2/email/account", None, env)
        dt = round(time.time() - t0, 3)
        filas.append(_resumen(r, i, dt))
        if r["http"] != 200:
            rechazo = filas[-1]
            break
    dur = filas[-1]["t_desde_inicio_s"] or 0.001
    ritmo1 = round(len(filas) / dur, 1)
    print(f"     {len(filas)} peticiones en {dur} s → {ritmo1} por segundo · "
          f"códigos { {f['http'] for f in filas} }")
    informe["pasadas"]["secuencial"] = {"ritmo_por_segundo": ritmo1, "filas": filas}

    # ── pasada 2 · concurrente ───────────────────────────────────────────────
    if rechazo is None:
        print(f"\n  -- pasada 2: {CONCURRENTES} peticiones concurrentes --")
        t0 = time.time()

        def una(i):
            r = BASE.llama("GET", "/v2/email/account", None, env)
            return _resumen(r, i, round(time.time() - t0, 3))

        with ThreadPoolExecutor(max_workers=CONCURRENTES) as ex:
            filas2 = sorted(ex.map(una, range(1, CONCURRENTES + 1)),
                            key=lambda f: f["t_desde_inicio_s"])
        dur2 = filas2[-1]["t_desde_inicio_s"] or 0.001
        ritmo2 = round(len(filas2) / dur2, 1)
        codigos = {}
        for f in filas2:
            codigos[f["http"]] = codigos.get(f["http"], 0) + 1
        print(f"     {len(filas2)} peticiones en {dur2} s → {ritmo2} por segundo · "
              f"códigos {codigos}")
        informe["pasadas"]["concurrente"] = {"ritmo_por_segundo": ritmo2,
                                             "codigos": codigos, "filas": filas2}
        rechazo = next((f for f in filas2 if f["http"] != 200), None)

    # ── lectura ──────────────────────────────────────────────────────────────
    print()
    if rechazo:
        print(f"  → el caudal rebota: HTTP {rechazo['http']}, tipo "
              f"'{rechazo['errortype']}', a t+{rechazo['t_desde_inicio_s']}s.")
        print("    Eso decide DISC-07 (el nombre del error) y DISC-08 (el código) midiendo.")
        informe["veredicto"] = "rechazo alcanzado"
    else:
        ritmo = informe["pasadas"].get("concurrente", informe["pasadas"]["secuencial"])["ritmo_por_segundo"]
        print(f"  → ninguna petición rebota a {ritmo} por segundo, y el tope publicado para")
        print("    estas acciones es de UNA por segundo. El tope no se aplica como rechazo.")
        print("    DISC-05 queda medida. DISC-07 y DISC-08 siguen abiertas: no se alcanza el")
        print("    error de caudal, así que su nombre y su código no se pueden medir aquí.")
        print("    El techo real NO se busca: eso es medición formal y no está en el encargo.")
        informe["veredicto"] = "sin rechazo; el tope publicado no se aplica a este ritmo"

    sello = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d_%H%M%S")
    informe["fecha_utc"] = sello
    os.makedirs(salida_dir, exist_ok=True)
    destino = os.path.join(salida_dir, f"probe_ses_caudal_lectura_{sello}.json")
    with open(destino, "w", encoding="utf-8") as fh:
        json.dump(BASE.redacta(informe, []), fh, ensure_ascii=False, indent=2)
    print(f"\nEvidencia en {destino}")


if __name__ == "__main__":
    main()
