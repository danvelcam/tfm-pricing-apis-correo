#!/usr/bin/env bash
# Sondeo empirico MailerSend (escalon 3) - TANDA 2 - preparado el 2026-09-09, ajustado el mismo
# dia tras la segunda ejecucion de la tanda 1.
# Continuacion de probe_mailersend_sandbox.sh (tanda 1, ejecutada DOS veces el 2026-09-09: 19:02 UTC,
# evidencias/probe_sandbox_limites_2026-09-09.json, y 19:13 UTC,
# evidencias/probe_sandbox_limites_2026-09-09_tanda1b.json). Mismo diseno a COSTE CERO y sin
# entregar correo: cada POST lleva un remitente de dominio NO verificado
# (from = probe@dominio-no-verificado.invalid), la validacion devuelve 422 MS42207 y el mensaje
# nunca se envia; como el 422 informa TODOS los campos que fallan, el par N / N+1 revela el tope.
#
# Lo que las dos ejecuciones de la tanda 1 ensenaron y esta tanda corrige:
#   - la cuenta Sandbox NO aprobada tiene un caudal de 10 peticiones/min en POST /v1/email
#     (429 en la undecima) y de 1 peticion/min en POST /v1/bulk-email (429 en la segunda):
#     aqui se hacen como mucho 9 POST a /v1/email con 'sleep 7' entre llamadas (< 10/min) y un
#     solo lote, tras esperar 61 s;
#   - la cuota diaria de peticiones YA ESTA MEDIDA (DISC-17 resuelta en la segunda ejecucion):
#     cada peticion cuenta 1, tambien las 422, las 429 y el 202 del lote; lo que pasa es que el
#     contador que devuelven x-apiquota-remaining y GET /v1/api-quota se actualiza CON RETARDO Y
#     POR LOTES (17 y 14 de golpe), no por peticion (O-11). Por eso esta tanda NO intenta medir el
#     descuento: solo lee la cuota una vez al empezar, como presupuesto del dia (necesita 12 de
#     las ~66 que quedaban a las 19:14 UTC del dia 9; se repone a las 00:00 UTC);
#   - to=10 ya devolvio MS42205 en las dos ejecuciones (DISC-18: la doc dice 'up to 10 TO' sin
#     aprobar): se acota con to 2/3, 5/6 y 9;
#   - tags 5/6 y subject 998/999 dieron 429 sin validar, dos veces: se repiten con el caudal
#     repartido;
#   - las dos ejecuciones aceptaron un lote de 5 con 202 (dos bulk_email_id): se consulta el
#     estado de los dos.
#
# Resuelve:
#   A2 GET /v1/api-quota una vez, al principio (presupuesto; no mide nada: el contador va por lotes)
#   B2 tope de 'to' en cuenta no aprobada: 2/3, 5/6, 9 (DISC-18); MS42225 marca los 2 unicos
#   C2 GET /v1/bulk-email/{id} de los DOS lotes aceptados en la tanda 1 (validation_errors:
#      demuestra que el 202 no envio nada, F-04) y lote de 6 objetos tras 61 s (tope 5/6 de
#      Sandbox, MS42229)
#   T2 tags 5/6 y subject 998/999 (topes menores del cuerpo, documentados)
#   Todo 429 que aparezca: cabeceras retry-after / x-ratelimit-* (DISC-19, tercera ventana)
#
# USO (en la maquina del autor; la clave NUNCA por el chat):
#   ~/.config/tfm/.env debe contener MAILERSEND_API_KEY=mlsn....   (chmod 600)
#   bash probe_mailersend_sandbox_t2.sh              # todo (A B C T): 13 peticiones, ~3 min
#   bash probe_mailersend_sandbox_t2.sh AB           # solo A y B
#   bash probe_mailersend_sandbox_t2.sh ABCT <bulk_id_1> <bulk_id_2>   # otros ids de lote
#
# Salida: probe_mailersend_t2_<fecha>.json junto a este script (clave redactada, no se escribe)
# y una tabla en pantalla. Pegar la tabla en el chat; el JSON va a
# 03_datos/apis/mailersend/evidencias/probe_sandbox_limites_t2_<fecha>.json

set -u
CASOS="${1:-ABCT}"
BULK_ID_1="${2:-6aa1ad527e48ed427f18cf4e}"  # lote de 5 aceptado con 202 el 2026-09-09 a las 19:02 UTC (tanda 1)
BULK_ID_2="${3:-6aa1affd1e3217ac0dd87aa1}"  # lote de 5 aceptado con 202 el 2026-09-09 a las 19:14 UTC (tanda 1b)
PAUSA=7                                      # segundos entre llamadas: 9 POST /v1/email < 10/min
set -a; . ~/.config/tfm/.env; set +a
: "${MAILERSEND_API_KEY:?Falta MAILERSEND_API_KEY en ~/.config/tfm/.env}"
BASE="https://api.mailersend.com"
FROM="probe@dominio-no-verificado.invalid"
OUT="$(dirname "$0")/probe_mailersend_t2_$(date -u +%Y-%m-%d_%H%M%S).json"
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
  sleep "$PAUSA"
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

echo "Sondeo MailerSend (Sandbox) TANDA 2 $(date -u +%Y-%m-%dT%H:%M:%SZ) - casos: $CASOS - remitente no verificado, coste 0, pausa ${PAUSA}s"
echo "Reloj UTC al empezar: $(date -u +%H:%M:%S) (la cuota diaria se repone a las 00:00 UTC)"
echo

if [[ "$CASOS" == *A* ]]; then
  llamada "A2_api_quota_inicio" GET "/v1/api-quota" "presupuesto del dia antes de gastar (la tanda necesita 12); NO mide el descuento: el contador se actualiza por lotes y con retardo (DISC-17 resuelta, O-11)"
fi

if [[ "$CASOS" == *B* ]]; then
  llamada "B2_to_2" POST "/v1/email" "to=2: 2 destinatarios unicos (tope Sandbox); debe pasar la validacion de to" "$(cuerpo 2 0 0 0 0)"
  llamada "B2_to_3" POST "/v1/email" "to=3: 3 unicos; MS42225 o MS42205 en to (DISC-18)"            "$(cuerpo 3 0 0 0 0)"
  llamada "B2_to_5" POST "/v1/email" "to=5: acotar el tope de to sin aprobar (DISC-18)"            "$(cuerpo 5 0 0 0 0)"
  llamada "B2_to_6" POST "/v1/email" "to=6: acotar el tope de to sin aprobar (DISC-18)"            "$(cuerpo 6 0 0 0 0)"
  llamada "B2_to_9" POST "/v1/email" "to=9: ultimo valor por debajo de los 10 documentados"        "$(cuerpo 9 0 0 0 0)"
fi

if [[ "$CASOS" == *C* ]]; then
  llamada "C2_bulk_status_t1"  GET "/v1/bulk-email/$BULK_ID_1" "estado y validation_errors del lote de 5 aceptado con 202 en la tanda 1, 19:02 UTC (F-04: no debe haber enviado nada)"
  llamada "C2_bulk_status_t1b" GET "/v1/bulk-email/$BULK_ID_2" "estado y validation_errors del lote de 5 aceptado con 202 en la tanda 1b, 19:14 UTC (F-04: no debe haber enviado nada)"
  echo "(esperando 61 s para asegurar un minuto nuevo del caudal de 1 lote/min sin aprobar)"
  sleep 61
  llamada "C2_bulk_6" POST "/v1/bulk-email" "6 objetos: tope Sandbox documentado 5; debe devolver MS42229 o similar (o 202 si valida en diferido)" "$(lote 6)"
fi

if [[ "$CASOS" == *T* ]]; then
  llamada "T2_tags_5"      POST "/v1/email" "tags=5: tope documentado"          "$(cuerpo 1 0 0 5 0)"
  llamada "T2_tags_6"      POST "/v1/email" "tags=6: debe fallar"               "$(cuerpo 1 0 0 6 0)"
  llamada "T2_subject_998" POST "/v1/email" "subject 998: tope documentado"     "$(cuerpo 1 0 0 0 998)"
  llamada "T2_subject_999" POST "/v1/email" "subject 999: debe fallar"          "$(cuerpo 1 0 0 0 999)"
fi

# (Sin lectura final de la cuota: la segunda ejecucion de la tanda 1 ya midio que cada peticion
#  cuenta 1 y que el contador expuesto va por lotes y con retardo; una lectura 7 s despues de la
#  ultima peticion no la reflejaria. DISC-17 resuelta, O-11.)

echo "]" >> "$OUT"
echo
echo "Peticiones realizadas: $N (reloj UTC al terminar: $(date -u +%H:%M:%S))"
echo "JSON: $OUT  (sin clave; comprobar que no aparece ningun dato personal antes de copiarlo a evidencias/)"
