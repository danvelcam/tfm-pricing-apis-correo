# Observación de panel — Brevo, 2026-09-17

Escalón 2 de la escalera de validación, con cuenta propia del autor (plan Free).
Navegador: el Chrome autorizado del autor (`8bfcd503-51fd-4675-bc3e-92d4701ee501`, Linux),
seleccionado por `deviceId` antes de navegar, según `docs/08-mandato.md`.

**Modo lectura y captura.** No se pulsó ningún botón con consecuencias: ni `Upgrade now`,
ni `Select Starter/Standard`, ni `Talk to Sales`, ni `Buy credits`, ni `Get package`, ni
`Generate API key`, ni `Generate SMTP key`, ni `Activate for API/SMTP keys`, ni el selector
de divisa. Lo único pulsado fue `More filters` en la página de logs, que solo despliega
filtros.

**Redactado antes de guardar.** Se omiten: el valor enmascarado de la clave de API, el
login del relay SMTP (tiene la forma `<id>@smtp-brevo.com`) y cualquier dato de
facturación. La cuenta pertenece a la organización `Universidad de Sevilla`, que es la
institución del TFM y no se oculta.

La forma de este volcado sigue el precedente de
`03_datos/apis/mailersend/evidencias/panel_operaciones_c2_2026-09-14.md`: texto con citas
literales, no capturas de pantalla.

---

## 1 · Estructura de precios interna (categoría 1 de la skill, F-02)

Página: `app.brevo.com/billing/account/plans/upgrade` («Plans V5»).

Citas literales, con el conmutador en `Billed monthly` y el selector de divisa en `EUR`:

- `"Billed monthly"` · `"Billed yearly (Save 10%)"` · `"EUR"`
- Starter: `"From"` `"€7"` `"per month"` · `"From 5,000 emails per month"`
- Standard: `"Most popular"` · `"From"` `"€15"` `"per month"` · `"From 5,000 emails per month"`
- Professional: `"From"` `"€499"` `"per month"` · `"From 150,000 emails per month"`
- Enterprise: `"Custom price"` · `"From 1 million emails per month"`

**Una cifra que la documentación pública no publica, y solo una:**

1. **El suelo de volumen de Enterprise.** La documentación daba
   `"Custom number of emails per month"` [F4] y el panel dice
   `"From 1 million emails per month"`. El `"1 million"` que ya aparecía en `fuentes.md`
   antes de esta observación es otra cosa: los packs de crédito prepago de [F25]
   (`"packs ranging from 5,000 to 1 million emails"`), no el suelo del plan.

**Lo que NO es un hallazgo del panel, y se dice para no atribuirle mérito de más:** el
precio de Professional. La pasada documental ya lo tenía, y con semáforo verde:
`professional: price: 499.00  # 🟢` en el `datasheet.yaml`, con el literal
`'Professional', 'price': '499'` del bloque JSON-LD de la página de precios. El panel lo
confirma sobre una cuenta identificada, que no es lo mismo que descubrirlo.

## 2 · La divisa (Q8, DISC-08, F-26) — confirmación, no descubrimiento

**Esto ya estaba en el fichero antes de mirar el panel, y hay que decirlo así.** El
`data_provenance` del `datasheet.yaml` ya traía, de la pasada documental:

> `"NOTA: la página de precios sirve ocho divisas —'EUR (Euro)', 'USD (US Dollar)', 'GBP
> (British Pound)', 'BRL (Brazilian Real)', 'INR (Indian Rupee)', 'CAD (Canadian Dollar)',
> 'AUD (Australian Dollar)', 'CHF (Swiss Franc)'— y geolocaliza: desde España sirve EUR con
> Starter 7, Standard 15 y Professional 499. Las cifras no son conversiones entre sí (9 USD
> frente a 7 EUR) y ninguna divisa se declara canónica. La datasheet declara USD porque es
> la del bloque JSON-LD y la del centro de ayuda"`

O sea: las ocho divisas, la geolocalización, los tres precios en euros, que no son
conversiones y por qué se eligió USD **estaban todos documentados**. El panel **confirma
sobre una cuenta identificada** lo que la pasada documental leyó de la página pública. Eso
vale —es el escalón 2 corroborando al 1, y para F-26 la corroboración cuenta— pero **no es
un hallazgo nuevo** y no se presenta como tal.

**Lo que sí aporta el panel son los add-ons en euros, que es justo de lo que va DISC-08.**
Antes de esta observación el `datasheet.yaml` no tenía ni un símbolo `€`:

| Concepto | Documentación (USD) | Panel (EUR, cuenta en España) | ¿Nuevo? |
|---|---|---|---|
| Standard, precio de entrada | `"Starting at $18/month for 5,000 emails/month"` | `"From €15 per month"` | **No**: el 15 EUR ya estaba en el provenance |
| Starter, precio de entrada | `$9` | `"From €7 per month"` | **No**: el 7 EUR ya estaba en el provenance |
| Quitar el logo | `$10.80` y `$9` (DISC-08) | `"€9.00 per month"` | Sí |
| Sales Essentials | `$27.92` y `$31` (DISC-08) | `"€29 per month"` | Sí |
| Sales Advanced | `$58.50` y `$64` (DISC-08) | `"€59 per month"` | Sí |
| IP dedicada | `"$251 per year"` | `"From €228.00 per year"` | Sí |

Las cuatro cifras del panel son **redondas en euros**. Eso apunta a que **DISC-08 puede ser
un artefacto de divisa** y no una contradicción del proveedor: los importes con decimales
del lado documental ($10.80, $27.92, $58.50) tienen la forma de una conversión de un precio
nativo redondo. **No se cierra DISC-08 con esto**, porque el panel no dice de qué precio
nativo sale cada uno; pero cambia la hipótesis.

Para **F-26** («un precio por geografía y una sola divisa en el fichero») esto es evidencia
de panel: la divisa es un **selector**, así que las ocho monedas publicadas no son
conversiones de una lista, son listas de precios distintas.

## 3 · El ancla del reinicio de la cuota diaria (el único 🔴 del fichero)

Página: `app.brevo.com` (inicio), bloque `"Your plan usage"`.

- `"Emails"` → `"300 left out of 300 until 17/09/2026"`
- `"Prepaid credits"` → `"0 credits left"`
- `"SMS"` → `"0 credits left"`

Página `app.brevo.com/billing/account/plans/subscriptions`:

- `"Free plan"` · `"300 emails per day"` · `"100% left"`
- `"300 / 300 Marketing & Transactional emails left"`

**Lo que esto decide y lo que no.** La ventana **no es rolling**: el panel le pone fecha de
fin (`until 17/09/2026`, que es el día de la observación), así que el reinicio está anclado
a un cambio de día de calendario. **Lo que sigue sin decidirse es el huso**: entre
medianoche UTC y medianoche de la zona de la cuenta, el panel no distingue, y por D8 el
tipo de ventana lo fija el ancla. Queda como hueco declarado, no como verde.

## 4 · La cuota es de los dos productos (Q10, F-10)

`"300 / 300 Marketing & Transactional emails left"` es **un solo contador para los dos
productos**, dicho por el panel y sin ambigüedad. Es la respuesta que el sondeo del paquete
B iba a buscar gastando un envío.

Y hay un tercer saldo, separado: `"Prepaid credits"` `"0 credits left"`, distinto de los
300 diarios.

## 5 · El prepago levanta la cuota diaria (F-07)

Página `.../plans/subscriptions`, bloque `"Do more with Brevo"`:

- `"Emails: Prepaid credits"` · `"Starting from 5000 emails"` ·
  `"Send emails with no sending limit and without the Brevo logo."`
- Y en el bloque del plan Free: `"Remove daily sending limit"`

**Comprar crédito prepago quita el límite diario del plan gratuito y además arrastra una
función** (quitar el logo). Es exactamente F-07 —add-ons que modifican capacidad— con
evidencia de panel, y la carencia es que el esquema no tiene dónde escribir que un add-on
suprima una `quota` de otro bloque.

## 6 · Add-ons: plan mínimo y forma de contratación (F-07)

- `"Remove Brevo logo"` · `"€9.00 per month"` · `"Available with Starter plan"` · `"Upgrade to Starter"`
- `"Sales packages"` · `"Starting at €29.00 per month"` · `"Available with Starter, Standard, and Professional plans"` · `"Get package"`
- `"WhatsApp: Prepaid credits"` · `"Starting from 100 credits"` · `"Available with Professional plan"` · `"Upgrade to Professional"`
- `"Dedicated IP"` · `"From €228.00 per year"` · `"Available with Professional plan"` · `"Upgrade to Professional"`
- `"SMS: Prepaid credits"` · `"Starting from 100 credits"` · `"Send SMS campaigns to over 180+ countries"` · `"Buy credits"`

Dos formas distintas de contratación en la misma página: los de `"Buy credits"` y
`"Get package"` son autoservicio, y los de `"Upgrade to ..."` exigen cambiar de plan
primero. El matiz del plan mínimo por add-on solo se ve desde dentro.

## 7 · Límites de recursos por plan (F-11)

- `"Single-user access"` · `"Add more users with Standard and Professional plan"` · `"Get more seats"`
- Professional: `"Multi-user access"` · `"10 seats included"`
- Enterprise: `"Best for companies with 1M+ contacts needing custom solutions & full data control."`

## 8 · Credenciales y segmentación (categoría 8, F-15)

Página `app.brevo.com/settings/keys/api`:

- `"Your API Keys"`, una sola fila: nombre `"Sandbox"`, `"Active"`,
  `"Expires on September 16, 2027"`, `"Created on September 16, 2026 11:53 AM"`,
  `"Last used on September 17, 2026"` (ese último uso es la lectura de control de esta
  sesión). Valor enmascarado, redactado aquí.
- `"1-1 of 1"`

Página `app.brevo.com/settings/keys/smtp`:

- `"Your SMTP Settings"` · `"SMTP Server"` `"smtp-relay.brevo.com"` · `"Port"` `"587"` ·
  `"Login"` (redactado: `<id>@smtp-brevo.com`)
- `"Your SMTP Keys"` → `"Click here to generate an SMTP key"`, es decir **cero claves SMTP
  creadas**.

**Evidencia de panel para F-15** («dos canales, dos workloads para la misma cuota»): el
relay SMTP tiene **su propia familia de credenciales**, separada de las claves de API, y el
bloqueo por IP se activa por separado para cada familia —`"Activate for API keys"` frente a
`"Activate for SMTP keys"`—. Dos canales, dos credenciales, dos controles de acceso, una
sola cuota de 300.

**Control de acceso que el esquema no recoge**, y es nuevo:

- `"Unauthorized IP addresses are not blocked for your API keys"`
- `"To secure your account and API keys, activate blocking of unauthorized IP addresses for
  API keys to restrict API calls to authorized IP addresses only."`
- `"Before activating, confirm that your calling IP addresses are listed under Security →
  Authorized IPs."`

Una lista de IP autorizadas condiciona si una llamada se acepta, y v0.3 no tiene campo para
eso. **Candidata a fricción, sin número todavía**: falta comprobar la recurrencia en las
otras cuatro APIs antes de abrir una F-nn (D-008 §3), y falta L2.

**Lo que el panel NO dice**, y va a `not_found` igual que un hueco documental: cuántas
claves de API y cuántas SMTP admite la cuenta. Hay botón de generar, pero ningún tope
publicado.

## 9 · El modo de pruebas y lo que llama «Sandbox»

La única clave de la cuenta se llama `"Sandbox"`, pero **ese es el nombre que le puso el
autor, no un modo de la cuenta**. La cuenta es un Free real que entrega a donde se le diga,
tal como advierte `docs/08-mandato.md`. El panel no ofrece ningún modo de pruebas de cuenta
en las páginas recorridas.

## 10 · Retención de registros: DISC-10 sigue abierta

Página `app.brevo.com/transactional/email/logs`:

- `"In this page you can see all the events that happened with your transactional emails"`
- `"0 logs"` · `"There are no items in this list yet."`
- Con `"More filters"` desplegado, los filtros son `"Events"`, `"Sender (From)"` y `"Tags"`:
  **ningún rango de fechas y ningún periodo de retención**.

**DISC-10 no se cierra.** La documentación enfrentaba `"unlimited log retention"` con
`"Customized log retention"` sin periodo, y **el panel tampoco publica periodo**. Que no lo
diga ninguno de los tres sitios es el resultado.

De paso, `"0 logs"` es lo que el panel publicaba en el momento de la observación.

> **Corrección del 2026-09-17, misma fecha, después del sondeo.** Esta línea decía que el
> `"0 logs"` era «confirmación desde el panel de que esta sesión no ha enviado ningún
> correo, coherente con `credits: 300` en la lectura de control de la API». Las dos mitades
> se retiran. **La segunda, porque esa lectura no existe:** en `evidencias/` no hay ningún
> volcado de `GET /v3/account`, y el panel no publica ningún campo llamado `credits` con
> valor 300 — publica `"300 left out of 300"` de cuota diaria de correos y, por separado,
> `"0 credits left"` de prepago (§3 y §4 de este mismo volcado). Cuál de los dos es el
> `credits` del endpoint es DISC-14, abierta. **La primera, porque el `"0 logs"` no puede
> sostenerla:** el sondeo del mismo día mandó dos peticiones con `X-Sib-Sandbox: drop` y
> [F16] declara que en sandbox `"No email logs are created in your Brevo account"`, así que
> un panel sin registros es compatible con haber emitido. Lo que hay medido sobre eso está
> en `fuentes.md` [E1] y en el libro de cuentas: una petición ACEPTADA con `201`.

---

## Lo que el panel NO resolvió

- **El tramo de caudal (Q1).** Ninguna de las páginas recorridas menciona General, Advanced
  ni Extended, ni RPS, ni RPH, ni cabeceras de caudal. Es coherente con la observación
  **O-16**, que midió que la especificación de 145.561 bytes tampoco los nombra: el régimen
  de límites de Brevo vive **solo en HTML de documentación para humanos**, ni en el panel ni
  en la spec. **Q1 sigue siendo del autor.**
- **El precio de exceso.** Sigue sin existir: ni la página de planes ni la de uso publican
  un sobrecoste por unidad. Lo que hay en su lugar es cambiar de plan o comprar prepago, que
  es justo lo que dice **F-27**.
- **El día del ciclo de facturación (DISC-09).** La cuenta está en Free, sin suscripción, así
  que no hay fecha de facturación que mirar. No es medible en esta cuenta.
- **El estado de aprobación de la cuenta.** Ninguna página recorrida lo menciona.
- **El test C2 completo (Q7).** El menú lateral se recorrió pero las ocho operaciones no se
  contrastaron contra la referencia de cada endpoint. Queda pendiente.

## Páginas que devolvieron error

- `account-app.brevo.com/account/plan` → `"This page is not available right now."`
- `app.brevo.com/log` → `"We could not show this page"` (URL inventada; la correcta es
  `/transactional/email/logs`)

El botón `"Manage your plan"` del inicio no navegó, probablemente por el mismo error de
`account-app`. Se llegó a la misma información por
`app.brevo.com/billing/account/plans/subscriptions`.
