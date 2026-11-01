# Fuentes — MailerSend (Email API)

API de correo transaccional (Email API + SMTP relay), con SMS, WhatsApp y verificación de
direcciones como productos aparte bajo la misma cuenta. Proveedor: MailerSend.
Recolección: **2026-09-08 (pasada 1, dos tandas)**, documentación pública leída por cuatro
lentes (pricing/matriz, docs de desarrollador, soporte/términos/changelog, huecos) + volcados
de página con navegador (orquestador) + observación de panel con cuenta propia, todo el mismo
día; **sondeo empírico [E1] el 2026-09-09** (escalón 3, cuenta Sandbox no aprobada, coste
cero; el mismo script ejecutado dos veces, a las 19:02 y a las 19:13 UTC). Toda cita entre
comillas es literal salvo donde se marca `[VERBATIM DUDOSO]`, con **tres
convenciones de transcripción** que no son literales y que conviene saber leer (anotadas tras la
verificación independiente del 2026-09-08): (a) las **celdas de tabla y de tarjeta** se escriben
unidas con ` | `, `: ` o un espacio (`"Trial | 100"`, `"Sandbox: 100"`, `"$35.00 /month"`), cuando
la página las renderiza en celdas o líneas separadas — el mismo criterio de unión de celdas que
se aplicó en SendGrid (`"Essentials 50K 50,000 $0.0013"`); (b) los **mensajes de error** se
escriben como mensaje + `#MSnnnnn`, la forma del JSON de ejemplo de la página, cuando la tabla de
mensajes lleva el código delante (`MS42225 You have reached…`); (c) los **puntos suspensivos
`…`** marcan fragmentos abreviados. Las citas `[WebFetch]` de páginas con volcado parcial ([F3],
[F39], [F44]) siguen sin segundo lector. El provenance del `datasheet.yaml` no usa estas
convenciones: sus 210 citas con volcado coinciden al 100 %. La numeración [Fn] es la que
referencia este registro; el `datasheet.yaml` lleva el *provenance* autocontenido con URLs
directas.

> **Encuadre.** MailerSend está modelada en el repositorio de la guía (Gavira/Ruiz,
> `mailersend_v03.yaml`, 2026-03-19). Esta pasada se construye **desde las fuentes leídas
> hoy**; el modelado previo se usa solo para contraste (sección «Contraste con el modelado
> previo», evidencia de F-09), como se hizo con Resend.
>
> **Varios productos bajo la misma cuenta.** Lo modelado aquí es **solo el Email API
> transaccional** (planes Free / Hobby / Starter / Professional / Enterprise; regla A1 de
> `CRITERIOS.md`). SMS [F12][F48], WhatsApp [F1][F17] y verificación de direcciones [F3][F11]
> se documentan y van a F-10, no al YAML. Los estados de cuenta previos a un plan (Sandbox,
> Professional trial, cuenta no aprobada) se documentan [F37][F38][F39] y van a F-14 /
> `not_found`.
>
> **Cómo se leyó.** Solo `WebFetch` (modelo intermedio que limita cada cita a ~120 caracteres;
> las citas largas van troceadas en fragmentos consecutivos tal como las devolvió) y
> `WebSearch`; el shell no tiene red hacia mailersend.com ni swaggerhub. Tres grados de
> origen, de mayor a menor fuerza: **[VOLCADO]** (texto leído en un volcado de
> `evidencias/paginas/2026-09-08/`, hecho por el orquestador con el navegador; literal
> verificable sin red), **[WebFetch]** (literal probable; sin volcado) y **[WebFetch-JSON]**
> (fragmentos JSON crudos de la OpenAPI). Las citas que un recolector marcó
> `[VERBATIM DUDOSO]` conservan la marca; donde la tanda 2 las contrastó (CD-01…CD-27) se
> anota el resultado a continuación.
>
> **La página de precios es interactiva.** Los precios de Starter y Professional los calcula
> JavaScript a partir del selector «How many emails do you plan to send?»; `WebFetch` solo ve
> la posición por defecto y devuelve `"$ /month"`. La escalera completa se capturó accionando
> el selector con el navegador [F1]. Una página de feature [F11] embebe un bloque de tarjetas
> **desactualizado** (descuento anual del 20 %, sobrecoste $0.90) que contaminó la primera
> lectura de [F1]; se registra como DISC-03 y evidencia de F-09.
>
> **No hay changelog.** `developers.mailersend.com/changelog` y `mailersend.com/changelog` →
> 404. Lo que hace las veces son `/whats-new` [F17] y `/newsroom` [F47].

Volcados de página en `evidencias/paginas/2026-09-08/` (regla E2):
`www_mailersend_com_pricing.txt`, `www_mailersend_com_pricing_escalera.txt`,
`developers_mailersend_com_general.txt`, `developers_mailersend_com_api_v1_email.txt`,
`www_mailersend_com_help_plans_features_and_limits.txt`,
`www_mailersend_com_help_rate_limits_how_to_reduce_403_422_429_errors.txt`,
`www_mailersend_com_help_smtp_relay.txt`,
`www_mailersend_com_help_sandbox_mode_and_the_professional_trial.txt`,
`www_mailersend_com_help_how_to_set_a_billing_limit.txt`,
`www_mailersend_com_help_account_reputation_statuses.txt`,
`www_mailersend_com_help_how_to_start_sending_emails.txt` (parcial, [F39]),
`www_mailersend_com_help_plan_add_ons.txt` (parcial, [F3]),
`www_mailersend_com_legal_terms_of_use.txt` (solo la cabecera con la fecha, [F44]);
los ficheros `*_html.txt` de developers son copias idénticas de `general.txt` y
`api_v1_email.txt` con el nombre normalizado de la URL `.html` (para `verificar_citas.py`).
Volcado del sondeo [E1] en `evidencias/paginas/2026-09-09/api_mailersend_com_v1.txt` (los dos
JSON de la evidencia, tanda 1 y tanda 1b, aplanados a `clave: valor` uno tras otro, como
`api_sendgrid_com_v3.txt` en SendGrid), para que `verificar_citas.py` compruebe las citas del
provenance con URL `https://api.mailersend.com/v1/...`. La tanda 2 (2026-09-10, 13 casos) va
aparte, en `evidencias/paginas/2026-09-10/api_mailersend_com_v1.txt`, mismo formato.

---

## [F1] Página de pricing

- **URL:** https://www.mailersend.com/pricing (selector y toggle: `?currency=usd&billing=monthly` / `…=yearly`)
- **Fecha de acceso:** 2026-09-08 (volcado 17:05 UTC; escalera ~17:10 UTC)
- **Origen:** [VOLCADO] `www_mailersend_com_pricing.txt` (toggle anual por defecto) y
  `www_mailersend_com_pricing_escalera.txt`; además siete lecturas `WebFetch` de la tanda 1
  (prompts fragmentados por sección), varias de cuyas citas resultaron proceder del bloque
  desactualizado de [F11] (ver «Lecturas de tanda 1» al final de esta entrada).
- **Cómo se capturó la escalera (nota del volcado, literal):** `"el selector «How many emails do
  you plan to send?» es un <input type="range" min="1" max="8" step="1">; se fijó cada valor por
  JavaScript (setter nativo + eventos input/change) y se leyó el innerText de las tarjetas de plan
  tras cada cambio. El toggle «Pay monthly / Pay yearly» se pulsó con click(); la URL pasa a
  ?currency=usd&billing=monthly|yearly."` → los literales son los que la página renderiza en cada
  posición. Nota del volcado: `"El selector no pasa de 2M; no hay tarjeta Enterprise en la página"`.

### Selector, toggles y moneda
- Encabezado del selector: `"How many emails do you plan to send?"` · toggle `"Pay monthly"` ·
  `"Pay yearly Save 10%"` [WebFetch, coincide con el volcado: etiqueta `"Save 10%"`].
- Botones de moneda `USD / EUR / GBP` y `"Taxes may apply, learn more."` [VOLCADO]. La frase
  `"Pricing in Euros and British Pounds is for informational purposes only. All billing invoices
  will be charged in US dollars."` **no está en /pricing** (CD-08): es literal de [F11].

### Escalera volumen × precio × sobrecoste — `billing=monthly` [VOLCADO]
Formato de la página: `"$110.00 /month"`, `"50,000 emails /month"`, `"Extra usage $1.30 /1,000 emails"`.
**Nota de literalidad (verificación 2026-09-08):** cada literal de tarjeta es la unión con un
espacio de celdas adyacentes que la página renderiza en líneas separadas (`Extra usage` / `$1.30`
/ `/1,000 emails`; `50,000` / `emails /month`), igual que en SendGrid. El DOM lleva las tres
monedas a la vez (`$1.50 €1.50 £1.50 /1,000 emails`) y el navegador solo muestra la elegida.
**Ninguna cifra de estas tablas, ni las tarjetas mensuales, ni los precios anuales se reproducen
sin ejecutar el JavaScript de la página:** un lector sin navegador ve `"$ /month"` o los valores
de 2024 (ver «Lecturas de tanda 1» más abajo). Los precios de plan ($7 / $35 / $110) tienen
además literal en prosa en [F2]; la escalera solo la sostiene `www_mailersend_com_pricing_escalera.txt`.

| Posición | Starter | Professional |
|---|---|---|
| 5K / 50K | `"$35.00 /month"` · `"50,000 emails /month"` · `"100 SMS /month"` · `"Extra usage $1.30 /1,000 emails"` · `"100,000 daily API requests"` | `"$110.00 /month"` · `"50,000 emails /month"` · `"150 SMS /month"` · `"Extra usage $1.30 /1,000 emails"` · `"500,000 daily API requests"` |
| 100K | `"$68.00 /month"` · `"100,000 emails /month"` · `"350 SMS /month"` · `"Extra usage $1.30 /1,000 emails"` | `"$140.00 /month"` · `"100,000 emails /month"` · `"500 SMS /month"` · `"Extra usage $1.30 /1,000 emails"` |
| 250K | `"$162.50 /month"` · `"250,000 emails /month"` · `"1,750 SMS /month"` · `"Extra usage $1.10 /1,000 emails"` | `"$275.00 /month"` · `"250,000 emails /month"` · `"2,500 SMS /month"` · `"Extra usage $1.00 /1,000 emails"` |
| 500K | `"$325.00 /month"` · `"500,000 emails /month"` · `"3,500 SMS /month"` · `"Extra usage $1.10 /1,000 emails"` | `"$525.00 /month"` · `"500,000 emails /month"` · `"5,000 SMS /month"` · `"Extra usage $0.80 /1,000 emails"` |
| 1M | `"$600.00 /month"` · `"1,000,000 emails /month"` · `"7,000 SMS /month"` · `"Extra usage $1.00 /1,000 emails"` | `"$1,000.00 /month"` · `"1,000,000 emails /month"` · `"10,000 SMS /month"` · `"Extra usage $0.60 /1,000 emails"` |
| 1.5M | *(repite el peldaño 1M: `"$600.00 /month"` · `"1,000,000 emails /month"`)* | `"$1,350.00 /month"` · `"1,500,000 emails /month"` · `"13,000 SMS /month"` · `"Extra usage $0.60 /1,000 emails"` |
| 2M | *(repite el peldaño 1M)* | `"$1,600.00 /month"` · `"2,000,000 emails /month"` · `"15,000 SMS /month"` · `"Extra usage $0.50 /1,000 emails"` |

Nota del volcado: `"Starter no crece más allá de 1M: la tarjeta repite el escalón 1M"`.
Hobby en todas las posiciones: `"$7.00 /month"` · `"5,000 emails /month"` · `"Extra usage $1.50
/1,000 emails"` · `"1,000 daily API requests"`. Free: sin tarjeta variable (`"500 emails /month"`, `"$0"`).

### Escalera — `billing=yearly` [VOLCADO] (etiqueta `"Save 10%"`)

| Posición | Starter | Professional |
|---|---|---|
| 5K / 50K | `"$ 31.50 /month"` · `"$378.00 billed yearly"` | `"$99.00 /month"` · `"$1,188.00 billed yearly"` |
| 100K | `"$ 61.20 /month"` · `"$734.40 billed yearly"` | `"$126.00 /month"` · `"$1,512.00 billed yearly"` |
| 250K | `"$ 146.25 /month"` · `"$1,755.00 billed yearly"` | `"$247.50 /month"` · `"$2,970.00 billed yearly"` |
| 500K | `"$ 292.50 /month"` · `"$3,510.00 billed yearly"` | `"$472.50 /month"` · `"$5,670.00 billed yearly"` |
| 1M | `"$ 540.00 /month"` · `"$6,480.00 billed yearly"` | `"$900.00 /month"` · `"$10,800.00 billed yearly"` |
| 1.5M | *(tope 1M)* | `"$1,215.00 /month"` · `"$14,580.00 billed yearly"` |
| 2M | *(tope 1M)* | `"$1,440.00 /month"` · `"$17,280.00 billed yearly"` |

Hobby anual: `"$ 6.30 /month"` · `"$75.60 billed yearly"`. El sobrecoste (`Extra usage`) es el
mismo en mensual y anual en cada peldaño. (El espacio en `"$ 31.50"` es de la página.)

### Tarjetas de plan [VOLCADO]
- Free — `"Free"` · `"For occasional email testing and sending"` · `"Get started for free —
  includes: 500 emails /month · Email API and SMTP relay · Email threads support · Drag & Drop
  email builder"` · botón `"Try for free"`. (CD-05: la tarjeta Free **no** lleva bloque «Usage
  limits»; esos valores están en la tabla comparativa y en la FAQ 14.)
- Hobby — `"Hobby"` · `"For personal projects and side hustles"` · `"All in Free, plus: User roles
  & permissions · Bulk emailing"` · Usage limits: `"5 seats"` · `"1 domain"` · `"10 templates"` ·
  `"1-day activity data retention"` · `"1,000 daily API requests"` · **sin línea SMS** (CD-04) ·
  botón `"Start free trial"` · `"Try Professional features free for 14 days"`.
- Starter — `"Starter"` · `"For growing startups and small businesses"` · `"All in Hobby, plus:
  Sender identities · Remove MailerSend logo · SMS API (USA and Canada)"` · Usage limits: `"5
  seats · 10 domains · 250 templates · 7-day activity data retention · 100,000 daily API
  requests"` (CD-06: `"50 webhooks"` no está en la tarjeta, solo en la tabla).
- Professional — `"Professional"` · `"For agencies and white-label resellers sending at scale"` ·
  `"Best value"` · `"All in Starter, plus: 7-days API logs retention · Dedicated Account manager
  · Deliverability consultation"` · Usage limits: `"∞ users* · ∞ domains* · ∞ templates* · 30-day
  activity data retention · 500,000 daily API requests"` · nota del asterisco `"*Learn more about
  plan limits."` (enlace a [F2]).
- Enterprise — **no hay tarjeta ni bloque Enterprise** (dos lecturas WebFetch: «SIN BLOQUE
  ENTERPRISE»; volcado: `"no hay tarjeta Enterprise en la página"`). La palabra aparece solo en
  la FAQ 7 y en el texto de IP dedicada.

### Prueba gratuita
- `"14 days free to integrate, send and validate"` · `"Start your free trial and get access to all
  Professional plan features"` · `"Explore every MailerSend feature free for 14 days without
  committing to a plan"` · `"Try Professional features free for 14 days"` [WebFetch].

### Add-ons y otros productos en la página [VOLCADO salvo indicación]
- `"Domain spaces and Phone numbers are available for Starter, Professional, and Enterprise plans."`
- `"All MailerSend plans can access Email Verification."`
- **`"Dedicated IPs are available for Enterprise accounts that send over 100K emails/week."`** ·
  tarjeta Dedicated IPs: `"For high-volume senders who want full control over sending
  reputation."` · `"Contact our support team"` (sin precio). Lectura de tanda 1: `"Dedicated IP
  add-on"` · `"Dedicated IPs - For high-volume senders who want full control over sending
  reputation."`. (CD-10: la lectura de tanda 1 `"For
  high-volume senders who send over 100K emails/week"` era una **fusión de dos frases**; se
  sustituye por las dos literales.)
- Add-ons: `"Domain spaces … $4.00 · 1 domain space"` · `"Phone numbers … $2.00 · 1 phone number"`
  · `"Activity data retention … From $5.00"` · `"DMARC monitors … For Professional plans that
  need to monitor more than 10 domains, plus Starter plans. · $2.00 · 1 domain"` · `"Email
  verification … 2,500 credits … $25.00 · $0.01 per credit"`.
- WhatsApp: `"WhatsApp"` · `"Connect with customers through instant rich media messaging."` ·
  `"Select a plan"` · `"1,000 messages"` · `"10,000 messages"` · `"50,000 messages"` · `"$5.00"` ·
  `"$0.0050 per message"` · `"Extra usage: $2.50/1,000"`; tabla `"WhatsApp API | Add-on available
  Add-on available Add-on available"` (tres celdas: Free sin add-on). [WebFetch tanda 1:
  `"WhatsApp API"` · `"Connect with customers through instant rich media messaging."`]
- SMS [WebFetch]: `"100 SMS /month"` · `"Reach customers with transactional text messages."` ·
  enlace `"SMS API"` (`US & CA`).
- Retención [WebFetch]: `"Email activity data retention - 30 days"` (enlace a [F4]) · `"API logs
  data retention - 7 days"`.
- SLA [WebFetch]: `"99.5% guaranteed uptime SLA"` (enlace a /legal/service-level-agreement).
- Descuento [WebFetch]: `"Yes, nonprofit organizations are eligible to receive a 30% discount"` ·
  `"US nonprofits can provide their IRS tax exemption certificate"` · `"European NGOs can provide
  any official government document"`.

### FAQ (títulos literales y respuestas; versión íntegra del volcado donde existe)
1. `"Is there a trial period?"` — `"Yes, MailerSend offers a 2-week free trial period of the
   Professional plan so you can fully evaluate the fit for your use case before committing to a
   plan. The trial gives you access to all MailerSend features, with 500 emails/month."` [VOLCADO]
2. `"What happens when my free trial expires?"` — `"Once your free trial expires, you won’t be
   charged or automatically upgraded. Instead, you’ll be transferred to the Free plan. We’ll never
   charge you unless you follow the steps to upgrade to a paid plan."` [VOLCADO] (tanda 1, truncada:
   `"Once your free trial expires, you won't be charged or automatically upgraded. Instead, you'll be
   transferred to the Free plan."`)
3. `"What are the advantages of using the trial domain?"` — `"With the trial domain, you can test
   out MailerSend to its full potential without adding your own domain, only doing so if you
   decide it's the tool for you."` [WebFetch]
4. `"How does the Free plan work?"` — `"Once your account is approved, you can subscribe to a Free
   plan. This plan lets you send up to 500 emails per month for free! Simply go to the Plan and
   billing page and enter your organization's address and credit card information to complete
   your subscription. The billing period starts right after you enter your credit card details.
   The number of emails that you have sent automatically resets every 30 days."` [WebFetch;
   VOLCADO confirma `"The billing period starts right after you enter your credit card details."`
   y `"The number of emails that you have sent automatically resets every 30 days."`]
5. `"How does the Hobby / Starter / Professional plan work?"` — `"Once your account is approved,
   you can pick a Hobby, Starter or Professional plan to match the number of emails that you send
   every month. Save money as you send more emails! In addition to all the features of the Hobby
   plan, Starter and Professional plans enjoy multiple sending domains, more templates, webhooks
   and API tokens, plus 30 days of log retention (Professional), and live chat support. Subscribe
   to a Hobby, Starter or Professional plan by choosing a monthly plan on the Plan and billing
   page. Then enter your organization's details and credit card information to complete your
   purchase. If you exceed the monthly quota of your plan, don't worry—you can continue sending
   emails without disruption. These will be charged at an additional low cost per 1,000 emails
   (applies to all plans). The number of emails that you have sent automatically resets every 30
   days."` [WebFetch; VOLCADO: `"If you exceed the monthly quota of your plan, don’t worry—you can
   continue sending emails without disruption. These will be charged at an additional low cost per
   1,000 emails (applies to all plans). The number of emails that you have sent automatically resets
   every 30 days."`]
6. `"What if I decide to cancel?"` — **`"If you no longer wish to use MailerSend, you may cancel at
   any time. Your subscription will remain active for the remainder of that month's billing cycle,
   at the end of which you will receive a final charge for any additional emails sent outside of
   your current plan’s allowance."`** [VOLCADO; la lectura de tanda 1 estaba truncada, CD-07: `"If you
   no longer wish to use MailerSend, you may cancel at any time. Your subscription will remain active
   for the remainder of that month's billing cycle."`]
7. `"Can I use MailerSend with multiple users?"` — `"Yes! Both the Hobby and Starter plans include
   up to 5 users while Professional and Enterprise plans offer unlimited user seats."` [WebFetch]
8. `"Are there any limits to the free trial?"` — **`"The free trial has everything you need for
   proper integration, testing, and validation of MailerSend, including 500 emails/month, 100 API
   requests/day, and 1 day of Log retention. You’ll get access to all MailerSend Professional plan
   features. View our free trial help guide to learn more."`** [VOLCADO] (tanda 1, truncada: `"The
   free trial has everything you need for proper integration, testing, and validation of MailerSend,
   including 500 emails/month."`)
9. `"What is the trial domain?"` — `"The trial domain is a free domain you can use to conveniently
   test out MailerSend before adding and verifying your own domain."` [WebFetch; VOLCADO coincide]
10. `"Do you offer discounts for nonprofits?"` — `"Yes, nonprofit organizations are eligible to
    receive a 30% discount on MailerSend's paid plans."` · cierre: `"This discount is not stackable
    with the Yearly discounted prices."` [VOLCADO]
11. `"Why do you need my credit card details for the Free plan?"` — `"You won't be charged for
    anything on the Free plan; we just ask that you provide this information to prevent abuse of
    the platform."` [WebFetch]
12. `"Can I change my plan later?"` — **`"You can change your plan at any time! When you upgrade
    your plan, changes are applied immediately. When you downgrade your plan, changes are applied
    at the end of your current billing cycle."`** [VOLCADO]
13. **`"What are extra emails?"`** — **`"MailerSend ensures you can keep sending emails if you reach
    your monthly subscription quota. For example, an $68 subscription includes 100,000 emails on
    the Starter plan. Any extra email sent above that allowance has a cost of $1.30 for a block of
    1,000 emails."`** [VOLCADO]
14. `"What if I hit a limit on my Free plan?"` — `"Our Free plan has a few limits per account: 1
    template, 1 domain, 1 user (plus 1 accountant), 1 API token, 1 webhook, and 100 daily
    requests. To increase your limits, and have the full MailerSend experience, you will need to
    upgrade to a Hobby, Starter or Professional plan."` [VOLCADO la primera frase; WebFetch el resto]

### Tabla «Compare plans & features»
Categorías literales: `"Sending and receiving"` · `"Integrations"` · `"Deliverability &
performance"` · `"Email templates"` · `"Users, security and support"`. Columnas: Professional /
Starter / Hobby / Free. La tanda 1 obtuvo **dos lecturas divergentes** del modelo intermedio
(`[VERBATIM DUDOSO]`; A | B donde divergen). CD-09: las filas numéricas quedan **confirmadas por
el volcado**; los ticks (✓/—) **no son capturables** por texto (respuesta del modelo: `"the
comparison table markup does not clearly preserve the checkmark/cross icons"`; para cada fila
`"(Icon missing)"`, [H8]).

| Fila | Free | Hobby | Starter | Professional |
|---|---|---|---|---|
| `Daily API requests` | 100 | 1,000 | 100,000 | 500,000 |
| `Sending domains` | 1 | 1 | 10 | `Unlimited*` |
| `Webhooks` | 1 | 1 | 50 | `Unlimited*` |
| `Bulk emailing` | — | ✓ | ✓ | ✓ |
| `Sender identities` | — | — | ✓ | ✓ |
| `Inbound routing` | — | — | ✓ | ✓ |
| `SMS API` | — | `Add-on available` (A) \| ✓ (B) `[VERBATIM DUDOSO]` | ✓ | ✓ |
| `WhatsApp API` | — | `Add-on` | `Add-on` | `Add-on` |
| `Custom headers support` (B) | — | — | ✓ | ✓ |
| `MCP server` (B) | — | — | — | ✓ |
| `Email activity data retention` | `1 day` | `1 day` | `7 days` | `30 days` |
| `API logs data retention` | — | — | — | `7 days` |
| `DMARC monitoring data retention` [VOLCADO] | | | `7 days (30-day free trial)` | `30 days` |
| `Email verification` | `Add-on available` (A) \| ✓ (B) `[VERBATIM DUDOSO]` | ídem | ídem | ídem |
| `DMARC monitoring` (B) | — | — | `1 domain (30-day free trial)` (volcado: `"10 domains 1 domain (30-day free trial)"`) | `10 domains` |
| `Blocklist monitoring` (B) | — | `2 monitors` | `64 monitors` | `256 monitors` |
| `99.5% guaranteed uptime SLA` (B) | — | — | ✓ | ✓ |
| `Dedicated IP add-on` | — | — | — (A) \| ✓ (B) `[VERBATIM DUDOSO]` | `Available` (A) \| ✓ (B) |
| `Branded templates` | 1 | 10 | 250 | `Unlimited*` |
| `Translations` (B) · `Split testing` (B) · `Remove MailerSend logo` (B) | — | — | ✓ | ✓ |
| `User seats` | `1 user + 1 accountant` (`"1 user seat + 1 accountant role"` [VOLCADO]) | 5 | 5 | `Unlimited*` |
| `User roles & Permissions` | — | ✓ | ✓ | ✓ |
| `IP allowlisting` (B) · `2-Factor Authentication bulk enforcement` (B) | — | — | ✓ | ✓ |
| `Support` | `"Limited"` | `"Email support"` | `"Email support, Live chat support"` | `"Priority email support, Live chat support, Onboarding assistance"` |

Filas literales del volcado: `"Webhooks | Unlimited* 50 1 1"` · `"Sending domains | Unlimited* 10 1
1"` · `"DMARC monitoring data retention | 30 days 7 days (30-day free trial)"` · `"API logs data
retention | 7 days"` · `"*Learn more about plan limits."`. Celdas de Support [WebFetch, por celdas].

### Lecturas de tanda 1: el HTML de /pricing sin JavaScript lleva los precios de 2024
Se conservan porque se registraron como leídas en /pricing. El contraste (CD-01…CD-06) las dio
por procedentes del bloque desactualizado de [F11]; **la verificación independiente del
2026-09-08 corrige esa lectura**: dos lecturas más de `/pricing` con un lector sin JavaScript
(verificador y corrector, el mismo día) devuelven para la tarjeta Hobby `"$ 5.60 /month"`,
`"$67.20 billed yearly"`, `"€5.15 /month"`, `"£4.43 /month"`, `"$7.00 /month €6.44 /month £5.53
/month"` y `"$1.50 €1.50 £1.50 /1,000 emails"`, y **no contienen** `"$6.30"` ni `"$75.60"`. Es
decir: el HTML servido de /pricing conserva los precios anuales de 2024 (los mismos de [F11]) y
el JavaScript los sustituye al cargar por los del volcado del navegador. Evidencia adicional de
F-09 (la misma URL publica dos ofertas según se ejecute o no el JS) y añadido a DISC-03; el
orquestador puede confirmarlo con `view-source:` cuando quiera. Lo que sigue son las lecturas
tal como se registraron:
- Hobby: `"$5.60 /month"` · `"$67.20 billed yearly"` · `"€5.15 /month"` · `"€61.83 billed yearly"`
  · `"£4.43 /month"` · `"£53.18 billed yearly"` · `"$7.00 /month"` · `"€6.44 /month"` · `"£5.53
  /month"` · `"Extra usage"` · `"$1.50 €1.50 £1.50 /1,000 emails"` (CD-01).
- Starter/Professional: `"$ /month"` (celda vacía, JS) · `"Extra usage"` · `"$0.90 €0.90 £0.90
  /1,000 emails"`, es decir `"Extra usage $0.90 €0.90 £0.90 /1,000 emails"` (CD-03).
- Hobby `"100 SMS /month"` `[VERBATIM DUDOSO]` y Professional `"100 SMS /month"` `[VERBATIM
  DUDOSO]` → **CD-04: error de lectura**; /pricing: Professional `"150 SMS /month"`, Starter `"100
  SMS /month"`, Hobby sin línea SMS.
- Free «Usage limits» (`"1 user seat + 1 accountant role"` · `"1 domain"` · `"1 template"` ·
  `"1-day activity data retention"` · `"100 daily API requests"` · `"1 webhook"`) → CD-05: están en
  la tabla y en la FAQ 14, no en la tarjeta.
- Professional «Usage limits» `"7-days API logs retention"` · `"∞ webhooks*"`; Starter `"50
  webhooks"` → CD-06: reatribuidas a `"All in Starter, plus:"` y a la tabla.
- Opciones del selector: **NO VISIBLES** para WebFetch (respuesta del modelo intermedio: «NO
  VISIBLE EN EL CONTENIDO»); solo `"50,000 emails /month"` en Starter y Professional.

### Observaciones
- **Crítica:** el precio **no es una tarifa por plan sino plan × volumen** (FAQ 13, FAQ 5 `"Save
  money as you send more emails!"`, selector), con la escalera **oculta tras un control
  interactivo**: F-02 y F-08 en la página de precios. El sobrecoste **baja al subir el volumen**
  dentro del mismo tier (Starter $1.30 → $1.00; Professional $1.30 → $0.50) y a igual volumen
  Starter y Professional tienen sobrecostes distintos desde 250K.
- **Crítica:** el `"$0.90 /1,000 emails"` **no está hoy en /pricing** en ninguna posición del selector
  (cierra la parte de DISC-01 que enfrentaba tarjeta y FAQ; pasa a DISC-03). El anual es el **90 %**
  del mensual en todos los peldaños, coherente con `"Save 10%"` (cierra DISC-02 en /pricing).
- **Crítica:** en el selector **Starter llega a 1M** ($600) y no crece más; Professional sigue hasta
  2M. La tabla de [F14] es una mezcla de Starter (≤500K) y Professional (≥1M). DISC-06 sigue
  abierta contra `"up to 500,000"` de [F5]/[F13].
- El ciclo del volumen es `"resets every 30 days"` (FAQ 4 y 5) y el de cancelación `"that month's
  billing cycle"` (FAQ 6): dos formulaciones → DISC-12 (`fixed_billing_cycle` en ámbar, D3).
- La cuota mensual **no es tope duro** en los planes de pago (`"you can continue sending emails
  without disruption"`) y sí lo es en Free (`"you can't exceed"` no aparece; lo que dice [F2] es que
  el sobrecoste `"doesn't apply to ... the Free plan"`, `"none of which allow extra usage"`). F-13.
- El descuento nonprofit `"is not stackable with the Yearly discounted prices"`.
- WhatsApp tiene precio publicado aquí (`"$5.00"`, `"$0.0050 per message"`); producto aparte
  (A1 → F-10). Ticks de Inbound routing, Custom headers, MCP server, SLA, IP allowlisting, 2FA,
  Translations, Split testing: **sin fuente textual** ([H8]).

## [F2] Centro de ayuda — MailerSend Plans and Limits

- **URL:** https://www.mailersend.com/help/plans-features-and-limits
- **Fecha de acceso:** 2026-09-08 (la página no muestra fecha de actualización)
- **Origen:** [VOLCADO] `www_mailersend_com_help_plans_features_and_limits.txt` (tanda 2);
  antes dos lecturas WebFetch (lentes pricing y soporte; el modelo intermedio se negó a reproducir
  el artículo entero y se extrajo por secciones). Encabezados literales: `"What's included in the
  Hobby plan"`, `"What's included in the Starter plan"`, `"What's included in the Professional
  plan"`, `"Custom Enterprise plans"`.
- **Citas literales — introducción y sobrecoste:**
  - `"Each MailerSend plan includes a monthly email limit. Once you exceed your plan's allowance, we bill extra emails at a set rate per 1,000 on your next invoice"`
  - **`"(this doesn't apply to Sandbox mode, the Free plan, or the Professional trial, none of which allow extra usage)"`**
  - `"If you don't wish to send any emails above your plan's included allowance, you can set a limit to prevent overusage."`
  - **`"The number of emails that you send resets every 30 days."`**
  - `"Curious what Sandbox mode or the Professional trial include? Read about Sandbox mode and the Professional trial."` (enlace a [F37])
- **Citas literales — «What's included in the Free plan»:**
  - **`"Once approved, the Free plan allows you to send up to 500 emails a month for free, with a daily limit of 100 emails."`** [VOLCADO]
  - `"If you reach this limit within the 30-day usage period, your sendings will be paused until a new period begins and your email limit is reset."` [VOLCADO] (párrafo completo: `"Once approved, the Free plan allows you to send up to 500 emails a month for free, with a daily limit of 100 emails. If you reach this limit within the 30-day usage period, your sendings will be paused until a new period begins and your email limit is reset."`)
  - `"The Free plan also gives you access to features such as: Email API, SMTP relay, webhooks, inbound routing, email tracking, real-time activity, multiple email editors, and more!"` [VOLCADO]
  - Lista: `"Emails/month: 500"` · `"Sending domains: 1"` · `"API tokens: 1"` · `"Daily API requests: 100"` · `"Webhooks: 1"` · `"Inbound routes: 1"` · `"SMTP users: 1"` · `"Templates: 1"` · `"User seats: 1 + 1 accountant"` · `"Email verification credits: 10"` · `"Activity retention: 24 hours"`
- **Citas literales — «What's included in the Hobby plan»:**
  - `"The Hobby plan allows you to send up to 5,000 emails every month."`
  - **`"If your outgoing emails exceed this limit within your billing period, you can continue to send emails at a metered rate of $1.50 per 1,000 additional emails sent."`**
  - Lista: `"3 API tokens"` · `"5 webhooks"` · `"10 templates"` · `"5 users"` · `"1 inbound route"` · `"1,000 daily API requests"` · `"Access to the bulk email endpoint"` · `"100 email verification credits on signup"` · `"24/7 email support"`
  - **`"The Hobby plan costs $7 per month, or $6.30 per month with an annual plan."`**
- **Citas literales — «What's included in the Starter plan»:**
  - `"You can select your plan size based on the number of emails you expect you'll need to send."`
  - **`"If you exceed the sending quota outlined in your Starter plan, you will be charged a metered rate starting at $1.30 per additional 1,000 emails sent. The price per 1,000 emails decreases the larger your plan size."`**
  - Lista: `"Transactional SMS API"` · `"7-day Activity data retention"` · `"5 inbound routes/domain"` · `"10 sending domains"` · `"50 webhooks, SMTP users (5 users/domain), and API tokens"` · `"100,000 daily API requests"` · `"50 sender identities"` · `"100 email verification credits on signup"` · `"24/7 live chat support"`
  - **`"Starter plans start from as little as $35 a month, or $31.50 a month with an annual plan, for an allowance of 50,000 emails per month."`**
- **Citas literales — «What's included in the Professional plan»:**
  - `"if you exceed the limit, additional emails will be charged a metered rate starting at $1.30 per 1,000 emails. The price per 1,000 emails decreases the larger your plan size."`
  - Lista: `"400 email verification credits on signup"` · `"30-day Activity data retention"` · `"7-day Log data retention"` · `"1,000 sending domains"` · `"1,000 API tokens and SMTP users (20 users/domain)"` · `"5,000 webhooks"` · `"500,000 daily API requests"` · `"100,000 inbound routes (5,000/domain)"` · `"5,000 templates"` · `"Custom header support"` · `"1,000 users"` · `"DMARC monitoring for up to 10 domains (+ add-on for additional domains)"` · `"Blocklist monitoring for up to 256 domains/IPs"` · `"Priority email support and onboarding assistance"`
  - **`"Professional plans start at $110 a month, or $99 a month with an annual plan, for an allowance of 50,000 emails per month."`**
- **Citas literales — «Custom Enterprise plans»:** `"If you are sending emails for a large enterprise and have special requirements, we can also provide a custom Enterprise plan."` · `"contact us"` (sin precio ni volumen).
- **Tabla «Plan limits comparison»** (`"Feature | Free plan | Hobby plan | Starter plan | Professional plan"`). La lente de soporte la marcó `[VERBATIM DUDOSO: tabla reconstruida por el modelo; cifras a contrastar con el volcado]` → **CD-22: confirmada fila a fila por el volcado**:
  - `"Emails/month | 500 | 5,000 | From 50,000 | From 50,000"`
  - `"Sending domains | 1 | 1 | 10 | 1,000"`
  - `"API tokens | 1 | 3 | 50 | 1,000"`
  - **`"Daily API requests | 100 | 1,000 | 100,000 | 500,000"`**
  - `"Webhooks | 1 | 5 | 50 | 5,000"`
  - `"Inbound routes | 1 | 1 | 50 | 100,000"`
  - `"SMTP users | 1 | 1 | 50 | 1,000"`
  - `"Templates | 1 | 10 | 250 | 5,000"`
  - `"Sender Identities | - | - | 50 | 5,000"`
  - `"User seats | 1 + 1 accountant | 5 | 5 | 1,000"`
  - `"Email verification credits | 10 | 100 | 100 | 400"`
  - `"Activity retention | 24 hours | 24 hours | 7 days | 30 days"`
  - `"Log retention | - | - | - | 7 days"`
- **Observaciones críticas:**
  1. Precio mensual y anual de los tres planes de pago: $7/$6.30, $35/$31.50, $110/$99 (anual =
     mensual × 0,9, coherente con `"Save 10%"` [F1]). El modelado previo trae 5.60 / 28.00 / 88.00
     = mensual × 0,8, el «20% discount» de 2024 [F47] → contraste, filas 2–4.
  2. Sobrecoste: Hobby $1.50/1.000; Starter y Professional «starting at» $1.30 y **decreciente con
     el tamaño del plan** (F-02 + F-08). Modelado previo 1.20 y 0.95 → contraste, filas 9–10.
  3. **Sin sobrecoste** en Sandbox, Free y Professional trial (`"none of which allow extra usage"`)
     → F-13 literal; el Free **pausa el envío** al agotar la cuota. Free tiene además una **cuota
     diaria de 100 emails** junto a los 500/mes: dos cuotas de volumen para un solo plan.
  4. Es el destino del asterisco de `"Unlimited*"` de [F1]: «ilimitado» son **1.000 dominios,
     1.000 usuarios, 5.000 plantillas, 5.000 webhooks** en Professional (F-11 con cifra, B3).
  5. Única fuente que expresa el tope diario del Free en *emails*; todas las demás dicen *requests*
     → DISC-11. Webhooks Hobby 5 aquí, 1 en [F1] → DISC-05.
  6. Ventana: `"resets every 30 days"` / `"within the 30-day usage period"` frente a `"within your
     billing period"` (Hobby) y `"next billing day"` [F41] → DISC-12.
  7. Tope de gasto configurable (`"you can set a limit to prevent overusage"`, ver [F40]) — v0.3 no
     lo expresa; a fricciones. Retención: B4.

## [F3] Centro de ayuda — Plan add-ons

- **URL:** https://www.mailersend.com/help/plan-add-ons
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch], tres lecturas (pricing, soporte, huecos; la tercera rechazó la
  reproducción íntegra y devolvió la tabla por celdas, idéntica). **[VOLCADO] parcial**
  (17:40 UTC, tanda 3 del orquestador): `www_mailersend_com_help_plan_add_ons.txt` con la
  cabecera, los créditos incluidos, «Domain spaces», «Dedicated IPs» y «Activity data
  retention» (tabla completa); omite Phone numbers y DMARC. Las citas de esas secciones
  quedan confirmadas literales; las de Phone numbers y DMARC siguen como [WebFetch].
- **Título e intro:** `"Plan add-ons"` · `"Each MailerSend plan includes various resources and limits for the use of its features. There is a series of add-ons available that you can purchase in addition to your monthly or annual subscription."` · encabezados `"Email verification credits"`, `"Phone numbers"`, `"Domain spaces"`, `"Dedicated IPs"`, `"DMARC monitoring"`, `"Activity data retention"`.
- **Email verification credits:** `"1 credit allows for the verification of 1 email address. If you have a Hobby plan or above, you can purchase additional credits at the following rates, with a minimum purchase of 1,000 credits"`. Incluidos: Free `"10 credits"` · Hobby `"100 credits"` · Starter `"100 credits"` · Professional `"400 credits"` · Enterprise `"400 credits"`. Escalera por crédito: `"1K - 5K $0.01"` · `"5K - 10K $0.009"` · `"10K - 25K $0.008"` · `"25K - 50K $0.007"` · `"50K - 100K $0.006"` · `"100K - 250K $0.005"` · `"250K - 500K $0.004"` · `"500K - 1M $0.003"` · `"1M - 2M $0.002"` · `"2M + $0.001"`.
- **Phone numbers (SMS):** `"If you are in the U.S. or Canada, you can purchase a phone number to send toll-free text messages to your customers. Phone numbers cost $2/month per number."`
- **Domain spaces:** **`"Starter plans and above can purchase up to 50 additional domains through the Domain spaces add-on. Each additional domain costs $4/month."`** Dominios incluidos: Sandbox `"1"` · Free `"1"` · Hobby `"1"` · Starter `"10"` · Professional `"1,000"` · Enterprise `"5,000"`.
- **Dedicated IPs:** **`"Dedicated IPs are best suited to high-volume senders, sending at least 100,000 emails per week. The dedicated IP add-on is available to Professional (excluding the Professional trial) and Enterprise plans (Enterprise plans also have 1 dedicated IP included) for $50/month per IP."`** (tercera lectura: `"$50/month per IP."` · `"Professional (excluding Professional trial) and Enterprise plans"`; retención: `"Starter, Professional (excluding Professional trial), and Enterprise plans"`)
- **DMARC monitoring:** `"The price of each additional DMARC monitoring slot is $2/month."` · `"available to Starter and Professional plans"` · Starter `"free for 1 domain for 30 days"`, `"up to 10"`; Professional `"up to 10 domains"`, `"up to 20"` con add-on.
- **Activity data retention:** `"Starter, Professional (excluding the Professional trial), and Enterprise plans can extend their activity data retention period up to 365 days with the add-on. Pricing is on a per-month basis and depends on your email volume."` Por defecto: Sandbox `"1 day"` · Free `"1 day"` · Hobby `"1 day"` · Starter `"7 days"` · Professional `"30 days"` · Enterprise `"30 days"`. Tabla (volumen del plan × retención, USD/mes; la lente de soporte la marcó `[VERBATIM DUDOSO: la tabla de precios de retención no se devolvió fila a fila]` → **CD-23: confirmada** por tercera lectura y por [F4]):

  | Plan volume | 30 days | 90 days | 180 days | 365 days |
  |---|---|---|---|---|
  | 50K | `$5` | `$10` | `$12.50` | `$15` |
  | 100K | `$10` | `$20` | `$25` | `$30` |
  | 250K | `$25` | `$50` | `$62.50` | `$75` |
  | 500K | `$50` | `$100` | `$125` | `$150` |
  | 1M | `$100` | `$150` | `$200` | `$250` |
  | 1.5M | `$150` | `$225` | `$300` | `$375` |
  | 2M | `$200` | `$300` | `$400` | `$500` |
  | 2.5M | `$250` | `$375` | `$500` | `$625` |

- **WhatsApp:** sin mención (`"No pricing mentioned for WhatsApp add-on on this page."`); el precio está en [F1].
- **Observaciones críticas:**
  1. La columna «Plan volume» es una **escalera de ocho volúmenes** (50K … 2,5M) para el add-on de
     retención; el selector de [F1] llega a 2M. El precio de retención escala con el volumen
     contratado: **el mismo add-on cuesta distinto según plan × volumen** (F-08 sobre un add-on).
  2. IP dedicada **solo Professional/Enterprise**, $50/mes, umbral 100.000/semana; contradice [F9]
     y [F10] (Starter y superiores, 500.000/mes) y [F1] (Enterprise, sin precio) → DISC-04.
  3. Un plan **Sandbox** aparece como fila propia sin estar en la página de precios: estado de
     cuenta, no tier comercial → F-14. Dominios extra con **tope de 50** y solo desde Starter:
     límite de recursos que a su vez tiene un límite de compra (F-11 con techo).

## [F4] Novedades — Introducing flexible data retention options

- **URL:** https://www.mailersend.com/whats-new/data-retention-add-on
- **Fecha de acceso:** 2026-09-08 (entrada fechada `"December 19th, 2024"`)
- **Origen:** [WebFetch] (dos lentes)
- **Título:** `"Data on your terms: Introducing flexible data retention options"`
- **Citas literales:** `"Starter accounts and above"` · `"available for Starter plans and above"` · `"Starter plans include 7 days of data retention"` · `"Professional and Enterprise plans include 30 days"` · `"7, 30, 90, 180, or 365 days"` · `"choose to retain your activity data for 7, 30, 90, 180, or 365 days"` · `"Don't store content"` · `"Pricing for the add-on is on a per-month basis and depends on your email volume"` · encabezado `"Plan volume | 30 days | 90 days | 180 days | 365 days"` con los mismos ocho volúmenes y precios que [F3] (`"$5.00"` … `"$625.00"`); filas `"50,000 | $5.00 | $10.00 | $12.50 | $15.00"` · `"1,000,000 | $100.00 | $150.00 | $200.00 | $250.00"` `[VERBATIM DUDOSO: cabeceras de la tabla (30/90/180/365 días) reconstruidas]` → CD-23: confirmadas · `"downgrade to a lower data retention period, data from outside of the new limit will be lost"`.
- **Observación:** segunda fuente de la escalera de volúmenes; los precios de retención no han
  cambiado entre 2024-12 y 2026-09. Precio bidimensional (volumen × días) que ningún campo de
  v0.3 recoge (B4 + F-11); la retención es PI-E03 (clase X).

## [F5] Página de feature — SMTP relay

- **URL:** https://www.mailersend.com/features/smtp-relay
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch] (dos lecturas; la segunda: `"does not embed pricing cards"`)
- **Citas literales:** `"Get started for free with 500 emails/month and upgrade for as little as $7 when you need more emails"` · `"Free plan, which includes 500 emails/month"` · `"Hobby plan is available for up to 5,000 emails/month"` · **`"Starter plan is available for up to 500,000 emails/month"`** (relectura: `"the Starter plan is available for up to 500,000 emails/month"`) · **`"Professional plan is available with more features and limits for up to 2,000,000 emails/month"`** (relectura: `"the Professional plan is available with more features and limits for up to 2,000,000 emails/month"`) · **`"Need more than 2,000,000 emails? Talk to us about a custom Enterprise plan"`** · `"Create up to 5 SMTP users for each domain"` · `"MailerSend offers dedicated IPs"`
- **Observación crítica:** topes de volumen por tier que la página de precios no muestra
  como texto: Starter hasta 500.000, Professional hasta 2.000.000, Enterprise por encima.
  Contradice el selector de [F1] (Starter hasta 1M) y [F14] → DISC-06.

## [F6] Centro de ayuda — How to send emails via SMTP with MailerSend

- **URL:** https://www.mailersend.com/help/smtp-relay
- **Fecha de acceso:** 2026-09-08
- **Origen:** [VOLCADO] `www_mailersend_com_help_smtp_relay.txt` (parcial: secciones «SMTP
  limits» y «Daily requests & rate limits»); antes WebFetch (dos lentes).
- **Citas literales:** `"smtp.mailersend.net"` · `"you're connecting to port 587"`
  - **`"The SMTP relay has a limit on the maximum number of concurrent connections. That limit is 5 for Sandbox, Free, Hobby and Starter accounts, and 50 for Professional (including the professional trial) and Enterprise."`** [VOLCADO; CD-27: la lectura de soporte estaba truncada en `"…and 50 for Professional"`; el final literal es `"…and 50 for Professional (including the professional trial) and Enterprise."`]
  - **`"The SMTP relay has a limit on the maximum number of users per domain. That limit is 1 for Sandbox, Free and Hobby, 5 for Starter accounts, and 20 for Professional (including the Professional trial) and Enterprise."`**
  - **`"In total, an account can have up to 1 SMTP user on the Sandbox, Free, or Hobby plan, 50 on Starter, and 1,000 on Professional (including the Professional trial) and Enterprise."`**
  - `"Additionally, the following general rate limits are also in place: SMTP relay requests: Up to 120 requests per minute."` [VOLCADO: `"SMTP relay requests: Up to 120 requests per minute."`]
  - Lectura de tanda 1 (una línea): `"Sandbox & Professional plan trial: 100 requests per day / Free plan: 100 requests per day / Hobby plan: 1,000 requests per day / Starter plan: 100,000 requests per day / Professional plan: 500,000 requests per day / Enterprise plan: 500,000 requests per day"`
  - Sección `"Daily requests & rate limits"` [VOLCADO]: `"Sandbox & Professional plan trial: 100 requests per day"` · `"Free plan: 100 requests per day"` · `"Hobby plan: 1,000 requests per day"` · `"Starter plan: 100,000 requests per day"` · `"Professional plan: 500,000 requests per day"` · `"Enterprise plan: 500,000 requests per day"`
  - `"421 Service not available error"` · `"your sending software is most likely trying to send too many emails through a single connection"`
- **Buscado y no presente:** tamaño máximo de mensaje SMTP, destinatarios por mensaje.
- **Observaciones:** el canal SMTP tiene **concurrencia por plan** (5 / 50 conexiones) y un caudal
  único de 120 peticiones/min; la concurrencia está fuera de v0.3 (como F-15 en SendGrid). Confirma
  que Sandbox y Professional trial comparten los 100 req/día y que la cuota diaria es común a API
  y SMTP. El 120/min coincide con [F20] y no con [F27] → DISC-10.

## [F7] Página de feature — Inbound email routing

- **URL:** https://www.mailersend.com/features/inbound-emails
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** FAQ `"Do emails processed with the inbound route count toward my quota?"` — **`"Any inbound emails forwarded or posted to your endpoint URL are counted against your monthly usage. One forward is equivalent to one sent email."`** · `"get started with a Free plan and 500 emails/month"`
- La página **no dice en qué plan está disponible** inbound routing (respuesta del modelo: «does not specify which paid plans include inbound routing»).
- **Observación crítica:** el correo entrante **consume la cuota de envío** (1 reenvío = 1 email).
  Es la respuesta a la pregunta abierta de SendGrid (F-12).

## [F8] Centro de ayuda — How to set up an Inbound Route

- **URL:** https://www.mailersend.com/help/inbound-route
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `"How to set up an Inbound Route"` · **`"Inbound emails are free to receive but are counted towards your monthly usage when forwarded or posted to your endpoint URL."`**
- Sin plan, sin número de rutas, sin tamaño máximo, sin precio (respuesta del modelo).

## [F9] Página de feature — Dedicated IP for Transactional Emails

- **URL:** https://www.mailersend.com/features/dedicated-ip-email (`/features/dedicated-ip` da 404)
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** **`"Transactional email dedicated IPs are available for Starter and above plans"`** · `"you send 500,000 or more emails per month"` · FAQ `"Who's eligible for a dedicated IP"` — **`"If you have a Starter and above account with at least 1 verified domain and you send around 50,000 emails/day or 500,000 emails/month, you're eligible to request a dedicated IP."`** · FAQ `"How can I get a dedicated IP?"` — `"All Starter and above accounts that meet our eligibility criteria can request a dedicated IP by getting in touch with our customer support team."` · `"We'll also take care of IP warming for you, which will take approximately 1-4 weeks."`
- Sin precio en esta página.
- **Observación:** plan mínimo **Starter** y umbral **500.000/mes**; [F3] dice Professional y
  100.000/semana → DISC-04.

## [F10] Centro de ayuda — How to request a dedicated IP

- **URL:** https://www.mailersend.com/help/how-to-request-dedicated-ip
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `"How to request a dedicated IP"` · `"Dedicated IP addresses are available as an add-on for high-volume senders."` · `"To be eligible for a dedicated IP, your account must meet the following criteria:"` · `"Have at least 1 authenticated domain"` · **`"Send 500,000 or more emails per month."`** · **`"Pricing is $50/month."`** · `"Accounts that are best suited should be sending a minimum of 50,000 emails per day."` · `"For best performance, we suggest one dedicated IP for every 10 million emails per month."` · `"This process can take from 1 to 8 weeks."` · `"get in touch with our customer service team via email or chat"`
- **Observación:** precio coincide con [F3] ($50/mes); umbral (500.000/mes) coincide con [F9] y
  no con [F3] (100.000/semana ≈ 433.000/mes); plan mínimo no se nombra aquí. DISC-04.

## [F11] Página de feature — Email verification tool (bloque de tarjetas de planes DESACTUALIZADO)

- **URL:** https://www.mailersend.com/features/email-verification-tool
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch] (dos lecturas coincidentes: tanda 1 y tanda 2, petición verbatim)
- **Nota de captura:** esta página embebe las mismas tarjetas de planes que /pricing pero con los
  precios de Starter y Professional **en texto estático** (posición 50.000). La tanda 2 demostró
  que el bloque conserva el **descuento anual del 20 %** y un sobrecoste **$0.90** que /pricing ya
  no publica → DISC-03, evidencia de F-09.
- **Citas literales (tarjetas):**
  - Free — `"For occasional email testing and sending"` · `"Get started for free — includes: 500 emails /month · 10 email verification credits · Email threads support · Drag & Drop email builder"` · `"500 emails/month"` · `"10 email verification credits"`
  - Hobby — **`"$5.60 /month"`** · **`"$67.20 billed yearly"`** · `"€5.15 /month"` · `"€61.83 billed yearly"` · `"£4.43 /month"` · `"£53.18 billed yearly"` · `"$7.00 /month €6.44 /month £5.53 /month"` · `"5,000 emails /month"` · `"100 email verification credits"` · `"Extra usage $1.50 €1.50 £1.50 /1,000 emails"`
  - Starter — **`"$28.00 /month"`** · **`"$336.00 billed yearly"`** · `"€25.81 /month"` · `"€309.71 billed yearly"` · `"£21.71 /month"` · `"£260.53 billed yearly"` · `"$35.00 /month €32.26 /month £27.14 /month"` · `"Save 10%"` · `"50,000 emails /month"` · `"100 SMS /month"` · `"100 email verification credits"` · **`"$0.90 €0.90 £0.90 /1,000 emails"`** · **`"$1.40 €1.40 £1.40 /100 SMS"`**
  - Professional — **`"$88.00 /month"`** · **`"$1,056.00 billed yearly"`** · `"€81.12 /month"` · `"€973.39 billed yearly"` · `"£68.23 /month"` · `"£818.79 billed yearly"` · `"$110.00 /month €101.39 /month £85.29 /month"` · `"Save 10%"` · `"50,000 emails /month"` · **`"150 SMS /month"`** (la tanda 1 lo marcó `[VERBATIM DUDOSO]` frente a `"100 SMS /month"` de [F1]; CD-04: 150 es correcto en ambas páginas) · `"400 email verification credits"` · **`"$0.90 €0.90 £0.90 /1,000 emails"`** · `"$1.40 €1.40 £1.40 /100 SMS"`
  - Formas de la lectura de tanda 1 (sin espacio o con espacio distinto): Hobby `"$ 5.60 /month"`; Starter `"€32.26/month"` · `"€309.71"` yearly · `"£27.14/month"` · `"£260.53"` yearly · `"50,000 emails/month"` · `"100 SMS/month"` · `"100 email verification credits"`; Professional `"€101.39/month"` · `"€973.39"` yearly · `"£85.29/month"` · `"£818.79"` yearly · `"150 SMS/month"`.
  - `"Email verification is available for all plans with a number of free credits"`
  - **`"Pricing in Euros and British Pounds is for informational purposes only. All billing invoices will be charged in US dollars."`** (CD-08: confirmada literal **aquí**; ausente en /pricing)
- **Observaciones críticas:**
  - Precios mensuales base coinciden con [F1] ($35 / $110 / $7); los anuales ($28.00 / $88.00 /
    $5.60 = 80 %) y el sobrecoste ($0.90) **no**: /pricing dice $31.50 / $99.00 / $6.30 y $1.30.
    La newsroom [F47] sitúa el $0.90 **antes** de 2024-07-29 (`"$30. Extra emails: $0.90/1,000"`).
    Manda /pricing por Terms 2.2 [F44]. → DISC-03.
  - Para `currency`: `USD` en 🟢 por ser la moneda por defecto de /pricing y de todas las cifras
    del volcado; esta frase va al provenance como apoyo, marcada como procedente de una página
    con precios desactualizados.

## [F12] Página de feature — SMS API *(producto aparte, F-10)*

- **URL:** https://www.mailersend.com/features/sms-api
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `"Our base plan includes 100 SMS messages."` · `"Additional SMS usage on this plan level would be billed as $1.40 per 100 SMS messages."` · `"Depending on your chosen plan, you'll receive a certain number of SMS messages included."` · `"MailerSend's transactional SMS service is currently available in the US and Canada."` · `"All Starter, Professional, and Enterprise accounts come with a complimentary trial phone number for testing purposes."` · `"you can purchase a dedicated phone number as an add-on via the Plan and Billing page"` · `"Toll free numbers will be available for purchase through the app."`
- **Observación:** producto aparte (SMS) con su cuota (100 incluidos) y su sobrecoste ($1.40/100),
  disponible desde Starter. Regla A1 → F-10; no entra en el YAML. Misma redacción en [F48].

## [F13] Página de feature — Webhooks

- **URL:** https://www.mailersend.com/features/webhooks
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch] (dos lecturas; sin tarjetas de planes)
- **Citas literales:** `"Our Free plan includes 500 emails/month to get your started."` · `"You can upgrade for as little as $7/month to the Hobby plan to get 5,000 emails"` · **`"The Starter plan is available for up to 500,000 emails/month, starting at $35/month"`** (relectura: `"The Starter plan is available for up to 500,000 emails/month, starting at $35/month for 50,000 emails"`) · **`"The Professional plan is available for up to 2,000,000 emails/month, starting at $110/month"`** (relectura: `"The Professional plan is available for up to 2,000,000 emails/month, starting at $110/month for 50,000 emails"`) · `"Need more than 2,000,000 emails? Talk to us about a custom Enterprise plan"` · `"Auto-retry failed webhook attempts"` · `"See all POST requests, including retries, sent to your endpoint URL in the past 7 days."`
- La página **no cifra webhooks por plan** (respuesta del modelo).
- **Observación:** confirma [F5] (Starter ≤ 500.000, Professional ≤ 2.000.000) y añade los precios
  de arranque ($35 / $110), coherentes con [F1] y [F2]. DISC-06.

## [F14] Página de comparación — SendGrid alternative *(marketing, sin fecha)*

- **URL:** https://www.mailersend.com/compare/sendgrid-alternative
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Aviso:** página de marketing sin fecha con datos **desactualizados** (`"3,000 emails/month | Free"`, cuando Free es 500 en [F1]). **No es fuente primaria.**
- **Tabla (columna MailerSend):** `"3,000 emails/month | Free"` · `"50,000 | $35"` · `"100,000 | $68"` · `"250,000 | $162.50"` · `"500,000 | $325"` · `"1,000,000 | $1,000"` · `"1,500,000 | $1,350"` · `"2,000,000 | $1,600"` · `"Annual discount available | 20%"`
- **Citas literales:** `"Get started with 3,000 emails/month for free"` · **`"Starter plan is available for up to 1,000,000 emails/month, with additional emails charged at decremental rates starting at $0.95/1,000"`** · `"Professional plan is available for up to 2,000,000 emails/month"` · `"Dedicated IPs are available to high-volume senders with Enterprise accounts"`
- **Observación:** CD-26: con la escalera de [F1], la tabla es una **mezcla de Starter (≤500K) y
  Professional (≥1M)**, no una tercera escalera (en 1M Starter = `"$600.00"`, Professional =
  `"$1,000.00"`). El `"$0.95/1,000"` es el valor de 2024-07-29 [F47]; el «20%» de descuento
  anual también. DISC-01, DISC-02, DISC-06.

## [F15] Página de comparación — Mandrill alternative *(marketing, sin fecha)*

- **URL:** https://www.mailersend.com/compare/mandrill-alternative
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Aviso:** misma naturaleza que [F14]; aquí Free ya es 500 (`"Get started with 500 free emails per month"`), luego es más reciente que [F14].
- **Tabla (columna MailerSend):** `"5,000 emails/month | $7"` · `"50,000 | $35"` · `"100,000 | $68"` · `"250,000 | $163"` · `"500,000 | $325"` · `"1,000,000 | $600"` · `"Annual discount | 10%"`
- **Citas literales:** `"upgrade for as little as $7/month"` · `"Dedicated IPs are available to high-volume senders with Enterprise accounts"`
- **Observación:** coherente con la escalera de Starter de [F1] hasta 1M ($600) y con el 10 %.

## [F16] Página de comparación — Amazon SES alternative *(marketing, sin fecha)*

- **URL:** https://www.mailersend.com/compare/amazonses-alternative
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `"500 free emails per month"` · Starter `"100,000"` emails por `"$68"`/mes · `"when you reach your monthly plan email limit, additional emails are charged on a pay-as-you-go basis, per 1,000 at decremental rates"` · `"$1.50/1,000"` (tarifa de arranque)
- **Observación:** cuarta formulación del sobrecoste: **decreciente con el volumen**, arrancando en
  $1.50/1.000. Coherente con Hobby [F1] y con F-08, pero sin la escalera. DISC-01.

## [F17] What's new — índice de novedades de producto (entradas fechadas)

- **URL:** https://www.mailersend.com/whats-new (y `?page=2`)
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch] (dos lentes)
- **Citas literales (fecha — título):**
  - `"Sep 1, 2026"` — `"Unlock fast, global messaging: WhatsApp API has arrived"` (`/whats-new/whatsapp-api-release`)
  - **`"Aug 24, 2026"` — `"The Hobby plan now includes 10 email templates"`** — extracto: **`"We've increased the number of templates on the Hobby plan from 3 to 10 to make the Hobby plan more usable for low-volume senders that need to send multiple types of transactional emails. If you're subscribed to a Hobby plan, you'll now be able to create and manage up to 10 templates on your account."`** (sin página propia)
  - `"Aug 4, 2026"` — `"New 2048-bit dual CNAME keys for DKIM authentication"`
  - `"Jul 27, 2026"` — `"Payment via PayPal is now available"`
  - `"Jul 21, 2026"` — `"Stronger protection for SMTP credentials"`
  - `"Jun 30, 2026"` — `"Template translations are here: Translate with a click"`
  - `"Mar 9, 2026"` — `"New: Protect domain/IP reputation with Blocklist monitoring"`
  - `"Feb 26, 2026"` — `"MailerSend CLI: Send emails and manage your account from the terminal"`
  - `"Dec 9, 2025"` — `"Get more deliverability insights with DMARC monitoring"`
  - `"Sep 24, 2025"` — `"Deferred status is here, giving you more detailed bounce information"`
  - `"Sep 22, 2025"` — `"Check out the new lighter, faster webhooks"`
  - `"Aug 5, 2025"` — `"Turn your AI tool into your own smart email engine: Introducing the MailerSend MCP"`
  - `"Jul 22, 2025"` — `"A little help for the helpers: Special discount for nonprofit organizations"` (`/whats-new/nonprofit-discount`)
  - Página 2: `"Mar 21, 2025"` — `"Send emails and SMS messages to Airtable lists"` · **`"Dec 19, 2024"` — `"Data on your terms: Introducing flexible data retention options"`** [F4] · `"Sep 24, 2024"` — `"Filter, Find, Fix — say hello to your API and SMTP Logs tab"` · `"Sep 6, 2022"` — `"Introducing transactional SMS: A new way to reach customers"`
- **Observaciones críticas:**
  1. **Ninguna entrada anuncia un cambio de precio, de cuota de emails, de cuota diaria ni de
     rate.** El único cambio de límite fechado es de recursos: plantillas de Hobby 3 → 10 el
     **2026-08-24** (posterior al modelado previo 2026-03-19) → evidencia de F-09.
  2. La URL `/whats-new/new-mailersend-pricing` que devuelve el buscador («MailerSend Pricing
     Update») **ya no existe como entrada**: al abrirla se obtiene el índice.

## [F18] Página de features (índice)

- **URL:** https://www.mailersend.com/features
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales (nombres de feature):** `"Email API"` · `"SMTP relay"` · `"SMS API"` · `"WhatsApp API"` · `"Inbound email routing"` · `"User management"` · `"API logs"` · `"Webhooks"` · `"Suppression list management"` · `"MCP server"` · `"DMARC monitoring"` · `"Blocklist monitoring"` · `"Email verification"` · `"Email validation API"` · `"Email activity"` · `"Drag & drop builder"` · `"HTML builder"` · `"Rich-text email editor"` · `"Dynamic email templates"` · `"Email split testing"`
- Sin planes ni precios (respuesta del modelo).

## [F19] MailerLite — página de precios de MailerSend (canal alternativo)

- **URL:** https://www.mailerlite.com/pricing-mailersend
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `"Get 50% off your first month with the code GOLITE50"` · `"Extra usage: $1.50 € £ /1000 emails"` (Hobby)
- Mismo bloque JS que [F1]: precios de Starter/Professional vacíos. Registrada solo por el cupón
  (canal de distribución alternativo con descuento; matiz para F-13/identificación).

## [F20] Developer docs — General API resources (rate limits, cuota diaria, códigos HTTP, mensajes #MS)

- **URL:** https://developers.mailersend.com/general.html (la navegación enlaza a `https://developers.mailersend.com/general`)
- **Fecha de acceso:** 2026-09-08
- **Origen:** [VOLCADO] `developers_mailersend_com_general.txt` (tanda 2); antes WebFetch.
- **Secciones (h2/h3) literales:** `"General API resources"`, `"Authentication"`, `"API response"` → `"HTTP status codes"`, `"Other error response messages"`, `"Validation errors"`, `"Rate limits"`, `"Example response"`, `"Daily request quota"`, `"Activity status list"`; `"Email resource"`, `"SMS resource"`, `"WhatsApp resource"`.
- **Citas literales — base y autenticación:**
  - `"All API requests should start with the following base part: https://api.mailersend.com/v1/"` (también en [F28])
  - `"Authentication is done by adding an Authorization header containing an API token as a value to your API request."`
  - `"API tokens are generated for sending domains and can have different permissions to limit which areas of your account they may be used to access."`
- **Citas literales — «Rate limits»:**
  - `"MailerSend has a default rate limit of 60 requests per minute on general API endpoints."`
  - `"If you exceed that rate limit, you will receive a 429 error response with a "Too Many Attempts." message."`
  - `"Please wait for the amount of seconds indicated by retry-after and try again."`
  - Lista de rates: `"All API requests (excluding email endpoints): 60 requests/minute"` · `"API requests to POST /v1/email: 120 requests/minute"` · `"API requests to POST /v1/bulk-email: 10 requests/minute"` · `"API requests to GET /v1/activity: 10 requests/minute"` · `"SMTP: 120 requests/minute"`
  - «Example response» (cabeceras del 429 de rate): `"HTTP/2 429"` · `"content-type: application/json"` · `"x-ratelimit-limit: 60"` · `"x-ratelimit-remaining: 0"` · `"retry-after: 59"` · `"x-ratelimit-reset: 1629291024"`
  - Cuerpo del ejemplo: `"Your account reached its rate limit of 120 requests/min. Please wait before trying again. #MS42903"`
- **Citas literales — «Daily request quota»:**
  - `"MailerSend has a daily request quota for API and SMTP relay services."`
  - **`"Every request is counted against the quota and is reset daily at midnight UTC."`**
  - Tabla `"Plan | Quota / day"`: `"Sandbox: 100"` · `"Professional trial (14 days): 100"` `[VERBATIM DUDOSO: en otra lectura salió "Professional trial" sin el paréntesis]` · `"Hobby: 1000"` `[VERBATIM DUDOSO: 1000 vs 1,000]` · `"Starter: 100,000"` · `"Professional: 500,000"` · `"Enterprise: 500,000"` → **CD-14: confirmadas literales en el volcado** (`"Hobby 1000"`, `"Professional trial (14 days) 100"`). **No hay fila Free** en esta tabla (sí en [F31]).
  - `"Two HTTP headers to indicate the quota limit and quota reset time will be returned with every API request."`
  - `"When the quota is hit, MailerSend will return a 429 HTTP error."`
  - Ejemplo de cuota agotada: `"HTTP/2 429"` · `"x-ratelimit-limit: 60"` · `"x-ratelimit-remaining: 59"` · `"retry-after: 59"` · `"x-apiquota-remaining: 0"` · `"x-apiquota-reset: 2022-03-05T00:00:00Z"` · cuerpo `"Your account reached its API daily quota limit. Upgrade to increase it. #MS42901"`
  - Recomendaciones: `"Avoid sending repeated API requests that fail validation (HTTP 422 error)"` · `"To track email activity and status, use webhooks"` · `"If you are sending emails in bulk, use bulk endpoint"` · `"For more throughput, upgrade to a professional plan."`
- **Citas literales — tabla «HTTP status codes»** (`code | name | description`):
  - `"200 | OK | The request was accepted."` · `"201 | Created | Resource was created."` · `"202 | Accepted | The request was accepted and further actions are taken in the background."` · `"204 | No Content | The request was accepted and there is no content to return."`
  - `"401 | Unauthorized | The provided API token is invalid."` · `"403 | Forbidden | The action is denied for that account or a particular API token."` · `"405 | Method Not Allowed | HTTP method is not supported by the requested endpoint."` · `"408 | Request Timeout | There is an error on our system."` · `"421 | Service isn't available, try again later | We are currently running maintenance."`
  - `"422 | Unprocessable Entity | There was a validation error found when processing the request."` · 400: `"Please adjust your request based on the endpoint requirements and try again."` · 422: `"Please adjust it based on the endpoint requirements and try again. Read more"` (CD-16: la tanda 1 atribuía la primera frase a 400/422 sin distinguir)
  - **`"429 | Too Many Requests | There were too many requests made to the API."`**
  - `"500 | Internal Server Error | There was an error on our system."` (502, 503, 504 con la misma descripción)
- **Citas literales — «Other error response messages» (Message / Explanation):**
  - `"The custom API token you're using doesn't have the required permissions. #MS40301"`
  - `"Your account's access to API/SMTP has been switched off. #MS40302"`
  - MS40303 [VOLCADO]: `"Your account is not authorized to perform this action."` / `"but is not authorized to do so"`
  - `"Your account is suspended, you can't do any more requests. #MS40304"`
  - `"Your IP address is not allowlisted. #MS40305"`
  - `"{recipient email} is duplicated in the {$field} recipients list. #MS42201"`
  - **`"Your account reached its email quota limit. Contact support to increase it. #MS42204"`** · Explanation [VOLCADO]: **`"The account has a custom email quota due to compliance concerns and it reached it. Contact customer support to clarify how your business uses MailerSend."`** (CD-15: **no es la cuota mensual del plan**; la observación de la tanda 1 que lo usaba como evidencia de la cuota de volumen se retira)
  - **`"The {$field} recipient limit is exceeded. #MS42205"`** · Explanation [VOLCADO]: **`"The limit of TO, CC or BCC recipients in a single email object has been reached. Approved accounts can include up to 50 TO, 10 CC and 10 BCC recipients. Unapproved acounts can include up to 10 TO, 1 CC and 1 BCC recipients. Get your account approved to send to more recipients or use our bulk email endpoint."`** (sic: `acounts`)
  - **`"The attachments.0.content size exceeds the threshold of 25 MB. #MS42206"`**
  - `"The from.email domain must be verified in your account to send emails. #MS42207"`
  - `"This feature requires a Hobby plan or higher. Upgrade to use it. #MS42216"`
  - `"The send_at timestamp does not match the Unix format. #MS42218"` · `"The send_at must be a date in the future. #MS42219"`
  - **`"Your trial domain reached its email quota limit. #MS42222"`** · Explanation [VOLCADO]: `"The email quota limit for your trial domain was reached."` (sin cifra)
  - **`"You have reached sandbox account unique recipients limit. #MS42225"`** (cifra: 2, en [F37])
  - **`"The number of email objects must not be greater than 500. #MS42229"`**
  - `"The email objects are required. #MS42230"` · `"The bulk request item is invalid. #MS42231"`
  - MS42901 — `"Your account reached its API daily quota limit. Upgrade to increase it. #MS42901"` · Explanation [VOLCADO]: `"The account making the request reached its API daily quota limit. Upgrade to raise your quota."` · `"Every request is counted against the quota and the quota is reset daily at midnight UTC."` · **`"Sandbox and Professional trial accounts have a daily limit of 100 API requests. Hobby plan accounts are limited to 1,000 daily requests. Starter plan accounts can send up to 100,000 daily requests, and Professional or Enterprise plan accounts can send up to 500,000 requests."`**
  - MS42903 — `"Your account reached its rate limit of {$limit} requests/min. Please wait before trying again. #MS42903"` · Explanation [VOLCADO]: **`"The account making the request reached its rate limit. The default rate limit is 120 requests per minute for /email endpoints, 10 requests per minute for /bulk-email endpoints and 60 requests per minute for all other endpoints. Please wait for the amount of seconds indicated by 'retry-after' and try again."`**
- **Observaciones críticas:**
  1. **Dos contadores distintos y ambos con 429:** un *rate* por minuto (`x-ratelimit-*`, `retry-after`) y una **cuota diaria de peticiones** (`x-apiquota-*`, reposición `"midnight UTC"` → `fixed_utc_midnight` literal, 🟢 por D3). El 429 se distingue por el mensaje (`#MS42903` vs `#MS42901`), no por el código.
  2. **La cuota diaria se mide en peticiones, no en emails:** una petición a `/v1/bulk-email` con 500 emails consume **1**. Dos cuotas con unidades distintas sobre el mismo endpoint (candidato a fricción). **[E1] (2026-09-09, dos ejecuciones):** el `"Every request is counted"` **se sostiene** —las 17 peticiones de la primera ejecución (422, 429, 202 y 200 por igual) aparecen descontadas al empezar la segunda (`"remaining": 83`)—, pero el contador que devuelven la cabecera y `/v1/api-quota` **se actualiza con retardo y por lotes** (17 y 14 unidades), no por petición: en la primera ejecución las 18 respuestas llevaban `x-apiquota-remaining: 100` → DISC-17 (resuelta) y O-11 en `fricciones.md`.
  3. El rate del bulk aquí es **un solo valor (10/min)** y la explicación de MS42903 lo llama `"default"`; [F21] y [F31] lo publican **por plan** → DISC-08. La palabra `"default"` justifica D2 (valor por defecto en 🟢 en todos los planes; `Under review` como alias).
  4. `"SMTP: 120 requests/minute"` frente a [F27] → DISC-10.
  5. El ejemplo del 429 de rate es internamente incoherente (`x-ratelimit-limit: 60` y mensaje `"120 requests/min"`): ilustrativo.
  6. Ventana del rate: «per minute» con `x-ratelimit-reset` en marca Unix y `retry-after: 59` s — compatible con ventana fija de un minuto, **pero no lo dice** (ámbar como mucho).
  7. Estados con límites propios: dominio de prueba (`#MS42222`, sin cifra), Sandbox (`#MS42225`), plan mínimo por feature (`#MS42216`), IP allowlist (`#MS40305`), **cuenta no aprobada** (10/1/1). El workload cambia con el **estado** de la cuenta → F-14.
  8. `"Too Many Attempts."` (prosa) frente al cuerpo JSON `#MS42903`: dos formas de 429 documentadas.

## [F21] Developer docs — Email API: «Send an email» (POST /v1/email), «Send bulk emails» (POST /v1/bulk-email) y «Get bulk email status»

- **URL:** https://developers.mailersend.com/api/v1/email.html (secciones «Send an email», «Request parameters», «Supported file types», «Responses», `#send-bulk-emails`; **no existe** `/api/v1/bulk-email.html` → 404)
- **Fecha de acceso:** 2026-09-08
- **Origen:** [VOLCADO] `developers_mailersend_com_api_v1_email.txt`; antes WebFetch.
- **Citas literales — POST /v1/email:**
  - `"POST https://api.mailersend.com/v1/email"`
  - Intro: `"This endpoint allows you to send an asynchronous email. It returns the status of the email sent with an x-message-id that can be used to continuously query for the status using the Email API."`
  - Tabla de parámetros (`campo | tipo | requerido | descripción`):
    - `from` · `object` · `"yes *"` · `"Not required if template_id is present and template has default sender set."`
    - `from.email` · `string` · `"Must be a verified domain or a subdomain from a verified domain."`
    - **`to` · `object[]` · `yes` · `"Min 1, max 50"`**
    - **`cc` · `object[]` · `no` · `"Max 10"`**
    - **`bcc` · `object[]` · `no` · `"Max 10"`**
    - `subject` · `string` · `"yes *"` · `"Max 998"` (caracteres) · `"Not required if template_id is present and template has default subject set."`
    - **`text` · `"Max size of 2 MB"`** · `"Only required if there's no html or template_id present."`
    - **`html` · `"Max size of 2 MB"`** · `"Only required if there's no text or template_id present."`
    - `attachments.*.content` · `string` · `"Base64 encoded content of the attachment."` · **`"Max size of 25MB. After decoding Base64"`**
    - `attachments.*.id` · `"Max 256 characters"` `[VERBATIM DUDOSO]` → CD-13: literal `"Max: 256."`
    - **`tags` · `string[]` · `"Limit is max 5 tags. If the template used already has tags…"`** · `tags.*` `"Max 191 characters each"` `[VERBATIM DUDOSO: la lectura literal solo confirma "Limit is max 5 tags"]` → CD-13: literal `"Max 191 characters"` (fila `tags.*`); confirmado por [F35]
    - `personalization` · `object[]` · `"Allows using personalization in {{var}} syntax. Can be used in the subject, html, text fields…"`
    - `personalization.*.email` · `"Email address that personalization will be applied to. Valid email address as per RFC 2821."`
    - **`send_at` · `"Unix timestamp (integer) or ISO 8601 date string."` · `"min: now, max: now + 72hours"`** · `"Please note that this timestamp is a minimal guarantee…"` (fragmento inicial)
    - `in_reply_to` [VOLCADO]: `"string | no | Max 998 characters. Valid characters: alphanumeric and _ . @ = < > ( ~ ! # $ % ^ & * + ) - [ ] | A Message-ID that this email is replying to. Please note that this feature is available to paid plan accounts only."` (tanda 1: `"Please note that this feature is available to paid…"` `[VERBATIM DUDOSO: otra lectura dijo "Professional+ only"; confirmar el plan exacto]` → CD-12: **«Professional+» errónea**; es `"paid plan accounts only"`)
    - `references` [VOLCADO]: `"string[] | no | List of Message-ID's that the current email is referencing. Read more about creating email threads. Please note that this feature is available to paid plan accounts only."` · `references.*`: `"string | yes | Valid characters: alphanumeric and _ . @ = < > ( ~ ! # $ % ^ & * + ) - [ ]"`
    - `language` [VOLCADO]: `"string | no | Nullable. Must be one of the supported languages: de, en, es, fr, it, lt, nl, pl, pt-BR | … Only applied when template_id is also provided; ignored for raw HTML/text sends."`
    - `headers` · `"Please note that this feature is available to Professional and Enterprise accounts only"`
    - `list_unsubscribe` · `"Please note that this feature is available to Professional and Enterprise accounts only"` · `"Max 990 characters"` `[VERBATIM DUDOSO]` → CD-13: literal [VOLCADO] `"Max 990 characters. Please note that this feature is available to Professional and Enterprise accounts only"`; confirmado por [F35]
    - `settings` · `"Can only contain the keys: track_clicks, track_opens and track_content"`
  - Nota: `"If a scheduled email uses a template that is deleted before sending, the email will not be sent."` `[VERBATIM DUDOSO]` → **CD-11: paráfrasis**; literal [VOLCADO]: `"If a scheduled email is sent with a template, and that template is deleted before the sending is triggered, the scheduled email will not be sent."`
  - «Responses» (rótulos literales): `"Sending queued"` · `"Sending paused"` · `"Validation error"` · `"Validation warning — some suppressed"` · `"Validation warning — all suppressed"`. Cabeceras: `x-message-id`, `x-send-paused`. `"Sending paused"` [VOLCADO] → `"Response Code: 202 Accepted"` con **`"x-send-paused: true"`** y `"Response Body: [EMPTY]"`; la página **no dice qué condición** activa `x-send-paused`. En «all suppressed» **no** hay `x-message-id`. Código de éxito: **202 Accepted**; error de validación: 422.
- **Citas literales — POST /v1/bulk-email:**
  - `"POST https://api.mailersend.com/v1/bulk-email"`
  - `"This endpoint allows you to send multiple asynchronous emails."` · `"It returns the status of the request sent with a bulk_email_id that can be used to continuously query for the status using the Email API."`
  - `"To prevent long waiting periods for a response, each email validation is done after the request and then the result is stored."` · `"If there is any validation error, you can query it using the bulk_email_id provided."`
  - Cuerpo: `"*" | object[] | yes | "Array of email objects."` · `"*.*" | object | yes | "Must be an email object. See email object for detailed options available."`
  - **Tabla «Limitations»** (`Description | Limit`) [VOLCADO]:
    - **`"Total size of the JSON payload | 50MB"`**
    - **`"Number of individual email objects in a single request | 5 for Sandbox accounts. 500 for Professional trial, Hobby, Starter, Professional or Enterprise plan accounts."`**
    - `"Number of recipients per email object. | See Email endpoint."`
    - **`"API requests per minute | 10 for Sandbox and Hobby plan accounts. 15 for Starter plan accounts. 30 for Professional trial and Professional plan accounts. 60 for Enterprise plan accounts."`**
    - `"If not mentioned, the limits are the same as for the generic Email API endpoint."`
  - Respuesta: `202 Accepted` · `{"message": "The bulk email is being processed.", "bulk_email_id": "614470d1588b866d0454f3e2"}`
  - `"GET https://api.mailersend.com/v1/bulk-email/{bulk_email_id}"` · `"Get the bulk email information like validation errors, failed emails and more."`
  - Ejemplo de estado: `"state": "completed"`, `"total_recipients_count": 1`, `"suppressed_recipients_count": 0`, `"validation_errors_count": 0`, `"messages_id"`.
- **Observaciones críticas:**
  1. **Workload de `/v1/email`:** `to` **1–50**, `cc` ≤ 10, `bcc` ≤ 10. Máximo por petición = **70** (50 + 10 + 10) **por inferencia**: ninguna frase dice «total» → tope total en 🟡 (D4). Por estado: **aprobada 70 · sin aprobar 12** (10+1+1, [F20]) · **Enterprise 150** (cc/bcc 50 en [F39]; ninguna fuente sube `to` por encima de 50 → 🟡).
  2. **No hay tabla «Limitations» en el envío simple**: el tamaño total de la petición no se publica para `/v1/email` (solo 2 MB de `text`/`html` y 25 MB por adjunto; número de adjuntos sin acotar). F-06 y `not_found`.
  3. **Consumo compuesto (F-03) en su forma más extrema:** 500 emails × 70 = **35.000 destinatarios en una petición** ([F49] lo cifra literalmente) que, para la **cuota diaria de peticiones** [F20], cuenta **1**.
  4. **El rate del bulk varía por plan** (10/15/30/60) y **el workload por estado de cuenta** (5 Sandbox, 500 resto). Contradice el valor único de [F20] → DISC-08. **Free ausente** en ambas filas ([H9]). Professional trial: 500 aquí, 5 en [F49] → DISC-14.
  5. `"Total size of the JSON payload | 50MB"`: tope de petición publicado solo para el bulk (F-06).
  6. Validación **diferida** (202 no garantiza el envío) — F-04 en potencia; **confirmada por [E1]** (2026-09-09): un lote de 5 objetos con remitente no verificado entra con 202 `"The bulk email is being processed."` mientras `/v1/email` rechaza ese remitente en el acto con 422 `#MS42207`. Envío asíncrono que puede quedar «paused» (`x-send-paused`): estado que la datasheet no expresa.
  7. La superficie del endpoint cambia en **dos escalones** (F-08): `in_reply_to` y `references` desde cualquier plan **de pago** (Hobby+); `headers` y `list_unsubscribe` desde **Professional**. La tarjeta Free de [F1] lista `"Email threads support"` → DISC-16.

## [F22] Developer docs — Tokens API

- **URL:** https://developers.mailersend.com/api/v1/tokens.html
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:**
  - Secciones: `"List tokens"`, `"Show a token"`, `"Create a token"`, `"Update a token"`, `"Change token name"`, `"Delete a token"`
  - `"GET https://api.mailersend.com/v1/token"` · `"POST https://api.mailersend.com/v1/token"` · `"PUT https://api.mailersend.com/v1/token/{token_id}"` · `"DELETE https://api.mailersend.com/v1/token/{token_id}"`
  - `limit` (paginación): `"Min: 10, Max: 100"` · `name`: `"Max: 50"`
  - Scopes: `"email_full", "domains_read", "domains_full", "activity_read", "activity_full", "analytics_read", "analytics_full", "tokens_full", "webhooks_full", "templates_full", "suppressions_read", "suppressions_full", "sms_full", "sms_read", "email_verification_read", "email_verification_full", "inbounds_full", "recipients_read", "recipients_full", "sender_identity_read", "sender_identity_full", "users_read", "users_full", "smtp_users_read", "smtp_users_full", "dmarc_monitoring_read", "dmarc_monitoring_full", "blocklist_monitoring_read", "blocklist_monitoring_full", "whatsapp_full"`
  - «Create a token» (relectura de la verificación, 2026-09-08, [WebFetch]): parámetros `name` (`string`, yes, `"Max: 50"`), `domain_id` (`string`, no), `scopes` (`array`, yes); **ningún parámetro de expiración** (`expires_at`, `expires`) ni frase con «expire» en la sección.
- **Observación:** **no publica máximo de tokens** por cuenta o dominio, ni caducidad, ni restricción por plan (cifras en [F2]). B3 → `features.md`/F-11. Que el token observado en el panel tenga `"Expires at"` [F53] sin que la API ofrezca fijarla deja abierto si la caducidad la impone el proveedor al crear desde el panel o la eligió el titular: no se cuenta en F-14.

## [F23] Developer docs — Domains API

- **URL:** https://developers.mailersend.com/api/v1/domains.html
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:**
  - `"GET https://api.mailersend.com/v1/domains"` · `"POST https://api.mailersend.com/v1/domains"` · `"DELETE https://api.mailersend.com/v1/domains/{domain_id}"` · `"GET https://api.mailersend.com/v1/domains/{domain_id}/verify"` · `"GET https://api.mailersend.com/v1/domains/{domain_id}/dns-records"`
  - Paginación: `"Min: 10, Max: 100 | Default: 25"`
  - `name`: `"Must be unique and lowercase. Domain must be available and resolvable."` · `return_path_subdomain` / `custom_tracking_subdomain` / `inbound_routing_subdomain`: `"Must be alphanumeric."`
  - Nota DKIM: `"DKIM is now two CNAME records"` · `"Support for the legacy record ends on 1 February 2027"`
- **Observación:** **no publica máximo de dominios por plan** ni límites del dominio de prueba. El único vínculo con la capacidad está en [F21] (`from.email` verificado) y en `#MS42207`/`#MS42222` de [F20].

## [F24] Developer docs — Webhooks API

- **URL:** https://developers.mailersend.com/api/v1/webhooks.html (relectura tanda 2 en `https://developers.mailersend.com/api/v1/webhooks`)
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch] (dos lecturas)
- **Citas literales:**
  - `"GET https://api.mailersend.com/v1/webhooks"` · `"POST https://api.mailersend.com/v1/webhooks/"` · `"PUT https://api.mailersend.com/v1/webhooks/{webhook_id}"` · `"DELETE https://api.mailersend.com/v1/webhooks/{webhook_id}"`
  - `url`: `"Max: 191"` · `name`: `"Max: 50"` · `limit`: `"Min: 10, Max: 100"` (default 25) · `version`: `"1, 2"`
  - `"The endpoint must return a 2xx response for the webhook to be saved successfully."`
  - `"If your endpoint is unreachable or returns a non-2xx response, MailerSend automatically retries with exponential backoff for up to about 3 days."` `[VERBATIM DUDOSO]` → CD-17: segunda lectura devuelve la misma frase; literal probable, sin volcado
  - Timeout: `"doesn't respond within 3 seconds"` `[VERBATIM DUDOSO: fragmento]` → CD-17: `"if the endpoint doesn't respond within 3 seconds, it will show up as a failed attempt in the log"` · `"Some failures are considered unrecoverable and aren't retried. Examples include 4xx client errors (other than 429) and DNS resolution failures."`
  - Eventos: `activity.sent, activity.delivered, activity.soft_bounced, activity.hard_bounced, activity.deferred, activity.opened, activity.opened_unique, activity.clicked, activity.clicked_unique, activity.unsubscribed, activity.spam_complaint, activity.survey_opened, activity.survey_submitted, sender_identity.verified, maintenance.start, maintenance.end, inbound_forward.failed, inbound_message.rejected, email_single.verified, email_list.verified, bulk_email.completed, recipient.on_hold_added, recipient.on_hold_removed`
- **Observación:** **no publica máximo de webhooks por plan** (cifras en [F1][F2]). Evento `bulk_email.completed`, alternativa al polling de [F21]. B3.

## [F25] Developer docs — Templates API

- **URL:** https://developers.mailersend.com/api/v1/templates.html (relectura tanda 2 en `https://developers.mailersend.com/api/v1/email/templates`)
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch] (dos lecturas)
- **Citas literales:**
  - `"GET https://api.mailersend.com/v1/templates"` · `"POST https://api.mailersend.com/v1/templates"` · `"PUT https://api.mailersend.com/v1/templates/{template_id}"` · `"DELETE https://api.mailersend.com/v1/templates/{template_id}"`
  - `limit`: `"Min: 10, Max: 100"`, `"Default: 25"` · nombre `"Max: 50"` · tags `"Max: 5"` items, `191` chars `[VERBATIM DUDOSO]`
  - **`"Only templates created via API (origin=api) can be updated — templates created in the MailerSend app return 404"`**
    → **CD-18 cerrada el 2026-09-14**: tercera lectura idéntica y ahora **con volcado**
    (`evidencias/paginas/2026-09-14/developers_mailersend_com_api_v1_email_templates.txt`), así que la
    marca `[VERBATIM DUDOSO]` se retira. **Esta frase es la que decide `type`** (C2, D-031): crear
    plantillas es programático (`POST /v1/templates`), pero **editar una creada en el panel no lo es**,
    y esa es la operación 2 del test, eliminatoria → `partial_saas`. La frase estaba recogida aquí desde
    el 2026-09-08 y **nadie la había conectado con el campo `type`**, que se juzgaba con C1, es decir
    mirando solo el envío.
- **Observación:** **sin máximo de plantillas** por cuenta ni por plan (cifras en [F1][F2][F17]). B3.

## [F26] Developer docs — Inbound routing API

- **URL:** https://developers.mailersend.com/api/v1/inbound.html
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:**
  - `"GET https://api.mailersend.com/v1/inbound"` · `"POST https://api.mailersend.com/v1/inbound"` · `"PUT https://api.mailersend.com/v1/inbound/{inbound_id}"` · `"DELETE https://api.mailersend.com/v1/inbound/{inbound_id}"`
  - `limit`: `"Min: 10, Max: 100"`, `"Default: 10"` · forwards: `"Min 1 and max 5"` · catch filters `"Max 5"` · match filters `"Max 5"` · `name` `"Max 191 characters"` · priority `"Min 0 and Max 100"`
- **Observación:** **sin máximo de rutas inbound** por plan ni tamaño de mensaje entrante; **no dice si el correo entrante consume cuota** (lo dicen [F7][F8]: sí, 1 reenvío = 1 email).

## [F27] Developer docs — SMTP relay

- **URL:** https://developers.mailersend.com/smtp-relay.html
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales (sección «Limitations», en orden):**
  - `"We only support TLS security via 587 port and do not have plans to support older/unsecure protocols for SMTP"`
  - `"FROM email domain must be verified"` · `"A subject is required"`
  - `"All custom headers, apart from the ones mentioned in Additional features, will be dropped"`
  - `"Additional features like advanced personalization or templates are only supported via our Email API"`
  - `"We only support attachments of the file types as defined in Email API"`
  - **`"There are Rate limits applied to SMTP relay based on IP address and these tend to be lower than available through our API"`**
  - **`"SMTP Relay has a single connection transaction limit set at 5."`**
  - `"To send bulk emails use our Bulk Email API"`
  - **`"Daily request quota applies to each individual message sent through our SMTP relay service."`**
  - `"We do not support desktop email clients such as Apple Mail, Outlook, Thunderbird and similar applications."`
  - Tags por SMTP: `"X-MailerSend-Tags"` · `"You can send a maximum of 5 tags"`
  - Error de ejemplo: `"450 The given data was invalid. You must provide one of html, text or template_id."`
- **Observaciones críticas:**
  1. **Rate SMTP sin valor** (`"based on IP address"`, `"tend to be lower"`) frente a `"SMTP: 120 requests/minute"` de [F20][F6][F39] → DISC-10. Y es **por IP**, no por cuenta: segmentación que v0.3 no expresa.
  2. **5 transacciones por conexión SMTP**: concurrencia/sesión, fuera de v0.3 (como F-15 en SendGrid). Conexiones concurrentes por plan en [F6].
  3. **CRF distinto por canal para la misma cuota diaria:** por API cuenta la petición (1 por bulk de 500), por SMTP cuenta **cada mensaje**. Candidato a fricción nueva o a F-15.
  4. No se publica tamaño máximo de mensaje SMTP ni destinatarios por mensaje SMTP.

## [F28] Developer docs — portada (base URL, enlace a la OpenAPI)

- **URL:** https://developers.mailersend.com/
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `"All API requests should start with the following base part: https://api.mailersend.com/v1/"` · enlace `"MailerSend OpenAPI collection"` → https://app.swaggerhub.com/apis/MailerSend/mailersend-api/1.0.0-oas3.1
- **Observación:** no menciona rate limits ni cuota. (`base_uri` no es campo de v0.3, regla B2.)

## [F29] Developer docs — página de SDKs

- **URL:** https://developers.mailersend.com/sdk.html
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `"Sending emails with MailerSend SDKs"`; repos `mailersend-nodejs`, `mailersend-php`, `mailersend-python`, `mailersend-go`, `mailersend-ruby`, `mailersend-java` (github.com/mailersend/…)
- **Observación:** no menciona rate limits ni cuota.

## [F30] Especificación OpenAPI — SwaggerHub `MailerSend/mailersend-api/1.0.0-oas3.1`

- **URL:** https://api.swaggerhub.com/apis/MailerSend/mailersend-api/1.0.0-oas3.1 (JSON; visor https://app.swaggerhub.com/apis/MailerSend/mailersend-api/1.0.0-oas3.1)
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch-JSON] (dos lecturas independientes coincidentes con fragmentos JSON crudos); **no hay fichero descargado**: `curl` → `CONNECT tunnel failed, response 403` (proxy). CD-19: afirmaciones negativas confirmadas por lectura, sin volcado → 🟡.
- **Fragmentos literales:**
  - `"info.title": "MailerSend API"` · `"info.version": "1.0.0-oas3.1"` · `"servers[].url": "{protocol}://{host}/v1"`
  - `servers`: `[{"url":"{protocol}://{host}/v1","description":"MailerSend API Server","variables":{"protocol":{"description":"The protocol for the API request.","default":"https","enum":["https"]},"host":{"description":"The host for the MailerSend API.","default":"api.mailersend.com"}}}]`
  - `SendEmailRequest`: `{"type":"object","properties":{"from":{"$ref":"#/components/schemas/EmailFrom"},"to":{"type":"array","items":{"$ref":"#/components/schemas/EmailTo"}},"subject":{"type":"string","examples":["Hello Client"]},"text":{"type":"string","examples":["This is just a friendly hello from your friends."]},"html":{"type":"string","examples":["<h1>Hello, this is the HTML body</h1>"]}},"required":["from","to","subject","text"]}`
  - `EmailTo`: `{"type":"object","properties":{"email":{"type":"string","format":"email","examples":["your@client.com"]},"name":{"type":"string","examples":["Client Name"]}},"required":["email"]}`
  - `"maxItems"`: `"Does not appear anywhere in the document."` · `"429"`: `"Does not appear anywhere in the document."` · propiedades `cc`, `bcc`, `attachments`, `send_at`, `tags`: `No`; `personalization`: solo en `SendSmsRequest`.
  - Respuestas declaradas para `POST /email`: **`200`** (`"Email sent successfully"`).
  - Paths (61 rutas; selección): `/email`, `/bulk-email`, `/bulk-email/{bulk_email_id}`, `/activity/{domain_id}`, `/activities/{activity_id}`, `/analytics/date`, `/messages`, `/message-schedules`, `/domains`, `/domains/{domain_id}/smtp-users`, `/domains/{domain_id}/smtp-users/{smtp_user_id}`, `/token`, `/webhooks`, `/templates`, `/inbound`, `/email-verification`, **`/api-quota`**, `/users`, `/sms…`
- **Lo que NO declara:** `SendEmailRequest.to` **sin `maxItems`**; `cc`, `bcc`, `attachments`, `tags`, `personalization`, `send_at` **ausentes**; `SendBulkEmailRequest` = array de `SendEmailRequest` **sin `maxItems`**; **ningún** `429`, `x-ratelimit`, `retry-after` ni `quota`, salvo el endpoint `GET /api-quota`.
- **Observaciones críticas:** la OpenAPI **está por detrás de la prosa** (como en SendGrid): los topes 50/10/10/500 solo existen en prosa y en los mensajes de error. Declara `200` para POST /email y `text` obligatorio, contra [F21] (`202 Accepted`; `text` opcional) → DISC-15. Si el orquestador descarga el JSON con el navegador, `grep -c maxItems` y `grep -c '"429"'` cierran esto en 🟢.

## [F31] Centro de ayuda — «Rate limits: How to Reduce 403, 422, & 429 Errors»

- **URL:** https://www.mailersend.com/help/rate-limits-how-to-reduce-403-422-429-errors
- **Fecha de acceso:** 2026-09-08
- **Origen:** [VOLCADO] `www_mailersend_com_help_rate_limits_how_to_reduce_403_422_429_errors.txt` (17:32 UTC); antes WebFetch (lentes docs y soporte, citas coincidentes).
- **Citas literales — tabla «Daily Quotas Limits»** (`Plan | Quota / day`): `"Trial | 100"` · `"Free | 100"` · `"Hobby | 1,000"` · `"Starter | 100,000"` · `"Professional | 500,000"` · `"Enterprise | 500,000"`
  - `"MailerSend has a daily request quota for API and SMTP relay services, which varies depending on your subscription plan."`
  - `"Every request made counts against your daily quota, which is reset daily at midnight UTC."`
- **Citas literales — tabla «Rate Limits»** (`Endpoint | Healthy reputation | Under review reputation`) [VOLCADO]:
  - `"All API requests (excluding v1/email) | 60 requests per minute | 60 requests per minute"`
  - **`"API requests to v1/email | 120 requests per minute* | 10 requests per minute"`**
  - **`"API requests to v1/bulk | Free plan: 10 API calls/min Hobby plan: 10 API calls/min Starter plan: 15 API calls/min Professional plan: 30 API calls/min Enterprise plan: 60 API calls/min | 1 request per minute"`**
  - Forma con separadores del volcado: `"API requests to v1/bulk | Free plan: 10 API calls/min · Hobby plan: 10 API calls/min · Starter plan: 15 API calls/min · Professional plan: 30 API calls/min · Enterprise plan: 60 API calls/min | 1 request per minute"`; filas de cuota diaria `"Trial 100"` y `"Free 100"`.
  - Nota del asterisco: **`"*Newly upgraded accounts may have a lower rate limit until they've been established as a sender with good sending practices."`**
  - `"For each MailerSend plan level, there are rate limits specified for different types of requests:"`
  - `"Please wait for the amount of seconds indicated by the retry-after response header and try again."`
- **Citas literales — «429 - Too many requests»:** `"Either your account is sending more API or SMTP requests per day than our daily quota limits allow"` · `"Or your account is sending more API or SMTP requests per minute than our rate limits allow"` · `"When you hit your daily quota or a rate limit, you will start receiving 429 HTTP error."` · `"Two HTTP headers will be returned with every API request to indicate the quota limit and when the quota will be reset."`
- **Citas literales — 403 / 422:** `"If your MailerSend account is suspended, under review, or otherwise restricted, API calls may result in 403 errors."` · `"This error means a validation error was found when processing your request."` (sin cifras)
- **Observaciones críticas:**
  1. **Rates por estado de la cuenta** («Healthy» / «Under review»): `/v1/email` cae de 120 a **10/min**, bulk a **1/min**. D2: el valor único va en 🟢 a todos los planes; «under review» y «newly upgraded» (sin cifra) → `not_found` + fricción (alias de estado).
  2. Nombres de plan **distintos** de [F20]/[F21]: aquí «Trial» y «Free», allí «Sandbox» y «Professional trial». Mismo valor (100) → DISC-09 (nomenclatura). Aquí sí hay fila **Free**; [F20] no.
  3. **Única fuente** que publica los rates «under review» y confirma el bulk por plan de [F21] → DISC-08.

## [F32] Developer docs — «Checking your API quota» (GET /v1/api-quota)

- **URL:** https://developers.mailersend.com/api/v1/other-endpoints.html (`/api/v1/api-quota.html` → 404)
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** título `"Checking your API quota | MailerSend Developers"` · `"GET https://api.mailersend.com/v1/api-quota"` · `"Inspect how many MailerSend API requests you have remaining and when the limit resets."` · **`"Requests to this endpoint do not count toward your quota."`** · ejemplo `{"quota": 1000, "remaining": 752, "reset": "2023-04-15T00:00:00Z"}`
- **Observación:** endpoint de **autoobservación de la cuota diaria** (CRF 0 declarado). Hace viable el escalón 2/3 sin gastar: leer `quota` en la cuenta propia cierra el valor del plan real y resolvería DISC-11. El ejemplo (`1000`, reset a las 00:00Z) es coherente con Hobby y con `midnight UTC`.

## [F33] Developer docs — Activity API (GET /v1/activity/{domain_id})

- **URL:** https://developers.mailersend.com/api/v1/activity.html
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:**
  - `"GET https://api.mailersend.com/v1/activity/{domain_id}"` · `"GET https://api.mailersend.com/v1/activities/{activity_id}"`
  - `date_to`: `"Timestamp is assumed to be UTC. Must be higher than date_from. The allowed timeframe depends on your plan's data retention limit (1–30 days)."`
  - `page`: `"Min: 1, Max: 1000"` · `"To reach older activity beyond the last page, narrow date_from and date_to"`
  - `limit`: `"Min: 10, Max: 100"`, `"Default: 25"`
  - `"deferred and suppressed are available on the Starter plan and above."`
- **Observación:** RPR (F-05): 100 por página, **1.000 páginas** máximo, ventana acotada por la **retención del plan (1–30 días)** — B4 + F-05 + F-08. El rate de 10/min de [F20] **no aparece** aquí.

## [F34] Developer docs — SMTP users API

- **URL:** https://developers.mailersend.com/api/v1/smtp-users.html
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `GET /v1/domains/{domain_id}/smtp-users` (y POST/PUT/DELETE) · paginación `"Min: 10, Max: 100"`, `"Default: 25"` · `name` `"Max 50 characters"` · contraseña `"is stored as a hash and cannot be retrieved again afterwards"`
- **Observación:** **sin máximo de usuarios SMTP por dominio** ni por plan (cifras en [F6][F2]).

## [F35] SDK oficial PHP — `mailersend/mailersend-php` (validación en cliente y 429)

- **URL:** https://raw.githubusercontent.com/mailersend/mailersend-php/master/src/Helpers/GeneralHelpers.php · https://raw.githubusercontent.com/mailersend/mailersend-php/master/src/Endpoints/BulkEmail.php · https://raw.githubusercontent.com/mailersend/mailersend-php/master/src/Endpoints/ApiQuota.php · https://raw.githubusercontent.com/mailersend/mailersend-php/master/src/Exceptions/MailerSendRateLimitException.php (un repositorio, cuatro ficheros)
- **Fecha de acceso:** 2026-09-08 (descarga en crudo, sin modelo intermedio: literal con certeza)
- **Citas literales (código):**
  - `Assertion::maxCount($params->getRecipients(), 50, 'Recipients list should not contain more than 50 items.')`
  - `Assertion::maxLength($params->getSubject(), 998, 'Subject may not be greater than 998 characters.')`
  - `Assertion::maxCount($params->getTags(), 5, 'Tags list should not contain more than 5 items.')` · `Assertion::maxLength($tag, 191, 'Each tag may not be greater than 191 characters.')`
  - `Assertion::lessOrEqualThan($params->getSendAt(), $now + 259200, 'Send at may not be more than 72 hours in the future.')`
  - `Assertion::maxLength($params->getInReplyToHeader(), 998, …)` · `Assertion::maxLength($params->getListUnsubscribe(), 990, …)`
  - `Assertion::maxCount($params->getCc(), 10)` · `Assertion::maxCount($params->getBcc(), 10)`
  - Bulk: `Assertion::minCount($bulkParams, 1, 'Bulk params should contain at least 1 email')` — **sin `maxCount`**
  - `class MailerSendRateLimitException extends MailerSendHttpException` (expone `getHeaders()`)
  - `protected string $endpoint = 'api-quota';`
- **Observación:** el SDK **replica en cliente** 50/10/10, 5 tags × 191, 998, 990 y 72 h — confirma los literales de [F21] marcados dudosos. **No** replica el 500 del bulk ni el 25 MB del adjunto. Sin reintento automático en PHP.

## [F36] SDK oficial Python — `mailersend/mailersend-python` README (reintentos y cabeceras)

- **URL:** https://raw.githubusercontent.com/mailersend/mailersend-python/main/README.md
- **Fecha de acceso:** 2026-09-08 (descarga en crudo: literal)
- **Citas literales:**
  - `"The client automatically retries transient errors (429, 500, 502, 503, 504) with exponential backoff. For 429 responses the Retry-After header is respected if present."`
  - `"- **RateLimitExceeded**: API rate limit exceeded (429)"`
  - `rate_limit = response.headers.x_rate_limit_remaining` · `retry_after = response.headers.get("retry-after", "0")` · `retry_delay = response.retry_after  # Seconds to wait before retry`
  - `| API Quota | GET api-quota | ✅ |`
- **Observación:** el SDK oficial documenta el **contrato del 429**: `Retry-After` en segundos y backoff exponencial. Ningún SDK publica valores de límite.

## [F37] Centro de ayuda — «Sandbox mode and the Professional trial»

- **URL:** https://www.mailersend.com/help/sandbox-mode-and-the-professional-trial
- **Fecha de acceso:** 2026-09-08
- **Origen:** [VOLCADO] `www_mailersend_com_help_sandbox_mode_and_the_professional_trial.txt` (17:30 UTC); antes WebFetch.
- **Citas literales — introducción:** `"When you sign up, we'll offer you a choice: start your free 14-day Professional trial by adding a payment method, giving you full access to send to real recipients and Professional features, or skip this and try Sandbox mode instead."`
- **Citas literales — «Sandbox mode»:**
  - `"Sandbox mode is where you land if you skip the 14-day Professional trial. It's built for testing, not production sending."`
  - **`"100 emails a month, with a cap of 100 API requests a day"`**
  - `"A trial domain you can use right away, or your own domain once verified"`
  - `"1 domain (plus the trial domain), 1 API token, 1 webhook, 1 SMTP user and 1 template"` · `"Bulk emailing included"` · `"1 day of activity data retention"`
  - **`"You can send to any 2 recipients in Sandbox mode, until your account is approved, after which your 100 monthly emails can go to any recipient."`**
  - `"Get approved. Submit your account for approval from your dashboard, no payment method needed, and the recipient limit lifts."`
  - `"Start your 14-day Professional trial. Click Start 14-day trial in the banner at the top of your dashboard (payment method verification only, no charge)."`
  - `"Subscribe directly. Click the Upgrade now button to choose a plan."`
- **Citas literales — «The Professional trial»:**
  - `"you can start your 14-day Professional trial by adding a payment method and clicking Start free trial on the pop-up you'll see at signup or login."`
  - **`"We only use your payment method to verify it. You won't be charged during the trial, and if you don't upgrade before your 14 days are up, your account moves to the Free plan."`**
  - Incluye: `"Unlimited sending domains"` · `"Unlimited API tokens and SMTP users (20 users/domain)"` · `"Unlimited webhooks and sender identities"` · `"Inbound routing"` · `"Unlimited dynamic email templates"` · `"Custom header support"` · `"API logs retention"` · `"Email activity data retention (30 days)"` · `"Email and live chat support"`
  - Limitaciones: **`"500 emails a month and 100 API requests a day"`** · `"1 user seat (Professional includes unlimited seats)"` · `"1 day of API log retention (Professional includes 7 days)"` · `"Add-ons and logo removal aren't included"`
  - `"You'll see a countdown in the sidebar showing how many days are left on your trial."`
- **Citas literales — «What happens when the trial ends?»:**
  - **`"If you haven't chosen a plan by the time your 14 days are up, your account moves to the Free plan."`**
  - `"If any of your resources, domains, API tokens, SMTP users and more, exceed the limits of your new plan, we'll ask you to choose which ones to keep active. Domains you don't select are paused rather than removed"`
  - **`"Each customer can activate one Professional trial. Creating a new account won't unlock a second one."`**
- **Observaciones críticas:**
  1. **Tres estados de cuenta previos a un plan**, ninguno en la página de precios: **Sandbox** (100 emails/mes, 100 req/día, 2 destinatarios hasta la aprobación), **Professional trial** (14 días, 500 emails/mes, 100 req/día) y **Free** (500/mes tras aprobación [F2]). El trial **caduca** pero no deja la cuenta a cero: cae a Free → variante de F-14 (SendGrid caía a «end of trial»). DISC-13.
  2. **Cuota de destinatarios únicos por estado de aprobación:** `"any 2 recipients"` en Sandbox: es la cifra del `#MS42225` [F20]. Dimensión distinta del workload por petición; ningún campo de v0.3 la recoge.
  3. Sandbox 100 emails/mes y Free 500 con la misma cuota diaria de peticiones (100): dos «gratuitos» con dos volúmenes.

## [F38] Centro de ayuda — «Getting started with MailerSend»

- **URL:** https://www.mailersend.com/help/getting-started
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch] (dos lecturas)
- **Citas literales:** `"start your free 14-day Professional trial by adding a payment method"` · `"we only use your payment method to verify it, and you won't be charged"` · `"skip this and try Sandbox mode instead"` · `"If you're still in Sandbox mode and want to try before you commit, click Start 14-day trial"` · `"you can send your first email right away using your trial domain"` · `"Either way, you can send your first email right away using your trial domain."` · `"The account approval process is a crucial step for accessing all MailerSend features"` (relectura: `"The account approval process is a crucial step for accessing all MailerSend features."`) · `"To submit your account for approval, just click Get approved from the banner"` (relectura: `"To submit your account for approval, just click Get approved from the banner in the dashboard."`) · **`"The approval process is usually very quick but can take up to 48 hours"`** (relectura: `"The approval process is usually very quick but can take up to 48 hours."`) · `"We'll then offer you a choice: start your free 14-day Professional trial by adding a payment method, giving you full access to send to real recipients and Professional features, or skip this and try Sandbox mode instead."`
- **Buscado y no presente:** «500 emails», «100 requests», «daily limit», «unique recipients», «Free plan»; respuesta del modelo: `"The document does not contain specific information about sender limits for unapproved accounts"`.
- **Observación:** la **aprobación de cuenta** es una puerta previa a la capacidad (hasta 48 h) que v0.3 no expresa; **criterios de aprobación no publicados** ([H14]). Límites de cuenta no aprobada reunidos: 12 destinatarios por objeto (10+1+1, [F20]), 2 destinatarios únicos en Sandbox [F37], 100 emails/mes [F37][F39], 100 peticiones/día.

## [F39] Centro de ayuda — «How to Start Sending Emails With MailerSend»

- **URL:** https://www.mailersend.com/help/how-to-start-sending-emails
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch] (tres lecturas: soporte, huecos ×2). **[VOLCADO] parcial** (17:44 UTC,
  tanda 3): `www_mailersend_com_help_how_to_start_sending_emails.txt` con «Sending to multiple
  recipients», «How to add CC and BCC recipients» (tabla, cabeceras `"Free, Hobby, Starter,
  Professional accounts"` / `"Enterprise accounts"` y nota `"Limitations refer to approved
  accounts…"` confirmadas literales), la frase del adjunto (`"less than 25MB"`) y la entrada 422
  `"Email quota reached"`. La tabla de rate limits de esta página **no** está en el volcado
  (sigue como [WebFetch]).
- **Citas literales — destinatarios (sección `"How to add CC and BCC recipients"`):**
  - Tabla, cabeceras `"JSON parameter | Type | Required | Free, Hobby, Starter, Professional accounts | Enterprise accounts"`; filas **`"cc | object [ ] | No | Max 10 | Max 50"`** · **`"bcc | object [ ] | No | Max 10 | Max 50"`** (la lente de soporte la marcó `[VERBATIM DUDOSO: cabeceras de columna reconstruidas por el modelo]` → **CD-20: cabeceras confirmadas** por segunda lectura)
  - **`"Limitations refer to approved accounts. If your account is not approved yet, you may only include one CC and BCC recipient."`** · `"Get approved to unlock more features!"` (relectura, seguidas: `"Limitations refer to approved accounts. If your account is not approved yet, you may only include one CC and BCC recipient. Get approved to unlock more features!"`)
  - `"specifying multiple 'to' recipients in the same request will cause one email to be sent with all recipients visible to each other."`
  - `"The attachment file must be less than 25MB in size."`
  - `"When testing MailerSend for the first time, you can send transactional emails using the trial domain or any verified domain you have added on your account."`
  - No aparece el máximo del campo `to` (está en [F21]: 50; sin aprobar 10 en [F20]).
- **Citas literales — rate limits:** fragmentos de la tanda 1: `"Rate limits restrict the number of requests a user can make per"` `"minute. They exist to protect shared servers from being abused by"` `"spammers—protecting the sender's reputation of all that server's"` `"users."` · `"MailerSend has a default rate limit on all endpoints. If you exceed"` `"that rate limit, you will receive a 429 error response with a "Too"` `"Many Attempts." message. See all rate limits here."` → CD-21, releídos enteros: `"MailerSend has a default rate limit on all endpoints. If you exceed that rate limit, you will receive a 429 error response with a 'Too Many Attempts.' message."` · tabla: `"All API requests (excluding v1/email) | 60 requests per minute"` · `"API requests to v1/email | 120 requests to v1/email per minute"` · `"API requests to v1/bulk-email | 10 requests to v1/bulk-email per minute"` · `"SMTP | 120 requests/minute"` (tanda 1: `"All API requests (excluding v1/email): 60 requests per minute"` · `"API requests to v1/email: 120 requests to v1/email per minute"` · `"API requests to v1/bulk-email: 10 requests to v1/bulk-email per"` `"minute"` · `"SMTP: 120 requests/minute"`)
- **Citas literales — lista `"422 - unprocessable entity"`:** entrada **`"Email quota reached"`** — `"The account's quota has been reached. Make sure your account has been approved so you can send more than 100 emails per month."`
- **Observaciones críticas:**
  1. **`cc`/`bcc` cambian con el plan (Enterprise: 50) y con el estado de aprobación (1 + 1 sin aprobar).** Workload por petición: aprobada 70, sin aprobar **12** (10+1+1 con [F20]; la inferencia «52» de la tanda 1 era errónea, CD-20), Enterprise 150. Alias de estado sobre el *workload*, no solo sobre el rate.
  2. Repite el bulk a **10/min sin desglose por plan**, como [F20], contra [F31] y [F21] → DISC-08.
  3. La cuota de cuenta **no aprobada** es 100 emails/mes (coincide con Sandbox [F37]); el 422 `"Email quota reached"` es candidato a respuesta de rechazo por cuota ([H4]).

## [F40] Centro de ayuda — «How to set a billing limit on your account»

- **URL:** https://www.mailersend.com/help/how-to-set-a-billing-limit
- **Fecha de acceso:** 2026-09-08
- **Origen:** [VOLCADO] `www_mailersend_com_help_how_to_set_a_billing_limit.txt` (17:38 UTC); antes WebFetch.
- **Citas literales:**
  - `"set a limit on how many additional emails or SMSes you authorize your account to send"`
  - **`"If you reach the billing limit, your transactional messages will stop sending until your next billing period begins and your limits are reset."`** [VOLCADO] (tanda 1: `"If you reach the billing limit, your transactional messages will stop sending"` · `"until your next billing period begins and your limits are reset"`)
  - `"Free plans include up to 500 emails per month"` · `"Hobby plans include up to 5,000 emails per month"` · `"Starter and Professional plans include 50,000 emails or more each month"`
  - `"emails will continue to be sent at a metered rate per 1,000 additional emails"`
  - **`"For Hobby plans, the price is $1.50 per 1,000 emails"`** · **`"for Starter and Professional plans, the price starts at $1.30 per 1,000"`**
- **Buscado y no presente:** «trial», «30 days», «paused», «quota».
- **Observación:** el **sobrecoste tiene tope configurable por el cliente** (no por el proveedor, a diferencia del 10× de SendGrid, F-16). Segunda fuente de $1.50 y $1.30. Reposición descrita como `"next billing period"` → DISC-12.

## [F41] Centro de ayuda — «How to change or cancel your plan»

- **URL:** https://www.mailersend.com/help/how-to-change-or-cancel-your-plan
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch] (dos lecturas)
- **Citas literales:**
  - Secciones: `"Change your plan type or size"` · `"Setting billing limits for your account"` · `"Switching to a monthly or yearly subscription"` · `"How to cancel your plan"`
  - `"Choose the Monthly or Yearly tab and click Upgrade"`
  - **`"That's it! Your plan is now active and ready to use. Your monthly email quota will reset on your next billing day."`** (tanda 1, troceada: `"That's it! Your plan is now active and ready to use. Your monthly"` `"email quota will reset on your next billing day."`)
  - **`"Yearly plans are billed upon subscription and the subscription stays active until the end of the billing period. Keep in mind, any overcharges will be billed at the end of each month."`**
  - `"If you upgrade before your current plan has expired, the time remaining on your current plan will be automatically deducted from the cost of your upgrade."`
  - `"If you no longer require the use of your MailerSend plan, you can"` `"cancel your subscription in 3 simple steps."`
  - `"When you cancel, we'll ask if you'd like the Free plan instead."` (relectura, seguidas: `"When you cancel, we'll ask if you'd like the Free plan instead. Your account switches over at the end of your current billing period, either to the Free plan or to Sandbox mode, depending on what you chose."`)
  - **`"Your account switches over at the end of your current billing period, either to the Free plan or to Sandbox mode, depending on what you chose."`** (tanda 1, troceada: `"Your account switches over at the end of your current billing"` `"period, either to the Free plan or to Sandbox mode, depending on"` `"what you chose."`)
- **Buscado y no presente:** «prorated», «immediately», «extra emails», «final charge», «30 days».
- **Observación:** `"reset on your next billing day"` es la cita más cercana a `fixed_billing_cycle`; enfrentada a `"resets every 30 days"` [F1][F2] → DISC-12. En el plan **anual** el periodo de pago es un año pero los sobrecostes se facturan `"at the end of each month"` y la cuota es `"monthly"` → `fixed_billing_cycle` mensual en 🟡 (D3). La baja lleva a **Free o a Sandbox**, a elección.

## [F42] Centro de ayuda — «Account reputation statuses»

- **URL:** https://www.mailersend.com/help/account-reputation-statuses
- **Fecha de acceso:** 2026-09-08
- **Origen:** [VOLCADO] `www_mailersend_com_help_account_reputation_statuses.txt` (17:34 UTC); antes WebFetch.
- **Citas literales:**
  - `"Healthy"` — `"Your account is in good standing with no current deliverability issues."`
  - `"Under review"` — **`"Your account has triggered certain thresholds indicative of potential deliverability problems, such as increased error rates (e.g., 403, 422, 429 responses)"`**
  - `"Rebuilding"` — `"Following a review that identified issues affecting your sender reputation, your account has entered the process of restoring to a healthy status."`
  - `"Sending paused"` — `"Activities from your account have been temporarily halted due to significant concerns regarding sending practices or reputation."`
  - `"you will receive notifications to your account's registered email address when your reputation status changes from Healthy to Under Review or Sending Paused"`
- **Buscado y no presente:** ninguna cifra (umbrales ni rates por estado; los rates están solo en [F31]).
- **Observación:** **cuatro estados**, no dos: el modelado previo solo tiene `healthy` y `under_review`. `Rebuilding` y `Sending paused` sin rate publicado. El disparador de «Under review» incluye **los propios 429**: agotar el rate degrada el rate (bucle). «Sending paused» es un estado de reputación, distinto de la pausa por cuota agotada [F2] y de la pausa por *billing limit* [F40] ([H4]).

## [F43] Centro de ayuda — «How to access and use MailerSend API & SMTP logs»

- **URL:** https://www.mailersend.com/help/api-smtp-logs
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `"API and SMTP logs are available to Professional and Enterprise plan accounts, as well as Professional trial accounts"` · **`"For Professional plans, log retention is 7 days, for Enterprise, 14 days, and for Professional trial accounts, 1 day"`** · `"Hobby or Starter account, you can still access Template error logs"` · `"Before using the Logs feature, you'll need to enable it for your account"`
- **Observación:** retención de *logs* (peticiones API/SMTP) distinta de la de *actividad* [F2]; solo Professional+. B4 → provenance/`features.md`.

## [F44] Legal — «Terms of Use»

- **URL:** https://www.mailersend.com/legal/terms-of-use (`/legal/terms-of-service` → 404)
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch] (dos lecturas; CD-24: confirmadas). **[VOLCADO] parcial** (17:46 UTC,
  tanda 3): `www_mailersend_com_legal_terms_of_use.txt`, solo la cabecera con **`"Last updated
  on August 31, 2026"`** confirmada literal; el orquestador anotó que el texto completo (29.028
  caracteres) no contiene «quota», «rate limit», «per day», «per minute» ni «fair use». Las
  cláusulas 2.1, 2.2, 13.1 y 15.1.2 siguen como [WebFetch].
- **Citas literales:**
  - **`"Last updated on August 31, 2026"`**
  - **2.1** — `"Payment is not made until the provision of Service. The payment period is one month for a monthly plan or one year for a yearly plan and can be settled by a credit card or via PayPal. In the event that you exceed your Services limit, you must pay for the exceeding part additionally."`
  - **2.2** — `"The rates for Services and additional services provided by us are listed at www.mailersend.com/pricing. We may modify or change our fees and pricing at any time and, at our sole discretion, run in-app beta pricing experiments that offer different rates to some users."`
  - 2.5 — `"you will also be directly billed by Meta Platforms, Inc."` (WhatsApp)
  - 6.6 — `"Every marketing email you send using MailerSend must include a single-click, clear and visible unsubscribe link"`
  - **13.1** — `"MailerSend may suspend the Services without liability if: (i) MailerSend reasonably believes that the Services are being used in violation of the Terms; (ii) you do not cooperate with our reasonable investigation of any suspected violation of the Terms; (iii) there is an attack on the Services or your Services are accessed or manipulated by a third party without your consent, (iv) MailerSend is required by law or by a regulatory or government body to suspend the Services, or (v) there is another event for which MailerSend reasonably believes that the suspension of the Services is necessary to protect the MailerSend network or our other customers."`
  - 15.1.2 — `"We do not refund any unused or partially used plans (monthly or yearly) when you did not use or partially used the Services"` (la lectura de tanda 1 estaba truncada en `"…(monthly or yearly)"`)
- **Buscado y no presente:** «trial», «free», «sandbox», «inactive», «quota», «rate limit» (`"No sentences containing these terms appear"`).
- **Observaciones críticas:**
  1. **`"in-app beta pricing experiments that offer different rates to some users"`**: el proveedor se reserva por contrato **precios distintos por usuario**. Evidencia directa de F-09 y de F-13/F-08.
  2. Términos **posteriores al modelado previo** (2026-08-31 > 2026-03-19).
  3. 2.2 fija /pricing como lista de precios oficial → criterio para DISC-03 (manda /pricing). Ciclo de pago literal: `"one month for a monthly plan or one year for a yearly plan"` → DISC-12.

## [F45] Legal — «API Use Policy: Guidelines and Best Practices»

- **URL:** https://www.mailersend.com/legal/api-use-policy
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:**
  - `"Last updated"`: **`"September 02, 2024"`**
  - Sección 4 «Abuse» (fragmentos consecutivos): **`"We have API limits in place by the endpoint (rate limits) and for our"` `"whole API (daily quota). Hitting one of these limits is considered an"` `"excessively frequent request to MailerSend. If this occurs, we will tell"` `"you the problems with how you are interfacing with our API. However, if"` `"the abuse is too big to handle, we have the right to temporarily or"` `"permanently suspend your account with or without notice immediately."`**
  - Sección 9 — `"We may terminate your access to our API at any time for any reason"`
  - Sección 11 — `"MailerSend reserves the right to change this API Use Policy at any time"` · `"All changes are effective immediately upon posting"`
- **Buscado y no presente:** «bulk», «marketing», «transactional», «automated», cifras.
- **Observación:** la política **convierte el 429 en infracción**: alcanzar el rate o la cuota diaria `"is considered an excessively frequent request"` y puede acabar en suspensión. Enlaza con [F42]. Sin cifras.

## [F46] Centro de ayuda — «About MailerSend's refund and account policies»

- **URL:** https://www.mailersend.com/help/about-mailersends-refund-and-account-policies
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `"Refunds are generally not issued except in instances where MailerSend terminates the service"` · `"Violations of our Anti-Spam Policy, API Use Policy, or any Terms of Use do not entitle a user to a refund."` · `"MailerSend retains the right to suspend or terminate accounts in the following circumstances"` · `"High bounce rates, significant spam complaints, or excessive unsubscribe rates."` · `"MailerSend reserves the right to suspend or terminate access to our API for any abuse or misuse"`
- **Observación:** sin cifras de umbral (bounce, quejas). Complementa [F42] y [F45].

## [F47] Newsroom — «New MailerSend pricing: Introducing more flexible, scalable plans»

- **URL:** https://www.mailersend.com/newsroom/price-and-plans-changes
- **Fecha de acceso:** 2026-09-08 (entrada fechada **`"June 28th, 2024"`**)
- **Origen:** [WebFetch] (dos lecturas; CD-25: tabla confirmada fila a fila)
- **Citas literales:**
  - `"The new pricing and plans will come into effect on Monday, July 29th."`
  - **`"Introducing the Hobby plan (formerly Free/Starter), the Starter plan (formerly Premium), the Professional plan (new), and remaining the same, the Enterprise plan."`**
  - Tabla «Premium plan limits» (`Feature | Limit before changes | Limit as of 29th July`): `"Domains | 50 | 10"` · `"Data retention | 14 days | 7 days"` · `"Users | 20 | 5"` · `"API tokens | 100 | 50"` · `"Sender identities | 250 | 50"`
  - **`"The free plan (Hobby) will remain with up to 3,000 emails per month free of charge but with the ability to add up to 5 users instead of the current 1."`**
  - Professional: `"1,000 domains"` · `"500,000 requests per day"` · `"30 days data retention"` · `"Unlimited API tokens, webhooks, sender identities, inbound routes, and SMTP users"` · `"Pricing for the Professional plan will be released shortly so stay tuned."`
  - Tabla «Premium (Starter) plan monthly pricing» (`Number of emails | Price before changes | Price as of 29th July`): **`"50,000 | $30. Extra emails: $0.90/1,000 | $35 Extra emails: $0.95/1,000"`** · `"100,000 | $60 Extra emails: $0.80/1,000 | $68 Extra emails: $0.90/1,000"` · `"250,000 | $150 Extra emails: $0.70/1,000 | $163 Extra emails: $0.90/1,000"` · `"500,000 | $300 Extra emails: $0.60/1,000 | $325 Extra emails: $0.80/1,000"` · `"750,000 | $450 | Discontinued"` · `"1,000,000 | $580 Extra emails: $0.45/1,000 | $600 Extra emails: $0.70/1,000"`
  - **`"Current Premium plan users have the opportunity to lock in their pricing for the next year by subscribing to a yearly subscription. This will also give you a 20% discount overall."`**
  - `"Existing Premium plan customers will be migrated to a Starter plan at the beginning of the new billing cycle after July 29th, 2024."`
  - `"Even if you exceed the new limits, you'll retain access"` (cláusula de abuelo)
- **Observaciones críticas:**
  1. **Único anuncio fechado de cambio de planes y precios.** Fija 2024-07-29 (renombrado y subida) y el **descuento anual del 20 %** vigente entonces; hoy es 10 % [F1][F2] y el cambio no tiene anuncio localizado.
  2. En julio de 2024 el gratuito era **Hobby con 3.000 emails/mes**; hoy Hobby es de pago ($7) con 5.000 y existe un Free de 500. Sin anuncio localizado; el modelado previo (2026-03-19) ya recoge Free 500 / Hobby 5.000, así que el cambio ocurrió **entre 2024-07-29 y 2026-03-19** (el panel [F53] conserva un modal con la fecha `"December 2"`).
  3. Sobrecoste de Starter 50K: $0.90 → **$0.95** (2024-07-29) → **$1.30** hoy [F1][F2][F40]: tres valores para el mismo plan, F-09 con tres fechas. Los precios base de la tabla ($35 / $68 / $163 / $325 / $600) coinciden con la escalera de Starter de [F1] hoy: subió el sobrecoste, no la tarifa.
  4. Cláusula de abuelo: dos clientes en el mismo plan pueden tener límites distintos (F-08/F-13).

## [F48] Producto SMS — «SMS API Service» *(F-10, fuera del YAML por A1)*

- **URL:** https://www.mailersend.com/sms-api
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `"Our base plan includes 100 SMS messages."` · **`"Additional SMS usage on this plan level would be billed as $1.40 per 100 SMS messages."`** · `"MailerSend's transactional SMS service is currently available in the US and Canada."` · `"All Starter, Professional, and Enterprise accounts come with a complimentary trial phone number for testing purposes."`
- **Observación:** el SMS es un **segundo producto con su propia unidad y su propio sobrecoste** bajo la misma cuenta y la misma cuota diaria de peticiones → F-10. SMS incluidos por peldaño en [F1] (Starter `"100 SMS /month"` … `"7,000"`; Professional `"150"` … `"15,000"`); número `"$2.00"` [F1][F3]. El modelado previo lo metió en el YAML (`consumption_units: sms`, `quota_100_sms_month`, `quota_150_sms_month`, `v1/sms`); por A1 aquí **no entra**. Sobrecoste de SMS en Professional (150/mes) **no publicado**.

## [F49] Centro de ayuda — «Schedule bulk emails with the bulk endpoint»

- **URL:** https://www.mailersend.com/help/schedule-bulk-emails-with-the-bulk-endpoint
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch] (dos lecturas coincidentes)
- **Citas literales:** **`"Note: If you're on a Hobby, Starter or Professional plan, you can include 500 individual email objects in a single request, each containing up to 50 TO recipients, 10 CC, and 10 BCC, for a total of 35,000 emails. Otherwise, you are limited to 5 individual email objects."`**
- **Observaciones críticas:**
  1. 500 × (50 + 10 + 10) = 35.000 → la página llama «emails» a los **destinatarios** (to + cc + bcc), no a los objetos ni a las peticiones. Es la única frase oficial que relaciona destinatarios con «emails» contados: para el CRF de la cuota mensual la lectura más defendible es **1 unidad por destinatario** (mín. 1, máx. 70 aprobado / 12 sin aprobar / 150 Enterprise) → 🟡 hasta el escalón 2/3 ([H2]). F-03.
  2. «Otherwise» (5 objetos) abarca Free, Sandbox **y trial**; [F21] da 500 al Professional trial → DISC-14. Tercera fuente del 50/10/10.
  3. Free nunca nombrado junto a bulk ([H9]): `not_found` + escalón 3 barato (`POST /v1/bulk-email` desde Sandbox, 1 objeto).

## [F50] Centro de ayuda — «Navigating the dashboard»

- **URL:** https://www.mailersend.com/help/navigating-the-dashboard
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `"At the bottom of the main navigation, you'll find your accounts usage indicator."` · `"Number of emails sent during your billing period"` · `"Number of SMS sent during your billing period"` · `"Number of daily requests"` · `"Remaining email verification credits"` · `"Summary of your plan including plan name, billing period and next payment date"`
- **Observación:** el contador de uso se define sobre el `"billing period"` (no «30 días»); coincide con los rótulos del panel [F53] (`"Emails sent 0"`, `"Daily requests 100"`). Sin definición de cómo se cuentan los emails.

## [F51] Centro de ayuda — «How to create a template»

- **URL:** https://www.mailersend.com/help/how-to-create-a-template
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `"When you save a newly created template or click Manage on an existing template, you'll be taken to the Template details page."` · **`"This is where you can configure the options for your template, get the API instructions, send a test email, and create a split test."`**
- **Observación (C1, `type`):** el único envío desde el panel es una **prueba de plantilla**, que la API también hace (`template_id` en POST /v1/email). Lectura conservadora: `api_first` en 🟡 con nota; la alternativa (`partial_saas`) se plantea al autor ([H11]). Si el «test email» consume cuota: no dicho.

## [F52] Centro de ayuda — «How to test email sending in MailerSend»

- **URL:** https://www.mailersend.com/help/how-to-test-email-sending-in-mailersend
- **Fecha de acceso:** 2026-09-08
- **Origen:** [WebFetch]
- **Citas literales:** `"Blackhole email recipients are specialized email addresses that help you test your email sending without actually delivering the message to a real inbox."`
- **Observación:** trata solo de direcciones *blackhole*; `"no contiene información sobre enviar un email de prueba desde la aplicación/panel"` (respuesta del modelo).

## [F54] Developer docs — Recipients API (y **las supresiones, que no tienen página propia**)

- **URL:** https://developers.mailersend.com/api/v1/email/recipients
- **Fecha de acceso:** 2026-09-14
- **Origen:** [VOLCADO] `evidencias/paginas/2026-09-14/developers_mailersend_com_api_v1_email_recipients.txt`
- **Citas literales:**
  - `"GET https://api.mailersend.com/v1/recipients"` · `"GET https://api.mailersend.com/v1/recipients/{recipient_id}"` · `"DELETE https://api.mailersend.com/v1/recipients/{recipient_id}"`
  - Supresiones, cinco listas: `"GET https://api.mailersend.com/v1/suppressions/blocklist"`, `"…/hard-bounces"`, `"…/spam-complaints"`, `"…/unsubscribes"`, `"…/on-hold-list"`; alta con `"POST https://api.mailersend.com/v1/suppressions/blocklist"` y las tres siguientes; baja con `DELETE` en las cinco
- **Observación:** **las supresiones no se documentan en una página propia**, van dentro de la de
  Recipients, y el índice lateral no las nombra. Eso es lo que hizo fallar con 404 los tres intentos
  del 2026-09-14 (`/api/v1/email/suppressions`, `/api/v1/suppressions`, `/api/v1/suppressions.html`)
  y dejó la operación 7 del test C2 sin comprobar en la primera pasada. Con esta lectura, **las ocho
  operaciones del test quedan comprobadas** y el `type` de MailerSend pasa de 🟡 a 🟢 por D9, sin
  dejar de ser `partial_saas`: el color mide la cobertura del test, no el valor.

## [F53] Panel de cuenta — observación con cuenta propia (escalón 2)

- **Fecha de acceso:** 2026-09-08, 16:35–17:40 UTC
- **Cuenta:** organización «Universidad de Sevilla», usuario «Daniel» (correo redactado), rol Administrator; estado `Sandbox` en la cabecera de la app y `Trial` en el selector de cuentas (/accounts); ninguna suscripción activa; sin dominio propio; zona horaria de la cuenta «UTC (+00:00)». Modo lectura: no se creó, borró, reveló ni contrató nada; no se pulsó «Try Professional for free» ni «Add my domain».
- **Evidencia:** `evidencias/panel_dashboard_sandbox_2026-09-08_redactado.jpg` (correo tapado en el DOM antes de la captura); resto de pantallas leídas por texto. Registro completo en `_recoleccion/panel_observacion.md`. **Las citas de `/api-tokens` y `/domains` no tienen captura ni volcado propio: su única evidencia es ese registro del agente** (anotado por la verificación del 2026-09-08; ninguna sostiene un semáforo del YAML).
- **Citas literales (Dashboard):** `"You're in sandbox mode with strict limits and limited features."` · botones `"Upgrade now"` · `"Try Professional for free"` · `"Your test domain is ready! Use it to try out MailerSend’s API and SMTP features."` · `"Choose a plan to get started — Start free with 500 emails a month, or pick a plan that fits your needs."` · contadores `"Emails sent 0"`, `"SMS sent 0"`, `"Daily requests 100"` (barra `width: 0%`; el rótulo enlaza a https://developers.mailersend.com/general.html#daily-request-quota), `"Email verification 0"`, enlace `"Plan and billing"`.
- **Citas literales (Plan and billing / Upgrade):** `/billing` (y `?open=0`, `?open=1`) **redirige al dashboard**; el botón «Upgrade» abre el modal **`"Add your domain to upgrade — To get started, first add your own domain. Once approved, you’ll be able to upgrade and access more features. Add my domain"`**. Modales presentes en el DOM pero ocultos (plantillas de la app, no mensajes activos; indicio de F-09): `"Your free plan is changing soon From December 2, we're introducing a fee of $7/month for the Hobby plan, with 5,000 emails. You can keep using MailerSend for free to send up to 500 emails/month. Please review your plan by December 2. Accounts with no action taken will be downgraded to the Free plan automatically."` · `"Your Professional trial ends tomorrow After that, you'll move to the Free plan. Upgrade to keep your Professional features."`
- **Citas literales (Domains):** un solo dominio `test-86org8e1dvzgew13.mlsender.net` · `"Test domain"` · `"Domain is verified and ready to use"` · `"API token — API tokens authenticate requests made when sending emails and on server-specific endpoints."` · `"You don't have any API tokens"` (a nivel de dominio) · `"SMTP — Use your SMTP credentials to send emails"` · `"You don't have any SMTP users"` · `"Inbound routing … Create an inbound route"` seguido del botón **`"Upgrade plan"`** · `"Webhooks … Add webhook"` (disponible) · `"Pause domain — Pause your domain sendings, all future emails will be queued for 7 days maximum, after which they will be erased from our servers and won’t be sent."` · **`"Test domains are automatically deleted if not in use for 30 days."`**
- **Citas literales (API tokens):** `"API tokens authenticate email, SMS, and server-specific requests."` · token `Testing`, `"Full access ・ 8 Sep 2026"`, Domain `All`, `"Last used on: Never"`, `"Expires at: 30 Sep 2026"`, Status `Active`.
- **Citas literales (Settings / Logs / Webhooks / ayuda):** `"Enable API Logging — SMTP and API logs will appear on logs page. Available on Professional and Enterprise plans."` · `"Manage account users, assign roles or create custom ones."` · `"SMTP & API logging is a Professional feature — Upgrade your plan to start monitoring all SMTP and API activities."` (botón `"Upgrade plan"`) · secciones «Email webhooks» (`"Add webhook"`), «SMS webhooks», «Whatsapp webhooks» · `"Live chat support 14 days left"`.
- **Qué revela el panel que la documentación no dice:**
  1. «Sandbox» (app) y «Trial» (selector de cuentas) conviven para la misma cuenta: dos etiquetas para un mismo escalón sin suscripción.
  2. **La escalera de precios interna, la sección Usage y «Set billing limit» están detrás de un muro: dominio propio aprobado.** En Sandbox no se puede observar la página de billing (como los tiers superiores de Postmark). La escalera visible es la de la página pública [F1].
  3. `"Daily requests 100"` con 0 consumidas: coincide con el dato documental «Sandbox 100» [F20].
  4. Inbound routing y API logs bloqueados por plan desde dentro (F-08). `"Upgrade plan"` en inbound aunque [F2] lista `"inbound routing"` entre las features de Free.
  5. El token de API muestra fecha de caducidad (`"Expires at: 30 Sep 2026"`, creado el 8 Sep 2026). No se comprobó si es obligatoria: la API de creación no tiene parámetro de expiración [F22] y el token lo creó el titular. Es un recurso con ciclo de vida (F-11), no una caducidad del plan: **no se cuenta en F-14** (corrección de la verificación, 2026-09-08). El token se usó por primera vez en el sondeo [E1] del 2026-09-09.
- **Lo que el panel NO enseña:** el caudal vigente ni registros de 429; la fecha literal de reposición de la cuota mensual (sin sección Usage visible); los topes de webhooks, usuarios, dominios o plantillas del plan actual (no hay «x / y»); si el límite es por cuenta o por token.

## [E1] Sondeo empírico — límites con cuenta Sandbox no aprobada (escalón 3)

- **Fecha:** 2026-09-09, **dos ejecuciones del mismo script**: tanda 1 de 19:02:18 a 19:02:56 UTC
  (38 segundos, 18 casos; el caso final `A_api_quota_final` no llegó a ejecutarse) y tanda 1b de
  19:13:40 a 19:14:21 UTC (41 segundos, 19 casos, esta vez con `A_api_quota_final`). **Ejecutado
  por:** el autor, en su máquina, con el token `Testing` de la cuenta propia [F53] (estado Sandbox,
  **no aprobada**, sin dominio propio; solo el dominio de prueba `test-…mlsender.net`). Comando:
  `bash 05_salida/_herramientas/probe_mailersend_sandbox.sh` (casos A B C R T, `sleep 2` entre
  peticiones; la clave en `~/.config/tfm/.env`, nunca por el chat). Una tercera ejecución,
  **tanda 2**, se hizo el 2026-09-10 de 11:24:08 a 11:26:36 UTC (2 min 28 s, 13 casos) con un
  script distinto y complementario, `probe_mailersend_sandbox_t2.sh` (casos A2 B2 C2 T2,
  `sleep 7` entre peticiones para no agotar el caudal de 10/min); mismo ejecutor, misma cuenta y
  mismo token.
- **Evidencia:** `evidencias/probe_sandbox_limites_2026-09-09.json` (tanda 1, 18 casos) y
  `evidencias/probe_sandbox_limites_2026-09-09_tanda1b.json` (tanda 1b, 19 casos); en cada caso,
  código HTTP, cuerpo y cabeceras `date`, `x-ratelimit-*`, `x-apiquota-*`; sin clave ni datos
  personales; el cuerpo de `GET /v1/domains` trae solo el dominio de prueba. Volcado aplanado de
  las dos tandas, una tras otra, en `evidencias/paginas/2026-09-09/api_mailersend_com_v1.txt`. De
  la tanda 2, `evidencias/probe_sandbox_limites_t2_2026-09-10.json` (13 casos), mismo diseño sin
  clave ni direcciones de correo reales; volcado aplanado en
  `evidencias/paginas/2026-09-10/api_mailersend_com_v1.txt`.
- **Reproducción:** la tanda 1b **repite exactamente los veredictos** de la tanda 1 en los casos
  B, C, R y T (mismos códigos, mismos mensajes `#MS42205` / `#MS42207` / `#MS42225` / `#MS42903`,
  mismo 429 a 10/min en la undécima petición a `/v1/email` y a 1/min en el segundo lote; segundo
  lote de 5 objetos aceptado con 202 y `bulk_email_id` `6aa1affd1e3217ac0dd87aa1`; de nuevo
  `x-ratelimit-remaining` de 9 a 0 en los diez 422; de nuevo las cinco respuestas 429 sin
  `retry-after` ni `x-ratelimit-*`). La tabla de abajo no se duplica: donde un caso se cita, valen
  las dos tandas. **Lo único que cambia entre las dos es el contador de la cuota diaria** (caso A),
  y es lo que resuelve DISC-17.
- **Diseño a coste cero:** cada `POST` lleva `from` de un dominio no verificado
  (`probe@dominio-no-verificado.invalid`), así que la validación responde `422 #MS42207` y nada se
  envía; como el 422 informa todos los campos que fallan, el par N / N+1 del campo sondeado revela
  el tope. Contador de emails del panel: no consultado después (nada podía salir).
- **Resultado literal, caso a caso:**
  - **A_api_quota (tanda 1, 19:02:18)** `GET /v1/api-quota` → 200 `{"quota": 100, "remaining":
    100, "reset": "2026-09-10T00:00:00Z"}`; cabeceras `x-apiquota-remaining: 100`,
    `x-apiquota-reset: 2026-09-10T00:00:00Z`. **Las 18 respuestas** de la tanda 1 llevan esas dos
    cabeceras con los mismos valores: el contador **no bajó** con ninguna de las 17 peticiones
    siguientes (diez 422, cinco 429, un 202, un 200) en 38 segundos.
  - **A_api_quota (tanda 1b, 19:13:41)** → 200 `{"quota": 100, "remaining": 83, "reset":
    "2026-09-10T00:00:00Z"}`, `x-apiquota-remaining: 83`: **17 peticiones descontadas** entre las
    dos ejecuciones, es decir, las de la tanda 1 que devolvieron respuesta HTTP —422, 429, 202 y
    200 **por igual**. La tanda 1 tuvo 18 casos, así que uno quedó por descontar o se descontó más
    tarde; por número coincide con el propio `GET /v1/api-quota`, que [F32] excluye (`"Requests to
    this endpoint do not count toward your quota."`), aunque el sondeo no lo demuestra por sí solo.
    Después, `x-apiquota-remaining: 83` **se mantiene durante 14 peticiones** (B_to_10 …
    T_tags_5, 19:13:43–19:14:12) y **salta a 69 en T_tags_6** (19:14:14): 83 − 14 = 69, las
    catorce anteriores descontadas de golpe, incluidas dos 429 y el 202 del lote.
    **A_api_quota_final** (19:14:21) → `{"quota": 100, "remaining": 69, ...}`: las tres últimas
    peticiones (T_tags_6, T_subject_998, T_subject_999) aún sin descontar al cerrar el script.
    → **DISC-17 resuelta**: `"Every request is counted against the quota"` se sostiene (se
    cuentan también las rechazadas con 422 y 429 y el 202 del lote), pero **el contador que
    devuelven la cabecera y `/v1/api-quota` se actualiza con retardo y por lotes** (de 17 y 14
    unidades en lo observado), no por petición.
  - **B_to_10, B_to_11, B_to_50, B_to_51** `POST /v1/email` → 422, `errors.to`: `"The to
    recipient limit is exceeded. #MS42205"` (más `#MS42207` en `from.email`). **`to = 10` ya
    falla**: el tope de `to` sin aprobar es **menor que 10**, contra el `"up to 10 TO"` de
    [F20]; no acotado (una dirección en `to` pasa, ver B_cc_1). → DISC-18.
  - **B_cc_1** (`to` 1 + `cc` 1) → 422 con **solo** `from.email` `#MS42207`: los destinatarios
    pasan. **B_cc_2** (`to` 1 + `cc` 2) → 422, `errors.cc`: `"The cc recipient limit is
    exceeded. #MS42205"` y `errors.to`: `"You have reached sandbox account unique recipients
    limit. #MS42225"`. **Tope `cc` = 1 sin aprobar: literal de [F20] y [F39] confirmado.**
    B_cc_10 y B_cc_11: mismo par de errores.
  - **B_bcc_10, B_bcc_11** (`to` 1 + `bcc` 10 / 11) → 422, `errors.bcc`: `"The bcc recipient
    limit is exceeded. #MS42205"` y `errors.to` `#MS42225`. Tope `bcc` **≤ 9**, no acotado (la
    documentación dice 1; no se probó 1/2).
  - **Destinatarios únicos:** `#MS42225` aparece en el campo `to` en cuanto `to + cc` o
    `to + bcc` suman **3 o más** direcciones distintas (B_cc_2: 1 + 2; B_bcc_10: 1 + 10), y no
    aparece con 2 (B_cc_1). El límite `"any 2 recipients"` de Sandbox [F37] **suma los tres
    campos**. Cuando `to` ya falla por su propio tope (B_to_10…51) el `#MS42225` no aparece: la
    API informa **un solo error por campo**, el primero que salta.
  - **Cabeceras de caudal de `/v1/email`:** `x-ratelimit-limit: 10` en las diez respuestas 422,
    con `x-ratelimit-remaining` de **9 a 0** (el contador cuenta las peticiones rechazadas).
    **T_tags_5, T_tags_6, T_subject_998, T_subject_999** (peticiones 11.ª a 14.ª al endpoint
    dentro del mismo minuto, 19:02:49–19:02:56) → **429** `"Your account reached its rate limit
    of 10 requests/min. Please wait before trying again. #MS42903"`. Es el `"10 requests per
    minute"` que [F31] publica para la reputación **bajo revisión**, aplicado aquí a una cuenta
    **sin aprobar**; no el 120/min por defecto. 429 alcanzado: el 10/min es dato medido (regla E
    ampliada, D-024) **del estado no aprobado**, no del plan. Reproducido en la tanda 1b
    (19:13:43–19:14:19): mismo `x-ratelimit-limit: 10`, de 9 a 0, y 429 en la undécima.
  - **C_bulk_5** `POST /v1/bulk-email` con 5 objetos y remitente no verificado → **202**
    `{"message": "The bulk email is being processed.", "bulk_email_id":
    "6aa1ad527e48ed427f18cf4e"}`; cabeceras `x-ratelimit-limit: 1`, `x-ratelimit-remaining: 0`.
    Sandbox **tiene** el endpoint; el lote **entra** con un remitente que `/v1/email` rechaza en el
    acto (validación diferida, [F21]). **C_bulk_6** (3 s después) → **429** `"Your account reached
    its rate limit of 1 requests/min. Please wait before trying again. #MS42903"`: el
    `"1 request per minute"` de [F31], con 429 alcanzado. **El sexto objeto no se midió.**
    Reproducido en la tanda 1b: segundo lote de 5 aceptado con 202 y `bulk_email_id`
    `6aa1affd1e3217ac0dd87aa1`; el de 6, de nuevo 429 a 1/min.
  - **R_get_domains** `GET /v1/domains?limit=10` → 200, `x-ratelimit-limit: 60`,
    `x-ratelimit-remaining: 59`: el 60/min general de [F20] en cabecera (regla D6: se registra;
    ya era 🟢 por literal).
  - **Las cinco respuestas 429** traen solo `date` y `x-apiquota-*`: **ni `x-ratelimit-*` ni
    `retry-after`** (el script conserva toda cabecera con `ratelimit`, `retry` o `apiquota` en el
    nombre), frente al ejemplo de [F20] (`retry-after: 59`, `x-ratelimit-reset`). → DISC-19.
    Reproducido en la tanda 1b: **diez respuestas 429 en dos ejecuciones**, ninguna con esas
    cabeceras.
- **Lo que NO se pudo medir y por qué:**
  - Los topes **aprobados** 50/10/10 y el `max: 70` de `/v1/email`: la cuenta no está aprobada
    (todo `to ≥ 10` cae en MS42205). El 70 **sigue 🟡** (D4).
  - `tags` 5/6 y `subject` 998/999 (casos T): en las dos tandas las diez peticiones B agotaron el
    caudal de 10/min antes; los cuatro casos dieron 429 sin llegar a validar el cuerpo (ocho 429
    en total).
  - El sexto objeto del lote (C_bulk_6): en las dos tandas, 429 por el caudal de 1/min dos o tres
    segundos después del lote de 5. Los `validation_errors` de los dos lotes aceptados no se han
    consultado (`GET /v1/bulk-email/6aa1ad527e48ed427f18cf4e` y
    `GET /v1/bulk-email/6aa1affd1e3217ac0dd87aa1`).
  - **El retardo del contador de la cuota**: se sabe que descuenta por lotes (17 y 14) y que la
    lectura final de la tanda 1b aún no reflejaba las tres últimas peticiones; **no** se midió
    cuánto tarda ni qué dispara la actualización (tiempo, número de peticiones u otra cosa). La
    tanda 1b cerró 7 segundos después de la última petición; entre tanda y tanda pasaron 11
    minutos.
  - El 120/min de `/v1/email`, el 10/min del lote de Hobby, el rate de Starter/Professional
    (DISC-08) y la unidad de la cuota mensual (Q9): fuera del alcance de una cuenta Sandbox sin
    aprobar. DISC-11 tampoco: la cuenta es Sandbox, no Free.
- **Lo que cierra:** (1) `window_type: fixed_utc_midnight` de la cuota diaria de peticiones,
  ya 🟢 por literal, queda además **medido** (`reset` a las 00:00Z del día siguiente); (2) el 60/min
  general, en cabecera; (3) el tope `cc = 1` sin aprobar, literal confirmado; (4) los caudales
  10/min y 1/min **por estado de cuenta** con 429 alcanzado → F-18 con evidencia medida; (5) el
  lote se acepta con 202 antes de validar el remitente → F-04 pasa de candidato a recurrente;
  (6) Sandbox tiene `/v1/bulk-email` (no dice nada de Free, Q3); (7) **DISC-17 resuelta** con la
  tanda 1b: cada petición cuenta 1 (también 422, 429 y 202), y el contador expuesto se actualiza
  por lotes y con retardo (O-11 en `fricciones.md`; F-20 retirada). **Ningún semáforo del YAML
  cambia**: el 120 y el 10 del plan siguen 🟢 por D2 (valor por defecto publicado), con NOTA en
  el provenance de que la cuenta Sandbox no aprobada devuelve 10 y 1; `quota_request_daily_*`
  ya era 🟢 por literal y ahora está además medida en su regla de descuento.
- **Tanda 2 propuesta:** `probe_mailersend_sandbox_t2.sh` (≤ 10 peticiones por minuto a
  `/v1/email`, `sleep 7`): `to` 2/3, 5/6, 9 (acotar DISC-18), lote de 6 tras 61 s,
  `GET /v1/bulk-email/{id}` de los dos lotes aceptados (`6aa1ad527e48ed427f18cf4e` y
  `6aa1affd1e3217ac0dd87aa1`), `tags` 5/6 y `subject` 998/999. Ya no necesita medir el descuento
  de la cuota (DISC-17 resuelta); una lectura inicial de `GET /v1/api-quota` solo como
  presupuesto del día. Ver `REVISION.md`.
- **Tanda 2 — ejecutada (2026-09-10, 11:24:08–11:26:36 UTC, 13 casos):** el plan de arriba se
  llevó a cabo sin cambios, con `bash 05_salida/_herramientas/probe_mailersend_sandbox_t2.sh`
  (mismo ejecutor, misma cuenta Sandbox no aprobada, mismo token, mismo diseño a coste cero:
  remitente de dominio no verificado). Evidencia:
  `evidencias/probe_sandbox_limites_t2_2026-09-10.json`; volcado aplanado en
  `evidencias/paginas/2026-09-10/api_mailersend_com_v1.txt`.
  - **A2_api_quota_inicio** (11:24:08) `GET /v1/api-quota` → 200 `{"quota": 100, "remaining": 66,
    "reset": "2026-09-11T00:00:00Z"}`; cabeceras `x-apiquota-remaining: 66`,
    `x-apiquota-reset: 2026-09-11T00:00:00Z`. Solo presupuesto del día (la tanda necesita 12 de
    las 66 restantes); no mide el descuento, que sigue por lotes y con retardo (DISC-17 resuelta,
    O-11).
  - **B2_to_2, B2_to_3, B2_to_5, B2_to_6, B2_to_9** `POST /v1/email` → 422 en las cinco, mismo
    mensaje: `errors.to`: `"The to recipient limit is exceeded. #MS42205"` (más `#MS42207` en
    `from.email`). **`to = 2` ya falla**: junto con `to = 1` (B_cc_1, tanda 1, que solo dio
    `#MS42207`), acota el tope de `to` sin aprobar en exactamente **1**, contra el `"up to 10 TO"`
    de [F20].
  - **C2_bulk_status_t1** y **C2_bulk_status_t1b** `GET /v1/bulk-email/{id}` de los dos lotes de 5
    objetos aceptados con 202 en la tanda 1 (`6aa1ad527e48ed427f18cf4e`, 2026-09-09 19:02 UTC) y
    en la tanda 1b (`6aa1affd1e3217ac0dd87aa1`, 19:14 UTC) → 200 en los dos, idénticos salvo el
    `id` y las marcas de tiempo: `state: "completed"`, `total_recipients_count: 5`,
    `suppressed_recipients_count: 0`, `validation_errors_count: 5`, con los cinco objetos
    (`message.0` … `message.4`) marcados en `errors.to`: `"You have reached sandbox account
    unique recipients limit. #MS42225"` y en `errors.from.email`: `#MS42207`. Los dos lotes
    aceptados con 202 no enviaron nada: **F-04 confirmada** con el estado final, no solo con la
    cabecera de aceptación.
  - **C2_bulk_6** `POST /v1/bulk-email` con 6 objetos, tras esperar 61 s desde el lote anterior
    para no chocar con el caudal de 1/min → **422** (no 429, a diferencia de la tanda 1):
    `"The number of email objects must not be greater than 5. #MS42229"`, en `errors.data`. Tope
    de 5 objetos por lote confirmado con la respuesta de validación real.
  - **T2_tags_5** y **T2_subject_998** `POST /v1/email` → 422 con **solo** `errors.from.email`
    `#MS42207`: los valores documentados como límite (5 tags, *subject* de 998 caracteres) pasan
    la validación.
  - **T2_tags_6** → 422, `errors.tags`: `"The tags must not have more than 5 items."` (más
    `#MS42207`). **T2_subject_999** → 422, `errors.subject`: `"The subject must not be greater
    than 998 characters."` (más `#MS42207`). Los dos topes de cuerpo documentados quedan medidos
    por primera vez: en las dos ejecuciones de la tanda 1 los cuatro casos T habían agotado antes
    el caudal de 10/min y respondieron 429 sin validar.
  - **Traza de `x-apiquota-remaining` en las 13 respuestas:** 66 en la lectura inicial
    (`reset: 2026-09-11T00:00:00Z`) y se mantiene en 66 en la primera petición (B2_to_2); sube a
    **99** en las seis siguientes (B2_to_3 a C2_bulk_status_t1b); baja a **93** en C2_bulk_6,
    T2_tags_5 y T2_tags_6; cierra en **90** en T2_subject_998 y T2_subject_999. El salto de 66 a
    99 **no es un descuento** (el contador sube, no baja): compatible con el retardo y el
    descuento por lotes ya descrito (DISC-17 resuelta) si la aplicación tardía del gasto
    pendiente del día 09-09 (que cerró en `remaining: 69`) cae después del reset a las 00:00 UTC
    del día 10-09 y antes de la primera lectura de la tanda 2; la traza no fija el instante
    exacto. Dato adicional para O-11 (`fricciones.md`), no una contradicción de DISC-17.
  - **Lo que NO se pudo medir en la tanda 2:** los topes aprobados 50/10/10 y el `max: 70`
    de `/v1/email` (D4), el 120/min por defecto, el rate de Starter/Professional (DISC-08), la
    unidad de la cuota mensual (Q9) y el retardo exacto del contador de la cuota diaria: todos
    fuera del alcance de una cuenta Sandbox sin aprobar, o ya cerrados por la tanda 1b.
  - **Lo que cierra la tanda 2:** (8) acota el tope de `to` sin aprobar en **1** (DISC-18, parte
    numérica); (9) confirma con el estado final de los dos lotes que el 202 del bulk no envía
    nada (F-04, ahora con `validation_errors_count` y no solo con la cabecera de aceptación);
    (10) confirma el tope de 5 objetos por lote con una respuesta de validación real, `#MS42229`,
    no un 429 por caudal; (11) mide por primera vez `tags` (5/6) y `subject` (998/999). **Ningún
    semáforo del YAML cambia** con esta tanda: el `max: 70` sigue 🟡 (D4), y los topes numéricos
    de `to`, del lote y del cuerpo del mensaje ya estaban documentados y en verde por literal
    (D2); lo que aporta la tanda 2 es la cita medida, no un cambio de color.

---

### Tanda 3 — Q9, unidad de la cuota mensual: **ejecutada el 2026-09-14 y SIN RESULTADO** (16:39–16:47 UTC)

**Ejecutada por:** el autor, mismo token y misma cuenta Sandbox no aprobada. Script nuevo
`05_salida/_herramientas/probe_mailersend_q9_unidad.sh`, en fases (`antes`, `enviar`,
`enviar-mismo`, `despues`). Evidencias: `evidencias/probe_q9_unidad_antes_2026-09-14_163913.json`,
`…_enviar_2026-09-14_164207.json` y `…_enviar-mismo_2026-09-14_164728.json` (direcciones
redactadas por el propio script; no se escribe PII).

**Qué se buscaba.** La unidad de la cuota mensual (Q9): mandar **un** mensaje a **dos**
destinatarios y ver si el contador baja 1 o 2. A diferencia de las tandas 1 y 2, esta **sí
pretendía enviar de verdad**, con el dominio de prueba verificado como remitente.

**Qué pasó.** Nada salió, y el motivo es el hallazgo:

| Caso | Resultado (literal) | Qué cierra |
|---|---|---|
| Estado de partida (16:39) | `{"quota": 100, "remaining": 100, "reset": "2026-09-15T00:00:00Z"}`; panel `"Emails sent"` **0** | Cuota mensual intacta: lo que se mida después es de este sondeo |
| `to` 1 + `cc` 1, **dos direcciones distintas** (16:42) | **422** `"You have reached sandbox account unique recipients limit. #MS42225"` | La combinación que la tanda 1 midió como válida **ya no pasa**. La diferencia es el remitente: con dominio no verificado la petición moría antes en `#MS42207` y nunca llegaba al chequeo de únicos |
| `GET /v1/recipients` | `recipients registrados: 0` | El cupo **no es consultable**: ese endpoint lista destinatarios de mensajes procesados, y no salió ninguno |
| `to` 1 + `cc` 1, **la misma dirección** (16:47) | **422** con tres errores: `"You have reached sandbox account unique recipients limit. #MS42225"`, y en `to.0.email` y `cc.0.email` `"{recipient email} is duplicated in the {$field} recipients list. #MS42201"` | Dos cosas: el cupo salta **también** con una sola dirección única, y la misma dirección **no puede ir en `to` y `cc` a la vez** — `#MS42201`, que [F20] publicaba y que aquí queda **medido** |

**Conclusión: Q9 no es medible con esta cuenta.** El literal de [F37], `"You can send to any 2
recipients in Sandbox mode, until your account is approved"`, no es un tope por petición: es un
**cupo de la cuenta**, y las tandas 1 y 2 lo agotaron probando direcciones **sin que saliera ni un
correo**. No se repone, no se expone en ninguna parte y la única forma de levantarlo —aprobar la
cuenta— no tiene vía en el panel (comprobado el 14-09 en dashboard y Settings).

**Coste real de la tanda 3: cero correos del mes** (el panel sigue en `"Emails sent"` 0) y tres
peticiones de las 100 diarias. La cuota que bajó en `x-apiquota-remaining` (100 → 97) es la
**diaria de peticiones**, no la mensual de correos: son dos cuotas distintas que el panel muestra
juntas, que es justo lo que documenta DISC-11.

**Lo que esto le da al TFM.** Un resultado negativo que vale más que el dato que buscaba: la
escalera de validación tiene un peldaño que **se consume al pisarlo**. El diseño «a coste cero» de
las tandas 1 y 2 era correcto en lo que decía medir —no gastó un solo email— pero consumió un
recurso distinto que ninguna fuente declara consumible, que el panel no muestra y que ningún campo
de v0.3 recoge. → **F-21** y O-13.

---

## Verificación independiente — 2026-09-08

Tres verificadores (adversarial sobre las URL del provenance con un lector sin JavaScript;
criterios contra `CRITERIOS.md` y el README v0.3; fricciones contra el recuento D-008) levantaron
30 hallazgos, resueltos por el corrector el mismo día (tabla completa en `REVISION.md`,
«Verificación independiente»). **Ningún valor modelado refutado.** Lo que cambió en este registro:
la cabecera distingue citas literales de transcripciones de tabla; [F1] anota que los literales
de tarjeta son celdas adyacentes unidas y que la escalera solo existe ejecutando el JavaScript;
las lecturas de tanda 1 de /pricing (`"$ 5.60 /month"`…) **no** eran de [F11] sino del HTML de
/pricing sin JavaScript (DISC-03 ampliada); DISC-04 se reencuadra como discrepancia de plan
mínimo (el 100.000/semana de [F3] es recomendación, no requisito); DISC-11 baja a 🟡 el tope
diario de 100 emails del Free y deja F-17 en suspenso; DISC-12 sube a 🟢 el `fixed_billing_cycle`
de los planes de pago; [F22] registra que la API de tokens no tiene parámetro de expiración y
[F53] deja de contar el token en F-14. Sin volcado ni segundo lector quedan [F35] (raw de GitHub,
bloqueado para el verificador) y las pantallas `/api-tokens` y `/domains` del panel.

## Discrepancias entre fuentes

Numeración única de este registro. Entre paréntesis, el identificador provisional de la lente
que la abrió (DISC-Pn / DISC-Dn / DISC-Sn / DISC-Hn) o «sondeo» si la abrió [E1] (DISC-17 a
DISC-19, documentación frente a realidad medida el 2026-09-09).

### DISC-01 (DISC-P1) · Sobrecoste de Starter/Professional: $0.90, $1.30, $0.95 o $1.50 por 1.000

- **[F1] /pricing (volcado, escalera), 2026-09-08:** Starter `"Extra usage $1.30 /1,000 emails"` (50K–100K) → `"$1.10"` (250K–500K) → `"$1.00"` (1M); Professional `"$1.30"` → `"$1.00"` → `"$0.80"` → `"$0.60"` → `"$0.50"`. FAQ 13: `"Any extra email sent above that allowance has a cost of $1.30 for a block of 1,000 emails."` (abreviado: `"an $68 subscription includes 100,000 emails on the Starter plan … $1.30 for a block of 1,000"`)
- **[F2], 2026-09-08:** `"metered rate starting at $1.30 per additional 1,000 emails sent. The price per 1,000 emails decreases the larger your plan size."` · **[F40]:** `"for Starter and Professional plans, the price starts at $1.30 per 1,000"`
- **[F11] /features/email-verification-tool, 2026-09-08:** `"$0.90 €0.90 £0.90 /1,000 emails"` (Starter y Professional a 50.000)
- **[F14]:** `"decremental rates starting at $0.95/1,000"` · **[F16]:** `"$1.50/1,000"` de arranque
- Hobby es consistente: `"$1.50"` en [F1], [F2], [F11], [F40].

**Estado: reencuadrada por la escalera de [F1].** El `"$0.90"` no está hoy en /pricing en ninguna
posición del selector: procede del bloque desactualizado de [F11] (→ DISC-03) y la newsroom [F47]
lo sitúa antes de 2024-07-29; el `"$0.95"` es el valor de 2024-07-29 [F47]. Para el YAML: el
sobrecoste **depende del peldaño de volumen** (F-08) y se toma de la escalera de [F1] por peldaño;
[F14] y [F16] son páginas de marketing sin fecha. Queda abierta solo la vigencia de [F14]/[F16].

### DISC-02 (DISC-P2) · Descuento anual: «Save 10%» frente a precios al 80 %

- **[F1] toggle:** `"Pay yearly Save 10%"`; escalera anual = 90 % del mensual en todos los peldaños (`"$ 31.50"` / `"$378.00"`, `"$99.00"` / `"$1,188.00"`, `"$ 6.30"` / `"$75.60"`). **[F2]:** `"$6.30 per month with an annual plan"`, `"$31.50"`, `"$99"`. **[F15]:** `"Annual discount | 10%"`.
- **[F11]:** Hobby `"$5.60 /month"` / `"$67.20 billed yearly"`, Starter `"$28.00 /month"` / `"$336.00 billed yearly"`, Professional `"$88.00 /month"` / `"$1,056.00 billed yearly"` (= 80 %). **[F14]:** `"Annual discount available | 20%"`. **[F47] (2024-06-28):** `"This will also give you a 20% discount overall."`

**Estado: reencuadrada.** No es un artefacto de caché: dos páginas oficiales el mismo día con dos
descuentos → DISC-03. En /pricing es 10 % en todos los peldaños. El modelado previo (5.60 / 28.00 /
88.00) arrastra el 20 % de 2024 (contraste, filas 2–4).

### DISC-03 (DISC-H1) · /pricing frente a /features/email-verification-tool, mismo día, mismo plan y volumen

- **[F1] /pricing [VOLCADO], 2026-09-08:** Starter 50K `"$ 31.50 /month"` · `"$378.00 billed yearly"` · `"Extra usage $1.30 /1,000 emails"`; Hobby `"$ 6.30 /month"` · `"$75.60 billed yearly"`; Professional `"$99.00 /month"` · `"$1,188.00 billed yearly"`.
- **[F11] [WebFetch], 2026-09-08:** Starter `"$28.00 /month"` · `"$336.00 billed yearly"` · `"$0.90 €0.90 £0.90 /1,000 emails"`; Hobby `"$5.60 /month"` · `"$67.20 billed yearly"`; Professional `"$88.00 /month"` · `"$1,056.00 billed yearly"`.

- **[F1] /pricing sin ejecutar JavaScript [WebFetch ×2, verificación 2026-09-08]:** Hobby `"$ 5.60 /month"` · `"$67.20 billed yearly"` · `"$1.50 €1.50 £1.50 /1,000 emails"`; `"$6.30"` y `"$75.60"` **ausentes**. El HTML servido de la propia página de precios conserva los precios anuales de 2024 y el JavaScript los sustituye al cargar.

Los precios mensuales base coinciden ($35 / $110 / $7). **Abierta** como hecho (dos páginas
oficiales contradictorias, y la propia /pricing publica dos ofertas según se ejecute o no su
JavaScript); **para el modelo manda /pricing renderizada**, porque Terms 2.2 [F44] dice `"The
rates for Services and additional services provided by us are listed at www.mailersend.com/pricing"`.
Evidencia de F-09 (una página del proveedor conserva la oferta de 2024, y la página vigente la
lleva escondida en su HTML).

### DISC-04 (DISC-P3 + DISC-S4) · IP dedicada: plan mínimo, umbral y precio

- **[F3] plan-add-ons:** `"available to Professional (excluding the Professional trial) and Enterprise plans (Enterprise plans also have 1 dedicated IP included) for $50/month per IP"` · `"at least 100,000 emails per week"`.
- **[F9]:** `"available for Starter and above plans"` · `"500,000 emails/month"`. **[F10]:** `"Send 500,000 or more emails per month."` · `"Pricing is $50/month."` (plan mínimo no nombrado).
- **[F1] /pricing [VOLCADO]:** `"Dedicated IPs are available for Enterprise accounts that send over 100K emails/week."` · `"Contact our support team"` (sin precio). **[F14][F15]:** `"Dedicated IPs are available to high-volume senders with Enterprise accounts"`.
- Tabla de [F1] `[VERBATIM DUDOSO]`: `Dedicated IP add-on` en Starter — (lectura A) / ✓ (B).

**Reencuadre (verificación 2026-09-08).** La discrepancia real es de **plan mínimo**: tres páginas
oficiales dan tres (Starter [F9], Professional [F3], Enterprise [F1]). En cuanto al volumen, el
único **requisito** publicado es `"Send 500,000 or more emails per month."` [F10] (lista `"your
account must meet the following criteria"`), coherente con [F9]; la frase de [F3] `"best suited to
high-volume senders, sending at least 100,000 emails per week"` es una **recomendación**, no un
umbral de elegibilidad, y la de [F1] (`"Enterprise accounts that send over 100K emails/week"`)
condiciona el plan, no cuantifica un requisito aparte. Consistente en todas: **$50/mes por IP**
(donde hay precio) y **Enterprise incluye 1**. **Abierta** (plan mínimo). Add-on → `features.md`
con todas las citas (G2).

**Cerrada por D17 (D-068, 2026-10-18).** El pricing define la verdad: la página de precios
[F1] publica el plan del que depende la IP dedicada, `"Dedicated IPs are available for
Enterprise accounts that send over 100K emails/week."`, y por tanto **solo Enterprise**
(más de 100.000 correos a la semana). Los planes mínimos de [F9] (Starter) y [F3]
(Professional), el umbral de [F10] (500.000/mes) y el precio de $50/mes quedan aquí y en el
provenance como **incoherencia del pricing**. La fila `Dedicated IP add-on` de la tabla de [F1]
no entra: sus ticks no son capturables y no hay literal contra el que comparar.

- **Efecto declarado:** excluyente (D11) · cerrada por D17; sin campo en el YAML (add-on,
  D-001). Cambia `features.md` y PI-E02: Starter y Professional no tienen IP dedicada y
  MailerSend sale de esa comparación.

### DISC-05 (DISC-P4 + DISC-S2) · Límites de recursos: página de precios frente a centro de ayuda

- **Webhooks de Hobby** — [F1] tabla `"Webhooks | Unlimited* 50 1 1"` (→ Hobby **1**) · [F2] `"5 webhooks"` y tabla `"Webhooks | 1 | 5 | 50 | 5,000"` (→ Hobby **5**).
- **Inbound Free/Hobby** — [F1] tabla `Inbound routing —` en Free y Hobby · [F2] `"Inbound routes: 1"` (Free), `"1 inbound route"` (Hobby) y prosa `"The Free plan also gives you access to features such as: Email API, SMTP relay, webhooks, inbound routing…"`; panel [F53]: `"Upgrade plan"` en inbound (Sandbox).
- **Dominios de Professional** — [F1] `"Sending domains | Unlimited* 10 1 1"` · [F2] `"1,000 sending domains"`; [F37] para el trial: `"Unlimited sending domains"`.
- **Webhooks de Professional** — [F1] `"Unlimited*"` · [F2] `"5,000 webhooks"`; [F47] (2024): `"Unlimited API tokens, webhooks, sender identities, inbound routes, and SMTP users"`.
- Plantillas Hobby coherente (10) en [F1], [F2], [F17].

Límites de recursos (B3): no van a `capacity`, pero `features.md` lleva las dos cifras. El asterisco
de [F1] remite a `"*Learn more about plan limits."` → [F2], que da la cifra finita: «Unlimited» con
nota al pie que dice 1.000 / 5.000. **Abierta** (Hobby 1 vs 5; inbound en Free).

**Webhooks de Hobby cerrados por D17 (D-068, 2026-10-18).** Gana la página de precios: Hobby
**1** (`"Webhooks Unlimited* 50 1 1"`, columnas Professional, Starter, Hobby y Free en el
volcado). El `5` de [F2] queda como **incoherencia del pricing**. **El inbound en Free y Hobby
sigue abierto:** en el volcado de [F1] la fila `Inbound routing` sale sin valores, porque los
ticks no son capturables. La página no publica un literal contra el que aplicar D17, así que
sigue D11. Los dominios y los webhooks de Professional no son discrepancia: el asterisco de
[F1] remite a la cifra de [F2].

- **Efecto declarado:** excluyente (D11) · abierta en el inbound, sin campo en el YAML (B3,
  límite de recursos); la parte de webhooks, cerrada por D17, solo cambia `features.md`.

### DISC-06 (DISC-P5) · Tope de volumen de Starter (500K o 1M) y precio a 1.000.000

- **500K:** [F5] `"Starter plan is available for up to 500,000 emails/month"` · [F13] `"The Starter plan is available for up to 500,000 emails/month, starting at $35/month for 50,000 emails"`.
- **1M:** [F14] `"Starter plan is available for up to 1,000,000 emails/month"` · [F1] selector [VOLCADO]: tarjeta Starter en 1M `"$600.00 /month"` · `"1,000,000 emails /month"`, y en 1.5M y 2M repite ese peldaño (`"Starter no crece más allá de 1M"`).
- **Sin tope:** [F2] `"Emails/month | … | From 50,000 | From 50,000"`.
- **Precio a 1M:** [F14] `"1,000,000 | $1,000"` · [F15] `"1,000,000 | $600"` → CD-26: [F14] mezcla Starter (≤500K) y Professional (≥1M); en 1M Starter = `"$600.00"` y Professional = `"$1,000.00"` [F1].

Estado anterior: abierta en cuanto al tope (la página de precios ofrece Starter hasta 1M; las
páginas de feature dicen 500K); la parte del precio a 1M queda explicada. Escalón 2 (desplegable
de Starter en el panel) bloqueado por el muro de dominio aprobado [F53].

**Cerrada por D17 (D-068, 2026-10-18).** Gana el selector de la página de precios: Starter llega
hasta **1.000.000** correos al mes (`"$600.00 /month"` · `"1,000,000 emails /month"`, y la tarjeta
repite ese peldaño en 1,5M y 2M). El tope de 500.000 de [F5] y [F13] queda como **incoherencia
del pricing**.

- **Efecto declarado:** excluyente (D11) · cerrada por D17; el YAML modela el primer volumen
  (50.000) y la escalera vive en el provenance, que pasa a declarar el tope de la página.

### DISC-07 (DISC-P6) · SMS incluidos en Professional (100 o 150) y en Hobby — CERRADA

- **[F1] lectura WebFetch tanda 1:** Professional `"100 SMS /month"` `[VERBATIM DUDOSO]`; Hobby `"100 SMS /month"` `[VERBATIM DUDOSO]`; tabla A `Add-on available` / B ✓ en Hobby.
- **[F11]:** Professional `"150 SMS/month"`. **[F12]:** `"Our base plan includes 100 SMS messages."` **[F2]:** no lista SMS en Hobby.

**CERRADA (CD-04): error de lectura del modelo intermedio.** El volcado de /pricing dice Professional
`"150 SMS /month"`, Starter `"100 SMS /month"` y Hobby **sin línea SMS**; [F11] coincide (150). Producto
aparte (F-10); no afecta al YAML.

### DISC-08 (DISC-D1) · Rate de `POST /v1/bulk-email`: valor único frente a valor por plan

- **[F20] general.html [VOLCADO]:** `"API requests to POST /v1/bulk-email: 10 requests/minute"` · MS42903: `"The default rate limit is 120 requests per minute for /email endpoints, 10 requests per minute for /bulk-email endpoints and 60 requests per minute for all other endpoints."` · **[F39]:** `"API requests to v1/bulk-email | 10 requests to v1/bulk-email per minute"`.
- **[F21] email.html «Limitations» [VOLCADO]:** `"API requests per minute | 10 for Sandbox and Hobby plan accounts. 15 for Starter plan accounts. 30 for Professional trial and Professional plan accounts. 60 for Enterprise plan accounts."`
- **[F31] help center [VOLCADO]:** `"API requests to v1/bulk | Free plan: 10 API calls/min Hobby plan: 10 API calls/min Starter plan: 15 API calls/min Professional plan: 30 API calls/min Enterprise plan: 60 API calls/min | 1 request per minute"`

Dos páginas (una de ellas la referencia del endpoint) publican valores por plan; la página general
y [F39] publican solo el mínimo, que general.html llama `"default"`. Es la primera API del catálogo
con un rate publicado **por plan**.

**CERRADA el 2026-09-14 (Q4, ficha D-028, regla E4).** El autor decidió que la referencia del endpoint
manda sobre la página general cuando esta se declara `"default"`: un valor por defecto no
contradice una tabla por plan. `rate_request_bulk_starter` (15) y `rate_request_bulk_professional`
(30) pasan de 🟡 a 🟢, el 10 de Hobby sigue en 🟢 y la entrada de `not_found` se retira. No hizo
falta leer `x-ratelimit-limit` con una cuenta de pago: se cierra por criterio, no por medición.

- **[E1] 2026-09-09 (cuenta Sandbox no aprobada):** `x-ratelimit-limit: 1` en el 202 del lote y 429
  `"Your account reached its rate limit of 1 requests/min. Please wait before trying again.
  #MS42903"` en la segunda petición del minuto. **No resuelve** la discrepancia (que es sobre
  Starter y Professional) y añade un matiz: la fila `"10 for Sandbox and Hobby plan accounts"` de
  [F21] no describe esta cuenta Sandbox, que recibe el `"1 request per minute"` de la columna
  «Under review» de [F31] sin estar bajo revisión: **el caudal del lote depende del estado de
  aprobación además del plan** (F-18). Ese matiz sigue vivo y está modelado en el alias
  `unapproved_account` (D-025); lo que se cierra el 2026-09-14 es la discrepancia sobre Starter y
  Professional.

### DISC-09 (DISC-D2) · Nomenclatura de los planes de prueba/gratuito en la cuota diaria

- **[F20]:** `"Sandbox: 100"` · `"Professional trial (14 days): 100"` (sin fila Free)
- **[F21]:** `"5 for Sandbox accounts. 500 for Professional trial, Hobby, Starter, Professional or Enterprise plan accounts."`
- **[F31]:** `"Trial | 100"` · `"Free | 100"` · **[F6]:** `"Sandbox & Professional plan trial: 100 requests per day"` · `"Free plan: 100 requests per day"`
- Panel [F53]: `Sandbox` (app) y `Trial` (selector de cuentas) para la misma cuenta.

Mismo valor (100/día), nombres distintos. Discrepancia de nomenclatura, no de cifra. El plan `free`
del YAML es el **Free aprobado** (A1 y nombre de la página de precios); Sandbox y trial → F-14 /
`not_found`.

### DISC-10 (DISC-D3) · Rate del canal SMTP

- **[F20]:** `"SMTP: 120 requests/minute"` · **[F6] [VOLCADO]:** `"SMTP relay requests: Up to 120 requests per minute."` · **[F39]:** `"SMTP | 120 requests/minute"`
- **[F27]:** `"There are Rate limits applied to SMTP relay based on IP address and these tend to be lower than available through our API"`

Un valor numérico (tres fuentes) frente a «sin valor, por IP y menor que la API». **Abierta**; el SMTP
no es el canal modelado, pero comparte la cuota diaria [F20][F27].

### DISC-11 (DISC-S1) · Tope diario del Free: «100 emails» frente a «100 requests» — CERRADA (D17, 2026-10-18)

- **[F2] [VOLCADO], 2026-09-08:** `"Once approved, the Free plan allows you to send up to 500 emails a month for free, with a daily limit of 100 emails."`
- **[F6] [VOLCADO]:** `"Free plan: 100 requests per day"` · **[F31] [VOLCADO]:** `"Free | 100"` bajo `"Quota / day"` de `"daily request quota"` · **[F1] [VOLCADO] FAQ 14:** `"1 API token, 1 webhook, and 100 daily requests"` · tabla `Daily API requests` Free `100`.

Misma cifra, **dos unidades**: emails frente a peticiones. Como una petición a `/v1/email` puede llevar
hasta 70 destinatarios y una a `/v1/bulk-email` hasta 500 objetos, no es lo mismo. Todas las fuentes
salvo [F2] dicen *requests*. **Abierta**; `GET /v1/api-quota` [F32] con cuenta Free (escalón 2/3) lo
resolvería. **Consecuencia en el YAML (verificación 2026-09-08):** el valor de
`quota_email_daily_free` pasa de 🟢 a 🟡 (D1: ambigüedad de unidad, una fuente contra cuatro) y
sigue sin referenciar desde ningún plan; si DISC-11 se resuelve en peticiones, la entrada
duplica `quota_request_daily_free` y debe retirarse (Q5 de `REVISION.md`). F-17 queda en
suspenso hasta entonces.

- **[E1] 2026-09-09: no la resuelve.** `GET /v1/api-quota` devolvió `"quota": 100` en peticiones
  para la cuenta propia, pero la cuenta es **Sandbox**, no Free (la fila `"Sandbox: 100"` de [F20]
  nunca estuvo en discusión). Para leer el contador del Free hace falta una cuenta aprobada y
  suscrita al Free, lo que exige dominio propio [F53]; el autor no controla ningún DNS, así que
  DISC-11 queda **abierta sin vía de cierre por cuenta propia** (solo por el proveedor o por un
  tercero con dominio). Sigue **abierta**.

**Cerrada por D17 (D-068, 2026-10-18).** La página de precios publica el dato dos veces, y las
dos en peticiones: FAQ 14 de [F1], `"1 API token, 1 webhook, and 100 daily requests"`, y la fila
`Daily API requests` de su tabla, Free `100`. La página gana: el tope diario del Free es de 100
peticiones, que es `quota_request_daily_free`. El `"daily limit of 100 emails"` de [F2] queda
como **incoherencia del pricing**. La vía de [E1] ya no cambia el valor, porque D17 gana también
sobre panel y sondeo.

- **Efecto declarado:** sin cambio en el YAML; `quota_email_daily_free` se retiró en D-029 y
  `quota_request_daily_free` ya lleva el valor. F-17 se retira del inventario por **B17** y la
  celda de F-38 en MailerSend pasa de ⏸ a ❌ (`RECURRENCIA_2026-09-23.md`).

### DISC-12 (DISC-S3) · Ventana de la cuota mensual: «every 30 days» frente a «next billing day»

- **[F2] [VOLCADO]:** `"The number of emails that you send resets every 30 days."` · `"within the 30-day usage period"` (Free) · **[F1] [VOLCADO] FAQ 4 y 5:** `"The number of emails that you have sent automatically resets every 30 days."` · FAQ 4: `"The billing period starts right after you enter your credit card details."`
- **[F41]:** `"Your monthly email quota will reset on your next billing day."` · `"Yearly plans are billed upon subscription and the subscription stays active until the end of the billing period. Keep in mind, any overcharges will be billed at the end of each month."` · **[F40] [VOLCADO]:** `"until your next billing period begins and your limits are reset"` · **[F2] (Hobby):** `"within your billing period"` · **[F1] FAQ 6:** `"the remainder of that month's billing cycle"` · **[F44] 2.1:** `"The payment period is one month for a monthly plan or one year for a yearly plan"` · **[F50]:** `"Number of emails sent during your billing period"`

«Cada 30 días» y «el día de facturación» solo coinciden si el ciclo es de 30 días exactos, y los
términos hablan de **un mes**. Para un plan anual la cuota es mensual y el pago anual: qué día se
repone no lo dice ninguna fuente. **Abierta** en cuanto al día exacto y al plan anual. **Para el
`window_type` (verificación 2026-09-08):** las dos formulaciones son ventanas fijas ligadas al
ciclo de facturación y dos fuentes lo dicen literalmente para los planes de pago (`"Your monthly
email quota will reset on your next billing day."` [F41], `"until your next billing period begins
and your limits are reset"` [F40]; `"The billing period starts right after you enter your credit
card details."` [F1]), así que `fixed_billing_cycle` va en 🟢 en Hobby, Starter y Professional
por D3, como se hizo en SendGrid con `"sending limit for the current billing period"`; en Free
se queda en 🟡 (solo `"within the 30-day usage period"` y `"until a new period begins"`, sin
frase propia de día de facturación). Nunca `rolling` (nadie lo dice; el modelado previo lo tenía).
Escalón 2 (fecha «next payment date» del panel) bloqueado hoy [F53].

### DISC-13 (DISC-S5) · Cuota mensual de emails de los tres estados gratuitos

- **[F37] [VOLCADO]:** `"100 emails a month, with a cap of 100 API requests a day"` (Sandbox) · `"500 emails a month and 100 API requests a day"` (Professional trial)
- **[F1] [VOLCADO] FAQ 8:** `"including 500 emails/month, 100 API requests/day, and 1 day of Log retention"` (trial) · **[F2]:** `"500 emails a month … with a daily limit of 100 emails"` (Free) · **[F39]:** `"Make sure your account has been approved so you can send more than 100 emails per month."` (no aprobada) · **[F21]:** `"5 for Sandbox accounts. 500 for Professional trial, Hobby, Starter…"` (objetos por petición bulk)

No es contradicción entre fuentes sobre el mismo estado, sino **tres estados gratuitos con tres
cuotas** (Sandbox / no aprobada 100, trial 500, Free 500) y la misma cuota diaria (100). Se registra
para fijar qué estado modela el plan `free` del YAML (el Free aprobado); Sandbox y trial → F-14.

### DISC-14 (DISC-H2) · Objetos por petición bulk en el Professional trial: 500 o 5

- **[F21] [VOLCADO]:** `"Number of individual email objects in a single request | 5 for Sandbox accounts. 500 for Professional trial, Hobby, Starter, Professional or Enterprise plan accounts."`
- **[F49]:** `"If you're on a Hobby, Starter or Professional plan, you can include 500 individual email objects in a single request … Otherwise, you are limited to 5 individual email objects."` (resumido en la tanda 2 como `"Hobby, Starter or Professional plan … 500 … Otherwise, you are limited to 5"`)

**Abierta** (trial: 500 frente a 5). No afecta a los planes comerciales del YAML; a `not_found` del
estado trial.

### DISC-15 (DISC-H3) · OpenAPI frente a documentación en prosa de POST /v1/email

- **[F30] [WebFetch-JSON]:** respuesta declarada para `POST /email` **`200`** (`"Email sent successfully"`); `"required":["from","to","subject","text"]`.
- **[F21] [VOLCADO]:** `"Response Code: 202 Accepted"`; `text` `"Only required if there's no html or template_id present."`

**Abierta**; la OpenAPI está desalineada con la documentación (como en SendGrid). Observación O-nn
del repositorio del proveedor, no del modelo.

### DISC-16 (DISC-H4) · «Email threads support» en Free frente a `references`/`in_reply_to` solo de pago

- **[F1] tarjeta Free [VOLCADO]:** `"Email threads support"`
- **[F21] [VOLCADO]:** `references` e `in_reply_to`: `"Please note that this feature is available to paid plan accounts only."`

Estado anterior: abierta; posible distinto significado de «threads» (recibir/mostrar hilos sin
poder fijar `in_reply_to`). F-08.

**Cerrada por D17 (D-068, 2026-10-18).** El volcado de [F1] del 2026-09-08 lista `"Email threads
support"` en la tarjeta Free, bajo `"Get started for free — includes:"`. La página dice qué
incluye el plan y gana: el Free **incluye** hilos. La restricción de [F21] (`"available to paid
plan accounts only"`) queda como **incoherencia del pricing**. Salvedad: la tarjeta no nombra
`in_reply_to` ni `references`, y la lectura de que «threads» son esos dos campos es la de la
propia entrada desde que se abrió.

- **Efecto declarado:** excluyente (D11) · cerrada por D17; sin campo en el YAML (feature,
  B3). Cambia `features.md` (Free: sí).

### DISC-17 (sondeo) · Cuota diaria de peticiones: «every request is counted» frente a un contador que no baja — RESUELTA (2026-09-09, tanda 1b)

- **[F20] general.html [VOLCADO]:** `"Every request is counted against the quota and is reset daily
  at midnight UTC."` · MS42901: `"Every request is counted against the quota and the quota is reset
  daily at midnight UTC."` · **[F31]:** `"Every request made counts against your daily quota, which
  is reset daily at midnight UTC."` · **[F32]:** solo `/v1/api-quota` se excluye (`"Requests to this
  endpoint do not count toward your quota."`).
- **[E1] tanda 1, 2026-09-09, 19:02:18–19:02:56 UTC:** `GET /v1/api-quota` → `"remaining": 100`;
  después, diez `POST /v1/email` con 422, un `POST /v1/bulk-email` con 202, un `GET /v1/domains`
  con 200 y cinco 429, y **las 18 respuestas** traen `x-apiquota-remaining: 100`. Ninguna de las
  17 peticiones que según [F20] cuentan descontó nada en 38 segundos.
- **[E1] tanda 1b, 2026-09-09, 19:13:41–19:14:21 UTC (mismo script, 11 minutos después):**
  `GET /v1/api-quota` → `{"quota": 100, "remaining": 83, "reset": "2026-09-10T00:00:00Z"}`,
  `x-apiquota-remaining: 83`: **las 17 de la tanda 1 ya descontadas** (422, 429, 202 y 200 por
  igual; de los 18 casos de la tanda 1 uno quedó por descontar o se descontó más tarde, y por
  número es el propio `GET /v1/api-quota` que [F32] excluye). Después `x-apiquota-remaining: 83`
  en **14 respuestas seguidas** (B_to_10 … T_tags_5, 19:13:43–19:14:12), **69 en T_tags_6**
  (19:14:14; 83 − 14, las catorce anteriores de golpe, dos de ellas 429 y una el 202 del lote) y
  69 en las dos siguientes; `A_api_quota_final` (19:14:21) → `"remaining": 69`, con T_tags_6,
  T_subject_998 y T_subject_999 aún sin descontar.

**Resuelta a favor de la documentación, con un matiz que la documentación no da.**
`"Every request is counted against the quota"` **se sostiene**: se cuentan también las rechazadas
por validación (422) y por caudal (429) y el 202 del lote; 17 + 14 descuentos observados, ninguna
clase de respuesta excluida. La lectura (a) de la tanda 1 (las rechazadas no cuentan) **cae**; la
lectura (b) **se confirma y se precisa**: el contador que devuelven la cabecera `x-apiquota-*` y
`GET /v1/api-quota` **se actualiza con retardo y por lotes** (de 17 y 14 unidades en lo
observado), no por petición; ni [F20], ni [F31], ni [F32] lo dicen (`"Inspect how many MailerSend
API requests you have remaining"`). Cuánto tarda y qué dispara la actualización no se midió (la
tanda 1b cerró 7 s después de la última petición). **Consecuencias:** sin cambio en el YAML
(`quota_request_daily_*` sigue 🟢 por literal y queda además medida en su regla de descuento; el
valor 100 de Sandbox coincide con `"quota": 100`); la NOTA del provenance y la entrada de
`not_found` se reescriben (lo no publicado ahora es el retardo del contador, no la regla); **F-20
cae tal como estaba** («la cuota no cuenta las rechazadas») y se retira: lo que queda —el
contador expuesto no es el contador que se aplica— es la observación **O-11** de `fricciones.md`,
no una fricción del esquema. Para el escalón 3: `remaining` no sirve como cuentakilómetros
inmediato de un sondeo; hay que leerlo antes y bastante después.

### DISC-18 (sondeo) · Tope de `to` para cuentas no aprobadas: documentación 10 frente a API 1

- **[F20] general.html [VOLCADO], MS42205 Explanation:** `"Approved accounts can include up to 50
  TO, 10 CC and 10 BCC recipients. Unapproved acounts can include up to 10 TO, 1 CC and 1 BCC
  recipients."` · **[F39]:** `"If your account is not approved yet, you may only include one CC and
  BCC recipient."` (no cifra `to`).
- **[E1] 2026-09-09 (las dos tandas, 19:02 y 19:13 UTC):** `to` con **10** direcciones (también
  11, 50 y 51) → 422 `"The to recipient limit is exceeded. #MS42205"`; `to` con 1 dirección pasa
  (B_cc_1). El tope real de `to` sin aprobar está entre 1 y 9. Ocho respuestas iguales en dos
  ejecuciones.
- **[E1] tanda 2, 2026-09-10 (11:24:15–11:24:44 UTC):** `to` con **2**, 3, 5, 6 y 9 direcciones →
  422 `"The to recipient limit is exceeded. #MS42205"` en los cinco casos (`B2_to_2`, `B2_to_3`,
  `B2_to_5`, `B2_to_6`, `B2_to_9`). Con el `to = 1` que pasa, el tope queda acotado en
  **exactamente 1**.

Documentación frente a realidad, sobre el mismo mensaje de error cuya explicación da la cifra.
**Acotada y abierta.** La cifra ya no es un rango —el tope medido es 1, contra los 10 publicados—
pero la contradicción sigue sin explicar, y hay dos lecturas.

**Decidido el 2026-09-15 por el autor (D-040).** La discrepancia **se cuenta en la memoria tal cual
se ve**, con el experimento y las dos cifras, y **se nombra la hipótesis que la explicaría**: que
la diferencia esté en el tipo de cuenta, es decir, que la Sandbox gratuita del sondeo no sea la
«cuenta no aprobada» de la que habla el tope publicado. Ninguna fuente lo confirma, así que la
hipótesis va como hipótesis y **DISC-18 sigue abierta**; el YAML no cambia. Las dos lecturas de
abajo se conservan porque son el contenido de esa hipótesis.

- **(a) La documentación publica un tope que su API no aplica.** El `"up to 10 TO"` de [F20] es
  para «cuenta no aprobada» y la cuenta medida es una cuenta no aprobada, así que el proveedor
  dice 10 y acepta 1. Es la lectura que sostiene DISC-18, y la que el YAML da por buena hoy: el
  alias `unapproved_account` lleva la carga medida y una NOTA del provenance declara esa
  identificación como supuesto, no como equivalencia publicada.
- **(b) Sandbox es un estado propio y no «cuenta no aprobada».** El rechazo del límite de
  destinatarios únicos dice `"sandbox account"`, y la línea 993 de este fichero registra
  **Sandbox**, **Professional trial** y **Free** como tres estados distintos previos a un plan.
  Si Sandbox fuese uno más, el `10 TO, 1 CC, 1 BCC` de [F20] describiría un estado que esta
  medición no toca: **dejaría de estar contradicho y DISC-18 se caería**, y lo medido pasaría a
  ser el tope de `to` de Sandbox, coherente con los `"any 2 recipients"` de [F37].

Ninguna fuente leída dice cuál de las dos es cierta: no hay página que relacione Sandbox con el
estado de aprobación, ni cifra de `to` para Sandbox. `cc = 1` **coincide** con la documentación en
las dos lecturas (1 pasa, 2 falla). Consecuencia en el YAML desde D-025: el estado ya no queda
fuera —el alias `unapproved_account` lo modela en los siete bloques de endpoint, con la carga en
ámbar— y los 10/1/1 publicados siguen sin modelarse como valores; en `not_found`, en la NOTA del
provenance y en F-18.

### DISC-19 (sondeo) · Cabeceras del caudal: `x-ratelimit-*` en el 200 y en el 422, ausentes justo en el 429

- **[F20] general.html [VOLCADO]:** `"Please wait for the amount of seconds indicated by retry-after
  and try again."` · ejemplo `"HTTP/2 429"` · `"x-ratelimit-limit: 60"` · `"x-ratelimit-remaining: 0"`
  · `"retry-after: 59"` · `"x-ratelimit-reset: 1629291024"` · **[F31]:** `"Please wait for the amount
  of seconds indicated by the retry-after response header and try again."` · **[F36]** (SDK Python):
  `"For 429 responses the Retry-After header is respected if present."`
- **[E1] 2026-09-09:** las cinco respuestas 429 de la tanda 1 (`#MS42903`, 10/min en `/v1/email`
  y 1/min en `/v1/bulk-email`) traen únicamente `date`, `x-apiquota-remaining` y
  `x-apiquota-reset`. Ni `retry-after` ni `x-ratelimit-*` (el script archiva toda cabecera con
  `ratelimit`, `retry` o `apiquota` en el nombre). **Reproducido en la tanda 1b** (19:14:07–19:14:19):
  otras cinco respuestas 429 idénticas, sin esas cabeceras. Diez muestras en dos ventanas de un
  minuto.
- **[E1] tanda 2, 2026-09-10 (11:24:08–11:26:36 UTC):** **ningún 429** —el sexto objeto del lote
  respondió 422 tras los 61 s de espera—, así que la tercera ventana no llegó. Lo que sí aporta es
  el contraste: **doce de sus trece respuestas traen cabecera de caudal**, `x-ratelimit-limit: 10`
  con `x-ratelimit-remaining` de 9 a 5 en los cinco 422 de `/v1/email`, `60` con 59 y 58 en los dos
  200 de `GET /v1/bulk-email/{id}`, `1` con `0` en el 422 del lote de seis objetos y `10` con 9 a 6
  en los cuatro 422 de `tags` y `subject`. La única sin ellas es la lectura de `GET /v1/api-quota`.

Documentación frente a realidad, y con las tres tandas el contraste se afina: la API **sí emite**
`x-ratelimit-limit` y `x-ratelimit-remaining` —36 respuestas de las tres tandas, entre 422 de
validación, el 202 del lote y los 200 de `GET /v1/domains` y `GET /v1/bulk-email/{id}`— y deja de
emitirlas **justo en el 429**, que es la respuesta para la que [F20] y [F31] las publican y la que
[F36] necesita para reintentar. Ni `retry-after` ni `x-ratelimit-reset` aparecen en ninguna
respuesta de ninguna tanda. Así que lo contradicho no es «la API no da cabeceras de caudal», sino
que las da en todas partes menos donde hacen falta. **Abierta**: diez muestras en dos ventanas de
un minuto, una sola cuenta y sin aprobar, y la tanda 2 **no** añadió la tercera ventana porque no
provocó ningún 429. Sin consecuencia en el YAML: v0.3 no serializa cabeceras. Relevante para F-01
(el cliente no sabe cuánto esperar salvo por el texto del mensaje) y para el contrato del 429 que
[F36] da por sentado.

**No son DISC (complementos):** general.html `10 TO, 1 CC, 1 BCC` [F20] frente a [F39] `one CC and
BCC recipient` (cc/bcc = 1 en ambos; general.html añade el tope de `to`); [F31] `Free 100` frente a
[F20] sin fila Free.

---

## Contraste con el modelado previo (mailersend_v03.yaml, 2026-03-19) — evidencia de F-09

Regla: cada fila enfrenta lo que **dice el modelado previo**
(`/work/apis_consumption_model/datasheets/mailersend/mailersend_v03.yaml`, citado literal) con lo
que **dice hoy la fuente oficial** (cita y [Fn]). «Divergencia» = valor, unidad o estructura
distintos; «Coincide» = mismo valor hoy; «Sin fuente hoy» = el dato del modelado previo no está
publicado en ninguna página leída en esta pasada. Las filas incorporan lo que la tanda 2 corrigió.

| # | Dato | Modelado previo (2026-03-19) | Fuente oficial hoy (2026-09-08) | Veredicto |
|---|---|---|---|---|
| 1 | Planes | `plans: free, hobby, starter, professional` (cuatro) | `"Free plan"`, `"Hobby plan"`, `"Starter plan"`, `"Professional plan"`, `"Custom Enterprise plans"` [F2]; además estados **Sandbox** y **Professional trial** [F37] | **Divergencia parcial**: falta Enterprise (sin precio, admisible) y faltan los dos estados gratuitos previos a Free |
| 2 | Precio Hobby | `hobby: price: 5.60`, `period: 1 MONTH` | `"The Hobby plan costs $7 per month, or $6.30 per month with an annual plan."` [F2]; [F1] `"$7.00 /month"` · `"$ 6.30 /month"` `"$75.60 billed yearly"` con `"Save 10%"` | **Divergencia**: 5.60 no es ni el mensual ($7) ni el anual ($6.30). 5.60 = 7 × 0,8: descuento anual del 20 % que [F47] publicó en 2024 y que hoy es del 10 %; el 5.60 sigue publicado en [F11] (DISC-03). **F-09 con fecha**: el descuento cambió entre 2026-03-19 y 2026-09-08 (inferencia aritmética; el anuncio no se ha localizado) |
| 3 | Precio Starter | `starter: price: 28.00` | `"Starter plans start from as little as $35 a month, or $31.50 a month with an annual plan"` [F2]; [F1] `"$35.00 /month"` · `"$ 31.50 /month"` `"$378.00 billed yearly"` | **Divergencia**: 28.00 = 35 × 0,8 (valor de [F11] hoy). Mismo patrón que la fila 2 |
| 4 | Precio Professional | `professional: price: 88.00` | `"Professional plans start at $110 a month, or $99 a month with an annual plan"` [F2]; [F1] `"$110.00 /month"` · `"$99.00 /month"` `"$1,188.00 billed yearly"` | **Divergencia**: 88.00 = 110 × 0,8 (valor de [F11] hoy). Mismo patrón |
| 5 | Precio Free | `free: price: 0.0` | [F1] `"Free"` `"$0"`; [F2] `"500 emails a month for free"`; [F1] FAQ 11: tarjeta obligatoria `"we just ask that you provide this information to prevent abuse of the platform"` | Coincide |
| 6 | Cuota emails Free | `quota_500_emails_month: value: 500 … MONTH`, `window_type: rolling` | `"up to 500 emails a month"` [F2]; `"Free plans include up to 500 emails per month"` [F40]; además `"with a daily limit of 100 emails"` [F2] (DISC-11) | Valor **coincide**; `rolling` **sin fuente hoy** (DISC-12: `"resets every 30 days"` / `"next billing day"`; nadie dice ventana deslizante) |
| 7 | Cuota emails Hobby | `quota_5k_emails_month: value: 5000`, `window_type: rolling` | `"up to 5,000 emails every month"` [F2]; `"Hobby plans include up to 5,000 emails per month"` [F40]; [F1] `"5,000 emails /month"` | Valor **coincide**; ventana ídem fila 6 |
| 8 | Cuota emails Starter y Professional | `quota_50k_emails_month: value: 50000` en ambos | `"for an allowance of 50,000 emails per month"` [F2]; tabla `"Emails/month … From 50,000 | From 50,000"` [F2]; escalera de [F1]: Starter 50K → 1M, Professional 50K → 2M | **Coincide en el escalón mínimo**; el modelado previo no expresa que el volumen es **seleccionable** (`"You can select your plan size"` [F2]; selector `"How many emails do you plan to send?"` [F1]) → F-02 |
| 9 | Sobrecoste Hobby | `overage_cost: price: 1.20, value: 1000` | **`"$1.50 per 1,000 additional emails sent"`** [F2]; `"For Hobby plans, the price is $1.50 per 1,000 emails"` [F40]; [F1] `"Extra usage $1.50 /1,000 emails"` | **Divergencia**: 1.20 → 1.50 (+25 %). F-09. Además B6 exige precio unitario (0.0015) |
| 10 | Sobrecoste Starter y Professional | `overage_cost: price: 0.95, value: 1000` en ambos | **`"starting at $1.30 per additional 1,000 emails sent. The price per 1,000 emails decreases the larger your plan size."`** [F2]; `"starts at $1.30 per 1,000"` [F40]; [F1] `"Extra usage $1.30 /1,000 emails"` a 50K, decreciente por peldaño hasta `"$1.00"` (Starter 1M) y `"$0.50"` (Professional 2M) | **Divergencia**: 0.95 → 1.30 (+37 %). El 0.95 es exactamente el valor que [F47] fijó el 2024-07-29 para 50K (`"$35 Extra emails: $0.95/1,000"`): el modelado previo arrastraba una cifra de 2024. F-09 con **tres fechas** (0.90 → 0.95 → 1.30). Y el sobrecoste es **por peldaño** (F-08), no un valor por plan |
| 11 | Sobrecoste Free | sin `overage_cost` en `quota_500_emails_month` | `"none of which allow extra usage"` (Sandbox, Free, trial) [F2]; `"your sendings will be paused"` [F2] | **Coincide** (F-13 literal hoy) |
| 12 | Cuota diaria de peticiones | `quota_100_req_day` (free), `quota_1k_req_day` (hobby), `quota_100k_req_day` (starter), `quota_500k_req_day` (professional), `unit: requests`, `window_type: fixed_utc_midnight` | `"Daily API requests | 100 | 1,000 | 100,000 | 500,000"` [F2]; [F6] `"Free plan: 100 requests per day"` … `"Professional plan: 500,000 requests per day"`; [F20]/[F31] `"reset daily at midnight UTC"` | **Coincide** en valor, unidad y ventana. Matiz: [F2] dice `"daily limit of 100 emails"` para Free (DISC-11); Enterprise 500.000 [F31][F6] no modelado |
| 13 | Rate general 60/min | `rate_60_min` en `/*` de los cuatro planes | `"All API requests (excluding v1/email) | 60 requests per minute | 60 requests per minute"` [F31]; `"All API requests (excluding email endpoints): 60 requests/minute"` [F20]; [F39] | **Coincide** (y no varía con la reputación) |
| 14 | Rate `/v1/email` sana 120/min | `healthy_reputation: rate: rate_120_min` en `v1/email` de los cuatro planes | `"API requests to v1/email | 120 requests per minute* | 10 requests per minute"` [F31]; `"API requests to POST /v1/email: 120 requests/minute"` [F20]; MS42903 `"The default rate limit is 120 requests per minute for /email endpoints"` [F20] | **Coincide**. Hoy además: `"*Newly upgraded accounts may have a lower rate limit"` [F31], sin cifra → estado tercero no modelado |
| 15 | Rate `/v1/email` under review 10/min | `under_review_reputation: rate: rate_10_min` | `"10 requests per minute"` (columna `Under review reputation`) [F31] | **Coincide**. Las claves `healthy_reputation` / `under_review_reputation` son los **aliases** de v0.3 (README §3.4.3, con MailerSend como ejemplo); el catálogo no los ha usado hasta ahora (regla D2) — corrección del constructor, 2026-09-08, ver O-08 en `fricciones.md` y Q1 en `REVISION.md` |
| 16 | Rate `/v1/bulk` sana | `healthy_reputation: rate: rate_10_min` en **los cuatro planes**; `rate_15_min` y `rate_30_min` definidos y **no usados** | **`"Free plan: 10 API calls/min Hobby plan: 10 API calls/min Starter plan: 15 API calls/min Professional plan: 30 API calls/min Enterprise plan: 60 API calls/min"`** [F31]; [F21] `"10 for Sandbox and Hobby … 15 for Starter … 30 for Professional trial and Professional … 60 for Enterprise"`; pero [F20] y [F39] `"10 requests … per minute"` sin desglose | **Divergencia**: Starter 15 y Professional 30 en dos fuentes (DISC-08, **cerrada el 2026-09-14** a favor del desglose por plan: regla E4, D-028; los dos valores en 🟢). El modelado previo tenía los rates definidos y asignó 10 a todos |
| 17 | Rate `/v1/bulk` under review 1/min | `under_review_reputation: rate: rate_1_min` | `"1 request per minute"` [F31] | **Coincide** |
| 18 | Estados de reputación | dos: `healthy_reputation`, `under_review_reputation` | cuatro: `"Healthy"`, `"Under review"`, `"Rebuilding"`, `"Sending paused"` [F42]; más `"Newly upgraded"` [F31] y «not approved» [F39][F37][F20] | **Divergencia estructural**: rates publicados solo para dos estados; los demás sin cifra → `not_found` |
| 19 | Workload `/v1/email` máx. 70 | `workload: max: 70`, `"depends on the params you use, cc, to, bcc"` | `to` `"Min 1, max 50"` [F21]; `"cc … Max 10"`, `"bcc … Max 10"` (Free–Professional), **`"Max 50"` (Enterprise)** [F39]; MS42205 **`"Approved accounts can include up to 50 TO, 10 CC and 10 BCC recipients. Unapproved acounts can include up to 10 TO, 1 CC and 1 BCC recipients."`** [F20] | **Coincide como suma aritmética** (50+10+10) para cuentas aprobadas no-Enterprise, pero **70 no es literal** (D4 → 🟡). Hoy: **12** sin aprobar (la tanda 1 infirió 52; corregido por [F20]), 150 en Enterprise (🟡: nadie sube `to` sobre 50) |
| 20 | Workload `/v1/bulk` máx. 35.000 | `workload: max: 35000` | `"The number of email objects must not be greater than 500. #MS42229"` [F20]; `"500 individual email objects … each containing up to 50 TO recipients, 10 CC, and 10 BCC, for a total of 35,000 emails"` [F49] | **Coincide y hoy es literal** en [F49] (la tanda 1 lo daba como producto de dos límites, F-03). Con cuenta sin aprobar sería 500 × 12; en Sandbox 5 objetos [F21] |
| 21 | Cuota SMS Starter | `quota_100_sms_month: value: 100`, `overage_cost: price: 1.40, value: 100`; endpoint `v1/sms` con `rate_60_min` y workload `max: 50` | [F1] Starter `"100 SMS /month"` (50K; sube por peldaño hasta `"7,000"`); [F48][F12] `"Our base plan includes 100 SMS messages."` · `"$1.40 per 100 SMS messages"`; [F11] `"$1.40 €1.40 £1.40 /100 SMS"` | Valor y sobrecoste **coinciden** en el peldaño base; pero **fuera del YAML por A1** (F-10). Workload 50 y rate 60 del SMS no verificados |
| 22 | Cuota SMS Professional | `quota_150_sms_month: value: 150`, `overage_cost: price: 1.40, value: 100` | [F1] Professional `"150 SMS /month"` (50K; hasta `"15,000"`); [F11] `"$1.40 €1.40 £1.40 /100 SMS"` en la tarjeta Professional (página desactualizada); [F48] `"on this plan level"` se refiere al plan base | Valor **coincide**; sobrecoste 1.40 en Professional solo en [F11]. F-10 |
| 23 | `type: partial_saas` | `type: partial_saas` | [F1] `"Drag & Drop email builder"`, `"Bulk emailing"`; [F51] `"send a test email"` desde la ficha de plantilla; ninguna fuente dice que el panel envíe algo que la API no pueda ([H11]) | **Divergencia candidata**: lectura conservadora `api_first` en 🟡 (C1); decisión para el autor |
| 24 | `consumption_units: emails, requests, sms` | tres unidades en un YAML | Hoy además WhatsApp (`"Sep 1, 2026"` [F17]; [F1] `"$0.0050 per message"`; [F44] 2.5 `"billed by Meta"`) y créditos de verificación [F3] | **Divergencia de alcance**: por A1 solo `emails` y `requests` |
| 25 | Trial | no existe | `"14-day Professional trial"`: `"500 emails a month and 100 API requests a day"`, `"your account moves to the Free plan"`, `"one Professional trial"` por cliente [F37]; [F1] FAQ 1, 2, 8 | **Ausente en el modelado previo**. Variante de F-14 (caduca a Free, no a cero) |
| 26 | Sandbox | no existe | `"100 emails a month, with a cap of 100 API requests a day"`, `"any 2 recipients … until your account is approved"` [F37]; `"5 for Sandbox accounts"` [F21]; panel [F53] | **Ausente**. Estado con cuota de destinatarios únicos (2) que ningún campo de v0.3 recoge |
| 27 | Retención de actividad / logs | no modelado | `"Activity retention | 24 hours | 24 hours | 7 days | 30 days"`, `"Log retention | - | - | - | 7 days"` [F2]; logs Enterprise 14 días, trial 1 día [F43]; add-on 7–365 días por volumen [F3][F4] | Fuera de v0.3 (B4, PI-E03). Sin divergencia posible |
| 28 | Vigencia | `date: 2026-03-19` | Terms **`"Last updated on August 31, 2026"`** [F44]; `"We may modify or change our fees and pricing at any time … in-app beta pricing experiments that offer different rates to some users"` [F44]; Hobby plantillas 3 → 10 el `"Aug 24, 2026"` [F17]; [F11] conserva precios de 2024 el mismo día que [F1] publica los de hoy (DISC-03) | El proveedor ha cambiado términos y al menos un límite **después** del modelado previo; se reserva precios distintos por usuario; y mantiene dos ofertas publicadas a la vez. F-09 |

**Balance.** De los datos de capacidad y precio del modelado previo: **coinciden** hoy las cuatro
cuotas diarias de peticiones, las cuatro cuotas mensuales de emails (en su escalón mínimo), los
rates 60 / 120 / 10 / 1, el workload de 70 (como suma) y de 35.000 (hoy literal), y la ausencia de
sobrecoste en Free. **Divergen** los tres precios de plan (5.60 / 28.00 / 88.00 → $7 / $35 / $110
mensual, $6.30 / $31.50 / $99 anual; los valores del modelado previo siguen publicados en una
página de feature desactualizada [F11]), los dos sobrecostes (1.20 → 1.50; 0.95 → 1.30, y este
último era ya un valor de 2024-07-29; además el sobrecoste es por peldaño), el rate del bulk en
Starter y Professional (10 → 15 y 30), y la ventana de la cuota mensual (`rolling` no está en
ninguna fuente). **Faltan** en el modelado previo el trial, el Sandbox, la aprobación de cuenta, los
cuatro estados de reputación, Enterprise y la escalera plan × volumen. Y el SMS **sobra** por A1.

---

## Fuentes buscadas y NO encontradas

Fusión de las cuatro lentes, con el resultado de la tanda 2 donde un hueco se cerró («Resuelto en
[Fn]») o se acotó. Todas las consultas: 2026-09-08; las filas marcadas **[E1]** incorporan el sondeo
del 2026-09-09.

| Qué se buscó | Dónde | Resultado |
|---|---|---|
| Escalera completa volumen × precio × sobrecoste de Starter y Professional | [F1] (selector), [F2], [F19] | **Resuelto en [F1]** (tanda 2): no capturable con WebFetch (JS); el orquestador accionó el selector con el navegador y volcó las siete posiciones, mensual y anual. Escalón 2 bloqueado (muro de dominio aprobado, [F53]) |
| Sobrecoste por peldaño de volumen | [F1], [F2], [F14], [F16] | **Resuelto en [F1]**: `"$1.30"` → `"$1.10"` → `"$1.00"` (Starter) y `"$1.30"` → `"$0.50"` (Professional). El centro de ayuda solo dice `"starting at $1.30"` y `"decreases the larger your plan size"` |
| Precio y volumen de Enterprise | [F1], [F2], [F3], `/enterprise` (404), búsqueda web | **No publicado**: `"contact us"`. Solo se sabe que incluye 1 IP dedicada [F3], 5.000 dominios [F3], 500.000 peticiones/día [F6][F31], 30 días de retención [F3], logs 14 días [F43], cc/bcc 50 [F39], bulk 60/min [F21][F31] |
| Bloque/tarjeta Enterprise en la página de precios | [F1] (dos lecturas + volcado) | **No existe** (`"no hay tarjeta Enterprise en la página"`) |
| Precio del add-on de WhatsApp | [F1], [F3] | **Resuelto en [F1]** (tanda 2): `"$5.00"` · `"$0.0050 per message"` · `"Extra usage: $2.50/1,000"`; no está en [F3]. Producto aparte (F-10). La fila «no publicado» de la tanda 1 era falsa |
| Precio de usuarios adicionales / seats extra | [F1], [F3] | **No existe** como add-on: los seats son fijos por plan (5 / 5 / 1.000) |
| Precio de webhooks, tokens o plantillas adicionales | [F3] | **No existe** como add-on |
| Si el sobrecoste tiene tope del proveedor (como el 10× de SendGrid) | [F1], [F2], [F40] | **No publicado**; solo el tope **voluntario** del cliente (`"you can set a limit to prevent overusage"` [F2]; [F40]) |
| Hora o zona de reposición del límite diario de emails del Free (100/día) y del ciclo mensual | [F1], [F2], [F6], [F41], [F44] | Cuota diaria de **peticiones**: `"midnight UTC"` [F20][F31]. Cuota mensual: **no publicadas** hora ni día; `"resets every 30 days"` frente a `"next billing day"` (DISC-12). Plan anual: **no dicho** |
| Unidad de la cuota mensual de emails (¿petición, email-objeto o destinatario?) | [F20] `#MS42204`, [F21], [F49], [F50], [F39], /help/analytics, /help/faq (404), WebSearch (`"per recipient" OR "counted as" OR "counts as one email"`, `how are emails counted usage recipients`) | **Sin artículo propio.** /help/analytics: `"there are no sentences that explain how emails are counted"`. Solo la aritmética de [F49] (`"for a total of 35,000 emails"` = destinatarios) y `"total_recipients_count"` en el estado del bulk [F21] → **1 por destinatario en 🟡** ([H2]); escalón 3 inocuo desde Sandbox (2 `to`, leer `"Emails sent"`) |
| Código/estado de la API al agotar los 500/mes del Free o el *billing limit* | [F21], [F2], [F40], [F42], WebSearch `"x-send-paused" OR "sending paused"` | **No encontrado como respuesta de API.** Tres «pausas» con la misma palabra (cuota Free agotada [F2], *billing limit* [F40], estado de reputación [F42]); la API documenta `"x-send-paused: true"` sobre un 202 sin decir la condición [F21]; candidato 422 `"Email quota reached"` [F39]. Solo el sondeo lo fija ([H4]) |
| Interpretación de `#MS42204` | [F20] | **Resuelto en [F20]** (volcado): `"The account has a custom email quota due to compliance concerns"` — **no es la cuota del plan** |
| **Rate de `/v1/email` por plan** | [F20], [F21], [F31], **[E1]** | **No publicado por plan.** Un único 120/min (`"default"`, `"healthy reputation"`); 10/min «under review»; «newly upgraded» sin cifra. Regla D2. **[E1]:** la cuenta Sandbox no aprobada devuelve `x-ratelimit-limit: 10` y 429 `"rate limit of 10 requests/min"` en la 11.ª petición del minuto: el 10/min rige también para el estado **no aprobado**; el 120/min no es observable con esta cuenta |
| Tipo de ventana del rate por minuto (rolling / fija) | [F20], [F31], [F39], **[E1]** | **No dicho.** Solo `"per minute"`, `retry-after` en segundos y `x-ratelimit-reset` en marca Unix. **[E1]:** las diez peticiones y el 429 cayeron dentro del mismo minuto de reloj (19:02:20–19:02:56); no distingue ventana fija de deslizante, y los 429 no traen `x-ratelimit-reset` (DISC-19) |
| **Cabeceras `retry-after` y `x-ratelimit-*` en el 429 real** | [F20], [F31], [F36], **[E1]** | **Publicadas, no observadas** (DISC-19): las diez respuestas 429 del sondeo (cinco por tanda, dos ejecuciones) traen solo `date` y `x-apiquota-*` |
| **Qué peticiones cuenta la cuota diaria de peticiones** | [F20], [F31], [F32], **[E1]** | **Resuelto en [E1] tanda 1b** (DISC-17): `"Every request is counted"` se sostiene —las 17 de la tanda 1 (422, 429, 202, 200) aparecen descontadas 11 minutos después (`"remaining": 83`) y 14 de la tanda 1b de golpe (83 → 69)—; **lo no publicado** es que el contador de la cabecera y de `/v1/api-quota` se actualiza con retardo y por lotes, no por petición (retardo y disparador sin medir) |
| **Retardo y granularidad del contador expuesto de la cuota diaria** | [F20], [F31], [F32], **[E1]** | **No publicados.** [F32] solo dice `"Inspect how many MailerSend API requests you have remaining"`. Medido: lotes de 17 y 14; la lectura final de la tanda 1b (7 s después de la última petición) aún no reflejaba las tres últimas. O-11 |
| Si el rate es por cuenta, por token, por dominio o por IP | [F20], [F22], [F31], [F53] | **No dicho** para la API (`"Your account reached…"` sugiere cuenta; el panel muestra tokens «All» o por dominio, no la segmentación del límite). SMTP: `"based on IP address"` [F27] |
| **Tope total de destinatarios por petición** (`to`+`cc`+`bcc`) | [F21], [F20] `#MS42205`, [F39], [F49], **[E1]** | **No publicado como total.** 50/10/10 por campo (aprobada), 10/1/1 (sin aprobar), cc/bcc 50 (Enterprise) → 70 / 12 / 150 en 🟡 (D4). **[E1]:** no medible con la cuenta Sandbox no aprobada (`to ≥ 10` → MS42205); el 70 sigue 🟡 |
| **Tope de `to` y `bcc` para cuentas no aprobadas** | [F20] `#MS42205`, [F39], **[E1]** | **`to`: contradicho** (DISC-18): la doc dice 10, la API rechaza 10 (y 11, 50, 51) en las dos ejecuciones; 1 pasa. **Acotado en la tanda 2** (2026-09-10): `to = 2` ya responde `#MS42205`, así que el tope sin aprobar es **exactamente 1**. **`cc` = 1 confirmado** (1 pasa, 2 falla; dos ejecuciones). **`bcc`:** doc 1; medido solo que 10 y 11 fallan |
| **Cuenta del límite de destinatarios únicos de Sandbox** | [F37], [F20] `#MS42225`, **[E1]** | **Resuelto en [E1]:** `#MS42225` salta desde 3 direcciones distintas sumando `to`, `cc` y `bcc` (1+2 y 1+10 fallan, 1+1 pasa), informado en el campo `to`; igual en las dos ejecuciones |
| **Sexto objeto del lote en Sandbox y `validation_errors` de los lotes aceptados** | [F21], **[E1]** | **A medias, dos veces:** 5 objetos → 202 (`bulk_email_id` `6aa1ad527e48ed427f18cf4e` a las 19:02 y `6aa1affd1e3217ac0dd87aa1` a las 19:14); 6 objetos → 429 por el caudal de 1/min, sin validar, en las dos tandas. **Cerrado en la tanda 2** (2026-09-10): con 61 s de espera el lote de 6 responde 422 `"The number of email objects must not be greater than 5. #MS42229"`, y `C2_bulk_status_t1` y `C2_bulk_status_t1b` devuelven los dos lotes con `state: "completed"` y `validation_errors_count: 5` |
| **`tags` 5/6 y `subject` 998/999 medidos** | [F21], [F35], **[E1]** | **Medidos en la tanda 2** (2026-09-10): `tags = 5` y `subject` de 998 caracteres pasan la validación; `tags = 6` → `"The tags must not have more than 5 items."` y `subject` de 999 → `"The subject must not be greater than 998 characters."`. En las dos tandas del 2026-09-09 los cuatro casos habían respondido 429 sin validar (caudal de 10/min agotado por los casos B) |
| Tamaño máximo de la petición a `/v1/email` | [F21] | **No publicado.** Solo `text`/`html` 2 MB y adjunto 25 MB (decodificado); [F39] `"less than 25MB"`. Bulk sí: 50 MB JSON [F21] |
| Número máximo de adjuntos por email | [F21], [F20] | **No publicado** |
| Máximo de entradas o tamaño de `personalization` | [F21] | **No publicado** |
| Cifra del límite del dominio de prueba (`#MS42222`) | [F20], [F23], [F37], [F38], [F39], [F1] FAQ, WebSearch `"trial domain" emails limit mlsender.net` | **Sin cifra propia**: Explanation `"The email quota limit for your trial domain was reached."`; la única cifra de cuenta sin aprobar es 100 emails/mes [F37][F39]. Panel: `"Test domains are automatically deleted if not in use for 30 days."` [F53] |
| Cifra del límite de destinatarios únicos en Sandbox (`#MS42225`) | [F20], [F21] | **Resuelto en [F37]**: `"You can send to any 2 recipients in Sandbox mode, until your account is approved"` |
| Artículo de aprobación de cuenta y criterios («Get approved») | [F38], [F37], [F20], WebSearch `account approval get approved recipients limit` | **Sin artículo propio ni criterios.** Solo `"up to 48 hours"` [F38] y límites dispersos (12 destinatarios por objeto, 2 únicos, 100 emails/mes, 100 req/día) |
| Rate para cuentas «Newly upgraded», «Rebuilding» y «Sending paused» | [F31], [F42] | **Sin cifra** (`"may have a lower rate limit"`) |
| Umbrales que disparan «Under review» (tasa de 403/422/429, rebotes, quejas) | [F42], [F45], [F46] | **Sin cifra** (`"certain thresholds"`, `"High bounce rates"`) |
| Máximo de conexiones SMTP concurrentes | [F27] | **Resuelto en [F6]**: `"5 for Sandbox, Free, Hobby and Starter accounts, and 50 for Professional (including the professional trial) and Enterprise"`. [F27] solo publica `"single connection transaction limit set at 5"` |
| Tamaño máximo de mensaje y destinatarios por mensaje SMTP | [F27], [F6] | **No publicados** |
| Máximo de tokens, dominios, webhooks, plantillas, rutas inbound, usuarios SMTP en developers | [F22]–[F26], [F34] | **No publicados en developers**; cifras en [F2] (y [F1], [F6], [F37]) → `features.md` / F-11 |
| Disponibilidad de `/v1/bulk-email` en el plan Free | [F49], [F21], [F2], [F37], [F31], [F20] `#MS42216`, [F1] tarjeta Hobby, **[E1]** | **Free nunca nombrado.** Tres indicios a favor de «Free sin bulk» (tarjeta Hobby `"All in Free, plus: … Bulk emailing"`, [F2] lista de Hobby `"Access to the bulk email endpoint"`, MS42216) y dos a favor de «Free con bulk limitado» ([F31] `"Free plan: 10 API calls/min"`; Sandbox `"Bulk emailing included"` con 5 objetos) → `not_found` + escalón 3 barato ([H9]). **[E1]:** Sandbox tiene el endpoint (202 con 5 objetos, `x-ratelimit-limit: 1`); de Free sigue sin decir nada |
| Ticks (✓/—) de la tabla «Compare plans & features» de /pricing | [F1] (WebFetch y volcado de texto) | **No capturables por texto** (`"(Icon missing)"`). Sin fuente textual para Inbound routing por plan, Custom headers, MCP server, SLA, IP allowlisting, 2FA, Translations, Split testing, Custom tracking branding. Requiere `read_page` o captura del orquestador ([H8]) |
| Disponibilidad de inbound routing por plan en las páginas de la feature | [F7], [F8] | **No dicha** allí; [F1] tabla (Starter+), [F2] (rutas desde Free, prosa `"inbound routing"` en Free), panel [F53] (`"Upgrade plan"` en Sandbox) → DISC-05 |
| Plan mínimo para IP dedicada en el artículo de solicitud | [F10] | **No nombrado** (solo volumen y dominio autenticado). DISC-04 |
| Si el «test email» del editor de plantillas consume cuota; si el panel envía a destinatarios arbitrarios | [F51], [F52], panel [F53] (editor no abierto en modo lectura) | **No dicho** ([H11]) |
| Condición que activa `x-send-paused: true` | [F21], WebSearch | **No dicha** |
| Restricciones de la OpenAPI (`maxItems`, 429) | [F30] | **Ausentes** (`"Does not appear anywhere in the document."`). Solo `GET /api-quota` alude a la cuota. Fichero crudo **no descargable** (proxy 403) |
| Página propia del bulk (`/api/v1/bulk-email.html`) y de la cuota (`/api/v1/api-quota.html`) | developers.mailersend.com | **404** ambas; el bulk vive en `email.html#send-bulk-emails` [F21], la cuota en `other-endpoints.html` [F32] |
| Repositorio público del sitio de documentación (para volcado literal) | GitHub `mailersend/*`, búsqueda web | **No localizado.** Los SDKs sí son públicos [F35][F36] |
| Rate de `GET /v1/activity` en su propia página | [F33] | **No mencionado** allí; solo en [F20] (10/min) |
| Changelog de desarrollador / changelog general | `developers.mailersend.com/changelog`, `mailersend.com/changelog` | **404** ambos. Lo más parecido: `/whats-new` [F17] y `/newsroom` [F47] |
| Anuncio del paso de «Hobby gratuito 3.000/mes» (2024) a «Free 500/mes + Hobby $7» | [F17] (2 páginas), [F47], WebSearch en mailersend.com | **No localizado.** [F47] es el último anuncio de precios; el cambio ocurrió entre 2024-07-29 y 2026-03-19. El panel [F53] conserva un modal oculto con `"From December 2, we're introducing a fee of $7/month for the Hobby plan"` (sin año) |
| Anuncio del cambio de descuento anual (20 % en [F47] → `"Save 10%"` hoy) | ídem | **No localizado.** Solo se infiere por aritmética (contraste, filas 2–4) |
| Anuncio del cambio de sobrecoste $0.95 → $1.30 (Starter/Professional) y $1.20 → $1.50 (Hobby) | ídem | **No localizado** |
| Entrada «MailerSend Pricing Update» (`/whats-new/new-mailersend-pricing`) | URL devuelta por el buscador | **Redirige al índice** `/whats-new`; la entrada ya no existe |
| Página `/legal/terms-of-service` | mailersend.com | **404**; los términos están en `/legal/terms-of-use` [F44] |
| «Acceptable use policy» como documento propio | `/legal` | **No existe con ese nombre**: hay `anti-spam-policy` (no leída) y `api-use-policy` [F45] |
| Página `/help/faq` | mailersend.com | **404** (la devuelve el buscador) |
| Fecha de actualización de los artículos del centro de ayuda | [F2]–[F3], [F6], [F8], [F10], [F31], [F37]–[F43], [F49]–[F52] | **No la muestran** (solo [F44], [F45], [F4], [F17] y [F47] llevan fecha) |
| Sobrecoste de SMS en Professional (150/mes) | [F48], [F12], [F1] | **No publicado** en las páginas de producto; solo el del plan base (100) y la tarjeta desactualizada de [F11] |
| Página oficial con la política de vigencia de la prueba (qué pasa con los add-ons) | [F1] FAQ, [F37] | [F37]: `"your account moves to the Free plan"`, `"Add-ons and logo removal aren't included"` en el trial; recursos sobrantes `"paused rather than removed"` |
| Distribución por marketplace (bloque 1 del checklist) | `WebSearch` | Aparece un listado en **AWS Marketplace** (`aws.amazon.com/marketplace/pp/prodview-oxx6zfagmbpb2`), no consultado. RapidAPI: no buscado. Canal MailerLite con cupón [F19] |
| Nota al pie explicando `"Unlimited*"` en la propia página de precios | [F1] | Solo `"*Learn more about plan limits."` con enlace a [F2]; la cifra real (1.000 / 5.000) está en [F2] |
| Volcados (E2) de [F39], [F3], [F44], [F47], [F24], [F25], [F49] | — | [F39], [F3] y [F44] **hechos en la tanda 3** (parciales, 17:40–17:46 UTC; ver cada entrada). [F47], [F24], [F25] y [F49] siguen sin volcado (solo WebFetch; regla E2: recomendado, no exigido) |
| Modelado previo de MailerSend en el repositorio de la guía | `/work/apis_consumption_model/datasheets/mailersend/mailersend_v03.yaml` | **Consultado solo para contraste** (sección anterior); ningún dato del YAML sale de él |

---

## Tabla de correspondencia — identificadores provisionales de las lentes → [Fn]

| Provisional | [Fn] | URL / origen |
|---|---|---|
| P1 | [F1] | mailersend.com/pricing |
| P2 · S1 | [F2] | /help/plans-features-and-limits |
| P3 · S9 | [F3] | /help/plan-add-ons |
| P4 · S17 | [F4] | /whats-new/data-retention-add-on |
| P5 | [F5] | /features/smtp-relay |
| P6 · S6 | [F6] | /help/smtp-relay |
| P7 | [F7] | /features/inbound-emails |
| P8 | [F8] | /help/inbound-route |
| P9 | [F9] | /features/dedicated-ip-email |
| P10 | [F10] | /help/how-to-request-dedicated-ip |
| P11 | [F11] | /features/email-verification-tool |
| P12 | [F12] | /features/sms-api |
| P13 | [F13] | /features/webhooks |
| P14 | [F14] | /compare/sendgrid-alternative |
| P15 | [F15] | /compare/mandrill-alternative |
| P16 | [F16] | /compare/amazonses-alternative |
| P17 · S16 | [F17] | /whats-new |
| P18 | [F18] | /features |
| P19 | [F19] | mailerlite.com/pricing-mailersend |
| D1 | [F20] | developers.mailersend.com/general.html |
| D2 · D3 | [F21] | developers.mailersend.com/api/v1/email.html (envío simple y bulk) |
| D4 | [F22] | /api/v1/tokens.html |
| D5 | [F23] | /api/v1/domains.html |
| D6 | [F24] | /api/v1/webhooks.html |
| D7 | [F25] | /api/v1/templates.html |
| D8 | [F26] | /api/v1/inbound.html |
| D9 | [F27] | developers.mailersend.com/smtp-relay.html |
| D10 (portada) | [F28] | developers.mailersend.com/ |
| D10 (SDK) | [F29] | developers.mailersend.com/sdk.html |
| D11 · H15 | [F30] | SwaggerHub OpenAPI 1.0.0-oas3.1 |
| D12 · S5 | [F31] | /help/rate-limits-how-to-reduce-403-422-429-errors |
| D13 | [F32] | /api/v1/other-endpoints.html (GET /v1/api-quota) |
| D14 | [F33] | /api/v1/activity.html |
| D15 | [F34] | /api/v1/smtp-users.html |
| D16 | [F35] | SDK PHP (raw.githubusercontent.com, 4 ficheros) |
| D17 | [F36] | SDK Python README |
| S2 | [F37] | /help/sandbox-mode-and-the-professional-trial |
| S3 | [F38] | /help/getting-started |
| S4 | [F39] | /help/how-to-start-sending-emails |
| S7 | [F40] | /help/how-to-set-a-billing-limit |
| S8 | [F41] | /help/how-to-change-or-cancel-your-plan |
| S10 | [F42] | /help/account-reputation-statuses |
| S11 | [F43] | /help/api-smtp-logs |
| S12 | [F44] | /legal/terms-of-use |
| S13 | [F45] | /legal/api-use-policy |
| S14 | [F46] | /help/about-mailersends-refund-and-account-policies |
| S15 | [F47] | /newsroom/price-and-plans-changes |
| S18 | [F48] | mailersend.com/sms-api |
| [P] (volcado de pricing citado por la lente de soporte) | [F1] | — |
| H1 | [F1] (escalera) | — |
| H2 | [F49] (URL A) · [F39] (URL B) · [F50] (URL C) · [F21] (URL D) | — |
| H3 | [F20] (URL A) · [F39] (URL B) · [F49] (URL C) · [F37] (URL D) | — |
| H4 | [F20] · [F2] · [F40] · [F21] · [F39] · [F42] | — |
| H5 | [F11] (URL A) · [F1] (URL B) · [F5] (URL C) · [F13] (URL D) | — |
| H6 | [F5] · [F13] · [F14] · [F1] · [F2] | — |
| H7 | volcados de [F31], [F6], [F37], [F40], [F42]; relecturas de [F39], [F3], [F44], [F47] | — |
| H8 | [F1] · [F2] | — |
| H9 | [F21] · [F49] · [F31] · [F2] · [F37] · [F1] · [F20] | — |
| H10 | [F1] · [F3] · [F44] | — |
| H11 | [F51] (URL A) · [F52] (URL B) | — |
| H12 | [F1] (URL A) · [F41] (URL B) · [F2] (URL C) · [F44] (URL D) | — |
| H13 | [F20] · [F39] · [F37] · [F1] · [F53] | — |
| H14 | [F38] (URL A) · [F37] (URL B) · [F20] (URL C) | — |
| H16 | [F1] | — |
| H17 | [F21] | — |
| H18 | [F20] | — |
| panel_observacion.md | [F53] | Panel de cuenta (escalón 2) |
| probe_sandbox_limites_2026-09-09.json | [E1] | Sondeo empírico con cuenta Sandbox no aprobada (escalón 3), 2026-09-09, tanda 1 (19:02 UTC, 18 casos) |
| probe_sandbox_limites_2026-09-09_tanda1b.json | [E1] | Segunda ejecución del mismo script, 2026-09-09, tanda 1b (19:13 UTC, 19 casos, con `A_api_quota_final`) |
| probe_sandbox_limites_t2_2026-09-10.json | [E1] | Tercera ejecución, script distinto (`probe_mailersend_sandbox_t2.sh`), 2026-09-10, tanda 2 (11:24–11:26 UTC, 13 casos: acota `to`, valida el sexto objeto del lote, consulta el estado de los dos lotes aceptados, mide `tags` y `subject`) |
| DISC-17 / 18 / 19 | — | Abiertas por [E1] tanda 1 (documentación frente a realidad medida); DISC-17 **resuelta** por la tanda 1b; DISC-18 y DISC-19 reproducidas, abiertas (DISC-18: la tanda 2 acota el tope de `to` en 1, ver entrada [E1]) |
| DISC-P1 / P2 / P3 / P4 / P5 / P6 | DISC-01 / 02 / 04 / 05 / 06 / 07 | — |
| DISC-D1 / D2 / D3 | DISC-08 / 09 / 10 | — |
| DISC-S1 / S2 / S3 / S4 / S5 | DISC-11 / 05 / 12 / 04 / 13 | — |
| DISC-H1 / H2 / H3 / H4 | DISC-03 / 14 / 15 / 16 | — |

> **Corrección del 2026-10-31 (página de feature [F11]).** Con navegador, [F11] da hoy los mismos
> precios que /pricing (`"$ 6.30 /month"`, `"$75.60 billed yearly"`). El bloque «desactualizado» de
> 2024 está en el HTML que el servidor envía antes de ejecutar JavaScript, en [F11] y en [F1], y la
> lectura de [F11] de la tanda 1 se hizo con `WebFetch`, sin JavaScript. DISC-03 la produce el modo de
> lectura, no una página del proveedor que se contradiga para el cliente.
> Evidencia: `evidencias/paginas/2026-10-31/LEEME.md`.
