#!/usr/bin/env bash
# Sondeo empirico Brevo (escalon 3) - PAQUETE A, CERO ENVIOS - 2026-09-18
#
# PREGUNTA QUE RESUELVE
#   Tres, con una sola rafaga, y las tres POR CONSTRUCCION (E7: "un delta que las dos
#   lecturas predicen no mide nada"):
#
#   DISC-12: que trae el CUERPO del 429. El blog publica {"code":"too_many_requests"}
#     [F28] y ese valor no existe ni en la tabla de codigos [F9] ni en el enum errorModel
#     del OpenAPI [F21]. La unica via es alcanzar el 429 y leerlo.
#   DISC-13: en que unidad viene x-sib-ratelimit-reset. El sondeo de unidad del 2026-09-18
#     midio reset=1 constante con remaining volviendo a 1 tras 8,6 s y tras 21,6 s, y eso
#     NO distingue "queda 1 segundo" de "un 1 constante que no cuenta nada". Se separan
#     agotando la ventana: si tras el 429 la peticion vuelve a pasar ~1 s despues, el 1 es
#     un segundo. Si no vuelve hasta la hora, el 1 no describe esta ventana.
#   E-D024: "verde solo si el sondeo alcanza la respuesta de rechazo (429)". Este es el
#     unico sondeo de la pasada que puede sostener un VERDE para un rate de Brevo.
#
#   POR QUE /v3/smtp/emails Y NO "All other endpoints"
#     probe_brevo_a_cuerpo_429.sh ataca el bucket de "All other endpoints", que [F6]
#     publica en 100 RPH y que [E2] midio en 'x-sib-ratelimit-limit: 5000': agotarlo son
#     miles de peticiones y deja GET /v3/account devolviendo 429 hasta una hora, que es la
#     lectura de la que depende todo lo demas. GET /v3/smtp/emails tiene fila propia de
#     2 RPS medidos ([E2] y el sondeo de unidad), asi que el rechazo llega con TRES
#     peticiones y la ventana que se agota dura un segundo.
#
# COSTE EN ENVIOS: 0. Ni un POST. Presupuesto: hasta 11 peticiones GET.
#   Buckets: la fila propia de GET /v3/smtp/emails (2 RPS / 7.200 RPH) a proposito, y una
#   lectura de control en el prefijo /v3/smtp/{...} y otra en "All other endpoints".
#   Duracion: unos 10 s.
#
# DESTINATARIOS (D-046): ninguno. No se construye ningun cuerpo de correo.
#
# USO
#   bash probe_brevo_a_429_rps.sh [salida.json]   (lee BREVO_API_KEY de ~/.config/tfm/.env)
#   bash probe_brevo_a_429_rps.sh --solo-funciones  (para el test del guardian)
set -u
unset CDPATH

# El endpoint de envio es /smtp/email EXACTO. /smtp/emails lo contiene como subcadena y es
# justo el que hay que golpear, asi que no vale un '*/smtp/email*'.
ruta_es_envio () {  # $1 ruta; 0 = es envio
  [[ $1 == "/smtp/email" || $1 == "/smtp/email?"* ]]
}

# El test carga este fichero para probar el guardian sin llamar a la API.
if [[ ${1:-} == "--solo-funciones" ]]; then
  return 0 2>/dev/null || exit 0
fi

readonly AQUI="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
. "$AQUI/lib_env_brevo.sh" || exit 3
brevo_exige_funciones brevo_carga_env brevo_limpia_funciones || exit 3
brevo_limpia_funciones
brevo_carga_env || exit 3
if [[ -z ${BREVO_API_KEY:-} ]]; then
  echo "ABORTA: BREVO_API_KEY vacia tras leer el .env." >&2
  exit 3
fi

readonly BASE="https://api.brevo.com/v3"
readonly SALIDA="${1:-/tmp/probe_brevo_429_rps.json}"
readonly TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT

readonly RUTA_MEDIDA="/smtp/emails?limit=1"
readonly RAFAGA=5          # tope duro: 2 RPS medidos, el rechazo cae en la tercera
readonly RUTAS_CONTROL=("/smtp/templates?limit=1" "/account")

pide () {  # $1 nombre  $2 ruta
  local NOMBRE="$1" RUTA="$2"
  if ruta_es_envio "$RUTA"; then
    echo "ABORTA: $NOMBRE apunta al endpoint de envio. Este sondeo es de lectura." >&2
    exit 3
  fi
  date -u +%s.%N > "$TMP/$NOMBRE.t"
  curl -sS -o "$TMP/$NOMBRE.body" -D "$TMP/$NOMBRE.head" -w '%{http_code} %{method}' \
       -H "api-key: $BREVO_API_KEY" -H 'accept: application/json' \
       "$BASE$RUTA" > "$TMP/$NOMBRE.code" 2> "$TMP/$NOMBRE.err" || true
  printf '%s' "$RUTA" > "$TMP/$NOMBRE.ruta"
}

# --- Fase 1: la rafaga. Sin pausas: hay que meter 3 peticiones en el mismo segundo -------
for I in $(seq 1 "$RAFAGA"); do
  pide "$(printf 'f1_rafaga_%02d' "$I")" "$RUTA_MEDIDA"
  if [[ "$(cut -d' ' -f1 "$TMP/$(printf 'f1_rafaga_%02d' "$I")".code)" == "429" ]]; then break; fi
done

# --- Fase 2: control inmediato. El 429 de la fila propia, ¿alcanza a las otras filas? ----
N=0
for R in "${RUTAS_CONTROL[@]}"; do
  N=$((N + 1)); pide "$(printf 'f2_control_%02d' "$N")" "$R"
done

# --- Fase 3: la recuperacion, que es la medida de la unidad ------------------------------
# 1,2 s despues del rechazo. Si vuelve a pasar, el reset=1 era un segundo.
sleep 1.2
pide "f3_tras_1200ms" "$RUTA_MEDIDA"

python3 -I - "$TMP" "$SALIDA" "$BREVO_API_KEY" <<'PYEOF'
import json, re, sys, pathlib, datetime
tmp, salida, clave = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
RE_CORREO = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
def redacta(s):
    if clave:
        s = s.replace(clave, "<BREVO_API_KEY>")
    s = RE_CORREO.sub("<CORREO_REDACTADO>", s)
    s = re.sub(r'"address"\s*:\s*\{[^}]*\}', '"address":"<REDACTADO>"', s)
    for campo in ("firstName", "lastName", "userName", "companyName",
                  "organization_id", "user_id"):
        s = re.sub('"' + campo + r'"\s*:\s*"[^"]*"', '"' + campo + '":"<REDACTADO>"', s)
        s = re.sub('"' + campo + r'"\s*:\s*[0-9]+', '"' + campo + '":0', s)
    return s

casos = {}
for t in sorted(tmp.glob("*.t")):
    n = t.stem
    cab_todas, cab_caudal = {}, {}
    head = tmp / f"{n}.head"
    if head.exists():
        for linea in head.read_text(errors="replace").splitlines():
            if ":" in linea and not linea.startswith("HTTP/"):
                k, _, v = linea.partition(":")
                k = k.lower().strip(); v = v.strip()
                cab_todas[k] = v
                if k.startswith("x-sib-ratelimit") or k in ("retry-after", "date"):
                    cab_caudal[k] = v
    # El metodo es el que curl informa (%{method}), no un rotulo: de el sale el coste.
    code, metodo = ((tmp / f"{n}.code").read_text().split() + ["", ""])[:2] \
        if (tmp / f"{n}.code").exists() else ("", "")
    cuerpo = (tmp / f"{n}.body").read_text(errors="replace")[:1200] if (tmp / f"{n}.body").exists() else ""
    casos[n] = {"ruta": (tmp / f"{n}.ruta").read_text() if (tmp / f"{n}.ruta").exists() else "",
                "metodo": metodo, "http": code,
                "epoch": float(t.read_text().strip()),
                "cabeceras_caudal": cab_caudal,
                "retry_after": cab_todas.get("retry-after"),
                "cuerpo_crudo": redacta(cuerpo)}

rafaga = [(n, c) for n, c in sorted(casos.items()) if n.startswith("f1_")]
rech = [(n, c) for n, c in rafaga if c["http"] == "429"]
tras = casos.get("f3_tras_1200ms")

# --- DISC-12: el cuerpo del 429 ---------------------------------------------------------
if rech:
    cuerpo429 = rech[0][1]["cuerpo_crudo"]
    m = re.search(r'"code"\s*:\s*"([^"]+)"', cuerpo429)
    disc12 = {"alcanzado": True, "peticion_del_rechazo": rech[0][0],
              "cuerpo_literal": cuerpo429.strip(),
              "code_del_cuerpo": m.group(1) if m else None,
              "retry_after": rech[0][1]["retry_after"],
              "veredicto": ("el cuerpo del 429 trae code=%r" % (m.group(1) if m else None))}
else:
    disc12 = {"alcanzado": False, "veredicto":
              "429 NO alcanzado en %d peticiones seguidas: el tope de 2 RPS no mordio" % len(rafaga)}

# --- DISC-13: la unidad, separada por construccion ---------------------------------------
if rech and tras is not None:
    dt = tras["epoch"] - rech[0][1]["epoch"]
    vuelve = tras["http"] != "429"
    reset_en_rechazo = rech[0][1]["cabeceras_caudal"].get("x-sib-ratelimit-reset")
    if vuelve:
        v13 = ("la ventana se repone en %.2f s: el 'reset: %s' leido en el rechazo son "
               "SEGUNDOS, no minutos ni horas" % (dt, reset_en_rechazo))
    else:
        v13 = ("sigue rechazando %.2f s despues: el 'reset: %s' NO describe esta ventana "
               "en segundos" % (dt, reset_en_rechazo))
    disc13 = {"reset_en_el_rechazo": reset_en_rechazo, "segundos_hasta_reintento": round(dt, 3),
              "vuelve_a_pasar": vuelve, "veredicto": v13}
else:
    disc13 = {"veredicto": "sin rechazo: la unidad no se separa por construccion"}

# --- El bucket: por fila o por ruta ------------------------------------------------------
control = {c["ruta"]: c["http"] for n, c in casos.items() if n.startswith("f2_")}
bucket = ("las rutas de control siguen pasando: el 429 es de la FILA de GET /v3/smtp/emails "
          "y no alcanza ni al prefijo ni a 'All other endpoints'"
          if all(v != "429" for v in control.values()) else
          "alguna ruta de control tambien recibe 429: el bucket es compartido")

res = {"resumen": {"api": "brevo", "paquete": "A (cero envios)", "sondeo": "429_rps",
                   "fecha_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                   "envios_reales": sum(1 for c in casos.values()
                                        if c["metodo"] == "POST" and c["http"].startswith("2")),
                   "peticiones_de_envio": sum(1 for c in casos.values() if c["metodo"] == "POST"),
                   "peticiones": len(casos),
                   "invariante_cero_envios":
                       "CUMPLIDA" if all(c["metodo"] == "GET" for c in casos.values()) else "ROTA",
                   "codigos_de_la_rafaga": [c["http"] for _, c in rafaga],
                   "DISC_12": disc12, "DISC_13": disc13,
                   "bucket_del_429": bucket, "control": control,
                   "E_D024": ("rechazo alcanzado: el rate de GET /v3/smtp/emails puede adoptarse "
                              "en VERDE por la ampliacion D-024 de la seccion E"
                              if rech else "sin rechazo: no hay verde que sostener")},
       "casos": casos}
pathlib.Path(salida).write_text(json.dumps(res, ensure_ascii=False, indent=1), encoding="utf-8")
print(json.dumps(res["resumen"], ensure_ascii=False, indent=1))
print("\nJSON: " + salida)
PYEOF
