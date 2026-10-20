#!/usr/bin/env bash
# Sondeo empirico Brevo (escalon 3) - PAQUETE A, CERO ENVIOS - preparado el 2026-09-17
#
# PREGUNTA QUE RESUELVE
#   DISC-03: la guia de lotes dice "Send up to 1000 email messages in one API call" [F13]
#   y la referencia dice "Maximum total recipients per API request is 2000. Maximum
#   recipients per message version is 99." [F10]. Mil versiones a 99 serian 99.000, no
#   2.000. Afecta directamente a workload[].max, que hoy vale 2000 en AMBAR en los cinco
#   planes.
#   DISC-04: el centro de ayuda dice "If you add an attachment in your API script, you can
#   only send your transactional email to a maximum of 99 recipients." [F27] sin
#   condicionarlo al modo; la referencia da 2.000 por peticion y no menciona adjuntos.
#   Se resuelve con el 2x2: 99 y 100 destinatarios, con adjunto y sin adjunto.
#
# COMO SE MIDE SIN QUE SALGA UN SOLO CORREO
#   La invariante del paquete A es que ninguna peticion de envio puede ser ACEPTADA: si
#   una peticion fuese aceptada, no se hace. Por eso TODAS llevan una GUARDA -- un defecto
#   que Brevo tiene que rechazar -- y el tope se lee en QUE error vuelve:
#     - control (guarda sola, 1 destinatario)          -> mensaje de la guarda
#     - caso de tope (guarda + carga por encima)       -> mensaje del tope, si el tope se
#                                                         valida antes que la guarda
#   Brevo devuelve UN solo {code,message}, asi que la precedencia importa: la MIDE
#   probe_brevo_a_preflight_rechazo.sh y este script LEE la guarda de su JSON. Si ese JSON
#   no existe, aborta: elegir la guarda a ciegas es gastar 13 peticiones sin medir nada.
#
#   Y EL CONTROL ES LA VARA DE MEDIR. Si d00_control_to_1 no deja un {code,message} de
#   Brevo con un 4xx -- red caida, cuerpo no JSON, 429 -- entonces "distinto del control"
#   es cierto para todos los casos y el cuadro leeria tope en todas las celdas. En ese caso
#   el resumen sale NO CONCLUYENTE entero y lo dice, en vez de dar cifras envenenadas.
#
#   LO QUE ESTE DISENO PUEDE Y NO PUEDE CONCLUIR. Solo se explora el lado RECHAZADO. Del
#   par (99, 100), un mensaje de tope en el 100 demuestra "el tope es COMO MAXIMO 99"; NO
#   demuestra que sea exactamente 99, porque el 99 tambien se rechazo -- por la guarda. El
#   lado aceptado no se prueba en este paquete, y asi se escribe en la datasheet.
#
# COSTE EN ENVIOS: 0 ENTREGADOS. Presupuesto: 13 peticiones a POST /v3/smtp/email, todas
#   con guarda. Un 2xx aborta el script en el acto, anota el envio en el libro compartido y
#   pone la PARADA del paquete, para que los sondeos de detras no repitan la jugada.
#   CONSUMO DE CUOTA EN SANDBOX: **NO MEDIDO**. La version anterior de esta cabecera afirmaba
#   "sendLimit se descuenta al entregar, no al validar", y eso es exactamente la pregunta
#   abierta que mide probe_brevo_b_unidad_cuota.sh -- afirmarla aqui era darla por cerrada sin
#   medirla, y ademas contradecia a probe_brevo_a_caudal_cabeceras.sh, que dice lo contrario.
#   Lo que este sondeo SI sostiene es mas estrecho y no necesita medicion: ninguna de sus
#   13 peticiones puede ser ACEPTADA, asi que ninguna llega a entregar.
#   Caudal: 13 del bucket de la fila compartida del envio, 1.000 RPS / 3.600.000 RPH en el
#   tramo General [F6]. Trafico de subida: ~350 KB en total. Duracion: ~40 s.
#
# DESTINATARIOS (D-046)
#   Lista blanca literal, sin variantes:  persona-3@example.invalid
#                                         persona-1@example.invalid
#                                         persona-2@example.invalid
#   Este script NO usa ninguna de las tres. Los 2.001 destinatarios del caso mas grande
#   van todos a @example.invalid, dominio sin MX, que D-046 declara verde y via preferente.
#   verificar_destinatarios() recorre to/cc/bcc y messageVersions[].to de CADA cuerpo antes
#   de la llamada y aborta si aparece una direccion de la lista blanca o cualquier otro
#   dominio. La garantia es esta comprobacion, no el modo de la cuenta.
#
# USO
#   bash probe_brevo_a_destinatarios.sh
#   BREVO_GUARDA=sender_ausente bash probe_brevo_a_destinatarios.sh
#   Guardas admitidas: sender_sumidero | sender_ausente. Las dos llevan UN solo defecto.
#   'contenido_ausente' se quito el 2026-09-17: quitaba el contenido pero MANTENIA el
#   remitente del sumidero, asi que llevaba dos defectos y el mensaje que devolvia la API
#   era la precedencia entre ellos, no el de la guarda -- y ese mensaje es la vara con la
#   que se lee el tope. Dejarlo en un solo defecto exigiria el remitente verificado, que es
#   una peticion que Brevo PUEDE aceptar.
#   SIN BREVO_GUARDA, la guarda se LEE del JSON mas reciente de
#   probe_brevo_a_preflight_rechazo.sh, que es el sondeo que mide la precedencia. Antes habia
#   un valor por defecto a ciegas: eso elegia la guarda sin saber si el preflight la habia
#   validado, y una guarda que se valida antes que el tope hace que el par no vea nada. Si no
#   hay JSON del preflight, este script ABORTA y dice que hay que correrlo primero.
#   Lee BREVO_API_KEY de ~/.config/tfm/.env.
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
# El libro de cuentas y la PARADA son los del paquete entero, no de este script: el tope de
# la pasada tiene que ver tambien lo que gaste el paquete A si una guarda no se sostiene. La
# clave, fuera del argv de curl. Y brevo_limpia_funciones desarma las funciones con nombre
# de orden externa que llegasen exportadas desde el shell que lanza el sondeo -- del .env ya
# no puede venir ninguna.
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
: "${BREVO_API_KEY:?}"
brevo_clave_valida "$BREVO_API_KEY" || {
  echo "ABORTA: BREVO_API_KEY tiene caracteres fuera de [A-Za-z0-9_.:-]." >&2; exit 3; }

parada_comprobar
# El libro tiene que poder ESCRIBIR, y se comprueba antes de la primera llamada. Con el
# libro presente pero no escribible -- 400, disco lleno, sistema de ficheros en solo lectura
# -- el append fallaba con un "Permiso denegado" que nadie miraba, reservar() devolvia 0 y
# el contador volvia a leer 0: cada llamada creia tener el tope entero libre.
libro_exige_escritura

readonly BASE="https://api.brevo.com/v3"
readonly SUMIDERO="example.invalid"
. "$AQUI/lib_guarda_preflight_brevo.sh"
GUARDA="$(guarda_elegida)" || exit 2
# readonly aparte y no en la misma linea: en "readonly V=$(cmd)" el estado de salida
# es el de readonly, no el del comando, asi que el "|| exit 2" no dispararia.
readonly GUARDA
D="$(mktemp -d "${TMPDIR:-/tmp}/brevo_a_dest_XXXXXX")" || { echo "ABORTA: no se pudo crear el directorio de trabajo." >&2; exit 3; }
[[ -d $D && -w $D ]] || { echo "ABORTA: el directorio de trabajo '$D' no existe o no acepta escrituras." >&2; exit 3; }
# El JSON va a 03_datos/apis/brevo/evidencias/ si esa carpeta existe, igual que hacen los
# dos sondeos del paquete B. Antes caia junto al script y la ultima linea imprimia una ruta a
# evidencias/ a la que nadie lo llevaba: quien seguia esa linea y movia el fichero dejaba a
# probe_brevo_a_destinatarios.sh y probe_brevo_a_tamano.sh abortando por falta de preflight,
# porque guarda_elegida lo buscaba solo junto al script.
SAL="$AQUI"
[ -d "$AQUI/../../03_datos/apis/brevo/evidencias" ] &&
  SAL="$(CDPATH='' cd -- "$AQUI/../../03_datos/apis/brevo/evidencias" && pwd)"
OUT="$SAL/probe_brevo_a_destinatarios_$(date -u +%Y-%m-%d_%H%M%S).json"
ORDEN=""
ABORTO=""

CASOS="d00_control_to_1 d01_to_99 d02_to_100 d03_to_2000 d04_to_2001 d05_mv_1v_99 d06_mv_1v_100 d07_mv_20v_99 d08_mv_21v_99 d09_mv_1000v_1 d10_mv_1001v_1 d11_adj_to_99 d12_adj_to_100"
OMITIDOS=""
CONTROL_OK=0

# --- Cuantos destinatarios lleva cada caso ---------------------------------------------
# El libro cuenta en DESTINATARIOS desde el 2026-09-17, no en peticiones: si una peticion de
# 2.000 destinatarios fuese aceptada, el gasto es 2.000. Asi que hace falta saber la cifra
# ANTES de construir el cuerpo, para reservarla y para decidir si el caso cabe siquiera.
# construir() y esta tabla tienen que decir lo mismo, y verificar_destinatarios() lo
# comprueba contando el cuerpo ya escrito: una tabla desincronizada del constructor seria la
# misma clase de error que se esta corrigiendo.
dest_de () {  # $1 caso -> destinatarios, o 0 si el caso no esta en la tabla
  case "$1" in
    d00_control_to_1)                        echo 1 ;;
    d01_to_99|d05_mv_1v_99|d11_adj_to_99)    echo 99 ;;
    d02_to_100|d06_mv_1v_100|d12_adj_to_100) echo 100 ;;
    d03_to_2000)                             echo 2000 ;;
    d04_to_2001)                             echo 2001 ;;
    d07_mv_20v_99)                           echo 1980 ;;   # 20 versiones x 99
    d08_mv_21v_99)                           echo 2079 ;;   # 21 versiones x 99
    d09_mv_1000v_1)                          echo 1000 ;;
    d10_mv_1001v_1)                          echo 1001 ;;
    *)                                       echo 0 ;;
  esac
}

echo "== PRESUPUESTO DECLARADO (D-046 condicion 2) =="
echo "   Envios ENTREGADOS ...................... 0  (invariante del paquete A; un 2xx"
echo "                                              aborta, se anota en el libro y pone"
echo "                                              la PARADA del paquete)"
echo "   Unidad del libro ....................... el DESTINATARIO, no la peticion. Cada"
echo "                                              caso RESERVA sus destinatarios antes"
echo "                                              de llamar y los LIBERA con el 4xx"
echo "   Consumo de cuota en sandbox ............ NO MEDIDO -- lo mide el paquete B,"
echo "                                              probe_brevo_b_unidad_cuota.sh"
echo "   Comprometidos en la ventana ............ $(libro_comprometido) de $(libro_tope_efectivo)   (la pasada son 24 horas)"
echo "   Peticiones a POST /v3/smtp/email ....... $(echo "$CASOS" | wc -w)  (todas con guarda; un 2xx aborta)"
echo "   Guarda en uso .......................... $GUARDA"
echo "   Destinatarios .......................... solo @$SUMIDERO; lista blanca NO usada"
echo "   Pausa entre llamadas ................... 2 s"
echo

resumir() {
  if [ -f "$D/.resumido" ]; then return 0; fi
  : > "$D/.resumido"
  CLAVE="${BREVO_API_KEY:-}" CLAVE2="${BREVO_API_KEY_2:-}" \
  FROM="${BREVO_FROM:-}" TO="${BREVO_TO:-}" SUMIDERO="$SUMIDERO" \
  GUARDA_VALIDADA="$(guarda_validada_por_el_preflight)" \
  python3 -I - "$D" "$OUT" "$ORDEN" "$ABORTO" "$GUARDA" "$OMITIDOS" <<'PY'
import sys,json,os,re as _re
d,out,orden,aborto,guarda=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5]
omitidos=[x for x in sys.argv[6].split(",") if x]
def cab(p):
    h={}
    if not os.path.exists(p): return h
    for l in open(p,errors="replace"):
        if ":" in l and not l.upper().startswith("HTTP/"):
            k,v=l.split(":",1); h[k.strip().lower()]=v.strip()
    return h
casos=[]
for c in [x for x in orden.split(",") if x]:
    if not os.path.exists(d+"/"+c+".code"): continue
    crudo=open(d+"/"+c+".body",errors="replace").read()
    try: cuerpo=json.loads(crudo)
    except Exception: cuerpo=None
    h=cab(d+"/"+c+".hdr")
    m=(open(d+"/"+c+".meta").read().rstrip("\n").split("\t")+[""]*6)[:6]
    casos.append({"caso":c,"metodo":m[0],"ruta":m[1],"descripcion":m[2],
      "inicio_utc":m[3],"fin_utc":m[4],"bytes_peticion":int(m[5] or 0),
      "http":int(open(d+"/"+c+".code").read().strip() or 0),
      "error_code":cuerpo.get("code") if isinstance(cuerpo,dict) else None,
      "error_message":cuerpo.get("message") if isinstance(cuerpo,dict) else None,
      # El CUERPO ENTERO del error: de aqui sale la cita literal para fuentes.md (regla 7).
      "cuerpo_crudo":crudo,
      "cabeceras_caudal":{k:v for k,v in h.items() if k.startswith("x-sib-ratelimit")}})
por={c["caso"]:c for c in casos}
ctrl=por.get("d00_control_to_1")
msg_guarda=(ctrl or {}).get("error_message")
# El control es la vara de medir: "esto es un mensaje de tope" significa "distinto del
# mensaje del control". Si el control NO dejo mensaje -- HTTP 000 por red, cuerpo no JSON,
# 429 -- entonces msg_guarda es None y TODOS los casos con mensaje salen distintos de None,
# es decir TODOS leen como tope y el cuadro entero queda envenenado sin que nada avise. Con
# la vara ausente no se mide: es_tope devuelve None para todo y el resumen lo dice.
control_util = bool(msg_guarda) and isinstance((ctrl or {}).get("http"), int) \
    and 400 <= ctrl["http"] < 500
def es_tope(c):
    if not control_util: return None
    x=por.get(c)
    if not x: return None
    return x.get("error_message")!=msg_guarda
def cita(c):
    x=por.get(c) or {}
    return {"http":x.get("http"),"code":x.get("error_code"),"message":x.get("error_message")}
PARES=[("99 destinatarios en 'to' plano (DISC-04 sin adjunto)","d01_to_99","d02_to_100",99),
       ("2.000 destinatarios totales en 'to' plano (DISC-03)","d03_to_2000","d04_to_2001",2000),
       ("99 destinatarios por version (DISC-03)","d05_mv_1v_99","d06_mv_1v_100",99),
       ("2.000 totales repartidos en versiones (DISC-03)","d07_mv_20v_99","d08_mv_21v_99",2078),
       ("1.000 versiones por llamada (DISC-03, [F13])","d09_mv_1000v_1","d10_mv_1001v_1",1000),
       ("99 destinatarios CON adjunto (DISC-04)","d11_adj_to_99","d12_adj_to_100",99)]
pares=[]
for nom,lo,hi,tope in PARES:
    tlo,thi=es_tope(lo),es_tope(hi)
    if lo in omitidos or hi in omitidos:
        v=("no medible: el caso no cabe en el tope de la pasada. El libro cuenta en "
           "DESTINATARIOS, y una peticion de este par pide mas de los que quedan, asi que "
           "no se mando. La pregunta vuelve sin responder y el valor se queda en AMBAR")
    elif tlo is None or thi is None:
        v="no medible: falta uno de los dos casos del par"
    elif thi and not tlo:
        v=("acotado por arriba: el tope es COMO MAXIMO %d. El caso alto trae mensaje de "
           "tope y el bajo trae el de la guarda. El lado aceptado NO se ha probado, asi "
           "que no se afirma que el tope sea exactamente %d"%(tope,tope))
    elif thi and tlo:
        v=("el tope esta por DEBAJO del caso bajo: los dos traen mensaje de tope. Hay que "
           "repetir el par con valores menores")
    elif not thi and not tlo:
        v=("no se ve el tope con esta guarda: los dos casos traen el mensaje de la guarda. "
           "No demuestra que no haya tope, demuestra que la guarda se valida antes")
    else:
        v=("incoherente: el caso bajo trae mensaje de tope y el alto no. Repetir; puede ser "
           "ruido (429, duplicate_request) -- mirar http y code de los dos")
    pares.append({"par":nom,"caso_bajo":lo,"caso_alto":hi,
      "cita_bajo":cita(lo),"cita_alto":cita(hi),"veredicto":v})
# DISC-04: el 2x2 completo. La celda que decide es la de 100 destinatarios, no la de 99:
# [F27] pone el tope en 99 con adjunto y [F10] en 2.000 por peticion, asi que a 100 las dos
# fuentes dicen cosas distintas y a 99 las dos dicen que pasa. Las celdas de 99 son el
# control: si alguna salta, el par esta mal acotado y hay que bajarlo.
c2x2={"sin_adjunto_99":cita("d01_to_99"),"sin_adjunto_100":cita("d02_to_100"),
      "con_adjunto_99":cita("d11_adj_to_99"),"con_adjunto_100":cita("d12_adj_to_100")}
t99s,t99a=es_tope("d01_to_99"),es_tope("d11_adj_to_99")
t100s,t100a=es_tope("d02_to_100"),es_tope("d12_adj_to_100")
if None in (t99s,t99a,t100s,t100a):
    v04="no medible: falta alguna celda del 2x2"
elif t100a and not t100s:
    v04=("el adjunto SI baja el tope: 100 destinatarios CON adjunto traen mensaje de tope y "
         "100 SIN adjunto no. Respalda [F27] y deja el tope con adjunto en COMO MAXIMO 99")
elif t100a and t100s:
    v04=("el tope de 100 salta con y sin adjunto: el 99 no es una condicion del adjunto, "
         "asi que [F27] describe un tope que rige siempre y los 2.000 por peticion de [F10] "
         "no se sostienen para 'to' plano. DISC-04 se cierra, y DISC-03 se agrava")
elif not t100a and not t100s:
    v04=("ninguna de las dos celdas de 100 cambia el mensaje: por esta via no se distingue "
         "[F27] de [F10]. DISC-04 se queda abierta y el valor en ambar")
else:
    v04=("incoherente: salta la celda sin adjunto y no la de con adjunto. Repetir; mirar "
         "http y code de las cuatro celdas")
if t99s or t99a:
    v04+=(" | AVISO: una celda de control (99 destinatarios) tambien trae mensaje de tope, "
          "asi que el par esta mal acotado: repetir con 49/50 antes de concluir nada")
aceptadas=[c["caso"] for c in casos if 200<=c["http"]<300]
# --- EL COSTE SE CALCULA, NO SE DECLARA -------------------------------------------------
# Hasta el 2026-09-17 este resumen declaraba el coste con un cero escrito a mano,
# asi que habria
# dicho 0 aunque todas las peticiones hubieran vuelto con 201. Le paso al preflight ese
# mismo dia: declaro cero envios en el mismo objeto en el que declaraba la invariante ROTA
# y una peticion aceptada, y el libro de cuentas anotaba GASTO de 1. La unidad es la del
# libro: el DESTINATARIO de una peticion aceptada. Una lectura (GET) no lleva ninguno.
def _dest_de_req(p):
    if not os.path.exists(p): return 0
    try: b=json.load(open(p))
    except Exception: return 0
    n=[0]
    def rec(o):
        if not isinstance(o,dict): return
        for k in ("to","cc","bcc"):
            v=o.get(k) or []
            if isinstance(v,list): n[0]+=len(v)
        for v in (o.get("messageVersions") or []): rec(v)
    rec(b)
    return n[0]
envios_calculados=sum(_dest_de_req(d+"/"+c["caso"]+".req")
                      for c in casos if 200<=int(c.get("http") or 0)<300)
resumen={"api":"brevo","paquete":"A (cero envios)","sondeo":"destinatarios",
  "fecha_utc":casos[0]["inicio_utc"] if casos else None,
  "guarda_en_uso":guarda,"mensaje_de_la_guarda":msg_guarda,
  # Si la guarda se forzo con BREVO_GUARDA, el preflight NO la respalda y el dato medido no
  # se puede citar como si lo hiciera.
  "guarda_validada_por_el_preflight":(os.environ.get("GUARDA_VALIDADA")=="si"),
  "control_utilizable":control_util,
  "aviso_del_control":(None if control_util else
    ("EL CONTROL NO SIRVE DE VARA: d00_control_to_1 no dejo un {code,message} de Brevo con "
     "un 4xx (http=%s, message=%r). Sin mensaje de control, 'es distinto del control' seria "
     "cierto para todos los casos y el cuadro leeria tope en todas las celdas. Todo lo de "
     "abajo sale NO CONCLUYENTE a proposito: repetir el sondeo con el control sano."
     % ((ctrl or {}).get("http"), msg_guarda))),
  "envios_reales":envios_calculados,
  "unidad_de_envios_reales":("destinatarios de las peticiones ACEPTADAS (2xx), que es la "
    "unidad con la que el libro de cuentas reserva y gasta. Calculado, no declarado"),
  "peticiones":len(casos),
  "casos_omitidos_por_presupuesto":omitidos,
  "peticiones_de_envio_aceptadas_2xx":aceptadas,
  "invariante_cero_envios":"CUMPLIDA" if not aceptadas else "ROTA",
  "abortado_en":aborto or None,
  "http_por_caso":{c["caso"]:c["http"] for c in casos},
  "error_por_caso":{c["caso"]:[c.get("error_code"),c.get("error_message")] for c in casos},
  "pares":pares,"cuadro_2x2_DISC_04":c2x2,"veredicto_DISC_04":v04,
  "lo_que_esto_NO_demuestra":("Todo lo medido es del lado RECHAZADO: 'el tope es como "
    "maximo N'. Confirmar que N se acepta exige una peticion que Brevo acepte, y eso es "
    "un envio: paquete B, presupuesto declarado y destinatario de la lista blanca. "
    "Mientras tanto workload[].max se queda en AMBAR aunque el par acote por arriba.")}
# Los secretos se redactan EN MEMORIA, antes de escribir el fichero. La version anterior
# lo hacia con un `sed -i` posterior, y eso tenia tres agujeros: la clave viajaba en el
# argv de sed (legible con un `ps`), el `2>/dev/null` se comia el fallo de la redaccion en
# silencio, y entre el volcado y el sed habia un instante con el JSON sin redactar escrito
# dentro del repo -- un instante que un SIGKILL convierte en permanente, porque el sed
# corria dentro del `trap EXIT`.
# Tres capas, y la tercera es nueva del 2026-09-17.
#   1. La clave, POR PATRON. Antes se redactaba por valor exacto, lo que obligaba a pasar la
#      credencial en el entorno de este python solo para poder borrarla. Con el patron ya no
#      hace falta que entre en el proceso.
#   2. El remitente y el BREVO_TO del .env, por valor, con su etiqueta.
#   3. CUALQUIER OTRA DIRECCION SUELTA. Esta faltaba, y el paquete A guarda 'cuerpo_crudo'
#      de todos los casos sin condicion: GET /v3/account trae la identidad del titular, y
#      /contacts, /smtp/blockedContacts y /smtp/emails traen direcciones de TERCEROS. El JSON
#      se copia a 03_datos/apis/brevo/evidencias/ y el .gitignore no excluye esa ruta, asi
#      que entraria en un commit -- irreversible -- contra la clausula "nunca PII en logs ni
#      en ejemplos" de CLAUDE.md. Se exceptuan las del sumidero sintetico, que las escribe
#      este sondeo y son justo lo que hay que poder leer en la evidencia.
#   Los messageId de Brevo tienen forma de direccion (<id@relay>) y son el enlace con el
#   evento de entrega, asi que se APARCAN con un centinela antes de redactar y se devuelven
#   al final; solo se aparca el token que no lleve dentro ninguna direccion conocida.
# El patron cubre las dos formas que Brevo emite, y la lista de VALORES exactos de abajo
# cubre cualquier otra: redactar solo por patron dejaria pasar una credencial de formato
# distinto -- una clave SMTP, un formato nuevo -- y este JSON se copia a evidencias/ y entra
# en un commit, que es irreversible. Las dos capas cuestan lo mismo.
_CLAVE_PAT = _re.compile(r"x(?:keysib|smtpsib)-[A-Za-z0-9._:-]{8,}")
_MENSAJE_ID = _re.compile(r"<[^<>@\s]+@[^<>\s]+>")
_SUELTA = _re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
_SUMI = (os.environ.get("SUMIDERO") or "").strip().lower()


def _redactado(t):
    t = _CLAVE_PAT.sub("<CLAVE_REDACTADA>", t)
    _conocidas = [v.lower() for v in (os.environ.get("FROM") or "",
                                      os.environ.get("TO") or "") if v]
    _aparcados = []

    def _aparcar(m):
        tok = m.group(0)
        if any(c in tok.lower() for c in _conocidas):
            return tok
        _aparcados.append(tok)
        return "\x01%d\x01" % (len(_aparcados) - 1)

    t = _MENSAJE_ID.sub(_aparcar, t)
    for _v, _e in (("CLAVE", "<CLAVE_REDACTADA>"), ("CLAVE2", "<CLAVE_2_REDACTADA>"),
                   ("FROM", "<FROM_REDACTADO>"), ("TO", "<TO_REDACTADO>")):
        _x = os.environ.get(_v) or ""
        if _x:
            t = t.replace(_x, _e)

    def _suelta(m):
        d = m.group(0)
        if _SUMI and d.lower().endswith("@" + _SUMI):
            return d                      # sonda-00001@example.invalid: sintetica, se deja
        return "<REDACTADO>"

    t = _SUELTA.sub(_suelta, t)
    for _i, _tok in enumerate(_aparcados):
        t = t.replace("\x01%d\x01" % _i, _tok)
    return t


open(out, "w").write(_redactado(json.dumps({"resumen": resumen, "casos": casos},
                                           ensure_ascii=True, indent=1)))
print(_redactado(json.dumps(resumen, ensure_ascii=True, indent=1)))
PY
  echo
  echo "JSON: $OUT"
  echo "   (03_datos/apis/brevo/evidencias/ si existe; si no, junto al script)"
  rm -rf "$D"
}
trap resumir EXIT

construir() {
  python3 -I - "$1" "$D/$1.req" "$SUMIDERO" "$GUARDA" <<'PY'
import json,sys,time,base64
caso,out,sumi,guarda=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4]
nonce=str(time.time_ns())   # evita 'duplicate_request' [F9] sin usar idempotencyKey [F15]
def tos(n,off=0):
    return [{"email":"sonda-%06d@%s"%(i+off,sumi)} for i in range(1,n+1)]
def base_cuerpo():
    # Cada guarda, UN solo defecto. El contenido va SIEMPRE: el modo 'contenido_ausente'
    # se quito porque quitaba el contenido y ademas dejaba el remitente del sumidero, asi
    # que llevaba dos defectos y el mensaje que devolvia la API era la precedencia entre
    # ellos, no la de la guarda -- y ese mensaje es justo la vara con la que se lee el tope.
    b={"subject":"TFM sonda %s %s"%(caso,nonce),
       "htmlContent":"<html><body><p>sonda TFM paquete A, cero envios</p></body></html>"}
    if guarda!="sender_ausente":
        b["sender"]={"name":"TFM sonda","email":"sonda-remitente@%s"%sumi}
    return b
ADJ=[{"content":base64.b64encode(b"sonda TFM paquete A\n"*50).decode(),"name":"sonda.txt"}]
b=base_cuerpo()
if   caso=="d00_control_to_1":  b["to"]=tos(1)
elif caso=="d01_to_99":         b["to"]=tos(99)
elif caso=="d02_to_100":        b["to"]=tos(100)
elif caso=="d03_to_2000":       b["to"]=tos(2000)
elif caso=="d04_to_2001":       b["to"]=tos(2001)
elif caso=="d05_mv_1v_99":      b["messageVersions"]=[{"to":tos(99)}]
elif caso=="d06_mv_1v_100":     b["messageVersions"]=[{"to":tos(100)}]
elif caso=="d07_mv_20v_99":     b["messageVersions"]=[{"to":tos(99,off=v*100)} for v in range(20)]
elif caso=="d08_mv_21v_99":     b["messageVersions"]=[{"to":tos(99,off=v*100)} for v in range(21)]
elif caso=="d09_mv_1000v_1":    b["messageVersions"]=[{"to":tos(1,off=v)} for v in range(1000)]
elif caso=="d10_mv_1001v_1":    b["messageVersions"]=[{"to":tos(1,off=v)} for v in range(1001)]
elif caso=="d11_adj_to_99":     b["to"]=tos(99);  b["attachment"]=ADJ
elif caso=="d12_adj_to_100":    b["to"]=tos(100); b["attachment"]=ADJ
else: sys.exit("ABORTA: caso desconocido "+caso)
# [F13]: "Do not pass an outer to parameter" cuando se usan messageVersions. Los dos modos
# son excluyentes (F-25), asi que ningun caso lleva los dos a la vez.
if "messageVersions" in b and "to" in b: sys.exit("ABORTA: to y messageVersions a la vez")
json.dump(b,open(out,"w"))
PY
}

verificar_destinatarios() {  # $1 caso  $2 destinatarios esperados
  python3 -I - "$D/$1.req" "$SUMIDERO" "$2" <<'PY'
import json,sys
req,sumi,esperados=sys.argv[1],sys.argv[2],int(sys.argv[3])
# Lista blanca literal de D-046. El paquete A no entrega a ninguna de las tres.
BLANCA={"persona-3@example.invalid","persona-1@example.invalid","persona-2@example.invalid"}
d=json.load(open(req)); dest=[]
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
    for k in ("to","cc","bcc"):
        for e in (o.get(k) or []): dest.append((e or {}).get("email",""))
    r = o.get("replyTo")
    if isinstance(r, dict) and r.get("email"): dest.append(r.get("email"))
    for v in (o.get("messageVersions") or []): rec(v, "una messageVersion", CLAVES_VERSION)
rec(d)
if not dest: sys.exit("ABORTA: la peticion no lleva destinatarios")
for e in dest:
    l=(e or "").strip().lower()
    if l in BLANCA:
        sys.exit("ABORTA: %s esta en la lista blanca de D-046. El paquete A es de CERO "
                 "ENVIOS y no entrega a buzones reales; eso es el paquete B."%l)
    if l.count("@")!=1 or not l.endswith("@"+sumi):
        sys.exit("ABORTA: destinatario fuera del sumidero sin MX (@%s): %s"%(sumi,l))
# El cuerpo tiene que llevar EXACTAMENTE lo que la tabla dest_de dijo, que es lo que el
# libro va a reservar. Una tabla desincronizada de construir() gastaria mas de lo
# comprometido, que es la causa 3 en pequeno.
if len(dest)!=esperados:
    sys.exit("ABORTA: el cuerpo lleva %d destinatarios y la tabla dest_de dice %d. El libro "
             "reservaria menos de lo que se gasta."%(len(dest),esperados))
print("   destinatarios comprobados: %d, todos en @%s"%(len(dest),sumi))
PY
}

llamar_envio() {
  caso="$1"; desc="$2"; ndest="${3:-1}"
  t0="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
  code="$(curl_brevo "$BREVO_API_KEY" -sS --max-time 90 -o "$D/$caso.body" -D "$D/$caso.hdr" -w '%{http_code}' \
    -H "accept: application/json" -H "content-type: application/json" \
    -H "X-Sib-Sandbox: drop" \
    -X POST "$BASE/smtp/email" --data-binary @"$D/$caso.req")" || code="000"
  t1="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
  echo "$code" > "$D/$caso.code"
  printf 'POST\t/v3/smtp/email\t%s\t%s\t%s\t%s\n' "$desc" "$t0" "$t1" "$(wc -c < "$D/$caso.req")" > "$D/$caso.meta"
  ORDEN="$ORDEN$caso,"
  printf '   HTTP %s  %s\n' "$code" "$(head -c 240 "$D/$caso.body" | tr -d '\n')"
  # El resultado se lee de DOS formas, no de tres: 4xx explicito = rechazo demostrado y el
  # sondeo sigue; cualquier otra cosa -- 000 de curl, 5xx, cuerpo vacio, timeout -- es "no se
  # sabe", y no saberlo se paga. Antes solo el 2xx contaba ('case "$code" in 2*)'), asi que un
  # 000 no anotaba nada, no ponia la PARADA y el bucle escalaba al caso siguiente. La regla
  # entera vive en paquete_a_cerrar(), en lib_presupuesto_brevo.sh.
  paquete_a_cerrar "$caso" "$code" "$ndest" || { RC=$?; ABORTO="$caso"; exit "$RC"; }
}

# --- La puerta del presupuesto, ANTES de la primera llamada ----------------------------
# Todos los pares de este sondeo se acotan con casos de 99 destinatarios o mas, y el tope de
# esta pasada son 3: la cifra es de la pasada y vive en lib_presupuesto_brevo.sh. D-046 exige
# presupuesto declarado (condicion 2) y no fija ningun numero. Con la unidad corregida -- un envio = un destinatario -- ninguno
# de esos casos cabe, y la regla 6 del encargo dice que un caso suelto no demuestra nada: el
# caso de control, solo, no mide ningun tope. Asi que el sondeo NO hace ni una llamada.
# Es "medir menos que medir mal": la peticion de 99 destinatarios no se puede mandar con un
# margen de 3 sin que un 2xx inesperado gaste 33 veces el tope de la pasada.
MINIMO_DEL_PAR="$(dest_de d01_to_99)"
if ! libro_cabe "$MINIMO_DEL_PAR"; then
  echo "== NO EJECUTABLE CON ESTE PRESUPUESTO =="
  echo "   El par mas barato de este sondeo es 99 frente a 100 destinatarios, y el margen"
  echo "   de hoy son $(libro_margen) destinatario(s) de un tope de $(libro_tope_efectivo)."
  echo "   Un caso de $MINIMO_DEL_PAR destinatarios no cabe, y sin el par no hay bisercion"
  echo "   (regla 6: un caso suelto no demuestra nada). No se hace NINGUNA llamada."
  echo
  echo "   DISC-03 y DISC-04 se quedan SIN MEDIR por esta via, con el valor en AMBAR, y la"
  echo "   pregunta vuelve en la salida: 'la lista blanca de D-046 tiene tres direcciones y"
  echo "   el tope tres envios, asi que un tope de 99 o de 2.000 destinatarios no se puede"
  echo "   acotar con este presupuesto'. Ya estaba anticipado en REVISION.md, escalon 3,"
  echo "   punto 4 del bloque de envio real."
  echo
  echo "   Lo que haria falta para medirlo, y es decision del autor, no del sondeo: un tope de"
  echo "   pasada expresado en destinatarios y bastante mayor que 2.001, sabiendo que un 2xx"
  echo "   inesperado gastaria esa cifra de golpe."
  exit 4
fi

for C in $CASOS; do
  NDEST="$(dest_de "$C")"
  if [ "$NDEST" = "0" ]; then
    echo "!!! ABORTA: el caso '$C' no esta en la tabla dest_de: no se sabe cuanto reservar." >&2
    exit 2
  fi
  # La escalada tiene puerta: ningun caso por encima de un destinatario se construye hasta
  # que el control haya devuelto un 4xx EXPLICITO con {code,message}. Es la misma condicion
  # que el resumen llama 'control_utilizable', consultada AQUI y no al final: antes se
  # calculaba con los doce casos de detras ya mandados.
  if [ "$NDEST" -gt 1 ] && [ "$CONTROL_OK" != "1" ]; then
    echo "!!! ABORTA: el control no ha demostrado un 4xx explicito, asi que '$C' no se" >&2
    echo "!!! construye. Sin vara de medir, 'distinto del control' es cierto para todo y" >&2
    echo "!!! el cuadro saldria envenenado." >&2
    ABORTO="$C"
    exit 7
  fi
  if ! libro_cabe "$NDEST"; then
    echo "-- $C  OMITIDO: $NDEST destinatarios no caben en el margen de hoy ($(libro_margen))"
    OMITIDOS="$OMITIDOS$C,"
    continue
  fi
  echo "-- $C  ($NDEST destinatarios)"
  construir "$C" || exit 2
  verificar_destinatarios "$C" "$NDEST" || exit 2
  reservar "$C" "$NDEST"
  llamar_envio "$C" "caso $C con guarda $GUARDA" "$NDEST"
  # El control va primero a proposito: es la unica peticion que puede decir, barata, que el
  # resto de la escalera no va a medir nada.
  if [ "$C" = "d00_control_to_1" ]; then
    if MOT="$(control_inutil "$D/$C.body")"; then
      echo "!!! ABORTA tras el control, antes de gastar las otras 12 peticiones:" >&2
      echo "!!!   $MOT" >&2
      echo "!!! DISC-03 y DISC-04 se quedan SIN MEDIR por esta via y la pregunta vuelve en" >&2
      echo "!!! la salida. El cuerpo del control esta guardado y es la cita literal." >&2
      ABORTO="$C"
      exit 3
    fi
    if control_valido "$D/$C.body" "$(cat "$D/$C.code" 2>/dev/null)"; then
      CONTROL_OK=1
      echo "   control valido: 4xx explicito con {code,message}. La vara existe."
    else
      echo "!!! ABORTA: el control devolvio HTTP $(cat "$D/$C.code" 2>/dev/null) sin un 4xx" >&2
      echo "!!! explicito y un {code,message} legibles. Sin vara de medir no se escala:" >&2
      echo "!!! 'distinto del control' seria cierto para todos los casos y el cuadro entero" >&2
      echo "!!! saldria envenenado. Los 12 casos de detras NO se construyen." >&2
      ABORTO="$C"
      exit 7
    fi
  fi
  sleep 2
done
