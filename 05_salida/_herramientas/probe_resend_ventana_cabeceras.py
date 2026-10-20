#!/usr/bin/env python3
"""
Sondeo de Resend · el origen de la ventana del límite diario de Free (100 correos).

La documentación solo dice `"wait until 24 hours have passed"`, y la Datasheet deja
`window_type: rolling` en 🟡 con la nota «observable con las cabeceras x-resend-daily-quota,
pendiente de sondeo». El sondeo del 2026-09-08 dependía de leer el panel a mano y no se cerró.

Una petición rechazada no trae esas cabeceras (comprobado el 2026-10-18: un 422 solo trae las
`ratelimit-*`), y la clave es de solo envío, así que cada lectura es un envío. Tres, separados
para que las dos lecturas rivales den cifras distintas:

  E1  T0, de noche en UTC.
  E2  T0 + 4 h, ya pasada la medianoche UTC. Si la ventana es fija en medianoche, el contador
      vuelve a empezar y E2 lee 1; si no, lee 2.
  E3  T0 + 24 h 5 min. Si la ventana es deslizante, E1 ya salió y E3 lee 2 (E2 y E3).

PRESUPUESTO DECLARADO (D-046, condición 2): **3 envíos**, a la dirección de la cuenta, que pasa
por la guarda de lista blanca antes de la primera llamada. Si E1 no trae ninguna cabecera de
cuota, el sondeo para ahí y gasta uno.

El `.env` se **lee**: solo `RESEND_API_KEY` y `RESEND_LOGIN`. Ni la clave ni la dirección se
imprimen ni van al informe.

USO
---
    python3 -I 05_salida/_herramientas/probe_resend_ventana_cabeceras.py 03_datos/apis/resend/evidencias/
"""
import sys, os, json, time, datetime, subprocess, urllib.request, urllib.error

AQUI = os.path.dirname(os.path.abspath(__file__))
GUARDA = os.path.join(AQUI, "lib_lista_blanca.py")
ENVIOS_PRESUPUESTADOS = 3
CALENDARIO_H = (0, 4, 24 + 5 / 60)


def carga_env(ruta=os.path.expanduser("~/.config/tfm/.env")):
    valores = {"RESEND_API_KEY": "", "RESEND_LOGIN": ""}
    with open(ruta, encoding="utf-8") as fh:
        for linea in fh:
            linea = linea.strip()
            if linea.startswith("export "):
                linea = linea[7:].strip()
            nombre, _, valor = linea.partition("=")
            if nombre.strip() in valores:
                valor = valor.strip()
                if len(valor) >= 2 and valor[0] == valor[-1] and valor[0] in "\"'":
                    valor = valor[1:-1]
                valores[nombre.strip()] = valor
    return valores


def exige_destinatario(direccion):
    r = subprocess.run([sys.executable, "-I", GUARDA, "check", direccion],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print("ABORTA: la guarda de lista blanca rechaza el destinatario.", file=sys.stderr)
        sys.exit(2)
    return r.stdout.strip()


def envia(clave, destino, n):
    t = datetime.datetime.now(datetime.timezone.utc)
    cuerpo = json.dumps({"from": "TFM sondeo <onboarding@resend.dev>", "to": [destino],
                         "subject": f"Sondeo TFM · ventana diaria · E{n} · {t:%Y-%m-%dT%H:%M}Z",
                         "text": "Sondeo del catalogo de Datasheets del TFM. Mide el contador diario."})
    req = urllib.request.Request("https://api.resend.com/emails", method="POST", data=cuerpo.encode(),
                                 headers={"Authorization": f"Bearer {clave}", "User-Agent": "tfm-sondeo",
                                          "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            codigo, cab, bruto = r.status, r.headers, r.read()
    except urllib.error.HTTPError as e:
        codigo, cab, bruto = e.code, e.headers, e.read()
    cab = {k.lower(): v for k, v in cab.items()}
    utiles = {k: v for k, v in cab.items() if "quota" in k or "ratelimit" in k or k.startswith("x-resend")}
    try:
        cuerpo_r = json.loads(bruto)
    except ValueError:
        cuerpo_r = bruto.decode(errors="replace")[:300]
    return {"envio": f"E{n}", "utc": t.isoformat(timespec="seconds"), "http": codigo,
            "cabeceras": utiles, "cuerpo": cuerpo_r}


def main():
    salida_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    env = carga_env()
    destino = exige_destinatario(env["RESEND_LOGIN"])
    print(f"PRESUPUESTO: {ENVIOS_PRESUPUESTADOS} envíos, a la lista blanca.\n")
    t0 = datetime.datetime.now(datetime.timezone.utc)
    ruta = os.path.join(salida_dir, f"probe_resend_ventana_cabeceras_{t0:%Y-%m-%d_%H%M%S}.json")
    informe = {"sondeo": "resend_ventana_cabeceras", "presupuesto_envios": ENVIOS_PRESUPUESTADOS,
               "envios_gastados": 0, "inicio_utc": t0.isoformat(timespec="seconds"),
               "calendario_horas": CALENDARIO_H, "envios": []}
    for n, h in enumerate(CALENDARIO_H, start=1):
        espera = (t0 + datetime.timedelta(hours=h) - datetime.datetime.now(datetime.timezone.utc)).total_seconds()
        if espera > 0:
            time.sleep(espera)
        r = envia(env["RESEND_API_KEY"], destino, n)
        informe["envios_gastados"] += 1 if r["http"] == 200 else 0
        informe["envios"].append(r)
        texto = json.dumps(informe, indent=2, ensure_ascii=False).replace(destino, "<direccion-redactada>")
        with open(ruta, "w") as f:
            f.write(texto)
        print(f"  E{n}: HTTP {r['http']} · {r['cabeceras']}")
        if r["http"] != 200 or not any("quota" in k for k in r["cabeceras"]):
            print("  para: sin envío aceptado o sin cabecera de cuota")
            break
    print(f"\n  informe: {ruta}")


if __name__ == "__main__":
    main()
