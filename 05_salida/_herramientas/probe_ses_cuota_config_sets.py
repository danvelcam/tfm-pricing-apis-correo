#!/usr/bin/env python3
"""
Sondeo de SES · DISC-01: ¿la cuota de *configuration sets* es ajustable?

[F1] dice `Adjustable: No` y [F7] dice `Adjustable: Yes` para el mismo techo de 10.000, con
código `L-10E24536`. Service Quotas expone el campo `Adjustable` de esa cuota, así que una
lectura lo dirime sin tocar nada.

PRESUPUESTO DECLARADO (D-046, condición 2): **0 envíos**. Dos lecturas, `GetServiceQuota` y
`GetAWSDefaultServiceQuota`, que no cambian ningún estado de la cuenta.

El `.env` se **lee** como dato con `carga_env` del sondeo base y no se sourcea. Las claves no
se imprimen ni se escriben en el informe.

USO
---
    python3 -I 05_salida/_herramientas/probe_ses_cuota_config_sets.py 03_datos/apis/ses/evidencias/ [región]

La región del argumento manda sobre `SES_REGION`. Existe porque el 2026-10-18 el `.env` traía
`SES_REGION` truncada a ocho caracteres, sin el dígito final, y la forma se comprueba entera.
"""
import sys, os, re, json, datetime, hashlib, hmac, importlib.util, urllib.request, urllib.error

AQUI = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location(
    "probe_ses_base", os.path.join(AQUI, "probe_ses_cuota_caudal.py"))
BASE = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(BASE)

CODIGO = "L-10E24536"
TIPO = "application/x-amz-json-1.1"


def llama_sq(accion, cuerpo_obj, env):
    region = env["SES_REGION"]
    host = f"servicequotas.{region}.amazonaws.com"
    cuerpo = json.dumps(cuerpo_obj)
    ahora = datetime.datetime.now(datetime.timezone.utc)
    amzdate, dia = ahora.strftime("%Y%m%dT%H%M%SZ"), ahora.strftime("%Y%m%d")
    objetivo = f"ServiceQuotasV20190624.{accion}"
    canon_h = f"content-type:{TIPO}\nhost:{host}\nx-amz-date:{amzdate}\nx-amz-target:{objetivo}\n"
    firmados = "content-type;host;x-amz-date;x-amz-target"
    canon = "\n".join(["POST", "/", "", canon_h, firmados,
                       hashlib.sha256(cuerpo.encode()).hexdigest()])
    ambito = f"{dia}/{region}/servicequotas/aws4_request"
    a_firmar = "\n".join(["AWS4-HMAC-SHA256", amzdate, ambito,
                          hashlib.sha256(canon.encode()).hexdigest()])
    k = ("AWS4" + env["SES_SECRET_ACCESS_KEY"]).encode()
    for parte in (dia, region, "servicequotas", "aws4_request"):
        k = hmac.new(k, parte.encode(), hashlib.sha256).digest()
    sig = hmac.new(k, a_firmar.encode(), hashlib.sha256).hexdigest()
    cab = {"Content-Type": TIPO, "X-Amz-Date": amzdate, "X-Amz-Target": objetivo,
           "Authorization": f"AWS4-HMAC-SHA256 Credential={env['SES_ACCESS_KEY_ID']}/{ambito}, "
                            f"SignedHeaders={firmados}, Signature={sig}"}
    req = urllib.request.Request(f"https://{host}/", data=cuerpo.encode(), headers=cab, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return {"http": r.status, "cuerpo": json.loads(r.read() or b"{}")}
    except urllib.error.HTTPError as e:
        bruto = e.read()
        try:
            c = json.loads(bruto)
        except ValueError:
            c = bruto.decode(errors="replace")[:500]
        return {"http": e.code, "cuerpo": c}


def main():
    salida_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    env = BASE.carga_env()
    if len(sys.argv) > 2:
        env["SES_REGION"] = sys.argv[2]
    region = env.get("SES_REGION", "")
    if not re.fullmatch(r"[a-z]{2}(-[a-z]+)+-\d", region):
        print("ABORTA: la región no tiene forma de región de AWS (p. ej. eu-west-1). "
              "Corrige SES_REGION en ~/.config/tfm/.env o pásala como segundo argumento.",
              file=sys.stderr)
        sys.exit(3)
    print("PRESUPUESTO: 0 envíos. Este sondeo solo lee.\n")
    pet = {"ServiceCode": "ses", "QuotaCode": CODIGO}
    informe = {"sondeo": "ses_cuota_config_sets", "region": region, "presupuesto_envios": 0,
               "envios_gastados": 0, "quota_code": CODIGO,
               "fecha_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
               "lecturas": {}}
    for accion in ("GetServiceQuota", "GetAWSDefaultServiceQuota"):
        r = llama_sq(accion, pet, env)
        informe["lecturas"][accion] = r
        q = r["cuerpo"].get("Quota", {}) if isinstance(r["cuerpo"], dict) else {}
        print(f"  {accion}: HTTP {r['http']} · Adjustable={q.get('Adjustable')} · "
              f"Value={q.get('Value')} · {q.get('QuotaName', r['cuerpo'] if r['http'] != 200 else '')}")
    sello = datetime.datetime.now().strftime("%Y-%m-%d_%H%M%S")
    ruta = os.path.join(salida_dir, f"probe_ses_cuota_config_sets_{sello}.json")
    with open(ruta, "w") as f:
        json.dump(informe, f, indent=2, ensure_ascii=False)
    print(f"\n  informe: {ruta}")


if __name__ == "__main__":
    main()
