# Fuentes — SendGrid (Twilio SendGrid Email API)

API de correo transaccional y de marketing. Proveedor: Twilio Inc. (SendGrid).
Recolección: **2026-09-06 (pasada 1)**, documentación pública + panel con cuenta propia +
verificación adversarial independiente + sondeo en sandbox [E1], todo el mismo día.
Toda cita es literal. La numeración [Fn] es la que referencia este registro; el
`datasheet.yaml` lleva el *provenance* autocontenido con URLs directas.

> **Encuadre.** SendGrid es una de las APIs modeladas en el TFM de Gavira Sánchez (dos
> versiones) y en el repositorio de la guía. Esta pasada la construye **desde las fuentes,
> sin consultar ese modelado previo** (Fase 0 que sugirió el tutor: interiorizar el formato
> sin mirar la solución). El contraste con el modelado previo queda para una pasada
> posterior y se registrará como [Fn] aparte, igual que se hizo con Resend.
>
> **Dos productos bajo la misma cuenta.** «Email API» y «Marketing Campaigns» se contratan
> por separado [F1][F7]. Lo modelado aquí es **solo el Email API** (regla A1 de
> `CRITERIOS.md`); el otro se documenta y va a F-10.
>
> **La web se ha mudado.** `sendgrid.com/pricing` redirige a `twilio.com`: *"SendGrid ❤️
> Twilio. We're finally moving in together on Twilio.com!"*. Las URLs de esta pasada son las
> de twilio.com; el centro de soporte sigue en `support.sendgrid.com`.

Volcados de cada página en `evidencias/paginas/2026-09-06/` (regla E2).

---

## [F1] Página de pricing del Email API

- **URL:** https://www.twilio.com/en-us/products/email-api/pricing
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - Resumen — `"Free trial lets you send 100 emails/day for 60 days"`, `"Essentials plan
    starts at $19.95 per month"`, `"Exact pricing depends on email send volume, features"`,
    `"Pro and premier plans include dedicated IPs, with option to purchase more"`
  - `"Pricing is determined by monthly email volume and features. Select your email volume
    below to see which plans are right for you."`
  - Free Trial — `"$0/mo for 60 days"`, `"Send 100 emails/day"`, `"No credit card, no commitment."`
  - Essentials — `"Starting $19.95/mo"`, `"Send 50,000 - 100,000 emails/mo"`
  - Pro — `"Starting at $89.95/mo"`, `"Send 100,000 - 2,500,000 emails/mo"`, `"Dedicated IPs
    included"`, `"Subuser management"`, `"Single sign-on (SSO)"`
  - Premier — `"Custom pricing"`, `"Need to send more? Talk to us for custom, high volume pricing."`
  - Los cuatro planes: `"Taxes and overages may apply"`
  - **Selector de volumen** (control «How many emails would you like to send per month?»,
    posiciones `<3,000 · 50,000 · 100,000 · 300,000 · 700,000 · 1,500,000 · 2,500,000 ·
    5,000,000+`). La tarjeta *Recommended* que muestra cada posición:

    | Posición | Tarjeta | Precio | Volumen |
    |---|---|---|---|
    | <3,000 | `"Free Trial"` | `"$0/mo for 60 days"` | `"Send 100 emails/day"` |
    | 50,000 | `"Essentials 50k"` | `"$19.95/mo"` | `"50,000 emails/mo"` |
    | 100,000 | `"Essentials 100k"` | `"$34.95/mo"` | `"100,000 emails/mo"` |
    | 50,000–100,000 | `"Pro 100k"` | `"$89.95/mo"` | `"100,000 emails/mo"` |
    | 300,000 | `"Pro 300k"` | `"$249.00/mo"` | `"300,000 emails/mo"` |
    | 700,000 | `"Pro 700k"` | `"$499.00/mo"` | `"700,000 emails/mo"` |
    | 1,500,000 | `"Pro 1.5M"` | `"$799.00/mo"` | `"1,500,000 emails/mo"` |
    | 2,500,000 | `"Pro 2.5M"` | `"$1,099.00/mo"` | `"2,500,000 emails/mo"` |
    | 5,000,000+ | `"Premier"` | `"Custom pricing"` | — |

  - **FAQ «What happens if I go over my email plan?»** — `"If you send more emails than your
    email plan allows within a given billing period, you will be charged a small overage
    fee on a per-email basis. Any overage fees are added to your invoice for the following
    billing period."`
  - **FAQ «API plans overage costs»** — `"The Free Trial plan covers storage of 100 contacts
    and sending 100 emails each day for 60 days. You can’t exceed these limitations."` y la
    tabla `"Plan | Plan email limit | Cost per extra email"`:

    | Plan | Plan email limit | Cost per extra email |
    |---|---|---|
    | Essentials 50K | 50,000 | $0.0013 |
    | Essentials 100K | 100,000 | $0.0009 |
    | Pro 100K | 100,000 | $0.0011 |
    | Pro 300K | 300,000 | $0.0009 |
    | Pro 700K | 700,000 | $0.0008 |
    | Pro 1.5M | 1,500,000 | $0.0006 |
    | Pro 2.5M | 2,500,000 | $0.0005 |
    | Pro 2.5M Legacy | 2,500,000 | $0.0005 |
    | Premier | Custom | |

  - `"If you created your SendGrid account through Heroku or Google Cloud, your subscription
    does not allow for overages."`
  - **FAQ «How do you measure the number of emails I send?»** — `"Every time you send one
    email to one recipient, it’s deducted as one email credit from your SendGrid Email API
    plan. This occurs whether the email is ultimately deferred or sent to spam by the inbox
    provider."` · `"Also note that emails you send via Marketing Campaigns will be counted
    separately from any emails you send via the SendGrid Email API."`
  - **FAQ «Do I have to sign up for the Marketing Campaigns and SendGrid Email API
    separately?»** — `"Yes! If you want to use Marketing Campaigns and the Email API, you
    will need to purchase the email plans separately."`
  - **FAQ «How does the free plan work?»** — `"Once you create a sender identity, you can send
    100 emails per day on our free SMTP plan."`
  - Tabla de características (Free Trial / Essentials / Pro / Premier):
    `"Dedicated IP Addresses"` — / — / `"1 included*"` / `"1 included*"`, con `"*You can
    purchase additional IPs as an add-on"`; `"Email Address Validation API"` — / — /
    `"2,500 free validations included"` / `"5,000 free validations included"`;
    `"Event Webhook"` `"1 included"` / `"2 included"` / `"5 included"` / `"5 included"`;
    `"Searchable Email Activity"` `"3 days included"` / `"3 days included"` / `"7 days of
    history"` / `"7 days of history*"` (`"*Not available to Premier 100M and above"`);
    `"Additional Email Activity History"` — / `"Available for purchase"` (×3);
    `"Email Content Testing"` — / — / `"60 credits/mo (more for purchase)"` / `"60 credits/mo
    (more for purchase)"`; `"Teammate Permissions"` `"1 teammate"` / `"1 teammate"` /
    `"1,000 teammates"` / `"1,000 teammates"`; `"Data Residency (EU)"` solo en Pro y Premier.
  - Add-on de créditos de prueba: `"30 Email Testing credits per month, available for $18.00
    USD"`, `"60 … $30.00 USD"`, `"100 … $40.000 USD"` (sic), `"500 … $200.00 USD"`,
    `"2,000 … $800.00 USD"`.
- **Observación crítica:** el «plan» se vende como **tier × volumen contratado**, y el
  nombre de la tarjeta lo dice literalmente (`"Essentials 50k"`, `"Pro 300k"`). El
  sobrecoste **baja al subir el volumen** dentro del mismo tier (Pro: de $0.0011 a $0.0005).
  Es F-02 y F-08 a la vez, y aquí **publicado en la página de precios**, como en Resend.
- **Observación:** el sobrecoste se publica ya como precio unitario por email, que es
  justo la normalización D-002 que este catálogo aplica; no hay que dividir por 1.000.

## [F2] Developer docs — Rate Limits (v3 API)

- **URL:** https://www.twilio.com/docs/sendgrid/api-reference/how-to-use-the-sendgrid-v3-api/rate-limits
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"Each Web API response includes rate-limit headers that indicate how many requests remain
    in the current refresh period. Each endpoint permits a fixed number of requests per
    refresh period. If you exceed that limit, the API returns an HTTP 429 (Too Many Requests)
    status code."`
  - Cabeceras del ejemplo: `"X-RateLimit-Limit: 500"`, `"X-RateLimit-Remaining: 499"`,
    `"X-RateLimit-Reset: 1392815263"`
  - `"When you reach a rate limit, you can no longer make requests against that endpoint for
    the remainder of the refresh period, and the API returns a 429 response."`
  - Cuerpo del 429: `"too many requests"`
- **Observación crítica:** la página dice que **cada endpoint tiene un límite fijo** y
  describe las cabeceras y el 429, pero **no publica ningún valor**: los `500` y `150` de
  los ejemplos son ilustrativos y ni siquiera coinciden entre sí. Es la forma exacta de
  F-01 en Postmark. El único caudal numérico publicado está en la FAQ de Mail Send [F5],
  y solo para ese endpoint.

## [F3] Developer docs — Mail Send API Overview

- **URL:** https://www.twilio.com/docs/sendgrid/api-reference/mail-send
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - Base — `"SendGrid's v3 Web API uses https://api.sendgrid.com for global users and subusers
    and https://api.eu.sendgrid.com for regional subusers in the EU."`
  - **Limitations** — `"The total size of your email, including attachments, must be less than
    30MB."` · `"The total number of recipients must be no more than 1,000. This includes all
    recipients defined within the to, cc, and bcc parameters, across each object that you
    include in the personalizations array."` · `"The total length of custom arguments must be
    less than 10,000 bytes."` · `"Unicode encoding is not supported for the from field."`
  - `"There is a limit of 1,000 reply_to_list emails per Mail Send request."`
  - Compresión — `"Mail body compression is available to some high volume accounts."` ·
    `"the gzip file can be no more than 30mb"` · `"The compressed data must also be less than
    the 30MB maximum for the email with headers, body, and attachments."` · `"Submit a request
    to support to have gzip enabled on your account."`
- **Observación crítica:** el tope de destinatarios es **por petición y total** (`to` + `cc` +
  `bcc`, sumando todas las *personalizations*). Es el dato que Postmark y Resend solo
  aclararon con sondeo (DISC-01, DISC-04); aquí está escrito. Y acota por arriba el
  producto N×M de F-03: 1.000 sobres × N destinatarios, pero **nunca más de 1.000 en
  total**.

## [F4] Developer docs — Mail Send (referencia del endpoint)

- **URL:** https://www.twilio.com/docs/sendgrid/api-reference/mail-send/mail-send
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"POST/v3/mail/send"` · `"Base url: https://api.sendgrid.com (for global users and
    subusers)"` · `"Base url: https://api.eu.sendgrid.com (for EU regional subusers)"`
  - `"Regional Email sending in the European Union (EU) is available for Twilio SendGrid Pro
    plan or above"`
  - `personalizations` — `"An array of messages and their metadata. Each object within the
    personalizations array can be thought of as a mail envelope"` · `"Max items: 1000"`
  - `reply_to_list` — `"Max items: 1000"` · `categories` — `"Max items: 10"` ·
    `custom_args` — `"Total custom_args size may not exceed 10,000 bytes."`
  - `send_at` — `"A send cannot be scheduled more than 72 hours in advance."`
  - `Content-Encoding` — `"Use this header when sending a gzip compressed mail body. Mail body
    compression is available to some high volume accounts."`
  - Autenticación — `"Authorization: Bearer <<YOUR_API_KEY_HERE>>"`
- **Observación:** la superficie del endpoint **cambia con el plan** (EU regional solo Pro o
  superior; gzip solo «some high volume accounts» y por solicitud). Alimenta F-08.

## [F5] Developer docs — v3 Mail Send FAQ

- **URL:** https://www.twilio.com/docs/sendgrid/for-developers/sending-email/v3-mail-send-faq
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"The v3 Mail Send endpoint is available on all SendGrid pricing plans. The same plan based
    limitations on the volume of email you may send still apply to the v3 Mail Send endpoint."`
  - **`"There are rate limits on how frequently you can call the v3 Mail Send endpoint. You may
    make up to 10,000 requests per second to the endpoint. Each email you send may include up
    to 1000 recipients."`**
  - `"Make an HTTP POST request to https://api.sendgrid.com/v3/mail/send"`
- **Observación crítica:** es el **único caudal numérico** que publica el proveedor, y solo
  para `/v3/mail/send`. No se condiciona al plan → regla D2: 🟢 en todos los planes que no
  lo contradigan. Para el resto de endpoints solo existe [F2], sin valor → F-01 parcial,
  como en Resend.

## [F6] Developer docs — Personalizations

- **URL:** https://www.twilio.com/docs/sendgrid/for-developers/sending-email/personalizations
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"Each API request has a limit of 1,000 personalization objects. To include more than
    1,000, divide the objects across multiple API requests."`
  - `"No email address in any of the to, cc, or bcc properties can repeat within the same
    personalizations array."`
  - `"Limit of 150 substitutions per personalization block."`
- **Observación:** cada *personalization* es un mensaje independiente con sus propios
  destinatarios; el lote y el envío individual son **el mismo endpoint**. No hay un
  `/batch` aparte como en Postmark o Resend.

## [F7] Centro de soporte — Twilio SendGrid Trial Account Plan

- **URL:** https://support.sendgrid.com/hc/en-us/articles/35270136965403-Twilio-SendGrid-Trial-Account-Plan
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"Beginning March 25, 2025 and when creating a new Twilio SendGrid account for email sending
    … users will be given a 60 day timed free trial plan."`
  - Email API — `"Send up to 100 email messages via web API or SMTP per day"` · `"Try most of
    the features related to the "Essentials" Email API plan"`
  - `"After the 60 day trial period, email send via any web API or SMTP integration for the
    account will stop unless an appropriate "Email API" plan is chosen before then"`
  - `"If an upgrade does not take place within the trial period for either plan, the plan will
    resolve to "end of trial" status and email send will stop."`
  - Baja de un plan de pago — `"Upon downgrading or canceling a paid plan for either Email API
    or Marketing Campaigns, this plan will have until the end of the month to use its features
    and email send functionality. At the turn of the month, the plan will be on the "end of
    trial" plan status which will not allow for email send"`
  - `"Existing free accounts or new accounts created through a partner platform (e.g. Microsoft
    Azure) may experience a difference in features and will be on their current plan"`
- **Observación crítica:** el plan gratuito **tiene fecha de caducidad** (60 días) y después
  la capacidad es cero: estado «end of trial». Ningún campo de v0.3 lo expresa → **F-14**
  (nueva). Y la baja de un plan de pago no devuelve a Free: cae al mismo estado.

## [F8] Centro de soporte — Twilio SendGrid Overage Rates

- **URL:** https://support.sendgrid.com/hc/en-us/articles/40779261694875-Twilio-SendGrid-Overage-Rates
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"Twilio charges a small amount for each email that you send exceeding your current plan’s
    limit. Any overage charges appear on the invoice for the month following any overage
    occurred."`
  - `"Upgrading your account doesn’t negate incurred overage charges."`
  - `"The Free Trial version plan covers storage of 100 contacts and sending 100 emails each
    day for 60 days. You can’t exceed these limitations."`
  - `"If you created your SendGrid account through Heroku or Google Cloud, your subscription
    does not allow for overages."`
- **Observación:** el artículo **no lleva la tabla de precios**: remite a la FAQ del pricing
  [F1]. Y la disponibilidad del sobrecoste depende del **canal de contratación**
  (Heroku / Google Cloud sin sobrecoste), un matiz que refuerza F-13.

## [F9] Developer docs — Responses (códigos de estado)

- **URL:** https://www.twilio.com/docs/sendgrid/api-reference/how-to-use-the-sendgrid-v3-api/responses
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"429 | Too many requests or rate limit exceeded | Yes"`
  - `"403 | From address doesn't match Verified Sender Identity | Yes"`
  - `"403 | You are temporarily blocked from sending emails due to repeated bad requests. | Yes"`
- **Observación:** hay un **bloqueo temporal por peticiones malformadas repetidas** (403),
  distinto del 429. Es un límite de comportamiento sin umbral publicado; se anota en
  `not_found`, no se modela.

## [F10] Developer docs — Sandbox Mode

- **URL:** https://www.twilio.com/docs/sendgrid/for-developers/sending-email/sandbox-mode
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"Sandbox mode is an optional parameter within mail_settings that validates a Mail Send
    request without delivering the email."`
  - `"Any requests made in sandbox mode will not generate events in either Event Webhook or
    Email Activity. No Credits will be consumed."`
  - `"When your request validates, you will receive a 200 OK response (as opposed to the 202
    ACCEPTED response that is returned for successful non-sandbox requests)."`
- **Observación:** hace **viable el escalón 3 sin gastar cuota ni dominio**: una petición
  con 1.001 destinatarios en sandbox debe devolver el error de validación. Ver REVISION.md.

## [F11] Changelog — Changes coming to SendGrid’s Free Plan

- **URL:** https://www.twilio.com/en-us/changelog/sendgrid-free-plan
- **Fecha de acceso:** 2026-09-06 (entrada fechada `"May. 27, 2025"`)
- **Citas literales:**
  - `"Twilio SendGrid will be retiring its Free Email API and Free Marketing Campaigns plan
    starting May 27, 2025."`
  - `"After the 60-day transition period: Email sending will be paused for accounts on all free
    plans"`
  - `"These changes do not impact any paid SendGrid plans– those will continue as usual."`
- **Observación:** el plan Free permanente **desapareció en 2025** y lo sustituye la prueba
  de 60 días. Cualquier modelado de SendGrid anterior a esa fecha describe un plan que ya
  no existe → evidencia de F-09 (vigencia por dato) cuando se haga el contraste con el
  modelado previo.

## [F12] Panel de cuenta — observación con cuenta propia (escalón 2)

- **Fecha de acceso:** 2026-09-06
- **Cuenta:** Free Trial (Email API y Marketing Campaigns), creada el mismo día, sin identidad
  de remitente ni dominio autenticado. Modo lectura: sin cambios de plan, sin add-ons, sin
  claves.
- **Evidencia:** `evidencias/panel_planes_freetrial_2026-09-06.jpg`,
  `evidencias/panel_escalera_volumen_2026-09-06.jpg`,
  `evidencias/paginas/2026-09-06/app_sendgrid_com_account_products.txt`,
  `evidencias/paginas/2026-09-06/app_sendgrid_com_account_products_addons.txt`,
  `evidencias/paginas/2026-09-06/app_sendgrid_com_account_billing_choose_plan.txt`,
  `evidencias/paginas/2026-09-06/app_sendgrid_com_guide.txt` (volcado de texto de
  cuatro pantallas; la captura de pantalla falló en dos de ellas por un cuelgue de la
  extensión, el texto es la evidencia; nombres corregidos el 2026-09-07, antes se citaba un
  fichero inexistente).
- **Citas literales (Settings → Account Details → Your Products):**
  - Email API — `"Free Trial"`, `"100 emails/day"`, `"$0.00"`, `"0 emails sent today"`,
    `"100 left"`, `"Upgrade your plan to send more than 100 emails/day."`
  - **`"Your plan will be downgraded to End Of Trial on November 5, 2026. This change will be
    reflected on your November invoice."`** (cuenta creada el 2026-09-06: 60 días exactos)
  - Marketing Campaigns — `"Up to 100 contacts and 100 marketing emails/day"`, contadores
    independientes: `"0 unique contacts stored this month"`, `"0 marketing emails sent today"`
  - Add-ons — `"No Add-ons Purchased"` · `"Due to your plan downgrade, all add-ons will be
    removed on November 5, 2026."`
- **Citas literales (Email API Plans, `/account/billing/choose_plan`):**
  - Free — `"3 Days of Email Activity History"`, `"1 Event Webhook"`, `"No Access to Email
    Testing"`, `"No Access to Email Validation"`, `"No Access to Dedicated IPs"`, `"No
    Subuser Management"`, `"No Regional Data Residency"`
  - Essentials — `"2 Event Webhooks"`, el resto igual que Free; tarjetas
    **`"Essentials 50K — $19.95/month * — 50.000 emails/month + $0.00133 per additional
    email"`** y `"Essentials 100K — $34.95/month * — 100.000 emails/month + $0.0009 per
    additional email"`
  - Pro — `"7 Days of Email Activity History"`, `"5 Event Webhooks"`, `"60 Email Testing
    Credits"`, `"2,500 Email Validations"`, `"Dedicated IP Included 🎉"`, `"Subuser
    Management"`, `"Regional Data Residency"`; tarjetas `"Pro 100K — $89.95/month * —
    100.000 emails/month + $0.0011 per additional email"`, **`"Pro 300K — $249.00/month * —
    300.000 emails/month + $0.00091 per additional email"`**, **`"Pro 700K — $499.00/month *
    — 700.000 emails/month + $0.00078 per additional email"`**, **`"Pro 1.5 Million —
    $799.00/month * — 1.500.000 emails/month + $0.00059 per additional email"`**,
    **`"Pro 2.5 Million — $1,099.00/month * — 2.500.000 emails/month + $0.00047 per
    additional email"`**
  - Premier — `"500 Email Testing Credits"`, `"5,000 Email Validations"`, `"Contact Sales"`
  - `"*Taxes may apply"`
- **Citas literales (Add-ons, `/account/products/addons`):**
  - `"Additional Dedicated IP Addresses — $30/month* each"` · `"Note: You have 0 dedicated IP
    included with your plans"`
  - `"Additional Email Testing Credits — Monthly credit bundles starting at $18/month*"` ·
    `"Upgrade to a paid Email API plan or a paid Marketing Campaigns plan for this add-on."`
  - `"Email Address Validation — Pricing varies per plan and volume."` · `"Upgrade to an Email
    API Pro plan for this add-on."`
- **Observaciones sin cita (estructura del panel):**
  - La sección *Email API* del menú tiene **Dynamic Templates, Legacy Templates e Integration
    Guide**; **no hay formulario de envío**. El único envío desde la interfaz es *Single
    Sends*, dentro de *Marketing*. → `type: api_first` sobre el producto modelado (C1).
  - El contador diario dice `"sent today"`: reposición por día natural, **sin hora ni zona
    horaria publicadas**.
  - **El panel no muestra el caudal** ni ningún registro de 429.
  - Aviso permanente: `"Before sending your first email, you'll need to create a sender
    identity."` — sin identidad verificada no se puede enviar (afecta al escalón 3).

## [F13] Developer docs — Integrating with the SMTP API *(señalada por el verificador)*

- **URL:** https://www.twilio.com/docs/sendgrid/for-developers/sending-email/integrating-with-the-smtp-api
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"When using SMTP to send emails through SendGrid, it's essential to be aware of the
    following rate limits:"` · `"You may send up to 5k messages per SMTP connection."` ·
    `"You may open up to 10k concurrent connections from a single server."`
  - `"SendGrid recommends setting your server host to smtp.sendgrid.net"`
- **Observación:** el canal SMTP tiene **caudal publicado** —el único además del de
  `/v3/mail/send`— y es un límite de **concurrencia** (conexiones), dimensión que v0.3 no
  modela. Consume la misma cuota que la API (`"via web API or SMTP"` [F7]).

## [F14] Developer docs — Building an X-SMTPAPI Header *(señalada por el verificador)*

- **URL:** https://www.twilio.com/docs/sendgrid/for-developers/sending-email/building-an-x-smtpapi-header
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"There is a hard limit of 10,000 addresses in a multiple recipient email. However, the
    best practice is to split large jobs into separate transactions of approximately 1,000
    recipients, which allows better processing load distribution."`
- **Observación crítica:** el tope de 10.000 direcciones es de la cabecera X-SMTPAPI, no del
  relé SMTP en general: la página lo da entre lo que hay que vigilar al usar la cabecera
  (`"However, there are several things to keep in mind when using the header."`). Un mensaje
  SMTP sin la cabecera no tiene tope de destinatarios publicado en las páginas de SMTP
  consultadas, así que la cifra no es el equivalente SMTP de los 1.000 de la API [F3].
  Corregido el 2026-10-31: hasta esa fecha esta observación lo leía como tope del relé y lo
  llevaba a **F-15**.

## [F15] Developer docs — Email Activity: Filter all messages *(señalada por el verificador)*

- **URL:** https://www.twilio.com/docs/sendgrid/api-reference/email-activity/filter-all-messages
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"To gain access to the Email Activity Feed API, purchase additional email activity history."`
  - `limit` — `"This parameter must be greater than 0 and less than or equal to 1000"` ·
    `"Combine up to 160 filter conditions per request."`
- **Observación:** un endpoint entero (`/v3/messages`) **cerrado tras un add-on**, con
  límites de consulta propios (RPR, F-05). Es la forma más nítida de F-08 vista hasta ahora:
  la superficie de la API no depende del tier sino de una compra aparte.

## [F16] Developer docs — Email Activity Feed *(señalada por el verificador)*

- **URL:** https://www.twilio.com/docs/sendgrid/ui/analytics-and-reporting/email-activity-feed
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"If you purchase the Email Activity history add-on, the feed retains events for up to 30 days."`
- **Observación:** el add-on cambia la retención de 3/7 días a 30; sin precio publicado.

## [F17] Developer docs — Real Time Email Address Validation *(señalada por el verificador)*

- **URL:** https://www.twilio.com/docs/sendgrid/api-reference/email-address-validation/validate-an-email
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"Email Address Validation is available to Email API Pro and Premier level accounts only."`
  - `"There is a limit of 50 sources. Sources are automatically deleted once the last
    validation to use that source falls off the 30 day window."`
- **Observación:** otro endpoint que solo existe desde Pro (F-08) y un límite de recursos
  (50 fuentes, F-11).

---

## Verificación adversarial independiente — 2026-09-06

Un segundo agente, con acceso **solo al `datasheet.yaml` final**, volvió a abrir cada URL
pública y contrastó cita a cita y valor a valor (D-013, `docs/10-revision-automatica.md`).
Resultado sobre las 35 líneas con URL pública de la primera versión: **34 coinciden
literalmente**, ninguna ha cambiado, y la del selector de volumen no es reproducible sin
ejecutar el JavaScript de la página (el panel [F12] la corrobora). Las 8 líneas de
`app.sendgrid.com` no son verificables sin cuenta. Lo que el verificador encontró y el
constructor no había visto —SMTP [F13][F14], actividad [F15][F16], validación [F17], el
quinto paquete de créditos con errata y las 150 sustituciones— se incorporó en la misma
tanda. Sus objeciones de semáforo se resolvieron así: `window_type` del límite diario
**vaciado** (regla D3: ninguna fuente dice cómo se repone), tope de 30 MB **a ámbar** (es
estricto, `"less than"`), y el caudal de 10.000 rps se **mantiene en verde** en los cuatro
planes por la regla D2 (valor único no condicionado al plan). El `period: 1 MONTH` de la
prueba se mantiene porque `"$0/mo for 60 days"` es literal y los 60 días son la vigencia,
no el ciclo: eso es F-14, no un error de modelado. Informe completo en `REVISION.md`.

## [E1] Sondeo empírico en modo sandbox — escalón 3

- **Fecha:** 2026-09-06, 20:46 UTC. Ejecutado por el autor en su máquina con la clave de la
  cuenta Free Trial (`probe_sendgrid_sandbox.sh BCD`, en `05_salida/_herramientas/`).
- **Coste:** cero. Los envíos llevan `mail_settings.sandbox_mode.enable: true` (la API
  valida y no entrega, *"No Credits will be consumed"* [F10]); el resto son `GET`.
  Contador tras el sondeo: `"used": 0`.
- **Evidencia:** `evidencias/probe_sandbox_destinatarios_ratelimits_2026-09-06.json`
  (clave, correo, id de usuario e id de clave redactados).
- **Citas literales (cuerpos de respuesta y cabeceras):**
  - B1 (1 sobre, 1.000 en `to`) → `200`. B3 (2 sobres de 500) → `200`.
  - B2 (1 sobre, 1.001 en `to`), B4 (500 + 501 en dos sobres), B5 (500 `to` + 501 `cc`) →
    `400` · `"There is a limit of 1000 total recipients (to + cc + bcc) per mail/send
    request."` · `"field": "personalizations"`
  - B6 (1.001 sobres de 1) → `400` · `"The personalization block is limited to 1000
    personalizations per API request. You have provided 1001 personalizations. Please
    consider splitting this into multiple requests and resending your request."`
  - Ninguna respuesta de `/v3/mail/send` lleva cabeceras `x-ratelimit-*`.
  - C1 `/v3/user/profile`, C2 `/v3/api_keys`, C5 `/v3/scopes` → `"x-ratelimit-limit: 600"`,
    `"x-ratelimit-remaining: 599"`, `"x-ratelimit-reset"` = `9`, `6`, `58` (segundos).
  - C3 `/v3/templates`, D1 `/v3/user/credits`, D2 `/v3/user/account` →
    `"x-ratelimit-limit: 600"`, `"x-ratelimit-reset"` = `1788727620`, `1788727680` (marcas
    Unix: 20:47:00 y 20:48:00 UTC, los minutos exactos siguientes a cada llamada).
  - C4 `/v3/messages?limit=1` → `200` `{"messages": []}` · `"x-ratelimit-limit: 6"`,
    `"x-ratelimit-remaining: 5"`, `"x-ratelimit-reset: 1"`.
  - D1 `/v3/user/credits` → `{"is_hard_limit": true, "last_reset": "2026-09-01",
    "next_reset": "2026-09-02", "overage": 0, "remain": 100, "reset_frequency": "daily",
    "total": 100, "used": 0}`
  - D2 `/v3/user/account` → `{"is_reseller_customer": false, "reputation": 100, "type": "free"}`
- **Qué cierra:**
  - El tope de **1.000 destinatarios en total** por petición, sumando campos y sobres
    (verde por documentación [F3] y ahora por medición; O-06 queda respondida: la OpenAPI
    no lo declara pero la API lo aplica).
  - **F-01 para los endpoints de lectura:** 600 peticiones por ventana fija de un minuto
    en seis endpoints; 6 por ventana en `/v3/messages`. Valores que la documentación no
    publica.
  - **F-13:** `"is_hard_limit": true` — la propia API declara que la cuota de la prueba es
    tope duro.
  - La ventana del límite diario **es diaria y por fecha** (`reset_frequency: daily`,
    `next_reset` sin hora): no es *rolling*. Hora y zona siguen sin publicarse →
    `window_type: fixed_utc_midnight` en 🟡 (antes vacío).
- **Qué destapa y no cierra:**
  - `last_reset`/`next_reset` traen `2026-09-01`/`2026-09-02` en una cuenta creada el
    2026-09-06: el campo **no está al día**. La API expone una fecha de reposición que no
    es la real.
  - `x-ratelimit-reset` significa **segundos restantes** en unos endpoints y **marca de
    tiempo Unix** en otros (la documentación [F2] solo muestra la segunda). Anotado como
    **O-07**.
  - `/v3/messages` responde `200` a la cuenta de prueba aunque [F15] diga que el acceso a
    la Email Activity Feed API requiere comprar el add-on. Puede que la restricción sea
    sobre el historial y no sobre el endpoint; **candidato a F-04**, sin confirmar.
  - El caudal de `/v3/mail/send` no es observable: sin cabeceras, los 10.000 rps de [F5]
    solo se contrastarían con una campaña de carga (fuera del encargo).

## [E2] Sondeo empírico — tamaño máximo de la petición en sandbox

- **Fecha:** 2026-09-07, 22:04–22:06 UTC · **Ejecutado por:** el agente en la máquina del autor
  con la clave de la cuenta Free Trial (`~/.config/tfm/.env`). Scripts
  `05_salida/_herramientas/probe_sendgrid_tamano_30mb.sh` (29, 30 y 31 MiB de texto) y una
  bisección por bytes totales del JSON. `mail_settings.sandbox_mode.enable: true`: SendGrid
  valida y no envía; coste 0.
- **Evidencia:** `evidencias/probe_tamano_30mib_2026-09-07.json` y
  `evidencias/probe_tamano_30mib_biseccion_2026-09-07.json`.
- **Resultado literal:** JSON de 30.000.000, 31.000.000 y **31.457.280 bytes** (30 MiB
  exactos) → HTTP 200 sin cuerpo (aceptado en sandbox). JSON de **31.457.281 bytes** y de
  31.500.000 → HTTP 413 `413 Request Entity Too Large` con página de **nginx**: lo corta el
  proxy antes de llegar a la aplicación, sin JSON de error.
- **Lo que cierra:** el «less than 30MB» de [F3] es en la práctica «hasta 30 MiB inclusive»
  medido sobre el cuerpo de la petición. `max: 30` (MBs) pasa de 🟡 a 🟢 en los cuatro planes:
  el esquema no distingue `<` de `≤`, pero el dato real es `≤ 30 MiB`, así que el valor 30 es
  exacto y la duda de Q6 desaparece por medida, no por criterio.
- **Matiz:** la doc habla del «total size of your email, including attachments»; lo medido es
  el tamaño de la petición HTTP (texto plano, sin adjuntos base64). Para adjuntos el límite
  efectivo de contenido es menor porque base64 infla un 33 %; el tope del proxy es el mismo.
  Fricción candidata: el proveedor documenta un límite de correo y aplica un límite de
  petición (F-06, otra métrica).

## [F18] Centro de soporte — Understanding the "Maximum Credits Exceeded" error *(pasada documental 2)*

- **URL:** https://support.sendgrid.com/hc/en-us/articles/35466138799899-Understanding-the-Maximum-Credits-Exceeded-error
- **Fecha de acceso:** 2026-09-06 (búsqueda dirigida a cerrar los ámbar de ventana)
- **Citas literales:**
  - `"These accounts have a daily 100-credit limit."`
  - **`"If your account is under the Email API Free Trial version plan, please wait until the
    next day (UTC time) for the credit count to reset."`**
  - **`"Starting March 26, 2026, a sending limit was applied to accounts under the Email API
    Essentials and Pro plans, capping their allotment to 10X times the plan. For example, if
    your account is under the Email API Essentials 50K plan, you can send up to 500,000
    requests to our server throughout the month."`**
  - `"The rationale behind this cap is the same than the one for Reseller accounts: it is in
    our customer's best interest to upgrade to a higher volume plan than to continue paying
    overages."`
  - Reseller — `"these accounts have an artificial credit limit, that is 2.5X times the plan
    allotment. For example, if your reseller account is under the Email API Pro 100k plan,
    the credit limit is set to 250K."`
  - `"SendGrid is a service that is paid in advance, so if you upgrade, an invoice for the
    prorated charges will be generated. The credit limits are removed once the payment is
    confirmed."`
  - `"Keep in mind that Requests = Processed + Dropped."`
- **Qué cierra:** la ventana diaria de la prueba → **día UTC**, `fixed_utc_midnight` en 🟢
  (la hora en punto no se dice; se toma la medianoche). La ventana mensual de Essentials y
  Pro → `"throughout the month"`, junto con [F19], 🟢.
- **Qué destapa:** el sobrecoste **tiene tope** (10 × el volumen contratado desde el
  2026-03-26; 2,5 × en cuentas de reseller). No está en la página de precios ni en el
  artículo de sobrecostes [F8]: está en un artículo de resolución de errores → **F-16**.
  Y una fecha de cambio de política dentro de 2026 → evidencia de F-09.

## [F19] Twilio docs — Error 60603: SendGrid maximum credits exceeded *(pasada documental 2)*

- **URL:** https://www.twilio.com/docs/api/errors/60603
- **Fecha de acceso:** 2026-09-06
- **Citas literales:**
  - `"Your SendGrid Email API account is on a free trial or end-of-trial plan and has reached
    its available daily credits."`
  - **`"Your SendGrid Email API plan has reached its sending limit for the current billing
    period."`**
  - `"If your account is on a free trial or end-of-trial plan, wait for the limit to reset if
    you are still within the trial allowance, or upgrade the Email API plan."`
- **Qué cierra:** el volumen de los planes de pago se aplica **por ciclo de facturación**
  (`"current billing period"`), que con [F1] (`"within a given billing period"`) y [F18]
  (`"throughout the month"`) sube `fixed_billing_cycle` a 🟢 en Essentials y Pro. Premier
  se queda en 🟡: condiciones a medida.

---

## [F21] Developer docs — operaciones 4 a 8 del test de `type` (C2)

- **URLs:** `/docs/sendgrid/api-reference/api-keys/create-api-keys` (4) ·
  `/docs/sendgrid/api-reference/webhooks/create-an-event-webhook` (5) ·
  `/docs/sendgrid/api-reference/settings-inbound-parse/create-a-parse-setting` (6) ·
  `/docs/sendgrid/api-reference/suppressions-global-suppressions/add-recipient-addresses-to-the-global-suppression-group`
  y `/docs/sendgrid/api-reference/bounces-api/retrieve-all-bounces` (7) ·
  `/docs/sendgrid/api-reference/email-activity/filter-all-messages` (8), todas bajo
  `https://www.twilio.com`
- **Fecha de acceso:** 2026-09-14
- **Origen:** lectura de la referencia con el navegador del autor; sin volcado propio (D-023).
  El de la operación 8 sí lo tiene, de la pasada del 06-09
  (`evidencias/paginas/2026-09-06/www_twilio_com_docs_sendgrid_api_reference_email_activity_filter_all_messages.txt`)
- **Citas literales, una por operación:**
  - **(4) credenciales adicionales** — `"POST /v3/api_keys"`; con Update API key name and
    scopes y Delete API keys
  - **(5) webhooks** — `"POST /v3/user/webhooks/event/settings"`, `"This endpoint allows you to
    create a new Event Webhook."`; con Update, Delete y Toggle Signature Verification
  - **(6) inbound routing** — `"POST /v3/user/webhooks/parse/settings"` (Inbound Parse), con
    Retrieve, Update y Delete de la misma configuración
  - **(7) supresiones y rebotes** — `"POST /v3/asm/suppressions/global"` y
    `"GET /v3/suppression/bounces"`, con su Delete
  - **(8) actividad y logs** — `"GET /v3/messages"`, la Email Activity Feed API
- **Observación (el matiz de la 8, no eliminatorio).** La operación existe en la API, pero
  **cobrada aparte**: `"To gain access to the Email Activity Feed API, purchase additional
  email activity history."` [F15], mientras el panel da 3 días de actividad dentro del plan
  [F16]. No cambia el `type` —la 8 no es eliminatoria—, y no es fricción nueva: es **F-08** ya
  registrada en esta API, el endpoint entero detrás de un add-on. Las otras cuatro no dejan
  nada solo en el panel.

## [F22] Panel de cuenta — operaciones 4 a 8 del test de `type` (escalón 2)

- **Fecha de acceso:** 2026-09-14
- **Cuenta:** la propia del autor, **Free Trial** (`"Your free trial ends on November 5th, 2026."`),
  sin identidad de remitente creada. Modo lectura: no se creó, editó ni borró ninguna clave, no
  se compró el add-on y no se pulsó `Upgrade`; se cerró un modal informativo de «Email Logs» para
  leer la página de debajo
- **Evidencia:** `evidencias/panel_operaciones_c2_2026-09-14.md` (volcado de texto; sin captura,
  y sin transcribir correo, nombre de clave ni su identificador)
- **Citas literales:**
  - Settings → API Keys: `"Create API Key"`, `"Edit API Key"`, `"Delete API Key"`
  - Settings → Mail Settings → Webhook Settings: `"Event Webhooks"`, `"Allows notifications for
    events, such as bounces, clicks, and opens to be POSTed to a specified URL."`
  - Activity → Activity Feed: `"Retrieve information about every email you've sent in the past 3
    days by clicking "Search"."` y `"Up to 30 days of history is available for purchase."`
  - Suppressions, seis listas: Global Unsubscribes, Group Unsubscribes, Bounces, Spam Reports,
    Blocks, Invalid. Settings incluye `Inbound Parse`
- **Observación (la operación 8, medida en los dos lados).** El panel da la actividad **con 3
  días incluidos en el plan**; la API la cobra aparte —`"To gain access to the Email Activity
  Feed API, purchase additional email activity history."` [F15]—. Es decir: con esta cuenta, la
  operación **existe en la web y no en la API**. Es la forma que C2 castiga, pero la 8 **no es
  eliminatoria**, así que el `type` sigue `api_first`; la asimetría se anota y refuerza **F-08**,
  el endpoint entero detrás de un add-on. Las otras cuatro están en los dos lados.

## Discrepancias entre fuentes

### DISC-01 · El sobrecoste tiene más decimales dentro del panel que en la página pública

- **Pricing [F1], 2026-09-06:** `"Essentials 50K | 50,000 | $0.0013"`, `"Pro 300K | $0.0009"`,
  `"Pro 700K | $0.0008"`, `"Pro 1.5M | $0.0006"`, `"Pro 2.5M | $0.0005"`.
- **Panel [F12], 2026-09-06:** `"$0.00133"`, `"$0.00091"`, `"$0.00078"`, `"$0.00059"`,
  `"$0.00047"` para los mismos volúmenes. Coinciden Essentials 100K (`$0.0009`) y Pro 100K
  (`$0.0011`).

No es un cambio de oferta: son **las mismas cifras redondeadas a cuatro decimales** en la
página pública. La diferencia es de hasta un 6 % (0.00047 frente a 0.0005).

**Historia.** Resuelta por el autor (chat, 2026-09-06) a favor del panel, en 🟢, porque es el que
se factura y el panel es fuente oficial; el público quedó en el provenance. De ahí salió la
regla D5 de `CRITERIOS.md`.

**Reabierta y cerrada por D17 (D-068, 2026-10-18).** El pricing define la verdad, sin
excepción por precisión: va el valor de la página, **$0.0013 en 🟢**, literal de [F1]. Las
cifras del panel quedan aquí y en el provenance como **incoherencia del pricing**. Supuesto de
cierre: E5 (2), manda una regla escrita. D5 queda acotada a los pares sin la página de precios.

- **Efecto declarado:** excluyente (D11) · cerrada por D17; `overage_cost.price` de Essentials
  en 🟢 con el valor de la página.

### DISC-02 · Créditos de prueba de Premier: 60 en el pricing, 500 en el panel

- **Pricing [F1]:** `"Email Content Testing — 60 credits/mo (more for purchase)"` en Pro
  **y en Premier**.
- **Panel [F12]:** Pro `"60 Email Testing Credits"`, Premier **`"500 Email Testing Credits"`**.

Límite de recursos, no de consumo (regla B3): no entra en `capacity`. Se registra en el
provenance con las dos cifras.

**Cerrada por D17 (D-068, 2026-10-18).** Gana la página de precios: Premier lleva **60
créditos al mes**, como Pro. El `"500 Email Testing Credits"` del panel queda como
**incoherencia del pricing**. Supuesto de cierre: E5 (2). No cambia ningún valor del YAML,
porque el dato no se modela; cambia la línea del provenance y la celda de `features.md`.

- **Efecto declarado:** excluyente · campo sin valor

### DISC-03 · Plantillas dinámicas: la página distingue «testing» por plan, el panel no

- **Pricing [F1], 2026-09-06:** `"Dynamic templates:"` `"Editor"` en Free Trial y en
  Essentials; `"Dynamic templates:"` `"Editor and testing"` en Pro y en Premier (volcado
  `evidencias/paginas/2026-09-06/www_twilio_com_en_us_products_email_api_pricing.txt`,
  líneas 42–43, 61–62, 83–84 y 102–103). Unidad: la celda con su encabezado de tarjeta.
- **Panel [F12], 2026-09-06:** `"Dynamic Template Editor"` en las cuatro tarjetas (Free,
  Essentials, Pro, Premier), sin mención a «testing» en ninguna.

Registrada el 2026-10-18 al rellenar la fila de plantillas de `features.md`, que hasta ese día
solo tenía la celda de la prueba gratuita. **Cerrada por D17 (D-068, 2026-10-18):** la
matriz toma lo que dice la página, «Editor» en los dos primeros planes y «Editor and testing»
en los dos de arriba. Que el panel no nombre el *testing* en Pro y Premier queda como
**incoherencia del pricing**. Supuesto de cierre: E5 (2).

- **Efecto declarado:** no excluyente en sentido estricto —el panel calla el *testing*, no lo
  niega— · campo sin valor

---

## Fuentes buscadas y NO encontradas

| Qué se buscó | Dónde | Resultado |
|---|---|---|
| Valor numérico del rate limit de los endpoints REST distintos de `/v3/mail/send` | [F2], [F9], [F15], [F17] | **No publicado.** Solo las cabeceras `X-RateLimit-*` y el 429; los valores de los ejemplos (`500`, `150`) son ilustrativos. El canal SMTP sí publica el suyo [F13]. **Medido en [E1]:** 600/min en seis endpoints de lectura, 6 por ventana en `/v3/messages` |
| Caudal real de `/v3/mail/send` | [E1] | **No observable:** la respuesta no lleva cabeceras `X-RateLimit-*`. Los 10.000 rps de [F5] quedan como dato documental |
| Tamaño máximo de mensaje por SMTP | [F13], [F14] | **No publicado**; los 30 MB solo constan para `/v3/mail/send` e Inbound Parse |
| Si el caudal de 10.000 rps de [F5] es por cuenta, por clave o por subusuario | [F5], [F2], [F3] | **No dicho.** [F2] habla de «each endpoint», no de segmentación |
| Duración del «refresh period» de los rate limits | [F2] | **No publicada.** Solo `X-RateLimit-Reset` como timestamp |
| Hora o zona horaria de reposición del límite diario de la prueba | [F1], [F7], [F12], [E1], [F18] | **Resuelto en [F18]:** `"next day (UTC time)"`. Queda sin decir la hora en punto; se toma la medianoche UTC |
| Umbral del bloqueo temporal por «repeated bad requests» (403) | [F9] | **No publicado** |
| Qué es «some high volume accounts» para activar gzip | [F3], [F4] | **No publicado**; por solicitud a soporte |
| Precio y volumen de Premier, y de `"Premier 100M and above"` | [F1], [F12] | **No publicados**: `"Contact sales"` |
| Precio del add-on «Additional Email Activity History» | [F1], [F12] | **No publicado** en las páginas consultadas (`"Available for purchase"`) |
| Precio del add-on de validación de direcciones | [F12] | `"Pricing varies per plan and volume"`, sin cifra en las páginas consultadas |
| Si Inbound Parse (recepción) consume la cuota de envío (F-12) | [F1], [F3] | **No encontrado** en las páginas consultadas |
| Especificación OpenAPI (`twilio/sendgrid-oai`, `spec/json/tsg_mail_v3.json`) | consultada por el verificador | `personalizations`, `cc` y `bcc` con `maxItems: 1000`; **`to` sin `maxItems`**; sin mención a 30 MB ni a rate limits. El tope total de 1.000 solo está en prosa [F3] |
| Modelado previo de SendGrid en el repositorio de la guía y en el TFM de Gavira | — | **Deliberadamente no consultado** (Fase 0). El autor (chat, 2026-09-06): tarea pendiente para otra pasada, como [F20] |
