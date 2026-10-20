#!/usr/bin/env bash
# =============================================================================
# SONDEO MANDRILL A — rechazos previos a la entrega (escalon 3)
#
# COSTE EN ENVIOS: 0 ENTREGADOS, por construccion y con guarda.
#   Todo va a `sondeo@example.invalid` (RFC 2606). Ademas la cuenta no tiene ningun
#   dominio de envio verificado, que es una segunda barrera del propio proveedor.
#
#   /messages/send devuelve una LISTA con el estado de cada destinatario. Un estado
#   "sent" o "queued" significa entrega aceptada y ABORTA el script en el acto. Los
#   estados "rejected" e "invalid" son rechazos y no gastan envio.
#
# QUE MIDE:
#   T1  El estado y el `reject_reason` de un destinatario que no puede recibir.
#   T2  El maximo de destinatarios por llamada.
#   T3  El tope de tamano del mensaje (el adjunto viaja en base64 dentro del JSON).
#   T4  El tope horario `hourly_quota` que la propia API declara, y si /messages/send
#       lo menciona al rechazar.
#   T5  Cabeceras de la respuesta. D6: se registra y NO se adopta.
# =============================================================================
set -uo pipefail

readonly AQUI="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
. "$AQUI/lib_env_catalogo.sh" || exit 3
cat_exige_funciones cat_carga_env cat_limpia_funciones || exit 3
cat_limpia_funciones
cat_carga_env MANDRILL_API_KEY || exit 3
[[ -n $MANDRILL_API_KEY ]] || { echo "ABORTA: falta MANDRILL_API_KEY." >&2; exit 3; }

readonly BASE="https://mandrillapp.com/api/1.0"
readonly DEST="sondeo@example.invalid"
readonly REMITENTE="sondeo@example.invalid"
readonly SALIDA="${1:-$PWD/03_datos/apis/mailchimp/evidencias}"
readonly HOY="$(date +%F)"
mkdir -p "$SALIDA"
readonly LOG="$SALIDA/sondeo_a_preflight_${HOY}.txt"

redacta () { sed -e "s/${MANDRILL_API_KEY}/«CLAVE-REDACTADA»/g"; }
anota () { printf '%s\n' "$*" | tee -a "$LOG"; }

# Un "sent" o "queued" en la respuesta es una entrega aceptada: se para todo.
guarda_entrega () {  # $1 fichero de respuesta $2 etiqueta
  if grep -qE '"status":"(sent|queued|scheduled)"' "$1"; then
    anota ""
    anota "!!! ABORTA: $2 devolvio un destinatario en estado sent/queued/scheduled."
    anota "!!! Mandrill ACEPTO el mensaje para entrega y este sondeo se declara de coste cero."
    anota "!!! No se ejecuta ninguna prueba mas. Anotar el gasto en el libro."
    exit 4
  fi
}

envia () {  # $1 fichero json de cuerpo, $2 fichero de salida
  curl -s -o "$2" -w '%{http_code}' --max-time 240 \
       -X POST "$BASE/messages/send" \
       -H 'Content-Type: application/json' --data-binary @"$1"
}

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

: > "$LOG"
anota "# Sondeo Mandrill A — rechazos previos a la entrega"
anota "# Fecha: $HOY"
anota "# Destinatario de todas las pruebas: $DEST (RFC 2606, no resuelve)"
anota "# La cuenta no tiene dominio de envio verificado."
anota "# Presupuesto declarado: 0 envios entregados. Un sent/queued aborta."
anota ""

# ── T4a · lo que la propia API declara de la cuenta ─────────────────────────
anota "═══ T4a · POST /users/info ═══"
python3 - "$MANDRILL_API_KEY" > "$TMP/info.json" <<'PY'
import json,sys; print(json.dumps({"key":sys.argv[1]}))
PY
C=$(curl -s -o "$TMP/info.out" -w '%{http_code}' -X POST "$BASE/users/info" \
      -H 'Content-Type: application/json' --data-binary @"$TMP/info.json")
anota "HTTP $C"
anota "$(redacta < "$TMP/info.out" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(json.dumps({k:d[k] for k in ("reputation","hourly_quota","backlog") if k in d}))' 2>/dev/null || redacta < "$TMP/info.out" | head -c 300)"
anota ""

# ── T1 · destinatario que no puede recibir ──────────────────────────────────
anota "═══ T1 · POST /messages/send a un destinatario que no puede recibir ═══"
python3 - "$MANDRILL_API_KEY" "$REMITENTE" "$DEST" > "$TMP/t1.json" <<'PY'
import json,sys
k,f,t=sys.argv[1],sys.argv[2],sys.argv[3]
print(json.dumps({"key":k,"message":{"from_email":f,"subject":"sondeo TFM",
 "text":"sondeo TFM","to":[{"email":t,"type":"to"}]}}))
PY
C=$(envia "$TMP/t1.json" "$TMP/t1.out")
guarda_entrega "$TMP/t1.out" "T1"
anota "HTTP $C"
anota "$(redacta < "$TMP/t1.out" | head -c 1200)"
anota ""

# ── T2 · numero de destinatarios por llamada ────────────────────────────────
anota "═══ T2 · numero de destinatarios por llamada ═══"
for N in 100 1000 1001 5000; do
  python3 - "$MANDRILL_API_KEY" "$REMITENTE" "$N" > "$TMP/t2.json" <<'PY'
import json,sys
k,f,n=sys.argv[1],sys.argv[2],int(sys.argv[3])
to=[{"email":"sondeo%d@example.invalid"%i,"type":"to"} for i in range(1,n+1)]
print(json.dumps({"key":k,"message":{"from_email":f,"subject":"sondeo TFM",
 "text":"sondeo TFM","to":to}}))
PY
  C=$(envia "$TMP/t2.json" "$TMP/t2.out")
  guarda_entrega "$TMP/t2.out" "T2 con $N destinatarios"
  anota "n=$N  → HTTP $C  $(redacta < "$TMP/t2.out" | head -c 350)"
done
anota ""

# ── T3 · tope de tamano del mensaje ─────────────────────────────────────────
anota "═══ T3 · tamano del mensaje (adjunto en base64 dentro del JSON) ═══"
for MB in 10 25 26 30; do
  python3 - "$MANDRILL_API_KEY" "$REMITENTE" "$DEST" "$MB" > "$TMP/t3.json" <<'PY'
import json,sys,base64
k,f,t,mb=sys.argv[1],sys.argv[2],sys.argv[3],int(sys.argv[4])
raw=b"A"*(mb*1024*1024)
print(json.dumps({"key":k,"message":{"from_email":f,"subject":"sondeo TFM %dMB"%mb,
 "text":"sondeo TFM","to":[{"email":t,"type":"to"}],
 "attachments":[{"type":"text/plain","name":"a.txt",
   "content":base64.b64encode(raw).decode()}]}}))
PY
  C=$(envia "$TMP/t3.json" "$TMP/t3.out")
  guarda_entrega "$TMP/t3.out" "T3 con adjunto de ${MB} MB"
  anota "adjunto=${MB}MB  → HTTP $C  $(redacta < "$TMP/t3.out" | head -c 350)"
done
anota ""

# ── T5 · cabeceras (D6: se registra, no se adopta) ──────────────────────────
anota "═══ T5 · cabeceras de POST /users/ping2 (D6: se registra, no se adopta) ═══"
curl -s -D "$TMP/t5.hdr" -o /dev/null -X POST "$BASE/users/ping2" \
     -H 'Content-Type: application/json' --data-binary @"$TMP/info.json"
anota "$(redacta < "$TMP/t5.hdr")"
anota ""
anota "FIN. Envios entregados: 0."
