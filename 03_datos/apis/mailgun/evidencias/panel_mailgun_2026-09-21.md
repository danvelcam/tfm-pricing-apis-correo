# Observación de panel — Mailgun (escalón 2)

- **Fecha de acceso:** 2026-09-21
- **Navegador:** «danvelcam - dvela browser» (deviceId 8bfcd503-51fd-4675-bc3e-92d4701ee501)
- **Cuenta:** Daniel Vela / Universidad de Sevilla
- **Modo:** solo lectura. No se pulsó ningún botón de facturación, upgrade, borrado ni
  aceptación de términos. El diálogo «Yes, I agree» de Red Sift (DMARC) se dejó sin tocar.

Transcripción literal de lo que muestra el panel. Sin resumir: lo que sigue es el texto
que devolvió cada pantalla.

---

## P1 · Billing → Plans  `https://app.mailgun.com/billing?tab=plans`

```
Mailgun Send
Upgrade
Your current plan
Free
$0
/ month
3000 emails per month
1 day of log retention
24/7 ticket support
Pricing details
Emails sent this month
0 / 3000

Mailgun Optimize
Subscribe to a plan
Your current plan
No subscription

Mailgun Inspect
Subscribe to a plan
Your current plan
No subscription

Upcoming bill
MAILGUN SEND
Free
0,00 US$
Estimated total
0,00 US$
Autopay on the 1st of each month
The estimated total may be prorated, as appropriate, based on the billing period for selected plans.
```

## P2 · Guía de inicio  `https://app.mailgun.com/welcome-guide?tab=send`

```
Sandbox domain
sandboxcc7d3466734a4ff18c9247a488599261.mailgun.org
Base URL
https://api.mailgun.net
```

El ejemplo de código que el propio panel genera va preconfigurado con
`from` = `postmaster@sandboxcc7d3466734a4ff18c9247a488599261.mailgun.org` y
`to` = `Daniel Vela <persona-3@example.invalid>`, y llama a
`https://api.mailgun.net/v3/sandboxcc7d3466734a4ff18c9247a488599261.mailgun.org/messages`.

## P3 · Domain settings → Settings  `…/settings?tab=settings`

```
Message retention is unavailable for your plan. Upgrade to start storing message bodies
(MIMES) for later retrieval (either rendered via logs or retrieved via API). Learn more.

Message retention
Unavailable for your plan
Upgrade
Inbound spam filter
No filtering
Security
TLS connection
Opportunistic
Certificate verification
Required
Tracking
To setup tracking you need to add a CNAME to our DNS as described on the "DNS Records" tab
Click tracking
Off
Open tracking
Off
Unsubscribes
Off
```

## P4 · Domain settings → DNS Records  `…/settings?tab=dns`

```
DKIM settings for sandboxcc7d3466734a4ff18c9247a488599261.mailgun.org are managed by the
root domain sandbox.mgsend.net (DKIM authority is set to "false"). Subdomains cannot add
new DKIM records independently.
```

## P5 · Domains  `https://app.mailgun.com/mg/sending/domains`

```
sandboxcc7d3466734a4ff18c9247a488599261.mailgun.org   0   0%  0%  0%  0%  0%
1-1 of 1
```

## P6 · Superficie del producto (menú lateral, enlaces reales)

```
/mg/reporting/metrics · /mg/reporting/logs · /mg/reporting/bounce-classification
/mg/reporting/tags · /mg/reporting/saved-reports
/mg/sending/domains · /mg/sending/<dominio>/templates · /mg/sending/<dominio>/suppressions
/mg/sending/<dominio>/webhooks/account-level · /mg/sending/<dominio>/ips
/mg/sending/mailing-lists · /mg/sending/<dominio>/settings
/mg/receiving/routes
/inspect/email-testing
/mgo/ai-insights · /mgo/dmarc-reports · /mgo/email-health-score
/mgo/google-postmaster-tools · /mgo/microsoft-snds · /mgo/spam-traps
/mgo/blocklist-monitoring · /mgo/inbox-placement/reports · /mgo/inbox-placement/seed-lists
/mgo/validations
```

---

## Lo que el panel NO enseña

- El caudal vigente (rate limit) de la cuenta: ninguna pantalla lo muestra.
- Ningún registro de errores 429.
- La escalera de volúmenes contratables: el enlace «Pricing details» no abrió panel
  interno; el plan de pago no es observable sin contratarlo.
- La fecha literal de reposición de la cuota de 3.000 emails. Lo único con fecha es
  «Autopay on the 1st of each month», que habla del **cobro**, no del reinicio del
  contador.
- La lista de destinatarios autorizados del sandbox como pantalla propia.
