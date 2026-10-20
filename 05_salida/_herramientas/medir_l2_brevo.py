# -*- coding: utf-8 -*-
"""
Condición L2 del listón B9 para las cuatro fricciones nuevas de Brevo.

Qué mide
--------
B9 · L2 exige que PRIME4API, con la Datasheet del catálogo delante y **sin manipularla**,
devuelva un valor falso o deje sin responder lo que respondería si el esquema expresara la
carencia, y que la ejecución venga con un **caso de control** que enseñe que el motor sabe
responder bien cuando el esquema sí lo permite.

Este script no calcula nada por su cuenta: llama al motor y transcribe lo que devuelve.

  F-23 · comodín de prefijo con excepción
         → se le pregunta por una ruta real del prefijo /v3/smtp/ que el fichero no puede
           declarar. Control: una ruta que sí está declarada, en la misma Datasheet.
  F-24 · cuota blanda que absorbe y descarta
         → cuota diaria del plan gratuito. Control: una API cuyo borde es un muro.
  F-25 · dos modos excluyentes y una carga condicionada
         → carga máxima del endpoint de envío. Control: una API sin modos.
  F-27 · el exceso no se paga por unidad
         → coste a tres demandas. Control: una API con `overage_cost`.

Uso (en contenedor, con el clon de la guía montado en el HOME):

    python3 05_salida/_herramientas/medir_l2_brevo.py <salida.json>
"""
import sys, os, json, subprocess, datetime

REPO = "https://github.com/API-TaskForce/prime4api"
CACHE = os.path.expanduser("~/.cache/atf/prime4api")


def _bootstrap():
    if not os.path.isdir(os.path.join(CACHE, "app")):
        os.makedirs(os.path.dirname(CACHE), exist_ok=True)
        subprocess.run(["git", "clone", "--depth", "1", "-q", REPO, CACHE], check=True)
    sys.path.insert(0, CACHE)


_bootstrap()
from app.services.datasheet_evaluator_service import DatasheetEvaluatorService  # noqa: E402
from app.services.budget_service import BudgetService                            # noqa: E402
from app.schemas.datasheet import EvaluateDatasheetRequest                       # noqa: E402
from app.utils.yaml_utils import load_yaml_source                                # noqa: E402

SVC = DatasheetEvaluatorService()
BUDG = BudgetService()

DEMANDAS = [1.0, 100_000.0, 10_000_000.0]
BREVO = "03_datos/apis/brevo/datasheet.yaml"


def _cargar(ruta):
    with open(ruta, encoding="utf-8") as fh:
        return load_yaml_source(fh.read())


def _pregunta(ruta, **kw):
    """Una consulta al motor. Devuelve lo que conteste, o el error con el que se planta."""
    y = _cargar(ruta)
    req = EvaluateDatasheetRequest(datasheet_source="-", operation=kw.pop("operation", "limits"), **kw)
    try:
        r = SVC.evaluate(y, req)
    except Exception as e:
        return {"respondio": False, "error": f"{type(e).__name__}: {e}"}
    def _plano(it):
        if hasattr(it, "model_dump"):
            it = it.model_dump()
        elif hasattr(it, "dict"):
            it = it.dict()
        return {k: str(v) for k, v in it.items()} if isinstance(it, dict) else {"valor": str(it)}
    return {"respondio": True,
            "por_plan": {p: [_plano(i) for i in (v if isinstance(v, list) else [v])]
                         for p, v in r.items()}}


# --- F-23 ------------------------------------------------------------------------------
# El fichero declara endpoints explícitos y un comodín /*. El prefijo /v3/smtp/{…}, que el
# proveedor publica en 300 por hora, no se puede escribir: v0.3 solo admite el comodín
# global. Se le pregunta al motor por una ruta REAL de ese prefijo.
RUTAS_F23 = [
    ("/v3/smtp/statistics/events", "caso: ruta real del prefijo de 300 RPH, no declarable"),
    ("/v3/smtp/emails",            "control: ruta con fila propia, sí declarada"),
]


def f23():
    y = _cargar(BREVO)
    declarados = SVC.get_endpoints(y)
    salida = {"endpoints_declarados": declarados, "consultas": []}
    for ruta, papel in RUTAS_F23:
        r = _pregunta(BREVO, endpoint_path=ruta, plan_names=["free"])
        salida["consultas"].append({"ruta": ruta, "papel": papel, "plan": "free", **r})
    return salida


# --- F-24 y F-25 -----------------------------------------------------------------------
def cuotas_y_cargas(ruta_yaml, endpoint=None, plan=None):
    """
    Cuotas plan a plan, siempre aisladas.

    Un plan con `price: custom` tumba la consulta entera (DV-03), y si eso le pasa al caso
    de CONTROL la medida deja de distinguir «el esquema no lo expresa» de «el motor se
    rompió». Aislando, cada plan trae su respuesta o su error.
    """
    y = _cargar(ruta_yaml)
    planes = [plan] if plan else SVC.get_plans(y)
    salida = {}
    for pl in planes:
        kw = {"operation": "quotas", "plan_names": [pl]}
        if endpoint:
            kw["endpoint_path"] = endpoint
        salida[pl] = _pregunta(ruta_yaml, **kw)
    return salida


def cargas(ruta_yaml, endpoint, plan=None):
    """
    Carga máxima por petición que el motor atribuye a un endpoint, plan a plan.

    Es la cifra de F-25: el fichero solo tiene sitio para UNA, y el proveedor publica dos
    según la petición lleve adjunto o no.
    """
    y = _cargar(ruta_yaml)
    planes = [plan] if plan else SVC.get_plans(y)
    salida = {}
    for pl in planes:
        try:
            esc = SVC.get_curve_scenarios(
                y, EvaluateDatasheetRequest(datasheet_source="-", operation="limits",
                                            plan_names=[pl]))
        except Exception as e:
            salida[pl] = {"error": f"{type(e).__name__}: {e}"}
            continue
        filas = []
        for s in esc:
            if s.get("endpoint") != endpoint:
                continue
            filas.append({k: str(s.get(k)) for k in
                          ("endpoint", "alias", "workload_unit", "workload_max",
                           "workload_max_effective", "workload_min")
                          if k in s})
        salida[pl] = {"escenarios_del_endpoint": filas or "sin escenarios",
                      "claves_disponibles": sorted(esc[0].keys()) if esc else []}
    return salida


# --- F-27 ------------------------------------------------------------------------------
def coste(ruta_yaml):
    """
    Coste por demanda, plan a plan y con el plan AISLADO en su propia llamada.

    Preguntar por todos a la vez no vale aquí: el Enterprise de Brevo lleva `price: custom`
    y tumba la consulta entera con `could not convert string to float: 'custom'`, que es
    DV-03, un defecto del motor ya inventariado. Aislando, el fallo se queda en su fila y
    los otros cuatro planes sí contestan.
    """
    y = _cargar(ruta_yaml)
    filas = []
    for plan in SVC.get_plans(y):
        try:
            escenarios = SVC.get_curve_scenarios(
                y, EvaluateDatasheetRequest(datasheet_source="-", operation="limits",
                                            plan_names=[plan]))
        except Exception as e:
            filas.append({"plan": plan, "error": f"{type(e).__name__}: {e}",
                          "nota": "DV-03 si el mensaje es el del literal 'custom'"})
            continue
        try:
            pr = SVC.get_plan_pricing(y, plan)
        except Exception as e:
            filas.append({"plan": plan, "error": f"{type(e).__name__}: {e}"})
            continue
        del_plan = [s for s in escenarios if s["plan"] == plan]
        elasticas, costes = [], {f"{int(d)}": pr["price"] for d in DEMANDAS}
        for s in del_plan:
            quotas = s.get("quotas") or []
            elasticas += [q for q in quotas if getattr(q, "overage_cost", None)]
            for d in DEMANDAS:
                costes[f"{int(d)}"] = max(costes[f"{int(d)}"],
                                          round(pr["price"] + BUDG.total_overage_cost(quotas, d), 6))
        filas.append({"plan": plan, "precio_plan": pr["price"], "moneda": pr["currency"],
                      "cuotas_elasticas": len(elasticas), "coste_por_demanda": costes,
                      "plano": len(set(costes.values())) == 1})
    return filas


def superficie():
    """
    Lo que F-25 necesita archivado: qué se le puede preguntar al motor y qué ejes tiene
    ocupados esta Datasheet. Hasta ahora esto se comprobaba a mano y no quedaba en el JSON,
    así que la afirmación de F-25 remitía a una ejecución que no la contenía.
    """
    y = _cargar(BREVO)
    return {"campos_de_la_peticion": list(EvaluateDatasheetRequest.model_fields.keys()),
            "aliases_del_fichero": SVC.get_aliases(y),
            "endpoints_del_fichero": SVC.get_endpoints(y),
            "comodin_declarado": _pregunta(BREVO, endpoint_path="/*", plan_names=["free"])}


def main():
    destino = sys.argv[1] if len(sys.argv) > 1 else None
    informe = {
        "superficie_de_consulta": superficie(),
        "fecha_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "motor": "PRIME4API (clon de la guía en ~/.cache/atf/prime4api)",
        "demandas_en_correos": DEMANDAS,
        "F-23": f23(),
        "F-24": {"caso_brevo_free": cuotas_y_cargas(BREVO, plan="free"),
                 "control_sendgrid": cuotas_y_cargas("03_datos/apis/sendgrid/datasheet.yaml")},
        "F-25": {"caso_brevo_envio": cargas(BREVO, "/v3/smtp/email"),
                 "control_resend_lote": cargas("03_datos/apis/resend/datasheet.yaml",
                                               "/emails/batch")},
        "F-27": {"caso_brevo": coste(BREVO),
                 "control_mailersend": coste("03_datos/apis/mailersend/datasheet.yaml")},
    }
    txt = json.dumps(informe, ensure_ascii=False, indent=1)
    if destino:
        with open(destino, "w", encoding="utf-8") as fh:
            fh.write(txt)
        print("JSON: " + destino)
    print(txt[:3000])


if __name__ == "__main__":
    main()
