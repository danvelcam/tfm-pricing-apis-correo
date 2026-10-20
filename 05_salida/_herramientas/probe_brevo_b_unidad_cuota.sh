#!/usr/bin/env bash
# =============================================================================
# Sondeo empirico Brevo - escalon 3 - PAQUETE B, sondeo 1 - preparado 2026-09-17
#
# QUE PREGUNTAS RESUELVE
#
#   (1) LA UNIDAD DE LA CUOTA: el volumen del plan se descuenta por PETICION o por
#       DESTINATARIO?  Es el sondeo 1 de REVISION.md, "Escalon 3 - sondeos que SI exigen
#       envio real", y cierra la unidad del CRF de TODA la datasheet. Hoy el fichero lo
#       dice de si mismo: "Que cada destinatario consuma una unidad de la cuota es
#       inferencia y no literal", en las cinco descripciones de /v3/smtp/email, con su
#       hueco en metadata.not_found. Los dos literales que sostienen la inferencia son del
#       saldo PREPAGO -- "One credit equals one email sent to one contact." -- y no del
#       volumen incluido en el plan.
#
#   (2) SI EL SALDO ES UNICO ENTRE MARKETING Y TRANSACCIONAL (F-10, Q10), sin un solo
#       envio adicional: se mira QUE entrada de plan[] se mueve al enviar un transaccional.
#
#   Y de paso, a coste cero, por leer GET /v3/account con cuidado:
#     - DISC-14: que devuelve de verdad ese endpoint, frente a lo que el blog afirma
#       ("returns your current plan limits and API usage").
#     - DISC-09: startDate y endDate del periodo del plan, en Unix, que es el dia del
#       ciclo de facturacion que la web no publica.
#
# COSTE: 2 DESTINATARIOS, en una sola peticion.
#   La unidad del libro es el DESTINATARIO desde el 2026-09-17, no la peticion: una
#   peticion con dos destinatarios gasta 2. Este sondeo manda UNA peticion, asi que son 2.
#
#   EL BRAZO DE SANDBOX SE RETIRA DE ESTA PASADA (2026-09-17). Media el otro lado de
#   DISC-14 -- si la cabecera X-Sib-Sandbox: drop descuenta saldo -- y no cabe sin romper
#   una regla. El razonamiento, entero, porque la pregunta vuelve sin responder:
#
#     - El tramo tiene que RESERVAR sus 2 destinatarios antes de llamar. D-046 dice que "el
#       modo de la cuenta no es una garantia", y [F16] lo remata: "You receive a success
#       response", asi que un 201 de sandbox es INDISTINGUIBLE de uno real, y "No email logs
#       are created in your Brevo account" impide comprobarlo despues con
#       GET /v3/smtp/statistics/events. Si la cabecera no se honrase, saldria correo.
#     - La version anterior LIBERABA esa reserva cuando el saldo salia igual en una lectura
#       tomada $PAUSA despues del POST: 4 segundos. Ese mismo fichero impone un suelo de 30 s
#       (90 por omision) a la lectura que sirve para medir, y lo justifica por escrito: "el
#       contador de credits va con retardo, asi que una lectura demasiado pronta devuelve el
#       saldo de antes y la resta sale cero". Aplicado a la liberacion, ese retardo no da una
#       respuesta falsa inocua: DEVUELVE al margen 2 destinatarios que Brevo quizas ya cobro,
#       y encima deja hueco para la peticion real. Hasta 4 o 5 destinatarios alcanzados con
#       el libro afirmando 3.
#     - Y aunque la lectura esperase lo mismo que la de medida, seguiria sin demostrar nada
#       en el escenario para el que se escribio: la tabla de lectura de este sondeo admite
#       "0 0 0 -> credits no es el contador del consumo de esta cuenta". En ese mundo el
#       saldo SIEMPRE sale igual, la liberacion es automatica y la guarda esta vacia.
#     - Con la reserva sin liberar, sandbox (2) mas envio real (2) son 4 sobre un tope de 3.
#
#   Asi que de los dos brazos solo cabe uno, y se queda el que responde la pregunta
#   principal: el ENVIO REAL, que es el que mide la unidad de la cuota. El coste del sandbox
#   se queda SIN MEDIR y vuelve como pregunta en la salida. Es "medir menos que medir mal".
#   Queda el par de bisercion de REPOSO contra ENVIO REAL, que es el que aisla "el contador
#   se mueve solo" de "el envio lo mueve".
#
#   Las fases plan / antes / reposo / despues / veredicto no llaman a ningun endpoint de
#   envio y no pueden gastar.
#
#   UN ENVIO = UN DESTINATARIO DE UNA PETICION ACEPTADA, y solo un rechazo DEMOSTRADO
#   libera la reserva: codigo 4xx explicito. Un 000 de curl (timeout, conexion cortada, TLS
#   caido), un cuerpo vacio o un 5xx NO demuestran nada -- la peticion pudo ser aceptada y
#   encolada y la respuesta perderse por el camino -- asi que la reserva se queda puesta, el
#   movimiento se anota DUDOSO y la fase no se repite. Un 000 consume presupuesto igual que
#   un envio.
#
#   El tope de ESTA pasada -- paquetes A y B juntos -- son 3 envios, y lo lleva un solo
#   libro de cuentas en lib_presupuesto_brevo.sh. La cifra es de la pasada, no de D-046: el
#   mandato exige presupuesto declarado y no fija ningun numero. El tope no es una variable
#   de entorno: esta escrito en el fichero, porque un tope que se puede cambiar desde fuera
#   no es un tope.
#
# EL PAR DE BISECCION, QUE ES LO QUE HACE QUE LA CIFRA VALGA ALGO
#   Un caso suelto no demuestra nada. Con un envio no se puede pagar el par obvio
#   (1 destinatario contra 2 destinatarios), asi que el par se construye con dos tramos
#   que NO gastan envio y que aislan las dos maneras de equivocarse:
#     - REPOSO:  dos lecturas de GET /v3/account separadas por la misma pausa y SIN enviar
#                nada en medio. Mide si el contador se mueve solo. Si se mueve, el
#                instrumento no vale y no se concluye nada.
#   El par queda: consumo(reposo, cero envios) contra consumo(real, 2 destinatarios). Ojo
#   al signo: 'credits' es saldo RESTANTE y baja al enviar, asi que el consumo es el delta
#   con el signo cambiado.
#   El brazo que FALTA es el de sandbox, que separaria "la peticion cobra" de "la entrega
#   cobra". Esta retirado de esta pasada por presupuesto -- el motivo, entero, arriba -- y
#   eso deja sin medir una cosa concreta: si el descuento lo provoca aceptar la peticion o
#   entregarla. Lo que SI queda medido es la unidad, que es la pregunta del sondeo.
#
# EL INSTRUMENTO TIENE QUE ESTAR VIVO ANTES DE PAGAR EL ENVIO
#   Las cuatro lecturas de GET /v3/account son el instrumento entero de este sondeo, y ese
#   endpoint vive en la fila "All other endpoints" (100 RPH), la misma que
#   probe_brevo_a_cuerpo_429.sh agota A PROPOSITO durante hasta una hora. Si se corre este
#   sondeo dentro de esa ventana, las lecturas vuelven 429, 'credits' es ilegible y el
#   correo saldria igual: un envio irreversible a cambio de nada. Por eso la fase 'enviar'
#   ABORTA si la linea base no esta: sin lectura no hay delta que calcular.
#   Orden de la pasada: probe_brevo_a_cuerpo_429.sh va el ULTIMO de todo, DESPUES del
#   paquete B.
#
# COMO SE LEE EL RESULTADO
#   consumo en reposo / en el envio real (1 peticion, 2 destinatarios)
#      0                    2                 unidad = DESTINATARIO
#      0                    1                 unidad = PETICION
#      0                    0                 'credits' no es el contador del consumo de
#                                             esta cuenta: refuerza DISC-14 y la unidad
#                                             sigue sin medir
#    != 0                   *                 el contador se mueve solo: no se concluye nada
#      0                   > 2                algo mas consume; se guarda crudo y se
#                                             devuelve como pregunta
#
# LO QUE ESTE SONDEO NO MIDE, Y HAY QUE DECIRLO
#   - Que el MARKETING descuente del mismo saldo. Aqui solo se ve que el transaccional
#     descuenta de la unica entrada de correo de la cuenta. Que la campana salga de esa
#     misma entrada esta publicado (F26) y NO se mide: mandar una campana exige listas de
#     contactos y se sale de la lista blanca.
#   - El contador puede ir con RETARDO. Le paso en MailerSend (O-11, DISC-17 de esa API).
#     Por eso la fase 'despues' es repetible: cada ejecucion anade una lectura y el
#     veredicto usa la ultima, con toda la serie guardada.
#
# POR QUE NO LLEVA idempotencyKey
#   El TTL de 30 minutos de idempotencyKey (F15) esta documentado en la via de LOTE, no en
#   el envio simple. Meter un campo que la referencia del caso simple no documenta podria
#   cambiar el resultado que se esta midiendo. El cuerpo lleva el identificador de la
#   ejecucion en el asunto, que es lo que distingue una pasada de otra.
#
# POR QUE NO PIDE CONFIRMACION POR TECLADO
#   D-046 pone en verde el envio a la lista blanca: "lo ejecuta el agente sin preguntar".
#   Un 'read' colgaria la sesion que lo ejecuta. La confirmacion es la fase explicita
#   'enviar' mas el libro de cuentas; sin argumento el script no llama a nada.
#
# USO (en la maquina del autor; la clave NUNCA por el chat)
#   bash probe_brevo_b_unidad_cuota.sh plan       # imprime que enviaria. CERO llamadas
#   bash probe_brevo_b_unidad_cuota.sh antes      # GET /v3/account            0 envios
#   bash probe_brevo_b_unidad_cuota.sh reposo     # vuelve a leer sin enviar   0 envios
#   bash probe_brevo_b_unidad_cuota.sh enviar     # POST real       2 DESTINATARIOS
#   bash probe_brevo_b_unidad_cuota.sh despues    # vuelve a leer (repetible)  0 envios
#   bash probe_brevo_b_unidad_cuota.sh veredicto  # calcula y escribe el JSON  0 llamadas
#   bash probe_brevo_b_unidad_cuota.sh todo       # las cinco en orden         2 destinatarios
#   (la fase 'sandbox' existia y se ha RETIRADO: pedirla explica por que y no llama a nada)
#   bash probe_brevo_b_unidad_cuota.sh reiniciar  # borra el estado de trabajo (NO el libro)
#
# LISTA BLANCA (D-046, docs/08-mandato.md). Las tres direcciones estan escritas literales
#   mas abajo, copiadas del mandato y sin generar variantes. Este sondeo usa las DOS
#   primeras. Cada una pasa por la guarda lib_lista_blanca.py ANTES de la primera llamada,
#   una por una, y lo que viaja al proveedor es lo que la guarda devuelve, no lo que se le
#   paso. Los destinatarios NO se leen del entorno: BREVO_TO existe en ~/.config/tfm/.env
#   y este script no lo usa a proposito, porque un destinatario que se puede cambiar con
#   una variable de entorno no esta comprobado, esta sugerido.
#
# CREDENCIALES: ~/.config/tfm/.env, fuera del repo, y desde el 2026-09-17 se LEE en vez de
#   sourcearse (lib_env_brevo.sh): de ese fichero se toman cuatro nombres y el resto es
#   texto que se descarta, asi que ya no puede definir PATH, PYTHONPATH, la ruta de la
#   guarda ni el tope. Tampoco se exporta: la clave no viaja en el entorno de los hijos.
#   No viaja en la linea de ordenes: curl la lee de su fichero de configuracion por la
#   entrada estandar (lib_curl_brevo.sh), asi que no hay ningun argv donde leerla con un
#   'ps'. Y no se escribe en ningun fichero: el JSON pasa por un redactor en memoria.
#   La guarda de la lista blanca corre DESPUES de leer el .env, que es lo ultimo que le
#   pasa al destinatario antes de viajar.
#
# PII: el cuerpo de GET /v3/account trae la identidad del titular (email, nombre, empresa,
#   direccion). El JSON de evidencia guarda SOLO plan[] y la LISTA DE NOMBRES de campo,
#   que es lo que DISC-14 necesita; los valores de identidad no se escriben. Encima de eso
#   corre el redactor general de direcciones.
#
# SALIDA: probe_brevo_b_unidad_cuota_<fecha>.json en 03_datos/apis/brevo/evidencias/ si esa
#   carpeta existe, y si no junto a este script. Guarda, tramo a tramo: codigo HTTP,
#   cabeceras de interes y el CUERPO ENTERO de la respuesta -- de ahi sale la cita literal.
# =============================================================================

set -u

# --- El .env se LEE, no se sourcea; las librerias van primero ---------------------------
# Hasta el 2026-09-17 este bloque era 'set -a; . ~/.config/tfm/.env; set +a', y esa pareja
# define CUALQUIER nombre del shell: la ruta de la guarda de destinatarios, el host de la
# API, el tope de la pasada, el libro de cuentas, el testigo de PARADA, PATH y PYTHONPATH.
# La defensa declarada era el ORDEN de las asignaciones mas 'readonly', y ninguna de las dos
# sujeta un source, porque el fichero puede desarmarlas antes de que se ejecuten:
#   readonly () { return 0; }   -> 'readonly X=1' pasa a ser una LLAMADA, no una asignacion
#   readonly TOPE_PASADA=99     -> la asignacion de la libreria FALLA y, sin 'set -e', sigue
#   [ () { ... }                -> las comparaciones del tope y de la PARADA quedan a merced
#   PATH=<dir>:...              -> de ahi salen el python3 de la guarda y el curl del envio
#   PYTHONPATH=<dir>            -> 'import json' suplantable dentro de cada heredoc
# Medido el 2026-09-17 con un .env simulado, las cinco. La correccion esta en
# lib_env_brevo.sh: el fichero se lee linea a linea, se toman cuatro nombres y el resto es
# texto que se descarta. Lo de aqui ya no es una defensa, es el orden natural: primero el
# codigo del repositorio, y solo despues el fichero de credenciales, como dato.
# CDPATH en el entorno hace que 'cd' imprima el destino por stdout, y entonces AQUI sale
# con DOS lineas y todas las rutas del sondeo quedan corruptas. Se desarma antes de nada.
unset CDPATH
readonly AQUI="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
readonly GUARDA="$AQUI/lib_lista_blanca.py"
readonly RAIZ="$(cd "$AQUI/../.." && pwd)"
readonly EVIDENCIAS="$RAIZ/03_datos/apis/brevo/evidencias"

# --- Presupuesto. Escrito en el fichero, no en el entorno. -----------------------------
# El tope de la pasada y el libro viven en lib_presupuesto_brevo.sh, uno solo para los dos
# paquetes: dos contabilidades no vigilan un tope, vigilan dos mitades. Esa libreria
# COMPRUEBA el valor de sus tres constantes al final del fichero y aborta si no es el suyo;
# 'readonly' no era una defensa. Y brevo_limpia_funciones desarma las funciones con nombre
# de orden externa que llegasen exportadas desde el shell que lanza el sondeo.
# Sourcear una libreria SIN comprobar que cargo deja el sondeo con 'libro_cabe' devolviendo
# 127 y a nadie mirandolo, porque ningun sondeo usa 'set -e'. Hasta hoy cerraba en falso por
# casualidad; ahora aborta.
. "$AQUI/lib_env_brevo.sh" || { echo "ABORTA: no se pudo cargar lib_env_brevo.sh." >&2; exit 3; }
# La limpieza va AQUI, antes de que se ejecute cualquier otra libreria: si el shell que
# lanza el sondeo trae una funcion exportada llamada 'readonly', '[' o 'python3', las
# librerias de abajo se ejecutarian ya a su merced. Y no se limita a intentarlo: comprueba
# despues que las ordenes que deciden algo son ejecutables de verdad.
brevo_limpia_funciones
. "$AQUI/lib_presupuesto_brevo.sh" || { echo "ABORTA: no se pudo cargar el libro." >&2; exit 3; }
. "$AQUI/lib_curl_brevo.sh" || { echo "ABORTA: no se pudo cargar lib_curl_brevo.sh." >&2; exit 3; }
brevo_exige_funciones libro_init libro_cabe libro_anota libro_comprometido libro_margen \
    libro_tope_efectivo libro_veredicto_http libro_exige_escritura reservar parada_puesta \
    parada_poner parada_comprobar paquete_a_cerrar brevo_limpia_funciones curl_brevo \
    brevo_clave_valida brevo_carga_env || exit 3
# Y AQUI se lee el .env, como DATO y no como codigo: lib_env_brevo.sh se queda con cuatro
# nombres y descarta el resto del fichero. Un 'set -a' mas un source podia definir PATH,
# PYTHONPATH, GUARDA, BASE, TOPE_PASADA, LIBRO, PARADA -- y hasta 'readonly' o '[' como
# funciones, con lo que las dos defensas anteriores caian juntas.
brevo_carga_env || exit 3
# El coste va en DESTINATARIOS, que es la unidad del libro desde el 2026-09-17. Este sondeo
# manda UNA peticion con DOS destinatarios, asi que son 2. Eran 4 mientras existia el brazo
# de sandbox, y 4 no caben en el tope de 3 de esta pasada sin liberar una reserva sin prueba:
# por eso ese brazo se retiro. La cifra se declara aqui, una sola vez, y el JSON de evidencia
# la lee de esta constante en vez de llevarla escrita a mano.
readonly COSTE_MAXIMO_ESTE_SONDEO=2            # una peticion, dos destinatarios
readonly ESTADO="$HOME/.cache/tfm/probe_brevo_b_unidad_cuota"

readonly BASE="https://api.brevo.com/v3"
PAUSA="${PAUSA:-4}"                            # pausa entre llamadas (D-046: no se provoca)
ESPERA="${ESPERA:-90}"                         # espera antes de la primera lectura 'despues'
# Suelo de la pausa. El entorno puede ALARGARLA, nunca quitarla: la regla 8 del encargo
# dice que se sondea un limite de velocidad, no se provoca, y una pausa que se puede poner
# a cero desde fuera no es una pausa. Mismo argumento que el del tope.
case "$PAUSA" in ''|*[!0-9]*) PAUSA=2 ;; *) [ "$PAUSA" -ge 2 ] || PAUSA=2 ;; esac
# Suelo tambien para la espera, por el mismo motivo que la pausa pero del lado de la
# medida: el contador de 'credits' va con retardo, asi que una lectura demasiado pronta
# devuelve el saldo de antes y la resta sale cero -- que es exactamente la respuesta falsa
# "la cuota no se descuenta". Con ESPERA=0 desde el entorno el sondeo mide otra cosa.
case "$ESPERA" in ''|*[!0-9]*) ESPERA=90 ;; *) [ "$ESPERA" -ge 30 ] || ESPERA=30 ;; esac

FASE="${1:-}"

uso () {
  sed -n '/^# USO (en la maquina/,/^#   bash probe_brevo_b_unidad_cuota.sh reiniciar/p' "$0" \
    | sed 's/^# \{0,3\}//'
}

case "$FASE" in
  plan|antes|reposo|enviar|despues|veredicto|todo|reiniciar) ;;
  sandbox)
    echo "La fase 'sandbox' se RETIRO el 2026-09-17 y este script no la ejecuta."
    echo
    echo "Media si X-Sib-Sandbox: drop descuenta saldo (el otro lado de DISC-14). Para"
    echo "medirlo hay que reservar sus 2 destinatarios antes de llamar -- el modo de la"
    echo "cuenta no es garantia, y F16 dice que un 201 de sandbox es indistinguible de uno"
    echo "real y no deja registro consultable -- y esa reserva solo se podia liberar con una"
    echo "lectura de saldo tomada 4 s despues del POST, cuando el propio sondeo exige 30 s"
    echo "como minimo para la lectura que mide, porque el contador va con retardo. Liberar"
    echo "ahi devuelve al margen 2 destinatarios que Brevo quizas ya cobro."
    echo
    echo "Sin liberar, sandbox (2) mas envio real (2) son 4 sobre un tope de 3. De los dos"
    echo "brazos cabe uno, y se queda el que responde la pregunta del sondeo: 'enviar'."
    echo "El coste del sandbox se queda SIN MEDIR y vuelve como pregunta en la salida."
    exit 2 ;;
  *) echo "Falta la fase."; echo; uso; exit 2 ;;
esac

# --- Credenciales: el .env ya se cargo arriba, antes de todo lo demas -------------------
: "${BREVO_API_KEY:?Falta BREVO_API_KEY en ~/.config/tfm/.env}"
: "${BREVO_FROM:?Falta BREVO_FROM en ~/.config/tfm/.env}"
brevo_clave_valida "$BREVO_API_KEY" || {
  echo "ABORTA: BREVO_API_KEY tiene caracteres fuera de [A-Za-z0-9_.:-]. No se llama a nada."
  exit 3; }

# --- Guarda de la lista blanca: lo ultimo antes de construir cualquier cuerpo -----------
[ -r "$GUARDA" ] || { echo "ABORTA: no se encuentra la guarda $GUARDA. No se envia nada."; exit 3; }

# --- Lista blanca, literal. Copiada de docs/08-mandato.md. Sin variantes. --------------
# Literales en el fichero: no salen de ninguna variable de entorno ni del .env.
# (la tercera, persona-2@example.invalid, la usa el sondeo del tamano; aqui no hace falta)
readonly DEST1="persona-3@example.invalid"
readonly DEST2="persona-1@example.invalid"

# La PARADA es del paquete entero. Si un sondeo vio una peticion de envio aceptada -- o sin
# resolver -- donde no debia, la pasada se mira, no se continua. Las fases que no llaman a
# nada siguen disponibles: son justamente con las que se mira.
case "$FASE" in
  plan|veredicto|reiniciar) ;;
  *) parada_comprobar ;;
esac

# Una llamada por CADA destinatario, como exige la condicion 1 de D-046. La guarda escribe
# el motivo del rechazo en stderr; su stdout no se ensena, que la lista no tiene por que
# acabar en el log de cada sondeo.
for D in "$DEST1" "$DEST2"; do
  python3 -I "$GUARDA" check "$D" >/dev/null || {
    echo "ABORTA: la guarda rechazo un destinatario. No se envia nada."; exit 3; }
done
# Y una sobre la envolvente completa: lo que se manda es lo que la guarda devuelve.
SOBRE="$(python3 -I "$GUARDA" check "$DEST1,$DEST2")" || {
  echo "ABORTA: la guarda rechazo la envolvente. No se envia nada."; exit 3; }

mkdir -p "$ESTADO" && chmod 700 "$ESTADO"
libro_init
# El libro tiene que poder ESCRIBIR, y se comprueba antes de la primera llamada. Con el
# libro presente pero no escribible el append fallaba en silencio, reservar() devolvia 0 e
# imprimia "reservados 2", y el contador volvia a leer 0: el tope dejaba de morder.
libro_exige_escritura
EJEC="${EJEC:-$(date -u +%Y%m%d%H%M%S)}"

presupuesto () {
  libro_init
  local C T; C="$(libro_comprometido)"; T="$(libro_tope_efectivo)"
  echo "== PRESUPUESTO (D-046 condicion 2), impreso ANTES de la primera llamada"
  echo "   tope de la pasada entera (paquetes A y B) . $T envios"
  echo "   ya comprometidos en la ventana ............ $C   (la pasada son 24 horas)"
  echo "   este sondeo gasta como mucho .............. $COSTE_MAXIMO_ESTE_SONDEO destinatarios"
  echo "     la unidad del libro es el DESTINATARIO, no la peticion (corregido 2026-09-17)"
  echo "     enviar:  2 (una peticion, dos destinatarios de la lista blanca)"
  echo "     el brazo de sandbox esta RETIRADO de esta pasada: media el otro lado de"
  echo "              DISC-14 y no cabia sin liberar una reserva sin prueba. Sin medir."
  echo "   fases sin coste ........................... plan, antes, reposo, despues, veredicto"
  echo "   libro ..................................... $LIBRO"
  echo "   estado de trabajo ......................... $ESTADO"
  echo "   un envio = UN DESTINATARIO de una peticion ACEPTADA; solo un 4xx explicito"
  echo "   libera la reserva."
  echo "   Un 000 de curl NO demuestra rechazo: consume presupuesto y la fase no se repite."
  echo
}

# --- Llamadas --------------------------------------------------------------------------
cabeceras_interesantes () {  # $1 fichero de cabeceras
  grep -iE '^(x-sib-|date|content-type|retry-after|x-request-id)' "$1" 2>/dev/null || true
}

leer_cuenta () {  # $1 etiqueta del tramo. 0 envios.
  local E="$1"
  date -u +%Y-%m-%dT%H:%M:%SZ > "$ESTADO/$E.utc"
  curl_brevo "$BREVO_API_KEY" -sS --max-time 60 -o "$ESTADO/$E.body" -D "$ESTADO/$E.hdr" \
    -w '%{http_code}' -H 'accept: application/json' \
    "$BASE/account" > "$ESTADO/$E.code" 2> "$ESTADO/$E.curlerr" || true
  echo "   [$E] GET /v3/account -> HTTP $(cat "$ESTADO/$E.code" 2>/dev/null || echo '?')"
  cabeceras_interesantes "$ESTADO/$E.hdr" | sed 's/^/        /'
  python3 -I - "$ESTADO/$E.body" <<'PY' || true
import json,sys
try: d=json.load(open(sys.argv[1]))
except Exception as e: print("        (cuerpo no JSON: %s)"%e); raise SystemExit
for p in (d.get("plan") or []):
    print("        plan: credits=%s creditsType=%s type=%s startDate=%s endDate=%s"
          % (p.get("credits"), p.get("creditsType"), p.get("type"),
             p.get("startDate"), p.get("endDate")))
PY
}

construir_cuerpo () {  # $1 modo (hoy solo 'real') -> $ESTADO/req_$1.json y req_$1_esqueleto.json
  local MODO="$1"
  SOBRE="$SOBRE" DE="$BREVO_FROM" MODO="$MODO" EJEC="$EJEC" python3 -I - "$ESTADO" <<'PY'
import json, os, sys
est  = sys.argv[1]
modo = os.environ["MODO"]
dest = [{"email": d} for d in os.environ["SOBRE"].split(",") if d]
# Un 'assert' desaparece con PYTHONOPTIMIZE en el entorno, y esta comprobacion decide
# cuantos destinatarios viajan. Se escribe como una excepcion de verdad.
if len(dest) != 2:
    raise SystemExit("este sondeo necesita exactamente dos destinatarios, no %d" % len(dest))
cuerpo = {
    "sender": {"email": os.environ["DE"], "name": "TFM sondeo"},
    "to": dest,
    "subject": "TFM Brevo B1 unidad de la cuota [%s/%s]" % (modo, os.environ["EJEC"]),
    "textContent": ("Sondeo del TFM de Pricing Intelligence (escalon 3, paquete B, "
                    "sondeo 1). Mide si la cuota se descuenta por peticion o por "
                    "destinatario. No requiere respuesta."),
}
with open("%s/req_%s.json" % (est, modo), "w") as f:
    json.dump(cuerpo, f, ensure_ascii=True)
# Esqueleto sin direcciones, para la evidencia.
esq = json.loads(json.dumps(cuerpo))
esq["sender"]["email"] = "<FROM>"
for i, _ in enumerate(esq["to"]):
    esq["to"][i]["email"] = "<DEST%d>" % (i + 1)
with open("%s/req_%s_esqueleto.json" % (est, modo), "w") as f:
    json.dump(esq, f, ensure_ascii=True, indent=1)
PY
}

# El paquete A -- que no puede entregar a nadie -- reserializa el cuerpo y lo relee con una
# comprobacion recursiva antes de CADA llamada. El paquete B, que si entrega, comprobaba una
# variable de shell al arrancar y luego posteaba un fichero de la cache sin volver a mirarlo.
# Aqui se cierra esa asimetria: lo que se comprueba es lo que va a salir por el cable.
verificar_cuerpo () {  # $1 fichero de peticion. Aborta si algo no cuadra.
  local REQ="$1"
  [ -s "$REQ" ] || { echo "ABORTA: $REQ no existe o esta vacio. No se llama a nada."; exit 3; }
  local DEST
  DEST="$(python3 -I - "$REQ" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
dest = []
# Comprobacion en CERRADO. Cualquier clave que el cuerpo lleve y no este en estas listas es
# un campo que este sondeo no escribe, asi que nadie ha comprobado si arrastra direcciones.
# El caso concreto: POST /v3/smtp/email acepta replyTo -- y messageVersions[].replyTo -- y el
# recorrido de abajo no lo miraba. Hoy no fuga nada porque ningun constructor lo escribe,
# pero el comprobador es justo la pieza que tiene que ser exhaustiva: un campo nuevo pasaria
# las dos capas. Asi que se recorre replyTo y, ademas, se falla en cerrado.
CLAVES = {"sender", "to", "cc", "bcc", "replyTo", "subject", "textContent",
          "htmlContent", "attachment", "messageVersions"}
CLAVES_VERSION = {"to", "cc", "bcc", "replyTo", "subject", "textContent", "htmlContent",
                  "params"}
def _claves(o, permitidas, donde):
    sobra = sorted(k for k in o if k not in permitidas)
    if sobra:
        sys.exit("ABORTA: %s lleva campos que este sondeo no escribe y que nadie ha "
                 "comprobado: %s" % (donde, ", ".join(sobra)))
def rec(o, donde="el cuerpo", permitidas=CLAVES):
    _claves(o, permitidas, donde)
    for k in ("to", "cc", "bcc"):
        for e in (o.get(k) or []):
            dest.append((e or {}).get("email", ""))
    r = o.get("replyTo")
    if isinstance(r, dict) and r.get("email"):
        dest.append(r.get("email"))
    for v in (o.get("messageVersions") or []):
        rec(v, "una messageVersion", CLAVES_VERSION)
rec(d)
if not dest:
    sys.exit("la peticion no lleva destinatarios")
print(",".join(dest))
PY
)" || { echo "ABORTA: no se pudieron extraer los destinatarios de $REQ."; exit 3; }
  python3 -I "$GUARDA" check "$DEST" >/dev/null || {
    echo "ABORTA: el fichero que se iba a enviar lleva un destinatario fuera de la lista"
    echo "        blanca. No se llama a nada."; exit 3; }
  echo "   destinatarios del fichero comprobados por la guarda, uno a uno"
}

# Cuantos destinatarios lleva el fichero que se va a mandar. El libro cuenta en
# DESTINATARIOS desde el 2026-09-17, asi que la reserva se calcula sobre el cuerpo REAL y no
# sobre una constante escrita a mano: una constante que se desincroniza del cuerpo es la
# misma clase de error que contar una peticion de 2.000 destinatarios como un envio.
# Devuelve rc 1 sin imprimir nada si el cuerpo no se puede contar. No aborta el script desde
# aqui: esta funcion se llama dentro de "$( )", y un 'exit' ahi mata solo el subshell y
# devuelve la salida a medias -- justo la clase de fallo silencioso que se esta corrigiendo.
# Aborta quien llama.
dest_del_fichero () {  # $1 fichero de peticion -> numero de destinatarios
  local N
  N="$(python3 -I - "$1" <<'PY2'
import json, sys
d = json.load(open(sys.argv[1]))
n = 0
# Un replyTo tambien cuenta: no entrega correo, pero si aparece el cuerpo lleva un campo
# que este sondeo no escribe, y la cuenta tiene que salir distinta de la reserva para que el
# envio se pare. Fallar en cerrado.
def rec(o):
    global n
    for k in ("to", "cc", "bcc"):
        n += len(o.get(k) or [])
    if isinstance(o.get("replyTo"), dict):
        n += 1
    for v in (o.get("messageVersions") or []):
        rec(v)
rec(d)
if n <= 0:
    raise SystemExit(1)
print(n)
PY2
)" || return 1
  case "$N" in ''|*[!0-9]*) return 1 ;; esac
  printf '%s' "$N"
}

# Suma de 'credits' de las entradas de CORREO (creditsType sendLimit y type != sms). Es la
# cifra del par de bisercion: el saldo de correo antes y despues del envio real. Se calcula
# aqui y no se deduce del veredicto.
# Imprime la suma, o nada si el cuerpo no es legible.
saldo_correo () {  # $1 fichero de cuerpo de GET /v3/account
  python3 -I - "$1" <<'PY' 2>/dev/null || true
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    raise SystemExit
vs = [p.get("credits") for p in (d.get("plan") or [])
      if (p.get("creditsType") or "") == "sendLimit" and (p.get("type") or "") != "sms"
      and isinstance(p.get("credits"), (int, float))]
if vs:
    print(int(sum(vs)))
PY
}

http_de () {  # $1 etiqueta de tramo -> codigo tal cual, o vacio
  cat "$ESTADO/$1.code" 2>/dev/null | tr -dc '0-9'
}

es_2xx () { case "$(http_de "$1")" in 2[0-9][0-9]) return 0 ;; *) return 1 ;; esac; }

postear () {  # $1 etiqueta  $2 fichero de cuerpo  $3.. cabeceras extra
  local E="$1" REQ="$2"; shift 2
  verificar_cuerpo "$REQ"
  date -u +%Y-%m-%dT%H:%M:%SZ > "$ESTADO/$E.utc"
  wc -c < "$REQ" | tr -d ' ' > "$ESTADO/$E.reqbytes"
  curl_brevo "$BREVO_API_KEY" -sS --max-time 180 -o "$ESTADO/$E.body" -D "$ESTADO/$E.hdr" \
    -w '%{http_code}' -X POST -H 'accept: application/json' \
    -H 'content-type: application/json' "$@" \
    --data-binary @"$REQ" "$BASE/smtp/email" > "$ESTADO/$E.code" 2> "$ESTADO/$E.curlerr" || true
  local C; C="$(cat "$ESTADO/$E.code" 2>/dev/null || echo 0)"
  echo "   [$E] POST /v3/smtp/email ($(cat "$ESTADO/$E.reqbytes") bytes) -> HTTP $C"
  cabeceras_interesantes "$ESTADO/$E.hdr" | sed 's/^/        /'
  echo "        cuerpo: $(head -c 600 "$ESTADO/$E.body" 2>/dev/null)"
  if [ -s "$ESTADO/$E.curlerr" ]; then
    echo "        AVISO de curl (fallo de transporte): $(head -c 300 "$ESTADO/$E.curlerr")"
  fi
}

# Como se cierra en el libro una peticion de envio. La regla, entera, en un solo sitio:
#   2xx                     -> GASTO   : el correo salio
#   4xx explicito           -> LIBERA  : rechazo DEMOSTRADO, no salio
#   000, cuerpo vacio, 5xx  -> DUDOSO  : no se sabe, y no saberlo se paga
# Devuelve 0 si la peticion quedo RESUELTA (2xx o 4xx) y 1 si quedo dudosa, para que quien
# llama decida si sigue o se para.
cerrar_en_el_libro () {  # $1 tramo  $2 codigo http  $3 detalle extra  $4 destinatarios
  local E="$1" C="$2" X="${3-}" N; N="$(libro_unidades "${4:-1}")"
  case "$(libro_veredicto_http "$C")" in
    aceptada)
      libro_anota GASTO "$E" "http=$C $X" "$N"
      echo "   >>> ACEPTADA: el correo sale. $N destinatario(s) gastados."
      return 0 ;;
    rechazada)
      libro_anota LIBERA "$E" "http=$C rechazo demostrado (4xx) $X" "$N"
      echo "   >>> HTTP $C: rechazo DEMOSTRADO. No sale correo y el libro libera la reserva."
      echo "   >>> La cifra sale del cuerpo del error, que ya esta guardado entero."
      return 0 ;;
    *)
      libro_anota DUDOSO "$E" "http=$C resultado ambiguo: la reserva se queda puesta $X" "$N"
      echo "   >>> HTTP '$C': NO demuestra rechazo. Con --max-time y un cuerpo grande, la"
      echo "   >>> respuesta se puede perder DESPUES de que Brevo aceptara y encolara la"
      echo "   >>> peticion, asi que el lado conservador es asumir que salio: la reserva se"
      echo "   >>> queda puesta, el movimiento se anota DUDOSO y esta fase no se repite."
      return 1 ;;
  esac
}

# --- Fases -----------------------------------------------------------------------------
fase_plan () {
  presupuesto
  echo "== PLAN (cero llamadas). Esto es lo que enviaria la fase 'enviar':"
  construir_cuerpo real || { echo "ABORTA: construir_cuerpo real fallo."; exit 3; }
  verificar_cuerpo "$ESTADO/req_real.json"
  echo "   remitente: BREVO_FROM de ~/.config/tfm/.env (no se imprime)"
  echo "   destinatarios: DOS, los dos aceptados por la guarda (no se imprimen)"
  echo "   cuerpo, sin direcciones:"
  sed 's/^/        /' "$ESTADO/req_real_esqueleto.json"
  echo "   bytes del cuerpo real: $(wc -c < "$ESTADO/req_real.json" | tr -d ' ')"
  echo
  echo "   Es la UNICA peticion que manda este sondeo: el brazo de sandbox esta retirado."
}

fase_antes ()  { presupuesto; echo "== ANTES (0 envios)";  leer_cuenta antes; }
fase_reposo () {
  echo "== REPOSO (0 envios): control de deriva. Misma pausa, sin enviar nada en medio."
  sleep "$PAUSA"; leer_cuenta reposo
}
# La fase 'sandbox' vivia aqui y se RETIRO el 2026-09-17. No se deja comentada: un tramo
# que puede mandar correo no se guarda a medio gas dentro del fichero que lo manda. El
# motivo esta en la cabecera, y el 'case' de las fases lo repite a quien la pida.
#
# El envio es irreversible y el instrumento puede estar caido. Sin linea base no hay delta
# que calcular, asi que un envio sin instrumento es dinero tirado: se aborta ANTES de
# reservar y sin tocar el libro. El caso concreto que lo obliga:
# probe_brevo_a_cuerpo_429.sh agota a proposito la fila "All other endpoints" (100 RPH),
# donde vive GET /v3/account, durante hasta una hora.
exigir_instrumento () {
  local FALLA=0 T
  for T in antes reposo; do
    if [ ! -e "$ESTADO/$T.code" ]; then
      echo "   FALTA el tramo '$T': corre las fases en orden (antes, reposo)." >&2
      FALLA=1
    elif ! es_2xx "$T"; then
      echo "   el tramo '$T' devolvio HTTP $(http_de "$T"), no 2xx." >&2
      FALLA=1
    fi
  done
  if [ -z "$(saldo_correo "$ESTADO/antes.body")" ]; then
    echo "   el tramo 'antes' no trae un 'credits' numerico en plan[]: no hay linea base." >&2
    FALLA=1
  fi
  if [ "$FALLA" != "0" ]; then
    echo "ABORTA: el instrumento de medida no esta disponible, asi que el envio no se" >&2
    echo "        gasta. Si las lecturas de GET /v3/account devolvieron 429, es la fila" >&2
    echo "        'All other endpoints' agotada por probe_brevo_a_cuerpo_429.sh: hay que" >&2
    echo "        esperar a que se reponga la ventana (hasta una hora) y repetir 'antes'" >&2
    echo "        y 'reposo'. El libro no se ha tocado." >&2
    exit 6
  fi
  # Si una pasada anterior alcanzo a ejecutar el brazo de sandbox -- la fase existia antes
  # del 2026-09-17 -- y quedo DUDOSO, el estado de trabajo lo guarda. Pagar el envio real
  # encima de un envio que quizas salio invalida el par, asi que se para igual.
  if [ -e "$ESTADO/sandbox_post.code" ]; then
    case "$(libro_veredicto_http "$(http_de sandbox_post)")" in
      dudosa)
        echo "ABORTA: hay un tramo de sandbox de una pasada anterior que quedo DUDOSO" >&2
        echo "        (HTTP '$(http_de sandbox_post)'): no se sabe si salio correo ni si" >&2
        echo "        cobro, asi que el par esta roto y el envio real no se paga. Mirar el" >&2
        echo "        libro y $ESTADO/sandbox_post.curlerr." >&2
        exit 6 ;;
    esac
  fi
}

fase_enviar () {
  echo "== ENVIAR: ESTO ENTREGA CORREO DE VERDAD (1 peticion, 2 destinatarios)."
  # Idempotencia: solo se repite sobre un rechazo DEMOSTRADO. Un 000 o un 5xx no demuestran
  # que no saliera correo, asi que repetir sobre ellos seria mandar un segundo correo encima
  # de uno que quizas ya salio.
  if [ -e "$ESTADO/real_post.code" ]; then
    local ANT; ANT="$(http_de real_post)"
    case "$(libro_veredicto_http "$ANT")" in
      aceptada)
        echo "   El envio de este sondeo YA se gasto (HTTP $ANT)."
        echo "   No se repite. Lo que falta es 'despues' y 'veredicto'. Si de verdad hay"
        echo "   que rehacerlo, 'reiniciar' primero y cuenta lo del libro."
        return 0 ;;
      rechazada)
        echo "   El intento anterior fue RECHAZADO con HTTP $ANT (4xx explicito): eso si"
        echo "   demuestra que no salio correo, asi que se puede repetir." ;;
      *)
        echo "   El intento anterior quedo DUDOSO (HTTP '$ANT'): no se sabe si salio correo."
        echo "   NO se repite -- repetir mandaria un segundo correo encima de uno que quizas"
        echo "   ya salio. El libro tiene la reserva puesta a proposito. Si hace falta"
        echo "   rehacerlo, primero hay que averiguar que paso con esa peticion."
        return 0 ;;
    esac
  fi
  exigir_instrumento
  construir_cuerpo real || { echo "ABORTA: construir_cuerpo real fallo."; exit 3; }
  local N; N="$(dest_del_fichero "$ESTADO/req_real.json")" || {
    echo "ABORTA: no se pudo contar los destinatarios del cuerpo real. Sin esa cuenta no hay"
    echo "        reserva que hacer, y sin reserva no se manda nada."; exit 3; }
  reservar envio_real "$N"
  sleep "$PAUSA"
  postear real_post "$ESTADO/req_real.json"
  cerrar_en_el_libro envio_real "$(http_de real_post)" "$N destinatarios" "$N" || true
}
fase_despues () {
  local N=1
  while [ -e "$ESTADO/despues_$N.code" ]; do N=$((N + 1)); done
  echo "== DESPUES lectura $N (0 envios). El contador puede ir con retardo: repite esta"
  echo "   fase espaciada hasta que el numero deje de moverse."
  leer_cuenta "despues_$N"
}

fase_veredicto () {
  local SAL="$AQUI"
  [ -d "$EVIDENCIAS" ] && SAL="$EVIDENCIAS"
  local OUT="$SAL/probe_brevo_b_unidad_cuota_$(date -u +%Y-%m-%d_%H%M%S).json"
  CLAVE="$BREVO_API_KEY" FROM="$BREVO_FROM" D1="$DEST1" D2="$DEST2" \
  TOPE="$TOPE_PASADA" LIBROF="$LIBRO" COSTE="$COSTE_MAXIMO_ESTE_SONDEO" \
  python3 -I - "$ESTADO" "$OUT" <<'PY'
import json, os, re, sys, glob, datetime

est, out = sys.argv[1], sys.argv[2]
CAP = 200000

# ---------- redactor ----------
# La clave se redacta por PATRON y por VALOR exacto, y las dos capas hacen falta: el patron
# cubre las dos formas que Brevo emite y ademas lo que se cuele en un cuerpo de respuesta;
# el valor exacto cubre cualquier formato que el patron no reconozca. Este JSON se copia a
# evidencias/ y entra en un commit, que es irreversible, asi que aqui no se ahorra.
CLAVE = os.environ.get("CLAVE") or ""
CLAVE_PATRON = re.compile(r"x(?:keysib|smtpsib)-[A-Za-z0-9._:-]{8,}")
ETIQ  = [(os.environ.get("FROM") or "", "<FROM>"),
         (os.environ.get("D1") or "", "<DEST1>"),
         (os.environ.get("D2") or "", "<DEST2>")]
# Los messageId de Brevo tienen forma de direccion (<id@relay>) y son el unico enlace entre
# el envio y su evento de entrega, asi que hay que conservarlos enteros. Mirar alrededor con
# lookarounds no sirve: la primera version usaba (?<!<) ... (?!>) y el motor entraba igual
# por dentro del token, dejando "<sbx<REDACTADO>.fr>". Asi que se APARCAN con un centinela
# antes de redactar y se devuelven al final -- y solo se aparca el token que no contenga
# ninguna de las direcciones conocidas, que si no seria un agujero por donde colar PII.
MENSAJE_ID = re.compile(r"<[^<>@\s]+@[^<>\s]+>")
SUELTA = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
CONOCIDAS = [c.lower() for c, _ in ETIQ if c]

def redactar(t):
    if not isinstance(t, str):
        return t
    t = CLAVE_PATRON.sub("<CLAVE_REDACTADA>", t)
    if CLAVE:
        t = t.replace(CLAVE, "<CLAVE_REDACTADA>")
    aparcados = []

    def aparcar(m):
        tok = m.group(0)
        if any(d in tok.lower() for d in CONOCIDAS):
            return tok                      # lleva una direccion dentro: que lo redacte
        aparcados.append(tok)
        return "\x01%d\x01" % (len(aparcados) - 1)

    t = MENSAJE_ID.sub(aparcar, t)
    for cruda, etiqueta in ETIQ:
        if cruda:
            t = re.sub(re.escape(cruda), etiqueta, t, flags=re.I)
    t = SUELTA.sub("<REDACTADO>", t)
    for i, tok in enumerate(aparcados):
        t = t.replace("\x01%d\x01" % i, tok)
    return t

def limpiar(o):
    if isinstance(o, str):  return redactar(o)
    if isinstance(o, list): return [limpiar(x) for x in o]
    if isinstance(o, dict): return {redactar(k): limpiar(v) for k, v in o.items()}
    return o

# ---------- lectura de un tramo ----------
def leer(nombre):
    p = lambda ext: os.path.join(est, nombre + ext)
    if not os.path.exists(p(".code")):
        return None
    tramo = {"tramo": nombre, "utc": None, "http": None, "cabeceras": {},
             "cuerpo": None, "cuerpo_texto": None, "truncado": False}
    try: tramo["utc"] = open(p(".utc")).read().strip()
    except Exception: pass
    try: tramo["http"] = int((open(p(".code")).read().strip() or "0"))
    except Exception: tramo["http"] = 0
    try:
        for l in open(p(".hdr"), errors="replace"):
            if ":" in l:
                k, v = l.split(":", 1)
                k = k.strip().lower()
                if k.startswith("x-sib-") or k in ("date", "content-type",
                                                   "retry-after", "x-request-id"):
                    tramo["cabeceras"][k] = v.strip()
    except Exception: pass
    try:
        crudo = open(p(".body"), errors="replace").read()
        if len(crudo) > CAP:
            crudo, tramo["truncado"] = crudo[:CAP], True
        tramo["cuerpo_texto"] = crudo
        try: tramo["cuerpo"] = json.loads(crudo)
        except Exception: pass
    except Exception: pass
    try:
        e = open(p(".curlerr"), errors="replace").read().strip()
        if e: tramo["curl_stderr"] = e
    except Exception: pass
    try: tramo["bytes_peticion"] = int(open(p(".reqbytes")).read().strip())
    except Exception: pass
    return tramo

def unix(v):
    try: return datetime.datetime.fromtimestamp(int(v), datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    except Exception: return None

# De GET /v3/account solo se guarda plan[] y la LISTA DE NOMBRES de campo. El resto del
# cuerpo es identidad del titular (email, nombre, empresa, direccion) y no se escribe.
def cuenta(tramo):
    if tramo is None: return None
    d = tramo.get("cuerpo")
    fuera = {"tramo": tramo["tramo"], "utc": tramo["utc"], "http": tramo["http"],
             "cabeceras": tramo["cabeceras"], "plan": [], "planVerticals": [],
             "campos_presentes": [], "expone_limites_o_consumo": None}
    if not isinstance(d, dict):
        fuera["cuerpo_texto"] = tramo.get("cuerpo_texto")   # error: se guarda entero
        return fuera
    fuera["campos_presentes"] = sorted(d.keys())
    fuera["expone_limites_o_consumo"] = sorted(
        k for k in d.keys() if re.search(r"limit|usage|used|consum|quota", k, re.I))
    for p in (d.get("plan") or []):
        fuera["plan"].append({
            "credits": p.get("credits"), "creditsType": p.get("creditsType"),
            "type": p.get("type"), "startDate": p.get("startDate"),
            "endDate": p.get("endDate"),
            "startDate_utc": unix(p.get("startDate")), "endDate_utc": unix(p.get("endDate")),
        })
    # planVerticals es donde de verdad viven startDate y endDate del periodo: plan[] los
    # trae null. Sin guardarlo, DISC-09 salia "no medible" con el dato delante.
    for v in (d.get("planVerticals") or []):
        fuera["planVerticals"].append({
            "planCategory": v.get("planCategory"), "planType": v.get("planType"),
            "name": v.get("name"), "status": v.get("status"),
            "startDate": v.get("startDate"), "endDate": v.get("endDate"),
            "startDate_utc": unix(v.get("startDate")), "endDate_utc": unix(v.get("endDate")),
        })
    return fuera

def clave_entrada(p):
    return "%s:%s" % (p.get("creditsType"), p.get("type"))

def saldos(c):
    if not c: return {}
    return {clave_entrada(p): p.get("credits") for p in c["plan"]}

def delta(a, b):
    """b - a por entrada. None donde falte un lado."""
    if not a or not b: return None
    sa, sb = saldos(a), saldos(b)
    d = {}
    for k in sorted(set(sa) | set(sb)):
        va, vb = sa.get(k), sb.get(k)
        d[k] = (vb - va) if isinstance(va, (int, float)) and isinstance(vb, (int, float)) else None
    return d

antes   = cuenta(leer("antes"))
reposo  = cuenta(leer("reposo"))
sbx_c   = cuenta(leer("sandbox_cuenta"))
desp    = [cuenta(leer(os.path.basename(f)[:-5]))
           for f in sorted(glob.glob(os.path.join(est, "despues_*.code")))]
sbx_p   = leer("sandbox_post")
real_p  = leer("real_post")

ultimo  = desp[-1] if desp else None
d_reposo  = delta(antes, reposo)
d_sandbox = delta(reposo or antes, sbx_c)
d_real    = delta(sbx_c or reposo or antes, ultimo)

# entradas de correo: sendLimit que no sea el saldo de SMS
def entradas_correo(c):
    if not c: return []
    return [clave_entrada(p) for p in c["plan"]
            if (p.get("creditsType") or "") == "sendLimit"
            and (p.get("type") or "") != "sms"]

correo = entradas_correo(antes or ultimo)

def movido(d):
    if not d: return []
    return [k for k, v in d.items() if isinstance(v, (int, float)) and v != 0]

def consumo_correo(d):
    """Unidades CONSUMIDAS en las entradas de correo. 'credits' es saldo RESTANTE, asi que
    baja al enviar: el consumo es el delta con el signo cambiado. Que esto se llame consumo
    y no delta no es cosmetica -- confundir los dos signos es la manera facil de leer el
    veredicto al reves."""
    if not d: return None
    vs = [d[k] for k in correo if isinstance(d.get(k), (int, float))]
    return -sum(vs) if vs else None

mov_reposo, mov_sandbox, mov_real = movido(d_reposo), movido(d_sandbox), movido(d_real)
c_reposo, c_sandbox, c_real = (consumo_correo(d_reposo), consumo_correo(d_sandbox),
                               consumo_correo(d_real))

http_real = (real_p or {}).get("http")
acept = isinstance(http_real, int) and 200 <= http_real < 300

# El instrumento de este sondeo son las cuatro lecturas de GET /v3/account. Si alguna no
# es 2xx, el delta no se puede calcular y decirlo como "delta inesperado" haria pasar por
# anomalia de datos lo que es un instrumento inutilizado -- el caso tipico es el 429 de la
# fila "All other endpoints" que agota probe_brevo_a_cuerpo_429.sh.
def http_de(c):
    return (c or {}).get("http")

# El instrumento son las lecturas de GET /v3/account que este sondeo NECESITA: 'antes',
# 'reposo' y las de 'despues'. 'sandbox_cuenta' ya no esta -- el brazo se retiro -- y dejarla
# aqui la metia en la lista de "faltan lecturas" y envenenaba el veredicto de cada pasada.
lecturas = {"antes": http_de(antes), "reposo": http_de(reposo)}
if sbx_c is not None:                    # una pasada anterior alcanzo a ejecutarla
    lecturas["sandbox_cuenta"] = http_de(sbx_c)
for i, c in enumerate(desp):
    lecturas["despues_%d" % (i + 1)] = http_de(c)
malas = sorted(k for k, h in lecturas.items()
               if h is not None and not (isinstance(h, int) and 200 <= h < 300))
sin_lectura = sorted(k for k, h in lecturas.items() if h is None)

# El brazo de sandbox solo mide algo si la PETICION fue aceptada. Un saldo quieto detras de
# una peticion rechazada no dice que sandbox no cobre: dice que no hubo sandbox.
http_sbx = (sbx_p or {}).get("http")
sbx_aceptada = isinstance(http_sbx, int) and 200 <= http_sbx < 300
sbx_rechazada = isinstance(http_sbx, int) and 400 <= http_sbx < 500

# ---------- veredicto ----------
v = {"unidad_de_la_cuota": None, "saldo_unico": None, "motivo": None,
     "http_de_las_lecturas_de_cuenta": lecturas,
     "instrumento": ("ok" if not malas and not sin_lectura else
                     "lecturas_no_2xx:" + ",".join(malas) if malas else
                     "faltan_lecturas:" + ",".join(sin_lectura)),
     "brazo_sandbox": ("RETIRADO de esta pasada: no se ejecuto" if http_sbx is None else
                       "midio: la peticion de sandbox fue aceptada" if sbx_aceptada else
                       "NO midio: la peticion de sandbox fue rechazada (HTTP %s), asi que "
                       "el saldo quieto no dice nada de si sandbox cobra" % http_sbx
                       if sbx_rechazada else
                       "NO midio: el resultado de la peticion de sandbox es ambiguo "
                       "(HTTP %s)" % http_sbx),
     "par_de_bisercion": {"consumo_en_reposo_sin_envio": c_reposo,
                          "consumo_sandbox_2_destinatarios":
                              c_sandbox if sbx_aceptada else None,
                          "consumo_real_2_destinatarios": c_real}}
if malas and acept:
    v["unidad_de_la_cuota"] = "no_concluyente"
    v["motivo"] = ("las lecturas de GET /v3/account devolvieron %s: el instrumento no "
                   "estaba disponible y el envio se gasto sin medida. Si el codigo es 429, "
                   "es la fila 'All other endpoints' agotada por probe_brevo_a_cuerpo_429.sh "
                   "-- ese sondeo va el ULTIMO de la pasada, despues del paquete B. Hay que "
                   "esperar a que se reponga la ventana y repetir 'despues'"
                   % ", ".join("%s=%s" % (k, lecturas[k]) for k in malas))
elif malas:
    v["unidad_de_la_cuota"] = "sin_medir"
    v["motivo"] = ("las lecturas de GET /v3/account devolvieron %s y la peticion real no fue "
                   "aceptada: no se gasto envio y no hay nada medido"
                   % ", ".join("%s=%s" % (k, lecturas[k]) for k in malas))
elif not acept and http_sbx is not None and not sbx_aceptada and not sbx_rechazada:
    v["unidad_de_la_cuota"] = "sin_medir"
    v["motivo"] = ("la peticion real no se llego a lanzar y la de sandbox quedo DUDOSA "
                   "(HTTP %s): de esa no se sabe si salio correo, asi que el libro la cuenta "
                   "como gastada y no se afirma que la pasada no haya entregado nada. Mirar "
                   "el .curlerr del tramo sandbox_post antes de repetir" % http_sbx)
elif not acept:
    v["unidad_de_la_cuota"] = "sin_medir"
    v["motivo"] = ("la peticion real no fue aceptada (HTTP %s): no salio correo por esa via, "
                   "no se gasto cuota y la cifra, si la hay, esta en el cuerpo del error, "
                   "guardado entero" % http_real)
elif c_reposo not in (0, None):
    v["unidad_de_la_cuota"] = "no_concluyente"
    v["motivo"] = ("el contador se movio SIN enviar nada (delta de reposo %s): el instrumento "
                   "no es fiable y no se concluye nada" % c_reposo)
elif c_sandbox not in (0, None) and sbx_aceptada:
    v["unidad_de_la_cuota"] = "no_concluyente"
    v["motivo"] = ("sandbox descuenta saldo (delta %s) pese a que F16 dice 'No emails are sent "
                   "to recipients': el tramo real deja de ser limpio y hay hallazgo nuevo que "
                   "anotar" % c_sandbox)
elif c_sandbox not in (0, None):
    v["unidad_de_la_cuota"] = "no_concluyente"
    v["motivo"] = ("el saldo se movio (delta %s) alrededor de una peticion de sandbox que NO "
                   "fue aceptada (HTTP %s): el movimiento no es de sandbox y el instrumento "
                   "deja de ser fiable" % (c_sandbox, http_sbx))
elif c_real == 2:
    v["unidad_de_la_cuota"] = "destinatario"
    v["motivo"] = ("una sola peticion con dos destinatarios descuenta 2: la unidad de la cuota "
                   "es el destinatario. Confirma la inferencia que el YAML declara como tal")
elif c_real == 1:
    v["unidad_de_la_cuota"] = "peticion"
    v["motivo"] = ("una sola peticion con dos destinatarios descuenta 1: la unidad es la "
                   "peticion. REFUTA la inferencia del YAML y hay que corregir las cinco "
                   "descripciones de /v3/smtp/email")
elif c_real == 0:
    v["unidad_de_la_cuota"] = "sin_medir"
    v["motivo"] = ("la peticion fue aceptada y 'credits' no se movio: ese campo no es el "
                   "contador del consumo de esta cuenta. Refuerza DISC-14 y la unidad sigue "
                   "sin medir. Vuelve a correr 'despues' espaciado antes de cerrarlo: el "
                   "descuento puede ir con retardo")
else:
    v["unidad_de_la_cuota"] = "no_concluyente"
    v["motivo"] = ("delta inesperado (%s) para una peticion con dos destinatarios: se guarda "
                   "crudo y se devuelve como pregunta" % c_real)

# El saldo solo se declara medido si la unidad se midio limpia: con el contador derivando
# o con sandbox cobrando, el movimiento del saldo no prueba de donde salio.
limpio = v["unidad_de_la_cuota"] in ("destinatario", "peticion")
if limpio and len(correo) == 1 and mov_real == correo:
    v["saldo_unico"] = "confirmado_parcial"
    v["saldo_unico_motivo"] = (
        "la cuenta expone UNA sola entrada de correo (%s) y es la que se movio al enviar un "
        "transaccional: el transaccional consume el saldo de la cuenta y no uno propio. Lo que "
        "esto NO mide es que la campana salga de esa misma entrada; eso esta publicado en F26 "
        "y no se ha medido" % correo[0])
elif limpio and len(correo) > 1:
    v["saldo_unico"] = "revisar_a_mano"
    v["saldo_unico_motivo"] = ("la cuenta expone %d entradas de correo (%s): hay que mirar cual "
                               "se movio antes de afirmar nada" % (len(correo), ", ".join(correo)))
elif not limpio:
    v["saldo_unico"] = "sin_medir"
    v["saldo_unico_motivo"] = ("la unidad no se midio limpia (%s), asi que el movimiento del "
                               "saldo no prueba de donde salio"
                               % v["unidad_de_la_cuota"])
else:
    v["saldo_unico"] = "sin_medir"
    v["saldo_unico_motivo"] = "no hubo movimiento atribuible en el saldo de correo"

# DISC-14 y DISC-09, de propina y a coste cero
base = antes or ultimo
disc14 = None
if base and base.get("campos_presentes"):
    disc14 = {
        "campos_que_devuelve": base["campos_presentes"],
        "campos_de_limite_o_consumo": base["expone_limites_o_consumo"],
        "lectura": ("el blog afirma que este endpoint 'returns your current plan limits and API "
                    "usage'; la lista de campos de arriba es lo que devuelve de verdad en esta "
                    "cuenta" ),
    }
disc09 = None
disc09_pv = None
if base and base.get("plan"):
    # CORREGIDO 2026-09-17: este bloque leia startDate/endDate de plan[], donde vienen
    # null, y daba DISC-09 por no medible. Estan en planVerticals[], y ahi si: la cuenta
    # Free devolvio 1789552093 y 1792144093, que son 2026-09-16 y 2026-10-16 a las 09:48:13
    # UTC, treinta dias exactos. El dato estaba delante y se declaraba ausente.
    # El periodo no cambia entre lecturas, asi que vale cualquiera que lo traiga: se coge
    # la primera que lo tenga en vez de atarlo a 'base'. Importa porque un registro escrito
    # antes de guardar planVerticals no lo lleva, y reejecutar 'antes' destruiria la linea
    # base del delta.
    disc09_pv = next((c.get("planVerticals") for c in (antes, reposo, ultimo)
                      if c and c.get("planVerticals")), [])
    disc09 = [{"entrada": clave_entrada(p), "startDate": p.get("startDate"),
               "endDate": p.get("endDate"), "startDate_utc": p.get("startDate_utc"),
               "endDate_utc": p.get("endDate_utc")} for p in base["plan"]]

esq = {}
for m in ("real",):
    f = os.path.join(est, "req_%s_esqueleto.json" % m)
    if os.path.exists(f):
        try: esq[m] = json.load(open(f))
        except Exception: pass

libro = []
try:
    libro = [l.rstrip("\n") for l in open(os.environ["LIBROF"]) if not l.startswith("#")]
except Exception: pass

doc = {
  "sondeo": "brevo-b1-unidad-de-la-cuota",
  "api": "brevo", "escalon": 3, "paquete": "B",
  "fecha_utc": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
  "preguntas": {
      "unidad_de_la_cuota": "metadata.not_found: 'Unidad de descuento de la cuota mensual'; "
                            "REVISION.md, escalon 3 con envio real, sondeo 1",
      "saldo_unico_marketing_transaccional": "F-10 y Q10",
      "de_propina": ["DISC-14 (que devuelve GET /v3/account)", "DISC-09"],
      "retirada_de_esta_pasada": (
          "el otro lado de DISC-14 -- si X-Sib-Sandbox: drop descuenta saldo -- NO se mide "
          "aqui. El brazo de sandbox exige reservar 2 destinatarios, y su reserva solo se "
          "podia liberar con una lectura de saldo tomada antes de que el contador se mueva, "
          "que es ausencia de prueba y no prueba. Sin liberar, sandbox (2) mas envio real "
          "(2) son 4 sobre un tope de 3, asi que cabe un brazo y se queda el que mide la "
          "unidad. Vuelve como pregunta en la salida"),
  },
  "presupuesto": {
      "tope_de_la_pasada": int(os.environ["TOPE"]),
      "unidad": "destinatarios de una peticion aceptada",
      "coste_maximo_declarado_de_este_sondeo": int(os.environ["COSTE"]),
      "desglose": ("2 de la peticion real, que lleva dos destinatarios de la lista blanca. "
                   "La cifra sale de la constante COSTE_MAXIMO_ESTE_SONDEO del script, no "
                   "escrita a mano aqui: dos cifras distintas en el mismo presupuesto es lo "
                   "que la condicion 2 de D-046 prohibe. El brazo de sandbox, que sumaba "
                   "otros 2, esta retirado de esta pasada"),
      "envio_es": ("UN DESTINATARIO de una peticion ACEPTADA. Solo un 4xx explicito libera "
                   "la reserva: un 000 de curl, un cuerpo vacio o un 5xx no demuestran "
                   "rechazo -- la peticion pudo ser aceptada y la respuesta perderse -- y se "
                   "anotan DUDOSO"),
      "brazo_sandbox": "retirado de esta pasada (ver preguntas.retirada_de_esta_pasada)",
      "peticion_real_aceptada": bool(acept),
      "destinatarios_alcanzados": int(os.environ["COSTE"]) if acept else 0,
      "libro": libro,
  },
  "veredicto": v,
  "deltas_por_entrada_saldo_restante": {"reposo": d_reposo, "sandbox": d_sandbox,
                                        "real": d_real,
                                        "lectura": "delta del saldo RESTANTE (negativo = se "
                                                   "consumio); el consumo con signo positivo "
                                                   "esta en veredicto.par_de_bisercion"},
  "entradas_de_correo": correo,
  "disc14_que_devuelve_get_account": disc14,
  "disc09_ciclo_de_facturacion": disc09,
  "disc09_periodo_desde_planVerticals": disc09_pv,
  "tramos": {
      "antes": antes, "reposo": reposo, "sandbox_cuenta": sbx_c,
      "sandbox_post": sbx_p, "real_post": real_p, "despues": desp,
  },
  "cuerpos_enviados_sin_direcciones": esq,
  "notas": [
      "Los cuerpos de respuesta se guardan ENTEROS (tope %d bytes) porque de ahi sale la "
      "cita literal; se lee el cuerpo, no el codigo HTTP." % CAP,
      "De GET /v3/account solo se escriben plan[] y los NOMBRES de campo: el resto es "
      "identidad del titular.",
      "Redactado: clave de API (por patron x{keysib,smtpsib}-... y por valor exacto, que "
      "un formato nuevo no lo reconoceria el patron) y direcciones. Los messageId entre "
      "<...> se conservan a proposito, que son el enlace con el evento de entrega.",
      "El brazo de sandbox se retiro el 2026-09-17: con el tope de la pasada en 3 "
      "destinatarios no cabia sin liberar una reserva sin prueba de que no salio correo.",
  ],
}

doc = limpiar(doc)
with open(out, "w") as f:
    json.dump(doc, f, ensure_ascii=True, indent=1)
print(json.dumps({"veredicto": doc["veredicto"], "presupuesto": doc["presupuesto"],
                  "entradas_de_correo": doc["entradas_de_correo"]},
                 ensure_ascii=True, indent=1))
print("JSON: %s" % out)
PY
}

case "$FASE" in
  plan)      fase_plan ;;
  antes)     fase_antes ;;
  reposo)    presupuesto; fase_reposo ;;
  enviar)    presupuesto; fase_enviar ;;
  despues)   presupuesto; fase_despues ;;
  veredicto) fase_veredicto ;;
  reiniciar) rm -rf "$ESTADO"; echo "Estado de trabajo borrado. El libro de cuentas NO se"
             echo "toca: $LIBRO (un tope que se borra no es un tope)." ;;
  todo)
    presupuesto
    echo "== TODO: antes, reposo, enviar, despues, veredicto"
    echo
    fase_antes; echo; fase_reposo; echo; fase_enviar; echo
    echo "   esperando ${ESPERA}s antes de la primera lectura 'despues' (el descuento"
    echo "   puede ir con retardo)"
    sleep "$ESPERA"
    fase_despues; echo; fase_veredicto
    echo
    echo ">>> Si el delta salio 0, vuelve a correr 'despues' espaciado y luego 'veredicto'."
    ;;
esac
