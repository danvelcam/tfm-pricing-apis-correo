#!/usr/bin/env bash
# Sondeo empirico MailerSend (escalon 3) - 2026-09-08
# Diseno a COSTE CERO y sin entregar correo: cada POST lleva un remitente de dominio NO
# verificado (from = probe@dominio-no-verificado.invalid), de modo que la validacion
# devuelve 422 MS42207 y el mensaje nunca se envia. Como la validacion de MailerSend
# informa TODOS los campos que fallan en el mismo 422, el par N / N+1 del campo sondeado
# revela el tope (por ejemplo 'to': 50 pasa, 51 devuelve MS42205) sin consumir emails.
# Cada peticion SI cuenta contra la cuota diaria de peticiones (100/dia en Sandbox):
# el sondeo completo gasta ~16 peticiones.
#
# Resuelve:
#   A  GET /v1/api-quota y cabeceras x-apiquota-*: valor y hora de reposicion de la cuota
#      diaria de peticiones (window_type de la cuota diaria: fixed_utc_midnight)
#   B  topes de destinatarios por peticion en /v1/email: to 50/51, cc 10/11, bcc 10/11
#      (docs: 'Min 1, max 50', 'Max 10', 'Max 10'; MS42205: 'Approved accounts can include
#      up to 50 TO, 10 CC and 10 BCC recipients. Unapproved acounts can include up to 10 TO,
#      1 CC and 1 BCC' -> la cuenta Sandbox NO esta aprobada: se sondea tambien 10/11 y 1/2)
#   C  tope de objetos por lote en /v1/bulk-email: 5/6 (docs: '5 for Sandbox accounts')
#   R  cabeceras x-ratelimit-* de /v1/email (120/min), /v1/bulk-email (10/min) y de un
#      endpoint general GET /v1/domains (60/min); solo lectura de cabeceras, sin forzar 429
#   T  tags 5/6 y subject 998/999 (topes menores de la peticion, documentados)
#
# USO (en la maquina del autor; la clave NUNCA por el chat):
#   ~/.config/tfm/.env debe contener MAILERSEND_API_KEY=mlsn....   (chmod 600)
#   bash probe_mailersend_sandbox.sh          # todo (A B C R T): ~16 peticiones
#   bash probe_mailersend_sandbox.sh AB       # solo A y B
#
# Salida: probe_mailersend_<fecha>.json junto a este script (clave redactada, no se escribe)
# y una tabla en pantalla. Pegar la tabla en el chat; el JSON va a
# 03_datos/apis/mailersend/evidencias/probe_sandbox_limites_<fecha>.json

set -u
CASOS="${1:-ABCRT}"
set -a; . ~/.config/tfm/.env; set +a
: "${MAILERSEND_API_KEY:?Falta MAILERSEND_API_KEY en ~/.config/tfm/.env}"
BASE="https://api.mailersend.com"
FROM="probe@dominio-no-verificado.invalid"
OUT="$(dirname "$0")/probe_mailersend_$(date -u +%Y-%m-%d_%H%M%S).json"
echo "[" > "$OUT"
PRIMERO=1
N=0

registrar () {  # nombre, metodo, ruta, code, hdrfile, bodyfile, nota
  python3 - "$1" "$2" "$3" "$4" "$5" "$6" "$OUT" "$PRIMERO" "$7" <<'PY'
import sys, json
nombre, metodo, ruta, code, hdr, bodyf, out, primero, nota = sys.argv[1:10]
headers = {}
for line in open(hdr, encoding='utf-8', errors='replace'):
    if ':' in line:
        k, v = line.split(':', 1); headers[k.strip().lower()] = v.strip()
try:
    body = json.load(open(bodyf, encoding='utf-8'))
except Exception:
    body = open(bodyf, encoding='utf-8', errors='replace').read()[:2000]
keep = {k: v for k, v in headers.items() if any(s in k for s in ("ratelimit", "apiquota", "retry", "date", "x-message-id", "x-send-paused"))}
rec = {"caso": nombre, "nota": nota, "metodo": metodo, "ruta": ruta, "http": int(code), "cuerpo": body, "cabeceras": keep}
with open(out, "a", encoding="utf-8") as f:
    f.write(("" if primero == "1" else ",\n") + json.dumps(rec, ensure_ascii=True, indent=2))
msg = ""
if isinstance(body, dict):
    errs = body.get("errors") or {}
    if errs:
        # lista compacta campo: primer mensaje
        partes = []
        for k, v in errs.items():
            m = v[0] if isinstance(v, list) and v else str(v)
            partes.append("%s: %s" % (k, m))
        msg = " | ".join(partes)
    else:
        msg = json.dumps(body)[:160]
else:
    msg = str(body)[:160]
print("%-30s HTTP %-4s %s" % (nombre, code, msg[:150]))
for k, v in keep.items():
    if "ratelimit" in k or "apiquota" in k or "retry" in k:
        print("%-30s   %s: %s" % ("", k, v))
PY
  PRIMERO=0
}

llamada () {  # nombre, metodo, ruta, nota, [json_body]
  local nombre="$1" metodo="$2" ruta="$3" nota="$4" body="${5:-}" hdr="/tmp/ms_hdr.$$" bf="/tmp/ms_body.$$" code
  if [[ "$metodo" == "POST" ]]; then
    code="$(curl -sS -o "$bf" -D "$hdr" -w '%{http_code}' -H "Authorization: Bearer $MAILERSEND_API_KEY" \
        -H "Content-Type: application/json" -H "X-Requested-With: XMLHttpRequest" -X POST "$BASE$ruta" --data-binary @<(printf '%s' "$body"))"
  else
    code="$(curl -sS -o "$bf" -D "$hdr" -w '%{http_code}' -H "Authorization: Bearer $MAILERSEND_API_KEY" -H "X-Requested-With: XMLHttpRequest" "$BASE$ruta")"
  fi
  N=$((N+1))
  registrar "$nombre" "$metodo" "$ruta" "$code" "$hdr" "$bf" "$nota"
  rm -f "$hdr" "$bf"
  sleep 2
}

lista () {  # n, prefijo -> [{"email":"p1@example.com"},...]
  python3 -c 'import sys,json; n=int(sys.argv[1]); p=sys.argv[2]; print(json.dumps([{"email":"%s%d@example.com"%(p,i)} for i in range(1,n+1)]))' "$1" "$2"
}

# cuerpo de /v1/email: n_to, n_cc, n_bcc, n_tags, len_subject
cuerpo () {
  python3 - "$FROM" "$1" "$2" "$3" "$4" "$5" <<'PY'
import sys, json
frm, nto, ncc, nbcc, ntags, lsub = sys.argv[1], *map(int, sys.argv[2:7])
b = {"from": {"email": frm, "name": "Sondeo TFM"},
     "to": [{"email": "to%d@example.com" % i} for i in range(1, nto+1)],
     "subject": ("S" * lsub) if lsub else "Sondeo de limites (nunca se envia: remitente no verificado)",
     "text": "Sondeo a coste cero. Este mensaje no puede enviarse: el dominio del remitente no esta verificado."}
if ncc: b["cc"] = [{"email": "cc%d@example.com" % i} for i in range(1, ncc+1)]
if nbcc: b["bcc"] = [{"email": "bcc%d@example.com" % i} for i in range(1, nbcc+1)]
if ntags: b["tags"] = ["t%d" % i for i in range(1, ntags+1)]
print(json.dumps(b))
PY
}

lote () {  # n objetos de bulk, cada uno con remitente no verificado y 1 destinatario
  python3 -c 'import sys,json; n=int(sys.argv[1]); f=sys.argv[2]; print(json.dumps([{"from":{"email":f},"to":[{"email":"b%d@example.com"%i}],"subject":"Sondeo lote","text":"no se envia"} for i in range(1,n+1)]))' "$1" "$FROM"
}

echo "Sondeo MailerSend (Sandbox) $(date -u +%Y-%m-%dT%H:%M:%SZ) - casos: $CASOS - remitente no verificado, coste 0"
echo

if [[ "$CASOS" == *A* ]]; then
  llamada "A_api_quota" GET "/v1/api-quota" "cuota diaria de peticiones: quota, remaining, reset"
fi

if [[ "$CASOS" == *B* ]]; then
  llamada "B_to_10"  POST "/v1/email" "to=10: tope de cuenta NO aprobada segun MS42205"  "$(cuerpo 10 0 0 0 0)"
  llamada "B_to_11"  POST "/v1/email" "to=11: debe fallar si la cuenta no esta aprobada" "$(cuerpo 11 0 0 0 0)"
  llamada "B_to_50"  POST "/v1/email" "to=50: tope documentado 'max 50'"                 "$(cuerpo 50 0 0 0 0)"
  llamada "B_to_51"  POST "/v1/email" "to=51: debe devolver MS42205"                     "$(cuerpo 51 0 0 0 0)"
  llamada "B_cc_1"   POST "/v1/email" "cc=1 (cuenta no aprobada: tope 1)"                "$(cuerpo 1 1 0 0 0)"
  llamada "B_cc_2"   POST "/v1/email" "cc=2"                                             "$(cuerpo 1 2 0 0 0)"
  llamada "B_cc_10"  POST "/v1/email" "cc=10: tope documentado 'Max 10'"                 "$(cuerpo 1 10 0 0 0)"
  llamada "B_cc_11"  POST "/v1/email" "cc=11: debe devolver MS42205"                     "$(cuerpo 1 11 0 0 0)"
  llamada "B_bcc_10" POST "/v1/email" "bcc=10: tope documentado 'Max 10'"                "$(cuerpo 1 0 10 0 0)"
  llamada "B_bcc_11" POST "/v1/email" "bcc=11: debe devolver MS42205"                    "$(cuerpo 1 0 11 0 0)"
fi

if [[ "$CASOS" == *C* ]]; then
  llamada "C_bulk_5"  POST "/v1/bulk-email" "5 objetos: tope Sandbox documentado"         "$(lote 5)"
  llamada "C_bulk_6"  POST "/v1/bulk-email" "6 objetos: debe devolver MS42229 o similar"  "$(lote 6)"
fi

if [[ "$CASOS" == *R* ]]; then
  llamada "R_get_domains" GET "/v1/domains?limit=10" "cabeceras x-ratelimit-* de un endpoint general (60/min)"
fi

if [[ "$CASOS" == *T* ]]; then
  llamada "T_tags_5"      POST "/v1/email" "tags=5: tope documentado"          "$(cuerpo 1 0 0 5 0)"
  llamada "T_tags_6"      POST "/v1/email" "tags=6: debe fallar"               "$(cuerpo 1 0 0 6 0)"
  llamada "T_subject_998" POST "/v1/email" "subject 998: tope documentado"     "$(cuerpo 1 0 0 0 998)"
  llamada "T_subject_999" POST "/v1/email" "subject 999: debe fallar"          "$(cuerpo 1 0 0 0 999)"
fi

if [[ "$CASOS" == *A* ]]; then
  llamada "A_api_quota_final" GET "/v1/api-quota" "cuota tras el sondeo: remaining debe haber bajado en el numero de peticiones"
fi

echo "]" >> "$OUT"
echo
echo "Peticiones realizadas: $N (todas cuentan contra la cuota diaria de 100)"
echo "JSON: $OUT  (sin clave; comprobar que no aparece ningun dato personal antes de copiarlo a evidencias/)"
