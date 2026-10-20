#!/usr/bin/env bash
# =============================================================================
# SONDEO MAILGUN A — rechazos previos a la entrega (escalon 3)
#
# COSTE EN ENVIOS: 0 ENTREGADOS, por construccion y con guarda.
#   Todas las peticiones van dirigidas a `sondeo@example.invalid` (RFC 2606: el TLD
#   .invalid no resuelve y nadie puede tenerlo). Ademas el dominio de la cuenta es un
#   SANDBOX de Mailgun, que solo entrega a destinatarios autorizados, asi que hay dos
#   barreras independientes entre este script y un buzon real.
#
#   Aun asi, TODA respuesta 2xx de /messages ABORTA el script en el acto y se anota: un
#   2xx significa que Mailgun acepto el mensaje para entrega, que es justo lo que este
#   sondeo afirma no hacer. Preferir el rechazo al envio es la condicion 3 de D-046.
#
# QUE MIDE, y por que cada cosa no se puede sacar leyendo la documentacion:
#   T1  El texto literal de la restriccion del sandbox. Decide si el escalon 3 con envio
#       real es viable y contra que buzones.
#   T2  El maximo de destinatarios por peticion. La documentacion publica un numero para
#       el envio por lotes; este mide el que la API aplica de verdad.
#   T3  El tope de tamano del mensaje. Se busca el UMBRAL en el cuerpo del error, no el
#       numero de la pagina de ayuda.
#   T4  Las cabeceras de caudal en una lectura. OJO, regla D6: una cabecera que aparece
#       en un sondeo de otro proposito SE REGISTRA Y NO SE ADOPTA.
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

# El dominio TIENE que ser el sandbox. Si algun dia la cuenta tiene dominio propio, este
# sondeo no vale tal cual: un dominio propio entrega a cualquiera y example.invalid
# dejaria de ser la unica barrera.
[[ $MAILGUN_DOMAIN == sandbox* ]] || {
  echo "ABORTA: MAILGUN_DOMAIN no es un sandbox. Este sondeo solo corre contra sandbox." >&2
  exit 3; }

readonly BASE="https://api.mailgun.net"
readonly DEST="sondeo@example.invalid"
readonly REMITENTE="postmaster@${MAILGUN_DOMAIN}"
readonly SALIDA="${1:-$PWD/03_datos/apis/mailgun/evidencias}"
readonly HOY="$(date +%F)"
mkdir -p "$SALIDA"
readonly LOG="$SALIDA/sondeo_a_preflight_${HOY}.txt"

redacta () { sed -e "s/${MAILGUN_API_KEY}/«CLAVE-REDACTADA»/g"; }

anota () { printf '%s\n' "$*" | tee -a "$LOG"; }

# Cualquier 2xx de un endpoint de envio es un envio aceptado: se para todo.
guarda_2xx () {  # $1 codigo $2 etiqueta
  if [[ $1 =~ ^2 ]]; then
    anota ""
    anota "!!! ABORTA: $2 devolvio HTTP $1. Mailgun ACEPTO el mensaje para entrega."
    anota "!!! Este sondeo se declara de coste cero y acaba de gastar un envio."
    anota "!!! No se ejecuta ninguna prueba mas. Anotar el gasto en el libro."
    exit 4
  fi
}

: > "$LOG"
anota "# Sondeo Mailgun A — rechazos previos a la entrega"
anota "# Fecha: $HOY"
anota "# Dominio: $MAILGUN_DOMAIN (sandbox)"
anota "# Destinatario de todas las pruebas: $DEST (RFC 2606, no resuelve)"
anota "# Presupuesto declarado: 0 envios entregados. Un 2xx aborta."
anota ""

# ── T1 · restriccion del sandbox ────────────────────────────────────────────
anota "═══ T1 · POST /v3/\$dominio/messages con un destinatario no autorizado ═══"
C=$(curl -s -o "$SALIDA/.t1.json" -w '%{http_code}' \
      --user "api:$MAILGUN_API_KEY" \
      -X POST "$BASE/v3/$MAILGUN_DOMAIN/messages" \
      -F from="$REMITENTE" -F to="$DEST" \
      -F subject='sondeo TFM' -F text='sondeo TFM')
guarda_2xx "$C" "T1"
anota "HTTP $C"
anota "$(redacta < "$SALIDA/.t1.json" | head -c 1200)"
anota ""

# ── T2 · maximo de destinatarios por peticion ───────────────────────────────
# Se sube por potencias hasta que la API rechace por numero de destinatarios. Todos los
# destinatarios son de example.invalid y llevan indice: nunca se generan sobre un dominio
# propio, que es lo que D-046 marca en rojo.
anota "═══ T2 · numero de destinatarios por peticion ═══"
for N in 100 500 1000 1001 2000; do
  TO=""
  for ((i=1;i<=N;i++)); do TO+="sondeo${i}@example.invalid,"; done
  TO="${TO%,}"
  C=$(curl -s -o "$SALIDA/.t2.json" -w '%{http_code}' \
        --user "api:$MAILGUN_API_KEY" \
        -X POST "$BASE/v3/$MAILGUN_DOMAIN/messages" \
        -F from="$REMITENTE" --form-string to="$TO" \
        -F subject='sondeo TFM' -F text='sondeo TFM')
  guarda_2xx "$C" "T2 con $N destinatarios"
  anota "n=$N  → HTTP $C  $(redacta < "$SALIDA/.t2.json" | head -c 400)"
done
anota ""

# ── T3 · tope de tamano del mensaje ─────────────────────────────────────────
anota "═══ T3 · tamano del mensaje ═══"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
for MB in 10 25 26 30 50; do
  head -c "$((MB*1024*1024))" /dev/zero | tr '\0' 'A' > "$TMP/adjunto.txt"
  C=$(curl -s -o "$SALIDA/.t3.json" -w '%{http_code}' --max-time 180 \
        --user "api:$MAILGUN_API_KEY" \
        -X POST "$BASE/v3/$MAILGUN_DOMAIN/messages" \
        -F from="$REMITENTE" -F to="$DEST" \
        -F subject="sondeo TFM ${MB}MB" -F text='sondeo TFM' \
        -F attachment=@"$TMP/adjunto.txt")
  guarda_2xx "$C" "T3 con adjunto de ${MB} MB"
  anota "adjunto=${MB}MB  → HTTP $C  $(redacta < "$SALIDA/.t3.json" | head -c 400)"
done
anota ""

# ── T4 · cabeceras en una lectura ───────────────────────────────────────────
# D6: lo que salga de aqui SE REGISTRA Y NO SE ADOPTA. No decide ningun campo del YAML.
anota "═══ T4 · cabeceras de GET /v4/domains (D6: se registra, no se adopta) ═══"
curl -s -D "$SALIDA/.t4.hdr" -o /dev/null --user "api:$MAILGUN_API_KEY" \
     "$BASE/v4/domains?limit=1"
anota "$(redacta < "$SALIDA/.t4.hdr")"
anota ""
anota "FIN. Envios entregados: 0."
rm -f "$SALIDA"/.t1.json "$SALIDA"/.t2.json "$SALIDA"/.t3.json "$SALIDA"/.t4.hdr
