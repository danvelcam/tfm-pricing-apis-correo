# shellcheck shell=bash
# =============================================================================
# El .env de Brevo, LEIDO como dato y no SOURCEADO - 2026-09-17
#
# POR QUE EXISTE
#   Hasta hoy los diez sondeos cargaban las credenciales asi:
#
#       set -a; . ~/.config/tfm/.env; set +a
#
#   Un source es EJECUCION DE CODIGO, y con 'set -a' cada asignacion se exporta. Ese par
#   puede definir cualquier nombre del shell -- variables y funciones -- asi que el fichero
#   de credenciales tenia poder sobre todo lo que los sondeos deciden. Los revisores lo
#   midieron el 2026-09-17 sobre el codigo anterior, y las cinco vias son distintas:
#
#     GUARDA=<ruta>            suplanta al validador de la lista blanca, y como
#                              verificar_cuerpo() usa la misma variable, las dos capas
#                              caen juntas: el campo 'to' sale con direcciones ajenas
#     BASE=https://evil/v3     la cabecera api-key viaja a un host arbitrario
#     TOPE_PASADA=99           el tope de la pasada deja de existir
#     PATH=<dir>:...           el python3 de la guarda y el curl del envio salen de ahi
#     PYTHONPATH=<dir>         'import json' se puede suplantar dentro de los heredocs
#
#   Y las dos defensas que se habian puesto -- el ORDEN de las asignaciones y 'readonly' --
#   no sujetan un source, porque el fichero puede desarmarlas antes:
#
#     readonly () { return 0; }        'readonly X=1' pasa a ser una LLAMADA a esa funcion
#                                      con la cadena "X=1" como argumento: no hay asignacion
#     readonly TOPE_PASADA=99          la asignacion posterior de la libreria FALLA, y como
#                                      ningun sondeo usa 'set -e', el proceso sigue
#     readonly -f reservar             el source de la libreria no puede redefinirla
#     unset () { :; }                  brevo_limpia_funciones entero pasa a ser un no-op
#
#   Comprobado en esta maquina: 'readonly () { return 0; }; TOPE=99; readonly TOPE=3'
#   deja TOPE=99. Y '[' admite ser una funcion, asi que ampliar la lista de 'unset -f'
#   tampoco cierra la clase. La unica correccion que la cierra es esta: NO sourcear.
#
# QUE HACE EN SU LUGAR
#   Lee el fichero linea a linea con las operaciones de cadena del propio shell y se queda
#   SOLO con cuatro nombres. No hay 'eval', no hay 'source' y no se interpreta nada del
#   valor: ni $VAR, ni $(...), ni comillas anidadas, ni barras invertidas. Una linea
#   'PATH=...' o 'readonly TOPE_PASADA=99' dentro del .env es texto que se descarta.
#
#   Los cuatro nombres, y para que sirve cada uno:
#     BREVO_API_KEY     la credencial
#     BREVO_API_KEY_2   la segunda clave de la misma cuenta (sondeo de segmentacion)
#     BREVO_FROM        el remitente verificado
#     BREVO_TO          NO se usa para enviar a nadie -- los destinatarios son literales en
#                       el script -- solo para redactarlo si aparece en una respuesta
#
#   NO SE EXPORTAN. Con 'set -a' la clave viajaba en el entorno de todos los hijos, y
#   '/proc/<pid>/environ' la ensena a su dueno. Aqui se queda en variables del shell y se
#   pasa a mano donde hace falta.
#
# USO (y el orden importa, aunque ya no sea una defensa)
#   readonly AQUI="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
#   . "$AQUI/lib_env_brevo.sh" || exit 3
#   . "$AQUI/lib_presupuesto_brevo.sh" || exit 3     # librerias: codigo del repositorio
#   brevo_carga_env || exit 3                        # y DESPUES el fichero, como dato
# =============================================================================

# Lee el .env y deja BREVO_API_KEY, BREVO_API_KEY_2, BREVO_FROM y BREVO_TO. Devuelve 3 si
# el fichero no se puede leer. Las cuatro se inicializan vacias: una lectura a medias no
# puede dejar en pie el valor que tuviera el entorno del que llamo.
brevo_carga_env () {  # $1 ruta del .env (por omision ~/.config/tfm/.env)
  local F L N V
  F="${1:-$HOME/.config/tfm/.env}"
  if [[ ! -r $F ]]; then
    echo "ABORTA: no se puede leer el fichero de credenciales $F." >&2
    return 3
  fi
  BREVO_API_KEY=""; BREVO_API_KEY_2=""; BREVO_FROM=""; BREVO_TO=""
  while IFS= read -r L || [[ -n $L ]]; do
    L="${L%$'\r'}"                              # ficheros con salto de linea de Windows
    L="${L#"${L%%[![:space:]]*}"}"              # espacios por delante
    [[ $L == \#* ]] && continue
    if [[ $L == export[[:space:]]* ]]; then
      L="${L#export}"; L="${L#"${L%%[![:space:]]*}"}"
    fi
    [[ $L == *=* ]] || continue
    N="${L%%=*}"; V="${L#*=}"
    case "$N" in
      BREVO_API_KEY|BREVO_API_KEY_2|BREVO_FROM|BREVO_TO) ;;
      *) continue ;;
    esac
    V="${V%"${V##*[![:space:]]}"}"              # espacios por detras
    # Comillas envolventes, si las hay, y nada mas: el valor es una cadena literal.
    if (( ${#V} >= 2 )) && [[ ${V:0:1} == '"' && ${V: -1} == '"' ]]; then
      V="${V:1:${#V}-2}"
    elif (( ${#V} >= 2 )) && [[ ${V:0:1} == "'" && ${V: -1} == "'" ]]; then
      V="${V:1:${#V}-2}"
    fi
    case "$N" in
      BREVO_API_KEY)   BREVO_API_KEY="$V" ;;
      BREVO_API_KEY_2) BREVO_API_KEY_2="$V" ;;
      BREVO_FROM)      BREVO_FROM="$V" ;;
      BREVO_TO)        BREVO_TO="$V" ;;
    esac
  done < "$F"
  return 0
}

# Las funciones que deciden algo tienen que EXISTIR, y ser funciones. Un source que falle a
# medias -- fichero ausente, ruta corrupta, una funcion que el entorno declaro 'readonly -f'
# antes de arrancar -- deja el sondeo con 'libro_cabe' devolviendo 127 y nadie lo mira,
# porque ningun sondeo usa 'set -e'. Esto lo convierte en un aborto.
# Se escribe con [[ ]] y no con [ ], que es una palabra reservada del shell y no se puede
# sombrear con una funcion; '[' si (comprobado: 'declare -F [' funciona).
brevo_exige_funciones () {  # $1.. nombres
  local F FALLA=0
  for F in "$@"; do
    if [[ $(declare -F "$F" 2>/dev/null) != "$F" ]]; then
      echo "ABORTA: falta la funcion '$F': una libreria no se cargo entera." >&2
      FALLA=1
    fi
  done
  (( FALLA == 0 )) || return 3
  return 0
}

# Una funcion definida en el entorno sombrea una orden externa: con 'python3 () { ... }',
# TODAS las comprobaciones de destinatario de todos los sondeos pasarian por codigo ajeno.
# Desde que el .env se LEE en vez de sourcearse, el fichero de credenciales ya no puede
# plantar funciones; esto cubre lo que llegue exportado desde el shell que lanza el sondeo.
# No basta con INTENTAR el unset -- 'unset -f' falla sobre una funcion declarada
# 'readonly -f' y el viejo '2>/dev/null || true' se comia el fallo en silencio -- asi que
# despues se COMPRUEBA que los nombres que deciden algo son ejecutables de verdad.
brevo_limpia_funciones () {
  unset -f curl python3 date mktemp wc head tail tr cut grep sed awk cat ls basename \
           dirname chmod mkdir sleep printf echo test rm cp mv sort uniq base64 df \
           '[' ':' true false timeout env command builtin unset readonly declare type \
           2>/dev/null || true
  local O FALLA=0 T
  for O in curl python3 date awk grep sed basename wc; do
    T="$(type -t "$O" 2>/dev/null || true)"
    if [[ $T != file ]]; then
      echo "ABORTA: '$O' no es un ejecutable del sistema (type dice '${T:-nada}')." >&2
      FALLA=1
    fi
  done
  if (( FALLA != 0 )); then
    echo "        Algo del entorno sombrea las ordenes que este sondeo usa para comprobar" >&2
    echo "        destinatarios y para llamar a la API. No se llama a nada." >&2
    exit 3
  fi
  return 0
}
