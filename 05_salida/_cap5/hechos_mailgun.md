# Hechos — Mailgun

Extracción literal de `03_datos/apis/mailgun/` (`datasheet.yaml`, `fuentes.md`, `fricciones.md`,
`REVISION.md`, `features.md`, `evidencias/*`). Fecha de extracción: 2026-09-21.

Convenciones:
- **fuente**: id `[Fn]`/`[En]` de `fuentes.md`, o nombre de fichero de `evidencias/`.
- **escalón**: doc (documentación pública) · panel (cuenta propia, [F24]) · sondeo (petición real).
- **semáforo**: el que lleva el campo en `datasheet.yaml`; «—» si el hecho no está serializado
  (solo en `metadata.data_provenance`, `not_found` o en ninguna parte).
- **YAML**: ruta del campo donde vive el dato, cuando existe.
- Las cifras se citan tal como aparecen en la fuente (moneda, periodo, unidades). No se infiere,
  redondea ni completa nada. Un literal entre comillas es literal.
- Lo medido va marcado como medido, con su fecha y el literal de la respuesta. Lo inferido lleva
  su etiqueta y no se disfraza de medido.
- Donde el catálogo declara un hueco, el hueco es el hecho: se cita con la línea de
  `metadata.not_found` o con la fila de «Fuentes buscadas y NO encontradas» que lo sostiene.
- Esta API tiene **un solo bloque de sondeo fechado**, el del 2026-09-21, repartido en cinco
  guiones (A preflight, B envío, C ventana, D caudal de lectura, E segunda pasada). Solo el
  último está registrado en `fuentes.md` como **[E1]**; los otros cuatro se citan por el nombre
  del fichero de `evidencias/`, que es como los cita el propio `data_provenance`.

---

## 1. Planes y precios

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MG-01 | La moneda declarada de la Datasheet es USD. | [F1] | doc | 🟢 | `currency` | F-26 |
| MG-02 | Free: `"$0/mo"`. | [F1] | doc | 🟢 | `plans.free.price` (0.00, period 1 MONTH) | — |
| MG-03 | Basic: `"Starting at"` · `"$15/mo"`. | [F1] | doc | 🟢 | `plans.basic.price` (15.00, period 1 MONTH) | F-02 |
| MG-04 | Foundation: `"Free for 1 month, then"` · `"$35/mo"`. | [F1] | doc | 🟢 | `plans.foundation.price` (35.00) | F-02, F-14 |
| MG-05 | Scale: `"Free for 1 month, then"` · `"$90/mo"`. | [F1] | doc | 🟢 | `plans.scale.price` (90.00) | F-02, F-14 |
| MG-06 | El precio real lo fija un selector de la misma página: `"How many emails do you want to send per month?"`, con las posiciones `"10,000 50,000 100,000 250,000 500,000 750,000 1,000,000 2,500,000 More"`. | [F1] | doc | — | — (solo `data_provenance`, NOTA) | F-02 |
| MG-07 | Escalera de volumen, bloque de datos que lee el selector: Free `100` y Basic `10,000` no se mueven en ninguna posición; Foundation va de $35 con 50.000 correos a $75 con 100.000. | [F1] | doc | — | — (solo `data_provenance`, NOTA) | F-02 |
| MG-08 | Escalera de Scale: $90 con 100.000, $215 con 250.000, $400 con 500.000, $550 con 750.000, $700 con 1.000.000 y $1,250 con 2.500.000. | [F1] | doc | — | — (solo `data_provenance`, NOTA) | F-02 |
| MG-09 | El fichero modela **el tramo mínimo de cada tarjeta**; la escalera entera vive en dos notas del provenance. | `datasheet.yaml` | — | — | `capacity.quota_email_monthly_*.value` | F-02 |
| MG-10 | El plan de empresa no tiene fila ni tarjeta propia: `"Need more? Get in touch with our team to tailor an Enterprise experience to fit your needs."`, `"Partner with Mailgun to create an enterprise-grade solution for delivering email at scale."` y el botón `"Request a quote"`. Queda fuera de los planes modelados (regla A3). | [F1] | doc | — | — (solo `data_provenance`) | — |
| MG-11 | La misma página sirve la lista en tres divisas, fijadas por el proveedor a un cambio casi constante. La libra vale 0,80 del dólar en ocho de los nueve precios de plan, y el euro ronda el dólar entre 1,1. Foundation vale $35, €32 y £28 en su tramo mínimo. El fichero declara la lista en dólares. | [F1]; `evidencias/paginas/2026-09-21/features-02.txt` | doc | — | — (solo `data_provenance`, NOTA) | F-26 |
| MG-12 | El `"Free for 1 month, then"` de Foundation y Scale es promoción de captación y no altera el precio de lista que declara el fichero. | [F1] | doc | — | — (solo `data_provenance`, NOTA) | F-14 |
| MG-13 | No hay planes anuales ni toggle mensual/anual en el contenido recuperado; solo precios `/mo`. | `fuentes.md` («Fuentes buscadas y NO encontradas») | doc | — | — | — |
| MG-14 | Panel, cuenta propia: `"Mailgun Send"` · `"Your current plan"` · `"Free"` · `"$0"` · `"/ month"` · `"3000 emails per month"` · `"1 day of log retention"` · `"24/7 ticket support"`. | [F24] (`panel_mailgun_2026-09-21.md` P1) | panel | 🟢 | `plans.free.price` | DISC-03 |
| MG-15 | Panel, facturación: `"Upcoming bill"` · `"MAILGUN SEND"` · `"Free"` · `"0,00 US$"` · `"Estimated total"` · `"Autopay on the 1st of each month"` · `"The estimated total may be prorated, as appropriate, based on the billing period for selected plans."` | [F24] (P1) | panel | 🟡 (de ahí sale el `window_type` de los planes de pago) | `capacity.quota_email_monthly_{basic,foundation,scale}.window_type` | — |
| MG-16 | IP dedicada por plan: `"Access at 50k, included at 100K+ volumes"` (Foundation) · `"One Dedicated IP Included"` (Scale); no en Free ni en Basic. Add-on: `"you can add additional IPs to your account for $59/IP/month from within the control panel or by contacting support."` | [F1] | doc | — | — | F-07 *(verificar)* |
| MG-17 | Add-on de validación de correo: `"from $1.20 / 100 validations"` (Basic), escalonado por plan, con `"5,000 email validations included"` en Scale. | [F1] | doc | — | — | F-07 *(verificar)* |
| MG-18 | Retención de logs por plan: `"1 day log retention"` (Free y Basic) · `"5 days log retention"` (Foundation) · `"30 days log retention"` (Scale). | [F1] | doc | — | — | — |
| MG-19 | Retención de clasificación de rebotes, dimensión distinta en la misma tabla: `"1 day of bounce classification"` · `"1 day"` · `"5 days"` · `"30 days"`. | [F1] | doc | — | — | — |
| MG-20 | Retención de mensajes: no incluida en Free ni en Basic (`false`, sin cifra); `"1 day message retention"` en Foundation; `"Up to 7 days of Message Retention"` en Scale, con el tooltip `"Message retention defaults to 3 days and can be increased to 7 days on a per domain basis"`. | [F1] | doc | — | — | — |
| MG-21 | Confirmado en el panel para Free: `"Message retention is unavailable for your plan. Upgrade to start storing message bodies (MIMES) for later retrieval..."`. Es política de retención, no cuota. | [F24] (P3) | panel | — | — (solo `data_provenance`) | — |
| MG-22 | Dominios de envío propios por plan: `1` · `1` · `1,000` · `1,000`. | [F1] | doc | — | — | F-11 |
| MG-23 | `"The default limit is 1,000 domains per Mailgun account."` Límite de recurso (B3), no de consumo. | [F15] (`navegador-ai-info.txt`) | doc | — | — (solo `data_provenance`) | F-11 |
| MG-24 | Claves de API por plan: `"2 API keys"` en Free y en Basic; sin cifra publicada para Foundation ni Scale. | [F1] | doc | — | — (solo `data_provenance`) | F-11 |
| MG-25 | Usuarios: `"Free plans are limited to 1 user per account."` y `"Every Mailgun plan (except free and basic) allows you to add as many users as you need to your account at no additional cost."` — Basic queda excluido sin que se publique su cifra. | [F1] | doc | — | — (solo `data_provenance`) | F-11 |
| MG-26 | Entrada de correo: `"1 inbound route"` (Free) · `"5 inbound routes"` (Basic) · `"Full access to inbound routing"` (Foundation, sin cifra) · Scale hereda sin cifra propia. | [F1] | doc | — | — | F-11 |
| MG-27 | Webhooks: incluido en las cuatro columnas (`cols: true`), y `"Each event type is configured individually and can contain up to 3 URLs per event type."`, no condicionado a plan. | [F1], [F14] | doc | — | — (solo `data_provenance`) | F-11 |
| MG-28 | Filas de la matriz exclusivas de los planes altos: Multi-user Access, RBAC API Keys y Guaranteed Uptime SLA en Foundation y Scale; SAML SSO, Dedicated IP pools y Send Time Optimization solo en Scale. | [F1] | doc | — | — | F-08 |
| MG-29 | Soporte: `"Ticket support"` en las cuatro columnas; Scale añade `"Live phone & chat support"`. El panel precisa para Free `"24/7 ticket support"` y por **D5** manda el panel para ese matiz, sin que sea discrepancia. | [F1], [F24] | doc + panel | — | — | — |
| MG-30 | Región de datos, no condicionada por plan: `"Send email through the US or the EU from a single account. Mailgun's service is hosted within both regions, so your data can remain in the region of your choice."` | [F1] | doc | — | — | F-31 (variante) |
| MG-31 | La FAQ de IP dedicada cita un plan que no existe en la tabla: `"One dedicated IP is included with Foundation 100k, Growth and Scale plans."` El plan `"Growth"` no aparece ni en la tabla de precios ni en el bloque `pricingData.plans` (solo `free/basic/foundation/scale`). | [F1] | doc | — | `metadata.not_found` | — |
| MG-32 | Mailgun vende bajo la misma cuenta dos productos más, fuera de lo modelado por **A1**: el panel muestra `"Mailgun Optimize"` y `"Mailgun Inspect"`, los dos en `"No subscription"`. | [F24] (P1) | panel | — | — (solo `data_provenance`, NOTA) | F-10 |
| MG-167 | El servicio se identifica como `mailgun` y la URL de referencia del fichero es la página de precios, `https://www.mailgun.com/pricing/`. | `datasheet.yaml` | doc | 🟢 | `associated_saas`, `url` | — |
| MG-168 | Las unidades de consumo declaradas son `requests`, `emails`, `MBs` y `MiBs`. La cuarta, `MiBs`, está fuera de la lista de la guía y el validador la admite con aviso: es la unidad del tope de tamaño de la petición, que el proveedor expresa en mebibytes. | `datasheet.yaml` | doc | 🟢 | `consumption_units` | — |
| MG-169 | El fichero registra **24 URL** consultadas en `sources_visited`, que es la lista de lo leído y no la de lo citado: las citas viven en `fuentes.md` con su literal. | `datasheet.yaml` | doc | — | `metadata.sources_visited` | — |

## 2. Cuotas y ventanas

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MG-33 | Free, página pública: `"100 emails/day included"`. | [F1] | doc | 🟡 | `capacity.quota_email_daily_free.value` (100 emails / 1 DAY) | DISC-03, F-38 |
| MG-34 | Free, panel de la cuenta propia: `"3000 emails per month"`, con el contador `"Emails sent this month"` → `"0 / 3000"`. | [F24] (P1) | panel | 🟡 | `capacity.quota_email_monthly_free.value` (3000 emails / 1 MONTH) | DISC-03, F-38 |
| MG-35 | Las dos magnitudes se declaran por separado, cada una con su fuente, y ninguna sube a verde: ninguna fuente dice si la cifra diaria compone la mensual o si son dos topes concurrentes. | `metadata.not_found` #5; DISC-03 | doc + panel | 🟡 | `capacity.quota_email_daily_free`, `capacity.quota_email_monthly_free` | DISC-03, F-38 |
| MG-36 | El bullet del plan Basic dice `"No daily email limit"`, que es la única frase de la página que trata el tope diario como propio de otro plan. | [F1] | doc | — | — (solo `data_provenance`) | F-38 |
| MG-37 | Basic: `"10,000 emails/mo included"`. | [F1] | doc | 🟢 | `capacity.quota_email_monthly_basic.value` (10000 / 1 MONTH) | F-02 |
| MG-38 | Foundation: `"50,000 emails/mo included"`. | [F1] | doc | 🟢 | `capacity.quota_email_monthly_foundation.value` (50000) | F-02 |
| MG-39 | Scale: `"100,000 emails/mo included"`. | [F1] | doc | 🟢 | `capacity.quota_email_monthly_scale.value` (100000) | F-02 |
| MG-40 | Las tres cuotas de los planes de pago llevan `window_type: fixed_billing_cycle` **inferido**, no literal: sale del `"Autopay on the 1st of each month"` del panel, que habla del cobro y no del contador. | [F24]; REVISION §A4 | panel | 🟡 | `capacity.quota_email_monthly_{basic,foundation,scale}.window_type` | — |
| MG-41 | Las dos cuotas del plan Free se quedan **sin `window_type`**, con el campo vacío y el hueco declarado: el panel no publica ninguna ancla de reinicio. | `metadata.not_found` #7 | panel | 🔴 | `capacity.quota_email_{daily,monthly}_free.window_type` (vacío) | F-33 (no recurre) |
| MG-42 | Existe un tope de envío que fija **el propio titular**: `"The custom message limit imposes a hard limit on how many messages your account can send during a calendar month."`, con `"The timeframe for which the limit applies - m for months, d for days, h for hours"`. No es cuota de plan. | [F7] | doc | — | `plans.*.endpoints./v5/accounts/limit/custom/monthly`; `metadata.not_found` #12 | F-37 |
| MG-43 | El ejemplo de la documentación usa `limit=10000` solo como valor de muestra, no como valor por defecto del proveedor. | [F7] | doc | — | — | F-37 |
| MG-44 | Plantillas, tope de recurso: `"Mailgun caps usage of account-level templates to 100 templates and 40 versions per template. Domain-scoped templates have same limit set on a per sending domain basis."` El endpoint modelado es el de dominio: 100 y 40 en cada dominio de envío (corregido el 2026-10-31). No entra en `capacity` (B3). | [F9] | doc | — | `plans.*.endpoints./v3/{domain_name}/templates.workload[0].description` | F-11 |
| MG-45 | Umbrales de la política de uso aceptable, que son política y no cuota (B4): rebotes hasta el 5 %, quejas por correo no deseado hasta el 0,08 %, bajas hasta el 1,4 % (o 1 % si las bajas superan a los clics) y bloqueos por debajo del 20 %. | [F19] | doc | — | — (solo `data_provenance`) | F-18 |
| MG-46 | Y esos umbrales no se aplican de forma automática: `"The determination of whether and to what extent a customer's act or omission and is in violation of this AUP will be made at our sole discretion."` y `"Sinch Email reserves the right to update the parameters of the acceptable sending threshold without prior notice."` | [F19] | doc | — | — (solo `data_provenance`) | F-04, F-18 |
| MG-47 | La versión archivada de la política declara los mismos umbrales que la vigente (rebotes ≤5 %, quejas ≤0,08 %, bajas ≤1,4 %): no hay cambio de cifra entre las dos versiones públicas, así que **E3 no aplica**. | [F21] (revisión `01/14/2022`) | doc | — | — | F-09 |
| MG-48 | Arranque de cuenta nueva, descrito sin ninguna cifra: el proveedor `"gradually increases sending rates"` y `"automatically queues your email and sends them at rates that makes the ESPs happy, increasing those rates as your sending reputation grows"`. | [F17], [F18] | doc | — | — (solo `data_provenance`); `metadata.not_found` #14 | F-18 |
| MG-49 | El plan Free no puede enviar a cualquiera: `"Domain sandboxcc7d3466734a4ff18c9247a488599261.mailgun.org is not allowed to send: Free accounts are for test purposes only. Please upgrade or add the address to your authorized recipients."` (HTTP 403, **medido** el 2026-09-21). El texto nombra la cuenta Free, no el dominio de pruebas. | `sondeo_a_preflight_2026-09-21.txt` (T1) | sondeo | — | — (solo `data_provenance`) | F-18 |

## 3. Caudales

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MG-50 | Única cifra de caudal publicada por el proveedor: `"Yes. Mailgun has request limits per API call:"` · `"1,500 API requests per second per client IP"`. | [F15] (`navegador-ai-info.txt`) | doc | 🟡 | `max_power.rate_request_api` (1500 requests / 1 SECOND) | F-01, DISC-01 |
| MG-51 | El ámbar de esa cifra **no es reserva de método**: la página se transcribió con navegador el 2026-09-21 y el literal está verificado. El ámbar es que el proveedor acota `"per client IP"` y el esquema no tiene dimensión de ámbito, así que la cifra del fichero es el techo de una salida de red, no el de la cuenta ni el del plan. | [F15]; `data_provenance` NOTA; REVISION §A3 | doc | 🟡 | `max_power.rate_request_api` | F-01, F-31 |
| MG-52 | El mismo canal en SMTP: `"1,500 SMTP requests per second per client IP"`. No llega al fichero porque el esquema solo admite caudales colgados de un endpoint HTTP. | [F15] | doc | — | `metadata.not_found` #2 | F-15 |
| MG-53 | `"There are no concurrent connection or simultaneous request limits."` | [F15] | doc | — | — (solo `data_provenance`) | — |
| MG-54 | La documentación de la API describe el mecanismo entero y no publica ningún umbral: `"Mailgun APIs include the following headers to indicate rate limiting state for the current API being called: X-RateLimit-Limit — Total calls that can be made in each time window. X-RateLimit-Remaining — Calls remaining in the given time window. X-RateLimit-Reset — Unix milliseconds (UTC) until the limit resets. Used for back-off logic on a HTTP 429 response. Time windows may vary by API depending on resource usage."` | [F2] | doc | 🔴 (no hay umbral) | — (solo `data_provenance`) | F-01, DISC-01 |
| MG-55 | El contrato de rechazo publica el 429 sin cifra: `429 \| Rate Limited \| "Rate limits exceeded. Retry as defined in response headers defined below. Contact support if limits need adjustment"`. | [F2] | doc | — | — | F-01 |
| MG-56 | No hay cabecera `Retry-After`: Mailgun usa el nombre propio `X-RateLimit-Reset`. | [F2]; `fuentes.md` (no encontradas) | doc | — | — | — |
| MG-57 | El manual reconoce el límite y tampoco lo cifra: `"Mailgun does have rate limits in place to protect our system. In the unlikely case you encounter them and need them raised, please reach out to our support team."` | [F12] | doc | — | — (solo `data_provenance`) | F-01 |
| MG-58 | Caudal del envío, **medido** el 2026-09-21: un POST aceptado a `/v3/{domain_name}/messages` devuelve `x-ratelimit-limit: 80000`, `x-ratelimit-remaining: 79999`, `x-ratelimit-reset: 1790012856315`. | `sondeo_b_envio_2026-09-21.txt` | sondeo | 🟡 | `max_power.rate_request_send` (80000 requests / 10 SECOND) | F-36 |
| MG-59 | La misma respuesta trae un segundo contador sobre la misma ventana: `x-recipient-limit: 2000000`, `x-recipient-remaining: 1999999`, `x-recipient-reset: 1790012856315` — mismo instante de reposición. | `sondeo_b_envio_2026-09-21.txt` | sondeo | — | `metadata.not_found` #3 (el esquema admite un solo caudal por nodo) | F-36 |
| MG-60 | La ventana **medida** dura 9,852 s (17:48:37.879 → 17:48:47.731) y 9,870 s (17:48:55.836 → 17:49:05.706); el sondeo B, aislado, dio 10,315 s. El fichero declara diez segundos, que es un redondeo. | `sondeo_c_ventana_2026-09-21.txt`; `sondeo_resumen_2026-09-21.md` §C | sondeo | 🟡 | `max_power.rate_request_send.period` (10 SECOND) | F-35 |
| MG-61 | La ventana **no es rodante**: once peticiones repartidas en dos tandas comparten exactamente dos valores de `reset`, uno por tanda; en una rodante cada petición desplazaría el horizonte. | `sondeo_c_ventana_2026-09-21.txt` | sondeo | — | — | F-35 |
| MG-62 | La ventana se ancla en la **primera petición** que la abre, no en un instante del calendario, y al superarla el contador vuelve entero al tope (`79999` tras la primera petición de la ventana nueva), sin decaer gradualmente. | `sondeo_c_ventana_2026-09-21.txt` | sondeo | — | `metadata.not_found` #4 (ninguno de los tres `window_type` de v0.3 la describe) | F-35 |
| MG-63 | Las cabeceras de caudal **solo aparecen en un POST aceptado**: `GET /v4/domains?limit=1` devuelve 200 sin ninguna, y el POST rechazado con 403 tampoco las trae. En Mailgun el caudal no se lee sin gastar un envío. | `sondeo_a_preflight_2026-09-21.txt` (T4); `sondeo_resumen_2026-09-21.md` §A4, §B | sondeo | — | — (solo `data_provenance`, NOTA) | O-12 (observación de método) |
| MG-64 | El caudal medido se obtuvo desde una cuenta del plan **Free** y ninguna fuente atribuye caudales por plan, así que la misma clave se referencia desde los cuatro. | `data_provenance` NOTA; `metadata.not_found` #8 | sondeo + doc | 🟡 | `plans.*.endpoints./v3/{domain_name}/messages.rate` | F-01 |
| MG-65 | Sondeo de caudal de lectura, **resultado negativo declarado**: 1.570 peticiones `GET /v4/domains?limit=1` en seis tandas, **cero 429**. Tasas conseguidas 26,7 · 66,7 · 120,5 · 200,0 · 303,0 · 186,0 peticiones por segundo. | `sondeo_d_caudal_lectura_2026-09-21.txt` | sondeo | — | — (solo `data_provenance`, NOTA) | DISC-01 |
| MG-66 | El techo alcanzado, 303 peticiones por segundo, es **del cliente y no de la API**: subir de 200 a 400 procesos concurrentes bajó la tasa conseguida, que es la firma de la saturación local. El sondeo no confirma ni refuta las 1.500 por segundo publicadas. | `sondeo_d_caudal_lectura_2026-09-21.txt`; `sondeo_resumen_2026-09-21.md` §D | sondeo | — | — | DISC-01 |
| MG-67 | El 429 del envío **no se alcanzó** y por eso el caudal se adopta en ámbar por **D6**: forzarlo son 80.000 peticiones en diez segundos, que es una campaña de carga y no un sondeo. | REVISION §A2; `data_provenance` NOTA | sondeo | 🟡 | `max_power.rate_request_send` | F-01 |
| MG-68 | El caudal del producto hermano no se traslada al transaccional: `"API calls are subject to a rate limit of 500 requests every 10 seconds"` es de Mailgun Optimize, y ninguna fuente declara contador ni credencial compartidos (**B15**). | [F16] | doc | — | — (solo `data_provenance`, NOTA) | F-10 |

## 4. Destinatarios y topes por petición

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MG-69 | Referencia del endpoint de envío: `"Maximum 1,000 recipients per batch."` | [F5] | doc | 🟢 | `plans.*.endpoints./v3/{domain_name}/messages.workload[0].max` (1000 emails) | F-03 (no recurre), F-06 |
| MG-70 | Segunda página con el mismo tope: `"The maximum number of recipients allowed for batch is 1,000"`. | [F6] | doc | 🟢 | ídem | F-06 |
| MG-71 | **Medido** el 2026-09-21: 1.001 destinatarios → HTTP 400, `{"message":"Too many recipients, max is 1000"}`; 2.000 → el mismo 400. | `sondeo_a_preflight_2026-09-21.txt` (T2) | sondeo | 🟢 | ídem | F-06 |
| MG-72 | Con 100, 500 y 1.000 destinatarios la respuesta es 403 por la restricción de la cuenta Free: el tope de número no se alcanza. | `sondeo_a_preflight_2026-09-21.txt` (T2) | sondeo | 🟢 | ídem | — |
| MG-73 | El recuento de destinatarios se aplica **antes** que los permisos: con 1.001 el 400 por número gana al 403 por cuenta no autorizada, y por eso la cifra se pudo medir desde una cuenta que no puede enviar a nadie. | `sondeo_a_preflight_2026-09-21.txt`; `data_provenance` NOTA | sondeo | — | — (solo `data_provenance`) | — |
| MG-74 | Tamaño publicado por mensaje, en tres fuentes independientes: `"The maximum message size Mailgun supports is 25MB"` [F12], `"The maximum size is 25 MB per message on Mailgun."` [F15] y `"an individual email message not exceeding the per-message size limit (including attachments) of 25MB or it may be permanently lost."` [F20]. | [F12], [F15], [F20] | doc | — | — (solo `data_provenance`); `metadata.not_found` #10 | F-04, F-34 |
| MG-75 | `"Compressing message bodies does *not* bypass the above limit. This limit is enforced on the *uncompressed* body"`. | [F12] | doc | — | — (solo `data_provenance`) | F-04 |
| MG-76 | Ese tope publicado **no se aplica**, medido el 2026-09-21: adjuntos de 30, 35, 40, 45 y 48 MB atraviesan la comprobación de tamaño y solo caen después, por los permisos de la cuenta (403). | `sondeo_resumen_2026-09-21.md` §E3; `sondeo_a_preflight_2026-09-21.txt` (T3) | sondeo | — | — (solo `data_provenance`) | F-04, F-34 |
| MG-77 | El único tope que la API aplica en el borde: HTTP 413, `{"message":"request size exceeds 52.4MiB limit"}`. Es de la **petición entera**, no del mensaje. | `sondeo_a_preflight_2026-09-21.txt` (T3); `contraste_medido_vs_publicado_2026-09-21.md` §1 | sondeo | 🟡 | `plans.*.endpoints./v3/{domain_name}/messages.workload[1].max` (52 MiBs) | F-04, F-34, F-35 |
| MG-78 | El fichero declara **52 MiB y no 52,4**: el esquema tipa el máximo de un workload como entero, así que la cifra baja al entero inmediato inferior. Los 0,4 MiB de diferencia quedan en la nota y en `not_found`. | `data_provenance` NOTA; `metadata.not_found` #6 | sondeo | 🟡 | ídem | F-35 |
| MG-79 | Tope de los parámetros de opciones: `"Send options (parameters starting with o:, h:, v:, or t:) are limited to 16KB total"`. | [F5] | doc | — | — (solo `data_provenance`); `metadata.not_found` #11 | F-06 |
| MG-80 | **Medido**: 16 kB pasan la comprobación (403 de cuenta) y 17 kB devuelven 400 con `"Send options (parameters starting with o:, h:, or v:) are limited to 16 kB total"` — el mensaje de error enumera **tres** familias de parámetros y la referencia publicada enumera **cuatro** (`o:`, `h:`, `v:`, `t:`). | `sondeo_resumen_2026-09-21.md` §E2 | sondeo | — | — (solo `data_provenance`) | F-06 |
| MG-81 | Variables personalizadas: `"Anything over 4KB will be truncated in the event/webhooks"` (parámetros `v:`). | [F5] | doc | — | — | F-06 |
| MG-82 | Paginación de la consulta de eventos: `"The number of entries to return (300 max)"`. | [F8] | doc | — | `plans.*.endpoints./v3/{domain_name}/events.workload[0].description` | F-05 |
| MG-83 | **Medido**, con el rango en el propio error: `limit=300` → 200 y `limit=301` → 400 con `"Invalid parameter: limit=[\"301\"], Number out of range [1, 300]"`. | `sondeo_resumen_2026-09-21.md` §E1 | sondeo | — | ídem (RPR solo en la descripción) | F-05 |
| MG-84 | Importación masiva de rebotes: `"The CSV file must be 25MB or under"`. | [F10] | doc | 🟢 | `plans.*.endpoints./v3/{domain_name}/bounces/import.workload[0].max` (25 MBs) | F-06 |
| MG-85 | Lote por SMTP: `"If your \"X-Mailgun-Recipient-Variables\" header exceeds 998 characters, you should use folding to spread the variables over multiple lines."` Es del canal SMTP, no del HTTP. | [F6] | doc | — | — | F-15 |
| MG-86 | Canal SMTP: `"Mailgun SMTP servers listen on ports 25, 465, 587, and 2525. Port 465 requires a TLS connection."`, sin condicionar por plan. | [F13] | doc | — | — (solo `data_provenance`) | F-15 |
| MG-87 | Horizonte de programación por canal y por plan, con dos valores y sin atribución: `"Depending on your billing plan, you can schedule messages up to 3 or 7 days in advance."` | [F13] | doc | — | — (solo `data_provenance`); `metadata.not_found` #20 | F-15 |

## 5. Endpoints modelados

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MG-88 | El fichero modela **seis endpoints en cada uno de los cuatro planes**: `/v3/{domain_name}/messages`, `/v3/{domain_name}/events`, `/v4/domains`, `/v3/{domain_name}/templates`, `/v3/{domain_name}/bounces/import` y `/v5/accounts/limit/custom/monthly`. | `datasheet.yaml` | — | — | `plans.*.endpoints` | DISC-04 |
| MG-89 | Solo el plan Free cuelga una cuota del endpoint de envío (`quota: quota_email_daily_free`); los tres de pago cuelgan del envío únicamente el caudal. | `datasheet.yaml` | — | 🟡 | `plans.free.endpoints./v3/{domain_name}/messages.quota` | F-38 |
| MG-90 | El envío lleva **dos cargas** en el mismo endpoint: destinatarios (`emails`, 1..1000) y tamaño de la petición (`MiBs`, 1..52). El tercer tope medido, los 16 kB de opciones, no tiene unidad de consumo donde colgarse. | `datasheet.yaml`; fricciones §F-06 | — | 🟢 / 🟡 | `…/messages.workload[0]`, `…/messages.workload[1]` | F-06, O-01 |
| MG-91 | Los otros cinco endpoints se serializan con `workload: requests 1..1` y el tope real en la descripción: 300 entradas por petición (eventos), un dominio por petición, una plantilla por petición, 25 MB de CSV (rebotes) y una llamada para el tope propio. | `datasheet.yaml` | — | — | `plans.*.endpoints.*.workload` | F-05 |
| MG-92 | `type: api_first` en **ámbar**: el test C2 no se recorrió entero. El envío se opera por API, y también el alta de plantilla (`POST /v3/{domain_name}/templates`) y el alta de dominio (`"Creates a domain for sending emails"`). Quedan sin cita la edición de una plantilla ya creada y el disparo de la verificación DNS de un dominio ya creado, cuyas páginas de referencia devolvieron 404. | [F3], [F4]; `data_provenance` NOTA | doc | 🟡 | `type` | — |
| MG-93 | Base de la API por región: `"https://api.mailgun.net/"` (Estados Unidos) y `"https://api.eu.mailgun.net/"` (Unión Europea); el panel de la cuenta confirma `"Base URL"` → `https://api.mailgun.net`. | [F2], [F24] (P2) | doc + panel | — | — (solo `data_provenance`) | F-31 (variante) |
| MG-94 | El endpoint del tope propio se modela **sin cuota ni caudal asociados**, porque lo fija, consulta y borra el titular con una llamada, sin coste y sin aprobación del proveedor: la cifra no entra en la capacidad comparable (**B14**). | [F7]; `data_provenance`; `metadata.not_found` #12 | doc | — | `plans.*.endpoints./v5/accounts/limit/custom/monthly` | F-37 |
| MG-95 | La superficie real del producto que enseña el panel es mayor que la modelada: `/mg/reporting/{metrics,logs,bounce-classification,tags,saved-reports}`, `/mg/sending/{domains,<dominio>/templates,<dominio>/suppressions,<dominio>/webhooks/account-level,<dominio>/ips,mailing-lists,<dominio>/settings}`, `/mg/receiving/routes`, más el espacio `mgo` de Optimize y `/inspect/email-testing`. | [F24] (P6) | panel | — | — | F-10 |
| MG-96 | `[F11]`, la «Limits API» de la referencia, **no** es el rate limit de envío: es la API de umbrales (`thresholds`) de subcuentas de validación, y se descarta como fuente del contrato de rechazo del envío. | [F11] | doc | — | — | — |
| MG-97 | Existe el fichero de especificación OpenAPI (`.../\_spec/docs/mailgun/api-reference/send/mailgun.json`, OAS 3.1.0) y **no se ha descargado ni inspeccionado** en esta pasada. | [F23]; `metadata.not_found` #21 | doc | — | `metadata.not_found` | F-09 |

## 6. Sobrecoste

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MG-98 | Basic: `"from $1.80 / 1,000 emails"`. | [F1] | doc | 🟢 | `capacity.quota_email_monthly_basic.overage_cost` (price 0.0018, value 1; normalización unitaria) | F-02, F-13 |
| MG-99 | Foundation: `"from $1.30 / 1,000 emails"`. | [F1] | doc | 🟢 | `capacity.quota_email_monthly_foundation.overage_cost` (price 0.0013, value 1) | F-02, F-13 |
| MG-100 | Scale: `"from $1.10 / 1,000 emails"`. | [F1] | doc | 🟢 | `capacity.quota_email_monthly_scale.overage_cost` (price 0.0011, value 1) | F-02, F-13 |
| MG-101 | El plan Free **no publica ningún sobrecoste**, y sus dos cuotas no llevan `overage_cost`. | [F1]; `datasheet.yaml` | doc | — | `capacity.quota_email_{daily,monthly}_free` (sin `overage_cost`) | F-13 |
| MG-102 | Escalera del sobrecoste, del mismo bloque de datos que sirve las tarjetas: Basic tiene un solo tramo, `"Basic 10k $1.80"`; Foundation `"Foundation 50k $1.30"` y `"Foundation 100k $1.10"`; Scale `"Scale 100k $1.10"`, `"Scale 250k $0.90"`, `"Scale 500k $0.75"`, `"Scale 750k $0.60"`, `"Scale 1M $0.50"` y `"Scale 2.5M $0.40"`. | [F1] | doc | — | — (solo `data_provenance`, NOTA) | F-02 |
| MG-103 | El fichero lleva el sobrecoste **del tramo mínimo de cada tarjeta**: en Scale declara $0.0011 por correo, la tarifa más cara de su propia escalera, cuando el cliente de 2,5 millones paga $0.0004. La distancia entre lo declarado y lo real llega a 2,75 veces dentro del mismo plan. | fricciones §F-02 | doc | 🟢 (el valor declarado) | `capacity.quota_email_monthly_scale.overage_cost` | F-02 |
| MG-104 | No se publica ninguna cifra de sobrecoste **fija**: `[F1]` solo da `"from $X / 1,000 emails"`, que es precio de arranque y no unitario. | `fuentes.md` (no encontradas) | doc | — | — | F-02 |
| MG-105 | El único tope del exceso lo fija el titular (MG-42); el proveedor no publica ninguno, así que **F-16 no recurre**. | fricciones §Recuento | doc | — | — | F-37 |

## 7. Lo que el proveedor no publica

Las veintiuna entradas de `metadata.not_found` y las filas de «Fuentes buscadas y NO
encontradas» que no aparecen ya arriba. **Un hueco documentado es un dato del dominio**, y
por eso cada fila lleva la línea que lo sostiene.

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MG-106 | Umbral numérico del caudal **por cuenta o por plan**: no publicado. La documentación solo describe el 429 y las cabeceras de estado, declara que las ventanas varían por API, y la única cifra publicada acota por IP de cliente. | `metadata.not_found` #1; [F2], [F12], [F15] | doc | 🟡 | `max_power.rate_request_api` | F-01 |
| MG-107 | Caudal del canal SMTP: publicado (1.500/s por IP) y **sin nodo donde colgarlo**; el esquema solo admite caudales sobre endpoints HTTP. | `metadata.not_found` #2 | doc | — | `metadata.not_found` | F-15 |
| MG-108 | El tope de 2.000.000 de destinatarios de la misma ventana se queda fuera del fichero: el esquema admite un solo caudal por nodo. | `metadata.not_found` #3 | sondeo | — | `metadata.not_found` | F-36 |
| MG-109 | Tipo de ventana del caudal del envío: ninguno de los tres que admite v0.3 la describe, y el periodo declarado es un redondeo a diez segundos. | `metadata.not_found` #4 | sondeo | 🟡 | `metadata.not_found` | F-35 |
| MG-110 | Relación entre el tope diario de 100 y los 3.000 mensuales: ninguna fuente dice si la cifra diaria compone la mensual o si son concurrentes. | `metadata.not_found` #5 | doc + panel | 🟡 | `metadata.not_found` | DISC-03, F-38 |
| MG-111 | Los 0,4 MiB que separan el tope medido (52,4 MiB) del declarado (52 MiB) **no tienen dónde declararse**. | `metadata.not_found` #6 | sondeo | 🟡 | `metadata.not_found` | F-35 |
| MG-112 | Ancla del reinicio de las cuotas del plan Free: no publicada. El panel solo fecha el cobro, `"Autopay on the 1st of each month"`, y no muestra ningún contador diario junto al mensual. | `metadata.not_found` #7; [F24] | panel | 🔴 | `metadata.not_found` | F-38 |
| MG-113 | Si el caudal **varía por plan**: no mencionado en ninguna fuente. El valor declarado se midió sobre una cuenta del plan Free. | `metadata.not_found` #8 | doc | 🟡 | `metadata.not_found` | F-01 |
| MG-114 | Máximo de destinatarios entre los campos de destino en el **envío individual**, fuera del lote: no publicado. Las 1.000 direcciones publicadas y medidas son las del lote. | `metadata.not_found` #9; `fuentes.md` (no encontradas) | doc | — | `metadata.not_found` | F-06 |
| MG-115 | Tamaño por mensaje: el proveedor publica 25 MB en tres páginas distintas y **no lo aplica**. | `metadata.not_found` #10 | doc + sondeo | — | `metadata.not_found` | F-04 |
| MG-116 | El tope agregado de 16 kB de los parámetros de opciones suma tres familias distintas y se expresa en peso: el esquema no tiene forma ni para un límite que agrega familias ni para uno cuya unidad es el tamaño. | `metadata.not_found` #11 | doc + sondeo | — | `metadata.not_found` | F-06 |
| MG-117 | El tope que se impone el titular no es capacidad comparable entre proveedores y no entra en las cuotas. | `metadata.not_found` #12 | doc | — | `metadata.not_found` | F-37 |
| MG-118 | Tope de envío **por hora para cuentas nuevas**: el artículo de soporte que lo cuantificaría (`help.mailgun.com/hc/en-us/articles/115001124753`) devuelve HTTP 403 a WebFetch y a `curl` con user-agent de navegador, y no se ha renderizado. No se registra ninguna cifra. | `metadata.not_found` #13; `fuentes.md` (no encontradas) | doc | — | `metadata.not_found` | — |
| MG-119 | Duración y etapas del arranque de una cuenta nueva: no publicadas; las dos páginas que lo tratan describen el mecanismo sin cifras ni plazos. El *Automatic IP Warmup* documentado es exclusivo de IP dedicada. | `metadata.not_found` #14; `fuentes.md` (no encontradas) | doc | — | `metadata.not_found` | F-18 |
| MG-120 | Lista de destinatarios autorizados del dominio de pruebas: ni el panel la muestra como pantalla propia ni la documentación publica cuántos admite. Lo único medido es el rechazo. | `metadata.not_found` #15; [F24] | panel | — | `metadata.not_found` | — |
| MG-121 | Precio y condiciones del plan de empresa: no publicados, solo un botón de petición de presupuesto. | `metadata.not_found` #16 | doc | — | `metadata.not_found` | — |
| MG-122 | Tope acumulado de la paginación de eventos: **no medible con esta cuenta**, porque la retención del plan Free es de un día y solo hay 42 eventos. Resultado negativo por falta de material, no de intento. | `metadata.not_found` #17; [E1] | sondeo | — | `metadata.not_found` | F-05 |
| MG-123 | Número de rutas de entrada de correo en Foundation y Scale, y número de usuarios del plan Basic: no publicados. | `metadata.not_found` #18 | doc | — | `metadata.not_found` | F-11 |
| MG-124 | El plan `"Growth"` de la sección de preguntas frecuentes no aparece ni en la tabla de precios ni en el bloque de datos que sirve las tarjetas. | `metadata.not_found` #19 | doc | — | `metadata.not_found` | — |
| MG-125 | Qué campo distingue el horizonte de programación de 3 o 7 días entre planes: no publicado. | `metadata.not_found` #20 | doc | — | `metadata.not_found` | F-15 |
| MG-126 | Contenido del fichero de especificación de la API: existencia confirmada, no descargado. | `metadata.not_found` #21 | doc | — | `metadata.not_found` | F-09 |
| MG-127 | Tipo de ventana (rodante o fija) del caudal **general** de la API: no determinable, porque no hay umbral ni descripción de reinicio en la documentación de desarrollador. | `fuentes.md` (no encontradas) | doc | — | — | F-01 |
| MG-128 | Límites de concurrencia: no publicados en la documentación de desarrollador; la única frase que los trata es la de [F15], `"There are no concurrent connection or simultaneous request limits."` | `fuentes.md` (no encontradas) | doc | — | — | — |
| MG-129 | Tamaño de payload del lote en MB: no encontrado ni en [F5] ni en [F6]; solo se documenta el tope de 1.000 destinatarios. | `fuentes.md` (no encontradas) | doc | — | — | F-06 |
| MG-130 | Error 413 o mensaje literal para el caso de exceder los 25 MB: **no documentado**. El 413 solo existe medido. | `fuentes.md` (no encontradas) | doc | — | — | F-04 |
| MG-131 | Umbral que dispara específicamente un 403 por tamaño o por destinatarios: no encontrado; el 403 de [F2] es solo de permisos y credenciales. | `fuentes.md` (no encontradas) | doc | — | — | — |
| MG-132 | Endpoint de disparo de verificación DNS de un dominio ya creado, y endpoint de creación o rotación de una segunda clave de API: **no citables**, las páginas concretas devolvieron 404. | `fuentes.md` (no encontradas) | doc | 🟡 (afecta a `type`) | `type` | F-22 *(verificar)*, solo por la clave |
| MG-133 | Reventa oficial en marketplaces con pricing propio: no encontrada. Solo un listado de terceros no oficial en RapidAPI (`orliesaurus`), que por **D1** no cuenta como fuente del proveedor. | `fuentes.md` (no encontradas) | doc | — | — | — |
| MG-134 | La condición de *account probation* y el umbral de 100 mensajes/hora que citan terceros (Courier, MailTester): **no encontrados en fuente oficial**. | `fuentes.md` (no encontradas) | doc | — | — | F-18 |
| MG-135 | Changelog con un cambio numérico del caudal de la API REST del producto transaccional: no encontrado. Las entradas del último año sobre límites son todas de Optimize o de IP dedicada: `"ability to set usage limits for subaccounts enabled with Optimize features"`. | [F22]; `fuentes.md` (no encontradas) | doc | — | — | F-09 |
| MG-136 | Plantillas **a nivel de dominio**: ~~no se ha localizado cita propia que confirme si comparten el tope 100/40 de las de cuenta~~. Corregido el 2026-10-31: la frase siguiente de [F9] lo dice, `"Domain-scoped templates have same limit set on a per sending domain basis."`, y ya estaba en Wayback el 2026-06-12. Deja de ser hueco. | [F9] | doc | — | `plans.*.endpoints./v3/{domain_name}/templates.workload[0].description` | F-11 |

## 8. Lo medido en el escalón 3

Todo el escalón 3 de Mailgun es del **2026-09-21**, ejecutado por el agente en la máquina del
autor, contra el dominio sandbox `sandboxcc7d3466734a4ff18c9247a488599261.mailgun.org` de la
cuenta propia, plan Free. Las mediciones de caudal, destinatarios y tamaño están en §3 y §4;
aquí va lo que sostiene el sondeo como tal y lo que no cabe en otra sección.

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MG-137 | Presupuesto del día y coste: **13 envíos entregados**, 1 del sondeo B y 12 del sondeo C, todos a la dirección de la lista blanca de `docs/08-mandato.md`. Son el 0,43 % de los 3.000 correos mensuales del plan. Todo lo demás se midió sin gastar ningún envío. | `sondeo_resumen_2026-09-21.md` | sondeo | — | — | — |
| MG-138 | Los sondeos A y E declaran presupuesto **cero** y abortan ante cualquier 2xx de `/messages`; sus destinatarios van a `example.invalid` (RFC 2606). | `sondeo_a_preflight_2026-09-21.txt`, `sondeo_e_segunda_pasada_2026-09-21.txt`, [E1] | sondeo | — | — | — |
| MG-139 | El sondeo B confirma la entrega: `{"id":"<20260921174726.3c6e512a1c5dbdaa@sandbox….mailgun.org>","message":"Queued. Thank you."}` y `GET /v3/$dominio/stats/total` con `accepted.outgoing: 1`, `delivered.smtp: 1`, `failed.total: 0`. | `sondeo_b_envio_2026-09-21.txt`; `sondeo_resumen_2026-09-21.md` §B | sondeo | — | — | — |
| MG-140 | Cierre del día: `accepted {incoming: 0, outgoing: 13, total: 13}` y `delivered {smtp: 12, http: 0, optimized: 0, total: 12}`. | `sondeo_resumen_2026-09-21.md` («Contadores al cerrar el día») | sondeo | — | — | — |
| MG-141 | **[E1], segunda pasada del mismo día** (cerrada a las 20:53:37, `probe_mailgun_e_segunda_pasada.sh`): `POST /v3/$dominio/templates` desde el plan Free → 200 con `"template has been stored"`, plantilla `"sondeo-disc02-1790016807"`, creada `"Mon, 21 Sep 2026 18:53:28 UTC"`. | [E1] | sondeo | 🟢 | `plans.*.endpoints./v3/{domain_name}/templates` | F-08, DISC-02 |
| MG-142 | El script borra la plantilla a continuación y no deja estado en la cuenta: `DELETE /v3/$dominio/templates/sondeo-disc02-1790016807` → 200 con `"template has been deleted"`. | [E1] | sondeo | — | — | — |
| MG-143 | Esa medición cierra **DISC-02** y alcanza también a Basic: ningún literal distingue a Basic de Free en este endpoint —los bullets de los dos planes no mencionan plantillas— y la matriz los trata igual. Basic sube de 🟡 a 🟢 sobre el literal de la matriz, sostenido por la medición. | [E1]; `fuentes.md` DISC-02; `data_provenance` NOTA | sondeo + doc | 🟢 | `plans.basic.endpoints./v3/{domain_name}/templates` | F-08 |
| MG-144 | Profundidad de la paginación de eventos, **resultado negativo declarado**: `limit=300` → 200 con 42 items y enlace `paging.next` presente; siguiendo el enlace, 200 con 0 items y el `next` todavía presente. Total recorrido: 42 eventos en 2 páginas. | [E1] | sondeo | — | `metadata.not_found` #17 | F-05 |
| MG-145 | El cupo **no se gasta con intentos que no envían**: `"accepted.outgoing=13 delivered.smtp=13"` antes y después de un 400 por 1.001 destinatarios y un 403 por destinatario no autorizado. **F-21 no recurre**, y es un no medido. | [E1] | sondeo | — | — (solo `data_provenance`) | F-21 (no recurre) |
| MG-146 | El caudal de Mailgun **no se puede leer sin gastar un envío**, lo que condiciona la escalera de validación: la observación de un caudal y la medición de una cuota no son separables en esta API (observación O-12, que va a la guía de `sondeo-empirico` y no a un PR del esquema). | fricciones §O-12 | sondeo | — | — | O-12 |
| MG-147 | Cuatro cotas quedan **sin medir** porque la cuenta Free no puede enviar a nadie: el consumo real de cuota por destinatario, si la cola de reintento descuenta, el reprecio de la escalera al cambiar de plan y el sobrecoste aplicado. | REVISION §R1 | sondeo | — | — | — |
| MG-148 | La frase del fichero «cada destinatario consume una unidad de la cuota» es **inferencia, no literal**: ninguna fuente de Mailgun lo dice y el sondeo no pudo comprobarlo porque no llegó a enviar. | REVISION («Lo que no existe y habría que medir») | — | 🟢 (el `max`; la afirmación vive en la `description`) | `plans.*.endpoints./v3/{domain_name}/messages.workload[0].description` | — |

## 9. Discrepancias

`fuentes.md` registra tres con id. Las cuatro siguientes no tienen id en ningún fichero y se
levantan aquí al cruzar `datasheet.yaml`, `REVISION.md`, `fricciones.md` y `evidencias/`.

| id | filas | qué dice cada fuente | estado según los ficheros |
|---|---|---|---|
| DISC-01 (registrada) | MG-50, MG-51 vs MG-54, MG-57, MG-65 | **A:** [F2] describe las cabeceras y `"Time windows may vary by API depending on resource usage."`, sin ninguna cifra, y [F12] reconoce el límite sin cifrarlo. **B:** [F15], mismo dominio, `"1,500 API requests per second per client IP"`. | **Abierta.** La reserva de método (E10) se levantó el 2026-09-21 al transcribir la página con navegador; lo que queda es tensión de contenido entre dos fuentes oficiales. El sondeo no la desempata: midió otro contador (el del envío) y la rampa de lectura solo llegó a 303 peticiones por segundo, techo del cliente. `rate_request_api` en 🟡 con el alcance por IP anotado. |
| DISC-02 (registrada) | MG-141, MG-143 vs [F1] | **A:** la matriz comparativa marca `"Email Templates"` con `cols: true` en las cuatro columnas. **B:** la misma página, listado `"Features include:"`, no menciona plantillas en los bullets de Free ni de Basic, y Foundation enumera `"Email template builder and API"` bajo `"Everything on Basic plus..."`. | **Cerrada midiendo el 2026-09-21 ([E1]).** Manda A. Cierra por medición, no eligiendo lado (**E5**), y **D6** no aplica porque el sondeo se diseñó para esta pregunta. |
| DISC-03 (registrada) | MG-33 vs MG-34 | **A:** [F1], `"100 emails/day included"`. **B:** [F24], panel, `"3000 emails per month"` con `"0 / 3000"`. | **Abierta.** Aritméticamente compatibles (100 × 30 = 3.000) y no necesariamente el mismo dato; **D5** no dirime «página vs. panel» cuando el periodo declarado es distinto, y v0.3 tiene sitio para las dos magnitudes. Bloquea que las dos cuotas del Free suban a 🟢. Vía de cierre barata: agotar el tope diario y mirar si el mensual sigue entero — depende de R1. |
| Sin id | MG-88 vs REVISION | El `datasheet.yaml` modela **seis** endpoints en cada plan; el «Resumen de la pasada» de `REVISION.md` dice `Endpoints modelados \| 3 por plan: /v3/{domain_name}/messages, /v3/{domain_name}/events, /v4/domains`. | **Abierta, no comentada en ningún fichero.** El recuento del cierre se quedó corto en tres endpoints: plantillas, importación de rebotes y el tope propio. Afecta a cualquier cifra del capítulo 5 que cuente endpoints modelados por API. |
| Sin id | MG-140 vs MG-145 | El resumen del día cierra con `delivered {smtp: 12, total: 12}`; el log de [E1], esa misma noche, lee `"accepted.outgoing=13 delivered.smtp=13"` antes y después de los dos rechazos, y `REVISION.md` repite `delivered.smtp 13`. | **Abierta.** Los aceptados coinciden (13) y los entregados no (12 frente a 13). La lectura compatible es que el treceavo se entregó entre el cierre del resumen y el sondeo E, pero ningún fichero lo dice. |
| Sin id | MG-11 vs `fuentes.md` | El `data_provenance` declara tres divisas en la página de precios (`$35`, `€32`, `£28` en Foundation) y sostiene la recurrencia de **F-26**; la tabla «Fuentes buscadas y NO encontradas» de `fuentes.md` dice, sobre moneda distinta de USD, `"No visto selector de moneda en el contenido recuperado de [F1]"`. | **Abierta.** Compatibles si las tres listas se vieron con navegador y no en el contenido estático, pero ningún fichero lo declara: la fila de «no encontradas» no se retiró ni se anotó. |
| Sin id | MG-06, MG-07 vs `fuentes.md` [F1] | El `data_provenance` afirma que `"el bloque de datos que el selector lee publica precio y volumen por posición"` y lista la escalera entera; la ficha de [F1] dice `"Sin verificar con navegador: WebFetch es un fetch estático sin ejecución de JS, así que no se pudo determinar si mover el selector cambia el precio mostrado"`, y `features.md` mantiene PI-E02 como no respondible por eso. | **Abierta.** El fichero usa la escalera como dato y la ficha de la fuente la sigue dando por no verificada. |
| Sin id | MG-76, MG-77 vs `sondeo_a`/contraste | El sondeo A mide `adjunto=50MB → HTTP 413`; la bisección del resumen mide `48 MB → 403` y `52 MB → 413`, y el `data_provenance` narra «30, 35, 40, 45 y 48 MB atraviesan… con 52 MB llega el 413», sin mencionar el 50. | **Abierta.** Si el adjunto de 50 MB ya da 413, la frontera del 413 está entre 48 y 50 MB de adjunto, no entre 48 y 52. El literal del tope —`52.4MiB` de **petición entera**— no cambia; lo que queda sin conciliar es el punto de corte por tamaño de adjunto. |
| Sin id (textual) | MG-77 vs fricciones §F-04 | `fricciones.md` escribe «El único tope que la API aplica en el borde llega en **52 MB**, con `413 "request size exceeds 52.4MiB limit"`»; el literal medido dice 52,4 **MiB** y el YAML declara 52 **MiB**. | Textual, pero mezcla las dos unidades (MB y MiB) en la misma frase, que es justo la distinción sobre la que se levanta F-35. |

## 10. Fricciones

Columna de Mailgun sobre el catálogo de treinta y cuatro fricciones, **quince recurrentes,
una en variante en duda, dos variantes, cuatro nuevas y cinco sin dato**.

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MG-149 | Mailgun es la **octava API del catálogo** y la primera en la que el sondeo desmiente el tope publicado por un factor de dos. | `fricciones.md` (cabecera) | — | — | — | F-04 |
| MG-150 | Recurren, con literal registrado: F-01, F-02, F-04, F-05, F-06, F-09, F-10, F-11, F-13, F-15, F-18, F-26 y F-34. | `fricciones.md` §Recuento | — | — | — | — |
| MG-151 | **F-04 alcanza el umbral de D-008**: salió del piloto de Postmark y solo aparecía allí; con Mailgun van dos APIs, que es el mínimo que el marco exige para promover una fricción a propuesta de esquema. Y aquí el caso está **medido**, no declarado por el proveedor. | `contraste_medido_vs_publicado_2026-09-21.md` §1; fricciones §F-04 | sondeo | — | — | F-04 |
| MG-152 | **F-05** suma su sexto caso (Postmark, SendGrid, MailerSend, Brevo, Mailchimp y Mailgun): con seis de las ocho APIs, la RPR no serializable deja de ser carencia de una API y es dimensión del ACM que la serialización no cubre. | fricciones §F-05 | — | — | — | F-05 |
| MG-153 | **F-06 en variante triple**: una llamada a `/v3/{domain_name}/messages` está acotada a la vez por destinatarios (1.000), tamaño de petición (52,4 MiB) y parámetros de opciones (16 kB), y las tres tienen literal. El tercer tope no tiene unidad de consumo donde colgarse. | fricciones §F-06 | doc + sondeo | 🟢 / 🟡 | `…/messages.workload` | F-06 |
| MG-154 | **F-08 queda en variante en duda**: `plans` sí puede declarar endpoints distintos por plan, así que el problema no es de expresividad — es que la fuente no permite saber qué declarar. La superficie de la API por plan se publica en prosa comercial y no en la referencia técnica. | fricciones §F-08 | doc | — | — | F-08 |
| MG-155 | **F-14 falla V1**: lo que caduca en `"Free for 1 month, then"` es la promoción de captación, no el plan. | fricciones §Recuento | doc | — | — | F-14 |
| MG-156 | **F-31, variante y por debajo de la cuenta**: el caudal se acota `"per client IP"`, así que una cuenta con N salidas obtiene N veces el tope; y la base de la API se bifurca por región. | fricciones §Recuento | doc | — | — | F-31 |
| MG-157 | **F-35, nueva** — un tope fraccionario donde el esquema solo admite enteros. Las dos cifras medidas en el borde salieron fraccionarias: 52,4 MiB de tamaño y una ventana de 9,85–9,87 s. El README tipa `workload.min`/`workload.max` como `integer` (§3.4.2) y el periodo de un caudal como entero. | fricciones §F-35 | sondeo | 🟡 | `…/messages.workload[1].max`, `max_power.rate_request_send.period` | F-35 |
| MG-158 | Coste declarado de F-35: los 0,4 MiB son el 0,8 % de la cota y los 0,14 s son el 1,4 % de la ventana; con 80.000 peticiones, esa diferencia son **1.120 peticiones por ventana** que el modelo no sabe si existen. Y el error va siempre en el mismo sentido. | fricciones §F-35 | — | — | — | F-35 |
| MG-159 | **F-36, nueva** — dos contadores sobre la misma ventana y un solo caudal por nodo. Con 25 destinatarios de media por petición los dos topes caen a la vez; por encima de eso corta el de destinatarios, que es el perfil de quien usa la API de lotes. | fricciones §F-36 | sondeo | — | `max_power.rate_request_send`; `metadata.not_found` #3 | F-36 |
| MG-160 | **F-37, nueva** — un tope de capacidad que fija el cliente y no el proveedor. Para una herramienta que responda «¿cuánto puedo enviar?», la respuesta correcta es el mínimo entre la cuota del plan y ese tope, y hoy el segundo término no existe en el modelo. | fricciones §F-37 | doc | — | `plans.*.endpoints./v5/accounts/limit/custom/monthly` | F-37 |
| MG-161 | **F-38, nueva** — dos cuotas concurrentes de la misma unidad y un `quota` por nivel. El fichero aloja la mensual en el plan y la diaria en el endpoint de envío: cabe, y dice algo falso, porque coloca un tope de cuenta como si fuera del endpoint. | fricciones §F-38 | doc + panel | 🟡 | `plans.free.quota`, `plans.free.endpoints./v3/{domain_name}/messages.quota` | F-38 |
| MG-162 | Las cuatro nuevas cruzan por traza (**B9**) y **ninguna alcanza el umbral de recurrencia de D-008**, que pide dos APIs. Quedan anotadas para releerlas cuando el catálogo escale a diez o doce. | `fricciones.md` §Recuento | — | — | — | — |
| MG-163 | Cinco fricciones quedan **sin dato** por **G2** (celda en *(verificar)*, no en ❌): F-07, F-12, F-20, F-22 y F-28. | `fricciones.md` §Recuento | — | — | — | — |
| MG-164 | **O-01**, candidata a PR del repositorio: los dos topes del envío se serializan como **lista** de objetos —la forma del ejemplo canónico— y no como el objeto único que define el README. Sin la lista, F-06 no tendría dónde alojar ni dos de sus tres cotas. | fricciones §O-01 | — | — | `…/messages.workload` | O-01 |
| MG-165 | De esta API salen **seis reglas nuevas** de `CRITERIOS.md`, de los consejos MG-1 a MG-6 del 2026-09-21: **E12** (el periodo de un contador no es su unidad), **D14** (un lado disuelto por D12 devuelve el campo a D1), **E13** (rendir con navegador la página bloqueada cuando es la única fuente del dominio para una cifra), **B14** (el tope que levanta el titular no es `capacity`), **B11** (los tramos de un selector de volumen son F-02, no planes) y **B15** (la gobernanza entre productos hermanos no se presume). | `REVISION.md`; `fricciones.md` | — | — | — | — |
| MG-166 | El carril rojo de la API son tres decisiones del autor, las tres sin marcar: autorizar destinatarios del sandbox (R1), contratar un plan de pago (R2) y el alcance de Optimize e Inspect (R3). | REVISION §Carril rojo | — | — | — | — |

---

## Lo que sorprendería a un tribunal

1. **El proveedor publica 25 MB por mensaje en tres páginas y acepta 48** (MG-74 frente a
   MG-76, MG-77). El único tope que aplica el borde llega en 52,4 MiB y es de la petición
   entera. La distancia entre lo declarado y lo aplicado es de 23 MB, casi el doble del tope
   publicado: F-04 deja de ser interpretación y pasa a ser medida.
2. **La única cifra de caudal que publica el proveedor está en una página escrita para
   asistentes de IA y blindada contra las herramientas que un asistente usaría para leerla**
   (MG-50, MG-51). Cloudflare devuelve 403 a `curl` y a WebFetch; la cifra se obtuvo
   rindiendo la página con el navegador de la cuenta propia, que es el escalón 2 aplicado a
   una página pública. De ahí sale la regla E13.
3. **El caudal no se puede leer sin gastar un envío** (MG-63): las cabeceras
   `x-ratelimit-*` solo aparecen en un POST aceptado, y ni un GET ni un POST rechazado por
   permisos las traen. Observar el caudal y consumir la cuota no son separables en esta API.
4. **Una ventana que ninguno de los tres `window_type` de v0.3 describe** (MG-60, MG-61,
   MG-62): dura 9,85 s, no es rodante —el `reset` no se desplaza dentro de la ventana— y su
   origen lo fija la primera petición, no el calendario.
5. **El plan Free publica su volumen en dos periodos y en dos sitios, y nadie dice si son el
   mismo tope** (MG-33, MG-34): `"100 emails/day included"` en la página pública y `"3000
   emails per month"` en el panel, con el bullet de Basic —`"No daily email limit"`—
   empujando hacia la lectura de dos topes concurrentes.
6. **El sobrecoste declarado es 2,75 veces el que paga el cliente grande del mismo plan**
   (MG-102, MG-103): Scale baja de $1.10 por mil a $0.40 por mil al recorrer su propia
   escalera, y el fichero solo puede declarar el tramo mínimo.
7. **El contador del que depende la comparación de lotes es el que el esquema no admite**
   (MG-59, MG-159): la misma ventana devuelve 80.000 peticiones y 2.000.000 de
   destinatarios, y `max_power` solo aloja uno.

## Corrección del 2026-10-31 (verificador independiente)

El 31-10 un verificador reabrió cada URL del `datasheet.yaml`. El informe íntegro está en
`03_datos/apis/mailgun/evidencias/verificador_adversarial_2026-10-31.md`. Ningún valor cambia.

- **MG-92 sube a 🟢.** Las dos páginas de referencia que MG-132 daba por 404 responden hoy 200 con
  su operación. Verificación DNS: `"Verify the domains DNS records (includes A, CNAME, SPF, DKIM and
  MX records) to ensure the domain is ready and able to send"`. Edición de plantilla: `"Update the
  description of a template."`. Con eso el test C2 queda entero, y `type: api_first` pasa a 🟢 por
  D9. No hay captura de Wayback de esas páginas, así que no se sabe si el 404 de septiembre lo daba
  la web o la herramienta.
- **MG-132 deja de ser hueco** por lo mismo.
- **MG-48, cita corregida.** `"gradually increases sending rates"` no está en ninguna de las dos
  páginas. La frase que hay, `"For newly allocated IPs, Mailgun protects and improves the reputation
  by gradually increasing sending rates."`, habla de IP nuevas y no de cuentas nuevas. La entrada
  del YAML se queda con la cita de `faq/deliver-rep`.
- **MG-44 y MG-136, alcance del tope de plantillas** (consejo del 2026-10-31, 5 a 0). El endpoint
  modelado es el de plantillas de dominio. La frase que le da alcance es la segunda del párrafo:
  `"Domain-scoped templates have same limit set on a per sending domain basis."`. Las cuatro
  `description` dicen ahora «en cada dominio de envío». Las dos frases ya estaban en Wayback el
  2026-06-12.

Volcados: `03_datos/apis/mailgun/evidencias/paginas/2026-10-31/LEEME.md`.
