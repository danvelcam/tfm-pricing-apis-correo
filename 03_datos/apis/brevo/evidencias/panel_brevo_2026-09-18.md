# Observación de panel — Brevo, 2026-09-18

Segunda pasada de escalón 2, con la misma cuenta Free. La primera está en
`panel_brevo_2026-09-17.md` y dejó pendiente el test C2: recorrió el menú pero no las
páginas donde vive cada operación. Esta pasada va a por ellas, y de paso cae el dato que
DISC-10 pedía.

**Cuenta:** Free, `Universidad de Sevilla`. **Método:** navegador con la sesión del
titular, solo lectura. No se pulsó ningún botón que cree, borre o guarde nada.
**Redacción:** la única dirección que aparece en pantalla es la del titular y no se
transcribe.

**Un detalle de la herramienta, porque condiciona lo que se puede observar.** Varias rutas
del panel devuelven `"We could not show this page"` o una pantalla en blanco cuando se
entra por URL directa, y cargan bien al recargar (F5) o al llegar por el menú. Las páginas
de abajo se alcanzaron así. Las que no existen se dicen como tales.

---

## 1 · Test C2, la mitad de panel que faltaba

| # | Operación | En la API ([F29]) | En el panel |
|---|---|---|---|
| 1 | Enviar | ✅ `POST /smtp/email` | — (no se prueba desde el panel) |
| 2 | Crear o editar plantilla | ✅ `createSmtpTemplate`, `updateSmtpTemplate` | ✅ `app.brevo.com/templates/listing` |
| 3 | Añadir dominio y verificarlo | ✅ `POST /senders/domains`, `PUT …/authenticate` | ✅ `app.brevo.com/senders/domain/list` |
| 4 | Credenciales adicionales | ❌ solo subcuentas Corporate | ✅ `app.brevo.com/settings/keys/api` |
| 5 | Webhooks | ✅ `GET`/`POST /webhooks` | ✅ `app.brevo.com/transactional/email/settings` |
| 6 | Inbound routing | ✅ `POST /webhooks` con `type: inbound` | **no localizado** |
| 7 | Supresiones y rebotes | ✅ `blockedContacts`, `blockedDomains`, `deleteHardbounces` | ✅ misma página que la 5 |
| 8 | Actividad y registros | ✅ `GET /smtp/emails` | ✅ `app.brevo.com/transactional/email/logs`, §5 |

**Literales.**

- Plantillas, `app.brevo.com/templates/listing`: `"Templates"`, `"Create folder"`,
  `"Create Template"`, `"You have not created any Email templates."` **Cero plantillas
  creadas y ningún tope publicado.**
- Remitentes, `app.brevo.com/senders/list`: `"Senders, Domains & Dedicated IPs"`,
  `"Add sender"`, y las pestañas `"Senders"`, `"Domains"`, `"Dedicated IPs"`,
  `"Sending cadence"`. Un remitente, `"Verified"`, `"Shared IP"`, `"DMARC is configured"`,
  `"1-1 of 1"`.
- Dominios, `app.brevo.com/senders/domain/list`: `"Set up your domain"`,
  `"Authenticate your domain and brand your tracking links…"`, `"Add a domain"`. **Cero
  dominios y ningún tope publicado.**
- Ajustes transaccionales, `app.brevo.com/transactional/email/settings`: `"Configuration"`,
  `"Webhook — Each event (opening, click, bounce, etc.) will be sent in real time to your
  server."`, `"Blocked or unsubscribed contacts"`, `"Blocked domains"`, `"Tags"`,
  `"Retention rules"`, `"Tracking"`. **No hay entrada de inbound parsing**, que es
  coherente con que la API lo configure como un webhook de tipo `inbound`.

**Qué le hace esto al `type`.** Las tres operaciones que deciden el valor están en la API y
también en el panel, así que **ninguna es exclusiva de la web** y `api_first` se sostiene.
La única exclusiva del panel es la 4, las credenciales, que no decide el `type` y ya está
contada como **F-22**. La 6 **no existe en el panel**, y eso no es un hueco de observación:
significa que el *inbound routing* solo se configura por API, que es lo contrario de lo que
invertiría el valor. Las ocho quedan con cita por comprobación.

---

## 2 · Retención de registros: DISC-10 medida en el panel

`app.brevo.com/transactional/email/settings/retention-rules`:

- `"Email retention rules"` · `"For how long do you want to store previews and logs?"`
- `"Transactional logs are stored only for a limited time. Once the retention period ends,
  they will be deleted automatically."`
- `"All senders — The retention rule will apply to all senders."` ·
  `"Only Selected Senders — Apply retention rules only to specific senders you choose."`
- `"The logs will be deleted after [ ] months"`
- Previews: `"Keep the previews for the duration selected above."` ·
  `"Never store previews — New transactional emails will not have a preview. Choose this
  option if the previews may contain private information about their recipients."`

**El control, leído del DOM** (inspección, sin tocarlo): el campo es
`input[name="all-senders-retention"]`, de tipo `number`, con **`min="1"`, `max="24"` y
valor actual `1`**.

**Lo que decide.** La retención no es ilimitada ni viene fijada por el plan: **la fija el
cliente, entre 1 y 24 meses**, y puede aplicarse a todos los remitentes o solo a algunos.
Los *previews* se guardan la misma duración o no se guardan. Lo que esta cuenta **no**
puede decir es si el techo de 24 meses cambia con el plan.

---

## 3 · Lo que aparece y el esquema no tiene dónde poner

- **`"Sending cadence"`**, en `app.brevo.com/senders/sending-cadence`: `"Define how often
  you send marketing emails to manage marketing pressure…"`, `"Activate frequency cap"`,
  `"Set the maximum number of emails your contacts can receive during the below-defined
  period."`, con un botón `"Upgrade"` al lado. Es un **tope que pone el cliente**, por
  contacto y por periodo, y además **está detrás del plan**. Va como observación: el mismo
  patrón que el tope voluntario de MailerSend (F-13) y que la retención de arriba, tres
  límites que el cliente fija y que ninguna herramienta puede leer del fichero.
- **La retención configurable** es el segundo caso del mismo patrón, y el más claro: un
  número entre 1 y 24 que cambia cuánta historia tiene el cliente y que v0.3 no modela.

---

## 4 · Páginas que no existen

Probadas por URL directa y sin resultado: `app.brevo.com/settings/inbound`,
`app.brevo.com/settings/senders`, `app.brevo.com/webhook/list`,
`app.brevo.com/transactional/email/templates`. La ruta buena de plantillas
transaccionales es la misma que la de marketing, `app.brevo.com/templates/listing`.

---

## 5 · Los registros, y lo que desmienten (operación 8 del test C2)

`app.brevo.com/transactional/email/logs` · `"Logs"` · `"In this page you can see all the
events that happened with your transactional emails"` · `"6 logs"` · `"Download CSV"`.

Las seis filas, extraídas del DOM y **con los destinatarios redactados** (las dos primeras
son direcciones reales del autor, de la lista blanca de D-046):

| Evento | Fecha (hora de Madrid) | Asunto | De | Para |
|---|---|---|---|---|
| `Delivered` | 17/09/2026 23:30 | `TFM Brevo B1 unidad de la cuota [real/20260917213043]` | `<titular>` | `<lista_blanca_1>` |
| `Soft bounce` | 17/09/2026 23:30 | idem | `<titular>` | `<lista_blanca_2>` |
| `Sent` | 17/09/2026 23:30 | idem | `<titular>` | `<lista_blanca_1>` |
| `Sent` | 17/09/2026 23:30 | idem | `<titular>` | `<lista_blanca_2>` |
| `Error` | 17/09/2026 17:34 | `TFM sonda p2_sender_sumidero 1789659292222004022` | `sonda-remitente@example.invalid` | `sonda-00001@example.invalid` |
| `Sent` | 17/09/2026 17:34 | idem | `sonda-remitente@example.invalid` | `sonda-00001@example.invalid` |

**Tres cosas se leen aquí, y dos corrigen al expediente.**

1. **La petición en sandbox SÍ deja registro.** El expediente daba por hecho lo contrario
   —«0 logs no sirve de control, porque sandbox declara que no crea registros»— y se usó
   como argumento al razonar Q-A2. Medido: la petición de las 17:34, la que llevaba
   `X-Sib-Sandbox: drop`, tiene **dos filas**, `Sent` y `Error`. Lo que el par no permite
   distinguir es si la cabecera se respetó: el destinatario estaba en `example.invalid`, un
   dominio que no existe, así que el `Error` se explica igual con sandbox que sin él.
2. **El envío real de [E3] gastó dos destinatarios y uno rebotó.** Cuatro filas para dos
   destinatarios: `Sent` + `Delivered` en uno y `Sent` + `Soft bounce` en el otro. El rebote
   es de una dirección **de la lista blanca**, así que no hay nada que corregir en el
   mandato; se anota porque una dirección que rebota deja de servir para medir entrega.
3. **El panel muestra hora de Madrid** (GMT+02:00, como declara `Settings → General`),
   mientras los sondeos anotan UTC. Las 23:30 de la tabla son las 21:30 UTC de [E3].
