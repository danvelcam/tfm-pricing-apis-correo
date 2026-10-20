# -*- coding: utf-8 -*-
"""
Ejecuta las preguntas de clase P del catálogo de Pricing Intelligence contra el servicio
REST de PRIME4API (TFM de Gavira Sánchez), sobre las Datasheets reales del catálogo.

Qué hace (modo por defecto, sin subcomando)
-------------------------------------------
1. Arranca PRIME4API como servicio (uvicorn sobre el clon de ~/.cache/atf/prime4api, el
   mismo que usa verificar_prime4api.py) en 127.0.0.1:8000.
2. Para cada instancia (pregunta PI × API) envía la petición REST que la resuelve, con la
   Datasheet como `datasheet_source` (YAML crudo), y guarda petición + respuesta en
   `05_salida/_cap5/prime4api_ejecucion/<PI-id>_<api>.json`.
3. Escribe `RESULTADOS.md` con la tabla pregunta × API (endpoint, parámetros, respuesta
   resumida) para contrastarla con el cálculo a mano de analisis.md y del cap. 5.
4. Para el servicio.

Uso (desde la raíz del proyecto; pip: fastapi uvicorn pydantic pyyaml numpy plotly requests):
    python3 05_salida/_herramientas/ejecutar_prime4api_PI.py 05_salida/_cap5/prime4api_ejecucion/

Modos para un PRIME4API que corre en otra máquina (p. ej. el de SPHERE en localhost:8003
del portátil, al que solo llega el navegador): las mismas peticiones, sin arrancar nada.
    # 1) plan: escribe la lista ordenada de llamadas de una API (no llama a ningún servicio)
    python3 05_salida/_herramientas/ejecutar_prime4api_PI.py plan sendgrid plan_sendgrid.json \\
            [--base http://localhost:8003/api/v1/datasheet]
    # 2) importar: lee las respuestas (mismo orden que el plan) y escribe los <PI-id>_<api>.json
    #    con el formato del modo por defecto, y regenera RESULTADOS.md a partir de la carpeta
    python3 05_salida/_herramientas/ejecutar_prime4api_PI.py importar sendgrid respuestas.json \\
            05_salida/_cap5/prime4api_ejecucion/ [--origen "PRIME4API de SPHERE en local (localhost:8003), vía navegador"]
El fichero de respuestas es una lista `[{"id": "PI-A06", "n": 0, "http": 200, "ms": 31, "respuesta": {...}}, …]`
(respuesta = JSON del motor o `{"_texto": "..."}` si no era JSON); también se admite `{"respuestas": [...]}`.

Alias de estado (D-025)
-----------------------
Desde que MailerSend declara aliases de estado de cuenta (`healthy_reputation`,
`under_review_reputation`, `unapproved_account`), el motor devuelve una fila por alias
donde antes devolvía una sola. Estas preguntas consumen **`healthy_reputation`**, que es
el valor por defecto de `ALIAS`: el estado nominal de la cuenta, el que sostiene las
cifras del capítulo 5. Se cambia en los tres modos con `--alias <nombre>`, y `--alias ""`
quita el filtro y deja que el motor devuelva las filas de todos los aliases.
El alias solo viaja en el cuerpo cuando el endpoint de esa API lo declara: las Datasheets
sin aliases (Postmark, Resend, SendGrid) van sin filtro, porque el motor aborta con
`ValueError: Endpoint '…' has no aliases, but an alias was provided`.

RESULTADOS.md se regenera siempre leyendo los JSON que haya en la carpeta (y el origen de cada
API en `ORIGENES.json`), de modo que se puede añadir una API sin reejecutar las demás.

No calcula nada por su cuenta: las respuestas son las del motor. Lo que no responde el
motor (Postmark sin rate, preguntas H) se registra tal cual, con el error o la ausencia.
"""
import sys, io, os, json, time, subprocess, datetime
from urllib.parse import urlencode
import requests
import yaml as _yaml

BASE = "http://127.0.0.1:8000/api/v1/datasheet"
BASE_REMOTA = "http://localhost:8003/api/v1/datasheet"   # PRIME4API de SPHERE en el portátil
CACHE = os.path.expanduser("~/.cache/atf/prime4api")
APIS = {
    "postmark": ("03_datos/apis/postmark/datasheet.yaml", "/email"),
    "resend":   ("03_datos/apis/resend/datasheet.yaml",   "/emails"),
    "sendgrid": ("03_datos/apis/sendgrid/datasheet.yaml", "/v3/mail/send"),
    "mailersend": ("03_datos/apis/mailersend/datasheet.yaml", "/v1/email"),
    "brevo":    ("03_datos/apis/brevo/datasheet.yaml",    "/v3/smtp/email"),
    "ses":      ("03_datos/apis/ses/datasheet.yaml",      "/v2/email/outbound-emails"),
    "mailgun":  ("03_datos/apis/mailgun/datasheet.yaml",  "/v3/{domain_name}/messages"),
    "mailchimp": ("03_datos/apis/mailchimp/datasheet.yaml", "/messages/send"),
}
# plan «primer plan de pago» y plan gratuito por API, tal como los usa analisis.md
# El valor puede ser un nombre de plan o una lista de nombres. Va en lista cuando la
# definición del eje admite más de una instancia y no hay campo que desempate: se publican
# todas, como D-037 publica los dos regímenes en vez de inventarse un punto intermedio (E16).
PAGO  = {"postmark": "basic", "resend": "pro", "sendgrid": "essentials",
         "mailersend": "hobby", "brevo": "starter", "mailgun": "basic",
         # SES: `pro` es el plan más barato con precio numérico > 0, pero NO liga volumen;
         # ningún plan de SES lo hace. La respuesta la da el alias `sandbox` y así se rotula.
         "ses": "pro",
         # Mailchimp tiene un plan y nada más. Gratuito y primer plan de pago son el mismo
         # nombre, y lo que los separa es el alias `demo` (B12, D7).
         "mailchimp": "transactional_email"}
FREE  = {"postmark": "free",  "resend": "free", "sendgrid": "free_trial",
         "mailersend": "free", "brevo": "free", "mailgun": "free",
         # SES empata dos planes a 0,00 y ninguno incluye volumen: `a_la_carte`, que el
         # proveedor describe como la ausencia de plan, y `essentials`. Ningún campo
         # desempata, así que se ejecutan los dos.
         "ses": ["a_la_carte", "essentials"],
         "mailchimp": "transactional_email"}
KMAX  = {"postmark": 50, "resend": 50, "sendgrid": 1000,
         "mailersend": 70, "brevo": 2000, "mailgun": 1000, "ses": 50,
         # Mailchimp no publica tope de destinatarios: el `max` del workload está vacío y en
         # 🔴. El 5.000 es lo medido, una sola llamada aceptada, y se usa como tal.
         "mailchimp": 5000}
# Planes que el motor puede ingerir en las operaciones de presupuesto y demanda: fuera los
# «custom» (DV-03: precio no numérico) y los planes con rate vacío (🔴, Resend Enterprise).
CALCULABLES = {"postmark": ["free", "basic", "pro", "platform"],
               "resend": ["free", "pro", "scale"],
               "sendgrid": ["free_trial", "essentials", "pro"],
               "mailersend": ["free", "hobby", "starter", "professional"],
               "brevo": ["free", "starter", "standard", "professional"],
               "mailgun": ["free", "basic", "foundation", "scale"],
               "ses": ["a_la_carte", "essentials", "pro", "enterprise"],
               "mailchimp": ["transactional_email"]}
# Cuota mensual del primer plan de pago (PI-D01): objetivo de capacidad para el t_min
CUOTA_PAGO = {"postmark": 10000, "resend": 50000, "sendgrid": 50000,
              "mailersend": 5000, "brevo": 5000, "mailgun": 10000,
              # SES no publica cuota de ningún plan. La única serializada son los 200 al día
              # del entorno de pruebas, y es la que el motor puede agotar.
              "ses": 200,
              "mailchimp": 25000}

# Alias de estado de cuenta que consumen las preguntas P cuando la Datasheet los declara
# (D-025). Por defecto `healthy_reputation`: el estado nominal, el que reproduce las cifras
# del capítulo 5. Se cambia con --alias en los tres modos; --alias "" quita el filtro.
ALIAS = "healthy_reputation"
# El vocabulario de aliases es del proveedor, no del catálogo (D7), así que el valor por
# defecto solo vale para MailerSend. Aquí van las APIs cuyo vocabulario es otro; la cadena
# vacía significa «sin filtro», y el motor devuelve la fila o filas que el endpoint declare.
# Un `--alias` explícito en la línea de órdenes manda sobre esta tabla.
ALIAS_POR_API = {
    # Brevo declara `general`, `advanced` y `extended`, pero solo en professional y
    # enterprise. Pedir un alias con los cinco planes aborta el motor: «Endpoint
    # '/v3/smtp/email' has no aliases, but an alias was provided.»
    "brevo": "",
    # En SES el endpoint de envío no tiene rate ni quota base: la única rama es `sandbox`,
    # porque los límites de producción no los publica el proveedor. Filtrar o no filtrar
    # devuelve la misma fila, y el motor la rotula con el alias.
    "ses": "",
    # Igual en Mailchimp con `demo`, que además concatena la cuota del plan con la de la
    # franquicia en la misma fila.
    "mailchimp": "",
}
# Campos propios de un endpoint en el motor (`_KNOWN_ENDPOINT_KEYS` de
# `app/services/datasheet_evaluator_service.py`): todo sub-dict que no sea uno de estos es
# un alias. Se replica aquí para saber a qué API se le puede pedir el filtro.
CLAVES_ENDPOINT = {"rate", "quota", "workload", "cost_per_request"}

# En «seco» (modos plan e importar) `llamada` no llama al servicio: devuelve solo la petición.
SECO = False

_ALIAS_CACHE = {}


def yaml_de(api):
    with io.open(APIS[api][0], encoding="utf-8") as f:
        return f.read()


def alias_de(api):
    """Alias que se envía en el cuerpo para esta API: `ALIAS` si el endpoint lo declara, None si no.

    El motor aborta (`ValueError`) si se filtra por alias un endpoint que no tiene ninguno,
    así que las Datasheets sin aliases van sin filtro y devuelven la fila de siempre. Si la
    Datasheet declara aliases pero no el pedido, se para aquí con la lista de los que hay.
    """
    alias = ALIAS_POR_API.get(api, ALIAS)
    if not alias:
        return None
    if api not in _ALIAS_CACHE:
        y = _yaml.safe_load(yaml_de(api)) or {}
        declarados = set()
        for plan in (y.get("plans") or {}).values():
            ep = ((plan or {}).get("endpoints") or {}).get(APIS[api][1]) or {}
            declarados |= {k for k, v in ep.items()
                           if isinstance(v, dict) and k not in CLAVES_ENDPOINT}
        if declarados and alias not in declarados:
            sys.exit(f"El endpoint {APIS[api][1]} de «{api}» no declara el alias «{alias}»; "
                     f"declara: {sorted(declarados)}")
        _ALIAS_CACHE[api] = alias if declarados else None
    return _ALIAS_CACHE[api]


def planes(valor):
    """`FREE`/`PAGO` admiten un nombre o una lista de nombres; el cuerpo siempre lleva lista."""
    return list(valor) if isinstance(valor, (list, tuple)) else [valor]


def peticion(api, ruta, params=None, body_extra=None):
    """Descriptor de la petición tal como queda en el JSON de salida (sin datasheet_source)."""
    body = {"endpoint_path": APIS[api][1]}
    if alias := alias_de(api):
        body["alias"] = alias
    if body_extra:
        body.update(body_extra)
    return {"endpoint": "POST " + ruta, "params": params or {}, "body": body, "datasheet": APIS[api][0]}


def llamada(api, ruta, params=None, body_extra=None):
    p = peticion(api, ruta, params, body_extra)
    if SECO:
        return p
    body = {"datasheet_source": yaml_de(api)}
    body.update(p["body"])
    t0 = time.time()
    r = requests.post(BASE + ruta, params=params or {}, json=body, timeout=120)
    try:
        resp = r.json()
    except Exception:
        resp = {"_texto": r.text[:2000]}
    p.update({"http": r.status_code, "ms": round((time.time() - t0) * 1000), "respuesta": resp})
    return p


# Cada instancia: (id PI, operación Qn, descripción del ejemplo, función que devuelve las llamadas por API)
def instancias():
    I = []
    # PI-A06 · Q1 · tiempo mínimo para 100.000 correos (plan de pago), k = 1 y k máx,
    # en los dos regímenes (D-037): sin `max_budget` el motor trata la cuota con sobrecoste
    # como dura y cuenta renovaciones; con un presupuesto que no limita la expande y el
    # tiempo lo fija el caudal. Las dos cifras son del proveedor. El 1e9 es el mismo
    # «presupuesto muy alto» que ya usa PI-D02: la respuesta satura en el coste del
    # objetivo, así que cualquier valor por encima devuelve lo mismo.
    I.append(("PI-A06", "Q1", "Tiempo mínimo para enviar 100.000 correos con el primer plan de pago, k = 1 y k máximo, con la cuota dura y con presupuesto que no limita",
              lambda api: [
                  llamada(api, "/min-time", {"capacity_goal": 100000, "capacity_unit": "emails",
                                             "capacity_request_factor": "1"}, {"plan_names": planes(PAGO[api])}),
                  llamada(api, "/min-time", {"capacity_goal": 100000, "capacity_unit": "emails",
                                             "capacity_request_factor": str(KMAX[api])}, {"plan_names": planes(PAGO[api])}),
                  llamada(api, "/min-time", {"capacity_goal": 100000, "capacity_unit": "emails",
                                             "capacity_request_factor": "1", "max_budget": 1e9},
                          {"plan_names": planes(PAGO[api])}),
                  llamada(api, "/min-time", {"capacity_goal": 100000, "capacity_unit": "emails",
                                             "capacity_request_factor": str(KMAX[api]), "max_budget": 1e9},
                          {"plan_names": planes(PAGO[api])}),
              ]))
    # PI-A07 · Q3 · capacidad acumulada en 7 días con el plan gratuito
    I.append(("PI-A07", "Q3", "Capacidad acumulada en 7 días con el plan gratuito, k = 1",
              lambda api: [llamada(api, "/capacity-at", {"time": "7day", "capacity_unit": "emails",
                                                          "capacity_request_factor": "1"}, {"plan_names": planes(FREE[api])})]))
    # PI-B01 · Q6 · suscripción más barata para 40.000 correos al mes
    I.append(("PI-B01", "Q6", "Suscripción más barata para 40.000 correos al mes: primero todos los planes (falla con precio custom o rate vacío), después solo los calculables",
              lambda api: [llamada(api, "/budget/recommendation", {"desired_capacity": 40000, "capacity_unit": "emails"}),
                           llamada(api, "/budget/recommendation", {"desired_capacity": 40000, "capacity_unit": "emails"},
                                   {"plan_names": CALCULABLES[api]})]))
    # PI-B02 · Q7 · máximo de correos con 50 USD al mes (cuotas expandidas por presupuesto)
    I.append(("PI-B02", "Q7", "Máximo de correos al mes con 50 USD: cuota expandida por presupuesto (/quotas con max_budget) y capacidad al mes con esa cuota, planes calculables",
              lambda api: [llamada(api, "/quotas", {"capacity_unit": "emails", "max_budget": 50}, {"plan_names": CALCULABLES[api]}),
                           llamada(api, "/capacity-at", {"time": "1month", "capacity_unit": "emails",
                                                          "capacity_request_factor": "1", "max_budget": 50},
                                   {"plan_names": CALCULABLES[api]})]))
    # PI-B03 · Q10 · 12.000 correos: sobrecoste frente a plan siguiente
    I.append(("PI-B03", "Q10", "12.000 correos al mes: coste total por plan (sobrecoste frente a subir de plan), planes calculables",
              lambda api: [llamada(api, "/budget/recommendation", {"desired_capacity": 12000, "capacity_unit": "emails"},
                                   {"plan_names": CALCULABLES[api]})]))
    # PI-B05 · Q5 · sostener un pico de 20.000 correos en una hora
    I.append(("PI-B05", "Q5", "Sostener un pico de 20.000 correos en una hora (demanda con duración), planes calculables, k = 1",
              lambda api: [llamada(api, "/demand-evaluation", {"time_interval": "1hour", "capacity_unit": "emails",
                                                                "capacity_request_factor": "1"},
                                   {"plan_names": CALCULABLES[api],
                                    "demands": [{"rate": {"value": 20000 / 3600.0, "unit": "emails", "period": "1s"},
                                                 "duration": "1h", "label": "pico 20.000 en 1 h"}]})]))
    # PI-D01 · Q5 · qué se agota antes: la cuota mensual entera como demanda uniforme en un mes,
    #   más el tiempo mínimo en agotarla al rate máximo (si t_min < ventana, la cuota manda)
    I.append(("PI-D01", "Q5", "Qué se agota antes en el primer plan de pago: t_min para agotar la cuota al rate máximo (k = 1) y veredicto para consumir la cuota entera en un mes",
              lambda api: [
                  llamada(api, "/quotas", {"capacity_unit": "emails"}, {"plan_names": planes(PAGO[api])}),
                  llamada(api, "/min-time", {"capacity_goal": CUOTA_PAGO[api],
                                             "capacity_unit": "emails", "capacity_request_factor": "1"},
                          {"plan_names": planes(PAGO[api])}),
              ]))
    # PI-D02 · Q5 · a partir de qué volumen mensual el rate es el límite: R·W·k (rates del plan, ventana de un mes)
    I.append(("PI-D02", "Q5", "Rates del primer plan de pago y capacidad en 1 mes con la cuota expandida (presupuesto muy alto): el rate limita por encima de R·W·k",
              lambda api: [
                  llamada(api, "/rates", {"capacity_unit": "emails", "capacity_request_factor": "1"}, {"plan_names": planes(PAGO[api])}),
                  llamada(api, "/capacity-at", {"time": "1month", "capacity_unit": "emails",
                                                "capacity_request_factor": "1", "max_budget": 1e9}, {"plan_names": planes(PAGO[api])}),
              ]))
    # PI-D03 · Q9 · CRF que iguala el agotamiento de cuota y rate
    I.append(("PI-D03", "Q9", "Umbral de agotamiento de cuota (CRF que iguala cuota y rate) en el primer plan de pago",
              lambda api: [llamada(api, "/quota-exhaustion-threshold", {"capacity_unit": "emails"}, {"plan_names": planes(PAGO[api])})]))
    # PI-G02 · Q10 · coste de 25.000 correos sin cambiar de plan
    I.append(("PI-G02", "Q10", "Coste de un mes de 25.000 correos en el primer plan de pago sin cambiar de plan",
              lambda api: [llamada(api, "/budget/recommendation", {"desired_capacity": 25000, "capacity_unit": "emails"},
                                   {"plan_names": planes(PAGO[api])})]))
    return I


def resumen(resp):
    s = json.dumps(resp, ensure_ascii=False, default=str)
    return s if len(s) <= 600 else s[:600] + " …"


def ahora():
    return datetime.datetime.now().isoformat(timespec="seconds")


def comprobar_api(api):
    """Nombre de API conocido y YAML presente; si no, mensaje claro y salida."""
    if api not in APIS:
        sys.exit(f"API desconocida: «{api}». Conocidas: {', '.join(APIS)}")
    if not os.path.exists(APIS[api][0]):
        sys.exit(f"No existe la Datasheet de «{api}»: {APIS[api][0]} (¿ejecutas desde la raíz del proyecto? ¿está construida ya?)")


# ---------------------------------------------------------------------------------------------
# Ficheros de la carpeta de salida: <PI-id>_<api>.json, ORIGENES.json (origen por API) y RESULTADOS.md
# ---------------------------------------------------------------------------------------------
def escribir_json_instancia(outdir, pid, qn, desc, api, res):
    fn_json = f"{pid}_{api}.json"
    with io.open(os.path.join(outdir, fn_json), "w", encoding="utf-8") as f:
        json.dump({"pregunta": pid, "operacion": qn, "descripcion": desc, "api": api, "llamadas": res},
                  f, ensure_ascii=False, indent=1, default=str)
    return fn_json


def registrar_origen(outdir, api, origen):
    """ORIGENES.json: de dónde salieron las respuestas de cada API y cuándo (para la cabecera de RESULTADOS.md)."""
    ruta = os.path.join(outdir, "ORIGENES.json")
    origenes = {}
    if os.path.exists(ruta):
        with io.open(ruta, encoding="utf-8") as f:
            origenes = json.load(f)
    origenes[api] = {"origen": origen, "fecha": ahora()}
    with io.open(ruta, "w", encoding="utf-8") as f:
        json.dump(origenes, f, ensure_ascii=False, indent=1)


def leer_carpeta(outdir):
    """Devuelve {(pid, api): contenido} de todos los <PI-id>_<api>.json de la carpeta."""
    datos = {}
    for fn in sorted(os.listdir(outdir)):
        if not (fn.startswith("PI-") and fn.endswith(".json")):
            continue
        with io.open(os.path.join(outdir, fn), encoding="utf-8") as f:
            d = json.load(f)
        datos[(d["pregunta"], d["api"])] = d
    return datos


def migrar_cabecera_antigua(outdir, apis, origenes):
    """Un RESULTADOS.md anterior a ORIGENES.json llevaba una sola línea «Fecha: … · commit … · salud …»
    para todas las APIs: se conserva como origen de las que aún no lo tienen registrado."""
    ruta = os.path.join(outdir, "RESULTADOS.md")
    if not os.path.exists(ruta):
        return
    with io.open(ruta, encoding="utf-8") as f:
        linea = next((l.strip() for l in f if l.startswith("Fecha: ")), None)
    if not linea:
        return
    fecha, resto = linea[len("Fecha: "):].split(" · ", 1)
    origen = "PRIME4API local (uvicorn 127.0.0.1:8000) · " + resto.split(" · Datasheets:")[0]
    for api in apis:
        if api not in origenes:
            origenes[api] = {"origen": origen, "fecha": fecha}
    with io.open(os.path.join(outdir, "ORIGENES.json"), "w", encoding="utf-8") as f:
        json.dump(origenes, f, ensure_ascii=False, indent=1)


def escribir_resultados(outdir):
    """Regenera RESULTADOS.md leyendo los JSON de la carpeta: orden de instancias() y de APIS,
    y al final lo que haya en la carpeta sin estar en el catálogo del script."""
    datos = leer_carpeta(outdir)
    origenes = {}
    if os.path.exists(os.path.join(outdir, "ORIGENES.json")):
        with io.open(os.path.join(outdir, "ORIGENES.json"), encoding="utf-8") as f:
            origenes = json.load(f)
    apis = [a for a in APIS if any(k[1] == a for k in datos)]
    apis += sorted({k[1] for k in datos} - set(apis))
    migrar_cabecera_antigua(outdir, apis, origenes)
    cab = [f"# Ejecución de las preguntas P con PRIME4API (servicio REST)", "",
           f"Generado: {ahora()} a partir de los JSON de esta carpeta · Datasheets: las de `03_datos/apis/` "
           f"a la fecha de ejecución de cada API.", "", "Origen de las respuestas por API:"]
    for api in apis:
        o = origenes.get(api)
        if o:
            cab.append(f"- **{api}**: {o['origen']} · {o['fecha']}")
        else:
            mt = max(os.path.getmtime(os.path.join(outdir, f"{k[0]}_{api}.json")) for k in datos if k[1] == api)
            cab.append(f"- **{api}**: origen no registrado (ejecución anterior a `ORIGENES.json`) · ficheros de "
                       f"{datetime.datetime.fromtimestamp(mt).isoformat(timespec='seconds')}")
    cab += ["", "Cada fila remite a un JSON con la petición y la respuesta íntegras. Las respuestas son del motor;",
            "la comparación con el cálculo a mano está en `CONTRASTE.md`.", ""]
    orden = [(pid, qn, desc) for pid, qn, desc, _ in instancias()]
    vistos = {pid for pid, _, _ in orden}
    for (pid, api), d in sorted(datos.items()):
        if pid not in vistos:  # instancia que ya no está en el script pero sí en la carpeta
            orden.append((pid, d["operacion"], d["descripcion"]))
            vistos.add(pid)
    filas = ["| PI | Qn | API | Endpoint · parámetros | HTTP | Respuesta (resumen) | JSON |", "|---|---|---|---|---|---|---|"]
    for pid, qn, desc in orden:
        if not any(k[0] == pid for k in datos):
            continue
        cab.append(f"- **{pid}** ({qn}): {desc}")
        for api in apis:
            d = datos.get((pid, api))
            if not d:
                continue
            fn_json = f"{pid}_{api}.json"
            for r in d["llamadas"]:
                filas.append(f"| {pid} | {qn} | {api} | `{r['endpoint']}` · `{json.dumps(r['params'])}` · `{json.dumps(r['body'])}` "
                             f"| {r['http']} | `{resumen(r['respuesta']).replace('|', '¦')}` | `{fn_json}` |")
    with io.open(os.path.join(outdir, "RESULTADOS.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(cab + [""] + filas) + "\n")


# ---------------------------------------------------------------------------------------------
# Modo por defecto: servicio local + ejecución de todas las APIS
# ---------------------------------------------------------------------------------------------
def main(outdir):
    os.makedirs(outdir, exist_ok=True)
    # APIs del catálogo cuyo YAML aún no existe: se avisan y se saltan, no se aborta la ejecución
    apis = [a for a in APIS if os.path.exists(APIS[a][0])]
    for a in APIS:
        if a not in apis:
            print(f"AVISO: no existe {APIS[a][0]}; se omite «{a}»")
    srv = subprocess.Popen([sys.executable, "-m", "uvicorn", "app.main:app", "--host", "127.0.0.1", "--port", "8000"],
                           cwd=CACHE, stdout=open(os.path.join(outdir, "servidor.log"), "w"), stderr=subprocess.STDOUT)
    try:
        for _ in range(40):
            try:
                if requests.get("http://127.0.0.1:8000/", timeout=2).status_code == 200:
                    break
            except Exception:
                time.sleep(0.5)
        salud = requests.get("http://127.0.0.1:8000/", timeout=5).json()
        sha = subprocess.run(["git", "rev-parse", "HEAD"], cwd=CACHE, capture_output=True, text=True).stdout.strip()
        for pid, qn, desc, fn in instancias():
            for api in apis:
                res = fn(api)
                escribir_json_instancia(outdir, pid, qn, desc, api, res)
                print(pid, api, [r["http"] for r in res])
        for api in apis:
            registrar_origen(outdir, api, f"PRIME4API local (uvicorn 127.0.0.1:8000) · commit `{sha[:12]}` · salud: `{salud}`")
        escribir_resultados(outdir)
        print("escrito", outdir)
    finally:
        srv.terminate()
        try:
            srv.wait(timeout=10)
        except Exception:
            srv.kill()


# ---------------------------------------------------------------------------------------------
# Modo plan: lista de llamadas de una API para ejecutarlas en otra máquina (no llama a nada)
# ---------------------------------------------------------------------------------------------
def params_como_requests(params):
    """`requests` codifica cada valor de la query con str(): 100000 → "100000", 1e9 → "1000000000.0"."""
    return {k: (v if isinstance(v, str) else str(v)) for k, v in params.items() if v is not None}


def plan(api, salida, base):
    global SECO
    comprobar_api(api)
    SECO = True
    llamadas = []
    for pid, qn, desc, fn in instancias():
        for n, p in enumerate(fn(api)):
            params = params_como_requests(p["params"])
            url = base.rstrip("/") + p["endpoint"].split(" ", 1)[1]
            llamadas.append({"id": pid, "n": n, "op": qn, "descripcion": desc, "metodo": "POST", "url": url,
                             "url_completa": url + ("?" + urlencode(params) if params else ""),
                             "params": params, "body": p["body"]})
    doc = {"api": api, "base": base, "generado": ahora(), "datasheet": APIS[api][0], "datasheet_source": yaml_de(api),
           "nota": "Cada llamada es POST url?params con body JSON = body ∪ {datasheet_source}; el orden es el de importar.",
           "llamadas": llamadas}
    with io.open(salida, "w", encoding="utf-8") as f:
        json.dump(doc, f, ensure_ascii=False, indent=1)
    print(f"plan de {api}: {len(llamadas)} llamadas en {len(instancias())} instancias → {salida}")


# ---------------------------------------------------------------------------------------------
# Modo importar: respuestas obtenidas fuera (mismo orden que el plan) → JSON por instancia + RESULTADOS.md
# ---------------------------------------------------------------------------------------------
def importar(api, fichero, outdir, origen):
    global SECO
    if api not in APIS:
        sys.exit(f"API desconocida: «{api}». Conocidas: {', '.join(APIS)}")
    with io.open(fichero, encoding="utf-8") as f:
        respuestas = json.load(f)
    if isinstance(respuestas, dict):
        respuestas = respuestas.get("respuestas", respuestas.get("llamadas"))
    if not isinstance(respuestas, list):
        sys.exit(f"{fichero}: se esperaba una lista de respuestas (o un objeto con clave «respuestas»)")
    SECO = True
    # primero se casan todas las respuestas con el plan (orden e ids); no se escribe nada si algo falla
    i, salida = 0, []
    for pid, qn, desc, fn in instancias():
        res = []
        for n, p in enumerate(fn(api)):
            if i >= len(respuestas):
                sys.exit(f"faltan respuestas: {fichero} tiene {len(respuestas)} y el plan de {api} llega hasta {pid} n={n}")
            r = respuestas[i]
            if r.get("id") != pid or int(r.get("n", -1)) != n:
                sys.exit(f"respuesta #{i} desordenada: esperaba id={pid} n={n}, viene id={r.get('id')} n={r.get('n')}")
            if "http" not in r or "respuesta" not in r:
                sys.exit(f"respuesta #{i} ({pid} n={n}): faltan las claves «http» o «respuesta»")
            p.update({"http": r["http"], "ms": r.get("ms"), "respuesta": r["respuesta"]})
            res.append(p)
            i += 1
        salida.append((pid, qn, desc, res))
    if i != len(respuestas):
        print(f"AVISO: {fichero} trae {len(respuestas) - i} respuestas de más; se ignoran")
    os.makedirs(outdir, exist_ok=True)
    for pid, qn, desc, res in salida:
        escribir_json_instancia(outdir, pid, qn, desc, api, res)
        print(pid, api, [r["http"] for r in res])
    registrar_origen(outdir, api, origen)
    escribir_resultados(outdir)
    print("escrito", outdir, "(RESULTADOS.md regenerado)")


def opcion(args, nombre, defecto):
    """--nombre valor (o --nombre=valor) dentro de args; lo elimina de la lista."""
    for j, a in enumerate(args):
        if a == nombre and j + 1 < len(args):
            v = args[j + 1]; del args[j:j + 2]; return v
        if a.startswith(nombre + "="):
            v = a.split("=", 1)[1]; del args[j]; return v
    return defecto


if __name__ == "__main__":
    args = sys.argv[1:]
    _pedido = opcion(args, "--alias", None)  # «» = sin filtro; el mismo valor en plan e importar
    if _pedido is not None:                  # un alias explícito manda sobre ALIAS_POR_API
        ALIAS, ALIAS_POR_API = _pedido, {}
    if args and args[0] == "plan":
        base = opcion(args, "--base", BASE_REMOTA)
        if len(args) != 3:
            sys.exit("uso: ejecutar_prime4api_PI.py plan <api> <salida.json> [--base URL] [--alias NOMBRE]")
        plan(args[1], args[2], base)
    elif args and args[0] == "importar":
        origen = opcion(args, "--origen", f"PRIME4API remoto ({BASE_REMOTA}), respuestas importadas")
        if len(args) != 4:
            sys.exit("uso: ejecutar_prime4api_PI.py importar <api> <respuestas.json> <carpeta_salida/> "
                     "[--origen TEXTO] [--alias NOMBRE]")
        importar(args[1], args[2], args[3], origen)
    elif len(args) == 1:
        main(args[0])
    else:
        sys.exit("uso: ejecutar_prime4api_PI.py <carpeta_salida/> [--alias NOMBRE]  ·  "
                 "subcomandos: plan, importar")
