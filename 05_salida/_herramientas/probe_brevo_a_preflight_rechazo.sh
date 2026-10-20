#!/usr/bin/env bash
# Sondeo empirico Brevo (escalon 3) - PAQUETE A, CERO ENVIOS - preparado el 2026-09-17
#
# PREGUNTA QUE RESUELVE
#   Es la puerta del paquete A y se ejecuta PRIMERO. Responde dos cosas de las que depende
#   todo lo demas:
#     (1) POST /v3/smtp/email RECHAZA la peticion de sonda? Si la aceptara (2xx) el paquete
#         A dejaria de ser de coste cero, y con example.invalid (dominio sin MX) habria
#         gastado cuota y generado un rebote. El script aborta en el acto si ve un 2xx.
#     (2) QUE error gana cuando la peticion viola DOS cosas a la vez: la guarda estructural
#         y un tope de carga documentado. Brevo devuelve UN solo {code,message}, no una
#         lista de campos, asi que la PRECEDENCIA de validacion decide si los demas sondeos
#         del paquete pueden llegar a ver el tope detras de la guarda.
#   Salida operativa: escribe la guarda elegida en el JSON, y los dos sondeos que la
#   necesitan -- probe_brevo_a_destinatarios.sh y probe_brevo_a_tamano.sh -- la LEEN de ese
#   JSON en vez de arrancar con un valor por defecto a ciegas.
#
# COSTE EN ENVIOS: hasta 8 peticiones ACEPTADAS -- 2.001 destinatarios la mayor--, y lo que
#   de verdad se gasta lo decide el libro de cuentas, no esta cabecera.
#   MEDIDO EL 2026-09-17, y por eso esta cabecera ya no promete cero: p2_sender_sumidero
#   volvio con 201 y messageId. La version anterior declaraba "0 envios ENTREGADOS" y
#   "ninguna puede ser aceptada: todas llevan un defecto que Brevo tiene que rechazar", y
#   eso era una SUPOSICION sobre la validacion del proveedor, no un hecho: la guarda
#   sender_sumidero NO se sostiene. El unico 4xx explicito de la pasada fue sender_ausente.
#   Que un destinatario no pueda recibir y que la peticion se rechace son propiedades
#   INDEPENDIENTES, y el libro de cuentas existe justo para cazar la diferencia.
#   Cada caso RESERVA sus destinatarios antes de llamar; un 2xx los anota como GASTO, aborta
#   el script y pone la PARADA para que ningun otro sondeo del paquete A repita la jugada.
#   CONSUMO DE CUOTA EN SANDBOX: **NO MEDIDO**, y no se afirma; lo mide
#   probe_brevo_b_unidad_cuota.sh leyendo el saldo antes y despues. Tampoco esta medido si
#   Brevo descarto el mensaje aceptado o lo curso hacia un dominio sin MX, que seria un
#   rebote contra la reputacion de la cuenta.
#   Caudal: 8 del bucket de la fila del endpoint de envio, 1.000 RPS / 3.600.000 RPH en el
#   tramo General [F6]. Medido: el 400 de p1 ya volvio con remaining 999 de limit 1000, o
#   sea que una peticion RECHAZADA tambien consume unidad de ese bucket.
#
# LA GUARDA, que es lo que hace este paquete de coste cero
#   El paquete A no admite un 2xx en un endpoint de envio: si una peticion fuese ACEPTADA,
#   no se hace. Por eso ninguna peticion se manda "bien": todas llevan un defecto que Brevo
#   tiene que rechazar (la GUARDA). El tope se mide comparando QUE error vuelve:
#     - caso de control (guarda sola, carga por debajo del tope) -> error de la guarda
#     - caso de tope    (guarda + carga por encima del tope)     -> error del tope
#   Las dos peticiones del par son rechazadas, asi que el lado ACEPTADO no se explora nunca.
#   Consecuencia que hay que escribir tal cual en la datasheet: lo medido es "el tope es
#   COMO MAXIMO N", nunca "el tope es exactamente N".
#
# DESTINATARIOS (D-046, docs/08-mandato.md)
#   Lista blanca literal, sin variantes:  persona-3@example.invalid
#                                         persona-1@example.invalid
#                                         persona-2@example.invalid
#   El paquete A NO USA ninguna de las tres: es de cero envios y una aceptacion inesperada
#   sobre un buzon real SI entregaria. Los destinatarios van todos al sumidero sin MX
#   example.invalid, que D-046 declara verde y via preferente. La comprobacion es del
#   script, no del modo de la cuenta: verificar_destinatarios() recorre to/cc/bcc y
#   messageVersions[].to de CADA cuerpo antes de la llamada, y aborta si encuentra una
#   direccion de la lista blanca o cualquier dominio que no sea el sumidero.
#
# USO
#   bash probe_brevo_a_preflight_rechazo.sh
#   Lee BREVO_API_KEY de ~/.config/tfm/.env.
#
# LO QUE ESTE SONDEO YA NO MIDE, Y POR QUE (2026-09-17)
#   Habia un caso opt-in, p9_sumidero_solo, detras de BREVO_SONDA_SUMIDERO=1: remitente
#   verificado de verdad, contenido valido y un destinatario en el sumidero, para ver si
#   Brevo rechaza example.invalid POR SI SOLO. Se ha QUITADO. El motivo no es el
#   destinatario -- example.invalid es un TLD reservado por RFC 2606, no se puede delegar y
#   ahi no hay desconocido posible -- es el presupuesto: esa peticion PUEDE devolver 2xx, y
#   entonces gasta un credito y genera un rebote dentro de un paquete que imprime "envios
#   reales: 0" y que no llevaba libro de cuentas, asi que el tope de 3 de la pasada no lo
#   habria visto. Dos cifras distintas en el mismo presupuesto impreso es exactamente lo que
#   la condicion 2 de D-046 prohibe.
#   La pregunta se queda SIN MEDIR y vuelve en la salida: medirla es paquete B (reserva en
#   el libro y presupuesto declarado en 1, no en 0), y en esta pasada no hay margen porque
#   los 3 envios estan comprometidos con la unidad de la cuota y el tamano.
#
# ORDEN DE LA PASADA (los buckets de caudal se comparten y no se reponen al instante)
#   1 preflight_rechazo  2 cuenta  3 caudal_cabeceras  4 unidad_reset  5 segmentacion
#   6 destinatarios      7 tamano
#   ... el PAQUETE B entero (probe_brevo_b_*.sh) ...
#   y el ULTIMO de todo: cuerpo_429, que agota el bucket de 100 RPH durante hasta una hora
#   y ahi vive GET /v3/account, que es el instrumento entero del paquete B.
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
# brevo_limpia_funciones desarma las funciones con nombre de orden externa que llegasen
# exportadas desde el shell que lanza el sondeo; del .env ya no puede venir ninguna. La
# libreria del preflight se sourcea por 'control_valido' -- la vara de medir consultada
# dentro del bucle -- y no por 'guarda_elegida', que es este sondeo el que la alimenta: solo
# define funciones, asi que no hay dependencia circular.
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
. "$AQUI/lib_guarda_preflight_brevo.sh"
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
# Las cabeceras de la peticion viven en UN solo sitio: de aqui las coge curl y de aqui las
# copia la evidencia. Hasta el 2026-09-17 'X-Sib-Sandbox: drop' solo existia dentro de la
# llamada, asi que el volcado no permitia saber que las respuestas eran de SANDBOX -- y sin
# eso un 201 no se puede leer, porque [F16] dice que sandbox "only validates the API request
# format". Tenerlas en una sola variable evita ademas que la llamada y el volcado deriven.
CAB_PETICION=("accept: application/json" "content-type: application/json"
              "X-Sib-Sandbox: drop")
readonly -a CAB_PETICION
D="$(mktemp -d "${TMPDIR:-/tmp}/brevo_a_preflight_XXXXXX")" || { echo "ABORTA: no se pudo crear el directorio de trabajo." >&2; exit 3; }
[[ -d $D && -w $D ]] || { echo "ABORTA: el directorio de trabajo '$D' no existe o no acepta escrituras." >&2; exit 3; }
# El JSON va a 03_datos/apis/brevo/evidencias/ si esa carpeta existe, igual que hacen los
# dos sondeos del paquete B. Antes caia junto al script y la ultima linea imprimia una ruta a
# evidencias/ a la que nadie lo llevaba: quien seguia esa linea y movia el fichero dejaba a
# probe_brevo_a_destinatarios.sh y probe_brevo_a_tamano.sh abortando por falta de preflight,
# porque guarda_elegida lo buscaba solo junto al script.
SAL="$AQUI"
[ -d "$AQUI/../../03_datos/apis/brevo/evidencias" ] &&
  SAL="$(CDPATH='' cd -- "$AQUI/../../03_datos/apis/brevo/evidencias" && pwd)"
OUT="$SAL/probe_brevo_a_preflight_rechazo_$(date -u +%Y-%m-%d_%H%M%S).json"
ORDEN=""
ABORTO=""

CASOS="p1_sender_ausente p2_sender_sumidero p3_contenido_ausente p4_sender_ausente_mas_2001 p5_sender_sumidero_mas_2001 p6_contenido_ausente_mas_2001 p7_to_y_messageversions p8_version_100_destinatarios"
OMITIDOS=""

# --- Cuantos destinatarios lleva cada caso ---------------------------------------------
# El libro cuenta en DESTINATARIOS desde el 2026-09-17, no en peticiones: si una peticion de
# 2.001 destinatarios fuese aceptada, el gasto es 2.001. La cifra se necesita ANTES de
# construir el cuerpo, para reservarla y para saber si el caso cabe. construir() y esta
# tabla tienen que decir lo mismo, y verificar_destinatarios() lo comprueba sobre el cuerpo
# ya escrito.
dest_de () {  # $1 caso -> destinatarios, o 0 si el caso no esta en la tabla
  case "$1" in
    p1_sender_ausente|p2_sender_sumidero|p3_contenido_ausente)  echo 1 ;;
    p7_to_y_messageversions)                                    echo 2 ;;
    p8_version_100_destinatarios)                               echo 100 ;;
    p4_sender_ausente_mas_2001|p5_sender_sumidero_mas_2001|p6_contenido_ausente_mas_2001)
                                                                echo 2001 ;;
    *)                                                          echo 0 ;;
  esac
}

# Que caso es la VARA de cada caso que escala. No hay una vara global: cada par mide la
# precedencia frente a SU guarda, asi que el caso de tope de un par solo se manda si el
# control de ESE par dejo un 4xx explicito. Se consulta dentro del bucle y no al final.
vara_de () {  # $1 caso -> caso de control, o vacio si el caso ES un control
  case "$1" in
    p4_sender_ausente_mas_2001)          echo p1_sender_ausente ;;
    p5_sender_sumidero_mas_2001)         echo p2_sender_sumidero ;;
    p6_contenido_ausente_mas_2001)       echo p3_contenido_ausente ;;
    p7_to_y_messageversions)             echo p2_sender_sumidero ;;
    p8_version_100_destinatarios)        echo p2_sender_sumidero ;;
    *)                                   echo "" ;;
  esac
}

echo "== PRESUPUESTO DECLARADO (D-046 condicion 2) =="
echo "   Peticiones que pueden ser ACEPTADAS .... todas. MEDIDO el 2026-09-17: el caso"
echo "                                              p2_sender_sumidero volvio 201 con"
echo "                                              messageId, asi que la guarda"
echo "                                              sender_sumidero NO se sostiene y este"
echo "                                              paquete NO es de coste cero. Unico 4xx"
echo "                                              explicito medido: sender_ausente"
echo "   Tope que de verdad manda ............... el libro de cuentas, en destinatarios."
echo "                                              Un 2xx los anota como GASTO, aborta y"
echo "                                              pone la PARADA del paquete"
echo "   Consumo de cuota en sandbox ............ NO MEDIDO -- lo mide el paquete B,"
echo "                                              probe_brevo_b_unidad_cuota.sh. Aqui no"
echo "                                              se afirma ni lo uno ni lo otro"
echo "   Rebote de un dominio sin MX ............ NO MEDIDO. [F16] dice \"No emails are sent"
echo "                                              to recipients\", pero que el mensaje"
echo "                                              aceptado se descartara no esta medido"
echo "   Comprometidos en la ventana ............ $(libro_comprometido) de $(libro_tope_efectivo)   (la pasada son 24 horas)"
echo "   Peticiones a POST /v3/smtp/email ....... $(echo "$CASOS" | wc -w)  (todas con guarda; un 2xx aborta)"
echo "   Destinatarios ..........................  solo @$SUMIDERO (sin MX); lista blanca NO usada"
echo "   Unidad del libro ....................... el DESTINATARIO, no la peticion. Cada"
echo "                                              caso RESERVA sus destinatarios antes de"
echo "                                              llamar; el que no quepa NO se manda"
echo "   Margen de hoy .......................... $(libro_margen) destinatario(s)"
echo "   Pausa entre llamadas ................... 2 s"
echo

resumir() {
  if [ -f "$D/.resumido" ]; then return 0; fi
  : > "$D/.resumido"
  CLAVE="${BREVO_API_KEY:-}" CLAVE2="${BREVO_API_KEY_2:-}" \
  FROM="${BREVO_FROM:-}" TO="${BREVO_TO:-}" SUMIDERO_RED="$SUMIDERO" \
  python3 -I - "$D" "$OUT" "$ORDEN" "$ABORTO" "$OMITIDOS" <<'PY'
import sys,json,os,re as _re
d,out,orden,aborto=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4]
omitidos=[x for x in sys.argv[5].split(",") if x]
def cab(p):
    h={}
    if not os.path.exists(p): return h
    for l in open(p,errors="replace"):
        if ":" in l and not l.upper().startswith("HTTP/"):
            k,v=l.split(":",1); h[k.strip().lower()]=v.strip()
    return h
# --- LA PETICION, no solo la respuesta ------------------------------------------------
# Hasta el 2026-09-17 el volcado guardaba de la peticion unicamente 'bytes_peticion', asi
# que la garantia central de D-046 -- ninguna direccion de la lista blanca se toco -- solo
# era verificable leyendo el codigo del script, que no esta en evidencias/ ni lleva huella.
# Lo mismo con el remitente y con 'X-Sib-Sandbox: drop', que el provenance de la datasheet
# cita como literales. Se registran aqui: destino comprobable en el propio artefacto.
MUESTRA=5   # con 2.001 destinatarios la lista entera solo engordaria el fichero
def peticion(c):
    p=d+"/"+c+".req"
    if not os.path.exists(p): return None
    try: b=json.load(open(p))
    except Exception: return {"ilegible":True}
    dest=[]
    def rec(o):
        if not isinstance(o,dict): return
        for k in ("to","cc","bcc"):
            for e in (o.get(k) or []):
                if isinstance(e,dict) and e.get("email"): dest.append(e["email"])
        r=o.get("replyTo")
        if isinstance(r,dict) and r.get("email"): dest.append(r["email"])
        for v in (o.get("messageVersions") or []): rec(v)
    rec(b)
    doms=sorted({e.split("@")[-1].lower() for e in dest if "@" in e})
    rem=(b.get("sender") or {}).get("email")
    return {"cabeceras":[l for l in open(d+"/"+c+".reqhdr").read().splitlines() if l]
                        if os.path.exists(d+"/"+c+".reqhdr") else [],
            "sender":rem,
            "destinatarios":{"n":len(dest),"dominios":doms,
                             "direcciones":dest[:MUESTRA],
                             "lista_truncada":len(dest)>MUESTRA}}
def dest_aceptados(c):
    """Destinatarios de una peticion ACEPTADA: la unidad con la que el libro gasta."""
    p=peticion(c)
    return (p or {}).get("destinatarios",{}).get("n",0)
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
      "peticion":peticion(c),
      "http":int(open(d+"/"+c+".code").read().strip() or 0),
      "error_code":cuerpo.get("code") if isinstance(cuerpo,dict) else None,
      "error_message":cuerpo.get("message") if isinstance(cuerpo,dict) else None,
      "cuerpo_crudo":crudo,
      "cabeceras_caudal":{k:v for k,v in h.items() if k.startswith("x-sib-ratelimit")},
      "date":h.get("date"),"retry_after":h.get("retry-after")})
por={c["caso"]:c for c in casos}
TOPE=("recipient","recipients","2000","99","out_of_range","limit","maximum","exceed")
def menciona(c):
    m=((c.get("error_message") or "")+" "+(c.get("cuerpo_crudo") or "")).lower()
    return sorted({t for t in TOPE if t in m})
pares=[("guarda remitente sumidero","p2_sender_sumidero","p5_sender_sumidero_mas_2001"),
       ("guarda remitente sumidero / tope 99 por version","p2_sender_sumidero","p8_version_100_destinatarios"),
       # OJO: este par NO mide una guarda. p3 y p6 quitan el contenido PERO MANTIENEN el
       # remitente del sumidero, asi que llevan DOS defectos a la vez y lo que devuelve la
       # API es la precedencia entre esos dos, no la de "falta el contenido". Se mide igual
       # -- es informacion y no cuesta nada -- pero no entra en la eleccion de guarda.
       ("dos defectos a la vez (contenido ausente Y remitente del sumidero)",
        "p3_contenido_ausente","p6_contenido_ausente_mas_2001"),
       ("guarda sender ausente","p1_sender_ausente","p4_sender_ausente_mas_2001")]
prec=[]
no_medibles=[]
for nom,ctrl,tope in pares:
    a=por.get(ctrl); b=por.get(tope)
    if tope in omitidos or ctrl in omitidos:
        no_medibles.append({"par":nom,"control":ctrl,"caso_tope":tope,
          "motivo":("el caso de tope no se mando. O sus destinatarios no caben en el tope de "
                    "la pasada -- el libro cuenta en DESTINATARIOS -- o su control no dejo un "
                    "4xx explicito con el que leerlo. Sin ese caso el par no existe")})
        continue
    if not a or not b: continue
    prec.append({"par":nom,"control":ctrl,"caso_tope":tope,
      "mensaje_control":a.get("error_message"),"mensaje_tope":b.get("error_message"),
      "http_control":a["http"],"http_tope":b["http"],
      "el_tope_desplaza_a_la_guarda":(a.get("error_message")!=b.get("error_message")),
      "terminos_de_tope_en_el_mensaje":menciona(b)})
aptas=[p["par"] for p in prec if p["el_tope_desplaza_a_la_guarda"]]
# Solo pueden salir recomendadas las guardas de UN defecto. 'contenido_ausente' se cayo de
# la lista el 2026-09-17: para tener un solo defecto tendria que ir con el remitente
# verificado de verdad, y eso es una peticion que Brevo PUEDE aceptar -- el mismo riesgo por
# el que se quito p9_sumidero_solo. Ofrecer una eleccion que no existe es peor que no
# ofrecerla.
guarda=None
for clave,nom in (("guarda remitente sumidero","sender_sumidero"),
                  ("guarda sender ausente","sender_ausente")):
    if any(p["par"].startswith(clave) and p["el_tope_desplaza_a_la_guarda"] for p in prec):
        guarda=nom; break
aceptadas=[c["caso"] for c in casos if 200<=c["http"]<300]
if not prec:
    veredicto=("sin datos: no hay ningun par control/tope completo, asi que no se elige "
               "guarda. Con el tope de la pasada en destinatarios, los casos de tope de este "
               "sondeo (2.001 y 100 destinatarios) no caben, asi que la PRECEDENCIA no se "
               "mide y probe_brevo_a_destinatarios.sh / probe_brevo_a_tamano.sh abortaran al "
               "no encontrar guarda recomendada. Lo que este sondeo SI deja medido es la "
               "invariante: si sus casos de un destinatario fueron rechazados, ninguna "
               "peticion con guarda es aceptada. Mirar 'pares_no_medibles', 'abortado_en' y "
               "'http_por_caso'")
elif guarda:
    veredicto=("usar BREVO_GUARDA=%s en probe_brevo_a_destinatarios.sh y "
               "probe_brevo_a_tamano.sh"%guarda)
else:
    veredicto=("ninguna guarda deja ver el tope: la bisercion por error discriminante NO es "
               "viable en Brevo. Los topes de carga se quedan en ambar y la pregunta vuelve "
               "en la salida, sin gastar un envio para forzarla.")
# El coste se CALCULA de lo aceptado, en la unidad del libro (el destinatario). Hasta el
# 2026-09-17 este campo era el literal 0, asi que el resumen del 2026-09-17 declaraba cero
# envios en el mismo objeto en el que declaraba la invariante ROTA y una peticion aceptada,
# y el libro anotaba GASTO de 1. Quien citaba la evidencia leyendo su primer campo -- que es
# donde apunta el provenance -- concluia que no se acepto nada.
envios=sum(dest_aceptados(c) for c in aceptadas)
resumen={"api":"brevo",
  "paquete":("A (declarado de cero envios; MEDIDO %d destinatario(s) aceptado(s))"%envios
             if envios else "A (cero envios, invariante CUMPLIDA en esta pasada)"),
  "sondeo":"preflight_rechazo",
  "fecha_utc":casos[0]["inicio_utc"] if casos else None,
  "envios_reales":envios,"peticiones":len(casos),
  "unidad_de_envios_reales":("destinatarios de las peticiones ACEPTADAS (2xx), que es la "
    "unidad con la que el libro de cuentas reserva y gasta. Calculado, no declarado"),
  "casos_omitidos_por_presupuesto_o_sin_vara":omitidos,
  "pares_no_medibles":no_medibles,
  "peticiones_aceptadas_2xx":aceptadas,
  "invariante_cero_envios":"CUMPLIDA" if not aceptadas else "ROTA",
  "abortado_en":aborto or None,
  "http_por_caso":{c["caso"]:c["http"] for c in casos},
  "error_por_caso":{c["caso"]:[c.get("error_code"),c.get("error_message")] for c in casos},
  "precedencia":prec,"pares_utiles":aptas,"guarda_recomendada":guarda,
  "veredicto":veredicto,
  "rechaza_el_sumidero_por_si_solo":("NO MEDIDO. El caso que lo media (p9_sumidero_solo) se "
    "quito del paquete A el 2026-09-17: podia devolver 2xx, y entonces gastaba un credito y "
    "generaba un rebote dentro de un paquete que declara cero envios y que no lleva libro de "
    "cuentas, asi que el tope de la pasada no lo veria. Medirlo es paquete B, con reserva en "
    "el libro y presupuesto declarado en 1. La pregunta vuelve en la salida."),
  "guardas_candidatas":["sender_sumidero","sender_ausente"],
  "por_que_no_esta_contenido_ausente":("'contenido_ausente' quita el contenido pero MANTIENE "
    "el remitente del sumidero, asi que lleva DOS defectos y su mensaje mide la precedencia "
    "entre ellos, no la de la guarda. Para tener un solo defecto habria que mandarlo con el "
    "remitente verificado, y esa peticion PUEDE ser aceptada: es el mismo riesgo que tumbo a "
    "p9_sumidero_solo. Se mide el par (no cuesta nada) pero no se ofrece como guarda."),
  "lectura_de_los_huecos":("Un par cuyo mensaje de tope es IGUAL al del control no demuestra "
    "que no haya tope: demuestra que esa guarda se valida antes. No se convierte en dato.")}
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
# El nombre es SUMIDERO_RED y no SUMIDERO a proposito: la variable del shell es `readonly`
# desde la linea 139 -- eso la protege de un .env hostil -- y un prefijo de entorno
# `SUMIDERO="$SUMIDERO"` choca con ese readonly. Bash contesta "variable de solo lectura",
# ejecuta la orden igual y deja la variable SIN DEFINIR en el hijo: el sumidero llegaba
# vacio, la excepcion de _suelta() no se cumplia nunca y el redactor tachaba tambien las
# direcciones sinteticas, que son justo lo que hay que poder leer en la evidencia.
_SUMI = (os.environ.get("SUMIDERO_RED") or "").strip().lower()


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


# Si el sumidero no llego, la evidencia SE ESCRIBE igual -- una pasada ya gastada no se
# tira -- pero lo dice en su propio resumen en vez de salir sobre-redactada en silencio.
if not _SUMI:
    resumen["defecto_del_instrumento"] = (
        "el sumidero no llego al redactor (SUMIDERO_RED vacio), asi que TODA direccion "
        "suelta esta tachada, incluidas las sinteticas: este volcado NO prueba hacia donde "
        "salio la peticion")
    sys.stderr.write("AVISO: SUMIDERO_RED vacio; el volcado sobre-redacta las direcciones "
                     "sinteticas.\n")
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
  # El remitente verificado (BREVO_FROM) NO se le pasa a proposito: el unico caso que lo
  # usaba era p9_sumidero_solo, y con el fuera ninguna peticion de este paquete puede
  # llevar un remitente que Brevo acepte.
  python3 -I - "$1" "$D/$1.req" "$SUMIDERO" <<'PY'
import json,sys,time
caso,out,sumi=sys.argv[1],sys.argv[2],sys.argv[3]
nonce=str(time.time_ns())
def tos(n):
    return [{"email":"sonda-%05d@%s"%(i,sumi)} for i in range(1,n+1)]
# El nonce evita 'duplicate_request' ("Identical request submitted too frequently", [F9])
# y hace innecesario el idempotencyKey, cuyo TTL de 30 min [F15] estorbaria a la bisercion.
CONT={"subject":"TFM sonda %s %s"%(caso,nonce),
      "htmlContent":"<html><body><p>sonda TFM paquete A, cero envios</p></body></html>"}
REM={"name":"TFM sonda","email":"sonda-remitente@%s"%sumi}
if   caso=="p1_sender_ausente":             b=dict(CONT,to=tos(1))
elif caso=="p2_sender_sumidero":            b=dict(CONT,sender=REM,to=tos(1))
elif caso=="p3_contenido_ausente":          b={"sender":REM,"to":tos(1)}
elif caso=="p4_sender_ausente_mas_2001":    b=dict(CONT,to=tos(2001))
elif caso=="p5_sender_sumidero_mas_2001":   b=dict(CONT,sender=REM,to=tos(2001))
elif caso=="p6_contenido_ausente_mas_2001": b={"sender":REM,"to":tos(2001)}
elif caso=="p7_to_y_messageversions":       b=dict(CONT,sender=REM,to=tos(1),messageVersions=[{"to":tos(1)}])
elif caso=="p8_version_100_destinatarios":  b=dict(CONT,sender=REM,messageVersions=[{"to":tos(100)}])
else: sys.exit("ABORTA: caso desconocido "+caso)
# El remitente REAL no se usa en ningun caso de este paquete: el unico que lo usaba era
# p9_sumidero_solo, que se quito porque podia ser ACEPTADO y gastar un credito sin libro.
assert b["sender"]["email"].endswith("@"+sumi) if "sender" in b else True, \
    "el paquete A no manda con el remitente verificado: eso puede ser aceptado"
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
# El cuerpo tiene que llevar EXACTAMENTE lo que dijo dest_de, que es lo que el libro va a
# reservar: una tabla desincronizada del constructor gastaria mas de lo comprometido.
if len(dest)!=esperados:
    sys.exit("ABORTA: el cuerpo lleva %d destinatarios y la tabla dest_de dice %d. El libro "
             "reservaria menos de lo que se gasta."%(len(dest),esperados))
print("   destinatarios comprobados: %d, todos en @%s"%(len(dest),sumi))
PY
}

llamar_envio() {
  caso="$1"; desc="$2"; ndest="${3:-1}"
  t0="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
  # Las cabeceras se escriben ANTES de llamar y desde la misma variable que las manda, para
  # que el volcado diga con que se pidio y no haya que leer el script para saberlo.
  HS=()
  for _h in "${CAB_PETICION[@]}"; do HS+=(-H "$_h"); done
  printf '%s\n' "${CAB_PETICION[@]}" > "$D/$caso.reqhdr"
  code="$(curl_brevo "$BREVO_API_KEY" -sS --max-time 60 -o "$D/$caso.body" -D "$D/$caso.hdr" -w '%{http_code}' \
    "${HS[@]}" \
    -X POST "$BASE/smtp/email" --data-binary @"$D/$caso.req")" || code="000"
  t1="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
  echo "$code" > "$D/$caso.code"
  printf 'POST\t/v3/smtp/email\t%s\t%s\t%s\t%s\n' "$desc" "$t0" "$t1" "$(wc -c < "$D/$caso.req")" > "$D/$caso.meta"
  ORDEN="$ORDEN$caso,"
  printf '   HTTP %s  %s\n' "$code" "$(head -c 240 "$D/$caso.body" | tr -d '\n')"
  # DOS lecturas, no tres: 4xx explicito = rechazo demostrado y el sondeo sigue; cualquier
  # otra cosa -- 000, 5xx, cuerpo vacio, timeout -- es "no se sabe", y no saberlo se paga.
  # La regla entera vive en paquete_a_cerrar(), en lib_presupuesto_brevo.sh.
  paquete_a_cerrar "$caso" "$code" "$ndest" || { RC=$?; ABORTO="$caso"; exit "$RC"; }
}

for C in $CASOS; do
  NDEST="$(dest_de "$C")"
  if [ "$NDEST" = "0" ]; then
    echo "!!! ABORTA: el caso '$C' no esta en la tabla dest_de: no se sabe cuanto reservar." >&2
    exit 2
  fi
  # Puerta de escalada: el caso de tope de un par no se construye hasta que el control de
  # ESE par haya dejado un 4xx explicito con {code,message}. Es la condicion que el resumen
  # llama 'el_tope_desplaza_a_la_guarda' -- que necesita un mensaje de control que exista --
  # consultada AQUI y no despues de haber mandado los 2.001 destinatarios.
  VARA="$(vara_de "$C")"
  if [ -n "$VARA" ] && [ ! -e "$D/$VARA.vara" ]; then
    echo "-- $C  OMITIDO: su control '$VARA' no dejo un 4xx explicito con {code,message},"
    echo "   asi que no hay vara con la que leer este caso y no se manda."
    OMITIDOS="$OMITIDOS$C,"
    continue
  fi
  # Puerta de presupuesto: el libro cuenta en destinatarios.
  if ! libro_cabe "$NDEST"; then
    echo "-- $C  OMITIDO: $NDEST destinatarios no caben en el margen de hoy ($(libro_margen))."
    echo "   El tope de la pasada son $(libro_tope_efectivo) y un 2xx inesperado gastaria"
    echo "   $NDEST de golpe. Se prefiere medir menos que medir mal."
    OMITIDOS="$OMITIDOS$C,"
    continue
  fi
  echo "-- $C  ($NDEST destinatarios)"
  construir "$C" || exit 2
  verificar_destinatarios "$C" "$NDEST" || exit 2
  reservar "$C" "$NDEST"
  llamar_envio "$C" "caso de preflight $C" "$NDEST"
  # Si este caso es un control, aqui se decide si sirve de vara para los que escalan.
  if [ -z "$VARA" ]; then
    if control_valido "$D/$C.body" "$(cat "$D/$C.code" 2>/dev/null)"; then
      : > "$D/$C.vara"
      echo "   sirve de vara: 4xx explicito con {code,message}."
    else
      echo "   NO sirve de vara: HTTP $(cat "$D/$C.code" 2>/dev/null) sin 4xx explicito o"
      echo "   sin {code,message}. Los casos que se leian contra el no se mandaran."
    fi
  fi
  sleep 2
done
