#!/usr/bin/env bash
# =============================================================================
# SONDEO MAILGUN D — caudal contra un endpoint de LECTURA (escalon 3)
#
# COSTE EN ENVIOS: 0. Solo GET. Ningun endpoint de /messages se toca.
#
# QUE MIDE
#   Si el tope de «1,500 API requests per second per client IP» que la pagina
#   www.mailgun.com/ai-info/ publica se aplica de verdad, y si al superarlo aparece un
#   429 con cabeceras. El sondeo B ya midio que un GET normal NO trae cabeceras de
#   caudal; aqui se busca el punto donde empiezan a aparecer.
#
# COMO
#   Rampa de tasa: seis tandas de dos segundos a 10, 25, 50, 100, 200 y 400 peticiones
#   por segundo nominales. Tope duro de 2.000 peticiones en total y de 120 s de reloj.
#   Se mide la tasa CONSEGUIDA, no la nominal: desde una sola maquina y con TLS, la
#   nominal es una intencion.
#
# TOPE DECLARADO: 2.000 peticiones GET. Ninguna escribe nada.
# =============================================================================
set -uo pipefail
readonly AQUI="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
. "$AQUI/lib_env_catalogo.sh" || exit 3
cat_exige_funciones cat_carga_env cat_limpia_funciones || exit 3
cat_limpia_funciones
cat_carga_env MAILGUN_API_KEY || exit 3
[[ -n $MAILGUN_API_KEY ]] || { echo "ABORTA: falta MAILGUN_API_KEY." >&2; exit 3; }

readonly URL="https://api.mailgun.net/v4/domains?limit=1"
readonly SALIDA="${1:-$PWD/03_datos/apis/mailgun/evidencias}"
readonly HOY="$(date +%F)"
mkdir -p "$SALIDA"
readonly LOG="$SALIDA/sondeo_d_caudal_lectura_${HOY}.txt"
readonly TOPE_TOTAL=2000
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
GASTADAS=0
anota () { printf '%s\n' "$*" | tee -a "$LOG"; }

: > "$LOG"
anota "# Sondeo Mailgun D — caudal contra GET /v4/domains"
anota "# Fecha: $HOY   ·   Envios: 0, solo lectura"
anota "# Tope declarado: $TOPE_TOTAL peticiones GET"
anota "# Literal que se pone a prueba: «1,500 API requests per second per client IP»"
anota ""
anota "tanda  nominal  enviadas  segundos  tasa_real  2xx   429   otros  primera_429"
anota "-----  -------  --------  --------  ---------  ----  ----  -----  -----------"

for RPS in 10 25 50 100 200 400; do
  N=$((RPS*2))
  if (( GASTADAS + N > TOPE_TOTAL )); then
    anota "ABORTA la rampa: la tanda de $RPS req/s pasaria del tope de $TOPE_TOTAL."
    break
  fi
  : > "$TMP/codigos"
  T0=$(date +%s.%N)
  seq 1 "$N" | xargs -P "$RPS" -I{} curl -s -o /dev/null -w '%{http_code}\n' \
      --max-time 20 --user "api:$MAILGUN_API_KEY" "$URL" >> "$TMP/codigos" 2>/dev/null
  T1=$(date +%s.%N)
  GASTADAS=$((GASTADAS+N))
  DUR=$(awk -v a="$T0" -v b="$T1" 'BEGIN{printf "%.2f", b-a}')
  OK=$(grep -c '^2' "$TMP/codigos" || true)
  C429=$(grep -c '^429' "$TMP/codigos" || true)
  OTROS=$(grep -cvE '^(2|429)' "$TMP/codigos" || true)
  TASA=$(awk -v n="$N" -v d="$DUR" 'BEGIN{ if (d>0) printf "%.1f", n/d; else print "-" }')
  PRIMERA="-"
  (( C429 > 0 )) && PRIMERA="si"
  anota "$(printf '%-5s  %-7s  %-8s  %-8s  %-9s  %-4s  %-4s  %-5s  %s' \
          "$RPS" "$RPS/s" "$N" "$DUR" "$TASA" "$OK" "$C429" "$OTROS" "$PRIMERA")"
  if (( C429 > 0 )); then
    anota ""
    anota "429 alcanzado en la tanda de $RPS req/s. Se captura una respuesta con cabeceras:"
    curl -s -D "$TMP/h429" -o "$TMP/b429" --user "api:$MAILGUN_API_KEY" "$URL" >/dev/null
    anota "$(sed -e "s/${MAILGUN_API_KEY}/«CLAVE-REDACTADA»/g" < "$TMP/h429")"
    break
  fi
  sleep 3
done

anota ""
anota "Peticiones gastadas: $GASTADAS de un tope de $TOPE_TOTAL. Envios de correo: 0."
