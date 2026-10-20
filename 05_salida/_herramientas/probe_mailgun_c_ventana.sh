#!/usr/bin/env bash
# =============================================================================
# SONDEO MAILGUN C — la ventana del caudal (escalon 3)
#
# COSTE EN ENVIOS: 12 ENTREGADOS COMO MAXIMO, todos a la lista blanca de D-046.
#   Presupuesto declarado y contado: la variable TOPE vale 12 y el script aborta al
#   llegar. Son el 0,4 % de los 3.000 emails/mes del plan Free de la cuenta.
#
# POR QUE CUESTA ENVIOS
#   El sondeo B midio que las cabeceras `x-ratelimit-*` y `x-recipient-*` SOLO aparecen
#   en un POST aceptado: el rechazo 403 del sondeo A no las trae. No hay via de coste
#   cero para este dato en Mailgun, y la condicion 3 de D-046 pide preferir el rechazo
#   «si la cifra se puede sacar» asi. Aqui no se puede.
#
# QUE MIDE, y por que hace falta mas de una peticion
#   El sondeo B dejo una sola lectura: limit 80000, remaining 79999, reset = instante de
#   la peticion + 10,3 s. Con un punto no se puede decir si la ventana es rodante o fija,
#   ni de cuanto es: esa es exactamente la ambiguedad que las reglas D3 y D8 no dejan
#   resolver por inferencia. Tres tandas separadas por pausas dan la forma de la curva:
#     Tanda 1  cinco peticiones seguidas  → como baja `remaining` y si `reset` se mueve
#     Pausa    15 s, por encima del reset observado
#     Tanda 2  una peticion               → si `remaining` volvio al tope
#     Tanda 3  seis peticiones seguidas   → si la caida se repite igual
#
# OJO, REGLA D6: lo que salga de aqui se REGISTRA y NO se adopta como valor de
#   `max_power` mientras no haya literal documental. El proposito declarado de este
#   sondeo es leer esas cabeceras, pero D-024 ya dejo en ambar el caso equivalente de
#   Postmark. El color lo decide el libro, no este script.
# =============================================================================
set -uo pipefail

readonly AQUI="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
. "$AQUI/lib_env_catalogo.sh" || exit 3
cat_exige_funciones cat_carga_env cat_limpia_funciones || exit 3
cat_limpia_funciones
cat_carga_env MAILGUN_API_KEY MAILGUN_DOMAIN || exit 3
[[ -n $MAILGUN_API_KEY && -n $MAILGUN_DOMAIN ]] || { echo "ABORTA: faltan credenciales." >&2; exit 3; }
[[ $MAILGUN_DOMAIN == sandbox* ]] || { echo "ABORTA: el dominio no es sandbox." >&2; exit 3; }

readonly DEST_PEDIDO="persona-3@example.invalid"     # literal, una de las tres de D-046
readonly GUARDA="$AQUI/lib_lista_blanca.py"
[[ -r $GUARDA ]] || { echo "ABORTA: falta la guarda $GUARDA." >&2; exit 3; }
DEST="$(python3 "$GUARDA" check "$DEST_PEDIDO")" || {
  echo "ABORTA: guarda rechazo el destinatario. No se llama a la API." >&2; exit 2; }

readonly BASE="https://api.mailgun.net"
readonly REMITENTE="postmaster@${MAILGUN_DOMAIN}"
readonly TOPE=12
readonly SALIDA="${1:-$PWD/03_datos/apis/mailgun/evidencias}"
readonly HOY="$(date +%F)"
mkdir -p "$SALIDA"
readonly LOG="$SALIDA/sondeo_c_ventana_${HOY}.txt"
GASTADOS=0
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
redacta () { sed -e "s/${MAILGUN_API_KEY}/«CLAVE-REDACTADA»/g"; }
anota () { printf '%s\n' "$*" | tee -a "$LOG"; }

peticion () {  # $1 etiqueta
  if (( GASTADOS >= TOPE )); then
    anota "ABORTA: presupuesto de $TOPE envios agotado. No se envia nada mas."
    exit 5
  fi
  GASTADOS=$((GASTADOS+1))
  local T0 C
  T0=$(date +%s.%N)
  C=$(curl -s -D "$TMP/h" -o "$TMP/b" -w '%{http_code}' \
        --user "api:$MAILGUN_API_KEY" \
        -X POST "$BASE/v3/$MAILGUN_DOMAIN/messages" \
        -F from="Sondeo TFM <$REMITENTE>" --form-string to="$DEST" \
        -F subject="Sondeo TFM ventana $1" -F text="Sondeo escalon 3 del TFM.")
  local RL RR RS PL PR
  RL=$(grep -i '^x-ratelimit-limit:'     "$TMP/h" | tr -d '\r' | awk '{print $2}')
  RR=$(grep -i '^x-ratelimit-remaining:' "$TMP/h" | tr -d '\r' | awk '{print $2}')
  RS=$(grep -i '^x-ratelimit-reset:'     "$TMP/h" | tr -d '\r' | awk '{print $2}')
  PL=$(grep -i '^x-recipient-limit:'     "$TMP/h" | tr -d '\r' | awk '{print $2}')
  PR=$(grep -i '^x-recipient-remaining:' "$TMP/h" | tr -d '\r' | awk '{print $2}')
  anota "$(printf '%-8s t=%s HTTP %s  ratelimit %s/%s reset=%s  recipient %s/%s' \
           "$1" "$(date -u +%H:%M:%S.%3N)" "$C" "${RR:--}" "${RL:--}" "${RS:--}" "${PR:--}" "${PL:--}")"
  if [[ ! $C =~ ^2 ]]; then
    anota "  cuerpo: $(redacta < "$TMP/b" | head -c 300)"
  fi
}

: > "$LOG"
anota "# Sondeo Mailgun C — la ventana del caudal"
anota "# Fecha: $HOY"
anota "# Presupuesto declarado: $TOPE envios, todos al destinatario que devolvio la guarda."
anota "# Las cabeceras se registran; la regla D6 decide si se adoptan, y este script no."
anota ""
anota "── Tanda 1: cinco peticiones seguidas ──"
for i in 1 2 3 4 5; do peticion "T1-$i"; done
anota ""
anota "── Pausa de 15 s (por encima del reset observado en el sondeo B) ──"
sleep 15
anota "── Tanda 2: una peticion ──"
peticion "T2-1"
anota ""
anota "── Tanda 3: seis peticiones seguidas ──"
for i in 1 2 3 4 5 6; do peticion "T3-$i"; done
anota ""
anota "FIN. Envios gastados: $GASTADOS de un presupuesto de $TOPE."
