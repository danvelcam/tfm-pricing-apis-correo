#!/usr/bin/env python3
"""
Sondeo de SES · DISC-10: ¿la cuota diaria se cuenta en ventana deslizante o fija?

[F3] dice que la cuota se calcula sobre las 24 horas anteriores a cada envío, y [F32] dice que
hay que esperar «al siguiente periodo de 24 horas». El contador `SentLast24Hours` de
`GET /v2/email/account` lo dirime: con un solo envío a la hora T, una ventana deslizante lo
baja a cero hacia T + 24 h, y una fija lo baja de golpe en su frontera (la medianoche UTC, si es
esa), antes de T + 24 h.

PRESUPUESTO DECLARADO (D-046, condición 2): **1 envío**, a la dirección verificada de la cuenta,
que está en la lista blanca y pasa por la guarda antes de la primera llamada. El resto son
lecturas, que no gastan cuota.

Si el contador no está en cero al empezar, el sondeo **no envía**: con envíos previos dentro de
la ventana la bajada no se podría atribuir.

CALENDARIO DE LECTURAS. Cada 15 minutos durante 25 horas, y cada 2 minutos entre T + 23 h 40 y
T + 24 h 20, donde cae la bajada si la ventana es deslizante. El contador va con retraso, entre
cinco segundos y minuto y medio ([E5]), así que la bajada se fecha con ese margen. El informe se
reescribe tras cada lectura: si el proceso muere, lo leído queda.

USO
---
    python3 -I 05_salida/_herramientas/probe_ses_ventana_cuota.py 03_datos/apis/ses/evidencias/ [región]
"""
import sys, os, re, json, time, datetime, importlib.util

AQUI = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location(
    "probe_ses_base", os.path.join(AQUI, "probe_ses_cuota_caudal.py"))
BASE = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(BASE)

ENVIOS_PRESUPUESTADOS = 1
DURACION_H = 25
PASO_NORMAL_S = 15 * 60
PASO_FINO_S = 2 * 60
FINO_DESDE_H, FINO_HASTA_H = 23 + 40 / 60, 24 + 20 / 60


def ahora():
    return datetime.datetime.now(datetime.timezone.utc)


def guarda(ruta, informe, direcciones):
    with open(ruta, "w") as f:
        json.dump(BASE.redacta(informe, direcciones), f, indent=2, ensure_ascii=False)


def main():
    salida_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    env = BASE.carga_env()
    if len(sys.argv) > 2:
        env["SES_REGION"] = sys.argv[2]
    if not re.fullmatch(r"[a-z]{2}(-[a-z]+)+-\d", env.get("SES_REGION", "")):
        print("ABORTA: la región no tiene forma de región de AWS (p. ej. eu-west-1).", file=sys.stderr)
        sys.exit(3)
    destino = BASE.exige_destinatario(BASE.DESTINO)
    remitente = env.get("SES_FROM") or destino
    direcciones = [destino, remitente]
    print(f"PRESUPUESTO: {ENVIOS_PRESUPUESTADOS} envío, a la lista blanca. El resto, lecturas.\n")

    sello = ahora().strftime("%Y-%m-%d_%H%M%S")
    ruta = os.path.join(salida_dir, f"probe_ses_ventana_cuota_{sello}.json")
    informe = {"sondeo": "ses_ventana_cuota", "pregunta": "DISC-10", "region": env["SES_REGION"],
               "presupuesto_envios": ENVIOS_PRESUPUESTADOS, "envios_gastados": 0,
               "inicio_utc": ahora().isoformat(timespec="seconds"), "envio": None,
               "lecturas": [], "veredicto": None}

    r, c = BASE.contador(env)
    informe["lecturas"].append({"utc": ahora().isoformat(timespec="seconds"), "http": r["http"],
                                "SentLast24Hours": c.get("SentLast24Hours"), "fase": "antes"})
    if r["http"] != 200 or c.get("SentLast24Hours") not in (0, 0.0):
        informe["veredicto"] = "no enviado: el contador no estaba en cero o la lectura falló"
        guarda(ruta, informe, direcciones)
        print(f"  {informe['veredicto']} (HTTP {r['http']}, {c.get('SentLast24Hours')})")
        sys.exit(4)

    t0 = ahora()
    e = BASE.llama("POST", "/v2/email/outbound-emails",
                   BASE.cuerpo_envio(remitente, [destino], None,
                                     f"Sondeo TFM · ventana de la cuota · {t0:%Y-%m-%dT%H:%M}Z"), env)
    informe["envios_gastados"] = 1 if e["http"] == 200 else 0
    informe["envio"] = {"utc": t0.isoformat(timespec="seconds"), "http": e["http"], "cuerpo": e["cuerpo"]}
    guarda(ruta, informe, direcciones)
    print(f"  envío: HTTP {e['http']} a las {t0:%H:%M:%S}Z")
    if e["http"] != 200:
        sys.exit(5)

    fin = t0 + datetime.timedelta(hours=DURACION_H)
    previo = None
    while ahora() < fin:
        horas = (ahora() - t0).total_seconds() / 3600
        r, c = BASE.contador(env)
        valor = c.get("SentLast24Hours")
        informe["lecturas"].append({"utc": ahora().isoformat(timespec="seconds"),
                                    "horas_desde_envio": round(horas, 3), "http": r["http"],
                                    "SentLast24Hours": valor})
        if previo not in (None, 0, 0.0) and valor in (0, 0.0) and informe["veredicto"] is None:
            informe["veredicto"] = (f"bajada a cero a las {horas:.2f} h del envío: "
                                    + ("deslizante" if horas >= 23.5 else "fija, antes de 24 h"))
            print(f"  {informe['veredicto']}")
        if valor not in (None,):
            previo = valor
        guarda(ruta, informe, direcciones)
        horas = (ahora() - t0).total_seconds() / 3600
        time.sleep(PASO_FINO_S if FINO_DESDE_H - 0.05 <= horas <= FINO_HASTA_H else PASO_NORMAL_S)
    if informe["veredicto"] is None:
        informe["veredicto"] = "sin bajada a cero en 25 h"
    guarda(ruta, informe, direcciones)
    print(f"\n  informe: {ruta}\n  veredicto: {informe['veredicto']}")


if __name__ == "__main__":
    main()
