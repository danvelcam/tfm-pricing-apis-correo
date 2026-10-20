#!/usr/bin/env bash
# =============================================================================
# SONDEO MAILGUN B — un envio real, con guarda y presupuesto (escalon 3)
#
# COSTE EN ENVIOS: 1 ENTREGADO como maximo, y solo a la lista blanca de D-046.
#   Presupuesto declarado: 1 peticion a POST /v3/$dominio/messages. Si devuelve 2xx, el
#   script para: ya tiene lo que venia a buscar y no gasta un segundo envio.
#
# POR QUE HACE FALTA
#   El sondeo A demostro que la cuenta Free rechaza todo destinatario no autorizado con
#   403 «Free accounts are for test purposes only». Lo que A no puede decir es si
#   persona-3@example.invalid ESTA en la lista de destinatarios autorizados del sandbox. De
#   eso depende que el escalon 3 con envio real exista en Mailgun o no, y si no existe,
#   eso mismo es el hallazgo y se anota en not_found.
#
# QUE MIDE
#   1  Si el destinatario de la lista blanca esta autorizado en el sandbox.
#   2  Las cabeceras de la respuesta de un POST que SI se acepta. Regla D6: se registran
#      y NO se adoptan; no deciden ningun campo del YAML.
#   3  Si el contador de 3.000 emails/mes del panel se mueve con un envio.
#
# LA GUARDA
#   El destinatario se comprueba contra `lib_lista_blanca.py` ANTES de la primera
#   llamada, y lo que viaja a Mailgun es la SALIDA de la guarda, nunca la entrada
#   (condicion 1 de D-046). La direccion es literal en este fichero: no se lee del
#   entorno, no se generan variantes y no se parsea «Nombre <buzon>».
# =============================================================================
set -uo pipefail

readonly AQUI="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
. "$AQUI/lib_env_catalogo.sh" || exit 3
cat_exige_funciones cat_carga_env cat_limpia_funciones || exit 3
cat_limpia_funciones
cat_carga_env MAILGUN_API_KEY MAILGUN_DOMAIN || exit 3
[[ -n $MAILGUN_API_KEY && -n $MAILGUN_DOMAIN ]] || {
  echo "ABORTA: faltan MAILGUN_API_KEY o MAILGUN_DOMAIN." >&2; exit 3; }
[[ $MAILGUN_DOMAIN == sandbox* ]] || {
  echo "ABORTA: MAILGUN_DOMAIN no es un sandbox." >&2; exit 3; }

# Literal. Una de las tres de D-046. No sale del .env.
readonly DEST_PEDIDO="persona-3@example.invalid"
readonly GUARDA="$AQUI/lib_lista_blanca.py"
[[ -r $GUARDA ]] || { echo "ABORTA: no se encuentra la guarda $GUARDA." >&2; exit 3; }

DEST="$(python3 "$GUARDA" check "$DEST_PEDIDO")" || {
  echo "ABORTA: la guarda rechazo el destinatario. No se llama a la API." >&2; exit 2; }

readonly BASE="https://api.mailgun.net"
readonly REMITENTE="postmaster@${MAILGUN_DOMAIN}"
readonly SALIDA="${1:-$PWD/03_datos/apis/mailgun/evidencias}"
readonly HOY="$(date +%F)"
mkdir -p "$SALIDA"
readonly LOG="$SALIDA/sondeo_b_envio_${HOY}.txt"
redacta () { sed -e "s/${MAILGUN_API_KEY}/«CLAVE-REDACTADA»/g"; }
anota () { printf '%s\n' "$*" | tee -a "$LOG"; }

: > "$LOG"
anota "# Sondeo Mailgun B — un envio real"
anota "# Fecha: $HOY"
anota "# Dominio: $MAILGUN_DOMAIN (sandbox)"
anota "# Destinatario: la guarda de la lista blanca devolvio una direccion y es la que viaja."
anota "# Presupuesto declarado: 1 envio. Un 2xx cierra el sondeo."
anota ""

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

anota "═══ POST /v3/\$dominio/messages ═══"
C=$(curl -s -D "$TMP/h" -o "$TMP/b" -w '%{http_code}' \
      --user "api:$MAILGUN_API_KEY" \
      -X POST "$BASE/v3/$MAILGUN_DOMAIN/messages" \
      -F from="Sondeo TFM <$REMITENTE>" --form-string to="$DEST" \
      -F subject="Sondeo TFM Mailgun $HOY" \
      -F text="Sondeo del escalon 3 del TFM. Un solo envio, presupuesto declarado.")
anota "HTTP $C"
anota "--- cuerpo ---"
anota "$(redacta < "$TMP/b" | head -c 800)"
anota "--- cabeceras (D6: se registran, no se adoptan) ---"
anota "$(redacta < "$TMP/h")"
anota ""

if [[ $C =~ ^2 ]]; then
  anota "RESULTADO: el destinatario ESTA autorizado en el sandbox. Envios gastados: 1."
else
  anota "RESULTADO: el destinatario NO esta autorizado, o la cuenta no puede enviar."
  anota "Envios gastados: 0. El escalon 3 con envio real no existe en esta cuenta, y eso"
  anota "es el hallazgo: va a metadata.not_found."
fi
