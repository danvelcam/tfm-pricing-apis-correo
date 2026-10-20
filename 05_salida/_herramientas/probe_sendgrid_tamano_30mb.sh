#!/usr/bin/env bash
# Sondeo empirico SendGrid (escalon 3) - 2026-09-08
# Cierra el ambar del tamano total del correo (workload MBs max: 30, "less than 30MB").
# Sandbox mode: SendGrid valida la peticion y devuelve 200 sin enviar ni gastar cuota.
# Casos: cuerpo de texto de 29, 30 y 31 MiB (1 MiB = 1.048.576 bytes). El 30 exacto separa
# "menor que 30" de "hasta 30".
# USO: bash probe_sendgrid_tamano_30mb.sh   (lee SENDGRID_API_KEY y SENDGRID_LOGIN de ~/.config/tfm/.env)
set -u
set -a; . ~/.config/tfm/.env; set +a
: "${SENDGRID_API_KEY:?}" "${SENDGRID_LOGIN:?}"
OUT="$(dirname "$0")/probe_sendgrid_tamano_$(date -u +%Y-%m-%d_%H%M%S).json"
echo "[" > "$OUT"; PRIMERO=1
for MB in 29 30 31; do
  BODYF="/tmp/sg_body_$$.json"
  python3 - "$MB" "$SENDGRID_LOGIN" "$BODYF" <<'PY'
import json,sys
mb,login,out=int(sys.argv[1]),sys.argv[2],sys.argv[3]
texto='x'*(mb*1048576)
req={"personalizations":[{"to":[{"email":login}]}],"from":{"email":login},
     "subject":"TFM sondeo tamano %d MiB"%mb,"content":[{"type":"text/plain","value":texto}],
     "mail_settings":{"sandbox_mode":{"enable":True}}}
open(out,'w').write(json.dumps(req))
PY
  T0="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  CODE="$(curl -sS -o /tmp/sg_resp_$$ -D /tmp/sg_hdr_$$ -w '%{http_code}' -H "Authorization: Bearer $SENDGRID_API_KEY" -H "Content-Type: application/json" -X POST https://api.sendgrid.com/v3/mail/send --data-binary @"$BODYF")"
  python3 - "$MB" "$T0" "$CODE" /tmp/sg_resp_$$ /tmp/sg_hdr_$$ "$OUT" "$PRIMERO" "$BODYF" <<'PY'
import json,sys,os
mb,t0,code,resp,hdr,out,primero,bodyf=sys.argv[1:9]
try: cuerpo=json.load(open(resp))
except Exception: cuerpo=open(resp,errors='replace').read()[:500]
h={}
for l in open(hdr,errors='replace'):
    if ':' in l:
        k,v=l.split(':',1); h[k.strip().lower()]=v.strip()
rec={"caso":f"sandbox_{mb}MiB","bytes_json":os.path.getsize(bodyf),"instante_utc":t0,"http":int(code),"cuerpo":cuerpo,
     "cabeceras":{k:v for k,v in h.items() if any(s in k for s in("ratelimit","date","x-message-id"))}}
with open(out,'a') as f: f.write(("" if primero=="1" else ",\n")+json.dumps(rec,ensure_ascii=True,indent=2))
msg=json.dumps(cuerpo)[:160] if cuerpo else "(sin cuerpo)"
print(f"{rec['caso']:<16} json={rec['bytes_json']:>10} B  HTTP {code}  {msg}")
PY
  PRIMERO=0; rm -f "$BODYF" /tmp/sg_resp_$$ /tmp/sg_hdr_$$; sleep 3
done
echo "]" >> "$OUT"
sed -i "s/${SENDGRID_LOGIN}/LOGIN_REDACTADO/g" "$OUT"
echo "JSON: $OUT"
