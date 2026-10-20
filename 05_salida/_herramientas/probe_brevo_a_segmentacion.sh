#!/usr/bin/env bash
# Sondeo empirico Brevo (escalon 3) - PAQUETE A, CERO ENVIOS - preparado el 2026-09-17
#
# PREGUNTA QUE RESUELVE
#   Hueco 8 de fuentes.md: el caudal se cuenta por CUENTA o por CLAVE. [F7] dice que
#   "This value depends on your account plan and the specific endpoint", y no dice nada de
#   la credencial. Importa para el modelado: si el contador es por clave, el caudal de la
#   datasheet es por credencial y una integracion con dos claves tiene el doble; si es por
#   cuenta, el reparto entre claves es cosa del cliente.
#
#   EL PAR (regla 6), en dos fases, porque la respuesta depende de a que ventana se refiere
#   remaining:
#     Fase 1, espaciada (4 llamadas, 1,1 s entre ellas): k1, k2, k1, k2. Si el contador es
#       por CUENTA, remaining baja de forma monotona entre claves (L-1, L-2, L-3, L-4). Si
#       es por CLAVE, cada una ve su propia serie (L-1, L-2).
#     Fase 2, seguida (2 llamadas sin pausa): k1 y k2 dentro del mismo segundo de servidor,
#       para el caso de que remaining describa la ventana por SEGUNDO -- que en esta ruta
#       son 2 RPS [F6], asi que dos llamadas seguidas estan en el limite y no lo pasan.
#   Una sola pareja de lecturas no distingue las dos hipotesis: hacen falta las cuatro.
#
# COSTE EN ENVIOS: 0. Presupuesto: 6 peticiones, todas GET inocuos a GET /v3/smtp/emails.
#   Este script NO toca ningun endpoint de envio. Bucket: 6 de la fila propia de
#   GET /v3/smtp/emails (7.200 RPH / 2 RPS en el tramo General [F6]).
#
# DESTINATARIOS (D-046): ninguno. No hay peticiones de envio. La lista blanca literal
#   -- persona-3@example.invalid, persona-1@example.invalid, persona-2@example.invalid -- no se usa.
#
# LO QUE NO PUEDE HACER ESTE SCRIPT
#   Necesita DOS claves de la misma cuenta: BREVO_API_KEY y BREVO_API_KEY_2, las dos en
#   ~/.config/tfm/.env. Crear la segunda es carril ROJO -- docs/08-mandato.md deja "altas de
#   cuenta, facturacion, upgrades y rotacion de claves" en manos del autor. Si falta, el
#   script no inventa nada: deja una evidencia que dice que el hueco 8 NO es medible en esta
#   pasada, el valor se queda en ambar y la peticion de la segunda clave vuelve en la
#   salida. Las claves no se imprimen nunca y se redactan del JSON.
#
# USO
#   bash probe_brevo_a_segmentacion.sh
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
readonly RUTA="/smtp/emails?limit=1"
D="$(mktemp -d "${TMPDIR:-/tmp}/brevo_a_segm_XXXXXX")" || { echo "ABORTA: no se pudo crear el directorio de trabajo." >&2; exit 3; }
[[ -d $D && -w $D ]] || { echo "ABORTA: el directorio de trabajo '$D' no existe o no acepta escrituras." >&2; exit 3; }
# El JSON va a 03_datos/apis/brevo/evidencias/ si esa carpeta existe, igual que hacen los
# dos sondeos del paquete B. Antes caia junto al script y la ultima linea imprimia una ruta a
# evidencias/ a la que nadie lo llevaba: quien seguia esa linea y movia el fichero dejaba a
# probe_brevo_a_destinatarios.sh y probe_brevo_a_tamano.sh abortando por falta de preflight,
# porque guarda_elegida lo buscaba solo junto al script.
SAL="$AQUI"
[ -d "$AQUI/../../03_datos/apis/brevo/evidencias" ] &&
  SAL="$(CDPATH='' cd -- "$AQUI/../../03_datos/apis/brevo/evidencias" && pwd)"
OUT="$SAL/probe_brevo_a_segmentacion_$(date -u +%Y-%m-%d_%H%M%S).json"
ORDEN=""

if [ -z "${BREVO_API_KEY_2:-}" ]; then
  echo "== NO EJECUTABLE EN ESTA PASADA =="
  echo "   Falta BREVO_API_KEY_2 en ~/.config/tfm/.env. Comprobado el 2026-09-17 leyendo"
  echo "   solo los NOMBRES de variable del fichero: define BREVO_API_KEY, BREVO_FROM y"
  echo "   BREVO_TO, y ninguna segunda clave."
  echo "   Crear una segunda clave de API es carril ROJO (docs/08-mandato.md: altas de"
  echo "   cuenta, facturacion, upgrades y rotacion de claves) y ademas es escalon 2, no 3:"
  echo "   se crea en el panel. El hueco 8 de fuentes.md -- si el caudal se cuenta por"
  echo "   cuenta o por clave -- se queda SIN MEDIR en esta pasada y el valor en ambar."
  echo "   NO contarlo como cerrado al aplicar los resultados al datasheet."
  CLAVE="${BREVO_API_KEY:-}" CLAVE2="${BREVO_API_KEY_2:-}" \
  FROM="${BREVO_FROM:-}" TO="${BREVO_TO:-}" \
  python3 -I - "$OUT" <<'PY'
import sys,json,datetime
json.dump({"resumen":{"api":"brevo","paquete":"A (cero envios)","sondeo":"segmentacion",
  "fecha_utc":datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
  "estado":"NO EJECUTABLE","envios_reales":0,"peticiones":0,
  "motivo":("hace falta una segunda clave de API de la misma cuenta (BREVO_API_KEY_2) y "
    "crearla es carril rojo: docs/08-mandato.md reserva al autor las altas de cuenta y la "
    "rotacion de claves"),
  "consecuencia":("el hueco 8 de fuentes.md -- si el caudal se cuenta por cuenta o por "
    "clave -- se queda abierto y sin cifra; ninguna via de coste cero lo cierra con una "
    "sola credencial")},"casos":[]},open(sys.argv[1],"w"),ensure_ascii=True,indent=1)
print("Evidencia de no ejecutable: "+sys.argv[1])
PY
  exit 4
fi
# La segunda clave pasa por la misma puerta que la primera: viaja por el fichero de
# configuracion de curl y una comilla doble ahi rompe la linea.
brevo_clave_valida "$BREVO_API_KEY_2" || {
  echo "ABORTA: BREVO_API_KEY_2 tiene caracteres fuera de [A-Za-z0-9_.:-]." >&2; exit 3; }

echo "== PRESUPUESTO DECLARADO (D-046 condicion 2) =="
echo "   Envios reales de correo ................ 0  (no hay ninguna peticion de envio)"
echo "   Peticiones ............................. 6  (4 espaciadas + 2 seguidas), solo GET"
echo "   Claves en uso .......................... 2 de la misma cuenta (no se imprimen)"
echo "   Pausa en la fase 1 ..................... 1,1 s (por debajo de los 2 RPS de la fila)"
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
    h=cab(d+"/"+c+".hdr")
    crudo=open(d+"/"+c+".body",errors="replace").read()
    m=(open(d+"/"+c+".meta").read().rstrip("\n").split("\t")+[""]*6)[:6]
    casos.append({"caso":c,"ruta":m[1],"clave":m[2],"fase":m[3],"inicio_utc":m[4],
      "http":int(open(d+"/"+c+".code").read().strip() or 0),
      "limit":num(h.get("x-sib-ratelimit-limit")),
      "remaining":num(h.get("x-sib-ratelimit-remaining")),
      "reset":h.get("x-sib-ratelimit-reset"),"date":h.get("date"),
      "error_code":(json.loads(crudo).get("code") if crudo.strip().startswith("{") else None),
      # Solo la cabecera y el estado interesan; el listado de correos no se guarda para no
      # arrastrar direcciones de la cuenta a evidencias/ (E1 pide la cita, no el volcado).
      "bytes_cuerpo":len(crudo)})
f1=[c for c in casos if c["fase"]=="1"]
f2=[c for c in casos if c["fase"]=="2"]
serie=[{"caso":c["caso"],"clave":c["clave"],"limit":c["limit"],"remaining":c["remaining"],
        "date":c["date"],"http":c["http"]} for c in f1]
rem=[c["remaining"] for c in f1]
lim={c["clave"]:c["limit"] for c in f1}
if any(x is None for x in rem) or len(rem)<4:
    v="no medible: falta remaining en alguna de las cuatro lecturas de la fase 1"
    d1=d2=None
else:
    # El discriminador: cuanto cae el contador de UNA clave cuando entre sus dos lecturas
    # se ha colado una llamada de la OTRA. Cae 2 -> cubo compartido; cae 1 -> por clave.
    d1=rem[0]-rem[2]; d2=rem[1]-rem[3]
    if d1>=2 and d2>=2:
        v=("contador por CUENTA: el de la clave 1 cae %d y el de la clave 2 cae %d con una "
           "llamada de la otra clave en medio, asi que las dos comparten cubo (%s). El "
           "caudal de la datasheet es por cuenta, no por credencial"%(d1,d2,rem))
    elif d1==1 and d2==1:
        v=("contador por CLAVE: cada credencial cae 1 entre sus propias lecturas e ignora "
           "las de la otra (%s). El caudal se multiplica por el numero de claves y eso es "
           "un hueco del esquema, que no tiene donde decirlo"%rem)
    else:
        v=("no concluyente: caidas de %s y %s sobre la serie %s. Repetir, y mirar si limit "
           "se refiere a la ventana por segundo -- en ese caso manda la fase 2"%(d1,d2,rem))
if lim and len({v2 for v2 in lim.values() if v2 is not None})>1:
    v+=(" | AVISO: las dos claves declaran limit distinto (%s), asi que la credencial "
        "tambien acota el tope y no solo el plan"%lim)
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
resumen={"api":"brevo","paquete":"A (cero envios)","sondeo":"segmentacion",
  "fecha_utc":casos[0]["inicio_utc"] if casos else None,
  "estado":"EJECUTADO","envios_reales":envios_calculados,
  "unidad_de_envios_reales":("destinatarios de las peticiones ACEPTADAS (2xx), que es la "
    "unidad con la que el libro de cuentas reserva y gasta. Calculado, no declarado"),
  "peticiones":len(casos),"peticiones_de_envio":0,
  "invariante_cero_envios":"CUMPLIDA","endpoint":ruta,
  "fase_1_espaciada":serie,
  "fase_2_seguida":[{"caso":c["caso"],"clave":c["clave"],"limit":c["limit"],
    "remaining":c["remaining"],"date":c["date"],"http":c["http"]} for c in f2],
  "limit_por_clave":lim,
  "caida_del_contador_clave_1":d1,"caida_del_contador_clave_2":d2,
  "veredicto_hueco_8":v,
  "reserva":("si limit es un tope por SEGUNDO (2 RPS en esta fila [F6]), la fase 1 no vale "
    "porque la ventana se reinicia entre lecturas: en ese caso manda la fase 2, y solo si "
    "los dos 'date' caen en el mismo segundo"),
  "lo_que_esto_NO_demuestra":("Dos claves de la MISMA cuenta no dicen nada del reparto "
    "entre subcuentas ni entre IP. Y remaining es un contador que el proveedor no "
    "documenta como contractual: por E-D024 el valor va en AMBAR mientras el sondeo no "
    "alcance el rechazo.")}
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

llamar_con_clave() {
  caso="$1"; etq="$2"; fase="$3"; clave="$4"
  t0="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
  code="$(curl_brevo "$clave" -sS --max-time 30 -o "$D/$caso.body" -D "$D/$caso.hdr" -w '%{http_code}' \
    -H "accept: application/json" \
    -X GET "$BASE$RUTA")" || code="000"
  echo "$code" > "$D/$caso.code"
  printf 'GET\t%s\t%s\t%s\t%s\t0\n' "$RUTA" "$etq" "$fase" "$t0" > "$D/$caso.meta"
  ORDEN="$ORDEN$caso,"
  printf '   %-14s %-8s HTTP %s  limit=%s remaining=%s\n' "$caso" "$etq" "$code" \
    "$(grep -i '^x-sib-ratelimit-limit:' "$D/$caso.hdr" | tr -d '\r' | cut -d' ' -f2-)" \
    "$(grep -i '^x-sib-ratelimit-remaining:' "$D/$caso.hdr" | tr -d '\r' | cut -d' ' -f2-)"
}

echo "-- fase 1: alterna las dos claves con 1,1 s de pausa"
llamar_con_clave s1_k1 clave_1 1 "$BREVO_API_KEY";   sleep 1.1
llamar_con_clave s2_k2 clave_2 1 "$BREVO_API_KEY_2"; sleep 1.1
llamar_con_clave s3_k1 clave_1 1 "$BREVO_API_KEY";   sleep 1.1
llamar_con_clave s4_k2 clave_2 1 "$BREVO_API_KEY_2"
echo "-- fase 2: las dos claves seguidas, para caer en el mismo segundo de servidor"
sleep 2
llamar_con_clave s5_k1 clave_1 2 "$BREVO_API_KEY"
llamar_con_clave s6_k2 clave_2 2 "$BREVO_API_KEY_2"
