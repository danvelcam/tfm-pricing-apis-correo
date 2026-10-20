#!/usr/bin/env bash
# Sondeo empirico Brevo (escalon 3) - PAQUETE A, CERO ENVIOS - preparado el 2026-09-17
#
# PREGUNTA QUE RESUELVE
#   Cuanto caudal tiene DE VERDAD esta cuenta, fila por fila de [F6]. Brevo devuelve
#   x-sib-ratelimit-limit "in all responses, not just 429 errors" [F7], asi que el tope
#   vigente se lee sin forzar el 429 y sin gastar un envio. Cierra:
#     DISC-01  POST /v3/smtp/email: 3.600.000 RPH [F6] o 6.000/hora [F13] (factor 600)
#     DISC-02  el caudal del lote: 100 llamadas/min [F13] o 5 [F28] (factor 200)
#     DISC-15  a que TRAMO va esta cuenta (General / Advanced / Extended): la huella de
#              los cinco topes observados solo encaja con una de las tres tablas de [F6]
#     DISC-17  GET /v3/smtp/emails: 7.200 RPH de su fila propia, o 300 RPH del prefijo
#              /v3/smtp/{...} que la nota al pie NO la exime. El par decisivo es
#              emails (fila propia) contra templates (solo prefijo)
#     hueco 27 el caudal efectivo del Free: contrasta el tope leido en el endpoint de
#              envio con los creditos diarios que devuelve GET /v3/account
#     Q12      la fila compartida (POST /v3/smtp/email + GET /v3/smtp/blockedContacts):
#              un cubo unico o un contador por ruta. Se ve en la triada rapida del final
#
# COSTE EN ENVIOS: 0 ENTREGADOS. Presupuesto: 10 peticiones.
#   8 GET inocuos y 2 POST a /v3/smtp/email que NO pueden ser aceptados (llevan guarda:
#   remitente en dominio sin MX y destinatario en el sumidero). Un 2xx en el endpoint de
#   envio aborta el script en el acto, lo anota en el libro compartido y pone la PARADA del
#   paquete: la invariante del paquete A es que ninguna peticion de envio sea aceptada,
#   porque una aceptada PUEDE gastar credito y generar un rebote. Que una peticion aceptada
#   en sandbox descuente saldo o no es la pregunta de probe_brevo_b_unidad_cuota.sh y aqui
#   NO se afirma en ninguna de las dos direcciones -- la cabecera de este fichero decia
#   antes que si y la de probe_brevo_a_destinatarios.sh que no, y las dos sin medir.
#   Buckets que se consumen: 2 del prefijo /v3/smtp/{...} (300 RPH), 2 de "All other
#   endpoints" (100 RPH), 1 de /v3/contacts/{...}, 5 de la fila compartida del envio.
#
# DESTINATARIOS (D-046): la lista blanca literal es persona-3@example.invalid,
#   persona-1@example.invalid y persona-2@example.invalid. Este script NO usa ninguna: los dos POST
#   van a @example.invalid (sin MX), que D-046 declara verde y via preferente. La
#   comprobacion la hace el script antes de cada llamada, no el modo de la cuenta.
#
# USO
#   bash probe_brevo_a_caudal_cabeceras.sh        (lee BREVO_API_KEY de ~/.config/tfm/.env)
#   Correr DESPUES de probe_brevo_a_preflight_rechazo.sh y ANTES de
#   probe_brevo_a_cuerpo_429.sh, que agota el bucket de 100 RPH durante una hora.
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
# Por control_valido: la vara de medir, consultada DENTRO del bucle. Este sondeo no
# usa guarda_elegida -- su guarda es fija -- pero si necesita saber si el caso de
# control dejo un 4xx explicito antes de mandar el caso que escala.
. "$AQUI/lib_guarda_preflight_brevo.sh"
: "${BREVO_API_KEY:?}"
brevo_clave_valida "$BREVO_API_KEY" || {
  echo "ABORTA: BREVO_API_KEY tiene caracteres fuera de [A-Za-z0-9_.:-]." >&2; exit 3; }

readonly BASE="https://api.brevo.com/v3"
readonly SUMIDERO="example.invalid"
D="$(mktemp -d "${TMPDIR:-/tmp}/brevo_a_caudal_XXXXXX")" || { echo "ABORTA: no se pudo crear el directorio de trabajo." >&2; exit 3; }
[[ -d $D && -w $D ]] || { echo "ABORTA: el directorio de trabajo '$D' no existe o no acepta escrituras." >&2; exit 3; }
# El JSON va a 03_datos/apis/brevo/evidencias/ si esa carpeta existe, igual que hacen los
# dos sondeos del paquete B. Antes caia junto al script y la ultima linea imprimia una ruta a
# evidencias/ a la que nadie lo llevaba: quien seguia esa linea y movia el fichero dejaba a
# probe_brevo_a_destinatarios.sh y probe_brevo_a_tamano.sh abortando por falta de preflight,
# porque guarda_elegida lo buscaba solo junto al script.
SAL="$AQUI"
[ -d "$AQUI/../../03_datos/apis/brevo/evidencias" ] &&
  SAL="$(CDPATH='' cd -- "$AQUI/../../03_datos/apis/brevo/evidencias" && pwd)"
OUT="$SAL/probe_brevo_a_caudal_cabeceras_$(date -u +%Y-%m-%d_%H%M%S).json"
ORDEN=""
ABORTO=""

parada_comprobar
# El libro tiene que poder ESCRIBIR, y se comprueba antes de la primera llamada. Con el
# libro presente pero no escribible -- 400, disco lleno, sistema de ficheros en solo lectura
# -- el append fallaba con un "Permiso denegado" que nadie miraba, reservar() devolvia 0 y
# el contador volvia a leer 0: cada llamada creia tener el tope entero libre.
libro_exige_escritura

echo "== PRESUPUESTO DECLARADO (D-046 condicion 2) =="
echo "   Envios ENTREGADOS ...................... 0  (invariante del paquete A; un 2xx"
echo "                                              aborta, se anota en el libro y pone"
echo "                                              la PARADA del paquete)"
echo "   Consumo de cuota en sandbox ............ NO MEDIDO -- lo mide el paquete B,"
echo "                                              probe_brevo_b_unidad_cuota.sh"
echo "   Comprometidos en la ventana ............ $(libro_comprometido) de $(libro_tope_efectivo)   (la pasada son 24 horas)"
echo "   Peticiones ............................. 10  (8 GET inocuos + 2 POST con guarda)"
echo "   Destinatarios .......................... solo @$SUMIDERO; lista blanca NO usada"
echo "   Unidad del libro ....................... el DESTINATARIO. Los dos POST llevan 1"
echo "                                              cada uno: se reservan antes de llamar"
echo "                                              y se liberan con el 4xx explicito"
echo "   Pausa entre llamadas ................... 2 s (la triada final va sin pausa, a proposito)"
echo

resumir() {
  if [ -f "$D/.resumido" ]; then return 0; fi
  : > "$D/.resumido"
  CLAVE="${BREVO_API_KEY:-}" CLAVE2="${BREVO_API_KEY_2:-}" \
  FROM="${BREVO_FROM:-}" TO="${BREVO_TO:-}" SUMIDERO="$SUMIDERO" \
  python3 -I - "$D" "$OUT" "$ORDEN" "$ABORTO" <<'PY'
import sys,json,os,datetime,re as _re
d,out,orden,aborto=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4]
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
    casos.append({"caso":c,"metodo":m[0],"ruta":m[1],"descripcion":m[2],
      "inicio_utc":m[3],"fin_utc":m[4],"bytes_peticion":int(m[5] or 0),
      "http":int(open(d+"/"+c+".code").read().strip() or 0),
      "limit":num(h.get("x-sib-ratelimit-limit")),
      "remaining":num(h.get("x-sib-ratelimit-remaining")),
      "reset":h.get("x-sib-ratelimit-reset"),
      "date":h.get("date"),"retry_after":h.get("retry-after"),
      "cabeceras_caudal":{k:v for k,v in h.items() if k.startswith("x-sib-ratelimit")},
      "error_code":cuerpo.get("code") if isinstance(cuerpo,dict) else None,
      "error_message":cuerpo.get("message") if isinstance(cuerpo,dict) else None,
      # El cuerpo entero, que es de donde sale la cita literal (regla 7 del encargo).
      "cuerpo_crudo":crudo if len(crudo)<=20000 else crudo[:20000]+"...[truncado]"})
por={c["caso"]:c for c in casos}
def lim(c): return por[c]["limit"] if c in por else None
# Las tres tablas de [F6], tal como estan citadas en fuentes.md. RPH / RPS por fila.
TRAMOS={
 "general": {"envio":(3600000,1000),"emails":(7200,2),"prefijo_smtp":(300,None),
             "contactos":(36000,10),"otros":(100,None)},
 "advanced":{"envio":(7200000,2000),"emails":(10800,3),"prefijo_smtp":(600,None),
             "contactos":(72000,20),"otros":(200,None)},
 "extended":{"envio":(None,6000),"emails":(18000,None),"prefijo_smtp":(1800,None),
             "contactos":(None,60),"otros":(600,None)}}
FILA={"m01_get_smtp_emails":"emails","m02_get_smtp_templates":"prefijo_smtp",
      "m03_get_smtp_blockedcontacts":"envio","m04_get_contacts":"contactos",
      "m05_get_account":"otros","m06_get_senders":"otros",
      "m07_post_smtp_email_rechazada":"envio"}
encaje={}
for caso,fila in FILA.items():
    v=lim(caso)
    if v is None: continue
    encaje[caso]={"fila_de_F6":fila,"limit_observado":v,
      "encaja_con":[t for t,f in TRAMOS.items() if v in [x for x in f[fila] if x is not None]]}
votos={}
for k,v in encaje.items():
    for t in v["encaja_con"]: votos[t]=votos.get(t,0)+1
# DISC-17: el par decisivo.
e,t=lim("m01_get_smtp_emails"),lim("m02_get_smtp_templates")
if e is None or t is None:
    v17="no medible: falta la cabecera en uno de los dos casos del par"
elif e==t:
    v17=("el prefijo /v3/smtp/{...} SI alcanza a GET /v3/smtp/emails: los dos topes "
         "observados coinciden (%s). El fichero sobrestima esa ruta y la lectura "
         "conservadora de Q11 (bajarla a 300/HORA) queda respaldada"%e)
else:
    v17=("la fila propia manda: GET /v3/smtp/emails observa %s y GET /v3/smtp/templates "
         "(solo prefijo) observa %s, asi que la nota al pie de [F6] no la alcanza"%(e,t))
# DISC-01 y DISC-02.
env=lim("m07_post_smtp_email_rechazada") or lim("m03_get_smtp_blockedcontacts")
if env is None:
    v01="no medible: POST /v3/smtp/email no devolvio x-sib-ratelimit-limit en la respuesta de error"
else:
    v01={1000:"coincide con los 1.000 RPS de la tabla General [F6]",
         3600000:"coincide con los 3.600.000 RPH de la tabla General [F6]",
         2000:"coincide con los 2.000 RPS de la tabla Advanced [F6]",
         7200000:"coincide con los 7.200.000 RPH de la tabla Advanced [F6]",
         6000:"coincide con los 6.000 RPS de la tabla Extended [F6] -- y tambien con las "
              "6.000 llamadas/hora de [F13]: la cifra sola NO desempata DISC-01, hay que "
              "leer la ventana en x-sib-ratelimit-reset",
         100:"no es ninguna fila del envio: son los 100 RPH de 'All other endpoints'",
        }.get(env,"no coincide con ninguna fila publicada de [F6]")
    v01="limit=%s -> %s"%(env,v01)
# hueco 27: caudal contra cuota diaria.
cred=None
cb=por.get("m05_get_account",{}).get("cuerpo_crudo") or ""
try:
    ja=json.loads(cb)
    cred=[p for p in (ja.get("plan") or []) if isinstance(p,dict)]
except Exception: pass
h27={"creditos_del_plan":cred,"limit_en_el_endpoint_de_envio":env,
  "lectura":("Si el tope de caudal del envio es de miles por segundo y la cuota del plan "
             "es de cientos al dia, el caudal publicado no es alcanzable ni una vez: la "
             "cuota muerde antes. Eso es el hueco 27 y se dice con las dos cifras juntas.")}
# Q12: la fila compartida.
a,b,c3=por.get("q12a_blocked_antes"),por.get("q12b_post_envio"),por.get("q12c_blocked_despues")
if not (a and b and c3) or None in (a["remaining"],c3["remaining"]):
    q12="no medible: falta remaining en la triada"
else:
    caida=a["remaining"]-c3["remaining"]
    q12={"limit":a["limit"],"remaining_antes":a["remaining"],
      "remaining_despues":c3["remaining"],"caida":caida,
      "segundo_servidor":[a["date"],b["date"],c3["date"]],
      "veredicto":("cubo compartido: la caida es de %d con dos peticiones de por medio "
                   "(el GET y el POST)"%caida) if caida>=2 else
                  ("contador por ruta: la caida es de %d, el POST no descuenta del "
                   "contador del GET"%caida),
      "reserva":("si limit es un tope por SEGUNDO y las tres llamadas no caen en el mismo "
                 "segundo de servidor, la comparacion no vale: mirar la lista de 'date'")}
aceptadas=[c["caso"] for c in casos if c["metodo"]=="POST" and 200<=c["http"]<300]
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
resumen={"api":"brevo","paquete":"A (cero envios)","sondeo":"caudal_cabeceras",
  "fecha_utc":casos[0]["inicio_utc"] if casos else None,
  "envios_reales":envios_calculados,
  "unidad_de_envios_reales":("destinatarios de las peticiones ACEPTADAS (2xx), que es la "
    "unidad con la que el libro de cuentas reserva y gasta. Calculado, no declarado"),
  "peticiones":len(casos),
  "peticiones_de_envio_aceptadas_2xx":aceptadas,
  "invariante_cero_envios":"CUMPLIDA" if not aceptadas else "ROTA",
  "abortado_en":aborto or None,
  "cabeceras_por_caso":{c["caso"]:{"http":c["http"],"limit":c["limit"],
    "remaining":c["remaining"],"reset":c["reset"]} for c in casos},
  "la_cabecera_viene_en_respuestas_de_error":bool(
    por.get("m07_post_smtp_email_rechazada",{}).get("cabeceras_caudal")),
  "encaje_con_las_tablas_de_F6":encaje,"votos_por_tramo":votos,
  "veredicto_DISC_15_tramo":(max(votos,key=votos.get) if votos else
    "no medible: ninguna cabecera legible"),
  "veredicto_DISC_17":v17,"veredicto_DISC_01_y_02":v01,
  "veredicto_hueco_27":h27,"veredicto_Q12_fila_compartida":q12,
  "lo_que_esto_NO_demuestra":("x-sib-ratelimit-limit da el tope vigente, no la ventana. "
    "Con una sola cifra no se distingue 6.000 por segundo de 6.000 por hora: eso lo separa "
    "probe_brevo_a_unidad_reset.sh. Y por E-D024 un contador leido sin alcanzar el 429 "
    "sube el campo a AMBAR, no a verde.")}
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

construir_envio() {
  python3 -I - "$D/$1.req" "$SUMIDERO" <<'PY'
import json,sys,time
out,sumi=sys.argv[1],sys.argv[2]
# GUARDA: remitente en dominio sin MX (no verificable como remitente de la cuenta) y un
# destinatario en el sumidero. La peticion tiene que ser rechazada; solo interesan sus
# cabeceras de caudal. El nonce evita 'duplicate_request' [F9].
json.dump({"sender":{"name":"TFM sonda","email":"sonda-remitente@%s"%sumi},
  "to":[{"email":"sonda-00001@%s"%sumi}],
  "subject":"TFM sonda caudal %d"%time.time_ns(),
  "htmlContent":"<html><body><p>sonda TFM paquete A, cero envios</p></body></html>"},
  open(out,"w"))
PY
}

verificar_destinatarios() {  # $1 caso  $2 destinatarios esperados
  python3 -I - "$D/$1.req" "$SUMIDERO" "$2" <<'PY'
import json,sys
req,sumi,esperados=sys.argv[1],sys.argv[2],int(sys.argv[3])
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
                 "ENVIOS y no entrega a buzones reales."%l)
    if l.count("@")!=1 or not l.endswith("@"+sumi):
        sys.exit("ABORTA: destinatario fuera del sumidero sin MX (@%s): %s"%(sumi,l))
# Y tantos como el libro va a reservar: un cuerpo con mas destinatarios que la reserva gasta
# mas de lo comprometido.
if len(dest)!=esperados:
    sys.exit("ABORTA: el cuerpo lleva %d destinatarios y se van a reservar %d."
             %(len(dest),esperados))
PY
}

llamar_get() {
  caso="$1"; ruta="$2"; desc="$3"
  t0="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
  code="$(curl_brevo "$BREVO_API_KEY" -sS --max-time 45 -o "$D/$caso.body" -D "$D/$caso.hdr" -w '%{http_code}' \
    -H "accept: application/json" \
    -X GET "$BASE$ruta")" || code="000"
  t1="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
  echo "$code" > "$D/$caso.code"
  printf 'GET\t%s\t%s\t%s\t%s\t0\n' "$ruta" "$desc" "$t0" "$t1" > "$D/$caso.meta"
  ORDEN="$ORDEN$caso,"
  printf '   %-34s HTTP %s  limit=%s remaining=%s reset=%s\n' "$caso" "$code" \
    "$(grep -i '^x-sib-ratelimit-limit:' "$D/$caso.hdr" | tr -d '\r' | cut -d' ' -f2-)" \
    "$(grep -i '^x-sib-ratelimit-remaining:' "$D/$caso.hdr" | tr -d '\r' | cut -d' ' -f2-)" \
    "$(grep -i '^x-sib-ratelimit-reset:' "$D/$caso.hdr" | tr -d '\r' | cut -d' ' -f2-)"
}

# Los dos POST de este sondeo llevan UN destinatario, y el libro cuenta en destinatarios
# desde el 2026-09-17: se reserva 1 antes de llamar y se libera con el 4xx. La cifra sale de
# construir_envio(), que escribe un solo "to", y verificar_destinatarios() la comprueba sobre
# el cuerpo ya escrito, asi que no hay constante que pueda desincronizarse.
llamar_envio() {
  caso="$1"; desc="$2"
  construir_envio "$caso" || exit 2
  verificar_destinatarios "$caso" 1 || exit 2
  if ! libro_cabe 1; then
    echo "!!! ABORTA: no queda margen en el libro ni para un destinatario (margen" >&2
    echo "!!! $(libro_margen) de $(libro_tope_efectivo)). DISC-01 y DISC-02 se quedan sin" >&2
    echo "!!! medir por la via del POST rechazado; las filas de GET ya estan en el JSON." >&2
    ABORTO="$caso"
    exit 4
  fi
  reservar "$caso" 1
  t0="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
  code="$(curl_brevo "$BREVO_API_KEY" -sS --max-time 45 -o "$D/$caso.body" -D "$D/$caso.hdr" -w '%{http_code}' \
    -H "accept: application/json" -H "content-type: application/json" \
    -H "X-Sib-Sandbox: drop" \
    -X POST "$BASE/smtp/email" --data-binary @"$D/$caso.req")" || code="000"
  t1="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
  echo "$code" > "$D/$caso.code"
  printf 'POST\t/v3/smtp/email\t%s\t%s\t%s\t%s\n' "$desc" "$t0" "$t1" "$(wc -c < "$D/$caso.req")" > "$D/$caso.meta"
  ORDEN="$ORDEN$caso,"
  printf '   %-34s HTTP %s  limit=%s remaining=%s reset=%s\n' "$caso" "$code" \
    "$(grep -i '^x-sib-ratelimit-limit:' "$D/$caso.hdr" | tr -d '\r' | cut -d' ' -f2-)" \
    "$(grep -i '^x-sib-ratelimit-remaining:' "$D/$caso.hdr" | tr -d '\r' | cut -d' ' -f2-)" \
    "$(grep -i '^x-sib-ratelimit-reset:' "$D/$caso.hdr" | tr -d '\r' | cut -d' ' -f2-)"
  # DOS lecturas, no tres: 4xx explicito = rechazo demostrado y el sondeo sigue; cualquier
  # otra cosa -- 000, 5xx, cuerpo vacio, timeout -- es "no se sabe", y no saberlo se paga.
  paquete_a_cerrar "$caso" "$code" 1 || { RC=$?; ABORTO="$caso"; exit "$RC"; }
}

echo "-- matriz de filas de [F6], una llamada por fila"
llamar_get m01_get_smtp_emails          "/smtp/emails?limit=1"          "fila propia 7.200 RPH / 2 RPS (DISC-17 A, DISC-15)"; sleep 2
llamar_get m02_get_smtp_templates       "/smtp/templates?limit=1"       "solo prefijo /v3/smtp/{...} 300 RPH (DISC-17 B)"; sleep 2
llamar_get m03_get_smtp_blockedcontacts "/smtp/blockedContacts?limit=1" "fila compartida con el envio 3.600.000 RPH / 1.000 RPS"; sleep 2
llamar_get m04_get_contacts             "/contacts?limit=1"             "fila /v3/contacts/{...} 36.000 RPH / 10 RPS"; sleep 2
llamar_get m05_get_account              "/account"                      "All other endpoints 100 RPH + creditos del plan (hueco 27)"; sleep 2
llamar_get m06_get_senders              "/senders"                      "par de la fila All other endpoints"; sleep 2
llamar_envio m07_post_smtp_email_rechazada "endpoint de envio, peticion rechazada (DISC-01, DISC-02)"; sleep 2

echo "-- triada rapida, sin pausa, para Q12 (fila compartida: cubo unico o por ruta)"
llamar_get q12a_blocked_antes "/smtp/blockedContacts?limit=1" "remaining antes del POST"
llamar_envio q12b_post_envio  "POST de envio rechazado entre las dos lecturas"
llamar_get q12c_blocked_despues "/smtp/blockedContacts?limit=1" "remaining despues del POST"
