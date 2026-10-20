#!/usr/bin/env bash
# Sondeo empirico Brevo (escalon 3) - PAQUETE A, CERO ENVIOS - 2026-09-18
#
# POR QUE EXISTE, Y QUE CORRIGE
#   El sondeo del 429 del mismo dia dejo tres afirmaciones sin artefacto, y un revisor
#   esceptico las tumbo una a una:
#
#   (1) "el 429 llega sin cuerpo: content-length 0 y sin Content-Type". El instrumento
#       anterior solo archivaba las cabeceras x-sib-ratelimit-*, retry-after y date, asi
#       que esas dos no estaban en el JSON. Aqui se archivan TODAS.
#   (2) "la ventana es de un segundo". No se midio: la rafaga cabia en 0,399 s y la
#       reposicion se vio 1,658 s despues, asi que la ventana solo quedaba acotada entre
#       0,4 y 2,06 s. Aqui se sondea la reposicion cada 250 ms para fijarla.
#   (3) "la cabecera solo existe donde hay ventana por segundo, asi que el factor 3.600
#       no tiene observable". FALSO, y lo desmiente el propio JSON de aquel sondeo:
#       GET /v3/account esta declarado SOLO por hora --"All other endpoints | 100 RPH | -"
#       [F6]-- y devuelve x-sib-ratelimit-reset: 233. Ese es justo el observable que
#       decide DISC-13, y aqui se mide bien: dos lecturas separadas por una pausa CONOCIDA
#       sobre ese endpoint horario.
#         - Si reset baja ~1 por segundo transcurrido, la unidad es el SEGUNDO y el lado B
#           de DISC-13 gana en un endpoint horario, que es donde el factor 3.600 mordia.
#         - Si no se mueve, o baja por otra escala, la unidad NO es el segundo y el cierre
#           anterior se cae.
#
# COSTE EN ENVIOS: 0. Ni un POST. Presupuesto: hasta 22 peticiones GET.
#   Buckets: la fila propia de GET /v3/smtp/emails (2 RPS) a proposito, y unas pocas
#   lecturas de "All other endpoints", medido en 5.000 por [E2].
#   Duracion: unos 40 s.
#
# DESTINATARIOS (D-046): ninguno. No se construye ningun cuerpo de correo.
set -u
unset CDPATH

ruta_es_envio () { [[ $1 == "/smtp/email" || $1 == "/smtp/email?"* ]]; }
if [[ ${1:-} == "--solo-funciones" ]]; then return 0 2>/dev/null || exit 0; fi

readonly AQUI="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
. "$AQUI/lib_env_brevo.sh" || exit 3
brevo_exige_funciones brevo_carga_env brevo_limpia_funciones || exit 3
brevo_limpia_funciones
brevo_carga_env || exit 3
[[ -n ${BREVO_API_KEY:-} ]] || { echo "ABORTA: BREVO_API_KEY vacia." >&2; exit 3; }

readonly BASE="https://api.brevo.com/v3"
readonly SALIDA="${1:-/tmp/probe_brevo_ventana_reset.json}"
readonly TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT

pide () {  # $1 nombre  $2 ruta
  local N="$1" R="$2"
  ruta_es_envio "$R" && { echo "ABORTA: $N es el endpoint de envio." >&2; exit 3; }
  date -u +%s.%N > "$TMP/$N.t"
  curl -sS -o "$TMP/$N.body" -D "$TMP/$N.head" -w '%{http_code} %{size_download} %{method}' \
       -H "api-key: $BREVO_API_KEY" -H 'accept: application/json' \
       "$BASE$R" > "$TMP/$N.code" 2> "$TMP/$N.err" || true
  printf '%s' "$R" > "$TMP/$N.ruta"
}

# --- Fase 1: agotar la ventana por segundo y capturar el 429 con TODAS sus cabeceras -----
for I in 1 2 3 4; do
  pide "$(printf 'f1_rafaga_%02d' "$I")" "/smtp/emails?limit=1"
  grep -qi '^HTTP/[0-9.]* 429' "$TMP/$(printf 'f1_rafaga_%02d' "$I").head" && break
done

# --- Fase 2: la reposicion, sondeada cada 250 ms, para FIJAR la ventana ------------------
for I in $(seq 1 10); do
  sleep 0.25
  pide "$(printf 'f2_reposicion_%02d' "$I")" "/smtp/emails?limit=1"
  grep -qi '^HTTP/[0-9.]* 429' "$TMP/$(printf 'f2_reposicion_%02d' "$I").head" || break
done

# --- Fase 3: el endpoint declarado SOLO por hora, dos lecturas con pausa conocida --------
pide "f3_account_a" "/account"
sleep 12
pide "f3_account_b" "/account"

python3 -I - "$TMP" "$SALIDA" "$BREVO_API_KEY" <<'PYEOF'
import json, re, sys, pathlib, datetime
tmp, salida, clave = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
RE_CORREO = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
def redacta(s):
    if clave: s = s.replace(clave, "<BREVO_API_KEY>")
    s = RE_CORREO.sub("<CORREO_REDACTADO>", s)
    s = re.sub(r'"address"\s*:\s*\{[^}]*\}', '"address":"<REDACTADO>"', s)
    for c in ("firstName","lastName","userName","companyName","organization_id","user_id"):
        s = re.sub('"'+c+r'"\s*:\s*"[^"]*"', '"'+c+'":"<REDACTADO>"', s)
        s = re.sub('"'+c+r'"\s*:\s*[0-9]+', '"'+c+'":0', s)
    return s

casos = {}
for t in sorted(tmp.glob("*.t")):
    n = t.stem
    cab, estado = {}, None
    h = tmp / f"{n}.head"
    if h.exists():
        for linea in h.read_text(errors="replace").splitlines():
            if linea.startswith("HTTP/"): estado = linea.strip(); continue
            if ":" in linea:
                k, _, v = linea.partition(":")
                cab[k.lower().strip()] = v.strip()
    # El metodo es el que curl informa (%{method}), no un rotulo: de el sale el coste.
    code_size = ((tmp / f"{n}.code").read_text().split() if (tmp / f"{n}.code").exists() else []) + ["", "", ""]
    cuerpo = (tmp / f"{n}.body").read_text(errors="replace")[:800] if (tmp / f"{n}.body").exists() else ""
    casos[n] = {"ruta": (tmp / f"{n}.ruta").read_text() if (tmp / f"{n}.ruta").exists() else "",
                "metodo": code_size[2], "http": code_size[0], "bytes_descargados": code_size[1],
                "linea_de_estado": estado,
                "cabeceras_todas": cab, "cuerpo_crudo": redacta(cuerpo),
                "epoch": float(t.read_text().strip())}

# --- (1) el cuerpo del 429, con las cabeceras que lo describen --------------------------
r429 = next(((n, c) for n, c in sorted(casos.items()) if c["http"] == "429"), None)
c429 = {"alcanzado": bool(r429)}
if r429:
    n, c = r429
    c429.update({"peticion": n, "bytes_descargados": c["bytes_descargados"],
                 "content_length": c["cabeceras_todas"].get("content-length"),
                 "content_type": c["cabeceras_todas"].get("content-type"),
                 "retry_after": c["cabeceras_todas"].get("retry-after"),
                 "cuerpo_literal": c["cuerpo_crudo"],
                 "cabeceras_de_caudal": {k: v for k, v in c["cabeceras_todas"].items()
                                         if k.startswith("x-sib-ratelimit")}})

# --- (2) la ventana, fijada por la reposicion -------------------------------------------
rep = [(n, c) for n, c in sorted(casos.items()) if n.startswith("f2_")]
primera_ok = next(((n, c) for n, c in rep if c["http"] != "429"), None)
ventana = {"muestras": [{"peticion": n, "http": c["http"],
                         "s_desde_el_rechazo": round(c["epoch"] - r429[1]["epoch"], 3)}
                        for n, c in rep]} if r429 else {}
if r429 and primera_ok:
    ultima_429 = [(n, c) for n, c in rep if c["http"] == "429"]
    desde_inicio = round(primera_ok[1]["epoch"] - casos["f1_rafaga_01"]["epoch"], 3)
    ventana.update({
        "reposicion_s_desde_el_rechazo": round(primera_ok[1]["epoch"] - r429[1]["epoch"], 3),
        "reposicion_s_desde_la_primera_peticion": desde_inicio,
        "ultimo_429_s_desde_el_rechazo": round(ultima_429[-1][1]["epoch"] - r429[1]["epoch"], 3) if ultima_429 else None,
        "veredicto": ("la ventana se repone %.3f s despues de la primera peticion de la serie; "
                      "con el tope en 2 y el rechazo en la tercera, eso fija la ventana declarada "
                      "de 1 s si el valor cae cerca de 1" % desde_inicio)})

# --- (3) DISC-13 en un endpoint declarado SOLO por hora ---------------------------------
a, b = casos.get("f3_account_a"), casos.get("f3_account_b")
disc13 = {}
if a and b:
    ra = a["cabeceras_todas"].get("x-sib-ratelimit-reset")
    rb = b["cabeceras_todas"].get("x-sib-ratelimit-reset")
    dt = round(b["epoch"] - a["epoch"], 3)
    try:
        d = float(ra) - float(rb)
    except (TypeError, ValueError):
        d = None
    if d is None:
        v = "no medible: una de las dos lecturas no trae la cabecera"
    elif abs(d - dt) <= max(2.0, 0.25 * dt):
        v = ("reset baja %.1f en %.3f s reales: cuenta SEGUNDOS, y lo hace en un endpoint "
             "declarado solo por hora, que es donde el factor 3.600 de DISC-13 mordia" % (d, dt))
    elif d == 0:
        v = "reset no se mueve en %.3f s: no es una cuenta atras en segundos" % dt
    else:
        v = "reset baja %.1f en %.3f s: no es uno por segundo" % (d, dt)
    disc13 = {"endpoint": "/v3/account", "declarado": "All other endpoints | 100 RPH | - [F6]",
              "limit": a["cabeceras_todas"].get("x-sib-ratelimit-limit"),
              "reset_a": ra, "reset_b": rb, "segundos_entre_lecturas": dt,
              "caida_de_reset": d, "veredicto": v}

res = {"resumen": {"api": "brevo", "paquete": "A (cero envios)", "sondeo": "ventana_y_reset",
                   "fecha_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                   "envios_reales": sum(1 for c in casos.values()
                                        if c["metodo"] == "POST" and c["http"].startswith("2")),
                   "peticiones": len(casos),
                   "invariante_cero_envios":
                       "CUMPLIDA" if all(c["metodo"] == "GET" for c in casos.values()) else "ROTA",
                   "cuerpo_del_429": c429, "ventana_por_segundo": ventana,
                   "DISC_13_en_endpoint_horario": disc13},
       "casos": casos}
pathlib.Path(salida).write_text(json.dumps(res, ensure_ascii=False, indent=1), encoding="utf-8")
print(json.dumps(res["resumen"], ensure_ascii=False, indent=1))
print("\nJSON: " + salida)
PYEOF
