"""Tests del veredicto de verificar_citas.py con varias URL en la línea (U3a, apartado B).

El script se prueba por subprocess con ficheros temporales, sin red.
"""
import os
import re
import subprocess
import sys
import tempfile
import unittest

AQUI = os.path.dirname(os.path.abspath(__file__))
SCRIPT = os.path.join(os.path.dirname(AQUI), "verificar_citas.py")

CITA = "el limite diario es de quinientos mensajes"
OTRO = "texto que no contiene nada de lo que se busca aqui"
PROPIA = "https://ejemplo.com/x/y"
PADRE = "https://ejemplo.com/z/w"   # solo existe el volcado de la página padre /z
VOLCADO_PADRE = "https://ejemplo.com/z"


def _nombre(u):
    return re.sub(r"[^A-Za-z0-9]+", "_", re.sub(r"^https?://", "", u).rstrip("/")).strip("_")


def _ejecutar(lineas, volcados):
    """lineas: líneas de data_provenance; volcados: {url: texto}. Devuelve (stdout, resumen)."""
    with tempfile.TemporaryDirectory() as d:
        carpeta = os.path.join(d, "volcados")
        os.mkdir(carpeta)
        for url, texto in volcados.items():
            with open(os.path.join(carpeta, _nombre(url) + ".txt"), "w", encoding="utf-8") as f:
                f.write(texto)
        ds = os.path.join(d, "datasheet.yaml")
        with open(ds, "w", encoding="utf-8") as f:
            f.write("metadata:\n  data_provenance:\n")
            for l in lineas:
                f.write('    - "%s"\n' % l.replace('"', '\\"'))
        r = subprocess.run([sys.executable, SCRIPT, ds, carpeta],
                           capture_output=True, text=True, timeout=60)
    assert r.returncode == 0, r.stderr
    resumen = [l for l in r.stdout.splitlines() if l.startswith("Resumen:")][0]
    return r.stdout, resumen


def _linea(*urls, extra=""):
    return "%s '%s' %s" % (" y ".join(urls), CITA, extra)


class TestOrdenUrls(unittest.TestCase):

    def test_B1_propia_sin_cita_y_luego_padre_sin_cita(self):
        out, res = _ejecutar([_linea(PROPIA, PADRE)], {PROPIA: OTRO, VOLCADO_PADRE: OTRO})
        self.assertIn("CAMBIO 1", res)
        self.assertIn("SIN-PAG 0", res)

    def test_B2_orden_inverso_da_lo_mismo(self):
        out, res = _ejecutar([_linea(PADRE, PROPIA)], {PROPIA: OTRO, VOLCADO_PADRE: OTRO})
        self.assertIn("CAMBIO 1", res)
        self.assertIn("SIN-PAG 0", res)

    def test_B3_un_ok_gana_en_ambos_ordenes(self):
        for urls in ((PROPIA, PADRE), (PADRE, PROPIA)):
            with self.subTest(urls=urls):
                _, res = _ejecutar([_linea(*urls)], {PROPIA: OTRO, VOLCADO_PADRE: "xx " + CITA + " yy"})
                self.assertIn("OK 1", res)
                self.assertIn("CAMBIO 0", res)

    def test_B4_una_sola_url_no_cambia(self):
        _, res = _ejecutar([_linea(PADRE)], {VOLCADO_PADRE: OTRO})
        self.assertIn("SIN-PAG 1", res)
        self.assertIn("CAMBIO 0", res)
        _, res = _ejecutar([_linea(PROPIA)], {PROPIA: OTRO})
        self.assertIn("CAMBIO 1", res)
        self.assertIn("SIN-PAG 0", res)

    def test_B5_relectura_convierte_el_cambio_conservado_en_f09(self):
        out, res = _ejecutar([_linea(PROPIA, PADRE, extra="RELEIDA el 2026-09-01")],
                             {PROPIA: OTRO, VOLCADO_PADRE: OTRO})
        self.assertIn("CAMBIO 0", res)
        self.assertIn("F-09 1", res)


if __name__ == "__main__":
    unittest.main()
