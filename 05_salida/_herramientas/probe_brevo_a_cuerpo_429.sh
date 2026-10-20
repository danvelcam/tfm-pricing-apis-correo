#!/usr/bin/env bash
# Sondeo empirico Brevo (escalon 3) - PAQUETE A, CERO ENVIOS - preparado el 2026-09-17
#
# PREGUNTA QUE RESUELVE
#   DISC-12: que trae el cuerpo del 429. El blog publica {"code": "too_many_requests",
#   "message": "API call rate limit exceeded"} [F28], y ese valor NO existe ni en la tabla
#   de codigos de la documentacion [F9] ni en el enum errorModel del OpenAPI [F21], que son
#   las dos listas cerradas que el proveedor publica. La cifra sale del CUERPO del error, no
#   del codigo HTTP (regla 7 del encargo), asi que hay que alcanzar el 429 y leerlo.
#   Y de paso, sin coste adicional:
#     - el tope real de "All other endpoints": 100 RPH (General), 200 (Advanced) o 600
#       (Extended) [F6]. Aqui SI se ven los dos lados -- la peticion N aceptada y la N+1
#       rechazada -- porque son GET de lectura, no envios. Es la unica medida de esta pasada
#       que puede sostener un VERDE por E-D024 (el sondeo alcanza la respuesta de rechazo).
#     - DISC-13: el valor de x-sib-ratelimit-reset en el instante del 429, sobre un endpoint
#       declarado SOLO en RPH. Si la unidad es el segundo, tiene que rondar los 3.600.
#     - si Brevo manda Retry-After, que ninguna de las dos paginas de caudal menciona.
#     - si el bucket del comodin es por FILA o por RUTA: despues del 429 se leen
#       GET /v3/account (misma fila "All other"), GET /v3/smtp/templates (fila del prefijo)
#       y GET /v3/smtp/emails (fila propia).
#
# COSTE EN ENVIOS: 0. Presupuesto: hasta 133 peticiones, TODAS GET inocuos.
#   Este script NO toca ningun endpoint de envio, asi que no puede gastar cuota de correo
#   ni por accidente.
#   LO QUE SI CUESTA, y por eso va ULTIMO DE TODA LA PASADA: agota a proposito el bucket de
#   "All other endpoints". Mientras no se reponga la ventana -- hasta una hora, 3.600 s --
#   GET /v3/account y GET /v3/senders devolveran 429.
#
#   TIENEN QUE ESTAR YA EJECUTADOS, y el ultimo de la lista es el que importa:
#     - probe_brevo_a_cuenta.sh          (2 lecturas de GET /v3/account)
#     - probe_brevo_a_caudal_cabeceras.sh
#     - probe_brevo_a_unidad_reset.sh
#     - **el PAQUETE B COMPLETO**, y en particular probe_brevo_b_unidad_cuota.sh, cuya
#       medicion ENTERA son cuatro lecturas de GET /v3/account -- que vive en esta misma
#       fila, como demuestra el caso z01_account_misma_fila de aqui abajo -- y que es el
#       sondeo que gasta correo IRREVERSIBLE. Si el paquete B arranca dentro de la ventana
#       del 429, sus lecturas vuelven vacias, 'credits' es ilegible y el envio se gastaria
#       sin medir nada. La espera de ese sondeo entre lecturas son 90 s y la ventana del
#       429 son hasta 3.600: no se recupera solo.
#   La version anterior de esta nota solo nombraba a los tres sondeos del paquete A, que son
#   los que menos pierden. El que paga es el B.
#   Duracion: ~2 minutos.
#
# DESTINATARIOS (D-046): ninguno. No hay peticiones de envio. La lista blanca literal
#   -- persona-3@example.invalid, persona-1@example.invalid, persona-2@example.invalid -- no se usa.
#
# USO
#   bash probe_brevo_a_cuerpo_429.sh [MAX=133]
#   Lee BREVO_API_KEY de ~/.config/tfm/.env. Para el bucle en el primer 429; MAX es solo el
#   tope de seguridad por si el 429 no llega (tramo Extended: 600 RPH, y entonces el sondeo
#   NO alcanza el rechazo y hay que subir MAX a conciencia).
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

# La PARADA la mira TODO sondeo del paquete, no solo los que postean: un envio aceptado
# donde no debia invalida la pasada entera, y lo que se hace con el es mirarlo, no seguir
# midiendo alrededor.
parada_comprobar
# El libro tiene que poder ESCRIBIR, y se comprueba antes de la primera llamada. Con el
# libro presente pero no escribible -- 400, disco lleno, sistema de ficheros en solo lectura
# -- el append fallaba con un "Permiso denegado" que nadie miraba, reservar() devolvia 0 y
# el contador volvia a leer 0: cada llamada creia tener el tope entero libre.
libro_exige_escritura

readonly BASE="https://api.brevo.com/v3"
MAX="${1:-133}"
readonly RUTA="/senders"
D="$(mktemp -d "${TMPDIR:-/tmp}/brevo_a_429_XXXXXX")" || { echo "ABORTA: no se pudo crear el directorio de trabajo." >&2; exit 3; }
[[ -d $D && -w $D ]] || { echo "ABORTA: el directorio de trabajo '$D' no existe o no acepta escrituras." >&2; exit 3; }
# El JSON va a 03_datos/apis/brevo/evidencias/ si esa carpeta existe, igual que hacen los
# dos sondeos del paquete B. Antes caia junto al script y la ultima linea imprimia una ruta a
# evidencias/ a la que nadie lo llevaba: quien seguia esa linea y movia el fichero dejaba a
# probe_brevo_a_destinatarios.sh y probe_brevo_a_tamano.sh abortando por falta de preflight,
# porque guarda_elegida lo buscaba solo junto al script.
SAL="$AQUI"
[ -d "$AQUI/../../03_datos/apis/brevo/evidencias" ] &&
  SAL="$(CDPATH='' cd -- "$AQUI/../../03_datos/apis/brevo/evidencias" && pwd)"
OUT="$SAL/probe_brevo_a_cuerpo_429_$(date -u +%Y-%m-%d_%H%M%S).json"
ORDEN=""

echo "== PRESUPUESTO DECLARADO (D-046 condicion 2) =="
echo "   Envios reales de correo ................ 0  (no hay ninguna peticion de envio)"
echo "   Peticiones ............................. hasta $MAX GET a $RUTA + 3 lecturas finales"
echo "   Efecto colateral ....................... agota el bucket 'All other endpoints'"
echo "                                            (100 RPH en General) hasta una hora"
echo "   Pausa entre llamadas ................... 1 s"
echo

resumir() {
  if [ -f "$D/.resumido" ]; then return 0; fi
  : > "$D/.resumido"
  CLAVE="${BREVO_API_KEY:-}" CLAVE2="${BREVO_API_KEY_2:-}" \
  FROM="${BREVO_FROM:-}" TO="${BREVO_TO:-}" \
  python3 -I - "$D" "$OUT" "$ORDEN" "$RUTA" <<'PY'
import sys,json,os,re as _re
d,out,orden,ruta=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4]
def cab(p):
    h={}
    if not os.path.exists(p): return h
    for l in open(p,errors="replace"):
        if ":" in l and not l.upper().startswith("HTTP/"):
            k,v=l.split(":",1); h[k.strip().lower()]=v.strip()
    return h
def num(x):
    try: return int(str(x).strip())
    except Exception: return None
casos=[]
for c in [x for x in orden.split(",") if x]:
    if not os.path.exists(d+"/"+c+".code"): continue
    crudo=open(d+"/"+c+".body",errors="replace").read()
    try: cuerpo=json.loads(crudo)
    except Exception: cuerpo=None
    h=cab(d+"/"+c+".hdr")
    m=(open(d+"/"+c+".meta").read().rstrip("\n").split("\t")+[""]*6)[:6]
    casos.append({"caso":c,"ruta":m[1],"descripcion":m[2],"inicio_utc":m[3],
      "http":int(open(d+"/"+c+".code").read().strip() or 0),
      "limit":num(h.get("x-sib-ratelimit-limit")),
      "remaining":num(h.get("x-sib-ratelimit-remaining")),
      "reset":h.get("x-sib-ratelimit-reset"),
      "retry_after":h.get("retry-after"),"date":h.get("date"),
      "error_code":cuerpo.get("code") if isinstance(cuerpo,dict) else None,
      "error_message":cuerpo.get("message") if isinstance(cuerpo,dict) else None,
      # El CUERPO ENTERO: la cita literal de DISC-12 sale de aqui (regla 7 del encargo).
      "cuerpo_crudo":crudo if len(crudo)<=8000 else crudo[:8000]+"...[truncado]",
      "cabeceras_caudal":{k:v for k,v in h.items() if k.startswith("x-sib-ratelimit")}})
bucle=[c for c in casos if c["ruta"]==ruta]
r429=[c for c in bucle if c["http"]==429]
ok=[c for c in bucle if 200<=c["http"]<300]
primero=r429[0] if r429 else None
ultimo_ok=ok[-1] if ok else None
# Las dos listas cerradas que Brevo publica: [F9] (tabla de codigos) y [F21] (enum
# errorModel del OpenAPI). 'too_many_requests' de [F28] no esta en ninguna.
ENUM_F21=("invalid_parameter","missing_parameter","out_of_range","campaign_processing",
  "not_enough_credits","permission_denied","duplicate_parameter","duplicate_request",
  "method_not_allowed","unauthorized","account_under_validation","not_acceptable",
  "bad_request","unprocessable_entity")
if not primero:
    v12=("no alcanzado: el 429 no llego en %d peticiones. Si el tramo es Extended (600 RPH) "
         "hace falta mas presupuesto; DISC-12 se queda abierta y el cuerpo del 429 sin "
         "medir"%len(bucle))
    v_tope="no medible sin el rechazo"
else:
    cod=primero.get("error_code")
    if cod=="too_many_requests":
        v12=("[F28] acertaba: code='too_many_requests', que NO esta en el enum errorModel "
             "de [F21] ni en la tabla de [F9]. Las dos listas cerradas que el proveedor "
             "publica estan incompletas, y eso es material de friccion, no solo un dato")
    elif cod in ENUM_F21:
        v12=("code='%s', que SI esta en el enum de [F21]: [F28] publica un valor que la API "
             "no devuelve"%cod)
    elif cod is None:
        v12=("el 429 no trae un {code,message} JSON. Cuerpo literal en 'cuerpo_del_429'")
    else:
        v12=("code='%s': no esta ni en [F21] ni en [F28]. Tercer valor, y el hueco crece"%cod)
    n=len(ok)
    L=sorted({c["limit"] for c in bucle if c["limit"] is not None})
    rem0=bucle[0]["remaining"] if bucle else None
    fila={100:"los 100 RPH del tramo General [F6]",
          200:"los 200 RPH del tramo Advanced [F6]",
          600:"los 600 RPH del tramo Extended [F6]"}
    # OJO: las aceptadas de ESTE bucle no son el tope de la ventana. Los otros sondeos del
    # paquete A ya gastaron parte del bucket, asi que el tope se lee en la cabecera y el
    # par (ultima aceptada / primer 429) demuestra que ese numero es el que se aplica.
    v_tope=("el 429 llego tras %d aceptadas en este bucle, con remaining=%s en la primera "
            "peticion (%s). El tope de la ventana es el de la cabecera, %s -> %s. Lo que "
            "el par (ultima aceptada / primer 429) demuestra es que remaining llega a 0 y "
            "el rechazo cae justo ahi, asi que por E-D024 el valor puede ir en VERDE. Las "
            "aceptadas de este bucle NO son el tope: los otros sondeos de la pasada ya "
            "habian gastado parte del bucket."%(n,rem0,
            "coherente" if (rem0 is not None and n==rem0+1) else
            "revisar: n no cuadra con remaining+1",
            L or "sin cabecera",
            ", ".join(fila.get(x,"ninguna fila publicada de [F6]") for x in L) or "-"))
post={c["caso"]:{"ruta":c["ruta"],"http":c["http"],"limit":c["limit"],
        "remaining":c["remaining"],"error_code":c["error_code"]}
      for c in casos if c["caso"].startswith("z")}
if post:
    mismo=post.get("z01_account_misma_fila",{}).get("http")
    otra1=post.get("z02_smtp_templates_prefijo",{}).get("http")
    otra2=post.get("z03_smtp_emails_fila_propia",{}).get("http")
    v_bucket=("el comodin es un bucket por FILA: GET /v3/account, que comparte fila con "
      "/v3/senders, tambien da 429") if mismo==429 else \
      ("el contador es por RUTA: /v3/senders da 429 y /v3/account sigue respondiendo %s"%mismo)
    v_bucket+=" | prefijo /v3/smtp/: %s | fila propia de emails: %s"%(otra1,otra2)
else:
    v_bucket="no medido"
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
resumen={"api":"brevo","paquete":"A (cero envios)","sondeo":"cuerpo_429",
  "fecha_utc":casos[0]["inicio_utc"] if casos else None,
  "envios_reales":envios_calculados,
  "unidad_de_envios_reales":("destinatarios de las peticiones ACEPTADAS (2xx), que es la "
    "unidad con la que el libro de cuentas reserva y gasta. Calculado, no declarado"),
  "peticiones":len(casos),"peticiones_de_envio":0,
  "invariante_cero_envios":"CUMPLIDA",
  "endpoint_del_bucle":ruta,"aceptadas":len(ok),"rechazos_429":len(r429),
  "limit_declarado_en_cabecera":sorted({c["limit"] for c in bucle if c["limit"] is not None}),
  "ultima_aceptada":{"indice":len(ok),"remaining":(ultimo_ok or {}).get("remaining"),
    "date":(ultimo_ok or {}).get("date")} if ultimo_ok else None,
  "cuerpo_del_429":(primero or {}).get("cuerpo_crudo"),
  "code_del_429":(primero or {}).get("error_code"),
  "message_del_429":(primero or {}).get("error_message"),
  "retry_after_del_429":(primero or {}).get("retry_after"),
  "reset_del_429":(primero or {}).get("reset"),
  "veredicto_DISC_12":v12,
  "veredicto_tope_all_other_endpoints":v_tope,
  "para_DISC_13":("reset en el instante del 429 sobre un endpoint declarado SOLO en RPH: "
    "%s. Si la unidad es el segundo, una ventana de una hora tiene que dar un valor "
    "proximo a 3.600"%((primero or {}).get("reset"))),
  "lecturas_despues_del_429":post,"veredicto_alcance_del_bucket":v_bucket,
  "lo_que_esto_NO_demuestra":("El tope medido es el de esta cuenta y esta fila. No dice nada "
    "del tope del endpoint de envio: ese esta tres ordenes de magnitud mas arriba (1.000 RPS "
    "en General [F6]) y forzarlo exigiria miles de peticiones, asi que DISC-01 se cierra "
    "leyendo la cabecera, no provocando el rechazo.")}
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
  echo "AVISO: el bucket 'All other endpoints' queda agotado hasta que se reponga la"
  echo "       ventana -- hasta una hora. Hasta entonces NO relanzar:"
  echo "         - probe_brevo_a_cuenta.sh, _caudal_cabeceras.sh, _unidad_reset.sh"
  echo "         - y sobre todo probe_brevo_b_unidad_cuota.sh, cuya medicion entera son"
  echo "           lecturas de GET /v3/account (misma fila) y que gasta correo real: con el"
  echo "           429 puesto, el envio se gastaria sin poder medir el delta. Ese sondeo"
  echo "           aborta solo si la linea base no esta, pero la espera hay que darla."
  echo "JSON: $OUT"
  echo "   (03_datos/apis/brevo/evidencias/ si existe; si no, junto al script)"
  rm -rf "$D"
}
trap resumir EXIT

llamar_get() {
  caso="$1"; ruta="$2"; desc="$3"
  t0="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
  code="$(curl_brevo "$BREVO_API_KEY" -sS --max-time 30 -o "$D/$caso.body" -D "$D/$caso.hdr" -w '%{http_code}' \
    -H "accept: application/json" \
    -X GET "$BASE$ruta")" || code="000"
  echo "$code" > "$D/$caso.code"
  printf 'GET\t%s\t%s\t%s\t-\t0\n' "$ruta" "$desc" "$t0" > "$D/$caso.meta"
  ORDEN="$ORDEN$caso,"
  ULTIMO_CODE="$code"
}

I=0
ULTIMO_CODE=""
echo "-- bucle sobre GET /v3$RUTA hasta el primer 429 (tope de seguridad: $MAX)"
while [ "$I" -lt "$MAX" ]; do
  I=$((I+1))
  llamar_get "$(printf 'a%03d' "$I")" "$RUTA" "peticion $I del bucle"
  REM="$(grep -i '^x-sib-ratelimit-remaining:' "$D/$(printf 'a%03d' "$I").hdr" | tr -d '\r' | cut -d' ' -f2-)"
  printf '   %3d  HTTP %s  remaining=%s\n' "$I" "$ULTIMO_CODE" "$REM"
  if [ "$ULTIMO_CODE" = "429" ]; then
    echo "   429 alcanzado en la peticion $I"
    break
  fi
  sleep 1
done

if [ "$ULTIMO_CODE" != "429" ]; then
  echo "   AVISO: el 429 no llego en $MAX peticiones. DISC-12 se queda sin medir."
fi

echo "-- lecturas de despues del 429: el bucket es por fila o por ruta?"
llamar_get z01_account_misma_fila       "/account"                "misma fila 'All other endpoints' que /v3/senders"
sleep 1
llamar_get z02_smtp_templates_prefijo   "/smtp/templates?limit=1" "fila del prefijo /v3/smtp/{...}, 300 RPH"
sleep 1
llamar_get z03_smtp_emails_fila_propia  "/smtp/emails?limit=1"    "fila propia de GET /v3/smtp/emails"
printf '   z01 HTTP %s\n' "$(cat "$D/z01_account_misma_fila.code")"
printf '   z02 HTTP %s\n' "$(cat "$D/z02_smtp_templates_prefijo.code")"
printf '   z03 HTTP %s\n' "$(cat "$D/z03_smtp_emails_fila_propia.code")"
