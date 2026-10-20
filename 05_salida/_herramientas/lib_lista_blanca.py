#!/usr/bin/env python3
"""Guarda de lista blanca de destinatarios para los sondeos del escalón 3 (D-046).

`docs/08-mandato.md`, «Envíos de correo en los sondeos», condición 1: la comprobación
del destinatario vive **en el script** y corre antes de la primera llamada, porque *"no
vale confiar en el modo de la cuenta"*. Brevo no es sandbox: entrega a donde se le diga.

La lista está escrita literal aquí abajo y no se lee del entorno. Una lista que se puede
cambiar con una variable de entorno no es una guarda, es una sugerencia.

El buzón que obliga a comparar por dirección y no por dominio es `alum.us.es`: es el
dominio de alumnado de la Universidad de Sevilla y acepta cualquier nombre, así que una
dirección inventada ahí no rebota, **llega a un desconocido**.

## Cómo se compara

Por **igualdad exacta** contra la lista, después de normalizar solo lo que no admite dos
lecturas: espacios alrededor y caja. Nada de parsear direcciones. Un `"el autor <x@y>"`
obliga a decidir qué trozo es el destinatario, y ahí entra el contrabando
(`persona-2@example.invalid <attacker@evil.test>`), así que la forma con nombre entre ángulos se
rechaza igual que las comas, los saltos de línea y lo que no sea ASCII.

**Lo no-ASCII se rechaza ANTES de comparar, y no por purismo.** `str.lower()` aplica
plegado de caja Unicode, así que `Persona-1@Example.invalid` con el signo Kelvin (U+212A)
normaliza a la dirección buena y pasaría la comparación siendo otro dominio. Medido el
2026-09-17: con la puerta ASCII delante, sale rc 2. La misma puerta cierra los homoglifos
cirílicos y cualquier variante futura del truco.

## Uso desde un sondeo

    TO="$(python3 05_salida/_herramientas/lib_lista_blanca.py check "$TO")" || exit 1

Sale 0 y escribe en stdout la envolvente normalizada; sale 2 y escribe el motivo en
stderr.

**El contrato es: el llamante manda la SALIDA de la guarda, nunca la entrada.** No es un
detalle de estilo, es lo que sostiene la seguridad del caso de arriba: lo que viaja al
proveedor es exactamente la cadena que se comparó contra la lista, carácter a carácter. Un
sondeo que compruebe `$TO` y luego mande `$TO` está confiando en que normalizar y comparar
sean la misma operación, y no lo son.

Al rechazar no se imprime la lista: los buzones del autor no tienen por qué acabar en el log
de cada sondeo.
"""
import sys

# Las tres de D-046. Se copian de `docs/08-mandato.md` y no se generan variantes.
LISTA_BLANCA = (
    "persona-3@example.invalid",
    "persona-1@example.invalid",
    "persona-2@example.invalid",
)

#: Separador de la envolvente cuando el `.sh` pasa varios destinatarios en un solo valor.
SEPARADOR = ","

_PERMITIDAS = frozenset(LISTA_BLANCA)

_MOTIVO_FUERA = "destinatario fuera de la lista blanca de D-046 (docs/08-mandato.md)"


class DestinatarioRechazado(ValueError):
    """Se levanta antes de la primera llamada a la API. El sondeo no llega a correr."""


#: Espacios que se quitan de alrededor. La lista es explícita y **solo ASCII** a
#: propósito: `str.strip()` sin argumentos también quita los espacios Unicode, y entre
#: ellos está `U+00A0`, que no es un espacio que ningún cliente de correo haya puesto ahí.
#: Un carácter raro pegado a la dirección es señal de que algo la construyó mal, y eso se
#: rechaza, no se limpia.
_ESPACIOS_ASCII = " \t\n\r\f\v"


def _es_ascii_imprimible(valor):
    """`True` si toda la cadena cae en el ASCII imprimible (0x20–0x7E).

    Es la puerta que se cruza **antes** de normalizar. `str.lower()` no es un cambio de
    caja, es plegado Unicode: el signo Kelvin `U+212A` baja a `k`, así que
    `Persona-1@Example.invalid` acabaría siendo igual a una de las tres siendo otro dominio.
    Aquí no hay ninguna dirección legítima fuera del ASCII: las tres de D-046 son ASCII
    puro y se copian literales.
    """
    return all("\x20" <= c <= "\x7e" for c in valor)


def normalizar(valor):
    """Espacios alrededor y caja, y nada más. Lo no-ASCII no llega a normalizarse.

    Las dos son reversibles y no cambian de buzón: los tres dominios de la lista tratan
    la caja como indiferente, y un espacio sobrante lo quita cualquier cliente de correo.
    Lo que no sea una cadena vale lo mismo que la cadena vacía: no hay destinatario.

    Una cadena con cualquier carácter fuera del ASCII imprimible se devuelve **entera y
    sin tocar**, para que la comparación por igualdad la rechace y el motivo del rechazo
    la nombre. Plegarla primero sería justo el fallo que la puerta evita.
    """
    if not isinstance(valor, str):
        return ""
    desnudo = valor.strip(_ESPACIOS_ASCII)
    if not _es_ascii_imprimible(desnudo):
        return desnudo
    return desnudo.lower()


def permitida(valor):
    """`True` solo si `valor` normalizado es **una** de las tres, exacta y entera."""
    return normalizar(valor) in _PERMITIDAS


def _trozos(destinatarios):
    """Aplana la envolvente a piezas sueltas, partiendo por comas en cualquier nivel.

    Se parte también dentro de cada elemento de una lista: así la cadena
    `"persona-2@example.invalid,attacker@evil.test"` se comprueba pieza a pieza tanto si el `.sh`
    la pasó entera como si ya la había partido, y ninguna de las dos lecturas deja pasar
    al polizón. Un elemento que no sea una cadena se normaliza a vacío y lo rechaza
    `comprobar` como cualquier otro hueco.
    """
    if isinstance(destinatarios, str):
        destinatarios = [destinatarios]
    piezas = []
    for crudo in destinatarios:
        piezas.extend(normalizar(crudo).split(SEPARADOR))
    return piezas


def comprobar(destinatarios):
    """Devuelve la envolvente normalizada, o levanta `DestinatarioRechazado`.

    Rechaza la lista **entera** en cuanto una pieza no esté en la lista blanca: un sondeo
    que manda a dos buzones buenos y a uno ajeno ya mandó a un desconocido. También
    rechaza la envolvente vacía, que significa que el `.sh` se quedó sin destinatario y
    no que no haya nada que comprobar.
    """
    piezas = _trozos(destinatarios)
    aceptadas = []
    for pieza in piezas:
        direccion = normalizar(pieza)
        if not direccion:
            raise DestinatarioRechazado(
                "destinatario vacío en la envolvente %r" % (destinatarios,))
        if not _es_ascii_imprimible(direccion):
            raise DestinatarioRechazado(
                "%s: la dirección lleva caracteres fuera del ASCII imprimible, así que no "
                "se compara (el plegado Unicode haría pasar por buena una dirección de "
                "otro dominio)" % _MOTIVO_FUERA)
        if direccion not in _PERMITIDAS:
            raise DestinatarioRechazado("%s: %s" % (_MOTIVO_FUERA, direccion))
        aceptadas.append(direccion)
    if not aceptadas:
        raise DestinatarioRechazado("sin destinatarios: no hay nada que enviar")
    return aceptadas


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    if not argv or argv[0] != "check":
        print("uso: lib_lista_blanca.py check <destinatario>[,<destinatario>...]",
              file=sys.stderr)
        return 2
    try:
        aceptadas = comprobar(argv[1:])
    except DestinatarioRechazado as e:
        print("ABORTA, no se envía nada: %s" % e, file=sys.stderr)
        return 2
    print(SEPARADOR.join(aceptadas))
    return 0


if __name__ == "__main__":
    sys.exit(main())
