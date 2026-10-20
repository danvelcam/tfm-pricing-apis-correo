"""Tests de `fijar_alias` de gen_fig_capacidad.py (U3a, apartado C).

alias_de lee 03_datos/apis/<slug>/datasheet.yaml relativo al cwd: los tests trabajan en un
directorio temporal con datasheets falsas y restauran ALIAS y ALIAS_POR_SLUG al terminar.
"""
import os
import sys
import tempfile
import unittest

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(AQUI))

import gen_fig_capacidad as gf  # noqa: E402

YAML = """plans:
  p:
    endpoints:
      ep:
        healthy_reputation: {a: 1}
        sandbox: {a: 1}
        x: {a: 1}
"""


class TestFijarAlias(unittest.TestCase):

    def setUp(self):
        self._alias = gf.ALIAS
        self._por_slug = dict(gf.ALIAS_POR_SLUG)
        self._cwd = os.getcwd()
        self._tmp = tempfile.TemporaryDirectory()
        for slug in ("ses", "otra"):
            d = os.path.join(self._tmp.name, "03_datos", "apis", slug)
            os.makedirs(d)
            with open(os.path.join(d, "datasheet.yaml"), "w", encoding="utf-8") as f:
                f.write(YAML)
        os.chdir(self._tmp.name)

    def tearDown(self):
        os.chdir(self._cwd)
        self._tmp.cleanup()
        gf.ALIAS = self._alias
        gf.ALIAS_POR_SLUG.clear()
        gf.ALIAS_POR_SLUG.update(self._por_slug)

    def test_C1_alias_vacio_no_filtra_ninguna_api(self):
        gf.fijar_alias("")
        self.assertEqual(gf.ALIAS_POR_SLUG, {})
        self.assertFalse(gf.alias_de("ses", "ep"))
        self.assertFalse(gf.alias_de("otra", "ep"))

    def test_C2_alias_pedido_vale_para_todas_incluida_ses(self):
        gf.fijar_alias("x")
        self.assertEqual(gf.alias_de("ses", "ep"), "x")
        self.assertEqual(gf.alias_de("otra", "ep"), "x")

    def test_C3_sin_fijar_alias_ses_sigue_con_sandbox(self):
        self.assertEqual(gf.alias_de("ses", "ep"), "sandbox")
        self.assertEqual(gf.alias_de("otra", "ep"), "healthy_reputation")


if __name__ == "__main__":
    unittest.main()
