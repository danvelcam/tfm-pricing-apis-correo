#!/usr/bin/env bash
# Sondeo empirico Brevo (escalon 3) - PAQUETE A, CERO ENVIOS - preparado el 2026-09-17
#
# PREGUNTA QUE RESUELVE
#   DISC-16: el tope de tamano por correo transaccional. El centro de ayuda dice "The size
#   limit for transactional emails is 20MB, including the attachments and email content."
#   [F27]; la pagina de producto dice "Max attachment size | 25 MB per email" [F5]. Un tope
#   de adjunto mayor que el tope total del correo no puede ser cierto a la vez. La carga en
#   MBs del endpoint de envio esta hoy en AMBAR con la cifra menor, 20.
#   Y una pregunta que DISC-16 no formula y decide la cifra: el tope se cuenta sobre el
#   adjunto DECODIFICADO o sobre el cuerpo de la peticion, que va en base64 y pesa un 33 %
#   mas. Lo separa el caso t01: 15 MB decodificados son 20,0 MB de peticion. Si ese salta,
#   el tope es del cuerpo; si no salta y si lo hace el de 21 MB decodificados, es del
#   adjunto.
#
# COMO SE MIDE SIN QUE SALGA UN SOLO CORREO
#   Igual que en probe_brevo_a_destinatarios.sh: la invariante del paquete A es que
#   ninguna peticion de envio sea ACEPTADA, asi que TODAS llevan GUARDA -- un defecto que
#   Brevo tiene que rechazar -- y el tope se lee en QUE error vuelve. El control (adjunto
#   de 1 KB) fija el mensaje de la guarda; un caso cuyo mensaje cambia es un caso donde el
#   tope de tamano se valido ANTES que la guarda.
#   Solo se explora el lado RECHAZADO: el resultado es "el tope es COMO MAXIMO N", nunca
#   "el tope es exactamente N".
#
#   LOS PARES (regla 6) estan puestos para que cada uno cruce las DOS lecturas de la unidad,
#   MB decimal y MiB, y el resultado valga con cualquiera de las dos:
#     20 MB -> 19,0 MB y 21,0 MB decodificados   (19e6 < 20e6 <= 20 MiB = 20.971.520 < 21e6)
#     25 MB -> 24,0 MB y 26,5 MB decodificados   (24e6 < 25e6 <= 25 MiB = 26.214.400 < 26,5e6)
#   Si el mensaje cambia dentro del par, el tope cae en ese intervalo con las dos lecturas.
#
#   RESERVA QUE HAY QUE ESCRIBIR EN EL PROVENANCE: la cabecera de sandbox "only validates
#   the API request format" [F16]. Si el tope de tamano se aplica en la ENTREGA y no en la
#   validacion, este sondeo no lo vera, y entonces DISC-16 pasa al paquete B (2 envios).
#
# COSTE EN ENVIOS: 0 ENTREGADOS. Presupuesto: 7 peticiones a POST /v3/smtp/email, todas con
#   guarda. Un 2xx aborta el script en el acto, anota el envio en el libro compartido y pone
#   la PARADA del paquete A.
#   CONSUMO DE CUOTA EN SANDBOX: **NO MEDIDO**, y no se afirma aqui: es la pregunta de
#   probe_brevo_b_unidad_cuota.sh. Lo que este sondeo sostiene es que ninguna de sus 7
#   peticiones puede ser ACEPTADA, asi que ninguna llega a entregar.
#   Caudal: 7 del bucket de la fila compartida del envio (1.000 RPS / 3.600.000 RPH, tramo
#   General [F6]).
#   TRAFICO DE SUBIDA: ~184 MB en total (el caso mas grande sube ~42,7 MB). No es cuota,
#   pero es el coste real de este sondeo y por eso va declarado. El control de 1 KB va
#   PRIMERO y el script se para ahi si su error es de los que hacen inutil la bisercion
#   (cuenta pendiente de aprobacion, clave sin permiso): entonces el coste es 1 KB, no
#   184 MB.
#   Duracion: depende de la subida; con 10 Mbit/s de subida, unos 3 minutos.
#
# DESTINATARIOS (D-046)
#   Lista blanca literal, sin variantes:  persona-3@example.invalid
#                                         persona-1@example.invalid
#                                         persona-2@example.invalid
#   Este script NO usa ninguna de las tres: el unico destinatario de cada caso va a
#   @example.invalid, dominio sin MX, que D-046 declara verde y via preferente. La
#   comprobacion la hace el script antes de cada llamada, no el modo de la cuenta.
#
# USO
#   bash probe_brevo_a_tamano.sh
#   BREVO_GUARDA=sender_ausente bash probe_brevo_a_tamano.sh
#   Guardas admitidas: sender_sumidero | sender_ausente, las dos con UN solo defecto.
#   'contenido_ausente' se quito el 2026-09-17 por llevar dos defectos a la vez.
#   SIN BREVO_GUARDA la guarda se LEE del JSON mas reciente del preflight, que es el sondeo
#   que la mide; si ese JSON no existe, este script ABORTA en vez de elegir a ciegas.
#   Lee BREVO_API_KEY de ~/.config/tfm/.env.
#   Necesita ~120 MB libres en $TMPDIR (los cuerpos se escriben en disco antes de subir).
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
D="$(mktemp -d "${TMPDIR:-/tmp}/brevo_a_tamano_XXXXXX")" || { echo "ABORTA: no se pudo crear el directorio de trabajo." >&2; exit 3; }
[[ -d $D && -w $D ]] || { echo "ABORTA: el directorio de trabajo '$D' no existe o no acepta escrituras." >&2; exit 3; }
# El JSON va a 03_datos/apis/brevo/evidencias/ si esa carpeta existe, igual que hacen los
# dos sondeos del paquete B. Antes caia junto al script y la ultima linea imprimia una ruta a
# evidencias/ a la que nadie lo llevaba: quien seguia esa linea y movia el fichero dejaba a
# probe_brevo_a_destinatarios.sh y probe_brevo_a_tamano.sh abortando por falta de preflight,
# porque guarda_elegida lo buscaba solo junto al script.
SAL="$AQUI"
[ -d "$AQUI/../../03_datos/apis/brevo/evidencias" ] &&
  SAL="$(CDPATH='' cd -- "$AQUI/../../03_datos/apis/brevo/evidencias" && pwd)"
# El espacio libre, ANTES de generar los cuerpos. Este sondeo escribe ~184 MB en total en
# $D, y un disco lleno a mitad deja peticiones truncadas que se leen como resultado. 'df' ya
# estaba en la lista de brevo_limpia_funciones y no se usaba.
espacio_suficiente () {  # $1 MB que hacen falta
  local LIBRE
  LIBRE="$(df -Pm "$D" 2>/dev/null | awk 'NR==2{print $4}')"
  case "$LIBRE" in ''|*[!0-9]*)
    echo "AVISO: no se pudo leer el espacio libre de $D; se sigue." >&2; return 0 ;;
  esac
  if (( LIBRE < $1 )); then
    echo "ABORTA: en $D quedan ${LIBRE} MB libres y este sondeo necesita al menos $1 MB" >&2
    echo "        para los cuerpos de peticion. Un disco lleno a mitad deja peticiones" >&2
    echo "        truncadas que se leen como resultado. No se llama a nada." >&2
    exit 3
  fi
}
espacio_suficiente 400

OUT="$SAL/probe_brevo_a_tamano_$(date -u +%Y-%m-%d_%H%M%S).json"
ORDEN=""
ABORTO=""

# caso:bytes_decodificados_del_adjunto
CASOS="t00_control_1kb:1024 t01_dec15mb:15000000 t02_dec19mb:19000000 t03_dec21mb:21000000 t04_dec24mb:24000000 t05_dec26_5mb:26500000 t06_dec32mb:32000000"
CONTROL_OK=0
# Cada caso lleva UN destinatario -- construir() escribe un solo "to" -- y el libro cuenta
# en destinatarios desde el 2026-09-17: se reserva 1 antes de cada llamada y se libera con
# el 4xx. La escalada de este sondeo es por TAMANO, no por destinatarios, asi que la puerta
# que importa aqui es la del control: sin un 4xx explicito en los 1 KB no se construye el
# primer adjunto grande.

echo "== PRESUPUESTO DECLARADO (D-046 condicion 2) =="
echo "   Envios ENTREGADOS ...................... 0  (invariante del paquete A; un 2xx"
echo "                                              aborta, se anota en el libro y pone"
echo "                                              la PARADA del paquete)"
echo "   Consumo de cuota en sandbox ............ NO MEDIDO -- lo mide el paquete B,"
echo "                                              probe_brevo_b_unidad_cuota.sh"
echo "   Comprometidos en la ventana ............ $(libro_comprometido) de $(libro_tope_efectivo)   (la pasada son 24 horas)"
echo "   Peticiones a POST /v3/smtp/email ....... 7  (todas con guarda; un 2xx aborta)"
echo "   Guarda en uso .......................... $GUARDA"
echo "   Trafico de subida ...................... ~184 MB (no es cuota, pero es el coste)"
echo "                                              El control (1 KB) va primero y si su"
echo "                                              error hace inutil la bisercion, el"
echo "                                              script para ANTES del primer adjunto"
echo "                                              grande: 1 KB en vez de 184 MB"
echo "   Destinatarios .......................... solo @$SUMIDERO; lista blanca NO usada"
echo "   Unidad del libro ....................... el DESTINATARIO. Cada caso lleva 1: se"
echo "                                              reserva antes de llamar y se libera con"
echo "                                              el 4xx explicito"
echo "   Pausa entre llamadas ................... 5 s"
echo

resumir() {
  if [ -f "$D/.resumido" ]; then return 0; fi
  : > "$D/.resumido"
  CLAVE="${BREVO_API_KEY:-}" CLAVE2="${BREVO_API_KEY_2:-}" \
  FROM="${BREVO_FROM:-}" TO="${BREVO_TO:-}" SUMIDERO="$SUMIDERO" \
  GUARDA_VALIDADA="$(guarda_validada_por_el_preflight)" \
  python3 -I - "$D" "$OUT" "$ORDEN" "$ABORTO" "$GUARDA" <<'PY'
import sys,json,os,re as _re
d,out,orden,aborto,guarda=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5]
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
    try: tam=json.load(open(d+"/"+c+".tam"))
    except Exception: tam={}
    w=(open(d+"/"+c+".w").read().strip().split("\t")+[""]*3)[:3] if os.path.exists(d+"/"+c+".w") else ["","",""]
    casos.append({"caso":c,"metodo":m[0],"ruta":m[1],"descripcion":m[2],
      "inicio_utc":m[3],"fin_utc":m[4],"bytes_peticion":int(m[5] or 0),
      "bytes_adjunto_decodificado":tam.get("bytes_decodificado"),
      "bytes_adjunto_base64":tam.get("bytes_base64"),
      "sha256_peticion":tam.get("sha256"),
      "bytes_subidos_por_curl":w[1],"segundos_curl":w[2],
      "http":int(open(d+"/"+c+".code").read().strip() or 0),
      "error_code":cuerpo.get("code") if isinstance(cuerpo,dict) else None,
      "error_message":cuerpo.get("message") if isinstance(cuerpo,dict) else None,
      # El CUERPO ENTERO del error: de aqui sale la cita literal para fuentes.md (regla 7).
      "cuerpo_crudo":crudo,
      "cabeceras_caudal":{k:v for k,v in h.items() if k.startswith("x-sib-ratelimit")}})
por={c["caso"]:c for c in casos}
ctrl=por.get("t00_control_1kb")
msg_guarda=(ctrl or {}).get("error_message")
# Sin mensaje de control no hay vara de medir: "distinto del control" seria cierto para
# todos los casos y la tabla entera leeria tope. Con la vara ausente no se mide.
control_util = bool(msg_guarda) and isinstance((ctrl or {}).get("http"), int) \
    and 400 <= ctrl["http"] < 500
def es_tope(c):
    if not control_util: return None
    x=por.get(c)
    if not x: return None
    return x.get("error_message")!=msg_guarda
def cita(c):
    x=por.get(c) or {}
    return {"http":x.get("http"),"code":x.get("error_code"),"message":x.get("error_message"),
            "bytes_adjunto_decodificado":x.get("bytes_adjunto_decodificado"),
            "bytes_peticion":x.get("bytes_peticion")}
PARES=[("frontera de 20 MB (cubre MB y MiB)","t02_dec19mb","t03_dec21mb","20 MB"),
       ("frontera de 25 MB (cubre MB y MiB)","t04_dec24mb","t05_dec26_5mb","25 MB")]
pares=[]
for nom,lo,hi,etq in PARES:
    tlo,thi=es_tope(lo),es_tope(hi)
    if tlo is None or thi is None: v="no medible: falta uno de los dos casos del par"
    elif thi and not tlo:
        v=("acotado por arriba: el tope cae entre %s y %s bytes de adjunto decodificado, "
           "es decir por DEBAJO de %s con las dos lecturas de la unidad. El lado aceptado "
           "no se ha probado, asi que no se afirma la cifra exacta"%(
            por[lo].get("bytes_adjunto_decodificado"),por[hi].get("bytes_adjunto_decodificado"),etq))
    elif thi and tlo:
        v="el tope esta por debajo del caso bajo: repetir el par con tamanos menores"
    elif not thi and not tlo:
        v=("no se ve el tope con esta guarda en esta frontera: los dos casos traen el "
           "mensaje de la guarda")
    else:
        v="incoherente: el caso bajo salta y el alto no. Repetir y mirar http y code"
    pares.append({"par":nom,"caso_bajo":lo,"caso_alto":hi,"cita_bajo":cita(lo),
      "cita_alto":cita(hi),"veredicto":v})
# t01: el tope se cuenta sobre el cuerpo o sobre el adjunto decodificado.
t01,t03=es_tope("t01_dec15mb"),es_tope("t03_dec21mb")
if t01 is None: unidad="no medible: falta t01"
elif t01: unidad=("el tope se cuenta sobre el CUERPO de la peticion: 15 MB decodificados "
                  "(20,0 MB de peticion en base64) ya saltan")
elif t03: unidad=("el tope se cuenta sobre el ADJUNTO DECODIFICADO: 20,0 MB de peticion no "
                  "saltan y 21 MB decodificados si")
else: unidad="no concluyente: ni t01 ni t03 cambian de mensaje"
# Con pocos casos no se concluye nada: un 'all()' sobre una lista vacia diria que Brevo no
# valida el tamano sin haber medido un solo caso.
medidos=[c for c in casos if c["caso"]!="t00_control_1kb" and es_tope(c["caso"]) is not None]
ninguno=(len(medidos)>=4 and all(es_tope(c["caso"]) is False for c in medidos))
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
resumen={"api":"brevo","paquete":"A (cero envios)","sondeo":"tamano",
  "fecha_utc":casos[0]["inicio_utc"] if casos else None,
  "guarda_en_uso":guarda,"mensaje_de_la_guarda":msg_guarda,
  # Si la guarda se forzo con BREVO_GUARDA, el preflight NO la respalda y el dato medido no
  # se puede citar como si lo hiciera.
  "guarda_validada_por_el_preflight":(os.environ.get("GUARDA_VALIDADA")=="si"),
  "control_utilizable":control_util,
  "aviso_del_control":(None if control_util else
    ("EL CONTROL NO SIRVE DE VARA: t00_control_1kb no dejo un {code,message} de Brevo con un "
     "4xx (http=%s, message=%r). Sin mensaje de control, 'es distinto del control' seria "
     "cierto para todos los casos y la tabla leeria tope en todas las filas. Todo lo de "
     "abajo sale NO CONCLUYENTE a proposito." % ((ctrl or {}).get("http"), msg_guarda))),
  "envios_reales":envios_calculados,
  "unidad_de_envios_reales":("destinatarios de las peticiones ACEPTADAS (2xx), que es la "
    "unidad con la que el libro de cuentas reserva y gasta. Calculado, no declarado"),
  "peticiones":len(casos),
  "peticiones_de_envio_aceptadas_2xx":aceptadas,
  "invariante_cero_envios":"CUMPLIDA" if not aceptadas else "ROTA",
  "abortado_en":aborto or None,
  "tabla":[{"caso":c["caso"],"http":c["http"],
            "adjunto_decodificado":c["bytes_adjunto_decodificado"],
            "peticion":c["bytes_peticion"],"code":c["error_code"],
            "message":c["error_message"]} for c in casos],
  "pares":pares,"sobre_que_se_cuenta_el_tope":unidad,
  "veredicto_DISC_16":("ningun tamano cambia el mensaje: Brevo NO valida el tamano en esta "
    "ruta, o lo valida despues de la guarda. Cuadra con [F16] ('sandbox mode only validates "
    "the API request format') y con que el tope se aplique en la ENTREGA: DISC-16 no se "
    "cierra aqui y pasa al paquete B, 2 envios reales a la lista blanca"
    if ninguno else ("sin datos suficientes: solo %d casos medidos de los 6 previstos. No "
    "se concluye nada; ver 'pares'"%len(medidos) if len(medidos)<4 else
    "ver 'pares' y 'sobre_que_se_cuenta_el_tope'")),
  "lo_que_esto_NO_demuestra":("El lado aceptado no se prueba: el resultado es 'el tope es "
    "como maximo N'. Y un 413 del borde HTTP no es el tope del producto: si aparece, se "
    "cita como tope de la infraestructura, no como la cifra de [F27] ni la de [F5].")}
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
  python3 -I - "$1" "$D/$1.req" "$D/$1.tam" "$SUMIDERO" "$GUARDA" "$2" <<'PY'
import json,sys,time,base64,hashlib
caso,out,tam,sumi,guarda,nbytes=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5],int(sys.argv[6])
nonce=str(time.time_ns())   # evita 'duplicate_request' [F9]
# Cada guarda, UN solo defecto: el contenido va SIEMPRE. El modo 'contenido_ausente' se
# quito el 2026-09-17 porque mantenia el remitente del sumidero y llevaba dos defectos a la
# vez, con lo que el mensaje devuelto no era el de la guarda que se creia.
b={"subject":"TFM sonda %s %s"%(caso,nonce),"to":[{"email":"sonda-000001@%s"%sumi}],
   "htmlContent":"<html><body><p>sonda TFM paquete A, cero envios</p></body></html>"}
if guarda!="sender_ausente":
    b["sender"]={"name":"TFM sonda","email":"sonda-remitente@%s"%sumi}
crudo=b"x"*nbytes
b64=base64.b64encode(crudo).decode()
# .txt esta en la lista de extensiones admitidas de [F10], asi que la extension no puede
# ser el motivo del rechazo; la unica variable del sondeo es el tamano.
b["attachment"]=[{"content":b64,"name":"sonda.txt"}]
json.dump(b,open(out,"w"))
h=hashlib.sha256()
with open(out,"rb") as f:
    for trozo in iter(lambda:f.read(1<<20),b""): h.update(trozo)
json.dump({"bytes_decodificado":nbytes,"bytes_base64":len(b64),
           "sha256":h.hexdigest()},open(tam,"w"))
print("   adjunto decodificado %d B -> base64 %d B -> peticion %d B"%(
      nbytes,len(b64),__import__("os").path.getsize(out)))
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
# Y tantos como el libro va a reservar: un cuerpo con mas destinatarios que la reserva gasta
# mas de lo comprometido.
if len(dest)!=esperados:
    sys.exit("ABORTA: el cuerpo lleva %d destinatarios y se van a reservar %d."
             %(len(dest),esperados))
PY
}

llamar_envio() {
  caso="$1"; desc="$2"; ndest="${3:-1}"
  t0="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
  w="$(curl_brevo "$BREVO_API_KEY" -sS --max-time 600 -o "$D/$caso.body" -D "$D/$caso.hdr" \
    -w '%{http_code}\t%{size_upload}\t%{time_total}' \
    -H "accept: application/json" -H "content-type: application/json" \
    -H "X-Sib-Sandbox: drop" \
    -X POST "$BASE/smtp/email" --data-binary @"$D/$caso.req")" || w="$(printf '000\t0\t0')"
  t1="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
  printf '%s\n' "$w" > "$D/$caso.w"
  code="$(printf '%s' "$w" | cut -f1)"
  echo "$code" > "$D/$caso.code"
  printf 'POST\t/v3/smtp/email\t%s\t%s\t%s\t%s\n' "$desc" "$t0" "$t1" "$(wc -c < "$D/$caso.req")" > "$D/$caso.meta"
  ORDEN="$ORDEN$caso,"
  printf '   HTTP %s  %s\n' "$code" "$(head -c 240 "$D/$caso.body" | tr -d '\n')"
  rm -f "$D/$caso.req"
  # DOS lecturas, no tres: 4xx explicito = rechazo demostrado y el sondeo sigue; cualquier
  # otra cosa -- 000, 5xx, cuerpo vacio, timeout -- es "no se sabe", y no saberlo se paga.
  # Aqui es el caso mas caro del paquete: con --max-time 600 y un cuerpo de decenas de MB,
  # la respuesta se puede perder DESPUES de que Brevo aceptara la peticion.
  paquete_a_cerrar "$caso" "$code" "$ndest" || { RC=$?; ABORTO="$caso"; exit "$RC"; }
}

for PAR in $CASOS; do
  C="${PAR%%:*}"; N="${PAR##*:}"
  # Las puertas van ANTES de construir: un adjunto de 32 MB se escribe en disco y se sube
  # entero, asi que decidir despues de montarlo es pagar el coste para nada.
  if [ "$C" != "t00_control_1kb" ] && [ "$CONTROL_OK" != "1" ]; then
    echo "!!! ABORTA: el control de 1 KB no ha demostrado un 4xx explicito, asi que '$C' no" >&2
    echo "!!! se construye. Sin vara de medir, 'distinto del control' es cierto para todos" >&2
    echo "!!! los casos y la escalera de tamanos saldria envenenada. Se ahorran ~184 MB de" >&2
    echo "!!! subida que no habrian medido nada." >&2
    ABORTO="$C"
    exit 7
  fi
  if ! libro_cabe 1; then
    echo "!!! ABORTA: no queda margen en el libro ni para un destinatario (margen" >&2
    echo "!!! $(libro_margen) de $(libro_tope_efectivo)). DISC-16 se queda sin medir por" >&2
    echo "!!! esta via y la pregunta vuelve en la salida." >&2
    ABORTO="$C"
    exit 4
  fi
  echo "-- $C  ($N bytes de adjunto decodificado)"
  construir "$C" "$N" || exit 2
  verificar_destinatarios "$C" 1 || exit 2
  reservar "$C" 1
  llamar_envio "$C" "adjunto de $N bytes decodificados, guarda $GUARDA" 1
  # Salida temprana: el control son 1 KB y decide si vale la pena subir los 184 MB que
  # vienen detras. Antes el script leia el control y seguia pase lo que pase.
  if [ "$C" = "t00_control_1kb" ]; then
    if MOT="$(control_inutil "$D/$C.body")"; then
      echo "!!! ABORTA tras el control de 1 KB, antes de subir el primer adjunto grande:" >&2
      echo "!!!   $MOT" >&2
      echo "!!! Se ahorran ~184 MB de subida que no habrian medido nada. DISC-16 se queda" >&2
      echo "!!! SIN MEDIR por esta via; el cuerpo del control esta guardado y es la cita." >&2
      ABORTO="$C"
      exit 3
    fi
    # Y la vara: el resumen ya calculaba 'control_util' con esta misma condicion, pero al
    # final, con los 184 MB ya subidos. Aqui decide si se suben.
    if control_valido "$D/$C.body" "$(cat "$D/$C.code" 2>/dev/null)"; then
      CONTROL_OK=1
      echo "   control valido: 4xx explicito con {code,message}. La vara existe."
    fi
  fi
  sleep 5
done
