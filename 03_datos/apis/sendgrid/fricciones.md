# Fricciones con ACM2YAML v0.3 — SendGrid

Tercera API del catálogo y la primera de las dos que ya estaban modeladas en el TFM de
Gavira Sánchez. Con tres APIs, el recuento D-008 (promoción con ≥2 APIs) deja de ser
un empate: lo que recurre tres veces es una carencia del modelo, no una rareza de dos
proveedores.

Pasada 1 · 2026-09-06 (documentación + panel + verificador adversarial + sondeo en sandbox [E1], todo el mismo día).

---

## Recuento de recurrencia

| # | Fricción | Postmark | Resend | SendGrid | Vía · veredicto (D-008 · D-042) |
|---|---|---|---|---|---|
| F-01 | Rate que existe sin valor | ✅ | ⚠️ parcial | ⚠️ parcial | **PROMOVIBLE por traza** → P-04 (no por recurrencia: ver abajo) |
| F-02 | Volumen contratado con sobrecoste variable | ✅ | ✅ | ✅ | **PROMOVIBLE** (3/3) |
| F-03 | CRF multiplicativo | ✅ | ✅ | ⚠️ acotado | **PROMOVIBLE** (2/3 + variante) |
| F-04 | Restricciones declaradas y no aplicadas | ✅ | — | — | Sin promover |
| F-05 | RPR no serializable | ✅ | — | ✅ | **PROMOVIBLE** |
| F-06 | Workload acotado por otra métrica | ✅ | ✅ | ✅ | **PROMOVIBLE** (3/3) |
| F-07 | Add-ons que modifican capacidad | ✅ | ✅ | ✅ | **PROMOVIBLE** (3/3) |
| F-08 | El plan es un producto cartesiano | ✅ | ⚠️ parcial | ✅ | **PROMOVIBLE** |
| F-09 | La datasheet no dice qué parte sigue vigente | — | ✅ | ✅ *(por contraste con 2025)* | **PROMOVIBLE** |
| F-10 | Dos productos, dos unidades de consumo | — | ✅ | ✅ | **PROMOVIBLE** |
| F-11 | Límites de recursos por plan | ✅ | ✅ | ✅ | **PROMOVIBLE** (3/3) |
| F-12 | La recepción consume la cuota de envío | *(verificar)* | ✅ | *(verificar)* *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: sin fuente que lo afirme ni lo niegue; antes: — con no documentado)* | 1 API |
| F-13 | El sobrecoste es opcional y no existe en Free | *(verificar)* | ✅ | ✅ | **PROMOVIBLE** |
| F-14 | El plan tiene fecha de caducidad | — | — | ✅ nueva | 1 API |
| F-15 | Dos canales, dos workloads para la misma cuota | — | — | ✅ nueva | 1 API |
| F-16 | El sobrecoste tiene tope (10 × el volumen contratado) | *(verificar)* | *(verificar)* | ✅ nueva | **PROMOVIBLE por traza** → P-07 (L2 ejecutada, `prime4api_ejecucion_d042/tope_sobrecoste/`); 1 API |

Nuevas en esta API: **F-14**, **F-15** y **F-16**. Observaciones nuevas: **O-06**, **O-07**.

---

## F-01 · Un rate que existe pero no tiene valor — recurrencia PARCIAL

**Qué pasa.** La página de rate limits [F2] es la forma pura de la fricción de Postmark:
*"Each endpoint permits a fixed number of requests per refresh period"*, cabeceras
`X-RateLimit-*`, un 429… y **ningún valor**. Los dos ejemplos de la misma página usan
`500` y `150`, que es la prueba de que son ilustrativos. Pero, a diferencia de Postmark,
existe **un** caudal numérico: la FAQ de Mail Send [F5] dice *"You may make up to 10,000
requests per second to the endpoint"*. Y el canal SMTP publica el suyo [F13].

**Por qué es parcial.** Para el endpoint que importa (el de envío) hay valor; para el
resto de la API REST no. La datasheet lleva el 10.000 en verde en los cuatro planes
(regla D2) y el resto en `not_found`. Es la misma situación que Resend: «existe un valor
por defecto» no es «existe un rate inobservable». No cuenta como segunda ocurrencia plena.

**Lo que sí aporta.** El verificador señaló, con razón, que la página oficial de rate
limits **ni menciona** `mail/send`, y que 10.000 rps aparece una sola vez, en una FAQ, sin
segmentación (por cuenta, por clave, por subusuario). Un valor publicado en una FAQ y no
en la página de límites es un grado de opacidad intermedio que el semáforo de tres colores
no distingue. Anotado para el capítulo 6 como matiz de F-01.

**Lo que midió el sondeo [E1].** Los valores existen y son estables: `x-ratelimit-limit:
600` por ventana fija de un minuto en seis endpoints de lectura, y `6` en `/v3/messages`.
Y una asimetría que Postmark no tenía: **el endpoint de envío no devuelve cabeceras de
caudal**; los demás sí. El único rate publicado (10.000 rps, mail/send) es el único que
no se puede observar, y los observables son los que no se publican. Es el caso más
limpio de F-01 hasta ahora: el proveedor **tiene** los números —los sirve en cada
respuesta— y no los escribe en la documentación.

---

## F-02 · Cuotas por volumen contratado, con sobrecoste variable — RECURRE ✅ (3/3)

**Qué pasa.** Es el caso más explícito de los tres. El nombre comercial del plan **es**
tier × volumen: `"Essentials 50k"`, `"Pro 300k"`, `"Pro 2.5M"` [F1]. Dos volúmenes en
Essentials, cinco en Pro, y el sobrecoste baja de $0.0013 a $0.0005 por email a lo largo
de la escalera. Todo publicado en la página de precios, con la tabla de sobrecostes en la
FAQ.

**Qué hace v0.3.** Lo mismo que en las otras dos: un `value` y un `overage_cost` por
cuota. La datasheet modela el volumen mínimo de cada tier y la escalera completa vive en
el provenance.

**Consecuencia.** «Pro cuesta $89.95 por 100.000 emails con sobrecoste de $0.0011» es
verdad solo en el primer peldaño. En el último, Pro son 2,5 millones a $1.099 con
sobrecoste de $0.0005. Tres proveedores de tres con la misma estructura: la propuesta de
`tiers` por cuota ya no es una hipótesis del piloto.

**Un matiz que solo aparece aquí.** El sobrecoste tiene **más decimales dentro del
panel** que en la página pública (`$0.00133` frente a `$0.0013`, DISC-01). La página
pública redondea. Para una herramienta que calcule coste, la diferencia entre 0.00047 y
0.0005 es un 6 %. Es un argumento a favor de la regla E2 (volcado del panel también).
Criterio fijado por el autor el 2026-09-06 (regla D5): iba el del panel, que es el que se factura.
Desde el 2026-10-18 manda D17 (D-068): el pricing define la verdad, así que va el $0.0013 de
la página y el $0.00133 del panel queda como incoherencia del pricing.

---

## F-03 · CRF multiplicativo entre dimensiones — recurrencia ACOTADA ⚠️

**Qué pasa.** El endpoint acepta hasta 1.000 *personalizations* (sobres) y cada sobre sus
destinatarios [F4][F6]. En Postmark y Resend eso producía N×M sin tope declarado. Aquí
el proveedor **pone el tope al total**: *"The total number of recipients must be no more
than 1,000. This includes all recipients defined within the to, cc, and bcc parameters,
across each object that you include in the personalizations array"* [F3].

**Por qué es una variante y no una ocurrencia más.** Con el tope total declarado, la
terna escalar `unit/min/max` de v0.3 **es correcta**: `max: 1000` emails por petición,
sin ambigüedad. SendGrid resuelve por escrito lo que en las otras dos APIs hubo que
sondear. Eso no quita que el producto N×M exista (1.000 sobres × destinatarios); solo
que el proveedor lo acota. Se anota como «acotado» y no se cuenta como tercera
ocurrencia plena, porque forzar el recuento le quitaría valor.

**Lo que aporta al capítulo 6.** Es el contraejemplo que la propuesta necesita: un
proveedor que publica el tope total demuestra que el dato existe y es publicable; los
otros dos demuestran que, sin él, el esquema produce un número plausible y equivocado.

**Verificado [E1].** 1.000 pasa y 1.001 falla en las tres formas (un sobre, dos sobres,
`to` + `cc`), con el mensaje *"There is a limit of 1000 total recipients (to + cc + bcc)
per mail/send request."*. Y la OpenAPI, que deja `to` sin `maxItems` (O-06), queda
desmentida por la API: el tope existe y es total.

---

## F-05 · Results Per Request no serializable — RECURRE ✅

**Qué pasa.** El endpoint de actividad `/v3/messages` tiene tope por petición
(*"greater than 0 and less than or equal to 1000"*) y tope de filtros (*"Combine up to
160 filter conditions per request"*) [F15]. Y además solo existe tras comprar un add-on.

**Qué hace v0.3.** Lo mismo que en Postmark: RPR está fuera de la serialización. La
capacidad de *consulta* no se modela; queda en el provenance.

---

## F-06 · Un workload acotado por otra métrica — RECURRE ✅ (3/3)

**Qué pasa.** *"The total size of your email, including attachments, must be less than
30MB"* [F3]. La cota está en megabytes, no en emails. Aquí, además de los 1.000
destinatarios, así que el workload lleva **dos entradas** (`emails` y `MBs`), que es
justo lo que la forma de lista (B5, DV-01) permite y la de mapa no.

**Un matiz.** La cota publicada es **estricta** (`"less than"`), y el esquema no distingue
`<` de `≤`. El sondeo [E2] del 2026-09-07 lo resolvió midiendo: una petición de 31.457.280
bytes (30 MiB) pasa y una de 31.457.281 recibe un 413 del proxy. El tope real es `≤ 30 MiB`,
así que el máximo en MBs va en verde. Y el verificador tiene razón en que `min: 1` no sale
de ninguna fuente: es la convención del catálogo para «al menos algo», no un dato.

---

## F-07 · Add-ons que modifican dimensiones de capacidad — RECURRE ✅ (3/3)

**Qué pasa.** IP dedicada incluida en Pro y Premier y **no disponible** en Essentials
(`"No Access to Dedicated IPs"` [F12]); IPs adicionales a $30/mes cada una; créditos de
prueba en paquetes (con una errata de precio en la página: `"$40.000 USD"`); validación
de direcciones *"Pro and Premier level accounts only"* [F17]; historial de actividad
ampliable a 30 días con un add-on [F16].

**Qué hace v0.3.** Sin bloque de add-ons; se derivan a Pricing2YAML (D-001). Sigue en
Trabajo Futuro, ahora con tres APIs detrás.

---

## F-08 · El plan como producto cartesiano — RECURRE ✅

**Qué pasa.** Es la API donde F-08 se ve con más nitidez, en tres formas:

1. **El nombre del plan es tier × volumen** (`"Pro 300k"`). La lista plana de `plans`
   obliga a elegir un peldaño por tier o a enumerar los siete.
2. **La superficie de la API cambia con el tier**: envío regional EU
   (`api.eu.sendgrid.com`) *"available for Twilio SendGrid Pro plan or above"* [F4];
   subusuarios y SSO desde Pro; validación de direcciones desde Pro [F17]; gzip *"to some
   high volume accounts"* por solicitud [F3].
3. **La superficie cambia con un add-on**: *"To gain access to the Email Activity Feed
   API, purchase additional email activity history"* [F15]. Un endpoint entero detrás de
   una compra que no es un plan.

**Qué hace v0.3.** `plans` es una lista plana con `endpoints` por plan. La forma 2 cabe
a duras penas (omitir el endpoint en el plan que no lo tiene); la forma 3 no cabe.

**Consecuencia.** Dos clientes del mismo tier pueden tener APIs distintas según lo que
hayan comprado aparte. La comparación por plan no captura eso.

---

## F-09 · Una datasheet no puede decir qué parte sigue vigente — RECURRE ✅

**Qué pasa.** El plan Free permanente de SendGrid **se retiró el 27 de mayo de 2025**
[F11] y lo sustituye una prueba de 60 días [F7]. Cualquier modelado anterior a esa fecha
—incluido, previsiblemente, el del repositorio de la guía y el del TFM de Gavira, que aún
no se han contrastado (Fase 0)— describe un plan que ya no existe, mientras que el resto
de sus datos (precios de Essentials y Pro, topes del endpoint) puede seguir siendo válido.

**Qué hace v0.3.** Un `date` por documento. Misma carencia que en Resend, con un cambio
más grande: no es un valor que cambia, es un plan que desaparece.

**Pendiente.** El contraste con el modelado previo se hará en una pasada aparte y se
registrará como DISC. Cuando se haga, esta entrada se completa con las cifras.

---

## F-10 · Un SaaS con dos productos de precio y dos unidades de consumo — RECURRE ✅

**Qué pasa.** *"Yes! If you want to use Marketing Campaigns and the Email API, you will
need to purchase the email plans separately"* [F1]. El panel muestra los dos productos
con contadores independientes: emails/día para el Email API, contactos y emails/día para
Marketing [F12]. Marketing se factura por contactos, como en Resend.

**Qué hace v0.3.** Un `associated_saas`, una lista de `plans`. Se modela solo el Email
API (A1) y la datasheet no puede declarar que es una parte del servicio.

---

## F-11 · Límites de recursos por plan, que no son consumo — RECURRE ✅ (3/3)

**Qué pasa.** Compañeros de equipo (1 / 1 / 1.000 / 1.000), webhooks de eventos (1 / 2 /
5 / 5), validaciones incluidas (0 / 0 / 2.500 / 5.000), créditos de prueba (0 / 0 / 60 /
60; el panel dice 500 en Premier, incoherencia del pricing cerrada por D17 en DISC-02), fuentes de validación (50) [F1][F12][F17].

**Qué hace v0.3.** Nada; van al provenance (regla B3). Tres de tres.

---

## F-13 · El sobrecoste es opcional y no existe en Free — RECURRE ✅

**Qué pasa.** *"The Free Trial plan covers … sending 100 emails each day for 60 days. You
can’t exceed these limitations"* [F1][F8]: la cuota de la prueba es tope duro. Y una
variante nueva: **la disponibilidad del sobrecoste depende del canal de contratación** —
*"If you created your SendGrid account through Heroku or Google Cloud, your subscription
does not allow for overages"* [F1][F8]. El mismo plan, contratado por un marketplace, es
tope duro; contratado directamente, tiene sobrecoste.

**Lo que añade el sondeo [E1].** La API lo declara como campo: `GET /v3/user/credits`
devuelve `"is_hard_limit": true` para la prueba. Es decir, el proveedor **sí modela** el
matiz que v0.3 no tiene: un booleano que distingue tope duro de sobrecoste. La propuesta
`overage_mode` de Resend tiene aquí un precedente en la propia API del proveedor.

**Qué hace v0.3.** `overage_cost` está o no está. No puede decir «depende de dónde se
compró». La propuesta de Resend (`overage_mode`) cubre lo primero; lo segundo pide un
valor más (`channel_dependent`) o, más honestamente, reconocer que el pricing de
marketplace es otra datasheet (el punto 1.4 del checklist de recolección).

---

## F-14 · El plan tiene fecha de caducidad — NUEVA

**Qué pasa.** La prueba gratuita dura **60 días** y después la capacidad es **cero**: *"the
plan will resolve to "end of trial" status and email send will stop"* [F7]. El panel lo
enseña como fecha literal: *"Your plan will be downgraded to End Of Trial on November 5,
2026"* para una cuenta creada el 6 de septiembre [F12]. Y no es solo la prueba: la baja
de un plan de pago tampoco vuelve a un plan gratuito, cae al mismo estado *"at the turn of
the month"* [F7].

**Qué hace v0.3.** Un plan tiene `price` y `period`. El `period` es el ciclo de
facturación (*"$0/mo for 60 days"*: el precio es mensual, la vigencia es de 60 días).
No hay campo para «este plan existe durante N días» ni para «después de N días la
capacidad es cero». La datasheet dice que Free Trial son 100 emails/día, y eso es cierto
solo hasta el 5 de noviembre.

**Consecuencia.** Cualquier cálculo de capacidad acumulada sobre la prueba a más de 60
días es falso, y el esquema no da forma de saberlo. Para el análisis de Pricing
Intelligence es peor que un hueco: es un valor correcto con caducidad invisible.

**Propuesta.** Un atributo opcional de plan `validity: {value: 60, unit: DAY}` (o
`expires_after`) y un estado terminal explícito (`after_expiry: no_capacity`). Es
barato y no rompe nada. Alternativa mínima: que `period` admita declarar que **no** es
recurrente (`recurring: false`), lo que ya cubriría las pruebas de tiempo limitado.

---

## F-15 · Dos canales, dos workloads para la misma cuota — NUEVA

**Qué pasa.** El mismo plan se consume por la API REST y por el relé SMTP, y las dos
interfaces descuentan la misma cuota (*"Send up to 100 email messages via web API or SMTP
per day"* [F7]). La API acota cada petición: 1.000 destinatarios en total entre `to`, `cc`
y `bcc` [F3], comprobado en [E1], y 30 MiB, medido en [E2]. El relé tiene dos topes que la
API no publica, uno por conexión y otro de concurrencia: *"You may send up to 5k messages per
SMTP connection."* y *"You may open up to 10k concurrent connections from a single
server."* [F13]. Para un mensaje sin la cabecera X-SMTPAPI, las páginas de SMTP consultadas
no publican tope de destinatarios, y para ningún mensaje publican tamaño máximo.

**Corrección del 2026-10-31.** Hasta esa fecha este apartado daba al relé 10.000
destinatarios por mensaje, diez veces la API, con [F14]. Ese tope es de la cabecera
X-SMTPAPI: la página lo enumera entre lo que hay que vigilar al usar la cabecera
(*"However, there are several things to keep in mind when using the header."*) y no lo dice
de cualquier mensaje del relé. Un mensaje sin la cabecera no tiene tope de destinatarios
publicado en las páginas de SMTP consultadas, así que la comparación de destinatarios entre
las dos interfaces sale del caso.

**Qué hace v0.3.** Modela `endpoints`. SMTP no es un endpoint: no tiene ruta ni método.
O se le inventa una ruta ficticia (`smtp://`) —que rompe la conformidad estricta— o se
deja fuera, que es lo que hace esta datasheet, con el dato en el provenance.

**Consecuencia.** La datasheet dice que 5.000 correos de un destinatario cada uno
necesitan al menos cinco peticiones a `/v3/mail/send`. Por el relé caben en una sola
conexión, que admite 5.000 mensajes. La unidad de trabajo depende de la interfaz, y el
modelo solo ve una. Además, el tope de 10.000 conexiones simultáneas es de
**concurrencia**, la dimensión que v0.3 declara fuera de alcance (F-05 la deja a un lado
para RPR, y esta, para conexiones).

**Propuesta.** Permitir «canales» además de endpoints (`channels: {smtp: {workload,
rate}}`), o al menos que un endpoint pueda declarar `protocol`. Y reabrir la dimensión de
concurrencia con un caso real: 10.000 conexiones por servidor es una cifra contractual
publicada que hoy no tiene sitio.

**Relación con Resend.** Resend también tiene SMTP (`smtp.resend.com`) y se anotó como
«canal alternativo; no cambia la capacidad» en la familia no capacitaria. En SendGrid **sí
la cambia**. Cuando se revisite Resend habrá que comprobar si su SMTP tiene topes propios;
si los tiene, F-15 recurre.

**Recuento tras la corrección (2026-10-31).** El caso sigue contando. La fila arbitrada de
F-15 (`05_salida/_herramientas/workflows/revision_externa/unidades/w1/filas/F-15.md`, una de
las entradas de `03_datos/RECURRENCIA_2026-09-23.md`) da una celda por plena si se cumplen
dos condiciones: que una interfaz sin ruta gaste la misma cuota y que publique un tope
propio, de workload o de caudal, que el fichero no puede escribir. SendGrid cumple las dos
sin los 10.000 destinatarios: la cuota común es la de [F7] y los topes propios son los dos
de [F13]. El precedente más cercano es Mailgun: su celda es plena solo por un tope propio
del relé (*"1,500 SMTP requests per second per client IP"*, `mailgun/fuentes.md` [F15]), sin
comparar destinatarios entre interfaces, que es la forma que le queda a SendGrid sin los
10.000. MailerSend cuenta con el mismo criterio, y su relé tampoco publica destinatarios
ni tamaño por mensaje: su celda se apoya en la concurrencia, en las cinco transacciones por
conexión y en que el relé descuenta la cuota diaria por mensaje. La diferencia es que la
concurrencia de MailerSend cambia con el plan (5 o 50 conexiones) y la de SendGrid se
publica como una sola cifra, sin distinguir planes. La celda de SendGrid sigue en ✅ y el
recuento del inventario no cambia.

---

## F-16 · El sobrecoste tiene tope — NUEVA

**Qué pasa.** El plan de pago no permite pagar sobrecoste indefinidamente: *"Starting
March 26, 2026, a sending limit was applied to accounts under the Email API Essentials
and Pro plans, capping their allotment to 10X times the plan. For example, if your
account is under the Email API Essentials 50K plan, you can send up to 500,000 requests
to our server throughout the month"* [F18]. En cuentas de reseller el tope es 2,5 × el
plan. Y el proveedor explica por qué: a partir de ahí *"paying for overages is more
expensive than upgrading the plan"*. No está en la página de precios ni en el artículo de
sobrecostes [F8]: está en un artículo de **resolución de errores**.

**Qué hace v0.3.** `overage_cost` es un precio unitario sin límite de cantidad. La
datasheet dice que Essentials 50K son 50.000 emails y $0.0013 por cada extra, lo que se
lee como «capacidad ilimitada a ese precio». La capacidad real es 500.000 y después un
error `Maximum credits exceeded`.

**Consecuencia.** Cualquier cálculo de coste o de capacidad máxima por encima de 10 × el
volumen contratado es falso, y el esquema no da forma de saberlo. Para Pricing
Intelligence es el mismo defecto que F-14: un valor correcto con un techo invisible. Y el
techo cambió en marzo de 2026, así que un modelado anterior lo describiría mal (F-09).

**Propuesta.** `overage_cost` con un `max` opcional (`max: {value: 10, unit: x_plan}` o
en unidades absolutas), o un `hard_limit` a nivel de cuota distinto del `value`. Emparenta
con F-13 (`overage_mode`): entre las dos describen el sobrecoste como lo que es, un tramo
acotado y condicionado, no un precio unitario abierto.

**Pendiente en las otras dos APIs.** Ni en Postmark ni en Resend se buscó un tope de
sobrecoste; hay que volver a mirar (el artículo de Postmark sobre *overage* y la
knowledge base de Resend) antes de dar F-16 por única de SendGrid.

---

## Familia aparte: características no capacitarias (decisión Q6, 2026-09-01)

| Rasgo | SendGrid | Qué es |
|---|---|---|
| Entregabilidad | Panel: `"Reputation 100%"` en la barra lateral; *"Delivery Optimization Tools"* en todos los planes [F12] | Resultado observado, no contratado |
| Reputación / warm-up | *"Automated, dedicated IP warm up"* en la tabla de características [F1]; bloqueo temporal 403 *"due to repeated bad requests"* [F9] sin umbral | Afecta al techo real de envío sin cifra publicada |
| IP dedicada | Incluida en Pro y Premier, $30/mes cada IP extra [F1][F12] | Cubierto como F-07 |
| Canal SMTP | `smtp.sendgrid.net`, misma cuota, **topes propios** [F13] | **Ya no es solo alternativo: F-15** |
| Identidad de remitente | Sin identidad verificada, 403 *"From address doesn't match Verified Sender Identity"* [F9]; el panel lo exige antes del primer envío [F12] | Precondición de uso, no capacidad |

## Observaciones sobre el propio repositorio y la especificación del proveedor

**O-06 · La especificación OpenAPI del proveedor no lleva el tope que sí lleva la prosa.**
En `twilio/sendgrid-oai` (`spec/json/tsg_mail_v3.json`, consultada por el verificador),
`personalizations`, `cc` y `bcc` declaran `maxItems: 1000`, **`to` no declara ninguno**, y
no hay rastro de los 30 MB ni de rate limits. El tope total de 1.000 destinatarios solo
existe en prosa [F3]. Para un pipeline que quisiera derivar datasheets de OpenAPI
automáticamente (la vía que el checklist de recolección pone en segundo lugar), SendGrid
demuestra que la especificación formal es **menos completa** que la documentación
narrativa. No es una observación sobre `apis_consumption_model` sino sobre la premisa de
que OpenAPI sea una fuente suficiente.

**O-07 · La semántica de `X-RateLimit-Reset` cambia por endpoint.** En [E1],
`/v3/user/profile`, `/v3/api_keys` y `/v3/scopes` devuelven **segundos restantes** (`9`,
`6`, `58`) y `/v3/templates`, `/v3/user/credits` y `/v3/user/account` devuelven una
**marca de tiempo Unix** (`1788727620`). La documentación [F2] solo muestra la segunda.
Para una herramienta que lea cabeceras y calcule el *cooling period*, es una trampa: el
mismo nombre, dos unidades. No es fricción de v0.3 sino del proveedor; va al capítulo 5
como hallazgo y a la propuesta de `status: measured` de F-01 como advertencia.

**Candidato a F-04 (sin confirmar).** [F15] dice que para acceder a la Email Activity
Feed API hay que comprar el add-on; en [E1] la cuenta de prueba recibe `200 {"messages":
[]}` de `/v3/messages`. Puede que la restricción sea sobre la profundidad del historial y
no sobre el endpoint. Si se confirma con una cuenta que tenga actividad, sería la segunda
API con una restricción declarada y no aplicada.

**Recordatorio de DV-03.** `price: custom` en Premier tumba las 13 operaciones de
PRIME4API que no son de navegación, igual que Enterprise en Resend. Sin Premier, la
datasheet pasa 20 de 20. Tercera API con el mismo fallo: el issue merece abrirse.

## Nota sobre el verificador (no es fricción del esquema)

El verificador adversarial (D-013) no refutó ningún dato pero encontró **cinco páginas**
que el constructor no había abierto, y en una de ellas estaba F-15 entera. Es la segunda
vez (Resend destapó las citas sin literal) que el segundo lector aporta algo que el
primero no vio. Para el capítulo 2 (metodología): el fan-out no es redundancia, es
cobertura.
