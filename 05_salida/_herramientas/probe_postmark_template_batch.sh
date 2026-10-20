#!/usr/bin/env bash
# Sondeo empirico Postmark (escalon 3), segunda tanda - 2026-09-06
# Cierra dos amarillos que el token de pruebas no puede tocar (solo vale en /email):
#   T  /email/withTemplate: 51 destinatarios -> se espera 422 con "Maximum of 50 recipients..."
#   B  /email/batch: 501 mensajes -> se espera 422 con el tope de 500 en el texto
# Los dos casos estan disenados para que Postmark los RECHACE antes de enviar (coste 0).
# RIESGO del caso B: si el lote de 501 se acepta y se valida mensaje a mensaje, podria
# enviar hasta 500 correos a tu direccion y agotar la cuota mensual del plan Free.
#
# USO (en la maquina del autor):
#   export POSTMARK_SERVER_TOKEN='...'    # Server API Token (Servers > tu servidor > API Tokens). NO un Account token.
#   export POSTMARK_FROM='tu@correo'      # un Sender Signature CONFIRMADO
#   bash probe_postmark_template_batch.sh T      # solo plantilla
#   bash probe_postmark_template_batch.sh TB     # plantilla y lote
set -u
CASOS="${1:-T}"
: "${POSTMARK_SERVER_TOKEN:?Falta POSTMARK_SERVER_TOKEN}"
: "${POSTMARK_FROM:?Falta POSTMARK_FROM}"
API="https://api.postmarkapp.com"
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
OUT="$(dirname "$0")/probe_postmark_$(date -u +%Y-%m-%d_%H%M%S).json"
echo "[" > "$OUT"; PRIMERO=1
H=(-H "Accept: application/json" -H "Content-Type: application/json" -H "X-Postmark-Server-Token: $POSTMARK_SERVER_TOKEN")

registrar () {  # nombre t0 code hdr body
  python3 - "$1" "$2" "$3" "$4" "$5" "$OUT" "$PRIMERO" <<'PY'
import sys, json
nombre, t0, code, hdr, bodyf, out, primero = sys.argv[1:8]
headers = {}
for line in open(hdr, encoding='utf-8', errors='replace'):
    if ':' in line:
        k, v = line.split(':', 1); headers[k.strip().lower()] = v.strip()
try: body = json.load(open(bodyf, encoding='utf-8'))
except Exception: body = open(bodyf, encoding='utf-8', errors='replace').read()
rec = {"caso": nombre, "instante_utc": t0, "http": int(code), "cuerpo": body,
       "cabeceras": {k: v for k, v in headers.items() if any(s in k for s in ("ratelimit", "rate-limit", "retry", "date", "x-pm", "postmark"))}}
with open(out, "a", encoding="utf-8") as f:
    f.write(("" if primero == "1" else ",\n") + json.dumps(rec, ensure_ascii=True, indent=2))
if isinstance(body, dict):
    msg = f"ErrorCode {body.get('ErrorCode')} - {body.get('Message')}" if 'ErrorCode' in body else json.dumps(body)[:100]
elif isinstance(body, list):
    codes = {}
    for m in body:
        k = f"{m.get('ErrorCode')}:{str(m.get('Message'))[:60]}"; codes[k] = codes.get(k, 0) + 1
    msg = f"lista de {len(body)} respuestas: " + "; ".join(f"{v}x [{k}]" for k, v in codes.items())
else: msg = str(body)[:120]
print(f"{nombre:<26} HTTP {code:<5} {msg[:140]}")
PY
  PRIMERO=0
}
post () {  # nombre path body
  local hdr="/tmp/pm_hdr.$$" bodyf="/tmp/pm_body.$$" t0 code
  t0="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  code="$(curl -sS -o "$bodyf" -D "$hdr" -w '%{http_code}' "${H[@]}" -X POST "$API$2" --data "$3")"
  registrar "$1" "$t0" "$code" "$hdr" "$bodyf"; rm -f "$hdr" "$bodyf"; sleep 2
}
lista51 () { python3 -c "import sys; print(','.join([sys.argv[1]]*51))" "$POSTMARK_FROM"; }

echo "Sondeo Postmark  $STAMP  casos=$CASOS"
echo "----------------------------------------------------------------"

# Comprobacion previa: que el token es de servidor y hay plantillas (GET no envia nada)
code="$(curl -sS -o /tmp/pm_t.$$ -w '%{http_code}' "${H[@]}" "$API/templates?count=5&offset=0")"
TPL="$(python3 -c "
import json,sys
try:
    d=json.load(open('/tmp/pm_t.$$'))
    ts=d.get('Templates',[])
    if not ts: print('')
    elif ts[0].get('Alias'): print('\"TemplateAlias\":\"%s\"' % ts[0]['Alias'])
    else: print('\"TemplateId\":%s' % ts[0]['TemplateId'])
except Exception: print('')
")"
echo "GET /templates -> HTTP $code, plantilla usada: ${TPL:-ninguna}"
rm -f /tmp/pm_t.$$
if [[ "$code" != "200" ]]; then echo "El token no es de servidor o no vale (HTTP $code). Parar."; echo "]" >> "$OUT"; exit 1; fi

if [[ "$CASOS" == *T* ]]; then
  if [[ -z "$TPL" ]]; then
    echo "Sin plantillas en el servidor: el caso T no se puede ejecutar (crea una plantilla cualquiera en el panel y repite)."
  else
    post "T_withTemplate_51_To" "/email/withTemplate" "{\"From\":\"$POSTMARK_FROM\",\"To\":\"$(lista51)\",$TPL,\"TemplateModel\":{}}"
  fi
fi

if [[ "$CASOS" == *B* ]]; then
  BODY="$(python3 -c "
import json,sys
f=sys.argv[1]
print(json.dumps([{'From':f,'To':f,'Subject':'TFM sondeo batch %d'%i,'TextBody':'B'} for i in range(501)]))" "$POSTMARK_FROM")"
  post "B_batch_501" "/email/batch" "$BODY"
fi

echo "]" >> "$OUT"
sed -i "s/${POSTMARK_SERVER_TOKEN}/REDACTADO/g" "$OUT"
echo "----------------------------------------------------------------"
echo "JSON guardado en: $OUT (token redactado). Pegar la tabla y el fichero en el chat."
