#!/usr/bin/env python3
"""Valida el `recogida.yaml` de un proveedor (recogida-terminos-consumo 0.3 a 1.0, esquema 0.3).

Uso, dentro del contenedor (README, «Contenedor»):
    python3 -I validate_result.py CARPETA_PROVEEDOR --texto CARPETA_TEXTO [--incluir incluir.txt]

CARPETA_PROVEEDOR es terminos_bruto/<api>/. CARPETA_TEXTO es la carpeta del texto en
bruto, la que contiene <api>/. Si la carpeta trae los JSON de la 0.1 o la 0.2 y no
`recogida.yaml`, la valida `legacy_validate.py`.

Comprueba cuatro cosas, en este orden:

1. Forma. Claves y orden del esquema, valores permitidos, ids, recuentos de `resumen`,
   que cada semilla llega a incluida y que cada incluida tiene su fila en `extraccion`.
2. Huellas. Cada capturada tiene su fichero de texto, y sha256, bytes y sha256_texto son
   los del fichero.
3. Cobertura y presupuesto. Recalcula, desde los ficheros, cuántas páginas de cada tema se
   capturaron y en cuántas aparece su patrón de evidencia, y comprueba que la evidencia
   anotada está literal en el texto normalizado de su página, en su posición. Comprueba los
   topes de `presupuesto` contra los de recoger.py.
4. Calidad. Recalcula cada medida de la puerta y exige los umbrales de recoger.py, no los
   que diga el fichero.

Comprueba también que el texto no está en la carpeta que se publica: ni dentro de
CARPETA_PROVEEDOR ni bajo una regla «+» de incluir.txt, y que su carpeta lleva un
.gitignore con «*». No juzga si una página merece estar en el conjunto.

Sale con 0 si no hay errores y la puerta de calidad pasa; con 1 si hay errores, uno por
línea; con 2 si no hay errores pero la puerta no pasa o la recogida no llegó a la fase 2.
"""
import argparse
import fnmatch
import hashlib
import importlib.util
import os
import re
import sys

try:
    import yaml
except ImportError:  # pragma: no cover
    sys.exit("hace falta PyYAML: el validador corre en el contenedor del README")

SKILL = "recogida-terminos-consumo"
SCHEMA = "0.3"
VERSION = re.compile(r"^(0\.3|1\.0)(\.\d+)?$")   # 1.0 es la 0.3.1 congelada
AQUI = os.path.dirname(os.path.abspath(__file__))
HEX64 = re.compile(r"^[0-9a-f]{64}$")
FECHA = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
ID = re.compile(r"^P-(\d{3,})$")

TOP = ["schema_version", "generator", "api", "fase", "semillas", "descubrimiento", "extraccion", "cobertura",
       "presupuesto", "calidad", "resumen"]
FASES = ["semillas", "descubrimiento", "extraccion"]
SEMILLAS = ["generated_at", "ficheros_leidos", "incluidas", "descartadas"]
DESC = ["generated_at", "user_agent", "intervalo_s", "ambito", "semillas", "derivadas", "halladas_fuera_ambito",
        "candidatas"]
EXTR = ["generated_at", "user_agent", "intervalo_s", "paginas"]
PAGINA = ["id", "url", "url_final", "titulo", "fecha_captura", "sha256", "sha256_texto", "bytes", "content_type",
          "http", "estado", "error", "aviso", "interfaz", "motivo", "temas", "cuelga_de", "fichero_texto"]
CAND_INCL = ["url", "decision", "motivo", "temas", "via", "interfaz", "cuelga_de"]
CAND_DESC = ["url", "decision", "motivo", "cuelga_de"]
COBERTURA = ["tema", "estado", "paginas", "con_evidencia", "evidencia", "motivo_hueco"]
EVIDENCIA = ["pagina", "termino", "posicion"]
PRESUPUESTO = ["peticiones", "sitemaps", "incluidas"]
MEDIDA = ["id", "valor", "sentido", "umbral", "cumple"]
MOTIVOS_SEMILLA = ["fuera_ambito", "no_pagina", "idioma"]
MOTIVOS_DESCARTE = ["no_pagina", "idioma", "ruido", "novedades", "sin_tema", "tope"]
ERRORES = ["robots", "tipo_no_texto", "redirige_fuera_ambito", "soft_404", "sin_cuerpo", "demasiado_grande",
           "destino_no_publico", "redirige_a_destino_no_publico"]
EXTENSIONES = ["html", "md", "txt"]   # las que da extension() en recoger.py
PUBLICABLES = ["recogida.yaml", "indice.md"]

errores = []


def err(msg):
    errores.append(msg)


def claves(obj, esperadas, donde):
    if not isinstance(obj, dict):
        err(f"{donde}: debe ser un mapa")
        return False
    if list(obj) != esperadas:
        err(f"{donde}: claves {list(obj)}, se esperaba {esperadas}")
        return False
    return True


def lista(obj, donde):
    if not isinstance(obj, list):
        err(f"{donde}: debe ser una lista")
        return []
    return obj


def sha(ruta):
    h = hashlib.sha256()
    with open(ruta, "rb") as f:
        for bloque in iter(lambda: f.read(1 << 20), b""):
            h.update(bloque)
    return h.hexdigest()


def ruta_relativa_a_repo(ruta):
    d = os.path.abspath(ruta)
    while d != "/":
        if os.path.exists(os.path.join(d, ".git")):
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


def cargar_recoger():
    # se carga por ruta, porque `python -I` quita el directorio del script del path
    spec = importlib.util.spec_from_file_location("recoger", os.path.join(AQUI, "recoger.py"))
    rec = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(rec)
    return rec


# ---------------------------------------------------------------- 1. forma

def v_semillas(sem, ambito):
    if not claves(sem, SEMILLAS, "semillas"):
        return []
    if not FECHA.match(str(sem["generated_at"])):
        err("semillas: generated_at no es una fecha UTC")
    incl = lista(sem["incluidas"], "semillas.incluidas")
    urls = [s.get("url") for s in incl if isinstance(s, dict)]
    if len(set(urls)) != len(urls):
        err("semillas: hay semillas repetidas")
    for s in incl:
        if not claves(s, ["url", "citada_en"], "semillas.incluidas"):
            continue
        if not ambito.dentro(s["url"], True):
            err(f"semillas: semilla fuera del ámbito: {s['url']}")
        if not s["citada_en"]:
            err(f"semillas: semilla sin citada_en: {s['url']}")
    for s in lista(sem["descartadas"], "semillas.descartadas"):
        if claves(s, ["url", "motivo", "citada_en"], "semillas.descartadas") and s["motivo"] not in MOTIVOS_SEMILLA:
            err(f"semillas: motivo de descarte desconocido {s['motivo']!r}: {s['url']}")
    return urls


def v_descubrimiento(desc, ambito, semillas):
    if not claves(desc, DESC, "descubrimiento"):
        return []
    if not FECHA.match(str(desc["generated_at"])):
        err("descubrimiento: generated_at no es una fecha UTC")
    if len(lista(desc["semillas"], "descubrimiento.semillas")) != len(semillas):
        err("descubrimiento: las semillas no son las de la sección semillas")
    vistas, incl = set(), []
    for c in lista(desc["candidatas"], "descubrimiento.candidatas"):
        u = c.get("url") if isinstance(c, dict) else None
        if u in vistas:
            err(f"descubrimiento: candidata repetida: {u}")
        vistas.add(u)
        if isinstance(c, dict) and c.get("decision") == "incluida":
            if not claves(c, CAND_INCL, f"descubrimiento: incluida {u}"):
                continue
            incl.append(c)
            if not c["cuelga_de"]:
                err(f"descubrimiento: incluida sin cuelga_de: {u}")
            if not c["interfaz"]:
                err(f"descubrimiento: incluida sin interfaz: {u}")
            if not ambito.dentro(u, c["motivo"] == "semilla"):
                err(f"descubrimiento: incluida fuera del ámbito: {u}")
        elif isinstance(c, dict) and c.get("decision") == "descartada":
            if claves(c, CAND_DESC, f"descubrimiento: descartada {u}") and c["motivo"] not in MOTIVOS_DESCARTE:
                err(f"descubrimiento: motivo de descarte desconocido {c['motivo']!r}: {u}")
        else:
            err(f"descubrimiento: decision inválida en {u}")
    urls_incl = {c["url"] for c in incl}
    for s in semillas:
        if s not in urls_incl:
            err(f"una semilla no llegó a incluida: {s}")
    return incl


def v_extraccion(ext, incl, texto, rec):
    """Filas válidas de páginas y {id: texto normalizado} de las capturadas."""
    if not claves(ext, EXTR, "extraccion"):
        return [], {}
    if not FECHA.match(str(ext["generated_at"])):
        err("extraccion: generated_at no es una fecha UTC")
    filas, textos, ids, urls = [], {}, set(), []
    por_url = {c["url"]: c for c in incl}
    for n, p in enumerate(lista(ext["paginas"], "extraccion.paginas"), 1):
        if not claves(p, PAGINA, f"extraccion: página {n}"):
            continue
        filas.append(p)
        donde = f"extraccion: {p['id']}"
        if not ID.match(str(p["id"])) or int(ID.match(p["id"]).group(1)) != n:
            err(f"{donde}: el id debe ser P-{n:03d}")
        if p["id"] in ids or p["url"] in urls:
            err(f"{donde}: id o url repetidos")
        ids.add(p["id"]), urls.append(p["url"])
        c = por_url.get(p["url"])
        if c and [p[k] for k in ("motivo", "temas", "interfaz", "cuelga_de")] != \
                [c[k] for k in ("motivo", "temas", "interfaz", "cuelga_de")]:
            err(f"{donde}: motivo, temas, interfaz y cuelga_de tienen que ser los de su candidata")
        if not FECHA.match(str(p["fecha_captura"])):
            err(f"{donde}: fecha_captura no es una fecha UTC")
        if p["estado"] == "capturada":
            if not HEX64.match(str(p["sha256"])) or not HEX64.match(str(p["sha256_texto"])):
                err(f"{donde}: huella inválida")
                continue
            if not p["titulo"]:
                err(f"{donde}: capturada sin título")
            if p["error"] is not None:
                err(f"{donde}: capturada con error")
            if not p["fichero_texto"]:
                err(f"{donde}: capturada sin fichero_texto")
                continue
            f = os.path.join(texto, p["fichero_texto"])
            if not os.path.isfile(f):
                err(f"{donde}: no existe {p['fichero_texto']}")
                continue
            if sha(f) != p["sha256"]:
                err(f"{donde}: el sha256 no es el del fichero")
            elif os.path.getsize(f) != p["bytes"]:
                err(f"{donde}: bytes no coincide con el fichero")
            elif not p["fichero_texto"].split("/")[-1].startswith(p["sha256"][:16]):
                err(f"{donde}: el nombre del fichero no lleva la huella")
            with open(f, "rb") as fh:
                textos[p["id"]] = rec.texto_normalizado(fh.read(), p["content_type"] or "")
            if hashlib.sha256(textos[p["id"]].encode("utf-8")).hexdigest() != p["sha256_texto"]:
                err(f"{donde}: el sha256_texto no es el del texto normalizado del fichero")
        elif p["estado"] == "fallida":
            if p["error"] not in ERRORES and not str(p["error"] or "").startswith(("http_", "red")):
                err(f"{donde}: fallida con error inválido {p['error']!r}")
            if p["sha256"] or p["sha256_texto"] or p["fichero_texto"]:
                err(f"{donde}: fallida con huella o fichero")
        else:
            err(f"{donde}: estado inválido {p['estado']!r}")
    esperadas = [c["url"] for c in incl]
    if urls != esperadas:
        falta, sobra = sorted(set(esperadas) - set(urls)), sorted(set(urls) - set(esperadas))
        if falta:
            err(f"extraccion: {len(falta)} incluidas sin fila, por ejemplo {falta[0]}")
        if sobra:
            err(f"extraccion: {len(sobra)} filas que no son incluidas, por ejemplo {sobra[0]}")
        if not falta and not sobra:
            err("extraccion: las filas no van en el orden de las candidatas incluidas")
    return filas, textos


# ---------------------------------------------------------------- 3. cobertura y presupuesto

def v_cobertura(cob, paginas, textos, rec, reglas):
    temas = [t for t, _ in reglas.temas]
    cob = lista(cob, "cobertura")
    if [c.get("tema") if isinstance(c, dict) else None for c in cob] != temas:
        err(f"cobertura: un registro por tema, en el orden de patrones.json: {temas}")
        return
    for c in cob:
        donde = f"cobertura: {c['tema']}"
        if not claves(c, COBERTURA, donde):
            continue
        rx = reglas.evidencia[c["tema"]]
        con_tema = [p for p in paginas if c["tema"] in p["temas"]]
        capt = [p for p in con_tema if p["estado"] == "capturada" and p["id"] in textos]
        con_ev = [p for p in capt if rec.evidencia_en(textos[p["id"]], rx)]
        if c["paginas"] != len(capt):
            err(f"{donde}: paginas es {c['paginas']}, se capturaron {len(capt)} con ese tema")
        if c["con_evidencia"] != len(con_ev):
            err(f"{donde}: con_evidencia es {c['con_evidencia']}, el patrón aparece en {len(con_ev)}")
        estado = "con_evidencia" if con_ev else "solo_ruta" if capt else "hueco"
        if c["estado"] != estado:
            err(f"{donde}: estado {c['estado']!r}, le toca {estado!r}")
        hueco = None if capt else "ninguna_capturada" if con_tema else "ninguna_incluida"
        if c["motivo_hueco"] != hueco:
            err(f"{donde}: motivo_hueco {c['motivo_hueco']!r}, le toca {hueco!r}")
        ev = c["evidencia"]
        if not con_ev:
            if ev is not None:
                err(f"{donde}: evidencia sin páginas que la tengan")
            continue
        if not claves(ev, EVIDENCIA, f"{donde}: evidencia"):
            continue
        if ev["pagina"] != con_ev[0]["id"]:
            err(f"{donde}: la evidencia es de la primera página con el patrón, {con_ev[0]['id']}")
            continue
        t, pos = ev["termino"], ev["posicion"]
        if not isinstance(t, str) or not isinstance(pos, int) or not 0 < len(t) <= rec.TERMINO_MAXIMO:
            err(f"{donde}: término o posición inválidos (el término tiene de 1 a {rec.TERMINO_MAXIMO} caracteres)")
        elif textos[ev["pagina"]][pos:pos + len(t)] != t:
            err(f"{donde}: el término no está literal en {ev['pagina']}, posición {pos}")
        elif not rx.fullmatch(t):
            err(f"{donde}: el término no casa entero con el patrón de evidencia del tema")
        elif (t, pos) != rec.evidencia_en(textos[ev["pagina"]], rx):
            err(f"{donde}: la evidencia es la primera coincidencia de la página")


def v_presupuesto(pres, desc, fase, rec):
    if not claves(pres, PRESUPUESTO, "presupuesto"):
        return
    pet = pres["peticiones"]
    if claves(pet, ["descubrir", "extraer"], "presupuesto.peticiones"):
        if not isinstance(pet["descubrir"], int) or pet["descubrir"] < 0:
            err("presupuesto: peticiones.descubrir debe ser un entero")
        if fase == "extraccion" and (not isinstance(pet["extraer"], int) or pet["extraer"] < 0):
            err("presupuesto: peticiones.extraer debe ser un entero")
        if fase != "extraccion" and pet["extraer"] is not None:
            err("presupuesto: peticiones.extraer sin fase 2")
    sm = pres["sitemaps"]
    if claves(sm, ["abiertos", "tope", "sin_abrir", "tope_alcanzado"], "presupuesto.sitemaps"):
        if sm["tope"] != rec.TOPE_SITEMAPS:
            err(f"presupuesto: el tope de sitemaps es {rec.TOPE_SITEMAPS}")
        if sm["abiertos"] != len(desc["derivadas"]["sitemaps"]) or sm["abiertos"] > rec.TOPE_SITEMAPS:
            err("presupuesto: sitemaps.abiertos no son los de derivadas.sitemaps")
        if not isinstance(sm["sin_abrir"], int) or sm["sin_abrir"] < 0:
            err("presupuesto: sitemaps.sin_abrir debe ser un entero")
        elif sm["tope_alcanzado"] != (sm["sin_abrir"] > 0):
            err("presupuesto: sitemaps.tope_alcanzado debe decir si quedaron sin abrir")
    inc = pres["incluidas"]
    if claves(inc, ["halladas", "tope", "fuera_por_tope", "tope_alcanzado"], "presupuesto.incluidas"):
        n_tope = sum(1 for c in desc["candidatas"] if c.get("motivo") == "tope")
        n_incl = sum(1 for c in desc["candidatas"] if c.get("decision") == "incluida")
        if inc["tope"] != rec.TOPE_INCLUIDAS:
            err(f"presupuesto: el tope de incluidas es {rec.TOPE_INCLUIDAS}")
        if inc["fuera_por_tope"] != n_tope or inc["halladas"] != n_incl + n_tope:
            err("presupuesto: incluidas no coincide con las candidatas")
        if inc["tope_alcanzado"] != (n_tope > 0) or n_incl > rec.TOPE_INCLUIDAS:
            err("presupuesto: incluidas.tope_alcanzado no coincide con las descartadas por tope")


# ---------------------------------------------------------------- 4. calidad

def v_calidad(cal, doc, rec):
    """True si la puerta pasa."""
    if not claves(cal, ["medidas", "pasa"], "calidad"):
        return False
    medidas = lista(cal["medidas"], "calidad.medidas")
    if [m.get("id") if isinstance(m, dict) else None for m in medidas] != list(rec.UMBRALES):
        err(f"calidad: una medida por umbral, en este orden: {list(rec.UMBRALES)}")
        return False
    valores = rec.medidas_calidad(doc)
    pasa = True
    for m in medidas:
        if not claves(m, MEDIDA, f"calidad: {m['id']}"):
            return False
        sentido, umbral = rec.UMBRALES[m["id"]]
        if (m["sentido"], m["umbral"]) != (sentido, umbral):
            err(f"calidad: {m['id']}: el umbral es {sentido} {umbral}, el de recoger.py")
        if m["valor"] != valores[m["id"]]:
            err(f"calidad: {m['id']}: valor {m['valor']}, recalculado {valores[m['id']]}")
        ok = rec.cumple(sentido, valores[m["id"]], umbral)
        if m["cumple"] != ok:
            err(f"calidad: {m['id']}: cumple debe ser {ok}")
        pasa = pasa and ok
    if cal["pasa"] != pasa:
        err(f"calidad: pasa debe ser {pasa}")
    return pasa


# ---------------------------------------------------------------- texto no publicado

def v_texto_fuera(carpeta, texto, api, incluir):
    if texto == carpeta or texto.startswith(carpeta + os.sep):
        err("el texto en bruto está dentro de la carpeta del índice")
    otros = sorted(f for f in os.listdir(carpeta) if f not in PUBLICABLES)
    if otros:
        err(f"ficheros que no son del índice en {os.path.basename(carpeta)}: {', '.join(otros)}")
    guarda = os.path.join(texto, ".gitignore")
    if not os.path.isfile(guarda) or "*" not in open(guarda, encoding="utf-8").read().split():
        err("la carpeta del texto no lleva un .gitignore con «*»")
    if incluir:
        rel = ruta_relativa_a_repo(texto)
        if rel is None:
            err("no se pudo situar la carpeta del texto dentro de un repositorio git para mirar incluir.txt")
            return
        reglas = reglas_incluir(incluir)
        for ext in EXTENSIONES:
            ejemplo = f"{rel}/{api}/{'0' * 16}.{ext}"
            ganadora = None
            for mas, patron in reglas:
                if fnmatch.fnmatchcase(ejemplo, patron):
                    ganadora = mas
            if ganadora:
                err(f"una regla «+» de incluir.txt cubre el texto en bruto ({rel}/, ficheros .{ext})")


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("carpeta")
    ap.add_argument("--texto", required=True)
    ap.add_argument("--incluir")
    a = ap.parse_args(argv)
    errores.clear()   # main se puede llamar varias veces en el mismo proceso
    carpeta, texto = os.path.abspath(a.carpeta), os.path.abspath(a.texto)
    api = os.path.basename(carpeta.rstrip("/"))
    if not os.path.isdir(carpeta):
        err(f"{carpeta}: no es una carpeta")
        return salir(False, "")
    ruta = os.path.join(carpeta, "recogida.yaml")
    if not os.path.exists(ruta) and os.path.exists(os.path.join(carpeta, "semillas.json")):
        spec = importlib.util.spec_from_file_location("legacy_validate", os.path.join(AQUI, "legacy_validate.py"))
        legacy = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(legacy)
        return legacy.main(argv)

    rec = cargar_recoger()
    reglas = rec.Reglas()
    prov = rec.cargar("proveedores.json")["proveedores"].get(api)
    if prov is None:
        err(f"{api}: no está en references/proveedores.json")
        return salir(False, "")
    ambito = rec.Ambito(prov["ambito"], prov["excluir"])
    try:
        with open(ruta, encoding="utf-8") as f:
            doc = yaml.safe_load(f)
    except FileNotFoundError:
        err("recogida.yaml: no existe")
        return salir(False, "")
    except yaml.YAMLError as e:
        err(f"recogida.yaml: YAML mal formado ({e})")
        return salir(False, "")

    pasa, motivo = False, ""
    if claves(doc, TOP, "recogida.yaml"):
        if doc["schema_version"] != SCHEMA:
            err(f"schema_version debe ser {SCHEMA!r}")
        g = doc["generator"]
        if not (isinstance(g, dict) and g.get("skill") == SKILL and VERSION.match(str(g.get("skill_version", "")))):
            err("generator inválido")
        if doc["api"] != api:
            err(f"api es {doc['api']!r}, la carpeta es {api!r}")
        fase = doc["fase"]
        if fase not in FASES:
            err(f"fase inválida {fase!r}")
            return salir(False, "")
        hecho = FASES.index(fase)
        for k, n in (("descubrimiento", 1), ("presupuesto", 1), ("extraccion", 2), ("cobertura", 2), ("calidad", 2)):
            if (doc[k] is None) != (hecho < n):
                err(f"{k}: {'falta' if doc[k] is None else 'sobra'} con la fase {fase!r}")
        if errores:
            return salir(False, "")
        semillas = v_semillas(doc["semillas"], ambito)
        if hecho >= 1:
            incl = v_descubrimiento(doc["descubrimiento"], ambito, semillas)
            if not errores:
                v_presupuesto(doc["presupuesto"], doc["descubrimiento"], fase, rec)
        if hecho == 2:
            paginas, textos = v_extraccion(doc["extraccion"], incl, texto, rec)
            if not errores:
                v_cobertura(doc["cobertura"], paginas, textos, rec, reglas)
            if not errores:
                pasa = v_calidad(doc["calidad"], doc, rec)
                if not pasa:
                    motivo = "la puerta de calidad no pasa: " + ", ".join(
                        m["id"] for m in doc["calidad"]["medidas"] if not m["cumple"])
            if not os.path.isfile(os.path.join(carpeta, "indice.md")):
                err("falta indice.md")
        else:
            motivo = f"la recogida se quedó en la fase {fase!r}: no hay puerta de calidad"
        if not errores and doc["resumen"] != rec.resumen(doc):
            err("resumen no coincide con las listas")
    v_texto_fuera(carpeta, texto, api, a.incluir)
    return salir(pasa, motivo)


def salir(pasa, motivo):
    for e in errores:
        print("ERROR:", e)
    if errores:
        return 1
    if not pasa:
        print("NO PASA:", motivo)
        return 2
    print("ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
