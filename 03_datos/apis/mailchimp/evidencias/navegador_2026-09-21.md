# Transcripciones con navegador renderizado — Mailchimp Transactional · 2026-09-21

Método: navegador con la sesión iniciada del autor, páginas renderizadas y texto extraído del
DOM servido. No hay resumen de herramienta en este fichero: lo que va entre comillas es lo que
la página sirve (E10, E13).

Cierra cuatro ámbares que `REVISION.md` había dejado con la vía escrita: el literal en inglés
del plan Essentials, la premisa de la franquicia que no caduca, la pantalla de plantillas del
panel que faltaba para el test C2/D9, y si la cola del sondeo descontó algo.

---

## P1 · Referencia de API del proveedor, en su propio dominio

**URL:** https://mailchimp.com/developer/transactional/api/ · **consultada:** 2026-09-21
**Título servido:** «Mailchimp Transactional API Reference | Mailchimp Developer» ·
**versión declarada en la página:** «v. 1.4.1»

La página lista los endpoints por bloques. Transcripción del bloque que decide el test C2/D9,
el de plantillas:

```
Templates

Manage templates created via the Mandrill UI or through the /templates endpoint.

Add template            POST  /templates/add
                        Add a new template.
Get template info       POST  /templates/info
                        Get the information for an existing template.
Update template         POST  /templates/update
                        Update the code for an existing template. If null is provided for any
                        fields, the values will remain unchanged.
Publish template content POST /templates/publish
                        Publish the content for the template. Any new messages sent using this
                        template will start using the content that was previously in draft.
Delete template         POST  /templates/delete
                        Delete a template.
List templates          POST  /templates/list
                        Return a list of all the templates available to this user.
Get template history    POST  /templates/time-series
                        Return the recent history (hourly stats for the last 30 days) for a
                        template.
Render html template    POST  /templates/render
                        Inject content and optionally merge fields into a template, returning
                        the HTML that results.
```

Las otras dos operaciones del test, también en esta misma página:

```
Messages
Send new message        POST  /messages/send
                        Send a new transactional message through the Transactional API.

Senders
Add sender domain       POST  /senders/add-domain
                        Adds a sender domain to your account. Sender domains are added
                        automatically as you send, but you can use this call to add them ahead
                        of time.
Verify domain           POST  /senders/verify-domain
                        Sends a verification email in order to verify ownership of a domain.
                        Domain verification is a required step to confirm ownership of a
                        domain.
```

Y el caudal del endpoint de búsqueda, que es el único con cifra de toda la API:

```
Search messages by date POST  /messages/search
                        Search recently sent messages and optionally narrow by date range,
                        tags, senders, and API keys. If no date range is specified, results
                        within the last 7 days are returned. This method may be called up to
                        20 times per minute. If you need the data more often, you can use
                        /messages/info.json to get the information for a single message, or
                        webhooks to push activity to your own application for querying.
```

**Lo que esto cambia.** Las tres operaciones que deciden el `type` están publicadas en el
dominio del proveedor, no solo en el contrato máquina de GitHub. El test C2/D9 queda entero
sin depender de DISC-01.

**Lo que esta página NO enseña.** No hay enlace a una especificación OpenAPI, ni mención de
ella, en ningún punto del texto servido. La ausencia es el dato: el fichero
`transactional.openapi.json` de la organización de GitHub del proveedor no está enlazado desde
la referencia oficial.

---

## P2 · Página de precios en inglés, con el descargo completo

**URL:** https://mailchimp.com/en/pricing/transactional-email/ · **consultada:** 2026-09-21

El literal que `fuentes.md` traía de resumen de herramienta era `"Essentials plans are not
eligible."`. La página no dice eso. Dice, dentro de «*Disclaimers», en el apartado «50% Off 1M+
Emails 12 months Offer Terms»:

```
Essentials plan is not eligible for Transactional Email.
```

Y el párrafo entero donde vive, transcrito:

```
50% off the monthly base price of Transactional Email at 1,000,000 or more emails (40 or more
blocks) for the first 12 (twelve) months of service, starting from the date of enrollment,
followed by the then-current monthly list price based on your monthly Transactional Email
subscription. A block contains 25,000 transactional emails. To be eligible, you must be a new
Mailchimp Transactional Email customer and enroll or be currently enrolled in a Standard or
Premium marketing plan or Legacy Monthly plan (each a "Paid Marketing Plan") with an account
created within the last 90 days in select countries, and sign up for the Mailchimp
Transactional Email monthly plan and purchase a minimum of 1,000,000 emails (40 or more
blocks). Essentials plan is not eligible for Transactional Email. Mailchimp accounts with
compliance holds or violations are ineligible.
```

La escalera de tramos, en inglés y verbatim, con la fila de cabecera tal como se sirve:

```
Each block is a credit for 25,000 emails
TOTAL BLOCKS      EMAILS PER MONTH      PRICE PER BLOCK
1 to 20 blocks    1 to 500k emails      $20/block
21 to 40 blocks   500k to 1M emails     $18/block
41 to 80 blocks   1M to 2M emails       $16/block
81 to 120 blocks  2M to 3M emails       $14/block
121 to 160 blocks 3M to 4M emails       $12/block
161+ blocks       4M+ emails            $10/block
```

Y el asterisco de la franquicia, que en `fuentes.md` estaba parafraseado como «can receive up
to 500 free emails to their verified domain (restrictions apply)»:

```
*New transactional email users can get up to 500 free email sends to their verified domain.
Restrictions apply.
```

---

## P3 · La página de ayuda de la demo, que es la fuente de la franquicia

**URL:** https://mailchimp.com/help/transactional-email-demo/ · **consultada:** 2026-09-21

Transcripción del apartado «Limitations», entero:

```
The Mailchimp Transactional demo includes the following limitations:

Each eligible Mailchimp account may only enroll in the demo once.
You can send up to 500 transactional emails to any email address on your verified domain.
You can send up to 25 emails in an hour and receive up to 100 inbound emails per day.
The emails included with the demo do not expire or renew.
Click tracking is not enabled for demo accounts.
Your transactional email history is stored for only 30 days. After that, you will not be able
to see the contents of the transactional emails or to whom the emails were sent.
You immediately lose access to the demo if:
    Your Mailchimp account is paused or closed.
    You have a compliance hold.
    You send 500 emails.
```

Y el apartado «Requirements»:

```
Have an active Mailchimp account in good standing. The account can be free or paid, but cannot
be paused or have a billing or compliance hold.

Be a new user of Mailchimp Transactional. If you've previously purchased transactional email
blocks, or purchased a Mailchimp Transactional plan, you are not eligible.
```

**Tres cosas que esta página cierra.**

La primera es la premisa de la franquicia sin ventana: «The emails included with the demo do
not expire or renew» es literal, no inferencia.

La segunda es la retención. `metadata.not_found` declaraba que ninguna fuente revisada publica
los días de retención de la actividad. Esta los publica: treinta días, y dice qué se pierde al
pasarlos.

La tercera es el agotamiento. «You immediately lose access to the demo if: […] You send 500
emails» ata el fin de la demo al consumo, no a una fecha, que es la otra mitad de por qué no
hay ventana.

---

## P4 · Panel, portada de la cuenta, después del sondeo

**URL:** https://mandrillapp.com/ · **consultada:** 2026-09-21, unas dos horas después de
cerrar el sondeo A que dejó unos 7.600 destinatarios en cola.

```
Account Overview
Last reset on September 16, 2026

You're currently on our free trial plan that includes 500 total sends and 30 days of technical
support. Upgrade through your Mailchimp account to send more than 500 emails, or to get access
to paid features and extended technical support.

Reputation        Unknown
Deliverability    0.0%
Sends This Month  0

Month plan usage
Free trial sends   0 of 500     0%
SMS credits        0 of 0       0%

Hourly sends
Email sends this hour   0 of 25   0%

No Sending Domains
You don't have any sending domains set up yet. To start sending through Mandrill, you need to
verify ownership of your sending domain and update your DNS records.
```

**Lo que mide.** La cola del sondeo no descontó nada. Ni la franquicia —`0 of 500`—, ni el
contador mensual —`Sends This Month 0`—, ni el horario —`0 of 25`—. Los ~7.600 destinatarios
encolados el 2026-09-21 drenan hacia rechazo sin tocar ningún contador de consumo, lo que es
coherente con `sent: 0` que ya daba la API. Es la celda *(verificar)* de F-21, y queda medida:
**en Mandrill, encolar no consume**.

**Un dato nuevo y sin conciliar:** «Last reset on September 16, 2026». El panel lo pone sobre
el bloque de contadores y no dice qué se reinició ni cada cuánto. La cuenta se dio de alta ese
día, así que la lectura más simple es que marca el alta y no un ciclo. No se adopta como ancla
de ninguna ventana: D8 dice que la periodicidad no es ancla, y aquí ni siquiera hay
periodicidad declarada.

---

## P5 · Panel, pantalla de plantillas

**URL:** https://mandrillapp.com/templates · **consultada:** 2026-09-21

```
You don't have any templates yet.

You can add a template below, use Mandrill's API or from your attached Mailchimp account.

Create a template
```

**Lo que cierra.** Es la comprobación que faltaba para el test C2/D9. La pantalla existe en el
panel, y el propio panel remite a la API como vía alternativa —«use Mandrill's API»—, así que
crear plantilla no es exclusiva de la web. Ninguna de las tres operaciones eliminatorias vive
solo en el panel, y el veredicto `api_first` queda con el test entero.
