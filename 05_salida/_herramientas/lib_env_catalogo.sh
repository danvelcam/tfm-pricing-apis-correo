# shellcheck shell=bash
# =============================================================================
# El .env del catalogo, LEIDO como dato y no SOURCEADO — 2026-09-21
#
# Misma correccion que `lib_env_brevo.sh` (2026-09-17) y por el mismo motivo: un
# `source` con `set -a` es ejecucion de codigo arbitrario, y el fichero de credenciales
# podria definir PATH, PYTHONPATH, la ruta de la guarda de destinatarios o el tope del
# presupuesto. Alli esta el analisis completo de las cinco vias y de por que ni el orden
# de las asignaciones ni `readonly` sujetan un source.
#
# Esta libreria generaliza aquella a cualquier API del catalogo: se le pasa la lista de
# nombres que el sondeo necesita y se queda SOLO con esos. Lo demas es texto que se tira.
# No se exportan: con `set -a` la clave viajaba en el entorno de todos los hijos y
# `/proc/<pid>/environ` la ensena a su dueno.
#
# USO
#   readonly AQUI="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
#   . "$AQUI/lib_env_catalogo.sh" || exit 3
#   cat_carga_env MAILGUN_API_KEY MAILGUN_DOMAIN MAILGUN_FROM || exit 3
#   # deja las variables con esos mismos nombres, vacias si no estaban
# =============================================================================

# Lee el .env y deja UNA variable por cada nombre pedido. Devuelve 3 si no se puede leer.
# Todas se inicializan vacias primero: una lectura a medias no puede dejar en pie el valor
# que tuviera el entorno del que llamo.
cat_carga_env () {  # $1.. nombres a extraer; CAT_ENV_FILE o ~/.config/tfm/.env
  local F L N V P QUERIDOS
  F="${CAT_ENV_FILE:-$HOME/.config/tfm/.env}"
  if [[ ! -r $F ]]; then
    echo "ABORTA: no se puede leer el fichero de credenciales $F." >&2
    return 3
  fi
  (( $# > 0 )) || { echo "ABORTA: cat_carga_env sin nombres que leer." >&2; return 3; }
  QUERIDOS=" $* "
  for N in "$@"; do
    [[ $N =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || {
      echo "ABORTA: '$N' no es un nombre de variable valido." >&2; return 3; }
    printf -v "$N" '%s' ''
  done
  while IFS= read -r L || [[ -n $L ]]; do
    L="${L%$'\r'}"                              # ficheros con salto de linea de Windows
    L="${L#"${L%%[![:space:]]*}"}"              # espacios por delante
    [[ $L == \#* ]] && continue
    if [[ $L == export[[:space:]]* ]]; then
      L="${L#export}"; L="${L#"${L%%[![:space:]]*}"}"
    fi
    [[ $L == *=* ]] || continue
    N="${L%%=*}"; V="${L#*=}"
    [[ $QUERIDOS == *" $N "* ]] || continue
    V="${V%"${V##*[![:space:]]}"}"              # espacios por detras
    # Comillas envolventes, si las hay, y nada mas: el valor es una cadena literal.
    if (( ${#V} >= 2 )) && [[ ${V:0:1} == '"' && ${V: -1} == '"' ]]; then
      V="${V:1:${#V}-2}"
    elif (( ${#V} >= 2 )) && [[ ${V:0:1} == "'" && ${V: -1} == "'" ]]; then
      V="${V:1:${#V}-2}"
    fi
    printf -v "$N" '%s' "$V"
  done < "$F"
  return 0
}

# Igual que `brevo_exige_funciones`: una funcion que decide algo tiene que EXISTIR. Un
# source que falle a medias deja la guarda devolviendo 127 y nadie lo mira, porque ningun
# sondeo usa `set -e`.
cat_exige_funciones () {  # $1.. nombres
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

# Una funcion exportada del shell que lanza el sondeo sombrea una orden externa: con
# `python3 () { ... }` la comprobacion de destinatario pasaria por codigo ajeno. No basta
# con INTENTAR el unset (`unset -f` falla sobre una funcion `readonly -f`), asi que
# despues se COMPRUEBA que los nombres que deciden algo son ejecutables de verdad.
# Se escribe con [[ ]] y no con [ ], que es palabra reservada y no se puede sombrear.
cat_limpia_funciones () {
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
