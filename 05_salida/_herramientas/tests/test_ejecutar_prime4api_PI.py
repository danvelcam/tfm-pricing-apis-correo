"""Tests del catálogo de llamadas P (`ejecutar_prime4api_PI.instancias`).

Necesita `pyyaml` (el módulo lee las Datasheets para el alias), así que se corre en
contenedor:

    docker exec tfm-py python -m unittest discover -s 05_salida/_herramientas/tests -v

D-037 (2026-09-14): PI-A06 responde con el par de regímenes. Sin `max_budget` el motor
trata la cuota con sobrecoste como dura y cuenta renovaciones; con un presupuesto que no
limita, la expande y el tiempo lo fija el caudal. Las dos cifras son del proveedor, y la
pregunta no dice cuál vale.
"""
import os
import sys
import unittest

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(AQUI))
# El módulo se importa desde la raíz del repo: las rutas de las Datasheets son relativas.
os.chdir(os.path.dirname(os.path.dirname(os.path.dirname(AQUI))))

import ejecutar_prime4api_PI as epi  # noqa: E402


def a06_de(api):
    epi.SECO = True
    for pid, _qn, _desc, fn in epi.instancias():
        if pid == "PI-A06":
            return fn(api)
    raise AssertionError("PI-A06 no está en el catálogo de instancias")


class TestA06ParDeRegimenes(unittest.TestCase):

    def test_cuatro_llamadas_por_api(self):
        self.assertEqual(len(a06_de("mailersend")), 4)

    def test_las_dos_primeras_van_sin_presupuesto(self):
        for ll in a06_de("mailersend")[:2]:
            self.assertNotIn("max_budget", ll["params"])

    def test_las_dos_ultimas_llevan_un_presupuesto_que_no_limita(self):
        for ll in a06_de("mailersend")[2:]:
            self.assertGreaterEqual(float(ll["params"]["max_budget"]), 1e9)

    def test_el_objetivo_es_el_mismo_en_las_cuatro(self):
        objetivos = {(ll["params"]["capacity_goal"], ll["params"]["capacity_unit"])
                     for ll in a06_de("mailersend")}
        self.assertEqual(objetivos, {(100000, "emails")})

    def test_cada_regimen_lleva_k_1_y_k_maximo(self):
        for api in ("postmark", "resend", "sendgrid", "mailersend"):
            ks = [str(ll["params"]["capacity_request_factor"]) for ll in a06_de(api)]
            kmax = str(epi.KMAX[api])
            self.assertEqual(ks, ["1", kmax, "1", kmax], f"{api}: {ks}")

    def test_las_cuatro_apis_del_catalogo_tienen_A06(self):
        for api in ("postmark", "resend", "sendgrid", "mailersend"):
            self.assertEqual(len(a06_de(api)), 4, api)


if __name__ == '__main__':
    unittest.main()
