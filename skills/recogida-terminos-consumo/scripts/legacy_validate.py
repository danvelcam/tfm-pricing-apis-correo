#!/usr/bin/env python3
"""Valida la salida JSON de recogida-terminos-consumo 0.1 y 0.2 (esquemas 0.1 y 0.2).

Desde la 0.3 la salida es un único `recogida.yaml` y la valida `validate_result.py`, que
llama a este fichero cuando la carpeta trae los JSON de antes. Se guarda para poder
volver a validar las capturas del 2026-10-23.

Uso:
    python3 -I legacy_validate.py CARPETA_PROVEEDOR --texto CARPETA_TEXTO [--incluir incluir.txt]

CARPETA_PROVEEDOR es terminos_bruto/<api>/ (semillas.json, descubrimiento.json,
indice.json). CARPETA_TEXTO es la carpeta del texto en bruto, la que contiene <api>/.

Comprueba el esquema 0.2, o el 0.1 de la demo (claves y orden), los valores permitidos, los ids, que los
recuentos de `resumen` son los de las listas, que cada candidata incluida y dentro del
ámbito está en el índice, que cada página capturada tiene su fichero de texto y que
sha256, bytes y, en el esquema 0.2, sha256_texto son los del fichero. Comprueba también que el texto no está en la
carpeta que se publica: ni dentro de CARPETA_PROVEEDOR ni bajo una regla «+» de
incluir.txt. No juzga si una página merece estar en el conjunto.

Necesita el `recoger.py` de la 0.3, que importa PyYAML: corre en el contenedor del README. Sale con 0 si no hay errores y con 1 si los hay, con un
error por línea.
"""
import argparse
import fnmatch
import hashlib
import importlib.util
import json
import os
import re
import sys

SKILL = "recogida-terminos-consumo"
# esquema -> versión de la skill que lo escribe. El 0.1 (demo del 2026-10-23) no lleva sha256_texto.
ESQUEMAS = {"0.1": re.compile(r"^0\.1(\.\d+)?$"), "0.2": re.compile(r"^0\.2(\.\d+)?$")}
AQUI = os.path.dirname(os.path.abspath(__file__))
HEX64 = re.compile(r"^[0-9a-f]{64}$")
FECHA = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
ID = re.compile(r"^P-(\d{3,})$")

SEMILLAS_TOP = ["schema_version", "generator", "api", "generated_at", "ficheros_leidos", "semillas", "descartadas", "resumen"]
DESC_TOP = ["schema_version", "generator", "api", "run", "ambito", "semillas", "derivadas", "candidatas", "resumen"]
INDICE_TOP = ["schema_version", "generator", "api", "run", "paginas", "resumen"]
PAGINA = ["id", "url", "url_final", "titulo", "fecha_captura", "sha256", "sha256_texto", "bytes", "content_type", "http", "estado",
          "error", "aviso", "interfaz", "motivo", "temas", "cuelga_de", "fichero_texto"]
CAND_INCL = ["url", "decision", "motivo", "temas", "via", "interfaz", "cuelga_de"]
CAND_DESC = ["url", "decision", "motivo", "cuelga_de"]
MOTIVOS_DESCARTE = ["no_pagina", "idioma", "ruido", "novedades", "sin_tema", "tope"]
ESTADOS = ["capturada", "fallida"]
ERRORES = ["robots", "tipo_no_texto", "redirige_fuera_ambito", "soft_404", "sin_cuerpo", "demasiado_grande",
           "destino_no_publico", "redirige_a_destino_no_publico"]
EXTENSIONES = ["html", "md", "txt"]   # las que da extension() en recoger.py

errores = []


def err(msg):
    errores.append(msg)


def cargar_json(ruta):
    try:
        with open(ruta, encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        err(f"{os.path.basename(ruta)}: no existe")
    except json.JSONDecodeError as e:
        err(f"{os.path.basename(ruta)}: JSON mal formado ({e})")
    return None


def claves(obj, esperadas, donde):
    if not isinstance(obj, dict):
        err(f"{donde}: debe ser un objeto")
        return False
    if list(obj) != esperadas:
        err(f"{donde}: claves {list(obj)}, se esperaba {esperadas}")
        return False
    return True


def cabecera(obj, api, donde, esquema):
    if obj.get("schema_version") != esquema:
        err(f"{donde}: schema_version debe ser {esquema}, el de semillas.json")
    g = obj.get("generator")
    if not (isinstance(g, dict) and g.get("skill") == SKILL and esquema in ESQUEMAS
            and ESQUEMAS[esquema].match(str(g.get("skill_version", "")))):
        err(f"{donde}: generator inválido")
    if obj.get("api") != api:
        err(f"{donde}: api es {obj.get('api')!r}, la carpeta es {api!r}")


def sha(ruta):
    h = hashlib.sha256()
    with open(ruta, "rb") as f:
        for bloque in iter(lambda: f.read(1 << 20), b""):
            h.update(bloque)
    return h.hexdigest()


def ruta_relativa_a_repo(ruta):
    d = os.path.abspath(ruta)
    while d != "/":
        if os.path.isdir(os.path.join(d, ".git")):
            return os.path.relpath(os.path.abspath(ruta), d).replace(os.sep, "/")
        d = os.path.dirname(d)
    return None


def reglas_incluir(ruta):
    reglas = []
    with open(ruta, encoding="utf-8") as f:
        for linea in f:
            linea = linea.strip()
            if linea[:2] in ("+ ", "- "):
                reglas.append((linea[0] == "+", linea[2:].strip()))
    return reglas


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("carpeta")
    ap.add_argument("--texto", required=True)
    ap.add_argument("--incluir")
    a = ap.parse_args(argv)
    carpeta = os.path.abspath(a.carpeta)
    api = os.path.basename(carpeta.rstrip("/"))
    if not os.path.isdir(carpeta):
        err(f"{carpeta}: no es una carpeta")
        return salir()

    # ámbito: se carga recoger.py por ruta, porque `python -I` quita el directorio del script del path
    spec = importlib.util.spec_from_file_location("recoger", os.path.join(AQUI, "recoger.py"))
    rec = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(rec)
    prov = rec.cargar("proveedores.json")["proveedores"].get(api)
    if prov is None:
        err(f"{api}: no está en references/proveedores.json")
        return salir()
    ambito = rec.Ambito(prov["ambito"], prov["excluir"])

    sem = cargar_json(os.path.join(carpeta, "semillas.json"))
    desc = cargar_json(os.path.join(carpeta, "descubrimiento.json"))
    ind = cargar_json(os.path.join(carpeta, "indice.json"))
    # el esquema lo fija semillas.json; los otros dos tienen que llevar el mismo
    esquema = next((str(o.get("schema_version")) for o in (sem, desc, ind) if isinstance(o, dict)), "0.2")
    if esquema not in ESQUEMAS:
        err(f"schema_version {esquema!r} desconocido; se admiten {', '.join(ESQUEMAS)}")
        esquema = "0.2"
    pagina = PAGINA if esquema != "0.1" else [k for k in PAGINA if k != "sha256_texto"]

    # ---- semillas.json
    if sem and claves(sem, SEMILLAS_TOP, "semillas.json"):
        cabecera(sem, api, "semillas.json", esquema)
        if not FECHA.match(str(sem["generated_at"])):
            err("semillas.json: generated_at no es una fecha UTC")
        urls = [s.get("url") for s in sem["semillas"]]
        if len(set(urls)) != len(urls):
            err("semillas.json: hay semillas repetidas")
        for s in sem["semillas"]:
            if not ambito.dentro(s["url"], True):
                err(f"semillas.json: semilla fuera del ámbito: {s['url']}")
            if not s.get("citada_en"):
                err(f"semillas.json: semilla sin citada_en: {s['url']}")
        if sem["resumen"] != {"semillas": len(sem["semillas"]), "descartadas": len(sem["descartadas"])}:
            err("semillas.json: resumen no coincide con las listas")

    # ---- descubrimiento.json
    candidatas = []
    if desc and claves(desc, DESC_TOP, "descubrimiento.json"):
        cabecera(desc, api, "descubrimiento.json", esquema)
        candidatas = desc["candidatas"]
        vistas = set()
        n_incl = 0
        motivos = {}
        for c in candidatas:
            u = c.get("url")
            if u in vistas:
                err(f"descubrimiento.json: candidata repetida: {u}")
            vistas.add(u)
            if c.get("decision") == "incluida":
                n_incl += 1
                if not claves(c, CAND_INCL, f"descubrimiento.json: incluida {u}"):
                    continue
                if not c["cuelga_de"]:
                    err(f"descubrimiento.json: incluida sin cuelga_de: {u}")
                if not c["interfaz"]:
                    err(f"descubrimiento.json: incluida sin interfaz: {u}")
                if not ambito.dentro(u, c["motivo"] == "semilla"):
                    err(f"descubrimiento.json: incluida fuera del ámbito: {u}")
            elif c.get("decision") == "descartada":
                if not claves(c, CAND_DESC, f"descubrimiento.json: descartada {u}"):
                    continue
                if c["motivo"] not in MOTIVOS_DESCARTE:
                    err(f"descubrimiento.json: motivo de descarte desconocido {c['motivo']!r}: {u}")
                motivos[c["motivo"]] = motivos.get(c["motivo"], 0) + 1
            else:
                err(f"descubrimiento.json: decision inválida en {u}")
        r = desc["resumen"]
        if r.get("candidatas") != len(candidatas) or r.get("incluidas") != n_incl \
                or r.get("descartadas_por_motivo") != dict(sorted(motivos.items())):
            err("descubrimiento.json: resumen no coincide con la lista de candidatas")
        if r.get("semillas") != len(desc["semillas"]):
            err("descubrimiento.json: resumen.semillas no coincide")
        if sem and r.get("semillas") != len(sem["semillas"]):
            err("descubrimiento.json: las semillas no son las de semillas.json")

    # ---- indice.json
    if ind and claves(ind, INDICE_TOP, "indice.json"):
        cabecera(ind, api, "indice.json", esquema)
        ids, urls, cap = set(), set(), 0
        for n, p in enumerate(ind["paginas"], 1):
            if not claves(p, pagina, f"indice.json: página {n}"):
                continue
            donde = f"indice.json: {p['id']}"
            if not ID.match(p["id"]) or int(ID.match(p["id"]).group(1)) != n:
                err(f"{donde}: el id debe ser P-{n:03d}")
            if p["id"] in ids or p["url"] in urls:
                err(f"{donde}: id o url repetidos")
            ids.add(p["id"]), urls.add(p["url"])
            if p["estado"] not in ESTADOS:
                err(f"{donde}: estado inválido {p['estado']!r}")
            if not FECHA.match(str(p["fecha_captura"])):
                err(f"{donde}: fecha_captura no es una fecha UTC")
            if p["estado"] == "capturada":
                cap += 1
                if not HEX64.match(str(p["sha256"])):
                    err(f"{donde}: sha256 inválido")
                if not p["titulo"]:
                    err(f"{donde}: capturada sin título")
                if p["error"] is not None:
                    err(f"{donde}: capturada con error")
                if not p["fichero_texto"]:
                    err(f"{donde}: capturada sin fichero_texto")
                    continue
                f = os.path.join(a.texto, p["fichero_texto"])
                if not os.path.isfile(f):
                    err(f"{donde}: no existe {p['fichero_texto']}")
                elif sha(f) != p["sha256"]:
                    err(f"{donde}: el sha256 no es el del fichero")
                elif os.path.getsize(f) != p["bytes"]:
                    err(f"{donde}: bytes no coincide con el fichero")
                elif not p["fichero_texto"].split("/")[-1].startswith(p["sha256"][:16]):
                    err(f"{donde}: el nombre del fichero no lleva la huella")
                elif esquema != "0.1":
                    with open(f, "rb") as fh:
                        if rec.sha256_texto(fh.read(), p["content_type"] or "") != p["sha256_texto"]:
                            err(f"{donde}: el sha256_texto no es el del texto normalizado del fichero")
            else:
                if p["error"] not in ERRORES and not str(p["error"] or "").startswith(("http_", "red")):
                    err(f"{donde}: fallida con error inválido {p['error']!r}")
                if p["sha256"] or p.get("sha256_texto") or p["fichero_texto"]:
                    err(f"{donde}: fallida con huella o fichero")
        r = ind["resumen"]
        if r.get("incluidas") != len(ind["paginas"]) or r.get("capturadas") != cap \
                or r.get("fallidas") != len(ind["paginas"]) - cap \
                or r.get("con_aviso") != sum(1 for p in ind["paginas"] if p.get("aviso")):
            err("indice.json: resumen no coincide con las páginas")
        incl = {c["url"] for c in candidatas if c.get("decision") == "incluida"}
        if set(urls) != incl:
            falta, sobra = sorted(incl - urls), sorted(urls - incl)
            if falta:
                err(f"indice.json: {len(falta)} incluidas sin fila en el índice, por ejemplo {falta[0]}")
            if sobra:
                err(f"indice.json: {len(sobra)} filas que no son incluidas, por ejemplo {sobra[0]}")
        # las semillas deben aparecer como incluidas
        if sem:
            for s in sem["semillas"]:
                if s["url"] not in incl:
                    err(f"una semilla no llegó a incluida: {s['url']}")

    # ---- el texto no se publica
    texto = os.path.abspath(a.texto)
    if texto == carpeta or texto.startswith(carpeta + os.sep):
        err("el texto en bruto está dentro de la carpeta del índice")
    otros = [f for f in os.listdir(carpeta) if f not in ("semillas.json", "descubrimiento.json", "indice.json", "indice.md")]
    if otros:
        err(f"ficheros que no son del índice en {os.path.basename(carpeta)}: {', '.join(sorted(otros))}")
    if a.incluir:
        rel = ruta_relativa_a_repo(texto)
        if rel is None:
            err("no se pudo situar la carpeta del texto dentro de un repositorio git para mirar incluir.txt")
        else:
            reglas = reglas_incluir(a.incluir)
            for ext in EXTENSIONES:
                ejemplo = f"{rel}/{api}/{'0' * 16}.{ext}"
                ganadora = None
                for mas, patron in reglas:
                    if fnmatch.fnmatchcase(ejemplo, patron):
                        ganadora = mas
                if ganadora:
                    err(f"una regla «+» de incluir.txt cubre el texto en bruto ({rel}/, ficheros .{ext})")
    return salir()


def salir():
    for e in errores:
        print("ERROR:", e)
    if not errores:
        print("ok")
    return 1 if errores else 0


if __name__ == "__main__":
    sys.exit(main())
