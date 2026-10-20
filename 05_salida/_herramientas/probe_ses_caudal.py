#!/usr/bin/env python3
"""
Sondeo de caudal de Amazon SES — el nombre y el código del error de una por segundo.

PRESUPUESTO DECLARADO (D-046, condición 2): **2 envíos como máximo**, los dos a la
dirección verificada de la lista blanca. La cuenta publica un caudal de un mensaje por
segundo, así que la segunda petición debería rebotar y costar cero; el presupuesto cuenta
el caso en que no rebote.

QUÉ PREGUNTAS RESUELVE
----------------------
  DISC-07  el nombre del error de caudal en la API v2. Tres fuentes de AWS, tres contratos:
           `ThrottlingException` en la página monográfica, `TooManyRequestsException` en la
           referencia de la operación, y **ninguna de las dos** en el contrato máquina, donde
           la primera forma no existe en el modelo v2.
  DISC-08  su código HTTP: 400 según un blog de 2012, 429 según la referencia.

POR QUÉ NO SE PUEDE HACER GRATIS, QUE ES LA VÍA QUE PIDE EL MANDATO
-------------------------------------------------------------------
La condición 3 de D-046 prefiere el rechazo al envío: si la cifra sale del cuerpo de un
error, no se gasta cuota. En SES **esa vía está cerrada**, y se midió el 2026-09-18. El
permiso de IAM que autoriza `ses:SendEmail` se evalúa sobre un ARN construido con la
dirección de **destino**, no con la del remitente: un intento contra
`sondeo@example.invalid` devuelve `AccessDeniedException` nombrando
`identity/sondeo@example.invalid`. Así que cualquier destinatario que el proveedor fuera a
rechazar es también un destinatario que IAM no autoriza, y el error que sale es el de
permisos, nunca el de caudal. Para llegar al caudal hay que enviar de verdad.

USO
---
    python3 -I 05_salida/_herramientas/probe_ses_caudal.py 03_datos/apis/ses/evidencias/
"""
import sys, os, json, time, datetime, importlib.util

AQUI = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location(
    "probe_ses_base", os.path.join(AQUI, "probe_ses_cuota_caudal.py"))
BASE = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(BASE)

INTENTOS = 2
ENVIOS_PRESUPUESTADOS = 2


def main():
    salida_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    env = BASE.carga_env()
    region = env.get("SES_REGION", "")
    if not all(c.isascii() and (c.isalnum() or c == "-") for c in region):
        print("ABORTA: SES_REGION mal formada. Corrige ~/.config/tfm/.env.", file=sys.stderr)
        sys.exit(3)

    destino = BASE.exige_destinatario(BASE.DESTINO)
    remitente = env.get("SES_FROM") or destino

    print(f"PRESUPUESTO: hasta {ENVIOS_PRESUPUESTADOS} envíos, los dos a la dirección "
          f"verificada de la lista blanca. Se para en cuanto una petición no sea 200.")

    # El tope publicado es de una por segundo. Las peticiones salen seguidas, sin pausa
    # entre ellas: la pausa es justo lo que impediría medir esto.
    r0 = BASE.llama("GET", "/v2/email/account", None, env)
    quota0 = r0["cuerpo"].get("SendQuota") if isinstance(r0["cuerpo"], dict) else None
    print(f"  caudal publicado por la API: MaxSendRate = "
          f"{quota0.get('MaxSendRate') if quota0 else '?'} por segundo\n")

    pasos, enviados = [], 0
    t_inicio = time.time()
    for i in range(1, INTENTOS + 1):
        cuerpo = BASE.cuerpo_envio(remitente, [destino], None,
                                   f"Sondeo TFM · caudal, intento {i}")
        r = BASE.llama("POST", "/v2/email/outbound-emails", cuerpo, env)
        dt = round(time.time() - t_inicio, 3)
        c = r["cuerpo"] if isinstance(r["cuerpo"], dict) else {}
        tipo = (r["cabeceras"].get("x-amzn-errortype", "") or "").split(":")[0]
        msg = c.get("Message") or c.get("message") or ""
        pasos.append({"intento": i, "t_desde_inicio_s": dt, "respuesta": r})
        if r["http"] == 200:
            enviados += 1
            print(f"  [{r['http']}] intento {i} a t+{dt}s → aceptado, MessageId presente")
        else:
            print(f"  [{r['http']}] intento {i} a t+{dt}s → {tipo}")
            print(f"        cuerpo: {msg}")
            print(f"        cabeceras de interés: "
                  f"{json.dumps({k: v for k, v in r['cabeceras'].items() if 'retry' in k or 'rate' in k or 'errortype' in k})}")
            break

    print(f"\n  envíos gastados: {enviados} de {ENVIOS_PRESUPUESTADOS} presupuestados")

    ultimo = pasos[-1]["respuesta"]
    if ultimo["http"] == 200:
        print("  → las dos peticiones consecutivas pasan. El tope de una por segundo NO se")
        print("    aplica a esta cuenta como rechazo inmediato. DISC-07 y DISC-08 siguen")
        print("    abiertas, y queda un hecho nuevo que registrar.")
    else:
        tipo = (ultimo["cabeceras"].get("x-amzn-errortype", "") or "").split(":")[0]
        print(f"  → el caudal rebota con HTTP {ultimo['http']} y tipo '{tipo}'.")
        print("    Eso decide DISC-07 (el nombre) y DISC-08 (el código) midiendo.")

    sello = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d_%H%M%S")
    os.makedirs(salida_dir, exist_ok=True)
    destino_fichero = os.path.join(salida_dir, f"probe_ses_caudal_{sello}.json")
    informe = BASE.redacta({
        "sondeo": "ses_caudal",
        "fecha_utc": sello,
        "region": region,
        "caudal_publicado_por_la_api": quota0,
        "presupuesto_envios": ENVIOS_PRESUPUESTADOS,
        "envios_gastados": enviados,
        "pasos": pasos,
    }, [destino, remitente])
    with open(destino_fichero, "w", encoding="utf-8") as fh:
        json.dump(informe, fh, ensure_ascii=False, indent=2)
    print(f"\nEvidencia en {destino_fichero}")


if __name__ == "__main__":
    main()
