#!/usr/bin/env bash
# Sondeo empirico SendGrid (escalon 3) - 2026-09-06
# Todo en MODO SANDBOX: la API valida la peticion y NO entrega ni consume creditos
# ("No Credits will be consumed", docs de Sandbox Mode). Las lecturas son GET.
#
# Resuelve:
#   B  tope de destinatarios por peticion: 1.000 en TOTAL entre to/cc/bcc y personalizations
#      (la OpenAPI deja "to" sin maxItems; la prosa dice 1.000 en total)
#   C  cabeceras X-RateLimit-* de mail/send y de endpoints de lectura (F-01: valores no publicados)
#   D  /v3/user/credits: contador y fecha de reposicion del limite diario (window_type en rojo)
#
# USO (en la maquina del autor, NUNCA desde el contenedor ni por chat):
#   export SENDGRID_API_KEY='SG....'      # la clave no se escribe en este fichero ni en el chat
#   export SENDGRID_FROM='tu@correo'      # opcional: remitente para el sandbox (si hay identidad verificada, mejor)
#   bash probe_sendgrid_sandbox.sh B      # solo B: 5 casos
#   bash probe_sendgrid_sandbox.sh CD     # solo C y D: lecturas
#   bash probe_sendgrid_sandbox.sh BCD    # todo (recomendado)
#
# Salida: probe_sendgrid_<fecha>.json junto a este script, con la clave redactada, y una tabla en pantalla.
# Pegar la tabla en el chat; el JSON se copia a 03_datos/apis/sendgrid/evidencias/.

set -u
CASOS="${1:-BCD}"
: "${SENDGRID_API_KEY:?Falta SENDGRID_API_KEY}"
FROM="${SENDGRID_FROM:-probe@example.com}"
BASE="https://api.sendgrid.com"
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
OUT="$(dirname "$0")/probe_sendgrid_$(date -u +%Y-%m-%d_%H%M%S).json"
echo "[" > "$OUT"
PRIMERO=1

registrar () {  # nombre, metodo, ruta, code, hdr, bodyfile
  python3 - "$1" "$2" "$3" "$4" "$5" "$6" "$OUT" "$PRIMERO" <<'PY'
import sys, json
nombre, metodo, ruta, code, hdr, bodyf, out, primero = sys.argv[1:9]
headers = {}
for line in open(hdr, encoding='utf-8', errors='replace'):
    if ':' in line:
        k, v = line.split(':', 1); headers[k.strip().lower()] = v.strip()
try:
    body = json.load(open(bodyf, encoding='utf-8'))
except Exception:
    body = open(bodyf, encoding='utf-8', errors='replace').read()[:2000]
keep = {k: v for k, v in headers.items() if any(s in k for s in ("ratelimit", "rate-limit", "retry", "date", "x-message-id"))}
rec = {"caso": nombre, "metodo": metodo, "ruta": ruta, "http": int(code), "cuerpo": body, "cabeceras": keep}
with open(out, "a", encoding="utf-8") as f:
    f.write(("" if primero == "1" else ",\n") + json.dumps(rec, ensure_ascii=True, indent=2))
msg = ""
if isinstance(body, dict):
    if "errors" in body and body["errors"]:
        e = body["errors"][0]
        msg = (e.get("message", "") + (" [" + e.get("field", "") + "]" if e.get("field") else "")) if isinstance(e, dict) else str(e)
    else:
        msg = json.dumps(body)[:100]
else:
    msg = str(body)[:100]
print(f"{nombre:<34} HTTP {code:<5} {msg[:95]}")
for k, v in keep.items():
    if "ratelimit" in k or "retry" in k:
        print(f"{'':<34} {k}: {v}")
PY
  PRIMERO=0
}

llamada () {  # nombre, metodo, ruta, [json_body]
  local nombre="$1" metodo="$2" ruta="$3" body="${4:-}" hdr="/tmp/probe_hdr.$$" bf="/tmp/probe_body.$$" code
  if [[ "$metodo" == "POST" ]]; then
    code="$(curl -sS -o "$bf" -D "$hdr" -w '%{http_code}' -H "Authorization: Bearer $SENDGRID_API_KEY" \
        -H "Content-Type: application/json" -X POST "$BASE$ruta" --data-binary @<(printf '%s' "$body"))"
  else
    code="$(curl -sS -o "$bf" -D "$hdr" -w '%{http_code}' -H "Authorization: Bearer $SENDGRID_API_KEY" "$BASE$ruta")"
  fi
  registrar "$nombre" "$metodo" "$ruta" "$code" "$hdr" "$bf"
  rm -f "$hdr" "$bf"
  sleep 2
}

# cuerpo de mail/send en sandbox: lista de personalizations "to1,to2,..." (destinatarios en "to" de cada sobre)
# y, opcionalmente, cuantos "cc" lleva el primer sobre. Todas las direcciones son distintas (SendGrid no admite repetidas).
cuerpo () {  # "500,501" [cc_primer_sobre]
  python3 - "$FROM" "$1" "${2:-0}" <<'PY'
import sys, json
frm, tos, c = sys.argv[1], [int(x) for x in sys.argv[2].split(",")], int(sys.argv[3])
i = 0; pers = []
for p, k in enumerate(tos):
    to = []; cc = []
    for _ in range(k):
        i += 1; to.append({"email": f"probe+{i:05d}@example.com"})
    if p == 0:
        for _ in range(c):
            i += 1; cc.append({"email": f"probe+{i:05d}@example.com"})
    d = {"to": to}
    if cc: d["cc"] = cc
    pers.append(d)
print(json.dumps({"personalizations": pers, "from": {"email": frm},
                  "subject": "TFM sondeo sandbox", "content": [{"type": "text/plain", "value": "sondeo"}],
                  "mail_settings": {"sandbox_mode": {"enable": True}}}))
PY
}

echo "Sondeo SendGrid (sandbox)  $STAMP  casos=$CASOS  from=$FROM"
echo "-----------------------------------------------------------------------------"

if [[ "$CASOS" == *B* ]]; then
  # En pares: el que debe pasar (200 en sandbox) y el que debe fallar (400 con el mensaje del limite). Sin consumo.
  llamada "B0_sanity_1_destinatario"          POST /v3/mail/send "$(cuerpo 1)"
  llamada "B1_1sobre_to_1000"                 POST /v3/mail/send "$(cuerpo 1000)"
  llamada "B2_1sobre_to_1001"                 POST /v3/mail/send "$(cuerpo 1001)"
  llamada "B3_2sobres_500_y_500_total_1000"   POST /v3/mail/send "$(cuerpo 500,500)"
  llamada "B4_2sobres_500_y_501_total_1001"   POST /v3/mail/send "$(cuerpo 500,501)"
  llamada "B5_1sobre_to_500_cc_501_total_1001" POST /v3/mail/send "$(cuerpo 500 501)"
  llamada "B6_1001sobres_de_1"                POST /v3/mail/send "$(cuerpo $(python3 -c 'print(",".join(["1"]*1001))'))"
fi

if [[ "$CASOS" == *C* ]]; then
  # Lecturas: solo miramos las cabeceras X-RateLimit-*. Si la clave no tiene permiso, el 403 tambien trae cabeceras.
  llamada "C1_GET_user_profile"   GET /v3/user/profile
  llamada "C2_GET_api_keys"       GET /v3/api_keys
  llamada "C3_GET_templates"      GET "/v3/templates?generations=dynamic&page_size=1"
  llamada "C4_GET_messages"       GET "/v3/messages?limit=1"
  llamada "C5_GET_scopes"         GET /v3/scopes
fi

if [[ "$CASOS" == *D* ]]; then
  llamada "D1_GET_user_credits"   GET /v3/user/credits
  llamada "D2_GET_user_account"   GET /v3/user/account
fi

echo "]" >> "$OUT"
sed -i "s/${SENDGRID_API_KEY}/REDACTADO/g" "$OUT"
echo "-----------------------------------------------------------------------------"
echo "JSON: $OUT  (clave redactada). Pega la tabla de arriba en el chat."
