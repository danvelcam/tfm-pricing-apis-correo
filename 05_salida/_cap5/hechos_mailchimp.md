# Hechos — Mailchimp Transactional (Mandrill)

Extracción literal de `03_datos/apis/mailchimp/` (`datasheet.yaml`, `fuentes.md`,
`fricciones.md`, `REVISION.md`, `features.md`, `evidencias/*`). Fecha de extracción: 2026-09-21.

Convenciones:
- **fuente**: id `[Fn]`/`[En]` de `fuentes.md`, o nombre de fichero de `evidencias/`.
- **escalón**: doc (documentación pública) · panel (cuenta propia) · sondeo (petición real).
- **semáforo**: el que lleva el campo en `datasheet.yaml`; «—» si el hecho no está serializado
  (solo en `metadata.data_provenance`, `not_found` o en ninguna parte).
- **YAML**: ruta del campo donde vive el dato, cuando existe.
- Las cifras se citan tal como aparecen en la fuente, con su moneda, su periodo y su unidad.
  No se infiere, redondea ni completa nada. Un literal entre comillas es literal.
- Esta API se sirve en dos idiomas según geolocalización. Donde `fuentes.md` trae el literal
  en español y `evidencias/navegador_2026-09-21.md` el mismo dato en inglés, se citan **los
  dos** y se dice cuál es cuál: no es discrepancia (E9), es la misma página en dos idiomas.
- Lo medido va marcado como medido, con fecha y el literal de la respuesta. Lo inferido lleva
  la palabra inferido y el semáforo del campo. Donde el catálogo declara un hueco, el hecho
  **es** el hueco y la fuente es la línea de `not_found` o de «Fuentes buscadas y NO
  encontradas» que lo sostiene.

---

## 1. Planes y precios

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MC-01 | La moneda de la página de precios es USD: `"$20/bloque"`. | [F3] | doc | 🟢 | `currency` (USD) | — |
| MC-02 | El producto **no tiene planes con nombre**: la página de precios no publica filas ni tarjetas, solo una tabla de tramos de volumen del mismo producto, así que `plans` lleva una entrada única. La ausencia no tiene literal que citar. | [F3]; `data_provenance` (NOTA) | doc | — | `plans.transactional_email` (entrada única) | F-32, F-08 |
| MC-03 | Unidad de venta: `"Cada bloque es un crédito por 25,000 correos electrónicos"` (ES); `"Each block is a credit for 25,000 emails"` (EN). | [F3]; `navegador_2026-09-21.md` P2 | doc | 🟢 | `capacity.quota_email_block.value` (25000 emails / 1 MONTH) | F-32 |
| MC-04 | Tramo 1 de la escalera: `"1 to 20 blocks \| 1 to 500k emails \| $20/block"` (EN); `"1 - 20 bloques \| 1 - 500k emails \| $20/bloque"` (ES). | `navegador_2026-09-21.md` P2; [F3] | doc | 🟡 (solo el tramo de entrada está serializado) | `plans.transactional_email.price` (20.00, period 1 MONTH) | F-32 |
| MC-05 | Tramo 2: `"21 to 40 blocks \| 500k to 1M emails \| $18/block"`. | `navegador_2026-09-21.md` P2; [F3] | doc | — | — (solo `data_provenance`) | F-32 |
| MC-06 | Tramo 3: `"41 to 80 blocks \| 1M to 2M emails \| $16/block"`. | `navegador_2026-09-21.md` P2; [F3] | doc | — | — (solo `data_provenance`) | F-32 |
| MC-07 | Tramo 4: `"81 to 120 blocks \| 2M to 3M emails \| $14/block"`. | `navegador_2026-09-21.md` P2; [F3] | doc | — | — (solo `data_provenance`) | F-32 |
| MC-08 | Tramo 5: `"121 to 160 blocks \| 3M to 4M emails \| $12/block"`. | `navegador_2026-09-21.md` P2; [F3] | doc | — | — (solo `data_provenance`) | F-32 |
| MC-09 | Tramo 6: `"161+ blocks \| 4M+ emails \| $10/block"`. | `navegador_2026-09-21.md` P2; [F3] | doc | — | — (solo `data_provenance`) | F-32 |
| MC-10 | La cabecera de la tabla, tal como se sirve: `"TOTAL BLOCKS \| EMAILS PER MONTH \| PRICE PER BLOCK"` — el eje es el número de bloques comprados, no un plan. | `navegador_2026-09-21.md` P2 | doc | — | — | F-32 |
| MC-11 | `price: 20.00` va en ámbar por decisión declarada: «el literal es un precio por unidad prepagada y el campo es el precio del plan». | `data_provenance` (NOTA escalera) | doc | 🟡 | `plans.transactional_email.price` | F-32 |
| MC-12 | Por encima de 161 bloques no hay cifra publicada: `"Nuestros precios se adaptan a las necesidades de gran volumen con tarifas por bloque más bajas para volúmenes más altos. Contáctanos para obtener más información sobre nuestros precios para grandes volúmenes."` | [F3] | doc | — | — (solo `data_provenance`) | F-32 |
| MC-13 | Promoción temporal, no precio de lista: `"50% off the monthly base price of Transactional Email at 1,000,000 or more emails (40 or more blocks) for the first 12 (twelve) months of service, starting from the date of enrollment, followed by the then-current monthly list price based on your monthly Transactional Email subscription."` | `navegador_2026-09-21.md` P2; [F3] | doc | — | — (no entra en el precio del plan) | F-26 |
| MC-14 | Requisito de elegibilidad de la promoción, con geografía sin lista: `"…with an account created within the last 90 days in select countries, and sign up for the Mailchimp Transactional Email monthly plan and purchase a minimum of 1,000,000 emails (40 or more blocks)."` | `navegador_2026-09-21.md` P2 | doc | — | — | F-26 |
| MC-15 | `"Essentials plan is not eligible for Transactional Email."` (EN, literal del descargo); `"El plan Essentials no es elegible para el Correo Electrónico Transaccional."` (ES). | `navegador_2026-09-21.md` P2; [F3] | doc | — | — (solo `data_provenance`) | F-08 |
| MC-16 | El transaccional es complemento de una cuenta de pago, no producto suelto: `"¿Necesito una cuenta de Mailchimp para enviar correos electrónicos transaccionales? Sí, necesitas una cuenta de Mailchimp. El correo electrónico transaccional está disponible como complemento de los planes Standard y Premium de Mailchimp, o del plan mensual heredado."` El coste de esa cuenta base no es capacidad y no se modela. | [F3] | doc | — | — (solo `data_provenance`) | F-08, F-10 |
| MC-17 | Add-on de IP dedicada: `"Agrega una IP exclusiva por $29.95 al mes (opcional)"`, sin requisito de volumen mínimo publicado. | [F3] | doc | — | — (solo `data_provenance`) | F-07 |
| MC-18 | Franquicia gratuita en la propia página de precios: `"New transactional email users can get up to 500 free email sends to their verified domain. Restrictions apply."` (EN); `"Los nuevos usuarios transaccionales de correo electrónico pueden recibir hasta 500 correos electrónicos gratuitos a su dominio verificado. Aplican restricciones."` (ES). Mismo valor, dos idiomas. | `navegador_2026-09-21.md` P2; [F3] | doc | 🟢 | `capacity.quota_email_demo.value` (500) | F-33 |
| MC-19 | No hay tabla de precio anual: solo mensual por bloque. | [F3] (observación); `not_found` | doc | — | — | — |
| MC-20 | El SMS transaccional queda fuera por A1: `"Los SMS transaccionales están disponibles como complemento de uno de los planes de pago de Mailchimp."` | [F3] | doc | — | — | F-10 |
| MC-21 | Definición del producto en la pantalla de acceso del panel: `"Mandrill is a paid Mailchimp add-on that allows you to send one-to-one transactional messages triggered by user actions, like requesting a password or placing an order."` | [F18] (`panel_mandrill_2026-09-21.md` P1) | panel | — | — | F-10 |
| MC-22 | Panel, plan de la cuenta propia: `"You're currently on our free trial plan that includes 500 total sends and 30 days of technical support. Upgrade through your Mailchimp account to send more than 500 emails, or to get access to paid features and extended technical support."` | [F21] (`navegador_2026-09-21.md` P4) | panel | — | — | F-18 |
| MC-23 | `type: api_first`, con el test C2/D9 entero: las tres operaciones eliminatorias están publicadas en la referencia de API del dominio propio del proveedor — `"Send new message — POST /messages/send"`, `"Add template — POST /templates/add — Add a new template."`, `"Add sender domain — POST /senders/add-domain"` y `"Verify domain — POST /senders/verify-domain"`. | [F19] | doc | 🟢 (cobertura, D9/D16) | `type` | — |
| MC-24 | El panel confirma que crear plantilla no es exclusiva de la web: `"You can add a template below, use Mandrill's API or from your attached Mailchimp account."` | [F20] (`navegador_2026-09-21.md` P5) | panel | 🟢 (cobertura) | `type` | — |
| MC-169 | El servicio se identifica como `mailchimp-transactional` y la URL de referencia del fichero es la página de precios, `https://mailchimp.com/pricing/transactional-email/`. | `datasheet.yaml` | doc | 🟢 | `associated_saas`, `url` | — |
| MC-170 | Las unidades de consumo declaradas son `emails`, `requests` y `MBs`. | `datasheet.yaml` | doc | 🟢 | `consumption_units` | — |
| MC-171 | El fichero registra **17 URL** consultadas en `sources_visited`, que es la lista de lo leído y no la de lo citado: las citas viven en `fuentes.md` con su literal. | `datasheet.yaml` | doc | — | `metadata.sources_visited` | — |

## 2. Cuotas y ventanas

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MC-25 | La cuota de la cuenta de pago es el bloque: 25.000 emails por 1 MONTH. | [F3] | doc | 🟢 (valor) | `capacity.quota_email_block.value` (25000 emails / 1 MONTH) | F-32 |
| MC-26 | La ventana del bloque es **inferida**: lo único que dice la fuente es que el saldo no se arrastra — `"Los correos electrónicos no utilizados de un bloque no se transfieren de un mes a otro"`. Ninguna fuente declara el día de reinicio. | [F3]; `data_provenance`; `not_found` #3 | doc | 🟡 | `capacity.quota_email_block.window_type` (fixed_billing_cycle) | — |
| MC-27 | Agotar el bloque es un muro, no un sobrecoste: `"Los envíos transaccionales se calculan en tiempo real, así que el sistema dejará de enviar correos electrónicos cuando se te acaben los bloques."` | [F3] | doc | — | — (solo `data_provenance`) | F-24, F-32 |
| MC-28 | Auto-compra opcional, con tope puesto por el cliente: `"Configura tu cuenta para que compre automáticamente bloques de correo electrónico al llegar a tu límite predefinido."` | [F3] | doc | — | — (solo `data_provenance`) | F-16 |
| MC-29 | La cuenta de prueba trae 500 correos de franquicia: `"You can send up to 500 transactional emails to any email address on your verified domain"`. | [F15] (`navegador_2026-09-21.md` P3) | doc | 🟢 | `capacity.quota_email_demo.value` (500 emails) | F-33 |
| MC-30 | Esa franquicia **no tiene ventana**: `"The emails included with the demo do not expire or renew."` El YAML deja `period` y `window_type` vacíos, con el comentario `"🔴 franquicia sin ventana declarada: el proveedor dice que no caduca ni se renueva, y v0.3 no tiene forma para eso (ver metadata.not_found)"`. | [F15]; `datasheet.yaml` (comentario) | doc | 🔴 | `capacity.quota_email_demo.period` y `.window_type` (vacíos) | F-33 |
| MC-31 | El fin de la demo lo dispara el consumo, no una fecha: `"You immediately lose access to the demo if: … You send 500 emails."` | `navegador_2026-09-21.md` P3 | doc | 🔴 (sostiene la ausencia de ventana) | `capacity.quota_email_demo` | F-33 |
| MC-32 | La franquicia se da una sola vez por cuenta: `"Each eligible Mailchimp account may only enroll in the demo once."` | `navegador_2026-09-21.md` P3 | doc | — | — | F-33 |
| MC-33 | El panel escribe la franquicia como contador: `"Free trial sends"` → `"0 of 500"`. | [F18] (`panel_mandrill_2026-09-21.md` P2) | panel | 🟢 | `capacity.quota_email_demo.value` | F-33 |
| MC-34 | Requisito de la demo: `"Have an active Mailchimp account in good standing. The account can be free or paid, but cannot be paused or have a billing or compliance hold."` y `"Be a new user of Mailchimp Transactional. If you've previously purchased transactional email blocks, or purchased a Mailchimp Transactional plan, you are not eligible."` | `navegador_2026-09-21.md` P3 | doc | — | — | F-18 |
| MC-35 | Tope de entrada de correo en la demo: `"receive up to 100 inbound emails per day"`. Ningún endpoint de la API puede referenciarlo, porque recibir un correo no es una llamada, así que queda fuera de `capacity`. | [F15]; `not_found` #11 | doc | — | — (solo `data_provenance` y `not_found`) | F-12 |
| MC-36 | Tope del modo de pruebas: `"Note that you're limited to 10,000 test mode messages per day. This limit resets at midnight, or if they hit the limit, 24 hours after that limit is hit."` No se modela mientras viva DISC-02. | [F5] | doc | — | — (solo `data_provenance`) | F-17 |
| MC-37 | Retención de la cuenta demo: `"Your transactional email history is stored for only 30 days. After that, you will not be able to see the contents of the transactional emails or to whom the emails were sent."` Es límite de recurso (B3/B4), no cuota. | [F15]; `navegador_2026-09-21.md` P3 | doc | — | — (solo `data_provenance`) | F-11 |
| MC-38 | Seguimiento de clics no disponible en la demo: `"Click tracking is not enabled for demo accounts."` | `navegador_2026-09-21.md` P3 | doc | — | — | F-18 |
| MC-39 | Panel, dato nuevo y sin conciliar: `"Last reset on September 16, 2026"`, sobre el bloque de contadores, sin decir qué se reinició ni cada cuánto. **No se adopta como ancla de ninguna ventana** (D8). | [F21] (`navegador_2026-09-21.md` P4) | panel | — | — | — |
| MC-40 | La cuenta propia se creó el `"2026-09-16 10:16:34.82112"` (campo `created_at` de la API), la misma fecha que el `"Last reset"` del panel. | `api_users_info_2026-09-21.json` / [E1] | sondeo | — | — | — |
| MC-41 | Cuotas de recurso (campañas, contactos, listas): **no existen** en esta API; el panel solo expone columnas `"Expires"` y `"Remaining"` de la clave de API, las dos vacías en esta cuenta. | [F18] | panel | — | — (solo `data_provenance`) | F-11 |

## 3. Rates (caudales)

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MC-42 | Cuota horaria de la cuenta demo: `"Demo accounts are limited to a fixed hourly quota of 25 emails. Once you upgrade to a paid account, you'll be switched to the standard reputation and quota system."` | [F6] | doc | 🟢 | `max_power.rate_email_hourly_demo` (25 emails / 1 HOUR) | F-18 |
| MC-43 | Segunda superficie con el mismo número: `"You can send up to 25 emails in an hour"`. | [F15] | doc | 🟢 | ídem | F-18 |
| MC-44 | Tercera superficie, el panel: `"Hourly sends"` → `"Email sends this hour"` → `"0 of 25"`. | [F18] (`panel_mandrill_2026-09-21.md` P2) | panel | 🟢 | ídem | F-18 |
| MC-45 | Cuarta superficie, **medida** el 2026-09-21 contra la API: `"hourly_quota":25` en la respuesta de `POST /users/info`. Tres superficies y una medición dan el mismo número: no hay discrepancia. | `api_users_info_2026-09-21.json` / [E1] | sondeo | 🟢 | ídem | F-18 |
| MC-46 | El tope horario se modela como **caudal y no como cuota** porque contiene la velocidad sin rechazar: lo que lo excede se encola. | `data_provenance` (NOTA) | doc | 🟢 | `max_power.rate_email_hourly_demo` | F-01 |
| MC-47 | Mecanismo del tope horario: `"The number of messages you can send in a given time is determined by your pricing plan as well as your hourly quota, which is based on your sending reputation. If you exceed your quota, unsent messages will be placed in the backlog."` | [F4] | doc | — | — (solo `data_provenance`) | F-01, F-24 |
| MC-48 | Agotamiento y reproceso: `"Hourly quota exhausted - You've sent all the emails your hourly quota allows. We'll begin processing the backlog in the next hour."` La cola **sí** se procesa: no hay descarte. | [F4] | doc | — | — (solo `data_provenance`) | F-24 |
| MC-49 | Para cuentas de pago **no hay cifra**: `"an account that sends 1 million messages per week and an account that sends 100 messages per week could both have excellent reputations, but their hourly quotas will be very different."` | [F6]; `not_found` #1 | doc | — | `metadata.not_found` | F-01, F-18 |
| MC-50 | Reserva de prioridad del proveedor: `"If you have a campaign or a large batch of emails queued in the backlog, Mailchimp Transactional reserves an extra 5% of your hourly quota so more critical emails, such as password resets or order confirmations, can send without delay. To flag important messages and give them priority in the queue, use the `important` parameter in your API call."` | [F4] | doc | — | — (solo `data_provenance`) | — |
| MC-51 | El mismo 5 % desde otra URL, como corroboración y no como discrepancia: `"Mailchimp Transactional reserves an extra 5% of your hourly quota so more critical emails, such as password resets or order confirmations, can send without delay."` | [F14] | doc | — | — (solo `data_provenance`) | — |
| MC-52 | La reputación baja el caudal: `"At certain spam complaint thresholds, ISPs may begin routing all your email to spam folders, bar you as a sender, or even block Mailchimp Transactional's sending IPs overall—and Mailchimp Transactional will lower your hourly quota as a result."` | [F6] | doc | — | — | F-18 |
| MC-53 | El panel publica el mecanismo: `"All new accounts have an \"Unknown\" reputation since we haven't seen the results of anything you've sent… your account will have a reputation (Excellent, Good or Poor) that is used, in part, to determine your hourly quota."` | [F18] | panel | — | — (solo `data_provenance`) | F-18 |
| MC-54 | El estado de reputación de la cuenta propia, en dos codificaciones: `"Reputation"` → `"Unknown"` (panel) y `"reputation":0` (API, medido el 2026-09-21). No son dos valores distintos. | [F18]; `api_users_info_2026-09-21.json` / [E1] | panel + sondeo | — | — (solo `data_provenance`) | F-18 |
| MC-55 | Único caudal con cifra de toda la API, y es de un endpoint: `"If you exceed the limit of 20 searches per minute, we'll now return a 429 Too Many Requests response code. You can retry your request 60 seconds after you sent the first of the original 20 requests."` | [F7] | doc | 🟢 | `max_power.rate_request_search` (20 requests / 1 MIN) | F-01 |
| MC-56 | El propio endpoint publica el mismo caudal: `"This method may be called up to 20 times per minute."` Doble confirmación, no discrepancia. | [F10]; [F19] | doc | 🟢 | ídem | — |
| MC-57 | El alias de estado `demo` se repite en los tres endpoints de envío porque **el tope es de la cuenta y no del endpoint**, y v0.3 solo admite alias dentro de un endpoint. | `data_provenance` (NOTA) | doc | — | `plans.transactional_email.endpoints./messages/{send,send-template,send-raw}.demo` | F-18 |
| MC-58 | La tabla oficial de errores no incluye **ni 429 ni 403**: solo `"401 Invalid API Key"`, `"401 IP does not have permission to use this key"`, `"401 This key does not have permission to call method name"`, `"404 No Such Template"`, `"404 Invalid Message ID"`, `"404 No message exists with the id"`, `"404 No subaccount exists with the id"` y `"405 Method not allowed"`. | [F5] | doc | — | — (solo `data_provenance`) | F-01 |
| MC-59 | Ninguna cabecera de rate limit (`X-RateLimit-*`, `Retry-After` o nombre propio) aparece en ninguna página oficial revisada, ni en las respuestas del sondeo. | `not_found` #6; REVISION.md | doc + sondeo | — | `metadata.not_found` | F-01 |

## 4. Workload — destinatarios y topes por petición

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MC-60 | El proveedor dice en la misma frase que no hay tope de destinatarios y que la cota está en otra métrica: `"Via the API, there's no recipient limitation, but the JSON provided per API call must be less than 10MB. We strongly recommend smaller recipient batches for easier troubleshooting."` | [F4] | doc | 🔴 | `plans.transactional_email.endpoints./messages/send.workload[0].max` (vacío) | F-06 |
| MC-61 | Tope de tamaño de la llamada: `"the JSON provided per API call must be less than 10MB"`. | [F4] | doc | 🟢 | `…/messages/send.workload[1].max` (10 MBs) | F-34, F-04 |
| MC-62 | Tope de tamaño del mensaje entregado, **otra magnitud**: `"Mailchimp Transactional allows attachments, but the total message size cannot exceed 25MB. There is no specific limit for individual attachments, just the total size of the message."` Solo el tope de llamada entra en el esquema. | [F4] | doc | — | — (solo `data_provenance` y `not_found`) | F-34 |
| MC-63 | Los dos topes conviven en la misma página y son conjuntamente inalcanzables: un mensaje de 25 MB en base64 no cabe en una llamada de menos de 10 MB. No son excluyentes, así que no abren DISC (D11). | [F4] (observación crítica); `fricciones.md` F-34 | doc | — | — | F-34 |
| MC-64 | Vía SMTP el tope **sí** es un entero y difiere del de la API: `"Via SMTP, you can send to up to 1,000 recipients at a time. If you're sending messages to more recipients, simultaneous and subsequent connections are permitted."` SMTP no es endpoint de la API y no se modela. | [F4] | doc | — | — (solo `data_provenance`) | F-15 |
| MC-65 | **No existe endpoint de envío por lotes**, y la ausencia no tiene literal que citar: el envío múltiple ocurre dentro de una sola llamada a `/messages/send` mediante el array `to`. | [F8] (observación); `data_provenance` (NOTA) | doc | — | — (solo `data_provenance`) | F-03 |
| MC-66 | Encolado asíncrono, sin umbral en la frase: `"We queue these messages to process asynchronously, and will send them as soon as possible, usually within seconds."` | [F4] | doc | — | — | O-22 |
| MC-67 | `/messages/send-template` no publica tope propio: la página del endpoint dice solo `"Send a new transactional message through the Transactional API using a template."` | [F9] | doc | 🔴 | `…/messages/send-template.workload[0].max` (vacío) | F-06 |
| MC-68 | `/messages/send-raw` es el envío de un documento MIME crudo: `"Take a raw MIME document for a message, and send it exactly as if sent through SMTP servers."` | [F8] | doc | 🔴 | `…/messages/send-raw.workload[0].max` (vacío) | F-06 |
| MC-69 | RPR de rechazos: `"Retrieves your email rejection denylist. You can provide an email address to limit the results. Returns up to 1000 results."` Tope de paginación, no de consumo (B3). | [F11] | doc | — | `…/rejects/list.workload` (requests 1..1; los 1.000 solo en `description`) | F-05 |
| MC-70 | RPR de búsqueda, por profundidad temporal: `"If no date range is specified, results within the last 7 days are returned."` | [F10]; [F19] | doc | — | `…/messages/search.workload` (requests 1..1; los 7 días solo en `description`) | F-05 |
| MC-71 | Requisito que condiciona todo envío, y no es cuota: `"Mailchimp Transactional won't send any email from unverified domains or domains without a valid DMARC policy and DKIM records."` y `"You'll need to add DMARC and a DKIM record, and verify ownership of your sending domains before you can send email through your account."` | [F16] | doc | — | — (solo `data_provenance`) | — |
| MC-72 | La lista de IP autorizadas decide si la llamada entra, y está en la tabla oficial de errores: `"401 IP does not have permission to use this key \| API keys can be limited by IP address, and the IP address does not have permission \| Go to the Settings page in Transactional and edit the key to allow the IP address to make requests"`. | [F5] | doc | — | — | F-28 |

## 5. Endpoints modelados

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MC-73 | `POST /messages/send` — `"Send a new transactional message through the Transactional API."` Lleva alias `demo` (rate horario + franquicia) y dos cargas: emails sin tope y 10 MBs. | [F8]; [F19] | doc | 🔴 (emails) / 🟢 (MBs) | `plans.transactional_email.endpoints./messages/send` | F-06 |
| MC-74 | `POST /messages/send-template` — modelado con el mismo alias `demo` y las mismas dos cargas. La descripción del YAML dice «la página del endpoint no publica ningún tope propio de destinatarios». | `datasheet.yaml`; [F9] | doc | 🔴 / 🟢 | `…/messages/send-template` | F-06 |
| MC-75 | `POST /messages/send-raw` — mismo alias y mismas cargas; la descripción del YAML dice «Envío de un documento MIME crudo, tal cual saldría por SMTP». | `datasheet.yaml`; [F8] | doc | 🔴 / 🟢 | `…/messages/send-raw` | F-06, F-15 |
| MC-76 | `POST /messages/search` — único endpoint del fichero con `rate` propio: `rate_request_search`, 20 requests / 1 MIN. | [F7]; [F10] | doc | 🟢 | `…/messages/search.rate` | F-01 |
| MC-77 | `POST /messages/search-time-series` — `"Search the content of recently sent messages and return the aggregated hourly stats for matching messages."` Sin rate propio en el fichero. | [F8] | doc | — | `…/messages/search-time-series` | — |
| MC-78 | `POST /messages/info` — `"Get the information for a single recently sent message."` | [F8] | doc | — | `…/messages/info` | — |
| MC-79 | `POST /messages/content` — `"Get the full content of a recently sent message."` | [F8] | doc | — | `…/messages/content` | — |
| MC-80 | `POST /rejects/list` — modelado con carga de 1 petición; el tope de 1.000 resultados vive en la descripción. | [F11] | doc | — | `…/rejects/list` | F-05 |
| MC-81 | `POST /users/info` — la descripción del YAML dice que «devuelve la cuota horaria vigente, la reputación y el tamaño de la cola»; es el canal de introspección del caudal. | `datasheet.yaml`; [E1] | doc + sondeo | — | `…/users/info` | F-01 |
| MC-82 | Endpoints que existen y **no se modelan** (dominio funcional, no capacidad): `"/webhooks/add": "Add a new webhook"`, `"/inbound/add-domain": "Add inbound domain"`, `"/rejects/add"`, `"/exports/activity"`, `/templates/{add,info,update,publish,delete,list,time-series,render}`, `/senders/{add-domain,verify-domain}`. | [F2]; [F19] | doc | — | — | — |
| MC-83 | Punto de entrada de la API, que no es campo de v0.3: `"servers": [{"url": "https://mandrillapp.com/api/1.4", "description": "Mailchimp Transactional API v1.4"}]`. El sondeo, sin embargo, se ejecutó contra `https://mandrillapp.com/api/1.0/users/info`. | [F2]; [E1] | doc + sondeo | — | — (solo `data_provenance`) | — |

## 6. Sobrecoste

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MC-84 | **No hay sobrecoste por unidad excedida.** El modelo es prepago por bloques y agotar el bloque detiene el envío; no hay tarifa de exceso (B6). | [F3]; `data_provenance` | doc | — | `capacity.quota_email_block` no lleva `overage_cost` | F-02 (no recurre), F-32 |
| MC-85 | Lo que ocupa el lugar del sobrecoste es comprar otro bloque del mismo producto, al precio degresivo de la escalera (MC-04…MC-09). | [F3]; `fricciones.md` F-32 | doc | 🟡 | `plans.transactional_email.price` | F-32 |
| MC-86 | El único tope de gasto publicado lo pone el cliente, no el proveedor: `"…compre automáticamente bloques de correo electrónico al llegar a tu límite predefinido."` | [F3] | doc | — | — | F-16 |
| MC-87 | No consta si el precio del tramo alcanzado es **marginal** (por tramo) o **plano** sobre todos los bloques del mes: no aclarado en ninguna página ni pregunta frecuente revisada. | `not_found` #12; «Fuentes buscadas y NO encontradas» | doc | — | `metadata.not_found` | F-30, F-32 |
| MC-88 | Consecuencia declarada del modelado actual: el coste que PRIME4API calcula para un millón de correos sale de `$20`/bloque cuando el proveedor cobra `$18`; el error crece con el volumen y **encarece al proveedor barato**. | `fricciones.md` F-32 | doc | 🟡 | `plans.transactional_email.price` | F-32 |

## 7. Vigencia

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MC-89 | La Datasheet lleva `date: 2026-09-21` y `syntax_version: 0.3`. | `datasheet.yaml` | — | — | `date`, `syntax_version` | — |
| MC-90 | Recolección: 2026-09-21, siete lentes documentales, más escalón 2 (panel con cuenta propia) y escalón 3 el mismo día. Todas las [F1]–[F21] llevan fecha de acceso 2026-09-21. | `fuentes.md` (cabecera) | doc | — | — | — |
| MC-91 | Segunda pasada el mismo día con navegador renderizado: cinco transcripciones (P1–P5); P2 y P3 se incorporan a [F3] y [F15], y P1, P4 y P5 abren [F19], [F21] y [F20]. | `fuentes.md`; `navegador_2026-09-21.md` | doc + panel | — | — | — |
| MC-92 | Las dos citas de [F17] (índice de release notes) se agregaron **por resumen de herramienta** y quedan en ámbar hasta releer cada nota por separado: `"Starting March 15, 2024, senders must implement DKIM records and DMARC policies. Non-compliant domains will use mandrillapp.com subdomains as sending addresses."` y `"Mailchimp Transactional status added to server status page"`. Ninguna cambia una cifra. | [F17]; REVISION.md | doc | — | — | F-09 |
| MC-93 | No hay changelog propio del producto: se filtra el índice general [F17], `https://mailchimp.com/help/about-mandrill/` devuelve HTTP 404 y el producto se cita con dos nombres vivos, Mandrill y Mailchimp Transactional. | [F17]; «Fuentes buscadas y NO encontradas»; `fricciones.md` F-09 | doc | — | — | F-09 |
| MC-94 | La cita de [F14] llegó por resumen de herramienta y no por transcripción directa; el literal de [F4] es el de mayor confianza para el mismo mecanismo. | [F14] (observación) | doc | — | — | — |

## 8. Lo que el proveedor no publica

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MC-95 | Cifra de la cuota horaria para cuentas de **pago**: no publicada en ninguna página oficial. Solo se documenta el mecanismo —reputación más volumen histórico— y la cifra fija de la cuenta de prueba, 25 a la hora. | `not_found` #1; [F4], [F6] | doc | — | `metadata.not_found[0]` | F-01, F-18 |
| MC-96 | Desglose de la cuota horaria **por plan** (Standard vs Premium): no encontrado; ninguna tabla por plan en precios, fundamentals, reputation-rejections ni en el panel. | «Fuentes buscadas y NO encontradas» | doc | — | — | F-08 |
| MC-97 | Ancla de reinicio de la cuota horaria de producción: no declarada. Solo consta que el backlog se reprocesa en la hora siguiente, sin decir si la ventana es deslizante o fija. | `not_found` #2 | doc | — | `metadata.not_found[1]` | F-01 |
| MC-98 | Día de reinicio del bloque de 25.000 correos: no publicado. Que el saldo no se arrastre de un mes a otro es lo único que se dice, y de ahí sale el ciclo de facturación en ámbar. | `not_found` #3 | doc | 🟡 | `capacity.quota_email_block.window_type` | — |
| MC-99 | Rate de peticiones de la API REST general (req/s o req/min): no publicado. El único endpoint con rate propio es la búsqueda de mensajes, 20 por minuto. | `not_found` #4 | doc | — | `metadata.not_found[3]` | F-01 |
| MC-100 | Límite de concurrencia de la API REST: no publicado — ninguna cifra en `fundamentals/` ni en `outbound-email/`. | `not_found` #5 | doc | — | `metadata.not_found[4]` | F-01 |
| MC-101 | Códigos 429 y 403 en la tabla oficial de errores: ausentes los dos. El exceso de envío se modela como cola y no como rechazo HTTP. | `not_found` #7; [F5] | doc | — | `metadata.not_found[6]` | F-01 |
| MC-102 | Tope de destinatarios por llamada a `/messages/send`: no publicado **y no medible por rechazo**. 5.000 destinatarios se aceptaron en una sola llamada el 2026-09-21, sin cota superior alcanzada. | `not_found` #8; sondeo A M5 | doc + sondeo | 🔴 | `metadata.not_found[7]`, `…/messages/send.workload[0].max` | F-06 |
| MC-103 | Tamaño máximo de mensaje comprobado por rechazo: no medible en esta API. Cualquier adjunto difiere la evaluación, y hasta 30 MB de adjunto la respuesta no devuelve ningún umbral; el literal de 25 MB por mensaje queda sin confirmar contra la API. | `not_found` #9; sondeo A M4 | doc + sondeo | — | `metadata.not_found[8]` | F-34, F-04 |
| MC-104 | Forma de esquema para una franquicia que no caduca ni se renueva: v0.3 exige periodo en toda cuota y los 500 correos de la cuenta de prueba no tienen ninguno. | `not_found` #10 | doc | 🔴 | `metadata.not_found[9]` | F-33 |
| MC-105 | Enlace de la cuota de 100 correos entrantes al día: ningún endpoint la puede referenciar, porque recibir un correo no es una llamada a la API. | `not_found` #11 | doc | — | `metadata.not_found[10]` | F-12 |
| MC-106 | Si el precio del tramo alcanzado es marginal o plano: no aclarado. | `not_found` #12 | doc | — | `metadata.not_found[11]` | F-30 |
| MC-107 | Precio por bloque por encima de 161 bloques (más de 4 millones de correos al mes): no publicado, la página remite a contacto comercial. | `not_found` #13 | doc | — | `metadata.not_found[12]` | F-32 |
| MC-108 | Tabla de precio anual del transaccional: no existe, solo precio mensual por bloque. | `not_found` #14 | doc | — | `metadata.not_found[13]` | — |
| MC-109 | Países elegibles para el descuento del 50 %: no enumerados — la página dice `"in select countries"` sin lista ni enlace. | `not_found` #15; `navegador_2026-09-21.md` P2 | doc | — | `metadata.not_found[14]` | F-26 |
| MC-110 | Consumo compuesto por destinatario —si N destinatarios en `to` gastan N unidades del bloque o una por llamada—: **no verificable**. El artículo del proveedor que lo trataría (`mandrill.zendesk.com/hc/en-us/articles/360038783814-How-Transactional-Email-Billing-Works`) devolvió **HTTP 403 Forbidden** en esta pasada. | `not_found` #16; «Fuentes buscadas y NO encontradas» | doc | — | `metadata.not_found[15]` | F-03 |
| MC-111 | Umbral oficial de destinatarios que fuerza el envío asíncrono: sin cita oficial. El «10» circula en fuentes de terceros sin respaldo oficial; medido el 2026-09-21 entre 10 y 11. | `not_found` #17; sondeo A M3 | doc + sondeo | — | `metadata.not_found[16]` | O-22 |
| MC-112 | Especificación OpenAPI servida **desde el dominio del producto**: no localizada, y la referencia oficial de la API tampoco la enlaza ni la menciona. El fichero de GitHub de la organización `mailchimp` sí puede citarse como oficial (D15); lo que no consta es que el proveedor la sirva desde su propio dominio. | `not_found` #18; [F19]; DISC-01 | doc | — | `metadata.not_found[17]` | — |
| MC-113 | Días de retención de actividad y logs para una cuenta de **pago**: ninguna fuente revisada publica un número. La cuenta demo sí publica una cifra, treinta días, que no se traslada sin más. | `not_found` #19 | doc | — | `metadata.not_found[18]` | F-11 |
| MC-114 | Tope de número de dominios de envío, de webhooks y de usuarios: no publicados. Es la primera API del catálogo donde **ningún** tope de recursos está publicado. | `not_found` #20; `fricciones.md` F-11 | doc | — | `metadata.not_found[19]` | F-11 |
| MC-115 | Periodo de calentamiento obligatorio para cuentas nuevas con topes progresivos: no encontrado. Solo hay calentamiento opcional de IP dedicada. | `not_found` #21 | doc | — | `metadata.not_found[20]` | — |
| MC-116 | Umbral numérico de suspensión automática por volumen: no publicado. Solo consta la condición de uso indebido, que es política: `"Enviar correos electrónicos masivos, es decir, correos electrónicos dirigidos a varias personas con el mismo contenido, a través de Transactional (antes conocido como Mandrill)"` [F12], con la consecuencia `"If you use Transactional Email to send bulk emails disregarding our Acceptable Use Policy, we may charge you at the equivalent Paid Marketing Plan rate or cancel your account"` [F13]. | `not_found` #22; [F12]; [F13] | doc | — | `metadata.not_found[21]` | F-10 |
| MC-117 | Límite o registros propios de `/messages/send-template` distintos del general: no encontrados. | «Fuentes buscadas y NO encontradas» | doc | 🔴 | `…/messages/send-template.workload[0].max` | F-06 |
| MC-118 | Página dedicada de referencia de errores distinta de `fundamentals/`: no existe — todo el catálogo de errores vive en esa única página. | «Fuentes buscadas y NO encontradas» | doc | — | — | — |
| MC-119 | Nombre exacto de cabecera/parámetro de autenticación: no detallado en el cuerpo volcado de la referencia de API; tampoco se revisó el bloque `securitySchemes` del OpenAPI en esta pasada. | «Fuentes buscadas y NO encontradas» | doc | — | — | — |
| MC-120 | Comportamiento del selector/input de la calculadora de precio: no probado de forma interactiva; esta pasada solo leyó el HTML estático servido (`data-behavior="transactionalPricingCalculator:rows"`), que ya trae la tabla completa. | [F3]; «Fuentes buscadas y NO encontradas» | doc | — | — | F-32 |
| MC-121 | Matriz de features **por plan/volumen**: no existe, porque no existen planes con nombre; el volumen solo mueve el precio, nunca qué endpoints o features están disponibles. | «Fuentes buscadas y NO encontradas»; `features.md` | doc | — | — | F-08 |

## 9. Lo medido en el escalón 3

Todo lo de esta sección se midió el **2026-09-21** con la clave de la cuenta de prueba, con
destinatarios en `*@example.invalid` (RFC 2606) y remitente `sondeo@example.invalid`, sobre una
cuenta **sin dominio de envío verificado**.

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MC-122 | [E1], coste 0, endpoints de lectura: `POST /users/info` → HTTP 200 con `{"username":"31644777","created_at":"2026-09-16 10:16:34.82112","public_id":"W-1vniwilLzrhCW3f3KPgA","reputation":0,"hourly_quota":25,"backlog":0, …}`; `users/ping2` → `{"PING":"PONG!"}`. | `api_users_info_2026-09-21.json`, `api_users_ping2_2026-09-21.json` / [E1] | sondeo | 🟢 (confirma el 25/hora) | `max_power.rate_email_hourly_demo` | F-01 |
| MC-123 | Los contadores de la misma respuesta dan `"sent":0,"hard_bounces":0,"soft_bounces":0,"rejects":0,"complaints":0` en `today`, `last_7_days`, `last_30_days`, `last_60_days`, `last_90_days` y `all_time`. | `api_users_info_2026-09-21.json` | sondeo | — | — | F-21 |
| MC-124 | Sondeo A, M2 — un destinatario en `/messages/send`: `[{"email":"sondeo@example.invalid","status":"rejected","_id":"89359bcfb1814c4ba98d807037f3c73a","reject_reason":"unsigned","queued_reason":null}]`. Mandrill evalúa en la propia llamada y rechaza porque el remitente no pertenece a un dominio verificado. | `sondeo_a_preflight_2026-09-21.md` §M2; `.txt` §T1 | sondeo | — | — | O-22 |
| MC-125 | Sondeo A, M3 — barrido de destinatarios: 2, 3, 5, 9 y **10** devuelven `rejected` con `unsigned`; **11**, 20 y 100 devuelven `queued` con `multiple-recipients`. **El umbral está entre 10 y 11, exacto.** | `sondeo_a_preflight_2026-09-21.md` §M3 | sondeo | — | — (solo `data_provenance`) | O-22 |
| MC-126 | Lo que ese umbral significa: por encima de diez destinatarios la API responde `queued` y **no dice si enviará**. Es límite de observabilidad, no de capacidad: la vía de medir haciendo que el proveedor rechace —condición 3 de D-046— deja de existir. | `sondeo_a_preflight_2026-09-21.md` §M3; `fricciones.md` O-22 | sondeo | — | — | O-22 |
| MC-127 | Sondeo A, M4 — adjuntos, un destinatario: 5 MB (cuerpo 6 MB), 10 MB (13 MB), 20 MB (26 MB), 25 MB (33 MB), 26 MB (34 MB) y 30 MB (40 MB) devuelven **todos** HTTP 200 con `queued` y `queued_reason: "attachments"`. Ninguna respuesta devuelve umbral de tamaño. | `sondeo_a_preflight_2026-09-21.md` §M4 | sondeo | 🟢 (el literal de 10 MB **no** baja: D6) | `…/messages/send.workload[1].max` (10 MBs) | F-04, F-34 |
| MC-128 | El mismo sondeo metió ~40 MB de cuerpo JSON por llamada, cuatro veces por encima del `"less than 10MB"` que publica [F4], sin un solo rechazo por tamaño. Es la fricción de restricción declarada y no aplicada, **medida**. | `sondeo_a_preflight_2026-09-21.md` §M4; `fricciones.md` F-04 | sondeo | 🟢 | `…/messages/send.workload[1].max` | F-04 |
| MC-129 | Sondeo A, M5 — destinatarios por llamada: 500, 1.000, 1.001 y **5.000** devuelven HTTP 200 con `queued` ×N. La API no aplica ningún tope de destinatarios por petición en el borde síncrono. Mailgun, en el mismo catálogo, rechaza la 1.001 con `400 {"message":"Too many recipients, max is 1000"}`. | `sondeo_a_preflight_2026-09-21.md` §M5 | sondeo | 🔴 | `…/messages/send.workload[0].max` (vacío) | F-06 |
| MC-130 | Lo que costó el sondeo: entregas **0**, rebotes **0**, quejas **0** según los contadores del propio proveedor. Lo que sí se generó fue cola — a las 19:44 `backlog 4956`, `sent 0`, `rejects 206`, y al cerrar unos **~7.600 destinatarios encolados**. | `sondeo_a_preflight_2026-09-21.md` («Lo que costó») | sondeo | — | — | O-22 |
| MC-131 | La guarda del script paró en la primera tanda de 100 —`"!!! ABORTA: T2 con 100 destinatarios devolvio un destinatario en estado sent/queued/scheduled."`—; las tandas de M4 y M5 se lanzaron **después, a mano**, y ahí se acumuló la cola. Declarado fallo del sondeo, no resultado buscado. | `sondeo_a_preflight_2026-09-21.txt`; `.md` | sondeo | — | — | O-22 |
| MC-132 | **Medido dos horas después:** la cola no descontó nada — `"Free trial sends 0 of 500"`, `"Sends This Month 0"`, `"Email sends this hour 0 of 25"`. En Mandrill, encolar no consume. Cierra la celda *(verificar)* de F-21. | [F21] (`navegador_2026-09-21.md` P4) | panel | — | — | F-21 |
| MC-133 | La cola drena hacia **rechazos** y no hacia entregas, porque la cuenta no tiene dominio verificado: los encolados se resuelven en `reject` con razón `unsigned`. | `sondeo_a_preflight_2026-09-21.md` | sondeo | — | — | — |

## 10. Discrepancias entre fuentes

| id | fuentes enfrentadas | qué dice cada una | estado según los ficheros |
|---|---|---|---|
| DISC-01 (registrada) | [F2] vs hallazgo de otro frente del mismo día | A: `transactional.openapi.json` vive bajo la organización oficial de GitHub `mailchimp` y la referencia lo nombra como «v. 1.4.1». B: `"no se ha encontrado /openapi.json ni /swagger.json servido por mailchimp.com ni mandrillapp.com"`. | **DISUELTA el 2026-09-21** por D15 (oficial lo fija quién mantiene el artefacto, no el dominio que lo sirve) y porque, tras [F19], ninguna afirmación de la datasheet depende ya de [F2]. `type` sube a 🟢. La mitad que D15 no cierra —si el proveedor **sirve** la spec desde su dominio— va a `not_found` sin color. |
| DISC-02 (registrada) | [F5] vs **[F5]**, la misma frase | A: `"This limit resets at midnight"`. B: `"or if they hit the limit, 24 hours after that limit is hit"`. Quien agota los 10.000 a las 15:00 no sabe si el contador vuelve a cero nueve o veinticuatro horas después. | **Abierta.** El tipo de ventana del límite de modo de pruebas se queda en 🟡 por D3/D11. Vía de cierre escrita y **no ejecutada**: agotar el límite lejos de medianoche y esperar al reinicio (caro en tiempo). El límite no se modela mientras viva. |
| Sin id (declarada no-DISC) | [F4] vs [F4], la misma página | `"the JSON provided per API call must be less than 10MB"` frente a `"the total message size cannot exceed 25MB"`. | **No abre DISC (D11):** miden objetos distintos —la llamada y el mensaje entregado— y a la vez son conjuntamente inalcanzables. Se registra como fricción **F-34**; solo el tope de llamada entra en el esquema. |
| Sin id | [F4] vs sondeo A M4 | El literal publica `"less than 10MB"` por llamada; la medición del 2026-09-21 metió ~40 MB sin un solo rechazo por tamaño. | **Resuelta por regla, no por arbitraje:** el campo se queda en 🟢 porque un sondeo no baja un literal oficial (D6), y la medición se escribe contra el campo que toca. Es **F-04 medida**. |
| Sin id (no registrada) | `datasheet.yaml` vs [F8]/[F9] | El fichero modela `/messages/send-template`; el índice de endpoints [F8] publica `POST /messages/send-mc-template` y la URL de [F9] es `…/api/messages/send-using-message-template/`. Tres nombres para la misma operación, y el del YAML no es literal de ninguna de las dos páginas. | **Abierta, no comentada en ningún fichero.** Afecta a la clave de dos entradas de `endpoints` y a su trazabilidad. |
| Sin id (no registrada) | [F2] vs [F19] | Para el mismo `/templates/add`, el contrato de GitHub dice `"Creates a new email template with the specified content and settings."` y la referencia del dominio propio dice `"Add a new template."`; para `/senders/add-domain`, `"…but you can add them ahead of time"` frente a `"…but you can use this call to add them ahead of time"`. | **Textual.** No cambia el veredicto de `type` —las dos superficies publican la operación— pero las citas del `data_provenance` proceden de [F19], no de [F2]. |
| Sin id (no registrada) | `features.md` vs [F20] | La matriz dice, en la fila de plantillas, `"— (no observado en panel esta pasada)"`; la segunda pasada del mismo día sí observó la pantalla, `"You can add a template below, use Mandrill's API…"`. | **Abierta:** `features.md` quedó sin actualizar tras la segunda pasada de navegador. |
| Sin id (no registrada) | `sondeo_a_preflight_2026-09-21.txt` vs `.md` | El `.txt` registra el aborto de la guarda en T2 con 100 destinatarios; el `.md` documenta el barrido completo hasta 5.000 destinatarios y 30 MB de adjunto. | **Compatibles y así declarado:** las tandas posteriores se lanzaron a mano, fuera de la guarda, y está escrito como fallo del sondeo (MC-131). |
| Sin id (no registrada) | [F18]/`panel_mandrill_2026-09-21.md` P5 vs [F21]/`navegador_2026-09-21.md` P4 | La misma URL, `https://mandrillapp.com/`, transcrita dos veces el mismo día: la primera solo trae `"No Sending Domains"`, la segunda trae además los contadores y `"Last reset on September 16, 2026"`. | **Compatibles:** distinto momento y distinta profundidad de transcripción. La segunda es la que mide la celda de F-21. |
| Sin id | [F3] (ES) vs `navegador_2026-09-21.md` P2 (EN) | Mismo dato servido en dos idiomas por geolocalización: 500 correos de franquicia, escalera de seis tramos, plan Essentials no elegible. | **No es discrepancia (E9).** Se citan los dos literales y se dice cuál es cuál. |

## 11. Fricciones

Celda de Mailchimp en el recuento de `fricciones.md`, sobre **siete** APIs cerradas (Mailgun
aún no tiene `fricciones.md` y no lleva columna).

| id | hecho | fuente | escalón | semáforo | YAML | fricción |
|---|---|---|---|---|---|---|
| MC-134 | ✅ Rate que existe sin valor: la cuota horaria de la cuenta de pago existe y no tiene cifra, `"their hourly quotas will be very different"`; del resto de la API solo `/messages/search` publica caudal. | [F6]; `fricciones.md` | doc | — | — | F-01 |
| MC-135 | ❌ Volumen contratado con sobrecoste variable: hay escalera y **no** hay sobrecoste. Se le cae la misma mitad que a Brevo, y **B13** manda que este caso vaya a fricción propia. | [F3]; `fricciones.md` | doc | — | — | F-02 → F-32 |
| MC-136 | ❌ CRF multiplicativo: no hay endpoint de lote, así que solo hay un eje y está acotado por MB. | [F8]; `fricciones.md` | doc | — | — | F-03 |
| MC-137 | ✅ **medida** — Restricciones declaradas y no aplicadas: `"less than 10MB"` frente a 40 MB de cuerpo con HTTP 200 y ningún rechazo. | `sondeo_a_preflight_2026-09-21.md` §M4 | sondeo | — | — | F-04 |
| MC-138 | ✅ RPR no serializable: `"Returns up to 1000 results"` y `"results within the last 7 days are returned"`, tope por petición y ventana de profundidad, las dos fuera del esquema. Sube a 5/7. | [F10]; [F11] | doc | — | — | F-05 |
| MC-139 | ✅ **el caso más literal del catálogo** — Workload acotado por otra métrica: `"Via the API, there's no recipient limitation, but the JSON provided per API call must be less than 10MB"`. Llega a **7/7**. | [F4] | doc | 🔴 | `…/messages/send.workload[0].max` | F-06 |
| MC-140 | ✅ Add-ons que modifican capacidad: IP dedicada `"$29.95 al mes (opcional)"` y créditos de SMS como línea aparte del panel. Llega a **7/7**. | [F3]; [F18] | doc + panel | — | — | F-07 |
| MC-141 | ⚠️ Variante que falla V1 — El plan es un producto cartesiano: hay segundo eje (cuenta Standard/Premium/heredada, `"El plan Essentials no es elegible"`) pero ninguna fuente ata un endpoint, una cuota ni un caudal a ese eje. | [F3] | doc | — | — | F-08 |
| MC-142 | ✅ La datasheet no dice qué parte sigue vigente: sin changelog propio, `/help/about-mandrill/` en 404 y dos nombres vivos del producto. | [F17] | doc | 🟡 | — | F-09 |
| MC-143 | ✅ Dos productos, dos unidades de consumo: `"Free trial sends — 0 of 500"` y `"SMS credits — 0 of 0"` como contadores separados, más la prohibición de masivo del AUP. | [F18]; [F12] | panel + doc | — | — | F-10 |
| MC-144 | ❌ Límites de recursos por plan: ninguna fuente publica tope de dominios, webhooks ni usuarios; el panel expone `"Expires"` y `"Remaining"` de la clave, las dos vacías — el mecanismo sin la cifra. **F-11 pierde universalidad aquí.** | [F18] | panel | — | — | F-11 |
| MC-145 | ❌ **con literal en contra** — La recepción consume la cuota de envío: la recepción tiene cuota propia y distinta, `"receive up to 100 inbound emails per day"`. | [F15] | doc | — | — | F-12 |
| MC-146 | ⚠️ Variante que falla V2 — El sobrecoste es opcional y no existe en Free: no existe sobrecoste en ninguna superficie, pero el mismo hecho ya cuenta entero en F-32. | `fricciones.md` | doc | — | — | F-13 |
| MC-147 | ❌ **con literal en contra** — El plan tiene fecha de caducidad: `"The emails included with the demo do not expire or renew"` es lo contrario de una caducidad. | [F15] | doc | — | — | F-14 |
| MC-148 | ✅ Dos canales, dos workloads para la misma cuota: `"Via the API, there's no recipient limitation"` y `"Via SMTP, you can send to up to 1,000 recipients at a time"`, en el mismo párrafo y sobre la misma cuota horaria. Sube a 5/7. | [F4] | doc | — | — | F-15 |
| MC-149 | ❌ El sobrecoste tiene tope del proveedor: no hay sobrecoste; el único tope es del cliente. | [F3] | doc | — | — | F-16 |
| MC-150 | ❌ Un tercer tope sin nivel de enganche: el tope de modo de pruebas sí tiene nivel (D7 admite el modo de operación como disparador de alias). No se modela por DISC-02, que es contradicción del dato y no carencia del esquema. | [F5]; DISC-02 | doc | — | — | F-17 |
| MC-151 | ✅ **el caso extremo: no hay plan del que pueda depender** — La capacidad depende del estado de la cuenta: `"Demo accounts are limited to a fixed hourly quota of 25 emails. Once you upgrade to a paid account, you'll be switched to the standard reputation and quota system"`, y en la cuenta de pago la cifra la fija la reputación. Pasa a 3/7. | [F6] | doc | 🟢 / — | `max_power.rate_email_hourly_demo` | F-18 |
| MC-152 | ❌ Cuota de cardinalidad: la franquicia demo se restringe por dominio, `"to any email address on your verified domain"`, no por número de direcciones distintas. | [F15] | doc | — | — | F-19 |
| MC-153 | ❌ **medida** — Un cupo que se gasta con intentos que no envían nada: sobre ~7.600 destinatarios en cola, los tres contadores siguen a cero. En Mandrill, encolar no consume. | [F21] | panel | — | — | F-21 |
| MC-154 | *(verificar)* Una credencial que solo se gestiona desde la web: el panel gestiona claves con caducidad y contador; ninguna fuente registrada dice si la API tiene endpoint equivalente, y por **G2** eso es celda vacía y no un ✅. | [F18] | panel | — | — | F-22 |
| MC-155 | ❌ Un comodín de prefijo con excepción: un solo caudal publicado y es de un endpoint concreto, sin comodín ni exclusión. | [F7]; [F10] | doc | — | — | F-23 |
| MC-156 | ❌ **por las dos mitades** — Cuota blanda que absorbe y luego descarta: el bloque es muro, `"el sistema dejará de enviar correos electrónicos cuando se te acaben los bloques"`; y la cuota horaria es cola que **sí** se procesa, `"We'll begin processing the backlog in the next hour"`, sin descarte. | [F3]; [F4] | doc | — | — | F-24 |
| MC-157 | ❌ Un endpoint, dos modos excluyentes: tres rutas separadas para los tres modos de envío. | [F8] | doc | — | — | F-25 |
| MC-158 | ⚠️ Variante que falla V1 — Un precio por geografía y una sola divisa: la página se sirve en dos idiomas con la misma cifra en USD, y la promoción es elegible `"in select countries"` sin lista. Se le cae la mitad de la divisa. | [F3]; `navegador_2026-09-21.md` P2 | doc | 🟢 | `currency` | F-26 |
| MC-159 | ❌ El exceso cambia el plan y lo dispara otra dimensión: no hay exceso, se compra otro bloque del mismo producto; **B13** descarta expresamente esta lectura. | [F3] | doc | — | — | F-27 |
| MC-160 | ✅ Una lista de IP autorizadas decide si la llamada entra, y está en la tabla oficial de errores. **F-28 cruza el umbral de D-008** (2/7). | [F5] | doc | — | — | F-28 |
| MC-161 | ❌ El precio unitario no tiene campo sin cuota incluida: aquí la unidad que se paga sí trae volumen dentro, `"Cada bloque es un crédito por 25,000 correos electrónicos"`. | [F3] | doc | 🟢 | `capacity.quota_email_block` | F-29 |
| MC-162 | ❌ **falla V1 y V2** — Precio por tramos marginales: no consta que los tramos sean marginales, y la escalera ya cuenta entera en F-32. | [F3]; `not_found` #12 | doc | — | — | F-30 |
| MC-163 | ❌ La unidad de gobierno es el par cuenta × región: ninguna fuente publica regiones ni endpoints regionales. | `fricciones.md` | doc | — | — | F-31 |
| MC-164 | ✅ **NUEVA** — Precio unitario degresivo sin planes que lo sostengan. Las tres formas que permite v0.3 fallan: seis planes-tramo es peso muerto (B1/B7), el precio de entrada declara como precio de plan lo que es precio de unidad, y `overage_cost` inventa un sobrecoste que el proveedor niega por escrito. **L1 completa; L2 y L3 pendientes. 1/7.** | `fricciones.md` F-32; [F3] | doc | 🟡 | `plans.transactional_email.price` | F-32 |
| MC-165 | ✅ **NUEVA** — Una franquicia que no caduca ni se renueva: la cuota sin ventana. `capacity` exige `period` y `window_type` en toda cuota, y aquí no hay ciclo que describir. Sin periodo, PRIME4API no puede situar la franquicia en ninguna curva; quitarla sería peor, porque dejaría el estado `demo` con caudal y sin tope de volumen. **L1 completa; L2 y L3 pendientes. 1/7.** | `fricciones.md` F-33; [F15]; [F18] | doc + panel | 🔴 | `capacity.quota_email_demo.period`, `.window_type` | F-33 |
| MC-166 | ✅ **NUEVA** — Dos topes de tamaño sobre la misma llamada, en magnitudes distintas. Las dos cifras están en MBs y el esquema solo puede alojar una: el fichero declara `max: 10` (la llamada) y los 25 MB del mensaje se quedan en el provenance. **L1 completa; L2 y L3 pendientes. 1/7.** | `fricciones.md` F-34; [F4] | doc | 🟢 / — | `…/messages/send.workload[1].max` | F-34 |
| MC-167 | **O-22, observación de método** — Por encima de un umbral no publicado, la API deja de decir qué va a hacer: hasta diez destinatarios `"status": "rejected"` con `"reject_reason": "unsigned"`, desde once `"status": "queued"` con `"queued_reason": "multiple-recipients"`; con cualquier adjunto, `"queued_reason": "attachments"` desde el primer byte. En esta API la vía de coste cero solo existe con ≤10 destinatarios y sin adjuntos. | `fricciones.md` O-22; `sondeo_a_preflight_2026-09-21.md` | sondeo | — | — | O-22 |
| MC-168 | Dos **reglas nuevas** salen de esta API, las dos del consejo del 2026-09-21: **B12** (producto sin planes con nombre) y **B13** (precio unitario degresivo sin planes que lo sostengan). B13 ordena que la escalera de Mailchimp no cuente como F-02 ni como F-27. | `fricciones.md` (cabecera); REVISION.md R4 | — | — | — | F-32 |

## 12. Lo que sorprendería a un tribunal

1. **Es la primera API del catálogo sin planes.** No tiene uno solo: no tiene ninguno. La página de precios no publica filas ni tarjetas, solo una unidad —`"Cada bloque es un crédito por 25,000 correos electrónicos"`— y seis precios para esa misma unidad (MC-02, MC-04…MC-09). Lo que en las siete anteriores era el eje del esquema, aquí no existe.
2. **El fichero encarece al proveedor barato, y no se ve.** `price: 20.00` es el tramo de entrada; a un millón de correos el proveedor cobra `$18`/bloque. El error crece con el volumen, va siempre en la misma dirección y no deja un hueco visible, sino una cifra plausible y alta (MC-88).
3. **Una cuota sin ventana.** `"The emails included with the demo do not expire or renew"`, y el fin de la demo lo dispara el consumo —`"You send 500 emails"`—, no una fecha. v0.3 exige periodo en toda cuota, así que el campo se queda vacío (MC-30, MC-31).
4. **El tope de tamaño publicado se midió y no se aplicó.** El proveedor dice `"less than 10MB"` por llamada; el sondeo metió ~40 MB con HTTP 200 y ninguna respuesta habló de tamaño (MC-128).
5. **Cinco mil destinatarios en una sola llamada, aceptados.** Sin cota superior alcanzada, frente a Mailgun, que rechaza la petición 1.001 con `"Too many recipients, max is 1000"` (MC-129).
6. **Por encima de diez destinatarios la API deja de decir qué va a hacer.** El borde es exacto —10 `rejected`, 11 `queued`— y no es de capacidad: es que desaparece la vía de medir sin gastar (MC-125, MC-126, O-22).
7. **Encolar no consume.** Unos 7.600 destinatarios en cola y los tres contadores del panel siguen a cero dos horas después (MC-132).
8. **La misma frase da dos anclas de reinicio incompatibles**, medianoche y veinticuatro horas desde que se agota el límite, y sigue abierta (DISC-02).
9. **La tabla oficial de errores no tiene 429 ni 403.** El exceso de envío no se rechaza: se encola y se reprocesa (MC-58, MC-101).
10. **Toda la capacidad de la cuenta de pago cuesta dinero de verdad.** El producto solo existe como complemento de una cuenta Mailchimp Standard o Premium, así que tres cifras —cuota horaria de pago, si el tramo es marginal o plano, y si N destinatarios gastan N unidades— quedan en `not_found` por decisión de gasto y no por falta de búsqueda (MC-16, MC-95, MC-106, MC-110).

## Corrección del 2026-10-31 (verificador independiente)

El 31-10 un verificador reabrió cada URL del `datasheet.yaml`. El informe íntegro está en
`03_datos/apis/mailchimp/evidencias/verificador_adversarial_2026-10-31.md`. No cambia ningún valor
ni ningún semáforo: siguen 11 🟢 · 2 🟡 · 4 🔴.

- **MC-12 y MC-107, error del dato.** Por encima de 161 bloques sí hay precio: `"161+ bloques |
  4M+ emails | $10/bloque"` (MC-09). Lo que remite a contacto comercial es un precio negociado
  por debajo de 10 USD.
- **MC-55 y MC-56, la fuente cambió (E3).** Con la migración de la documentación, entre el 3 y
  el 5 de octubre, las dos URL dan 404. El 20 por minuto sigue literal en el índice de notas de
  versión ([F17]), entrada `"Apr 10, 2023"`, y la línea del YAML apunta allí. La página que
  sucede al endpoint ya no da la cifra. MC-56 queda solo en Wayback, en la captura del
  2026-04-21.
- **MC-51, fuente mal atribuida.** El artículo de ayuda sobre throttling no dice nada del 5 %.
  El dato se queda con MC-50, de [F4].
- **MC-66 y MC-111, error del dato.** El umbral está publicado en la misma página: `"Emails with
  more than 10 recipients"`. Ya estaba en Wayback el 2026-03-12 y coincide con lo medido.
- **MC-112, la oferta cambió (E3).** Desde octubre el proveedor sirve la especificación,
  `openapi/api-reference-2.json`, enlazada desde `llms.txt`. El 2026-09-21 el hueco era cierto.
- **MC-113, error del dato.** La retención de la cuenta de pago está en `docs/activity-reports`:
  30 días de contenido, estadísticas sin límite y 90 días de datos de rebotes. Ya estaba en
  Wayback el 2026-07-30.
- **Términos.** La cita en inglés de la consecuencia del envío masivo era una retrotraducción.
  El literal es `"we may charge you at the comparable Paid Marketing Plan rate or terminate your
  account"`.

Volcados: `03_datos/apis/mailchimp/evidencias/paginas/2026-10-31/LEEME.md`.
