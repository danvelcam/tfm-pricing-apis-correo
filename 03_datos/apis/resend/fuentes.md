# Fuentes — Resend

API de correo transaccional y de marketing. Proveedor: Resend (Plus Five Five, Inc.).
Recolección: **2026-08-05 (pasada 1)**.
Toda cita es literal. La numeración [Fn] es la que referencia este registro; el
`datasheet.yaml` lleva el *provenance* autocontenido con URLs directas.

> **Encuadre.** Resend **ya estaba modelada** en el repositorio de la guía, en
> `datasheets/resend/resend_v01.yaml` (sintaxis 0.1, fecha 2026-02-24) y en
> `resend-transactional/datasheet/{free,pro,scale}-datasheet.yml` (formato previo a la
> sintaxis). Esta pasada **no parte de cero**: migra a v0.3 y **verifica contra fuente**.
> Dos de sus valores han cambiado desde febrero (ver DISC-02 y DISC-03).

---

## [F1] Página de pricing

- **URL:** https://resend.com/pricing
- **Fecha de acceso:** 2026-08-05
- **Citas literales:**
  - Free — `"$0 / mo"`, `"3,000 emails / mo"`, `"100 emails a day"`, `"30-day data retention"`,
    1 dominio, `"Ticket support"`
  - Pro — `"$20 / mo"`, `"50,000 emails / mo"`, `"Extra emails: $0.90 / 1,000"`,
    `"No daily limit"`, 10 dominios
  - Scale — `"$90 / mo"`, `"100,000 emails / mo"`, `"Extra emails: $0.90 / 1,000"`,
    1.000 dominios, `"Dedicated IP with add-on"`, `"Slack & ticket support"`
  - Enterprise — precio, volumen y condiciones a medida; `"Priority support"`
  - Add-on — Dedicated IPs `"$30 / mo"`, disponible al superar 3.000 emails al día en Scale
- **Observaciones:** la página segmenta por producto (`?product=transactional` frente al
  producto de marketing). Lo modelado aquí es **solo el transaccional** (ver Q1).

## [F2] Pricing en formato legible por máquina

- **URL:** https://resend.com/pricing.md
- **Fecha de acceso:** 2026-08-05
- **Citas literales:**
  - Free — `"Limited to 100 emails per day."`
  - `"The overage rate applies only to emails sent beyond the included volume."`
  - `"Marketing plans are not limited by the number of emails sent — only by the number of contacts."`
  - Volumen contratado dentro del plan, con su precio y su sobrecoste por 1.000:

    | Plan | Volumen | Precio | Sobrecoste /1.000 |
    |---|---|---|---|
    | Pro | 50.000 | $20 | $0.90 |
    | Pro | 100.000 | $35 | $0.90 |
    | Scale | 100.000 | $90 | $0.90 |
    | Scale | 200.000 | $160 | $0.80 |
    | Scale | 500.000 | $350 | $0.70 |
    | Scale | 1.000.000 | $650 | $0.65 |
    | Scale | 1.500.000 | $825 | $0.52 |
    | Scale | 2.500.000 | $1.150 | $0.46 |

  - Retención de datos — `"30-day"` en Free, Pro y Scale; flexible en Enterprise
- **Observación crítica:** el sobrecoste **baja al subir el volumen contratado**, y en Pro
  se mantiene igual entre sus dos volúmenes. Es el mismo patrón que Postmark, pero aquí
  **publicado** (ver F-02 en `fricciones.md`).

## [F3] Developer docs — Introduction

- **URL:** https://resend.com/docs/api-reference/introduction
- **Fecha de acceso:** 2026-08-05
- **Citas literales:**
  - Base — `"https://api.resend.com"`
  - Autenticación — `"Bearer re_xxxxxxxxx"`
  - `"429"` → `"The rate limit was exceeded."`
  - `"401"` → `"The API key used was missing."` · `"403"` → `"The API key used was invalid."`

## [F4] Developer docs — Rate limit

- **URL:** https://resend.com/docs/api-reference/rate-limit
- **Fecha de acceso:** 2026-08-05
- **Citas literales:**
  - `"The default maximum rate limit is 10 requests per second per team."`
  - `"This number can be increased for trusted senders upon request."`
  - `"If you have specific requirements, contact support to request a rate increase."`
  - `ratelimit-limit` — `"Maximum number of requests allowed within a window."`
  - `ratelimit-remaining` — `"How many requests you have left within the current window."`
  - `ratelimit-reset` — `"How many seconds until the limits are reset."`
  - `retry-after` — `"How many seconds to wait before making a follow-up request."`
- **Observación:** el caudal es **por equipo**, no por clave de API, y la documentación
  **no lo hace variar por plan**. Es el contraste directo con Postmark, que documenta el
  429 sin publicar umbral (F-01).

## [F5] Developer docs — Send Email

- **URL:** https://resend.com/docs/api-reference/emails/send-email
- **Fecha de acceso:** 2026-08-05
- **Citas literales:**
  - `to` — `"Recipient email address. For multiple addresses, send as an array of strings. Max 50."`
  - `cc` — `"Cc recipient email address. For multiple addresses, send as an array of strings."`
  - `bcc` — `"Bcc recipient email address. For multiple addresses, send as an array of strings."`
  - `attachments` — `"Filename and content of attachments (max 40MB per email, after Base64 encoding of the attachments)."`
  - `scheduled_at` — `"Schedule email to be sent later. The date should be in natural language (e.g.: 'in 1 min') or ISO 8601 format."`
- **Observación:** el `"Max 50"` se declara **solo en `to`**; `cc` y `bcc` no declaran tope.
  Es la misma ambigüedad que destapó DISC-01 en Postmark, con los papeles invertidos
  (allí los tres campos declaraban 50 y el total era 50). Ver DISC-04.

## [F6] Developer docs — Send Batch Emails

- **URL:** https://resend.com/docs/api-reference/emails/send-batch-emails
- **Fecha de acceso:** 2026-08-05
- **Citas literales:**
  - `"Trigger up to 100 batch emails at once."`
  - `to` — `"Max 50"`
  - `"The attachments field is not supported yet."`
- **Observación:** el tope de 100 mensajes por llamada se combina con los destinatarios de
  cada mensaje. CRF multiplicativo → F-03.

## [F7] Knowledge base — What is Resend pricing

- **URL:** https://resend.com/docs/knowledge-base/what-is-resend-pricing
- **Fecha de acceso:** 2026-08-05
- **Citas literales:**
  - `"Transactional Email plans are based on the number of emails sent and received each month."`
  - `"The Free plan is limited to 100 emails per day."`
  - `"Multiple To, CC, or BCC recipients count as separate emails."`
- **Observación crítica:** la última cita fija el **CRF**: una petición consume tantas
  unidades como destinatarios tenga, no una por petición. Es el dato que hace que
  `workload` sea imprescindible y el que Postmark nunca llegó a declarar por escrito.

## [F8] Repositorio de la guía — modelado previo de Resend

- **URL:** https://github.com/API-TaskForce/apis_consumption_model
- **Fecha de acceso:** 2026-08-05 (clonado de `main`)
- **Ficheros:** `datasheets/resend/resend_v01.yaml` (`syntax_version: 0.1`,
  `date: 2026-02-24`) y `resend-transactional/datasheet/{free,pro,scale}-datasheet.yml`
- **Citas literales:**
  - `resend_v01.yaml` — `rate_api_request_team_pool_free: value: 2, unit: requests, period: 1 second`
  - `free-datasheet.yml` — `maxPower: value: 2 requests/second`
  - `free-datasheet.yml` — `coolingPeriod: TBD (Sin embargo se incluye la cabecera Retry-After en las respuestas 429)`
  - `free-datasheet.yml` — `segmentation: Account Level (Authenticated): Múltiples API Keys aplican sobre el mismo límite global de la cuenta.`
  - `resend_v01.yaml` — `quota_log_retention_days_free: value: 1, unit: records`
- **Observaciones:** el fichero `free-datasheet.yml` usa un formato anterior a la sintaxis
  (`Assoaciated SaaS`, con la errata en el original; `maxPower`, `coolingPeriod`,
  `segmentation`) y **no valida contra v0.3**. Dos de sus valores están desfasados
  (DISC-02, DISC-03) y uno fuerza el esquema (O-04).

---

## [F9] Panel de cuenta — observación con cuenta propia (escalón 2)

- **Fecha de acceso:** 2026-09-01
- **Cuenta:** plan Free, sin dominio verificado, una clave de API con permiso de envío
- **Evidencia:** `evidencias/panel_suscripciones_2026-09-01_redactado.png`,
  `evidencias/panel_cuota_transaccional_2026-09-01_redactado.png`,
  `evidencias/panel_limites_equipo_2026-09-01_redactado.png`,
  `evidencias/panel_addons_payg_2026-09-01_redactado.png`
- **Citas literales (Settings → Billing):**
  - Subscriptions: `"Transactional — 3,000 emails — $0 / mo"` y `"Marketing — 1,000 contacts — $0 / mo"`,
    como dos suscripciones independientes bajo la misma cuenta
- **Citas literales (Settings → Usage):**
  - Transactional · Free: `"Monthly limit 0 / 3000"` desglosado en `"Sending"` y `"Receiving"`;
    `"Daily limit 0 / 100"` con el mismo desglose. **El panel no muestra fecha ni hora de
    reposición** de ninguno de los dos contadores.
  - Marketing · Free: `"Contacts limit 0 / 1000"`, `"Segments limit 1 / 3"`, `"Broadcasts limit Unlimited"`
  - Team · Free: `"AI credits 0 / 5"`, `"Automations 0 / 10.000"`, **`"Domains 0 / 3"`**, `"Rate limit 10 req/s"`
  - Extras · Pay-as-you-go, marcado `"Paid feature"`, con interruptor apagado:
    `"Transactional · $0.90 / Per 1,000 Emails — When enabled, you will continue sending and
    receiving transactional emails beyond your quota. Resend will automatically charge $0.90
    for each additional bucket of 1,000 emails."`
  - Add-ons: `"Domains - $20 / Mo — Adds 100 domains on top of the number included in your
    plan. You'll need to be on a paid transactional plan to add more domains."`;
    `"Dedicated IPs - $30 / Mo — Resend will provision, warm up, monitor and auto-scale the
    dedicated IP to ensure consistent deliverability and performance. You'll need to be on a
    Scale plan or higher to request a dedicated IP."`; `"Single Sign-On - $150 / Mo … Scale
    plan or higher"`
- **Observaciones sin cita (estructura del panel):**
  - La sección *Emails* es un registro (`"No sent emails yet"`) con pestañas *Sending* y
    *Receiving*; **no hay formulario de envío transaccional en el panel**. El único envío
    desde la interfaz es *Broadcasts* (producto de marketing).
  - *Metrics* muestra `"Deliverability rate"`, `"Bounce rate"` y `"Complain rate"` por
    dominio: la entregabilidad se mide en la cuenta, no se contrata.
  - *Settings → SMTP*: `smtp.resend.com`, usuario `resend`, contraseña = la clave de API.
    Canal alternativo al REST con la misma credencial.
  - Sin dominio verificado el panel indica que hay que añadir uno para
    `"start sending and receiving emails from your own address"`.

### DISC-05 · Dominios incluidos en Free: 1 el 2026-08-05, 3 el 2026-09-01

- **Página de pricing [F2], 2026-08-05:** 1 dominio en Free.
- **Página de pricing y knowledge base, 2026-09-01:** `"Custom domains 3 / 10 / 1,000 / Flexible"`;
  `"Free 3, Pro 10, Scale 1,000, Enterprise Set by contract"`. **Panel [F9], 2026-09-01:**
  `"Domains 0 / 3"`.
- No es una discrepancia entre fuentes: es un **cambio de la oferta** en menos de un mes, el
  tercero detectado en Resend (DISC-02 caudal, DISC-03 retención). Alimenta F-09 (vigencia
  por dato). La datasheet no lo modela (Q6) pero lo registra en el provenance con las dos
  fechas.

### Reverificación adversarial de [F1]–[F7] — 2026-09-01

Todas las fuentes documentales se volvieron a leer con el navegador y se contrastaron
dato a dato con la datasheet. **Ningún valor modelado ha cambiado**: precios y volúmenes
de los diez planes, sobrecostes, 100/día, 3.000/mes, `"Max 50"` en `to`, 100 por lote,
40 MB de adjuntos, 10 rps y 30 días de retención coinciden. Lo que sí ha cambiado es la
documentación alrededor:

- La página de rate limit se ha convertido en **«Usage Limits»** y ahora dice
  `"Both sent and received emails count towards these quotas"`, con las cabeceras
  `x-resend-daily-quota` (`"Only sent to free plan users"`) y `x-resend-monthly-quota`.
  Lo que el panel enseñó como F-12 está **documentado a fecha de hoy**; no lo estaba el
  2026-08-05.
- La knowledge base dice ahora `"based on the number of emails sent and received each
  month"` y, para Free, `"Overage Not available"` y `"Paid plans have no daily sending
  limit"`: F-13 también está documentada hoy.
- La página de errores: `"daily_quota_exceeded … wait until 24 hours have passed"`
  (ventana del límite diario: 🔴 → 🟡 `rolling`), `"email_above_quota (403): You can't
  retrieve this email's content because it was above quota when received"` (un correo
  entrante por encima de cuota se recibe pero no se puede leer: matiz de F-12) y `"You
  can only send testing emails to your own email address"` sin dominio verificado.
- Pricing: `"Webhook endpoints 1 / 5 / 10 / Flexible"` y `"AI credits 5 / 100 / 500"`
  (más límites de recursos para F-11) y `"Enterprise rate limits"` como característica
  del plan Enterprise (el caudal ampliado es contractual).
- Sigue sin existir un error ni un texto que resuelva el tope conjunto de destinatarios
  (Q2): el 🟡 se mantiene.

- **Segunda visita, 2026-09-06** (Claude in Chrome, cuenta del autor, solo lectura): mismas
  cifras que el 01-09 en Usage (`"Monthly limit 0 / 3000"`, `"Daily limit 0 / 100"`,
  ambos desglosados en `Sending`/`Receiving`; Team: `"Domains 0 / 3"`, `"Rate limit 10 req/s"`;
  Extras: `"Pay-as-you-go — Paid feature — Transactional · $0.90 / Per 1,000 Emails"`,
  interruptor apagado; Add-ons: `"Domains - $20 / Mo — Adds 100 domains… You'll need to be
  on a paid transactional plan"`) y en Billing (`"Transactional 3,000 emails $0 / mo"`,
  `"Marketing 1,000 contacts $0 / mo"`, sin fecha de ciclo porque el plan es gratuito).
  **Sigue sin aparecer ninguna fecha de reposición** ni del contador diario ni del
  mensual. Evidencia: `evidencias/panel_usage_transaccional_2026-09-06_redactado.png`,
  `evidencias/panel_usage_equipo_payg_2026-09-06_redactado.png`.

## [F10] Developer docs — operaciones 4 a 8 del test de `type` (C2), leídas en la referencia de cada endpoint

- **URLs:** `/docs/api-reference/api-keys/create-api-key` (4) ·
  `/docs/api-reference/webhooks/create-webhook` (5) ·
  `/docs/api-reference/emails/list-received-emails` y
  `/docs/dashboard/receiving/create-receiving-webhook` (6) ·
  `/docs/api-reference/suppressions/add-suppression` (7) ·
  `/docs/api-reference/logs/list-logs` (8), todas bajo `https://resend.com`
- **Fecha de acceso:** 2026-09-14
- **Origen:** lectura de la referencia con el navegador del autor; sin volcado (D-023).
  **Por qué esta fuente existe:** el 14-09, en la primera pasada, estas cinco operaciones se
  dieron por vistas en el **índice agregado** (`/docs/llms.txt`), que no es la referencia del
  endpoint; por eso el `type` bajó a 🟡 por D9. Esta entrada las repone una a una
- **Citas literales, una por operación:**
  - **(4) credenciales adicionales** — `"POST /api-keys"`, `"Add a new API key to authenticate
    communications with Resend."`; y además Update API key, Delete API key y, para los
    webhooks, `"Rotate Signing Secret"`
  - **(5) webhooks** — `"POST /webhooks"`, `"Create a webhook to receive real-time
    notifications about email events."`; con Update, Delete, Replay Event y List Attempts
  - **(6) inbound routing** — `"GET /emails/receiving"`, `"Retrieve a list of received emails
    for the authenticated user."`; la configuración del enrutado es el webhook
    `email.received`, que la guía declara API-able — `"create your webhook from the Webhooks
    API"` —, y el registro MX es acto del usuario en su DNS: `"Receiving emails requires an
    extra MX record to work. You'll need to add this record to your DNS provider."` Es la
    misma excepción que C2 escribe para la operación 3
  - **(7) supresiones** — `"POST /suppressions"`, `"Add an email address to the suppression
    list."`; con List, Remove y las dos variantes batch
  - **(8) actividad y logs** — `"GET /logs"`, `"Retrieve a list of API request logs."`; más
    List Sent Emails y Retrieve Metrics
- **Observación.** Ninguna de las cinco quedó solo en el panel, así que ninguna genera
  fricción. Con esto las **ocho** operaciones del test están comprobadas y el `type` vuelve a
  🟢 por D9, sin cambiar de valor: sigue siendo `api_first`.

## [F11] Panel de cuenta — operaciones 4 a 8 del test de `type` (escalón 2)

- **Fecha de acceso:** 2026-09-14
- **Cuenta:** la propia del autor, plan Free, sin dominios dados de alta. Modo lectura
- **Evidencia:** `evidencias/panel_operaciones_c2_2026-09-14.md` (volcado de texto; sin captura,
  y sin transcribir correo ni identificadores)
- **Citas literales:**
  - Menú lateral: `Emails`, `Broadcasts`, `Automations`, `Templates`, `Audience`, `Metrics`,
    `Domains`, `Logs`, `API keys`, `Webhooks`, `Settings`; dentro de Settings, `Usage`,
    `Billing`, `Team`, `SMTP`, `Integrations`, `Unsubscribe page`, `Documents`
  - Página Domains con la cuenta vacía: `"No domains yet"`, `"Verify a domain by adding a DNS
    record and start sending and receiving emails from your own address."`
- **Observación.** Ninguna de las cinco operaciones queda solo en el panel. La única asimetría es
  **a favor de la API**: el panel **no tiene sección de supresiones** y la API sí las gestiona
  (`POST /suppressions`, List, Remove y las dos variantes batch). C2 solo castiga lo contrario
  —lo que está en la web y no en la API—, así que no toca el `type`; se anota porque describe el
  producto.

## [E1] Sondeo empírico — ventana diaria y tope de destinatarios (escalón 3)

- **Fecha:** 2026-09-06, 18:36 UTC · **Ejecutado por:** el autor, en su máquina, con la clave
  de la cuenta Free (sin dominio verificado: solo se puede enviar a la propia dirección
  desde `onboarding@resend.dev`)
- **Script:** `05_salida/_herramientas/probe_resend_ventana_destinatarios.sh AB`
- **Evidencia:** `evidencias/probe_ventana_destinatarios_2026-09-06.json` (clave redactada),
  `evidencias/panel_usage_tras_sondeo_2026-09-06_redactado.png`
- **Resultados y citas literales:**
  - `A` (1 destinatario): HTTP 200. Cabeceras: `ratelimit-limit: 10`, `ratelimit-policy: 10;w=1`,
    `ratelimit-remaining: 9`, `ratelimit-reset: 1`, `x-resend-daily-quota: 0`, `x-resend-monthly-quota: 0`.
  - `B1` (51 en `to`): HTTP 422 `"Field `to` has a maximum of 50 items."`
  - `B2` (26 en `to` + 25 en `cc`): HTTP 422 `"The total number of recipients cannot exceed 50."`
  - `B3` (25 + 25 = 50): HTTP 200; `x-resend-daily-quota: 1`, `x-resend-monthly-quota: 1`.
  - Panel tras el sondeo: `"Monthly limit 2 / 3000"`, `"Daily limit 2 / 100"`; la lista de
    Emails muestra dos entradas `Delivered`. El envío de 50 direcciones idénticas contó como 1.
- **Lo que cierra:** DISC-04 (50 en total por petición) y el caudal del plan Free, que
  pasa de documental a verificado. **Lo que deja abierto:** la ventana diaria, pendiente
  de leer el contador el 2026-09-07 hacia las 18:06 UTC (30 min antes del envío A) y
  hacia las 18:40 UTC.

## Discrepancias entre fuentes

### DISC-02 · El caudal se ha multiplicado por cinco desde febrero

- **Repositorio [F8], 2026-02-24:** `2 requests/second`, en los cuatro planes.
- **Documentación oficial [F4], 2026-08-05:** `"The default maximum rate limit is 10
  requests per second per team."`

Ninguna de las dos miente: el proveedor subió el límite entre ambas fechas. **Se toma el
valor documentado hoy (10 rps)** y se registra el anterior con su fecha. No es un error
del modelado previo, es la vida útil de una datasheet — y es exactamente el argumento
que justifica exigir fecha de acceso y cita literal en cada dato.

### DISC-03 · La retención de datos ya no depende del plan

- **Repositorio [F8], 2026-02-24:** 1 día en Free, 3 en Pro, 7 en Scale.
- **Página de pricing [F1][F2], 2026-08-05:** `"30-day data retention"` en Free, Pro y
  Scale por igual.

Se toma el valor publicado hoy. La dimensión deja de discriminar entre planes, así que
**no se modela como cuota por plan** (ver Q3).

### DISC-04 · El tope de destinatarios se declara en un solo campo

**RESUELTA el 2026-09-06 por sondeo [E1]: 50 destinatarios EN TOTAL por petición**, la misma forma que DISC-01 de Postmark. La documentación declara el tope en `to` y la API lo aplica a la suma de `to`, `cc` y `bcc`: `"The total number of recipients cannot exceed 50."`.

- **`to` [F5]:** `"Max 50"`.
- **`cc` y `bcc` [F5]:** sin tope declarado.
- **Consumo [F7]:** `"Multiple To, CC, or BCC recipients count as separate emails."`

En la pasada 1 no estaba resuelto si el tope de 50 era del campo `to` o del conjunto de la
petición; la datasheet declaraba `max: 50` en 🟡 y la duda quedó abierta como Q2. El sondeo
[E1] del 2026-09-06 la cerró: el tope es del conjunto (`to` + `cc` + `bcc`) y `max: 50` pasa
a 🟢.

---

## Fuentes buscadas y NO encontradas

| Qué se buscó | Dónde | Resultado |
|---|---|---|
| Ventana de reinicio del límite diario del plan Free | pricing, knowledge base, docs, panel, **sondeo en curso** | No publicada ni observable en el panel [F9]. Sondeo [E1] lanzado el 2026-09-06 a las 18:36 UTC; la lectura del contador el 07-09 decide entre `rolling` y reinicio a hora fija |
| ~~Tope conjunto de destinatarios por petición~~ | docs, panel, **sondeo** | Resuelto por sondeo [E1] el 2026-09-06: 50 en total |
| Umbral y caudal de *trusted sender* | docs, **panel** | El panel enseña `"Rate limit 10 req/s"` y ninguna vía de solicitud [F9] |
| Caudal por plan | docs de rate limit, pricing | Solo hay un valor por defecto; no se afirma ni se niega que varíe |
| Definición de *trusted sender* y caudal concedido | docs de rate limit | `"upon request"`, sin umbral ni valor |
| Tope de destinatarios por mensaje dentro de `/emails/batch` | docs de batch | El `"Max 50"` aparece en el `to` de cada mensaje, sin aclarar el conjunto |
| Valor del cooling period tras un 429 | docs de rate limit | Solo la cabecera `retry-after`; el valor lo fija el servidor en cada respuesta |
| Especificación OpenAPI/Swagger pública | docs, GitHub del proveedor | No localizada |
| Límites de la API de marketing (broadcasts) | pricing, docs | Producto de precio aparte, limitado por contactos; fuera del alcance de esta pasada (Q1) |
