#!/usr/bin/env bash
# Sondeo empirico Brevo (escalon 3) - SOLO LECTURA - 2026-09-18
#
# PREGUNTA QUE RESUELVE
#   Q-A4 y el hueco 8 de 'not_found': el caudal de Brevo se cuenta POR CUENTA o POR CLAVE
#   de API? Ninguna fuente lo publica, y el modelo cambia por completo segun la respuesta:
#   si es por clave, un cliente multiplica su caudal creando claves; si es por cuenta, el
#   tope es del titular y v0.3 lo declara donde debe.
#
#   EL PAR DECISIVO. Se leen seis GET /account seguidos y se mira x-sib-ratelimit-remaining:
#     - si la clave 2 continua la serie descendente de la clave 1 (remaining_k2 ~ ultimo de
#       k1 menos 1), el cubo es UNO SOLO y el caudal es POR CUENTA;
#     - si la clave 2 arranca cerca de x-sib-ratelimit-limit mientras la 1 ya ha bajado,
#       cada clave tiene su cubo y el caudal es POR CLAVE.
#   El brazo de vuelta (k1_d despues de k2_a) separa las dos lecturas de un tercer caso: que
#   la ventana se haya repuesto en medio, que dejaria las dos series altas por un motivo que
#   no es la segmentacion.
#
# COSTE EN ENVIOS: 0. No hay POST y no se construye ningun cuerpo de correo, asi que no hay
#   destinatario que comprobar contra la lista blanca de D-046. Presupuesto: 6 peticiones
#   GET al bucket de "All other endpoints".
#
# USO
#   bash probe_brevo_a_caudal_por_clave.sh [salida.json]
set -u
unset CDPATH
readonly AQUI="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
. "$AQUI/lib_env_brevo.sh" || exit 3
brevo_exige_funciones brevo_carga_env brevo_limpia_funciones || exit 3
brevo_limpia_funciones
brevo_carga_env || exit 3
if [[ -z ${BREVO_API_KEY:-} ]]; then
  echo "ABORTA: BREVO_API_KEY vacia tras leer el .env." >&2
  exit 3
fi
if [[ -z ${BREVO_API_KEY_2:-} ]]; then
  echo "ABORTA: BREVO_API_KEY_2 vacia. Este sondeo mide la segmentacion y necesita las dos." >&2
  exit 3
fi
if [[ ${BREVO_API_KEY} == "${BREVO_API_KEY_2}" ]]; then
  echo "ABORTA: las dos claves son la misma cadena: no hay nada que segmentar." >&2
  exit 3
fi

readonly BASE="https://api.brevo.com/v3"
readonly SELLO="$(date -u +%Y-%m-%d_%H%M%S)"
readonly SALIDA="${1:-03_datos/apis/brevo/evidencias/probe_brevo_a_caudal_por_clave_${SELLO}.json}"
readonly TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT

# caso|clave|ruta -- ni una linea con el endpoint de envio. Solo lectura.
readonly CASOS=(
  "k1_a|1|/account"
  "k1_b|1|/account"
  "k1_c|1|/account"
  "k2_a|2|/account"
  "k1_d|1|/account"
  "k2_b|2|/account"
)

for C in "${CASOS[@]}"; do
  NOMBRE="${C%%|*}"; RESTO="${C#*|}"; CUAL="${RESTO%%|*}"; RUTA="${RESTO#*|}"
  if [[ $RUTA == "/smtp/email" || $RUTA == "/smtp/email?"* ]]; then
    echo "ABORTA: $NOMBRE apunta al endpoint de envio. Este sondeo es de lectura." >&2
    exit 3
  fi
  if [[ $CUAL == 1 ]]; then CLAVE="$BREVO_API_KEY"; else CLAVE="$BREVO_API_KEY_2"; fi
  curl -sS -o "$TMP/$NOMBRE.body" -D "$TMP/$NOMBRE.head" -w '%{http_code}' \
       -H "api-key: $CLAVE" -H 'accept: application/json' \
       "$BASE$RUTA" > "$TMP/$NOMBRE.code" 2> "$TMP/$NOMBRE.err" || true
  echo "$CUAL" > "$TMP/$NOMBRE.clave"
  sleep 2
done

python3 -I - "$TMP" "$SALIDA" "$BREVO_API_KEY" "$BREVO_API_KEY_2" <<'PYEOF'
import json, re, sys, pathlib, datetime
tmp, salida = pathlib.Path(sys.argv[1]), sys.argv[2]
claves = [c for c in sys.argv[3:5] if c]
RE_CORREO = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")


def redacta(s):
    for i, c in enumerate(claves, 1):
        s = s.replace(c, "<BREVO_API_KEY_%d>" % i)
    s = RE_CORREO.sub("<CORREO_REDACTADO>", s)
    s = re.sub(r'"address"\s*:\s*\{[^}]*\}', '"address":"<REDACTADO>"', s)
    for campo in ("firstName", "lastName", "userName", "companyName",
                  "organization_id", "user_id"):
        s = re.sub('"' + campo + r'"\s*:\s*"[^"]*"', '"' + campo + '":"<REDACTADO>"', s)
        s = re.sub('"' + campo + r'"\s*:\s*[0-9]+', '"' + campo + '":0', s)
    return s


casos = {}
for head in sorted(tmp.glob("*.head")):
    n = head.stem
    cab = {}
    for linea in head.read_text(errors="replace").splitlines():
        if ":" in linea:
            k, _, v = linea.partition(":")
            if k.lower().startswith("x-sib-ratelimit"):
                cab[k.lower().strip()] = v.strip()
    code = (tmp / (n + ".code")).read_text().strip() if (tmp / (n + ".code")).exists() else ""
    cual = (tmp / (n + ".clave")).read_text().strip() if (tmp / (n + ".clave")).exists() else ""
    cuerpo = (tmp / (n + ".body")).read_text(errors="replace")[:900] if (tmp / (n + ".body")).exists() else ""
    casos[n] = {"metodo": "GET", "ruta": "/account", "clave": cual, "http": code,
                "cabeceras_caudal": cab, "cuerpo_recortado": redacta(cuerpo)}


def num(n, campo):
    v = casos.get(n, {}).get("cabeceras_caudal", {}).get(campo)
    try:
        return int(v)
    except (TypeError, ValueError):
        return None


rem = {n: num(n, "x-sib-ratelimit-remaining") for n in casos}
lim = {n: num(n, "x-sib-ratelimit-limit") for n in casos}
k1c, k2a, k1d = rem.get("k1_c"), rem.get("k2_a"), rem.get("k1_d")
tope = lim.get("k1_a")
if None in (k1c, k2a, k1d):
    veredicto = ("sin decidir: falta la cabecera remaining en alguno del par "
                 "(k1_c=%r, k2_a=%r, k1_d=%r)" % (k1c, k2a, k1d))
elif k1d > k1c:
    veredicto = ("sin decidir: la ventana se repuso en medio (k1_d=%d por encima de k1_c=%d), "
                 "asi que la serie no es comparable" % (k1d, k1c))
elif k2a == k1c - 1:
    veredicto = ("POR CUENTA: la clave 2 continua la serie de la clave 1 "
                 "(k1_c=%d, k2_a=%d, k1_d=%d): un solo cubo" % (k1c, k2a, k1d))
elif tope and k2a >= tope - 2 and k1c < tope - 2:
    veredicto = ("POR CLAVE: la clave 2 arranca en %d con tope %d mientras la clave 1 iba por %d: "
                 "dos cubos" % (k2a, tope, k1c))
else:
    veredicto = ("ambiguo: k1_c=%d, k2_a=%d, k1_d=%d, tope=%r. No encaja en ninguna de las "
                 "dos lecturas y no se adopta valor" % (k1c, k2a, k1d, tope))

res = {"resumen": {"api": "brevo", "sondeo": "caudal_por_clave", "pregunta": "Q-A4 / hueco 8",
                   "fecha_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                   "envios_reales": sum(1 for c in casos.values()
                                        if c["metodo"] == "POST" and c["http"].startswith("2")),
                   "peticiones": len(casos),
                   "remaining_por_caso": rem, "limit_por_caso": lim,
                   "veredicto": veredicto},
       "casos": casos}
pathlib.Path(salida).write_text(json.dumps(res, ensure_ascii=False, indent=1), encoding="utf-8")
print(json.dumps(res["resumen"], ensure_ascii=False, indent=1))
PYEOF
