# Fricciones con ACM2YAML v0.3 — Postmark

Cosas del dominio real que el modelo no representa bien. Material directo para el
capítulo de evolución del esquema y candidatas a pull request en
`apis_consumption_model`. Ampliado el 2026-08-03 con la pasada 2 de recolección.

---

## Recuento de recurrencia

| # | Fricción | Postmark | Resend | SendGrid | MailerSend | Vía · veredicto (D-008 · D-042) |
|---|---|---|---|---|---|---|
| F-01 | Un rate que existe pero no tiene valor | ✅ | ⚠️ parcial | ⚠️ parcial | ⚠️ parcial | **PROMOVIBLE por traza** → P-04 (no por recurrencia: en Resend y SendGrid es un valor por defecto con procedimiento para cambiarlo, no un rate inobservable) |
| F-02 | Cuotas por escalón, con sobrecoste por escalón | ✅ | ✅ | ✅ | ✅ | **PROMOVIBLE** (4/4) → P-01 |
| F-03 | CRF multiplicativo entre dimensiones | ✅ | ✅ | ⚠️ acotado | ⚠️ acotado | **PROMOVIBLE** (2/4 + 2 variantes) → P-02 |
| F-04 | Restricciones declaradas pero no aplicadas | ✅ | — | — | ✅ | **PROMOVIBLE** (2/4) |
| F-05 | RPR no serializable | ✅ | — | ✅ | ✅ | **PROMOVIBLE** (3/4) |
| F-06 | Workload acotado por otra métrica | ✅ | ✅ | ✅ | ✅ | **PROMOVIBLE** (4/4) → P-03 |
| F-07 | Add-ons que modifican capacidad | ✅ | ✅ | ✅ | ✅ | **PROMOVIBLE** (4/4), sin propuesta: ver §F-07 del cap. 6 |
| F-08 | El plan es un producto cartesiano | ✅ | ⚠️ parcial | ✅ | ✅ | **PROMOVIBLE** |
| F-22 | Una credencial que solo se gestiona desde la web | ✅ | — | — | — | **PROMOVIBLE** desde el 2026-09-18 — **recurre con Brevo** (2/5): allí la API solo crea claves de una subcuenta Corporate y la propia se genera desde el panel. Cruza por recurrencia, que es la primera vía de B9; **L2 sigue fallando** —la carencia no altera ninguna respuesta de PRIME4API— y por esta vía no hace falta |

Este recuento cubre solo las fricciones que nacieron en esta API; el
inventario completo de las veinte está en `tab:recurrencia` del capítulo 6 y en
`docs/07-estado.md`; la de `03_datos/apis/mailersend/fricciones.md` cubre diecinueve de las veinte, sin F-22. La tabla se añadió el 2026-09-15 al aplicar
D-042, porque la regla B9 exige veredicto de vía para toda fricción.

---

## F-01 · Un rate que existe pero no tiene valor

**Qué pasa.** Postmark documenta el error `429 Rate Limit Exceeded` pero no publica
ningún umbral [F2]. El límite existe contractualmente (te lo aplican) y es inobservable
(no sabes cuál es). En `/email/bulk`, además, el proveedor declara que el ritmo lo
gestiona él: *"Postmark will optimize the sending speed for you"* [F6].

**Qué hace v0.3.** Nada. `max_power` admite rates con valor o no admite el rate. No
hay forma de decir *"existe un rate pero su valor es desconocido"*, que es distinto
de *"no hay rate"*. Una datasheet con `max_power: {}` se lee hoy como "sin límite de
velocidad", que es justo lo contrario de la verdad.

**Consecuencia.** PRIME4API no puede construir la curva de capacidad. Peor: si la
interpretara como "sin límite", daría respuestas optimistas y falsas a las preguntas
Q1–Q5.

**Propuesta.** Un estado explícito por dimensión, del tipo
`status: documented | undocumented | provider_managed | measured`, con
`source: empirical` cuando el valor venga de medición. Enlaza natural con
`datasheet-usage-testing`.

---

## F-02 · Cuotas por escalón, no por valor único — y con overage por escalón

**Qué pasa.** Los tres planes de pago dicen *"Starting at 10,000 emails/month"* [F1].
El panel [F11] revela la estructura completa: una escalera de volumen (10k/$15 ·
50k/$55 · 125k/$115 · 300k/$245 · 700k/$455 · 1,5M/$775) en la que **el propio
overage depende del escalón** ($1.80/1.000 hasta 125k, $1.70/1.000 desde 300k), y
por encima de 1,5M el precio se negocia por correo. El volumen contratado es una
variable con precio no lineal, no una constante del plan.

**Qué hace v0.3.** Una cuota tiene un `value` escalar y un `overage_cost` único. Ni
la escalera ni el overage-por-escalón caben.

**Consecuencia.** Modelado el escalón mínimo (10.000) como si fuera el valor del
plan. Es una simplificación que **falsea la comparación de precios** con proveedores
de planes de volumen fijo, y oculta que el coste marginal del exceso cambia con el
volumen.

**Propuesta.** Permitir que una cuota declare escalones (`tiers`) con precio y
overage propios por escalón, más un escalón `custom` para el tramo negociado.

---

## F-03 · CRF multiplicativo entre dimensiones

**Qué pasa.** `/email/batch` y `/email/batchWithTemplates` aceptan hasta 500 mensajes
por llamada [F3][F7], y cada mensaje admite hasta 50 destinatarios por campo [F3].
Una sola petición puede consumir decenas de miles de emails.

**Qué hace v0.3.** `workload` tiene una única terna `unit / min / max`. Puedo declarar
500 mensajes **o** 50 destinatarios, pero no que el consumo real es el producto de dos
factores anidados.

**Consecuencia.** El CRF declarado (max 500) subestima el consumo real por un factor de
hasta 50 (o 150, según Q2). Como el CRF alimenta las preguntas Q8–Q10 de PRIME4API,
**las respuestas sobre agotamiento de cuota y coste de overage salen mal** para esta
API. No produce un hueco visible sino un número plausible y equivocado.

**Propuesta.** Workloads compuestos, o un multiplicador anidado que exprese
"N unidades de A, cada una con hasta M unidades de B".

---

## F-04 · Restricciones declaradas pero no aplicadas

**Qué pasa.** Postmark recomienda 10 conexiones SMTP concurrentes por IP y dice que
*"no tenemos sistemas para hacer cumplir estos límites"* [F10]; los califica de
*"somewhat arbitrary, and informal"*.

**Qué hace v0.3.** La dimensión de concurrencia queda fuera de v0.3, pero la pregunta
sobrevive al problema técnico.

**La pregunta de fondo, conceptual:** ¿pertenece a la capacidad contractual un límite
que el proveedor declara y admite no aplicar? ACM define la capacidad como propiedad
intrínseca; este caso es un tercer estado: expuesta pero no real. Para el tutor.

---

## F-05 · La dimensión Results Per Request existe en el dominio y v0.3 no la serializa

**Qué pasa.** `GET /messages/outbound` y `GET /messages/inbound` documentan:
*"Number of messages to return per request. Max 500. Count + Offset cannot exceed
10,000 messages"* [F4]. Es la dimensión **RPR** que ACM define conceptualmente — y
con doble estructura: tope por petición (500) **y** tope de profundidad de la
paginación (10.000).

**Qué hace v0.3.** RPR está declarada fuera del alcance de la serialización ("versión
operativa parcial"). No hay dónde ponerla: la he dejado en `data_provenance` y en la
descripción del endpoint.

**Consecuencia.** La capacidad de *consulta* de la API queda invisible para las
herramientas. Y el tope de profundidad (10.000) ni siquiera encaja en el concepto RPR
simple: es una restricción sobre la ventana acumulada.

**Propuesta.** Serializar RPR en la próxima versión del esquema (era ya trabajo futuro
declarado de v0.3); considerar un campo adicional para topes de paginación. Este es el
caso real que la evolución v0.3→v0.8 necesitaba (C-02).

---

## F-06 · Un workload acotado por otra métrica, no por un entero

**Qué pasa.** `/email/bulk` no tiene tope numérico de mensajes: *"as many recipients
as you need, as long as your total payload (including attachments) stays under
50 MB"* [F5]. Y los MBs se miden **tras** base64 [F8], así que el tope efectivo en
contenido útil depende de la codificación.

**Qué hace v0.3.** `workload.max` es un entero en la unidad del workload. Aquí el
máximo en `emails` no existe: la cota está en OTRA métrica (`MBs`). He dejado `max`
vacío con comentario, que es honesto pero invisible para las herramientas.

**Consecuencia.** Igual que F-01: un hueco que se lee como "sin límite". Y PRIME4API
no puede razonar sobre el endpoint más potente de la API.

**Propuesta.** Permitir que `workload.max` referencie una cota en otra métrica
(`max_by: {unit: MBs, value: 50}`), o workloads multi-métrica. Se relaciona con F-03:
ambos piden que el CRF deje de ser una terna escalar.

---

## F-07 · Add-ons que modifican dimensiones de capacidad

**Qué pasa.** Tres add-ons de pago tocan capacidad [F1][F11]: **Dedicated IPs**
(50 $/mes por IP) exige *"sending 300,000 emails per month or more"* — un add-on
condicionado por una dimensión Volume, y además **por solicitud**, no autoservicio
[F11]; **Custom Activity Retention** cambia la ventana consultable de la Messages
API de 45 días a un conjunto **discreto** de pasos (0/7/28/45/90/180/365 días, con
45 gratis por defecto y efecto solo sobre mensajes futuros) [F9][F11]; **DMARC
Monitoring** (14 $/mes/dominio). Y el panel añade el remate: los add-ons **solo
pueden contratarse desde el tier Pro** — *"Optional Add-ons — Pro and Platform
plans only"* [F11]: un add-on condicionado por el tier.

**Qué hace v0.3.** La Datasheet no tiene bloque de add-ons: el esquema los deriva a
Pricing2YAML (canal web), que este TFM no modela por decisión D-001.

**Consecuencia.** Capacidad condicionada por add-ons queda fuera del canal API. Es un
argumento de peso para el mecanismo de vinculación iPricing↔Datasheet que Ramón dejó
como trabajo futuro — anotar en Trabajo Futuro, no resolver aquí.

---

## F-08 · El "plan" es un producto cartesiano, y la superficie de la API depende del tier

**Qué pasa.** El panel [F11] revela que lo que la página pública presenta como tres
planes (Basic/Pro/Platform) son en realidad dos ejes independientes: un **escalón de
volumen** (la escalera de F-02) y un **tier funcional**. El tier fija límites de
recursos (usuarios 4/6/∞, servers 5/10/∞, streams 15/30/∞, dominios de firma
5/10/∞) y — lo más grave para el modelado — **qué partes de la API existen**:
*"Stats & Open/Link Tracking APIs"* y *"All Event Webhooks"* solo están incluidas
desde Pro, e *"Inbound email processing"* también. Dos clientes del mismo proveedor
tienen superficies de API distintas.

**Qué hace v0.3.** `plans` es una lista plana: cada plan tiene un precio, una cuota
y unos endpoints. Puede aproximar la pertenencia de endpoints por tier (listando
endpoints distintos por plan), pero no puede expresar tier × escalón sin enumerar
las ~18 combinaciones, ni declara límites de recursos (servers, streams, usuarios)
que no son dimensiones de consumo pero condicionan la capacidad total alcanzable.

**Consecuencia.** Nuestra datasheet modela los tres tiers como "planes" con la cuota
del escalón mínimo: una proyección defendible pero con pérdida. Y las preguntas
funcionales del método de comparación (C-04) necesitan exactamente esto: *¿qué API
me da acceso a estadísticas por API en el plan que puedo pagar?* hoy no se puede
responder desde la Datasheet.

**Propuesta.** Separar en el esquema el eje funcional (tier) del eje de volumen
(escalón), o como mínimo permitir marcar endpoints como no disponibles por plan; y
considerar los límites de recursos como una familia aparte de restricciones. Es la
fricción con más recorrido conceptual para la evolución v0.3→v0.8 junto a F-03.

---

## F-22 · Una credencial que solo se gestiona desde la web

**Qué pasa.** El panel del servidor tiene la pestaña `"Server API tokens"` con
`"Generate another token"` y `"Delete"`: desde la web se añaden y se retiran credenciales de un
servidor que ya existe [F14]. La referencia de API **no publica ningún endpoint equivalente**
[F13]. Lo
único programable es `POST /servers`, que crea un servidor **nuevo** y devuelve sus `ApiTokens`
en la respuesta; para rotar la credencial de un servidor en uso hay que entrar al panel. El
listado de códigos de error del overview refuerza el hueco: anuncia una familia
`"SMTP TOKENS — new"` (1450–1460) que no tiene página en el índice de la referencia, y
`/developer/api/smtp-tokens-api` devuelve `"Oops, page not found"`.

**Qué hace v0.3.** Nada: el esquema describe precios, cuotas y límites, no qué operaciones
expone el producto por cada canal. El único campo que roza el asunto es `type`, y es un juicio
de una sola palabra para todo el producto. Con el test C2 (D-031) esta asimetría se detecta,
pero como la operación 4 no es eliminatoria, el `type` sigue `api_first` y la observación no
tiene dónde vivir dentro del modelo.

**Consecuencia.** Dos productos con el mismo `type` pueden exigir trabajo manual distinto. Una
pregunta operativa razonable —*¿puedo rotar credenciales sin intervención humana?*— no se
responde desde la Datasheet, y para una organización que automatiza la rotación es un criterio
de selección, no un detalle.

**Alcance medido.** Solo Postmark, 1 de 4: Resend tiene `POST /api-keys` con Update y Delete,
SendGrid `POST /v3/api_keys` con Update y Delete, y MailerSend `POST/PUT/DELETE /v1/token`. No
cruza el umbral de promoción de D-008 con el catálogo actual; se anota para volver a mirarlo con
ocho APIs.

**Propuesta.** Registrar por operación —no solo por producto— qué canal la ofrece, aunque sea
con una lista corta de operaciones del dominio y un valor por canal (API / web / ambos). Es la
forma granular del juicio que hoy resume `type`.

---

## Observaciones sobre el propio repositorio (candidatas a PR)

**O-01 · `workload` inconsistente entre la guía y el ejemplo canónico.** El README
define `workload` como objeto `{unit, min, max, description}`; `mailersend_v03.yaml`
lo serializa como **lista** de objetos. Si la lista es la forma buena, resolvería a
medias F-06 (multi-métrica); si no, el ejemplo canónico está desalineado. Preguntar
antes de abrir PR.

**O-03 · El esquema no tiene herencia entre planes.** Cuando varios planes
comparten endpoints idénticos, la práctica canónica (ejemplo de MailerSend) es
duplicar los bloques enteros, descripciones incluidas — el único mecanismo de
reutilización es el wildcard `/*`, y solo opera dentro de un plan. El canal web sí
tiene herencia (en Pricing2YAML los planes heredan valores por defecto y los
sobrescriben): trasladar esa semántica a la Datasheet eliminaría el *boilerplate*
que el producto tier×volumen multiplica (refuerza F-08). Esta datasheet sigue la
práctica canónica: duplicación completa.

**O-02 · El ejemplo canónico viola la convención de nombres del README.** La guía
dice *"NUNCA incluir valores numéricos en el nombre de la clave"* y el ejemplo usa
`quota_500_emails_month`, `rate_120_min`, etc. PR trivial de documentación o de
ejemplo.
