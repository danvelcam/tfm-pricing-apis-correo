#!/usr/bin/env bash
# Sondeo empirico Brevo (escalon 3) - PAQUETE A, CERO ENVIOS - preparado el 2026-09-17
#
# PREGUNTA QUE RESUELVE
#   DISC-14: que devuelve DE VERDAD GET /v3/account. El blog afirma que "returns your
#   current plan limits and API usage" [F28]; el esquema de la referencia solo publica
#   creditos restantes y fechas del plan, sin ningun campo de limite ni de consumo [F12].
#   Se cierra con lecturas: el inventario de claves que vuelve se compara con las dos
#   afirmaciones.
#   DISC-09: el ancla del ciclo de facturacion. Una pagina dice "the subscription period
#   is 30 days" [F1]; la otra, "charged each month on your billing date" [F25]. startDate
#   y endDate vienen en Unix [F12], asi que la aritmetica de los dos desempata: 30 dias
#   exactos apuntan a periodo fijo, un mes de calendario con el mismo dia apunta a dia de
#   alta.
#   Ademas deja escrita la cifra que hace falta para el hueco 27 (el caudal efectivo del
#   Free): los creditos que la cuenta declara tener.
#
#   EL PAR (regla 6). Dos lecturas separadas 20 s SIN ningun envio entre medias. Si
#   'credits' cambia sin que nadie haya enviado, el campo no es un saldo estable y toda
#   lectura posterior de la cuota queda en duda; si no cambia, la segunda lectura confirma
#   que el numero es el saldo y no un contador de consumo. Una sola lectura no distingue
#   las dos cosas.
#
# COSTE EN ENVIOS: 0. Presupuesto: 2 peticiones, GET inocuos.
#   Este script NO toca ningun endpoint de envio. Bucket: 2 de "All other endpoints"
#   (100 RPH, tramo General [F6]). Duracion: ~25 s.
#
# DESTINATARIOS (D-046): ninguno. No hay peticiones de envio. La lista blanca literal
#   -- persona-3@example.invalid, persona-1@example.invalid, persona-2@example.invalid -- no se usa.
#
# PII: el cuerpo de GET /v3/account trae la identidad del titular (correo de alta, nombre,
#   apellidos, empresa, direccion postal) y este JSON se escribe dentro del repo. De una
#   respuesta 2xx se guardan SOLO plan[] y la lista de NOMBRES de campo -- que es lo que
#   DISC-14 necesita comparar con [F28] y [F12] -- y no los valores. El cuerpo crudo se
#   guarda unicamente cuando la respuesta NO es 2xx: ahi es un mensaje de error.
#
# USO
#   bash probe_brevo_a_cuenta.sh        (lee BREVO_API_KEY de ~/.config/tfm/.env)
#   Correr al principio de la pasada y ANTES de probe_brevo_a_cuerpo_429.sh, que agota el
#   bucket de 100 RPH y dejaria GET /v3/account devolviendo 429 durante una hora. Ese
#   sondeo va el ULTIMO de la pasada entera, DESPUES del paquete B, que se sostiene entero
#   sobre lecturas de este mismo endpoint.
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
D="$(mktemp -d "${TMPDIR:-/tmp}/brevo_a_cuenta_XXXXXX")" || { echo "ABORTA: no se pudo crear el directorio de trabajo." >&2; exit 3; }
[[ -d $D && -w $D ]] || { echo "ABORTA: el directorio de trabajo '$D' no existe o no acepta escrituras." >&2; exit 3; }
# El JSON va a 03_datos/apis/brevo/evidencias/ si esa carpeta existe, igual que hacen los
# dos sondeos del paquete B. Antes caia junto al script y la ultima linea imprimia una ruta a
# evidencias/ a la que nadie lo llevaba: quien seguia esa linea y movia el fichero dejaba a
# probe_brevo_a_destinatarios.sh y probe_brevo_a_tamano.sh abortando por falta de preflight,
# porque guarda_elegida lo buscaba solo junto al script.
SAL="$AQUI"
[ -d "$AQUI/../../03_datos/apis/brevo/evidencias" ] &&
  SAL="$(CDPATH='' cd -- "$AQUI/../../03_datos/apis/brevo/evidencias" && pwd)"
OUT="$SAL/probe_brevo_a_cuenta_$(date -u +%Y-%m-%d_%H%M%S).json"
ORDEN=""

echo "== PRESUPUESTO DECLARADO (D-046 condicion 2) =="
echo "   Envios reales de correo ................ 0  (no hay ninguna peticion de envio)"
echo "   Peticiones ............................. 2  (GET /v3/account, separadas 20 s)"
echo

resumir() {
  if [ -f "$D/.resumido" ]; then return 0; fi
  : > "$D/.resumido"
  CLAVE="${BREVO_API_KEY:-}" CLAVE2="${BREVO_API_KEY_2:-}" \
  FROM="${BREVO_FROM:-}" TO="${BREVO_TO:-}" \
  python3 -I - "$D" "$OUT" "$ORDEN" <<'PY'
import sys,json,os,datetime,re as _re
d,out,orden=sys.argv[1],sys.argv[2],sys.argv[3]
def cab(p):
    h={}
    if not os.path.exists(p): return h
    for l in open(p,errors="replace"):
        if ":" in l and not l.upper().startswith("HTTP/"):
            k,v=l.split(":",1); h[k.strip().lower()]=v.strip()
    return h
def claves(o,pref=""):
    s=[]
    if isinstance(o,dict):
        for k,v in o.items():
            s.append(pref+k); s+=claves(v,pref+k+".")
    elif isinstance(o,list) and o:
        s+=claves(o[0],pref+"0.")
    return s
casos=[]
completos=[]   # solo en memoria: de aqui salen los NOMBRES de campo, no los valores
for c in [x for x in orden.split(",") if x]:
    if not os.path.exists(d+"/"+c+".code"): continue
    crudo=open(d+"/"+c+".body",errors="replace").read()
    try: cuerpo=json.loads(crudo)
    except Exception: cuerpo=None
    completos.append(cuerpo)
    h=cab(d+"/"+c+".hdr")
    m=(open(d+"/"+c+".meta").read().rstrip("\n").split("\t")+[""]*6)[:6]
    _http=int(open(d+"/"+c+".code").read().strip() or 0)
    _ok=200<=_http<300
    # PII: el cuerpo de GET /v3/account trae la identidad del titular -- correo de alta,
    # nombre, apellidos, empresa y direccion postal -- y este JSON se escribe DENTRO del
    # repo. La version anterior guardaba el cuerpo entero (parseado y crudo hasta 40.000
    # caracteres) y se defendia con un AVISO impreso pidiendo revisarlo a mano DESPUES de
    # haberlo escrito. Aqui se hace como en probe_brevo_b_unidad_cuota.sh: de una respuesta
    # 2xx se guardan solo plan[] y la LISTA DE NOMBRES de campo, que es lo que DISC-14
    # necesita; el cuerpo crudo se guarda solo cuando NO es 2xx, porque ahi es un mensaje
    # de error y no una identidad.
    _plan=[p for p in ((cuerpo or {}).get("plan") or [])] if isinstance(cuerpo,dict) else []
    casos.append({"caso":c,"ruta":m[1],"descripcion":m[2],"inicio_utc":m[3],
      "http":_http,
      "cabeceras_caudal":{k:v for k,v in h.items() if k.startswith("x-sib-ratelimit")},
      "date":h.get("date"),
      # Los NOMBRES de campo, anidados incluidos: es lo que DISC-14 necesita comparar con
      # las dos afirmaciones publicadas. Los VALORES de identidad no se escriben.
      "campos_presentes":(sorted(set(claves(cuerpo))) if isinstance(cuerpo,dict) else None),
      "plan":_plan,
      "cuerpo":({"plan":_plan} if _ok and isinstance(cuerpo,dict) else cuerpo),
      "cuerpo_crudo":(None if _ok else
                      (crudo if len(crudo)<=40000 else crudo[:40000]+"...[truncado]")),
      "cuerpo_crudo_omitido":("respuesta 2xx: el cuerpo entero lleva la identidad del "
                              "titular y no se escribe. Estan plan[] y campos_presentes, "
                              "que es lo que pide DISC-14" if _ok else None)})
a=casos[0] if casos else None
b=casos[1] if len(casos)>1 else None
# El inventario sale del cuerpo COMPLETO, que solo existe en memoria; lo que se escribe es
# la lista de nombres.
cuerpo_a=completos[0] if completos else None
inv=sorted(set(claves(cuerpo_a))) if isinstance(cuerpo_a,dict) else []
SOSPECHOSAS=("limit","usage","consum","quota","rate","remaining","used")
hay=[k for k in inv if any(s in k.lower() for s in SOSPECHOSAS)]
# [F12] publica estos campos y ningun otro para el plan.
DOC_F12=["credits","creditsType","type","startDate","endDate"]
planes=[]
if a and isinstance(a["cuerpo"],dict):
    for p in (a["cuerpo"].get("plan") or []):
        if not isinstance(p,dict): continue
        e={"type":p.get("type"),"creditsType":p.get("creditsType"),
           "credits":p.get("credits"),
           "startDate_crudo":p.get("startDate"),"endDate_crudo":p.get("endDate"),
           "claves_fuera_de_F12":[k for k in p if k not in DOC_F12]}
        def iso(v):
            try:
                n=float(v)
                if n>1e11: n=n/1000.0
                return datetime.datetime.fromtimestamp(n,datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
            except Exception:
                return None
        e["startDate_utc"]=iso(p.get("startDate")); e["endDate_utc"]=iso(p.get("endDate"))
        if e["startDate_utc"] and e["endDate_utc"]:
            s=datetime.datetime.strptime(e["startDate_utc"],"%Y-%m-%dT%H:%M:%SZ")
            f=datetime.datetime.strptime(e["endDate_utc"],"%Y-%m-%dT%H:%M:%SZ")
            dias=(f-s).total_seconds()/86400.0
            e["duracion_dias"]=round(dias,3)
            e["dia_del_mes"]={"startDate":s.day,"endDate":f.day}
            # OJO con la aritmetica: en un mes de 30 dias un periodo FIJO de 30 dias cae
            # justo en el mismo dia del mes siguiente, asi que las dos lecturas coinciden y
            # el sondeo NO discrimina. Solo separa [F1] de [F25] si el mes tiene 28, 29 o 31.
            import calendar
            dias_del_mes=calendar.monthrange(s.year,s.month)[1]
            e["dias_del_mes_de_inicio"]=dias_del_mes
            if s.day==f.day and 29.5<=dias<=30.5 and dias_del_mes==30:
                e["veredicto_DISC_09"]=("NO DISCRIMINA este mes: el periodo dura %.2f dias y "
                  "cae en el mismo dia del mes, pero el mes de inicio tiene 30 dias, asi que "
                  "un periodo fijo de 30 dias [F1] y un ancla en el dia de alta [F25] dan la "
                  "misma fecha. Repetir la lectura en un mes de 31 dias o en febrero"%dias)
            elif 29.5<=dias<=30.5 and s.day!=f.day:
                e["veredicto_DISC_09"]=("periodo FIJO de 30 dias: la duracion es %.2f dias y "
                  "el dia del mes no se repite -> respalda [F1]"%dias)
            elif s.day==f.day:
                e["veredicto_DISC_09"]=("mes de CALENDARIO anclado al dia %d: la duracion es "
                  "%.2f dias sobre un mes de %d -> respalda [F25] ('your billing "
                  "date')"%(s.day,dias,dias_del_mes))
            else:
                e["veredicto_DISC_09"]="no concluyente: duracion %.2f dias"%dias
        else:
            e["veredicto_DISC_09"]=("no medible con esta cuenta: el plan no devuelve "
              "startDate/endDate. El ejemplo oficial de [F12] tampoco los trae para una "
              "cuenta 'free', asi que DISC-09 se queda abierta y pasa al escalon 2 (panel).")
        planes.append(e)
estable=None
if a and b and isinstance(a["cuerpo"],dict) and isinstance(b["cuerpo"],dict):
    ca=[p.get("credits") for p in (a["cuerpo"].get("plan") or []) if isinstance(p,dict)]
    cb=[p.get("credits") for p in (b["cuerpo"].get("plan") or []) if isinstance(p,dict)]
    estable={"credits_lectura_1":ca,"credits_lectura_2":cb,"iguales":ca==cb,
      "lectura":("estable sin envios: el campo se comporta como SALDO, no como contador de "
                 "consumo") if ca==cb else
                ("cambio SIN envios de por medio: el campo no es un saldo estable y la "
                 "unidad de la cuota no puede derivarse de el")}
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
resumen={"api":"brevo","paquete":"A (cero envios)","sondeo":"cuenta",
  "fecha_utc":a["inicio_utc"] if a else None,
  "envios_reales":envios_calculados,
  "unidad_de_envios_reales":("destinatarios de las peticiones ACEPTADAS (2xx), que es la "
    "unidad con la que el libro de cuentas reserva y gasta. Calculado, no declarado"),
  "peticiones":len(casos),"peticiones_de_envio":0,
  "invariante_cero_envios":"CUMPLIDA",
  "http_por_caso":{c["caso"]:c["http"] for c in casos},
  "inventario_de_claves":inv,
  "claves_que_suenan_a_limite_o_consumo":hay,
  # Sin inventario no hay veredicto: una lista vacia porque la llamada fallo no es lo
  # mismo que una respuesta sin claves de limite.
  "veredicto_DISC_14":(("no medible: GET /v3/account no devolvio un objeto JSON legible "
     "(http %s). Mirar 'cuerpo_crudo' del caso"%[c["http"] for c in casos]) if not inv else
     (("[F28] no se sostiene: la respuesta no trae ninguna clave de limite ni de consumo, "
       "solo lo que publica [F12]") if not hay else
      ("la respuesta SI trae claves de limite o consumo (%s): [F28] se sostiene y el "
       "esquema de [F12] esta incompleto"%", ".join(hay)))),
  "planes":planes,
  "veredicto_DISC_09":[p.get("veredicto_DISC_09") for p in planes],
  "par_de_lecturas":estable,
  "para_el_hueco_27":("creditos declarados por la cuenta: %s. Contrastar con el "
    "x-sib-ratelimit-limit del endpoint de envio que mide "
    "probe_brevo_a_caudal_cabeceras.sh"%[p.get("credits") for p in planes]),
  "lo_que_esto_NO_demuestra":("El campo 'credits' no dice de que ventana es. Distinguir "
    "un saldo diario de uno mensual exige dos lecturas separadas por un cambio de dia, o "
    "el panel (escalon 2), no dos lecturas separadas 20 s. Y la unidad de descuento -- por "
    "peticion o por destinatario -- solo la mide un envio real: es el paquete B.")}
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
  echo "PII: el JSON NO lleva el cuerpo de GET /v3/account cuando la respuesta es 2xx, solo"
  echo "     plan[] y la lista de NOMBRES de campo, que es lo que pide DISC-14. El cuerpo"
  echo "     crudo se guarda unicamente cuando la respuesta NO es 2xx, porque ahi es un"
  echo "     mensaje de error y no la identidad del titular."
  echo "JSON: $OUT"
  echo "   (03_datos/apis/brevo/evidencias/ si existe; si no, junto al script)"
  rm -rf "$D"
}
trap resumir EXIT

leer_cuenta() {
  caso="$1"; desc="$2"
  t0="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
  code="$(curl_brevo "$BREVO_API_KEY" -sS --max-time 30 -o "$D/$caso.body" -D "$D/$caso.hdr" -w '%{http_code}' \
    -H "accept: application/json" \
    -X GET "$BASE/account")" || code="000"
  echo "$code" > "$D/$caso.code"
  printf 'GET\t/v3/account\t%s\t%s\t-\t0\n' "$desc" "$t0" > "$D/$caso.meta"
  ORDEN="$ORDEN$caso,"
  printf '   %-14s HTTP %s  %s bytes de cuerpo\n' "$caso" "$code" "$(wc -c < "$D/$caso.body")"
}

echo "-- lectura 1"
leer_cuenta c01_lectura_1 "primera lectura (inventario de claves, DISC-14 y DISC-09)"
echo "-- 20 s sin enviar nada"
sleep 20
echo "-- lectura 2"
leer_cuenta c02_lectura_2 "segunda lectura: 'credits' tiene que seguir igual (par de la regla 6)"
