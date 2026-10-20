#!/usr/bin/env bash
# =============================================================================
# SONDEO MAILGUN E — segunda pasada: lo que REVISION.md dejo medible y sin medir
#
# COSTE EN ENVIOS: 0 ENTREGADOS, por construccion y con guarda.
#   Las dos peticiones a /messages de E3 van dirigidas a direcciones en
#   `example.invalid` (RFC 2606) y estan construidas para que la API las rechace ANTES
#   de entregar: una con 1.001 destinatarios (Mailgun corta en 1.000) y otra con un
#   destinatario no autorizado en el sandbox. Igual que en el sondeo A, cualquier 2xx
#   de /messages aborta el script entero.
#
# QUE MIDE, y por que no sale de la documentacion:
#   E1  Si el endpoint de plantillas responde en el plan Free. Cierra DISC-02: la matriz
#       de precios marca «Email Templates» en las cuatro columnas y los bullets de
#       Foundation lo anuncian como novedad de ese plan. Un 200 da la razon a la matriz.
#       Si crea la plantilla, el propio script la borra a continuacion.
#   E2  La profundidad de la paginacion de eventos. El tope POR PETICION esta medido
#       —300, con el rango en el error—; esto busca la otra mitad de la RPR de Postmark,
#       el tope acumulado al seguir el enlace `next`.
#   E3  Si una peticion RECHAZADA descuenta cuota. Se lee el contador, se provocan dos
#       rechazos y se vuelve a leer. Es la friccion F-21 y bastaba con mirar.
#
# Las credenciales se LEEN, no se sourcean (lib_env_catalogo.sh).
# =============================================================================
set -uo pipefail

readonly AQUI="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
. "$AQUI/lib_env_catalogo.sh" || exit 3
cat_exige_funciones cat_carga_env cat_limpia_funciones || exit 3
cat_limpia_funciones
cat_carga_env MAILGUN_API_KEY MAILGUN_DOMAIN || exit 3

[[ -n $MAILGUN_API_KEY && -n $MAILGUN_DOMAIN ]] || {
  echo "ABORTA: faltan MAILGUN_API_KEY o MAILGUN_DOMAIN en el .env." >&2; exit 3; }

[[ $MAILGUN_DOMAIN == sandbox* ]] || {
  echo "ABORTA: MAILGUN_DOMAIN no es un sandbox. Este sondeo solo corre contra sandbox." >&2
  exit 3; }

readonly BASE="https://api.mailgun.net"
readonly DEST="sondeo@example.invalid"
readonly REMITENTE="postmaster@${MAILGUN_DOMAIN}"
readonly SALIDA="${1:-$PWD/03_datos/apis/mailgun/evidencias}"
readonly HOY="$(date +%F)"
readonly PLANTILLA="sondeo-disc02-$(date +%s)"
mkdir -p "$SALIDA"
readonly LOG="$SALIDA/sondeo_e_segunda_pasada_${HOY}.txt"
readonly TMP="$SALIDA/.e"

redacta () { sed -e "s/${MAILGUN_API_KEY}/«CLAVE-REDACTADA»/g"; }
anota () { printf '%s\n' "$*" | tee -a "$LOG"; }

guarda_2xx () {  # $1 codigo $2 etiqueta
  if [[ $1 =~ ^2 ]]; then
    anota ""
    anota "!!! ABORTA: $2 devolvio HTTP $1. Mailgun ACEPTO el mensaje para entrega."
    anota "!!! Este sondeo se declara de coste cero y acaba de gastar un envio."
    exit 4
  fi
}

: > "$LOG"
anota "# Sondeo Mailgun E — segunda pasada"
anota "# Fecha: $HOY"
anota "# Dominio: $MAILGUN_DOMAIN (sandbox)"
anota "# Presupuesto declarado: 0 envios entregados. Un 2xx de /messages aborta."
anota ""

# ── E1 · DISC-02: el endpoint de plantillas en el plan Free ─────────────────
anota "═══ E1 · POST /v3/\$dominio/templates desde una cuenta Free ═══"
C=$(curl -s -o "$TMP.e1.json" -w '%{http_code}' \
      --user "api:$MAILGUN_API_KEY" \
      -X POST "$BASE/v3/$MAILGUN_DOMAIN/templates" \
      --form-string "name=$PLANTILLA" \
      --form-string 'description=sondeo DISC-02, se borra a continuacion' \
      --form-string 'template=<html><body>{{nombre}}</body></html>')
anota "HTTP $C"
anota "cuerpo: $(redacta < "$TMP.e1.json")"

if [[ $C =~ ^2 ]]; then
  anota "-> la plantilla se creo. Se borra para no dejar estado en la cuenta."
  D=$(curl -s -o "$TMP.e1del.json" -w '%{http_code}' \
        --user "api:$MAILGUN_API_KEY" \
        -X DELETE "$BASE/v3/$MAILGUN_DOMAIN/templates/$PLANTILLA")
  anota "DELETE HTTP $D · cuerpo: $(redacta < "$TMP.e1del.json")"
fi
anota ""

# ── E2 · profundidad de la paginacion de eventos ────────────────────────────
anota "═══ E2 · profundidad acumulada de GET /v3/\$dominio/events ═══"
URL="$BASE/v3/$MAILGUN_DOMAIN/events?limit=300"
PAGINA=0
TOTAL=0
while (( PAGINA < 25 )); do
  C=$(curl -s -o "$TMP.e2.json" -w '%{http_code}' --user "api:$MAILGUN_API_KEY" "$URL")
  N=$(python3 -c '
import json,sys
try:
    d=json.load(open(sys.argv[1]))
except Exception:
    print(-1); raise SystemExit
print(len(d.get("items") or []))
' "$TMP.e2.json")
  SIG=$(python3 -c '
import json,sys
try:
    d=json.load(open(sys.argv[1]))
except Exception:
    print(""); raise SystemExit
print((d.get("paging") or {}).get("next") or "")
' "$TMP.e2.json")
  PAGINA=$(( PAGINA + 1 ))
  [[ $N =~ ^-?[0-9]+$ ]] && (( N > 0 )) && TOTAL=$(( TOTAL + N ))
  anota "pagina $PAGINA · HTTP $C · items $N · hay enlace next: $([[ -n $SIG ]] && echo si || echo no)"
  if [[ ! $C =~ ^2 ]]; then
    anota "cuerpo del rechazo: $(redacta < "$TMP.e2.json")"
    break
  fi
  [[ -z $SIG ]] && { anota "-> se acabo el paginado sin rechazo, tras $TOTAL eventos"; break; }
  [[ $N == 0 ]] && { anota "-> el enlace next existe pero devuelve 0 items: fin real del paginado"; break; }
  URL="$SIG"
done
anota "total de eventos recorridos: $TOTAL en $PAGINA paginas"
anota ""

# ── E3 · F-21: descuenta cuota una peticion rechazada ───────────────────────
anota "═══ E3 · el contador antes y despues de dos rechazos ═══"

lee_contador () {  # imprime accepted.outgoing y delivered.smtp
  curl -s --user "api:$MAILGUN_API_KEY" \
    "$BASE/v3/$MAILGUN_DOMAIN/stats/total?event=accepted&event=delivered&duration=1m" \
  | python3 -c '
import json,sys
d=json.load(sys.stdin)
ac=de=0
for s in d.get("stats") or []:
    ac+=int(((s.get("accepted") or {}).get("outgoing")) or 0)
    de+=int(((s.get("delivered") or {}).get("smtp")) or 0)
print(f"accepted.outgoing={ac} delivered.smtp={de}")
'
}

ANTES="$(lee_contador)"
anota "antes: $ANTES"

# rechazo 1 — 1.001 destinatarios, Mailgun corta en 1.000 (400)
DESTS=""
for i in $(seq 1 1001); do DESTS="$DESTS -F to=d$i@example.invalid"; done
# shellcheck disable=SC2086
C=$(curl -s -o "$TMP.e3a.json" -w '%{http_code}' \
      --user "api:$MAILGUN_API_KEY" \
      -X POST "$BASE/v3/$MAILGUN_DOMAIN/messages" \
      -F from="$REMITENTE" $DESTS \
      -F subject='sondeo E3 rechazo por numero' \
      -F text='no debe salir')
guarda_2xx "$C" "E3 rechazo por numero"
anota "rechazo 1 · 1.001 destinatarios · HTTP $C · $(redacta < "$TMP.e3a.json")"

# rechazo 2 — destinatario no autorizado en el sandbox (403)
C=$(curl -s -o "$TMP.e3b.json" -w '%{http_code}' \
      --user "api:$MAILGUN_API_KEY" \
      -X POST "$BASE/v3/$MAILGUN_DOMAIN/messages" \
      -F from="$REMITENTE" -F to="$DEST" \
      -F subject='sondeo E3 rechazo por destinatario' \
      -F text='no debe salir')
guarda_2xx "$C" "E3 rechazo por destinatario"
anota "rechazo 2 · destinatario no autorizado · HTTP $C · $(redacta < "$TMP.e3b.json")"

sleep 5
DESPUES="$(lee_contador)"
anota "despues: $DESPUES"
[[ $ANTES == "$DESPUES" ]] \
  && anota "-> el contador NO se movio: un rechazo previo a la entrega no descuenta" \
  || anota "-> el contador SI se movio: algun rechazo descuenta. Mirar cual."
anota ""

rm -f "$TMP".*.json
anota "FIN · $(date +%F' '%T) · envios entregados: 0"
