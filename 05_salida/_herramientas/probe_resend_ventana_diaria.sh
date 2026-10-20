#!/usr/bin/env bash
# Sondeo empirico Resend (escalon 3), ventana del limite diario - 2026-09-08
# Ambar: window_type del limite de 100 emails/dia en Free es "rolling" segun la doc ("wait until
# 24 hours have passed") pero no dice desde cuando. Diseno: enviar 1 correo a una hora T lejos
# de medianoche UTC y leer el contador del panel (Usage) dos veces:
#   T + 23 h 50 min -> si sigue en 1/100, la ventana no es medianoche UTC
#   T + 24 h 10 min -> si esta en 0/100, rolling de 24 h desde el envio confirmado
# Si a T+23h50 ya esta en 0, la ventana es fija (medianoche UTC u otra) -> window_type fixed.
# Coste: 1 correo de la cuota Free (3.000/mes, 100/dia), enviado a la propia cuenta.
# USO: bash probe_resend_ventana_diaria.sh   (lee RESEND_API_KEY y RESEND_LOGIN de ~/.config/tfm/.env)
# Ejecutar hacia las 12:00 UTC (14:00 hora de Sevilla en verano) para que las lecturas caigan lejos de medianoche.
set -u
set -a; . ~/.config/tfm/.env; set +a
: "${RESEND_API_KEY:?}" "${RESEND_LOGIN:?}"
OUT="$(dirname "$0")/probe_resend_ventana_$(date -u +%Y-%m-%d_%H%M%S).json"
T0="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
CODE="$(curl -sS -o /tmp/rs_resp_$$ -D /tmp/rs_hdr_$$ -w '%{http_code}' -H "Authorization: Bearer $RESEND_API_KEY" -H "Content-Type: application/json" -X POST https://api.resend.com/emails \
  --data "{\"from\":\"TFM sondeo <onboarding@resend.dev>\",\"to\":[\"$RESEND_LOGIN\"],\"subject\":\"TFM sondeo ventana diaria $T0\",\"text\":\"Marca temporal del sondeo: $T0\"}")"
python3 - "$T0" "$CODE" /tmp/rs_resp_$$ /tmp/rs_hdr_$$ "$OUT" <<'PY'
import json,sys,datetime
t0,code,resp,hdr,out=sys.argv[1:6]
try: cuerpo=json.load(open(resp))
except Exception: cuerpo=open(resp,errors='replace').read()[:300]
h={}
for l in open(hdr,errors='replace'):
    if ':' in l:
        k,v=l.split(':',1); h[k.strip().lower()]=v.strip()
t=datetime.datetime.strptime(t0,"%Y-%m-%dT%H:%M:%SZ")
lecturas={"L1_debe_seguir_en_1":(t+datetime.timedelta(hours=23,minutes=50)).strftime("%Y-%m-%dT%H:%MZ"),
          "L2_debe_estar_en_0_si_rolling":(t+datetime.timedelta(hours=24,minutes=10)).strftime("%Y-%m-%dT%H:%MZ")}
rec={"caso":"envio_1_correo","instante_utc":t0,"http":int(code),"cuerpo":cuerpo,
     "cabeceras":{k:v for k,v in h.items() if any(s in k for s in("ratelimit","date","retry"))},"lecturas_panel_utc":lecturas}
json.dump([rec],open(out,'w'),ensure_ascii=True,indent=2)
print(f"envio HTTP {code}  {json.dumps(cuerpo)[:120]}")
print("cabeceras rate:", {k:v for k,v in h.items() if 'ratelimit' in k})
print("Lecturas del panel Usage (UTC):", lecturas)
PY
rm -f /tmp/rs_resp_$$ /tmp/rs_hdr_$$; sed -i "s/${RESEND_LOGIN}/LOGIN_REDACTADO/g" "$OUT"; echo "JSON: $OUT"
