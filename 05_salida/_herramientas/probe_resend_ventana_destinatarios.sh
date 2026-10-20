#!/usr/bin/env bash
# Sondeo empirico Resend (escalon 3) - 2026-09-06
# Resuelve dos amarillos de la datasheet:
#   Q-A  ventana del limite diario (24 h desde el primer envio o reinicio a hora fija)
#   Q-B  DISC-04: el tope de 50 destinatarios, es del campo "to" o de la peticion
#
# USO (en la maquina del autor, nunca desde el contenedor):
#   export RESEND_API_KEY='re_...'         # la clave NO se escribe en este fichero ni en el chat
#   export RESEND_TO='tu@correo'          # la direccion de la cuenta (sin dominio verificado solo se puede enviar ahi)
#   bash probe_resend_ventana_destinatarios.sh A      # solo Q-A: 1 envio
#   bash probe_resend_ventana_destinatarios.sh B      # solo Q-B: dos casos, 50 y 51 (coste 0 si los rechaza; hasta 101 si los acepta)
#   bash probe_resend_ventana_destinatarios.sh AB     # los dos
#
# Salida: probe_resend_<fecha>.json junto a este script, con la clave redactada, y una tabla en pantalla.
# Pegar la tabla y el fichero en el chat.

set -u
CASOS="${1:-A}"
: "${RESEND_API_KEY:?Falta RESEND_API_KEY}"
: "${RESEND_TO:?Falta RESEND_TO}"
API="https://api.resend.com/emails"
FROM="onboarding@resend.dev"
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
OUT="$(dirname "$0")/probe_resend_$(date -u +%Y-%m-%d_%H%M%S).json"
echo "[" > "$OUT"
PRIMERO=1

llamada () {  # nombre, json_body
  local nombre="$1" body="$2" hdr="/tmp/probe_hdr.$$" resp code t0
  t0="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  resp="$(curl -sS -o /tmp/probe_body.$$ -D "$hdr" -w '%{http_code}' \
      -H "Authorization: Bearer $RESEND_API_KEY" -H "Content-Type: application/json" \
      -X POST "$API" --data "$body")"
  code="$resp"
  python3 - "$nombre" "$t0" "$code" "$hdr" /tmp/probe_body.$$ "$OUT" "$PRIMERO" <<'PY'
import sys, json
nombre, t0, code, hdr, bodyf, out, primero = sys.argv[1:8]
headers = {}
for line in open(hdr, encoding='utf-8', errors='replace'):
    if ':' in line:
        k, v = line.split(':', 1); headers[k.strip().lower()] = v.strip()
try:
    body = json.load(open(bodyf, encoding='utf-8'))
except Exception:
    body = open(bodyf, encoding='utf-8', errors='replace').read()
rec = {"caso": nombre, "instante_utc": t0, "http": int(code), "cuerpo": body,
       "cabeceras": {k: v for k, v in headers.items() if any(s in k for s in ("ratelimit", "rate-limit", "quota", "retry", "date", "x-resend"))}}
with open(out, "a", encoding="utf-8") as f:
    f.write(("" if primero == "1" else ",\n") + json.dumps(rec, ensure_ascii=True, indent=2))
msg = body.get("message") if isinstance(body, dict) else str(body)[:120]
print(f"{nombre:<28} HTTP {code:<5} {str(msg)[:90]}")
for k, v in rec["cabeceras"].items():
    if "ratelimit" in k or "quota" in k or "retry" in k: print(f"{'':<28} {k}: {v}")
PY
  PRIMERO=0
  rm -f "$hdr" /tmp/probe_body.$$
  sleep 2
}

lista () {  # n copias de RESEND_TO como array JSON
  python3 -c "import json,sys; print(json.dumps([sys.argv[1]]*int(sys.argv[2])))" "$RESEND_TO" "$1"
}

echo "Sondeo Resend  $STAMP  casos=$CASOS"
echo "----------------------------------------------------------------"

if [[ "$CASOS" == *A* ]]; then
  # Q-A: un envio para fijar la hora del primer consumo del dia
  llamada "A_ventana_diaria_1_envio" "{\"from\":\"$FROM\",\"to\":[\"$RESEND_TO\"],\"subject\":\"TFM sondeo ventana diaria $STAMP\",\"text\":\"Sondeo ventana diaria. Instante UTC: $STAMP\"}"
fi

if [[ "$CASOS" == *B* ]]; then
  # Q-B, en pares. Primero los que deberian fallar sin gastar cuota.
  llamada "B1_to_51" "{\"from\":\"$FROM\",\"to\":$(lista 51),\"subject\":\"TFM sondeo B1\",\"text\":\"B1\"}"
  llamada "B2_to_26_cc_25_total_51" "{\"from\":\"$FROM\",\"to\":$(lista 26),\"cc\":$(lista 25),\"subject\":\"TFM sondeo B2\",\"text\":\"B2\"}"
  llamada "B3_to_25_cc_25_total_50" "{\"from\":\"$FROM\",\"to\":$(lista 25),\"cc\":$(lista 25),\"subject\":\"TFM sondeo B3\",\"text\":\"B3\"}"
fi

echo "]" >> "$OUT"
sed -i "s/${RESEND_API_KEY}/REDACTADO/g" "$OUT"
echo "----------------------------------------------------------------"
echo "JSON guardado en: $OUT (clave redactada)"
echo "Q-A: anota la hora. Manana, 30 min ANTES de esa hora mira Settings > Usage > Daily limit:"
echo "     si sigue en 1/100 la ventana es de 24 h desde el envio; si esta en 0/100 se reinicia a hora fija."
