#!/usr/bin/env bash
# =============================================================================
# Sondeo empirico Brevo - escalon 3 - PAQUETE B, sondeo 2 - preparado 2026-09-17
#
# QUE PREGUNTA RESUELVE
#
#   DISC-16 y, con ella, el hueco 15 de fuentes.md. Brevo publica dos tamanos maximos que
#   no pueden ser ciertos a la vez: "The size limit for transactional emails is 20MB,
#   including the attachments and email content." [F27, centro de ayuda, seccion de API] y
#   "Max attachment size | 25 MB per email" [F5, pagina de producto]. Un tope de adjunto
#   mayor que el tope total del correo no se sostiene. La documentacion de desarrollador
#   -- [F10], [F13] y las dos specs -- no publica NINGUNA cifra de tamano (hueco 15). La
#   datasheet lleva hoy 'unit: MBs, max: 20' en ambar por la regla de Q6.
#
#   Y la pregunta que REVISION.md pone en este paquete no es cual de las dos cifras es:
#   es DONDE MUERDE el tope, en VALIDACION o en ENTREGA. Importa porque sandbox
#   "only validates the API request format" [F16], asi que un tope que solo se aplique al
#   entregar no lo ve ningun sondeo de coste cero. Si muerde en entrega, el 'max: 20' de
#   la datasheet describe algo que la API acepta y luego no hace, que es material del
#   capitulo 6 y no solo un numero corregido.
#
#   COMPLEMENTA A probe_brevo_a_tamano.sh (paquete A), que explora el mismo tope SOLO por
#   el lado rechazado y con una guarda que impide que nada se acepte: ese sondeo puede
#   decir "el tope es como maximo N" y no puede decir nada de la entrega. Este usa LOS
#   MISMOS PUNTOS de 19, 21, 24 y 26,5 MB para que las dos lecturas se compongan sin
#   convertir unidades, y anade los tres de abajo, que el paquete A no puede pisar porque
#   exigen que algo entre de verdad.
#
# COSTE EN ENVIOS: hasta 2 SI EL TRANSPORTE NO FALLA, y lo normal es 1.
#   El truco es el orden: la escalera va de MAYOR a MENOR, y un peldano RECHAZADO no
#   entrega correo, asi que NO GASTA (D-046 condicion 3, "preferir el rechazo al envio":
#   la cifra sale del cuerpo del error). Solo el primer peldano ACEPTADO cuesta un envio,
#   y ahi la escalera se para.
#     - 'escalera': 0 o 1 envio (1 en cuanto un peldano entra)
#     - 'control':  1 envio, y solo hace falta si el peldano aceptado estaba POR ENCIMA de
#                   las dos cifras publicadas y hay que demostrar que esta cuenta entrega.
#                   Va CONDICIONADO al margen que quede en el libro: es la fase que se cae
#                   si la pasada se queda sin presupuesto (ver PRESUPUESTO DE LA PASADA)
#     - 'plan', 'eventos', 'veredicto': 0 envios
#
#   LO QUE UN RECHAZO TIENE QUE SER PARA NO GASTAR (corregido el 2026-09-17). Solo un
#   codigo 4xx explicito demuestra que la peticion no fue aceptada. Con --max-time 600 y un
#   cuerpo de hasta 35 MB, un 000 de curl -- timeout, conexion cortada, TLS caido -- puede
#   significar que la respuesta se perdio DESPUES de que Brevo aceptara y encolara el
#   correo. La version anterior contaba ese 000 como rechazo, liberaba la reserva y BAJABA
#   un peldano: en el peor caso, los siete peldanos aceptados con la respuesta perdida eran
#   siete entregas reales con el libro marcando cero. Ahora un resultado ambiguo -- 000,
#   .curlerr no vacio, cuerpo vacio, cualquier 5xx -- se anota DUDOSO, la reserva se QUEDA
#   puesta y la escalera SE PARA en el acto, porque un envio perdido invalida el par de
#   bisercion igual que lo invalidaria uno de mas.
#
# PRESUPUESTO DE LA PASADA: 3 envios entre los paquetes A y B, en un solo libro de cuentas
#   (lib_presupuesto_brevo.sh). La cuenta del plan, con el tramo sandbox del sondeo 1 ya
#   declarado, es: sondeo 1 gasta 1 o 2 (1 si demuestra que sandbox no cobra) y este gasta 1
#   o 2. Los dos a la vez pueden pedir 4, asi que el que se queda sin margen es el peldano
#   'control' de ESTE sondeo -- es el unico prescindible de los cuatro: solo hace falta si
#   el peldano aceptado estaba por encima de las cifras publicadas y no consta entregado.
#   La fase lo dice y no llama a nada cuando el libro no da, en vez de abortar a mitad.
#   El tope esta escrito en el fichero y no en el entorno.
#
# LA ESCALERA, Y POR QUE CADA PELDANO (el par de bisercion)
#   Un caso suelto no demuestra nada: lo que se busca es el PAR {peldano mas bajo
#   rechazado, peldano mas alto aceptado}, que acota el techo real. Los peldanos se
#   declaran en BYTES del adjunto DECODIFICADO -- no en MB ni en MiB -- porque la unidad
#   es justo una de las cosas que no se sabe:
#     26.500.000 B  por encima de 25 MB en las dos lecturas (25e6 y 25 MiB = 26.214.400)
#     24.000.000 B  entre 20 MB y 25 MB decimal
#     21.000.000 B  por encima de 20 MB en las dos lecturas (20e6 y 20 MiB = 20.971.520)
#     19.000.000 B  por debajo de 20 MB en las dos lecturas
#     14.000.000 B  18,7 MB de peticion una vez en base64: por debajo de 20 MB TAMBIEN en
#                   el eje del cuerpo. Es el vecino de abajo del caso t01 del paquete A,
#                   que puso 15 MB decodificados = 20,0 MB de peticion
#      5.000.000 B  por encima de los 4 MB que [F27] declara SOLO para la via de plantilla
#      3.000.000 B  por debajo de esos 4 MB. Suelo de la escalera
#
#   LOS DOS EJES, QUE ES LA TRAMPA DE ESTA MEDICION. "20MB including the attachments and
#   email content" no dice si se mide el adjunto tal cual o el mensaje ya ensamblado, y
#   base64 infla un tercio: 19 MB de adjunto viajan como 25,3 MB de peticion. Por eso el
#   JSON guarda de cada peldano TRES cifras -- bytes del adjunto, longitud del base64 y
#   bytes del cuerpo HTTP entero -- y las da en MB decimal y en MiB. El bracket se lee
#   luego contra los DOS ejes y las DOS unidades, y la pareja {14 MB aceptado, 19 MB
#   rechazado} diria que el tope se mide sobre el cuerpo de la peticion y no sobre el
#   adjunto. Eso NO se decide aqui: se mide y se deja legible.
#
# LO QUE ESTE SONDEO NO MIDE, Y HAY QUE DECIRLO
#   - Cual de las dos cifras es la buena con precision de 1 MB: cada punto de la escalera
#     que entre cuesta un envio, y el presupuesto son 2. El bracket es lo que hay.
#   - Un rechazo puede venir de la INFRAESTRUCTURA (un tope de tamano de peticion en el
#     borde, con HTML por cuerpo) y no de la validacion de Brevo. Se distingue leyendo el
#     cuerpo: si trae 'code' de Brevo es validacion; si no, se marca como infraestructura
#     y el tope del correo se queda sin medir. Por eso el cuerpo se guarda ENTERO.
#   - Un correo aceptado puede no llegar porque el buzon del DESTINATARIO lo rechace por
#     tamano, que no es el tope de Brevo. El script NO arbitra quien lo aplico: marca que
#     el motivo habla de tamano y deja el literal de 'reason'. Por eso el destinatario es
#     persona-2@example.invalid, el de mayor tope de recepcion de los tres de la lista blanca.
#   - El plan Free retiene en una cola de reintento (F-24), asi que "no consta entregado"
#     puede ser "todavia no". La fase 'eventos' es repetible a proposito.
#
# USO (en la maquina del autor; la clave NUNCA por el chat)
#   bash probe_brevo_b_tamano_entrega.sh plan       # escalera y bytes. CERO llamadas
#   bash probe_brevo_b_tamano_entrega.sh escalera   # de mayor a menor, para al aceptar
#   bash probe_brevo_b_tamano_entrega.sh control    # 1 MB: demuestra que la cuenta entrega
#   bash probe_brevo_b_tamano_entrega.sh eventos    # lee los eventos (repetible) 0 envios
#   bash probe_brevo_b_tamano_entrega.sh veredicto  # calcula y escribe el JSON  0 llamadas
#   bash probe_brevo_b_tamano_entrega.sh reiniciar  # borra el estado (NO el libro)
#
# LISTA BLANCA (D-046, docs/08-mandato.md): una sola direccion, escrita literal abajo y
#   pasada por la guarda lib_lista_blanca.py antes de la primera llamada, y otra vez sobre
#   la envolvente. Lo que viaja al proveedor es lo que devuelve la guarda. No se lee del
#   entorno -- BREVO_TO existe en el .env y aqui no se usa a proposito, porque un
#   destinatario que se puede cambiar con una variable de entorno no esta comprobado, esta
#   sugerido -- y no se generan variantes.
#
# CREDENCIALES: ~/.config/tfm/.env, fuera del repo, cargadas con 'set -a' y nunca impresas.
#   La clave NO viaja en la linea de ordenes: curl la lee de su fichero de configuracion por
#   la entrada estandar (lib_curl_brevo.sh), asi que no hay argv donde leerla con un 'ps' --
#   y aqui importa mas que en ningun otro sondeo, porque cada peticion tarda minutos en
#   subir. No se escribe en ningun fichero: el JSON pasa por un redactor antes de guardarse.
#   El .env se carga ANTES de la guarda: 'set -a' mas un source pueden definir cualquier
#   nombre, y con la guarda delante una linea nueva del .env podria sobrescribir el
#   destinatario DESPUES de comprobarlo.
#
# SALIDA: probe_brevo_b_tamano_entrega_<fecha>.json en 03_datos/apis/brevo/evidencias/ si
#   esa carpeta existe, y si no junto a este script. De cada peldano: las tres cifras de
#   tamano, el codigo HTTP, las cabeceras y el CUERPO ENTERO de la respuesta.
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
    libro_tope_efectivo libro_veredicto_http libro_exige_escritura libro_tramo_pagado \
    reservar parada_puesta parada_poner parada_comprobar paquete_a_cerrar \
    brevo_limpia_funciones curl_brevo brevo_clave_valida brevo_carga_env || exit 3
# Y AQUI se lee el .env, como DATO y no como codigo: lib_env_brevo.sh se queda con cuatro
# nombres y descarta el resto del fichero. Un 'set -a' mas un source podia definir PATH,
# PYTHONPATH, GUARDA, BASE, TOPE_PASADA, LIBRO, PARADA -- y hasta 'readonly' o '[' como
# funciones, con lo que las dos defensas anteriores caian juntas.
brevo_carga_env || exit 3
# El coste va en DESTINATARIOS, que es la unidad del libro desde el 2026-09-17. Este sondeo
# manda a UN destinatario por peticion, asi que la cifra coincide con la de peticiones.
readonly COSTE_MAXIMO_ESTE_SONDEO=2            # escalera (0-1) + control (0-1, condicionado)
readonly ESTADO="$HOME/.cache/tfm/probe_brevo_b_tamano_entrega"

readonly BASE="https://api.brevo.com/v3"
PAUSA="${PAUSA:-6}"                            # pausa entre llamadas (no se provoca el limite)
# Suelo de la pausa: el entorno puede ALARGARLA, nunca quitarla (regla 8 del encargo). Una
# pausa que se pone a cero desde fuera no es una pausa, igual que un tope que se cambia
# desde fuera no es un tope.
case "$PAUSA" in ''|*[!0-9]*) PAUSA=2 ;; *) [ "$PAUSA" -ge 2 ] || PAUSA=2 ;; esac

# Escalera, de MAYOR a MENOR: <bytes del adjunto decodificado>:<que cruza ese peldano>.
# El orden es el que hace que los rechazos salgan gratis. Los cuatro primeros son los
# mismos puntos que probe_brevo_a_tamano.sh, para que las dos lecturas se compongan.
ESCALERA="26500000:por_encima_de_25MB_en_las_dos_lecturas \
24000000:entre_20MB_y_25MB_decimal \
21000000:por_encima_de_20MB_en_las_dos_lecturas \
19000000:por_debajo_de_20MB_en_las_dos_lecturas \
14000000:18.7MB_de_peticion_en_base64_por_debajo_de_20MB_tambien_en_ese_eje \
5000000:por_encima_de_los_4MB_que_F27_declara_solo_para_plantilla \
3000000:por_debajo_de_esos_4MB_suelo_de_la_escalera"
CONTROL_BYTES=1000000

FASE="${1:-}"

uso () {
  sed -n '/^# USO (en la maquina/,/^#   bash probe_brevo_b_tamano_entrega.sh reiniciar/p' "$0" \
    | sed 's/^# \{0,3\}//'
}

case "$FASE" in
  plan|escalera|control|eventos|veredicto|reiniciar) ;;
  *) echo "Falta la fase."; echo; uso; exit 2 ;;
esac

# --- Credenciales: el .env ya se cargo arriba, antes de todo lo demas -------------------
: "${BREVO_API_KEY:?Falta BREVO_API_KEY en ~/.config/tfm/.env}"
: "${BREVO_FROM:?Falta BREVO_FROM en ~/.config/tfm/.env}"
brevo_clave_valida "$BREVO_API_KEY" || {
  echo "ABORTA: BREVO_API_KEY tiene caracteres fuera de [A-Za-z0-9_.:-]. No se llama a nada."
  exit 3; }

# --- Lista blanca, literal. Copiada de docs/08-mandato.md. Sin variantes. --------------
# Literal en el fichero: no sale de ninguna variable de entorno ni del .env. De
# las tres, gmail es la de mayor tope de recepcion, y un rechazo del buzon del destinatario
# por tamano confundiria la medida del tope de Brevo.
readonly DEST="persona-2@example.invalid"

# La PARADA es del paquete entero. Si un sondeo vio una peticion de envio aceptada -- o sin
# resolver -- donde no debia, la pasada se mira, no se continua. Las fases que no llaman a
# nada siguen disponibles: son justamente con las que se mira.
case "$FASE" in
  plan|veredicto|reiniciar) ;;
  *) parada_comprobar ;;
esac

# --- Guarda de la lista blanca: lo ultimo antes de construir cualquier cuerpo -----------
[ -r "$GUARDA" ] || { echo "ABORTA: no se encuentra la guarda $GUARDA. No se envia nada."; exit 3; }
# Una llamada por CADA destinatario (aqui hay uno) y otra sobre la envolvente: lo que se
# manda es lo que la guarda devuelve, no lo que se le paso.
python3 -I "$GUARDA" check "$DEST" >/dev/null || {
  echo "ABORTA: la guarda rechazo el destinatario. No se envia nada."; exit 3; }
SOBRE="$(python3 -I "$GUARDA" check "$DEST")" || {
  echo "ABORTA: la guarda rechazo la envolvente. No se envia nada."; exit 3; }

# --- La unidad del libro es el DESTINATARIO, no la peticion (corregido 2026-09-17) ------
# Se cuenta sobre la SALIDA de la guarda, que es exactamente lo que va a viajar, y no sobre
# una constante escrita a mano: una constante que se desincroniza del cuerpo es la misma
# clase de error que contar una peticion de 2.000 destinatarios como un envio. Aqui vale 1,
# y verificar_cuerpo() comprueba que el fichero que sale por el cable lleva esos mismos.
readonly NDEST="$(printf '%s' "$SOBRE" | tr ',' '\n' | grep -c '[^[:space:]]')"
case "$NDEST" in
  ''|*[!0-9]*|0) echo "ABORTA: no se pudo contar los destinatarios de la envolvente."; exit 3 ;;
esac

mkdir -p "$ESTADO" && chmod 700 "$ESTADO"
libro_init
# El libro tiene que poder ESCRIBIR, y se comprueba antes de la primera llamada. Con el
# libro presente pero no escribible el append fallaba en silencio, reservar() devolvia 0 e
# imprimia "reservados 2", y el contador volvia a leer 0: el tope dejaba de morder.
libro_exige_escritura
EJEC="${EJEC:-$(date -u +%Y%m%d%H%M%S)}"

# El espacio libre, ANTES de generar los cuerpos. Este sondeo escribe ~35 MB por peldano en
# $ESTADO, y un disco lleno a mitad deja peticiones truncadas que se leen como resultado.
# 'df' ya estaba en la lista de brevo_limpia_funciones y no se usaba.
espacio_suficiente () {  # $1 MB que hacen falta
  local LIBRE
  LIBRE="$(df -Pm "$ESTADO" 2>/dev/null | awk 'NR==2{print $4}')"
  case "$LIBRE" in ''|*[!0-9]*)
    echo "AVISO: no se pudo leer el espacio libre de $ESTADO; se sigue." >&2; return 0 ;;
  esac
  if (( LIBRE < $1 )); then
    echo "ABORTA: en $ESTADO quedan ${LIBRE} MB libres y hacen falta al menos $1 MB para" >&2
    echo "        los cuerpos de peticion. Un disco lleno a mitad deja peticiones" >&2
    echo "        truncadas que se leen como resultado. No se llama a nada." >&2
    exit 3
  fi
}
espacio_suficiente 120

presupuesto () {
  libro_init
  local C T; C="$(libro_comprometido)"; T="$(libro_tope_efectivo)"
  echo "== PRESUPUESTO (D-046 condicion 2), impreso ANTES de la primera llamada"
  echo "   tope de la pasada entera (paquetes A y B) . $T envios"
  echo "   ya comprometidos en la ventana ............ $C   (la pasada son 24 horas)"
  echo "   margen que queda .......................... $((T - C))"
  echo "   este sondeo gasta como mucho .............. $COSTE_MAXIMO_ESTE_SONDEO destinatarios"
  echo "     la unidad del libro es el DESTINATARIO, no la peticion ($NDEST por peticion aqui)"
  echo "     escalera: 0 o 1 (solo el primer peldano ACEPTADO cuesta; los 4xx, nada)"
  echo "     control:  1, y es la fase prescindible de la pasada. Se ejecuta solo si queda"
  echo "              margen Y si la unidad de la cuota -- la pregunta principal del"
  echo "              paquete B, 2 destinatarios -- ya esta pagada en el libro"
  echo "   fases sin coste ........................... plan, eventos, veredicto"
  echo "   libro ..................................... $LIBRO"
  echo "   estado de trabajo ......................... $ESTADO"
  echo "   un envio = UN DESTINATARIO de una peticion ACEPTADA ($NDEST por peticion aqui);"
  echo "   solo un 4xx explicito libera la reserva."
  echo "   Un 000 de curl NO demuestra rechazo: consume presupuesto y PARA la escalera."
  echo
}

# La regla de cierre -- 2xx GASTO, 4xx LIBERA, cualquier otra cosa DUDOSO -- vive en
# libro_veredicto_http() de lib_presupuesto_brevo.sh y en ningun otro sitio. Aqui habia una
# copia, cerrar_en_el_libro(), que nadie llamaba: la escalera y el control llevan su propio
# 'case' en linea, y esa copia usaba el $NDEST global en vez de un parametro. Duplicar la
# regla en tres sitios es la misma clase de deriva que produjo la causa 2.
#
# El paquete A reserializa el cuerpo y lo relee antes de CADA llamada; el paquete B, que si
# entrega, comprobaba una variable de shell al arrancar y luego posteaba un fichero de la
# cache sin volver a mirarlo. Lo que se comprueba tiene que ser lo que sale por el cable.
verificar_cuerpo () {  # $1 fichero de peticion
  local REQ="$1" DEST_F
  [ -s "$REQ" ] || { echo "ABORTA: $REQ no existe o esta vacio. No se llama a nada."; exit 3; }
  DEST_F="$(python3 -I - "$REQ" <<'PY'
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
  python3 -I "$GUARDA" check "$DEST_F" >/dev/null || {
    echo "ABORTA: el fichero que se iba a enviar lleva un destinatario fuera de la lista"
    echo "        blanca. No se llama a nada."; exit 3; }
  # Y que sean TANTOS como el libro reservo. Un cuerpo con mas destinatarios que la reserva
  # gasta mas de lo comprometido, que es la causa 3 en pequeno.
  local CUANTOS; CUANTOS="$(printf '%s' "$DEST_F" | tr ',' '\n' | grep -c '[^[:space:]]')"
  [ "$CUANTOS" = "$NDEST" ] || {
    echo "ABORTA: el fichero lleva $CUANTOS destinatario(s) y el libro reservo $NDEST."
    echo "        No se llama a nada."; exit 3; }
}

cabeceras_interesantes () {
  grep -iE '^(x-sib-|date|content-type|retry-after|x-request-id)' "$1" 2>/dev/null || true
}

# --- Construccion del peldano ----------------------------------------------------------
# El adjunto se rellena con ASCII imprimible (base64 de /dev/urandom recortado), no con un
# patron repetido: asi el tamano no depende de que nada comprima, y el .txt sigue siendo
# texto de verdad. La extension .txt esta en la lista que publica [F10].
generar_adjunto () {  # $1 bytes del adjunto decodificado
  local N="$1"
  { head -c "$(( N * 3 / 4 + 64 ))" /dev/urandom | base64 -w0 | head -c "$N" ; } \
    > "$ESTADO/adj.txt" 2>/dev/null || true
  base64 -w0 "$ESTADO/adj.txt" > "$ESTADO/adj.b64"
  echo "$(wc -c < "$ESTADO/adj.txt" | tr -d ' ') $(wc -c < "$ESTADO/adj.b64" | tr -d ' ')"
}

construir_cuerpo () {  # $1 bytes del peldano  $2 etiqueta
  SOBRE="$SOBRE" DE="$BREVO_FROM" BYTES="$1" ETQ="$2" EJEC="$EJEC" \
  python3 -I - "$ESTADO" <<'PY'
import json, os, sys
est = sys.argv[1]
n = int(os.environ["BYTES"])
dest = [{"email": d} for d in os.environ["SOBRE"].split(",") if d]
assert len(dest) == 1, "este sondeo manda a UNA sola direccion de la lista blanca"
contenido = open("%s/adj.b64" % est).read()
nombre = "tfm-sondeo-%dB.txt" % n
cuerpo = {
    "sender": {"email": os.environ["DE"], "name": "TFM sondeo"},
    "to": dest,
    "subject": "TFM Brevo B2 tamano %d B [%s/%s]" % (n, os.environ["ETQ"],
                                                     os.environ["EJEC"]),
    "textContent": ("Sondeo del TFM de Pricing Intelligence (escalon 3, paquete B, "
                    "sondeo 2). Mide si el tope de tamano del correo muerde en validacion "
                    "o en entrega (DISC-16). No requiere respuesta."),
    "attachment": [{"content": contenido, "name": nombre}],
}
with open("%s/req.json" % est, "w") as f:
    json.dump(cuerpo, f, ensure_ascii=True)
esq = {k: v for k, v in cuerpo.items() if k != "attachment"}
esq["sender"] = {"email": "<FROM>", "name": "TFM sondeo"}
esq["to"] = [{"email": "<DEST>"}]
esq["attachment"] = [{"content": "<base64 de %d bytes>" % len(contenido), "name": nombre}]
with open("%s/req_esqueleto.json" % est, "w") as f:
    json.dump(esq, f, ensure_ascii=True, indent=1)
PY
}

postear_peldano () {  # $1 etiqueta de tramo  $2 bytes  $3 motivo del peldano
  local E="$1" N="$2" MOTIVO="$3"
  local TAM ADJ B64 REQB
  TAM="$(generar_adjunto "$N")"
  ADJ="${TAM%% *}"; B64="${TAM##* }"
  construir_cuerpo "$N" "$E" || { echo "ABORTA: construir_cuerpo fallo en $E."; exit 3; }
  verificar_cuerpo "$ESTADO/req.json"
  REQB="$(wc -c < "$ESTADO/req.json" | tr -d ' ')"
  printf '%s\t%s\t%s\t%s\t%s\n' "$N" "$ADJ" "$B64" "$REQB" "$MOTIVO" > "$ESTADO/$E.tam"
  date -u +%Y-%m-%dT%H:%M:%SZ > "$ESTADO/$E.utc"
  echo "   [$E] adjunto $ADJ B, base64 $B64 B, cuerpo HTTP $REQB B"
  curl_brevo "$BREVO_API_KEY" -sS --max-time 600 -o "$ESTADO/$E.body" -D "$ESTADO/$E.hdr" \
    -w '%{http_code}' -X POST -H 'accept: application/json' \
    -H 'content-type: application/json' \
    --data-binary @"$ESTADO/req.json" "$BASE/smtp/email" \
    > "$ESTADO/$E.code" 2> "$ESTADO/$E.curlerr" || true
  rm -f "$ESTADO/adj.txt" "$ESTADO/adj.b64" "$ESTADO/req.json"   # 130 MB no viven en cache
  echo "        -> HTTP $(cat "$ESTADO/$E.code" 2>/dev/null || echo '?')"
  cabeceras_interesantes "$ESTADO/$E.hdr" | sed 's/^/        /'
  echo "        cuerpo: $(head -c 800 "$ESTADO/$E.body" 2>/dev/null)"
  if [ -s "$ESTADO/$E.curlerr" ]; then
    echo "        AVISO de curl (fallo de transporte): $(head -c 300 "$ESTADO/$E.curlerr")"
  fi
}

http_de () {  # $1 etiqueta de tramo -> codigo tal cual, o vacio
  cat "$ESTADO/$1.code" 2>/dev/null | tr -dc '0-9'
}

# Un .curlerr con contenido es prueba de que el transporte tuvo algo que decir. Aunque el
# codigo parezca bueno, con el cuerpo perdido no se puede afirmar que la peticion no entrara.
transporte_sospechoso () {  # $1 etiqueta
  [ -s "$ESTADO/$1.curlerr" ] || [ ! -s "$ESTADO/$1.body" ]
}

# --- Fases -----------------------------------------------------------------------------
fase_plan () {
  presupuesto
  echo "== PLAN (cero llamadas). La escalera, de mayor a menor:"
  for P in $ESCALERA; do
    python3 -I - "${P%%:*}" "${P##*:}" <<'PY'
import sys
n = int(sys.argv[1]); mot = sys.argv[2]
b64 = (n + 2) // 3 * 4
print("   adjunto %11d B (%6.2f MB / %6.2f MiB) | peticion %11d B (%6.2f MB / %6.2f MiB)"
      % (n, n / 1e6, n / 1048576, b64, b64 / 1e6, b64 / 1048576))
print("      %s" % mot)
PY
  done
  echo
  echo "   peldano de control: $CONTROL_BYTES B (fase 'control', 1 envio)"
  echo "   Las dos cifras enfrentadas son 20 MB [F27] y 25 MB [F5]. La escalera las cruza"
  echo "   por los dos ejes -- adjunto y cuerpo de la peticion -- y por las dos unidades,"
  echo "   MB decimal y MiB. Cero llamadas en esta fase: ni se genera el adjunto."
}

fase_escalera () {
  presupuesto
  echo "== ESCALERA: de MAYOR a MENOR. Cada peldano reserva un envio ANTES de llamar; si"
  echo "   el proveedor lo rechaza, no entrega correo y la reserva se libera. En cuanto"
  echo "   uno entra, se para: ese es el peldano mas alto aceptado y cierra el par."
  echo
  for P in $ESCALERA; do
    local N="${P%%:*}" MOT="${P##*:}" E C
    E="peldano_${N}B"
    if [ -e "$ESTADO/$E.code" ]; then
      echo "   [$E] ya medido (HTTP '$(http_de "$E")'), se mira que paso"
      # TRES casos y no dos. La version anterior hacia 'continue' para todo lo que no
      # empezara por 20, y un peldano DUDOSO deja su .code con 000 -- o vacio, si curl murio
      # despues de que la redireccion creara el fichero -- asi que la segunda pasada lo
      # saltaba y BAJABA al peldano siguiente. Es justo lo que la rama DUDOSO de la ejecucion
      # en vivo prohibe cuarenta lineas mas abajo: bajar un peldano encima de un envio
      # perdido invalida el par y manda un segundo correo real.
      case "$(libro_veredicto_http "$(http_de "$E")")" in
        aceptada)
          echo "   >>> ya habia un peldano aceptado: la escalera termina aqui."
          return 0 ;;
        rechazada)
          continue ;;
        *)
          echo "ABORTA: el peldano $E quedo SIN RESOLVER en una pasada anterior (HTTP" >&2
          echo "        '$(http_de "$E")'). No se baja hasta saber que paso con el: si esa" >&2
          echo "        peticion salio, el peldano de abajo seria un segundo correo real y" >&2
          echo "        el par de bisercion no diria nada. Mirar $ESTADO/$E.curlerr y el" >&2
          echo "        libro $LIBRO." >&2
          return 1 ;;
      esac
    fi
    reservar "$E" "$NDEST"
    sleep "$PAUSA"
    postear_peldano "$E" "$N" "$MOT"
    C="$(http_de "$E")"
    # Un 4xx con el transporte tocado tampoco es un rechazo limpio: si el cuerpo no llego,
    # la cita literal no existe y el codigo suelto puede venir de un intermediario.
    if [ "$(libro_veredicto_http "$C")" = "rechazada" ] && transporte_sospechoso "$E"; then
      C="000"
      echo "   >>> el codigo parecia $(http_de "$E") pero el transporte fallo o el cuerpo"
      echo "   >>> llego vacio: se trata como DUDOSO, que es el lado conservador."
    fi
    case "$(libro_veredicto_http "$C")" in
      aceptada)
        libro_anota GASTO "$E" "http=$C bytes=$N" "$NDEST"
        echo "   >>> ACEPTADO con $N B de adjunto: 1 envio gastado y la escalera se para."
        echo "   >>> Par cerrado. Ahora 'eventos' dice si de verdad se entrego."
        return 0 ;;
      rechazada)
        libro_anota LIBERA "$E" "http=$C bytes=$N rechazo demostrado (4xx), no entrega" "$NDEST"
        echo "   >>> HTTP $C: rechazo DEMOSTRADO, no sale correo, no gasta. La cita literal"
        echo "   >>> esta en el cuerpo, guardado entero. Bajamos un peldano."
        ;;
      *)
        libro_anota DUDOSO "$E" "http=$C bytes=$N resultado ambiguo: la reserva se queda puesta" "$NDEST"
        echo "   >>> HTTP '$C': NO demuestra rechazo. Con --max-time 600 y un cuerpo de"
        echo "   >>> decenas de MB, la respuesta se puede perder DESPUES de que Brevo"
        echo "   >>> aceptara y encolara el correo, asi que el lado conservador es asumir"
        echo "   >>> que salio: la reserva se QUEDA puesta y la escalera SE PARA aqui."
        echo "   >>> Bajar un peldano encima de un envio perdido invalidaria el par."
        echo "   >>> Mirar $ESTADO/$E.curlerr antes de relanzar nada."
        # Y se pone la PARADA, igual que hace paquete_a_cerrar() en el paquete A. Sin ella
        # nada impedia relanzar este sondeo ni el otro del paquete: la pasada se mira, no se
        # continua.
        parada_poner "$E quedo sin resolver (HTTP '$C') en un endpoint de envio: no se sabe si salio correo" || true
        return 1 ;;
    esac
  done
  echo
  echo ">>> Ningun peldano entro: el tope esta por debajo del suelo de la escalera."
  echo ">>> Eso ya es un resultado, y la cita del cuerpo manda. Cero envios gastados."
}

fase_control () {
  presupuesto
  echo "== CONTROL: un peldano de $CONTROL_BYTES B, muy por debajo de cualquier cifra"
  echo "   publicada. Sirve para una sola cosa: demostrar que ESTA cuenta entrega, para"
  echo "   que 'no consta entregado' en el peldano grande signifique algo."
  local E="control_${CONTROL_BYTES}B" C M
  if [ -e "$ESTADO/$E.code" ]; then
    echo "   ya medido (HTTP '$(http_de "$E")'). No se repite."
    case "$(libro_veredicto_http "$(http_de "$E")")" in
      dudosa) echo "   >>> y quedo SIN RESOLVER: no se sabe si ese correo salio, asi que la"
              echo "   >>> lectura de 'no consta entregado' del peldano grande no se puede"
              echo "   >>> apoyar en el. Mirar $ESTADO/$E.curlerr." ;;
    esac
    return 0
  fi
  # Esta es la fase prescindible de la pasada: si el libro no da, se dice y no se llama a
  # nada, en vez de abortar dentro de reservar con el sondeo a medias. El plan entero
  # (1-2 del sondeo 1 mas 1-2 de este) puede pedir 4 envios sobre un tope de 3, y el
  # peldano de control es lo unico que se puede dejar caer sin romper ninguna medida: solo
  # hace falta si el peldano aceptado estaba por encima de las cifras publicadas y encima
  # no consta entregado.
  # El orden de la pasada, comprobado y no solo escrito. Esta fase es la prescindible; la
  # pregunta principal del paquete B es la unidad de la cuota, que cuesta 2 destinatarios.
  # Si el control corre ANTES de ese envio, se lleva el margen y la pregunta principal ya
  # no cabe: se pierde lo importante para quedarse con lo accesorio.
  if ! libro_tramo_pagado probe_brevo_b_unidad_cuota.sh envio_real; then
    echo "   NO SE EJECUTA todavia: el libro no tiene pagado el envio real de"
    echo "   probe_brevo_b_unidad_cuota.sh, que es la pregunta PRINCIPAL del paquete B y"
    echo "   cuesta 2 destinatarios. Este peldano de control es la fase prescindible y"
    echo "   cuesta $NDEST: si va delante, se lleva el margen y la unidad de la cuota deja"
    echo "   de caber. Correr primero ese sondeo y volver aqui si queda margen."
    return 0
  fi
  M="$(libro_margen)"
  if [ "$M" -lt "$NDEST" ]; then
    echo "   NO SE EJECUTA: el libro no tiene margen (quedan $M envios de $(libro_tope_efectivo))."
    echo "   Es la fase declarada prescindible del paquete. Lo que se pierde: la prueba de"
    echo "   que esta cuenta entrega, y con ella la lectura de 'no consta entregado' en el"
    echo "   peldano grande. Se anota asi en el veredicto y la pregunta vuelve en la salida."
    return 0
  fi
  reservar "$E" "$NDEST"
  sleep "$PAUSA"
  postear_peldano "$E" "$CONTROL_BYTES" "control_de_entrega"
  C="$(http_de "$E")"
  if [ "$(libro_veredicto_http "$C")" = "rechazada" ] && transporte_sospechoso "$E"; then
    C="000"
  fi
  case "$(libro_veredicto_http "$C")" in
    aceptada)  libro_anota GASTO "$E" "http=$C bytes=$CONTROL_BYTES" "$NDEST"
               echo "   >>> aceptado: 1 envio gastado. 'eventos' dira si se entrego." ;;
    rechazada) libro_anota LIBERA "$E" "http=$C rechazo demostrado (4xx)" "$NDEST"
               echo "   >>> HTTP $C: rechazo DEMOSTRADO. No gasta. Y si un correo de"
               echo "   >>> $CONTROL_BYTES B no entra, el problema no es el tamano: lee el cuerpo." ;;
    *)         libro_anota DUDOSO "$E" "http=$C resultado ambiguo: la reserva se queda puesta" "$NDEST"
               parada_poner "$E quedo sin resolver (HTTP '$C') en un endpoint de envio: no se sabe si salio correo" || true
               echo "   >>> HTTP '$C': no demuestra rechazo. La reserva se queda puesta, el"
               echo "   >>> control no se repite y se pone la PARADA: la pasada se mira."
               echo "   >>> Mirar $ESTADO/$E.curlerr." ;;
  esac
}

fase_eventos () {
  presupuesto
  echo "== EVENTOS (0 envios): GET /v3/smtp/statistics/events por messageId de cada"
  echo "   peldano aceptado. Repetible: la cola de reintento del Free (F-24) puede tardar,"
  echo "   asi que 'no consta entregado' puede ser 'todavia no'."
  local ENC=0
  for B in "$ESTADO"/peldano_*B.body "$ESTADO"/control_*B.body; do
    [ -e "$B" ] || continue
    local E MID N
    E="$(basename "$B" .body)"
    MID="$(python3 -I - "$B" <<'PY'
import json,sys
try:
    d=json.load(open(sys.argv[1]))
except Exception:
    raise SystemExit
m=d.get("messageId") or (d.get("messageIds") or [None])[0]
if m: print(m)
PY
)"
    [ -n "$MID" ] || continue
    ENC=$((ENC + 1))
    N=1; while [ -e "$ESTADO/evento_${E}_$N.body" ]; do N=$((N + 1)); done
    sleep "$PAUSA"
    date -u +%Y-%m-%dT%H:%M:%SZ > "$ESTADO/evento_${E}_$N.utc"
    curl_brevo "$BREVO_API_KEY" -sS --max-time 60 -G -o "$ESTADO/evento_${E}_$N.body" \
      -D "$ESTADO/evento_${E}_$N.hdr" \
      -w '%{http_code}' -H 'accept: application/json' \
      --data-urlencode "messageId=$MID" --data-urlencode "limit=50" \
      "$BASE/smtp/statistics/events" > "$ESTADO/evento_${E}_$N.code" \
      2> "$ESTADO/evento_${E}_$N.curlerr" || true
    echo "   [$E] lectura $N -> HTTP $(cat "$ESTADO/evento_${E}_$N.code" 2>/dev/null || echo '?')"
    python3 -I - "$ESTADO/evento_${E}_$N.body" <<'PY' || true
import json,sys
try: d=json.load(open(sys.argv[1]))
except Exception as e: print("        (cuerpo no JSON: %s)"%e); raise SystemExit
ev=d.get("events") or []
print("        eventos: %d" % len(ev))
for x in ev:
    print("          %s  event=%s  reason=%s" % (x.get("date"), x.get("event"), x.get("reason")))
PY
  done
  [ "$ENC" -gt 0 ] || echo "   (ningun peldano aceptado todavia: nada que consultar)"
}

fase_veredicto () {
  local SAL="$AQUI"
  [ -d "$EVIDENCIAS" ] && SAL="$EVIDENCIAS"
  local OUT="$SAL/probe_brevo_b_tamano_entrega_$(date -u +%Y-%m-%d_%H%M%S).json"
  CLAVE="$BREVO_API_KEY" FROM="$BREVO_FROM" D1="$DEST" \
  TOPE="$TOPE_PASADA" LIBROF="$LIBRO" COSTE="$COSTE_MAXIMO_ESTE_SONDEO" \
  python3 -I - "$ESTADO" "$OUT" <<'PY'
import json, os, re, sys, glob, datetime

est, out = sys.argv[1], sys.argv[2]
CAP = 200000

# La clave se redacta por PATRON y por VALOR exacto, y las dos capas hacen falta: el patron
# cubre las dos formas que Brevo emite y ademas lo que se cuele en un cuerpo de respuesta;
# el valor exacto cubre cualquier formato que el patron no reconozca. Este JSON se copia a
# evidencias/ y entra en un commit, que es irreversible, asi que aqui no se ahorra.
CLAVE = os.environ.get("CLAVE") or ""
CLAVE_PATRON = re.compile(r"x(?:keysib|smtpsib)-[A-Za-z0-9._:-]{8,}")
ETIQ  = [(os.environ.get("FROM") or "", "<FROM>"), (os.environ.get("D1") or "", "<DEST>")]
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

def leer(nombre):
    p = lambda ext: os.path.join(est, nombre + ext)
    if not os.path.exists(p(".code")): return None
    t = {"tramo": nombre, "utc": None, "http": None, "cabeceras": {}, "cuerpo": None,
         "cuerpo_texto": None, "truncado": False}
    try: t["utc"] = open(p(".utc")).read().strip()
    except Exception: pass
    try: t["http"] = int(open(p(".code")).read().strip() or "0")
    except Exception: t["http"] = 0
    try:
        for l in open(p(".hdr"), errors="replace"):
            if ":" in l:
                k, v = l.split(":", 1); k = k.strip().lower()
                if k.startswith("x-sib-") or k in ("date", "content-type", "retry-after",
                                                   "x-request-id", "content-length"):
                    t["cabeceras"][k] = v.strip()
    except Exception: pass
    try:
        crudo = open(p(".body"), errors="replace").read()
        if len(crudo) > CAP: crudo, t["truncado"] = crudo[:CAP], True
        t["cuerpo_texto"] = crudo
        try: t["cuerpo"] = json.loads(crudo)
        except Exception: pass
    except Exception: pass
    try:
        e = open(p(".curlerr"), errors="replace").read().strip()
        if e: t["curl_stderr"] = e
    except Exception: pass
    try:
        pedido, adj, b64, reqb, motivo = open(p(".tam")).read().strip().split("\t")
        t["tamano"] = {
            "bytes_pedidos": int(pedido), "motivo_del_peldano": motivo,
            "adjunto_bytes": int(adj), "base64_bytes": int(b64),
            "cuerpo_http_bytes": int(reqb),
            "adjunto_MB": round(int(adj) / 1e6, 3),
            "adjunto_MiB": round(int(adj) / 1048576, 3),
            "base64_MB": round(int(b64) / 1e6, 3),
            "base64_MiB": round(int(b64) / 1048576, 3),
            "cuerpo_http_MB": round(int(reqb) / 1e6, 3),
            "cuerpo_http_MiB": round(int(reqb) / 1048576, 3),
        }
    except Exception: pass
    # De donde viene el rechazo: de la validacion de Brevo (cuerpo con 'code') o del borde
    h = t.get("http") or 0
    if h and not (200 <= h < 300):
        c = t.get("cuerpo")
        t["origen_del_rechazo"] = ("validacion_brevo" if isinstance(c, dict) and "code" in c
                                  else "infraestructura_o_sin_codigo")
        t["code"] = (c or {}).get("code") if isinstance(c, dict) else None
        t["message"] = (c or {}).get("message") if isinstance(c, dict) else None
    return t

def bytes_de(t): return ((t or {}).get("tamano") or {}).get("adjunto_bytes")
def ok(t):       return isinstance((t or {}).get("http"), int) and 200 <= t["http"] < 300

peldanos = []
for f in sorted(glob.glob(os.path.join(est, "peldano_*B.code"))):
    t = leer(os.path.basename(f)[:-5])
    # sin fichero de tamano no es un peldano de la escalera, y contarlo como tal es como se
    # cuela un envio fantasma en el presupuesto
    if t and bytes_de(t) is not None:
        peldanos.append(t)
control = None
for f in sorted(glob.glob(os.path.join(est, "control_*B.code"))):
    control = leer(os.path.basename(f)[:-5])

peldanos.sort(key=lambda t: bytes_de(t), reverse=True)


# Un rechazo, a efectos de esta medicion, es un 4xx explicito. Lo demas -- 000, 5xx, cuerpo
# vacio, curl con algo que decir -- es DUDOSO: la peticion pudo entrar y perderse la
# respuesta, asi que ni acota el techo ni se puede contar como gratis.
def rechazo_limpio(t):
    h = (t or {}).get("http")
    if not (isinstance(h, int) and 400 <= h < 500):
        return False
    if t.get("curl_stderr"):
        return False
    return bool(t.get("cuerpo_texto"))


aceptados  = [t for t in peldanos if ok(t)]
rechazados = [t for t in peldanos if rechazo_limpio(t)]
dudosos    = [t for t in peldanos if not ok(t) and not rechazo_limpio(t)]
for t in dudosos:
    t["lectura_del_libro"] = ("DUDOSO: HTTP %s con el transporte o el cuerpo tocados. No "
                              "acota el techo y cuenta como envio comprometido"
                              % t.get("http"))

alto_aceptado  = max((bytes_de(t) for t in aceptados), default=None)
bajo_rechazado = min((bytes_de(t) for t in rechazados), default=None)

def eventos_de(nombre):
    lecturas = []
    for f in sorted(glob.glob(os.path.join(est, "evento_" + nombre + "_*.code"))):
        t = leer(os.path.basename(f)[:-5])
        if not t: continue
        ev = ((t.get("cuerpo") or {}).get("events") or []) if isinstance(t.get("cuerpo"), dict) else []
        lecturas.append({"tramo": t["tramo"], "utc": t["utc"], "http": t["http"],
                         "eventos": [{"date": x.get("date"), "event": x.get("event"),
                                      "reason": x.get("reason")} for x in ev],
                         "cuerpo_texto": None if ev else t.get("cuerpo_texto")})
    return lecturas

# Dos familias de motivo, y la diferencia decide si el sondeo cierra DISC-16 o no. Ojo:
# un 552 puede venir del relevo de Brevo o del MTA del destinatario, asi que el script NO
# arbitra quien aplico el tope: marca que el motivo habla de tamano y deja el literal.
MOTIVO_TAMANO = re.compile(r"size|too\s*large|message too big|552|5\.3\.4", re.I)
MOTIVO_DESTINATARIO = re.compile(
    r"mailbox|user unknown|does not exist|unavailable|over ?quota|550|5\.1\.1", re.I)

def lectura_de_entrega(t):
    if t is None: return None
    ev = eventos_de(t["tramo"])
    todos = [e for l in ev for e in l["eventos"]]
    nombres = sorted({(e.get("event") or "") for e in todos})
    entregado = "delivered" in nombres
    motivos = [e.get("reason") for e in todos if e.get("reason")]
    de_tamano = any(MOTIVO_TAMANO.search(m or "") for m in motivos)
    del_buzon = any(MOTIVO_DESTINATARIO.search(m or "") for m in motivos)
    if entregado:
        lect = "consta 'delivered': el correo salio y llego a ese tamano"
    elif not todos:
        lect = ("sin eventos todavia: o la cola de reintento del Free (F-24) o hace falta "
                "volver a correr 'eventos' mas tarde. No concluye nada")
    elif de_tamano:
        lect = ("no consta entregado y el motivo habla de TAMANO: el tope muerde DESPUES de "
                "la validacion, que es justo lo que sandbox no puede ver (F16). Quien lo "
                "aplica -- el relevo de Brevo o el MTA del destinatario -- lo dice el literal "
                "de 'reason', guardado entero. Aqui no se arbitra")
    elif del_buzon:
        lect = ("no consta entregado, y el motivo apunta al buzon del destinatario sin hablar "
                "de tamano: NO cierra DISC-16")
    else:
        lect = ("no consta entregado y el motivo no habla de tamano: NO cierra DISC-16. El "
                "literal esta guardado")
    return {"lecturas": ev, "eventos_vistos": nombres, "motivos": motivos,
            "entregado": entregado, "motivo_habla_de_tamano": de_tamano,
            "motivo_parece_del_destinatario": del_buzon, "lectura": lect}

entrega_aceptado = lectura_de_entrega(aceptados[0] if aceptados else None)
entrega_control  = lectura_de_entrega(control if ok(control) else None)

# ---------- veredicto ----------
def mb(n):  return None if n is None else round(n / 1e6, 3)
def mib(n): return None if n is None else round(n / 1048576, 3)

v = {"donde_muerde": None, "bracket_del_techo": None, "cifra_publicada_compatible": None,
     "eje_del_tope": None, "motivo": None,
     "peldanos_dudosos": [{"tramo": t["tramo"], "http": t.get("http"),
                           "adjunto_bytes": bytes_de(t),
                           "curl_stderr": t.get("curl_stderr")} for t in dudosos],
     "par_de_bisercion": {
         "peldano_mas_alto_ACEPTADO_bytes": alto_aceptado,
         "peldano_mas_alto_ACEPTADO_MB": mb(alto_aceptado),
         "peldano_mas_bajo_RECHAZADO_bytes": bajo_rechazado,
         "peldano_mas_bajo_RECHAZADO_MB": mb(bajo_rechazado)}}

solo_infra = (rechazados and all(t.get("origen_del_rechazo") == "infraestructura_o_sin_codigo"
                                 for t in rechazados))

if not peldanos:
    v["donde_muerde"] = "sin_medir"
    v["motivo"] = "la escalera no se ha ejecutado"
elif dudosos and not aceptados:
    v["donde_muerde"] = "sin_medir"
    v["motivo"] = ("la escalera se PARO en un peldano de resultado ambiguo (%s): el "
                   "transporte fallo o el cuerpo llego vacio, asi que no se sabe si ese "
                   "correo entro. Bajar un peldano encima de un envio quizas perdido "
                   "invalidaria el par, y el libro cuenta ese envio como comprometido. Hay "
                   "que averiguar que paso con esa peticion antes de seguir midiendo"
                   % ", ".join("%s http=%s" % (t["tramo"], t.get("http")) for t in dudosos))
elif solo_infra and not aceptados:
    v["donde_muerde"] = "sin_medir"
    v["motivo"] = ("todos los rechazos vienen sin codigo de Brevo en el cuerpo: parecen del "
                   "borde y no de la validacion, asi que el tope del correo no se ha "
                   "llegado a medir. El cuerpo entero esta guardado")
elif alto_aceptado is None:
    v["donde_muerde"] = "validacion"
    v["motivo"] = ("ningun peldano entro, ni el mas pequeno (%s B = %s MB): la validacion "
                   "aplica un tope por debajo de las dos cifras publicadas. Manda la cita "
                   "del cuerpo" % (bajo_rechazado, mb(bajo_rechazado)))
elif bajo_rechazado is None:
    v["donde_muerde"] = "no_es_la_validacion"
    v["motivo"] = ("el peldano de %s MB entro y esta POR ENCIMA de las dos cifras "
                   "publicadas: la validacion no aplica ningun tope de tamano. Si hay tope, "
                   "muerde en la entrega, y eso lo dice el bloque de entrega"
                   % mb(alto_aceptado))
else:
    v["donde_muerde"] = "validacion"
    cod_a = alto_aceptado * 4 // 3
    cod_r = bajo_rechazado * 4 // 3
    v["bracket_del_techo"] = {
        "adjunto_bytes": "(%d, %d]" % (alto_aceptado, bajo_rechazado),
        "adjunto_MB": "(%s, %s]" % (mb(alto_aceptado), mb(bajo_rechazado)),
        "adjunto_MiB": "(%s, %s]" % (mib(alto_aceptado), mib(bajo_rechazado)),
        "peticion_MB_aprox": "(%s, %s]" % (mb(cod_a), mb(cod_r)),
        "peticion_MiB_aprox": "(%s, %s]" % (mib(cod_a), mib(cod_r)),
    }
    v["motivo"] = ("entro %s MB de adjunto y se rechazo %s MB: el techo de la validacion "
                   "esta entre los dos" % (mb(alto_aceptado), mb(bajo_rechazado)))
    # Contra que cifra publicada encaja, y sobre que eje y con que unidad. Se prueban las
    # DOS lecturas de cada cifra (decimal y binaria) sobre los DOS ejes.
    PUBLICADAS = [("20 MB [F27]", 20 * 10**6, "decimal"),
                  ("20 MB [F27]", 20 * 2**20, "binaria"),
                  ("25 MB [F5]", 25 * 10**6, "decimal"),
                  ("25 MB [F5]", 25 * 2**20, "binaria")]
    comp = []
    for etq, valor, unidad in PUBLICADAS:
        if alto_aceptado < valor <= bajo_rechazado:
            comp.append("%s en lectura %s, sobre el ADJUNTO" % (etq, unidad))
        if cod_a < valor <= cod_r:
            comp.append("%s en lectura %s, sobre el CUERPO de la peticion" % (etq, unidad))
    v["cifra_publicada_compatible"] = comp or ["ninguna de las dos cifras cae en el bracket, "
                                               "en ninguna de las dos unidades ni sobre "
                                               "ninguno de los dos ejes"]
    sobre_adj = any("ADJUNTO" in c for c in comp)
    sobre_cue = any("CUERPO" in c for c in comp)
    # Si no encaja ninguna cifra publicada, el eje no es "indistinguible": es que el techo
    # medido no es ninguno de los dos numeros que Brevo publica, y eso es otro hallazgo.
    v["eje_del_tope"] = ("ninguna_cifra_publicada_encaja" if not comp else
                         "adjunto_decodificado" if sobre_adj and not sobre_cue else
                         "cuerpo_de_la_peticion" if sobre_cue and not sobre_adj else
                         "indistinguible_con_este_bracket")

if entrega_aceptado:
    v["entrega_del_peldano_aceptado"] = entrega_aceptado["lectura"]
    if v["donde_muerde"] == "no_es_la_validacion":
        if entrega_aceptado["entregado"]:
            v["donde_muerde"] = "en_ninguna_parte_hasta_%s_MB" % mb(alto_aceptado)
            v["motivo"] += ". Y consta 'delivered': ni valida ni deja de entregar a ese tamano"
        elif entrega_aceptado["motivo_habla_de_tamano"]:
            v["donde_muerde"] = "despues_de_la_validacion"
            v["motivo"] += (". No consta entregado y el motivo habla de tamano: el tope muerde "
                            "despues de la validacion. Quien lo aplica lo dice el 'reason'")
        elif entrega_aceptado["eventos_vistos"]:
            v["motivo"] += (". No consta entregado, pero el motivo no habla de tamano: hay un "
                            "fallo de entrega por otra causa y DISC-16 no queda cerrada")

if entrega_control:
    v["control_de_entrega"] = entrega_control["lectura"]
elif control is not None:
    v["control_de_entrega"] = "el peldano de control no fue aceptado (HTTP %s)" % control.get("http")
else:
    v["control_de_entrega"] = ("no ejecutado. Solo hace falta si el peldano aceptado estaba "
                               "por encima de las cifras publicadas y no consta entregado")

libro = []
try: libro = [l.rstrip("\n") for l in open(os.environ["LIBROF"]) if not l.startswith("#")]
except Exception: pass

# Envios comprometidos, no "aceptados": un peldano dudoso se paga igual, porque el lado
# conservador es asumir que salio. Si esta cifra no cuadra con el libro, manda el libro.
def dudoso(t):
    return t is not None and t.get("http") is not None and not ok(t) and not rechazo_limpio(t)


comprometidos = (len(aceptados) + len(dudosos)
                 + (1 if ok(control) else 0) + (1 if dudoso(control) else 0))

esq = None
f = os.path.join(est, "req_esqueleto.json")
if os.path.exists(f):
    try: esq = json.load(open(f))
    except Exception: pass

doc = {
  "sondeo": "brevo-b2-tamano-validacion-o-entrega",
  "api": "brevo", "escalon": 3, "paquete": "B",
  "fecha_utc": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
  "preguntas": {"principal": "DISC-16 (20 MB [F27] o 25 MB [F5]) y donde muerde el tope",
                "hueco": "hueco 15 de fuentes.md: la documentacion de desarrollador no "
                         "publica ninguna cifra de tamano",
                "de_propina": "hueco 16: si los 4 MB por adjunto de la via de plantilla "
                              "alcanzan tambien a la via de API (peldanos de 5 y 3 MB)"},
  "complementa": ("probe_brevo_a_tamano.sh, que explora el mismo tope solo por el lado "
                  "rechazado y no puede decir nada de la entrega. Los cuatro peldanos altos "
                  "son sus mismos puntos: 19, 21, 24 y 26,5 MB"),
  "presupuesto": {
      "tope_de_la_pasada": int(os.environ["TOPE"]),
      "unidad": "destinatarios de una peticion aceptada",
      "coste_maximo_declarado_de_este_sondeo": int(os.environ["COSTE"]),
      "desglose": ("1 del primer peldano ACEPTADO de la escalera (los 4xx no cuestan) + 1 "
                   "del peldano de control, que esta CONDICIONADO al margen del libro y es "
                   "la fase declarada prescindible de la pasada. Un destinatario por "
                   "peticion. La cifra sale de la constante COSTE_MAXIMO_ESTE_SONDEO del "
                   "script, no escrita a mano aqui"),
      "envio_es": ("UN DESTINATARIO de una peticion ACEPTADA. Solo un 4xx explicito con cuerpo y sin error de "
                   "transporte libera la reserva: un 000, un 5xx o un cuerpo vacio no "
                   "demuestran rechazo -- la peticion pudo entrar y perderse la respuesta -- "
                   "y cuentan como comprometidos"),
      "envios_comprometidos": comprometidos,
      "peticiones_aceptadas": len(aceptados),
      "peticiones_rechazadas_sin_coste": len(rechazados),
      "peticiones_dudosas_que_cuentan_como_gasto": len(dudosos) + (1 if dudoso(control) else 0),
      "libro": libro,
  },
  "veredicto": v,
  "peldanos": peldanos,
  "control": control,
  "entrega": {"peldano_aceptado": entrega_aceptado, "control": entrega_control},
  "cuerpo_enviado_sin_direcciones_ni_adjunto": esq,
  "notas": [
      "Los cuerpos de respuesta se guardan ENTEROS (tope %d bytes) porque de ahi sale la "
      "cita literal; se lee el cuerpo, no el codigo HTTP." % CAP,
      "De cada peldano se guardan TRES cifras de tamano -- adjunto, base64 y cuerpo HTTP "
      "entero -- porque 'including the attachments and email content' no dice sobre que "
      "eje se mide y base64 infla un tercio.",
      "Un rechazo sin 'code' de Brevo en el cuerpo se marca como infraestructura: un tope "
      "de peticion en el borde no es el tope del correo.",
      "Redactado: clave de API y direcciones. Los messageId entre <...> se conservan a "
      "proposito, que son el enlace con el evento de entrega.",
  ],
}

doc = limpiar(doc)
with open(out, "w") as f:
    json.dump(doc, f, ensure_ascii=True, indent=1)
print(json.dumps({"veredicto": doc["veredicto"], "presupuesto": doc["presupuesto"]},
                 ensure_ascii=True, indent=1))
print("JSON: %s" % out)
PY
}

case "$FASE" in
  plan)      fase_plan ;;
  escalera)  fase_escalera ;;
  control)   fase_control ;;
  eventos)   fase_eventos ;;
  veredicto) fase_veredicto ;;
  reiniciar) rm -rf "$ESTADO"; echo "Estado de trabajo borrado. El libro de cuentas NO se"
             echo "toca: $LIBRO (un tope que se borra no es un tope)." ;;
esac
