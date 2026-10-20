# Matriz funcional — Brevo (D-019, CRITERIOS G)

Construida el 2026-09-16 desde `fuentes.md` y **sin fuentes nuevas**. Regla **G2**: celda
«—» donde ninguna fuente registrada lo dice; nada se infiere de otro plan ni de otra API.
Escalón: **doc** = documentación pública ([F1] precios, [F2] «see all features», [F3]
créditos prepago, [F4] IP dedicada, [F5] página de producto, [F17] SMTP, [F19] webhooks
agrupados, [F24] límites del Free, [F25] planes de precios del centro de ayuda, [F26]
añadir o quitar correos). **Escalón 2 (panel) no ejecutado**, así que **ninguna celda lleva
escalón panel** y todo lo que solo se ve dentro de la cuenta queda fuera. Producto
modelado: Email API transaccional; los cinco planes tienen tarjeta y entran en el YAML
(A3). Fecha de validez: 2026-09-16.

**Aviso sobre la captura.** [F2] es una tabla de marcas y cruces. Donde la fila solo trae
✓/✗ sin prosa, la celda dice **sí** o **no** citando el rótulo de la fila, que es lo único
literal que hay; donde ni siquiera la fila existe, la celda es «—».

## Features por plan

| Feature | Free | Starter | Standard | Professional | Enterprise | Fuente · escalón |
|---|---|---|---|---|---|---|
| Webhooks de eventos (salientes) | sí (`"Outbound webhooks"`; `"Webhook support"` [F5]) | sí | sí | sí | sí | [F2] doc (`"Outbound webhooks"` con marca en los cinco planes) · [F5] doc. **Número de webhooks por plan: —** (ninguna fuente lo publica). Entrega agrupada: `"Each batch contains up to 500 events by default."`, ventana de 5 minutos, sin distinguir plan [F19] |
| Entrada de correo (inbound) | no | no | no | sí | sí | [F2] doc (`"Inbound webhooks"` — `"Receive real-time events from external sources to update data and objects in Brevo and trigger automations."` :: cruz en Free, Starter y Standard; marca en Professional y Enterprise). **Atención:** ese literal describe eventos externos, **no correo entrante**; la ruta `GET /v3/inbound/events` se atribuye a esos dos planes por inferencia y así consta en `metadata.not_found` |
| IP dedicada | no | no | no | add-on `"$251.00"` `"per year per dedicated IP"` | incluida | [F2] doc (cruz en Free, Starter y Standard; `"Add-on"` en Professional; marca en Enterprise) · [F4] doc (`"Available as a paid add-on for Professional plan, included in Enterprise."`) · [F25] doc (`"💰 A dedicated IP costs $251 per year."`, único add-on que coincide en las dos fuentes — DISC-08) |
| Retención de actividad / logs | **1 a 24 meses, lo fija el cliente** | sí, sin periodo | sí, sin periodo | sí, sin periodo | sí, sin periodo | [F30] panel (`"The logs will be deleted after [ ] months"`, control con `min=1` y `max=24`, y `"Transactional logs are stored only for a limited time. Once the retention period ends, they will be deleted automatically."`) · [F2] doc (`"Customized log retention"` con marca en los cinco planes) · [F1] doc dice `"unlimited log retention"`, que **no es una duración**: DISC-10. El techo de 24 meses está medido **solo en la cuenta Free** |
| Dominios de envío | **sin tope publicado** (panel: `"Add a domain"`, cero dominios) | — | — | — | — | [F30] panel. Ninguna de las 30 fuentes publica dominios por plan; el panel tiene el botón de alta y **ninguna cifra al lado**. Hueco documentado en `fuentes.md` |
| Usuarios | `"Single user"` | `"Single user"` | `"Up to 3 (add-on)"` | `"10 included"` | `"Unlimited"` | [F2] doc (`"Users"` — `"Single user \| Single user \| Up to 3 (add-on) \| 10 included \| Unlimited"`). Asientos de marketing: `"1 marketing seat included. $12.00 per month per additional seat."` con `"Add up to 2 additional Marketing users."` (Standard, USD y `"Monthly"`) [F1], por D17; `"💰 Each additional marketing seat costs $9 per month."` [F25] es incoherencia del pricing (**DISC-08**, cerrada) |
| SMTP | sí (`"Full API and SMTP access"` [F5]) | sí | sí | sí | sí | [F2] doc (`"Transactional email (API/SMTP)"` — `"Send time-sensitive emails triggered by user actions like purchases or sign-ups—via Email API or SMTP relay."` :: marca en los cinco planes) · [F5] doc · [F17] doc (puertos 587, 2525 y 465). **Límites del canal: —** — [F17] no publica ni conexiones simultáneas, ni mensajes por conexión, ni destinatarios por mensaje. Lo único que sí dice es una asimetría cualitativa: `"The SMTP relay does not support batch sending."` (F-15) |
| Plantillas | **sin tope publicado** (panel: `"Create Template"`, `"You have not created any Email templates."`) | — | — | — | — | [F30] panel. Ninguna fuente publica plantillas por plan. La especificación serializa el tope de paginación de `GET /smtp/templates`, que es de consulta y no de capacidad |

## Otras features registradas

| Feature | Free | Starter | Standard | Professional | Enterprise | Fuente · escalón |
|---|---|---|---|---|---|---|
| Volumen de correo incluido | `"300/day"` | `"Up to 100k"` | `"Up to 500k"` según el bloque `"Key features"` y `"Up to 1M"` según el de `"Email marketing"` — **DISC-06** | `"Up to 10M"` | `"Custom"` | [F2] doc. Volumen **de entrada** (el que lleva el YAML): Starter `"From 5,000 emails per month"`, Professional `"From 150,000 emails per month"` [F1]; Standard `"Starting at $18/month for 5,000 emails/month"`, única fuente que lo cifra [F5] |
| Acceso a la API transaccional | sí | sí | sí | sí | sí | [F2] doc (`"APIs"` :: marca en los cinco planes) · [F1] doc (`"Yes! All Brevo plans give you access to transactional email features, including RESTful APIs, SMTP, outbound webhooks, unlimited log retention, and more."`) |
| Tope de contactos (acoplado al escalón de correos) | `"Up to 100K contacts"` | `"Up to 500K contacts"` | `"Up to 500K contacts"` | `"Up to 2M contacts"` | `"Unlimited"` | [F2] doc. Dentro de Starter el tope sube con el escalón (`"5k emails/month"` → `"500 contacts"`; `"10k"` → `"1,500"`; `"15k"` → `"2,500"`; `"20k"` y superiores → `"500,000"`) [F1]. Rebasarlo **sube el plan solo**: `"If you reach or exceed that limit, we will automatically upgrade your plan to the next tier."` [F25] (F-27) |
| Precio por correo excedido | — | — | — | — | — | **Ninguna fuente lo publica en ningún plan**, y la página de precios lo niega: `"There are no hidden fees with Brevo. Sign up for a plan or purchase credits as you need them, there are no additional fees."` [F1]. Es el hallazgo central de la pasada (F-27) |
| Cola de reintento al agotar la cuota | `"up to 1,000 additional emails are held in a retry queue. Emails beyond this queue are not delivered."` (precedido de `"Transactional emails:"`) | — | — | — | — | [F24] doc, repetido sin ese encabezado en [F26], que es del mismo centro de ayuda. Solo se publica para el Free (F-24) |
| Créditos prepago | `"Purchase credits to send emails with no daily sending limit and without the Brevo logo. No expiration date."` | ídem | ídem | ídem | ídem | [F3] doc (`"$32.00"` 5.000 · `"$59.00"` 10.000 · `"$95.00"` 20.000 · `"$165.00"` 50.000 · `"$275.00"` 100.000 · `"$940.00"` 500.000 · `"$1,600.00"` 1.000.000) · [F25] doc (`"Prepaid email credits are available as an add-on on all plans."`). **Cambian el plan efectivo:** `"Prepaid email credits give you access to all Starter plan features and the Remove Brevo logo add-on."` [F25] (F-07) |
| Quitar el logo de Brevo | add-on | add-on | add-on | add-on | add-on | `"No Brevo logo"` `"$12.00 per month"` [F1] (USD y `"Monthly"`), por D17; `"💰 The Remove Brevo logo add-on costs $9 per month."` [F25] es incoherencia del pricing (**DISC-08**, cerrada). Incluido con créditos prepago [F25] |
| SSO & SAML | — | — | — | `"Add-on"` | sí | [F2] doc · [F25] doc (`"💰 The SAML SSO add-on costs $324 per month."`, sin decir a qué planes) |
| SLA | — | — | — | — | `"SLA (99.9% uptime)"` | [F2] doc (solo Enterprise) · [F5] doc (`"Enterprise plan: Custom pricing for high-volume senders with dedicated IPs and custom SLAs"`) |
| SMS transaccional (API) | sí | sí | sí | sí | sí | [F2] doc (`"Transactional SMS (API)"` :: marca en los cinco planes). Producto aparte (A1, F-10); su caudal es `"POST /v3/transactionalSMS/send \| 540,000 RPH \| 150 RPS"` [F6] |
| WhatsApp transaccional (API) | no | no | no | sí | sí | [F2] doc (`"Transactional WhatsApp (API)"` :: cruz en Free, Starter y Standard) |
| Modo sandbox | sí | sí | sí | sí | sí | [F16] doc (`"Add the X-Sib-Sandbox header with the value drop to your request."`, `"No emails are sent to recipients"`). Ninguna fuente lo condiciona al plan; la celda dice lo que la fuente dice, que es que es una cabecera de la API |
| Alojamiento de datos | `"France and Germany (EU-based servers)"` | ídem | ídem | ídem | ídem | [F5] doc. Sin distinción por plan en la fuente |
| Aprobación previa de la cuenta | `"Once we approve your account for sending, you can start sending up to 300 emails per day."` | — | — | — | — | [F1] doc · [F9] doc (código de error `"account_under_validation \| Account is pending validation"`). **Sus topes no se publican**, así que por D7 no genera alias de estado |
| Pago anual | `"$0.00/month"` | `"$96.96"`/año (`$8.08`/mes equivalente) | `"$194.04"`/año (`$16.17`) | `"$5388.96"`/año (`$449.08`) | `"Custom Price"` | [F1] doc (`"Yearly (-10%)"`) · [F25] doc (`"you pay once a year instead of every month, and you get a 10% discount"`). Precios **sin impuestos**: `"The prices shown in this article and on our pricing page are exclusive of taxes."` [F25] (F-26) |
| Divisa | \*ocho\* | \*ocho\* | \*ocho\* | \*ocho\* | \*ocho\* | [F1] doc: `"EUR (Euro)"`, `"USD (US Dollar)"`, `"GBP (British Pound)"`, `"BRL (Brazilian Real)"`, `"INR (Indian Rupee)"`, `"CAD (Canadian Dollar)"`, `"AUD (Australian Dollar)"`, `"CHF (Swiss Franc)"`, con geolocalización y cifras que **no son conversiones** (9 USD frente a 7 EUR). Ninguna se declara canónica (F-26, Q8) |

## Preguntas de clase L instanciadas

- **PI-E01** «¿Incluye el plan Free de Brevo webhooks de eventos?» → **sí**, y con el matiz
  que solo la matriz enseña: los **salientes** los llevan los cinco planes (`"Outbound
  webhooks"` [F2], `"Webhook support"` [F5]), y los de **entrada** no —`"Inbound
  webhooks"` está en cruz en Free, Starter y Standard, y solo con marca en Professional y
  Enterprise [F2]—. Cuántos webhooks admite cada plan **no se publica**, así que la
  pregunta se responde en su forma binaria y no en la numérica.

- **PI-E02** «¿Qué API me da IP dedicada al menor precio para 200.000 correos al mes?» →
  Brevo **cualifica**, y su add-on es el más barato de los cuatro que el catálogo tiene
  cifrados: `"$251.00"` `"per year per dedicated IP"` [F4], unos **20,92 $/mes**, frente a
  `"$30 / mo"` en Resend, `"Starts at $50/month per IP"` en Postmark y `"$50/month per IP"`
  en MailerSend (sus `features.md`). Pero la respuesta útil no es el precio del add-on, y
  eso solo lo enseña la matriz: la IP es `"Available as a paid add-on for Professional
  plan"` [F4], y el Professional arranca en `"From 150,000 emails per month"` por
  `"$499.00"` [F1], con el escalón de 250.000 en `"$599.00"`. El **coste de cualificar** es
  un orden de magnitud mayor que el add-on mismo, y comparar solo los 251 $ daría la
  respuesta al revés. La comparación completa entre APIs es de la memoria, no de este
  fichero: aquí queda instanciada la pregunta y la cifra de Brevo con su cita.

- **PI-E03** (retención) **queda respondida el 2026-09-18, y por el panel**: las tres
  fuentes documentales no publican periodo, pero el control de la cuenta lo tiene escrito
  —`"The logs will be deleted after [ ] months"`, con `min=1` y `max=24`—, así que la
  retención **la fija el cliente entre 1 y 24 meses** [F30]. Sigue siendo el caso que G3
  anticipa —límite no consumible que pertenece al esquema, F-09—, con el matiz que ahora se
  puede decir: el periodo no lo pone el proveedor, lo pone el cliente, y el techo está
  medido solo en la cuenta Free.

## Lo que esta matriz no puede cerrar sin panel

Eran ocho filas, y el escalón 2 ha cerrado o acotado cinco. **Cerrada**: el periodo de
retención, 1 a 24 meses [F30]. **Acotadas con lo que el panel enseña y sin cifra por plan**:
dominios de envío y plantillas —hay botón de alta y **ningún tope publicado**, con cero
creados en esta cuenta—, el número de claves de API y SMTP —mismo caso, botón de generar y
ninguna cifra— y el precio de los add-ons, que el panel da **en euros** (`"€9.00 per month"`
el logo, `"Starting at €29.00 per month"` los paquetes de ventas, `"From €228.00 per year"`
la IP) sin arbitrar por eso el par en dólares de DISC-08. Ese par lo cerró D17 el 2026-10-18:
vale la página en USD y `"Monthly"` (`$12.00` el logo, `$65.00` por usuario Sales Advanced,
`$12.00` el asiento), y el centro de ayuda queda como incoherencia del pricing.

**Siguen sin cerrar tres**: el número de webhooks por plan, los límites del canal SMTP y el
escalón `"More"` de los tres deslizadores. Las tres necesitan una cuenta de pago o una
pantalla que esta cuenta Free no muestra, así que no es falta de observación: es un muro del
producto, y como tal va a `not_found`.
