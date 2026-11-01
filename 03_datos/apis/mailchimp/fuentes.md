# Fuentes — Mailchimp Transactional (Mandrill)

Producto modelado: correo transaccional (**Mailchimp Transactional**, nombre histórico
**Mandrill**), complemento de pago sobre una cuenta Mailchimp Standard, Premium o el plan
mensual heredado. Proveedor: Mailchimp / The Rocket Science Group. El producto de marketing
(Mailchimp Marketing) y el SMS transaccional, que conviven bajo la misma cuenta, quedan fuera
por A1 y se anotan como fricción (F-10).

Recolección: **2026-09-21**, siete lentes documentales (identificación, precio, límites,
endpoints, errores, features, legal/ToS) más **escalón 2 ejecutado el mismo día**: panel con
cuenta propia en `mandrillapp.com` y un contraste mínimo contra la API en vivo. Toda cita es
literal. La numeración [Fn] es la que referencia `datasheet.yaml`.

---

## Identificación y superficie oficial

## [F1] Developer overview — Mailchimp Transactional

- **URL:** https://mailchimp.com/developer/transactional/
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"Learn how to use Mailchimp Transactional to send targeted and event
  driven messages to anyone, fast—with best-in-class deliverability."`
- **Observación:** el pie de la misma página identifica al proveedor: `"Mailchimp ® is a
  registered trademark of The Rocket Science Group."`

## [F2] Especificación OpenAPI — `transactional.openapi.json`

- **URL:** https://raw.githubusercontent.com/mailchimp/mailchimp-client-lib-codegen/main/spec/transactional.openapi.json
- **Fecha de acceso:** 2026-09-21
- **Citas literales:**
  - `base_uri`: `"servers": [{"url": "https://mandrillapp.com/api/1.4", "description":
    "Mailchimp Transactional API v1.4"}]`. No es campo de `capacity` (B2): va al provenance,
    no al esquema.
  - Test C2, operación (1) enviar: `"/messages/send": {"post": {"summary": "Send a new
    transactional message through the Transactional API."`
  - Test C2, operación (2) plantilla: `templates/add — "Creates a new email template with
    the specified content and settings."`
  - Test C2, operación (3) dominio + verificación: `senders/add-domain — "Adds a sender
    domain to your account. Sender domains are added automatically as you send, but you can
    add them ahead of time."`; `senders/verify-domain — "Sends a verification email in
    order to verify ownership of a domain."`
  - Resto del dominio funcional, sin cambiar `type` (anotado por C2): `"/webhooks/add":
    "Add a new webhook"`; `"/inbound/add-domain": "Add inbound domain"`; `"/rejects/add"`;
    `"/exports/activity"`.
- **Por qué se cita como fuente propia y no de terceros.** El repositorio vive bajo la
  organización oficial de GitHub `github.com/mailchimp`, y la página de referencia de la API
  ([F1], `/developer/transactional/api/`) remite a este fichero como la versión «v. 1.4.1» de
  la especificación. El resumen de `/messages/send` que trae este JSON coincide palabra por
  palabra con el que muestra la página humana del endpoint ([F8]), lo que sugiere que esa
  página se genera desde este mismo fichero. **Ver DISC-01**: otro frente del mismo día
  concluyó que no hay OpenAPI oficial servida por `mailchimp.com`/`mandrillapp.com`, sin
  mencionar este repositorio.

---

## Precio y planes

## [F3] Página de pricing — Transactional Email

- **URL:** https://mailchimp.com/pricing/transactional-email/
- **Fecha de acceso:** 2026-09-21
- **Estructura:** no hay planes con nombre ni tarjetas (Free/Basic/Pro…); hay una calculadora
  por bloques de volumen. La tabla de tramos es estática y visible sin interactuar con el
  input JS (`data-behavior="transactionalPricingCalculator:rows"`); el input en sí
  (`"Ingresa tus mandos estimados por mes"`) no se pudo probar de forma interactiva en esta
  pasada — solo se leyó el HTML estático servido, que ya trae la tabla completa.
- **Citas literales:**
  - Unidad de venta: `"Cada bloque es un crédito por 25,000 correos electrónicos"`.
  - Tabla de tramos (USD/bloque, degresiva por volumen, **F-02**): `"1 - 20 bloques | 1 - 500k
    emails | $20/bloque · 21 - 40 bloques | 500k - 1M emails | $18/bloque · 41 - 80 bloques |
    1M - 2M emails | $16/bloque · 81 - 120 bloques | 2M - 3M emails | $14/bloque · 121 - 160
    bloques | 3M - 4M emails | $12/bloque · 161+ bloques | 4M+ emails | $10/bloque"`.
  - Moneda: `"$20/bloque"` → USD.
  - Add-on IP dedicada: `"Agrega una IP exclusiva por $29.95 al mes (opcional)"`.
  - Requisito de cuenta base (no es `capacity`, va a B3/fricción F-10): `"¿Necesito una cuenta
    de Mailchimp para enviar correos electrónicos transaccionales? Sí, necesitas una cuenta
    de Mailchimp. El correo electrónico transaccional está disponible como complemento de los
    planes Standard y Premium de Mailchimp, o del plan mensual heredado."`
  - Plan Essentials excluido del add-on, dentro del descargo de la oferta del 50 %: `"Essentials
    plan is not eligible for Transactional Email."` — método: navegador renderizado,
    `https://mailchimp.com/en/pricing/transactional-email/`, 2026-09-21 (ver
    `evidencias/navegador_2026-09-21.md`, P2).
  - Demo/franquicia gratuita, en español: `"Los nuevos usuarios transaccionales de correo
    electrónico pueden recibir hasta 500 correos electrónicos gratuitos a su dominio
    verificado. Aplican restricciones."` — y en inglés, método: navegador renderizado,
    `https://mailchimp.com/en/pricing/transactional-email/`, 2026-09-21 (ver
    `evidencias/navegador_2026-09-21.md`, P2): `"New transactional email users can get up to
    500 free email sends to their verified domain. Restrictions apply."` Mismo valor (500),
    servido en los dos idiomas según geolocalización/selector; no es una discrepancia (E9).
  - Overage / agotamiento de bloque: `"Los envíos transaccionales se calculan en tiempo real,
    así que el sistema dejará de enviar correos electrónicos cuando se te acaben los bloques.
    Los correos electrónicos no utilizados de un bloque no se transfieren de un mes a otro."`
    Auto-compra opcional: `"Configura tu cuenta para que compre automáticamente bloques de
    correo electrónico al llegar a tu límite predefinido."` No hay `overage_cost` por unidad
    excedida (B6): el modelo es prepago por bloques, no tarifa de exceso.
  - Descuento de volumen del 50 % (oferta temporal, no precio de lista — D1 ámbar): `"50 % de
    descuento sobre el precio base mensual de Correo Electrónico Transaccional para 1,000,000
    o más correos electrónicos (40 o más bloques) durante los primeros 12 (doce) meses de
    servicio [...] El plan Essentials no es elegible para el Correo Electrónico
    Transaccional."`
  - Precio negociado por debajo de $10 para más de 161 bloques *(etiqueta corregida el
    2026-10-31: decía «sin cifra (>161 bloques)», y la fila `"161+ bloques | 4M+ emails |
    $10/bloque"` de arriba sí da precio)*: `"Nuestros precios se adaptan a las
    necesidades de gran volumen con tarifas por bloque más bajas para volúmenes más altos.
    Contáctanos para obtener más información sobre nuestros precios para grandes
    volúmenes."`
  - Producto marketing bajo la misma cuenta, fuera de alcance por A1: `"Los SMS
    transaccionales están disponibles como complemento de uno de los planes de pago de
    Mailchimp."`
- **Observación:** no hay tabla de precio anual — solo mensual por bloque. No aclara si el
  precio del tramo alcanzado es marginal (por tramo, tipo IRPF) o plano sobre todos los
  bloques del mes (ver «Fuentes buscadas y NO encontradas»).

---

## Límites de capacidad

## [F4] Developer docs — Outbound Email

- **URL:** https://mailchimp.com/developer/transactional/docs/outbound-email/
- **Fecha de acceso:** 2026-09-21
- **Citas literales:**
  - Cuota horaria (existencia, sin cifra): `"The number of messages you can send in a given
    time is determined by your pricing plan as well as your hourly quota, which is based on
    your sending reputation. If you exceed your quota, unsent messages will be placed in the
    backlog."`
  - Agotamiento y reproceso: `"Hourly quota exhausted - You've sent all the emails your
    hourly quota allows. We'll begin processing the backlog in the next hour."`
  - Reserva de prioridad: `"If you have a campaign or a large batch of emails queued in the
    backlog, Mailchimp Transactional reserves an extra 5% of your hourly quota so more
    critical emails, such as password resets or order confirmations, can send without
    delay. To flag important messages and give them priority in the queue, use the
    `important` parameter in your API call."`
  - Destinatarios vía API: `"Via the API, there's no recipient limitation, but the JSON
    provided per API call must be less than 10MB. We strongly recommend smaller recipient
    batches for easier troubleshooting."` (F-06: el tope real es de payload, no de un entero
    de destinatarios).
  - Destinatarios vía SMTP: `"Via SMTP, you can send to up to 1,000 recipients at a time. If
    you're sending messages to more recipients, simultaneous and subsequent connections are
    permitted."`
  - Tamaño de payload por llamada: `"the JSON provided per API call must be less than
    10MB"`.
  - Tamaño de mensaje con adjuntos: `"Mailchimp Transactional allows attachments, but the
    total message size cannot exceed 25MB. There is no specific limit for individual
    attachments, just the total size of the message."`
  - Encolado asíncrono (umbral no fijado en esta frase — ver «no encontradas»): `"We queue
    these messages to process asynchronously, and will send them as soon as possible,
    usually within seconds."`
  - **Corregido el 2026-10-31 (verificador).** El umbral sí está en la página, en la lista que
    precede a esa frase: `"These cases include: Emails sent with attachments Emails with more
    than 10 recipients"`. Ya estaba en la captura de Wayback del 2026-03-12, así que es un
    defecto del registro y no un cambio de la oferta. Coincide con lo medido el 2026-09-21.
- **Observación crítica.** El tope de payload (<10MB por llamada) y el tope de mensaje con
  adjuntos (≤25MB) conviven en la misma página: un mensaje de 25MB en base64 no cabría en una
  llamada de <10MB. No son dos literales estrictamente excluyentes sobre el mismo campo — uno
  mide el payload de la llamada, el otro el mensaje entregado — así que no abre DISC (D11 no
  se activa), pero es fricción a anotar para quien construya `fricciones.md`.

## [F5] Developer docs — Fundamentals

- **URL:** https://mailchimp.com/developer/transactional/docs/fundamentals/
- **Fecha de acceso:** 2026-09-21
- **Citas literales:**
  - Límite de modo de pruebas: `"Note that you're limited to 10,000 test mode messages per
    day. This limit resets at midnight, or if they hit the limit, 24 hours after that limit
    is hit."` **Ver DISC-02**: la propia frase da dos anclas de reinicio distintas.
  - Definición de error: `"You can consider any non-200 HTTP response code an error—the
    returned data will contain more detailed information."`
  - Tabla de errores: `"401 Invalid API Key"` · `"401 IP does not have permission to use
    this key | API keys can be limited by IP address, and the IP address does not have
    permission | Go to the Settings page in Transactional and edit the key to allow the IP
    address to make requests"` · `"401 This key does not have permission to call method
    name"` · `"404 No Such Template"` · `"404 Invalid Message ID"` · `"404 No message
    exists with the id"` · `"404 No subaccount exists with the id"` · `"405 Method not
    allowed"`.
- **Observación crítica.** La tabla oficial de errores no incluye **ni 429 ni 403**. Lo que
  en otras APIs del catálogo sería un 403 (autorización) aquí se modela con variantes de 401.
  No hay 429 en absoluto — el mecanismo de contención es el *backlog* de [F4], no un rechazo
  HTTP (fricción F-08: asimetría estructural frente a proveedores que sí devuelven 429).

## [F6] Developer docs — Reputation and rejections

- **URL:** https://mailchimp.com/developer/transactional/docs/reputation-rejections/
- **Fecha de acceso:** 2026-09-21
- **Citas literales:**
  - Cuota horaria dinámica, sin cifra para cuentas de pago: `"The account's reputation
    informs the account's hourly quota, but it isn't the only factor we use. Your typical
    sending volume also affects the hourly quota: an account that sends 1 million messages
    per week and an account that sends 100 messages per week could both have excellent
    reputations, but their hourly quotas will be very different."`
  - Cuota horaria de cuenta demo: `"Demo accounts are limited to a fixed hourly quota of 25
    emails. Once you upgrade to a paid account, you'll be switched to the standard
    reputation and quota system."` — confirmado por panel y API el mismo día, ver [F18] y
    [E1].
  - Consecuencia de exceder quejas de spam: `"At certain spam complaint thresholds, ISPs may
    begin routing all your email to spam folders, bar you as a sender, or even block
    Mailchimp Transactional's sending IPs overall—and Mailchimp Transactional will lower
    your hourly quota as a result."`
  - Umbral de industria (no es umbral propio del proveedor, D1 ámbar): `"spam complaints, but
    industry standards recommend a complaint rate under 0.1%."`

---

## Rate limits de endpoints

## [F7] Release note — Message search rate limit now enforced

- **URL:** https://mailchimp.com/developer/release-notes/message-search-rate-limit-now-enforced/
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"We're now enforcing the message search rate limit described in the
  Search messages by date endpoint. If you exceed the limit of 20 searches per minute, we'll
  now return a 429 Too Many Requests response code. You can retry your request 60 seconds
  after you sent the first of the original 20 requests."`
- **Observación:** único rate con valor numérico, ventana y mecanismo de reposición
  publicados en toda la documentación revisada — y es de un endpoint concreto
  (`/messages/search`), no del envío. Confirma B8: se declara en el endpoint, no en el plan.
- **Releída el 2026-10-31 (verificador, E3).** La URL da 404, también con JavaScript. La
  documentación migró entre el 3 y el 5 de octubre, y la nota ya no tiene página propia. El
  texto sigue literal en el índice [F17], en la entrada `"Apr 10, 2023"`, y la captura de
  Wayback del 2026-07-11 lo trae en la URL antigua. La línea del YAML apunta ahora al índice.

## [F8] API reference — Messages (índice de endpoints)

- **URL:** https://mailchimp.com/developer/transactional/api/messages/
- **Fecha de acceso:** 2026-09-21
- **Citas literales, una por endpoint:**
  - `POST /messages/send` — `"Send a new transactional message through the Transactional
    API."`
  - `POST /messages/send-mc-template` — `"Send a new transactional message through Mandrill
    using a Mailchimp Transactional template."`
  - `POST /messages/send-raw` — `"Take a raw MIME document for a message, and send it
    exactly as if sent through SMTP servers."`
  - `POST /messages/search-time-series` — `"Search the content of recently sent messages and
    return the aggregated hourly stats for matching messages."`
  - `POST /messages/info` — `"Get the information for a single recently sent message."`
  - `POST /messages/content` — `"Get the full content of a recently sent message."`
- **Observación.** No existe un endpoint de envío por lotes (*batch*) propiamente dicho: el
  envío a múltiples destinatarios ocurre dentro de una única llamada a `/messages/send` vía
  el array `to`.

## [F9] API reference — `POST /messages/send-template`

- **URL:** https://mailchimp.com/developer/transactional/api/messages/send-using-message-template/
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"Send a new transactional message through the Transactional API using a
  template."`
- **Observación:** la página propia del endpoint no menciona límite de destinatarios ni de
  tamaño distinto de los generales de [F4].

## [F10] API reference — `POST /messages/search`

- **URL:** https://mailchimp.com/developer/transactional/api/messages/search-messages-by-date/
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"Search recently sent messages and optionally narrow by date range,
  tags, senders, and API keys. If no date range is specified, results within the last 7 days
  are returned. This method may be called up to 20 times per minute."`
- **Observación:** el propio endpoint publica el mismo rate que [F7] (20/min), en la página
  de referencia y no solo en la nota de versión — doble confirmación, no discrepancia.
- **Releída el 2026-10-31 (verificador, E3).** La URL da 404. La página que la sucede,
  `/api/messages/search`, solo trae `"If no date range is specified, results within the last 7
  days are returned."`: ni el 20 por minuto ni el 429 están entre sus errores. La frase del
  límite sigue en la captura de Wayback del 2026-04-21 de la URL antigua. Del 20 por minuto solo
  queda la nota de versión, en el índice [F17].

## [F11] API reference — `POST /rejects/list`

- **URL:** https://mailchimp.com/developer/transactional/api/rejects/list-denylisted-emails/
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"Retrieves your email rejection denylist. You can provide an email
  address to limit the results. Returns up to 1000 results. By default, entries that have
  expired are excluded from the results; set `include_expired` to true to include them."`
- **Observación:** tope de paginación de resultados devueltos (1000), no de consumo de
  cuota (B3).

---

## Legal / Acceptable Use

## [F12] Acceptable Use Policy

- **URL:** https://mailchimp.com/legal/acceptable_use/
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"Enviar correos electrónicos masivos, es decir, correos electrónicos
  dirigidos a varias personas con el mismo contenido, a través de Transactional (antes
  conocido como Mandrill)."` (prohibido)
- **Observación:** confirma A1 desde política y no desde capacidad — el uso masivo por
  Transactional está prohibido por AUP, no acotado por una cuota numérica. Se anota como
  fricción F-10, no como `capacity`.

## [F13] Terms of Use

- **URL:** https://mailchimp.com/legal/terms/
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"If you use Transactional Email to send bulk emails disregarding our
  Acceptable Use Policy, we may charge you at the equivalent Paid Marketing Plan rate or
  cancel your account."`
- **Observación:** consecuencia de suspensión/recargo por incumplimiento de AUP; es política
  (B4), no un tope de capacidad.
- **Cita corregida el 2026-10-31 (verificador).** La de arriba no es el literal inglés, sino
  una retrotraducción del castellano (`"le podemos cobrar a la tarifa del Plan de Marketing
  Pago equivalente o cancelar su cuenta"`). La página en inglés dice, hoy y en la captura del
  2026-09-21: `"If you use Transactional Email to send bulk emails in violation of our
  Acceptable Use Policy, then we may charge you at the comparable Paid Marketing Plan rate or
  terminate your account."` El sentido es el mismo.

---

## Ayuda, demo y throttling

## [F14] Help Center — How throttling improves deliverability

- **URL:** https://mailchimp.com/help/how-throttling-improves-deliverability/
- **Fecha de acceso:** 2026-09-21
- **Cita literal:** `"Mailchimp Transactional reserves an extra 5% of your hourly quota so
  more critical emails, such as password resets or order confirmations, can send without
  delay."`
- **Observación:** mismo dato que [F4] con otras palabras y desde otra URL — no es
  discrepancia, es corroboración. Esta cita concreta llegó por resumen de herramienta y no
  por transcripción directa; el literal de [F4] es el de mayor confianza para citar el
  mecanismo, y este queda como refuerzo.
- **Refutada el 2026-10-31 (verificador).** La página no lo dice, ni hoy ni en la captura de
  Wayback de mayo, en inglés ni en castellano. Trata de cómo los proveedores de buzón limitan
  las campañas, y no menciona Transactional, la cuota horaria ni ningún 5 %. La cita llegó por
  resumen de herramienta, como ya avisaba la observación. El dato se queda con [F4] y la URL
  sale de la línea del YAML.

## [F15] Help Center — Transactional Email Demo

- **URL:** https://mailchimp.com/help/transactional-email-demo/
- **Fecha de acceso:** 2026-09-21 (releída con navegador renderizado el mismo día, ver
  `evidencias/navegador_2026-09-21.md`, P3)
- **Citas literales:**
  - `"You can send up to 25 emails in an hour"` (cuota horaria de la cuenta demo/trial).
  - `"receive up to 100 inbound emails per day"` (tope de entrada en demo).
  - `"You can send up to 500 transactional emails to any email address on your verified
    domain"`, con `"The emails included with the demo do not expire or renew."`
  - `"Your transactional email history is stored for only 30 days. After that, you will not
    be able to see the contents of the transactional emails or to whom the emails were
    sent."` (retención de la cuenta demo).
- **Observación:** el tope de 25/hora coincide exactamente con [F6] y con la observación de
  panel y API del mismo día ([F18], [E1]). El de 500 correos no es una ventana temporal
  (día/mes): es un tope acumulado sin caducidad, coherente con la cifra de [F3]. Los treinta
  días de retención son de la cuenta demo; ninguna fuente revisada publica la cifra para
  cuenta de pago, y una no se infiere de la otra. Es límite de recurso y no cuota (B3/B4): no
  entra en `capacity`.
- **Corregido el 2026-10-31 (verificador).** La cifra para la cuenta de pago sí está publicada,
  en una página que no estaba entre las revisadas,
  `https://mailchimp.com/developer/transactional/docs/activity-reports/`: `"keeps a copy of the
  HTML and text parts of emails you’ve sent for 30 days"`, `"Overall statistics … are stored
  indefinitely"` y `"data about bounced messages is only kept for 90 days"`. Ya lo decía en la
  captura de Wayback del 2026-07-30.

## [F16] Developer docs — Authentication and delivery

- **URL:** https://mailchimp.com/developer/transactional/docs/authentication-delivery/
- **Fecha de acceso:** 2026-09-21
- **Citas literales:**
  - `"You'll need to add DMARC and a DKIM record, and verify ownership of your sending
    domains before you can send email through your account."`
  - `"Mailchimp Transactional won't send any email from unverified domains or domains
    without a valid DMARC policy and DKIM records."`
- **Observación:** requisito de configuración que condiciona la capacidad de envío, no una
  cuota (B4/B3); va a fricciones y provenance.

## [F17] Release notes — índice general

- **URL:** https://mailchimp.com/developer/release-notes/
- **Fecha de acceso:** 2026-09-21
- **Citas literales, agregadas por resumen de herramienta y sin transcripción individual
  verificada línea a línea — quedan en ámbar hasta releer cada nota por separado:**
  - `"Starting March 15, 2024, senders must implement DKIM records and DMARC policies.
    Non-compliant domains will use mandrillapp.com subdomains as sending addresses."`
  - `"Mailchimp Transactional status added to server status page"`
- **Observación:** cuatro entradas relacionadas con Transactional encontradas entre 2023 y
  2025; ninguna cambia una cifra de rate o cuota. Recomendado releer cada nota individual
  antes de dar estas dos citas por verdes.
- **Releída el 2026-10-31 (verificador).** Desde la migración de octubre, el índice es la única
  página que conserva la nota del límite de búsqueda, en la entrada `"Apr 10, 2023"`: `"If you
  exceed the limit of 20 searches per minute, we’ll now return a 429 Too Many Requests response
  code. You can retry your request 60 seconds after you sent the first of the original 20
  requests."` Es la fuente de esa línea del YAML. Volcado en `evidencias/paginas/2026-10-31/`.

---

## Panel

## [F18] Observación de panel con cuenta propia — 2026-09-21

- **Fecha de acceso:** 2026-09-21 · **Navegador:** «danvelcam - dvela browser»
  (`deviceId 8bfcd503-51fd-4675-bc3e-92d4701ee501`) · **Acceso:** `mandrillapp.com` → *Log in
  using Mailchimp* (SSO por redirección, sin pantalla de consentimiento). **Modo lectura**: no
  se añadió dominio, no se creó ni reveló ninguna clave, no se tocó facturación ni add-ons.
- **Evidencia:** `evidencias/panel_mandrill_2026-09-21.md` (transcripción literal de cinco
  pantallas, sin capturas gráficas).
- **Citas literales:**
  - Login: `"Mandrill is a paid Mailchimp add-on that allows you to send one-to-one
    transactional messages triggered by user actions, like requesting a password or placing
    an order."`
  - Cuenta (`/account`): `"Free trial sends"` → `"0 of 500"` · `"SMS credits"` → `"0 of 0"` ·
    `"Hourly sends"` → `"Email sends this hour"` → `"0 of 25"` · `"Reputation"` →
    `"Unknown"`, con `"All new accounts have an \"Unknown\" reputation since we haven't seen
    the results of anything you've sent... your account will have a reputation (Excellent,
    Good or Poor) that is used, in part, to determine your hourly quota."` · `"Add Ons —
    Dedicated IPs — You don't have any dedicated IPs. Manage Dedicated IPs"`.
  - Credenciales (`/settings`): `"Send email using our API or get started quickly with SMTP
    using the information below: Host smtp.mandrillapp.com Port 587"`. Tabla de API Keys con
    columnas `"Expires"` y `"Remaining"`, ambas vacías en esta cuenta: la clave es una unidad
    a la que se le puede poner caducidad y un contador de usos restante.
  - Dominios de envío (`/settings/sending-domains`): `"No sending domains yet. To start
    sending through Mandrill, you need to verify ownership of your sending domain and update
    your DNS records."`
- **Lo que el panel NO enseña en esta pasada.** El precio por bloque ni la escalera de
  volúmenes (cuenta en prueba gratuita, pantalla de compra no abierta). Ningún rate de
  peticiones a la API — el único tope de velocidad que publica el panel es de **envíos por
  hora**, no de peticiones. Tampoco el tamaño máximo de mensaje/adjunto, ni el máximo de
  destinatarios por llamada, ni ningún registro de error 429. **El test C2 queda
  parcialmente cubierto**: la pantalla de dominios confirma que añadir un dominio de envío
  (operación 3) está también en el panel y no es exclusivo de la API, pero esta pasada no
  visitó una pantalla de creación de plantillas (operación 2) — comprobación pendiente que
  cierra la segunda pasada de navegador del mismo día, con la pantalla de plantillas [F20]
  y con la referencia de API del propio dominio del proveedor [F19], que ya no depende del
  panel para la operación 2 (D16).

## [E1] Sondeo empírico — contraste de la cuota horaria contra la API en vivo

- **Fecha:** 2026-09-21 · **Método:** `POST https://mandrillapp.com/api/1.0/users/info` con
  la clave de la cuenta de prueba (`~/.config/tfm/.env`), más un `users/ping2` de
  comprobación de conectividad. **Coste 0** (endpoints de lectura, sin envío).
- **Evidencia:** `evidencias/api_users_info_2026-09-21.json`,
  `evidencias/api_users_ping2_2026-09-21.json`.
- **Resultado literal:** `{"username":"31644777","created_at":"2026-09-16
  10:16:34.82112","public_id":"W-1vniwilLzrhCW3f3KPgA","reputation":0,"hourly_quota":25,
  "backlog":0, …}` · `{"PING":"PONG!"}`.
- **Lo que cierra.** `hourly_quota: 25` de la API coincide exactamente con `"Email sends this
  hour — 0 of 25"` del panel [F18] y con `"You can send up to 25 emails in an hour"` de [F15]
  y `"Demo accounts are limited to a fixed hourly quota of 25 emails"` de [F6]. Tres
  superficies —API, panel y documentación— dan el mismo número para cuenta demo/trial: no
  hay discrepancia. `reputation: 0` en la API es la misma noción que `"Reputation: Unknown"`
  en el panel, en dos codificaciones del mismo estado, no dos valores distintos.
- **Lo que no toca.** Ningún semáforo de cuota de cuenta de pago (sigue sin cifra publicada,
  ver «no encontradas»); ningún rate de peticiones por segundo/minuto de la API REST general
  (el único endpoint con rate propio publicado sigue siendo `/messages/search`, [F7]/[F10]).

---

## Segunda pasada — navegador renderizado, 2026-09-21

Cinco transcripciones con navegador, el mismo día, sobre `evidencias/navegador_2026-09-21.md`
(P1 a P5). P2 y P3 quedan incorporadas en [F3] y en [F15]; P1, P4 y P5 abren entrada propia
porque citan URLs no visitadas hasta ahora.

## [F19] Referencia de API del proveedor, en su propio dominio

- **URL:** https://mailchimp.com/developer/transactional/api/
- **Fecha de acceso:** 2026-09-21 · **Método:** navegador renderizado (ver
  `evidencias/navegador_2026-09-21.md`, P1)
- **Título servido:** «Mailchimp Transactional API Reference | Mailchimp Developer» ·
  **versión declarada en la página:** «v. 1.4.1»
- **Citas literales, las tres operaciones del test C2/D9:**
  - `"Send new message — POST /messages/send — Send a new transactional message through the
    Transactional API."`
  - `"Add template — POST /templates/add — Add a new template."` y `"Update template — POST
    /templates/update — Update the code for an existing template. If null is provided for any
    fields, the values will remain unchanged."`
  - `"Add sender domain — POST /senders/add-domain — Adds a sender domain to your account.
    Sender domains are added automatically as you send, but you can use this call to add them
    ahead of time."` y `"Verify domain — POST /senders/verify-domain — Sends a verification
    email in order to verify ownership of a domain. Domain verification is a required step to
    confirm ownership of a domain."`
- **Observación.** Las tres operaciones están publicadas en el dominio propio del proveedor,
  no solo en el contrato máquina de GitHub ([F2]): el test C2/D9 queda entero sin depender de
  DISC-01. La página no enlaza ni menciona ninguna especificación OpenAPI en ningún punto del
  texto servido — la ausencia cierra la segunda mitad de DISC-01 (ver más abajo).

## [F20] Panel, pantalla de plantillas

- **URL:** https://mandrillapp.com/templates
- **Fecha de acceso:** 2026-09-21 · **Método:** navegador renderizado (ver
  `evidencias/navegador_2026-09-21.md`, P5)
- **Cita literal:** `"You don't have any templates yet. You can add a template below, use
  Mandrill's API or from your attached Mailchimp account. Create a template"`
- **Observación.** Era la comprobación de panel que faltaba para el test C2/D9: crear
  plantilla no es exclusiva de la web, porque el propio panel remite a la API como vía
  alternativa.

## [F21] Panel, portada de la cuenta, dos horas después del sondeo A

- **URL:** https://mandrillapp.com/
- **Fecha de acceso:** 2026-09-21, unas dos horas después de cerrar el sondeo A que dejó unos
  7.600 destinatarios en cola · **Método:** navegador renderizado (ver
  `evidencias/navegador_2026-09-21.md`, P4)
- **Citas literales:** `"Last reset on September 16, 2026"` · `"Free trial sends — 0 of 500"`
  · `"Sends This Month — 0"` · `"Email sends this hour — 0 of 25"`
- **Observación.** Mide la celda *(verificar)* de F-21: la cola no descontó ni la franquicia,
  ni el contador mensual, ni el horario. Coherente con `'sent': 0` que ya daba la API — en
  Mandrill, encolar no consume. `"Last reset on September 16, 2026"` es dato nuevo y sin
  conciliar: la cuenta se dio de alta ese mismo día, y no hay periodicidad declarada que
  justifique un ciclo. No se adopta como ancla de ninguna ventana (D8); queda como
  observación.

---

## Discrepancias entre fuentes

Registro de contradicciones documentación↔documentación. El semáforo del campo afectado
sigue las reglas D11/D3/D8 mientras la discrepancia viva.

### DISC-01 · ¿Existe una especificación OpenAPI oficial de Mailchimp Transactional?

- **A —** [F2]: el fichero `transactional.openapi.json` vive en
  `raw.githubusercontent.com/mailchimp/mailchimp-client-lib-codegen`, bajo la organización
  oficial de GitHub `mailchimp`, y la propia página de referencia de la API la nombra como
  «v. 1.4.1». Se usó en esta pasada como fuente verde para `base_uri` y para las tres
  operaciones que fijan `type` por C2.
- **B —** hallazgo de otro frente del mismo día, sobre las páginas de fundamentals,
  outbound-email y la referencia de mensajes: `"no se ha encontrado /openapi.json ni
  /swagger.json servido por mailchimp.com ni mandrillapp.com; solo existen specs NO
  oficiales de terceros (APIs-guru/openapi-directory, elasticio/mandrill-api) generadas por
  la comunidad, que no cuentan como fuente oficial del proveedor (regla D1)"`.
- **Nota.** Los dos lados no son estrictamente incompatibles: B busca un fichero servido
  *desde el dominio del proveedor* (`mailchimp.com`/`mandrillapp.com`) y no encuentra
  ninguno; A es un repositorio de GitHub bajo la organización `mailchimp`, que es un dominio
  distinto pero de la misma empresa, y que B no llegó a evaluar (nombra otros dos
  repositorios de terceros, no este). El resumen de `/messages/send` en [F2] coincide
  palabra por palabra con el de la página humana [F8], lo que es indicio de parentesco pero
  no prueba autoría oficial del fichero JSON en sí. **No se elige un lado** (E5): ninguno de
  los tres supuestos de cierre aplica — no cae ninguna cita (las dos son correctas en lo que
  afirman), no manda una regla ya escrita, y el esquema no aloja «vale como oficial según el
  dominio que la sirve, no según el propietario del repositorio».
- **Vía de cierre ejecutada el 2026-09-21:** se visitó `/developer/transactional/api/` ([F19],
  método navegador renderizado). La página lista las tres operaciones del test C2/D9 con cita
  propia y no enlaza ni menciona ninguna especificación OpenAPI en ningún punto del texto
  servido.
- **DISUELTA el 2026-09-21, por dos vías.** La primera es **D15**, regla ya escrita: oficial lo
  fija quién mantiene el artefacto, no el dominio que lo sirve. [F2] cumple la señal (1) de
  D15 — el repositorio pertenece a la organización de GitHub del proveedor, `mailchimp` —, así
  que el fichero **sí puede citarse como fuente oficial** en verde, y el lado A queda resuelto
  sin arbitrar contra el lado B. La segunda es que, tras [F19], ninguna afirmación de la
  datasheet depende ya de [F2]: las tres operaciones del test C2/D9 están publicadas también en
  la referencia oficial del propio dominio del proveedor, así que el veredicto de `type` no
  necesita el fichero de GitHub ni su discusión.

  Lo que D15 no cierra, y aquí se deja escrito porque se midió: si el proveedor **sirve** esa
  especificación desde su propio dominio (`mailchimp.com`/`mandrillapp.com`) es una afirmación
  de hecho distinta de si el fichero **es** oficial, y sigue sin constar. [F19] confirma la
  ausencia con más precisión que el rastreo genérico del lado B: la propia página de referencia
  de la API, no solo el dominio en general, no enlaza ni nombra ninguna especificación OpenAPI.
  Esa ausencia va a `metadata.not_found`, sin color, porque no es lo que D1 mide.
- **Efecto en la datasheet:** las citas que se apoyaban en [F2] para las tres operaciones
  eliminatorias de C2 pasan a citarse sobre [F19]; `base_uri` se queda citado sobre [F2], en
  verde por D15. El campo `type` sube a 🟢 por D9/D16: el test ya no depende de una fuente
  discutida (ver `metadata.data_provenance`).
- **Efecto declarado:** no excluyente entre autoría del fichero y lugar de publicación —son
  preguntas distintas, D15— · campo `type` sube a 🟢 por quedar el test C2/D9 entero
- **Releída el 2026-10-31 (verificador, E3).** Lo que esta entrada dejaba sin constar ya
  consta. Desde la migración de octubre, `llms.txt` enlaza `openapi.json`, un índice que lleva a
  `openapi/api-reference-2.json`: es OpenAPI 3.1.0 y declara como servidor
  `https://mandrillapp.com/api/1.4`. El 2026-09-21 la ausencia era cierta. No cambia ningún
  valor ni ningún color.

### DISC-02 · La ventana de reinicio del límite de modo de pruebas

- **A —** [F5]: `"This limit resets at midnight"` — ancla de reinicio fija diaria.
- **B —** [F5], misma frase, segunda cláusula: `"or if they hit the limit, 24 hours after
  that limit is hit"` — ancla de reinicio *rolling* desde el momento en que se agota la
  cuota.
- **Nota.** Es la MISMA fuente, la misma frase, con dos mecanismos de reinicio que no
  coinciden salvo si el límite se agota exactamente a medianoche: alguien que agota los
  10.000 mensajes de prueba a las 15:00 no sabe, por este literal, si el contador vuelve a
  cero a medianoche (9 horas después) o a las 15:00 del día siguiente (24 horas después).
  D3 exige que la fuente diga *literalmente* cómo se reinicia una cuota para dar verde; aquí
  lo dice, pero de dos formas incompatibles, así que el campo se queda en ámbar por D3/D11 y
  no en verde.
- **Vía de cierre:** un sondeo que agote el límite de modo de pruebas en un horario alejado
  de medianoche y observe cuál de las dos anclas se cumple realmente (F2, escalón 3) — coste
  alto en tiempo (esperar hasta el reinicio) y no se ha ejecutado en esta pasada.
- **Efecto en la datasheet:** afecta al tipo de ventana del límite de modo de pruebas
  (`quota_test_mode_daily`, si el esquema lo modela). No es capacidad de producción — aplica
  solo a mensajes enviados con clave/modo de prueba — así que no toca ningún `plans[].price`
  ni la cuota horaria de producción.
- **Efecto declarado:** excluyente sobre el tipo de ventana (`rolling` vs `fixed`) · el campo
  de ventana del límite de modo de pruebas se queda en 🟡 mientras la discrepancia viva

---

## Fuentes buscadas y NO encontradas

Deduplicado de los siete frentes documentales del 2026-09-21.

| Dato buscado | Resultado |
|---|---|
| Valor numérico de la cuota horaria (`hourly quota`) para cuentas de **pago** | **No publicado en ninguna página oficial.** [F4] y [F6] documentan el mecanismo (reputación + volumen histórico), no la cifra. Solo hay número para cuenta demo/trial: 25/hora, confirmado en [F6], [F15], panel y API ([F18], [E1]). |
| Desglose de la cuota horaria por plan (Standard vs Premium) | No encontrado — ninguna tabla por plan en pricing, fundamentals, reputation-rejections ni en el panel de una cuenta de pago (esta cuenta es trial). |
| Ancla de reinicio de la cuota horaria de producción (rolling vs fixed) | No declarada — solo se documenta que el backlog «se reprocesa en la próxima hora», sin decir si la ventana es rolling o fixed. |
| Límite de concurrencia de la API REST (peticiones/conexiones simultáneas) | No publicado — ninguna cifra en fundamentals/ ni outbound-email/. |
| Rate de velocidad (req/s o req/min) para `/messages/send` y el resto de endpoints de envío | No publicado — el único rate con cifra en toda la documentación es el de `/messages/search`, 20/min ([F7], [F10]). |
| Límite o registros específico de `/messages/send-template` distinto del general | No encontrado — la página propia del endpoint ([F9]) no menciona cifras propias. |
| Umbral exacto de destinatarios que fuerza el envío asíncrono forzoso («more than 10 recipients») | **Corregido el 2026-10-31: sí publicado en [F4]**, `"Emails with more than 10 recipients"`. Lo que sigue es el texto original de la fila. No hay cita oficial con el número; [F4] confirma el encolado asíncrono en general, sin fijar el umbral en la frase transcrita. El «10» circula en fuentes de terceros sin respaldo oficial. |
| Consumo compuesto por destinatario (F-03): si N destinatarios en `to` cuentan como N unidades de cuota o como 1 por llamada | No verificable con fuente oficial accesible — el artículo del Zendesk de Mandrill que lo trataría (`mandrill.zendesk.com/hc/en-us/articles/360038783814-How-Transactional-Email-Billing-Works`) devolvió HTTP 403 Forbidden en esta pasada. |
| Endpoint de envío por lotes (*batch*) propiamente dicho | No existe — confirmado por el índice de endpoints [F8]: el envío múltiple ocurre dentro de una sola llamada a `/messages/send` vía el array `to`. |
| Especificación OpenAPI/Swagger servida **desde el dominio del proveedor** (`mailchimp.com`/`mandrillapp.com`) | **Desde octubre de 2026, servida**: `openapi/api-reference-2.json` (ver DISC-01, relectura del 2026-10-31). El 2026-09-21: No localizada. La propia referencia oficial de la API ([F19]) tampoco la enlaza ni la menciona, comprobado con navegador el 2026-09-21. El fichero de GitHub del proveedor sí puede citarse como fuente oficial por **D15** (organización `mailchimp`); lo que no consta es que el proveedor la sirva desde su propio dominio — es la mitad de DISC-01 que la regla no cierra, y sigue así. |
| Códigos HTTP 429 y 403 en la tabla oficial de errores | Ausentes los dos — [F5] solo lista 401 (tres variantes), 404 (cuatro variantes) y 405. El exceso de envío se modela como *backlog*, no como rechazo HTTP. |
| Cabeceras de rate limit (`X-RateLimit-*`, `Retry-After` o nombre propio) | No encontradas en ninguna página oficial revisada. Una búsqueda general devolvió solo un resumen genérico de una herramienta de búsqueda, sin URL de página oficial concreta que lo respalde — no se adopta (regla equivalente a D6). |
| Página dedicada de referencia de errores, distinta de `fundamentals/` | No existe — todo el catálogo de errores vive en esa única página. |
| Nombre exacto de cabecera/parámetro de autenticación (API key) | No detallado en el cuerpo volcado de la página de referencia de la API; tampoco se revisó el bloque `securitySchemes` del OpenAPI [F2] en esta pasada. |
| Listado de países elegibles para la oferta del 50 % de descuento | No enumerados — la página dice «en determinados países» sin lista ni enlace. |
| Cifra por debajo de $10/bloque para volúmenes por encima de 161 bloques (>4M emails/mes) | No publicada — la página remite a «Contáctanos» sin cifra. |
| Tabla de precio anual/facturación anual del transaccional | No existe — solo precio mensual por bloque. |
| Si el precio del tramo alcanzado es marginal (tipo IRPF) o plano sobre todos los bloques del mes | No aclarado en ninguna de las páginas ni preguntas frecuentes revisadas. |
| Comportamiento exacto del selector/input de la calculadora de precio | No probado de forma interactiva — el cálculo corre en JavaScript del navegador y esta pasada solo leyó el HTML estático servido (que ya trae la tabla de tramos completa). |
| Webhooks de eventos, retención de logs, dominios de firma, usuarios, SMTP y plantillas **por plan/volumen** | No hay matriz por plan — no existen planes con nombre en Mailchimp Transactional, solo escalones de precio por volumen sobre un único producto. Ver friccion F-08 candidata en `features.md`. |
| Página `https://mailchimp.com/help/about-mandrill/` | HTTP 404. |
| Periodo de calentamiento (*warm-up*) obligatorio para cuentas nuevas, con topes progresivos día a día | No encontrado — solo hay un warm-up **opcional** de IP dedicada. |
| Condiciones de suspensión automática por volumen (umbral numérico) | No publicado — solo la condición de uso indebido tipo bulk-email (política, no volumen). |
| Changelog específico y exclusivo de Mandrill/Transactional, distinto del índice general de release notes | No localizado — se usó el índice general [F17] filtrado. |
| Precio del bloque de créditos, ampliación del importe exacto de add-ons más allá de los ya citados en [F3] | Cubierto en [F3]; cualquier cifra adicional mencionada solo en resultados de búsqueda sin fetch propio no se adopta. |

---

## Otras notas de alcance

- **A1 (producto marketing bajo la misma cuenta).** Confirmado desde tres ángulos: pricing
  ([F3], SMS como add-on separado), AUP ([F12], envío masivo prohibido vía Transactional) y
  panel ([F18], `SMS credits — 0 of 0` como línea aparte de `Free trial sends`). El producto
  de marketing y el SMS transaccional quedan fuera del modelado; se anotan como fricción
  F-10.
- **`type` cerrado en verde.** Las tres operaciones eliminatorias de C2 (enviar, plantilla,
  dominio+verificación) están documentadas en la referencia de API del propio dominio del
  proveedor [F19], reforzadas por [F2], [F8] y [F9]. El panel confirma las dos que sí tienen
  pantalla propia: añadir dominio ([F18]) y crear plantilla ([F20]), ninguna exclusiva de la
  web. El test C2/D9 queda entero y el valor es **`api_first`**, en 🟢.
