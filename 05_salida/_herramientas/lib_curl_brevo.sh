# shellcheck shell=bash
# =============================================================================
# La clave de Brevo, fuera de la linea de ordenes - 2026-09-17
#
# POR QUE EXISTE
#   Hasta hoy los sondeos de Brevo pasaban la credencial con
#   -H "api-key: $BREVO_API_KEY". Eso la deja escrita en el argv del proceso, y
#   /proc/<pid>/cmdline es 0444: lo lee CUALQUIER usuario local, no solo el dueno. Un 'ps'
#   durante la llamada la ensena. En probe_brevo_a_tamano.sh la ventana no es un instante,
#   son minutos, porque cada peticion sube decenas de MB.
#
#   La salida es el fichero de configuracion de curl leido por la ENTRADA ESTANDAR.
#   'printf' es una orden interna del shell, asi que no crea ningun proceso con la clave
#   en su argv, y el fichero de configuracion no toca el disco.
#
#   QUE MEJORA EXACTAMENTE, dicho con precision: saca la clave del argv, que es
#   world-readable. En el ENTORNO ya no viaja -- desde el 2026-09-17 el .env se lee con
#   lib_env_brevo.sh en vez de sourcearse con 'set -a', asi que BREVO_API_KEY no se exporta
#   y los hijos no la heredan. Lo que se paso a decir mal antes era "la clave fuera del ps":
#   /proc/<pid>/environ es 0400, asi que con 'set -a' la fuga era al propio usuario, no a
#   cualquiera. Distinta gravedad, y conviene no confundirlas.
#
#   Comprobado el 2026-09-17 contra un servidor local: la cabecera llega, los demas -H de
#   la linea de ordenes se suman, y --data-binary @fichero sigue funcionando porque la
#   entrada estandar no la usa el cuerpo.
#
# EL -q VA PRIMERO, Y NO ES COSMETICA
#   curl lee su fichero de configuracion por omision AUNQUE se le pase --config. Cita del
#   'man curl' de esta maquina (8.22.0): "When curl is invoked, it (unless --disable is
#   used) checks for a default config file and uses it if found, even when --config is
#   used", con el orden $CURL_HOME/.curlrc, $XDG_CONFIG_HOME/curlrc, $HOME/.curlrc.
#
#   Un curlrc admite 'url =' (una transferencia extra al host que diga, con las MISMAS
#   cabeceras y el MISMO cuerpo), 'proxy =', 'insecure', 'cacert =' y 'output ='. Medido en
#   127.0.0.1 el 2026-09-17: con un curlrc de una sola linea 'url = http://127.0.0.1:.../',
#   la llamada tal como la hace curl_brevo entregaba la cabecera 'api-key' a ese host.
#   Hoy no existe ni ~/.curlrc ni ~/.config/curlrc en esta maquina, asi que era latente;
#   pero CURL_HOME y XDG_CONFIG_HOME las consume curl, no el shell, asi que ni el orden de
#   las asignaciones ni brevo_limpia_funciones las tocan. '-q' como PRIMER parametro es lo
#   unico que apaga esa busqueda, y cuesta cuatro caracteres.
#
# USO
#   . "$AQUI/lib_curl_brevo.sh"
#   brevo_clave_valida "$BREVO_API_KEY" || { echo "ABORTA: ..." >&2; exit 3; }
#   curl_brevo "$BREVO_API_KEY" -sS --max-time 60 -o "$F" -D "$H" -w '%{http_code}' \
#     -H 'accept: application/json' "$BASE/account"
#
#   El primer argumento es la clave; el resto son los argumentos de curl, tal cual. El
#   codigo de salida es el de curl, asi que los '|| code="000"' de los sondeos siguen
#   valiendo.
#
# CUATRO SONDEOS NO LA USAN, Y SE QUEDAN ASI (E22, consejo 2026-09-28)
#   De los catorce probe_brevo*.sh, diez llaman a curl_brevo. Estos cuatro siguen con
#   -H "api-key: ..." en el argv:
#     probe_brevo_a_429_rps.sh, probe_brevo_a_ventana_y_reset.sh,
#     probe_brevo_a_caudal_solo_lectura.sh y probe_brevo_a_caudal_por_clave.sh
#   Su salida ya se cita en brevo/fuentes.md y en la Datasheet, asi que estan congelados:
#   su huella es el commit que los ejecuto, y migrarlos cambiaria el instrumento de una
#   evidencia ya citada. Si hubiera que volver a ejecutar alguno, se migra antes a
#   curl_brevo y su salida entra como evidencia nueva con fecha propia.
# =============================================================================

# El formato de la clave importa por dos motivos, y ninguno es cosmetico: un comillas
# doble rompe la linea del fichero de configuracion, y una almohadilla al principio del
# valor lo convertiria en comentario. Las claves de Brevo son xkeysib-<hex>-<alnum>, asi
# que el juego permitido es holgado; lo que sale de el es un error de configuracion y se
# dice antes de llamar a nada.
brevo_clave_valida () {  # $1 clave
  case "${1-}" in
    "") return 1 ;;
    *[!A-Za-z0-9_.:-]*) return 1 ;;
    *) return 0 ;;
  esac
}

curl_brevo () {  # $1 clave  $2.. argumentos de curl
  local K="${1-}"
  shift || true
  if ! brevo_clave_valida "$K"; then
    echo "ABORTA: la clave de API tiene caracteres fuera de [A-Za-z0-9_.:-] y no se puede" >&2
    echo "        pasar por el fichero de configuracion de curl. No se llama a nada." >&2
    return 99
  fi
  printf 'header = "api-key: %s"\n' "$K" | curl -q --config - "$@"
}
