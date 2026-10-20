# Discrepancias encontradas en ACM2YAML v0.3, PRIME4API y el repositorio

Documento vivo. Recoge lo que aparece al construir el catálogo de Datasheets de correo y
**no encaja**: contradicciones entre la norma, los ejemplos y la implementación, o
comportamientos que rompen sin avisar. Destinatarios: Ramón Gavira Sánchez y los tutores.

Cada entrada trae evidencia reproducible. Nada aquí es una impresión.

---

## Procedimiento antes de reportar nada

**Ninguna discrepancia se comunica sin haber buscado antes si ya está reportada.** Si
existe un issue o un PR que dice lo mismo, no se abre uno nuevo: se comunica igualmente y
se **referencia el existente**. Que dos personas detecten el mismo hueco por separado no
es redundancia, es señal de que el criterio de detección es compartido, y eso vale más
que el hallazgo suelto.

Cada entrada de este documento declara qué se buscó y qué se encontró.

### Rastreo de issues y PR — 2026-08-10

| Repositorio | Issues | PR | Contenido |
|---|---|---|---|
| `prime4api` | **1 abierto** | **0, nunca** | #1 «Soportar listas de rates y cuotas en datasheet», de rgavira, 14-04-2026 |
| `apis_consumption_model` | 25 | — | Todos son peticiones de modelado de una API concreta (Amadeus, Spotify, SendGrid…) |
| `SPHERE` | 0 | — | Fork de `SCORELabUS/SPHERE`, con creación de issues restringida |
| `datasheet-usage-testing` | — | — | Fuera del alcance del esquema |

**Ninguna de las tres discrepancias de este documento está reportada.**

Observación al margen: el issue #1 de `prime4api` pide aceptar listas de rates y cuotas, y
`_parse_rates` / `_parse_quotas` **ya lo hacen** desde el commit del 14-04-2026. Está
implementado y sin cerrar. Merece un comentario, no un issue nuevo.

---

## Aviso: no existe validador oficial de Datasheets

Se buscó en los cuatro repositorios. No hay esquema JSON, ni linter, ni CI que compruebe
la conformidad de un `datasheet.yaml`.

- **PRIME4API** es un motor de cálculo, no un validador. No declara la estructura de la
  Datasheet en ningún Pydantic: la recorre con `.get()` y `float()` sobre el diccionario
  crudo. Sus `app/schemas/` describen las peticiones y respuestas **de su propia API REST**,
  no el artefacto.
- **SPHERE** valida *pricings* (Pricing2Yaml) y, de los ficheros que sube, solo tamaño y
  `mimetype`. Su módulo de datasheets es interfaz: lista, renderiza y edita, sin comprobar
  conformidad.
- Los dos repositorios restantes no tienen nada.

**Consecuencia metodológica:** la conformidad de una Datasheet solo puede establecerse
**por uso**, haciéndola consumir por el motor. Es lo que hace
`05_salida/_herramientas/verificar_prime4api.py`, y por eso sus resultados son evidencia y
no opinión.

---

## El código ha seguido avanzando después del TFM

`prime4api` tiene 27 commits. El último anterior a la entrega del TFM es
*«final version of implementation after psg2 ground truth»* (13-05-2026). Después hay
**cuatro más**, todos sobre curvas de capacidad:

| Fecha | Commit |
|---|---|
| 26-07-2026 | `fix: 'requests' now shows up as a selectable capacity unit` |
| 26-07-2026 | `fix: add option to show derived requests in plotly renderer` |
| 26-07-2026 | `feat: add show_derived_requests parameter to chart rendering` |
| 08-08-2026 | `fix: emit rate breakpoint before quota exhaustion in inflection curve` |

Es decir: **el motor hace hoy más cosas de las que documenta el TFM**, y todas ellas pasan
por `get_curve_scenarios`. Una Datasheet puede satisfacer lo que el TFM describe y aun así
ser inservible para lo que el motor calcula ahora. Por eso el verificador ejercita también
esa superficie, marcada como «post-TFM».

---

## DV-01 · El README documenta `workload` como mapa; todo lo demás usa lista

**Estado: resuelta por nuestro lado. El README sigue mal.**
**¿Reportada? No.** No hay issue ni PR sobre la forma de `workload` en ningún repositorio.

Las tres fuentes dicen cosas distintas:

| Fuente | Forma | Referencia |
|---|---|---|
| `readme/readme0.3.md` §3.4.2 | **Mapa** | Tabla de campos y ejemplo `v1/email` |
| `datasheets/mailersend/mailersend_v03.yaml` | **Lista** | Líneas 139-143 |
| TFM de Gavira Sánchez | **Lista** | Extractos 4.3 y 4.4, y Anexo (SendGrid) |
| PRIME4API | **Las dos al calcular, solo lista al navegar** | Ver abajo |

`_parse_workload` envuelve el mapa en una lista y tolera ambas formas, así que las
operaciones de cálculo funcionan. Pero `_collect_workloads_from_ep`, `get_capacity_units`
y `get_crf_ranges` iteran el valor directamente, y con un mapa iteran sus **claves**:

```
TypeError: string indices must be integers, not 'str'
```

**El modo de fallo es el peor posible.** La Datasheet calcula bien y solo se rompe al
navegarla, que es justo lo que hace un agente conversacional sobre ella. Quien la
construya siguiendo el README obtendrá números correctos y creerá estar conforme.

**Cómo lo hemos resuelto.** Adoptando la lista, porque es lo que sostiene el TFM con un
argumento y no solo con un ejemplo: *"cualquier endpoint cuya petición consuma métricas
distintas de forma simultánea necesita declararlas por separado"*. Un mapa solo puede
declarar una métrica, así que la lista no es convención de estilo sino requisito del
modelo. El ejemplo de SendGrid del propio TFM declara `emails` y `MBs` a la vez.

**Propuesta.** Corregir §3.4.2 del README para que documente la lista y muestre el caso de
dos métricas simultáneas, que es lo que justifica la forma. Opcionalmente, normalizar en
`_collect_workloads_from_ep` para que las Datasheets escritas contra el README actual no
queden inservibles.

---

## DV-02 · Un valor ausente inutiliza la Datasheet completa

**Estado: abierta. Es la discrepancia dominante.**
**¿Reportada? No.**

**Diez fallos entre las dos Datasheets, por dos campos distintos.**

| Datasheet | Campo | Por qué está vacío |
|---|---|---|
| Postmark | `workload.max` de `/email/bulk` | Postmark no pone tope de mensajes por llamada; el límite real es el payload de 50 MB |
| Resend | `max_power.rate_request_team_enterprise.value` | Caudal negociado, no publicado |

```
TypeError: float() argument must be a string or a real number, not 'NoneType'
```

Origen: `float(w['max'])` en `_parse_workload` y `float(r_def["value"])` en `_parse_rate`,
ninguno con comprobación de nulo.

**Lo que cae:** las cuatro operaciones de cálculo, `nav.crf_ranges` y **toda la superficie
post-TFM** — escenarios de curva, curva acumulada, curva de inflexión, curva de coste y
recomendación de plan. En las dos Datasheets.

**Por qué importa más de lo que parecía.** El esquema obliga a elegir entre dos males:
omitir el campo, y entonces la Datasheet afirma implícitamente que no hay límite —lo
contrario de la verdad—, o declararlo vacío, y entonces el consumidor no puede usarla para
nada de lo que se construyó después del TFM. No hay tercera opción en v0.3. Es la fricción
F-01 del catálogo, y esta traza es la primera evidencia empírica de que la decisión tiene
consecuencias medibles.

**Propuesta.** Distinguir en el esquema «sin límite» de «límite no publicado», y que el
motor trate el segundo como dimensión no evaluable en lugar de fallar. Un `not_found: true`
junto al campo permitiría a PRIME4API omitir esa dimensión y seguir evaluando el resto.

**Tercera API, y un tercer campo (2026-09-21, Mailchimp Transactional).** La segunda tanda de
preguntas PI lo reprodujo entero: **catorce de las diecisiete llamadas** de Mailchimp devuelven
`HTTP 500` con el cuerpo `{"detail": "float() argument must be a string or a real number, not
'NoneType'"}`, siempre idéntico. El código y el envoltorio salen de los JSON archivados de la
tanda, `05_salida/_cap5/prime4api_ejecucion_2026-09-21/PI-*_mailchimp.json`, donde el recuento
por código es 14 de 500 y 3 de 200. Solo contestan
las tres que no calculan tiempo —`/quotas` dos veces y `/rates`—. El campo vacío es el
`workload.max` de `emails` en `/messages/send`, que el proveedor no publica: «sin tope
publicado, y 5.000 en una sola llamada se aceptaron al medirlo».

Y hay un segundo nulo debajo, con otra traza. Aislado por sustitución en memoria, sin tocar el
fichero: rellenando solo el `max` del workload el error **cambia** a `division by zero`, que
sale de `t_milliseconds / period` con el `period` vacío de `quota_email_demo`; rellenando
además ese periodo, la misma llamada devuelve 200 y `nav/crf-ranges` también. Los dos huecos
son deliberados y el libro de reglas los admite por su nombre, el `max` por **B1** y **F-01** y
el `period` por **B16** y **E15**. Así que la factura de un hueco justificado ya está medida:
son catorce llamadas de diecisiete.

**Lo que esto añade a la propuesta.** El `not_found: true` no basta si solo cubre `workload.max`
y `max_power.*.value`: hace falta también en `capacity.*.period`, porque una cuota sin ventana
declarada —una franquicia que ni caduca ni se renueva— no tiene forma en v0.3 y tumba por una
división, no por una conversión.

---

## DV-03 · Un plan de precio negociado tumba también todo lo demás

**Estado: abierta.**
**¿Reportada? No.**

**Reproducible con.** Resend, plan `enterprise`. Resend no publica cifras de ese tier, ni
el precio ni la cuota, así que ambos campos llevan `custom`, que es literalmente lo que
publica el proveedor.

```
ValueError: could not convert string to float: 'custom'
```

**El fallo no está acotado a ese plan.** Como la evaluación recorre todos los planes de la
Datasheet, un único valor no numérico impide evaluar también `free`, `pro` y `scale`, que
están documentados al detalle y son los que cualquiera va a consultar. Caen las siete
operaciones y el pricing.

**Por qué importa.** El tier enterprise negociado es la norma en las APIs de correo, no la
excepción: Postmark tiene su equivalente por encima de 1,5 M de envíos. Con el
comportamiento actual, la mayoría de las Datasheets del dominio quedarán inservibles por
su plan menos interesante.

**Propuesta.** Dos cosas separables. En el esquema, una forma explícita de declarar un plan
cuyo precio existe pero no es público, en vez de forzar una cadena en un campo numérico. En
el motor, aislar el fallo por plan: que un plan no evaluable devuelva su error y los demás
sigan calculándose.

---

## DV-04 · Un escenario con un solo caudal y sin cuota tumba la curva acumulada

**Estado: abierta.** *(2026-09-08, MailerSend; 2026-09-18, Amazon SES; 2026-09-24, Mailgun)*

**Tercera API (2026-09-24, Mailgun).** `verificar_prime4api.py` da **20 OK / 1 ERR** con PRIME4API
en `8e6011c`, y el único fallo es `curve.accumulated` con el mismo mensaje, `unsupported operand
type(s) for /: 'int' and 'TimeDuration'` (`apis/mailgun/evidencias/verificar_prime4api_2026-09-24.txt`).
Candidato, sin aislar: `/v3/{domain_name}/bounces/import`, con workload en `MBs`, sin cuota en
`MBs` y sin `rate` propio, así que su escenario solo recibe el `rate` del plan. `/messages` lleva
`rate` de plan y de endpoint, y por eso esquivaría `RatePlotter` como SendGrid. No se ha ejecutado
el escenario suelto: hasta entonces la memoria dice «el mismo error», no «la misma causa».
**¿Reportada? No** (el rastreo del 2026-08-10 no la cubre; el issue #1 de `prime4api` habla de
listas de rates y cuotas, no de este caso).

**Reproducible con.** MailerSend, endpoint `/v1/bulk-email`, workload en `MBs` (el tope
publicado de 50 MB del cuerpo JSON). El plan tiene una cuota diaria en `requests` y el
endpoint una cuota mensual en `emails`; para la dimensión `MBs` no hay cuota, así que
PRIME4API construye un escenario con **un** `Rate` y **cero** `Quota` y despacha
`RatePlotter`:

```
File "app/engine/evaluators/rate_evaluator.py", line 25, in capacity_at
    c = value * np.floor((t_milliseconds / period)+1)
TypeError: unsupported operand type(s) for /: 'int' and 'TimeDuration'
```

`RateEvaluator.capacity_at` divide milisegundos por un `TimeDuration` sin convertirlo;
`BoundedRatePlotter` (dos o más rates, o rate y cuota) sí convierte. Solo falla
`curve.accumulated`; `curve.inflection`, las siete operaciones y el presupuesto pasan.

**Por qué SendGrid no lo destapó.** Su `/v3/mail/send` referencia el mismo rate a nivel de
plan y de endpoint, así que el escenario en `MBs` lleva **dos** rates idénticos y esquiva
`RatePlotter`. Sin esa duplicación accidental, SendGrid fallaría igual. Verificado el
2026-09-08: MailerSend sin el workload en `MBs` pasa 21/21; con él, 20/21.

**Segunda comprobación (verificación independiente, 2026-09-08).** Con `rate:
rate_request_general_<plan>` añadido a nivel de plan en los cuatro planes (la forma de Postmark,
Resend y SendGrid) MailerSend pasa **21/21**: el escenario en `MBs` lleva entonces dos rates y
esquiva `RatePlotter`. No se ha aplicado: el 60/min de MailerSend es *"excluding email
endpoints"* y declararlo como «caudal global del plan» (README §3.4) contradiría el 120/min de
`/v1/email`; el wildcard `/*` es la forma correcta. Confirma el diagnóstico: el fallo depende de
cuántas referencias `rate` alcanzan el escenario, no del dato.

**Por qué importa.** Cualquier dimensión de workload acotada solo por caudal (tamaño en MB,
registros por petición) sin cuota propia cae aquí, y es el caso normal de F-06: el
proveedor publica un tope de tamaño y no una cuota mensual de megabytes.

**Segundo reproductor (2026-09-18, Amazon SES).** La predicción se cumple en otro proveedor, con
la traza idéntica —`rate_evaluator.py`, línea 25— y `curve.accumulated` como único fallo. SES da
**20 OK / 1 ERR**.

```bash
docker exec tfm-py python3 05_salida/_herramientas/verificar_prime4api.py \
        03_datos/apis/ses/datasheet.yaml
```

El caso entra por donde el diagnóstico decía. Los dos endpoints de envío declaran un workload en
`MBs`, el tope de 40 MB del mensaje, y la cuota del entorno de pruebas está en `emails`: esa
dimensión sale con un `Rate` y ninguna `Quota`. Cae también el comodín `/*`, que solo declara
caudal y ni siquiera tiene workload. Recorriendo los 84 escenarios uno a uno, porque la
comprobación se detiene en el primero que rompe, caen **52**.

SES añade además un segundo modo de esquivarlo, y este no repite ninguna referencia. El
endpoint `/v2/email/account` declara caudal y workload en la misma unidad, `requests`. Con eso,
`_build_scenarios` mete ese único `Rate` en los dos cubos que construye, el de peticiones y el de
la unidad de workload, y el escenario sale con dos. Ahí la Datasheet no duplica nada: duplica el
motor.

**Qué cambia con el segundo caso.** Un defecto con un reproductor es una peculiaridad del
modelado de esa API. Con dos proveedores independientes es el patrón que el diagnóstico
anunciaba. La propuesta no cambia; cambia lo que la sostiene.

**Propuesta.** Una línea en el motor: `period.to_milliseconds()` en `RateEvaluator.capacity_at`
(como ya hace `min_time`). Ningún dato de la Datasheet se ha alterado para esquivarlo.

---

## DV-05 · La herencia suma el límite del plan y el del endpoint sin deduplicar

**Estado: abierta.** *(2026-09-14, SendGrid y Resend)*
**¿Reportada? No.**

**Reproducible con.** Cualquier Datasheet que declare la misma referencia de `quota` o de
`rate` en el plan y en uno de sus endpoints, forma que el esquema admite y que el catálogo
usaba en dos de sus cuatro APIs. `_get_node_scenarios` parte de los límites heredados del
plan y les concatena los del nodo:

```python
rates: List[Rate] = list(inherited_rates)
if rate_def := node_config.get("rate"):
    rates.extend(self._parse_rates(rate_def, max_power_defs))
```

No compara: dos referencias al mismo nombre producen dos `Rate` idénticos, y lo mismo con
las cuotas. El escenario sale con dos límites donde el proveedor publica uno.

**Lo medido.** SendGrid Essentials, `/v3/mail/send`, curva de inflexión del propio motor:
con la repetición, `capacity` a 30 días es **100.000** correos con $k = 1.000$ y la curva
con $k = 1$ mete una meseta en el primer segundo; sin ella, 50.000, que es la cuota
publicada. El efecto no es uniforme: Resend repetía solo la cuota y su curva no se movía,
porque el techo lo fijaba el mismo valor duplicado.

**Qué no es.** No es un defecto de la Datasheet —el esquema permite las dos formas— ni se
arregla con un dato distinto. El catálogo lo evita por criterio (**B8**, D-035): cada
límite se declara una sola vez y el validador v0.3 falla si se repite.

**Propuesta.** Deduplicar por identidad de referencia al construir el escenario, o declarar
en la guía que la repetición es un error de modelado.

---

## DV-06 · Un alias pedido tumba la consulta entera si un solo plan de la lista no lo declara

**Estado: abierta.** *(2026-09-21, Brevo)*
**¿Reportada? No.** Rastreo de issues pendiente: el último es del 2026-08-10.

**Reproducible con.** Cualquier Datasheet donde el mismo endpoint declare aliases en unos
planes y no en otros, forma que el esquema admite y que **D7** contempla —«un plan elegible de
una sola banda no lleva alias»—. Brevo declara `general`, `advanced` y `extended` en
`/v3/smtp/email`, pero solo dentro de `professional` y `enterprise`; los otros tres planes
llevan el `rate` directamente.

```
HTTP 400 {"detail": "Endpoint '/v3/smtp/email' has no aliases, but an alias was provided."}
```

Origen: la comprobación está dentro del bucle por plan de `datasheet_evaluator_service.py`, así
que el primer plan sin alias aborta la consulta de todos, incluidos los que sí lo declaran.

**Lo medido el 2026-09-21.** `POST /limits` con los cinco planes y `alias: general` devuelve 400.
Sin filtro de alias devuelve 200, y los planes que tienen aliases salen con **una fila por
alias**: en `/budget/recommendation` de 40.000 correos, `professional` aparece dos veces, con
`alias: general` a 39 s y con `alias: advanced` a 19 s, las dos al mismo precio de 499 USD.

**Qué no es.** No es un defecto de la Datasheet: el alias parcial es la forma que el proveedor
tiene, porque las bandas de caudal solo existen en los dos planes altos. Y no es DV-03: allí lo
que rompe es un valor no numérico, aquí lo que rompe es un filtro que no se puede aplicar.

**Consecuencia para el método.** El filtro de alias deja de ser utilizable en cuanto la consulta
abarca más de un plan, que es justo lo que piden las preguntas de comparación. La tanda del
2026-09-21 se ejecutó sin filtro por esto, y el rótulo lo pone el campo `alias` que el motor ya
devuelve en cada fila (**E16**).

**Propuesta.** Que el filtro de alias se aplique por plan y no aborte: los planes que no
declaran el alias pedido devuelven su fila base, o se omiten con un aviso, en vez de tumbar la
consulta entera.

---

## Estado actual

```bash
python3 05_salida/_herramientas/verificar_prime4api.py \
        03_datos/apis/postmark/datasheet.yaml \
        03_datos/apis/resend/datasheet.yaml
```

21 comprobaciones por Datasheet: 5 de navegación, una por plan de pricing, 5 post-TFM y 7
de evaluación.

| Datasheet | Antes de DV-01 | Ahora | Qué queda |
|---|---|---|---|
| Postmark | 10 OK / 6 ERR (16 compr.) | **11 OK / 10 ERR** (21 compr.) | 10 fallos, **todos DV-02** |
| Resend | 6 OK / 10 ERR (16 compr.) | **8 OK / 13 ERR** (21 compr.) | 5 de DV-02 y 8 de DV-03 |

Una vez normalizada la forma, **cada fallo que queda es una limitación documentada del
modelo, no un defecto de la Datasheet**. Ningún dato se ha alterado para que el motor deje
de protestar: los huecos son reales y el que no sabe expresarlos es el esquema.
