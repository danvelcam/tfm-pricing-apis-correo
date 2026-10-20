"""Efecto de declarar o no `rate` en un endpoint enumerado (Brevo, /v3/inbound/events).

El README de la guía (§3.4.1) dice que `/*` solo alcanza a los endpoints «que no
aparezca[n] explícitamente», y PRIME4API no implementa herencia de comodín en absoluto:
cero ocurrencias de `/*` en `app/services/datasheet_evaluator_service.py`, y en
`_process_node` los endpoints solo heredan `plan_rates` y `plan_quotas`. Un endpoint
enumerado sin `rate`, en un plan que tampoco declara `rate`, queda por tanto sin caudal.
"""
import sys, io, json, contextlib
sys.path.insert(0, "/root/.cache/atf/prime4api")
from app.services.datasheet_evaluator_service import DatasheetEvaluatorService
from app.schemas.datasheet import EvaluateDatasheetRequest
from app.utils.yaml_utils import load_yaml_source

SVC = DatasheetEvaluatorService()
EP = "/v3/inbound/events"
CON = f"      {EP}:\n        rate: rate_request_other_general\n        workload:"
SIN = f"      {EP}:\n        workload:"

src = io.open("03_datos/apis/brevo/datasheet.yaml", encoding="utf-8").read()
assert CON in src, "el fichero vivo debería declarar ya el rate"


def ev(y, op, params, plan, ep):
    req = EvaluateDatasheetRequest(datasheet_source="-", operation=op,
                                   operation_params=params, plan_names=[plan],
                                   endpoint_path=ep)
    with contextlib.redirect_stdout(io.StringIO()):
        return SVC.evaluate(y, req)


for etiqueta, texto in (("ANTES — endpoint enumerado SIN rate", src.replace(CON, SIN)),
                        ("DESPUÉS — con rate: rate_request_other_general", src)):
    y = load_yaml_source(texto)
    print("=" * 74)
    print(etiqueta)
    for op, par in (("limits", {}), ("min_time", {"capacity_goal": 1000})):
        r = ev(y, op, par, "professional", EP)
        print(f"  professional {EP}  {op:9s}")
        print(f"    {json.dumps(r, default=str, ensure_ascii=False)}")
