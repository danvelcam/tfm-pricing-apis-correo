# -*- coding: utf-8 -*-
"""
Conformidad de una Datasheet contra PRIME4API — el consumidor real.

Por qué existe
--------------
`gen_datasheet_viewer.py` valida la datasheet contra reglas escritas por nosotros:
comprobar nuestro trabajo con nuestra propia herramienta es circular. Este script
rompe la circularidad. No aplica un esquema propio: hace que el motor de PRIME4API
(TFM de Ramón Gavira Sánchez) ingiera el YAML y ejecute sus operaciones. Si PRIME4API
no puede navegar la datasheet ni calcular sus límites, el formato está mal por
definición, diga lo que diga cualquier validador nuestro.

Uso
---
    python3 verificar_prime4api.py 03_datos/apis/postmark/datasheet.yaml [...]
    TRACE=1 python3 verificar_prime4api.py ...      # traza completa de los errores

La primera ejecución clona PRIME4API en ~/.cache/atf/prime4api (necesita red).
Dependencias: pip install --break-system-packages fastapi pydantic pyyaml requests numpy plotly

Salida: código 0 si todo pasa, 1 si alguna comprobación falla.
"""
import sys, os, io, json, subprocess, contextlib, traceback

REPO = "https://github.com/API-TaskForce/prime4api"
CACHE = os.path.expanduser("~/.cache/atf/prime4api")


def _bootstrap():
    if not os.path.isdir(os.path.join(CACHE, "app")):
        os.makedirs(os.path.dirname(CACHE), exist_ok=True)
        print(f"[setup] clonando {REPO} en {CACHE} ...")
        subprocess.run(["git", "clone", "--depth", "1", "-q", REPO, CACHE], check=True)
    sys.path.insert(0, CACHE)


_bootstrap()
from app.services.datasheet_evaluator_service import DatasheetEvaluatorService   # noqa: E402
from app.services.capacity_curve_service import CapacityCurveService              # noqa: E402
from app.services.budget_service import BudgetService                             # noqa: E402
from app.services.demand_evaluator_service import DemandEvaluatorService          # noqa: E402
from app.schemas.datasheet import EvaluateDatasheetRequest                        # noqa: E402
from app.utils.yaml_utils import load_yaml_source                                 # noqa: E402

SVC   = DatasheetEvaluatorService()
CURVE = CapacityCurveService()
BUDG  = BudgetService()
DEM   = DemandEvaluatorService()

# Navegación: lo que HARVEY4API y SPHERE necesitan para recorrer la datasheet.
NAV = [
    ("nav.plans",          lambda y: SVC.get_plans(y)),
    ("nav.endpoints",      lambda y: SVC.get_endpoints(y)),
    ("nav.capacity_units", lambda y: SVC.get_capacity_units(y)),
    ("nav.aliases",        lambda y: SVC.get_aliases(y)),
    ("nav.crf_ranges",     lambda y: SVC.get_crf_ranges(y)),
]

# Evaluación: las operaciones que responden a Q1-Q10 del ground truth.
OPS = [
    ("op.rates",                      "rates",   {}),
    ("op.quotas",                     "quotas",  {}),
    ("op.limits",                     "limits",  {}),
    ("op.min_time",                   "min_time", {"capacity_goal": 1000}),
    ("op.capacity_at",                "capacity_at", {"time": "1 day"}),
    ("op.quota_exhaustion_threshold", "quota_exhaustion_threshold", {}),
    ("op.idle_time_period",           "idle_time_period", {}),
]


def _short(v, n=150):
    s = json.dumps(v, default=str, ensure_ascii=False)
    return s if len(s) <= n else s[:n] + " ..."


@contextlib.contextmanager
def _quiet():
    """PRIME4API imprime trazas [DIM]/[BR] por stdout. Se silencian."""
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        yield


def run(path):
    name = os.path.basename(os.path.dirname(path)) or os.path.basename(path)
    print("=" * 78)
    print(f"DATASHEET: {name}   ({path})")
    print("=" * 78)
    with io.open(path, encoding="utf-8") as f:
        y = load_yaml_source(f.read())

    ok, fails = 0, []

    def check(label, fn):
        nonlocal ok
        try:
            with _quiet():
                res = fn()
            print(f"  [OK ] {label:34s} {_short(res)}")
            ok += 1
        except Exception as e:
            print(f"  [ERR] {label:34s} {type(e).__name__}: {e}")
            fails.append((label, f"{type(e).__name__}: {e}"))
            if os.environ.get("TRACE"):
                traceback.print_exc()

    for label, fn in NAV:
        check(label, lambda fn=fn: fn(y))

    try:
        plans = SVC.get_plans(y)
    except Exception:
        plans = []
    for p in plans:
        check(f"pricing[{p}]", lambda p=p: SVC.get_plan_pricing(y, p))

    comprobaciones_post_tfm(y, check)

    for label, op, params in OPS:
        def _ev(op=op, params=params):
            req = EvaluateDatasheetRequest(datasheet_source="-", operation=op,
                                           operation_params=params)
            r = SVC.evaluate(y, req)
            return {"planes": list(r), "items": sum(len(v) for v in r.values())}
        check(label, _ev)

    print(f"  ---- {name}: {ok} OK / {len(fails)} ERR")
    return name, ok, fails


# ─────────────────────────────────────────────────────────────────────────────
# Superficie post-TFM: curvas, presupuesto y demanda.
# PRIME4API siguió evolucionando tras la entrega del TFM de Gavira (commits del
# 2026-07-26 y 2026-08-08, todos sobre curvas de capacidad). Esta parte comprueba
# que la Datasheet sirve también para lo que el motor hace HOY, no solo para lo
# que el TFM documenta.
# ─────────────────────────────────────────────────────────────────────────────

def _escenarios(y):
    req = EvaluateDatasheetRequest(datasheet_source="-", operation="limits")
    return SVC.get_curve_scenarios(y, req)


def comprobaciones_post_tfm(y, check):
    check("curve.scenarios", lambda: {"n": len(_escenarios(y))})

    def _curvas(tipo):
        sc = _escenarios(y)
        if not sc:
            raise ValueError("get_curve_scenarios devolvió 0 escenarios")
        fn = (CURVE.get_accumulated_capacity_curve if tipo == "acumulada"
              else CURVE.get_inflection_point_capacity_curve)
        n = 0
        for s in sc:
            fn("1 day", s.get("rates") or None, s.get("quotas") or None)
            n += 1
        return {"escenarios_dibujados": n}

    check("curve.accumulated", lambda: _curvas("acumulada"))
    check("curve.inflection",  lambda: _curvas("inflexion"))

    def _coste():
        sc, n = _escenarios(y), 0
        for s in sc:
            pr = SVC.get_plan_pricing(y, s["plan"])
            BUDG.cost_curve_points(s.get("quotas") or [], pr["price"], 100000.0)
            n += 1
        return {"curvas_de_coste": n}

    check("budget.cost_curve", _coste)

    def _recom():
        sc, n = _escenarios(y), 0
        for s in sc:
            pr = SVC.get_plan_pricing(y, s["plan"])
            BUDG.compute_recommendation(
                plan_name=s["plan"], endpoint=s["endpoint"], alias=s.get("alias"),
                dimension=s.get("dimension", "requests"), plan_price=pr["price"],
                billing_period_ms=pr["period_ms"], currency=pr["currency"],
                quotas=s.get("quotas") or [], rates=s.get("rates") or [],
                desired_capacity=10000.0, max_budget=None, exclude_plan_price=False,
                provider_mode=False)
            n += 1
        return {"recomendaciones": n}

    check("budget.recommendation", _recom)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(2)
    resumen, total_err = [], 0
    for p in sys.argv[1:]:
        n, o, f = run(p)
        resumen.append((n, o, f))
        total_err += len(f)
    print()
    print("RESUMEN")
    for n, o, f in resumen:
        estado = "CONFORME" if not f else f"NO CONFORME ({len(f)})"
        print(f"  {n:16s} {o:3d} OK   {estado}")
        for label, msg in f:
            print(f"      · {label}: {msg}")
    sys.exit(1 if total_err else 0)
