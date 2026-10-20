#!/usr/bin/env python3
"""
Sondeo de Amazon SES — escalón 3. Unidad de la cuota, nombre del error de caudal y
qué consume un intento rechazado.

PRESUPUESTO DECLARADO (D-046, condición 2): **2 envíos**, los dos a la dirección
verificada de la lista blanca. Todo lo demás es de coste cero: lecturas de
`GET /v2/email/account` y dos intentos contra un destinatario que el proveedor rechaza.

QUÉ PREGUNTAS RESUELVE
----------------------
  DISC-02  la unidad de la cuota: ¿correos o destinatarios? La misma tabla de AWS sostiene
           las dos lecturas. Se decide con dos envíos y tres lecturas del contador: el
           primero lleva un destinatario, el segundo lleva la misma dirección en `to` y en
           `cc`. Si el contador sube 2 con el segundo, la cuota cuenta destinatarios.
  DISC-07  el nombre del error de caudal en la v2: `ThrottlingException` según la página
           monográfica, `TooManyRequestsException` según la referencia de la operación, y
           la primera forma **no existe** en el contrato máquina.
  DISC-08  su código HTTP: 400 en un blog de 2012, 429 en la referencia.
  DISC-14  qué significa `MessageRejected`: ¿contenido inválido, o también identidad no
           verificada?
  F-21     si un intento que no entrega nada consume cuota igualmente. Es la fricción que
           MailerSend levantó y que aquí puede recurrir.

POR QUÉ ES PYTHON Y NO UN `probe_*.sh`
--------------------------------------
SES no admite una clave en una cabecera: cada petición va firmada con SigV4, que es una
cadena de HMAC sobre la petición canónica. En bash eso serían tres utilidades más; aquí
sale entero de `hmac` y `hashlib`, que son de la biblioteca estándar. El resto del
patrón se respeta: el `.env` se **lee** como dato y no se sourcea, la lista blanca la
decide `lib_lista_blanca.py`, y nada se imprime sin redactar.

USO
---
    python3 -I 05_salida/_herramientas/probe_ses_cuota_caudal.py \\
            03_datos/apis/ses/evidencias/

`-I` ignora `PYTHONPATH` y el `site` del usuario, que es lo mismo que hacen los sondeos
de Brevo al invocar intérpretes.
"""
import sys, os, json, time, hmac, hashlib, datetime, subprocess, urllib.request, urllib.error

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
GUARDA = os.path.join(RAIZ, "05_salida", "_herramientas", "lib_lista_blanca.py")

# El destinatario verificado de la cuenta, que además está en la lista blanca de D-046.
# Se escribe literal: una dirección que venga del entorno no es una guarda, es una sugerencia.
DESTINO = "persona-3@example.invalid"

# Destinatario que el proveedor rechaza antes de entregar. Dominio reservado por la RFC 2606,
# así que no existe y no puede llegarle a nadie. Es la vía preferente de D-046.
DESTINO_RECHAZO = "sondeo@example.invalid"

ENVIOS_PRESUPUESTADOS = 2
NOMBRES_ENV = ("SES_ACCESS_KEY_ID", "SES_SECRET_ACCESS_KEY", "SES_REGION", "SES_FROM")


# ─────────────────────────────────────────────────────────────────────────────
# Credenciales: el .env se LEE, no se sourcea (docs/08-mandato.md, patrón de Brevo)
# ─────────────────────────────────────────────────────────────────────────────
def carga_env(ruta=None):
    ruta = ruta or os.path.expanduser("~/.config/tfm/.env")
    valores = {n: "" for n in NOMBRES_ENV}
    with open(ruta, encoding="utf-8") as fh:
        for linea in fh:
            linea = linea.rstrip("\r\n").strip()
            if linea.startswith("#") or "=" not in linea:
                continue
            if linea.startswith("export "):
                linea = linea[len("export "):].strip()
            nombre, _, valor = linea.partition("=")
            nombre = nombre.strip()
            if nombre not in valores:
                continue
            valor = valor.strip()
            if len(valor) >= 2 and valor[0] == valor[-1] and valor[0] in "\"'":
                valor = valor[1:-1]
            valores[nombre] = valor
    return valores


def exige_destinatario(direccion):
    """Condición 1 de D-046: la guarda decide, y se manda SU salida, nunca la entrada."""
    r = subprocess.run([sys.executable, "-I", GUARDA, "check", direccion],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print(f"ABORTA: la guarda de lista blanca rechaza el destinatario: {r.stderr.strip()}",
              file=sys.stderr)
        sys.exit(2)
    return r.stdout.strip()


# ─────────────────────────────────────────────────────────────────────────────
# SigV4
# ─────────────────────────────────────────────────────────────────────────────
def _hmac(clave, mensaje):
    return hmac.new(clave, mensaje.encode("utf-8"), hashlib.sha256).digest()


def firma(metodo, host, region, ruta, cuerpo, access_key, secret_key, servicio="ses"):
    ahora = datetime.datetime.now(datetime.timezone.utc)
    amzdate = ahora.strftime("%Y%m%dT%H%M%SZ")
    datestamp = ahora.strftime("%Y%m%d")
    payload_hash = hashlib.sha256(cuerpo.encode("utf-8")).hexdigest()

    headers_canon = f"content-type:application/json\nhost:{host}\nx-amz-date:{amzdate}\n"
    firmados = "content-type;host;x-amz-date"
    peticion_canon = f"{metodo}\n{ruta}\n\n{headers_canon}\n{firmados}\n{payload_hash}"

    scope = f"{datestamp}/{region}/{servicio}/aws4_request"
    a_firmar = ("AWS4-HMAC-SHA256\n" + amzdate + "\n" + scope + "\n"
                + hashlib.sha256(peticion_canon.encode("utf-8")).hexdigest())

    k = _hmac(("AWS4" + secret_key).encode("utf-8"), datestamp)
    k = _hmac(k, region)
    k = _hmac(k, servicio)
    k = _hmac(k, "aws4_request")
    sig = hmac.new(k, a_firmar.encode("utf-8"), hashlib.sha256).hexdigest()

    return {
        "Content-Type": "application/json",
        "X-Amz-Date": amzdate,
        "Authorization": (f"AWS4-HMAC-SHA256 Credential={access_key}/{scope}, "
                          f"SignedHeaders={firmados}, Signature={sig}"),
    }


def llama(metodo, ruta, cuerpo_obj, env):
    host = f"email.{env['SES_REGION']}.amazonaws.com"
    cuerpo = json.dumps(cuerpo_obj) if cuerpo_obj is not None else ""
    cabeceras = firma(metodo, host, env["SES_REGION"], ruta, cuerpo,
                      env["SES_ACCESS_KEY_ID"], env["SES_SECRET_ACCESS_KEY"])
    req = urllib.request.Request(f"https://{host}{ruta}", method=metodo,
                                 data=cuerpo.encode("utf-8") if cuerpo else None,
                                 headers=cabeceras)
    t0 = time.time()
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return {"http": r.status, "ms": int((time.time() - t0) * 1000),
                    "cabeceras": {k.lower(): v for k, v in r.headers.items()},
                    "cuerpo": _json_o_texto(r.read())}
    except urllib.error.HTTPError as e:
        return {"http": e.code, "ms": int((time.time() - t0) * 1000),
                "cabeceras": {k.lower(): v for k, v in e.headers.items()},
                "cuerpo": _json_o_texto(e.read())}


def _json_o_texto(bruto):
    texto = bruto.decode("utf-8", "replace")
    try:
        return json.loads(texto)
    except ValueError:
        return {"_texto": texto}


# ─────────────────────────────────────────────────────────────────────────────
# El sondeo
# ─────────────────────────────────────────────────────────────────────────────
def cuerpo_envio(remitente, destinatarios_to, destinatarios_cc, asunto):
    destino = {"ToAddresses": destinatarios_to}
    if destinatarios_cc:
        destino["CcAddresses"] = destinatarios_cc
    return {
        "FromEmailAddress": remitente,
        "Destination": destino,
        "Content": {"Simple": {
            "Subject": {"Data": asunto, "Charset": "UTF-8"},
            "Body": {"Text": {"Data": "Sondeo del catalogo de Datasheets del TFM. "
                                      "Sin contenido; mide el contador de la cuenta.",
                              "Charset": "UTF-8"}},
        }},
    }


def contador(env):
    r = llama("GET", "/v2/email/account", None, env)
    c = r["cuerpo"].get("SendQuota", {}) if isinstance(r["cuerpo"], dict) else {}
    return r, c


def redacta(obj, direcciones):
    """
    Deja el volcado publicable. Dos cosas, y la segunda se descubrió midiendo: además de
    las direcciones, AWS devuelve el **número de cuenta** de doce dígitos dentro de cada
    ARN de sus mensajes de error, y el ARN del usuario IAM con su nombre. Ninguna de las
    dos es un secreto que abra la cuenta, pero identifican al titular y el TFM publica
    estas evidencias.
    """
    import re as _re
    texto = json.dumps(obj, ensure_ascii=False)
    for i, d in enumerate(direcciones):
        if d:
            texto = texto.replace(d, f"<direccion-{i + 1}-redactada>")
            texto = texto.replace(d.split("@")[1], "<dominio-redactado>")
    # Número de cuenta de AWS: doce dígitos seguidos, aparezcan donde aparezcan.
    texto = _re.sub(r"\b\d{12}\b", "<cuenta-aws-redactada>", texto)
    # Nombre del usuario o rol de IAM dentro del ARN.
    texto = _re.sub(r"(arn:aws:iam::[^:]*:(?:user|role)/)[^'\"\\\\ ]+",
                    r"\1<principal-redactado>", texto)
    return json.loads(texto)


def main():
    salida_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    env = carga_env()
    faltan = [n for n in ("SES_ACCESS_KEY_ID", "SES_SECRET_ACCESS_KEY", "SES_REGION")
              if not env.get(n)]
    if faltan:
        print(f"ABORTA: faltan credenciales en el .env: {', '.join(faltan)}", file=sys.stderr)
        sys.exit(3)

    # La región entra en el host y en el ámbito de la firma. Un carácter de más la convierte
    # en un host que no resuelve, y el fallo llega como `Name or service not known`, que no
    # apunta al .env. Pasó el 2026-09-18: el fichero tenía `eu-west-1` con un punto medio
    # pegado detrás. Se comprueba la forma antes de firmar nada.
    region = env["SES_REGION"]
    if not all(c.isascii() and (c.isalnum() or c == "-") for c in region):
        raros = [f"U+{ord(c):04X}" for c in region if not (c.isascii() and (c.isalnum() or c == "-"))]
        print(f"ABORTA: SES_REGION tiene caracteres que no son de una región de AWS "
              f"({', '.join(raros)}). Corrige ~/.config/tfm/.env.", file=sys.stderr)
        sys.exit(3)

    destino = exige_destinatario(DESTINO)
    remitente = env.get("SES_FROM") or destino

    print(f"PRESUPUESTO: {ENVIOS_PRESUPUESTADOS} envíos reales, ambos a la dirección "
          f"verificada de la lista blanca. Los cuatro intentos restantes son de coste cero.")
    print(f"Región: {env['SES_REGION']}\n")

    pasos = []

    def paso(nombre, pregunta, r):
        pasos.append({"paso": nombre, "pregunta": pregunta, "respuesta": r})
        cuerpo = r.get("cuerpo", {})
        err = cuerpo.get("message") or cuerpo.get("Message") or ""
        tipo = (r.get("cabeceras", {}).get("x-amzn-errortype", "") or "").split(":")[0]
        print(f"  [{r['http']:3d}] {nombre:38s} {tipo:28s} {str(err)[:70]}")
        return r

    # 1 · contador de partida (coste 0)
    r0, c0 = contador(env)
    paso("account.antes", "estado de partida del contador", r0)
    print(f"        SendQuota de partida: {json.dumps(c0)}\n")

    # 2 · caudal a coste cero: dos intentos seguidos contra un destinatario que no existe
    print("  -- caudal, coste cero: dos intentos seguidos a un dominio reservado --")
    cuerpo_rechazo = cuerpo_envio(remitente, [DESTINO_RECHAZO], None, "Sondeo TFM · rechazo")
    for i in (1, 2):
        paso(f"rechazo.{i}", "DISC-07/08/14: nombre y código del error",
             llama("POST", "/v2/email/outbound-emails", cuerpo_rechazo, env))

    r1, c1 = contador(env)
    paso("account.tras_rechazos", "F-21: ¿un intento rechazado consume cuota?", r1)
    print(f"        SendQuota tras los rechazos: {json.dumps(c1)}\n")

    # 3 · envío A: un destinatario (coste 1)
    print("  -- unidad de la cuota: envío A, un destinatario --")
    paso("envio_A", "DISC-02: un destinatario",
         llama("POST", "/v2/email/outbound-emails",
               cuerpo_envio(remitente, [destino], None, "Sondeo TFM · A, 1 destinatario"), env))
    time.sleep(4)
    r2, c2 = contador(env)
    paso("account.tras_A", "contador tras el envío A", r2)
    print(f"        SendQuota tras A: {json.dumps(c2)}\n")

    # 4 · envío B: la misma dirección en to y en cc (coste 1)
    print("  -- unidad de la cuota: envío B, la misma dirección en to y en cc --")
    paso("envio_B", "DISC-02: dos destinatarios en un mensaje",
         llama("POST", "/v2/email/outbound-emails",
               cuerpo_envio(remitente, [destino], [destino],
                            "Sondeo TFM · B, 2 destinatarios"), env))
    time.sleep(4)
    r3, c3 = contador(env)
    paso("account.tras_B", "contador tras el envío B", r3)
    print(f"        SendQuota tras B: {json.dumps(c3)}\n")

    def sent(c):
        return c.get("SentLast24Hours")

    lectura = {
        "contador_partida": sent(c0),
        "contador_tras_rechazos": sent(c1),
        "contador_tras_A": sent(c2),
        "contador_tras_B": sent(c3),
        "delta_rechazos": _delta(sent(c0), sent(c1)),
        "delta_A": _delta(sent(c1), sent(c2)),
        "delta_B": _delta(sent(c2), sent(c3)),
    }
    print("LECTURA")
    for k, v in lectura.items():
        print(f"  {k:26s} {v}")
    print()
    d = lectura["delta_B"]
    if d == 2:
        print("  → la cuota cuenta DESTINATARIOS: el mensaje B subió el contador en 2.")
    elif d == 1:
        print("  → el contador subió 1 con dos destinatarios. NO cierra DISC-02: puede ser")
        print("    que la cuota cuente mensajes, o que el proveedor deduplique la dirección")
        print("    repetida. Queda ACOTADA, no cerrada.")
    else:
        print(f"  → delta inesperado ({d}). Se registra tal cual y no se interpreta.")

    sello = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d_%H%M%S")
    destino_fichero = os.path.join(
        salida_dir, f"probe_ses_cuota_caudal_{sello}.json")
    os.makedirs(salida_dir, exist_ok=True)
    informe = redacta({
        "sondeo": "ses_cuota_caudal",
        "fecha_utc": sello,
        "region": env["SES_REGION"],
        "presupuesto_envios": ENVIOS_PRESUPUESTADOS,
        "envios_gastados": 2,
        "lectura": lectura,
        "pasos": pasos,
    }, [destino, remitente])
    with open(destino_fichero, "w", encoding="utf-8") as fh:
        json.dump(informe, fh, ensure_ascii=False, indent=2)
    print(f"\nEvidencia en {destino_fichero}")


def _delta(a, b):
    if a is None or b is None:
        return None
    return b - a


if __name__ == "__main__":
    main()
