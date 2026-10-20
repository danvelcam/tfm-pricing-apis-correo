# Pricing Intelligence en APIs de correo: repositorio de datos

Este repositorio acompaña al Trabajo Fin de Máster *Pricing Intelligence en APIs de correo:
catálogo de datasheets y comparación sistemática de la capacidad*. Su autor es Daniel Vela
Camacho, del Máster en Ingeniería del Software: Cloud, Datos y Gestión TI de la Universidad de
Sevilla, y lo dirigen Antonio Ruiz Cortés y Manuel Resinas Arias de Reyna.

Contiene lo que sostiene los Capítulos 4 a 6 de la memoria: las Datasheets de ocho APIs de
correo, sus fuentes y evidencias, los sondeos contra las APIs, las ejecuciones del motor de
PRIME4API y las herramientas que las reproducen. La memoria está en `memoria/`, en LaTeX y en PDF.

## Qué hay en cada carpeta

| Ruta | Contenido |
|---|---|
| `03_datos/apis/<api>/` | Datasheet (`datasheet.yaml`), registro de fuentes con las citas literales (`fuentes.md`), elementos no soportados (`fricciones.md`), matriz de *features*, acta de revisión y evidencias de los sondeos |
| `03_datos/preguntas/` | Catálogo de preguntas de decisión |
| `03_datos/_plantilla/` | Plantilla de la Datasheet y lista de comprobación de la recolección |
| `03_datos/*.md` | Criterios de modelado, consulta de selección de las APIs, recuento de recurrencia y discrepancias con la guía v0.3 |
| `05_salida/_cap5/` | Hechos por API, análisis comparativo, ejecuciones de PRIME4API y curvas de capacidad |
| `05_salida/_herramientas/` | Herramientas de verificación, ejecución y figuras, sondeos por API y sus pruebas |
| `sphere/` | La contribución preparada para SPHERE: las ocho APIs en Pricing2YAML, lo que el formato no admite y la maqueta de la colección con las versiones anteriores de cada pricing (`coleccion.html`) |
| `memoria/` | Fuentes LaTeX de la memoria y PDF |
| `DECISIONES.md` | Las decisiones del trabajo que citan los ficheros (D-nnn), con fecha |
| `PAGINAS.md` | Las copias de páginas de los proveedores que no se publican, con su huella |

Las rutas son las que cita la memoria en la tabla del paquete de replicación, en las Conclusiones.

## Reproducir la verificación

Hace falta Python 3.12 y red. La primera ejecución clona PRIME4API desde
<https://github.com/API-TaskForce/prime4api>.

```bash
pip install fastapi pydantic pyyaml ruamel.yaml requests numpy plotly matplotlib
python3 05_salida/_herramientas/verificar_prime4api.py 03_datos/apis/postmark/datasheet.yaml
```

Devuelve 0 si pasan todas las comprobaciones y 1 si falla alguna. La memoria fija la revisión
`8e6011c` del motor: para obtener la misma fila hay que situar antes la copia de
`~/.cache/atf/prime4api` en esa revisión.

Las pruebas de las herramientas:

```bash
python3 -m pytest 05_salida/_herramientas/tests/ -q
```

## Los sondeos

Los scripts `probe_*` envían peticiones reales a las APIs y algunos envían correo. Cada uno lee sus
claves de `~/.config/tfm/.env`, fuera del repositorio, y solo escribe a una lista blanca de
destinatarios con un tope de gasto. Las direcciones del autor se han sustituido por
`persona-N@example.invalid`: para repetir un sondeo hay que poner las propias y una cuenta propia
en cada proveedor. Los resultados de cada sondeo están en `evidencias/` de su API.

## Páginas de los proveedores

Las Datasheets citan páginas de los proveedores archivadas en una fecha. Las citas literales están
en `fuentes.md` y en cada Datasheet. Las copias completas no se publican porque los términos de
cinco de los ocho proveedores prohíben reproducir su contenido. `PAGINAS.md` lista cada copia con
su ruta, tamaño y huella sha256; el autor las conserva y las facilita al tribunal si las pide.

Los modelos de servicio de AWS (`service-2.json`) vienen de botocore y se publican con su licencia
Apache-2.0.

## Autoría de lo que se usa

El modelo ACM, la guía ACM2YAML, la Datasheet, PRIME4API y HARVEY4API son trabajo de Ramón Gavira
Sánchez y Daniel Ruiz López. SPHERE y Pricing2YAML son del grupo ISA de la Universidad de Sevilla.
Este trabajo los aplica a las APIs de correo y propone extensiones.

## Licencia

Datos y texto, con licencia CC BY 4.0 (`LICENSE-datos.md`). Código, con licencia MIT (`LICENSE`).
