# recogida-terminos-consumo v1.0.1

Recoge en bruto las páginas públicas que fijan cuánto se puede consumir del servicio de
correo transaccional de un proveedor: precios, límites, cuotas, uso aceptable, SMTP,
webhooks y errores. Por proveedor deja un único `recogida.yaml` con enlace, título, fecha y
huellas de cada página, la cobertura de cada tema con su evidencia, el presupuesto gastado y
una puerta de calidad. El texto sin tocar va a una carpeta que no se publica.

Es la capa de debajo de la Datasheet. No lee ni interpreta lo que recoge.

Versión de la skill: `1.0.1`: la 1.0 congelada, con los arreglos de una revisión de código. Esquema de
salida: `0.3`. Salida: YAML, como las skills de Daniel Ruiz, ACM2YAML y Pricing2YAML.

## Estado

**Versión 1.0.1, aplicada y no validada por el autor.** La anatomía es la de las skills de Daniel
Ruiz: `SKILL.md` como única fuente de reglas, árbol de decisión en orden fijo, evidencia
literal, presupuesto anotado, un único YAML con esquema, un validador y una puerta final.
Se congeló el 2026-10-23 tras la ronda de «Ronda de validación», con la condición que puso
el autor ese día: un barrido con la skill rehecha y su comparación con las capturas anteriores.

## Contenedor

Todo corre en un contenedor, también la red. El Python de la máquina no trae PyYAML y la
salida es YAML. `scripts/contenedor.sh` ejecuta cada comando de la lista cerrada en la
imagen `tfm-recogida:0.3`, que construye la primera vez desde `scripts/Dockerfile`: la
misma `python:3.12-slim` de `make verify` con PyYAML 6.0.2.

El contenedor monta el repositorio de solo lectura y solo la carpeta de la ronda con
escritura, y corre con el usuario de quien llama. Así, `recoger.py` no puede escribir fuera
de su ronda aunque lo intente, y lo que escribe no queda de root. El validador se monta
entero de solo lectura (`--solo-lectura`).

Los tests (`05_salida/_herramientas/tests/test_recogida_0_3.py` y
`test_recoger_huella_texto.py`) corren con `make verify`, en el mismo contenedor.

## Qué comprueba el validador

`validate_result.py` sale con **0** si la salida es correcta y la puerta pasa, con **1** si
la salida tiene errores y con **2** si es correcta pero la puerta no pasa. Comprueba:

1. **Forma.** Claves y orden del esquema, ids, recuentos, que toda semilla llega a
   incluida y que cada incluida tiene su fila.
2. **Huellas.** sha256, tamaño y huella del texto normalizado de cada captura, rehechos
   desde el fichero.
3. **Cobertura por categoría.** Para cada uno de los ocho temas rehace cuántas páginas se
   capturaron y en cuántas aparece su patrón, y busca el término de la evidencia en su
   posición del texto normalizado.
4. **Presupuesto.** Topes de `recoger.py` y lo gastado: peticiones por fase, sitemaps sin
   abrir, páginas fuera por el tope.
5. **Calidad.** Semillas caídas por la red, proporción de fallidas y de fallidas
   pasajeras, páginas sin texto visible, temas con evidencia y páginas de precios con
   evidencia, con los umbrales de `recoger.py` y no los del fichero.
6. **Texto no publicado.** Que el texto no está en la carpeta del índice, que ninguna regla
   `+` de `incluir.txt` lo cubre y que su carpeta lleva un `.gitignore` con `*`.

No juzga si una página merece estar en el conjunto.

## Ronda de validación

Cinco capturas de los ocho proveedores el 2026-10-23: la demo de la mañana y la ronda de
la tarde con la 0.1, la ronda de la noche con la 0.2, y dos barridos con ocho agentes en
paralelo, uno por proveedor, con la 0.3 y la 0.3.1. Por proveedor: incluidas / capturadas /
fallidas.

| Proveedor | demo 0.1 | tarde 0.1 | noche 0.2 | barrido 0.3 | barrido 0.3.1 |
|---|---|---|---|---|---|
| postmark | 146 / 146 / 0 | 146 / 146 / 0 | 146 / 146 / 0 | 146 / 146 / 0 | 146 / 146 / 0 |
| resend | 107 / 107 / 0 | 107 / 107 / 0 | 107 / 107 / 0 | 107 / 107 / 0 | 107 / 107 / 0 |
| sendgrid | 250 / 249 / 1 | 250 / 249 / 1 | 250 / 249 / 1 | 250 / 249 / 1 | 250 / 249 / 1 |
| mailersend | 133 / 133 / 0 | 133 / 133 / 0 | 133 / 133 / 0 | 133 / 133 / 0 | 133 / 133 / 0 |
| brevo | 148 / 139 / 9 | 148 / 139 / 9 | 148 / 139 / 9 | 148 / 135 / 13 | 148 / 138 / 10 |
| ses | 108 / 101 / 7 | 108 / 101 / 7 | 108 / 101 / 7 | 108 / 101 / 7 | 108 / 101 / 7 |
| mailgun | 249 / 248 / 1 | 249 / 248 / 1 | 249 / 248 / 1 | 249 / 247 / 2 | 249 / 247 / 2 |
| mailchimp | 56 / 51 / 5 | 56 / 51 / 5 | 56 / 51 / 5 | 56 / 51 / 5 | 56 / 51 / 5 |

- **El conjunto de páginas fue el mismo en las cinco.** 1.197 incluidas en todas, y 1.196
  URLs comunes de 1.198: la diferencia es un artículo de ayuda de Mailgun que cambió de
  título y de dirección entre la ronda de la tarde y la de la noche.
- **La puerta pasó en los ocho proveedores en los dos barridos**, sin repetir `extraer`.
- **La cobertura no cambió de estado.** Cada tema quedó `con_evidencia`, `solo_ruta` o
  `hueco` igual en los dos barridos. Los recuentos de páginas por tema variaron en una como
  mucho, por las páginas que fallaron con 403.
- **Las fallidas varían en los centros de ayuda.** Brevo y Mailgun devolvieron 403 en
  páginas que otras capturas tenían: cinco en el barrido 0.3 y dos en el 0.3.1. Es la única
  variación del número de capturadas, y es lo que motivó la 0.3.1.
- **La huella del texto separa el cambio del ruido.** De las 1.166 páginas capturadas en
  las cinco, 802 son iguales byte a byte y 269 más tienen el mismo texto: 1.071 sin cambio.
  Entre los dos barridos, separados por seis minutos, cambian dos: una por orden y otra
  por el menú. Las cifras son de `05_salida/ronda_recogida/comparacion_2026-10-23_cinco.md`.

El resultado estable es el conjunto de páginas y el estado de cada tema. Las capturadas y
los recuentos por tema llevan un margen de unas pocas páginas en los proveedores con centro
de ayuda.

## Limitaciones

- **Solo destinos públicos.** `recoger.py` pide únicamente URLs `https` cuyo host resuelve
  a direcciones públicas, y comprueba lo mismo en cada salto de una redirección. La
  comprobación es previa a la conexión: un DNS que cambie de respuesta entre las dos no se
  detecta.
- **Sin JavaScript.** Una página que se pinta en el navegador sale casi vacía. Se guarda y
  lleva el aviso `sin_texto_visible`, y cuenta en la puerta.
- **Profundidad 1.** Se siguen los enlaces de las semillas, de los sitemaps y de
  `llms.txt`. Una página enlazada solo desde otra candidata no entra.
- **Tope de 250 páginas por proveedor.** Lo que sobra queda como `descartada` con motivo
  `tope`, y `presupuesto` lo cuenta. El tope se aplica por orden de tema y no por
  importancia. SendGrid lo alcanza.
- **El árbol es de patrones sobre la ruta.** Deja fuera páginas con una ruta que no dice
  nada y sin un enlace con texto claro, y deja pasar alguna que sobra. Con redundancia
  permitida se asume lo segundo.
- **La evidencia es una marca, no una lectura.** Dice que en la página aparece un término
  del tema. Puede venir del menú o del pie, que repiten enlaces en todas las páginas: en
  Mailchimp, «Terms of Use» sale del pie. Un tema `con_evidencia` no prueba que el
  proveedor fije condiciones sobre él, y un `hueco` no prueba que no las fije.
- **Umbrales medidos con pocas capturas.** Salen de las capturas de un mismo día. El peor
  proveedor de cada medida queda dentro, a veces con poco margen: Mailchimp tiene un 8,9 %
  de fallidas frente a un tope del 15 %.
- **Heurísticas de formato.** Quitar el `.md` de las URLs descubiertas y reintentar con
  el prefijo `/en` cuando la geolocalización manda a otro idioma son reglas puestas
  para casos de Mailchimp y de documentación en Markdown. Pueden no valer en otro
  proveedor.
- **Fallos reales que quedan en el índice.** Rutas de un sitemap que dan 404 (los planes
  de Brevo), páginas que responden 200 y dicen «Page not found» (parte de la documentación
  para desarrolladores de Mailchimp) y páginas que `robots.txt` prohíbe (las etiquetas del
  blog de AWS). No se reintentan ni se esquivan, y no son pasajeros.
- **`Content-Signal`.** Los `robots.txt` de Twilio, MailerSend y Postmark declaran
  `ai-train=no`. La skill no lo aplica, porque archiva y no entrena. Es una
  interpretación y la tomó quien la escribe, no el tutor ni el autor.
- **Dos huellas.** La de los bytes cambia en cada carga. La del texto normalizado solo
  cambia si cambia lo que se lee, pero también lo hace con un contador, un menú que rota
  o un enlace reescrito. Una huella de texto distinta dice que la página cambió, no que
  cambiaran las condiciones: eso lo dice quien la lee.
- **Un proveedor por proceso.** El ritmo es de 2,5 peticiones por segundo y no se
  paraleliza dentro de un proveedor. Proveedores distintos sí pueden ir a la vez, cada
  uno en su proceso y su carpeta.
- **Cobertura de proveedores.** Los ocho del catálogo. Mandrill va dentro de Mailchimp.
  Un proveedor nuevo exige dar de alta su ámbito en `proveedores.json`.

## Versiones

Cambios de reglas sin cambio de esquema suben el tercer número; un cambio del esquema de
salida sube el segundo. La 1.0 llegó tras una ronda con la skill rehecha comparada con las
capturas anteriores, la condición que fijó el autor el 2026-10-23.

### 1.0.1 (2026-10-23)

Motivo: la revisión de código del commit de la 1.0. Sin cambio de esquema ni de umbrales; los
dieciséis resultados de los dos barridos siguen validando con 0.

- `descubrir` y `extraer` firman `generator` con su versión. Antes solo lo hacía `semillas`,
  y una carpeta de la 0.3 extraída de nuevo con la 1.0 seguía diciendo 0.3 y se medía con la
  regla del 403 de la 0.3.
- `0.3.0` cuenta como la 0.3 en la regla del 403.
- El validador vacía su lista de errores en cada llamada a `main`, y da un error legible si
  `sitemaps.sin_abrir` no es un entero, en vez de una traza.
- `contenedor.sh` comprueba que la carpeta está dentro del repositorio antes de crearla.

### 1.0 (2026-10-23)

La 0.3.1 congelada tras la ronda de «Ronda de validación». Sin cambios de reglas ni de
esquema. Los cambios siguientes serán 1.0.x si no cambia el esquema.

### 0.3.1 (2026-10-23)

Motivo: en el primer barrido con la 0.3, los centros de ayuda de Brevo y Mailgun devolvieron
403 en cinco páginas que las tres capturas anteriores tenían. La puerta contaba el 403 como
fallo de la fuente y pasó. Es la respuesta de un antibot, que bloquea un rato y luego deja
pasar.

- El 403 cuenta como fallo pasajero. Las salidas de la 0.3 se siguen validando con la regla
  de la 0.3, porque el validador mira `skill_version`.
- Sin cambio de esquema.

### 0.3 (2026-10-23)

Motivo: la revisión del 2026-10-23 contra la anatomía de las skills de Daniel Ruiz. El
validador de la 0.2 comprobaba la forma y no la calidad: una recogida con la mitad de las
páginas caídas, o sin ninguna página de precios, salía con `ok`.

- Un único `recogida.yaml` por proveedor en vez de tres JSON. Cada fase lo reescribe y
  `fase` dice hasta dónde llegó. `cifras` escribe `cifras.yaml`.
- Cobertura por tema con evidencia literal: término de 40 caracteres como mucho y su
  posición en el texto normalizado. Patrones nuevos `evidencia` en `patrones.json` (0.3).
- Presupuesto gastado en la salida: peticiones por fase, sitemaps sin abrir y páginas
  fuera por el tope.
- Puerta de calidad con seis umbrales, en `recoger.py` y en `SKILL.md`; un test comprueba
  que coinciden. El validador sale con 2 si no pasa, y el protocolo repite `extraer` una
  vez.
- La carpeta del texto lleva su `.gitignore` con `*`, y el validador lo exige.
- Todo corre en el contenedor de `scripts/contenedor.sh`.
- El validador de la 0.2 pasa a `legacy_validate.py`, para las capturas JSON.

### 0.2 (2026-10-23)

Motivo: entre la demo de la mañana y la ronda de la tarde, solo 901 de 1.197 páginas
tenían la misma huella de bytes. El HTML cambia en cada carga aunque diga lo mismo.

- Huella del texto normalizado (`sha256_texto`), que el validador rehace desde el fichero.
- `05_salida/_herramientas/comparar_rondas.py`, que compara capturas por URL con esa
  huella.
- Esta versión se publicó primero como 1.0 por error. El autor la renombró a 0.2 el mismo día:
  aún no había pasado la ronda que exige la anatomía de Daniel Ruiz.

### 0.1 (2026-10-23)

Demo para la reunión con los tutores: las dos fases, el árbol de decisión, los topes y el
validador de forma. Salida en tres JSON por proveedor.

## Qué hay en la carpeta

```
SKILL.md                      instrucciones, única fuente de las reglas
README.md                     este fichero
references/
  proveedores.json            ámbito de cada proveedor (dato)
  patrones.json               temas, evidencia, ruido y superficies (dato)
  output-schema.md            campos y orden del YAML
  conceptual-model.md         por qué dos fases, este árbol y esta puerta
  glosario.md
  examples.md                 ejemplos inventados
scripts/
  recoger.py                  semillas, descubrir, extraer, cifras
  validate_result.py          validador y puerta de calidad
  legacy_validate.py          validador de las capturas JSON de la 0.1 y la 0.2
  contenedor.sh               ejecuta un comando en el contenedor
  Dockerfile                  la imagen tfm-recogida:0.3
```

## Cómo se usa

Las órdenes exactas están en `SKILL.md`, en la lista cerrada de comandos. En resumen:
`semillas`, `descubrir` y `extraer` por proveedor, `cifras` una vez, y el validador por
cada proveedor al final. `05_salida/_herramientas/ronda_recogida.sh` lanza una ronda
completa en serie; varios agentes, uno por proveedor, la lanzan en paralelo con los mismos
comandos.

Cada ronda va en `05_salida/ronda_recogida/<fecha_hora>/`:

- `terminos_bruto/<api>/`: `recogida.yaml` e `indice.md`. Es lo único publicable.
- `terminos_bruto/cifras.md`: las cifras por proveedor. Es su única fuente: este
  fichero no las copia.
- `terminos_bruto_texto/<api>/`: el texto en bruto, fuera de git.

## Por qué el texto no se publica

El permiso para copiar texto de páginas de terceros sigue sin resolverse
(`05_salida/respuesta_tutor_2026-10-12/A4_permiso_copia.md`). El repositorio de datos
sale de `git ls-files` con las reglas de `incluir.txt`, y la regla `+ 03_datos/apis/*`
cruza las barras. El texto va en una carpeta que ninguna regla `+` cubre, que el
`.gitignore` de la raíz ignora y que lleva su propio `.gitignore` con `*`. Del texto solo
salen los títulos y los términos de evidencia.

Si se decide publicar el índice, hay que añadir a mano una regla de `incluir.txt` para
`terminos_bruto/*/indice.md`. La skill no toca ese fichero.

## Qué falta

- La revisión a mano de una muestra de descartadas por `sin_tema` y de incluidas sin ser
  semilla.
- Rondas a lo largo de semanas, para tener la serie de cada proveedor y medir los umbrales
  con más de un día (trabajo futuro).
- La decisión sobre el permiso de copia (A4) y, según salga, sobre qué se publica.
- Llevar la comparación dentro de la skill como un comando más; hoy es una herramienta
  aparte.
