#!/usr/bin/env bash
# COSTE EN ENVIOS: 0. Solo /users/ping2 y /users/info, que no envian nada.
set -uo pipefail
ENV=~/.config/tfm/.env
KEY=$(grep -m1 '^MANDRILL_API_KEY=' "$ENV" | cut -d= -f2- | tr -d '"'\''')
[ -n "$KEY" ] || { echo "sin clave"; exit 1; }
OUT=/tmp/claude-1000/-home-mate-TFM/8590811e-b77a-4eb1-bc99-cbce1911d32a/scratchpad
for ep in users/ping2 users/info; do
  echo "═══ POST /api/1.0/$ep ═══"
  code=$(curl -s -o "$OUT/mandrill_$(basename $ep).json" -w '%{http_code}' \
    -X POST "https://mandrillapp.com/api/1.0/$ep" \
    -H 'Content-Type: application/json' \
    -d "{\"key\":\"$KEY\"}")
  echo "HTTP $code"
  sed -e "s/$KEY/«CLAVE-REDACTADA»/g" "$OUT/mandrill_$(basename $ep).json" | head -c 2000
  echo; echo
done
