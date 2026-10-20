# Fuentes — Postmark

API de correo transaccional. Proveedor: ActiveCampaign (Wildbit).
Recolección: 2026-08-02 (pasada 1) · **2026-08-03 (pasada 2, cobertura completa)**.
Toda cita es literal. La numeración [Fn] es la que referencia `datasheet.yaml`.

---

## [F1] Página de pricing

- **URL:** https://postmarkapp.com/pricing
- **Fecha de acceso:** 2026-08-03 (re-verificada; primera visita 2026-08-02)
- **Citas literales:**
  - Free — `"$0.00/mo"`, `"100 emails/month"`, `"No overages allowed in this plan"`,
    `"Testing your integration"`
  - Basic — `"$15.00/mo"`, `"Starting at 10,000 emails/month"`,
    `"Extra emails @ $1.80 / 1,000"`
  - Pro — `"$16.50/mo"`, `"Starting at 10,000 emails/month"`,
    `"Extra emails @ $1.30 / 1,000"`, añade `"Inbound email processing"`
  - Platform — `"$18.00/mo"`, `"Starting at 10,000 emails/month"`,
    `"Extra emails @ $1.20 / 1,000"`
  - Add-ons — Dedicated IPs: `"Starts at $50/month per IP"`, requisito
    `"sending 300,000 emails per month or more"` · Custom Activity Retention:
    `"Starts at $5/month"` · DMARC Monitoring: `"Starts at $14/month per domain"`
- **Observaciones:** no hay planes anuales ni tabla pública de escalones tras el
  "Starting at 10,000" (ver F-02). Los add-ons modifican dimensiones de capacidad
  (ver F-07).

## [F2] Developer docs — API Overview

- **URL:** https://postmarkapp.com/developer/api/overview
- **Fecha de acceso:** 2026-08-03 (re-verificada; primera visita 2026-08-02)
- **Citas literales:**
  - `"429 — Rate Limit Exceeded"` → `"We have detected that you are making requests
    at a rate that exceeds acceptable use of the API."`
  - `"The request exceeded Postmark's size limit of 10 MB for our Email API"`
  - `"50 MB total payload size for our Batch Email API"`
  - `"410 — Too many batch messages"` → `"Your batched request contains more than
    500 messages."`
  - Autenticación: `X-Postmark-Server-Token` — `"Used for requests that require
    server level privileges"`; `X-Postmark-Account-Token` — `"Used for requests
    that require account level privileges"`. Token de pruebas: `POSTMARK_API_TEST`.
- **Observación crítica:** el 429 existe pero **no se publica ningún umbral
  numérico** (F-01). La segmentación de límites (¿por servidor o por cuenta?)
  tampoco está documentada.

## [F3] Developer docs — Email API

- **URL:** https://postmarkapp.com/developer/api/email-api
- **Fecha de acceso:** 2026-08-03 (re-verificada; primera visita 2026-08-02)
- **Citas literales:**
  - To — `"Recipient email address. Multiple addresses are comma separated. Max 50."`
  - Cc — `"Cc recipient email address. Multiple addresses are comma separated. Max 50."`
  - Bcc — `"Bcc recipient email address. Multiple addresses are comma separated. Max 50."`
  - `/email/batch` — `"accepts up to 500 messages per API call, and up to 50 MB
    payload size, including attachments."`
  - MessageStream — `"If not provided, message will default to the 'outbound'
    transactional stream."`
- **Observación:** el "Max 50" se declara POR CAMPO. Si el tope conjunto por
  petición es 50 o 150 no está aclarado (Q2 de REVISION.md).

## [F4] Developer docs — Messages API

- **URL:** https://postmarkapp.com/developer/api/messages-api
- **Fecha de acceso:** 2026-08-03
- **Citas literales:**
  - `GET /messages/outbound`, parámetro `count` — `"Number of messages to return
    per request. Max 500. Count + Offset cannot exceed 10,000 messages."`
  - `GET /messages/inbound`, parámetro `count` — ídem literal.
  - Recomendación de paginación por fechas (`fromdate`/`todate`) para superar el
    tope combinado de 10.000.
- **Observación crítica:** dimensión **Results Per Request** documentada con dos
  estructuras (máximo por petición + profundidad total de paginación). ACM la
  define; ACM2YAML v0.3 no la serializa (F-05).

## [F5] Página de producto — Bulk Email API

- **URL:** https://postmarkapp.com/bulk-api
- **Fecha de acceso:** 2026-08-03
- **Citas literales:**
  - `"All bulk email sends through our dedicated Broadcast infrastructure.
    Separate IPs, separate reputation from your transactional messages."`
  - `"as many recipients as you need, as long as your total payload (including
    attachments) stays under 50 MB"`
  - `"Right now, the Bulk API works with Broadcast Streams only."`
  - `"No additional fees. Every message sent through the Bulk API counts toward
    your monthly email limit, just like any other message."`

## [F6] Developer docs — Bulk Email API

- **URL:** https://postmarkapp.com/developer/api/bulk-email
- **Fecha de acceso:** 2026-08-03
- **Citas literales:**
  - Endpoint: `POST /email/bulk`
  - Destinatarios por mensaje: `"Multiple addresses are comma-separated. Max 50."`
  - `"stay within the 50 MB payload size limit, including attachments"`
  - Stream por defecto: `"If not provided, message will default to the outbound
    broadcast stream."`
  - Ritmo de envío: `"Postmark will optimize the sending speed for you"`
- **Observaciones:** producto en acceso anticipado (existe artículo de soporte
  "The early access program for the new Bulk API"). Sin tope numérico de mensajes
  por llamada: el límite operativo es el payload (F-06). El ritmo lo gobierna el
  proveedor — refuerza F-01.

## [F7] Developer docs — Templates API

- **URL:** https://postmarkapp.com/developer/api/templates-api
- **Fecha de acceso:** 2026-08-03
- **Citas literales:**
  - `/email/batchWithTemplates` — `"we accept up to 500 messages per API call"`
  - `"a Server may have up to 100 templates. Requests that exceed this limit
    won't be processed."`
- **Observación:** el tope de plantillas es un límite de recurso, no de consumo;
  se registra como provenance sin serializar.

## [F8] Support — Attachment and email size limits

- **URL:** https://postmarkapp.com/support/article/1056-what-are-the-attachment-and-email-size-limits
- **Fecha de acceso:** 2026-08-03
- **Citas literales:**
  - Salida — `"Total message size, including attachments, can be 10 MB"`
  - Entrada — `"Total cumulative size for all Inbound attachment files may not
    exceed 35 MB"`
  - Lotes — `"Batch endpoint total payload size, including attachments, cannot
    exceed 50 MB"`
  - `"We calculate the size of the email after it has been base64 encoded, so
    please keep in mind your final email size may be larger after being encoded."`
- **Observación:** los topes en MBs se miden **tras** base64 — el límite efectivo
  en contenido útil es menor y depende de la codificación (relevante para F-06).

## [F9] Support — Retención de actividad

- **URL:** https://postmarkapp.com/support/article/how-long-are-inbound-and-outbound-messages-stored-in-activity
- **Fecha de acceso:** 2026-08-03
- **Citas literales:**
  - `"Postmark stores email content, events (e.g. delivery, click, open), and
    metadata for all messages for 45 days by default"`
  - `"you can adjust this timeframe from 7 to 365 days with our Retention Add-on"`
- **Observación:** la retención acota la ventana consultable por la Messages API —
  un add-on de pago modifica de facto una dimensión de consulta (F-07).

## [F10] Support — Rate limits para SMTP

- **URL:** https://postmarkapp.com/support/article/do-we-have-rate-limits-for-smtp
- **Fecha de acceso:** 2026-08-02
- **Citas literales:**
  - `"We recommend that customers limit the total number of connections to our
    SMTP endpoint to 10 concurrent connections, per IP."`
  - `"We do not have any systems in place to enforce these limits, we rely on
    customers to self-police and be good actors on our systems."`
  - El propio proveedor califica sus límites de `"somewhat arbitrary, and informal"`.
- **Observación crítica:** dimensión de **concurrencia** declarada como
  recomendación no aplicada, y solo para SMTP (F-04).

## [F11] Panel de cuenta — observación con cuenta propia

- **URL:** https://account.postmarkapp.com/account/subscription (y
  /servers/…/settings, /servers)
- **Fecha de acceso:** 2026-08-03 · cuenta propia en *test mode* (Developer plan,
  Free tier). Captura en `evidencias/`: `panel_escalera_volumen_2026-08-03.png`
  (escalera de volumen). La segunda captura,
  `panel_testmode_setup_2026-08-03_redactado.png` (aviso de test mode en la página
  *Setup Instructions* del stream), se retiró el 2026-09-07: mostraba el correo del
  autor sin redactar (solo el token estaba tapado). El hecho que respaldaba sigue
  apoyado en la transcripción literal de este [F11] y en `data_provenance` del YAML;
  [E2] (2026-09-06) confirma que la cuenta seguía en *test mode*. Recaptura
  redactada pendiente.
- **Citas y observaciones literales:**
  - Escalera de volumen ("Choose a plan"): `10,000 → $15 (+ $1.80 per 1,000)` ·
    `50,000 → $55 (+ $1.80)` · `125,000 → $115 (+ $1.80)` · `300,000 → $245
    (+ $1.70)` · `700,000 → $455 (+ $1.70)` · `1,500,000 → $775 (+ $1.70)` ·
    `"Need a bigger plan? Email to discuss our high-volume plans."`
  - Tiers ("Choose a tier"), separados de la escalera de volumen:
    - Basic: `"Up to 4 users · SMTP & REST API · Up to 5 servers · Up to 15
      streams · Up to 5 signature domains · Email templates"`
    - Pro: `"Up to 6 users · Up to 10 servers · Up to 30 streams · Up to 10
      signature domains · All Event Webhooks · Inbound email processing ·
      Stats & Open/Link Tracking APIs"`
    - Platform: `"Unlimited users · Unlimited servers · Unlimited streams ·
      Unlimited signature domains · All Event Webhooks · Inbound email
      processing"`
  - Add-ons: `"Optional Add-ons — Pro and Platform plans only"`. Retención en
    pasos: `Don't store content · 7 · 28 · 45 (Default, Free) · 90 · 180 · 365
    days`, con `"Changing your data retention time will only impact future
    messages"`. Dedicated IP: `"$50 per month"` vía `"Request a dedicated IP"`
    (por solicitud, no autoservicio).
  - Ciclo de la cuota: `"Your 100 free emails will renew on Sep 4, 2026"`
    (cuenta creada el 2026-08-03) → ventana anclada al ciclo de la cuenta, no
    al mes natural.
  - Test mode: `"While your account is in test mode, you can only send and
    process 100 emails. In the meantime, you can only send emails to alum.us.es
    and other domains that you have verified. Inbound processing doesn't have
    any domain restrictions."` (evidencia gráfica retirada el 2026-09-07;
    pendiente de recaptura redactada)
  - Servers: `"You can create up to 10 Servers. Upgrade your Tier to create
    more servers"` (el tope depende del tier: 5/10/ilimitados).
  - Server Settings mapea 1:1 con la Servers API: SMTP (`SmtpApiActivated`),
    Open tracking (`TrackOpens`), Link tracking HTML/Text (`TrackLinks`).
  - Reprecio de la escalera por tier: **no observable** — `"You can update your
    plan once you've submitted an account approval request"`.
- **Observación crítica:** el "plan" público (Basic/Pro/Platform) es en realidad
  un producto cartesiano **tier funcional × escalón de volumen**, con overage
  por escalón y superficie de API dependiente del tier (F-02 y F-08).

## [F12] Blog oficial — API Explorer y especificación Swagger

- **URL:** https://postmarkapp.com/blog/introducing-the-postmark-api-explorer
  (explorador: https://postmarkapp.com/api-explorer)
- **Fecha de acceso:** 2026-08-03
- **Citas literales:**
  - `"With Swagger, it is possible to describe REST APIs in a standard way
    using a simple YAML file."`
- **Observación:** el API Explorer oficial está construido sobre especificaciones
  Swagger/OpenAPI → corrige la entrada previa de "OpenAPI no localizada". La URL
  directa del fichero YAML sigue sin localizarse.

## [F13] Developer docs — operaciones 4 a 8 del test de `type` (C2)

- **URLs:** `/developer/api/servers-api` (4) · `/developer/api/webhooks-api` (5) ·
  `/developer/api/inbound-rules-triggers-api` y `/developer/api/messages-api` (6) ·
  `/developer/api/suppressions-api` y `/developer/api/bounce-api` (7) ·
  `/developer/api/messages-api` (8), todas bajo `https://postmarkapp.com`
- **Fecha de acceso:** 2026-09-14
- **Origen:** lectura de la referencia con el navegador del autor; sin volcado (D-023, el
  volcado es recomendado y no exigido). Las tres eliminatorias ya estaban comprobadas el
  mismo día y no se repiten aquí
- **Citas literales, una por operación:**
  - **(4) credenciales adicionales** — Servers API: `"POST /servers"` con
    `X-Postmark-Account-Token`; la respuesta trae `"ApiTokens"`, `"List of API tokens
    associated with server"`
  - **(5) webhooks** — `"GET /webhooks"`, `"POST /webhooks"`, `"PUT /webhooks/{Id}"`,
    `"DELETE /webhooks/{Id}"`, `"POST /webhooks/{Id}/verify"`,
    `"GET /webhooks/{Id}/statistics"`
  - **(6) inbound routing** — `"GET /triggers/inboundrules"`, `"POST /triggers/inboundrules"`,
    `"DELETE /triggers/inboundrules/{triggerid}"`; y sobre el correo recibido,
    `"GET /messages/inbound"`, `"PUT /messages/inbound/{messageid}/bypass"`,
    `"PUT /messages/inbound/{messageid}/retry"`
  - **(7) supresiones y rebotes** — `"POST /message-streams/{stream_id}/suppressions"`,
    `"GET /message-streams/{stream_id}/suppressions/dump"`,
    `"POST /message-streams/{stream_id}/suppressions/delete"`; rebotes con `"GET /bounces"`,
    `"GET /bounces/{bounceid}/dump"`, `"PUT /bounces/{bounceid}/activate"` y
    `"GET /deliverystats"`
  - **(8) actividad y logs** — `"GET /messages/outbound"`,
    `"GET /messages/outbound/{messageid}/details"`, `"…/dump"`,
    `"GET /messages/outbound/opens"`, `"GET /messages/outbound/clicks"`
- **Observación (la carencia, no eliminatoria).** La referencia no publica cómo **rotar** el
  token de un servidor ya creado: el overview lo sitúa en el panel — `"Found from the API
  Tokens tab under your Postmark server"` —, y lo que la API sí permite es **crear**
  credenciales nuevas creando un servidor (`POST /servers`, que devuelve sus `ApiTokens`).
  Además, el listado de códigos de error del overview anuncia una familia
  `"SMTP TOKENS — new"` (1450–1460) que **no tiene página en el índice lateral**:
  `/developer/api/smtp-tokens-api` responde `"Oops, page not found"`. Ninguna de las dos cosas
  mueve el `type` (la 4 no es eliminatoria), pero quedan anotadas como pide C2.

## [F14] Panel de cuenta — operaciones 4 a 8 del test de `type` (escalón 2)

- **Fecha de acceso:** 2026-09-14
- **Cuenta:** la propia del autor, plan Free, **Test mode** (`"Request approval"` en la cabecera).
  Modo lectura: no se generó, reveló ni borró ningún token, ni se creó servidor, webhook o
  plantilla
- **Evidencia:** `evidencias/panel_operaciones_c2_2026-09-14.md` (volcado de texto con la
  superficie del panel; sin captura, y sin transcribir correo, identificadores ni tokens)
- **Citas literales:**
  - Pestaña API Tokens del servidor: `"Server API tokens"`, con `"Generate another token"` y
    `"Delete"`
  - Pestaña Webhooks del stream transaccional: `"Add webhook"`
  - Streams del servidor: `broadcast`, `outbound` («Default Transactional Stream») e `inbound`;
    cada stream tiene `Activity`, `Suppressions`, `Webhooks` y `Settings`
- **Observación (la operación 4 es asimétrica).** El panel **genera y borra tokens de un servidor
  ya creado**; la referencia de API no publica ningún endpoint para eso —solo `POST /servers`,
  que devuelve los `ApiTokens` del servidor **nuevo**—. Es una operación del dominio del correo
  que solo se puede hacer desde la web, exactamente la forma que C2 castiga, pero en una
  operación **no eliminatoria**: se anota como **F-22** y el `type` no cambia. Las otras cuatro
  (5 a 8) están en los dos lados.

## [E1] Sondeo empírico — token de pruebas contra la API real

- **Método:** 7 peticiones `POST` con el token documentado `POSTMARK_API_TEST`
  (valida sin enviar ni consumir cuota), ejecutadas por el autor el 2026-08-03 con
  `05_salida/_herramientas/probe_q2_v2.ps1`. Resultado íntegro en
  `evidencias/probe_q2_v2_resultado_2026-08-03.json`.
- **Resultados literales:**
  - 51 en To → 422/300 `"Maximum of 50 recipients allowed per email message."`
  - 50 en To → 200 `"Test job accepted"`
  - 25 To + 25 Cc (50 total) → 200 `"Test job accepted"`
  - 26 To + 25 Cc (51 total) → 422/300 (mismo mensaje)
  - 50 To + 1 Cc (51 total) → 422/300 (mismo mensaje)
  - 50+50+50 (150 total) → 422/300 (mismo mensaje)
  - `/email/bulk` con 600 mensajes → 403/10 `"The Postmark Test API Token may
    only be used on the /email endpoint."`
- **Conclusiones:** el tope real es **50 destinatarios TOTALES por mensaje**
  (To+Cc+Bcc combinados) — resuelve Q2 y desmiente la lectura "por campo" de la
  documentación (DISC-01). El token de pruebas **solo** opera en `/email`, así
  que bulk/batch quedan para la fase empírica con token real.

---

## [E2] Sondeo empírico — `/email/withTemplate` con token de servidor real

- **Fecha:** 2026-09-06, 19:00 UTC · **Ejecutado por:** el autor, en su máquina, con un
  Server API Token del servidor de la cuenta (plan Free, en *test mode*), sobre la
  plantilla de ejemplo `welcome`. Script `05_salida/_herramientas/probe_postmark_template_batch.sh T`.
- **Evidencia:** `evidencias/probe_withtemplate_2026-09-06.json`
- **Resultado literal:** 51 direcciones en `To` → HTTP 422, `ErrorCode 300`,
  `"Maximum of 50 recipients allowed per email message."`. Rechazado antes de enviar:
  coste 0.
- **Lo que cierra:** el `max: 50` de `/email/withTemplate`, que estaba inferido de «mismos
  límites que /email», pasa a verificado. El tope de 50 totales (DISC-01) se aplica igual
  con plantilla.
- **Lo que no se lanzó entonces:** el caso B (`/email/batch` con 501 mensajes) quedó sin
  ejecutar por el riesgo de que un lote aceptado consumiera la cuota mensual. Se lanzó el
  2026-09-07 con destinatarios de dominio no verificado, coste 0: ver [E3].
- **Nota de seguridad:** el token quedó expuesto en el chat durante la sesión; se pidió
  rotarlo en el panel. El JSON no lo contiene.
- **Cabeceras de rate (registradas el 2026-09-07, D-020):** la respuesta trae
  `ratelimit-limit: 5000`, `ratelimit-remaining: 4999`, `ratelimit-reset: 1`,
  `x-ratelimit-limit-second: 5000`, `x-ratelimit-remaining-second: 4999`, más
  `x-postmark-account` y `x-postmark-server`. Es la única respuesta archivada con
  cabeceras. Como el sondeo no se diseñó para medir caudal, el valor va a DISC-02 y a
  `not_found`, no a `max_power` (CRITERIOS D6).

## [E3] Sondeo empírico — lotes de 500 y 501 en `/email/batch` y `/email/batchWithTemplates`

- **Fecha:** 2026-09-07, 21:47 UTC · **Ejecutado por:** el autor, en su máquina Linux, con el
  Server API Token del servidor de la cuenta (plan Free, pendiente de aprobación). Script
  `05_salida/_herramientas/probe_postmark_batch_500.sh BT`: cuatro peticiones, tres segundos
  entre ellas. Plantilla `welcome` para los casos T.
- **Evidencia:** `evidencias/probe_batch_500_2026-09-07.json` (las listas de 500 respuestas
  se guardan como recuento por error, no fila a fila).
- **Diseño a coste 0:** los 500 mensajes van a `sondeo-tfm@example.invalid`. La cuenta solo
  puede enviar a dominios verificados, así que aunque el lote entre, Postmark rechaza cada
  mensaje sin enviarlo ni gastar cuota.
- **Resultado literal:**
  - B500 `/email/batch`, 500 mensajes → HTTP 200, lista de 500 respuestas, todas
    `ErrorCode 412`, `"While your account is pending approval, all recipient addresses must
    share the same domain as the 'From' address. The domain of the 'From' address is
    'alum.us.es', but you are attempting to send email to the following domain(s):
    'example.invalid'."` El lote entra; ningún mensaje sale.
  - B501 `/email/batch`, 501 mensajes → HTTP 422, `ErrorCode 410`, `"You may only send up
    to 500 messages in a single batched request."`
  - T500 `/email/batchWithTemplates`, 500 → HTTP 200, 500 × `ErrorCode 412` (mismo texto).
  - T501 `/email/batchWithTemplates`, 501 → HTTP 422, `ErrorCode 410` (mismo texto).
- **Lo que cierra:** el `max: 500` de `/email/batch` pasa de 🟡 documental a 🟢 verificado en
  los cuatro planes; el de `/email/batchWithTemplates`, ya en 🟢 por [F7], queda además
  verificado. El par 500/501 fija el tope exacto. Cierra la abierta 9 de
  `05_salida/_cap5/abiertas.md`.
- **Dos matices:** (1) el texto del 410 no coincide con el de la documentación [F2]
  (`"Your batched request contains more than 500 messages."`); mismo código, otra frase.
  (2) El aviso de la cuenta dice ahora *pending approval*, no *test mode* como el panel de
  [F11]; el efecto es el mismo (solo dominios verificados).
- **Cabeceras:** las cuatro respuestas traen `ratelimit-limit: 5000`,
  `x-ratelimit-limit-second: 5000`, `ratelimit-remaining: 4999`, `ratelimit-reset: 1`; las
  de HTTP 200 añaden `x-postmark-account` y `x-postmark-server`. Mismo valor que [E2]
  (DISC-02): se registra, no se adopta (D-020, CRITERIOS D6).

## [E4] Sondeo empírico — caudal inocuo contra `/email`

- **Fecha:** 2026-09-07, 22:06:00–22:06:04 UTC · **Ejecutado por:** el agente en la máquina
  del autor con el Server API Token (`~/.config/tfm/.env`). Script
  `05_salida/_herramientas/probe_postmark_caudal.sh 200 25`: 200 peticiones `POST /email`
  con 25 en paralelo, destinatario `sondeo-tfm@example.invalid`. Diseñado para medir caudal
  (CRITERIOS D6), no destinatarios.
- **Evidencia:** `evidencias/probe_caudal_2026-09-07.json` (resumen + las 200 peticiones con
  instante, HTTP, `ErrorCode` y cabeceras de rate).
- **Coste 0:** las 200 respuestas son HTTP 422, `ErrorCode 412` (cuenta pendiente de
  aprobación, dominio no verificado). Nada se envió.
- **Resultado literal:** 200 peticiones en 4,57 s (unas 44 por segundo). Todas traen
  `ratelimit-limit: 5000` y `ratelimit-reset: 1`. `ratelimit-remaining` baja dentro de cada
  segundo del reloj del servidor (cabecera `date`) y vuelve a 4999 al segundo siguiente:
  mínimos por segundo 4988, 4986, 4988, 4991, 4990 con 29, 48, 49, 50 y 24 peticiones
  respectivamente. El contador es **por segundo y se repone cada segundo**; el mínimo no
  llega a 5000 − n porque las respuestas de un mismo segundo se cuentan en vuelo.
- **Lo que cierra y lo que no:** confirma que la cabecera describe un límite de 5.000
  peticiones por segundo activo en el servidor (`x-postmark-server` presente). **No** alcanza
  el 429: harían falta 5.000 peticiones en un segundo, fuera de lo inocuo. DISC-02 pasa de
  «cabecera aparecida en un sondeo de otro propósito» a «cabecera medida en un sondeo de
  caudal». **Adoptada en `max_power` (🟡, observada y no forzada) por D-024** el mismo día;
  las preguntas P del motor se reejecutan sobre Postmark (`prime4api_ejecucion_d024/`).

## Discrepancias entre fuentes

Registro de contradicciones documentación↔documentación o documentación↔realidad.
El semáforo del campo afectado se queda en 🟡 mientras la discrepancia viva; pasa a
🟢-empírico cuando un experimento la resuelve.

| ID | Dato | Fuente A dice | Fuente B dice | Estado |
|---|---|---|---|---|
| DISC-01 | Destinatarios por mensaje en `/email` | [F3] docs: `"Max 50"` **por campo** To/Cc/Bcc (sugiere hasta 150) | [E1] API: `"Maximum of 50 recipients allowed per email message"` — 50 **totales** | **Resuelta a favor de [E1]** (2026-08-03). La doc es engañosa; hallazgo para la memoria |
| DISC-02 | Rate limit de la API REST | [F2] docs: solo el error `429 — Rate Limit Exceeded`, sin umbral numérico | [E2] API: la respuesta 422 de `/email/withTemplate` (2026-09-06, 19:00 UTC) trae `ratelimit-limit: 5000`, `x-ratelimit-limit-second: 5000`, `ratelimit-remaining: 4999`, `ratelimit-reset: 1` (`evidencias/probe_withtemplate_2026-09-06.json`) | **Abierta, registrada sin adoptar** (D-020, 2026-09-07). El sondeo [E2] era de destinatarios, no de caudal (CRITERIOS D6). **[E4] (2026-09-07, 22:06 UTC) es el sondeo de caudal inocuo:** 200 peticiones en 4,6 s, el contador baja dentro del segundo y se repone cada segundo; el 429 no se alcanza. **Cerrada en ámbar (D-024, 2026-09-07):** el autor adopta 5.000 req/s en `max_power` (`rate_request_rest`, 🟡). Verde solo si un sondeo alcanza el 429. La segmentación (cuenta o servidor) tampoco está documentada: la respuesta identifica ambos con `x-postmark-account` y `x-postmark-server` |

---

## Fuentes buscadas y NO encontradas

Registro explícito para que la ausencia sea trazable y no parezca descuido.

| Dato buscado | Resultado |
|---|---|
| Rate limit numérico de la API REST (req/s o req/min) | **No publicado.** Solo existe el 429 de [F2]. Terceros lo confirman: no hay umbral público. **Adoptado en ámbar (D-024):** `ratelimit-limit: 5000` por segundo, visto en [E2] y medido en el sondeo de caudal [E4]; `max_power.rate_request_rest` 🟡 (DISC-02). |
| Límite de concurrencia de la API REST (no SMTP) | **No publicado.** El de [F10] es solo SMTP. |
| Segmentación del rate limit (¿por server token o por cuenta?) | **No documentada.** |
| URL directa del fichero Swagger/OpenAPI | No localizada — la spec existe y alimenta el API Explorer [F12], pero el YAML no está enlazado públicamente. |
| Ventana de la cuota mensual en planes de pago | No explicitado en docs. En el plan free, **resuelto por panel** [F11]: ciclo de cuenta. Para los de pago, presumiblemente igual (sin confirmar). |
| ~~Tabla de escalones de volumen~~ | **Resuelta por panel** [F11]: no es pública, pero el panel la muestra completa (10k→1,5M; >1,5M negociado). Reprecio por tier: pendiente de cuenta aprobada. |
| Tope conjunto de destinatarios por petición (50 vs 150) | No aclarado en la documentación. Artículo de soporte no localizado. |
