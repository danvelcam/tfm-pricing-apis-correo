# Fuentes — Mailgun

API de correo transaccional. Proveedor: **Sinch Mailgun**. Recolección: **2026-09-21**,
pasada 1, siete lentes documentales (identificación, precios, límites, endpoints/CRF,
contrato de rechazo, features, ToS/AUP) más **panel de cuenta propia el mismo día**
(escalón 2, `evidencias/panel_mailgun_2026-09-21.md`). Toda cita es literal.

**Aviso de fiabilidad de una fuente concreta.** `https://www.mailgun.com/ai-info/` está
protegida por Cloudflare: ni `curl` ni WebFetch en modo bruto devuelven el HTML, solo el
resumen que construye la propia herramienta al leer la página con un modelo pequeño. Por
**E10** esa síntesis no vale como transcripción literal — puede omitir sin avisar—, así
que cada cifra que sale de ahí se marca 🟡 y nunca sube a verde por sí sola. Se registra
porque es la única fuente oficial que se pronuncia con un número sobre el caudal, no
porque el número esté confirmado.

**Segundo aviso, de alcance (regla A1).** Mailgun vende, bajo la misma cuenta, tres
productos con pricing propio — *Mailgun Send* (transaccional, el modelado aquí), *Mailgun
Optimize* (deliverability/reputación/validación) y *Mailgun Inspect* (email testing). El
panel lo confirma: `Mailgun Optimize — No subscription` y `Mailgun Inspect — No
subscription` en la misma pantalla de facturación que `Mailgun Send — Free` [F24]. Las
cifras de Optimize (`500 requests every 10 seconds` [F16], validaciones de email) se
registran y se excluyen del modelado.

---

## Identificación, precios y matriz de features

## [F1] Página de precios — www.mailgun.com/pricing/

- **URL:** https://www.mailgun.com/pricing/
- **Fecha de acceso:** 2026-09-21
- **Citas literales — identificación:**
  - Título de la página: `"Transactional Email API Service For Developers"`
- **Citas literales — planes, precio y volumen incluido:**
  - Free: `"$0/mo"` · `"100 emails/day included"` · `"1 day log retention"` ·
    `"1 day of bounce classification"` · `"1 inbound route"` · `"2 API keys"`
  - Basic: `"Starting at"` · `"$15/mo"` · `"10,000 emails/mo included"` · overage
    `"from $1.80 / 1,000 emails"` · `"1 day log retention"` · `"1 day of bounce
    classification"` · `"5 inbound routes"` · `"2 API keys"`
  - Foundation: `"Free for 1 month, then"` · `"$35/mo"` · `"50,000 emails/mo included"`
    · overage `"from $1.30 / 1,000 emails"` · `"5 days log retention"` · `"5 days of
    bounce classification"` · `"1 day message retention"` · `"Full access to inbound
    routing"` · `"Email template builder and API"`
  - Scale: `"Free for 1 month, then"` · `"$90/mo"` · `"100,000 emails/mo included"` ·
    overage `"from $1.10 / 1,000 emails"` · `"30 days log retention"` · `"30 days of
    bounce classification"` · `"Up to 7 days of Message Retention"` (tooltip: `"Message
    retention defaults to 3 days and can be increased to 7 days on a per domain
    basis"`) · `"One Dedicated IP Included"` · `"Send time optimization"`
  - Add-on de validación: `"from $1.20 / 100 validations"` (Basic; escalona por plan,
    `"5,000 email validations included"` en Scale)
  - Plan Custom/Enterprise, **sin fila ni tarjeta con nombre propio** (regla A3):
    `"Need more? Get in touch with our team to tailor an Enterprise experience to fit
    your needs."` · `"Partner with Mailgun to create an enterprise-grade solution for
    delivering email at scale."` · botón `"Request a quote"`
- **Citas literales — selector de volumen (F-02/E9):**
  - `"How many emails do you want to send per month?"` con opciones `"10,000 50,000
    100,000 250,000 500,000 750,000 1,000,000 2,500,000 More"`
  - **Sin verificar con navegador**: WebFetch es un fetch estático sin ejecución de JS,
    así que no se pudo determinar si mover el selector cambia el precio mostrado en las
    tarjetas o solo recomienda un plan.
- **Citas literales — matriz comparativa por plan (fila · Free · Basic · Foundation ·
  Scale):**
  - Custom Sending Domains: `1` · `1` · `1,000` · `1,000`
  - Message Retention: no incluida (`false`) · no incluida (`false`) · `"1 day message
    retention"` · `"Up to 7 days of Message Retention"`
  - Inbound Routing (Receiving): `"1 inbound route"` · `"5 inbound routes"` · `"Full
    access to inbound routing"` (`true`) · hereda de Foundation (`true`)
  - Webhooks: incluido en las cuatro columnas (`cols: true`)
  - Dedicated IPs: no · no · `"Access at 50k, included at 100K+ volumes"` · `"One
    Dedicated IP Included"`; add-on adicional `"you can add additional IPs to your
    account for $59/IP/month from within the control panel or by contacting support."`
  - Dedicated IP pools: solo Scale (`[false,false,false,true]`)
  - Authentication Protocols (SPF, DKIM, DMARC, BIMI, etc.): incluido en las cuatro
    (`cols: true`)
  - Multi-user Access: no · no · sí · sí (`[false,false,true,true]`)
  - RBAC API Keys: no · no · sí · sí (`[false,false,true,true]`)
  - SAML SSO: no · no · no · sí (`[false,false,false,true]`)
  - Guaranteed Uptime SLA: no · no · sí · sí (`[false,false,true,true]`)
  - Email Validations: no · `"Available as add-on"` · `"Available as add-on"` ·
    `"5,000 email validations included"`
  - Email Templates: incluido en las cuatro (`cols: true`) — **ver DISC-02**
  - Ticket Support: incluido en las cuatro (`cols: true`); Scale añade `"Live phone &
    chat support"`; Chat Support y Phone Support marcados `[false,false,false,true]`
    (solo Scale)
  - Send Time Optimization (STO): solo Scale (`[false,false,false,true]`)
  - Subaccounts: fila con `cols: false` sin desglose por plan
  - SMTP Relays: incluido (`cols: true`); texto de venta — Free/Basic `"RESTful email
    APIs and SMTP relay"`, Foundation `"Full access to RESTful email APIs and SMTP
    relays"`
- **Citas literales — usuarios, región y otros:**
  - `"Free plans are limited to 1 user per account."` · `"Every Mailgun plan (except
    free and basic) allows you to add as many users as you need to your account at no
    additional cost."` (Basic queda excluido de «tantos como necesites» sin que se
    publique su cifra)
  - Región de datos: `"Send email through the US or the EU from a single account.
    Mailgun's service is hosted within both regions, so your data can remain in the
    region of your choice."` (no condicionado por plan)
  - IP dedicada, FAQ: `"One dedicated IP is included with Foundation 100k, Growth and
    Scale plans."` — el plan `"Growth"` **no aparece** en la tabla de precios ni en el
    bloque `pricingData.plans` (solo `free/basic/foundation/scale`); no se ha podido
    confirmar si es nombre histórico, alias u otro producto.
- **Citas literales — listado de bullets `"Features include:"` por plan (distinto de
  la matriz comparativa; ver DISC-02):**
  - Free: no menciona plantillas en su lista de bullets
  - Basic: no menciona plantillas en su lista de bullets
  - Foundation: `"Email template builder and API"`
  - Scale: `"Everything on Foundation plus..."` (no repite el bullet de plantillas)
- **Observación:** es la fuente más citada del catálogo de Mailgun — precio, volumen,
  overage, selector y la matriz completa de features viven en esta única URL. No hay
  planes anuales ni toggle mensual/anual en el contenido recuperado.

---

## Límites, cuotas y tamaños

## [F2] Developer docs — API Overview

- **URL:** https://documentation.mailgun.com/docs/mailgun/api-reference/api-overview
- **Fecha de acceso:** 2026-09-21
- **Citas literales:**
  - Base URI: `"https://api.mailgun.net/"` (US) · `"https://api.eu.mailgun.net/"` (EU)
  - Cabeceras de rate limit: `"Mailgun APIs include the following headers to indicate
    rate limiting state for the current API being called: X-RateLimit-Limit — Total
    calls that can be made in each time window. X-RateLimit-Remaining — Calls remaining
    in the given time window. X-RateLimit-Reset — Unix milliseconds (UTC) until the
    limit resets. Used for back-off logic on a HTTP 429 response. Time windows may vary
    by API depending on resource usage."`
  - `429 | Rate Limited | "Rate limits exceeded. Retry as defined in response headers
    defined below. Contact support if limits need adjustment"`
  - `403 | Forbidden | "Valid credentials but access denied. Ensure you have
    permissions for the requested resource"`
  - `401 | Unauthorized | "Invalid or missing API key. Check that your API key is
    correct and properly formatted in the Authorization header"`
- **Observación crítica:** el 429 existe y las tres cabeceras `X-RateLimit-*` están
  documentadas oficialmente, pero **no se publica ningún umbral numérico** ni la
  duración de la ventana; `"Time windows may vary by API"` descarta además un valor
  único global (D2 no aplica limpio). No hay cabecera `Retry-After` — Mailgun usa el
  nombre propio `X-RateLimit-Reset`. Ver **DISC-01**.

## [F3] Developer docs — Domains, `POST /v4/domains`

- **URL:** https://documentation.mailgun.com/docs/mailgun/api-reference/send/mailgun/domains/post-v4-domains
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"Creates a domain for sending emails"`
- **Observación:** confirma la operación 3 del test C2 (crear dominio) disponible por
  API. El endpoint de **disparo de verificación DNS** de un dominio ya creado
  (`.../verify` o similar) no se ha podido citar literalmente: las páginas concretas de
  Domains devolvieron 404 vía WebFetch directo.

## [F4] Developer docs — Domain Templates, `POST /v3/{domain_name}/templates`

- **URL:** https://documentation.mailgun.com/docs/mailgun/api-reference/send/mailgun/domain-templates/post-v3--domain-name--templates
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"POST /v3/{domain_name}/templates"`, con `name`, `tag` y `template`
  como parámetros requeridos según la página.
- **Observación:** confirma la operación 2 del test C2 (crear/editar plantilla)
  disponible por API.

## [F5] Developer docs — Messages, referencia de `POST /v3/{domain_name}/messages`

- **URL:** https://documentation.mailgun.com/docs/mailgun/api-reference/send/mailgun/messages/post-v3--domain-name--messages
  (la misma página resuelve también bajo el alias sin sufijo
  `.../api-reference/send/mailgun/messages`, citado así por uno de los recolectores)
- **Fecha de acceso:** 2026-09-21
- **Citas literales:**
  - `"Send options (parameters starting with o:, h:, v:, or t:) are limited to 16KB
    total"`
  - `"Anything over 4KB will be truncated in the event/webhooks"` (variables custom
    `v:`)
  - `"Maximum 1,000 recipients per batch."`
- **Observación:** el tope de 16KB es de los **parámetros de opciones** del envío
  (`o:`/`h:`/`v:`/`t:`), no del mensaje completo ni de los adjuntos — no hay cifra de
  tamaño total del mensaje en esta página. El máximo de destinatarios en el envío
  individual NO-batch (fuera de `recipient-variables`) **no aparece** en esta
  referencia.

## [F6] User manual — Batch Sending

- **URL:** https://documentation.mailgun.com/docs/mailgun/user-manual/sending-messages/batch-sending
- **Fecha de acceso:** 2026-09-21
- **Citas literales:**
  - `"The maximum number of recipients allowed for batch is 1,000"`
  - `"Recipient variables should be set as a valid JSON-encoded dictionary where key is
    a plain recipient address, and value is a dictionary with variables."`
  - `"If your \"X-Mailgun-Recipient-Variables\" header exceeds 998 characters, you
    should use folding to spread the variables over multiple lines."`
- **Observación:** confirma [F5] con el mismo tope (1.000) en una página distinta —
  doble cobertura del dato. Es la friccion F-03 (consumo compuesto): una sola llamada
  con 1 plantilla × hasta 1.000 destinatarios consume 1.000 unidades de envío en una
  petición. El límite de 998 caracteres es solo del canal SMTP.

## [F7] Developer docs — Custom Message Limit

- **URL:** https://documentation.mailgun.com/docs/mailgun/api-reference/send/mailgun/custom-message-limit
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"The custom message limit imposes a hard limit on how many messages
  your account can send during a calendar month."` El campo `period` de la respuesta
  admite `"m"` (meses), `"d"` (días) o `"h"` (horas): `"The timeframe for which the
  limit applies - m for months, d for days, h for hours"`.
- **Observación:** **no es una cuota de plan**, es un endpoint (`PUT/GET/DELETE
  /v5/accounts/limit/custom/monthly`, también `.../custom/enable`) que permite al
  propio titular de la cuenta fijar un tope de envío. El ejemplo de la documentación usa
  `limit=10000` solo como valor de muestra, no como valor por defecto del proveedor.

## [F8] Developer docs — Events, `GET /v3/{domain_name}/events`

- **URL:** https://documentation.mailgun.com/docs/mailgun/api-reference/send/mailgun/events/get-v3-domain_name-events
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** parámetro `limit` — `"The number of entries to return (300 max)"`
- **Observación:** es tope de paginación de la consulta de eventos, no de consumo de
  cuota de envío.

## [F9] User manual — Send with Templates

- **URL:** https://documentation.mailgun.com/docs/mailgun/user-manual/sending-messages/send-templates
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"Mailgun caps usage of account-level templates to 100 templates and
  40 versions per template."`
- **Observación:** límite de recurso (B3), no de cuota de envío; no va a `capacity`. No
  se ha localizado cita propia que confirme si las plantillas **a nivel de dominio**
  comparten el mismo tope 100/40.

## [F10] Developer docs — Bounces

- **URL:** https://documentation.mailgun.com/docs/mailgun/api-reference/send/mailgun/bounces
- **Fecha de acceso:** 2026-09-21
- **Citas literales:**
  - `"The CSV file must be 25MB or under"` (import masivo de rebotes, `POST
    .../bounces/import`)
  - Endpoints listados: `POST .../bounces/import`, `GET/DELETE .../bounces/{address}`,
    `GET/POST/DELETE .../bounces`
- **Observación:** candidata a friccion F-06 (tope acotado por tamaño de fichero, no por
  número de registros).

## [F11] Developer docs — Limits API

- **URL:** https://documentation.mailgun.com/docs/mailgun/api-reference/send/mailgun/limits
- **Fecha de acceso:** 2026-09-21
- **Observación:** es la API de umbrales (`thresholds`) para subcuentas de
  validación/preview de email, **no** el rate limit de envío. Se descarta como fuente
  del CRF de envío; solo sería relevante si se modelase la validación de email, fuera de
  alcance por A1.

## [F12] User manual — Send via HTTP

- **URL:** https://documentation.mailgun.com/docs/mailgun/user-manual/sending-messages/send-http
- **Fecha de acceso:** 2026-09-21
- **Citas literales:**
  - `"The maximum message size Mailgun supports is 25MB"`
  - `"Compressing message bodies does *not* bypass the above limit. This limit is
    enforced on the *uncompressed* body"`
  - `"Mailgun does have rate limits in place to protect our system. In the unlikely
    case you encounter them and need them raised, please reach out to our support
    team."`
- **Observación:** confirma el tamaño de 25MB también citado en [F15] (ai-info, sin
  verificar) y en [F20] (ToS) — tres fuentes independientes coinciden en la misma cifra,
  así que el 25MB queda en verde por esta página aunque [F15] siga sin poder verificarse
  en crudo. El párrafo de rate limits reconoce la existencia del límite sin publicar
  ningún umbral — mismo patrón que Postmark F-01.

## [F13] User manual — Send via SMTP

- **URL:** https://documentation.mailgun.com/docs/mailgun/user-manual/sending-messages/send-smtp
- **Fecha de acceso:** 2026-09-21
- **Citas literales:**
  - `"Mailgun SMTP servers listen on ports 25, 465, 587, and 2525. Port 465 requires a
    TLS connection."`
  - `"Depending on your billing plan, you can schedule messages up to 3 or 7 days in
    advance."`
- **Observación:** los puertos no están condicionados por plan en la fuente. El
  horizonte de programación (3 o 7 días) declara solo dos valores posibles sin atribuir
  cuál corresponde a qué plan (D4). No se ha localizado cifra de límites de canal SMTP
  (conexiones concurrentes, mensajes por conexión).

## [F14] User manual — Configuring Webhooks

- **URL:** https://documentation.mailgun.com/docs/mailgun/user-manual/webhooks/configuring-webhooks
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"Each event type is configured individually and can contain up to 3
  URLs per event type."`
- **Observación:** no está condicionado a plan en la fuente (D2).

## [F15] www.mailgun.com/ai-info/ — transcrita con navegador (E13)

- **URL:** https://www.mailgun.com/ai-info/
- **Fecha de acceso:** 2026-09-21
- **Método: navegador renderizado.** La página devuelve 403 a `curl` y a WebFetch
  —Cloudflare sirve el challenge—, y es la única fuente del dominio del proveedor con
  una cifra de caudal, así que **E13** obliga al intento de render. Transcripción en
  `evidencias/paginas/2026-09-21/navegador-ai-info.txt`.
- **Citas literales:**
  - `"1,500 API requests per second per client IP"`
  - `"1,500 SMTP requests per second per client IP"`
  - `"The maximum size is 25 MB per message on Mailgun"`
  - `"There are no concurrent connection or simultaneous request limits."`
- **Observación.** La reserva de **E10** queda levantada: el literal ya no sale de una
  síntesis de herramienta sino del texto servido por el navegador, y desde ahí es un
  literal cualquiera, que colorea **D1**. El dato del tamaño de mensaje (25MB) sigue
  corroborado por [F12] y [F20]. Lo que la transcripción **no** resuelve es la tensión
  con [F2], que dice que las ventanas varían por API: eso es materia de **DISC-01** y no
  de método de lectura. Una relectura por WebFetch que vuelva a dar 403 no es caída de
  cita (**E8**) ni dispara **E3**.

## [F16] InboxReady/Optimize — Metrics, rate limits and quotas — **fuera de alcance (A1)**

- **URL:** https://documentation.mailgun.com/docs/inboxready/api-reference/optimize/mailgun/metrics/rate-limits-and-quotas
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"API calls are subject to a rate limit of 500 requests every 10
  seconds"`
- **Observación:** vive bajo el árbol documental de **InboxReady/Optimize/Metrics**, no
  bajo Mailgun Send transaccional. Se excluye del modelado por A1 — confirmado además
  por el panel [F24], que muestra Optimize como suscripción independiente (`No
  subscription`).

## [F17] FAQ — Sending

- **URL:** https://documentation.mailgun.com/docs/mailgun/faq/sending
- **Fecha de acceso:** 2026-09-21
- **Observación:** menciona cualitativamente que Mailgun `"gradually increases sending
  rates"` para IPs nuevas, sin publicar ningún número ni duración.

## [F18] FAQ — Deliverability and reputation

- **URL:** https://documentation.mailgun.com/docs/mailgun/faq/deliver-rep
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"automatically queues your email and sends them at rates that makes
  the ESPs happy, increasing those rates as your sending reputation grows"`
- **Observación:** es la fuente más cercana a un *warm-up* documentado para el producto
  transaccional; describe el mecanismo (cola automática, ritmo creciente con la
  reputación) sin umbral numérico ni duración.

---

## Política de uso aceptable, Términos y changelog

## [F19] Legal — Acceptable Use Policy

- **URL:** https://www.mailgun.com/legal/aup/
- **Fecha de acceso:** 2026-09-21
- **Citas literales:**
  - Bounce rate: `"Calculated on the number of messages that have bounced"` → umbral
    ≤5%
  - Spam complaints: `"Calculated on the number of messages that have been reported as
    spam"` → umbral ≤0.08%
  - Unsubscribe rate: umbral ≤1.4% (o 1% si unsubs > clicks)
  - Blocks: `"Calculated on blocked messages"` → umbral <20%
  - `"Sinch Email reserves the right to update the parameters of the acceptable
    sending threshold without prior notice."`
  - `"If you breach this AUP we may limit, suspend, or terminate your account in
    accordance with our Terms of Use."`
  - `"The determination of whether and to what extent a customer's act or omission
    and is in violation of this AUP will be made at our sole discretion."`
- **Observación:** son umbrales de **política**, no de cuota de capacidad (B4); van al
  provenance, no a `capacity`. El último literal es el hallazgo relevante: los umbrales
  numéricos publicados **no se aplican de forma automática**, la determinación es
  discrecional del proveedor.

## [F20] Legal — Terms of Use

- **URL:** https://www.mailgun.com/legal/terms/
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"an individual email message not exceeding the per-message size
  limit (including attachments) of 25MB or it may be permanently lost."`
- **Observación:** tercera fuente independiente que confirma el tope de 25MB (junto con
  [F12] y, sin verificar, [F15]).

## [F21] Legal — Acceptable Use Policy, versión archivada

- **URL:** https://www.mailgun.com/legal/aup-old/
- **Fecha de acceso:** 2026-09-21 · revisión `01/14/2022`
- **Observación:** declara los mismos umbrales que la versión vigente [F19] (bounces
  ≤5%, complaints ≤0.08%, unsubscribes ≤1.4%). No hay cambio de cifra detectable entre
  las dos versiones disponibles públicamente (no aplica E3).

## [F22] Changelog — www.mailgun.com/releases/

- **URL:** https://www.mailgun.com/releases/
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"ability to set usage limits for subaccounts enabled with Optimize
  features"`
- **Observación:** las entradas del último año relacionadas con límites son todas de
  Mailgun Optimize (subcuentas de validación) o de IP dedicada/warm-up de IP, no del
  producto transaccional Mailgun Send. No hay cambio de cifra de capacidad del producto
  modelado entre dos capturas (no aplica E3).

## [F23] OpenAPI spec — existencia confirmada

- **URL:** https://documentation.mailgun.com/_spec/docs/mailgun/api-reference/send/mailgun.json
  (también disponible en `.yaml`)
- **Fecha de acceso:** 2026-09-21
- **Observación:** localizada vía búsqueda (OAS 3.1.0); **no descargada ni inspeccionada
  su contenido** en esta pasada. Pendiente de pasada 2 para extraer límites de esquema
  (`maxItems`, `maxLength`) si los declara.

---

## Panel

## [F24] Observación de panel con cuenta propia — 2026-09-21

- **Fecha de acceso:** 2026-09-21 · **Navegador:** «danvelcam - dvela browser»
  (`deviceId 8bfcd503-51fd-4675-bc3e-92d4701ee501`) · **Cuenta:** Daniel Vela /
  Universidad de Sevilla, plan **Free**, dominio sandbox
- **Evidencia:** `evidencias/panel_mailgun_2026-09-21.md` — transcripción literal, modo
  solo lectura; no se pulsó ningún botón de facturación, upgrade, borrado ni aceptación
  de términos (el diálogo de Red Sift/DMARC se dejó sin tocar)
- **Citas literales — Billing → Plans:**
  - `"Mailgun Send"` · `"Your current plan"` · `"Free"` · `"$0"` · `"/ month"` ·
    `"3000 emails per month"` · `"1 day of log retention"` · `"24/7 ticket support"` ·
    `"Emails sent this month"` → `"0 / 3000"`
  - `"Mailgun Optimize"` → `"Subscribe to a plan"` · `"Your current plan"` → `"No
    subscription"` ; ídem para `"Mailgun Inspect"`
- **Citas literales — Guía de inicio:**
  - `"Sandbox domain"` → `sandboxcc7d3466734a4ff18c9247a488599261.mailgun.org` ·
    `"Base URL"` → `https://api.mailgun.net` (coincide con [F2], región US)
- **Citas literales — Domain settings → Settings:**
  - `"Message retention is unavailable for your plan. Upgrade to start storing message
    bodies (MIMES) for later retrieval..."` · `"Security"` → `"TLS connection"` →
    `"Opportunistic"` · `"Certificate verification"` → `"Required"`
- **Citas literales — Domain settings → DNS Records:**
  - `"DKIM settings for sandboxcc7d3466734a4ff18c9247a488599261.mailgun.org are managed
    by the root domain sandbox.mgsend.net (DKIM authority is set to \"false\").
    Subdomains cannot add new DKIM records independently."`
- **Citas literales — superficie del producto (menú lateral, enlaces reales):**
  - `/mg/reporting/metrics · /mg/reporting/logs · /mg/reporting/bounce-classification`
  - `/mg/sending/domains · /mg/sending/<dominio>/templates ·
    /mg/sending/<dominio>/suppressions · /mg/sending/<dominio>/webhooks/account-level ·
    /mg/sending/<dominio>/ips · /mg/sending/mailing-lists`
  - `/mg/receiving/routes` · `/inspect/email-testing` · `/mgo/ai-insights`,
    `/mgo/dmarc-reports`, `/mgo/email-health-score`, `/mgo/validations` (namespace
    `mgo` = Mailgun Optimize, separado de `mg` = Mailgun Send)
- **Lo que el panel NO enseña** (transcrito de la propia nota del observador): el
  caudal vigente (rate limit) de la cuenta, ningún registro de errores 429, la
  escalera de volúmenes contratables (el enlace *Pricing details* no abrió panel
  interno), la fecha literal de reposición de la cuota de 3.000 emails, y la lista de
  destinatarios autorizados del sandbox como pantalla propia.
- **Observación crítica.** El panel da el volumen del plan Free en una unidad y un
  periodo distintos a los de la página pública: **`"3000 emails per month"`** frente a
  **`"100 emails/day included"`** de [F1]. Ver **DISC-03**. El soporte de Free se lee
  con un adjetivo más en el panel — `"24/7 ticket support"` frente al `"Ticket
  support"` de [F1] —. Hasta el 2026-10-18 mandaba el panel por **D5**; desde **D17**
  (D-068) gana la página de precios, sin excepción por precisión, y el `"24/7"` queda
  como **incoherencia del pricing**. La retención de logs coincide exactamente: `"1 day log retention"`
  ([F1]) y `"1 day of log retention"` ([F24]).

---

## [E1] Sondeo empírico — plantillas en el plan Free, paginación de eventos y cupo tras rechazo (escalón 3, segunda pasada)

- **Fecha:** 2026-09-21, cerrado a las 20:53:37. **Ejecutado por:** el agente, en la
  máquina del autor, con las credenciales leídas —no sourceadas— por `lib_env_catalogo.sh`.
  Script `05_salida/_herramientas/probe_mailgun_e_segunda_pasada.sh`, contra el dominio
  sandbox `sandboxcc7d3466734a4ff18c9247a488599261.mailgun.org`.
- **Coste:** 0 envíos entregados, por construcción. Las dos peticiones de rechazo del
  tercer bloque van dirigidas a `example.invalid` (RFC 2606) y están hechas para que la
  API las rechace antes de entregar; cualquier 2xx de `/messages` aborta el script.
- **Evidencia:** `evidencias/sondeo_e_segunda_pasada_2026-09-21.txt`, log verbatim.
- **Citas literales — plantillas en el plan Free, cierra DISC-02:**
  - `POST /v3/$dominio/templates` → `200` · `"template has been stored"`, con el nombre
    `"sondeo-disc02-1790016807"` y fecha de creación `"Mon, 21 Sep 2026 18:53:28 UTC"`.
  - El script la borra a continuación, sin dejar estado en la cuenta: `DELETE
    /v3/$dominio/templates/sondeo-disc02-1790016807` → `200` · `"template has been
    deleted"`.
- **Citas literales — profundidad de la paginación de eventos:**
  - `GET /v3/$dominio/events?limit=300` → `200` · 42 items · enlace `paging.next`
    presente.
  - Siguiendo ese enlace: `200` · 0 items · el enlace `next` sigue presente.
  - Total recorrido: 42 eventos en 2 páginas.
- **Citas literales — el contador tras un rechazo, mide F-21:**
  - Antes: `"accepted.outgoing=13 delivered.smtp=13"`.
  - Rechazo 1, 1.001 destinatarios: `400` · `"Too many recipients, max is 1000"`.
  - Rechazo 2, destinatario no autorizado: `403` · `"Domain
    sandboxcc7d3466734a4ff18c9247a488599261.mailgun.org is not allowed to send: Free
    accounts are for test purposes only. Please upgrade or add the address to your
    authorized recipients."`
  - Después: `"accepted.outgoing=13 delivered.smtp=13"`.
- **Qué cierra:**
  - **DISC-02** (entrada reescrita más abajo): el endpoint de plantillas responde en el
    plan Free, y ningún literal separa esa columna de Basic.
  - **F-21**: el contador no se mueve entre el antes y el después. Un rechazo previo a
    la entrega no descuenta cuota.
- **Qué no cierra, y por qué:** la profundidad acumulada de la paginación de eventos.
  Con 42 eventos en la cuenta —la retención del plan Free es de un día— la segunda
  página ya devuelve 0 items con el enlace `next` todavía presente: no hay volumen para
  tropezar con un tope acumulado. El tope por petición, 300, sigue medido y no se toca.
  Resultado negativo por falta de material, no por falta de intento.

---

## Discrepancias entre fuentes

Por **E5**, ninguna discrepancia se cierra eligiendo un lado: se cierra midiendo o
disolviéndola. Las tres siguen abiertas, y se registran con los dos lados enteros. Cada
entrada lleva su línea **`Efecto declarado:`** (**E6**): si es excluyente por **D11** y
qué le hace al color del campo. El cuerpo de este apartado se escribió antes de construir
`datasheet.yaml`; los efectos declarados se reescribieron el 2026-09-21, al aplicar el
veredicto E13, contra el fichero ya construido.

### DISC-01 · El rate limit numérico de la API/SMTP: ¿no publicado o 1.500/s?

- **A —** [F2], página oficial de developer docs: `"Mailgun APIs include the following
  headers to indicate rate limiting state for the current API being called... Time
  windows may vary by API depending on resource usage."` **Sin ninguna cifra.** [F12]
  refuerza el mismo silencio para el canal HTTP: `"Mailgun does have rate limits in
  place to protect our system... please reach out to our support team."`
- **B —** [F15], `www.mailgun.com/ai-info/`, mismo dominio `mailgun.com`: `"1,500 API
  requests per second per client IP"` y `"1,500 SMTP requests per second per client
  IP"`.
- **La reserva de fiabilidad del lado B se levantó el 2026-09-21.** Nació de que la
  cifra salía de un resumen de herramienta sobre una página bloqueada por Cloudflare
  (**E10**). La página se rindió con navegador ese día y el literal está transcrito en
  `evidencias/paginas/2026-09-21/navegador-ai-info.txt`, así que ya se puede «volver a la
  fuente» como exige E5(1). Lo que queda es una discrepancia de contenido entre dos
  fuentes oficiales, no un problema de lectura.
- **Y la propia frase de A es difícil de conciliar con un número único:** «varía por
  API» y «1.500 para toda la API» son lecturas en tensión, aunque ninguna de las dos
  fuentes lo diga en esos términos exactos.
- **Efecto en la datasheet.** La cláusula que dejaba el campo sin valor se cumplió: el
  literal de [F15] está verificado con navegador. `max_power.rate_request_api` sale de
  ella y pasa a colorearse por **D1** sobre el literal ya transcrito, con valor 1.500
  peticiones por segundo en **🟡**. El ámbar no es la reserva de E10, que ya no existe:
  es que el proveedor acota por IP de cliente y el esquema no tiene dimensión para eso,
  así que la cifra del fichero es el techo de una IP y no el de la cuenta ni el del plan.
  `rate_request_smtp` no llega al fichero por otro motivo —el esquema solo admite
  caudales colgados de un endpoint HTTP—, y vive en `not_found`.
- **Tensión residual, que sigue abierta.** [F2] dice `"Time windows may vary by API
  depending on resource usage."` y [F15] da un número único. Ninguna de las dos fuentes
  niega a la otra en esos términos, y el sondeo de caudal del 2026-09-21 no las
  desempata: midió el endpoint de envío —80.000 peticiones por ventana de unos diez
  segundos, que es otro contador— y la lectura sostenida solo alcanzó 303 peticiones por
  segundo, techo del cliente. DISC-01 se queda abierta por ese flanco.
- **Efecto declarado:** no excluyente · `max_power.rate_request_api` lleva 1.500
  peticiones por segundo en 🟡, con el alcance por IP anotado en el provenance;
  `rate_request_smtp` se queda fuera del fichero, en `not_found`, por falta de nodo.

### DISC-02 · Email Templates: ¿incluido en las cuatro columnas o ausente en Free/Basic? — RESUELTA midiendo el 2026-09-21 ([E1])

- **A —** [F1], fila de la matriz comparativa: `"Email Templates"` con `cols: true` —
  incluido en Free, Basic, Foundation y Scale por igual.
- **B —** [F1], **la misma página**, listado `"Features include:"` de cada plan
  (bloque `pricingData.plans.<plan>.features`): el de **Free** no menciona plantillas
  en ningún bullet, y el de **Basic** tampoco.
- **La misma página sostenía las dos lecturas**, en dos estructuras distintas del mismo
  documento: la tabla de comparación por un lado, el resumen de bullets por plan por
  otro.
- **Precisión de alcance, del mismo consejo (D14).** La columna Free ya estaba resuelta
  antes de esta medición: su bullet no menciona plantillas y ningún plan la enmarca como
  incorporación suya, así que por D1 entraba en 🟢 con la omisión anotada como NOTA. Lo
  que seguía abierto era solo Basic, por la tarjeta de Foundation, que se titula
  `"Everything on Basic plus..."` y enumera `"Email template builder and API"` — una
  ausencia enmarcada que sí cuenta como segundo lado de D11.
- **Manda A.** [E1] envió `POST /v3/{domain_name}/templates` desde la cuenta propia,
  plan Free, y la API respondió con la plantilla creada; el sondeo la borró después. El
  endpoint funciona en el plan más restringido del catálogo. Ningún literal distingue a
  Basic de Free: los dos bullets dicen lo mismo, nada, y la matriz los trata igual que a
  Foundation y a Scale. Sin una fuente que separe Basic de Free, el bullet de Foundation
  se lee como venta que repite una feature ya incluida más abajo, no como aviso de que
  Basic carece de ella.
- **Vía de cierre.** Cierra midiendo, no eligiendo (**E5**): la medición desempata dos
  literales de la misma fuente que se contradicen entre sí (**E11**), no tumba ninguna
  cita ni descarta un lado por caída, así que no es **E5(1)**. El sondeo se diseñó para
  esta pregunta —lo dice su propio guion—, así que **D6** no aplica: no es una cabecera
  aparecida por otro motivo.
- **Efecto en la datasheet.** El endpoint de plantillas queda confirmado en Free y, por
  la ausencia de cualquier literal que distinga a Basic, también en Basic.
  `metadata.data_provenance` y `metadata.not_found` se actualizan con la medición. La
  celda de `features.md` queda pendiente de la misma actualización.
- **Efecto declarado:** excluyente hasta hoy · cerrada el 2026-09-21. Basic sube de 🟡 a
  🟢 sobre el literal de la matriz, sostenido ahora por la medición; Free se queda donde
  ya estaba.

### DISC-03 · El volumen del plan Free: ¿100 emails/día o 3.000 emails/mes?

- **A —** [F1], página pública de precios: `"100 emails/day included"` (Free).
- **B —** [F24], panel de la cuenta propia, plan Free, hoy: `"3000 emails per month"`,
  con `"Emails sent this month"` → `"0 / 3000"`.
- **Aritméticamente compatibles y no necesariamente el mismo dato.** `100 × 30 = 3.000`,
  así que un tope diario de 100 agregado sobre un mes de 30 días **podría** ser la
  misma cuota leída en dos periodos. Pero ninguna fuente dice que sea así: podrían ser
  dos topes que se aplican **a la vez** (un techo diario y, además, un techo mensual
  independiente), que es justo el patrón que otras APIs del catálogo documentan por
  separado. El panel no muestra ningún contador diario junto al mensual.
- **Por qué no se cierra hoy (E5).** No cae en ninguno de los tres supuestos: ninguna
  cita es inferencia sin respaldo (las dos son literales de fuente oficial — página
  pública y panel de cuenta propia), ninguna regla ya escrita dirime «página vs.
  panel» cuando el periodo declarado es distinto (**D5** exige que sea *el mismo dato*
  con más precisión, no un dato en otra unidad temporal), y v0.3 sí tiene sitio para
  ambas magnitudes (`quota_email_daily` y `quota_email_monthly`), así que tampoco cierra
  por el supuesto (3). Queda abierta.
- **Vía de cierre, barata:** enviar el sondeo de caudal inocuo de escalón 3 (rechazo sin
  gasto de cuota, dominio sandbox) durante 24-48h y leer si `"Emails sent this month"`
  tropieza con un tope antes de llegar a 3.000, o si existe un rechazo distinto a partir
  del email 100 de un mismo día.
- **Efecto en la datasheet:** decide si el plan Free de Mailgun lleva **una** cuota
  (mensual, 3.000) o **dos** (diaria de 100 y mensual de 3.000, como Postmark
  distingue test-mode de cuota). La lectura conservadora declara las dos, cada una con
  su fuente, sin fundir una en la otra.
- **Efecto declarado:** no excluyente, aritméticamente compatibles pero no confirmado ·
  bloquea que `capacity.quota_email_daily_free` y `quota_email_monthly_free` suban a 🟢
  sin la aclaración; hoy ambas quedarían en 🟡 por D1 (literal pero de alcance
  ambiguo). *(Superado en parte el 2026-10-18; ver abajo.)*
- **Acotada por D17 (D-068, 2026-10-18), no cerrada.** La cifra diaria es literal de la
  página de precios y D17 la sube a 🟢: `quota_email_daily_free` = 100 🟢. La mensual no
  tiene lado en el pricing —la página no publica ninguna cifra mensual del Free—, así que
  D17 no la toca y `quota_email_monthly_free` sigue en 🟡 por D1. Lo que queda abierto es lo
  mismo que antes: si son dos topes concurrentes o el mismo leído dos veces.
- **Efecto declarado (2026-10-18):** no excluyente · `quota_email_daily_free` 🟢 por D17;
  `quota_email_monthly_free` 🟡 por D1.

---

## Fuentes buscadas y NO encontradas

Registro explícito para que la ausencia sea trazable y no parezca descuido. Deduplicado
de los siete recolectores.

| Dato buscado | Resultado |
|---|---|
| Umbral numérico del rate limit general de la API (req/s o req/min), en documentación de desarrollador | **No publicado.** Solo cabeceras `X-RateLimit-*` y el 429 de [F2]. Único número es [F15] (ai-info, sin verificar en crudo — DISC-01). |
| Tipo de ventana (rolling / fixed) del rate limit general | **No determinable.** No hay umbral ni descripción de reinicio en dev docs (D3 no aplicable sin ancla). |
| Límites de concurrencia (conexiones SMTP simultáneas, peticiones API en paralelo) | **No publicado** en dev docs. Solo `"No concurrent connection or simultaneous request limits"` en [F15], sin verificar en crudo. |
| Límite de tamaño por petición del mensaje completo o de los adjuntos, en dev docs | **No hay cifra en `post-v3--domain-name--messages` ni en `send-attachments`.** El 25MB de [F12]/[F20] es de tamaño de *mensaje*, no está atado explícitamente a "por petición". |
| Si los rates varían por plan (Free/Basic/Foundation/Scale/Custom) | **No mencionado.** Solo el *Custom Message Limit* [F7] es configurable por el usuario, no diferenciado por plan de catálogo. |
| Si los rates varían por endpoint | **No encontrado**, salvo la frase genérica `"Time windows may vary by API"` de [F2]. |
| Si los rates varían por estado de la cuenta (IP nueva, warm-up) | Solo mención cualitativa en [F17]/[F18], sin cifra. |
| Tamaño de payload del batch en MB (solo se documenta el tope de 1.000 destinatarios) | **No encontrado** en [F6] ni en [F5]. |
| Máximo de destinatarios (To+Cc+Bcc) en el envío individual NO-batch, fuera de `recipient-variables` | **No encontrado** en [F5] ni en `send-http`/`send-smtp`. |
| Umbral que dispara específicamente un 403 (tamaño, destinatarios) | **No encontrado.** El 403 de [F2] es solo de permisos/credenciales. |
| Umbral numérico exacto que dispara el 429 en Mailgun Send | **No publicado.** Solo el mecanismo (429 + cabeceras). |
| Cabecera `Retry-After` | **No documentada.** Mailgun usa `X-RateLimit-Reset` como nombre propio. |
| Error 413 (Payload Too Large) o mensaje literal para el caso de exceder los 25MB | **No encontrado.** |
| Contenido real del fichero OpenAPI (`mailgun.json`) | Existencia confirmada [F23]; no descargado ni parseado esta pasada. |
| Endpoint de disparo de verificación DNS de un dominio ya creado (`.../verify`) | **No citable.** Las páginas concretas de Domains devolvieron 404 vía WebFetch. |
| Endpoint de creación/rotación de una segunda clave API (Domain Keys / Account Keys) | **No citable.** Páginas concretas devolvieron 404 vía WebFetch. |
| Reventa oficial de Mailgun en marketplaces (RapidAPI, AWS Marketplace) con pricing propio | **No encontrada.** Solo un listado de terceros no oficial en RapidAPI (`orliesaurus`), que por D1 no cuenta como fuente del proveedor. |
| Precio anual o toggle mensual/anual | **No encontrado** en [F1]; solo precios `/mo`. |
| Cifra de overage FIJA (no "from X") para Basic, Foundation y Scale | **No publicado.** [F1] solo da `"from $X / 1,000 emails"`, precio de arranque y no unitario fijo. |
| Precio o condiciones del plan Custom/Enterprise | **No publicado.** Solo `"Request a quote"`. |
| Moneda distinta de USD | **No visto** selector de moneda en el contenido recuperado de [F1]. |
| Mecanismo exacto del selector de volumen de [F1] (F-02/E9): si cambia el precio mostrado o solo recomienda un plan | **No determinable con WebFetch** (fetch estático sin JS); pendiente de verificación con navegador. |
| Límites de canal SMTP por plan (conexiones concurrentes, mensajes por conexión) | **No publicado**, ni en [F13] ni en [F11] (que resultó ser la API de *thresholds*, no de canal). |
| Número exacto de rutas de inbound routing para Foundation y Scale | **No publicado.** [F1] solo dice `"Full access to inbound routing"`, sin cifra. |
| Número de usuarios permitidos en el plan Basic | **No publicado.** La FAQ de [F1] excluye a Basic de "tantos como necesites" sin dar cifra concreta. |
| Plan "Growth" mencionado en la FAQ de IP dedicada de [F1] | **No confirmado.** No aparece en la tabla de precios ni en `pricingData.plans` (solo free/basic/foundation/scale); podría ser nombre histórico, alias u otro producto. |
| Detalle de qué campo (p. ej. cabecera SMTP `X-Mailgun-Deliver-By`) distingue el horizonte de 3 vs 7 días de programación por plan | **No publicado.** [F13] solo da los dos valores sin tabla de atribución. |
| Tope de envío por hora para cuentas nuevas, con cifra | **No accesible.** `help.mailgun.com/hc/en-us/articles/115001124753` (que según referencias de terceros la cuantificaría) devuelve HTTP 403 tanto por WebFetch como por `curl` con user-agent de navegador; no se registra ninguna cifra de ese artículo. |
| Periodo de *warm-up* con duración/etapas en días, para envío API/SMTP normal (no IP dedicada) | **No publicado.** [F18] solo describe el mecanismo (cola automática, ritmo creciente), sin cifras ni etapas. El *Automatic IP Warmup* documentado es exclusivo de IP dedicada. |
| Condición exacta de "account probation" / verificación de negocio con el umbral de 100 mensajes/hora citado por terceros (Courier, MailTester) | **No encontrada en fuente oficial.** Solo en blogs no oficiales, que por D1 no dan verde. |
| Changelog con cambio numérico del rate limit de la API REST (no de Optimize ni de warm-up de IP) | **No encontrado** en [F22] para el producto transaccional. |
| Producto de marketing de Mailgun bajo la misma cuenta, más allá de Optimize/Inspect ya registrados | No buscado explícitamente hoy más allá de lo que el panel [F24] confirma (Optimize e Inspect como suscripciones separadas). |
| Profundidad acumulada de la paginación de eventos, siguiendo `paging.next` hasta agotarlo | **Intentado y sin volumen medible [E1].** `limit=300` trajo 42 eventos; la página siguiente devolvió 0 items con el enlace `next` todavía presente. La retención del plan Free es de un día, así que no hay material para tropezar con un tope acumulado. El tope por petición, 300, sigue medido y no se toca. |
