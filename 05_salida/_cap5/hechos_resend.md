# Hechos — Resend (extracción para el capítulo 5)

Extraído el 2026-09-07 exclusivamente de `03_datos/apis/resend/` (`datasheet.yaml`,
`fuentes.md`, `fricciones.md`, `REVISION.md`, `evidencias/*.json`, `evidencias/paginas/2026-09-01/*.txt`).
Las capturas `.png` de `evidencias/` solo se citan por nombre a través de [F9] y [E1].
Toda cifra se copia tal como aparece en la fuente (moneda, periodo, unidades); no se
redondea ni se completa. Producto modelado: **solo el transaccional** (Q1).

Convenciones de la columna **fuente**: `[Fn]`/`[E1]` = ids de `fuentes.md`;
`rate_limit.txt` = `evidencias/paginas/2026-09-01/resend_com_docs_api_reference_rate_limit.txt`;
`pricing_md.txt` = `evidencias/paginas/2026-09-01/resend_com_pricing_md.txt`;
`probe.json` = `evidencias/probe_ventana_destinatarios_2026-09-06.json`.
**Escalón**: doc = documentación pública · panel = cuenta propia · sondeo = llamada a la API.
**Semáforo**: el del campo en `datasheet.yaml`; «—» si el hecho no vive en el YAML (solo en `metadata.data_provenance` o fuera de él).

---

## 1. Planes y precios

| id | hecho | fuente | escalón | semáforo | ruta YAML | fricción |
|---|---|---|---|---|---|---|
| RS-01 | Plan Free a `$0/mo` con `3,000` emails/mo. | [F1], [F2], pricing_md.txt | doc | 🟢 | `plans.free.price` = 0.00 / MONTH | — |
| RS-02 | Plan Pro a `$20/mo` con `50,000` emails/mo (primer volumen contratable). | [F1], [F2], pricing_md.txt | doc | 🟢 | `plans.pro.price` = 20.00 / MONTH | F-02 |
| RS-03 | Segundo volumen de Pro: `$35/mo` con `100,000` emails/mo. | [F2], pricing_md.txt | doc | — (solo provenance) | — | F-02 |
| RS-04 | Plan Scale a `$90/mo` con `100,000` emails/mo (primer volumen contratable). | [F1], [F2], pricing_md.txt | doc | 🟢 | `plans.scale.price` = 90.00 / MONTH | F-02 |
| RS-05 | Volúmenes adicionales de Scale: `$160/mo` / `200,000`; `$350/mo` / `500,000`; `$650/mo` / `1,000,000`; `$825/mo` / `1,500,000`; `$1,150/mo` / `2,500,000`. | [F2], pricing_md.txt | doc | — (solo provenance) | — | F-02 |
| RS-06 | Plan Enterprise: `Custom` en precio, volumen y sobrecoste (`\| Enterprise \| Custom \| Custom \| Custom \|`). | [F2], pricing_md.txt | doc | 🟢 | `plans.enterprise.price` = custom | — |
| RS-07 | Enterprise se ofrece `For teams sending 3M+ emails/month`; `Enterprise customers commonly send 3M-500M+ emails per month`. | pricing_md.txt | doc | — | — | — |
| RS-08 | Moneda de todos los precios: dólares (`$`). | [F1], [F2] | doc | 🟢 | `currency` = USD | — |
| RS-09 | Producto de marketing con catálogo aparte: Free `$0/mo` / `1,000` contacts; Pro marketing `$40/mo` / `5,000`, `$80/mo` / `10,000`, `$120/mo` / `15,000`, `$180/mo` / `25,000`, `$250/mo` / `50,000`, `$450/mo` / `100,000`, `$650/mo` / `150,000`; Enterprise `Custom`. `Marketing plans are not limited by the number of emails sent — only by the number of contacts.` | [F2], pricing_md.txt | doc | — (fuera de alcance, Q1) | — | F-10 |
| RS-10 | La cuenta lleva dos suscripciones independientes: `Transactional — 3,000 emails — $0 / mo` y `Marketing — 1,000 contacts — $0 / mo`. | [F9] (`panel_suscripciones_2026-09-01_redactado.png`) | panel | — | — | F-10 |
| RS-11 | Add-on `Dedicated IPs — $30 / mo`, `Available on the Scale plan to customers exceeding 3,000 emails sent per day`. | [F1], pricing_md.txt | doc | — (solo provenance) | — | F-07 |
| RS-12 | En el panel, el add-on de IP dedicada se ofrece `Dedicated IPs - $30 / Mo … You'll need to be on a Scale plan or higher to request a dedicated IP.` | [F9] (`panel_addons_payg_2026-09-01_redactado.png`) | panel | — | — | F-07 |
| RS-13 | Add-on `Domains - $20 / Mo — Adds 100 domains on top of the number included in your plan. You'll need to be on a paid transactional plan to add more domains.` | [F9], pricing_md.txt (`Available on Pro and Scale`) | panel + doc | — | — | F-07, F-11 |
| RS-14 | Add-on `Single Sign-On - $150 / Mo … Scale plan or higher`; en pricing `included on Enterprise plans`. | [F9], pricing_md.txt | panel + doc | — | — | F-07 |
| RS-15 | El panel no tiene formulario de envío transaccional (`No sent emails yet — Start sending emails to see insights…`, remite a `Go to docs`); el único envío desde la interfaz es *Broadcasts* (marketing). | [F9] | panel + doc | 🟢 | `type` = api_first (🟢 por D9: las ocho comprobadas por los dos lados, [F10] doc y [F11] panel; la única asimetría va a favor de la API, que gestiona supresiones sin sección en el panel) | C2, D-031 |
| RS-16 | Canal SMTP con la misma credencial: host `smtp.resend.com`, puerto `465`, usuario `resend`, contraseña `YOUR_API_KEY`. | [F9] | panel | — | — | — (familia no capacitaria) |
| RS-17 | Todos los planes incluyen, entre otros: `RESTful API, SMTP relay, official SDKs, inbound emails, batch sending, … multi-region, … webhooks`. | pricing_md.txt | doc | — | — | — |
| RS-18 | Soporte por plan: Free `Ticket support`; Scale `Slack & ticket support` / `Dedicated Slack channel`; Enterprise `Priority support`, `99.99% uptime SLA`. | [F1], pricing_md.txt | doc | — | — | — |

## 2. Cuotas

| id | hecho | fuente | escalón | semáforo | ruta YAML | fricción |
|---|---|---|---|---|---|---|
| RS-20 | Free: `3,000 emails / mo`. | [F1], [F2], pricing_md.txt | doc | 🟢 | `capacity.quota_email_transactional_monthly_free.value` = 3000 emails / 1 MONTH | — |
| RS-21 | Free: `Limited to 100 emails per day.` / `100 emails a day`. | [F2], [F7], pricing_md.txt | doc | 🟢 | `capacity.quota_email_transactional_daily_free.value` = 100 emails / 1 DAY | — |
| RS-22 | Pro: `50,000 emails / mo`. | [F1], [F2] | doc | 🟢 | `capacity.quota_email_transactional_monthly_pro.value` = 50000 | F-02 |
| RS-23 | Scale: `100,000 emails / mo`. | [F1], [F2] | doc | 🟢 | `capacity.quota_email_transactional_monthly_scale.value` = 100000 | F-02 |
| RS-24 | Enterprise: volumen `Custom`. | [F2] | doc | 🟢 | `capacity.quota_email_transactional_monthly_enterprise.value` = custom | — |
| RS-25 | Error `daily_quota_exceeded`: `Upgrade your plan to remove the daily quota limit or wait until 24 hours have passed.` (no dice desde cuándo cuentan las 24 h). | rate_limit.txt; [F9] reverificación (página de errores, 2026-09-01) | doc | 🟡 | `capacity.quota_email_transactional_daily_free.window_type` = rolling | — (hueco en `not_found`) |
| RS-26 | Error `monthly_quota_exceeded`: `Upgrade your plan to increase the monthly email quota.` | rate_limit.txt | doc | — | — | — |
| RS-27 | Pro tiene `No daily limit` / `No daily email limit`; la knowledge base dice `Paid plans have no daily sending limit`. | [F1], pricing_md.txt, [F7] (2026-09-01) | doc | — (Pro/Scale/Enterprise sin cuota diaria en el YAML) | `plans.pro.endpoints./emails.quota` → cuota mensual | — |
| RS-28 | La cuota se consume por destinatario: `Multiple To, CC, or BCC recipients count as separate emails.` | [F7] | doc | 🟢 | `plans.*.endpoints./emails.workload[0].description` | F-03 |
| RS-29 | `Both sent and received emails count towards these quotas.` (documentado el 2026-09-01; no constaba el 2026-08-05). | rate_limit.txt, [F4] reverificación | doc | — (solo provenance) | — | F-12 |
| RS-30 | El panel desglosa `Monthly limit 0 / 3000` y `Daily limit 0 / 100` en `Sending` y `Receiving`. | [F9] (`panel_cuota_transaccional_2026-09-01_redactado.png`, `panel_usage_transaccional_2026-09-06_redactado.png`) | panel | — | — | F-12 |
| RS-31 | Un entrante por encima de cuota se recibe pero no se lee: `email_above_quota (403): You can't retrieve this email's content because it was above quota when received`. | [F9] reverificación (página de errores, 2026-09-01) | doc | — | — | F-12 |
| RS-32 | Cabeceras de cuota en cada respuesta: `x-resend-daily-quota Your used daily email sending quota. Only sent to free plan users.` y `x-resend-monthly-quota Your used monthly email sending quota.` | rate_limit.txt | doc | — (solo provenance) | — | — (observabilidad, familia no capacitaria) |
| RS-33 | Sondeo: primer envío del día devuelve `x-resend-daily-quota: 0` y `x-resend-monthly-quota: 0`; el siguiente envío aceptado devuelve `1` y `1` (consumo acumulado **antes** de la petición). | probe.json (casos `A_ventana_diaria_1_envio`, `B3_to_25_cc_25_total_50`), [E1] | sondeo | — (solo provenance) | — | — |
| RS-34 | Tras dos envíos (uno a 1 destinatario, otro a 50 direcciones idénticas) el panel muestra `Monthly limit 2 / 3000` y `Daily limit 2 / 100`: las 50 direcciones idénticas contaron como 1. | [E1] (`panel_usage_tras_sondeo_2026-09-06_redactado.png`) | panel + sondeo | — (solo provenance) | — | — (observación; no fricción) |
| RS-35 | Retención de datos `30-day data retention` en Free, Pro y Scale; `flexible data retention` en Enterprise. | [F1], [F2], pricing_md.txt | doc | — (fuera de `capacity`, Q4) | — | DISC-03 |
| RS-36 | Modelado previo del repositorio (2026-02-24): retención `1` día Free, `3` Pro, `7` Scale, serializada como `quota_log_retention_days_free: value: 1, unit: records`. | [F8] | doc | — | — | DISC-03, O-04, F-09 |
| RS-37 | Automatizaciones: `All paid plans include 10,000 Automation Runs per month`; `The Free plan includes 10,000 Automation Runs per month with no overage`. | pricing_md.txt | doc | — | — | — |
| RS-38 | Límites de recursos por plan: dominios `3 / 10 / 1,000 / Set by contract`; webhook endpoints `1 / 5 / 10 / Flexible`; AI credits `5 / 100 / 500 / Flexible` (`Credits reset monthly. Unused credits do not roll over.`). | pricing_md.txt, [F9] reverificación | doc | — (eliminados del YAML por Q6) | — | F-11, DISC-05 |
| RS-39 | Panel, sección Team del plan Free: `Domains 0 / 3`, `Automations 0 / 10.000`, `AI credits 0 / 5`. | [F9] (`panel_limites_equipo_2026-09-01_redactado.png`) | panel | — | — | F-11, DISC-05 |
| RS-40 | Panel, Marketing · Free: `Contacts limit 0 / 1000`, `Segments limit 1 / 3`, `Broadcasts limit Unlimited`. | [F9] | panel | — (fuera de alcance, Q1) | — | F-10 |
| RS-41 | Cuota de contactos (marketing): se pueden añadir contactos por encima del límite pero no enviar broadcasts; el 403 dice `You have reached your contacts quota. Please upgrade your plan to send more emails.` | rate_limit.txt | doc | — (fuera de alcance, Q1) | — | F-10 |

## 3. Rates

| id | hecho | fuente | escalón | semáforo | ruta YAML | fricción |
|---|---|---|---|---|---|---|
| RS-50 | `The default maximum rate limit is 10 requests per second per team.` | [F4], rate_limit.txt | doc | 🟢 | `max_power.rate_request_team_free.value` = 10 requests / 1 SECOND | — |
| RS-51 | El mismo valor por defecto se asigna a Pro y Scale porque la documentación no lo hace variar por plan (decisión Q3: 🟢 el valor por defecto). | [F4]; REVISION.md Q3 | doc | 🟢 | `max_power.rate_request_team_pro.value` = 10; `max_power.rate_request_team_scale.value` = 10 | F-01 (parcial) |
| RS-52 | `This limit applies across all API keys associated with your team.` (caudal por equipo, no por clave). | rate_limit.txt; [F8] (`segmentation: Account Level … Múltiples API Keys aplican sobre el mismo límite global`) | doc | — | — | — |
| RS-53 | `This number can be increased for trusted senders upon request.` / `contact support to request a rate increase`. | [F4], rate_limit.txt | doc | 🔴 (Enterprise) | `max_power.rate_request_team_enterprise.value` = vacío | F-01 (parcial) |
| RS-54 | Panel, Team · Free: `Rate limit 10 req/s` (visto el 2026-09-01 y el 2026-09-06). | [F9] (`panel_limites_equipo_2026-09-01_redactado.png`, `panel_usage_equipo_payg_2026-09-06_redactado.png`) | panel | 🟢 | `max_power.rate_request_team_free` | — |
| RS-55 | Sondeo: cabeceras `ratelimit-limit: 10`, `ratelimit-policy: 10;w=1`, `ratelimit-remaining: 9`, `ratelimit-reset: 1` en cada respuesta. | probe.json, [E1] | sondeo | 🟢 | `max_power.rate_request_team_free` | — |
| RS-56 | Cabeceras documentadas: `ratelimit-limit`, `ratelimit-remaining`, `ratelimit-reset` (`How many seconds until the limits are reset.`) y `retry-after` (`How many seconds to wait before making a follow-up request.`), `in conformance with the sixth IETF standard draft`. | [F4], rate_limit.txt | doc | — | — | — |
| RS-57 | Al superar el caudal: `429` — `The rate limit was exceeded.` | [F3], rate_limit.txt | doc | — | — | — |
| RS-58 | Enterprise lista `Enterprise rate limits` como característica del plan. | pricing_md.txt | doc | 🔴 | `max_power.rate_request_team_enterprise` | F-01 (parcial) |
| RS-59 | Modelado previo del repositorio (2026-02-24): `2 requests/second` en los cuatro planes (`rate_api_request_team_pool_free: value: 2`). | [F8] | doc | — | — | DISC-02, F-09 |

## 4. Workload y tamaños

| id | hecho | fuente | escalón | semáforo | ruta YAML | fricción |
|---|---|---|---|---|---|---|
| RS-60 | Campo `to` de `/emails`: `For multiple addresses, send as an array of strings. Max 50.` | [F5] | doc | 🟢 | `plans.*.endpoints./emails.workload[0].max` = 50 | DISC-04 |
| RS-61 | Campos `cc` y `bcc`: `For multiple addresses, send as an array of strings.` sin tope declarado. | [F5] | doc | — | — | DISC-04 |
| RS-62 | Sondeo B1: 51 direcciones en `to` → HTTP `422`, `Field `to` has a maximum of 50 items.` | probe.json (`B1_to_51`), [E1] | sondeo | 🟢 | `plans.*.endpoints./emails.workload[0].max` | DISC-04 |
| RS-63 | Sondeo B2: 26 en `to` + 25 en `cc` (51) → HTTP `422`, `The total number of recipients cannot exceed 50.` | probe.json (`B2_to_26_cc_25_total_51`), [E1] | sondeo | 🟢 | ídem | DISC-04 (resuelta), F-03 |
| RS-64 | Sondeo B3: 25 en `to` + 25 en `cc` (50) → HTTP `200`. | probe.json (`B3_to_25_cc_25_total_50`), [E1] | sondeo | 🟢 | ídem | DISC-04 (resuelta) |
| RS-65 | `/emails/batch`: `Trigger up to 100 batch emails at once.` | [F6] | doc | 🟢 | `plans.*.endpoints./emails/batch.workload[0].max` = 100 | F-03 |
| RS-66 | En cada mensaje del lote, `to` lleva `Max 50`; el tope conjunto del lote no se aclara. | [F6] | doc | — | — | F-03; `not_found` |
| RS-67 | Adjuntos: `max 40MB per email, after Base64 encoding of the attachments`. | [F5] | doc | — (solo provenance; `MBs` figura en `consumption_units`) | `consumption_units` incluye `MBs` | F-06 |
| RS-68 | En `/emails/batch`, `The attachments field is not supported yet.` | [F6] | doc | — | — | — |
| RS-69 | `scheduled_at`: `The date should be in natural language (e.g.: 'in 1 min') or ISO 8601 format.` | [F5] | doc | — | `plans.pro/scale/enterprise.endpoints./emails/{id}/cancel` (descripción) | — |
| RS-70 | Base de la API `https://api.resend.com`; autenticación `Bearer re_xxxxxxxxx`; `401` = `The API key used was missing.`; `403` = `The API key used was invalid.` | [F3] | doc | — (`base_uri` retirado por Q7) | — | — |
| RS-71 | Sin dominio verificado, `403` — `You can only send testing emails to your own email address`; el sondeo se hizo desde `onboarding@resend.dev` a la propia dirección. | [F9] reverificación (página de errores), [E1] | doc + sondeo | — | — | — |
| RS-72 | Sondeo: las cuatro llamadas se hicieron entre `2026-09-06T18:36:25Z` y `2026-09-06T18:36:33Z` y en todas `ratelimit-remaining` siguió en `9`. | probe.json | sondeo | — | — | — |

## 5. Sobrecoste

| id | hecho | fuente | escalón | semáforo | ruta YAML | fricción |
|---|---|---|---|---|---|---|
| RS-80 | Pro y Scale (primer volumen): `Extra emails: $0.90 / 1,000` / `Overage (per 1,000)` = `$0.90`. | [F1], [F2], pricing_md.txt | doc | 🟢 | `capacity.quota_email_transactional_monthly_pro.overage_cost` = {price: 0.0009, value: 1}; ídem `_scale` (serializado por email, no por millar) | F-02 |
| RS-81 | El sobrecoste de Scale baja con el volumen contratado: `$0.90` (100,000), `$0.80` (200,000), `$0.70` (500,000), `$0.65` (1,000,000), `$0.52` (1,500,000), `$0.46` (2,500,000); en Pro se mantiene en `$0.90` en sus dos volúmenes. | [F2], pricing_md.txt | doc | — (solo provenance) | — | F-02 |
| RS-82 | `The overage rate applies only to emails sent beyond the included volume.` | [F2], pricing_md.txt | doc | — | — | — |
| RS-83 | Free sin sobrecoste: `—` en la tabla de pricing; knowledge base `Overage Not available`. | pricing_md.txt, [F7] (2026-09-01) | doc | — (Free sin `overage_cost`) | `capacity.quota_email_transactional_monthly_free` (sin `overage_cost`) | F-13 |
| RS-84 | El pay-as-you-go es un interruptor apagado marcado `Paid feature`: `Transactional · $0.90 / Per 1,000 Emails — When enabled, you will continue sending and receiving transactional emails beyond your quota. Resend will automatically charge $0.90 for each additional bucket of 1,000 emails.` | [F9] (`panel_addons_payg_2026-09-01_redactado.png`, `panel_usage_equipo_payg_2026-09-06_redactado.png`) | panel | — | — | F-13 |
| RS-85 | Enterprise: sobrecoste `Custom`. | [F2], pricing_md.txt | doc | — (Enterprise sin `overage_cost`) | — | — |
| RS-86 | Automatizaciones de pago: `Beyond that, pay-as-you-go billing applies at $0.0015 per run.` (Free: `no overage`). | pricing_md.txt | doc | — | — | — |

## 6. Vigencia

| id | hecho | fuente | escalón | semáforo | ruta YAML | fricción |
|---|---|---|---|---|---|---|
| RS-90 | Fechas de la datasheet: recolección documental `2026-08-05`; panel `2026-09-01` y `2026-09-06`; sondeo `2026-09-06, 18:36 UTC`; `date` del YAML `2026-09-01`. | fuentes.md (cabecera, [F9], [E1]); datasheet.yaml | doc/panel/sondeo | — | `date` = 2026-09-01 | F-09 |
| RS-91 | Reverificación adversarial de [F1]–[F7] el 2026-09-01: `Ningún valor modelado ha cambiado` (precios, volúmenes, sobrecostes, 100/día, 3.000/mes, `Max 50`, 100 por lote, 40 MB, 10 rps, 30 días). | [F9] (sección «Reverificación adversarial») | doc | — (nota en provenance) | — | F-09 |
| RS-92 | Caudal `2 requests/second` en el repositorio (2026-02-24) frente a `10 requests per second` en la documentación (2026-08-05). | [F8], [F4] | doc | 🟢 (se toma 10) | `max_power.rate_request_team_*` | DISC-02, F-09 |
| RS-93 | Retención `1 / 3 / 7` días por plan en el repositorio (2026-02-24) frente a `30-day` en todos los planes (2026-08-05). | [F8], [F1], [F2] | doc | — | — | DISC-03, F-09 |
| RS-94 | Dominios incluidos en Free: `1` en el pricing del 2026-08-05; `3` en pricing, knowledge base y panel el 2026-09-01. | [F1], [F2], pricing_md.txt, [F9] | doc + panel | — | — | DISC-05, F-09, F-11 |
| RS-95 | Entre el 2026-08-05 y el 2026-09-01 la página de rate limit pasó a llamarse `Usage Limits` y añadió `Both sent and received emails count towards these quotas` y las cabeceras `x-resend-daily-quota` / `x-resend-monthly-quota`. | [F4], rate_limit.txt, [F9] reverificación | doc | — | — | F-12, F-09 |
| RS-96 | Entre las mismas fechas la knowledge base añadió `based on the number of emails sent and received each month`, `Overage Not available` (Free) y `Paid plans have no daily sending limit`. | [F7], [F9] reverificación | doc | — | — | F-13, F-09 |
| RS-97 | Segunda visita al panel el 2026-09-06: mismas cifras que el 2026-09-01; `sin fecha de ciclo porque el plan es gratuito`. | [F9] (segunda visita) | panel | — | — | — |
| RS-98 | La ventana diaria sigue pendiente: lectura del contador prevista el `2026-09-07` hacia las `18:06 UTC` (si sigue en 2/100, 24 h desde el envío) y hacia las `18:40 UTC` (si baja a 0, `rolling` confirmado). | [E1]; REVISION.md (cierre) | sondeo (pendiente) | 🟡 | `capacity.quota_email_transactional_daily_free.window_type` | — |
| RS-99 | Validación de formato tras el cierre: `16 ok / 0 avisos / 0 errores` (la pasada 1 daba `0 errores · 1 aviso`). | REVISION.md | — | — | — | — |

## 7. Lo que el proveedor no publica

| id | hecho | fuente | escalón | semáforo | ruta YAML | fricción |
|---|---|---|---|---|---|---|
| RS-100 | Origen de la ventana de 24 h del límite diario (desde el primer envío o desde el rechazo): la documentación solo dice `wait until 24 hours have passed`; el panel no muestra fecha de reposición. | rate_limit.txt; [F9]; `metadata.not_found` | doc + panel | 🟡 | `capacity.quota_email_transactional_daily_free.window_type` = rolling | — |
| RS-101 | Ventana del contador mensual: el panel no muestra fecha de reposición ni fecha de ciclo (`sin fecha de ciclo porque el plan es gratuito`). | [F9] (2026-09-01 y 2026-09-06) | panel | 🟡 | `capacity.quota_email_transactional_monthly_*.window_type` = fixed_billing_cycle | — |
| RS-102 | Caudal del plan Enterprise: no publicado; `Enterprise rate limits` se lista como característica sin cifra. | pricing_md.txt; `metadata.not_found` | doc | 🔴 | `max_power.rate_request_team_enterprise.value` = vacío | F-01 (parcial) |
| RS-103 | Umbral que define a un `trusted sender` y caudal concedido `upon request`: no publicados; el panel del plan Free enseña `Rate limit 10 req/s` y ninguna vía de solicitud. | [F4], [F9]; `metadata.not_found` | doc + panel | — | — | F-01 (parcial) |
| RS-104 | Si el caudal varía por plan: la documentación solo da un valor por defecto, `no se afirma ni se niega que varíe`. | fuentes.md («Fuentes buscadas y NO encontradas») | doc | 🟢 (Pro/Scale por decisión Q3) | `max_power.rate_request_team_pro`, `_scale` | F-01 (parcial) |
| RS-105 | Cooling period tras un 429: solo la cabecera `retry-after`, `el valor lo fija el servidor en cada respuesta`; el repositorio lo tenía como `coolingPeriod: TBD`. | [F4], [F8]; `metadata.not_found` | doc | — | — | — |
| RS-106 | Tope conjunto de destinatarios por mensaje dentro de `/emails/batch`: `Max 50` solo en el `to` de cada mensaje, sin aclarar el conjunto. | [F6]; `metadata.not_found` | doc | — | — | F-03 |
| RS-107 | Deduplicación de destinatarios repetidos: no documentada; observada (50 direcciones idénticas = 1 unidad). `No prueba nada sobre destinatarios distintos`. | [E1]; fricciones.md («Observación del sondeo») | sondeo + panel | — | — | — (observación) |
| RS-108 | Especificación OpenAPI/Swagger pública: `No localizada` en docs ni en GitHub del proveedor. | fuentes.md («Fuentes buscadas y NO encontradas») | doc | — | — | — |
| RS-109 | Límites de la API de marketing (broadcasts): producto de precio aparte, limitado por contactos; `fuera del alcance de esta pasada`. | fuentes.md («Fuentes buscadas y NO encontradas»), [F2] | doc | — | — | F-10 |
| RS-110 | Entregabilidad, reputación y warm-up no se publican como cifra: *Metrics* muestra `Deliverability rate`, `Bounce rate`, `Complain rate` por dominio; la IP dedicada `will provision, warm up, monitor and auto-scale`. | [F9] | panel | — | — | — (familia no capacitaria) |

---

## Discrepancias entre fuentes

| id | discrepancia | filas implicadas | estado según los ficheros |
|---|---|---|---|
| DISC-02 | Caudal: `2 requests/second` en el repositorio de la guía (2026-02-24) frente a `10 requests per second per team` en la documentación oficial (2026-08-05, reverificado 2026-09-01 y por sondeo 2026-09-06). | RS-50, RS-54, RS-55, RS-59, RS-92 | Se toma 10 rps; el anterior queda registrado con fecha. Cambio de la oferta, no error. |
| DISC-03 | Retención de datos: `1 / 3 / 7` días por plan en el repositorio frente a `30-day` en Free, Pro y Scale en el pricing. | RS-35, RS-36, RS-93 | Se toma 30 días; no se modela como cuota (Q4). |
| DISC-04 | Tope de destinatarios: `Max 50` declarado solo en `to` [F5] frente a la API, que lo aplica a la suma de `to`+`cc`+`bcc` (`The total number of recipients cannot exceed 50.`). | RS-60, RS-61, RS-62, RS-63, RS-64 | **Resuelta por sondeo [E1] el 2026-09-06**: 50 en total por petición. Nota: la sección DISC-04 de `fuentes.md` conserva dos párrafos de la pasada 1 (`no está resuelto`, `no se ha sondeado todavía`) bajo la cabecera `RESUELTA`. |
| DISC-05 | Dominios incluidos en Free: `1` en el pricing del 2026-08-05 frente a `3` en pricing, knowledge base y panel el 2026-09-01. | RS-38, RS-39, RS-94 | Cambio de la oferta en menos de un mes. `fricciones.md` §F-11 lo formula como «1/10/1.000 según el pricing y 3 en Free según el panel»; `fuentes.md` precisa que el 2026-09-01 pricing y panel coinciden en 3. |
| (sin id) | Condición del add-on de IP dedicada: el pricing exige Scale **y** `exceeding 3,000 emails sent per day`; el panel solo menciona `Scale plan or higher`. | RS-11, RS-12 | No registrada como DISC en los ficheros; solo se anota aquí. |
| (sin id) | Cuota por destinatario: la documentación dice `Multiple To, CC, or BCC recipients count as separate emails`; el panel contó 1 unidad por un envío a 50 direcciones idénticas. | RS-28, RS-34, RS-107 | Los ficheros lo tratan como observación de deduplicación, no como contradicción: el caso de destinatarios distintos no se probó. |
| (sin id) | Semáforo de `rate_request_team_pro/scale`: la pasada 1 lo dejó en 🟡 (REVISION Q3); el YAML lo lleva en 🟢 tras la decisión Q3 del autor (`🟢 valor por defecto, 🔴 el negociado`). | RS-51, RS-104 | Coherente con la decisión; el histórico de REVISION.md conserva el 🟡 anterior. |

## Lo que sorprendería a un tribunal

1. **El mismo plan Scale son 100.000 emails a $0,90 el millar o 2.500.000 a $0,46, según el volumen contratado**, y la Datasheet solo puede serializar el primer peldaño. En el YAML el sobrecoste va además como `price: 0.0009` por email, cuando la fuente lo publica `$0.90 / 1,000`. (RS-04, RS-05, RS-80, RS-81)
2. **Un correo recibido gasta la misma cuota que uno enviado** (`Sending` / `Receiving` bajo el mismo contador; `Both sent and received emails count towards these quotas`), y uno recibido por encima de cuota se acepta pero no se puede leer. El 2026-08-05 ninguna fuente documental lo decía. (RS-29, RS-30, RS-31, RS-95)
3. **En tres semanas cambiaron la documentación, no los valores**: la página de rate limit se renombró, aparecieron las cabeceras de cuota, la knowledge base añadió `Overage Not available`, y los dominios de Free pasaron de 1 a 3. Todo con `date: 2026-09-01` a nivel de documento. (RS-91, RS-94, RS-95, RS-96)
4. **La documentación pone el tope de 50 en el campo `to`; la API lo aplica a la suma de `to`, `cc` y `bcc`**, con dos mensajes de error distintos según cómo se supere (`Field `to` has a maximum of 50 items.` frente a `The total number of recipients cannot exceed 50.`). (RS-60 a RS-64)
5. **Un envío a 50 direcciones idénticas consumió 1 unidad de cuota**, cuando la documentación dice que cada destinatario `count as separate emails`; y la cabecera de cuota devuelve el consumo *anterior* a la petición, no el posterior. Ninguna de las dos cosas está documentada. (RS-28, RS-33, RS-34, RS-107)
