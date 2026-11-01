# Esquema de salida (versión 0.3)

Lo escriben la 0.3, la 0.3.1, la 1.0 (la 0.3.1 congelada) y la 1.0.1.

Un único `recogida.yaml` por proveedor, en `terminos_bruto/<api>/`, y un `indice.md`
legible al lado. Las claves van en este orden y el validador lo exige. Todas las fechas son
UTC, con la forma `2026-10-23T15:00:43Z`. Las URLs son `https` y sin fragmento.

Las capturas de la 0.1 y la 0.2 son cuatro JSON por proveedor (`semillas.json`,
`descubrimiento.json`, `indice.json` e `indice.md`). Las valida `legacy_validate.py`, al que
`validate_result.py` pasa la carpeta cuando no encuentra `recogida.yaml`.

## Claves de primer nivel

| Clave | Valor |
|---|---|
| `schema_version` | La cadena `"0.3"`. |
| `generator` | `{skill: recogida-terminos-consumo, skill_version: "1.0.1"}`, la versión que escribió la última fase. La versión casa con `^(0\.3\|1\.0)(\.\d+)?$`. |
| `api` | La clave del proveedor. Es el nombre de la carpeta. |
| `fase` | Hasta dónde llegó: `semillas`, `descubrimiento` o `extraccion`. |
| `semillas` | La escribe `semillas`. |
| `descubrimiento` | La escribe `descubrir`. `null` antes. |
| `extraccion` | La escribe `extraer`. `null` antes. |
| `cobertura` | La escribe `extraer`. `null` antes. |
| `presupuesto` | La escribe `descubrir` y la completa `extraer`. `null` antes. |
| `calidad` | La escribe `extraer`. `null` antes. |
| `resumen` | Recuentos de las listas, reescritos en cada fase. |

Volver a ejecutar `descubrir` deja `extraccion`, `cobertura` y `calidad` en `null`.

## `semillas`

Claves: `generated_at`, `ficheros_leidos`, `incluidas`, `descartadas`.

- `ficheros_leidos`: los ficheros de los que se sacaron las URLs, ordenados.
- `incluidas`: `[{url, citada_en}]`. `citada_en` son los ficheros que citan la URL, y no
  está vacía. Sin repetidas. Todas dentro del ámbito.
- `descartadas`: `[{url, motivo, citada_en}]`. Lo que los ficheros citan y no es semilla:
  `fuera_ambito` (la API, un panel, GitHub, Wayback), `no_pagina` o `idioma`.

## `descubrimiento`

Claves: `generated_at`, `user_agent`, `intervalo_s`, `ambito`, `semillas`, `derivadas`,
`halladas_fuera_ambito`, `candidatas`.

- `ambito`: el ámbito del proveedor, tal como estaba en `proveedores.json`.
- `semillas`: `[{url, estado, http, enlaces}]`. `estado` es `ok`, `robots` o el error de
  red o de HTTP. `enlaces` es cuántos enlaces dio la página.
- `derivadas`: `robots` (`origen`, `estado`, `sitemaps`), `sitemaps` (`url`, `estado`,
  `urls`, y `hijos_seguidos` en un índice) y `llms_txt` (`url`, `estado`, `enlaces`).
- `halladas_fuera_ambito`: URLs que se vieron fuera del ámbito y no se guardan.
- `candidatas`: una fila por URL del ámbito, ordenadas por URL, sin repetidas.
  - Incluida: `url`, `decision: incluida`, `motivo`, `temas`, `via`, `interfaz`,
    `cuelga_de`. `motivo` es `semilla` o el primer tema. `via` es `semilla`, `url` o
    `texto_del_enlace`. `cuelga_de` son hasta cinco orígenes: una página, `semilla`,
    `sitemap:<url>` o `llms.txt:<url>`. No está vacía.
  - Descartada: `url`, `decision: descartada`, `motivo`, `cuelga_de`. El motivo es
    `no_pagina`, `idioma`, `ruido`, `novedades`, `sin_tema` o `tope`.

## `extraccion`

Claves: `generated_at`, `user_agent`, `intervalo_s`, `paginas`.

`paginas` tiene una fila por candidata incluida, en el orden de `descubrimiento`, con estas
claves en este orden:

| Campo | Valor |
|---|---|
| `id` | `P-001`, `P-002`... sin saltos. |
| `url`, `url_final` | La pedida y la que respondió tras redirecciones. |
| `titulo` | Cadena no vacía si la página se capturó. |
| `fecha_captura` | UTC. |
| `sha256` | 64 hexadecimales de los bytes recibidos. `null` si falló. |
| `sha256_texto` | 64 hexadecimales del texto normalizado (`SKILL.md`, «Conceptos»), en UTF-8. En Markdown y texto solo se reducen los blancos. Es la huella que se compara entre rondas. `null` si falló. |
| `bytes` | Tamaño de esos bytes. `null` si falló. |
| `content_type`, `http` | Los de la respuesta. |
| `estado` | `capturada` o `fallida`. |
| `error` | `null` si se capturó. Si no: `robots`, `tipo_no_texto`, `redirige_fuera_ambito`, `soft_404`, `sin_cuerpo`, `demasiado_grande`, `destino_no_publico` (no es https o el host resuelve a una dirección no pública), `redirige_a_destino_no_publico`, `http_<código>` o `red:<excepción>` (`red:dns` si el host no resuelve). |
| `aviso` | `null`, `sin_texto_visible`, `via_prefijo_en` o las dos unidas por `+`. |
| `interfaz`, `motivo`, `temas`, `cuelga_de` | Los de la candidata. |
| `fichero_texto` | `<api>/<16 primeros de sha256>.<html\|md\|txt>`, relativo a la carpeta del texto. `null` si falló. |

## `cobertura`

Una lista con un registro por tema, en el orden de `patrones.json`. Claves: `tema`,
`estado`, `paginas`, `con_evidencia`, `evidencia`, `motivo_hueco`.

- `paginas`: capturadas con ese tema en `temas`.
- `con_evidencia`: de ellas, en cuántas aparece el patrón `evidencia` del tema.
- `estado`: `con_evidencia`, `solo_ruta` o `hueco`, por el árbol de `SKILL.md`,
  «Cobertura por tema».
- `evidencia`: `{pagina, termino, posicion}` si el estado es `con_evidencia`; si no, `null`.
  `pagina` es la primera con el patrón por id; `termino`, la primera coincidencia de 1 a
  40 caracteres en su texto normalizado; `posicion`, el carácter donde empieza.
- `motivo_hueco`: `ninguna_capturada` o `ninguna_incluida` si el estado es `hueco`; si no,
  `null`.

## `presupuesto`

```yaml
presupuesto:
  peticiones: {descubrir: 230, extraer: 146}     # extraer es null antes de la fase 2
  sitemaps: {abiertos: 4, tope: 30, sin_abrir: 0, tope_alcanzado: false}
  incluidas: {halladas: 146, tope: 250, fuera_por_tope: 0, tope_alcanzado: false}
```

`sitemaps.abiertos` son las filas de `derivadas.sitemaps`; `sin_abrir`, los que quedaron en
la cola al llegar al tope. `incluidas.halladas` son las que el árbol incluyó antes del tope,
y `fuera_por_tope`, las candidatas descartadas con motivo `tope`. Los topes son los de
`recoger.py`.

## `calidad`

```yaml
calidad:
  medidas:
  - {id: semillas_fallidas_pasajeras, valor: 0, sentido: max, umbral: 0, cumple: true}
  - ...
  pasa: true
```

Una medida por umbral de `SKILL.md`, «La puerta de calidad», en ese orden. `sentido` es
`max` (el valor no puede pasar del umbral) o `min` (no puede quedarse por debajo). `pasa`
es verdadero si se cumplen todas.

## `resumen`

`semillas`, `semillas_descartadas`, `candidatas`, `incluidas`, `descartadas_por_motivo`,
`capturadas`, `fallidas` y `con_aviso`. Lo que la fase aún no ha escrito va en `null`.
`capturadas + fallidas = incluidas`.

## Reglas que comprueba el validador

- Claves y orden de cada sección, y que las secciones de las fases no hechas son `null`.
- Toda semilla está entre las incluidas, y el conjunto y el orden de `extraccion.paginas`
  son los de las candidatas incluidas, con su mismo motivo, temas, interfaz y `cuelga_de`.
- Cada capturada tiene fichero en la carpeta del texto, y su sha256, su `sha256_texto` y
  su tamaño son los del fichero. El nombre del fichero empieza por la huella.
- Ninguna fallida lleva huella ni fichero. Ninguna capturada lleva error.
- Ninguna URL incluida o semilla queda fuera del ámbito del proveedor.
- La cobertura se rehace desde los ficheros: recuentos, estado, motivo del hueco, y que el
  término de la evidencia está literal en su posición, casa entero con el patrón y es la
  primera coincidencia de la primera página.
- Los topes de `presupuesto` son los de `recoger.py` y sus recuentos, los de las listas.
- Las medidas de `calidad` se recalculan, con los umbrales de `recoger.py`.
- `resumen` coincide con las listas.
- La carpeta del índice solo tiene `recogida.yaml` e `indice.md`. El texto no está dentro
  de ella, ninguna regla `+` de `incluir.txt` lo cubre y su carpeta lleva un `.gitignore`
  con `*`.

## `indice.md`, `cifras.yaml` y `cifras.md`

`indice.md` es el índice para leer: una tabla `Título | Enlace | Fecha | Huella` con las
capturadas, y debajo las no capturadas con su motivo. La huella lleva los 16 primeros
caracteres. Es lo único que podría publicarse.

`cifras.yaml` y `cifras.md` están en `terminos_bruto/` y no en una carpeta de proveedor.
Dan, por proveedor y en total: semillas, candidatas, incluidas, capturadas, fallidas, con
aviso, temas con evidencia y si pasa la puerta. Un proveedor que no llegó a la fase 2 sale
«solo <fase>».
