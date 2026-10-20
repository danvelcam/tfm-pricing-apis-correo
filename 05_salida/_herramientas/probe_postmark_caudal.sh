#!/usr/bin/env bash
# Sondeo empirico Postmark (escalon 3), caudal inocuo - 2026-09-08
# DISC-02 / D-020 opcion (b): la respuesta trae ratelimit-limit 5000 y ratelimit-reset 1 sin
# que la documentacion lo publique. Este sondeo mide COMO baja ratelimit-remaining al lanzar
# N peticiones casi simultaneas a /email. No busca el 429 (harian falta 5.000 en un segundo).
# Coste 0: destinatario de dominio no verificado, la cuenta rechaza cada mensaje (412) sin enviar.
# USO: bash probe_postmark_caudal.sh [N=200] [P=25]   (lee POSTMARK_SERVER_TOKEN y POSTMARK_FROM de ~/.config/tfm/.env)
set -u
set -a; . ~/.config/tfm/.env; set +a
: "${POSTMARK_SERVER_TOKEN:?}" "${POSTMARK_FROM:?}"
N="${1:-200}"; P="${2:-25}"
D="/tmp/pm_caudal_$$"; mkdir -p "$D"
BODY="{\"From\":\"$POSTMARK_FROM\",\"To\":\"sondeo-tfm@example.invalid\",\"Subject\":\"TFM caudal\",\"TextBody\":\"c\"}"
export BODY D POSTMARK_SERVER_TOKEN
T0="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
seq 1 "$N" | xargs -P "$P" -I{} sh -c 'date -u +%s.%N > "$D/{}.t0"; curl -sS -o "$D/{}.body" -D "$D/{}.hdr" -w "%{http_code}" -H "Accept: application/json" -H "Content-Type: application/json" -H "X-Postmark-Server-Token: $POSTMARK_SERVER_TOKEN" -X POST https://api.postmarkapp.com/email --data "$BODY" > "$D/{}.code"; date -u +%s.%N > "$D/{}.t1"'
T1="$(date -u +%Y-%m-%dT%H:%M:%S.%NZ)"
OUT="$(dirname "$0")/probe_postmark_caudal_$(date -u +%Y-%m-%d_%H%M%S).json"
python3 - "$D" "$N" "$T0" "$T1" "$OUT" "$P" <<'PY'
import sys,json,os,collections
d,n,t0,t1,out,p=sys.argv[1],int(sys.argv[2]),sys.argv[3],sys.argv[4],sys.argv[5],int(sys.argv[6])
rows=[]
for i in range(1,n+1):
    try:
        code=int(open(f"{d}/{i}.code").read().strip() or 0)
        h={}
        for l in open(f"{d}/{i}.hdr",errors='replace'):
            if ':' in l:
                k,v=l.split(':',1); h[k.strip().lower()]=v.strip()
        try: b=json.load(open(f"{d}/{i}.body"))
        except Exception: b={}
        rows.append({"i":i,"t0":float(open(f"{d}/{i}.t0").read()),"t1":float(open(f"{d}/{i}.t1").read()),"http":code,
            "ErrorCode":b.get("ErrorCode"),"remaining":h.get("ratelimit-remaining"),"remaining_second":h.get("x-ratelimit-remaining-second"),
            "limit":h.get("ratelimit-limit"),"reset":h.get("ratelimit-reset"),"date":h.get("date")})
    except FileNotFoundError: pass
rows.sort(key=lambda r:r["t0"])
codes=collections.Counter((r["http"],r["ErrorCode"]) for r in rows)
rem=[int(r["remaining"]) for r in rows if r["remaining"] and r["remaining"].isdigit()]
dur=max(r["t1"] for r in rows)-min(r["t0"] for r in rows)
by_sec=collections.defaultdict(list)
for r in rows:
    if r["date"]: by_sec[r["date"]].append(int(r["remaining"]) if r["remaining"] and r["remaining"].isdigit() else None)
resumen={"n":len(rows),"paralelismo":p,"inicio_utc":t0,"fin_utc":t1,"duracion_s":round(dur,3),
  "http_por_codigo":{f"{k[0]}/{k[1]}":v for k,v in codes.items()},
  "ratelimit_limit":sorted(set(r["limit"] for r in rows if r["limit"])),"ratelimit_reset":sorted(set(r["reset"] for r in rows if r["reset"])),
  "remaining_min":min(rem) if rem else None,"remaining_max":max(rem) if rem else None,
  "por_segundo_servidor":{k:{"n":len(v),"remaining_min":min(x for x in v if x is not None) if any(x is not None for x in v) else None} for k,v in sorted(by_sec.items())}}
json.dump({"resumen":resumen,"peticiones":rows},open(out,'w'),ensure_ascii=True,indent=1)
print(json.dumps(resumen,ensure_ascii=False,indent=1))
PY
rm -rf "$D"; sed -i "s/${POSTMARK_SERVER_TOKEN}/REDACTADO/g; s/${POSTMARK_FROM}/FROM_REDACTADO/g" "$OUT"; echo "JSON: $OUT"
