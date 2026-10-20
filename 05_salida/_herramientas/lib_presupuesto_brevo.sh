# shellcheck shell=bash
# =============================================================================
# Libro de cuentas de los envios de Brevo - 2026-09-17
#
# UN SOLO LIBRO PARA LOS DOS PAQUETES, y una sola constante del tope.
#   Antes el tope estaba escrito dos veces -- en los dos sondeos del paquete B -- sobre un
#   libro compartido, y el paquete A no abria el libro en absoluto. Con eso, el tope de la
#   pasada vigilaba solo una parte del gasto: el paquete A declara cero envios, pero si una
#   guarda no se sostiene y Brevo ACEPTA una peticion, ese envio es real y el contador
#   tiene que verlo.
#
# QUE PIDE D-046 Y QUE PONE ESTA LIBRERIA.
#   D-046 (docs/08-mandato.md, «Envios de correo en los sondeos») exige tres condiciones:
#   comprobar el destinatario en el script, PRESUPUESTO DECLARADO y preferir el rechazo al
#   envio. La condicion 2 no fija ninguna cifra: dice que el script diga cuantos envios
#   gasta antes de correr. El tope de 3 es el de ESTA pasada y se escribe aqui, no en boca
#   del mandato.
#
# EL TOPE ES DE LA PASADA, Y LA PASADA SON LAS ULTIMAS 24 HORAS.
#   Antes se contaba el dia UTC. Eso cubria dos pasadas el mismo dia -- comparten tope, que
#   es el lado conservador -- pero no el caso contrario: una pasada que cruce las 00:00 UTC
#   estrenaba tope a mitad y podia gastar 3 + 3. No es teorico: la escalera del tamano lleva
#   --max-time 600 por peldano y el sondeo del 429 puede obligar a esperar una hora a que se
#   reponga la ventana de GET /v3/account. Con una ventana movil de 24 h no hay medianoche
#   que cruzar. Un tope que sumase toda la historia tampoco vale: abortaria la segunda
#   pasada legitima, y el remedio obvio para quien se lo encuentre es borrar el fichero a
#   mano, que es justo lo que no debe poder hacerse.
#
# NO VIVE EN ~/.cache.
#   Los limpiadores del sistema podan esa carpeta, y un contador que desaparece solo
#   devuelve el tope entero sin avisar a nadie. El libro vive en ~/.local/state/tfm/; el
#   estado de trabajo de cada sondeo, que si es desechable, se queda en ~/.cache.
#
# UN ENVIO = UN DESTINATARIO DE UNA PETICION ACEPTADA.  (corregido el 2026-09-17)
#   La unidad anterior era la PETICION, y era falsa justo donde mas caro sale:
#   probe_brevo_a_destinatarios.sh manda casos de 2.000 y 2.001 destinatarios, asi que una
#   peticion aceptada no gasta 1, gasta 2.000. Con la unidad vieja el tope de la pasada
#   vigilaba una cifra que no era la que se gastaba.
#
#   Por eso el libro lleva una columna de UNIDADES (destinatarios), y por eso la reserva
#   previa tambien va por destinatarios: antes de mandar un caso de N destinatarios el libro
#   reserva N, y si N no cabe en el margen de la ventana la peticion NO se manda. Un caso que
#   no cabe no se mide: se prefiere medir menos que medir mal.
#
#   RESERVA se escribe ANTES de la peticion. LIBERA solo cuando el rechazo esta DEMOSTRADO:
#   codigo 4xx explicito. Un 000 de curl, un cuerpo vacio o un 5xx NO demuestran nada -- la
#   peticion pudo ser aceptada y encolada y la respuesta perderse -- asi que la reserva se
#   queda puesta y el movimiento se anota como DUDOSO. Si el script muere a mitad, la
#   reserva tambien se queda puesta. Las dos cosas son el mismo criterio: el lado
#   conservador es asumir que salio.
#
# LA UNIDAD DE CUENTA SE SOSTIENE POR CONSTRUCCION, NO POR CONVENCION.  (2026-09-17)
#   El contador suma RESERVA y GASTO_DIRECTO y resta LIBERA. Eso era correcto solo mientras
#   todo GASTO fuese detras de una RESERVA de las mismas unidades; un sitio que anotase
#   GASTO sin reservar antes habria sido invisible para el tope. Ahora no depende de la
#   disciplina de quien llama:
#     - 'libro_anota GASTO' comprueba que hay una RESERVA del mismo tramo en la ventana. Si
#       no la hay, escribe GASTO_DIRECTO, que SI cuenta.
#     - un LIBERA resta como mucho lo que ese tramo tenga reservado. Un LIBERA sin RESERVA
#       no resta nada.
#
# EL LIBRO TIENE QUE PODER ESCRIBIR, Y SE COMPRUEBA.  (2026-09-17)
#   Con el libro presente pero no escribible -- 400, disco lleno, sistema de ficheros
#   remontado en solo lectura, atributo inmutable -- el append fallaba con un "Permiso
#   denegado" por stderr que nadie miraba, reservar() devolvia 0 e imprimia "reservados 2",
#   y libro_comprometido volvia a leer 0. El tope dejaba de morder por completo, sin ningun
#   ataque y con el .env de hoy. Ahora: libro_exige_escritura() aborta antes de la primera
#   llamada, libro_anota() devuelve el codigo del append y reservar() RELEE el contador y
#   exige que haya subido. Un tope que no se puede anotar es lo mismo que no tener tope.
#
# EL RESULTADO DE UNA PETICION DE ENVIO SE LEE DE DOS FORMAS, NO DE TRES.
#   4xx explicito = rechazo demostrado, el sondeo sigue. CUALQUIER OTRA COSA -- 000, 5xx,
#   cuerpo vacio, timeout -- es "no se sabe": DUDOSO en el libro, PARADA puesta y ABORTA.
#
# LA PARADA.
#   Un fichero testigo. Lo pone cualquier sondeo que vea un 2xx en un endpoint de envio
#   donde no debia haberlo -- o un resultado sin resolver -- y lo mira todo sondeo antes de
#   su primera llamada. Sin el, una guarda que no se sostiene gasta un envio en CADA script
#   del paquete, cada uno habiendo impreso "envios reales: 0".
#
# DE DONDE NO PUEDE VENIR NADA DE ESTO: DEL .env.
#   Hasta el 2026-09-17 los sondeos hacian 'set -a; . ~/.config/tfm/.env; set +a', y esa
#   pareja define CUALQUIER nombre del shell. La defensa declarada era el ORDEN de las
#   asignaciones mas 'readonly', y ninguna de las dos sujeta un source: con
#   'readonly () { return 0; }' en el fichero, cada 'readonly X=...' pasa a ser una LLAMADA
#   a esa funcion y la variable conserva lo que el .env le dio; con 'readonly TOPE_PASADA=99'
#   por delante, la asignacion de esta libreria FALLA y, como ningun sondeo usa 'set -e', el
#   proceso sigue. Medido en esta maquina. La correccion esta en lib_env_brevo.sh: el .env se
#   LEE, no se sourcea. Lo de aqui son dos cinturones mas, no la defensa:
#     - las comparaciones que gobiernan el tope, la PARADA o un destinatario se escriben con
#       [[ ]] y (( )), que son palabras reservadas y no se pueden sombrear con una funcion;
#       '[' si se puede (comprobado: 'declare -F [' funciona).
#     - al final del fichero se COMPRUEBA el valor de las tres constantes y se aborta si no
#       es el esperado. Comprobar es una defensa; declarar 'readonly' no lo era.
#
# USO
#   . "$AQUI/lib_env_brevo.sh"                # primero las librerias, que son del repo
#   . "$AQUI/lib_presupuesto_brevo.sh"
#   brevo_carga_env                           # y DESPUES el .env, leido como dato
#   libro_init; libro_exige_escritura
#   libro_cabe <n>                        # 0 si n destinatarios caben en el margen
#   reservar "<tramo>" <n>                # aborta (exit 4) si el tope no da; (exit 5) si el
#                                         # libro no acepta la anotacion
#   libro_anota GASTO   "<tramo>" "..." <n>   # peticion aceptada: el correo salio
#   libro_anota LIBERA  "<tramo>" "..." <n>   # rechazo DEMOSTRADO (4xx): no salio
#   libro_anota DUDOSO  "<tramo>" "..." <n>   # resultado ambiguo: cuenta como gastado
#   libro_veredicto_http "<codigo>"       # imprime aceptada|rechazada|dudosa
#   paquete_a_cerrar "<tramo>" "<codigo>" <n> # cierra una peticion del paquete A
#   (brevo_limpia_funciones vive en lib_env_brevo.sh y se llama ANTES de esta libreria)
# =============================================================================

# El tope de la pasada entera de Brevo, paquetes A y B juntos. Escrito aqui y en ningun
# otro sitio: no es una variable de entorno, porque un tope que se cambia desde fuera no es
# un tope. La cifra es de esta pasada; D-046 pide presupuesto declarado, no un numero.
TOPE_PASADA=3

# Las dos rutas van FIJAS, no con "${LIBRO:-...}": un libro que se redirige con una
# variable de entorno da tres envios nuevos cada vez que alguien lo apunta a un fichero
# vacio, que es el mismo agujero que un tope cambiable desde fuera. $HOME se interpola
# aqui, y ya no hay source del .env que pueda cambiarlo por debajo; la comprobacion del
# final del fichero verifica que las dos rutas son las que este fichero dice.
LIBRO="$HOME/.local/state/tfm/presupuesto_brevo.tsv"
PARADA="$HOME/.local/state/tfm/brevo_parada.txt"

# Ventana de la pasada: 24 horas. Se devuelve un sello UTC comparable como cadena, que es
# como estan escritas las fechas del libro. Si 'date' no sabe restar horas, se devuelve
# vacio y quien cuenta se pone en el lado conservador: cuenta TODO el libro.
libro_corte () {
  local C
  C="$(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || true)"
  if [[ -z $C ]]; then
    C="$(date -u -d "@$(( $(date -u +%s) - 86400 ))" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || true)"
  fi
  printf '%s' "$C"
}

libro_init () {
  mkdir -p "$(dirname "$LIBRO")" 2>/dev/null || true
  chmod 700 "$(dirname "$LIBRO")" 2>/dev/null || true
  if [[ ! -f $LIBRO ]]; then
    {
      printf '# libro de cuentas de los envios de Brevo (D-046 condicion 2: presupuesto declarado)\n'
      printf '# tope de la pasada: %s envios. La pasada son las ultimas 24 horas.\n' "$TOPE_PASADA"
      printf '# un envio = UN DESTINATARIO de una peticion ACEPTADA (corregido 2026-09-17).\n'
      printf '# LIBERA solo con rechazo demostrado (4xx). Un 000 no demuestra nada: DUDOSO.\n'
      printf '# utc\tmovimiento\tscript\ttramo\tunidades\tdetalle\n'
    } > "$LIBRO" || return 1
    chmod 600 "$LIBRO" 2>/dev/null || true
  fi
  return 0
}

# Que el libro ACEPTE una escritura, comprobado antes de la primera llamada. No escribe
# ninguna linea: abre en modo append y mira si el shell pudo. Aborta el sondeo, porque un
# presupuesto que no se puede anotar no vigila nada.
libro_exige_escritura () {
  libro_init || {
    echo "ABORTA: no se pudo crear el libro de cuentas $LIBRO. Sin libro no hay" >&2
    echo "        presupuesto que vigilar, asi que no se llama a nada." >&2
    exit 5
  }
  if ! : >> "$LIBRO" 2>/dev/null; then
    echo "ABORTA: el libro $LIBRO existe pero NO acepta escrituras." >&2
    echo "        Causas tipicas: permisos (mira si esta en 400), disco lleno, sistema de" >&2
    echo "        ficheros en solo lectura o atributo inmutable. Con el libro sordo cada" >&2
    echo "        llamada creeria tener el tope entero libre, asi que no se envia nada." >&2
    exit 5
  fi
  # La PARADA no se prueba escribiendo: vive en el MISMO directorio que el libro, asi que el
  # append de arriba ya demuestra que ese directorio acepta escrituras. Lo unico que queda
  # por mirar es el caso del testigo que existe y no se puede ampliar -- y crear el fichero
  # para probarlo seria peor: un testigo vacio se lee como PARADA puesta y abortaria la
  # pasada entera si el script muriese entre la prueba y el borrado.
  if [[ -e $PARADA && ! -w $PARADA ]]; then
    echo "ABORTA: el testigo de PARADA $PARADA existe y no acepta escrituras, asi que un" >&2
    echo "        envio inesperado no podria frenar los sondeos siguientes de la pasada." >&2
    echo "        No se llama a nada." >&2
    exit 5
  fi
  return 0
}

# El tope que el libro lleva grabado en su cabecera. Si alguien cambio la constante entre
# dos pasadas de la misma ventana, manda el MENOR de los dos: el fichero no puede documentar
# un tope y el script aplicar otro mas alto.
libro_tope_efectivo () {
  local G T
  G="$(awk -F'tope de la pasada: ' '/^# tope de la pasada:/{split($2,a," "); print a[1]; exit}' \
        "$LIBRO" 2>/dev/null)"
  T="$TOPE_PASADA"
  case "$G" in
    ''|*[!0-9]*) printf '%s' "$T"; return 0 ;;
  esac
  if (( G < T )); then printf '%s' "$G"; else printf '%s' "$T"; fi
}

# Normaliza un numero de destinatarios. Lo que no sea un entero positivo vale 1: el lado
# conservador es contar algo, nunca cero.
libro_unidades () {  # $1
  local N="${1:-1}"
  case "$N" in ''|*[!0-9]*) N=1 ;; esac
  (( N >= 1 )) 2>/dev/null || N=1
  printf '%d' "$N"
}

# Comprometidos en la ventana, EN DESTINATARIOS: RESERVA + GASTO_DIRECTO - LIBERA, cada
# movimiento por sus unidades, y un LIBERA resta como mucho lo reservado en su tramo.
# DUDOSO no resta: la reserva que lo acompana se queda puesta a proposito.
# La columna de unidades es la 5.a; una linea sin ella -- de un libro anterior al
# 2026-09-17 -- vale 1, que es lo que aquella version quiso decir.
# Llama a libro_init antes de contar: con el fichero ausente awk no imprime nada, y un
# contador que devuelve la cadena vacia se lee como cero en el sitio donde mas caro sale.
libro_comprometido () {
  libro_init || true
  local CORTE C
  CORTE="$(libro_corte)"
  if [[ -z $CORTE ]]; then
    echo "AVISO: no se pudo calcular la ventana de 24 h; se cuenta el libro ENTERO." >&2
    CORTE=""
  fi
  C="$(awk -F'\t' -v corte="$CORTE" '
    /^#/ {next}
    NF < 2 {next}
    corte != "" && $1 < corte {next}
    { u = ($5 ~ /^[0-9]+$/) ? $5 + 0 : 1 }
    $2=="RESERVA"       {res[$4] += u; total += u; next}
    $2=="GASTO_DIRECTO" {total += u; next}
    $2=="LIBERA" {
      libre = res[$4] - lib[$4]
      if (libre < 0) libre = 0
      l = (u < libre) ? u : libre
      lib[$4] += l
      total -= l
      next
    }
    END {printf "%d", total+0}' "$LIBRO" 2>/dev/null)"
  case "$C" in
    ''|*[!0-9]*) printf '%s' "$TOPE_PASADA"   # ilegible: se supone el tope gastado
                 echo "AVISO: el libro $LIBRO no se pudo leer; se supone el tope agotado." >&2 ;;
    *) printf '%s' "$C" ;;
  esac
}

# Hay una RESERVA de este tramo en la ventana? Lo usa libro_anota para decidir si un GASTO
# cierra una reserva previa o es un gasto que nadie reservo.
libro_tiene_reserva () {  # $1 tramo
  local CORTE
  CORTE="$(libro_corte)"
  awk -F'\t' -v corte="$CORTE" -v tramo="$1" '
    /^#/ {next}
    corte != "" && $1 < corte {next}
    $2=="RESERVA" && $4==tramo {encontrada=1}
    END {exit encontrada ? 0 : 1}' "$LIBRO" 2>/dev/null
}

# Hay en la ventana un movimiento de otro sondeo que resuelva un tramo suyo? Sirve para que
# una fase PRESCINDIBLE de un sondeo no se gaste el margen que la pregunta PRINCIPAL de otro
# necesita. El orden de la pasada esta escrito, pero un orden escrito no es un orden
# comprobado: si alguien lanza los dos sondeos del paquete B al reves, el peldano de control
# del tamano (1 destinatario) se lleva el margen y la unidad de la cuota (2) ya no cabe.
# Cuenta GASTO, GASTO_DIRECTO y DUDOSO: las tres significan "esa peticion ya se pago".
libro_tramo_pagado () {  # $1 script  $2 tramo
  local CORTE; CORTE="$(libro_corte)"
  awk -F'\t' -v corte="$CORTE" -v s="$1" -v tr="$2" '
    /^#/ {next}
    corte != "" && $1 < corte {next}
    ($2=="GASTO" || $2=="GASTO_DIRECTO" || $2=="DUDOSO") && $3==s && $4==tr {visto=1}
    END {exit visto ? 0 : 1}' "$LIBRO" 2>/dev/null
}

# Devuelve el codigo del append. Sin esto, reservar() daba por hecha una anotacion que el
# sistema de ficheros habia rechazado.
libro_anota () {  # $1 movimiento  $2 tramo  $3 detalle  $4 unidades (destinatarios, 1 por omision)
  libro_init || return 1
  local MOV="$1"
  # Un GASTO que no cierra ninguna RESERVA se escribe como GASTO_DIRECTO, que es el
  # movimiento que SI suma. Asi la unidad de cuenta no depende de que quien llama se acuerde
  # de reservar antes.
  if [[ $MOV == GASTO ]] && ! libro_tiene_reserva "$2"; then
    MOV=GASTO_DIRECTO
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$MOV" \
    "$(basename "${0:-sondeo}")" "$2" "$(libro_unidades "${4:-1}")" "$3" >> "$LIBRO"
}

# Caben N destinatarios en lo que queda de la ventana? Se consulta ANTES de construir el
# cuerpo, para no montar una peticion de 2.000 destinatarios -- ni subir 184 MB -- que el
# tope no puede cubrir. No toca el libro.
libro_cabe () {  # $1 destinatarios
  local N C T; N="$(libro_unidades "${1:-1}")"
  C="$(libro_comprometido)"; T="$(libro_tope_efectivo)"
  (( C + N <= T ))
}

reservar () {  # $1 tramo  $2 destinatarios. Aborta con exit 4 si el tope no da, 5 si el libro no anota.
  libro_init || true
  local C T N D; N="$(libro_unidades "${2:-1}")"
  C="$(libro_comprometido)"; T="$(libro_tope_efectivo)"
  if (( C + N > T )); then
    echo "ABORTA: el tramo '$1' son $N destinatarios, el libro ya tiene $C comprometidos"
    echo "        en la ventana de 24 h y el tope de la pasada es $T. No se envia nada."
    echo "        Libro: $LIBRO"
    echo "        Un envio = UN DESTINATARIO de una peticion aceptada: un caso que no cabe"
    echo "        no se mide, y la pregunta vuelve sin responder."
    exit 4
  fi
  if ! libro_anota RESERVA "$1" "tope=$T comprometidos_antes=$C destinatarios=$N" "$N"; then
    parada_poner "el libro no acepta escrituras: $LIBRO" || true
    echo "ABORTA: la reserva de '$1' NO se pudo anotar en $LIBRO, asi que no hay"
    echo "        presupuesto que vigilar. No se manda nada."
    exit 5
  fi
  # Relectura: el append puede fallar en silencio (sistemas de ficheros en red, cuota
  # llena). Sin comprobar que el contador SUBIO, la reserva es una linea impresa por
  # pantalla y nada mas.
  D="$(libro_comprometido)"
  if (( D != C + N )); then
    parada_poner "el libro no refleja la reserva de '$1': antes=$C despues=$D esperado=$((C + N))" || true
    echo "ABORTA: el libro dice $D comprometidos cuando la reserva de $N sobre $C tendria"
    echo "        que dejar $((C + N)). La anotacion no cuajo y el tope no esta vigilando."
    echo "        No se manda nada. Libro: $LIBRO"
    exit 5
  fi
  echo "   libro: reservados $N destinatario(s) (comprometidos $D/$T)"
}

# Margen que queda en la ventana. Sirve para decir "esta fase no cabe" ANTES de reservar,
# en vez de abortar a mitad de un sondeo con el par de bisercion sin cerrar.
libro_margen () {
  libro_init || true
  local C T; C="$(libro_comprometido)"; T="$(libro_tope_efectivo)"
  printf '%d' "$((T - C))"
}

# Como se lee un codigo HTTP a efectos del libro. La regla entera esta en la cabecera:
# solo un 4xx explicito demuestra que la peticion no fue aceptada.
libro_veredicto_http () {  # $1 codigo tal como lo escribio curl
  case "${1-}" in
    2[0-9][0-9]) printf 'aceptada' ;;
    4[0-9][0-9]) printf 'rechazada' ;;
    *)           printf 'dudosa' ;;
  esac
}

# --- La parada -------------------------------------------------------------------------
parada_puesta () { [[ -f $PARADA ]]; }

parada_motivo () { cat "$PARADA" 2>/dev/null || true; }

# Devuelve el codigo de la escritura. Si el testigo no se puede poner, el freno entre
# sondeos no existe y hay que decirlo a gritos: el sondeo que llama aborta igual, pero el
# SIGUIENTE arrancaria como si nada.
parada_poner () {  # $1 motivo
  mkdir -p "$(dirname "$PARADA")" 2>/dev/null || true
  if ! printf '%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$(basename "${0:-sondeo}")" \
        "${1-}" >> "$PARADA"; then
    echo "!!! LA PARADA NO SE PUDO PONER en $PARADA. El freno entre sondeos NO existe:" >&2
    echo "!!! el siguiente script de la pasada arrancaria como si no hubiera pasado nada." >&2
    echo "!!! Motivo que se queria anotar: ${1-}" >&2
    echo "!!! Parar la pasada A MANO antes de lanzar nada mas." >&2
    return 1
  fi
  chmod 600 "$PARADA" 2>/dev/null || true
  return 0
}

# Lo llama todo sondeo que pueda llegar a un endpoint de envio, antes de su primera
# llamada. Un envio que no debia haber salido invalida el paquete entero: lo que se hace
# con el es mirarlo, no seguir gastando.
parada_comprobar () {
  if parada_puesta; then
    echo "ABORTA: hay una PARADA puesta por un sondeo anterior de esta pasada." >&2
    echo "        Motivo:" >&2
    parada_motivo | sed 's/^/        /' >&2
    echo "        Una peticion de envio fue ACEPTADA -- o quedo sin resolver -- donde no" >&2
    echo "        debia. Antes de relanzar nada: leer el JSON de ese sondeo, apuntar el" >&2
    echo "        envio en el libro y borrar $PARADA a mano." >&2
    exit 5
  fi
}

# --- Como cierra el PAQUETE A una peticion de envio ------------------------------------
# La invariante del paquete A es que ninguna peticion puede ser ACEPTADA, y el resultado se
# lee de DOS formas, no de tres:
#   4xx explicito  -> rechazo DEMOSTRADO. Libera la reserva y el sondeo sigue.
#   2xx            -> la guarda no se sostiene. GASTO, PARADA y aborta.
#   lo demas       -> no se sabe (000 de curl, 5xx, cuerpo vacio, timeout). La peticion pudo
#                     ser aceptada y encolada y la respuesta perderse, asi que DUDOSO
#                     (la reserva se queda puesta), PARADA y aborta.
# Devuelve 0 si el sondeo puede seguir, 3 si la invariante esta rota y 7 si no se sabe.
# Quien llama tiene que propagar ese codigo: 'paquete_a_cerrar ... || { RC=$?; ...; exit $RC; }'
paquete_a_cerrar () {  # $1 tramo  $2 codigo http  $3 destinatarios
  local E="$1" C="$2" N; N="$(libro_unidades "${3:-1}")"
  case "$(libro_veredicto_http "$C")" in
    rechazada)
      libro_anota LIBERA "$E" \
        "http=$C rechazo demostrado (4xx): la peticion NO fue aceptada" "$N" || true
      return 0 ;;
    aceptada)
      libro_anota GASTO "$E" \
        "http=$C 2xx INESPERADO en un endpoint de envio (paquete A): $N destinatarios" "$N" || true
      parada_poner "$E devolvio $C en un endpoint de envio con $N destinatarios: la guarda no se sostiene" || true
      echo "!!! ABORTA: el endpoint de envio devolvio $C (ACEPTADA) en '$E'. La invariante" >&2
      echo "!!! del paquete A esta ROTA: con $N destinatario(s) habria salido correo si" >&2
      echo "!!! pudiesen recibir. Anotados $N en el libro y PARADA puesta: ningun otro" >&2
      echo "!!! sondeo del paquete arrancara hasta que se mire esto a mano." >&2
      return 3 ;;
    *)
      libro_anota DUDOSO "$E" \
        "http=$C resultado ambiguo: no se sabe si la peticion fue aceptada; la reserva se queda puesta" "$N" || true
      parada_poner "$E devolvio '$C' en un endpoint de envio con $N destinatarios: no se sabe si fue aceptada" || true
      echo "!!! ABORTA: el endpoint de envio devolvio '$C' en '$E', que NO demuestra" >&2
      echo "!!! rechazo. Brevo pudo aceptar la peticion y perderse la respuesta, asi que" >&2
      echo "!!! los $N destinatario(s) se anotan DUDOSO -- cuentan como gastados -- y se" >&2
      echo "!!! pone la PARADA. Sin un 4xx explicito no hay vara de medir y el bucle NO" >&2
      echo "!!! escala: el caso siguiente no se construye." >&2
      return 7 ;;
  esac
}

# --- El cierre: las tres constantes, COMPROBADAS ---------------------------------------
# 'readonly' no servia de defensa (ver la cabecera). Lo que si sirve es mirar el valor
# despues de asignarlo y abortar si no es el que este fichero escribe. Va al final a
# proposito: antes de esta linea las asignaciones de arriba tienen que poder ejecutarse.
if [[ $TOPE_PASADA != 3 ]] \
   || [[ $LIBRO != "$HOME/.local/state/tfm/presupuesto_brevo.tsv" ]] \
   || [[ $PARADA != "$HOME/.local/state/tfm/brevo_parada.txt" ]]; then
  echo "ABORTA: el entorno suplanto una constante del presupuesto." >&2
  echo "        tope='$TOPE_PASADA' (esperado 3)" >&2
  echo "        libro='$LIBRO'" >&2
  echo "        parada='$PARADA'" >&2
  echo "        Sin esas tres cifras no hay presupuesto que declarar, asi que no se llama" >&2
  echo "        a nada. La pasada se para y se mira el entorno del que salio." >&2
  exit 3
fi
readonly TOPE_PASADA LIBRO PARADA
