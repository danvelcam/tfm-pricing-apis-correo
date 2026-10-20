#!/usr/bin/env bash
# Sondeo empirico Brevo (escalon 3) - PAQUETE A, CERO ENVIOS - preparado el 2026-09-17
#
# PREGUNTA QUE RESUELVE
#   DISC-13: en que unidad viene x-sib-ratelimit-reset. La guia la deja abierta -- "Time
#   remaining until the rate limit resets, expressed in the granularity unit (typically
#   seconds)" [F7] -- y el blog la afirma en segundos [F28]. Para un endpoint declarado
#   solo en RPH la diferencia es un factor 3.600, asi que el consumidor no puede derivar
#   un valor unico.
#   Se mide observando COMO CAE la cifra: tres muestras del mismo endpoint separadas por
#   pausas conocidas. Si reset baja una unidad por segundo, la unidad es el segundo; si
#   baja una por minuto, el minuto; si no baja, no es una cuenta atras (o es una marca
#   absoluta de tiempo). El par de la regla 6 aqui son las parejas de muestras: una sola
#   lectura de reset no dice nada, porque cualquier numero es compatible con cualquier
#   unidad.
#   De paso responde algo que DISC-13 no pregunta y hace falta para leer DISC-17: cuando
#   un endpoint tiene DOS ventanas declaradas (RPS y RPH, [F6]), a cual de las dos se
#   refiere reset.
#
# COSTE EN ENVIOS: 0. Presupuesto: 9 peticiones, todas GET inocuos.
#   Este script NO toca ningun endpoint de envio, asi que no puede gastar cuota ni por
#   accidente. Buckets: 3 del prefijo /v3/smtp/{...} (300 RPH), 3 de la fila propia de
#   GET /v3/smtp/emails, 3 de "All other endpoints" (100 RPH).
#   Duracion: unos 35 s (las pausas son el instrumento de medida, no una cortesia).
#
# DESTINATARIOS (D-046): ninguno. No hay peticiones de envio. La lista blanca literal
#   -- persona-3@example.invalid, persona-1@example.invalid, persona-2@example.invalid -- no se usa.
#
# USO
#   bash probe_brevo_a_unidad_reset.sh      (lee BREVO_API_KEY de ~/.config/tfm/.env)
#   Correr ANTES de probe_brevo_a_cuerpo_429.sh: ese agota el bucket de 100 RPH y dejaria
#   /v3/senders devolviendo 429 durante una hora.
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
D="$(mktemp -d "${TMPDIR:-/tmp}/brevo_a_reset_XXXXXX")" || { echo "ABORTA: no se pudo crear el directorio de trabajo." >&2; exit 3; }
[[ -d $D && -w $D ]] || { echo "ABORTA: el directorio de trabajo '$D' no existe o no acepta escrituras." >&2; exit 3; }
# El JSON va a 03_datos/apis/brevo/evidencias/ si esa carpeta existe, igual que hacen los
# dos sondeos del paquete B. Antes caia junto al script y la ultima linea imprimia una ruta a
# evidencias/ a la que nadie lo llevaba: quien seguia esa linea y movia el fichero dejaba a
# probe_brevo_a_destinatarios.sh y probe_brevo_a_tamano.sh abortando por falta de preflight,
# porque guarda_elegida lo buscaba solo junto al script.
SAL="$AQUI"
[ -d "$AQUI/../../03_datos/apis/brevo/evidencias" ] &&
  SAL="$(CDPATH='' cd -- "$AQUI/../../03_datos/apis/brevo/evidencias" && pwd)"
OUT="$SAL/probe_brevo_a_unidad_reset_$(date -u +%Y-%m-%d_%H%M%S).json"
ORDEN=""

echo "== PRESUPUESTO DECLARADO (D-046 condicion 2) =="
echo "   Envios reales de correo ................ 0  (no hay ninguna peticion de envio)"
echo "   Peticiones ............................. 9  (3 endpoints x 3 muestras, solo GET)"
echo "   Pausas entre rondas .................... 6 s y 19 s (son la escala de la medida)"
echo

resumir() {
  if [ -f "$D/.resumido" ]; then return 0; fi
  : > "$D/.resumido"
  CLAVE="${BREVO_API_KEY:-}" CLAVE2="${BREVO_API_KEY_2:-}" \
  FROM="${BREVO_FROM:-}" TO="${BREVO_TO:-}" \
  python3 -I - "$D" "$OUT" "$ORDEN" <<'PY'
import sys,json,os,re as _re
d,out,orden=sys.argv[1],sys.argv[2],sys.argv[3]
def cab(p):
    h={}
    if not os.path.exists(p): return h
    for l in open(p,errors="replace"):
        if ":" in l and not l.upper().startswith("HTTP/"):
            k,v=l.split(":",1); h[k.strip().lower()]=v.strip()
    return h
def num(x):
    try: return float(str(x).strip())
    except Exception: return None
casos=[]
for c in [x for x in orden.split(",") if x]:
    if not os.path.exists(d+"/"+c+".code"): continue
    h=cab(d+"/"+c+".hdr")
    crudo=open(d+"/"+c+".body",errors="replace").read()
    m=(open(d+"/"+c+".meta").read().rstrip("\n").split("\t")+[""]*6)[:6]
    casos.append({"caso":c,"endpoint":m[1],"descripcion":m[2],"ronda":int(m[3]),
      "epoch_local":float(m[4]),"http":int(open(d+"/"+c+".code").read().strip() or 0),
      "limit":num(h.get("x-sib-ratelimit-limit")),
      "remaining":num(h.get("x-sib-ratelimit-remaining")),
      "reset":num(h.get("x-sib-ratelimit-reset")),
      "reset_crudo":h.get("x-sib-ratelimit-reset"),
      "date":h.get("date"),
      "cabeceras_caudal":{k:v for k,v in h.items() if k.startswith("x-sib-ratelimit")},
      "cuerpo_crudo":crudo if len(crudo)<=4000 else crudo[:4000]+"...[truncado]"})
grupos={}
for c in casos: grupos.setdefault(c["endpoint"],[]).append(c)
def clasifica(pares,reset0):
    if reset0 is not None and reset0>1e9:
        return ("marca de tiempo absoluta (epoch), no una cuenta atras: el valor supera "
                "1e9 y no cabe como duracion")
    if not pares: return "no medible: menos de dos muestras con reset legible"
    ratios=[p["delta_reset"]/p["delta_t_s"] for p in pares if p["delta_t_s"]>0]
    if not ratios: return "no medible: las muestras no estan separadas en el tiempo"
    r=sum(ratios)/len(ratios)
    if -1.35<=r<=-0.65:  return "SEGUNDOS: reset baja ~1 por segundo transcurrido"
    if -1400<=r<=-700:   return "MILISEGUNDOS: reset baja ~1000 por segundo transcurrido"
    if -0.035<=r<=-0.008:return "MINUTOS: reset baja ~1 por cada 60 s transcurridos"
    if abs(r)<0.004:
        return ("reset NO decrece con el tiempo: no es una cuenta atras, o la ventana se "
                "reinicia entre muestras (mirar 'reset_por_muestra' y 'limit')")
    return "no concluyente: caida media de %.4f unidades por segundo"%r
analisis={}
for ep,g in grupos.items():
    g=sorted(g,key=lambda x:x["epoch_local"])
    pares=[]
    for a,b in zip(g,g[1:]):
        if a["reset"] is None or b["reset"] is None: continue
        pares.append({"de_ronda":a["ronda"],"a_ronda":b["ronda"],
          "delta_t_s":round(b["epoch_local"]-a["epoch_local"],3),
          "reset_antes":a["reset"],"reset_despues":b["reset"],
          "delta_reset":b["reset"]-a["reset"]})
    r0=g[0]["reset"] if g else None
    l0=g[0]["limit"] if g else None
    coh=None
    if r0 is not None and l0 is not None:
        if r0<=1.5: coh=("reset cabe en una ventana de 1 s: apunta a que la cabecera "
                         "describe la ventana por SEGUNDO del endpoint")
        elif r0<=3600: coh=("reset cabe en una ventana de una hora: si la unidad es el "
                            "segundo, la cabecera describe la ventana por HORA")
        else: coh="reset excede los 3.600: no es una ventana horaria medida en segundos"
    analisis[ep]={"limit":l0,"reset_por_muestra":[x["reset_crudo"] for x in g],
      "remaining_por_muestra":[x["remaining"] for x in g],
      "date_por_muestra":[x["date"] for x in g],
      "pares":pares,"veredicto_unidad":clasifica(pares,r0),
      "a_que_ventana_se_refiere":coh}
import datetime
fecha=(datetime.datetime.fromtimestamp(casos[0]["epoch_local"],datetime.timezone.utc)
       .strftime("%Y-%m-%dT%H:%M:%SZ")) if casos else None
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
resumen={"api":"brevo","paquete":"A (cero envios)","sondeo":"unidad_reset",
  "fecha_utc":fecha,
  "envios_reales":envios_calculados,
  "unidad_de_envios_reales":("destinatarios de las peticiones ACEPTADAS (2xx), que es la "
    "unidad con la que el libro de cuentas reserva y gasta. Calculado, no declarado"),
  "peticiones":len(casos),
  "peticiones_de_envio":0,"invariante_cero_envios":"CUMPLIDA",
  "analisis_por_endpoint":analisis,
  "veredicto_DISC_13":{ep:a["veredicto_unidad"] for ep,a in analisis.items()},
  "lo_que_esto_NO_demuestra":("La unidad medida es la de ESTA cuenta y estos endpoints el "
    "dia del sondeo. Y si los tres endpoints dan unidades distintas, la contradiccion de "
    "DISC-13 no se cierra: se confirma que 'the granularity unit' [F7] significa que la "
    "unidad depende del endpoint, que es un hallazgo mayor que la propia discrepancia.")}
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

muestrear() {
  caso="$1"; ruta="$2"; desc="$3"; ronda="$4"
  tl="$(date -u +%s.%N)"
  code="$(curl_brevo "$BREVO_API_KEY" -sS --max-time 30 -o "$D/$caso.body" -D "$D/$caso.hdr" -w '%{http_code}' \
    -H "accept: application/json" \
    -X GET "$BASE$ruta")" || code="000"
  echo "$code" > "$D/$caso.code"
  printf 'GET\t%s\t%s\t%s\t%s\t0\n' "$ruta" "$desc" "$ronda" "$tl" > "$D/$caso.meta"
  ORDEN="$ORDEN$caso,"
  printf '   ronda %s  %-28s HTTP %s  limit=%s remaining=%s reset=%s\n' "$ronda" "$ruta" "$code" \
    "$(grep -i '^x-sib-ratelimit-limit:' "$D/$caso.hdr" | tr -d '\r' | cut -d' ' -f2-)" \
    "$(grep -i '^x-sib-ratelimit-remaining:' "$D/$caso.hdr" | tr -d '\r' | cut -d' ' -f2-)" \
    "$(grep -i '^x-sib-ratelimit-reset:' "$D/$caso.hdr" | tr -d '\r' | cut -d' ' -f2-)"
}

for R in 1 2 3; do
  echo "-- ronda $R"
  muestrear "r${R}_smtp_emails"    "/smtp/emails?limit=1"    "fila propia con DOS ventanas declaradas: 7.200 RPH y 2 RPS [F6]" "$R"
  sleep 1
  muestrear "r${R}_smtp_templates" "/smtp/templates?limit=1" "prefijo /v3/smtp/{...}, declarado SOLO en RPH (300) [F6]" "$R"
  sleep 1
  muestrear "r${R}_senders"        "/senders"                "All other endpoints, declarado SOLO en RPH (100) [F6]" "$R"
  if [ "$R" = "1" ]; then sleep 6; fi
  if [ "$R" = "2" ]; then sleep 19; fi
done
