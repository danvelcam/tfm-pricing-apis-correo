# -*- coding: utf-8 -*-
"""
Condición L2 del listón B9 para las fricciones nuevas de Amazon SES.

Qué mide
--------
B9 · L2 exige que PRIME4API, con la Datasheet del catálogo delante y **sin manipularla**,
devuelva un valor falso o deje sin responder lo que respondería si el esquema expresara la
carencia, y que la ejecución venga con **un caso de control** que enseñe que el motor sabe
responder bien cuando el esquema sí lo permite.

Este script no calcula nada por su cuenta: llama al motor y transcribe lo que devuelve.

  F-29 · el precio unitario no tiene campo cuando no hay cuota incluida
         → curva de coste de SES a tres demandas. Control: una API con `overage_cost`.
  F-31 · la unidad de gobierno es el par cuenta × región
         → capacidad del periodo de facturación. Control: una API cuya cuota es de la cuenta.

Uso (dentro del contenedor tfm-py, que tiene las dependencias del motor):

    docker exec tfm-py python3 05_salida/_herramientas/medir_l2_ses.py \\
        03_datos/apis/ses/evidencias/l2_prime4api_2026-09-18.json

Salida: tabla por consola y un JSON con la ejecución archivada.
"""
import sys, os, json, subprocess

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
from app.schemas.datasheet import EvaluateDatasheetRequest                      # noqa: E402
from app.utils.yaml_utils import load_yaml_source                                # noqa: E402

SVC = DatasheetEvaluatorService()
BUDG = BudgetService()

# Demandas a las que se pregunta el coste, en correos del periodo de facturación.
DEMANDAS = [1.0, 100_000.0, 10_000_000.0]

CASOS = [
    ("ses",        "03_datos/apis/ses/datasheet.yaml",        "caso"),
    ("postmark",   "03_datos/apis/postmark/datasheet.yaml",   "control"),
    ("sendgrid",   "03_datos/apis/sendgrid/datasheet.yaml",   "control"),
    ("mailersend", "03_datos/apis/mailersend/datasheet.yaml", "control"),
]


def _cargar(ruta):
    with open(ruta, encoding="utf-8") as fh:
        return load_yaml_source(fh.read())


def _escenarios(y):
    req = EvaluateDatasheetRequest(datasheet_source="-", operation="limits")
    return SVC.get_curve_scenarios(y, req)


def medir_coste(nombre, ruta):
    """
    F-29: qué cobra el motor por cada demanda, plan a plan.

    La pregunta correcta no es qué devuelve UN escenario, sino si ALGUNO de los del
    plan produce un coste que crezca con el volumen. Preguntárselo al primero que
    tenga cuota da un falso plano: en MailerSend el primero es la cuota de peticiones,
    que no lleva sobrecoste, y el sobrecoste vive en la cuota mensual de correos.
    """
    y = _cargar(ruta)
    filas = []
    escenarios = _escenarios(y)
    for plan in SVC.get_plans(y):
        pr = SVC.get_plan_pricing(y, plan)
        del_plan = [s for s in escenarios if s["plan"] == plan]
        elasticas, costes_max = [], {f"{int(d)}": pr["price"] for d in DEMANDAS}
        for s in del_plan:
            quotas = s.get("quotas") or []
            elasticas += [q for q in quotas if getattr(q, "overage_cost", None)]
            for d in DEMANDAS:
                total = round(pr["price"] + BUDG.total_overage_cost(quotas, d), 6)
                costes_max[f"{int(d)}"] = max(costes_max[f"{int(d)}"], total)
        filas.append({
            "plan": plan,
            "precio_plan": pr["price"],
            "moneda": pr["currency"],
            "escenarios_del_plan": len(del_plan),
            "cuotas_elasticas": len(elasticas),
            "coste_total_por_demanda": costes_max,
            "plano": len(set(costes_max.values())) == 1,
        })
    return filas


def medir_capacidad(nombre, ruta):
    """F-31: qué capacidad declara el motor para el periodo, sin eje de ámbito."""
    y = _cargar(ruta)
    req = EvaluateDatasheetRequest(datasheet_source="-", operation="quotas")
    try:
        r = SVC.evaluate(y, req)
    except Exception as e:                                    # pragma: no cover
        return {"error": f"{type(e).__name__}: {e}"}
    def _plano(it):
        # El motor devuelve modelos de pydantic en unas versiones y dicts en otras.
        if hasattr(it, "model_dump"):
            it = it.model_dump()
        elif hasattr(it, "dict"):
            it = it.dict()
        return {k: str(v) for k, v in it.items()} if isinstance(it, dict) else {"valor": str(it)}

    salida = {}
    for plan, items in r.items():
        salida[plan] = [_plano(it) for it in (items if isinstance(items, list) else [items])]
    return {"ejes_del_documento": {"planes": SVC.get_plans(y),
                                   "endpoints": SVC.get_endpoints(y),
                                   "aliases": SVC.get_aliases(y)},
            "cuotas": salida}


def main():
    destino = sys.argv[1] if len(sys.argv) > 1 else None
    informe = {"demandas_en_correos": DEMANDAS, "casos": {}}

    print("=" * 78)
    print("F-29 · coste que devuelve PRIME4API por demanda (precio de plan + exceso)")
    print("=" * 78)
    for nombre, ruta, papel in CASOS:
        informe["casos"].setdefault(nombre, {})["papel"] = papel
        try:
            filas = medir_coste(nombre, ruta)
        except Exception as e:
            # Un control que no arranca es dato, no ruido: suele ser un DV-nn ya
            # inventariado, y por eso se archiva con su traza en vez de callarlo.
            informe["casos"][nombre]["f29_coste"] = {"error": f"{type(e).__name__}: {e}"}
            print(f"  {papel:7s} {nombre:11s} [ERR] {type(e).__name__}: {e}", flush=True)
            continue
        informe["casos"][nombre]["f29_coste"] = filas
        for f in filas:
            c = f["coste_total_por_demanda"]
            marca = "PLANO" if f["plano"] else "crece"
            print(f"  {papel:7s} {nombre:11s} {f['plan']:22s} "
                  f"1={c['1']:>12} 100k={c['100000']:>12} 10M={c['10000000']:>14}  "
                  f"[{marca}, {f['cuotas_elasticas']} cuota(s) con overage]", flush=True)

    print()
    print("=" * 78)
    print("F-31 · ejes que el documento ofrece al motor")
    print("=" * 78)
    for nombre, ruta, papel in CASOS:
        cap = medir_capacidad(nombre, ruta)
        informe["casos"][nombre]["f31_capacidad"] = cap
        ejes = cap.get("ejes_del_documento", {})
        print(f"  {papel:7s} {nombre:11s} planes={len(ejes.get('planes', []))} "
              f"endpoints={len(ejes.get('endpoints', []))} "
              f"aliases={ejes.get('aliases')}")

    if destino:
        os.makedirs(os.path.dirname(destino), exist_ok=True)
        with open(destino, "w", encoding="utf-8") as fh:
            json.dump(informe, fh, ensure_ascii=False, indent=2)
        print(f"\nEjecución archivada en {destino}")


if __name__ == "__main__":
    main()
