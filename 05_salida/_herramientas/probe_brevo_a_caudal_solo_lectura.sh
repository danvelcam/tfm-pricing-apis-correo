#!/usr/bin/env bash
# Sondeo empirico Brevo (escalon 3) - SOLO LECTURA - 2026-09-17
#
# PREGUNTA QUE RESUELVE
#   DISC-17: GET /v3/smtp/emails lleva los 7.200 RPH de su fila propia de [F6], o los
#   300 RPH del prefijo /v3/smtp/{...} cuya nota al pie NO la exime? El par decisivo es
#   emails (fila propia) contra templates (solo prefijo): si las dos devuelven el mismo
#   x-sib-ratelimit-limit, manda el prefijo; si difieren, manda la fila propia.
#   De paso: GET /v3/senders (operacion 3 del test C2, Q7) y GET /v3/account, que la
#   propia documentacion senala para saber los limites vigentes -- el disparador del tramo
#   de Q1, que la revision daba por no consultable.
#
# POR QUE NO SE USA probe_brevo_a_caudal_cabeceras.sh
#   Ese script lleva 2 POST al endpoint de envio con la guarda 'sender_sumidero', y el
#   preflight del 2026-09-17 midio que esa guarda NO rechaza: p2_sender_sumidero devolvio
#   201 e 'invariante_cero_envios' quedo en ROTA, con 'guarda_recomendada' en null. Con la
#   guarda desmentida, sus dos POST pueden ser aceptados, y una peticion aceptada gasta
#   credito y genera un rebote. Este sondeo no nombra el endpoint de envio en ninguna
#   linea: no puede enviar aunque se quiera.
#
# COSTE EN ENVIOS: 0. No hay POST. Presupuesto: 4 peticiones GET.
#   Buckets que se consumen: 2 del prefijo /v3/smtp/{...} (300 RPH) y 1 de
#   "All other endpoints" (100 RPH).
#
# DESTINATARIOS (D-046): ninguno. No se construye ningun cuerpo de correo.
#
# USO
#   bash probe_brevo_a_caudal_solo_lectura.sh     (lee BREVO_API_KEY de ~/.config/tfm/.env)
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

readonly BASE="https://api.brevo.com/v3"
readonly SALIDA="${1:-/tmp/probe_brevo_solo_lectura.json}"
readonly TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT

# caso|metodo|ruta  --  ni una linea con /smtp/email (envio). Solo lectura.
readonly CASOS=(
  "m01_get_smtp_emails|/smtp/emails?limit=1"
  "m02_get_smtp_templates|/smtp/templates?limit=1"
  "m06_get_senders|/senders"
  "m05_get_account|/account"
)

for C in "${CASOS[@]}"; do
  NOMBRE="${C%%|*}"; RUTA="${C#*|}"
  # El endpoint de envio es /smtp/email EXACTO. Ojo: /smtp/emails lo contiene como
  # subcadena y es el caso que este sondeo SI tiene que medir, asi que no vale un *...*.
  if [[ $RUTA == "/smtp/email" || $RUTA == "/smtp/email?"* ]]; then
    echo "ABORTA: $NOMBRE apunta al endpoint de envio. Este sondeo es de lectura." >&2
    exit 3
  fi
  curl -sS -o "$TMP/$NOMBRE.body" -D "$TMP/$NOMBRE.head" -w '%{http_code} %{method}' \
       -H "api-key: $BREVO_API_KEY" -H 'accept: application/json' \
       "$BASE$RUTA" > "$TMP/$NOMBRE.code" 2> "$TMP/$NOMBRE.err" || true
  sleep 2
done

python3 -I - "$TMP" "$SALIDA" "$BREVO_API_KEY" <<'PYEOF'
import json, re, sys, pathlib, datetime
tmp, salida, clave = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
RE_CORREO = re.compile(r"[A-Za-z0-9._%%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
def redacta(s):
    if clave:
        s = s.replace(clave, "<BREVO_API_KEY>")
    # Cero PII en evidencias: los cuerpos de /senders y /account traen direcciones reales.
    s = RE_CORREO.sub("<CORREO_REDACTADO>", s)
    # /v3/account devuelve nombre y apellido del titular: fuera tambien.
    # La direccion postal y los identificadores de cuenta tampoco hacen falta para medir.
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
    # El metodo es el que curl informa (%{method}), no un rotulo: de el sale el coste.
    code, metodo = ((tmp / f"{n}.code").read_text().split() + ["", ""])[:2] \
        if (tmp / f"{n}.code").exists() else ("", "")
    cuerpo = (tmp / f"{n}.body").read_text(errors="replace")[:1400] if (tmp / f"{n}.body").exists() else ""
    casos[n] = {"metodo": metodo, "http": code, "cabeceras_caudal": cab,
                "cuerpo_recortado": redacta(cuerpo)}
lim = {n: c["cabeceras_caudal"].get("x-sib-ratelimit-limit") for n, c in casos.items()}
e, t = lim.get("m01_get_smtp_emails"), lim.get("m02_get_smtp_templates")
if e and t:
    veredicto = ("DISC-17: emails y templates comparten tope (%s) -> manda el PREFIJO de 300 RPH; "
                 "la fila propia de 7.200 no se aplica" % e) if e == t else \
                ("DISC-17: emails %s y templates %s difieren -> manda la FILA PROPIA de emails" % (e, t))
else:
    veredicto = "DISC-17 sin decidir: falta la cabecera en alguno del par (emails=%r, templates=%r)" % (e, t)
res = {"resumen": {"api": "brevo", "sondeo": "caudal_solo_lectura",
                   "fecha_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                   "envios_reales": sum(1 for c in casos.values()
                                        if c["metodo"] == "POST" and c["http"].startswith("2")),
                   "peticiones": len(casos),
                   "limit_por_caso": lim, "veredicto_disc17": veredicto,
                   "senders_existe": casos.get("m06_get_senders", {}).get("http")},
       "casos": casos}
pathlib.Path(salida).write_text(json.dumps(res, ensure_ascii=False, indent=1), encoding="utf-8")
print(json.dumps(res["resumen"], ensure_ascii=False, indent=1))
PYEOF
