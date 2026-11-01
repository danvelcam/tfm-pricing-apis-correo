# Fuentes — Brevo

API de correo transaccional (Email API, `https://api.brevo.com/v3`). Proveedor: Brevo
(antes Sendinblue). Producto modelado: **el transaccional** (regla A1); el de marketing
comparte cuenta, plan y cuota, y eso mismo es un hallazgo (ver `fricciones.md`, F-10).
Recolección: **2026-09-16**, pasada 1, tres lentes documentales (capacidad, precio,
contrato de rechazo). Toda cita es literal. La numeración `[Fn]` es la que referencian
`REVISION.md` y `fricciones.md`; el `datasheet.yaml` cita por URL, no por índice.

**La recolección del 16-09 fue documental.** El escalón 2 y el escalón 3 llegaron después y
están en este mismo fichero, entre [F29] y los huecos.

**Escalón 2 (panel), ejecutado el 2026-09-17.** Volcado en
`evidencias/panel_brevo_2026-09-17.md`, diez secciones. Sus literales sostienen los
veredictos de Q5, Q8, Q9 y Q10 en `REVISION.md`.

**Escalón 3, cuatro pasadas.** **[E1]** arrancó el 17-09 y abortó en su segundo caso, con 1
destinatario gastado y sin cerrar ninguna discrepancia. Las tres siguientes sí cierran:
**[E2]** (cabeceras por lectura, 0 envíos) cierra DISC-17, **[E3]** (envío real, 2
destinatarios) cierra DISC-14 y DISC-09, y **[E4]** (dos claves, 0 envíos) mide que el cubo
de caudal es de la cuenta. El libro de cuentas de la pasada quedó en **3 de 3**.

Del volcado de panel (`evidencias/panel_brevo_2026-09-17.md`) este fichero ha incorporado
**un solo dato, y por una razón concreta**: el que invalida la vía de DISC-09, porque esta
cuenta está en Free sin suscripción y ahí no hay ciclo de facturación que leer. **DISC-08, que el plan asigna al panel, sigue sin incorporar** pese a que el
panel dejó literales que la tocan; DISC-10 se incorporó el 2026-09-18 con [F30]. Sin esta frase,
el «quién cerró qué» dejaba de ser auditable: once DISC anotadas por el sondeo y una por el
panel, con una cabecera que decía que el panel no se había incorporado.

---

## [F1] Página de precios

- **URL:** https://www.brevo.com/pricing/
- **Fecha de acceso:** 2026-09-16
- **Citas literales (tarjetas y JSON-LD `schema.org/Product` del HTML estático):**
  - Free — `"@type": "Offer", "name": "Free", "price": "0", "priceCurrency": "USD"`,
    `"referenceQuantity": {"value": 1, "unitCode": "MON"}`
  - Starter — `"name": "Starter", "price": "9", "priceCurrency": "USD"` · mensual;
    `"name": "Starter", "price": "96.96", "priceCurrency": "USD"` · `"unitCode": "ANN"`
  - Standard — `"name": "Standard", "price": "18"` · mensual; `"194.04"` · anual
  - Professional — `"name": "Professional", "price": "499"` · mensual; `"5388.96"` · anual
  - Enterprise — `"@type": "Offer", "name": "Enterprise", "price": "Custom Price",
    "priceCurrency": "USD"`; tarjeta renderizada: `"Best for companies with 1M+ contacts
    needing custom solutions & full data control."`, `"Custom price"`, `"Talk to sales"`
  - Periodicidad — `"Monthly"` · `"Yearly (-10%)"`; el anual se muestra como mensual
    equivalente (`$8.08`, `$16.17`, `$449.08`)
  - Volumen de entrada — Starter `"From 5,000 emails per month"`;
    Professional `"From 150,000 emails per month"`
- **Citas literales (configurador `"Customize your plan"`):**
  - Free — `"Daily email volume (campaigns & transactional)"`,
    `"Upgrade to remove daily sending limit."`, `"300 emails/day"`,
    `"Total price"` `"$0.00/month"`
  - Starter / Standard / Professional — `"Monthly email volume (campaigns &
    transactional)"`
  - Starter, marcas del deslizador — `"5k | 10k | 15k | 20k | 30k | 40k | 50k | 60k |
    80k | 100k | More"`; precios `"$9.00"`, `"$17.00"`, `"$25.00"`, `"$32.00"`,
    `"$39.00"`, `"$46.00"`, `"$56.00"`, `"$65.00"`, `"$74.00"`, `"$82.00"`
    (`"with monthly billing"`)
  - Standard, marcas — `"5k | 10k | 15k | 20k | 30k | 40k | 50k | 60k | 80k | 100k |
    150k | 250k | 350k | 500k | More"`; precios `"$18.00"`, `"$35.00"`, `"$49.00"`,
    `"$69.00"`, `"$79.00"`, `"$89.00"`, `"$97.00"`, `"$104.00"`, `"$119.00"`,
    `"$139.00"`, `"$179.00"`, `"$249.00"`, `"$309.00"`, `"$429.00"`
  - Professional, marcas — `"150k | 250k | 500k | 1M | 2M | 3M | 4M | 5M | 6M | 7M |
    8M | 10M | More"`; precios `"$499.00"`, `"$599.00"`, `"$699.00"`, `"$999.00"`,
    `"$1,479.00"`, `"$1,863.00"`, `"$2,170.00"`, `"$2,447.00"`, `"$2,866.00"`,
    `"$3,285.00"`, `"$3,705.00"`, `"$4,543.00"`
  - Contactos acoplados al escalón — Starter `"5k emails/month" "Included" "500
    contacts" "Included"`; `"10k"` → `"1,500 contacts"`; `"15k"` → `"2,500 contacts"`;
    `"20k"` y superiores → `"500,000 contacts"`; Professional `"2 million contacts"`
  - Add-ons del configurador — `"Dedicated IP"` `"Take ownership of your sender
    reputation with a dedicated IP address."` `"Billed annually."` (Professional);
    `"Web & mobile push"` `"20,000 targeted subscribers per campaign and automation
    included"`; `"Marketing seats"` `"1 marketing seat included. $10.80 per month per
    additional seat."` `"Add up to 2 additional Marketing users."` (Standard)
  - Add-ons de las tarjetas — `"No Brevo logo"` `"$10.80 per month"`;
    `"Sales Essentials"` `"$27.92 per month"`; `"Sales Advanced"`
    `"$58.50 per month/user"`
- **Citas literales (preguntas frecuentes):**
  - `"Can I send transactional emails on my plan?"` — `"Yes! All Brevo plans give you
    access to transactional email features, including RESTful APIs, SMTP, outbound
    webhooks, unlimited log retention, and more."`
  - `"Are you committed to this plan?"` — `"You choose your commitment period when you
    sign up for a plan (monthly or yearly). There are no hidden fees with Brevo. Sign up
    for a plan or purchase credits as you need them, there are no additional fees."`
  - `"Why choose a pay-as-you-go plan?"` — `"PAYG credits do not expire, so you can use
    them at your own pace. One email sent equals one credit deducted."`
  - `"Can I try Brevo before purchasing a plan?"` — `"Absolutely! When you create an
    account, you will automatically have a Free plan to upload your contacts. Once we
    approve your account for sending, you can start sending up to 300 emails per day."`
  - `"How can I pay?"` — `"If you subscribe to a monthly plan, the subscription period
    is 30 days and charges are processed at the beginning of each period."`
- **Moneda:** selector con ocho divisas — `"EUR (Euro)"` · `"USD (US Dollar)"` ·
  `"GBP (British Pound)"` · `"BRL (Brazilian Real)"` · `"INR (Indian Rupee)"` ·
  `"CAD (Canadian Dollar)"` · `"AUD (Australian Dollar)"` · `"CHF (Swiss Franc)"`.
  Desde España sirve EUR por defecto (Starter 7 EUR, Standard 15 EUR, Professional
  499 EUR) y el JSON-LD lleva la oferta en cada divisa. Ninguna se declara canónica.
- **Observaciones:** los cinco planes tienen tarjeta, Enterprise incluido, así que por
  **A3** los cinco entran en `plans`. El volumen es **escalonado** (F-02) y está
  **acoplado al tope de contactos** en los dos sentidos. **Ningún escalón publica precio
  por correo excedido** (ver «Fuentes buscadas y NO encontradas»). El escalón `"More"`
  de los tres deslizadores no publica ni volumen ni precio. Las ocho divisas con cifras
  que no son conversiones entre sí son la fricción F-26.

## [F2] Página de precios — «see all features»

- **URL:** https://www.brevo.com/pricing/see-all-features/
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - Bloque `"Key features"`, fila `"Monthly email sends"` —
    `"300/day | Up to 100k | Up to 500k | Up to 10M | Custom"`
  - Bloque `"Email marketing"`, fila `"Monthly email sends"` —
    `"300/day | Up to 100k | Up to 1M | Up to 10M | Custom"`
  - `"Transactional email (API/SMTP)"` — `"Send time-sensitive emails triggered by user
    actions like purchases or sign-ups—via Email API or SMTP relay."` :: verificación en
    los cinco planes
  - `"APIs"` — `"Access and manage contacts, deals, tasks, notes, and more across your
    tools using our APIs."` :: verificación en los cinco planes
  - `"Outbound webhooks"` :: verificación en los cinco planes
  - `"Inbound webhooks"` — `"Receive real-time events from external sources to update
    data and objects in Brevo and trigger automations."` :: **cruz en Free, Starter y
    Standard; verificación en Professional y Enterprise**
  - `"Transactional SMS (API)"` :: verificación en los cinco planes ·
    `"Transactional WhatsApp (API)"` :: cruz en Free, Starter y Standard
  - `"Dedicated IP"` :: cruz en Free, Starter y Standard; `"Add-on"` en Professional;
    verificación en Enterprise
  - `"Users"` — `"Single user | Single user | Up to 3 (add-on) | 10 included |
    Unlimited"`; `"Contact limit"` — `"Up to 100K contacts | Up to 500K contacts |
    Up to 500K contacts | Up to 2M contacts | Unlimited"`
  - `"Customized log retention"` — `"Control how long data is stored to meet GDPR and
    privacy requirements."` :: verificación en los cinco planes ·
    `"SSO & SAML"` :: `"Add-on"` en Professional, verificación en Enterprise ·
    `"SLA (99.9% uptime)"` :: solo Enterprise
- **Observación crítica:** es la **única** atribución de capacidades de API por plan que
  hace la lista oficial, y por **A4** es la que decide qué endpoints lleva cada plan. El
  corte claro es el de entrada de correo: los webhooks de entrada solo existen en
  Professional y Enterprise. La misma página se contradice a sí misma en el techo del
  Standard (DISC-06).

## [F3] Página de precios — créditos prepago

- **URL:** https://www.brevo.com/pricing/pay-as-you-go/?selected=email
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"Pre-paid Email credits"` — `"Purchase credits to send emails with no daily sending
    limit and without the Brevo logo. No expiration date."`
  - Selector `"I want to send"` → `"Total price"`: 5,000 → `"$32.00"`;
    10,000 → `"$59.00"`; 20,000 → `"$95.00"`; 50,000 → `"$165.00"`;
    100,000 → `"$275.00"`; 500,000 → `"$940.00"`; 1,000,000 → `"$1,600.00"`
- **Observación:** un complemento que **levanta la cuota de otro plan** (el tope diario
  del Free) y arrastra consigo el conjunto de funciones del Starter. No cabe en v0.3:
  F-07 en su forma más aguda del catálogo.

## [F4] Página de precios — IP dedicada

- **URL:** https://www.brevo.com/pricing/pay-as-you-go/?selected=ip
- **Fecha de acceso:** 2026-09-16
- **Citas literales:** `"Dedicated IP"` — `"Take full control of your sender reputation
  and digitally sign your emails with a dedicated IP address."`, `"Available as a paid
  add-on for Professional plan, included in Enterprise."`, `"Total price"` `"$251.00"`
  `"per year per dedicated IP"`
- **Observación:** coincide con el centro de ayuda [F25], a diferencia de los otros tres
  add-ons cifrados en los dos sitios (DISC-08).

## [F5] Página de producto — correo transaccional

- **URL:** https://www.brevo.com/products/transactional-email/
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - Tabla `"Our transactional email service at a glance"` — `"Free plan | 300
    emails/day"` · `"Max attachment size | 25 MB per email"` · `"Batch sending | Up to
    1,000 emails per API request"` · `"Idempotency support | UUID-based with 30-minute
    TTL"` · `"Data hosting | France and Germany (EU-based servers)"`
  - `"How much does Brevo's transactional email cost?"` — `"Free plan: 300 emails per
    day (9,000/month) — forever free, no credit card required"` · `"Starter plan:
    Starting at $9/month for 5,000 emails/month"` · `"Standard plan: Starting at
    $18/month for 5,000 emails/month"` · `"Professional plan: Starting at $499/month for
    150,000 emails/month"` · `"Enterprise plan: Custom pricing for high-volume senders
    with dedicated IPs and custom SLAs"`
  - `"What's included in the free plan?"` — `"300 emails per day (9,000 emails per
    month)"` · `"Full API and SMTP access"` · `"Real-time tracking and analytics"` ·
    `"Webhook support"` · `"Flexible email log retention"`
- **Observaciones:** es la **única** fuente que da el volumen de entrada del Standard
  (5.000/mes), que la tarjeta de precios no publica. Y la única que deriva un tope
  mensual para el Free (9.000), que el centro de ayuda desmiente (DISC-07). El
  `"25 MB per email"` choca con los 20 MB del centro de ayuda (DISC-16).

## [F6] Developer docs — Rate limits

- **URL:** https://developers.brevo.com/docs/api-limits
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"The Brevo API enforces rate limits to ensure platform stability and fair resource
    allocation. Rate limits cap the number of API requests you can make within a given
    time period."`
  - `"RPS (Requests per second)"`: `"Maximum requests allowed per second"` ·
    `"RPH (Requests per hour)"`: `"Maximum requests allowed per hour"`
  - `"Some endpoints have both RPS and RPH limits. When both apply, you must respect
    both simultaneously."`
  - Tramos — `"General rate limits"`: `"Standard limits for most use cases. Available to
    all account types (Free, Starter, Standard, Professional, and Enterprise)."` ·
    `"Advanced rate limits"`: `"Higher limits for advanced use cases. Available to
    Professional and Enterprise accounts."` · `"Extended rate limits"`: `"Maximum limits
    for high-throughput integrations. Available to Enterprise accounts."`
  - Tabla **General** — `"| POST /v3/smtp/email  GET /v3/smtp/blockedContacts |
    3,600,000 RPH | 1,000 RPS |"` · `"| GET /v3/smtp/emails | 7,200 RPH | 2 RPS |"` ·
    `"| All endpoints under /v3/smtp/{…}* | 300 RPH | - |"` ·
    `"| All endpoints under /v3/contacts/{…} | 36,000 RPH | 10 RPS |"` ·
    `"| POST /v3/transactionalSMS/send | 540,000 RPH | 150 RPS |"` ·
    `"| POST /v3/events | 36,000 RPH | 10 RPS |"` ·
    `"| POST /v3/orders/status | 18,000 RPH | 5 RPS |"` ·
    `"| POST /v3/products | 7,200 RPH | 2 RPS |"` ·
    `"| All other endpoints | 100 RPH | - |"`
  - Nota de exclusión del comodín — `"*Excludes POST /v3/smtp/email and
    GET /v3/smtp/blockedContacts, which have dedicated limits."`
  - Tabla **Advanced** — `"| POST /v3/smtp/email  GET /v3/smtp/blockedContacts |
    7,200,000 RPH | 2,000 RPS |"` · `"| GET /v3/smtp/emails | 10,800 RPH | 3 RPS |"` ·
    `"| All endpoints under /v3/smtp/{…}* | 600 RPH | - |"` ·
    `"| All endpoints under /v3/contacts/{…} | 72,000 RPH | 20 RPS |"` ·
    `"| All other endpoints | 200 RPH | - |"`
  - Tabla **Extended** (encabezado `"Route | Policy"`) —
    `"| POST /v3/smtp/email  GET /v3/smtp/blockedContacts | 6,000 RPS |"` ·
    `"| GET /v3/smtp/emails | 18,000 RPH |"` ·
    `"| All endpoints under /v3/smtp/{…}* | 1,800 RPH |"` ·
    `"| All endpoints under /v3/contacts/{…} | 60 RPS |"` ·
    `"| POST /v3/events | 60 RPS |"` · `"| All other endpoints | 600 RPH |"`
  - `"When you exceed a rate limit, the API returns a 429 Too Many Requests status
    code. Monitor rate limit headers in responses to track your usage and prevent
    errors."`
  - `"Calculate your rate limit allowance and distribute requests evenly across the time
    window. For example, with a limit of 1,000 RPS, you can send up to 60,000 requests
    per minute when distributed evenly."`
  - `"Rate limits control request frequency, while platform quotas cap the number of
    objects you can create (campaigns, contacts, lists, etc.)."`
  - `"Upgrade to Enterprise — If your application requires higher throughput, upgrade to
    an Enterprise plan for increased rate limits."`
- **Observaciones:** es la fuente canónica del caudal y la **única** página de toda la
  documentación que lleva el distintivo `"Available in"` por plan. Tres cosas salen de
  aquí y de ningún otro sitio: (1) el caudal está escalonado en **tres tramos que no son
  los cinco planes**; (2) el comodín de prefijo con exclusión no es expresable en v0.3
  (F-23); (3) en **las diez filas** que publican las dos unidades a la vez, RPH es
  exactamente RPS × 3.600 — comprobado fila a fila en `fricciones.md`, observación O-15.
  *(Corregido el 2026-10-31, verificador: en la página son **catorce** filas con las dos
  unidades, siete del tramo General y siete del Advanced, hoy y en las capturas de Wayback del
  2026-05-21 y del 2026-10-13. La proporción se cumple en las catorce y la conclusión no
  cambia.)*
  La página **no declara ningún valor como «por defecto»**, así que la regla **E4** no
  sirve para arbitrar DISC-01.

## [F7] Developer docs — Rate limit headers

- **URL:** https://developers.brevo.com/docs/limit-headers
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"x-sib-ratelimit-limit"` — `"Maximum number of requests allowed in the current time
    window before receiving a 429 status code"`
  - `"x-sib-ratelimit-remaining"` — `"Number of requests remaining in the current time
    window"`
  - `"x-sib-ratelimit-reset"` — `"Time remaining until the rate limit resets, expressed
    in the granularity unit (typically seconds)"`
  - `"Rate limit headers are included in all responses, not just 429 errors. Monitor
    them proactively to prevent rate limit issues."`
  - `"The x-sib-ratelimit-limit header indicates the maximum number of requests you can
    make in the current time window. This value depends on your account plan and the
    specific endpoint."`
- **Observaciones:** el proveedor declara que el caudal se segmenta por plan **y** por
  endpoint, lo que sostiene declarar el `rate` en el endpoint (B8). Y abre la vía de
  sondeo más barata del catálogo: la cabecera viene en toda respuesta, así que un `GET`
  inocuo devuelve el tope vigente **sin gastar un solo envío**. El `"typically"` deja la
  unidad de `reset` sin fijar (DISC-13).

## [F8] Developer docs — Platform quotas

- **URL:** https://developers.brevo.com/docs/platform-quotas
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"Quotas limit the number of objects you can create via the API, UI, or other
    integrations. Each quota applies to a specific resource type, such as campaigns or
    contacts."`
  - `"When you reach a quota limit, delete unused objects to create new ones."`
  - `"General quota | Enterprise quota"` — `"10,000 email campaigns | 50,000 email
    campaigns"` · `"5M stored contacts | 900M stored contacts"` · `"300 created lists |
    600 created lists"` · `"Total active automation workflows"`: `"50 active workflows |
    500 active workflows"`
  - `"This quota is restricted to one account per company on the Starter Plan."`
- **Observaciones:** el propio proveedor separa caudal (frecuencia) de *quota* (objetos),
  lo que refuerza **B3**: estas no son cuotas del ACM y no van a `capacity`. Además su
  granularidad de plan (**dos** tramos) no coincide ni con la del caudal (**tres**) ni
  con la de los planes (**cinco**), y la página no dice a qué planes corresponde
  `"General"`.

## [F9] Developer docs — How it works

- **URL:** https://developers.brevo.com/docs/how-it-works
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"All API requests use the base URL with version v3:"` — `"https://api.brevo.com/v3/"`;
    `"Include your API key in the api-key header for every request."`
  - `"| 402 | Payment Required | Account requires activation or additional credits |"` ·
    `"| 403 | Forbidden | Insufficient permissions for this resource |"` ·
    `"| 406 | Not Acceptable | Content-Type must be application/json |"` ·
    `"| 429 | Too Many Requests | Rate limit exceeded. See [rate limits](/docs/api-limits) |"`
  - `"Errors include a code and message: {\"code\": \"invalid_parameter\", \"message\":
    \"Invalid email address\"}"`
  - `"| not_enough_credits | Insufficient credits to complete the request |"` ·
    `"| permission_denied | Account lacks permission for this operation |"` ·
    `"| account_under_validation | Account is pending validation |"` ·
    `"| duplicate_request | Identical request submitted too frequently |"`
  - `"When rate limits are exceeded, you receive a 429 Too Many Requests response with
    headers indicating: x-sib-ratelimit-limit - Maximum requests allowed ·
    x-sib-ratelimit-remaining - Requests remaining in current window ·
    x-sib-ratelimit-reset - Time until limit resets"`
  - `"| limit | integer | Number of results per page. Default and maximum vary by
    endpoint |"`
- **Observaciones:** el agotamiento de cuota (402 / `not_enough_credits`) y el de caudal
  (429) son **distinguibles por código**, a diferencia de lo que declara la referencia
  del propio endpoint de envío [F10]. `duplicate_request` (`"submitted too frequently"`)
  es un freno por repetición sin umbral publicado. Ninguna de las dos páginas de caudal
  menciona `Retry-After`. La tabla no lleva fila 422 (DISC-11).

## [F10] Developer docs — Referencia de `POST /v3/smtp/email`

- **URL:** https://developers.brevo.com/reference/send-transac-email
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"Send a transactional email to one or more recipients, either using inline HTML
    content or a pre-built template via templateId. You can schedule emails for future
    delivery using scheduledAt (UTC, up to 5-minute delay), send multiple personalized
    versions with messageVersions (max 2000 total recipients, 99 per version), and
    attach files via URL or base64-encoded content."`
  - `messageVersions` — `"Maximum total recipients per API request is 2000. Maximum
    recipients per message version is 99. Individual params objects must not exceed
    100 KB. Cumulative params across all versions must not exceed 1000 KB."`
  - `scheduledAt` — `"UTC date-time when the email should be sent (format:
    YYYY-MM-DDTHH:mm:ss.SSSZ). Include timezone information in the date-time value.
    Scheduled emails may be delayed by up to 5 minutes."`
  - Nombre de remitente y destinatario — `"Display name of the recipient. Maximum length
    is 70 characters."`
  - Adjuntos — `"Supported file extensions: xlsx, xls, ods, docx, docm, doc, csv, pdf,
    txt, gif, jpg, jpeg, png, tif, tiff, rtf, bmp, cgm, css, shtml, html, htm, zip, xml,
    ppt, pptx, tar, ez, ics, mobi, msg, pub, eps, odt, mp3, m4a, m4v, wma, ogg, flac,
    wav, aif, aifc, aiff, mp4, mov, avi, mkv, mpeg, mpg, wmv, pkpass, xlsm."`
  - Errores — `"## Errors · ### 400 Bad Request Error · bad request · code (enum,
    required) — Error code displayed in case of a failure · Allowed values:
    invalid_parameter, missing_parameter, out_of_range, … not_enough_credits,
    permission_denied, … account_under_validation, … Insufficient credits,
    Request already processed"`
  - Respuestas renderizadas: `"### 201"` y `"### 202"`
- **Observaciones críticas:** (1) los dos topes de destinatarios (2.000 y 99) viven
  **dentro de la descripción de `messageVersions`**, así que no está claro si el 2.000
  rige también cuando se usa solo `to`; ni la referencia ni las dos specs ponen
  `maxItems` en `to`, `cc` ni `bcc`. (2) La referencia aplana **a 400** motivos que la
  tabla general [F9] separa en 402 y 403. (3) Ningún tamaño de petición ni de adjunto
  aparece en esta página, que es donde debería estar.

## [F11] Developer docs — Referencia de `GET /v3/smtp/emails`

- **URL:** https://developers.brevo.com/reference/get-transac-emails-list
- **Fecha de acceso:** 2026-09-16
- **Citas literales:** `"limit (long, optional, default: 500) — Number of documents
  returned per page"` · `"offset (long, optional, default: 0)"` · `"This endpoint will
  show the list of emails for past 30 days by default."` · `"Maximum time period that
  can be selected is one month"`
- **Observación:** dimensión **Results Per Request** con dos estructuras (tope por
  petición y ventana de consulta acotada). El ACM la define; v0.3 no la serializa (F-05).

## [F12] Developer docs — Referencia de `GET /v3/account`

- **URL:** https://developers.brevo.com/reference/get-account
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"GET https://api.brevo.com/v3/account … **Use this to:** … Check plan details
    (type, credits, expiration)"`
  - `"credits (float, required) — Remaining credits of the user"` · `"creditsType
    (enum, required) — This is the type of the credit, \"Send Limit\" is one of the
    possible types of credit of a user. \"Send Limit\" implies the total number of emails
    you can send to the subscribers in your account. Allowed values: sendLimit"`
  - `"endDate (string, optional) — Date of the period from which the plan will end
    (Unix timestamp format)"` · `"startDate (string, optional) — Date of the period
    from which the plan will start (Unix timestamp format)"`
  - Ejemplo oficial — `"\"plan\": [ { \"credits\": 250, \"creditsType\": \"sendLimit\",
    \"type\": \"free\" }, { \"credits\": 15, \"creditsType\": \"sendLimit\", \"type\":
    \"sms\" } ]"`
- **Observaciones:** es el **canal de introspección de la cuota**, y devuelve el saldo
  restante y las dos marcas del periodo del plan, no el tope contratado ni el consumido.
  Sostiene `fixed_billing_cycle` (el reinicio va anclado al ciclo del plan) y es la vía
  de sondeo **de coste cero** para fijar el día del reinicio. El ejemplo no dice de qué
  ventana son los 250 créditos de una cuenta Free con tope diario de 300.

## [F13] Developer docs — Envío por lotes

- **URL:** https://developers.brevo.com/docs/batch-send-transactional-emails
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"Batch sending lets you send multiple personalized transactional emails in one API
    request. Instead of making 100 separate API calls, send up to 1000 message versions
    with different recipients, content, and variables in a single call."`
  - `"Bulk sending limits"` — `"Send up to 1000 email messages in one API call"` ·
    `"Execute the endpoint up to 6000 times per hour (100 times per minute)"` ·
    `"This means you can send up to **6,000,000 email versions per hour**."`
  - `"Do not pass an outer to parameter. Define all recipients inside each message
    version. If you include an outer to parameter, the request will fail."`
- **Observaciones:** el lote **no tiene endpoint propio**: es el mismo
  `POST /v3/smtp/email` con `messageVersions`, y los dos modos son **excluyentes**
  (F-25). Su caudal contradice a la página canónica por un factor de 600 (DISC-01) y su
  capacidad contradice a la referencia (DISC-03).
- **Releída el 2026-10-31 (verificador).** La lista `"Bulk sending limits"` sigue igual que en
  el volcado del 2026-09-21. Trae `"Maximum 2000 total recipients per API request"` y
  `"Maximum 99 recipients per message version"` debajo del `"Send up to 1000 email messages in
  one API call"`, que es por lo que DISC-03 cerró ese día por E5 (1). La NOTA del YAML que
  seguía diciendo que la guía contradice el 2.000 se ha corregido. DISC-01 (6.000 por hora
  frente a 1.000 por segundo) sigue en pie.

## [F14] Developer docs — Programación de lotes

- **URL:** https://developers.brevo.com/docs/schedule-batch-sendings
- **Fecha de acceso:** 2026-09-16
- **Cita literal:** `"*Note: you can schedule a message up to **72 hours** in the future
  (from the moment the API request is executed).*"`
- **Observación:** horizonte temporal, no consumible. v0.3 no lo expresa; provenance.

## [F15] Developer docs — Versiones heterogéneas e idempotencia

- **URL:** https://developers.brevo.com/docs/heterogenous-versions-batch-emails
- **Fecha de acceso:** 2026-09-16
- **Cita literal:** `"The TTL for idempotencyKey is 30 minutes. After the TTL expires,
  you can reuse the same key for a new request."`
- **Observación:** condiciona el **diseño del sondeo**: una bisección por reintento tiene
  que usar claves distintas o recibirá `duplicate_parameter`.

## [F16] Developer docs — Modo sandbox

- **URL:** https://developers.brevo.com/docs/using-sandbox-mode
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"Add the X-Sib-Sandbox header with the value drop to your request. In sandbox
    mode: * No emails are sent to recipients * No email logs are created in your Brevo
    account * You receive a success response indicating the API endpoint is working
    correctly"`
  - `"Sandbox mode only validates the API request format. To test actual email delivery,
    send emails without the sandbox header."`
- **Observación:** Brevo publica un modo de coste cero por cabecera. Cumple **F2** y la
  condición 3 de **D-046** (preferir el rechazo al envío) para medir forma y topes de
  carga. Su límite lo escribe el propio proveedor: lo que solo se aplique en la entrega
  no se medirá con sandbox.

## [F17] Developer docs — Integración SMTP

- **URL:** https://developers.brevo.com/docs/smtp-integration
- **Fecha de acceso:** 2026-09-16
- **Citas literales:** `"**Non-encrypted**: Use ports 587 or 2525 … **Encrypted**: Use
  port 465 with SSL or TLS encryption"` · `"The SMTP relay does not support batch
  sending. Use the batch sending API endpoints for batch operations. The SMTP relay is
  designed for transactional emails."`
- **Observación:** **dos canales sobre la misma cuota con capacidades distintas** por
  petición (F-15). No publica ni conexiones simultáneas, ni mensajes por conexión, ni si
  los RPS de la API alcanzan al relay.

## [F18] Developer docs — Exportación masiva de actividad

- **URL:** https://developers.brevo.com/docs/bulk-fetch-all-your-transactional-activity
- **Fecha de acceso:** 2026-09-16
- **Cita literal:** `"Maximum 20 export jobs per 7-day period. Large data volumes are
  delivered as compressed files containing multiple CSV files."`
- **Observación:** es una **cuota de consumo real, con ventana** (20 trabajos / 7 días),
  sobre un recurso que no es el envío. La página no publica la ruta del endpoint, así que
  ningún bloque la puede referenciar: por **B7** no se define en `capacity` y va al
  provenance y a `not_found`.

## [F19] Developer docs — Webhooks agrupados

- **URL:** https://developers.brevo.com/docs/batch-webhooks
- **Fecha de acceso:** 2026-09-16
- **Citas literales:** `"Each batch contains up to 500 events by default."` · `"If more
  than 500 events accumulate, multiple batches are sent at the end of the 5-minute
  window."`
- **Observación:** capacidad de **salida** del proveedor hacia el cliente. v0.3 modela lo
  que el cliente consume, no lo que el proveedor entrega.

## [F20] Especificación OpenAPI troceada — Email API

- **URL:** https://developers.brevo.com/openapi/email-api.json
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"\"servers\": [{\"url\": \"https://api.brevo.com/v3\", \"description\":
    \"https://api.brevo.com/v3\"}]"` (OpenAPI 3.1.0, 21 rutas)
  - `"\"limit\": {\"type\": \"integer\", \"format\": \"int64\", \"minimum\": 0,
    \"maximum\": 1000, \"default\": 500}"` — `"Number of documents returned per page"`
  - `"\"days\": {\"type\": \"integer\", \"format\": \"int64\", \"maximum\": 90}"` —
    `"Number of days in the past including today (positive integer, maximum 90). _Not
    compatible with 'startDate' and 'endDate'_. Defaults to 30 if neither dates nor days
    are provided."`
  - `paths./smtp/email.post.responses` — únicamente `"201: Transactional email sent
    successfully"` y `"400: bad request"`
  - La misma descripción de `messageVersions` que [F10], palabra por palabra
- **Topes de paginación serializados:** `GET /smtp/emails` máx. 1000 (def. 500) ·
  `GET /smtp/emailStatus/{identifier}` máx. 500 (def. 100) · `GET /smtp/templates`
  máx. 1000 (def. 50) · `GET /smtp/blockedContacts` máx. 100 (def. 50) ·
  `GET /inbound/events` máx. 500 (def. 100) · `GET /smtp/statistics/events` máx. 5000
  (def. 2500) · `GET /smtp/statistics/reports` máx. 30 (def. 10)
- **Observaciones:** la spec **sí** serializa la profundidad de paginación (F-05) y la
  ventana consultable (90 días), y **no** serializa ni un `maxItems` de destinatarios ni
  el 429 ni las cabeceras `x-sib-ratelimit-*`. Omite además el 202 que la histórica y la
  referencia renderizada sí declaran (DISC-05), lo que la descalifica como contrato
  completo del endpoint de envío.
- **URL corregida en el YAML el 2026-10-31 (verificador).** La NOTA del 202 citaba
  `https://developers.brevo.com/openapi`, que da 404 con y sin JavaScript y no tiene capturas.
  Aquí ya figuraba la buena, `/openapi/email-api.json`, y la cita no cambia. Volcado en
  `evidencias/paginas/2026-10-31/`.

## [F21] Especificación OpenAPI histórica — plataforma completa

- **URL:** https://api.brevo.com/v3/swagger_definition_v3.yml
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"openapi: 3.0.1 … title: Brevo API … servers: - url: https://api.brevo.com/v3"`
  - `/smtp/email` — `"post: operationId: sendTransacEmail … responses: '201': …
    description: Transactional email sent successfully · '202': … description:
    Transactional email scheduled successfully · '400': $ref:
    '#/components/responses/errorModel'"`
  - `/transactionalSMS/sms` — `"'402': … description: You don't have enough credit to
    send your SMS. Please update your plan · '429': … description: Too many requests.
    Please retry after some time."`
  - `/emailCampaigns/{campaignId}/sendNow` — `"'402': description: You don't have enough
    credit to send your campaign. Please update your plan … The system verifies your
    account's send limit and credit balance before dispatching; if credits are
    insufficient, a 402 error is returned."`
  - `creditsType` — `"This is the type of the credit, \"Send Limit\" is one of the
    possible types of credit of a user. \"Send Limit\" implies the total number of emails
    you can send to the subscribers in your account." enum: - sendLimit"`
  - `components.responses.errorModel` — `"enum: - invalid_parameter - missing_parameter -
    out_of_range - campaign_processing - campaign_sent - document_not_found -
    not_enough_credits - permission_denied - duplicate_parameter - duplicate_request -
    method_not_allowed - unauthorized - account_under_validation - not_acceptable -
    bad_request - unprocessable_entity …"` (sin `too_many_requests`)
  - `info.description` — `"**Possible responses** | Code | Message | … | 400 | Error. Bad
    Request | | 401 | Error. Authentication Needed | | 402 | Error. Not enough credit,
    plan upgrade needed | | 403 | Error. Permission denied | | 404 | Error. Object does
    not exist | | 405 | Error. Method not allowed | | 406 | Error. Not Acceptable |
    | 422 | Error. Unprocessable Entity |"` (sin fila 429)
  - La misma descripción de `messageVersions` que [F10], palabra por palabra
- **Búsqueda literal sobre la captura del 16-09 (145.561 bytes, no archivada; la misma URL
  devuelve 1.162.191 bytes dos días después, ver [F29]):** `"rate limit"`,
  `"rate-limit"`, `"requests per"`, `"RPS"`, `"RPH"`, `"per hour"`, `"per minute"`,
  `"per second"` y `"x-sib"` → **0 coincidencias**.
- **Observaciones críticas:** (1) el contrato máquina **no menciona el caudal ni una sola
  vez**, ni sus unidades, ni sus cabeceras: todo el régimen de límites vive en prosa
  HTML. (2) Asimetría dentro del mismo fichero: el SMS transaccional declara 402 y 429
  con mensaje literal y el correo transaccional no declara ninguno de los dos. (3) El
  envío de **campaña** (producto de marketing) documenta la verificación previa de
  `"send limit and credit balance"`; el transaccional, que gasta los mismos créditos, no
  documenta nada equivalente. Las tres son material de primer orden para el capítulo 6.

## [F22] Changelog

- **URL:** https://developers.brevo.com/changelog/2026/2/10
- **Fecha de acceso:** 2026-09-16
- **Cita literal:** `"Added dedicated rate limits for the following endpoints: *
  POST /v3/orders/status * POST /v3/products"`
- **Observación:** evidencia **datada** de que el régimen de caudal cambia con el tiempo
  y endpoint a endpoint (F-09).

## [F23] Índice legible por máquina

- **URL:** https://developers.brevo.com/llms.txt
- **Fecha de acceso:** 2026-09-16
- **Cita literal:** `"## OpenAPI Specification / The raw OpenAPI 3.1 specification for
  this API is available at: - [OpenAPI JSON](https://developers.brevo.com/openapi.json) -
  [OpenAPI YAML](https://developers.brevo.com/openapi.yaml)"`
- **Observación:** la URL que anuncia devuelve un índice HTML de APIs, no una spec; la
  spec útil del producto modelado es `/openapi/email-api.json` [F20].

## [F24] Centro de ayuda — Límites del plan Free

- **URL:** https://help.brevo.com/hc/en-us/articles/208580669-FAQs-What-are-the-limits-of-the-Free-plan
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"The Free plan includes 300 email sends per day. The daily limit resets every day,
    and unused emails do not roll over to the next day."`
  - `"Transactional emails: once you reach your daily limit, up to 1,000 additional
    emails are held in a retry queue. Emails beyond this queue are not delivered. This
    limit does not affect how many contacts you can add to a campaign."`
  - `"Once you reach the daily limit of 300 emails, you cannot schedule a campaign in
    advance for the next day. You need to wait until your quota resets."`
  - `"To remove the daily limit or send more emails, upgrade to a Starter, Standard,
    Professional, or Enterprise plan. Upgrading raises your daily limit right away, but
    only applies to emails sent after the upgrade."`
  - `"The Free plan allows you to store up to 100,000 contacts in your account."` ·
    `"The Free plan allows only one user (the account owner)."` · `"With the Free plan,
    up to 2,000 unique contacts can enter your active automations."`
  - `"Here are some of the features that are not included on the Free plan: Email A/B
    testing · Dedicated IPs · Landing pages · Popups · Mobile and web push notifications
    · WhatsApp · Sales workflows · Instagram DMs or Facebook Messenger · Phone support"`
- **Observación crítica:** la **cola de reintento de 1.000** es el hallazgo del plan Free
  y la fricción F-24: al agotar la cuota los transaccionales no se rechazan, se retienen,
  y a partir de ahí **se descartan en silencio**. No es tope duro, ni sobrecoste, ni 429.
  El literal `"resets every day"` es periodicidad y **no ancla** (regla D8): ni hora ni
  huso.

## [F25] Centro de ayuda — Planes de precios

- **URL:** https://help.brevo.com/hc/en-us/articles/208589409-About-Brevo-s-pricing-plans
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"🆓 Free $0/month · 🎯 Starter From $9/month · 🏅 Standard From $18/month ·
    📈 Professional From $499/month · 🏢 Enterprise Custom price"`
  - Starter — `"It includes no daily sending limit, and is available in multiple tiers to
    suit your needs:"`, tabla `"Monthly email sends | Contacts stored"`: `"5,000 | Up to
    500"` · `"10,000 | Up to 1,500"` · `"15,000 | Up to 2,500"` · `"20,000 to 100,000 |
    Up to 500,000"`
  - Standard — tabla `"Monthly email sends | Contacts stored"`: `"5,000 | Up to 500"` ·
    `"10,000 | Up to 1,500"` · `"15,000 | Up to 2,500"` · `"20,000 to 500,000 | Up to
    500,000"`
  - Professional — `"Choose from 150,000 to 10 million monthly email sends with storage
    for up to 2 million contacts."`; Enterprise — `"large organizations that need a fully
    tailored solution, from custom sending volumes and dedicated support…"`, `"It
    includes unlimited contacts storage."`
  - `"How does a monthly subscription work?"` — `"With a monthly subscription, you are
    charged each month on your billing date. Your credits are renewed each month on your
    billing date. Any unused credits expire just before the new credits are added."`
  - `"How does a yearly subscription work?"` — `"Even though you pay once a year, your
    credits are renewed each month on the same day as your billing date. For example, if
    your yearly plan starts on the 12th, your credits will be topped up on the 12th of
    each month. Any unused credits expire just before the new credits are added."`
  - `"The main difference is that with a yearly subscription, you pay once a year instead
    of every month, and you get a 10% discount."` · `"The prices shown in this article and
    on our pricing page are exclusive of taxes."`
  - Add-ons — `"💰 The Sales Essentials package costs $31 per month."` · `"💰 The Sales
    Advanced package costs $64 per month."` · `"💰 The Remove Brevo logo add-on costs $9
    per month."` · `"💰 Each additional marketing seat costs $9 per month."` · `"💰 A
    dedicated IP costs $251 per year."` · `"💰 The SAML SSO add-on costs $324 per
    month."` · `"💰 The International package costs $215 per month."`
  - Créditos prepago — `"Prepaid email credits are available as an add-on on all plans.
    They can be used for both marketing and transactional emails."` · `"Prepaid email
    credits give you access to all Starter plan features and the Remove Brevo logo
    add-on. The limit of 2,000 contacts in automations also applies."` · `"💰 Prepaid
    credits can be purchased in packs ranging from 5,000 to 1 million emails. One credit
    equals one email sent to one contact."`
  - Auto-ascenso — `"What is the auto-upgrade process when reaching the contact limit for
    my plan?"` — `"The email volume you select determines your pricing tier, which also
    sets the limit on the total number of contacts you can store in Brevo."` · `"If you
    reach or exceed that limit, we will automatically upgrade your plan to the next
    tier."` · `"For example, if you are using a Starter plan with a limit of 1,500
    contacts and you reach 1,501 contacts, we will automatically upgrade you to the next
    Starter plan tier, which allows up to 2,500 contacts. The cost of your subscription
    will increase accordingly."`
- **Observaciones:** aquí está el **ancla** de la ventana mensual —el día de facturación,
  citado dos veces—, que por **D8** da `fixed_billing_cycle` en verde. Y aquí está el
  **único mecanismo automático de sobrecoste que Brevo publica**, que se dispara por
  **contactos** y no por correos (F-27). Tres add-ons no cuadran con la página de precios
  (DISC-08).
- **Releída el 2026-10-31 (verificador, E3).** El artículo se ha reescrito entre el volcado
  del 2026-09-21 y el 31-10. Hay tres cambios del proveedor, sin efecto en ningún valor:
  - El asiento de marketing ya no cuesta 9 USD: `"Standard plan: $12 per month for each
    seat"`, como en la página de precios. Cae una de las tres incoherencias de DISC-08;
    siguen el logo (`"$9 per month"` frente a 12) y Sales Advanced (`"$64 per month"` frente
    a 65).
  - Desaparecen dos frases de los créditos prepago: `"One credit equals one email sent to
    one contact."` y `"Prepaid email credits give you access to all Starter plan features
    and the Remove Brevo logo add-on. The limit of 2,000 contacts in automations also
    applies."` Las dos seguían en la captura de Wayback del 2026-10-05. En su lugar,
    `"Varies based on the number of credits (packs from 5,000 to 1 million emails)"` y
    `"One email sent equals one credit deducted."`.
  - Starter, en otras palabras: `"The Starter plan includes no daily sending limit"`.
  Volcado en `evidencias/paginas/2026-10-31/`; las líneas del YAML llevan su relectura
  fechada.

## [F26] Centro de ayuda — Añadir o quitar correos del plan

- **URL:** https://help.brevo.com/hc/en-us/articles/8292912279954-Add-or-remove-emails-from-your-plan
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - Tabla `"Plan | Limit"` — `"🆓 Free | Up to 300 emails per day"` · `"🎯 Starter | Up
    to 100,000 emails per month"` · `"🏅 Standard | Up to 500,000 emails per month"` ·
    `"💼 Professional | Up to 10 million emails per month"` · `"🏙 Enterprise | Custom
    number of emails per month"`
  - `"The emails included in your plan need to be used within your monthly billing
    period. Any unused emails expire and won't carry over to the next month."`
  - `"Can I use my emails to send both marketing and transactional emails?"` — `"Yes, you
    can use your email credits to send both marketing and transactional emails."`
  - `"How will I be charged when adding more emails to my plan?"` — `"When adding emails
    to your plan, you are charged immediately, with a pro-rated charge from the date of
    your purchase to your next billing date. You will then be charged on your usual
    billing date each month."` · `"When removing emails from your plan, the change will
    apply on your next billing date."`
  - `"I cannot select a lower tier when trying to remove emails from my plan. Why?"` —
    `"Each tier includes a specific number of emails, and your chosen email volume
    determines both your pricing tier and the maximum number of contacts you can have in
    Brevo."` · `"If you have more contacts than the limit allowed for a given tier, you
    won't be able to select that lower tier."`
  - `"How can I send more than 300 emails per day on the Free plan?"` — `"The Free plan
    includes 300 email sends per day. The daily limit resets every day, and unused emails
    do not roll over to the next day."` · `"Once you reach your daily limit, up to 1,000
    additional emails are held in a retry queue. Emails beyond this queue are not
    delivered."`
- **Observación crítica para A1:** la cuota es **una sola y compartida** entre marketing
  y transaccional. El producto modelado **no tiene cuota propia**; la que lleva la
  datasheet es la de la cuenta. Es la variante inversa de F-10 y se anota como tal.
  Además es la segunda fuente independiente, con literal idéntico, de la cuota diaria del
  Free y de la cola de reintento.

## [F27] Centro de ayuda — Adjuntos en un correo transaccional

- **URL:** https://help.brevo.com/hc/en-us/articles/4402811730962-Add-an-attachment-to-a-transactional-email
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - Sección de API — `"The size limit for transactional emails is 20MB, including the
    attachments and email content."`
  - Sección de plantilla — `"The size limit for transactional emails is 20MB, including
    attachments and email content. The attachment should be less than 4MB."`
  - `"If you add an attachment in your API script, you can only send your transactional
    email to a maximum of 99 recipients."`
- **Nota de acceso:** `help.brevo.com` devuelve **403** a `curl` y a `WebFetch`. Estas
  tres citas se leyeron con navegador, con los acordeones desplegados; **no hay volcado
  en texto** y por tanto `verificar_citas.py` no puede comprobarlas sin red. Una de las
  tres lentes de esta pasada no llegó a la página por el 403 y por eso no anotó ninguna
  cifra suya: la discrepancia del tamaño (DISC-16) se sostiene con [F5] enfrente.
- **Observaciones críticas:** (1) es el **único** sitio de todo el dominio donde aparece
  un tamaño máximo del correo transaccional por API; la documentación de desarrollador no
  publica ninguno. (2) El tope por adjunto (4 MB) solo se declara en la vía de
  **plantilla**; la sección de API lo omite y no se puede extrapolar. (3) El tope de 99
  destinatarios **condicionado a que la petición lleve adjunto** es la fricción F-25.

## [F28] Blog oficial — API rate limiting *(contenido editorial, no referencia)*

- **URL:** https://www.brevo.com/blog/api-rate-limiting/
- **Fecha de acceso:** 2026-09-16
- **Citas literales:**
  - `"HTTP/1.1 429 Too Many Requests · x-sib-ratelimit-limit: 600 ·
    x-sib-ratelimit-remaining: 0 · x-sib-ratelimit-reset: 45 · Content-Type:
    application/json · {\"code\": \"too_many_requests\", \"message\": \"API call rate
    limit exceeded\"}"`
  - `"Brevo uses its own set of rate limit headers, not the generic Retry-After header.
    These headers are included in all API responses, not just 429s, so you can monitor
    your usage proactively before hitting the ceiling."`
  - `"Using messageVersions (sending up to 1,000 personalized versions in a single API
    call), the batch endpoint can be called up to 5 times per minute. That gives a
    maximum throughput of 30,000 emails per hour"`
  - `"GET /v3/smtp/emails allows 2 requests per second (7,200/hr) on self-service plans
    and 3 requests per second (10,800/hr) on Enterprise."`
  - `"Send limits vary by plan. Check your account's current limits via GET /v3/account
    or the Brevo dashboard. Lower limits apply on the free plan (300 emails/day). You can
    include a maximum of 2,000 total recipients per API request, and a maximum of 99
    recipients per message version when using batch mode. The params object is capped at
    100KB."`
  - `"x-sib-ratelimit-reset | Seconds until the rate limit counter resets"`
  - `"The GET /v3/account endpoint returns your current plan limits and API usage.
    Query it at the start of any bulk send job and gate accordingly"` / `"Check
    GET /v3/account to see your current limits programmatically."`
- **Estatus de la fuente:** es el **único** sitio del dominio donde Brevo publica el
  cuerpo literal de un 429, y a la vez es contenido editorial cuya autoría no es de
  ingeniería. Nada suyo se adopta: cinco de sus afirmaciones contradicen a la
  documentación o a la spec (DISC-02, DISC-12, DISC-13, DISC-14, DISC-15). Lo que sí
  confirma, palabra por palabra con [F10] y [F21], son los topes de 2.000 y 99.

---

## [F29] Especificación OpenAPI — plataforma completa, segunda consulta y primera archivada

- **URL:** https://api.brevo.com/v3/swagger_definition_v3.yml — la misma de [F21]
- **Fecha de acceso:** 2026-09-18
- **Cómo se obtuvo:** `curl -sS -o 03_datos/apis/brevo/evidencias/swagger_definition_v3_2026-09-18.yml https://api.brevo.com/v3/swagger_definition_v3.yml`, respuesta `http=200`
- **Fichero:** `evidencias/swagger_definition_v3_2026-09-18.yml` · **1.162.191 bytes** ·
  **207 rutas** · sha256 `924e7b80833868cfd9be8705c94540fa1ae966266d4291bcc086e69f3fe36716`
- **Por qué se abre como fuente propia.** [F21] es la misma URL, consultada el 16-09, y
  declara haber buscado *«sobre el fichero completo (145.561 bytes)»*. El fichero que
  contesta esa URL hoy mide ocho veces más, así que las dos consultas **no midieron el mismo
  artefacto**. Cuál de las dos cosas pasó —que la captura del 16-09 fuese parcial o que la
  especificación creciera— no está medido y no se afirma. Lo que sí queda: hasta hoy, ninguna
  cita del expediente se apoyaba en un fichero archivado.
- **Citas literales** (ruta y línea del fichero archivado):
  - `"openapi: 3.0.1"` (l. 1) · `"title: Brevo API"`
  - `"operationId: createSmtpTemplate"` y `"summary: Create an email template"` — `POST /smtp/templates` (l. 24949)
  - `"operationId: updateSmtpTemplate"` — `PUT /smtp/templates/{templateId}` (l. 25112)
  - `"Create a new sender domain"` — `POST /senders/domains` (l. 4028)
  - `"Authenticate a sender domain"` — `PUT /senders/domains/{domainName}/authenticate` (l. 4455)
  - `"to"`: `"Required when messageVersions is not provided. Ignored when messageVersions is provided."` (l. 2368)
  - `"Maximum total recipients per API request is 2000. Maximum recipients per message version is 99."` (l. 23492 y 23788)
- **Búsqueda literal repetida sobre el fichero completo de 1.162.191 bytes:** `"rate limit"`,
  `"rate-limit"`, `"requests per"`, `"RPS"`, `"RPH"`, `"per hour"`, `"per minute"`,
  `"per second"` y `"x-sib"` → **0 coincidencias**. **O-16 se sostiene sobre el fichero
  entero**, que es lo que la observación afirmaba y hasta hoy no estaba comprobado: cambia la
  cifra de bytes, no el hallazgo.
- **Alcance, y hay que decirlo antes de citarla:** es la spec de **plataforma**, con rutas de
  marketing, CRM, *loyalty*, *ecommerce* y WhatsApp. **A1** acota este TFM al producto
  transaccional, y el propio expediente declara que la spec útil del producto modelado es la
  troceada `/openapi/email-api.json` de [F20]. Una ruta que solo aparezca aquí y no en [F20]
  no se cuenta como parte del producto sin justificarlo.

---

## [F30] Panel con cuenta propia — segunda pasada, test C2 y retención

- **Fecha de acceso:** 2026-09-18 · **Cuenta:** Free, con la sesión del titular
- **Evidencia:** `evidencias/panel_brevo_2026-09-18.md`
- **Qué añade a [F-panel del 17-09]:** la primera pasada recorrió el menú y no las páginas
  donde vive cada operación del test C2. Esta va a por ellas.
- **Citas literales:**
  - Plantillas (`app.brevo.com/templates/listing`): `"Create Template"` ·
    `"You have not created any Email templates."`
  - Dominios (`app.brevo.com/senders/domain/list`): `"Add a domain"` ·
    `"Authenticate your domain and brand your tracking links…"`
  - Remitentes (`app.brevo.com/senders/list`): `"Add sender"`, con las pestañas
    `"Senders"`, `"Domains"`, `"Dedicated IPs"` y `"Sending cadence"`
  - Ajustes transaccionales (`app.brevo.com/transactional/email/settings`):
    `"Webhook — Each event (opening, click, bounce, etc.) will be sent in real time to your
    server."` · `"Blocked or unsubscribed contacts"` · `"Blocked domains"` ·
    `"Retention rules"`. **No hay entrada de inbound parsing.**
  - Retención (`.../settings/retention-rules`): `"Transactional logs are stored only for a
    limited time. Once the retention period ends, they will be deleted automatically."` ·
    `"The logs will be deleted after [ ] months"` · `"All senders"` /
    `"Only Selected Senders"` · `"Never store previews"`
  - Cadencia (`app.brevo.com/senders/sending-cadence`): `"Activate frequency cap"` ·
    `"Set the maximum number of emails your contacts can receive during the below-defined
    period."`, con `"Upgrade"` al lado
- **Dato leído del control, no del texto:** el campo de retención es
  `input[name="all-senders-retention"]`, `type="number"`, **`min="1"`, `max="24"`**, valor
  actual `1`. Inspección del DOM, sin tocarlo.
- **Lo que no publica:** ningún tope de plantillas, de dominios, de claves de API ni de
  claves SMTP. Hay botón de crear en los cuatro y ninguna cifra al lado.

---

## [E5] Sondeo empírico — el rechazo por caudal, y la unidad del reset (escalón 3, sin envíos)

- **Fecha:** 2026-09-18, 19:56 UTC · **Ejecutado por:** el agente en la máquina Linux del
  autor, con la clave de la cuenta Free de `~/.config/tfm/.env` (D-046).
- **Dos pasadas, y la segunda existe porque un revisor tumbó tres afirmaciones de la
  primera.** Los dos volcados están archivados y el cierre se apoya en el segundo:
  `probe_brevo_a_429_rps.sh` → `evidencias/probe_brevo_a_429_rps_2026-09-18_195606.json`, y
  `probe_brevo_a_ventana_y_reset.sh` →
  `evidencias/probe_brevo_a_ventana_y_reset_2026-09-18_202618.json`. Lo que la primera no
  archivaba: las cabeceras que describen el cuerpo del 429, la ventana —que quedaba acotada
  entre 0,4 y 2,06 s— y la cabecera de un endpoint declarado **solo por hora**.
- **Coste: 0 envíos.** Seis peticiones GET, ninguna al endpoint de envío. Un guardián aborta
  si la ruta es `/smtp/email` exacto o con query, probado contra cinco casos límite en
  `05_salida/_herramientas/test_guardian_429_rps.sh`. Entre ellos `/smtp/emails`, que es el
  que sí hay que golpear.
- **Por qué no se usó `probe_brevo_a_cuerpo_429.sh`,** que era el sondeo preparado para
  alcanzar el 429: ataca el bucket de «All other endpoints», que [F6] publica en 100 por
  hora y que [E2] midió en `'x-sib-ratelimit-limit: 5000'`. Agotarlo son miles de
  peticiones y deja `GET /v3/account` devolviendo 429 durante hasta una hora, que es la
  lectura de la que dependen los demás sondeos. `GET /v3/smtp/emails` tiene fila propia de
  **2 por segundo**, así que el rechazo llega con **tres** peticiones y la ventana que se
  agota dura un segundo.
- **Lo medido, petición a petición:**
  - Ráfaga sobre `GET /v3/smtp/emails?limit=1` sin pausas: `400`, `400`, `429`, con
    `'x-sib-ratelimit-limit: 2'` en las tres y `'x-sib-ratelimit-remaining'` en `1`, `0`
    y `0`.
  - El `429` llega **sin cuerpo**, y ahora con el artefacto que lo dice: `'content-length:
    0'`, sin `Content-Type`, sin `Retry-After` y con el tamaño de la descarga en **0 bytes**.
    Sí trae las tres cabeceras de caudal, `limit: 2`, `remaining: 0` y `reset: 1`.
  - Las dos lecturas de control tomadas justo después del rechazo —`GET /v3/smtp/templates`
    y `GET /v3/account`— devuelven `200`.
  - **La ventana no arranca con la primera petición.** Sondeada la reposición cada 250 ms,
    la primera muestra, 0,426 s después del rechazo y 0,702 s desde la primera de la serie, ya
    se admitió. Eso descarta una ventana de un segundo anclada a la primera petición; con una
    sola muestra no se separa una ventana fija alineada con el reloj de una reposición gradual.
    La primera pasada vio 1,658 s porque tomó una sola muestra, y esa cifra no medía la
    ventana.
  - **El endpoint declarado solo por hora sí emite cabecera, y ahí se decide DISC-13.**
    `GET /v3/account` —`"All other endpoints | 100 RPH | -"` en [F6]— devuelve
    `'x-sib-ratelimit-reset: 2021'` y, **12,306 s después**, `'2009'`: baja **12**. Cuenta
    segundos en un bucket horario, que es justo donde el factor 3.600 de DISC-13 mordía.
- **Qué cierra.**
  1. **DISC-13, la unidad del `reset`: son segundos, y el dato que lo decide es el del
     endpoint horario.** `GET /v3/account` está declarado solo por hora y su `reset` baja
     **12 en 12,306 s**. Ahí las dos lecturas registradas sí se separan: el lado B, `"Seconds
     until the rate limit counter resets"`, predice esa caída; una unidad de granularidad
     horaria predice 0 o un salto de escala distinta. Y en el endpoint por segundo la medida
     **no vale**, porque los dos lados predicen lo mismo cuando la granularidad ya es el
     segundo. Eso es lo que **E7** pide: un delta que las dos lecturas predicen no mide nada.
     Las dos pasadas anteriores tampoco bastaban: `reset` valía `1` en tres muestras
     separadas 8,6 s y 21,6 s, y ese `1` explica igual «queda un segundo» que «la longitud de
     la ventana escrita en su unidad de granularidad».
  2. **El color de `rate_request_activity_general`, que sube a 🟢.** La ampliación **D-024**
     de la sección E pide dos cosas: que el sondeo confirme el contador —límite, ventana y
     reposición— y que alcance la respuesta de rechazo. Las dos están. **Límite**: `limit: 2`
     y rechazo en la tercera petición. **Ventana**: la reposición llega 0,702 s después de la
     primera de la serie, lo que descarta una ventana anclada a la primera petición, sin fijar si es fija o gradual.
     **Reposición**: sondeada cada 250 ms y observada. No lo sube la cabecera leída, que por
     **D6** se registra y no se adopta; lo sube el 429.
  3. **El hueco del prefijo sobre esa ruta.** La lectura alternativa de DISC-17 —que el
     prefijo `/v3/smtp/{…}` la gobierne y su tope efectivo sean 300 por hora— queda
     descartada: el rechazo cae en la tercera petición de un segundo, no en la 301 de una
     hora. Los 7.200 por hora de su fila siguen publicados y sin comprobar.
- **Qué acota sin cerrar.** **DISC-12**, el cuerpo del 429. Medido aquí: en esta ruta no hay
  cuerpo ninguno, así que no hay `code` que contrastar con las dos listas cerradas del
  proveedor. No cierra el par. El ejemplo de [F28] trae `'x-sib-ratelimit-limit: 600'`, y
  600 no es el tope de esta fila: [F6] lo publica en otras dos —el prefijo `/v3/smtp/{…}`
  del tramo Advanced y «All other endpoints» del Extended—, sin decir de cuál sale el
  ejemplo. El blog describe **otro bucket**, y cuál no se sabe. Por **E5**: acotada, no
  cerrada.
- **Qué confirma de paso.** El bucket del rechazo es **de la fila**, no del prefijo ni de la
  cuenta: las dos rutas de control, leídas después del rechazo y antes de la reposición,
  devuelven `200`. Y **[F28] acierta en una**: dice que Brevo no usa `Retry-After` y usa
  cabeceras propias, y el 429 medido no trae `Retry-After` y sí las tres suyas.
- **Redacción.** El volcado sustituye la clave por una marca y cualquier dirección de correo
  por `<CORREO_REDACTADO>`; el `429` no trae cuerpo que redactar.

## [E4] Sondeo empírico — el caudal se cuenta por cuenta, no por clave (escalón 3, sin envíos)

- **Fecha:** 2026-09-17, 22:49 UTC · **Ejecutado por:** el agente en la máquina Linux del
  autor, con las **dos** claves de la misma cuenta que define `~/.config/tfm/.env` (D-046).
- **Comando:** `bash 05_salida/_herramientas/probe_brevo_a_caudal_por_clave.sh`
- **Evidencia:** `evidencias/probe_brevo_a_caudal_por_clave_2026-09-17_224916.json`
- **Coste: 0 envíos.** Seis `GET /v3/account`, sin `POST` y sin cuerpo de correo, así que no
  hay destinatario que comprobar contra la lista blanca. El sondeo aborta si alguna ruta es
  el endpoint de envío, y aborta también si las dos claves resultan ser la misma cadena.
- **La pregunta era Q-A4**, el hueco 8 de `not_found`: el caudal se cuenta por cuenta o por
  clave. Hasta hoy no era medible porque el entorno solo definía una clave, y crear la
  segunda es carril rojo. El autor la creó el 2026-09-18 a las 00:27 y la dejó en el `.env`.
- **Lo medido**, alternando las dos claves sobre el mismo endpoint y leyendo
  `x-sib-ratelimit-remaining`: clave 1 → `4999`, `4998`, `4997`; **clave 2 → `4996`**;
  clave 1 → `4995`; clave 2 → `4994`. Una sola serie descendente de uno en uno, sin importar
  con qué clave se pida. El `x-sib-ratelimit-reset` acompaña, de `643` a `637`, que es la
  misma ventana corriendo.
- **Veredicto: el cubo es de la CUENTA.** Si cada clave tuviera el suyo, la segunda habría
  arrancado en `4999` con `x-sib-ratelimit-limit: 5000` mientras la primera iba por `4997`.
  El brazo de vuelta (clave 1 después de la 2, en `4995`) descarta la tercera lectura, que
  sería una reposición de ventana en medio. **Crear claves no multiplica el caudal.**
- **Lo que no mide**, y se queda en `not_found`: si la segmentación cambia por IP de origen
  o por sub-organización, que es lo que el mismo hueco planteaba y esta cuenta Free no puede
  responder. Y el `limit: 5000` de `/v3/account` vuelve a salir donde [F6] publica 100 por
  hora para *«All other endpoints»*: registrado, no adoptado, por **D6**.

---

## [E3] Sondeo empírico — la unidad de la cuota, con envío real (escalón 3, paquete B)

- **Fecha:** 2026-09-17, 21:29–21:39 UTC · **Ejecutado por:** el agente en la máquina Linux
  del autor, con la clave de `~/.config/tfm/.env` (D-046).
- **Comando:** `bash 05_salida/_herramientas/probe_brevo_b_unidad_cuota.sh` en sus fases
  `antes`, `reposo`, `enviar`, `despues` y `veredicto`.
- **Autorización.** Este sondeo **entrega correo de verdad**, así que hizo falta lo que D-046
  exige y algo más. El autor autorizó en chat borrar la **PARADA** que el preflight había puesto a
  las 15:34:52 —archivada en `evidencias/parada_brevo_2026-09-17.txt`— y nombró el
  destinatario. El sondeo usa **dos** de las tres direcciones de la lista blanca, porque con
  un solo destinatario la pregunta no se puede responder.
- **Coste: 2 destinatarios**, en una sola petición. El libro de cuentas queda en 3 de 3, que
  es el tope de la pasada. El brazo de sandbox estaba retirado por presupuesto.
- **Lo medido.** `GET /v3/account` antes: `'credits: 300'`. Control de deriva, leyendo otra
  vez sin enviar nada: `'credits: 300'`, **sin movimiento**. `POST /v3/smtp/email` con dos
  destinatarios y **sin** cabecera de sandbox: `201` con
  `'{"messageId":"<202609172130.70071717055@smtp-relay.mailin.fr>"}'` y
  `'x-sib-ratelimit-limit: 1000'`. Lectura 90 s después, repetida para confirmar que dejó de
  moverse: `'credits: 298'` las dos veces.
- **Veredicto: la cuota se descuenta por DESTINATARIO.** Par de bisección 0 en reposo y 2 en
  el envío. Cierra la unidad del CRF de toda la datasheet, que las cinco descripciones de
  `/v3/smtp/email` declaraban como *«inferencia y no literal»*.
- **Q10, saldo único: confirmado por medición.** La cuenta expone **una sola** entrada de
  correo, `'"plan":[{"type":"free","credits":300,"creditsType":"sendLimit"}]'`, y es la que se
  movió al enviar un transaccional. Lo que **no** mide es que la campaña salga de esa misma
  entrada, que sigue solo publicado.
- **Q-A2, si el envío aceptado del preflight descontó cuota: no descontó.** Aquel `201` de las
  15:34 llevaba un destinatario y el contador seguía en 300 seis horas después. Con la unidad
  ya medida, debería haber consumido 1, y la única exención presente era
  `'X-Sib-Sandbox: drop'`. **Su límite, dicho claro:** es un contraste entre dos peticiones
  separadas por horas, no un brazo controlado, así que ese lado de DISC-14 no queda medido
  limpiamente.
- **Defecto del propio instrumento, encontrado y corregido.** El script extraía DISC-09 de
  `plan[]`, donde `startDate` y `endDate` vienen `null`, y daba el ciclo por no medible con el
  dato delante: está en `planVerticals[]`. Corregido para que el registro lo guarde y el
  cálculo lo lea de cualquier lectura que lo traiga — reejecutar la fase `antes` habría
  destruido la línea base del delta.

## [E2] Sondeo empírico — caudal por lectura, sin envíos (escalón 3)

- **Fecha:** 2026-09-17, 20:50 UTC, la del volcado archivado · **Ejecutado por:** el agente en
  la máquina Linux del autor, con la clave de la cuenta Free de `~/.config/tfm/.env` (D-046).
  Una ejecución anterior, de las 19:24–19:33, escribió en la misma ruta y quedó sobrescrita
  antes del commit: sus cifras no se citan (E24).
- **Comando:** `bash 05_salida/_herramientas/probe_brevo_a_caudal_solo_lectura.sh 03_datos/apis/brevo/evidencias/probe_brevo_caudal_solo_lectura_2026-09-17.json`
- **Por qué no se usó `probe_brevo_a_caudal_cabeceras.sh`,** que era el sondeo diseñado para
  esto: sus dos POST llevan la guarda `sender_sumidero`, y el preflight [E1] midió que esa
  guarda **no rechaza** —devolvió `201`— y dejó `guarda_recomendada` en `null`. Con la guarda
  desmentida, esos dos POST pueden ser aceptados, y una aceptación gasta crédito. El sondeo de
  lectura **no nombra el endpoint de envío en ninguna línea**, con un guardián que aborta si
  una ruta es `/smtp/email` exacto o con query, probado contra los tres casos límite.
- **Coste: 0 envíos.** Cuatro peticiones GET. Buckets consumidos: dos del prefijo
  `/v3/smtp/{…}` y dos de «All other endpoints».
- **Lo medido, cabecera a cabecera:**
  - `GET /v3/smtp/emails` → `400` con `'{"code":"missing_parameter","message":"Please pass
    atleast one of the following filters: email, messageId, templateId"}'` y
    `'x-sib-ratelimit-limit: 2'`, `'x-sib-ratelimit-remaining: 1'`, `'x-sib-ratelimit-reset: 1'`.
  - `GET /v3/account` → `200` con `'x-sib-ratelimit-limit: 5000'`,
    `'x-sib-ratelimit-remaining: 4999'`, `'x-sib-ratelimit-reset: 601'`, y en el cuerpo
    `'"plan":[{"type":"free","credits":300,"creditsType":"sendLimit"}]'`,
    `'"enterprise":false'` y `'"dateTimePreferences":{"timezone":"Europe\/Madrid"...}'`.
  - `GET /v3/smtp/templates` → `200`, **sin ninguna cabecera** `x-sib-ratelimit-*`.
  - `GET /v3/senders` → `200`, **sin ninguna cabecera** `x-sib-ratelimit-*`, y el cuerpo
    confirma que el endpoint existe.
- **Qué cierra.** **DISC-17 / Q11:** el `limit: 2` de `GET /v3/smtp/emails` es el valor de su
  **fila propia** en [F6] (2 por segundo, 7.200 por hora), no los 300 por hora del prefijo
  `/v3/smtp/{…}`. La nota al pie que exime a dos rutas **sí alcanza también a esta**, o el
  prefijo no la gobierna; en cualquiera de los dos casos el valor de la datasheet es el bueno
  y la lectura alternativa de bajarlo a 300/HORA queda descartada.
- **Qué abre.** Dos cosas, y las dos se registran sin adoptar por **D6**:
  1. **[F7] queda desmentida.** Afirma que la cabecera de caudal viene *«in all responses, not
     just 429 errors»*. Medido: viene en un `400` y **no viene** en dos `200`. No va por
     éxito frente a error, va **por endpoint**.
  2. **El caudal de «All other endpoints» está medido 50× por encima de lo publicado.** [F6]
     publica 100 por hora y `GET /v3/account` devuelve `limit: 5000`. El valor conservador de
     `rate_request_other_general` no era conservador: es el que se aparta más de lo medido.
- **Redacción.** El volcado lleva la clave, las direcciones, el nombre del titular, su
  dirección postal y los identificadores de cuenta sustituidos por marcas. Comprobado: cero
  direcciones de correo en el fichero.

## [E1] Sondeo empírico — preflight de rechazo del paquete A (escalón 3)

- **Fecha:** 2026-09-17, 15:34:49–15:34:52 UTC · **Ejecutado por:** el agente en la máquina
  Linux del autor, con la clave de la cuenta Free que vive en `~/.config/tfm/.env` (D-046).
- **Comando:** `bash 05_salida/_herramientas/probe_brevo_a_preflight_rechazo.sh`. Es la
  puerta del paquete A y se ejecuta primero: comprueba que el endpoint de envío **rechaza**
  las peticiones de sonda antes de que los otros siete sondeos midan cualquier cosa.
- **Lo que se emitió:** dos peticiones `POST /v3/smtp/email`, en serie, con
  `X-Sib-Sandbox: drop` y 2,4 s entre ellas. Son **2 de los 8 casos** del sondeo, p1 y p2.
  El script abortó en p2 y escribió la PARADA de `~/.local/state/tfm/brevo_parada.txt`, así
  que p3 a p8 no se emitieron y los otros siete scripts del paquete A no se ejecutaron: los
  ocho comprueban la PARADA antes de su primera llamada y habrían salido con código 5.
- **Coste: 1 envío contabilizado, no cero.** El libro de cuentas
  (`~/.local/state/tfm/presupuesto_brevo.tsv`) anota `GASTO` de 1 destinatario en p2, con
  tope de pasada 3 y margen restante 2. Ningún buzón humano recibió nada y **ninguna
  dirección de la lista blanca se tocó**: el destinatario era `sonda-00001@example.invalid`,
  en un TLD que la RFC 2606 reserva y que no se puede delegar. Lo que el libro cuenta como
  gasto es la **aceptación**: Brevo devolvió `201` con `messageId`. Si esa aceptación
  descontó un crédito **no está medido** y no se afirma en ninguna dirección; el panel no
  puede responderlo, porque el propio modo sandbox declara `"No email logs are created in
  your Brevo account"` [F16].
- **La rama simétrica del coste, también sin medir:** si Brevo **descartó** el mensaje
  aceptado o lo **cursó** hacia un dominio sin MX. El literal de [F16] —`"No emails are sent
  to recipients"`— apunta al descarte, pero eso convierte la pregunta en una rama **no
  medida**, no en una rama inexistente. En el segundo caso sería un **rebote duro contra la
  reputación** de la cuenta Free de la que dependen las pasadas siguientes del escalón 3. Lo
  predecía el propio instrumento (`probe_brevo_a_preflight_rechazo.sh`, líneas 8-9: con
  `example.invalid`, un dominio sin MX, *«habria gastado cuota y generado un rebote»*), y
  esta pasada no lo resuelve.
- **Un cupo que sí se gastó con un intento que no envió nada.** La respuesta del caso
  **rechazado** (p1, `400`, `"sender is missing"`) ya trae `x-sib-ratelimit-limit: 1000` y
  `x-sib-ratelimit-remaining: 999`: la petición que Brevo rechazó **consumió una unidad del
  bucket de caudal**. Es una forma del patrón de F-21 **medida**, no supuesta, y hay que
  distinguirla de la que sigue abierta: si la **aceptación** descontó cuota de correo (Q-A2).
  Con dos muestras la lectura no es firme —haría falta ver el contador caer con pausas
  conocidas— y por eso no sube de color a nada.
- **Evidencia:** `evidencias/probe_brevo_a_preflight_rechazo_2026-09-17_153449.json`, que es
  el nombre que **escribe el script** y el que citan el `datasheet.yaml` y `REVISION.md`.
  Hay además una copia hecha a mano, `evidencias/probe_preflight_rechazo_2026-09-17.json`,
  idéntica byte a byte
  (`sha256 39e5a59394adac50762c5ec1a65449a4c49a875498831b7e99489565aea91593` las dos). Esa
  copia **no la mantiene ninguna herramienta**: `guarda_elegida()` solo busca el patrón
  `probe_brevo_a_preflight_rechazo_*.json`, así que una pasada nueva escribiría un
  *timestamp* nuevo y la copia se quedaría congelada sin que nada avisara. Por eso las citas
  apuntan al nombre del script. Sin claves y sin direcciones de la lista blanca.
- **Citas literales, y de dónde sale cada una.** El volcado del 2026-09-17 guarda la
  **respuesta** (`http`, `cuerpo_crudo`, `cabeceras_caudal`) y, de la petición, solo
  `bytes_peticion`. Así que las líneas de abajo se separan en dos:
  - **Sostenidas por el JSON:**
    - p1 · 196 bytes → `400` ·
      `{"code":"missing_parameter","message":"sender is missing"}`
    - p2 · 274 bytes → `201` ·
      `{"messageId":"<202609171534.72501669544@smtp-relay.mailin.fr>"}`
    - Las **dos** respuestas traen las tres cabeceras de caudal:
      `x-sib-ratelimit-limit: 1000` · `x-sib-ratelimit-remaining: 999` ·
      `x-sib-ratelimit-reset: 1`
  - **Del cuerpo de la petición, reconstruidas desde el script** y **no registradas en el
    JSON de ese día**: el remitente `sonda-remitente@example.invalid`, el destinatario
    `sonda-00001@example.invalid` y la cabecera `X-Sib-Sandbox: drop`. Se leen en
    `05_salida/_herramientas/probe_brevo_a_preflight_rechazo.sh` —`tos()` y la llamada de
    `llamar_envio()`—, que no está en `evidencias/` ni lleva huella. La causa no era la
    sobre-redacción que este mismo bloque documenta: **el instrumento nunca escribía la
    petición**. Arreglado el 2026-09-17 (ver la reserva sobre el instrumento), así que el
    volcado de la siguiente pasada sí las traerá; el de esta, no.
- **Qué cierra, que son las dos cosas que este sondeo venía a decidir:**
  1. **Brevo no rechaza la petición del sumidero: la acepta.** Un remitente sin verificar en
     un dominio inexistente, un destinatario que no puede recibir y la cabecera de sandbox
     no impiden el `201`. La guarda `sender_sumidero` **no se sostiene**, el paquete A deja
     de ser de coste cero y su invariante queda ROTA. Y no contradice a [F16], que dice
     `"Sandbox mode only validates the API request format"` y `"You receive a success
     response indicating the API endpoint is working correctly"`: lo que falla es la guarda,
     no la documentación.
  2. **La única guarda con vara de medir es `sender_ausente`.** Deja un 4xx explícito con
     `{code,message}` —`missing_parameter` y `"sender is missing"`—, que es lo que la
     bisección por error discriminante necesita. Un rediseño del paquete A parte de ahí, y
     antes de medir un tope tiene que medir su **precedencia** frente a la guarda.
- **Qué NO cierra:** ninguna de las diecisiete DISC. Las tres que la cabecera roza
  —DISC-01, DISC-13 y DISC-15— quedan **registradas sin adoptar** por **D6**: la cabecera
  apareció en un sondeo de rechazo y el que se diseñó para medir caudal,
  `probe_brevo_a_caudal_cabeceras.sh`, no llegó a correr. Los otros siete sondeos del
  paquete —cuenta, unidad de `reset`, caudal, destinatarios, tamaño, segmentación y cuerpo
  del 429— no emitieron ni una petición. `GET /v3/smtp/emails`, que era el cierre más
  barato de la pasada con una lectura de cabecera y cero envíos, se queda sin hacer.
- **Lo que la cabecera dice, sin que se adopte.** `x-sib-ratelimit-limit: 1000` en el
  endpoint de envío coincide con el 1.000 RPS del tramo General [F6] y no con los 6.000 por
  hora de [F13]. `remaining` volvió a **999** en la segunda respuesta pese a los 2,4 s de
  separación, que es coherente con una ventana por segundo y no con la horaria. Dos muestras
  del mismo endpoint no fijan la unidad ni el tramo: la huella de tramo se decide comparando
  los cinco topes de [F6], y aquí se ha visto uno.
- **Reserva sobre el instrumento: tres defectos, y el volcado de esta pasada los lleva
  dentro.** Los tres se arreglaron el mismo 2026-09-17, **después** de la medición, así que
  el JSON archivado sigue siendo el de un instrumento defectuoso y se cita como tal.
  1. **El coste, escrito a mano.** El resumen declara `"envios_reales": 0` en el mismo
     objeto en el que declara `"invariante_cero_envios": "ROTA"`,
     `"peticiones_aceptadas_2xx": ["p2_sender_sumidero"]` y `http 201`, mientras el libro
     anota `GASTO` de 1. **La cifra válida es la del libro: 1.** El campo estaba cableado a
     `0` en el código (`probe_brevo_a_preflight_rechazo.sh:292` de la versión que corrió), y
     lo mismo en los otros siete sondeos, así que habría dicho `0` aunque los ocho casos
     hubieran vuelto con `201`. Quien cite esta evidencia leyendo solo su primer campo
     concluye lo contrario de lo que pasó. Hoy se calcula de lo aceptado, en la unidad del
     libro, y un test lo sujeta (`test_v_ningun_sondeo_cablea_el_coste`).
  2. **La petición no se registraba.** Solo `bytes_peticion`. Por eso el remitente, el
     destinatario y `X-Sib-Sandbox: drop` no se pueden verificar contra el volcado, y la
     garantía de D-046 —ninguna dirección de la lista blanca se tocó— había que creérsela
     leyendo el script. Hoy cada caso lleva `peticion` con las cabeceras, el remitente y los
     destinatarios con su dominio.
  3. **El sumidero no llegaba al redactor.** El prefijo de entorno del resumen pasaba
     `SUMIDERO="$SUMIDERO"` cuando `SUMIDERO` es `readonly` desde la línea 133, y bash
     contesta `SUMIDERO: variable de sólo lectura`: la orden se ejecuta igual y las otras
     cuatro asignaciones llegan, pero el sumidero llega **vacío**, y entonces el redactor
     **tacha toda dirección suelta**, incluidas las sintéticas que la evidencia debería
     poder leer. Sobre-redacta, no fuga: el JSON no contiene el patrón de la clave y la
     única dirección que sobrevive es el `messageId`. En esta pasada no se perdió nada
     porque ninguno de los dos cuerpos traía direcciones del sumidero. Hoy la variable del
     prefijo se llama `SUMIDERO_RED`, que no choca con el `readonly`, y si llegara vacía el
     propio resumen lo diría en `defecto_del_instrumento`.

  Y un cuarto, en la **cabecera** del script, que no afecta al dato pero sí a quien lo
  relance: declaraba *«COSTE EN ENVIOS: 0 envios ENTREGADOS»* y *«Ninguna puede ser
  aceptada: todas llevan un defecto que Brevo tiene que rechazar»*, que es exactamente lo
  que esta medición refutó. Corregido: la cabecera y el rótulo del presupuesto declaran
  ahora lo medido, con el nombre del caso que volvió `201`.
- **Hueco que el sondeo no pudo ni intentar:** la segmentación del caudal (hueco 8) necesita
  dos claves de la misma cuenta y `~/.config/tfm/.env` solo define `BREVO_API_KEY`. Crear la
  segunda es carril rojo.

---

## [F31] Página de precios leída con el selector en EUR, en sus dos periodicidades

- **URL:** https://www.brevo.com/pricing/ — la misma de [F1], leída desde España, donde el
  selector de divisa viene en `EUR` por defecto
- **Fecha de acceso:** 2026-09-18
- **Cómo se obtuvo:** navegador propio del autor. Es el control que **E9** exige: los dos lados
  de una discrepancia de precio se leen con el selector en la misma posición. Aquí se leen
  **las dos posiciones del conmutador de facturación**, y el estado de cada lectura se
  comprobó en el atributo `aria-checked` del propio conmutador antes de anotar las cifras.
- **Citas literales, con `"Yearly (-10%)"` activo, que es como la página carga:**
  `"No Brevo logo"` `"€8.10 per month"` · `"Sales Essentials"` `"€26.08 per month"` ·
  `"Sales Advanced"` `"€53.08 per month/user"`. Planes `"€7"` tachado con `"€6"` `".33"`,
  `"€15"` con `"€13"` `".50"`, `"€499"` con `"€449"` `".08"`, y el resumen
  `"€6.33/month"` · `"€7.00 with monthly billing"`.
- **Citas literales, con `"Monthly"` activo:** `"€9.00 per month"` · `"€29.00 per month with
  1 seat included"` · `"€59.00"`. Planes `"€7"`, `"€15"`, `"€499"`, y el resumen
  `"€7.00/month"` · `"€6.33 with yearly billing"`.
- **Qué decide, y va en contra de lo que esta misma fuente dijo hace unas horas.** Las tres
  cifras de add-on con `"Monthly"` activo son **exactamente** las del panel del 17-09, que se
  capturó con `"Billed monthly"`: 9,00, 29,00 y 59,00. El panel **no es un tercer lado** de
  DISC-08: es la misma página, en la misma divisa y en la misma periodicidad. Lo que parecía
  un choque entre superficies eran **dos conmutadores en posiciones distintas**, primero el
  de divisa y después el de facturación.
- **Y el 0,90 no era una pista: era la explicación.** 8,10 / 9,00 = 0,9000 · 26,08 / 29,00 =
  0,8993 · 53,08 / 59,00 = 0,8997. El descuento que la página anuncia es `"Yearly (-10%)"`.
  Tres ítems independientes con el mismo factor no es coincidencia.
- **Lo que NO se ha medido, y por eso el par original sigue abierto:** la página en
  **dólares**. El selector de divisa no se pudo abrir con el navegador en esta pasada, así
  que el `"$10.80 per month"` de [F1] y el `"$9 per month"` de [F25] siguen enfrentados sin
  control de periodicidad. Es la lectura que cierra o abre DISC-08, y está pendiente.

## Fuentes buscadas y NO encontradas

La ausencia documentada es un dato. Cada hueco dice **dónde debería estar**.

1. **Coste de exceso (overage) por correo.** Brevo **no publica ningún precio por correo
   enviado por encima del volumen del plan**, en ninguno de los cuatro planes de pago.
   Buscado en [F1] (tarjetas, configurador y las nueve preguntas frecuentes), [F2], [F25]
   y [F26]. Lo más cercano es una negación: `"there are no additional fees"` [F1].
   **Debería estar** en el configurador, junto a cada escalón del deslizador. No es un
   descuido de la recolección: es el hallazgo que sostiene F-27.
2. **Qué ocurre al agotar el volumen mensual en un plan de pago.** Solo se documenta el
   comportamiento del Free (cola de 1.000 y descarte). Para Starter, Standard y
   Professional no se dice si se bloquea, se encola, se factura o se sube de escalón.
   **Debería estar** en [F26], que es justo el artículo sobre el exceso.
3. **Ancla de la ventana diaria del Free.** `"resets every day"` no dice ni hora ni huso.
   **Debería estar** en [F24]. Medible por panel o por sondeo de lectura.
4. **Día del reinicio de la ventana mensual.** El ancla sí está publicada (el día de
   facturación, [F25]); el día concreto no, y depende de la cuenta. Solo
   `GET /v3/account` lo expone [F12]. **Debería estar** en [F1] o [F25].
5. **Volumen y precio del plan Enterprise.** `"Custom Price"` y `"Custom number of emails
   per month"`. Tampoco se publica el volumen mínimo de entrada ni el umbral desde el que
   se accede al tramo Extended de caudal. **Debería estar** en la tarjeta Enterprise [F1].
6. **Escalón `"More"` de los tres deslizadores.** Última marca de Starter, Standard y
   Professional, sin volumen y sin precio. **Debería estar** en el configurador [F1].
7. **Activación de los tramos Advanced y Extended.** `"Available to Professional and
   Enterprise accounts"` no dice si se aplican al contratar el plan o hay que pedirlos.
   Sin eso, el caudal de Professional es 1.000 RPS o 2.000 RPS y el de Enterprise es uno
   de tres. **Debería estar** en [F6].
8. **Segmentación del caudal.** Ni [F6] ni [F7] dicen si el caudal se cuenta por cuenta,
   por clave de API, por IP de origen o por sub-organización. Sin eso no se sabe si dos
   claves suman o comparten. **Debería estar** en [F6]. **No medible el 2026-09-17:** el
   sondeo necesita dos claves de la misma cuenta y el entorno solo define una; crear la
   segunda es carril rojo.
9. **Tipo de ventana de los caudales.** No se publica si la ventana de RPS/RPH es fija o
   deslizante. El único indicio es `"expressed in the granularity unit (typically
   seconds)"` [F7], y `"typically"` no lo fija. **Debería estar** en [F6] o [F7].
10. **Tope de destinatarios de `to` sin `messageVersions`.** La única cifra publicada
    (2.000) vive dentro de la descripción de `messageVersions` [F10]. Ni la referencia ni
    las dos specs ponen `maxItems` en `to`, `cc` ni `bcc`. **Debería estar** en [F10], en
    la descripción de `to`.
11. **Reparto entre `to`, `cc` y `bcc`.** No se publica si los 2.000 se cuentan sumando
    los tres campos o solo `to`. Mismo hueco que la regla D4 resolvió en Postmark.
    **Debería estar** en [F10].
12. **`maxItems` ausente en las dos specs.** Ni [F20] ni [F21] declaran `maxItems` para
    `to`, `cc`, `bcc`, `messageVersions` ni `attachment`, pese a que la prosa de la misma
    spec cita 2.000 y 99. La spec de contactos **sí** usa `maxItems` (150 en
    `/contacts/lists/{listId}/contacts/add`), así que la omisión no es una limitación del
    formato: los topes del envío **no son verificables por máquina**.
13. **429 no declarado en el endpoint de envío.** [F20] no contiene la cadena `"429"` en
    ninguna de sus 21 rutas; [F21] solo declara 429 en cuatro rutas de `/contacts` y en
    `/transactionalSMS/sms`. `POST /v3/smtp/email`, que es el endpoint con el caudal
    publicado más alto, no lo declara en ninguna de las dos.
14. **Cabeceras `x-sib-ratelimit-*` no declaradas en las specs.** Cero ocurrencias en
    [F20] y [F21], pese a que [F7] dice que vienen en todas las respuestas.
15. **Tamaño de petición y de adjunto en la documentación de desarrollador.** Buscado en
    [F10], [F13], [F20] y [F21]: **ninguna cifra**. Las dos únicas están en el centro de
    ayuda [F27] y en la página de producto [F5], y no coinciden (DISC-16).
16. **Tope por adjunto en la vía de API.** [F27] da 4 MB **solo** en la sección de
    plantilla; la sección de API lo omite. Ningún sitio dice si aplica también por API.
17. **Concurrencia.** Ninguna página publica conexiones simultáneas, peticiones en vuelo
    ni ventana de ráfaga. Solo hay RPS y RPH. Fuera de v0.3 de todos modos.
18. **Límites del canal SMTP.** [F17] da puertos y nada más: ni conexiones simultáneas,
    ni mensajes por conexión, ni destinatarios por mensaje, ni si los RPS de la API
    alcanzan al relay. **Debería estar** en esa misma página.
19. **Tamaño máximo en entrada de correo (inbound).** **No buscado** en esta pasada:
    ninguna de las 28 páginas leídas es documentación de *inbound* y ninguna entrada [F1]
    a [F28] la recoge, así que no hay cita que sostenga ni el dato ni su ausencia. Una
    redacción anterior entrecomillaba aquí `"Estimated size of the attachment"` sin `[Fn]`,
    sin URL y sin fecha de acceso, contra **E1**; se retira hasta dar de alta la página.
20. **Número máximo de claves de API y de claves SMTP.** La documentación explica cómo
    generarlas y no dice cuántas admite una cuenta. Límite de recurso (B3) que tampoco
    aparece en [F8].
21. **Granularidad de plan de las *platform quotas*.** [F8] solo distingue `"General"` y
    `"Enterprise"`, dos tramos, frente a los tres del caudal y los cinco planes; y no dice
    a qué planes corresponde `"General"`.
22. **Cuota de envío por plan en la documentación de desarrollador.** **Ninguna** página
    de `developers.brevo.com` publica cuántos correos incluye cada plan. El volumen solo
    vive en precios y en el centro de ayuda. Confirma la premisa del encargo por los dos
    lados: la capacidad no está donde está el precio, y el volumen tampoco está donde está
    la capacidad.
23. **Retención de registros por plan.** [F1] afirma `"unlimited log retention"` y [F2]
    dice `"Customized log retention"` en los cinco planes, sin ningún periodo. Los dos
    artículos del centro de ayuda que lo cifran devolvieron 403 en esta sesión. Sin
    literal, no se anota ninguna cifra (DISC-10).
24. **Precio unitario por correo.** No se publica. Solo se deriva dividiendo precio de
    escalón entre volumen de escalón, y no es lineal ni dentro de un plan ni entre planes.
25. **Tramos intermedios de créditos prepago.** El selector publica siete paquetes [F3] y
    [F25] dice `"packs ranging from 5,000 to 1 million"`. No se publica si hay tramos
    intermedios, ni cómo conviven los créditos con el volumen mensual de un plan de pago
    (si se consumen antes o después).
26. **Estado de cuenta no aprobada.** `"Once we approve your account for sending"` [F1]
    implica un estado previo sin envío. No se publican sus topes ni el disparador de la
    aprobación. Por **D7**, un estado sin cifras **no genera alias**: va a `not_found`.
27. **Caudal real del plan Free.** El tramo General atribuye 1.000 RPS al endpoint de
    envío en los cinco planes, Free incluido. Ninguna fuente aclara si ese caudal aplica
    de verdad a una cuenta con tope de 300 correos al día, ni si el tope diario se agota
    antes de que el caudal llegue a morder. **[E1] (2026-09-17) lo roza y no lo cierra:** en
    esta cuenta Free la cabecera del endpoint de envío anuncia `x-sib-ratelimit-limit:
    1000`, un número **sin ventana declarada** que coincide con el del tramo General, en una
    cuenta con 300 correos al día de cuota. Las dos peticiones llevaban `X-Sib-Sandbox:
    drop`, y si una petición en sandbox consume el mismo bucket de caudal que una real
    tampoco está medido. Registrado sin adoptar (D6), porque el sondeo de caudal no se
    ejecutó. Y lo de «no gasta envío» ya no se da por hecho: la cabecera de sandbox no
    impidió que una petición de sonda fuese aceptada con 201.
28. **Volcado de páginas (E2).** Los markdown oficiales de `developers.brevo.com` (la
    propia documentación los sirve añadiendo `.md` a la URL) y las dos specs se guardaron
    en el scratchpad de la sesión de recolección, **no en el repo**. `help.brevo.com`
    devuelve 403 y no tiene volcado. Por **D-023** esto no bloquea el cierre, pero
    `verificar_citas.py` no podrá comprobar sin red las citas de [F24] a [F27].
29. **Validación del remitente en la petición.** Ninguna página publica si el remitente
    tiene que estar verificado —ni si su dominio tiene que existir— para que
    `POST /v3/smtp/email` acepte la petición. **Debería estar** en [F10], que describe el
    objeto `sender`, o en [F16]. **El hueco sigue ABIERTO.** Medido en [E1] (2026-09-17)
    **solo en modo sandbox y en cuenta Free**: con `X-Sib-Sandbox: drop`, un remitente en
    `example.invalid` se acepta con `201` y `messageId`, o sea que **la validación de
    formato no lo exige**. Como [F16] declara que sandbox *"only validates the API request
    format"*, esto **no decide** qué exige la ruta sin la cabecera, y la vía es repetir la
    petición sin sandbox: eso ya es paquete B. Sigue sin medirse también si esa aceptación
    descuenta crédito.

---

## Discrepancias entre fuentes

Cada una lleva las dos citas enfrentadas, la vía que la cerraría y su **efecto declarado**
(E6). El efecto es de cada entrada, no de la sección. **Once están cerradas**: DISC-03,
DISC-04, DISC-05, DISC-07, DISC-11 y DISC-16 por E5 (1), DISC-09 y DISC-14 con [E3], DISC-10
en el panel, DISC-17 con [E2] y DISC-13 con [E5]. **Seis siguen abiertas** —DISC-01, DISC-02,
DISC-06, DISC-08, DISC-12 acotada y DISC-15—, todas con la lectura conservadora puesta. La
cabecera anterior prometía que ninguna se arbitraba, y eso dejó de ser cierto el 17-09.

**Lo que la pasada del 2026-09-21 destapó, y vale más que los cierres.** Se arbitraron las
once abiertas con dos escépticos de lente distinta cada una, y **ocho volvieron como entrada
no lista por D12**. La regla es del 18-09 y estas entradas se escribieron antes: registraban
el recorte que la entrada transcribe en vez de la unidad entera con su condición dentro, y
varias llevaban **elipsis literal** —`…`— dentro de la cita. D12 la prohíbe expresamente en
los lados de una discrepancia. Una entrada no lista **no decide nada**, ni cierra ni mueve
color, así que esas ocho nunca fueron arbitrables. Eso explica la tanda del 18-09 mejor que
ninguna otra cosa: se intentó cerrar trece entradas que no estaban listas, y cayeron las
trece.

**Reescritas las nueve con su unidad entera, sobre volcados ya archivados y sin un solo
envío, tres cerraron y tres se confirmaron.** **DISC-04** cierra porque sus dos lados acotan
objetos distintos: el adjunto y el parámetro `messageVersions`. El 99 que la entrada
enfrentaba al 2.000 estaba **en la misma frase que el 2.000**. **DISC-05** y **DISC-11**
cierran porque sus lados son ausencias cruzadas, y D12 dice que una ausencia comprobada no es
literal.
Se confirmaron **DISC-02** y **DISC-06**, que estaban mal registradas pero bien abiertas, y
**DISC-08**, medido ya su cuarto add-on. Y **DISC-15 se refunda**. Su lado del blog cae porque la
palabra `Advanced` no aparece **ni una vez** en esa fuente. En su lugar entra una
contradicción **interna a [F6]**: la viñeta reserva el tramo a Professional y Enterprise, y el
distintivo `"Available in"` que encabeza la tabla de ese mismo tramo lista los cinco planes.

**Ninguno de los tres cierres mueve el semáforo, y conviene decirlo para que nadie lo
cuente como avance de color.** DISC-05 y DISC-11 no tocaban campo, porque qué respuestas
publica un endpoint no está en v0.3. Y DISC-04 sale de D11 para caer en D1 por la regla D13:
los cinco `workload.max` siguen en 🟡, por ambigüedad de alcance y no por contradicción.

**Segundo barrido del 2026-09-21, contra el libro con quince reglas más que la pasada
anterior.** Las seis que seguían abiertas —DISC-01, DISC-02, DISC-06, DISC-08, DISC-12
acotada y DISC-15— se releyeron una por una contra D11 a D16 y E7 a E15, que no existían o
no estaban completas cuando se escribieron. Ninguna se disuelve: las seis mantienen su
color y su estado, ahora con la comprobación de cada regla nueva escrita dentro de su
propia entrada. Lo que cambia es la vía de cierre, que pasa de «pendiente» a **medición
exacta y por qué no se ha hecho**: DISC-01 y DISC-02 comparten el mismo sondeo bloqueado
—`probe_brevo_a_preflight_rechazo.sh` no certificó guarda el 2026-09-17, y sin eso ningún
sondeo de carga del paquete A puede correr—, DISC-12 tiene una ruta sin probar
(`GET /v3/account`, cubo de «All other endpoints»), y DISC-06, DISC-08 y la mitad de
DISC-15 exigen contratar un plan que este TFM no compra. Ninguna de las seis se cierra
eligiendo un lado.

### DISC-01 · Caudal de `POST /v3/smtp/email`: 3.600.000 peticiones/hora o 6.000

Un factor de **600** —casi tres órdenes de magnitud— sobre el **mismo** endpoint, entre dos páginas de documentación
de desarrollador que no se mencionan la una a la otra. La guía de lotes es más
específica, pero la página de caudal es la fuente canónica declarada y **no llama
«por defecto» a su valor en ningún momento**, así que la regla **E4 no resuelve aquí**.

- **Efecto declarado:** **excluyente** por D11 · baja a 🟡 los tres `rate` del envío, que son tres definiciones de `max_power` y **no tres valores por plan**: free, starter y standard referencian una, professional dos y solo enterprise las tres.
- **A — la unidad entera de [F6] (D12): la celda con su encabezado de columna, el título de
  su tabla y lo que define sus siglas.** Título: `"General rate limits"`, seguido del
  distintivo `"Available in"` · `"Free"` · `"Starter"` · `"Standard"` · `"Professional"` ·
  `"Enterprise"`. Encabezado de columna: `"Endpoint Rate limit Requests per second"`. Celda:
  `"POST /v3/smtp/email GET /v3/smtp/blockedContacts 3,600,000 RPH 1,000 RPS"`. Definición de
  las siglas, en el aviso que gobierna las tres tablas: `"RPS (Requests per second): Maximum
  requests allowed per second"` · `"RPH (Requests per hour): Maximum requests allowed per
  hour"` · `"Some endpoints have both RPS and RPH limits. When both apply, you must respect
  both simultaneously."` Y el pie de la tabla, que existe y nunca se había registrado:
  `"*Excludes POST /v3/smtp/email and GET /v3/smtp/blockedContacts, which have dedicated
  limits."` **Ese pie no toca este par.** El asterisco cuelga de la fila `"All endpoints under
  /v3/smtp/{…}*"`, y solo dice que el cubo genérico no se come a los dos endpoints con fila
  propia. Se registra porque D12 pide la unidad entera, no porque
  decida.
- **B — la unidad entera de [F13]: la lista de seis renglones bajo su encabezado.** Encabezado
  `"Bulk sending limits"`, dentro de `"Sending limits"`. Renglones: `"Send up to 1000 email
  messages in one API call"` · `"Execute the endpoint up to 6000 times per hour (100 times per
  minute)"` · `"Maximum 2000 total recipients per API request"` · `"Maximum 99 recipients per
  message version"` · `"Individual params objects must not exceed 100 KB"` · `"Cumulative
  params across all versions must not exceed 1000 KB"`. Cierra con `"This means you can send
  up to 6,000,000 email versions per hour ."`
- **Registrada la unidad entera, el lado B se lee distinto y conviene decirlo (2026-09-21).**
  La entrada citaba juntos el `"6000 times per hour"` y el `"6,000,000 email versions per
  hour"`, **y no son la misma magnitud**. El primero son peticiones por hora. El segundo son
  versiones de correo por hora, el producto de 6.000 llamadas por hasta 1.000 versiones cada
  una. Contra el `"3,600,000 RPH"` de A —definido por la propia fuente como
  `"requests allowed per hour"`— el único comparable es el **6.000**. El factor sigue siendo
  600 y el par sigue siendo excluyente, así que el veredicto no cambia; lo que se corrige es
  que la entrada enfrentaba dos cifras con la de al lado colada dentro.
- **Efecto en la datasheet:** el `rate` del endpoint de envío se queda en 🟡 en los cinco
  planes. **Vía:** sondeo de caudal leyendo `x-sib-ratelimit-limit` sobre ese endpoint en
  modo sandbox [F7][F16] — coste cero, y devuelve el tope vigente sin forzar el 429.
- **Medición [E1] (2026-09-17), registrada sin adoptar (D6):** las dos respuestas del
  preflight traen `x-sib-ratelimit-limit: 1000` sobre ese endpoint, un número **sin ventana
  declarada** que coincide con el RPS de la cita A y no con el 6.000 por hora de la cita B.
  Emparejar ese número con la fila de A es precisamente lo que esta DISC no arbitra, así que
  la cabecera se cita cruda. Las dos peticiones iban con `X-Sib-Sandbox: drop`, y que una
  petición en sandbox consuma el mismo bucket de caudal que una real **no está medido**.
  **No decide la discrepancia:** el sondeo era de rechazo y el de caudal no se ejecutó
  (PARADA), así que `rate_request_send_general` se queda en 🟡.

- **Barrido del 2026-09-21 contra las quince reglas nuevas.** Se comprobaron una por una.
  E11 no aplica: los lados son [F6] y [F13], dos fuentes distintas, y esa regla solo abre
  discrepancias dentro de una sola página. E7 tampoco bloquea el cierre de la Datasheet: las
  dos cifras cuentan la misma magnitud —peticiones por hora sobre el mismo endpoint—, sin
  ambigüedad de qué cuenta el contador. E12 tampoco: no hay dos periodos ni dos contadores
  independientes conviviendo, hay un valor único con dos cifras incompatibles. E9 no entra,
  no hay selector de divisa ni de facturación de por medio. D14 y D15 no tocan un par de
  literales vivos como este. Ninguna regla nueva mueve el veredicto: sigue excluyente por
  D11, y los tres `rate` del envío se quedan en 🟡.
- **SIGUE ABIERTA. La medición exacta, y por qué no se ha hecho.** Cerraría una ráfaga de
  `POST /v3/smtp/email` en modo sandbox (`X-Sib-Sandbox: drop`) hasta que llegue un 429,
  leyendo `x-sib-ratelimit-limit` en la respuesta inmediatamente anterior: un tope que
  resiste alrededor de 1.000 peticiones en el mismo segundo confirma [F6], uno que se agota
  hacia las 6.000 en la misma hora confirma [F13]. Es el sondeo que prepara
  `probe_brevo_a_caudal_cabeceras.sh`, y está bloqueado porque su guarda depende de que
  `probe_brevo_a_preflight_rechazo.sh` certifique cuál de las dos guardas admisibles
  rechaza de verdad. Medido el 2026-09-17 y archivado en
  `evidencias/probe_brevo_a_preflight_rechazo_2026-09-17_153449.json`: `sender_sumidero` no
  es guarda, Brevo la aceptó con `201` y `messageId` real (`"abortado_en":
  "p2_sender_sumidero"`, `"invariante_cero_envios": "ROTA"`), y el único caso con un 4xx
  explícito, `sender_ausente`, nunca llegó a enfrentarse a un caso de tope real porque la
  PARADA cerró la pasada antes. El JSON lo dice sin rodeos: `"guarda_recomendada": null` y
  el veredicto archivado es que ninguna guarda deja ver el tope mientras esa pareja no se
  mida. Con una sola guarda candidata y su precedencia sin medir, `probe_brevo_a_tamano.sh`
  y el resto de sondeos que dependen de esa elección abortan por diseño, tal como describe
  la cabecera de ese script alrededor de su línea 61. Este barrido no ejecuta ningún sondeo.

### DISC-02 · Caudal del lote: 100 llamadas/minuto o 5

La misma pregunta que DISC-01, ahora entre la guía y el blog oficial. Los caudales
resultantes son 6.000.000 y 30.000 correos por hora: un factor de 200.

- **Efecto declarado:** **excluyente** · baja a 🟡 el mismo `rate` que DISC-01, porque el lote no es un endpoint aparte: es un modo de `POST /v3/smtp/email`, que sí lleva `rate` en los cinco planes. El fichero no le da caudal propio al modo, y **v0.3 sí tendría dónde ponerlo**: el README lista `batch` entre los casos de alias (§3.4.3). Que no se use es decisión de modelado, no carencia.
- **A — la unidad entera de [F13], la misma lista de seis renglones que DISC-01 (D12).**
  Encabezado `"Bulk sending limits"`, dentro de `"Sending limits"`. El renglón que decide es
  `"Execute the endpoint up to 6000 times per hour (100 times per minute)"`, y la lista se
  cierra con `"This means you can send up to 6,000,000 email versions per hour ."` Los otros
  cuatro renglones están transcritos en el lado B de DISC-01 y no se repiten aquí.
- **B — la unidad entera de [F28]: el párrafo completo, con su rótulo y su cierre.** `"Batch
  sending throughput: Using messageVersions (sending up to 1,000 personalized versions in a
  single API call), the batch endpoint can be called up to 5 times per minute. That gives a
  maximum throughput of 30,000 emails per hour, because you're not making 1,000 API calls,
  you're making one. A maximum of 1,000 versions per call applies."`
- **La elipsis del lado A era el motivo real por el que esta entrada no decidía
  (2026-09-21).** El `…` que llevaba dentro la cita la dejaba **no lista por D12**, y una
  entrada no lista no decide nada. Retirada la elipsis y registradas las dos unidades enteras,
  el par queda enfrentado de verdad: **100 llamadas por minuto contra 5**, sobre el mismo modo
  del mismo endpoint, sin condición que el recorte se hubiera comido en ninguno de los dos
  lados. Se comprobó: el blog repite el `5 times per minute` en su FAQ sin añadir condición, y
  ni «However» ni «If» ni mención de plan gobiernan ninguna de las dos unidades.
- **SIGUE ABIERTA, y ahora bien abierta.** No cae ninguna cita: las dos dicen lo que el
  registro les atribuye y hablan de la misma magnitud. Ninguna regla previa ordena la guía
  frente al blog. Y el esquema no aloja las dos, porque hoy el fichero no le da caudal propio
  al modo de lote. La lectura conservadora se mantiene.
- **Vía:** la misma que DISC-01.
- **Estado tras [E1] (2026-09-17):** sin datos. Ninguna petición tocó el endpoint de lote;
  el sondeo de caudal no se ejecutó por la PARADA.
- **Barrido del 2026-09-21.** Mismas comprobaciones que DISC-01, con el mismo resultado: E7,
  E11, E12, E9, D14 y D15 no tocan este par. Son dos fuentes distintas, [F13] y [F28], con
  la misma magnitud y sin ambigüedad de unidad ni de periodo. Sigue excluyente por D11 y el
  `rate` del envío se queda en 🟡.
- **SIGUE ABIERTA. La medición es la misma vía que DISC-01, con el modo de lote en vez del
  simple.** Una ráfaga de `POST /v3/smtp/email` con `messageVersions`, guarda activa,
  leyendo `x-sib-ratelimit-remaining` tras cada llamada dentro del mismo minuto: si cae a
  cero en la sexta llamada gana [F28] (5/min), si aguanta hasta cerca de la centésima gana
  [F13] (100/min). Bloqueada por el mismo defecto que DISC-01: sin guarda recomendada
  —`evidencias/probe_brevo_a_preflight_rechazo_2026-09-17_153449.json`,
  `"guarda_recomendada": null`—, ningún sondeo de este paquete discrimina guarda de tope, y
  este barrido no lo ejecuta.

### DISC-03 · Capacidad del lote: 1.000 mensajes por llamada o 2.000 destinatarios

Las dos cifras solo son compatibles si cada versión lleva **dos** destinatarios de media.
Mil versiones al máximo de 99 darían 99.000, casi cincuenta veces el tope de la
referencia. Y el titular de la guía (6.000.000 de versiones por hora) se calcula
suponiendo 1.000 versiones por llamada, que con el tope de 2.000 destinatarios no se
sostiene. Ninguna fuente menciona a la otra. Afecta directamente a `workload[].max`.

- **Efecto declarado:** **excluyente** por D11 · baja a 🟡 los cinco `workload.max: 2000` del endpoint de envío.
- **A —** [F13]: `"Send up to 1000 email messages in one API call"` y `"send up to 1000
  message versions with different recipients, content, and variables in a single call"`
- **B —** [F10], [F20] y [F21], descripción de `messageVersions`: `"Maximum total
  recipients per API request is 2000. Maximum recipients per message version is 99.
  Individual params objects must not exceed 100 KB. Cumulative params across all
  versions must not exceed 1000 KB."`
- **Vía:** sondeo por bisección en modo sandbox, con clave de idempotencia distinta por
  intento [F15][F16]. Coste cero.
- **Estado tras [E1] (2026-09-17): la vía se ha caído.** No se emitió ninguna petición, y la
  bisección que cerraba esto depende de que Brevo **rechace** la petición por la guarda:
  `probe_brevo_a_destinatarios.sh` lee del preflight la guarda recomendada, y el preflight
  devolvió `null`. Medido que `sender_sumidero` se acepta con 201, la vía de coste cero hay
  que rediseñarla sobre `sender_ausente` y medir antes su precedencia frente al tope. Es la
  pregunta **Q-A1** de `REVISION.md`.
- **La unidad entera que D12 pide, leída del volcado del 2026-09-21.** El lado A no es una
  frase suelta: es un renglón de la lista `"Bulk sending limits"`, y la lista trae **seis
  renglones seguidos**, en este orden — `"Send up to 1000 email messages in one API call"` ·
  `"Execute the endpoint up to 6000 times per hour (100 times per minute)"` · `"Maximum 2000
  total recipients per API request"` · `"Maximum 99 recipients per message version"` ·
  `"Individual params objects must not exceed 100 KB"` · `"Cumulative params across all
  versions must not exceed 1000 KB"` —, y cierra con `"This means you can send up to
  6,000,000 email versions per hour ."`
  (`evidencias/paginas/2026-09-21/developers_brevo_com_docs_batch_send_transactional_emails.txt`).
- **CERRADA el 2026-09-21 por E5, supuesto (1): las dos citas no hablan de la misma
  magnitud.** Con la unidad entera delante, el lado A cuenta **mensajes o versiones por
  llamada** y el lado B cuenta **destinatarios por petición**. Son dos topes que se cumplen a
  la vez, y **D11** exige que los literales no puedan ser ciertos a la vez sobre el mismo
  campo del mismo objeto. La prueba es que **el 2.000 del lado B está también en el lado A**:
  la misma lista de la misma página publica `"Maximum 2000 total recipients per API request"`
  tres renglones después del `"1000 email messages"`. [F13] y [F10] no se contradicen, dicen
  lo mismo con otras palabras. Lo único que chocaba era la derivación 1.000 × 99 = 99.000 que
  el encabezado de esta entrada escribía, y D12 cierra esa puerta: *«un lado que sea
  inferencia, resumen o ausencia comprobada no es literal y no dispara D11»*. La aritmética
  del encabezado tampoco se sostenía por su cuenta: 1.000 versiones a 2 destinatarios son
  2.000, que es exactamente el tope, no una incompatibilidad. **Ningún color se mueve por el
  cierre** (D11): los cinco `workload.max: 2000` siguen en 🟡, y los sigue sosteniendo
  **DISC-04**, que apunta a los mismos campos por la otra cifra.

### DISC-04 · Destinatarios cuando la petición lleva adjunto: 99 o 2.000

El centro de ayuda fija 99 sin condicionarlo al modo de envío; la referencia fija 2.000
por petición y reserva el 99 para cada versión de un lote, sin mencionar los adjuntos.
Quien tenga que escribir **un** número en `workload[].max` tiene dos y ninguna regla de
prioridad.

- **Efecto declarado:** **excluyente** por D11 · baja a 🟡 los mismos cinco `workload.max: 2000`, por la otra cifra en disputa.
- **A — la unidad entera de [F27] (D12): la frase con las dos líneas que la gobiernan.**
  Sección `"Include an attachment in your API script"`, encabezada por `"There are technical
  limitations to including an attachment in your API script:"` y subtitulada `"👤 Recipients"`.
  La frase: `"If you add an attachment in your API script, you can only send your transactional
  email to a maximum of 99 recipients."` El artículo repite la misma estructura antes, para la
  vía de plantilla, con `"If you add an attachment to your email template, you can only send
  your transactional email to a maximum of 99 recipients."`
- **B — la unidad entera de [F10], y aquí estaba lo que el recorte se comió.** Las dos cifras
  no flotan en la página: viven **dentro de la descripción del parámetro `messageVersions`**,
  que arranca `"Array of message version objects for sending customized email variants."` y
  sigue `"The templateId can be customized per version only if a global templateId is provided.
  The htmlContent and textContent can be customized per version only if at least one of these
  is present in the global parameters. Global parameters such as to (required), bcc, cc,
  replyTo, and subject can be customized per version. Maximum total recipients per API request
  is 2000. Maximum recipients per message version is 99. Individual params objects must not
  exceed 100 KB. Cumulative params across all versions must not exceed 1000 KB. See
  https://developers.brevo.com/docs/batch-send-transactional-emails for detailed usage
  instructions."`
- **CERRADA el 2026-09-21 por E5, supuesto (1): los dos lados no hablan del mismo objeto.**
  A acota **el envío con adjunto**; B acota **el envío con `messageVersions`**, y lo dice su
  propio párrafo, que es la descripción de ese parámetro y de ningún otro. Un envío con adjunto y noventa y nueve
  destinatarios, y un lote de dos mil repartidos en versiones de a noventa y nueve,
  **pueden ser ciertos a la vez**. Es justo lo que D11 exige que no pase para bajar el color. La prueba de que el recorte era el problema está en el propio lado B: su 99
  —`"per message version"`— vive en la misma frase que el 2.000. La entrada enfrentaba el 99
  de A contra el 2.000 de B como si el 99 de B no existiera.
- **El campo se queda en 🟡, y por D1, no por D11 (regla D13).** Salir de D11 devuelve a D1 y
  no asciende por defecto. El `"Maximum total recipients per API request is 2000"` dice «per
  API request», pero lo dice **dentro** del párrafo de `messageVersions`: que ese tope gobierne
  también una petición sin versiones no lo publica nadie, y darlo por hecho es inferencia. Los
  cinco `workload.max` siguen en ámbar, ahora por ambigüedad de alcance y no por contradicción.
- **Lo que no se compra con el cierre.** El tope de 99 con adjunto **sigue sin modelarse**, y
  v0.3 tendría dónde: el fichero ya usa aliases para modos de consumo. No se invoca E5 (3)
  para cerrar, porque ese supuesto exige que el esquema **exprese** las dos hoy, y hoy no lo
  hace. Queda como carencia declarada, no como discrepancia.
  La descripción del parámetro `attachment` de la misma
  página enumera las extensiones admitidas y no menciona ningún tope de destinatarios.
- **Vía:** sondeo en sandbox con y sin adjunto. Coste cero.
- **Estado tras [E1] (2026-09-17):** sin datos, por el mismo motivo que DISC-03. El 2x2 de
  99 y 100 destinatarios con y sin adjunto no se emitió, y su guarda tampoco se sostiene.

### DISC-05 · Respuestas declaradas por `POST /v3/smtp/email`

Las dos especificaciones que publica Brevo no coinciden: la troceada omite el 202 de
programación que la histórica sí declara y que la referencia renderizada muestra. No
afecta a ningún campo de capacidad, pero **descalifica a `email-api.json` como contrato
completo** del endpoint y conviene dejarlo escrito antes de citar esa spec como fuente.

- **Efecto declarado:** **no excluyente** · **campo sin valor**: el conjunto de respuestas de un endpoint no es campo de v0.3. Lo que decide es de trazabilidad —`email-api.json` no vale como contrato completo del envío— y no de color.
- **A —** [F20], `paths./smtp/email.post.responses`: únicamente `"201: Transactional
  email sent successfully"` y `"400: bad request"`
- **B —** [F29], `/smtp/email.post.responses`, sin elipsis: `"'201': description:
  Transactional email sent successfully"` y `"'202': description: Transactional email
  scheduled successfully"`; [F10] lista `"### 201"` y `"### 202"`. **La atribución se corrige
  el 2026-09-21**: la cita apuntaba a [F21], que es la consulta del 16-09 y **no está
  archivada**; el artefacto en disco es [F29], la del 18-09. Por E8 una cita que se relee
  tiene que apuntar al artefacto que se releyó.
- **CERRADA el 2026-09-21 por E5, supuesto (1). El lado A no es un literal: es una
  ausencia.** El registro le atribuía a [F20] declarar que el endpoint responde
  «únicamente» 201 y 400. Medido sobre el artefacto archivado
  `evidencias/email-api_2026-09-18.json`, la cadena `"202"` aparece **cero veces en todo el
  fichero**. Y el objeto `responses` de `/smtp/email` no lleva `default` ni ninguna frase que
  se declare completa. [F20] no afirma que el 202 no exista: **no lo menciona**. D12 lo dice
  con todas las letras —«un lado que sea inferencia, resumen o ausencia comprobada no es
  literal y no dispara D11»—, así que nunca hubo dos literales excluyentes que arbitrar.
- **Lo que se cierra es la discrepancia, no el hallazgo, y son cosas distintas.** Que
  `email-api.json` omita el 202 en sus veintiuna rutas sigue siendo cierto y sigue
  importando: **no vale como contrato completo del endpoint de envío**. Deja de ser una
  `DISC-nn` y se queda donde le corresponde, como `NOTA` de trazabilidad en el provenance
  (E1). El color no se mueve porque no había campo que mover: el conjunto de respuestas de un
  endpoint **no es campo de v0.3**, comprobado hoy contra el README de la guía, cuyo esquema
  son `capacity`, `max_power`, `plans` y `metadata` y nada más.
- **Vía:** documental; ya inclinada de hecho por [F10] + [F21] contra [F20], pero se deja
  abierta porque las tres siguen publicadas.
- **Repasada con E5 el 2026-09-18 y NO se cierra.** No cae ninguna cita —las tres fuentes
  siguen publicadas y dicen lo que el registro les atribuye—, ninguna regla del libro ordena
  una especificación frente a otra, y el esquema no aloja nada porque **el conjunto de
  respuestas no es campo de v0.3**. Dos de tres contra una no es un supuesto de cierre: es
  contar fuentes, que es justo lo que E5 prohíbe. Se queda abierta, y su consecuencia práctica
  también: `email-api.json` no vale como contrato completo del endpoint de envío.

### DISC-06 · Techo mensual del plan Standard: 500.000 o 1.000.000

Las dos citas están en **la misma página**, en dos tablas distintas, con la **misma
etiqueta de fila**. El deslizador se detiene en 500k y el centro de ayuda dice 500.000 en
dos artículos, pero eso no arbitra: la cita B sigue publicada.

- **Efecto declarado:** **excluyente** por D11 · **campo sin valor**: el techo del escalonado no se modela, porque el fichero lleva el volumen de entrada. Afecta al provenance.
- **A — la unidad entera de [F2] (D12): celda, rótulo de fila, descriptor y título del
  bloque.** Bloque `"Key features"`, subsección `"Email & SMS campaigns"`, rótulo `"Monthly
  email sends"`, descriptor `"Flexible sending options to meet your needs."`, celdas
  `"300/day Up to 100k Up to 500k Up to 10M Custom"` sobre las cinco columnas de plan.
- **B — la unidad entera de [F2], mismo fichero, otro bloque.** Bloque `"Email marketing"`,
  rótulo `"Monthly email sends"`, descriptor `"Flexible sending options to meet your needs."`,
  celdas `"300/day Up to 100k Up to 1M Up to 10M Custom"`.
- **Registradas enteras, la entrada queda LISTA y la discrepancia se confirma
  (2026-09-21).** Era lo que faltaba comprobar y no se había comprobado: que las dos filas
  midieran lo mismo. **Lo miden.** Rótulo idéntico, **descriptor idéntico palabra por
  palabra**, cinco columnas en las dos y la divergencia en la misma posición, la tercera. No
  es una fila de envíos de marketing contra otra de envíos totales: es la misma fila publicada
  dos veces con dos cifras. Excluyente por D11 sobre el mismo objeto.
- **SIGUE ABIERTA.** Ningún supuesto de E5 aplica. Las dos citas dicen lo que el registro les
  atribuye. Ninguna regla previa ordena un bloque de la página frente a otro de la misma
  página: D5 ordena panel contra página, no página contra sí misma. Y el esquema no aloja las
  dos porque no aloja ninguna, ya que el techo del escalonado no se modela. Que el deslizador se
  pare en 500k y que el centro de ayuda diga 500.000 **no arbitra**, porque por E5 una tercera
  fuente que repite una de las dos cifras es un literal repetido y no una fuente más.
- **Efecto en la datasheet:** ninguno directo —el techo del escalonado no se modela,
  porque v0.3 lleva el volumen de entrada—. Afecta al provenance.
- **Barrido del 2026-09-21.** E11 confirma la forma de esta entrada —dos bloques de la misma
  página, [F2], con el mismo rótulo de fila y lecturas que no pueden ser ciertas a la vez—
  sin cambiar el veredicto: ya estaba tratada como excluyente por D11 antes de que la regla
  se escribiera. E9 no aplica, ninguno de los dos bloques lleva selector. D14 no aplica, no
  hay ausencia de por medio: las dos cifras están publicadas y enteras. Sigue excluyente y
  campo sin valor, sin efecto en el YAML.
- **SIGUE ABIERTA. No hay sondeo de coste cero que la cierre.** El techo del escalonado no
  lo expone ningún endpoint: `GET /v3/account` da crédito y tipo de crédito de la cuenta
  propia, no el techo del plan Standard para una cuenta que no lo tiene contratado.
  Cerraría un `GET /v3/account` autenticado con una cuenta suscrita al plan Standard,
  leyendo `plan[].credits` con `creditsType: sendLimit`: un tope mensual de 500.000
  confirma el bloque «Key features» de [F2], uno de 1.000.000 confirma el bloque «Email
  marketing». Contratar el plan Standard, desde 18 USD al mes, no está autorizado por el
  presupuesto de sondeo de este TFM y no se hace aquí.

### DISC-07 · Tope mensual del plan gratuito: existe o no existe

Una página publica una cifra mensual de 9.000 correos; el centro de ayuda solo publica el
tope diario y dice expresamente que lo no usado no se arrastra, lo que hace que 9.000 no
sea alcanzable salvo enviando exactamente 300 los treinta días.

- **A —** [F5]: `"Free plan: 300 emails per day (9,000/month) — forever free, no credit
  card required"` y `"300 emails per day (9,000 emails per month)"`
- **B —** [F24]: `"The Free plan includes 300 email sends per day. The daily limit resets
  every day, and unused emails do not roll over to the next day."`
- **Efecto en la datasheet:** el Free lleva **solo** la cuota diaria. La mensual derivada
  no se modela.
- **CERRADA el 2026-09-18 por E5, supuesto (1): las dos citas no hablan de la misma
  magnitud.** [F5] publica el agregado mensual y lo escribe como lo que es, la aritmética del
  tope diario —`"300 emails per day (9,000/month)"`, con el paréntesis dentro de la misma
  frase—, y [F24] publica el mecanismo de ese tope diario y su reposición. Las dos pueden ser
  ciertas a la vez: 9.000 es exactamente 300 por treinta días, y la frase de [F24] solo dice
  que ese agregado **no se alcanza** si algún día se envía de menos. No es una contradicción
  excluyente en el sentido de **D11**, así que nunca hubo dos cifras enfrentadas para el mismo
  campo. **Ningún color cambia**: el Free ya llevaba solo la cuota diaria, en 🟢, y la mensual
  derivada sigue sin modelarse. Lo que sí se queda escrito, porque es del dominio y no del
  fichero: un tope diario sin arrastre convierte el agregado mensual publicado en una **cota
  superior inalcanzable salvo con consumo perfectamente plano**.

### DISC-08 · Precio de los add-ons

La página de precios y el centro de ayuda dan cifras distintas para **cuatro** de los
cinco add-ons que ambos cifran. El quinto, la IP dedicada, coincide ($251/año en las dos).

- **Efecto declarado:** **excluyente en dos de los cuatro add-ons**, igualadas divisa y periodicidad por **E9** el 2026-09-21 · **campo sin valor**: los add-ons no tienen campo en v0.3 (F-07), así que la contradicción no mueve ningún color. Esta línea ha cambiado dos veces y conviene decir por qué. Hasta el 18-09 decía «no excluyente», apoyada en que las cifras estaban en monedas distintas. Después declaró excluyente el par `"€9.00"` del panel contra `"€8.10"` de la página, que es un par que **esta misma entrada disuelve** unas líneas más abajo, y que además estaba en euros mientras el par abierto está en dólares.
- **A —** [F1] (moneda USD): `"No Brevo logo"` `"$10.80 per month"`; `"Sales Essentials"`
  `"$27.92 per month"`; `"Sales Advanced"` `"$58.50 per month/user"`; `"Marketing seats"`
  `"1 marketing seat included. $10.80 per month per additional seat."`
- **B —** [F25]: `"The Remove Brevo logo add-on costs $9 per month."` · `"The Sales
  Essentials package costs $31 per month."` · `"The Sales Advanced package costs $64 per
  month."` · `"Each additional marketing seat costs $9 per month."`
- **C — el panel del 2026-09-17**, con la cuenta vista desde España y en euros:
  `"Remove Brevo logo"` `"€9.00 per month"` · `"Sales packages"` `"Starting at €29.00 per
  month"` · `"Dedicated IP"` `"From €228.00 per year"`.
- **Efecto en la datasheet:** ninguno (los add-ons no van al YAML, F-07). Va al
  provenance y a `features.md`.
- **El lado C, el del panel, se DISUELVE el 2026-09-18, y costó dos lecturas equivocadas
  llegar ahí.** La acotación de la mañana decía que el panel no competía con A y B porque
  servía otra divisa. Se leyó entonces la página en euros y dio `"€8.10 per month"`, así que
  se escribió lo contrario: que en la misma divisa seguían sin coincidir, 9,00 contra 8,10.
  **También era falso.** Esa lectura llevaba el conmutador en `"Yearly (-10%)"`, que es como
  la página carga. Puesto en `"Monthly"` —y comprobado en el `aria-checked` del conmutador,
  porque el primer intento de pulsarlo no llegó a cambiarlo— la página da `"€9.00 per
  month"`, `"€29.00 per month with 1 seat included"` y `"€59.00"` [F31]: **las tres exactas
  del panel**, que se capturó con `"Billed monthly"`. El panel no es un tercer lado: es la
  misma página con los dos conmutadores en la misma posición. Por **E5 (1)** el lado C no
  habla de la misma magnitud que aquello a lo que se le enfrentaba, y cae. De aquí sale
  **E9**, y el consejo **no escribió ninguna regla de precedencia** entre panel y página,
  porque E5 lo prohíbe.
- **Lo que queda abierto es el par original, y sigue en dólares.** `"$10.80 per month"` [F1]
  contra `"$9 per month"` [F25], **sin control de periodicidad**: el selector de divisa no se
  pudo abrir en la pasada del 18-09, así que la página en dólares no se ha leído en sus dos
  conmutadores. Es una lectura pendiente, no un arbitraje. Y hay un indicio de por dónde va:
  en euros, el mismo add-on vale 9,00 al mes y 8,10 con facturación anual.
- **Lo que decía la acotación anterior, que se conserva porque explica cómo se llegó aquí.**
  El panel **no arbitra el par A/B**, porque no compite con ellos: A y B discuten cifras en
  **dólares** y el panel sirve **euros**. Lo que
  sí hace es enseñar por dónde va la divergencia: el `"€9.00"` del logo coincide en dígito
  con el `"$9"` de B y no con el `"$10.80"` de A, que es **exactamente el patrón de F-26**
  —el mismo número en dos divisas, sin conversión—. Y el `"From €228.00 per year"` de la IP
  no cuadra con el `"$251.00 per year"` que A y B comparten. Con **D5** el panel manda en
  precisión para esta cuenta y esta geografía, pero D5 no dice qué pasa cuando el panel y la
  página publican **monedas distintas**: eso no está en el libro, así que la discrepancia
  **sigue abierta** y no se adopta ninguna de las tres.
- **La lectura que E9 exigía, hecha el 2026-09-21: la página en dólares, con los dos
  conmutadores.** Era la pieza que faltaba desde el 18-09, cuando el selector de divisa no se
  pudo abrir. La página **carga en EUR y en `"Yearly (-10%)"`**, y las dos cosas se
  comprobaron en el DOM y no de vista: el conmutador es `role="switch"` con `aria-checked`, y
  el clic programático **no lo mueve**, que es la misma trampa de la pasada anterior. Volcado
  en `evidencias/paginas/2026-09-21/www_brevo_com_pricing__usd_monthly.txt`, con el estado del
  selector declarado dentro, como E9 pide.

  | Add-on | Página, USD + `"Yearly (-10%)"` | Página, USD + `"Monthly"` | Centro de ayuda [F25] |
  |---|---|---|---|
  | No Brevo logo | `'$10.80 per month'` | `'$12.00 per month'` | `'$9 per month'` |
  | Sales Essentials | `'$27.92 per month'` | `'$31.00 per month'` | `'$31 per month'` |
  | Sales Advanced | `'$58.50 per month/user'` | `'$65.00 per month/user'` | `'$64 per month'` |
  | Asiento de marketing adicional | `'$10.80 per month per additional seat'` | `'$12.00 per month per additional seat'` | `'$9 per month'` |

  **Lo que el lado A registraba era la columna anual.** Las tres cifras de [F1] —`$10.80`,
  `$27.92`, `$58.50`— son las de `"Yearly (-10%)"`, y el centro de ayuda no tiene conmutador:
  publica un precio al mes y solo uno. Se estaban enfrentando anual contra mensual, que es
  justo lo que E9 declara mal abierto.
  **Igualadas, la discrepancia no se disuelve entera: se encoge.** `Sales Essentials` da
  `$31.00` contra `$31` y **cae por E5 (1)**, con el volcado como artefacto de E8. `No Brevo
  logo` y `Sales Advanced` siguen sin coincidir, ahora ya igualados, así que esos dos quedan
  **bien abiertos por primera vez**. La IP dedicada ya coincidía en `$251` al año. **El asiento de marketing
  se midió el 2026-09-21 por la tarde, y con él la entrada queda lista.** Su fila no está en la
  pestaña `Starter` del calculador, que es la que carga por defecto: aparece al seleccionar
  `Standard`, y ese era el estado del configurador que la lectura de la mañana no reprodujo.
  Leída con los dos conmutadores y la pestaña declarados, la unidad entera es `"Marketing
  seats"` · `"Allow multiple team members to collaborate securely. Add up to 2 additional
  Marketing users."` · `"1 marketing seat included. $12.00 per month per additional seat."` en
  `Monthly`, y `"1 marketing seat included. $10.80 per month per additional seat."` en
  `Yearly (-10%)`. Volcado en
  `evidencias/paginas/2026-09-21/www_brevo_com_pricing__calculador_standard_usd.txt`.
  **Igualadas, no coincide**: `$12.00` contra los `$9 per month` de [F25]. Es el cuarto
  add-on, y queda **bien abierto** como los otros dos. El `$10.80` que [F1] tenía registrado
  es, una vez más, la columna anual.
- **NOTA (E3, evidencia de F-09): la página sirve hoy dieciséis divisas, no ocho.** A las
  ocho registradas se añaden `"MXN (Mexican Peso)"`, `"SGD (Singapore Dollar)"`, `"RON
  (Romanian New Leu)"`, `"JPY (Japanese Yen)"`, `"MYR (Malaysian Ringgit)"`, `"CLP (Chilean
  Peso)"`, `"MAD (Moroccan Dirham)"` y `"PEN (Peru Nuevo Sol)"`. Con volcado de hoy y sin
  volcado del 16-09 manda **E8**: la cita de las ocho **no cae**, se queda con sus dos fechas
  y el desajuste es evidencia de **F-09**. No debilita a **F-26**, que se apoya en que las
  cifras no son conversiones entre sí y en que ninguna divisa se declara canónica; dieciséis
  refuerzan las dos mitades.
- **Barrido del 2026-09-21 sobre la entrada ya cerrada el mismo día con su cuarto add-on.**
  E9 ya está aplicada —es el caso que la originó— y no hay nada nuevo que igualar. E11 no
  aplica: los tres pares vivos son [F1] contra [F25], dos fuentes distintas, y no una
  contradicción interna de una sola página. D14 y D15 no tocan citas de precio. Ninguna
  regla nueva mueve nada: `No Brevo logo`, `Sales Advanced` y `Marketing seats` siguen
  abiertos, y `campo sin valor` sigue sin efecto en el YAML.
- **SIGUE ABIERTA en los tres, y no hay sondeo que los cierre.** Ningún endpoint de la
  Email API expone el precio de un add-on: `GET /v3/account` da crédito y tipo, no
  tarifario. La única medición posible es el importe real que el checkout del panel
  muestra al confirmar la compra de cada add-on con una cuenta de pago, o una respuesta
  escrita de soporte de Brevo que cite el precio vigente. Ninguna de las dos es un sondeo
  de escalón 3 contra la API, las dos exigen gasto o gestión fuera del alcance de este
  barrido, y no se ejecutan aquí.
- **Cerrada por D17 (D-068, 2026-10-18).** El pricing define la verdad, y aquí la página de
  precios publica los cuatro add-ons. Igualadas divisa y periodicidad por **E9** —USD y
  `"Monthly"`, que es la periodicidad que publica el centro de ayuda—, valen las cifras de la
  página. Los `$9`/`$64` de [F25] quedan como **incoherencia del pricing**:

  | Add-on | Valor (página, USD + `"Monthly"`) | Incoherencia del pricing [F25] |
  |---|---|---|
  | No Brevo logo | `'$12.00 per month'` | `'$9 per month'` |
  | Sales Advanced | `'$65.00 per month/user'` | `'$64 per month'` |
  | Asiento de marketing adicional | `'$12.00 per month per additional seat'` (pestaña `Standard`) | `'$9 per month'` |

  `Sales Essentials` ya había caído por E5 (1) el 2026-09-21 y la IP dedicada coincidía. Los
  volcados son los de E9: `www_brevo_com_pricing__usd_monthly.txt` y
  `www_brevo_com_pricing__calculador_standard_usd.txt`.
- **Efecto declarado (2026-10-18):** excluyente (D11) · cerrada por D17 · campo sin valor; los
  add-ons no tienen campo en v0.3 (F-07). Cambian el provenance y `features.md`.

### DISC-09 · Ancla del ciclo de facturación: periodo fijo de 30 días o día de alta

Importa porque decide si el día del reinicio es conocido y porque cambia la curva de
capacidad a doce meses. Las dos lecturas son de ciclo de facturación, así que
`fixed_billing_cycle` se sostiene en las dos; lo que quedaba abierto era **el día**.

**RESUELTA midiendo el 2026-09-17 ([E3]), y las dos lecturas caben a la vez.** `GET
/v3/account` devuelve el periodo en `planVerticals[]`, no en `plan[]`, que es donde el sondeo
lo buscaba y lo daba por ausente: `'"startDate":"1789552093"'` y `'"endDate":"1792144093"'`,
que son **2026-09-16T09:48:13Z** y **2026-10-16T09:48:13Z**, treinta días exactos. Así que el
periodo es de 30 días **y** tiene día y hora conocidos, anclados al alta y no al mes natural.
La cuenta medida es Free, así que lo que no se mide es si un plan de pago ancla en el mismo
sitio.

- **A —** [F1], preguntas frecuentes, `"How can I pay?"`: `"If you subscribe to a monthly
  plan, the subscription period is 30 days and charges are processed at the beginning of
  each period."`
- **B —** [F25]: `"With a monthly subscription, you are charged each month on your billing
  date. Your credits are renewed each month on your billing date."` y `"if your yearly
  plan starts on the 12th, your credits will be topped up on the 12th of each month"`
- **Vía:** `GET /v3/account` devuelve `startDate` y `endDate` del periodo en Unix [F12].
  Sondeo de lectura, coste cero.
- **Estado tras [E1] (2026-09-17):** sin datos, `probe_brevo_a_cuenta.sh` no se ejecutó. La
  observación de panel del mismo día añade algo que no depende del sondeo: esta cuenta está
  en Free **sin suscripción**, así que no hay fecha de facturación que leer en ella
  (`evidencias/panel_brevo_2026-09-17.md`).

### DISC-10 · Retención de registros: ilimitada o configurable

No es una contradicción numérica, porque ninguna de las dos publica un periodo, pero
`"unlimited"` y `"control how long data is stored"` no describen la misma política, y la
matriz funcional necesita saber cuál gobierna.

- **A —** [F1]: `"All Brevo plans give you access to transactional email features,
  including RESTful APIs, SMTP, outbound webhooks, unlimited log retention, and more."`
- **B —** [F2], fila `"Customized log retention"`: `"Control how long data is stored to
  meet GDPR and privacy requirements."`, con marca de verificación en los cinco planes
- **Efecto en la datasheet:** ninguno (política, no cuota — regla B4).
- **RESUELTA en el panel el 2026-09-18 ([F30]): manda B, y con cifra.** La retención no es
  ilimitada ni la fija el plan: **la fija el cliente entre 1 y 24 meses**, y puede aplicarla
  a todos los remitentes o solo a algunos. El control es un `input type="number"` con
  `min="1"` y `max="24"`, hoy en `1`, y el texto de la página lo dice sin ambigüedad:
  *"Transactional logs are stored only for a limited time. Once the retention period ends,
  they will be deleted automatically."* El `"unlimited log retention"` de [F1] **no describe
  una duración**, así que como dato de retención queda desmentido. **El fundamento es E5 (1)**
  (corregido el 2026-10-18; antes decía D5): los dos lados no hablan de la misma magnitud, porque
  `"unlimited"` no publica una duración y el panel sí. D17 no actúa: la página de precios no
  publica un periodo contra el que enfrentar el del panel. Por **B4** el fichero no cambia,
  porque la retención es política y no cuota. Lo que esta cuenta no puede decir es si el techo de 24
  meses se mueve con el plan. **Cierra también PI-E03**, que llevaba sin respuesta por no
  existir periodo publicado.

### DISC-11 · Qué códigos HTTP puede devolver la API

La misma pregunta con dos respuestas incompatibles: la guía de conceptos incluye 429 y
omite 422; la especificación oficial incluye 422 y omite 429.

- **Efecto declarado:** **no excluyente** · **campo sin valor**: qué códigos HTTP publica la API no es campo de v0.3. Decide qué spec vale como contrato, no un color.
- **A — la unidad entera de [F9] (D12): la tabla con su título y su encabezado.** Título
  `"HTTP status codes"`. Encabezado `"Code | Status | Description"`. Doce filas: `"200 | OK |
  Request succeeded"` · `"201 | Created | Resource created successfully"` · `"202 | Accepted |
  Request accepted for processing"` · `"204 | No Content | Resource updated or deleted
  successfully"` · `"400 | Bad Request | Invalid request. Check error details in response
  body"` · `"401 | Unauthorized | Invalid or missing API key"` · `"402 | Payment Required |
  Account requires activation or additional credits"` · `"403 | Forbidden | Insufficient
  permissions for this resource"` · `"404 | Not Found | Endpoint or resource does not exist"` ·
  `"405 | Method Not Allowed | HTTP method not supported for this endpoint"` · `"406 | Not
  Acceptable | Content-Type must be application/json"` · `"429 | Too Many Requests | Rate limit
  exceeded. See rate limits"`. Sin fila 422. **La cita anterior no era literal**: escribía
  `"See [rate limits](/docs/api-limits)"`, con una sintaxis de enlace que el volcado no tiene.
- **B — la unidad entera de [F29], `info.description`.** Rótulo `"**Possible responses**"`,
  encabezado `"| Code | Message |"`, doce filas: `"| 200 | OK. Successful Request |"` · `"| 201
  | OK. Successful Creation |"` · `"| 202 | OK. Request accepted |"` · `"| 204 | OK. Successful
  Update/Deletion |"` · `"| 400 | Error. Bad Request |"` · `"| 401 | Error. Authentication
  Needed |"` · `"| 402 | Error. Not enough credit, plan upgrade needed |"` · `"| 403 | Error.
  Permission denied |"` · `"| 404 | Error. Object does not exist |"` · `"| 405 | Error. Method
  not allowed |"` · `"| 406 | Error. Not Acceptable |"` · `"| 422 | Error. Unprocessable Entity
  |"`. Sin fila 429. Atribución corregida de [F21] a [F29] por el mismo motivo que DISC-05.
- **CERRADA el 2026-09-21 por E5, supuesto (1). Los dos lados son ausencias cruzadas.**
  Registradas enteras, las dos tablas tienen **doce filas** y **ninguna de las dos se declara
  exhaustiva**: no hay «all», ni «complete list», ni «the following are the only». Que una
  omita el 422 y la otra el 429 no es que cada una niegue lo que la otra afirma; es que cada
  una lista lo suyo. El registro les atribuía una afirmación de exclusividad que ninguna hace,
  y por D12 una ausencia comprobada no es literal. **Efecto sobre el color: ninguno**, y no
  porque la discrepancia cierre, sino porque el campo no existe: qué códigos publica la API no
  está en v0.3.

### DISC-12 · Código de error del 429

El blog publica `too_many_requests` como valor del campo `code` del cuerpo, y ese valor
**no existe** ni en la tabla de códigos de la documentación ni en el `enum` del OpenAPI,
que son las dos listas cerradas que el proveedor publica.

- **A — la unidad entera de [F28] (D12), con la frase que la introduce, que es la que decide
  qué clase de enunciado es.** `"A typical 429 response looks like this:"`, y a continuación el
  bloque: `"HTTP/1.1 429 Too Many Requests"` · `"x-sib-ratelimit-limit: 600"` ·
  `"x-sib-ratelimit-remaining: 0"` · `"x-sib-ratelimit-reset: 45"` · `"Content-Type:
  application/json"` · `"{"` · `"\"code\": \"too_many_requests\","` · `"\"message\": \"API call
  rate limit exceeded\""` · `"}"`. Cierra con `"Don't hardcode a sleep value. Read
  x-sib-ratelimit-reset for the exact wait time in seconds."`
- **Lo que el rótulo cambia, y no es poco.** Que el bloque se presente como una respuesta
  típica lo convierte en **ilustración**, no una declaración normativa: el blog no afirma que `too_many_requests`
  esté en la lista publicada de códigos, enseña una respuesta de ejemplo. Eso no basta para
  cerrar —un ejemplo publicado sigue siendo texto literal del proveedor— pero explica por qué
  el par nunca se dejó arbitrar, y se registra porque D12 obliga a traer la condición que el
  recorte se comió.
- **B —** [F29], `components.responses.errorModel` (atribución corregida de [F21] el
  2026-09-21 por E8: el artefacto archivado es el del 18-09). **El enum entero, sin elipsis,
  son treinta y seis valores:** `"invalid_parameter"` · `"missing_parameter"` ·
  `"out_of_range"` · `"campaign_processing"` · `"campaign_sent"` · `"document_not_found"` ·
  `"not_enough_credits"` · `"permission_denied"` · `"duplicate_parameter"` ·
  `"duplicate_request"` · `"method_not_allowed"` · `"unauthorized"` ·
  `"account_under_validation"` · `"not_acceptable"` · `"bad_request"` ·
  `"unprocessable_entity"` · `"Domain does not exist"` · `"Contact email not found"` ·
  `"Attribute not found"` · `"Category id not found"` · `"Invalid parameters passed"` ·
  `"Record(s) for identifier not found"` · `"Returned when query params are invalid"` ·
  `"Returned when invalid data posted"` · `"Feed not found"` · `"Campaign ID not found"` ·
  `"api-key not found"` · `"DMARC policy requires domain authentication"` · `"DNS records not
  properly configured"` · `"Invalid OTP code provided"` · `"OTP code has expired"` · `"Domain
  already exists in your account"` · `"The sum of all IP weights must equal 100"` ·
  `"Authentication failed"` · `"Insufficient credits"` · `"Request already processed"`, con
  `"example: method_not_allowed"` y `"type: string"`.
- **Registrado entero, el lado B se parece bastante menos a una lista cerrada (2026-09-21).**
  De los treinta y seis valores, dieciséis son códigos de máquina en minúscula con guion bajo
  y **veinte son frases de persona** —`"Domain does not exist"`, `"The sum of all IP weights
  must equal 100"`, `"Authentication failed"`—, que no son valores plausibles de un campo
  `code`. Un `enum` con veinte descripciones dentro es un saco, no un contrato. Eso **estrecha
  y no decide**: no prueba que `too_many_requests` sea válido, pero sí que la ausencia en esta
  lista pesa menos de lo que la entrada le suponía. Por E5 sigue siendo evidencia que estrecha
  sin decidir, así que la entrada se mantiene **acotada**, no cerrada, con lo acotado escrito
- **Vía:** un sondeo que alcance el 429 lo resuelve de un golpe. En sandbox, coste cero.
- **Efecto declarado:** no excluyente · sin efecto sobre el color — el cuerpo de un error no
  es campo de v0.3.
- **ACOTADA midiendo el 2026-09-18 ([E5]), y no cerrada.** El 429 se alcanzó en la fila propia
  de `GET /v3/smtp/emails` —tres peticiones en el mismo segundo— y **llega sin cuerpo**:
  `'content-length: 0'`, sin `Content-Type`, sin `Retry-After` y con **0 bytes** descargados,
  archivado en `evidencias/probe_brevo_a_ventana_y_reset_2026-09-18_202618.json`. Ahí no hay
  `code` que contrastar. Lo que **no** decide es el par. El ejemplo de [F28] trae
  `'x-sib-ratelimit-limit: 600'`, y ese 600 no es el tope de esta fila. [F6] lo publica en
  otras dos: el prefijo `/v3/smtp/{…}` del tramo Advanced y «All other endpoints» del
  Extended. El blog no dice de cuál sale su ejemplo. Describe **otro bucket**, y cuál no se
  sabe. Por **E5**, evidencia que estrecha sin decidir: acotada, con lo acotado escrito.
- **Estado tras [E1] (2026-09-17):** sin datos. `probe_brevo_a_cuerpo_429.sh` era el último
  del paquete y no se ejecutó. Aviso para quien lo retome: su cabecera exige que el paquete
  B esté corrido **antes**, porque agota durante hasta 3.600 s el bucket de `"All other
  endpoints"` (100 por hora) donde vive `GET /v3/account`, que es la medición entera del
  sondeo que sí gasta correo. Ese orden no lo impone ninguna guarda ejecutable, solo un
  comentario.
- **Barrido del 2026-09-21.** E8 ya se aplicó al corregir la atribución de [F21] a [F29] el
  mismo día; no hay cita nueva que tumbar. E11 no aplica: el lado A es un ejemplo del blog y
  el B el enum de la especificación, dos fuentes distintas, no una contradicción interna. E12
  no aplica, no hay periodo en disputa. Sigue acotada por E5, no cerrada: el 429 medido no
  trae cuerpo y no decide entre las dos listas.
- **SIGUE ACOTADA. La medición que faltaba probar es un 429 en una ruta distinta.** El 429
  del 2026-09-18 se forzó sobre la fila propia de `GET /v3/smtp/emails`, con RPS 2, y volvió
  con `content-length: 0`. Queda sin probar el cubo «All other endpoints» (100 RPH), donde
  vive `GET /v3/account`: más de cien llamadas a ese endpoint dentro de la misma hora, con la
  misma clave, es sondeo de coste cero —son lecturas, no envíos, y no dependen de la guarda
  ni del estado de aprobación de la cuenta—. Si el 429 de ese cubo trae cuerpo con `"code":
  "too_many_requests"`, gana el lado A; si vuelve igual de vacío, la ausencia de cuerpo se
  confirma como patrón del proveedor y no del endpoint, lo que estrecha sin decidir todavía.
  No se ejecuta en este barrido.

### DISC-13 · Unidad de `x-sib-ratelimit-reset`

La guía la deja indeterminada y el blog la afirma. Para un endpoint declarado solo en RPH
la diferencia es de un factor 3.600, así que el consumidor no puede derivar un valor
único.

- **A —** [F7]: `"x-sib-ratelimit-reset | Time remaining until the rate limit resets,
  expressed in the granularity unit (typically seconds)"`
- **B —** [F28]: `"x-sib-ratelimit-reset | Seconds until the rate limit counter resets"`
- **Vía:** leer la cabecera en dos endpoints de granularidad distinta (uno RPS, uno solo
  RPH). Coste cero.
- **Efecto declarado:** excluyente por D11 mientras estuvo abierta · **cerrada el 2026-09-18**,
  y el campo que gobernaba, `rate_request_activity_general`, sube a 🟢 por la ampliación D-024.
- **CERRADA midiendo el 2026-09-18 ([E5]): la unidad es el segundo, y se mide donde la
  discrepancia mordía.** El factor 3.600 solo es observable en un endpoint declarado **por
  hora**, y hay uno que emite la cabecera: `GET /v3/account`, que [F6] mete en `"All other
  endpoints | 100 RPH | -"`. Dos lecturas separadas por una pausa conocida dan
  `'x-sib-ratelimit-reset: 2021'` y `'2009'` en **12,306 s**: baja **12**. El lado B —`"Seconds
  until the rate limit counter resets"`— predice esa caída. Una cifra escrita en la unidad de
  granularidad del endpoint, que es la lectura que [F7] deja abierta, predeciría 0 o un salto
  de otra escala. Manda B, y el `"typically seconds"` de [F7] queda confirmado también fuera
  de su caso típico.
  **Lo que NO cierra esta discrepancia, y conviene decirlo porque lo intentó una pasada
  anterior:** el endpoint por segundo. Allí los dos lados predicen el mismo delta, porque la
  granularidad ya es el segundo, y **E7** avisa de que un delta que las dos lecturas predicen
  no mide nada. Su `'reset: 1'` constante explica igual «queda un segundo» que «la longitud de
  la ventana en su unidad de granularidad». `GET /v3/smtp/templates` y `GET /v3/senders`, los
  otros dos horarios, no sirven por otro motivo: no devuelven ninguna cabecera de caudal.
- **Medición [E1] (2026-09-17), registrada sin adoptar (D6):** `x-sib-ratelimit-reset: 1` en
  las dos respuestas, y `remaining` de vuelta a 999 en la segunda pese a los 2,4 s de
  separación. Eso **acota la ventana por debajo de 2,4 s** y es coherente con que la
  cabecera describa la ventana por segundo del endpoint de envío y no la horaria, pero **no
  fija la unidad** ni la ventana: haría falta ver la cifra caer con pausas conocidas, que es
  lo que mide `probe_brevo_a_unidad_reset.sh`, y ese no corrió. Las dos respuestas son de
  peticiones con `X-Sib-Sandbox: drop`, y si una petición en sandbox comparte bucket con una
  real tampoco se ha medido.

### DISC-14 · Qué devuelve el endpoint de consulta de cuota

El blog afirma que `GET /v3/account` devuelve los límites vigentes y el consumo; el
esquema de respuesta de la referencia solo publica créditos restantes y fechas del plan,
sin ningún campo de límite ni de consumo.

**RESUELTA midiendo el 2026-09-17 ([E3]): manda B.** Los campos que el endpoint devuelve de
verdad en esta cuenta son `address`, `companyName`, `dateTimePreferences`, `email`,
`enterprise`, `firstName`, `language`, `lastName`, `organization_id`, `plan`, `planVerticals`,
`relay` y `user_id`. Ninguno es de límite ni de consumo: la búsqueda por `limit|usage|used|
consum|quota` sobre las claves devuelve **vacío**. Lo único aprovechable para capacidad es
`plan[].credits`, que es saldo restante y no un límite, y `planVerticals[]`, que trae el
periodo (DISC-09). La frase del blog es más de lo que el endpoint da.

- **A —** [F28]: `"The GET /v3/account endpoint returns your current plan limits and API
  usage. Query it at the start of any bulk send job and gate accordingly"`
- **B —** [F12]: `"plan (list of object, required) — Information about your plans and
  credits · credits (float, required) — Remaining credits of the user · creditsType
  (enum, required) … Allowed values: sendLimit · type (enum, required) … Allowed
  values: payAsYouGo, free, subscription, sms · endDate … startDate"`
- **Vía:** una sola llamada de lectura la cierra. Coste cero.
- **Cronología de las dos pasadas, porque las dos están anotadas y decían cosas distintas.**
  Tras **[E1]** la entrada quedó sin datos: `probe_brevo_a_cuenta.sh` no llegó a ejecutarse
  por la PARADA, y así se escribió. La llamada se hizo después, en **[E3]**, y es la que
  cierra: lo que manda es el párrafo de arriba. Esta línea sustituye a la de «sin datos», que
  contradecía la resolución sin que el lector pudiera saber cuál de las dos era la vigente.

### DISC-15 · A qué planes alcanza el tramo Advanced

La misma página se contradice a sí misma: su viñeta de entrada reserva el tramo a Professional
y Enterprise, y el distintivo que encabeza la tabla de ese tramo lo declara disponible en los
cinco planes. Es la discrepancia que deja el caudal de Professional sin cerrar. **Hasta el
2026-09-21 el lado contrario era el blog**, y ahí estaba mal puesta: el blog no nombra el tramo
ni una vez.

- **Efecto declarado:** **excluyente sobre la atribución**, no sobre el valor · por D11 baja el color de la atribución mientras no se sepa a qué planes alcanza el tramo Advanced. El ámbar de esos `rate` lo reclaman **dos** entradas, esta y DISC-01. El comentario del YAML nombraba solo a DISC-01 en las tres líneas; desde el 2026-09-21 la de `rate_request_send_advanced` nombra las dos, y las de 1.000 y 6.000 siguen nombrando solo a DISC-01.
- **A — la unidad entera de [F6], no la viñeta suelta (D12).** La viñeta vive en una lista de
  tres que un párrafo introduce, y el antecedente entra porque sin él la viñeta no dice de qué
  habla: `"The API provides three rate limit tiers:"` · `"General rate limits: Standard limits
  for most use cases. Available to all account types (Free, Starter, Standard, Professional,
  and Enterprise)."` · `"Advanced rate limits: Higher limits for advanced use cases. Available
  to Professional and Enterprise accounts."` · `"Extended rate limits: Maximum limits for
  high-throughput integrations. Available to Enterprise accounts."`
- **B — la unidad entera de [F28].** `"GET /v3/smtp/emails allows 2 requests per second
  (7,200/hr) on self-service plans and 3 requests per second (10,800/hr) on Enterprise."` El
  párrafo no cuelga de ninguna condición: no hay «However» ni «If» ni mención de plan que el
  recorte se comiera. La unidad es la frase, y es toda.
- **El lado B CAE el 2026-09-21 por E5 (1), y con él la discrepancia tal como estaba escrita.**
  El registro le atribuía a [F28] una afirmación sobre a qué planes alcanza **el tramo
  Advanced**. Medido sobre el volcado archivado
  `evidencias/paginas/2026-09-21/www_brevo_com_blog_api_rate_limiting.txt`, la palabra
  `Advanced` aparece **cero veces en todo el blog**. [F28] no habla del tramo: habla del caudal
  de un endpoint concreto bajo las etiquetas `"self-service"` y `"Enterprise"`, que son otra
  partición y de otro objeto. Leer «self-service excluye a Professional» es **inferencia**, y
  por D12 una inferencia no es literal y no dispara D11. E8 queda cubierta: el artefacto está
  archivado y la relectura es sobre él.
- **Pero la discrepancia no muere: aparece un segundo literal MEJOR, y dentro de [F6].** La
  unidad de A es la viñeta; la unidad que gobierna **la tabla de la que salen los números** es
  su encabezado con el distintivo que lo sigue, y eso D12 lo pide expresamente cuando la fuente
  no es prosa. Bajo `"Advanced rate limits"` la página publica `"Available in"` · `"Free"` ·
  `"Starter"` · `"Standard"` · `"Professional"` · `"Enterprise"` — **los cinco planes**. Lo
  mismo bajo `"Extended rate limits"`, que la viñeta reserva a Enterprise. Contra
  `"Available to Professional and Enterprise accounts."` de la viñeta, es **excluyente sobre el
  mismo objeto**: a qué planes alcanza el tramo Advanced.
- **Y se comprobó que el distintivo afirma, no filtra**, porque de eso depende que sea un
  literal. En el DOM es un `DIV` estático inmediatamente posterior a cada `<h2>` de tramo, y
  cada nombre de plan es un `<a href="https://www.brevo.com/pricing/">`: **sin `role="tab"`, sin
  `aria-selected`, sin `aria-pressed`, sin `<button>`**, y no cambia la tabla que lo sigue. Un
  control habría sido texto de interfaz y no una afirmación. Archivado en
  `evidencias/paginas/2026-09-21/developers_brevo_com_docs_api_limits__distintivos_tramo.txt`,
  con esa naturaleza declarada dentro, porque el volcado plano del mismo día no la distingue.
- **La entrada se REFUNDA, no se cierra ni se renumera (2026-09-21).** El sujeto es el mismo
  —a qué planes alcanza el tramo Advanced— y D12 manda reescribir la entrada con la unidad
  entera donde el veredicto cambie. Lo que cambia son los lados: se va [F28] y entra la
  contradicción interna de [F6]. **El color no se mueve:** sigue 🟡 por D11 sobre la atribución,
  y ahora con un respaldo más fuerte, porque las dos mitades del par son de la fuente canónica.
- **Efecto en la datasheet:** los tres `rate` modelados se quedan en 🟡 en los cinco
  planes. **Vía:** `x-sib-ratelimit-limit` con una cuenta de cada plan; con una sola
  cuenta solo se cierra su propio tramo.
- **Medición [E1] (2026-09-17), registrada sin adoptar (D6):** el 1.000 leído en el endpoint
  de envío de esta cuenta Free encaja con el tramo General y no con Advanced (2.000) ni
  Extended (6.000). No cierra nada: la huella de tramo se decide comparando los **cinco**
  topes de [F6] y solo se ha visto uno, y los otros cuatro planes no se han contratado. Las
  dos respuestas son de peticiones con `X-Sib-Sandbox: drop`, y si sandbox comparte bucket
  de caudal con la ruta normal no está medido.
- **Barrido del 2026-09-21 sobre la entrada refundada el mismo día.** Es precisamente el
  caso que fija E11 —contradicción dentro de [F6], viñeta contra distintivo de tabla— y ya
  está escrita con esa forma; nada que corregir. D14 no aplica, no hay ausencia de por
  medio, las dos mitades publican plan a plan. E9 no aplica, no hay selector de precio.
  Sigue en D11 sobre la atribución, con los tres `rate` en 🟡 en los cinco planes.
- **SIGUE ABIERTA. La vía ya escrita es correcta y hay que decir por qué no se ha andado.**
  `x-sib-ratelimit-limit` sobre `POST /v3/smtp/email` en sandbox, leído con una cuenta de
  cada plan, es de coste cero por sí solo. Pero antes exige la misma guarda que DISC-01 y
  DISC-02 tienen bloqueada —`evidencias/probe_brevo_a_preflight_rechazo_2026-09-17_153449.json`,
  `"guarda_recomendada": null`—, así que ni siquiera el tramo de esta cuenta Free se puede
  reconfirmar hoy sin ese preflight resuelto. Y aunque se resolviera, la atribución de
  Professional y Enterprise exige contratar esos planes, desde 499 USD al mes: gasto fuera
  del presupuesto de sondeo de este TFM. La única cuenta disponible ya dejó su lectura,
  registrada sin adoptar por D6 en [E1]: 1.000 RPS, que encaja con General y no decide nada
  sobre a qué planes alcanza Advanced.

### DISC-16 · Tamaño máximo por correo transaccional: 20 MB o 25 MB

Un tope de adjunto (25 MB) mayor que el tope total del correo (20 MB) no puede ser cierto
a la vez. La cifra menor es la del centro de ayuda, que es también la única página que
habla del envío por API; la mayor es de una página de producto.

- **Efecto declarado:** **excluyente** por D11 · baja a 🟡 la carga en `MBs` del endpoint de envío, modelada con la cifra menor.
- **A —** [F27], sección de API: `"The size limit for transactional emails is 20MB,
  including the attachments and email content."`
- **B —** [F5], tabla `"Our transactional email service at a glance"`: `"Max attachment
  size | 25 MB per email"`
- **Efecto en la datasheet:** la carga en `MBs` del endpoint de envío se modela con la
  cifra menor, en 🟡. **Vía:** sondeo por bisección en sandbox con un adjunto sintético
  de tamaño creciente. Coste cero, y la única duda es si sandbox valida el tamaño.
- **Estado tras [E1] (2026-09-17):** sin datos, y el instrumento ha caído igual que en
  DISC-03. `probe_brevo_a_tamano.sh` no se ejecutó y, de haberlo hecho, habría abortado por
  falta de guarda recomendada. Los ~184 MB de subida que la escalera preveía no se gastaron:
  el valor sigue siendo la cifra menor publicada, no una cota medida.
- **CERRADA el 2026-09-21 por E5, supuesto (1): las dos citas no hablan de la misma
  magnitud.** [F27] acota el **correo entero** —`"The size limit for transactional emails is
  20MB, including the attachments and email content."`— y [F5] acota **solo el adjunto**. Su
  unidad entera por **D12** es la celda con el encabezado que la gobierna, `"Max attachment
  size"` · `"25 MB per email"`, dentro de la tabla `"Our transactional email service at a
  glance"`. El lado B deja de ser un lado: no es una segunda cifra para la carga en `MBs`, es
  una cifra de otro campo. Y con él cae el efecto declarado, porque nunca hubo contradicción
  excluyente por **D11**. El «un tope de adjunto mayor que el tope total no puede ser cierto a
  la vez» del encabezado de esta entrada es una **inferencia**, adjunto ⊆ correo, y D12 dice
  que una inferencia no dispara D11. **Prueba (E8, y E10 porque transcriben):**
  `evidencias/paginas/2026-09-21/help_brevo_com_hc_en_us_articles_4402811730962_Add_an_attachment_to_a_transactional_email.txt`,
  sección `"Include an attachment in your API script"`, y
  `evidencias/paginas/2026-09-21/www_brevo_com_products_transactional_email.txt`. **El cierre
  no mueve el color por sí solo** (D11): lo que hace es retirarle el sostén de D11 al 🟡 de la
  carga en `MBs`, cuyo valor sigue siendo 20 en los cinco planes. Lo que muere es el arbitraje
  entre 20 y 25, y solo eso: el sondeo por bisección **sigue haciendo falta** para las cuatro
  preguntas de unidad que esta discrepancia nunca formuló, y que las cabeceras de
  `probe_brevo_a_tamano.sh` y `probe_brevo_b_tamano_entrega.sh` ya tienen escritas.
- **El campo se queda en 🟡, y por D1, no por D11 (consejo 2026-09-21, regla D13).** Cerrada
  la discrepancia, el ámbar no se hereda ni se libera: **le cambia la pata**. Dos motivos, los
  dos medidos y ninguno tocado por DISC-16. **Uno, el denominador.** El README de ACM2YAML
  v0.3 titula su §3.4.2 `"workload — Carga de trabajo por petición"` y define
  `"cuántas unidades de consumo genera una sola petición"`, mientras [F27] acota
  `"transactional emails"`, por correo. El mismo bloque declara 2.000 destinatarios por
  petición, así que fuera del envío simple los dos denominadores no coinciden, y meter el
  literal en ese hueco es transferencia de magnitud: inferencia, no literalidad. **Dos, la
  base de medida.** Las cabeceras de los sondeos registran que el tope puede contarse sobre el
  adjunto decodificado o sobre el cuerpo en base64, que pesa un 33 % más; que hay dos lecturas
  de la unidad, MB decimal y MiB; y que no se sabe si muerde en validación o en entrega. Nada
  de eso está medido. Que otro proveedor sí lo fije —Resend publica
  `"max 40MB per email, after Base64 encoding of the attachments"`— prueba que el eje es real
  y no una duda de laboratorio. **No es discrepancia nueva**, porque no hay segundo literal:
  es hueco, y va a `metadata.not_found`.
  **Lo que queda escrito, porque es del dominio y no del fichero:** Brevo publica un tope de
  adjunto de 25 MB que no cabe dentro del tope total de 20 MB que publica su centro de ayuda,
  y el tope por adjunto de la vía de plantilla es todavía otro, 4 MB [F27]. Tres superficies,
  tres topes de tamaño que no encajan entre sí, y ninguna lo advierte.

### DISC-17 · `GET /v3/smtp/emails`: 7.200 peticiones/hora o 300

La misma página se contradice consigo misma. [F6] da a esa ruta una fila propia de 7.200
por hora y, tres filas más abajo, pone el prefijo `/v3/smtp/{…}` en 300 por hora con una
nota al pie que excluye **dos** rutas, y `GET /v3/smtp/emails` **no es ninguna de las dos**
pese a tener fila propia igual que ellas.

- **A —** [F6], fila dedicada: `"| GET /v3/smtp/emails | 7,200 RPH | 2 RPS |"`
- **B —** [F6], fila de prefijo y su nota al pie: `"| All endpoints under /v3/smtp/{…}* |
  300 RPH | - |"` con `"*Excludes POST /v3/smtp/email and GET /v3/smtp/blockedContacts,
  which have dedicated limits."`
- **Efecto en la datasheet:** `rate_request_activity_general` serializa el RPS de la fila
  dedicada, 2 por segundo, que son 7.200 por hora. Si el prefijo también la alcanza, el
  tope efectivo son 300 por hora y el fichero sobrestima **24 veces**. El valor se queda
  en 🟡 y no se arbitra; el hueco está en `metadata.not_found`. **Vía:** leer
  `x-sib-ratelimit-limit` sobre `GET /v3/smtp/emails` [F7], que devuelve el tope vigente
  sin gastar un envío — el mismo sondeo que cierra DISC-01 y DISC-15.
- **RESUELTA midiendo el 2026-09-17 ([E2]): manda la fila propia.** `GET /v3/smtp/emails`
  devuelve `'x-sib-ratelimit-limit: 2'`, que son los 2 por segundo de su fila dedicada en
  [F6] y no los 300 por hora del prefijo. O la nota al pie alcanza también a esta ruta, o el
  prefijo no la gobierna: en cualquiera de los dos casos el valor del fichero es el bueno y
  la lectura alternativa de bajarlo a 300/HORA queda descartada, con ella el riesgo de 24×.
  `rate_request_activity_general` se queda en 2 por segundo. **El color no sube**: por **D6**
  una cabecera leída se registra y no se adopta, así que sigue en 🟡 con su hueco en
  `not_found`. Lo que cambia es que la discrepancia deja de estar sin arbitrar.
  *(La PARADA de [E1] dejó este cierre sin hacer a las 15:34; [E2] lo hizo; su volcado archivado es el de las 20:50 UTC, E24.)*
- **Y el color sube el 2026-09-18 ([E5]), que es lo que [E2] no podía hacer.** La frase de
  arriba decía que el campo seguía en 🟡 porque **D6** registra una cabecera y no la adopta.
  El sondeo del rechazo no lee una cabecera: **alcanza el 429**, que es la condición que la
  ampliación **D-024** de la sección E pone para el verde. Tres peticiones en un segundo dan
  `400`, `400`, `429`. Las dos lecturas de control tomadas justo después devuelven `200`: el
  rechazo es de **la fila** de esta ruta. `rate_request_activity_general` pasa a 🟢 con sus 2
  por segundo. La lectura alternativa de 300 por hora queda descartada por la misma
  medida: el rechazo cae en la tercera petición de un segundo y no en la 301 de una hora.
