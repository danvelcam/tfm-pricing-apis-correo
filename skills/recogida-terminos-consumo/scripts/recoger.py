#!/usr/bin/env python3
"""Recogida de páginas de términos de consumo de un proveedor de correo.

Uso (la skill recogida-terminos-consumo, SKILL.md, manda sobre este fichero):

    recoger.py semillas  <api> --de FICHERO [FICHERO...] [--url URL ...] --salida DIR
    recoger.py descubrir <api> --salida DIR
    recoger.py extraer   <api> --salida DIR --texto DIR
    recoger.py cifras    --salida DIR

<api> es una clave de references/proveedores.json. --salida es la carpeta del
proveedor, por ejemplo terminos_bruto/postmark, donde cada fase reescribe el único
`recogida.yaml`. --texto es la carpeta del texto en bruto, que NO se publica
(SKILL.md, «Dónde va el texto»).

Biblioteca estándar más PyYAML: corre en el contenedor de scripts/contenedor.sh.
Sin sesiones, sin credenciales, sin JavaScript.
Respeta robots.txt, pide como mucho 2,5 páginas por segundo y no abre nada fuera
del ámbito oficial del proveedor.
"""
import argparse
import datetime
import functools
import hashlib
import html
import ipaddress
import json
import os
import re
import socket
import sys
import time
import urllib.error
import urllib.request
from html.parser import HTMLParser
from urllib.parse import unquote, urljoin, urlsplit, urlunsplit

import yaml

SKILL = "recogida-terminos-consumo"
SKILL_VERSION = "1.0.1"   # la 1.0 (0.3.1 congelada el 2026-10-23) con los arreglos de la revisión (README)
SCHEMA = "0.3"
SALIDA = "recogida.yaml"
AQUI = os.path.dirname(os.path.abspath(__file__))
REFS = os.path.join(AQUI, "..", "references")
UA = "Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0"
INTERVALO = 0.4          # segundos entre peticiones: 2,5 por segundo como máximo
TIMEOUT = 25
MAX_BYTES = 5 * 1024 * 1024
TOPE_INCLUIDAS = 250     # SKILL.md, «Presupuesto»
TOPE_SITEMAPS = 30
TOPE_HIJOS_SITEMAP = 15
TEXTO_MINIMO = 500       # menos de estos caracteres visibles: aviso sin_texto_visible
TERMINO_MAXIMO = 40      # caracteres de una evidencia: es una marca, no texto de la página
# Puerta de calidad (SKILL.md, «La puerta de calidad»). (sentido, umbral). Fijados con las
# tres capturas del 2026-10-23: el peor proveedor en cada medida queda dentro.
UMBRALES = {
    "semillas_fallidas_pasajeras": ("max", 0),
    "fallidas_pasajeras": ("max", 0.02),
    "fallidas": ("max", 0.15),
    "sin_texto": ("max", 0.10),
    "temas_con_evidencia": ("min", 5),
    "precios_con_evidencia": ("min", 1),
}


def ahora():
    return datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def cargar(nombre):
    with open(os.path.join(REFS, nombre), encoding="utf-8") as f:
        return json.load(f)


def escribir_yaml(ruta, obj):
    os.makedirs(os.path.dirname(os.path.abspath(ruta)), exist_ok=True)
    with open(ruta, "w", encoding="utf-8") as f:
        yaml.safe_dump(obj, f, sort_keys=False, allow_unicode=True, width=1000)


def leer_yaml(ruta):
    with open(ruta, encoding="utf-8") as f:
        return yaml.safe_load(f)


def firmar(doc):
    """Cada fase deja en `generator` la versión que la escribe: la puerta de calidad se
    calcula con las reglas de esa versión."""
    doc["generator"] = {"skill": SKILL, "skill_version": SKILL_VERSION}


def leer_recogida(carpeta, fase_previa):
    ruta = os.path.join(carpeta, SALIDA)
    if not os.path.exists(ruta):
        raise SystemExit(f"{ruta}: no existe; antes va la fase {fase_previa}")
    doc = leer_yaml(ruta)
    if doc.get("schema_version") != SCHEMA:
        raise SystemExit(f"{ruta}: esquema {doc.get('schema_version')!r}, esta versión escribe el {SCHEMA}")
    return doc


# ---------------------------------------------------------------- red

@functools.lru_cache(maxsize=None)
def _resolver(host, puerto):
    """Direcciones del host, o None si no resuelve. Una vez por host y ejecución."""
    try:
        return tuple(i[4][0].split("%")[0] for i in socket.getaddrinfo(host, puerto, proto=socket.IPPROTO_TCP))
    except (OSError, ValueError):
        return None


def bloqueo(url):
    """None si la URL se puede pedir; si no, el motivo. Se pide solo https a un host que
    resuelve a direcciones públicas: ni loopback, ni red privada, ni enlace local."""
    try:
        s = urlsplit(url)
        puerto = s.port or 443
    except ValueError:
        return "destino_no_publico"
    if s.scheme != "https" or not s.hostname:
        return "destino_no_publico"
    ips = _resolver(s.hostname, puerto)
    if ips is None:
        return "dns"
    if ips and all(ipaddress.ip_address(ip).is_global for ip in ips):
        return None
    return "destino_no_publico"


class RedireccionBloqueada(Exception):
    pass


class _Redirecciones(urllib.request.HTTPRedirectHandler):
    """Cada salto de una redirección pasa por bloqueo() antes de seguirlo."""

    def redirect_request(self, req, fp, code, msg, headers, newurl):
        if bloqueo(newurl):
            raise RedireccionBloqueada(newurl)
        return super().redirect_request(req, fp, code, msg, headers, newurl)


_abrir = urllib.request.build_opener(_Redirecciones()).open


class Cliente:
    """Una petición cada INTERVALO segundos, un reintento en 429 y 5xx."""

    def __init__(self):
        self.ultima = 0.0
        self.peticiones = 0

    def get(self, url, max_bytes=MAX_BYTES):
        motivo = bloqueo(url)
        if motivo == "dns":   # un fallo de resolución puede ser pasajero: un reintento
            time.sleep(2)
            _resolver.cache_clear()
            motivo = bloqueo(url)
        if motivo:
            return {"http": None, "url_final": url, "tipo": "", "cuerpo": None,
                    "error": "red:dns" if motivo == "dns" else motivo}
        for intento in (1, 2):
            espera = INTERVALO - (time.monotonic() - self.ultima)
            if espera > 0:
                time.sleep(espera)
            self.ultima = time.monotonic()
            self.peticiones += 1
            req = urllib.request.Request(url, headers={
                "User-Agent": UA, "Accept": "text/html,text/markdown,text/plain,application/xml;q=0.9,*/*;q=0.5",
                "Accept-Encoding": "identity", "Accept-Language": "en"})
            try:
                with _abrir(req, timeout=TIMEOUT) as r:
                    cuerpo = r.read(max_bytes + 1)
                    if len(cuerpo) > max_bytes:
                        return {"http": r.status, "url_final": r.geturl(), "tipo": r.headers.get("Content-Type", ""),
                                "cuerpo": None, "error": "demasiado_grande"}
                    return {"http": r.status, "url_final": r.geturl(), "tipo": r.headers.get("Content-Type", ""),
                            "cuerpo": cuerpo, "error": None}
            except urllib.error.HTTPError as e:
                if e.code in (429, 500, 502, 503, 504) and intento == 1:
                    try:
                        time.sleep(min(float(e.headers.get("Retry-After", "2")), 10))
                    except ValueError:
                        time.sleep(2)
                    continue
                return {"http": e.code, "url_final": url, "tipo": "", "cuerpo": None, "error": f"http_{e.code}"}
            except RedireccionBloqueada as e:
                return {"http": None, "url_final": str(e), "tipo": "", "cuerpo": None,
                        "error": "redirige_a_destino_no_publico"}
            except Exception as e:  # red, TLS, tiempo agotado
                if intento == 1:
                    time.sleep(2)
                    continue
                return {"http": None, "url_final": url, "tipo": "", "cuerpo": None,
                        "error": "red:" + type(e).__name__}
        return {"http": None, "url_final": url, "tipo": "", "cuerpo": None, "error": "red"}


class Robots:
    """robots.txt del grupo «*». RFC 9309: 4xx = sin restricciones; 5xx o red = todo prohibido.
    Entiende los comodines «*» y «$» y gana la regla más larga (Allow si empatan)."""

    def __init__(self, cliente):
        self.cliente = cliente
        self.hosts = {}

    def _cargar(self, origen):
        r = self.cliente.get(origen + "/robots.txt")
        info = {"reglas": [], "sitemaps": [], "estado": ""}
        if r["http"] == 200 and r["cuerpo"] is not None:
            info["estado"] = "ok"
            texto = r["cuerpo"].decode("utf-8", "replace")
            grupo_aplica, hay_agentes = False, False
            for linea in texto.splitlines():
                linea = linea.split("#", 1)[0].strip()
                if ":" not in linea:
                    continue
                k, v = (s.strip() for s in linea.split(":", 1))
                k = k.lower()
                if k == "sitemap":
                    info["sitemaps"].append(v)
                elif k == "user-agent":
                    if not hay_agentes:
                        grupo_aplica = False
                    hay_agentes = True
                    if v == "*":
                        grupo_aplica = True
                else:
                    hay_agentes = False
                    if grupo_aplica and k in ("allow", "disallow") and v:
                        info["reglas"].append((k, v))
        elif r["http"] is not None and 400 <= r["http"] < 500:
            info["estado"] = f"sin_robots_{r['http']}"
        else:
            info["estado"] = "robots_inaccesible"
            info["reglas"].append(("disallow", "/"))
        return info

    def info(self, url):
        s = urlsplit(url)
        origen = f"{s.scheme}://{s.netloc}"
        if origen not in self.hosts:
            self.hosts[origen] = self._cargar(origen)
        return self.hosts[origen]

    def permitido(self, url):
        s = urlsplit(url)
        ruta = s.path or "/"
        if s.query:
            ruta += "?" + s.query
        mejor = (-1, True)
        for k, patron in self.info(url)["reglas"]:
            rx = "^" + re.escape(patron).replace(r"\*", ".*").replace(r"\$", "$")
            if re.match(rx, ruta):
                largo = len(patron)
                if largo > mejor[0] or (largo == mejor[0] and k == "allow"):
                    mejor = (largo, k == "allow")
        return mejor[1]


# ---------------------------------------------------------------- URLs

def host_norm(host):
    host = host.lower()
    return host[4:] if host.startswith("www.") else host


def canonica(url, base=None, semilla=False):
    """Devuelve (url, clave) o None. Descarta fragmento y, salvo en semillas, la consulta.
    Una URL descubierta que acaba en .md se lleva a la página sin .md."""
    try:
        u = urljoin(base, url.strip()) if base else url.strip()
        s = urlsplit(u)
        puerto = s.port   # un puerto no numérico lanza ValueError
    except ValueError:
        return None
    if s.scheme not in ("http", "https") or not s.netloc:
        return None
    host = s.hostname.lower() if s.hostname else ""
    netloc = host + (f":{puerto}" if puerto and puerto not in (80, 443) else "")
    ruta = s.path or "/"
    if not semilla and ruta.endswith(".md") and len(ruta) > 3:
        ruta = ruta[:-3]
    consulta = s.query if semilla else ""
    url_c = urlunsplit(("https", netloc, ruta, consulta, ""))   # http pasa a https
    clave = host_norm(host) + ruta.rstrip("/").lower() + (("?" + consulta) if consulta else "")
    return url_c, clave


class Ambito:
    def __init__(self, entradas, excluir):
        self.entradas = []
        for e in entradas:
            host, _, resto = e["prefijo"].partition("/")
            self.entradas.append((host_norm(host), "/" + resto.lower(),
                                  re.compile(e["exige"]) if e.get("exige") else None))
        self.excluir = [re.compile(x) for x in excluir]

    def dentro(self, url, semilla=False):
        s = urlsplit(url)
        host, ruta = host_norm(s.hostname or ""), (s.path or "/").lower()
        for h, pref, exige in self.entradas:
            if host == h and (ruta.startswith(pref) or ruta + "/" == pref):
                if exige and not semilla and not exige.search(ruta):
                    continue
                if not semilla and any(x.search(host + ruta) for x in self.excluir):
                    return False
                return True
        return False

    def hosts(self):
        return sorted({h for h, _, _ in self.entradas})

    def raices(self):
        return sorted({(h, p) for h, p, _ in self.entradas})


class Reglas:
    def __init__(self):
        p = cargar("patrones.json")
        self.ext = set(p["extensiones_pagina"])
        self.idiomas = set(p["idiomas_no_ingles"])
        self.ruido = re.compile(p["ruido"])
        self.novedades = re.compile(p["novedades"])
        self.temas = [(t["id"], re.compile(t["patron"])) for t in p["temas"]]
        self.evidencia = {t["id"]: re.compile(t["evidencia"], re.I) for t in p["temas"]}
        self.superficies = [(s["nombre"], re.compile(s["patron"])) for s in p["superficies"]]
        self.superficie_defecto = p["superficie_por_defecto"]

    @staticmethod
    def texto_url(url):
        return unquote(urlsplit(url).path).lower().replace("_", "-")

    @staticmethod
    def texto_enlace(t):
        return re.sub(r"\s+", "-", t.strip().lower())

    def es_pagina(self, url):
        ruta = urlsplit(url).path
        base = ruta.rsplit("/", 1)[-1]
        ext = "." + base.rsplit(".", 1)[-1].lower() if "." in base else ""
        return ext in self.ext

    def es_idioma(self, url):
        segs = [x for x in urlsplit(url).path.lower().split("/") if x][:2]
        return any(x in self.idiomas for x in segs)

    def temas_de(self, url, textos):
        pu = self.texto_url(url)
        por_url = [i for i, rx in self.temas if rx.search(pu)]
        if por_url:
            return por_url, "url"
        por_texto = []
        for t in textos:
            tt = self.texto_enlace(t)
            por_texto += [i for i, rx in self.temas if rx.search(tt) and i not in por_texto]
        return por_texto, "texto_del_enlace"

    def superficie(self, url):
        s = urlsplit(url)
        t = (s.hostname or "") + unquote(s.path).lower().replace("_", "-")
        for nombre, rx in self.superficies:
            if rx.search(t):
                return nombre
        return self.superficie_defecto

    def decidir(self, url, ambito, es_semilla, textos):
        """Árbol del SKILL.md, «El árbol de decisión», en orden fijo."""
        if not ambito.dentro(url, es_semilla):
            return {"dentro": False, "decision": "descartada", "motivo": "fuera_ambito", "temas": []}
        r = {"dentro": True}
        if not self.es_pagina(url):
            return {**r, "decision": "descartada", "motivo": "no_pagina", "temas": []}
        if self.es_idioma(url):
            return {**r, "decision": "descartada", "motivo": "idioma", "temas": []}
        temas, via = self.temas_de(url, textos)
        if es_semilla:
            return {**r, "decision": "incluida", "motivo": "semilla", "temas": temas}
        if self.ruido.search(self.texto_url(url)):
            return {**r, "decision": "descartada", "motivo": "ruido", "temas": temas}
        if self.novedades.search(self.texto_url(url)):
            return {**r, "decision": "descartada", "motivo": "novedades", "temas": temas}
        if temas:
            return {**r, "decision": "incluida", "motivo": temas[0], "temas": temas, "via": via}
        return {**r, "decision": "descartada", "motivo": "sin_tema", "temas": []}


# ---------------------------------------------------------------- contenido

class Enlaces(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.enlaces, self.titulo, self.base = [], "", None
        self._a, self._t, self._tit = None, [], False

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == "a" and a.get("href"):
            self._a, self._t = a["href"], []
        elif tag == "base" and a.get("href") and not self.base:
            self.base = a["href"]
        elif tag == "title":
            self._tit = True

    def handle_endtag(self, tag):
        if tag == "a" and self._a is not None:
            self.enlaces.append((self._a, " ".join("".join(self._t).split())))
            self._a = None
        elif tag == "title":
            self._tit = False

    def handle_data(self, d):
        if self._a is not None:
            self._t.append(d)
        if self._tit:
            self.titulo += d


def decodificar(b):
    for enc in ("utf-8", "latin-1"):
        try:
            return b.decode(enc)
        except UnicodeDecodeError:
            continue
    return b.decode("utf-8", "replace")


def es_html(tipo, texto):
    return "html" in tipo.lower() or texto.lstrip()[:200].lower().startswith(("<!doctype html", "<html"))


def extraer_enlaces(cuerpo, tipo, url):
    """Lista de (url absoluta, texto del enlace) de un HTML o de un Markdown."""
    texto = decodificar(cuerpo)
    if es_html(tipo, texto):
        p = Enlaces()
        try:
            p.feed(texto)
        except Exception:
            pass
        base = urljoin(url, p.base) if p.base else url
        return [(urljoin(base, h), t) for h, t in p.enlaces]
    sal = []
    for m in re.finditer(r"\[([^\]]*)\]\((\S+?)\)", texto):
        sal.append((urljoin(url, m.group(2)), m.group(1)))
    for m in re.finditer(r"(?<![(\[])\bhttps?://[^\s<>\)\]\"']+", texto):
        sal.append((m.group(0).rstrip(".,;"), ""))
    return sal


def titulo_de(cuerpo, tipo, url):
    texto = decodificar(cuerpo)
    if es_html(tipo, texto):
        p = Enlaces()
        try:
            p.feed(texto)
        except Exception:
            pass
        t = " ".join(html.unescape(p.titulo).split())
        if t:
            return t
    else:
        m = re.search(r"^#\s+(.+)$", texto, re.M)
        if m:
            return m.group(1).strip()
        m = re.search(r"^title:\s*(.+)$", texto[:2000], re.M | re.I)
        if m:
            return m.group(1).strip().strip("\"'")
    return urlsplit(url).path.rstrip("/").rsplit("/", 1)[-1] or urlsplit(url).netloc


def texto_visible(cuerpo, tipo):
    texto = decodificar(cuerpo)
    if not es_html(tipo, texto):
        return len(texto.strip())
    t = re.sub(r"(?is)<(script|style|noscript|svg|head)\b.*?</\1>", " ", texto)
    t = re.sub(r"(?s)<[^>]+>", " ", t)
    return len(" ".join(html.unescape(t).split()))


def sha256(b):
    return hashlib.sha256(b).hexdigest()


INVISIBLES = re.compile("[\u00ad\u200b-\u200d\u2060\ufeff]")


def texto_normalizado(cuerpo, tipo):
    """Texto que ve el lector: sin comentarios, scripts, estilos, cabecera ni etiquetas, con las
    entidades resueltas, sin caracteres invisibles y con los blancos reducidos a un espacio. Lo que
    cambia en cada carga (nonces, tokens, ids de compilación) vive en atributos o en scripts y se va."""
    texto = decodificar(cuerpo)
    if es_html(tipo, texto):
        texto = re.sub(r"(?s)<!--.*?-->", " ", texto)
        texto = re.sub(r"(?is)<(script|style|noscript|svg|head|template)\b.*?</\1>", " ", texto)
        texto = html.unescape(re.sub(r"(?s)<[^>]+>", " ", texto))
    return " ".join(INVISIBLES.sub("", texto).split())


def sha256_texto(cuerpo, tipo):
    return sha256(texto_normalizado(cuerpo, tipo).encode("utf-8"))


# ---------------------------------------------------------------- semillas

URL_RE = re.compile(r"https?://[^\s<>\"'`|]+")


def limpiar_url(u):
    u = u.rstrip(".,;:)]}>\\*")
    u = re.sub(r"\)+$", "", u)
    return u


def cmd_semillas(a):
    prov = cargar("proveedores.json")["proveedores"][a.api]
    reglas = Reglas()
    ambito = Ambito(prov["ambito"], prov["excluir"])
    citadas = {}   # clave -> {url, citada_en}
    for f in a.de:
        with open(f, encoding="utf-8") as fh:
            for u in URL_RE.findall(fh.read()):
                u = limpiar_url(u)
                if "{" in u or "}" in u or "<" in u:
                    continue
                c = canonica(u, semilla=True)
                if not c:
                    continue
                d = citadas.setdefault(c[1], {"url": c[0], "citada_en": []})
                if f not in d["citada_en"]:
                    d["citada_en"].append(f)
    for u in a.url or []:
        c = canonica(u, semilla=True)
        if c:
            d = citadas.setdefault(c[1], {"url": c[0], "citada_en": []})
            d["citada_en"].append("--url")
    semillas, descartadas = [], []
    for k in sorted(citadas, key=lambda k: citadas[k]["url"]):
        d = citadas[k]
        v = reglas.decidir(d["url"], ambito, True, [])
        if v["decision"] == "incluida":
            semillas.append({"url": d["url"], "citada_en": sorted(d["citada_en"])})
        else:
            descartadas.append({"url": d["url"], "motivo": v["motivo"], "citada_en": sorted(d["citada_en"])})
    doc = {
        "schema_version": SCHEMA,
        "generator": {"skill": SKILL, "skill_version": SKILL_VERSION},
        "api": a.api,
        "fase": "semillas",
        "semillas": {"generated_at": ahora(), "ficheros_leidos": sorted(a.de),
                     "incluidas": semillas, "descartadas": descartadas},
        "descubrimiento": None, "extraccion": None, "cobertura": None, "presupuesto": None, "calidad": None,
        "resumen": None,
    }
    doc["resumen"] = resumen(doc)
    escribir_yaml(os.path.join(a.salida, SALIDA), doc)
    print(f"{a.api}: {len(semillas)} semillas, {len(descartadas)} descartadas")


RESUMEN = ["semillas", "semillas_descartadas", "candidatas", "incluidas", "descartadas_por_motivo",
           "capturadas", "fallidas", "con_aviso"]


def resumen(doc):
    """Recuentos de las listas del documento; null lo que su fase aún no ha escrito."""
    r = dict.fromkeys(RESUMEN)
    r["semillas"] = len(doc["semillas"]["incluidas"])
    r["semillas_descartadas"] = len(doc["semillas"]["descartadas"])
    if doc["descubrimiento"] is not None:
        cand = doc["descubrimiento"]["candidatas"]
        motivos = {}
        for c in cand:
            if c["decision"] == "descartada":
                motivos[c["motivo"]] = motivos.get(c["motivo"], 0) + 1
        r.update(candidatas=len(cand), incluidas=sum(1 for c in cand if c["decision"] == "incluida"),
                 descartadas_por_motivo=dict(sorted(motivos.items())))
    if doc["extraccion"] is not None:
        pag = doc["extraccion"]["paginas"]
        cap = sum(1 for p in pag if p["estado"] == "capturada")
        r.update(capturadas=cap, fallidas=len(pag) - cap, con_aviso=sum(1 for p in pag if p["aviso"]))
    return r


# ---------------------------------------------------------------- fase 1

def sitemap_urls(cuerpo):
    t = decodificar(cuerpo)
    locs = [html.unescape(m.strip()) for m in re.findall(r"<loc>\s*([^<]+?)\s*</loc>", t)]
    return ("<sitemapindex" in t[:2000]), locs


def a_https(url):
    """http pasa a https, como en canonica: la red solo pide https."""
    s = urlsplit(url)
    return urlunsplit(("https",) + tuple(s)[1:]) if s.scheme == "http" else url


def hijo_sitemap_ok(url, reglas, ambito):
    s = urlsplit(url)
    if host_norm(s.hostname or "") not in ambito.hosts():
        return False
    nombre = s.path.lower().rsplit("/", 1)[-1]
    fichas = [x for x in re.split(r"[^a-z]+", nombre) if x]
    return not any(x in reglas.idiomas for x in fichas)


def cmd_descubrir(a):
    prov = cargar("proveedores.json")["proveedores"][a.api]
    reglas = Reglas()
    ambito = Ambito(prov["ambito"], prov["excluir"])
    doc = leer_recogida(a.salida, "semillas")
    sem = {"semillas": doc["semillas"]["incluidas"]}
    cl = Cliente()
    rob = Robots(cl)
    ini = ahora()

    cand = {}   # clave -> dict

    def anotar(url, origen, texto="", semilla=False, base=None):
        c = canonica(url, base=base, semilla=semilla)
        if not c:
            return
        d = cand.setdefault(c[1], {"url": c[0], "semilla": False, "cuelga_de": [], "textos": []})
        if semilla and not d["semilla"]:
            d["url"] = c[0]   # la URL de la semilla manda sobre la variante que se vio antes
        d["semilla"] = d["semilla"] or semilla
        if origen not in d["cuelga_de"] and origen != d["url"]:
            d["cuelga_de"].append(origen)
        if texto and texto not in d["textos"] and len(d["textos"]) < 5:
            d["textos"].append(texto)

    # 1. semillas y los enlaces que llevan dentro
    filas_semillas = []
    for s in sem["semillas"]:
        anotar(s["url"], "semilla", semilla=True)
        fila = {"url": s["url"], "estado": "", "http": None, "enlaces": 0}
        if not rob.permitido(s["url"]):
            fila["estado"] = "robots"
        else:
            r = cl.get(s["url"])
            fila["http"] = r["http"]
            if r["cuerpo"] is None:
                fila["estado"] = r["error"] or "sin_cuerpo"
            else:
                pares = extraer_enlaces(r["cuerpo"], r["tipo"], r["url_final"])
                fila["estado"], fila["enlaces"] = "ok", len(pares)
                for href, txt in pares:
                    anotar(href, s["url"], txt)
        filas_semillas.append(fila)
        print(f"  [{a.api}] semilla {fila['estado']:<8} {s['url']}", file=sys.stderr)

    # 2. sitemaps (de robots.txt y /sitemap.xml) y llms.txt
    origenes = sorted({f"https://{h}" for h, _ in ambito.raices()})
    cola, vistos, filas_sitemaps = [], set(), []
    for o in origenes:
        info = rob.info(o + "/")
        for sm in info["sitemaps"] or [o + "/sitemap.xml"]:
            sm = a_https(sm)
            # Un sitemap que robots.txt declara fuera del ámbito no se pide.
            if urlsplit(sm).scheme == "https" and host_norm(urlsplit(sm).hostname or "") in ambito.hosts():
                cola.append((sm, 0))
    while cola and len(vistos) < TOPE_SITEMAPS:
        sm, nivel = cola.pop(0)
        if sm in vistos or sm.endswith(".gz"):
            continue
        vistos.add(sm)
        fila = {"url": sm, "estado": "", "urls": 0}
        if not rob.permitido(sm):
            fila["estado"] = "robots"
        else:
            r = cl.get(sm)
            if r["cuerpo"] is None:
                fila["estado"] = r["error"] or "sin_cuerpo"
            else:
                indice, locs = sitemap_urls(r["cuerpo"])
                fila["estado"], fila["urls"] = "ok", len(locs)
                if indice:
                    hijos = [a_https(x) for x in locs if hijo_sitemap_ok(x, reglas, ambito)][:TOPE_HIJOS_SITEMAP]
                    cola += [(x, nivel + 1) for x in hijos]
                    fila["hijos_seguidos"] = len(hijos)
                else:
                    for u in locs:
                        anotar(u, "sitemap:" + sm)
        filas_sitemaps.append(fila)
        print(f"  [{a.api}] sitemap {fila['estado']:<8} {fila['urls']:>6} {sm}", file=sys.stderr)

    sin_abrir = len({sm for sm, _ in cola if sm not in vistos and not sm.endswith(".gz")})
    filas_llms = []
    sondas = sorted({f"https://{h}{p if p.endswith('/') else p.rsplit('/', 1)[0] + '/'}llms.txt"
                     for h, p in ambito.raices()} | {f"https://{h}/llms.txt" for h, _ in ambito.raices()})
    for u in sondas:
        fila = {"url": u, "estado": "", "enlaces": 0}
        if not rob.permitido(u):
            fila["estado"] = "robots"
        else:
            r = cl.get(u)
            tipo_ok = r["cuerpo"] is not None and "html" not in r["tipo"].lower()
            if r["cuerpo"] is None or not tipo_ok:
                fila["estado"] = r["error"] or "no_es_llms"
            else:
                pares = extraer_enlaces(r["cuerpo"], r["tipo"], u)
                fila["estado"], fila["enlaces"] = "ok", len(pares)
                for href, txt in pares:
                    anotar(href, "llms.txt:" + u, txt)
        filas_llms.append(fila)

    # 3. decidir
    filas = []
    for k, d in cand.items():
        v = reglas.decidir(d["url"], ambito, d["semilla"], d["textos"])
        filas.append((k, d, v))
    por_motivo_fuera = sum(1 for _, _, v in filas if not v["dentro"])
    dentro = [(k, d, v) for k, d, v in filas if v["dentro"]]
    orden_tema = {t: i for i, (t, _) in enumerate(reglas.temas)}
    incl = [(k, d, v) for k, d, v in dentro if v["decision"] == "incluida"]
    incl.sort(key=lambda x: (not x[1]["semilla"], orden_tema.get(x[2]["motivo"], -1), x[1]["url"]))
    tope_fuera = {k for k, _, _ in incl[TOPE_INCLUIDAS:]}
    candidatas = []
    for k, d, v in sorted(dentro, key=lambda x: x[1]["url"]):
        fila = {"url": d["url"], "decision": v["decision"], "motivo": v["motivo"]}
        if v["decision"] == "incluida":
            if k in tope_fuera:
                fila["decision"], fila["motivo"] = "descartada", "tope"
            else:
                fila["temas"] = v["temas"]
                fila["via"] = v.get("via", "semilla" if d["semilla"] else "url")
        if fila["decision"] == "incluida":
            fila["interfaz"] = reglas.superficie(d["url"])
        fila["cuelga_de"] = d["cuelga_de"][:5]
        candidatas.append(fila)
    n_incl = sum(1 for c in candidatas if c["decision"] == "incluida")
    firmar(doc)
    doc["fase"] = "descubrimiento"
    doc["descubrimiento"] = {
        "generated_at": ini, "user_agent": UA, "intervalo_s": INTERVALO,
        "ambito": [e["prefijo"] + (f" [exige {e['exige']}]" if e.get("exige") else "") for e in prov["ambito"]],
        "semillas": filas_semillas,
        "derivadas": {
            "robots": [{"origen": o, "estado": i["estado"], "sitemaps": len(i["sitemaps"])}
                       for o, i in sorted(rob.hosts.items())],
            "sitemaps": filas_sitemaps,
            "llms_txt": filas_llms,
        },
        "halladas_fuera_ambito": por_motivo_fuera,
        "candidatas": candidatas,
    }
    # Volver a descubrir deja sin valor lo que extrajo la pasada anterior.
    doc.update(extraccion=None, cobertura=None, calidad=None)
    doc["presupuesto"] = {
        "peticiones": {"descubrir": cl.peticiones, "extraer": None},
        "sitemaps": {"abiertos": len(vistos), "tope": TOPE_SITEMAPS, "sin_abrir": sin_abrir,
                     "tope_alcanzado": sin_abrir > 0},
        "incluidas": {"halladas": len(incl), "tope": TOPE_INCLUIDAS, "fuera_por_tope": len(tope_fuera),
                      "tope_alcanzado": bool(tope_fuera)},
    }
    doc["resumen"] = resumen(doc)
    escribir_yaml(os.path.join(a.salida, SALIDA), doc)
    print(f"{a.api}: {len(filas_semillas)} semillas, {len(candidatas)} candidatas, {n_incl} incluidas "
          f"({cl.peticiones} peticiones)")


# ---------------------------------------------------------------- fase 2

TIPOS_TEXTO = ("text/", "application/xhtml", "application/markdown")


def sin_prefijo_en(url):
    s = urlsplit(url)
    if s.path.startswith("/en/") or s.path == "/en":
        return urlunsplit((s.scheme, s.netloc, s.path[3:] or "/", s.query, ""))
    return url


def extension(tipo, cuerpo, url):
    t = decodificar(cuerpo[:2000])
    if es_html(tipo, t):
        return "html"
    if "markdown" in tipo.lower() or urlsplit(url).path.endswith(".md"):
        return "md"
    return "txt"


def cmd_extraer(a):
    prov = cargar("proveedores.json")["proveedores"][a.api]
    ambito = Ambito(prov["ambito"], prov["excluir"])
    reglas = Reglas()
    doc = leer_recogida(a.salida, "semillas")
    if doc["descubrimiento"] is None:
        raise SystemExit(f"{a.api}: falta la fase descubrir")
    incl = [c for c in doc["descubrimiento"]["candidatas"] if c["decision"] == "incluida"]
    if a.limite:
        incl = incl[:a.limite]
    cl = Cliente()
    rob = Robots(cl)
    carpeta = os.path.join(a.texto, a.api)
    os.makedirs(carpeta, exist_ok=True)
    guarda = os.path.join(a.texto, ".gitignore")
    if not os.path.exists(guarda):   # que un git add descuidado no suba el texto
        with open(guarda, "w", encoding="utf-8") as fh:
            fh.write("*\n")
    ini = ahora()
    paginas, textos = [], {}
    for i, c in enumerate(incl, 1):
        fila = {"id": f"P-{i:03d}", "url": c["url"], "url_final": None, "titulo": None,
                "fecha_captura": ahora(), "sha256": None, "sha256_texto": None, "bytes": None, "content_type": None, "http": None,
                "estado": "fallida", "error": None, "aviso": None, "interfaz": c["interfaz"],
                "motivo": c["motivo"], "temas": c.get("temas", []), "cuelga_de": c["cuelga_de"],
                "fichero_texto": None}
        if not rob.permitido(c["url"]):
            fila["error"] = "robots"
        else:
            r = cl.get(c["url"])
            if r["cuerpo"] is not None and reglas.es_idioma(r["url_final"]) and not reglas.es_idioma(c["url"]):
                # el servidor nos manda a otro idioma por geolocalización: se pide la versión /en/
                s = urlsplit(c["url"])
                en = urlunsplit((s.scheme, s.netloc, "/en" + s.path, s.query, ""))
                if rob.permitido(en):
                    r2 = cl.get(en)
                    if r2["cuerpo"] is not None and not reglas.es_idioma(r2["url_final"]):
                        r, fila["aviso"] = r2, "via_prefijo_en"
            fila["http"], fila["url_final"], fila["content_type"] = r["http"], r["url_final"], r["tipo"] or None
            if r["cuerpo"] is None:
                fila["error"] = r["error"] or "sin_cuerpo"
            elif not (r["tipo"] == "" or r["tipo"].lower().startswith(TIPOS_TEXTO)):
                fila["error"] = "tipo_no_texto"
            elif not (ambito.dentro(r["url_final"], True) or ambito.dentro((canonica(r["url_final"]) or [r["url_final"]])[0], True)
                      or ambito.dentro(sin_prefijo_en(r["url_final"]), True)):
                fila["error"] = "redirige_fuera_ambito"
            else:
                cuerpo = r["cuerpo"]
                titulo = titulo_de(cuerpo, r["tipo"], r["url_final"])
                if re.match(r"(?i)\s*(error\s+)?(404\b|page not found|not found\b)", titulo) and len(cuerpo) < 200_000 \
                        and texto_visible(cuerpo, r["tipo"]) < 3000:
                    fila["error"] = "soft_404"
                    fila["titulo"] = titulo
                else:
                    h = sha256(cuerpo)
                    nombre = f"{h[:16]}.{extension(r['tipo'], cuerpo, r['url_final'])}"
                    ruta = os.path.join(carpeta, nombre)
                    if os.path.exists(ruta):
                        with open(ruta, "rb") as fh:
                            if sha256(fh.read()) != h:
                                raise SystemExit(f"colisión de huella en {ruta}")
                    else:
                        with open(ruta, "wb") as fh:
                            fh.write(cuerpo)
                    textos[fila["id"]] = texto_normalizado(cuerpo, r["tipo"])
                    fila.update(estado="capturada", titulo=titulo, sha256=h,
                                sha256_texto=sha256(textos[fila["id"]].encode("utf-8")), bytes=len(cuerpo),
                                fichero_texto=f"{a.api}/{nombre}")
                    if texto_visible(cuerpo, r["tipo"]) < TEXTO_MINIMO:
                        fila["aviso"] = (fila["aviso"] + "+" if fila["aviso"] else "") + "sin_texto_visible"
        paginas.append(fila)
        print(f"  [{a.api}] {i:>3}/{len(incl)} {fila['estado']:<9} {fila['error'] or fila['aviso'] or '':<18} {c['url']}",
              file=sys.stderr)
    cap = sum(1 for p in paginas if p["estado"] == "capturada")
    firmar(doc)
    doc["fase"] = "extraccion"
    doc["extraccion"] = {"generated_at": ini, "user_agent": UA, "intervalo_s": INTERVALO, "paginas": paginas}
    doc["cobertura"] = cobertura(paginas, textos, reglas)
    doc["presupuesto"]["peticiones"]["extraer"] = cl.peticiones
    doc["calidad"] = calidad(doc)
    doc["resumen"] = resumen(doc)
    escribir_yaml(os.path.join(a.salida, SALIDA), doc)
    escribir_indice_md(a.salida, a.api, prov["nombre"], paginas, ini)
    print(f"{a.api}: {cap} capturadas, {len(paginas) - cap} fallidas ({cl.peticiones} peticiones); "
          f"puerta de calidad: {'pasa' if doc['calidad']['pasa'] else 'NO pasa'}")


def evidencia_en(texto, rx):
    """(término, posición) de la primera coincidencia de rx en el texto con TERMINO_MAXIMO
    caracteres como mucho, o None."""
    for m in rx.finditer(texto):
        if 0 < len(m.group(0)) <= TERMINO_MAXIMO:
            return m.group(0), m.start()
    return None


def cobertura(paginas, textos, reglas):
    """Un registro por tema, en el orden de patrones.json (SKILL.md, «Cobertura por tema»).
    `textos` es {id: texto normalizado} de las capturadas."""
    filas = []
    for tema, _ in reglas.temas:
        con_tema = [p for p in paginas if tema in p["temas"]]
        capt = [p for p in con_tema if p["estado"] == "capturada"]
        halladas = [(p["id"], evidencia_en(textos[p["id"]], reglas.evidencia[tema])) for p in capt]
        halladas = [(i, e) for i, e in halladas if e]
        fila = {"tema": tema, "estado": "", "paginas": len(capt), "con_evidencia": len(halladas),
                "evidencia": None, "motivo_hueco": None}
        if halladas:
            i, (termino, pos) = halladas[0]
            fila.update(estado="con_evidencia", evidencia={"pagina": i, "termino": termino, "posicion": pos})
        elif capt:
            fila["estado"] = "solo_ruta"
        else:
            fila.update(estado="hueco", motivo_hueco="ninguna_capturada" if con_tema else "ninguna_incluida")
        filas.append(fila)
    return filas


def es_pasajero(error, version=SKILL_VERSION):
    """Fallo de red o del servidor que otra pasada puede no tener (SKILL.md, «La puerta de calidad»).
    Desde la 0.3.1 cuenta también el 403: en el barrido del 2026-10-23 los centros de ayuda de
    Brevo y Mailgun devolvieron 403 en cinco páginas que las tres capturas anteriores tenían."""
    codigos = "429|5\\d\\d" if version in ("0.3", "0.3.0") else "403|429|5\\d\\d"
    return bool(error) and (error.startswith("red") or re.match(rf"http_({codigos})$", error) is not None)


def medidas_calidad(doc):
    """{id: valor} de la puerta de calidad, en el orden de UMBRALES. Las proporciones van
    redondeadas a tres decimales."""
    pag = doc["extraccion"]["paginas"]
    version = doc["generator"]["skill_version"]
    pasajero = lambda e: es_pasajero(e, version)
    cap = [p for p in pag if p["estado"] == "capturada"]
    fall = [p for p in pag if p["estado"] != "capturada"]
    prop = lambda n, d: round(n / d, 3) if d else 1.0
    cob = {c["tema"]: c for c in doc["cobertura"]}
    v = {
        "semillas_fallidas_pasajeras": sum(1 for p in fall if p["motivo"] == "semilla" and pasajero(p["error"])),
        "fallidas_pasajeras": prop(sum(1 for p in fall if pasajero(p["error"])), len(pag)),
        "fallidas": prop(len(fall), len(pag)),
        "sin_texto": prop(sum(1 for p in cap if "sin_texto_visible" in (p["aviso"] or "")), len(cap)) if cap else 0.0,
        "temas_con_evidencia": sum(1 for c in doc["cobertura"] if c["estado"] == "con_evidencia"),
        "precios_con_evidencia": cob["precios"]["con_evidencia"],
    }
    return {k: v[k] for k in UMBRALES}


def cumple(sentido, valor, umbral):
    return valor <= umbral if sentido == "max" else valor >= umbral


def calidad(doc):
    medidas = []
    for k, valor in medidas_calidad(doc).items():
        sentido, umbral = UMBRALES[k]
        medidas.append({"id": k, "valor": valor, "sentido": sentido, "umbral": umbral,
                        "cumple": cumple(sentido, valor, umbral)})
    return {"medidas": medidas, "pasa": all(m["cumple"] for m in medidas)}


def escribir_indice_md(carpeta, api, nombre, paginas, fecha):
    def celda(s):
        return (s or "").replace("|", "\\|").replace("\n", " ")
    filas = ["| Título | Enlace | Fecha | Huella |", "|---|---|---|---|"]
    for p in paginas:
        if p["estado"] == "capturada":
            filas.append(f"| {celda(p['titulo'])} | <{p['url']}> | {p['fecha_captura'][:10]} | `{p['sha256'][:16]}` |")
    fallidas = [p for p in paginas if p["estado"] != "capturada"]
    cuerpo = [f"# Términos de consumo de {nombre}: índice de capturas", "",
              f"Captura del {fecha[:10]}. Enlace, título, fecha y huella (SHA-256, 16 primeros caracteres del contenido "
              "en bruto). El texto no está en el repositorio público: ver README de la skill.", "", *filas]
    if fallidas:
        cuerpo += ["", "## No capturadas", "", "| Enlace | Motivo |", "|---|---|"]
        cuerpo += [f"| <{p['url']}> | {p['error']} |" for p in fallidas]
    with open(os.path.join(carpeta, "indice.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(cuerpo) + "\n")


# ---------------------------------------------------------------- cifras

def cmd_cifras(a):
    claves = ["semillas", "candidatas", "incluidas", "capturadas", "fallidas", "con_aviso", "temas_con_evidencia"]
    filas, tot = [], dict.fromkeys(claves, 0)
    for api in sorted(d for d in os.listdir(a.salida) if os.path.isdir(os.path.join(a.salida, d))):
        ruta = os.path.join(a.salida, api, SALIDA)
        if not os.path.exists(ruta):
            continue
        doc = leer_yaml(ruta)
        r = doc["resumen"]
        fila = {"api": api, "fase": doc["fase"], **{k: r.get(k) for k in claves if k in r},
                "temas_con_evidencia": None, "puerta": None}
        if doc["calidad"] is not None:
            fila["temas_con_evidencia"] = sum(1 for c in doc["cobertura"] if c["estado"] == "con_evidencia")
            fila["puerta"] = "pasa" if doc["calidad"]["pasa"] else "no pasa"
        filas.append(fila)
        for k in tot:
            tot[k] += fila[k] or 0
    cab = "| API | Semillas | Candidatas | Incluidas | Capturadas | Fallidas | Con aviso | Temas con evidencia | Puerta |"
    md = [cab, "|---|---|---|---|---|---|---|---|---|"]
    for f in filas:
        v = lambda x: f"solo {f['fase']}" if x is None else str(x)
        md.append(f"| {f['api']} | {f['semillas']} | {v(f['candidatas'])} | {v(f['incluidas'])} | "
                  f"{v(f['capturadas'])} | {v(f['fallidas'])} | {v(f['con_aviso'])} | {v(f['temas_con_evidencia'])} | "
                  f"{v(f['puerta'])} |")
    md.append(f"| **Total** | {tot['semillas']} | {tot['candidatas']} | {tot['incluidas']} | {tot['capturadas']} | "
              f"{tot['fallidas']} | {tot['con_aviso']} | | |")
    escribir_yaml(os.path.join(a.salida, "cifras.yaml"),
                  {"schema_version": SCHEMA, "generated_at": ahora(), "apis": filas, "total": tot})
    with open(os.path.join(a.salida, "cifras.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(md) + "\n")
    print("\n".join(md))


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("semillas"); s.add_argument("api"); s.add_argument("--de", nargs="+", default=[])
    s.add_argument("--url", action="append"); s.add_argument("--salida", required=True)
    d = sub.add_parser("descubrir"); d.add_argument("api"); d.add_argument("--salida", required=True)
    e = sub.add_parser("extraer"); e.add_argument("api"); e.add_argument("--salida", required=True)
    e.add_argument("--texto", required=True); e.add_argument("--limite", type=int, default=0)
    c = sub.add_parser("cifras"); c.add_argument("--salida", required=True)
    a = ap.parse_args()
    {"semillas": cmd_semillas, "descubrir": cmd_descubrir, "extraer": cmd_extraer, "cifras": cmd_cifras}[a.cmd](a)


if __name__ == "__main__":
    main()
