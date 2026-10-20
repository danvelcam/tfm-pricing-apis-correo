#!/usr/bin/env bash
# Sondeo empirico MailerSend (escalon 3) - Q9: UNIDAD DE LA CUOTA MENSUAL - preparado 2026-09-14.
#
# QUE MIDE
#   Ninguna fuente de MailerSend dice como se cuentan los emails de la cuota mensual. La unica
#   pista es la aritmetica de [F49] ("500 individual email objects ... each containing up to 50 TO
#   recipients, 10 CC, and 10 BCC, for a total of 35,000 emails" = 500 x 70), que sugiere que un
#   "email" es un DESTINATARIO y no un mensaje. Este sondeo lo comprueba: manda UN solo mensaje a
#   DOS destinatarios distintos y mira cuanto baja el contador.
#     contador -2  ->  la unidad es el destinatario   (confirma lo aplicado; ademas Q8/D-032 sube
#                                                      el max: 70 de ambar a verde)
#     contador -1  ->  la unidad es el mensaje        (refuta lo aplicado; el 70 se queda ambar)
#
# ATENCION: A DIFERENCIA DE LAS TANDAS 1 Y 2, ESTE SONDEO **SI ENVIA CORREO DE VERDAD**.
#   Las tandas anteriores iban a coste cero con un remitente de dominio no verificado (422, nada
#   salia). Aqui hace falta que el mensaje SALGA, asi que el remitente es el dominio de prueba de
#   la cuenta, que esta verificado. Consecuencias, todas conocidas antes de ejecutar:
#     - gasta 1 o 2 de los 100 emails/mes de la cuenta Sandbox (justo lo que se quiere medir);
#     - consume los DOS destinatarios unicos que Sandbox permite hasta que la cuenta se apruebe
#       ("You can send to any 2 recipients in Sandbox mode, until your account is approved", F37).
#       El 14-09 se comprobo que el panel NO ofrece ninguna via de aprobacion, asi que esos dos
#       destinatarios no se recuperan: el envio es IRREVERSIBLE y no se puede repetir con otras
#       direcciones. Por eso el script pide confirmacion escrita y solo hace UN envio.
#
# POR QUE to=1 + cc=1 Y NO to=2
#   La tanda 2 (2026-09-10) midio que sin aprobar el tope de 'to' es exactamente 1: to=2 responde
#   422 "#MS42205" (DISC-18). La mayor combinacion que pasa la validacion es to 1 mas cc 1, que
#   son dos destinatarios distintos en una sola peticion. Esa es la unica via que queda.
#
# USO (en la maquina del autor; la clave NUNCA por el chat)
#   ~/.config/tfm/.env debe contener, con chmod 600:
#     MAILERSEND_API_KEY=mlsn....
#     Q9_FROM=...@test-86org8e1dvzgew13.mlsender.net   # remitente en el dominio de prueba
#     Q9_TO=...                                        # una direccion tuya
#     Q9_CC=...                                        # OTRA direccion tuya, distinta
#   bash probe_mailersend_q9_unidad.sh antes         # solo lee el estado de partida, NO envia
#   bash probe_mailersend_q9_unidad.sh enviar        # to y cc a DOS direcciones distintas
#   bash probe_mailersend_q9_unidad.sh enviar-mismo  # to y cc a LA MISMA direccion (ver abajo)
#   bash probe_mailersend_q9_unidad.sh despues       # vuelve a leer, para el contador con retardo
#
# LO QUE PASO EL 2026-09-14 Y POR QUE EXISTE 'enviar-mismo'
#   La fase 'enviar' con dos direcciones distintas respondio 422 con
#   "You have reached sandbox account unique recipients limit. #MS42225", pese a que la tanda 1
#   habia medido que to 1 mas cc 1 pasaba la validacion. La diferencia es el remitente: con
#   dominio no verificado la peticion moria antes, en MS42207, y nunca llegaba al chequeo de
#   destinatarios unicos. El literal de [F37], "You can send to any 2 recipients in Sandbox mode,
#   until your account is approved", no significa dos por peticion: es un cupo de la cuenta que
#   las tandas 1 y 2 ya agotaron probando direcciones, SIN QUE SALIERA NI UN CORREO.
#   GET /v1/recipients devuelve 0, asi que el cupo no es consultable ni se sabe que direcciones
#   lo gastaron. Queda un intento: repetir LA MISMA direccion en to y en cc. Como direccion unica
#   es una sola, deberia pasar el cupo, y el mensaje sigue teniendo dos entradas de destinatario.
#     422 MS42225 otra vez  ->  no gasta nada; Q9 cerrada como no medible
#     202 y contador -2     ->  concluyente: la unidad es la entrada de destinatario (Q8 a verde)
#     202 y contador -1     ->  AMBIGUO: o la unidad es el mensaje, o MailerSend deduplica la
#                               direccion repetida. No cierra Q9.
#
# EL CONTADOR VA CON RETARDO (O-11, DISC-17): el descuento de la cuota se aplica por lotes y
# minutos despues. Por eso hay fase 'despues' separada: ejecutala unas cuantas veces, espaciadas,
# hasta que el numero se estabilice. La lectura que manda para la cuota mensual es "Emails sent"
# del panel (https://app.mailersend.com/dashboard, indicador de uso al pie del menu); las lecturas
# por API que hace este script son el apoyo, no el veredicto.
#
# Salida: probe_mailersend_q9_<fase>_<fecha>.json junto a este script, con las direcciones
# REDACTADAS (nunca se escribe PII ni la clave). El JSON va despues a
# 03_datos/apis/mailersend/evidencias/

set -u
FASE="${1:-}"
case "$FASE" in
  antes|enviar|enviar-mismo|despues) ;;
  *) echo "Uso: bash $0 antes|enviar|enviar-mismo|despues"; exit 2 ;;
esac

set -a; . ~/.config/tfm/.env; set +a
: "${MAILERSEND_API_KEY:?Falta MAILERSEND_API_KEY en ~/.config/tfm/.env}"
: "${Q9_FROM:?Falta Q9_FROM (remitente en el dominio de prueba verificado)}"
BASE="https://api.mailersend.com"
OUT="$(dirname "$0")/probe_mailersend_q9_${FASE}_$(date -u +%Y-%m-%d_%H%M%S).json"
AUTH="Authorization: Bearer $MAILERSEND_API_KEY"

redactar () { python3 -c "
import sys,re
t=sys.stdin.read()
print(re.sub(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+', '<REDACTADO>', t))
"; }

leer_estado () {
  echo '--- GET /v1/api-quota (cuota DIARIA de peticiones; esta lectura no cuenta)'
  curl -s -D /tmp/q9h -H "$AUTH" "$BASE/v1/api-quota" | tee /tmp/q9q | redactar
  echo
  echo '--- GET /v1/domains (totals.sent por dominio: apoyo, no veredicto)'
  curl -s -H "$AUTH" "$BASE/v1/domains?limit=10" \
    | python3 -c "
import sys, json
d = json.load(sys.stdin)
for x in d.get('data', []):
    t = x.get('totals') or {}
    print('  dominio=%s  sent=%s  delivered=%s  rejected=%s'
          % (x.get('name'), t.get('sent'), t.get('delivered'), t.get('rejected')))
" 2>/dev/null || echo '  (no se pudo leer totals)'
  DOM_ID=$(curl -s -H "$AUTH" "$BASE/v1/domains?limit=10" \
    | python3 -c "import sys,json; d=json.load(sys.stdin).get('data') or [{}]; print(d[0].get('id',''))" 2>/dev/null)
  if [ -n "${DOM_ID:-}" ]; then
    echo "--- GET /v1/domains/$DOM_ID (la ficha si trae totals; el listado no)"
    curl -s -H "$AUTH" "$BASE/v1/domains/$DOM_ID" | python3 -c "
import sys, json
t = (json.load(sys.stdin).get('data') or {}).get('totals') or {}
print('  totals: %s' % (t or '(no expuesto en este estado de cuenta)'))
" 2>/dev/null || echo '  (no se pudo leer)'
    echo
    if [ "$FASE" = "despues" ]; then
      echo "--- GET /v1/activity/$DOM_ID  (una entrada por DESTINATARIO o por mensaje: es la pista)"
      curl -s -H "$AUTH" "$BASE/v1/activity/$DOM_ID?limit=25" | python3 -c "
import sys, json
d = json.load(sys.stdin).get('data') or []
print('  entradas: %d' % len(d))
for x in d:
    e = x.get('email') or {}
    print('   %s  %s  recipient=<REDACTADO>' % (x.get('created_at'), x.get('type')))
    if (e.get('recipient') or {}).get('email'):
        pass
" 2>/dev/null || echo '  (sin actividad legible)'
      echo
    fi
  fi
  echo '>>> AHORA MIRA EL PANEL: https://app.mailersend.com/dashboard'
  echo '>>> al pie del menu lateral, "Emails sent". APUNTA EL NUMERO Y LA HORA UTC.'
}

case "$FASE" in
  antes)
    echo "=== Q9 fase ANTES  ($(date -u +%Y-%m-%dT%H:%M:%SZ))"
    leer_estado
    { echo '{"fase":"antes","utc":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'","api_quota":'; cat /tmp/q9q; echo '}'; } \
      | redactar > "$OUT"
    echo "JSON: $OUT"
    ;;

  despues)
    echo "=== Q9 fase DESPUES  ($(date -u +%Y-%m-%dT%H:%M:%SZ))"
    echo "Recuerda: el descuento va con retardo y por lotes (O-11). Repite esta fase"
    echo "espaciada en el tiempo hasta que el numero deje de moverse."
    leer_estado
    { echo '{"fase":"despues","utc":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'","api_quota":'; cat /tmp/q9q; echo '}'; } \
      | redactar > "$OUT"
    echo "JSON: $OUT"
    ;;

  enviar|enviar-mismo)
    : "${Q9_TO:?Falta Q9_TO}"
    if [ "$FASE" = "enviar" ]; then
      : "${Q9_CC:?Falta Q9_CC}"
      if [ "$Q9_TO" = "$Q9_CC" ]; then
        echo "ERROR: Q9_TO y Q9_CC son la misma direccion. Para esta fase hacen falta DOS"
        echo "distintas; si lo que quieres es repetir una, usa la fase 'enviar-mismo'."; exit 1
      fi
      DEST_CC="$Q9_CC"
      ETIQ="1 to + 1 cc = DOS direcciones distintas"
      COSTE="  #  - gasta 1 o 2 de los 100 emails del mes                         #
  #  - consume los 2 destinatarios unicos de Sandbox, que NO se      #
  #    recuperan: la cuenta no se puede aprobar (no hay via en el    #
  #    panel)                                                        #"
    else
      DEST_CC="$Q9_TO"
      ETIQ="1 to + 1 cc = LA MISMA direccion repetida (una sola unica)"
      COSTE="  #  - gasta 1 o 2 de los 100 emails del mes                         #
  #  - NO deberia tocar el cupo de destinatarios unicos: es una      #
  #    sola direccion. Si aun asi responde MS42225, no se gasta      #
  #    nada y Q9 queda cerrada como no medible                       #"
    fi
    cat <<AVISO

  ####################################################################
  #  ESTO ENVIA UN CORREO DE VERDAD Y NO SE PUEDE DESHACER.          #
  #                                                                  #
$COSTE
  #                                                                  #
  #  Antes de seguir, ejecuta la fase 'antes' y apunta "Emails sent".#
  ####################################################################

AVISO
    printf 'Escribe exactamente  ENVIAR  para continuar: '
    read -r RESP
    [ "$RESP" = "ENVIAR" ] || { echo "Cancelado. No se ha enviado nada."; exit 0; }

    CUERPO=$(DEST_CC="$DEST_CC" python3 -c "
import json, os
print(json.dumps({
  'from': {'email': os.environ['Q9_FROM'], 'name': 'TFM probe'},
  'to':   [{'email': os.environ['Q9_TO']}],
  'cc':   [{'email': os.environ['DEST_CC']}],
  'subject': 'TFM Q9 unidad de cuota',
  'text': 'Sondeo Q9: un mensaje, dos entradas de destinatario. Mide como cuenta la cuota mensual.'
}))")
    echo "--- POST /v1/email  ($ETIQ)"
    CODE=$(curl -s -o /tmp/q9b -D /tmp/q9h -w '%{http_code}' \
      -X POST -H "$AUTH" -H 'Content-Type: application/json' \
      -d "$CUERPO" "$BASE/v1/email")
    echo "HTTP $CODE"
    echo "--- cabeceras de interes:"
    grep -iE '^(x-message-id|x-ratelimit|x-apiquota|retry-after)' /tmp/q9h || echo '  (ninguna)'
    echo "--- cuerpo:"; cat /tmp/q9b | redactar; echo
    if [ "$CODE" = "202" ]; then
      echo ">>> 202: aceptado, el mensaje sale. Espera unos minutos y ejecuta la fase 'despues'."
      echo ">>> Recuerda el criterio: contador -2 cierra Q9 y sube el max: 70 a verde;"
      echo ">>> contador -1 es ambiguo (unidad = mensaje, o deduplicacion de la direccion)."
    else
      echo ">>> NO es 202: el mensaje NO ha salido y no se ha gastado cuota mensual."
      echo ">>> (la cuota que baja en x-apiquota-remaining es la DIARIA de peticiones, otra cosa)"
      echo ">>> Pega esta salida en el chat."
    fi
    { echo '{"fase":"'"$FASE"'","utc":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'","http_code":"'"$CODE"'","cuerpo":'; \
      cat /tmp/q9b; echo ',"cabeceras":"'"$(grep -iE '^(x-message-id|x-ratelimit|x-apiquota)' /tmp/q9h | tr '\n' ';' | tr -d '"')"'"}'; } \
      | redactar > "$OUT"
    echo "JSON: $OUT"
    ;;
esac
