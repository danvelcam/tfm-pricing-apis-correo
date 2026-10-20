# Fricciones con ACM2YAML v0.3 — MailerSend

Cuarta API del catálogo y la segunda que ya estaba modelada en el repositorio de la guía
(`mailersend_v03.yaml`, 2026-03-19): es, además, **el ejemplo canónico del README** para
los aliases de reputación. Con cuatro APIs, **trece fricciones cruzan el umbral D-008**
(promoción con ≥2 APIs); tres de ellas entran en él con esta API (F-12, F-14, F-15). La cifra es
de recurrencia y **F-18 no cuenta en ella**, porque aparece en una sola API; su intento por la
**vía de traza** (D-042) tampoco prosperó, porque la condición L2 no se cumple. La pasada
añade **una fricción nueva (F-18)**; otras dos candidatas quedaron, tras la verificación
independiente del mismo día, una en suspenso (F-17, pendiente de DISC-11; retirada el 2026-10-18 por B17 al cerrarse DISC-11 en peticiones) y otra absorbida por
fricciones existentes (F-19 → F-11 / F-18). Sus números no se reutilizan. El sondeo [E1] del
2026-09-09 (cuenta Sandbox no aprobada, coste cero; el mismo script ejecutado dos veces, a las
19:02 y a las 19:13 UTC) **hace recurrir F-04** (el lote entra con 202 y un remitente que
`/v1/email` rechaza en el acto; dos lotes en dos ejecuciones) y **da evidencia medida a F-18**
(429 a 10/min y 1/min por estado de cuenta, reproducido): con F-04 en 2/4 el recuento pasa a
**catorce fricciones sobre el umbral D-008**. F-18 sigue sin sumar en esa cuenta —aparece en una sola
API— y tampoco se promueve por la **vía de traza** (D-042): la condición L2 no se cumple. La primera ejecución abrió **F-20** como candidata
(«la cuota diaria de peticiones no descontó ninguna de las 17 peticiones»); la segunda la
**retiró** el mismo día: las 17 aparecieron descontadas (DISC-17 resuelta a favor de la
documentación) y lo que queda —el contador expuesto va por detrás del que se aplica— es la
observación **O-11**, no una fricción del esquema. Su número tampoco se reutiliza.

La **tanda 2 del sondeo** (2026-09-10, 13 casos) y la **adopción de los aliases de estado**
(D-025 y regla D7, el mismo día) cambian tres cosas de esta lista. F-04 deja de apoyarse solo en
la cabecera de aceptación: el estado final de los dos lotes dice `validation_errors_count: 5` y
ningún correo enviado. F-18 pasa de carencia a **carencia acotada**, porque el mecanismo de
aliases absorbe **dos de los tres** cambios por estado que la sección enumera —el de reputación y
el de aprobación— y la datasheet ya los declara; el tercero, la antigüedad, no tiene cifra y por
D7 no genera alias. Lo que el mecanismo no absorbe queda escrito con precisión. Y aparece
una observación nueva, **O-12**: una clave
desconocida dentro de un bloque de endpoint no da error, se convierte en alias y desplaza los
límites reales del endpoint sin que ninguna de las tres comprobaciones del ciclo lo detecte.

Pasada 1 · 2026-09-08 (documentación pública por cuatro lentes + volcados con navegador +
panel con cuenta propia en Sandbox; verificación independiente y corrección el mismo día, ver
`REVISION.md`) · **Sondeo [E1] · 2026-09-09** (dos ejecuciones, 18 + 19 casos; `fuentes.md`
[E1], DISC-17 resuelta, DISC-18 y DISC-19 abiertas) · **Sondeo [E1] tanda 2 · 2026-09-10**
(13 casos; DISC-18 acotada en 1, DISC-19 reformulada, F-04 probada con el estado final) ·
**Aliases de estado aplicados · 2026-09-10** (D-025, regla D7; O-08 cerrada, O-12 abierta).

---

## Recuento de recurrencia

| # | Fricción | Postmark | Resend | SendGrid | MailerSend | Vía · veredicto (D-008 · D-042) |
|---|---|---|---|---|---|---|
| F-01 | Rate que existe sin valor | ✅ | ⚠️ parcial | ⚠️ parcial | ⚠️ parcial | **PROMOVIBLE por traza** → P-04 (no por recurrencia: ver abajo) |
| F-02 | Volumen contratado con sobrecoste variable | ✅ | ✅ | ✅ | ✅ | **PROMOVIBLE** (4/4) |
| F-03 | CRF multiplicativo | ✅ | ✅ | ⚠️ acotado | ⚠️ acotado *(el proveedor publica el total: 35.000)* | **PROMOVIBLE** (2/4 + 2 variantes) |
| F-04 | Restricciones declaradas y no aplicadas | ✅ | — | — | ✅ *(variante: aplicación diferida; el lote entra con 202 y un remitente que `/v1/email` rechaza en el acto, y el estado final de los dos lotes da `validation_errors_count: 5`, [E1] tandas 1 y 2)* | **PROMOVIBLE** (2/4) |
| F-05 | RPR no serializable | ✅ | — | ✅ | ✅ | **PROMOVIBLE** (3/4) |
| F-06 | Workload acotado por otra métrica | ✅ | ✅ | ✅ | ✅ | **PROMOVIBLE** (4/4) |
| F-07 | Add-ons que modifican capacidad | ✅ | ✅ | ✅ | ✅ | **PROMOVIBLE** (4/4) |
| F-08 | El plan es un producto cartesiano | ✅ | ⚠️ parcial | ✅ | ✅ | **PROMOVIBLE** |
| F-09 | La datasheet no dice qué parte sigue vigente | — | ✅ | ✅ | ✅ *(contraste con 2026-03-19, con fechas)* | **PROMOVIBLE** |
| F-10 | Dos productos, dos unidades de consumo | — | ✅ | ✅ | ⚠️ parcial *(WhatsApp como catálogo aparte; el SMS incluido en el plan sí cabe en v0.3)* | **PROMOVIBLE** (Resend, SendGrid) |
| F-11 | Límites de recursos por plan | ✅ | ✅ | ✅ | ✅ | **PROMOVIBLE** (4/4) |
| F-12 | La recepción consume la cuota de envío | *(verificar)* | ✅ | — *(no documentado)* | ✅ *(literal)* | **PROMOVIBLE** (2/4) |
| F-13 | El sobrecoste es opcional y no existe en Free | *(verificar)* | ✅ | ✅ | ✅ *(y tope voluntario del cliente)* | **PROMOVIBLE** |
| F-14 | El plan tiene fecha de caducidad | — | — | ✅ | ✅ *(la prueba cae a Free, no a cero; el trial no entra en `plans`)* | **PROMOVIBLE** (2/4) |
| F-15 | Dos canales, dos workloads para la misma cuota | — | — | ✅ | ✅ *(SMTP: concurrencia por plan y CRF distinto en la cuota diaria)* | **PROMOVIBLE** (2/4) |
| F-16 | El sobrecoste tiene tope del proveedor | *(verificar)* | *(verificar)* | ✅ | — *(solo tope voluntario del cliente)* | **PROMOVIBLE por traza** → P-07 (L2 ejecutada, `prime4api_ejecucion_d042/tope_sobrecoste/`); 1 API |
| F-17 | Un tercer tope sin nivel de enganche (dos cuotas de la misma unidad, dos ventanas) | — | — *(dos niveles usados: mensual en el plan, diaria en el endpoint)* | — | ❌ DISC-11 cerrada en peticiones (D17) | Retirada (B17, 2026-10-18) |
| F-18 | La capacidad depende del estado de la cuenta, no del plan | *(verificar: test mode, pending approval)* | *(verificar: trusted senders)* | ⚠️ *(403 por peticiones malformadas, sin cifra)* | ✅ nueva, **medida y aplicada** *(429 a 10/min y 1/min en cuenta no aprobada, [E1]; tres aliases de estado en el YAML desde D-025)* | Sin promover — **L2 no cumplida** (el fallo del motor es suyo, no del esquema); 1 API (+1 parcial, +2 a verificar) |
| F-19 | Cuota de cardinalidad: destinatarios únicos sin ventana | — | — | — | absorbida por F-11 / F-18 | — |
| F-20 | La cuota de peticiones no cuenta lo que la API contesta como dice que cuenta | — | — | — | retirada → O-11 *(la segunda ejecución de [E1] descontó las 17; DISC-17 resuelta)* | — |
| F-21 | **Un cupo que se gasta con intentos que no envían nada.** El cupo de destinatarios únicos de Sandbox (dos, `"You can send to any 2 recipients in Sandbox mode, until your account is approved"` [F37]) no es un tope por petición: es de la cuenta, se consume con direcciones **probadas** aunque la petición se rechace, no se repone, no es consultable (`GET /v1/recipients` devuelve 0) y solo lo levanta una aprobación que el panel no ofrece. Las tandas 1 y 2, diseñadas «a coste cero», lo agotaron sin enviar un solo correo, y eso dejó **Q9 sin poder medirse** *(rebaja del 2026-09-23: el gasto por intentos es inferencia, porque el cupo se encontró alcanzado sin envíos y no se determinó qué petición lo gastó; así lo tratan §5.2 y P-08)* | — | — | — | **nueva, medida en la tanda 3 (2026-09-14)** | **PROMOVIBLE por traza** → P-08 (L2 ejecutada y archivada, `prime4api_ejecucion_d042/cupo_destinatarios/`); O-13 |

Nueva en esta API: **F-18** (con evidencia medida desde [E1], reproducida en la segunda
ejecución). **F-04 recurre** con [E1] (2/4, promovible como variante «aplicación diferida»; dos
lotes aceptados con 202 en dos ejecuciones). **F-20** se abrió como candidata con la primera
ejecución de [E1] (DISC-17) y se **retira** con la segunda: la cuota descuenta cada petición como
dice la documentación; el hallazgo que sobrevive (el contador expuesto se actualiza por lotes y con
retardo) es la observación **O-11**. **F-17** quedó en suspenso hasta que DISC-11 se resolvió (D17, 2026-10-18) y se retiró por B17;
**F-19** se absorbe en F-11 (recurso `unique_recipients = 2`) y F-18 (cambia con la aprobación);
ninguno de los tres números se reutiliza. Observaciones nuevas: **O-08**, **O-09**, **O-10**,
**O-11**. Discrepancia con PRIME4API nueva: **DV-04** (en `03_datos/DISCREPANCIAS_v03.md`).

---

## F-01 · Un rate que existe pero no tiene valor — recurrencia PARCIAL

**Qué pasa.** MailerSend es la API que **más caudales publica**: 60/min general, 120/min en
`/v1/email`, 10/min en `GET /v1/activity`, y el lote por plan (10 / 15 / 30 / 60) [F20][F21]
[F31]. Pero quedan dos caudales que existen y no tienen cifra: el de las cuentas recién
ascendidas (*"Newly upgraded accounts may have a lower rate limit"* [F31]) y el del canal SMTP,
que una página cifra en 120/min [F6][F20] y otra describe como *"based on IP address and these
tend to be lower than available through our API"* [F27] (DISC-10). Y dos estados de reputación,
`Rebuilding` y `Sending paused`, de los que no se publica si tienen caudal propio o capacidad
cero: de `Sending paused` solo se dice que *"Activities from your account have been temporarily
halted"* y de `Rebuilding` nada sobre límites [F42].

**Por qué es parcial.** Para los endpoints modelados hay valor en verde. Lo que falta son
los **estados**, no los endpoints; eso es F-18, no F-01. Se anota como parcial y no cuenta
como ocurrencia plena, igual que en Resend y SendGrid.

**Un matiz nuevo.** Dos páginas publican el lote como **valor único** de 10/min y lo llaman
*"default"* [F20][F39]; otras dos lo publican **por plan** [F21][F31] (DISC-08). Cuatro
fuentes oficiales, dos cifras para el mismo plan. Es la primera API del catálogo con un rate
publicado por plan, y también la primera en que el proveedor se contradice sobre si lo es.
**Cerrado el 2026-09-14** con la regla **E4** (Q4, D-028): una página que se declara *default*
no contradice una tabla por plan, así que manda el desglose y la datasheet lleva 15 y 30 en
verde. DISC-08 queda cerrada; lo que la fricción registra ya no es el color, es que el
proveedor publique las dos formas a la vez.

---

## F-02 · Cuotas por volumen contratado, con sobrecoste variable — RECURRE ✅ (4/4)

**Qué pasa.** La página de precios tiene un selector (*"How many emails do you plan to
send?"*) que reescribe las tarjetas de Starter y Professional: cinco volúmenes en Starter
(50.000 → 1.000.000, $35 → $600) y siete en Professional (50.000 → 2.000.000, $110 →
$1.600) [F1]. El sobrecoste **baja al subir el volumen** dentro del tier (Starter $1.30 →
$1.00; Professional $1.30 → $0.50) y, a igual volumen, **difiere entre tiers** desde 250.000
(Starter $1.10, Professional $1.00). El centro de ayuda lo dice en prosa: *"The price per
1,000 emails decreases the larger your plan size."* [F2].

**Qué hace v0.3.** Un `value` y un `overage_cost` por cuota. La datasheet modela el primer
volumen (50.000) y la escalera entera vive en el provenance, como en SendGrid.

**Lo que añade MailerSend.** La escalera está **oculta tras JavaScript**: `WebFetch` solo
ve `"$ /month"` vacío; hubo que accionar el selector con el navegador [F1]. Y el tope de
Starter no coincide entre el selector (1.000.000) y las páginas de feature (500.000
[F5][F13]); desde el 2026-10-18 manda el selector por D17 y el 500.000 es incoherencia del
pricing (DISC-06, cerrada). Cuatro de cuatro: la propuesta de `tiers` por cuota es ya la regla del
dominio, no una excepción.

---

## F-03 · CRF multiplicativo entre dimensiones — recurrencia ACOTADA ⚠️

**Qué pasa.** `/v1/bulk-email` admite 500 objetos de correo y cada objeto hasta 50 `to`,
10 `cc` y 10 `bcc`. Aquí el proveedor **hace la multiplicación por escrito**: *"500 individual
email objects in a single request, each containing up to 50 TO recipients, 10 CC, and 10 BCC,
for a total of 35,000 emails"* [F49]. Es a la vez la forma más extrema del catálogo (35.000
destinatarios por petición, frente a 1.000 en SendGrid) y la única frase oficial que define
la unidad: «emails» son **destinatarios**, no objetos ni peticiones.

**Por qué es acotada y no una ocurrencia plena.** El mismo criterio que en SendGrid: cuando el
proveedor publica el tope total, la terna escalar `unit/min/max` de v0.3 **es correcta**
(`max: 35000` 🟢) y forzar el recuento le quitaría valor. Sin [F49] el esquema habría producido
un 500 plausible y falso; con ella, no. El envío individual (50 + 10 + 10 sin frase de total) no
es CRF multiplicativo sino aditivo por campo (regla D4) y tampoco rescata la ocurrencia plena.

**Lo que aporta al capítulo 6, junto a SendGrid.** Un segundo proveedor que publica el total
demuestra que el dato existe y es publicable. El matiz nuevo de MailerSend: **el mismo proveedor
publica el total del lote y calla el del envío simple** — el 35.000 es literal y el 70 es la suma
que el lector tiene que hacer (D4 → ámbar).

**Lo que añade MailerSend.** La misma petición consume **1** de la cuota diaria de
peticiones y hasta **35.000** de la cuota mensual de emails [F20][F49]. Dos cuotas con dos
unidades sobre un solo endpoint: v0.3 lo expresa (cuota del plan en `requests`, cuota del
endpoint en `emails`, workload en `emails`) y PRIME4API deriva la dimensión `requests`
dividiendo por el workload. Funciona; lo que no funciona es el 70 del envío individual, que
no es literal en ninguna página (ver arriba).

---

## F-04 · Restricciones declaradas y no aplicadas — RECURRE ✅ (2/4, variante «aplicación diferida», probada con el estado final)

**Qué pasa.** La documentación declara que el remitente debe ser de un dominio verificado
(*"Must be a verified domain or a subdomain from a verified domain."* [F21]; error *"The
from.email domain must be verified in your account to send emails. #MS42207"* [F20]) y
`/v1/email` la aplica en el acto: 422 en las diez peticiones del sondeo [E1]. Pero
`/v1/bulk-email`, con **el mismo remitente**, contesta **202** *"The bulk email is being
processed."* y devuelve un `bulk_email_id` (`6aa1ad527e48ed427f18cf4e` a las 19:02 UTC y
`6aa1affd1e3217ac0dd87aa1` a las 19:14 UTC del 2026-09-09: dos ejecuciones, dos lotes aceptados).
La restricción está declarada; en el momento de la petición no se aplica. La propia referencia lo
anuncia: *"each email validation is done after the request and then the result is stored"* [F21].

**Y la validación diferida los rechazó todos.** La tanda 2 del sondeo (2026-09-10) consultó
`GET /v1/bulk-email/{id}` de los dos lotes: los dos responden 200 con `state: "completed"`,
`total_recipients_count: 5`, `suppressed_recipients_count: 0` y **`validation_errors_count: 5`**,
con los cinco objetos marcados en `errors.to` (*"You have reached sandbox account unique
recipients limit. #MS42225"*) y en `errors.from.email` (`#MS42207`). Cinco objetos aceptados,
cinco rechazados, **ningún correo enviado**, y el cliente solo se entera si pregunta. La fricción
deja de apoyarse en la cabecera de aceptación: está probada por los dos extremos, el 202 de
entrada y el estado final.

**Por qué es F-04 y en qué se diferencia de Postmark.** En Postmark el proveedor publica un
límite (10 conexiones SMTP) y admite que no lo hace cumplir: la restricción existe **solo en el
papel**. Aquí la restricción se cumple, pero **no en la respuesta**: un 202 que ACM leería como
«capacidad consumida» puede ser un lote que no enviará nada. Es el mismo tercer estado
—expuesta pero no real en el momento de la petición— con otro mecanismo (diferido en vez de
no aplicado). Se cuenta como recurrencia en variante; si el autor prefiere abrir un número aparte
para «aplicación diferida», el material está aquí.

**Qué hace v0.3.** Nada: un workload con `max` y una cuota con `value` presuponen que la
respuesta de aceptación de la API mide el consumo. Para el lote, el consumo real de la cuota
mensual (en emails) solo se conoce **después**, consultando `GET /v1/bulk-email/{id}`
(`total_recipients_count`, `validation_errors_count` [F21]) — que es exactamente lo que hizo la
tanda 2, y lo que ningún campo del esquema puede representar: la datasheet no tiene dónde decir
que la respuesta que mide el consumo no es la de la petición.

**Consecuencia.** La medición del escalón 3 no puede usar el código HTTP del lote como
evidencia de nada: el 202 con 5 objetos no demostraba que el tope Sandbox fuera 5, solo que la
petición entró. El tope de 5 lo fijó después una respuesta de validación de verdad, el 422
*"The number of email objects must not be greater than 5. #MS42229"* de la tanda 2, no el 202. Y
para un cliente que mide su consumo por respuestas, el lote sobrestima lo consumido: aquí en cinco
de cinco objetos. En el capítulo 6: segunda API (Postmark, MailerSend) en que el «límite
declarado» y el «límite aplicado en la respuesta» no coinciden, y la única de las cuatro en que
se ha medido el desenlace.

---

## F-05 · Results Per Request no serializable — RECURRE ✅

**Qué pasa.** `GET /v1/activity/{domain_id}` pagina con `limit` 10–100, `page` *"Min: 1,
Max: 1000"* y una ventana temporal acotada por la retención del plan (*"The allowed timeframe
depends on your plan's data retention limit (1–30 days)"*) [F33]; tiene además su propio
caudal, 10/min [F20], y dos estados (`deferred`, `suppressed`) *"available on the Starter
plan and above"* [F33].

**Qué hace v0.3.** Nada: RPR sigue fuera. Aquí la capacidad de consulta depende de **tres**
cosas que el esquema no tiene juntas: paginación, retención (B4) y plan (F-08).

---

## F-06 · Un workload acotado por otra métrica — RECURRE ✅ (4/4)

**Qué pasa.** El lote publica *"Total size of the JSON payload 50MB"* [F21]; el envío
individual publica 2 MB para `text` y `html` y 25 MB por adjunto decodificado, pero **no un
tamaño total de petición** [F21][F20][F39]. El workload del lote lleva dos entradas
(`emails` y `MBs`); el del envío individual solo una, con el hueco en `not_found`.

**Lo que destapa.** La entrada en `MBs` del lote **tumba `curve.accumulated` en PRIME4API**
(DV-04): un escenario con un solo rate y sin cuota en esa unidad cae en un `RatePlotter`
que divide milisegundos por un `TimeDuration`. SendGrid no lo destapó porque su rate está
referenciado dos veces (plan y endpoint) y esquiva ese camino. Ningún dato se ha quitado
para que el motor pase.

---

## F-07 · Add-ons que modifican dimensiones de capacidad — RECURRE ✅ (4/4)

**Qué pasa.** Retención de actividad hasta 365 días con **precio por volumen contratado**
(de $5 a $625 al mes según plan × días) [F3][F4]; dominios extra a $4/mes **con tope de 50**
y solo desde Starter [F3]; IP dedicada a $50/mes con **tres planes mínimos distintos** según
la página (Starter [F9], Professional [F3], Enterprise [F1]) y dos umbrales (500.000/mes
[F10], 100.000/semana [F3]); por D17 manda la página de precios, solo Enterprise, y el resto es
incoherencia del pricing (DISC-04, cerrada el 2026-10-18); créditos de verificación con escalera propia de diez
tramos [F3]; WhatsApp y números de teléfono como productos aparte [F1].

**Qué hace v0.3.** Sin bloque de add-ons (D-001). Cuatro de cuatro. El add-on de retención
es además F-08 sobre un add-on: **el mismo add-on cuesta distinto según el volumen del plan**.

---

## F-08 · El plan como producto cartesiano — RECURRE ✅

**Qué pasa.** En cuatro formas:

1. **Tier × volumen** en el selector de precios [F1], como en SendGrid.
2. **La superficie del endpoint cambia con el tier**: `/v1/bulk-email` desde Hobby
   (*"All in Free, plus: … Bulk emailing"* [F1], *"This feature requires a Hobby plan or
   higher"* [F20]); `in_reply_to` y `references` *"available to paid plan accounts only"*;
   `headers` y `list_unsubscribe` *"available to Professional and Enterprise accounts only"*
   [F21]; logs de API solo Professional [F43][F53]; inbound bloqueado en Sandbox desde el
   panel [F53].
3. **La superficie cambia con el estado** (aprobación, reputación): es F-18.
4. **El «ilimitado» tiene cifra**: *"Unlimited*"* en la página de precios remite a
   *"*Learn more about plan limits."* y allí son 1.000 dominios, 1.000 usuarios, 5.000
   plantillas y 5.000 webhooks [F1][F2].

**Qué hace v0.3.** `plans` plano con `endpoints` por plan: la forma 2 cabe omitiendo el
endpoint (así va `/v1/bulk-email` en Free); las formas 3 y 4 no caben.

---

## F-09 · Una datasheet no puede decir qué parte sigue vigente — RECURRE ✅

**Qué pasa.** El contraste con `mailersend_v03.yaml` (2026-03-19, 28 filas en `fuentes.md`)
da divergencias **con fecha**:

| Dato | Modelado previo (2026-03-19) | Hoy (2026-09-08) | Qué cambió |
|---|---|---|---|
| Precio Hobby / Starter / Professional | 5.60 / 28.00 / 88.00 | $7 / $35 / $110 mensual; $6.30 / $31.50 / $99 anual [F1][F2] | 5.60 = 7 × 0,8: el descuento anual pasó del 20 % [F47] al 10 % [F1]; los valores viejos **siguen publicados** en una página de feature [F11] (DISC-03) |
| Sobrecoste Hobby | 1.20 / 1.000 | $1.50 / 1.000 [F1][F2][F40] | +25 % |
| Sobrecoste Starter y Professional | 0.95 / 1.000 | $1.30 / 1.000 en 50K, decreciente por volumen [F1] | 0.95 es exactamente el valor del 2024-07-29 [F47]: el modelado previo arrastraba una cifra de 2024. Tres valores con fecha: 0.90 → 0.95 → 1.30 |
| Plantillas de Hobby | — | 3 → 10 el *"Aug 24, 2026"* [F17] | Único cambio de límite fechado |
| Términos | — | *"Last updated on August 31, 2026"* [F44] | Posteriores al modelado previo |

Y dos hechos que no son un cambio sino la **negación de la vigencia**: el proveedor mantiene
**dos ofertas publicadas el mismo día** (/pricing con 10 % y $1.30; /features/… con 20 % y
$0.90 [F11], DISC-03), y se reserva por contrato *"in-app beta pricing experiments that offer
different rates to some users"* [F44]. Ninguna `date` por documento puede decir cuál de las
dos vio el lector ni si su cuenta está en el experimento.

Dos divergencias más con el modelado previo **no** entran en esta tabla porque no hay
evidencia de que sean cambios en el tiempo: el rate del lote (10 en los cuatro planes frente a
10 / 15 / 30 hoy) — el propio `mailersend_v03.yaml` define `rate_15_min` y `rate_30_min` sin
usarlos (O-09), así que el modelador ya conocía las cifras en marzo — y la ventana `rolling`,
que ninguna fuente de hoy ni de entonces dice. Están en el contraste de `fuentes.md` (filas 6,
7 y 16) como divergencias de modelado.

**Qué hace v0.3.** Un `date`. Tres de cuatro (Resend, SendGrid, MailerSend).

---

## F-10 · Un SaaS con varios productos y varias unidades de consumo — recurrencia PARCIAL ⚠️

**Qué pasa.** SMS (100 / 150 incluidos por plan, $1.40 por 100 extra [F1][F48]), WhatsApp
(lanzado el *"Sep 1, 2026"*, $0.0050 por mensaje [F1][F17]) y créditos de verificación
(10 / 100 / 100 / 400 incluidos, $0.01 por crédito [F2][F3]) conviven en la misma cuenta.

**Lo que v0.3 no expresa.** Solo **WhatsApp** tiene la forma de F-10 en Resend y SendGrid: un
catálogo de precio aparte, con su propio selector (*"Select a plan"*, *"1,000 messages"* …
*"$5.00"*, *"Extra usage: $2.50/1,000"* [F1]) y facturado además por un tercero (*"you will also
be directly billed by Meta Platforms, Inc."* [F44] 2.5). Eso no cabe en una lista plana de
`plans`.

**Lo que este TFM decide no modelar.** El SMS **no se contrata aparte**: viene dentro de
Starter y Professional, con su cuota, su sobrecoste y la cuota diaria de peticiones común. Y
v0.3 **sí lo expresa**: el ejemplo canónico `mailersend_v03.yaml` de Gavira/Ruiz lleva
`consumption_units: sms`, `quota_100_sms_month` y el endpoint `v1/sms` dentro del mismo plan.
Lo que lo deja fuera de esta datasheet es la regla A1 del catálogo (producto modelado: el
transaccional), no una carencia del esquema. Por eso la ocurrencia es parcial: el ejemplo de la
guía demuestra que varias unidades en un plan caben; el coste visible de A1 (el plan Starter
real incluye 100 SMS y la datasheet no lo dice) es una decisión de alcance, no una fricción.

**Qué hace v0.3.** Un `associated_saas`. Sigue promovible por Resend y SendGrid.

---

## F-11 · Límites de recursos por plan, que no son consumo — RECURRE ✅ (4/4)

**Qué pasa.** Tokens (1 / 3 / 50 / 1.000), webhooks (1 / 5 / 50 / 5.000), dominios (1 / 1 /
10 / 1.000), plantillas (1 / 10 / 250 / 5.000), usuarios (1+1 / 5 / 5 / 1.000), usuarios SMTP
(1 / 1 / 50 / 1.000), rutas inbound (1 / 1 / 50 / 100.000), identidades de remitente (- / - /
50 / 5.000) [F2]; con **dos cifras** para los webhooks de Hobby (1 en la página de precios,
5 en el centro de ayuda; por D17 queda 1 y el 5 es incoherencia del pricing, DISC-05). Y un límite de recursos que a su vez tiene un límite de
compra: 50 dominios extra como máximo [F3].

**Qué hace v0.3.** Nada; provenance y `features.md` (B3). Cuatro de cuatro.

---

## F-12 · La recepción consume la cuota de envío — RECURRE ✅ (2/4)

**Qué pasa.** *"Any inbound emails forwarded or posted to your endpoint URL are counted
against your monthly usage. One forward is equivalent to one sent email."* [F7]; *"Inbound
emails are free to receive but are counted towards your monthly usage when forwarded or
posted to your endpoint URL."* [F8]. Recibir es gratis; **reenviar** descuenta.

**Qué hace v0.3.** La cuota es de un endpoint de envío; el consumo por un evento entrante
no tiene dónde declararse. Segunda API con la fricción (Resend, MailerSend): **promovible**.
Matiz nuevo: el consumo no es por recepción sino por **acción configurada** (forward o
POST), así que el CRF depende de la configuración de la ruta, no de la petición.

---

## F-13 · El sobrecoste es opcional y no existe en Free — RECURRE ✅

**Qué pasa.** *"(this doesn't apply to Sandbox mode, the Free plan, or the Professional
trial, none of which allow extra usage)"* [F2]; el Free **pausa** el envío al agotar la cuota.
Y dos variantes nuevas: el cliente puede **fijar un tope de gasto** (*"you can set a limit to
prevent overusage"* [F2]; *"If you reach the billing limit, your transactional messages will
stop sending"* [F40]), lo que convierte un plan con sobrecoste en un plan de tope duro por
configuración; y el contrato admite **precios distintos por usuario** [F44].

**Qué hace v0.3.** `overage_cost` está o no está. La propuesta `overage_mode` de Resend
necesita un valor más: `customer_capped`.

---

## F-14 · El plan tiene fecha de caducidad — RECURRE ✅ (2/4)

**Qué pasa.** El **Professional trial** dura 14 días y después *"your account moves to the
Free plan"* [F37]; es único por cliente (*"Each customer can activate one Professional
trial."*). A diferencia de SendGrid, la capacidad no cae a cero: cae a otro plan. **Sandbox**
no caduca (*"There's no time limit"* [F37]) pero no es un plan.

**Lo que no cuenta aquí.** El token de API con *"Expires at: 30 Sep 2026"* [F53] y el dominio de
prueba que *"are automatically deleted if not in use for 30 days"* [F53] son **recursos con ciclo
de vida** (familia F-11), no caducidad del plan; y del token ni siquiera se sabe si la fecha la
impone el proveedor o la eligió el titular al crearlo (la API de creación no tiene parámetro de
expiración [F22]). Van a la sección de observaciones.

**Qué hace v0.3.** Un plan tiene `price` y `period`. La propuesta de SendGrid (`validity` +
`after_expiry`) necesita que `after_expiry` admita **un plan destino**, no solo
`no_capacity`. Promovible con dos APIs. A diferencia de SendGrid, donde `free_trial` **es** un
plan del YAML, aquí el trial no entra en `plans` (DISC-13: `free` es el Free aprobado), así que la
fricción se documenta sin afectar a la datasheet.

---

## F-15 · Dos canales, dos workloads para la misma cuota — RECURRE ✅ (2/4)

**Qué pasa.** El SMTP comparte la cuota mensual y la cuota diaria de peticiones con la API,
pero con reglas propias: **concurrencia por plan** (5 conexiones en Sandbox, Free, Hobby y
Starter; 50 en Professional y Enterprise [F6]), 5 transacciones por conexión [F27], un
caudal que una página cifra en 120/min [F6][F20] y otra describe **por IP y sin cifra** [F27]
(DISC-10), y un CRF distinto para la cuota diaria: por API un lote de 500 objetos cuenta
**1** petición; por SMTP *"Daily request quota applies to each individual message"* [F27].
No se publican ni el tamaño máximo ni los destinatarios por mensaje SMTP.

**Qué hace v0.3.** Modela `endpoints`; SMTP no tiene ruta. Segunda API: promovible. El
matiz nuevo es que la **concurrencia depende del plan** (5 / 50), lo que la convierte en una
dimensión de capacidad contractual y no solo en un detalle del canal.

---

## F-17 · Un tercer tope sin nivel de enganche — RETIRADA (refutada, B17, 2026-10-18)

**Retirada.** D17 cerró DISC-11 en peticiones: la página de precios dice `"100 daily requests"`
y la frase de [F2] en emails queda como incoherencia del pricing. Con eso se cumple el punto 2 de
abajo y la consecuencia enunciada es falsa. F-17 no tenía otra ocurrencia, así que sale del
inventario por **B17** (consejo 2026-10-18, 5–0). El número no se reutiliza. Lo que sigue es la
ficha tal como quedó en suspenso, que se conserva como historia.

**Qué pasa (si DISC-11 se resuelve en emails).** El plan Free tendría **tres cuotas
simultáneas**: 500 emails al mes, 100 emails al día (*"with a daily limit of 100 emails"* [F2])
y 100 peticiones al día [F1][F6][F31]. Las dos primeras tienen la misma unidad y distinta
ventana sobre el mismo endpoint.

**Por qué queda en suspenso.** Tres cosas que la verificación independiente dejó claras:

1. **No es nueva en la forma en que se enunció.** Resend Free ya tenía dos cuotas de la misma
   unidad con dos ventanas (100/día y 3.000/mes) sobre `/emails`, y su datasheet las serializa
   sin fricción usando los **dos niveles que v0.3 ofrece** (cuota del plan + cuota del
   endpoint, README §3.4); PRIME4API la ejecuta. Lo que MailerSend tendría es un **tercer**
   tope, y la carencia real es «un tercer tope sin nivel de enganche», no «una referencia
   `quota` por nivel».
2. **Descansa en una sola frase contradicha por cuatro fuentes** (DISC-11: [F1] FAQ 14, [F6],
   [F31] y la tabla de [F1] dicen *100 daily requests*). Si el tope diario del Free es en
   peticiones, el plan ya lo lleva (`quota_request_daily_free`) y la consecuencia enunciada
   («la curva diaria del Free sale cinco veces mayor») es falsa: el motor deriva peticiones del
   workload.
3. **La propuesta no es de este TFM.** Que `quota` (y `rate`) admitan lista es el issue #1 de
   `prime4api` (rgavira, 14-04-2026), y `_parse_quotas` ya lo implementa; el README no lo
   documenta y el validador lo rechaza (B1). Este TFM, como mucho, lo **respalda con un caso**.

**Qué hace v0.3 hoy con el dato.** Nada: desde el 2026-09-14 el dato **no está en el modelo**.
`quota_email_daily_free` estuvo definida en `capacity` (valor 🟡 por D1, ventana 🔴) y sin
referenciar desde ningún plan —visible para el lector, invisible para el motor— hasta que Q5 se
cerró retirándola (D-029, regla **B7**): una cuota que ningún plan puede referenciar sin duplicar
otra ya modelada no se define. El literal de [F2] se queda en el provenance y el hueco en
`metadata.not_found`. La fricción es justo eso: el esquema obliga a elegir entre una entrada
muerta y ningún sitio.

**Cómo se reabre.** Si `GET /v1/api-quota` con cuenta Free o el panel confirman dos contadores
en emails, se reabre como «tercer tope sin nivel de enganche», citando que Resend usó los dos
niveles disponibles y respaldando el issue #1 de Gavira con este caso. Si DISC-11 se resuelve en
peticiones, se cierra del todo: la entrada ya está retirada y no habría nada que deshacer.

---

## F-18 · La capacidad depende del estado de la cuenta, no del plan — NUEVA, MEDIDA Y APLICADA

**Qué hace v0.3 (primero, porque el mecanismo existe).** El README §3.4.3 de Gavira/Ruiz tiene
**aliases** de estado (*"Estado de reputación de la cuenta — healthy_reputation ·
under_review_reputation"*), **con MailerSend como ejemplo canónico** (`v1/email`,
`rate_120_min` / `rate_10_min`), y `mailersend_v03.yaml` los usa. **Desde D-025 (2026-09-10) el
catálogo también**: esta datasheet declara tres aliases en sus siete bloques de endpoint
—`healthy_reputation`, `under_review_reputation` y un tercero, `unapproved_account`, para el
estado que el proveedor publica y el vocabulario de ejemplo del README no recoge—, con la regla
D7 del libro, que sustituye a D2 en las APIs con cifras por estado. Así que la fricción ya no es
«v0.3 no lo expresa» sino **hasta dónde llega el mecanismo**: lo que sigue separa lo que absorbe
de lo que no. Ver O-08 y Q1 de `REVISION.md`.

**Qué pasa.** Con el mismo plan, tres cosas cambian por el **estado** de la cuenta:

1. **Reputación**: `/v1/email` pasa de 120 a 10 por minuto y el lote a 1 por minuto en
   *"Under review reputation"* [F31]; hay cuatro estados (*Healthy, Under review, Rebuilding,
   Sending paused*) [F42] y **solo dos tienen cifra, y la cifra está en [F31]**, no en la página
   de estados. El disparador incluye **los propios 429** (*"increased error rates (e.g., 403, 422,
   429 responses)"* [F42]): agotar el caudal degrada el caudal. Y la política lo remata: alcanzar
   un límite *"is considered an excessively frequent request"* [F45].
2. **Antigüedad**: *"Newly upgraded accounts may have a lower rate limit"* [F31], sin cifra.
3. **Aprobación**: el **workload** cae de 50/10/10 a 10/1/1 destinatarios (*"Unapproved
   acounts can include up to 10 TO, 1 CC and 1 BCC recipients"* [F20]) y la cuota mensual a
   100 [F39]; la aprobación tarda *"up to 48 hours"* y sus criterios no se publican [F38]. En
   Sandbox, además, el recurso `unique_recipients = 2` (absorbido de F-19). Y lo publicado se
   queda corto: **medido, el tope de `to` sin aprobar es 1**, no 10 (DISC-18).

(Que Enterprise suba `cc` y `bcc` a 50 [F39] es una diferencia por **plan**, no por estado:
está en F-08.)

**Lo que los aliases sí cubren, contra lo que la pasada 1 supuso.** Un alias no lleva solo
`rate` y `quota`: la implementación de referencia también le recoge el `workload`
(`_collect_workloads_from_ep`), aunque el README §3.4.3 documente únicamente los dos primeros. Con
eso, el caso 3 —que la pasada 1 dio por fuera del mecanismo justamente por leer el README— **sí
cabe**, y es lo que la datasheet hace hoy: cada bloque de `unapproved_account` lleva su caudal, su
cuota mensual de 100 emails y su carga por petición medida. **Dos de los tres cambios de la lista
caben, entonces: el 1 y el 3.** El 2, «newly upgraded», no tiene cifra publicada y por D7 no genera
alias: se queda en `not_found`. Comprobado contra el PRIME4API de SPHERE en local, que
devuelve una fila por alias donde antes devolvía una sola.

**Lo que los aliases no cubren.** Cinco cosas, y las cinco siguen abiertas. (i) El alias no dice
**qué dispara** el cambio de estado ni si es elegible por el cliente o impuesto por el proveedor:
no hay sitio para el disparador, y colarlo se paga caro —un `trigger` escalar dentro del alias se
ignora en silencio y a nivel de endpoint se lee como un alias más (O-12)—. (ii) No dice **cuál es
el estado por defecto** de una cuenta recién creada. (iii) Un estado sin cifra no genera alias
(D7): *Rebuilding*, *Sending paused* y las cuentas recién ascendidas se quedan en `not_found`, y
con dos estados en el ejemplo del README y cuatro publicados por el proveedor, más «newly
upgraded» y «not approved», el hueco es la norma. (iv) Un tope que no es por petición no cabe, y ese
**deja de contarse aquí**: los dos destinatarios **únicos por cuenta** no son un problema de
selector de estado sino de una dimensión que el esquema no tiene, así que pasan a caso propio,
**F-21 → P-08**. Lo que el alias sí lleva es el **máximo por petición**, que también vale 2 —la
mayor combinación que pasa la validación es `to` 1 más `cc` 1—; las dos cifras coinciden porque la
cuenta medida no había gastado ninguno de sus dos destinatarios únicos, no porque sean lo mismo.
(v) El estado no depende del plan y v0.3 obliga a **declararlo siete veces**, una por bloque de
endpoint, sin nada que ligue las copias.

**Evidencia medida ([E1], 2026-09-09).** Con la cuenta propia —Sandbox, **no aprobada**, sin
haber estado nunca bajo revisión— la API devuelve `x-ratelimit-limit: 10` en `/v1/email`, agota el
contador de 9 a 0 con diez peticiones rechazadas por validación y responde **429** en la undécima:
*"Your account reached its rate limit of 10 requests/min. Please wait before trying again.
#MS42903"*. En `/v1/bulk-email`, `x-ratelimit-limit: 1` y **429** en la segunda petición del
minuto: *"Your account reached its rate limit of 1 requests/min."*. Son exactamente las cifras de
la columna *"Under review reputation"* de [F31], aplicadas a un estado que esa tabla no nombra
(**no aprobada**) y que la fila `"10 for Sandbox and Hobby plan accounts"` de [F21] contradice.
El 429 alcanzado hace del 10/min y del 1/min datos **medidos** del estado no aprobado (regla E
ampliada, D-024); el 120 y el 10 del plan siguen en 🟢 por D2, con la NOTA en el provenance.
Además, los topes de destinatarios sin aprobar: `cc = 1` confirmado (1 pasa, 2 falla), `to`
**menor que los 10 publicados** (10 ya falla; DISC-18) y el límite de 2 destinatarios únicos de
Sandbox sumando `to`, `cc` y `bcc` (`#MS42225` desde 3). La documentación del estado, cuando
existe, tampoco acierta.

**Lo que añade la tanda 2 ([E1], 2026-09-10).** Tres medidas más del mismo estado. El tope de
`to` sin aprobar queda acotado en **exactamente 1**: `to = 2` ya responde 422 *"The to recipient
limit is exceeded. #MS42205"*, igual que 3, 5, 6 y 9, y solo una dirección pasa. La documentación
publica 10 (*"up to 10 TO"* [F20]): DISC-18 pasa de rango a cifra y la contradicción se queda
abierta con sus dos lecturas —o el proveedor publica un tope que no aplica, o Sandbox es un estado
propio y el 10/1/1 describe otro—; la elección es del autor y está escrita en `fuentes.md`, DISC-18.
El tope del lote sin aprobar queda medido con una respuesta de validación de verdad, 422 *"The
number of email objects must not be greater than 5. #MS42229"*, no con un 429 por caudal. Y el
estado final de los dos lotes aceptados confirma F-04. Ninguna de las tres sube de color: salen de
la misma cuenta única, y en el YAML van en 🟡 por eso, igual que los caudales.

**Cómo queda en la datasheet.** Los siete bloques de endpoint declaran los tres aliases.
`healthy_reputation` conserva el valor por defecto sin cambiarlo, así que las cifras del capítulo 5
se reproducen intactas. `under_review_reputation` lleva el 10/min y el 1/min publicados, en 🟢 por
literal. `unapproved_account` lleva lo medido —caudales, cuota mensual de 100 emails y carga por
petición— **todo en 🟡**: la ampliación de D-024 da verde al dato medido, y el dato medido es el de
una cuenta, no el de los cuatro planes a los que el valor se replica. El comodín `/*` se queda sin
aliases porque su caudal no cambia de estado.

**Consecuencia.** El valor «120/min» es cierto para una cuenta sana, aprobada y no recién
ascendida. Para una cuenta recién creada es **una** dirección en `to`, dos destinatarios únicos por
cuenta, cinco objetos por lote, 100 emails al mes, 10 peticiones por minuto y 1 lote por minuto;
para una bajo revisión, lo mismo en caudal. Con los aliases la datasheet ya **sí** puede decir de
cuál de las tres cuentas habla cada cifra, que es lo que la pasada 1 no podía; lo que sigue sin
poder decir es cuál de las tres es la del lector, porque el estado por defecto no se declara. Y el
sondeo demuestra que la cuenta que cualquiera abre hoy **no** es la del valor por defecto.

**Propuesta (extensión del mecanismo de Gavira/Ruiz, no sustituto).** (a) Documentar el
`workload` por alias en el README §3.4.3: la implementación ya lo admite y la guía no lo cuenta,
así que el mecanismo se está usando por debajo de lo que da. (b) Un atributo `trigger`
(`provider_managed | customer_selected`) con su condición en prosa **y con sitio propio**, porque
hoy escribirlo donde parece natural lo convierte en un alias fantasma sin que nada avise (O-12).
(c) Un estado `default` explícito que diga cuál de los aliases describe la cuenta recién creada.
(d) Una forma de declarar un estado **una sola vez** para toda la datasheet: hoy el hecho se
replica en siete bloques y nada liga las copias.

**Dónde más aparece (a verificar en el recuento).** No es la primera vez que un proveedor cambia
la capacidad por estado; es la primera vez que se cuenta, porque la etiqueta no existía:
**Postmark** publica capacidad por estado (*"While your account is in test mode, you can only
send and process 100 emails … only send emails to … domains that you have verified"*; *"While
your account is pending approval, all recipient addresses must share the same domain as the From
address"*, provenance de `postmark/datasheet.yaml`); **Resend** publica caudal por estado sin
cifra (*"This number can be increased for trusted senders upon request"* [F4] de Resend);
**SendGrid** bloquea por peticiones malformadas sin umbral (parcial). Con Postmark confirmada
sería promovible.

---

## F-19 · Cuota de cardinalidad: destinatarios únicos sin ventana — ABSORBIDA por F-11 / F-18

**Qué pasa.** En Sandbox, *"You can send to any 2 recipients in Sandbox mode, until your
account is approved"* [F37]; el error es propio: *"You have reached sandbox account unique
recipients limit."* [F20]. No es un tope por petición (workload) ni un volumen por ventana
(cuota): es un **conjunto de tamaño máximo 2** que no se repone con el tiempo sino con un cambio
de estado.

**Por qué no es fricción nueva.** Es exactamente la definición de F-11 en Resend: «un recurso
que se tiene o no se tiene, y acota la capacidad alcanzable sin ser una dimensión de
capacidad», cuya propuesta (bloque `resources` con `{name, value, unit}` sin periodo) ya cubre
`unique_recipients: 2`. Y que el recurso cambie con la aprobación es F-18. Además Sandbox no es
un plan ni está en el YAML (DISC-13), así que la fricción no muerde la datasheet. Se retira el
segundo ejemplo que se había dado (el dominio de prueba, `#MS42222`): es un tope de volumen
(*"email quota limit"*), no de cardinalidad. Y se retira la propuesta de `period: none` /
`window_type: until_state_change` en `capacity`: cambiaría la semántica de la cuota de ACM
(volumen por ventana) cuando el catálogo ya tiene una extensión (F-11, `resources`) que lo
resuelve sin tocar `capacity`.

**Dónde queda el dato.** Instancia de F-11: recurso `unique_recipients = 2` en estado Sandbox
([F37], `#MS42225`), que se levanta con la aprobación (F-18). Provenance y `not_found`. **Medido
en [E1]:** el conjunto suma `to`, `cc` y `bcc` (1 + 1 pasa; 1 + 2 y 1 + 10 fallan con `#MS42225`).

---

## F-20 · La cuota de peticiones no cuenta lo que la API contesta como dice que cuenta — RETIRADA (2026-09-09, segunda ejecución de [E1]) → O-11

**Lo que se creyó ver.** Tres páginas dicen que **cada petición** descuenta de la cuota diaria:
*"Every request is counted against the quota and is reset daily at midnight UTC."* [F20], *"Every
request made counts against your daily quota"* [F31]; la única excepción publicada es el propio
`GET /v1/api-quota` (*"Requests to this endpoint do not count toward your quota."* [F32]). La
primera ejecución del sondeo [E1] (19:02 UTC) leyó `"remaining": 100`, hizo 17 peticiones que
deberían contar —diez 422 de validación, cinco 429, un 202 del lote y un 200 de `GET /v1/domains`—
y **las 18 respuestas** llevaban `x-apiquota-remaining: 100`, mientras el contador de caudal sí
descontaba cada 422 (`x-ratelimit-remaining` de 9 a 0). De ahí la candidata: «la cuota no cuenta
las rechazadas» (DISC-17, lectura a).

**Por qué cae.** La segunda ejecución del mismo script (19:13 UTC, once minutos después) leyó
`{"quota": 100, "remaining": 83}`: **las 17 estaban descontadas**, 422, 429, 202 y 200 por igual.
Dentro de esa ejecución, `x-apiquota-remaining: 83` se mantuvo en 14 respuestas seguidas y saltó a
69 en la decimoquinta (83 − 14: las catorce anteriores de golpe, dos de ellas 429 y una el 202 del
lote); la lectura final, 7 s después de la última petición, daba 69 con tres peticiones aún sin
descontar. La regla de descuento **es la publicada**: cada petición cuenta 1, aceptada o
rechazada. Lo que no coincide con la documentación es otra cosa: el contador que devuelven la
cabecera y `/v1/api-quota` **se actualiza con retardo y por lotes** (17 y 14 unidades en lo
observado), no por petición, y ninguna de las tres páginas lo dice.

**Por qué no se reescribe como fricción de otra naturaleza.** Una fricción del catálogo es algo
que el proveedor ofrece y que ACM2YAML v0.3 no puede expresar, o expresa mal, de forma que la
datasheet describe una capacidad distinta de la real (F-02, F-07, F-11, F-18) o su respuesta no
mide lo que la datasheet dice (F-04). Aquí la datasheet acierta: `quota_request_daily_*` con
`value: 100`, ventana a medianoche UTC y **cada petición consume 1**, que es exactamente lo que
PRIME4API da por hecho al derivar la dimensión `requests`. Lo que falla es el **canal por el que el
cliente observa el consumo**, y v0.3 no modela ese canal para ninguna API: tampoco las cabeceras
`x-ratelimit-*` ni el `retry-after` ausente (DISC-19), que el catálogo ya trata como «sin
consecuencia en el YAML: v0.3 no serializa cabeceras». Abrir «v0.3 no dice nada de la
observabilidad del consumo» como fricción con una sola API y un solo comportamiento medido sería
repetir lo que la verificación del 2026-09-08 tumbó en F-17 y F-19: un número nuevo para algo que
no toca ningún valor del YAML ni impide expresarlo. Si un sondeo de otra API vuelve a encontrar un
contador expuesto que va por detrás del aplicado, se reabre como candidata con dos evidencias;
hasta entonces es la observación **O-11** (abajo) y material del capítulo 5 (qué puede y qué no
puede medir un sondeo con cuenta propia), no del capítulo 6.

**Lo que se conserva del razonamiento.** La advertencia de [F20] (*"Avoid sending repeated API
requests that fail validation (HTTP 422 error)"*) apunta a la cuota además de a la reputación: las
422 sí gastan. El coste del sondeo (*"el sondeo completo gasta ~16 peticiones"*, cabecera del
script) era correcto: dos ejecuciones, 34 peticiones que cuentan (31 ya reflejadas en el contador
al cerrar la segunda, `"remaining": 69`; las tres últimas todavía no). Y la regla de pipeline que
la candidata proponía sobrevive como regla de método: **todo sondeo lee el contador antes y
bastante después**, no en la respuesta siguiente.

---

## Familia aparte: características no capacitarias (decisión Q6, 2026-09-01)

| Rasgo | MailerSend | Qué es |
|---|---|---|
| Entregabilidad | *"Deliverability consultation"* en Professional [F1]; blocklist monitoring 2 / 64 / 256 [F1] | Servicio, no capacidad |
| Reputación | Cuatro estados con caudal condicionado [F42][F31] | **Ya no es solo observación: F-18** |
| IP dedicada | Solo Enterprise por la página de precios [F1] (D17); $50/mes y otros planes mínimos como incoherencia del pricing [F3][F9][F10] | F-07 |
| Canal SMTP | `smtp.mailersend.net`, misma cuota, concurrencia por plan | F-15 |
| Identidad de remitente | Sin dominio verificado, 422 MS42207 [F20]; el panel exige dominio propio aprobado hasta para ver la escalera de precios [F53] | Precondición de uso |
| Aprobación de cuenta | Hasta 48 h, criterios no publicados [F38] | Puerta previa a la capacidad (F-18) |

## Observaciones sobre el propio repositorio y la especificación del proveedor

**O-08 · v0.3 sí tiene aliases de estado, y MailerSend es su ejemplo canónico — ADOPTADOS
(D-025).** El README §3.4.3 documenta `healthy_reputation` / `under_review_reputation` con
`v1/email` y `rate_120_min` / `rate_10_min` como ejemplo, y `mailersend_v03.yaml` los usa.
El brief de esta pasada y la
fila 15 del contraste en `fuentes.md` los daban por ajenos a v0.3: **no lo son**. Lo que sí es
cierto: (a) el catálogo no los había usado en ninguna de las cuatro datasheets (regla D2); (b) el
ejemplo del README tiene solo dos estados y el proveedor cuatro; (c) el ejemplo canónico
`mailersend_v03.yaml` usa la ruta `v1/bulk`, que no existe (`/v1/bulk-email`); tanto el README
§3.4.3 como el ejemplo escriben `v1/email` sin barra inicial (el README no contiene `v1/bulk`).

**Cerrada el 2026-09-10.** El autor respondió Q1: **se adoptan**, con un tercer alias
`unapproved_account` para el estado que el README no recoge, y el libro gana la regla **D7**
(ficha D-025). El punto (a) deja de ser un argumento en contra —la uniformidad se recupera hacia
adelante, revisitando Postmark y Resend cuando toque— y el (b) se resuelve por regla: un estado
sin cifra publicada no genera alias, se queda en `not_found`. El (c) sigue en pie y es un defecto
del ejemplo de la guía, no de esta datasheet.

**O-09 · El ejemplo canónico define rates que no usa y ventanas sin fuente.**
`mailersend_v03.yaml` declara `rate_15_min` y `rate_30_min` y asigna `rate_10_min` al lote en
los cuatro planes; hoy Starter y Professional publican 15 y 30 [F21][F31]. Declara
`window_type: rolling` en las cuotas mensuales, que ninguna fuente dice (DISC-12). Y usa
números en los nombres de clave (`quota_500_emails_month`, `rate_120_min`): O-02 recurre en
el propio ejemplo de la guía.

**O-10 · PRIME4API cae con un rate solo y sin cuota (DV-04).** Detallada en
`DISCREPANCIAS_v03.md`. Para el capítulo 6: la comprobación tres del ciclo (`verificar_prime4api.py`)
ha encontrado un defecto del motor, no de la datasheet, y SendGrid lo esquivó por una
duplicación accidental de referencias. Sin la MailerSend, el catálogo habría dado el motor
por conforme con F-06.

**Recurrencia de O-06 (OpenAPI por detrás de la prosa).** La especificación de SwaggerHub
[F30] no declara `maxItems` en `to`, omite `cc`, `bcc`, `attachments`, `tags` y `send_at`,
no menciona el 429 y declara `200` donde la documentación dice `202` (DISC-15). Segunda API
(SendGrid, MailerSend) en la que la vía «OpenAPI primero» del checklist daría una datasheet
peor que la prosa.

**O-11 · El contador expuesto de la cuota diaria no es el contador que se aplica (2026-09-09,
[E1], dos ejecuciones).** MailerSend publica la regla (*"Every request is counted against the
quota"* [F20]) y un canal para observarla: la cabecera `x-apiquota-remaining` en cada respuesta y
`GET /v1/api-quota` (*"Inspect how many MailerSend API requests you have remaining and when the
limit resets."* [F32]). La regla se cumple —17 peticiones de la primera ejecución (422, 429, 202,
200) descontadas al empezar la segunda; 14 más dentro de ella—, pero el canal **va por detrás y
por lotes**: 18 respuestas seguidas con `100`, luego `83` en 14 respuestas seguidas, luego `69` de
golpe; la lectura final, 7 s después de la última petición, no reflejaba las tres últimas. Ni
[F20], ni [F31], ni [F32] lo dicen. Consecuencias: (a) `remaining` no sirve para reservar
capacidad al segundo —un cliente que lea `1` y envíe puede recibir el 429 `#MS42901` de un
contador que ya estaba en 0, o al revés—; (b) para la escalera de validación, un sondeo no puede
usar la cabecera de la respuesta siguiente como coste de la anterior: hay que leer antes y bastante
después (regla de método, ya aplicada al t2); (c) el retardo y su disparador no están medidos
(tiempo, número de peticiones u otra cosa).

**Ampliación con la tanda 2 (2026-09-10): la reposición diaria también es perezosa.** A las
11:24:08 UTC, once horas y veinticuatro minutos después de la medianoche que repone la cuota,
`GET /v1/api-quota` devolvió `{"quota": 100, "remaining": 66, "reset": "2026-09-11T00:00:00Z"}`.
El `reset` ya apuntaba al día siguiente, o sea que la ventana nueva había empezado, y el
`remaining` seguía sirviendo la anterior, ya completa: las dos tandas del 09-09 hicieron 37
peticiones, de las que cuentan 34 —los tres `GET /v1/api-quota` no cuentan, y [F32] lo dice—, y
100 − 34 = 66. Al cerrar la tanda 1b el contador daba 69, o sea que seis seguían sin descontarse:
tres se descontaron después y tres no lo harían nunca. `B2_to_2`, la primera petición de la tanda
2, volvió a leer 66; **el salto a 99 llegó con `B2_to_3`** (11:24:22), la ventana del día nuevo con
una sola petición descontada. Ni el descuento ni la reposición ocurren en el instante que la
documentación deja suponer (*"reset daily at midnight UTC"* [F20]): los dos esperan a que
llegue tráfico, y hasta
entonces el canal sirve el saldo de ayer con la fecha de mañana. Se suma a (b): un sondeo tampoco
puede fiarse de `remaining` para saber en qué ventana está.

No es fricción del esquema (v0.3 no modela el canal de
observación del consumo para ninguna API y la datasheet acierta en valor, ventana y regla); se
anota para el capítulo 5 y se reabre como candidata solo si otro sondeo del catálogo encuentra lo
mismo. Sustituye a la F-20 retirada.

**O-12 · Una clave desconocida dentro de un endpoint no da error: se vuelve alias, y si el
endpoint declara su propio `rate` le roba la fila (2026-09-10).** El motor de referencia trata
como alias **todo** diccionario del bloque de endpoint que no sea una de las cuatro claves
conocidas (`_KNOWN_ENDPOINT_KEYS = {"rate", "quota", "workload", "cost_per_request"}`): no hay
lista de nombres válidos ni validación del nombre. Así que `trigger`, escrito a nivel de endpoint
para anotar qué dispara el cambio de estado —la propuesta (b) de F-18, escrita donde parece
natural—, entra como un alias más.

**Medido el 2026-09-10 sobre dos copias de la datasheet de hoy** (la de D-025, no un borrador),
cada una con el mismo `trigger` en un endpoint distinto del plan Hobby. El daño **depende de dónde
se escriba**, y esa es la condición que lo hace cierto:

- **Endpoint que ya declara aliases y no lleva `rate` propio** (`/v1/bulk-email` hoy): el fantasma
  sale **vacío** y las tres filas reales siguen enteras —
  `endpoint='/v1/bulk-email' alias='trigger' result=[]`, junto a `healthy_reputation` 10/min,
  `under_review_reputation` 1/min y `unapproved_account` 1/min—. Daño: un estado inexistente en el
  vocabulario y una fila hueca, nada más.
- **Endpoint que lleva su `rate` al nivel del endpoint** (`/*` hoy, y `/v1/bulk-email` **antes** de
  D-025): el endpoint **pierde su fila propia**. Donde el motor devolvía
  `endpoint='/*' alias=None result=[Rate(60.0 requests/1 min)]` devuelve
  `endpoint='/*' alias='trigger' result=[Rate(60.0 requests/1 min)]`: el caudal real queda
  etiquetado con un estado que no existe, y un lector entendería «60/min en el estado *trigger*».

**Y ninguna comprobación lo ve, en ninguno de los dos casos.** `verificar_prime4api.py` da
**20 OK / 1 ERR** sobre las dos copias, la misma nota que la datasheet limpia, con el mismo único
ERR de siempre (DV-04). El validador de formato da **16 ok / 2 avisos / 0 errores** sobre las dos,
**idéntico** al limpio. La única huella está en una línea **marcada `[OK]`**: `nav.aliases` lista
`"trigger"` junto a los tres aliases reales. Hay que leerla para verlo; nada la señala. Y el
`trigger` **escalar** dentro de un alias se ignora sin dejar rastro alguno.

Es decir: **el ciclo de tres comprobaciones de `docs/10-revision-automatica.md` no protege contra
esto**. Las tres pasan igual con la datasheet buena y con la contaminada. Que hoy el daño en esta
datasheet se quede en una fila hueca es **una casualidad del modelado** —D-025 movió el `rate` del
lote dentro de los aliases—, no una salvaguarda: el comodín `/*` sigue siendo vulnerable, y
cualquier datasheet del catálogo con `rate` al nivel del endpoint lo es. No es fricción del
esquema —ninguna datasheet lleva ese `trigger`— sino un punto ciego del método, y la razón
concreta de que la propuesta (b) de F-18 pida sitio propio para el disparador y rechazo explícito
de lo que el motor no reconoce. Para el capítulo 6 va junto a O-10: la comprobación tres encontró
un defecto del motor (DV-04) y aquí enseña lo que deja pasar.

**O-14 · El motor sí calcula la cuota diaria, pero en otra curva, y su renderizador la esconde
(2026-09-14, D-036).** El hallazgo H1 decía que la cuota diaria de 1.000 peticiones del plan «no
entra» en las respuestas. Medido contra el PRIME4API de SPHERE en local, la formulación exacta es
otra: **el motor devuelve una curva por dimensión y no las junta en una sola**. Pedida la curva de Hobby en
`emails` salen el caudal de 120/min y la cuota mensual de 5.000, la rampa de 41 minutos del panel
(e) de la Figura 5.1; pedida en `requests` salen la cuota diaria de 1.000 **y** la mensual
convertida por el CRF (5.000 a $k = 1$, 71 a $k = 70$), y la curva es la escalera: 1.000 al
minuto 8, mil más cada medianoche UTC y 5.000 el quinto día.

Lo que sí esconde es el dibujo. `render_multi_curve_html` descarta la dimensión `requests`
derivada de un `workload` salvo que se le pase `show_derived_requests`, que el endpoint REST
expone con valor por defecto `False` y la descripción *"Hidden by default because it is usually
redundant with a native requests limit"*. En MailerSend **no es redundante**: esa serie es la
única que lleva la cuota diaria del plan. Medido: `chart/inflection` con `capacity_unit=requests`
devuelve **200 y un documento sin ninguna figura** (3.445 bytes, cero `Plotly.newPlot`); con
`show_derived_requests=true`, cuatro figuras y la escalera entre ellas. El endpoint de datos
(`data/inflection`) nunca la oculta, así que la ausencia es del renderizador y no del cálculo.

**Corregido el 2026-09-14 con D-038.** Esta ficha decía que la carencia era del esquema, que «no
da forma de decir que dos límites en unidades distintas acotan el mismo consumo». **No es así, y
se midió.** El CRF del `workload` es esa forma, está declarado en la Datasheet y el motor lo usa:
de las tres conversiones que permite hace **dos** —el caudal de peticiones por $k$ a correos
(120, 4.320 y 8.400 con $k = 1$, 36 y 70) y la cuota mensual de correos entre $k$ a peticiones
(5.000, 138 y 71)— y no hace la tercera, la cuota diaria de peticiones por $k$ a correos. El
esquema no tiene parte en ese hueco. Matriz y salida verbatim en
`05_salida/_cap5/h1_dimensiones_d038/MEDICION.md`.

Para el capítulo 6, por tanto, **defecto de contrato y no carencia de expresividad** (D-038): la
Datasheet es conforme, las comprobaciones pasan, y la respuesta en correos se queda corta sin
avisar —5.000 a los 41 minutos frente a los cinco días de la escalera—. Lo que sí es de esquema
queda enunciado y **sin promover**: nada en el fichero declara en qué dimensión mide el plan.
Quien lea la gráfica por defecto sigue llevándose la rampa y no la escalera: sin filtrar
dimensión el renderizador sirve cuatro figuras y las cuatro son de correos.

**Dos carencias del esquema que esta pasada deja medidas (capítulo 6).** Las dos salen de aplicar
los aliases, no de leerlos, y ninguna se ve sin haberlo hecho.

1. **El `workload` por alias funciona y el README no lo documenta.** La implementación de
   referencia lo recoge (`_collect_workloads_from_ep`); el README §3.4.3 solo documenta `rate` y
   `quota`. La consecuencia se midió en esta misma datasheet: la pasada 1 dio el caso 3 de F-18
   («la carga por petición cambia con la aprobación») por fuera del mecanismo **por leer el
   README**, y cabía. La carencia es de documentación, no de implementación, y se arregla
   escribiéndola; hasta que se escriba, el mecanismo se usa por debajo de lo que da.
2. **Un hecho de cuenta se replica en siete bloques y nada liga las copias.** El estado de la
   cuenta no depende del plan ni del endpoint, pero v0.3 no tiene dónde declararlo una sola vez:
   los valores viven en claves sin sufijo de plan (`rate_request_email_unapproved`, …) y la
   **referencia** se repite en los siete bloques de endpoint. Dos consecuencias, las dos medidas
   aquí: cambiar el estado obliga a tocar siete sitios y nada detecta que uno se quede atrás; y el
   recuento de semáforo cuenta copias como si fueran evidencia — de los 🟢 de esta datasheet (el
   recuento vive en `docs/07-estado.md` y lo comprueba `verificar_estado.py`), **tres son el mismo
   hecho**: la carga en MBs (50 MB) que los tres bloques del lote copian del endpoint porque el
   motor no mezcla la carga del endpoint con la del alias. Una NOTA
   del provenance lo advierte para que la cifra del tablero no se lea como cobertura; el esquema,
   por sí solo, no puede decirlo.

**F-04 confirmada por el sondeo (antes «candidato»).** El lote responde `202 Accepted` **antes**
de validar (*"each email validation is done after the request and then the result is stored"*
[F21]) y [E1] lo midió el 2026-09-09 con un remitente no verificado, dos veces (19:02 y 19:14
UTC, dos `bulk_email_id`): 202 en el lote, 422 en el envío individual. **La tanda 2 la cierra por
el otro extremo** (2026-09-10): los dos lotes están `state: "completed"` con
`validation_errors_count: 5` y ningún correo enviado. Sección F-04 arriba. Queda sin medir la otra
forma del mismo estado: el `202` con `x-send-paused: true` sin condición publicada (necesita
cuenta aprobada).

**Cabeceras del 429 (DISC-19), material para F-01.** Las diez respuestas 429 de [E1] (cinco por
ejecución, 19:02 y 19:14 UTC) no traen `retry-after` ni `x-ratelimit-*`, que [F20] y [F31]
publican y de las que [F36] hace depender el reintento del SDK. El caudal existe y tiene valor
(10/min, 1/min), pero el cliente no recibe cuánto esperar salvo por el texto del mensaje. Dos
ventanas de un minuto y una sola cuenta: **la tanda 2 no añadió la tercera** porque, con los 61 s
de espera antes del lote, no provocó ningún 429. Lo que sí añadió es el contraste que reformula
DISC-19: la API emite `x-ratelimit-limit` y `x-ratelimit-remaining` en los 422 de validación, en
el 202 del lote y en los 200 de `GET /v1/domains` y `GET /v1/bulk-email/{id}` —36 respuestas en
las tres tandas— y deja de emitirlas justo en el 429. No es que no dé cabeceras de caudal: no las
da donde hacen falta.

**Recursos con ciclo de vida (F-11), fuera de F-14.** El token de API observado en el panel
lleva `"Expires at: 30 Sep 2026"` y el dominio de prueba `"Test domains are automatically deleted
if not in use for 30 days."` [F53]. Caducan recursos que dan acceso a la capacidad, no el plan;
del token no se sabe si la fecha la impone el proveedor (la API de creación no tiene parámetro de
expiración [F22]). Se anotan aquí como variante de F-11 (el recurso tiene vida útil) y no
cuentan en F-14.

**Nota sobre DV-04 y el `rate` a nivel de plan.** Postmark, Resend y SendGrid declaran `rate` en
el plan además de en `/*`; MailerSend solo en `/*`, porque el 60/min es *"excluding email
endpoints"* [F20] y declararlo como *"caudal global del plan"* (README §3.4) diría que el plan
entero va a 60/min, lo que `/v1/email` (120/min) desmiente. Comprobado el 2026-09-08: con
`rate: rate_request_general_<plan>` en los cuatro planes PRIME4API pasa 21/21 (el escenario en
`MBs` lleva dos rates y esquiva `RatePlotter`), igual que SendGrid; se deja como está para no
enmascarar DV-04 con una referencia semánticamente dudosa. Anotado en `DISCREPANCIAS_v03.md`.

**Recordatorio de DV-03.** Enterprise se ha dejado **fuera del YAML**: no tiene precio ni
volumen mensual publicados (solo 500.000 peticiones al día, 60 lotes por minuto y cc/bcc de
50), y con `price: custom` tumbaría las 13 operaciones de los cuatro planes calculables. Con
los cuatro planes PRIME4API pasa 20 de 21 (el fallo restante es DV-04). Decisión para el autor en
`REVISION.md`.
