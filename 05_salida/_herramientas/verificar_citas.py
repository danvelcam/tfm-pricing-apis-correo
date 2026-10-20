# -*- coding: utf-8 -*-
"""
Verificador de citas: comprueba que cada cita literal del `data_provenance` de una
datasheet sigue existiendo en el volcado actual de la pagina que la respalda.

Es el escalon 1 (contraste documental) hecho mecanico. El volcado de cada pagina lo
guarda el agente con el navegador en `evidencias/paginas/<fecha>/<nombre>.txt`
(get_page_text), y este script hace el resto sin red. El volcado es recomendado, no
exigido (D-023): sin el, la cita no se comprueba y sale SIN-PAG, que es informativo.

Uso:
  python3 verificar_citas.py <datasheet.yaml> <carpeta de volcados> [--umbral 0.92]

Salida: una linea por cita con veredicto:
  OK        la cita esta literal (o casi: ratio >= umbral tras normalizar)
  CAMBIO    la pagina existe pero la cita ya no aparece  -> revisar el dato (F-09)
  SIN-PAG   no hay volcado para esa URL                   -> informativo (D-023), no bloquea
  SIN-CITA  la linea de provenance no lleva cita entre comillas simples -> no verificable
"""
import io, os, re, sys, unicodedata, difflib
import yaml

def norm(t):
    t = unicodedata.normalize("NFKC", t).lower()
    t = t.replace("’", "'").replace("‘", "'").replace("“", '"').replace("”", '"')
    # Frontera de celda: la vista markdown de una tabla la marca con `|` y la
    # renderizada con espacio. Es la misma tabla en dos serializaciones, y las
    # citas de una datasheet se tomaron de ambas. Se unifica a espacio.
    t = t.replace("|", " ")
    t = re.sub(r"[\s ]+", " ", t)
    # Espacio pegado a la puntuacion: es serializacion, no contenido. Un conversor
    # HTML->texto separa en cada frontera de etiqueta, asi que `</strong>:` sale
    # como `) :` donde el navegador muestra `):`. Misma familia que colapsar los
    # espacios de la linea anterior: un cambio de pagina que solo quite ese espacio
    # no es informacion, y su F-09 seria falso.
    t = re.sub(r" +([:;,.!?%)\]])", r"\1", t)
    t = re.sub(r"([(\[]) +", r"\1", t)
    return t.strip()

def url_a_nombre(u):
    u = re.sub(r"^https?://", "", u).rstrip("/")
    return re.sub(r"[^A-Za-z0-9]+", "_", u).strip("_")[:120]

# Una linea de provenance con las DOS fechas anotadas ya cumple E3 y E8: la cita no cae,
# se queda con su segunda fecha y el desajuste ES la evidencia de F-09. El checklist de
# cierre pide "0 CAMBIO sin fecha", no "0 CAMBIO", asi que el verificador tiene que saber
# distinguirlos. Sin esto el punto 3 es imposible de cumplir en cuanto exista un F-09 de
# verdad, y la unica salida seria borrar la cita vieja, que es lo contrario de E8.
RELECTURA = re.compile(r"REL[EE\u00c9][II\u00cd]D[AO]S?\s+el\s+\d{4}-\d{2}-\d{2}", re.I)

def es_apostrofo(linea, i):
    """Una comilla simple entre dos letras es un apostrofo ingles (Postmark's),
    no un delimitador de cita."""
    return (i > 0 and linea[i - 1].isalpha()
            and i + 1 < len(linea) and linea[i + 1].isalpha())

def extraer_citas(linea, minimo=12):
    """Citas de una linea de provenance, emparejando comillas EN FASE.

    El patron `'([^']{12,})'` no vale: al saltarse un entrecomillado mas corto que
    el minimo, el escaneo aterriza sobre su comilla de cierre y la toma por una de
    apertura. Desde ahi la linea entera se lee en antifase, la prosa castellana que
    separa dos citas pasa por cita y las citas de verdad quedan sin comprobar. Caso:
    la linea 06 de Brevo, con catorce precios de 7-9 caracteres, devolvia
    ' sobre las marcas ' y ocultaba la tira de marcas que si era la cita.

    Aqui se listan todas las comillas delimitadoras, se emparejan 1-2, 3-4... y se
    devuelven las de al menos `minimo` caracteres. Las cortas se descartan sin
    mover la fase.
    """
    pos = [i for i, c in enumerate(linea) if c == "'" and not es_apostrofo(linea, i)]
    if len(pos) % 2:
        # Comillas desparejadas: emparejar seria inventarse donde acaba cada cita.
        return None
    return [t for t in (linea[a + 1:b] for a, b in zip(pos[::2], pos[1::2]))
            if len(t) >= minimo]

def mejor_ratio(cita, texto):
    c = norm(cita)
    if c in texto:
        return 1.0
    # Ventana deslizante del tamano de la cita. El paso era n//2, y con ese salto una
    # cita larga que esta en la pagina con una diferencia minima puede caer siempre a
    # caballo entre dos ventanas y puntuar bajo: la ausencia medida era del escaner, no
    # de la pagina. Con n//4 el peor desalineamiento se parte por la mitad.
    n = len(c); mejor = 0.0
    if n == 0 or n > len(texto):
        return 0.0
    paso = max(1, n // 4)
    for i in range(0, len(texto) - n + 1, paso):
        r = difflib.SequenceMatcher(None, c, texto[i:i + n + 20]).ratio()
        if r > mejor:
            mejor = r
            if mejor >= 0.995:
                break
    return mejor

def main():
    ds, carpeta = sys.argv[1], sys.argv[2]
    umbral = float(sys.argv[sys.argv.index("--umbral") + 1]) if "--umbral" in sys.argv else 0.92
    d = yaml.safe_load(io.open(ds, encoding="utf-8"))
    lineas = (d.get("metadata") or {}).get("data_provenance") or []
    paginas = {}
    if not os.path.isdir(carpeta):
        # Sin carpeta de volcados no hay nada que contrastar: todas las citas saldran
        # SIN-PAG, que es informativo (D-023). No es un error.
        print("Aviso: no existe la carpeta de volcados %s; todas las citas saldran SIN-PAG (informativo, D-023)." % carpeta)
    else:
        for f in os.listdir(carpeta):
            if f.endswith(".txt"):
                paginas[f[:-4]] = norm(io.open(os.path.join(carpeta, f), encoding="utf-8", errors="ignore").read())
    res = {"OK": 0, "CAMBIO": 0, "F-09": 0, "SIN-PAG": 0, "SIN-CITA": 0}
    for k, linea in enumerate(lineas, 1):
        if linea.startswith("NOTA"):
            continue
        urls = re.findall(r"https?://[^\s\]\,]+", linea)
        citas = extraer_citas(linea)
        if citas is None:
            res["SIN-CITA"] += 1
            print("%-8s #%02d  (comillas desparejadas)  %s" % ("SIN-CITA", k, linea[:80]))
            continue
        if not citas:
            res["SIN-CITA"] += 1
            print("%-8s #%02d  (sin cita literal)  %s" % ("SIN-CITA", k, linea[:90]))
            continue
        for cita in citas:
            vered, detalle = "SIN-PAG", ""
            for u in urls:
                nombre = url_a_nombre(u)
                # Volcado de ESTA pagina, o variante suya con sufijo (p. ej. ..._html).
                propios = [p for p in paginas if p.startswith(nombre)]
                # Volcado de una pagina PADRE (la URL citada es una subruta suya). Sirve para
                # CONFIRMAR una cita -si el texto esta ahi, esta-, pero no para desmentirla: que
                # la cita de /a/b no aparezca en el volcado de /a no dice nada de /a/b.
                padres = [p for p in paginas if nombre.startswith(p) and p not in propios]
                cand = propios + padres
                if not cand:
                    continue
                r = max(mejor_ratio(cita, paginas[p]) for p in cand)
                if r >= umbral:
                    vered, detalle = "OK", "%.2f" % r
                    break
                # Sin volcado propio, la ausencia no prueba que la pagina haya cambiado: SIN-PAG.
                if propios:
                    vered, detalle = "CAMBIO", "%.2f" % r
                elif vered != "CAMBIO":
                    vered, detalle = "SIN-PAG", "%.2f" % r
            # CAMBIO con las dos fechas anotadas en la linea: es F-09 documentado (E3,
            # E8) y no bloquea el cierre. Se marca por LINEA, no por cita: la anotacion
            # describe la relectura de esa fuente, y si una linea lleva varias citas se
            # relee entera. Queda escrito por si algun dia hace falta afinarlo.
            if vered == "CAMBIO" and RELECTURA.search(linea):
                vered = "F-09"
            res[vered] += 1
            print("%-8s #%02d  %s  «%s»" % (vered, k, detalle.ljust(4), cita[:80]))
    print()
    print("Resumen: " + " · ".join("%s %d" % kv for kv in res.items()))
    if res["CAMBIO"]:
        print("Hay citas que ya no estan en la pagina y NO llevan fecha: bloquean el cierre.")
        print("Se resuelven anotando en su linea de provenance la relectura y su fecha")
        print("(«RELEIDA el AAAA-MM-DD»), que es lo que piden E3 y E8. La cita vieja NO se borra.")
    if res["F-09"]:
        print("F-09 es un CAMBIO con las dos fechas anotadas (E3, E8): documentado, no bloquea.")
    if res["SIN-PAG"]:
        print("SIN-PAG es informativo (D-023): sin volcado la cita no se comprueba; no bloquea el cierre.")

if __name__ == "__main__":
    main()
