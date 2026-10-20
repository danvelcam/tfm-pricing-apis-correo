#!/usr/bin/env bash
# Test del guardian de rutas de probe_brevo_a_429_rps.sh.
#
# QUE PRUEBA, Y POR QUE ESTE TEST EXISTE
#   El sondeo del 429 dispara una RAFAGA sin pausas. Si una de sus rutas fuese el endpoint
#   de envio, la rafaga gastaria credito y generaria rebotes antes de que nadie lo mirase.
#   El endpoint de envio es /smtp/email EXACTO, y /smtp/emails -- que es justo el que este
#   sondeo tiene que golpear -- lo contiene como subcadena: un '*/smtp/email*' prohibiria
#   la medicion entera, y un '== /smtp/email' sin el caso de la query dejaria pasar
#   '/smtp/email?foo=1'. Los tres casos limite se comprueban aqui.
set -u
unset CDPATH
AQUI="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck source=/dev/null
. "$AQUI/probe_brevo_a_429_rps.sh" --solo-funciones || { echo "FALLA: el sondeo no se deja cargar como libreria"; exit 1; }

FALLOS=0
comprueba () {  # $1 ruta  $2 esperado (ENVIO|INOCUA)
  local OBTENIDO
  if ruta_es_envio "$1"; then OBTENIDO=ENVIO; else OBTENIDO=INOCUA; fi
  if [[ $OBTENIDO == "$2" ]]; then
    printf 'ok    %-28s -> %s\n' "$1" "$OBTENIDO"
  else
    printf 'FALLA %-28s -> %s (esperado %s)\n' "$1" "$OBTENIDO" "$2"
    FALLOS=$((FALLOS + 1))
  fi
}

comprueba "/smtp/email"            ENVIO
comprueba "/smtp/email?foo=1"      ENVIO
comprueba "/smtp/emails?limit=1"   INOCUA
comprueba "/smtp/templates?limit=1" INOCUA
comprueba "/account"               INOCUA

if (( FALLOS == 0 )); then echo "TODO EN VERDE"; exit 0; fi
echo "$FALLOS caso(s) en rojo"; exit 1
