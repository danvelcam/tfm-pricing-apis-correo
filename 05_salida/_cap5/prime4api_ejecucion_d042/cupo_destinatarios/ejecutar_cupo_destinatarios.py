# -*- coding: utf-8 -*-
"""L2 de D-042 sobre F-21: preguntas de consumidor contra PRIME4API con la Datasheet de
MailerSend del catalogo **tal cual** (sin manipularla), sobre el alias `unapproved_account`.

Que hace: para cada caso envia la peticion REST a PRIME4API (el de SPHERE en local,
localhost:8003) con `datasheet_source` = el YAML crudo del catalogo, y archiva peticion y
respuesta en `<caso>_<pregunta>_mailersend.json`, con el mismo formato que
`05_salida/_cap5/prime4api_ejecucion_d037/`.

Uso (desde cualquier sitio; solo stdlib):
    python3 05_salida/_cap5/prime4api_ejecucion_d042/cupo_destinatarios/ejecutar_cupo_destinatarios.py

C1-C8 son las preguntas del catalogo instanciadas sobre la cuenta sin aprobar. C9 es el
control del campo `unreachable`: comprueba que el motor si sabe decir «no alcanzable» con
esta misma Datasheet y este mismo alias, de modo que el `false` de C7 es una afirmacion suya
y no un campo muerto.
"""
import io, os, json, time, datetime, urllib.request, urllib.parse, urllib.error

RAIZ = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", ".."))
BASE = "http://localhost:8003/api/v1/datasheet"
DS_REL = "03_datos/apis/mailersend/datasheet.yaml"
DS = os.path.join(RAIZ, DS_REL)
OUT = os.path.dirname(os.path.abspath(__file__))
EP = "/v1/email"

with io.open(DS, encoding="utf-8") as f:
    YAML = f.read()


def llamada(ruta, params, body_extra):
    """POST ruta?params con body JSON = body_extra + endpoint_path + datasheet_source."""
    body = {"endpoint_path": EP}
    body.update(body_extra)
    p = {"endpoint": "POST " + ruta,
         "params": {k: (v if isinstance(v, str) else str(v)) for k, v in params.items()},
         "body": body, "datasheet": DS_REL}
    envio = {"datasheet_source": YAML}
    envio.update(body)
    url = BASE + ruta + ("?" + urllib.parse.urlencode(p["params"]) if p["params"] else "")
    req = urllib.request.Request(url, data=json.dumps(envio).encode("utf-8"),
                                 headers={"Content-Type": "application/json"}, method="POST")
    t0 = time.time()
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            code, texto = r.status, r.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        code, texto = e.code, e.read().decode("utf-8")
    try:
        resp = json.loads(texto)
    except Exception:
        resp = {"_texto": texto[:2000]}
    p.update({"http": code, "ms": round((time.time() - t0) * 1000), "respuesta": resp})
    return p


SIN_APROBAR = {"alias": "unapproved_account", "plan_names": ["free"]}
CASOS = [
 ("C1", "PI-A07", "Q3", "Capacidad acumulada en un mes por una cuenta MailerSend sin aprobar (alias unapproved_account), k = 1 y k = 2 (el maximo por peticion que declara el alias)",
  [("/capacity-at", {"time": "1month", "capacity_unit": "emails", "capacity_request_factor": "1"}, SIN_APROBAR),
   ("/capacity-at", {"time": "1month", "capacity_unit": "emails", "capacity_request_factor": "2"}, SIN_APROBAR)]),
 ("C2", "PI-A07", "Q3", "Capacidad acumulada en un dia por una cuenta sin aprobar, k = 1 y k = 2",
  [("/capacity-at", {"time": "1day", "capacity_unit": "emails", "capacity_request_factor": "1"}, SIN_APROBAR),
   ("/capacity-at", {"time": "1day", "capacity_unit": "emails", "capacity_request_factor": "2"}, SIN_APROBAR)]),
 ("C3", "PI-A06", "Q1", "Tiempo minimo para que una cuenta sin aprobar envie 100 correos (su cuota mensual entera), k = 1 y k = 2",
  [("/min-time", {"capacity_goal": "100", "capacity_unit": "emails", "capacity_request_factor": "1"}, SIN_APROBAR),
   ("/min-time", {"capacity_goal": "100", "capacity_unit": "emails", "capacity_request_factor": "2"}, SIN_APROBAR)]),
 ("C4", "PI-A06", "Q1", "Tiempo minimo para que una cuenta sin aprobar alcance 3 destinatarios: la unidad es 1 por destinatario y el tercero es exactamente donde la medicion da 422 MS42225",
  [("/min-time", {"capacity_goal": "3", "capacity_unit": "emails", "capacity_request_factor": "1"}, SIN_APROBAR),
   ("/min-time", {"capacity_goal": "3", "capacity_unit": "emails", "capacity_request_factor": "2"}, SIN_APROBAR)]),
 ("C5", "PI-A01", "quotas", "Cuotas que el motor atribuye a la cuenta sin aprobar en unidades de email",
  [("/quotas", {"capacity_unit": "emails"}, SIN_APROBAR)]),
 ("C6", "PI-A02", "rates", "Caudal que el motor atribuye a la cuenta sin aprobar",
  [("/rates", {"capacity_unit": "emails", "capacity_request_factor": "1"}, SIN_APROBAR)]),
 ("C7", "PI-B01", "Q6", "Suscripcion mas barata para 3 destinatarios distintos al mes, sobre los planes calculables con el estado sin aprobar",
  [("/budget/recommendation", {"desired_capacity": "3", "capacity_unit": "emails"},
    {"alias": "unapproved_account", "plan_names": ["free", "hobby", "starter", "professional"]})]),
 ("C8", "PI-D01", "Q5", "Umbral de agotamiento de cuota de la cuenta sin aprobar: que se agota antes, la cuota o el caudal",
  [("/quota-exhaustion-threshold", {"capacity_unit": "emails"}, SIN_APROBAR)]),
 ("C9", "control", "Q6", "Control del campo unreachable: la misma Datasheet y el mismo alias con un objetivo que el caudal no alcanza (100.000 correos) y con presupuesto 0, para comprobar que el motor si sabe decir que no",
  [("/budget/recommendation", {"desired_capacity": "100000", "capacity_unit": "emails"}, SIN_APROBAR),
   ("/budget/recommendation", {"desired_capacity": "3", "capacity_unit": "emails", "max_budget": "0"}, SIN_APROBAR)]),
]


def main():
    for cid, pid, qn, desc, llamadas in CASOS:
        res = [llamada(r, p, b) for r, p, b in llamadas]
        doc = {"caso": cid, "pregunta": pid, "operacion": qn, "descripcion": desc, "api": "mailersend",
               "servicio": BASE, "ejecutado": datetime.datetime.now().isoformat(timespec="seconds"),
               "llamadas": res}
        nombre = cid + ("_control" if pid == "control" else "_" + pid) + "_mailersend.json"
        with io.open(os.path.join(OUT, nombre), "w", encoding="utf-8") as f:
            json.dump(doc, f, ensure_ascii=False, indent=1)
        for r in res:
            print(cid, r["endpoint"], json.dumps(r["params"]), "->", r["http"],
                  json.dumps(r["respuesta"], ensure_ascii=False)[:300])


if __name__ == "__main__":
    main()
