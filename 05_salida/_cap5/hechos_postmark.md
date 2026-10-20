# Hechos — Postmark

Extracción literal de `03_datos/apis/postmark/` (`datasheet.yaml`, `fuentes.md`, `fricciones.md`,
`REVISION.md`, `evidencias/*.json`). Fecha de extracción: 2026-09-07.

Convenciones:
- **fuente**: id `[Fn]`/`[En]` de `fuentes.md`, o nombre de fichero de `evidencias/`.
- **escalón**: doc (documentación pública) · panel (cuenta propia, [F11]) · sondeo (petición real contra la API).
- **semáforo**: el que lleva el campo en `datasheet.yaml`; «—» si el hecho no está serializado en el YAML (solo en `metadata.data_provenance`, `not_found` o en ninguna parte).
- **YAML**: ruta del campo donde vive el dato, cuando existe.
- Las cifras se citan tal como aparecen en la fuente (moneda, periodo, unidades). No se infiere, redondea ni completa nada.
- La captura `evidencias/panel_escalera_volumen_2026-08-03.png` no se ha leído; se cita por nombre porque [F11] remite a «Capturas en `evidencias/`». La captura `panel_testmode_setup_2026-08-03_redactado.png` fue retirada el 2026-09-07 (mostraba el correo del autor sin redactar); el hecho que respaldaba (PM-29) sigue apoyado en la transcripción literal de [F11].

---

## 1. Planes y precios

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| PM-01 | La moneda de la página de precios es USD. | [F1] | doc | 🟢 | `currency` | — |
| PM-02 | Plan Free: `"$0.00/mo"`, presentado como `"Testing your integration"`. | [F1] | doc | 🟢 | `plans.free.price` (0.00, period 1 MONTH) | — |
| PM-03 | Plan Basic: `"$15.00/mo"`. | [F1] | doc | 🟢 | `plans.basic.price` (15.00, period 1 MONTH) | F-02 |
| PM-04 | Plan Pro: `"$16.50/mo"`. | [F1] | doc | 🟢 | `plans.pro.price` (16.50, period 1 MONTH) | F-02 |
| PM-05 | Plan Platform: `"$18.00/mo"`. | [F1] | doc | 🟢 | `plans.platform.price` (18.00, period 1 MONTH) | F-02 |
| PM-06 | Pro añade `"Inbound email processing"` respecto a Basic. | [F1] | doc | — | `/messages/inbound` solo aparece en `plans.pro` y `plans.platform` | F-08 |
| PM-07 | Escalera de volumen del panel («Choose a plan»), tier Basic, escalón 1: `10,000 → $15 (+ $1.80 per 1,000)`. | [F11] (`panel_escalera_volumen_2026-08-03.png`) | panel | 🟡 | `capacity.quota_email_included_basic.value` (10000) | F-02 |
| PM-08 | Escalón 2: `50,000 → $55 (+ $1.80)`. | [F11] | panel | — | — (solo `data_provenance`) | F-02 |
| PM-09 | Escalón 3: `125,000 → $115 (+ $1.80)`. | [F11] | panel | — | — (solo `data_provenance`) | F-02 |
| PM-10 | Escalón 4: `300,000 → $245 (+ $1.70)`. | [F11] | panel | — | — (solo `data_provenance`) | F-02 |
| PM-11 | Escalón 5: `700,000 → $455 (+ $1.70)`. | [F11] | panel | — | — (solo `data_provenance`) | F-02 |
| PM-12 | Escalón 6: `1,500,000 → $775 (+ $1.70)`. | [F11] | panel | — | — (solo `data_provenance`) | F-02 |
| PM-13 | Por encima de 1.500.000: `"Need a bigger plan? Email to discuss our high-volume plans."` | [F11] | panel | — | — (solo `data_provenance`) | F-02 |
| PM-14 | La escalera de volumen y el tier funcional se eligen por separado en el panel («Choose a plan» y «Choose a tier»). | [F11] | panel | — | — | F-08 |
| PM-15 | Tier Basic (panel): `"Up to 4 users · SMTP & REST API · Up to 5 servers · Up to 15 streams · Up to 5 signature domains · Email templates"`. | [F11] | panel | — | — (solo `data_provenance`, sin «Email templates») | F-08 |
| PM-16 | Tier Pro (panel): `"Up to 6 users · Up to 10 servers · Up to 30 streams · Up to 10 signature domains · All Event Webhooks · Inbound email processing · Stats & Open/Link Tracking APIs"`. | [F11] | panel | — | — (solo `data_provenance`) | F-08 |
| PM-17 | Tier Platform (panel): `"Unlimited users · Unlimited servers · Unlimited streams · Unlimited signature domains · All Event Webhooks · Inbound email processing"`. | [F11] | panel | — | — (solo `data_provenance`, sin «All Event Webhooks · Inbound email processing») | F-08 |
| PM-18 | Add-on Dedicated IPs: `"Starts at $50/month per IP"`, con requisito `"sending 300,000 emails per month or more"`. | [F1] | doc | — | — (solo `data_provenance`) | F-07 |
| PM-19 | Add-on Dedicated IP en el panel: `"$50 per month"` vía `"Request a dedicated IP"` (por solicitud, no autoservicio). | [F11] | panel | — | — | F-07 |
| PM-20 | Add-on Custom Activity Retention: `"Starts at $5/month"`. | [F1] | doc | — | — (solo `data_provenance`) | F-07 |
| PM-21 | Add-on DMARC Monitoring: `"Starts at $14/month per domain"`. | [F1] | doc | — | — (solo `data_provenance`) | F-07 |
| PM-22 | Los add-ons están restringidos por tier: `"Optional Add-ons — Pro and Platform plans only"`. | [F11] | panel | — | — (solo `data_provenance`) | F-07, F-08 |
| PM-23 | La cuenta propia está en *test mode* (Developer plan, Free tier) y el cambio de plan exige aprobación: `"You can update your plan once you've submitted an account approval request"`. | [F11] | panel | — | — | F-02 |

## 2. Cuotas

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| PM-24 | Free incluye `"100 emails/month"`. | [F1] | doc | 🟢 | `capacity.quota_email_included_free.value` (100 emails / 1 MONTH) | — |
| PM-25 | Basic: `"Starting at 10,000 emails/month"`. | [F1] | doc | 🟡 | `capacity.quota_email_included_basic.value` (10000 emails / 1 MONTH) | F-02 |
| PM-26 | Pro: `"Starting at 10,000 emails/month"`. | [F1] | doc | 🟡 | `capacity.quota_email_included_pro.value` (10000) | F-02 |
| PM-27 | Platform: `"Starting at 10,000 emails/month"`. | [F1] | doc | 🟡 | `capacity.quota_email_included_platform.value` (10000) | F-02 |
| PM-28 | La cuota free renueva por ciclo de cuenta: `"Your 100 free emails will renew on Sep 4, 2026"` con alta el 2026-08-03. | [F11] | panel | 🟢 | `capacity.quota_email_included_free.window_type` (fixed_billing_cycle) | — |
| PM-29 | Test mode: `"While your account is in test mode, you can only send and process 100 emails. In the meantime, you can only send emails to alum.us.es and other domains that you have verified. Inbound processing doesn't have any domain restrictions."` | [F11] (transcripción literal; captura retirada el 2026-09-07 por mostrar el correo del autor sin redactar; evidencia gráfica retirada, pendiente de recaptura redactada) | panel | — | — (solo `data_provenance`) | — |
| PM-30 | Bulk API: `"Every message sent through the Bulk API counts toward your monthly email limit, just like any other message."` | [F5] | doc | — | — (solo `data_provenance`) | — |
| PM-31 | Plantillas: `"a Server may have up to 100 templates. Requests that exceed this limit won't be processed."` | [F7] | doc | — | — (solo `data_provenance`) | — |
| PM-32 | Servers en el panel de la cuenta propia: `"You can create up to 10 Servers. Upgrade your Tier to create more servers"`. | [F11] | panel | — | — | F-11 (F-08 en el piloto, antes de la división) |
| PM-33 | Retención de actividad: `"Postmark stores email content, events (e.g. delivery, click, open), and metadata for all messages for 45 days by default"`. | [F9] | doc | — | — (solo `data_provenance`) | F-07 |
| PM-34 | Con add-on: `"you can adjust this timeframe from 7 to 365 days with our Retention Add-on"`. | [F9] | doc | — | — (solo `data_provenance`) | F-07 |
| PM-35 | Pasos de retención en el panel: `Don't store content · 7 · 28 · 45 (Default, Free) · 90 · 180 · 365 days`, con `"Changing your data retention time will only impact future messages"`. | [F11] | panel | — | — | F-07 |

## 3. Rates

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| PM-36 | Existe el error `"429 — Rate Limit Exceeded"`: `"We have detected that you are making requests at a rate that exceeds acceptable use of the API."`, sin umbral numérico. | [F2] | doc | 🟡 (D-024) | `max_power.rate_request_rest: 5000/s` | F-01 |
| PM-37 | En `/email/bulk` el ritmo lo gestiona el proveedor: `"Postmark will optimize the sending speed for you"`. | [F6] | doc | 🔴 | `max_power: {}` | F-01 |
| PM-38 | SMTP: `"We recommend that customers limit the total number of connections to our SMTP endpoint to 10 concurrent connections, per IP."` | [F10] | doc | — | — (solo `data_provenance`) | F-04 |
| PM-39 | SMTP: `"We do not have any systems in place to enforce these limits, we rely on customers to self-police and be good actors on our systems."`; el proveedor califica sus límites de `"somewhat arbitrary, and informal"`. | [F10] | doc | — | — (solo `data_provenance`) | F-04 |
| PM-40 | La respuesta HTTP 422 del sondeo [E2] (2026-09-06T19:00:21Z) trae las cabeceras `ratelimit-limit: 5000`, `ratelimit-remaining: 4999`, `ratelimit-reset: 1`, `x-ratelimit-limit-second: 5000`, `x-ratelimit-remaining-second: 4999`. | `probe_withtemplate_2026-09-06.json` | sondeo | — | — (no está en `max_power`, `data_provenance` ni `not_found`) | F-01 |
| PM-41 | La misma respuesta trae `x-postmark-account: 546797` y `x-postmark-server: 20186205`. | `probe_withtemplate_2026-09-06.json` | sondeo | — | — | F-01 |

## 4. Workload y tamaños

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| PM-42 | Email API, campo To: `"Recipient email address. Multiple addresses are comma separated. Max 50."`; Cc y Bcc declaran cada uno `"Max 50."` (por campo). | [F3] | doc | 🟢 | `plans.*.endpoints./email.workload[0].max` (50) | DISC-01, F-03 |
| PM-43 | Sondeo A_51_To (`/email`, token `POSTMARK_API_TEST`): 51 en To → HTTP 422, ErrorCode 300, `"Maximum of 50 recipients allowed per email message."` | `probe_q2_v2_resultado_2026-08-03.json` / [E1] | sondeo | 🟢 | `plans.*.endpoints./email.workload[0].max` (50) | DISC-01 |
| PM-44 | Sondeo B_50_To: 50 en To → HTTP 200, ErrorCode 0, `"Test job accepted"`. | `probe_q2_v2_resultado_2026-08-03.json` / [E1] | sondeo | 🟢 | ídem | DISC-01 |
| PM-45 | Sondeo C_25To_25Cc (50 tot): HTTP 200, `"Test job accepted"`. | `probe_q2_v2_resultado_2026-08-03.json` / [E1] | sondeo | 🟢 | ídem | DISC-01 |
| PM-46 | Sondeo D_26To_25Cc (51 tot): HTTP 422, ErrorCode 300, `"Maximum of 50 recipients allowed per email message."` | `probe_q2_v2_resultado_2026-08-03.json` / [E1] | sondeo | 🟢 | ídem | DISC-01 |
| PM-47 | Sondeo E_50To_1Cc (51 tot): HTTP 422, ErrorCode 300, mismo mensaje. | `probe_q2_v2_resultado_2026-08-03.json` / [E1] | sondeo | 🟢 | ídem | DISC-01 |
| PM-48 | Sondeo F_50_50_50 (150 tot): HTTP 422, ErrorCode 300, mismo mensaje. | `probe_q2_v2_resultado_2026-08-03.json` / [E1] | sondeo | 🟢 | ídem | DISC-01 |
| PM-49 | Sondeo G_bulk_600_msgs (`/email/bulk`, token de pruebas): HTTP 403, ErrorCode 10, `"The Postmark Test API Token may only be used on the /email endpoint."` | `probe_q2_v2_resultado_2026-08-03.json` / [E1] | sondeo | 🔴 | `plans.*.endpoints./email/bulk.workload[0].max` (vacío) | F-06 |
| PM-50 | Sondeo T_withTemplate_51_To (`/email/withTemplate`, token de servidor real, plantilla `welcome`): 51 en To → HTTP 422, ErrorCode 300, `"Maximum of 50 recipients allowed per email message."`; rechazado antes de enviar, coste 0. | `probe_withtemplate_2026-09-06.json` / [E2] | sondeo | 🟢 | `plans.*.endpoints./email/withTemplate.workload[0].max` (50) | DISC-01 |
| PM-51 | `/email/batch`: `"accepts up to 500 messages per API call, and up to 50 MB payload size, including attachments."` | [F3] | doc | 🟢 (verificado por [E3], 2026-09-07) | `plans.*.endpoints./email/batch.workload[0].max` (500) | F-03 |
| PM-52 | Error `"410 — Too many batch messages"`: `"Your batched request contains more than 500 messages."` | [F2] | doc | 🟢 (verificado por [E3]; el texto real del 410 es otro, PM-95) | `plans.*.endpoints./email/batch.workload[0].max` (500) | F-03 |
| PM-53 | `/email/batchWithTemplates`: `"we accept up to 500 messages per API call"`. | [F7] | doc | 🟢 | `plans.*.endpoints./email/batchWithTemplates.workload[0].max` (500) | F-03 |
| PM-54 | Tamaño Email API: `"The request exceeded Postmark's size limit of 10 MB for our Email API"`; artículo de soporte: `"Total message size, including attachments, can be 10 MB"`. | [F2], [F8] | doc | — | `consumption_units` incluye `MBs`; sin campo de valor | F-06 |
| PM-55 | Tamaño Batch: `"50 MB total payload size for our Batch Email API"`; soporte: `"Batch endpoint total payload size, including attachments, cannot exceed 50 MB"`. | [F2], [F8] | doc | — | — (solo `data_provenance`) | F-06 |
| PM-56 | Entrada: `"Total cumulative size for all Inbound attachment files may not exceed 35 MB"`. | [F8] | doc | — | — | — |
| PM-57 | Los tamaños se miden tras codificar: `"We calculate the size of the email after it has been base64 encoded, so please keep in mind your final email size may be larger after being encoded."` | [F8] | doc | — | — (solo `data_provenance`) | F-06 |
| PM-58 | `/email/bulk`: `"as many recipients as you need, as long as your total payload (including attachments) stays under 50 MB"`. | [F5] | doc | 🔴 | `plans.*.endpoints./email/bulk.workload[0].max` (vacío, description «limitado por payload de 50 MB») | F-06 |
| PM-59 | `/email/bulk`, destinatarios por mensaje: `"Multiple addresses are comma-separated. Max 50."`; `"stay within the 50 MB payload size limit, including attachments"`. | [F6] | doc | — | — | F-06 |
| PM-60 | `/email/bulk` solo opera sobre broadcast: `"Right now, the Bulk API works with Broadcast Streams only."`; stream por defecto `"outbound broadcast stream"`. | [F5], [F6] | doc | — | — (solo `data_provenance`) | — |
| PM-61 | `/email`, `MessageStream`: `"If not provided, message will default to the 'outbound' transactional stream."` | [F3] | doc | — | — | — |
| PM-62 | `GET /messages/outbound`, parámetro `count`: `"Number of messages to return per request. Max 500. Count + Offset cannot exceed 10,000 messages."` | [F4] | doc | — | `plans.*.endpoints./messages/outbound.workload` (requests 1..1; RPR solo en `description`) | F-05 |
| PM-63 | `GET /messages/inbound`, parámetro `count`: ídem literal (`"Max 500. Count + Offset cannot exceed 10,000 messages"`). | [F4] | doc | — | `plans.pro/platform.endpoints./messages/inbound.workload` (requests 1..1; RPR solo en `description`) | F-05 |
| PM-64 | El token de pruebas `POSTMARK_API_TEST` valida sin enviar ni consumir cuota (método de [E1]). | [E1], [F2] | sondeo | — | — (solo `data_provenance`) | — |

## 5. Sobrecoste

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| PM-65 | Free: `"No overages allowed in this plan"`. | [F1] | doc | — | `capacity.quota_email_included_free` no lleva `overage_cost` | — |
| PM-66 | Basic: `"Extra emails @ $1.80 / 1,000"`. | [F1] | doc | 🟢 | `capacity.quota_email_included_basic.overage_cost` (price 0.0018, value 1; normalización unitaria por D-002) | F-02 |
| PM-67 | Pro: `"Extra emails @ $1.30 / 1,000"`. | [F1] | doc | 🟢 | `capacity.quota_email_included_pro.overage_cost` (price 0.0013, value 1) | F-02 |
| PM-68 | Platform: `"Extra emails @ $1.20 / 1,000"`. | [F1] | doc | 🟢 | `capacity.quota_email_included_platform.overage_cost` (price 0.0012, value 1) | F-02 |
| PM-69 | Panel, tier Basic: el sobrecoste es `+ $1.80 per 1,000` en los escalones 10,000, 50,000 y 125,000. | [F11] | panel | 🟢 (solo el escalón 10k está serializado) | `capacity.quota_email_included_basic.overage_cost` | F-02 |
| PM-70 | Panel, tier Basic: el sobrecoste es `+ $1.70` en los escalones 300,000, 700,000 y 1,500,000. | [F11] | panel | — | — (solo `data_provenance`) | F-02 |
| PM-71 | Bulk API: `"No additional fees."` | [F5] | doc | — | — | — |

## 6. Vigencia

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| PM-72 | La Datasheet lleva `date: 2026-08-03` y `syntax_version: 0.3`. | `datasheet.yaml` | — | — | `date`, `syntax_version` | — |
| PM-73 | Recolección documental: pasada 1 el 2026-08-02, pasada 2 (cobertura completa) el 2026-08-03. | `fuentes.md` (cabecera) | doc | — | — | — |
| PM-74 | [F1], [F2] y [F3] accedidas el 2026-08-03 (re-verificadas; primera visita 2026-08-02). | [F1], [F2], [F3] | doc | — | — | — |
| PM-75 | [F4], [F5], [F6], [F7], [F8], [F9], [F11] y [F12] accedidas el 2026-08-03. | [F4]–[F9], [F11], [F12] | doc / panel | — | — | — |
| PM-76 | [F10] (rate limits SMTP) accedida el 2026-08-02. | [F10] | doc | — | — | — |
| PM-77 | Sondeo [E1] ejecutado por el autor el 2026-08-03 con `05_salida/_herramientas/probe_q2_v2.ps1` (7 peticiones POST). | [E1] | sondeo | — | — | — |
| PM-78 | Sondeo [E2] ejecutado el 2026-09-06 a las 19:00 UTC (`instante_utc: 2026-09-06T19:00:21Z`, cabecera `date: Sun, 06 Sep 2026 19:00:22 GMT`) con `probe_postmark_template_batch.sh T`. | [E2], `probe_withtemplate_2026-09-06.json` | sondeo | — | — | — |
| PM-79 | El Bulk API está en acceso anticipado: existe el artículo de soporte «The early access program for the new Bulk API». | [F6] (observación) | doc | — | — | — |
| PM-80 | La cuenta propia se creó el 2026-08-03 y su cuota free renueva el `Sep 4, 2026`. | [F11] | panel | 🟢 | `capacity.quota_email_included_free.window_type` | — |
| PM-81 | El token de servidor usado en [E2] quedó expuesto en el chat y se pidió rotarlo; el JSON no lo contiene. | [E2] | sondeo | — | — | — |

## 7. Lo que el proveedor no publica

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| PM-82 | Rate limit numérico de la API REST (req/s o req/min): no publicado; solo existe el 429 de [F2]. Adoptado desde la cabecera en ámbar (D-024). | [F2]; `not_found` | doc | 🟡 | `max_power.rate_request_rest`; `metadata.not_found[0]` | F-01 |
| PM-83 | Límite de concurrencia de la API REST: no publicado (el de [F10] es solo SMTP). | [F10]; `not_found` | doc | — | `metadata.not_found[1]` | F-04 |
| PM-84 | Segmentación del rate limit (¿por server token o por cuenta?): no documentada. | [F2] | doc | — | — | F-01 |
| PM-85 | URL directa del fichero Swagger/OpenAPI: no localizada; la spec existe y alimenta el API Explorer (`"With Swagger, it is possible to describe REST APIs in a standard way using a simple YAML file."`). | [F12]; `not_found` | doc | — | `metadata.not_found[2]` | — |
| PM-86 | Ventana de la cuota mensual en los planes de pago: no explicitada en docs (en free, resuelta por panel). | `not_found`; [F11] | doc | 🟡 | `capacity.quota_email_included_{basic,pro,platform}.window_type` | — |
| PM-87 | Precio y sobrecoste de cada volumen en los tiers Pro y Platform: no observable con cuenta sin aprobar; el valor en cada cruce tier × volumen queda sin determinar. | `not_found`; [F11] | panel | — | `metadata.not_found[4]` | F-02, F-08 |
| PM-88 | Disponibilidad de `/email/bulk` por plan: no documentada (incluido en los cuatro planes con caveat). | `not_found`; REVISION Q8 | doc | — | `metadata.not_found[5]` | — |
| PM-89 | Tope conjunto de destinatarios por petición (50 vs 150): no aclarado en la documentación; artículo de soporte no localizado (resuelto solo por sondeo). | `fuentes.md` (no encontradas) | doc | 🟢 (por sondeo) | `plans.*.endpoints./email.workload[0].max` | DISC-01 |
| PM-90 | No hay planes anuales ni tabla pública de escalones tras el «Starting at 10,000». | [F1] (observación) | doc | — | — | F-02 |
| PM-91 | Reprecio de la escalera de volumen al cambiar de tier: no observable hasta que aprueben la cuenta. | [F11] | panel | — | — | F-02, F-08 |
| PM-92 | Si el cómputo de cuota es 1 email por destinatario: sin confirmar (fleco de Q2 para la fase con token real). | REVISION Q2 | — | — | — | — |
| PM-93 | `/email/batch` con 501 mensajes (caso B): no lanzado el 2026-09-06 por riesgo de consumir la cuota; lanzado el 2026-09-07 como [E3] con destinatarios de dominio no verificado, coste 0. | [E2], [E3] | sondeo | 🟢 | `plans.*.endpoints./email/batch.workload[0].max` | F-03 |
| PM-94 | Los endpoints `/stats/*` y `/messages/outbound/{opens,clicks}` no publican límites de consumo propios más allá del RPR genérico; no están modelados. | REVISION Q10 | doc | — | — | F-08 |
| PM-95 | Sondeo [E3] (2026-09-07T21:47Z): 501 mensajes en `/email/batch` y en `/email/batchWithTemplates` → HTTP 422, ErrorCode 410, `"You may only send up to 500 messages in a single batched request."`; 500 mensajes → HTTP 200 con 500 respuestas. Tope exacto 500 en ambos. | `probe_batch_500_2026-09-07.json` / [E3] | sondeo | 🟢 | `plans.*.endpoints./email/batch.workload[0].max`, `…/email/batchWithTemplates.workload[0].max` (500) | F-03 |
| PM-96 | Cuenta pendiente de aprobación: cada mensaje a dominio no verificado se rechaza con ErrorCode 412, `"While your account is pending approval, all recipient addresses must share the same domain as the 'From' address…"`; el lote de 500 no gastó cuota. | `probe_batch_500_2026-09-07.json` / [E3] | sondeo | — | — (solo `data_provenance`) | — |
| PM-97 | Sondeo de caudal [E4] (2026-09-07T22:06Z): 200 `POST /email` en 4,57 s, 25 en paralelo, todas 422/412 sin envío; `ratelimit-limit: 5000`, `ratelimit-reset: 1` en las 200; `ratelimit-remaining` mínimo 4986 dentro de un segundo y repuesto a 4999 al siguiente. 429 no alcanzado. | `probe_caudal_2026-09-07.json` / [E4] | sondeo | 🟡 (adoptado, D-024) | `max_power.rate_request_rest: 5000/s`, `not_found`, DISC-02 | F-01 |
| PM-98 | D-024 (2026-09-07): `max_power.rate_request_rest` = 5.000 requests / 1 SECOND en 🟡, referenciado por los cuatro planes; verde solo si un sondeo alcanza el 429. | DECISIONES D-024, [E4] | decisión | 🟡 | `max_power`, `plans.*.rate` | F-01 |
| PM-99 | Test C2 (2026-09-14): el panel del servidor gestiona credenciales —`"Server API tokens"`, `"Generate another token"`, `"Delete"`— y la referencia de API no publica ningún endpoint para generar o borrar tokens de un servidor ya creado; lo único programable es `POST /servers`, que crea uno nuevo y devuelve sus `ApiTokens`. Operación 4 del test, **no eliminatoria**: `type` sigue `api_first`. | [F13] doc · [F14] panel | doc + panel | 🟢 (cobertura, D9) | `type` | C2, D-031, F-22 |

---

## Discrepancias entre fuentes

| id | filas | qué dice cada fuente | estado según los ficheros |
|---|---|---|---|
| DISC-01 (registrada en `fuentes.md`) | PM-42 vs PM-43…PM-48, PM-50 | [F3] declara `"Max 50"` **por campo** To/Cc/Bcc; la API responde `"Maximum of 50 recipients allowed per email message"` a 51 totales en cualquier reparto (y a 150). | Resuelta a favor de [E1] el 2026-08-03; [E2] confirma lo mismo en `/email/withTemplate`. |
| Sin id (no registrada) | PM-40 vs PM-36, PM-82 | El JSON de [E2] contiene `ratelimit-limit: 5000`, `x-ratelimit-limit-second: 5000`, `ratelimit-reset: 1`; el YAML mantiene `max_power: {}` y `not_found` dice «Rate limit numérico de la API REST: no publicado»; REVISION.md (misma fecha) afirma «rate REST y concurrencia (nadie los publica)». Ni `fuentes.md` [E2] ni REVISION.md mencionan las cabeceras. | Abierta: la evidencia existe en `evidencias/` pero no ha sido leída en la Datasheet. |
| Sin id | PM-51, PM-52 vs PM-53 | `/email/batch` (`max: 500`) lleva 🟡 con dos citas documentales ([F3] «up to 500 messages per API call», [F2] error 410); `/email/batchWithTemplates` (`max: 500`) lleva 🟢 con una cita documental ([F7] «up to 500 messages per API call»). Misma base documental, semáforos distintos. | Abierta (no comentada en ningún fichero). |
| Sin id | PM-15 vs PM-32 | El tier Basic declara `"Up to 5 servers"` y Platform «Unlimited»; el panel de la cuenta propia (Free, test mode) dice `"You can create up to 10 Servers. Upgrade your Tier to create more servers"`. `fuentes.md` glosa «el tope depende del tier: 5/10/ilimitados». | Abierta: el tope de 10 observado no coincide con el del tier Basic (5) ni figura como tope del tier Free. |
| Sin id | PM-15, PM-17 vs `data_provenance` | `fuentes.md` [F11] cita para Basic «… · Email templates» y para Platform «… · All Event Webhooks · Inbound email processing»; el `data_provenance` del YAML omite esos fragmentos en ambos tiers. | Textual; la cita del YAML es más corta que la de `fuentes.md`. |
| Sin id | PM-18 vs PM-19 | [F1] «Starts at $50/month per IP» con requisito de 300,000 emails/mes; el panel [F11] «$50 per month» por solicitud, sin mencionar el requisito. | Compatibles; el panel no muestra la condición de volumen. |

## Lo que sorprendería a un tribunal

1. **La respuesta de la API lleva un rate limit que la Datasheet declara inexistente** (PM-40 frente a PM-36/PM-82): `ratelimit-limit: 5000` y `x-ratelimit-limit-second: 5000` en el JSON del sondeo [E2], mientras `max_power` sigue vacío y `not_found` dice «no publicado». La evidencia está en la carpeta y nadie la ha citado.
2. **La documentación dice «Max 50» por campo y la API rechaza 51 en total** (PM-42 frente a PM-43–PM-48): un lector de la doc esperaría hasta 150 destinatarios y obtiene 422 con 51.
3. **El sobrecoste no es un número por plan sino una función de dos variables sin tabla pública** (PM-66–PM-70, PM-87): $1.80/$1.30/$1.20 por 1,000 según tier en la página, $1.80→$1.70 según escalón en el panel del tier Basic, y el cruce Pro/Platform × volumen no se puede ver sin cuenta aprobada.
4. **El token de pruebas solo funciona en `/email`** (PM-49): batch y bulk no se pueden sondear sin gastar cuota real, así que el `500` de `/email/batch` sigue 🟡 (PM-93) y `/email/bulk` sigue 🔴 (PM-58).
5. **El proveedor publica un límite de concurrencia y declara que no lo aplica** (PM-38, PM-39): «10 concurrent connections, per IP», «We do not have any systems in place to enforce these limits», «somewhat arbitrary, and informal».
