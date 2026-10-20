# shellcheck shell=bash
# =============================================================================
# De donde sale la GUARDA de los sondeos de carga del paquete A - 2026-09-17
#
# POR QUE EXISTE
#   probe_brevo_a_destinatarios.sh y probe_brevo_a_tamano.sh miden un tope comparando QUE
#   error devuelve Brevo: el caso de control trae el mensaje de la GUARDA y el caso de tope
#   trae el del tope, si el tope se valida antes. Cual de las tres guardas deja ver el tope
#   NO es una preferencia: lo MIDE probe_brevo_a_preflight_rechazo.sh.
#
#   Hasta hoy los dos scripts arrancaban con 'sender_sumidero' por defecto y un comentario
#   que decia "poner la que recomiende el JSON del preflight". Nadie comprobaba que el
#   preflight se hubiera ejecutado, y el orden alfabetico de los ficheros no coincide con el
#   orden de la pasada, asi que era perfectamente posible medir 13 peticiones (o subir
#   184 MB) con una guarda que el preflight habria descartado. Ahora la dependencia es
#   ejecutable: sin JSON del preflight no se mide.
#
# COMO SE ELIGE
#   1. Se lee 'resumen.guarda_recomendada' del JSON de preflight MAS RECIENTE. Se busca en
#      03_datos/apis/brevo/evidencias/ y junto al script, en ese orden: el preflight lo
#      escribe junto al script y luego imprime una ruta a evidencias/, asi que el fichero
#      puede estar en cualquiera de los dos sitios.
#   2. Si el preflight corrio y su veredicto es que NINGUNA guarda deja ver el tope, se
#      aborta: la bisercion por error discriminante no es viable y gastar 184 MB de subida
#      para confirmarlo no aporta nada. Ese resultado ya esta medido y escrito.
#   3. Si no hay JSON de preflight, se aborta pidiendo que se corra primero.
#   4. BREVO_GUARDA fuerza una guarda a mano, para repetir una medida, pero ya no es la
#      primera opcion ni es silenciosa: exige ademas BREVO_GUARDA_SIN_PREFLIGHT=1 y el JSON
#      de evidencia anota 'guarda_validada_por_el_preflight: false'. Antes bastaba con una
#      linea del entorno para saltarse la puerta entera.
# =============================================================================

# --- Si el caso de control ya dice que la bisercion no va a medir nada -----------------
# El caso de control corre PRIMERO y fija el mensaje de la guarda. Si ese mensaje es de una
# familia que se traga cualquier otra validacion -- la cuenta pendiente de aprobacion, la
# clave sin permiso -- entonces los demas casos van a devolver ese mismo {code,message},
# es_tope dara False en los dos lados de cada par y el veredicto saldra "no se ve el tope
# con esta guarda" habiendo gastado todas las peticiones. En probe_brevo_a_tamano.sh eso son
# ~184 MB de subida para nada, y la datasheet ya documenta el codigo que lo provoca
# ('account_under_validation | Account is pending validation', datasheet.yaml:368).
# Devuelve 0 -- e imprime el motivo -- cuando el control dice que no hay nada que medir.
control_inutil () {  # $1 fichero de cuerpo del caso de control
  python3 -I - "$1" <<'PY'
import json, sys
INUTILES = {
    "account_under_validation": "la cuenta esta pendiente de aprobacion",
    "unauthorized": "la clave no autoriza esta ruta",
    "permission_denied": "la clave no tiene permiso sobre esta ruta",
    "not_enough_credits": "la cuenta no tiene saldo, asi que toda peticion cae por ahi",
    "too_many_requests": ("el control cayo por caudal, asi que ese mensaje se va a tragar "
                          "todos los demas casos"),
}
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    raise SystemExit(1)
if not isinstance(d, dict):
    raise SystemExit(1)
c = d.get("code")
if c in INUTILES:
    print("el control devolvio code=%s (%s) y ese error se va a tragar todos los demas "
          "casos: los dos lados de cada par traerian el MISMO mensaje, asi que la bisercion "
          "no puede distinguir el tope. message=%r"
          % (c, INUTILES[c], d.get("message")))
    raise SystemExit(0)
raise SystemExit(1)
PY
}

# --- La vara de medir, consultada DENTRO del bucle ------------------------------------
# Es la MISMA condicion que los resumenes llaman 'control_util' / 'control_utilizable': el
# caso de control dejo un 4xx EXPLICITO y un {code,message} de Brevo legible. La diferencia
# es CUANDO se mira. Hasta el 2026-09-17 se calculaba al final, con los doce casos de detras
# ya mandados: con un control en 000 el cuadro entero salia envenenado y la escalada a 2.001
# destinatarios se habia hecho igual. Ahora se consulta antes de construir cada caso que
# escale, y sin vara no se escala.
#
# La sourcean tambien probe_brevo_a_caudal_cabeceras.sh y probe_brevo_a_preflight_rechazo.sh,
# que no usan guarda_elegida: esta libreria solo define funciones, asi que sourcearla no
# ejecuta nada ni crea dependencia circular con el JSON del preflight.
#
# El 429 y el 408 quedan FUERA de la vara, y no por prudencia general. El 429 cumple las
# dos condiciones de la version anterior -- es 4xx y trae un 'message' legible: fuentes.md
# [F28] recoge el cuerpo literal '{"code": "too_many_requests", ...}' -- asi que el control
# se declaraba utilizable y la escalada seguia; pero entonces todo caso cuyo mensaje
# difiriese de 'too_many_requests' se leia como TOPE, y en probe_brevo_a_tamano.sh ese mismo
# visto bueno autoriza ~184 MB de subida. La cabecera de probe_brevo_a_destinatarios.sh ya
# listaba el 429 entre los casos que invalidan el control; ahora el codigo dice lo mismo.
# Un 408 es lo mismo por el otro lado: un tiempo agotado no es un veredicto del validador.
#
# Devuelve 0 si el control sirve de vara.
control_valido () {  # $1 fichero de cuerpo del control  $2 codigo http del control
  case "${2-}" in
    429|408) return 1 ;;
    4[0-9][0-9]) ;;
    *) return 1 ;;
  esac
  python3 -I - "$1" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    raise SystemExit(1)
raise SystemExit(0 if isinstance(d, dict) and d.get("message") else 1)
PY
}

# Solo dos guardas, y las dos con UN solo defecto:
#   sender_sumidero : remitente en un dominio sin MX, contenido valido
#   sender_ausente  : sin remitente, contenido valido
# 'contenido_ausente' se cayo el 2026-09-17: como se implementaba -- sin contenido pero
# MANTENIENDO el remitente del sumidero -- llevaba DOS defectos, asi que lo que la API
# devolvia era la precedencia entre ellos y no la de la guarda; y para dejarlo en un solo
# defecto habria que mandar con el remitente verificado, que es una peticion que Brevo PUEDE
# aceptar. Una eleccion que no mide lo que dice medir es peor que no ofrecerla.
guarda_valida () {  # $1
  case "${1-}" in
    sender_sumidero|sender_ausente) return 0 ;;
    *) return 1 ;;
  esac
}

# Vino la guarda del preflight, o de un forzado a mano? Los dos sondeos que la consumen lo
# copian a su JSON de evidencia, para que un dato medido con una guarda sin validar no se
# pueda citar como si el preflight lo respaldara. Es una funcion y no una variable porque
# los sondeos hacen GUARDA="$(guarda_elegida)", y lo que se asigne dentro de esa subshell
# no vuelve al proceso.
guarda_validada_por_el_preflight () {
  if [ -n "${BREVO_GUARDA:-}" ]; then printf 'no'; else printf 'si'; fi
}

# Imprime la guarda por stdout. Los avisos van por stderr, para que
# GUARDA="$(guarda_elegida)" no se los coma.
guarda_elegida () {
  if [ -n "${BREVO_GUARDA:-}" ]; then
    # El forzado a mano existe para repetir una medida, pero era la PRIMERA opcion y
    # silenciosa: con BREVO_GUARDA puesto, la "dependencia ejecutable" del preflight no
    # existia. Y eso importa porque con el tope de la pasada en 3 el preflight NO puede
    # medir la precedencia -- sus casos de tope, de 2.001 y 100 destinatarios, se omiten
    # todos por presupuesto y guarda_recomendada sale vacia -- asi que ese vacio es lo
    # unico que hoy impide que probe_brevo_a_tamano.sh suba sus siete peldanos con una
    # guarda que nadie valido. Ahora el forzado exige decirlo dos veces y deja huella.
    if [ -z "${BREVO_GUARDA_SIN_PREFLIGHT:-}" ]; then
      echo "ABORTA: BREVO_GUARDA esta puesta pero el preflight no la respalda." >&2
      echo "        Esa variable salta la medida que decide QUE guarda deja ver el tope, y" >&2
      echo "        una bisercion con la guarda equivocada gasta las peticiones sin medir" >&2
      echo "        nada. Si de verdad quieres forzarla, dilo tambien con" >&2
      echo "        BREVO_GUARDA_SIN_PREFLIGHT=1: el JSON de evidencia anotara que el dato" >&2
      echo "        NO viene validado por el preflight." >&2
      return 2
    fi
    if guarda_valida "$BREVO_GUARDA"; then
      echo "   AVISO: guarda FORZADA a mano ($BREVO_GUARDA), sin validar por el preflight." >&2
      echo "          El JSON lo anotara como guarda_validada_por_el_preflight: false." >&2
      printf '%s' "$BREVO_GUARDA"
      return 0
    fi
    echo "ABORTA: BREVO_GUARDA no valida: $BREVO_GUARDA" >&2
    return 2
  fi
  # El JSON se busca en los DOS sitios, y en evidencias/ primero. El preflight lo escribe
  # junto al script y acto seguido imprime "Evidencia -> 03_datos/apis/brevo/evidencias/",
  # asi que el operador que siga esa linea movia el fichero y dejaba a los dos sondeos de
  # carga abortando por falta de preflight.
  local ULTIMO EVID
  EVID="$AQUI/../../03_datos/apis/brevo/evidencias"
  ULTIMO="$(ls -1t "$EVID"/probe_brevo_a_preflight_rechazo_*.json \
                   "$AQUI"/probe_brevo_a_preflight_rechazo_*.json 2>/dev/null | head -1)"
  if [ -z "$ULTIMO" ]; then
    echo "ABORTA: no hay JSON de probe_brevo_a_preflight_rechazo.sh ni en $AQUI ni en" >&2
    echo "        $EVID." >&2
    echo "        Ese sondeo es el que MIDE que guarda deja ver el tope, y va primero en la" >&2
    echo "        pasada. Sin su resultado, este sondeo elegiria la guarda a ciegas y sus" >&2
    echo "        peticiones no medirian nada. Correrlo antes, o forzar con BREVO_GUARDA=." >&2
    return 2
  fi
  # El motivo del rechazo lo escribe el python en stderr (sys.exit con texto), asi que
  # llega solo al operador; aqui solo se anade el contexto.
  local R
  R="$(python3 -I - "$ULTIMO" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception as e:
    sys.exit("el JSON del preflight no se puede leer: %s" % e)
r = d.get("resumen") or {}
g = r.get("guarda_recomendada")
if g:
    print(g)
    raise SystemExit
sys.exit("el preflight corrio y NO recomienda ninguna guarda. Su veredicto: %s"
         % (r.get("veredicto") or "(sin veredicto)"))
PY
)" || {
    echo "ABORTA por lo que dice el preflight (motivo justo arriba)." >&2
    echo "        Fichero: $ULTIMO" >&2
    echo "        Si ninguna guarda deja ver el tope, la bisercion por error discriminante" >&2
    echo "        no es viable en Brevo: el valor se queda en AMBAR y la pregunta vuelve en" >&2
    echo "        la salida. No se gastan peticiones para volver a comprobarlo." >&2
    return 2
  }
  if ! guarda_valida "$R"; then
    echo "ABORTA: el preflight recomienda una guarda que este script no conoce: $R" >&2
    return 2
  fi
  echo "   guarda leida del preflight ($(basename "$ULTIMO")): $R" >&2
  printf '%s' "$R"
}
