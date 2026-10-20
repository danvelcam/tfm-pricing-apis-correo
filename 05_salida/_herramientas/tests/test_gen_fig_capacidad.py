"""Tests de `gen_fig_capacidad.py` (unittest, stdlib).

    python3 -m unittest discover -s 05_salida/_herramientas/tests -v

D-036 (2026-09-14): los paneles llevan la dimensión que le piden al motor. Hasta
entonces el generador filtraba `dimension == "emails"` fijo, y por eso el panel de
MailerSend Hobby con k = 1 no podía enseñar la cuota diaria, que está en `requests`
(hallazgo H1).
"""
import os
import sys
import unittest

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(AQUI))

import gen_fig_capacidad as gf  # noqa: E402


ESCENARIOS = [
    {"dimension": "emails", "crf": 1.0, "alias": "healthy_reputation", "id": "emails-k1"},
    {"dimension": "emails", "crf": 70.0, "alias": "healthy_reputation", "id": "emails-k70"},
    {"dimension": "requests", "crf": 1.0, "alias": "healthy_reputation", "id": "requests-k1"},
    {"dimension": "emails", "crf": 1.0, "alias": "unapproved_account", "id": "emails-k1-sin-aprobar"},
]


class TestEscenarioDe(unittest.TestCase):

    def test_elige_por_dimension_crf_y_alias(self):
        sc = gf.escenario_de(ESCENARIOS, "emails", 1.0, "healthy_reputation")
        self.assertEqual(sc["id"], "emails-k1")

    def test_la_dimension_requests_trae_la_cuota_diaria_de_H1(self):
        sc = gf.escenario_de(ESCENARIOS, "requests", 1.0, "healthy_reputation")
        self.assertEqual(sc["id"], "requests-k1")

    def test_el_alias_distingue_dos_escenarios_de_la_misma_dimension(self):
        sc = gf.escenario_de(ESCENARIOS, "emails", 1.0, "unapproved_account")
        self.assertEqual(sc["id"], "emails-k1-sin-aprobar")

    def test_sin_coincidencia_avisa_en_vez_de_devolver_otro(self):
        with self.assertRaises(LookupError):
            gf.escenario_de(ESCENARIOS, "MBs", 1.0, "healthy_reputation")


class TestPaneles(unittest.TestCase):

    def test_cada_panel_declara_su_dimension(self):
        for p in gf.PANELES:
            self.assertEqual(len(p), 7, f'panel sin dimensión: {p}')

    def test_los_nombres_no_se_repiten(self):
        nombres = [p[-1] for p in gf.PANELES]
        self.assertEqual(len(nombres), len(set(nombres)))

    def test_solo_la_escalera_de_hobby_va_en_requests(self):
        en_requests = [p[-1] for p in gf.PANELES if p[-2] == "requests"]
        self.assertEqual(en_requests, ["mailersend_hobby_k1_peticiones"])

    def test_los_ocho_paneles_de_la_figura_51_siguen_en_correos(self):
        """Los ocho paneles de la Figura 5.1 se piden en `emails`: los seis del piloto y los dos de
        Amazon SES, que entraron el 2026-09-22 como paneles (g) y (h)."""
        en_emails = [p[-1] for p in gf.PANELES if p[-2] == "emails"]
        self.assertEqual(en_emails, [
            "resend_pro_k1", "resend_pro_k50",
            "sendgrid_essentials_k1", "sendgrid_essentials_k1000",
            "mailersend_hobby_k1", "mailersend_hobby_k70",
            "ses_pro_k1", "ses_pro_k50",
        ])


HTML_MOTOR = """
<div id="plan_hobby_ep__v1_email__healthy_reputation__dim_requests_crf_ov" class="x">
  <div><div id="aaaa-0000" class="plotly-graph-div" style="height:460px"></div>
  <script>Plotly.newPlot("aaaa-0000", [{"y":[0]}], {"title":{"text":"overlay"}}, {})</script></div>
</div>
<div id="plan_hobby_ep__v1_email__healthy_reputation__dim_requests_crf_0" class="x">
  <div><div id="bbbb-1111" class="plotly-graph-div" style="height:460px"></div>
  <script>Plotly.newPlot("bbbb-1111", [{"y":[1]}], {"title":{"text":"k = 1"}}, {})</script></div>
</div>
<div id="plan_hobby_ep__v1_email__healthy_reputation__dim_requests_crf_1" class="x">
  <div><div id="cccc-2222" class="plotly-graph-div" style="height:460px"></div>
  <script>Plotly.newPlot("cccc-2222", [{"y":[2]}], {"title":{"text":"k = 36"}}, {})</script></div>
</div>
"""


class TestContenedor(unittest.TestCase):
    """Con `show_derived_requests` el motor devuelve una figura por CRF más la superpuesta,
    así que el panel dice cuál de ellas extrae."""

    def test_elige_la_figura_del_contenedor_pedido(self):
        self.assertEqual(gf.uuid_de_contenedor(HTML_MOTOR, "dim_requests_crf_0"), "bbbb-1111")

    def test_no_se_queda_con_la_primera_del_documento(self):
        """La superpuesta (`crf_ov`) va antes en el HTML y no es la que queremos."""
        self.assertNotEqual(gf.uuid_de_contenedor(HTML_MOTOR, "dim_requests_crf_0"), "aaaa-0000")

    def test_contenedor_inexistente_avisa(self):
        with self.assertRaises(LookupError):
            gf.uuid_de_contenedor(HTML_MOTOR, "dim_emails_crf_0")


if __name__ == '__main__':
    unittest.main()
