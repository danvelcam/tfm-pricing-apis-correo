#!/usr/bin/env bash
# Sondeo empirico Postmark (escalon 3), tercera tanda - 2026-09-07
# Cierra la abierta 9: max 500 mensajes por lote en /email/batch y /email/batchWithTemplates.
#
# Par por bisección, coste 0 por diseño:
#   B500  /email/batch con 500 mensajes  -> lote ACEPTADO (HTTP 200, lista de 500 respuestas)
#   B501  /email/batch con 501 mensajes  -> lote RECHAZADO (HTTP 422, ErrorCode 410 "Too many batch messages")
#   T500  /email/batchWithTemplates 500  -> idem B500
#   T501  /email/batchWithTemplates 501  -> idem B501
#
# Por que no envia nada aunque el lote se acepte: la cuenta esta en test mode y solo puede
# enviar a dominios verificados. Cada mensaje va a un destinatario de dominio NO verificado,
# asi que Postmark rechaza los 500 uno a uno (ErrorCode 412, test mode) sin enviarlos ni
# gastar cuota. Es la mitigacion del riesgo que dejo sin ejecutar el caso B del 2026-09-06.
#
# USO (en esta maquina; el token lo exporta el autor, no va en el fichero ni en el chat):
#   export POSTMARK_SERVER_TOKEN='...'    # Server API Token (Servers > servidor > API Tokens). NO un Account token.
#   export POSTMARK_FROM='tu@correo'      # un Sender Signature CONFIRMADO
#   bash 05_salida/_herramientas/probe_postmark_batch_500.sh B      # solo /email/batch (2 llamadas)
#   bash 05_salida/_herramientas/probe_postmark_batch_500.sh BT     # tambien batchWithTemplates (4 llamadas)
set -u
CASOS="${1:-B}"
: "${POSTMARK_SERVER_TOKEN:?Falta POSTMARK_SERVER_TOKEN}"
: "${POSTMARK_FROM:?Falta POSTMARK_FROM}"
API="https://api.postmarkapp.com"
DEST="sondeo-tfm@example.invalid"   # dominio no verificado: test mode lo rechaza sin enviar
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
OUT="$(dirname "$0")/probe_postmark_batch_$(date -u +%Y-%m-%d_%H%M%S).json"
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
# En las listas de 500 respuestas se guarda el recuento por (ErrorCode, Message), no las 500 filas.
resumen = body
if isinstance(body, list):
    codes = {}
    for m in body:
        k = f"{m.get('ErrorCode')}|{m.get('Message')}"; codes[k] = codes.get(k, 0) + 1
    resumen = {"n_respuestas": len(body), "recuento_por_error": codes, "primera": body[0] if body else None}
rec = {"caso": nombre, "instante_utc": t0, "http": int(code), "cuerpo": resumen,
       "cabeceras": {k: v for k, v in headers.items() if any(s in k for s in ("ratelimit", "rate-limit", "retry", "date", "x-pm", "postmark"))}}
with open(out, "a", encoding="utf-8") as f:
    f.write(("" if primero == "1" else ",\n") + json.dumps(rec, ensure_ascii=True, indent=2))
if isinstance(body, dict):
    msg = f"ErrorCode {body.get('ErrorCode')} - {body.get('Message')}" if 'ErrorCode' in body else json.dumps(body)[:100]
elif isinstance(body, list):
    msg = f"lista de {len(body)} respuestas: " + "; ".join(f"{v}x [{k[:70]}]" for k, v in resumen["recuento_por_error"].items())
else: msg = str(body)[:120]
print(f"{nombre:<10} HTTP {code:<5} {msg[:150]}")
PY
  PRIMERO=0
}
post () {  # nombre path body
  local hdr="/tmp/pm_hdr.$$" bodyf="/tmp/pm_body.$$" t0 code
  t0="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  code="$(curl -sS -o "$bodyf" -D "$hdr" -w '%{http_code}' "${H[@]}" -X POST "$API$2" --data "$3")"
  registrar "$1" "$t0" "$code" "$hdr" "$bodyf"; rm -f "$hdr" "$bodyf"; sleep 3
}
lote () {  # n from dest [tpl-json]
  python3 -c "
import json,sys
n,f,d,tpl=int(sys.argv[1]),sys.argv[2],sys.argv[3],sys.argv[4]
if tpl:
    k,v=tpl.split(':',1); v=int(v) if v.isdigit() else v
    print(json.dumps({'Messages':[{'From':f,'To':d,k:v,'TemplateModel':{}} for i in range(n)]}))
else:
    print(json.dumps([{'From':f,'To':d,'Subject':'TFM sondeo lote %d'%i,'TextBody':'B'} for i in range(n)]))
" "$1" "$2" "$3" "${4:-}"
}

echo "Sondeo Postmark lotes  $STAMP  casos=$CASOS  destinatario=$DEST"
echo "----------------------------------------------------------------"
code="$(curl -sS -o /tmp/pm_t.$$ -w '%{http_code}' "${H[@]}" "$API/templates?count=5&offset=0")"
TPL="$(python3 -c "
import json
try:
    ts=json.load(open('/tmp/pm_t.$$')).get('Templates',[])
    if not ts: print('')
    elif ts[0].get('Alias'): print('TemplateAlias:%s' % ts[0]['Alias'])
    else: print('TemplateId:%s' % ts[0]['TemplateId'])
except Exception: print('')
")"
echo "GET /templates -> HTTP $code, plantilla: ${TPL:-ninguna}"
rm -f /tmp/pm_t.$$
if [[ "$code" != "200" ]]; then echo "El token no es de servidor o no vale (HTTP $code). Parar."; echo "]" >> "$OUT"; exit 1; fi

if [[ "$CASOS" == *B* ]]; then
  post "B500" "/email/batch" "$(lote 500 "$POSTMARK_FROM" "$DEST")"
  post "B501" "/email/batch" "$(lote 501 "$POSTMARK_FROM" "$DEST")"
fi
if [[ "$CASOS" == *T* ]]; then
  if [[ -z "$TPL" ]]; then echo "Sin plantillas: casos T saltados."; else
    post "T500" "/email/batchWithTemplates" "$(lote 500 "$POSTMARK_FROM" "$DEST" "$TPL")"
    post "T501" "/email/batchWithTemplates" "$(lote 501 "$POSTMARK_FROM" "$DEST" "$TPL")"
  fi
fi

echo "]" >> "$OUT"
sed -i "s/${POSTMARK_SERVER_TOKEN}/REDACTADO/g; s/${POSTMARK_FROM}/FROM_REDACTADO/g" "$OUT"
echo "----------------------------------------------------------------"
echo "JSON en: $OUT (token y From redactados). Pega la tabla en el chat."
