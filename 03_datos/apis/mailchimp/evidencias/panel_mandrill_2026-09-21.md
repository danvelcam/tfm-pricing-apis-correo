# Observación de panel — Mailchimp Transactional (Mandrill), escalón 2

- **Fecha de acceso:** 2026-09-21
- **Navegador:** «danvelcam - dvela browser» (deviceId 8bfcd503-51fd-4675-bc3e-92d4701ee501)
- **Acceso:** `mandrillapp.com` → «Log in using Mailchimp». El SSO resolvió por redirección,
  sin pantalla de consentimiento que aceptar.
- **Modo:** solo lectura. No se añadió dominio, no se creó ni reveló ninguna clave, no se
  tocó facturación ni add-ons.

Transcripción literal de cada pantalla.

---

## P1 · Pantalla de acceso  `https://mandrillapp.com/login/`

```
What is Mandrill?
Mandrill is a paid Mailchimp add-on that allows you to send one-to-one transactional
messages triggered by user actions, like requesting a password or placing an order.
```

## P2 · Cuenta → Monthly Plan and Statements  `https://mandrillapp.com/account`

```
Sending Stats
Total Sends This Month
0
Deliverability
0.0%

Month plan usage
Free trial sends
0 of 500
0%
SMS credits
0 of 0
0%
Add SMS

Hourly sends
Email sends this hour
0 of 25
0%

Reputation
Reputation
Unknown

All new accounts have an "Unknown" reputation since we haven't seen the results of
anything you've sent. As you start sending more and Mandrill learns more about your mail,
your account will have a reputation (Excellent, Good or Poor) that is used, in part, to
determine your hourly quota.

How you compare to all other Mandrill users
Top 20%   100.0%  Delivery Rate
Top 20%   0.0%    Bounce Rate
Top 20%   0.00%   Spam Rate

Add Ons
Dedicated IPs
You don't have any dedicated IPs.
Manage Dedicated IPs
```

## P3 · SMTP and API Credentials  `https://mandrillapp.com/settings`

```
Send email using our API or get started quickly with SMTP using the information below:
Host      smtp.mandrillapp.com
Port      587
SMTP Username   any username will work - try "Ingeniería" for example
SMTP Password   any valid API key

API Keys
Valid API Keys
Key | Description | Created | Expires | Remaining
md-YWas******************  |  | Sep 16, 2026 12:16 pm | — | —
```

La tabla de claves tiene columnas **Expires** y **Remaining**: la clave es una unidad a la
que se le puede poner caducidad y un contador restante. Ambas vacías en esta cuenta.

## P4 · Sending Domains  `https://mandrillapp.com/settings/sending-domains`

```
No sending domains yet
To start sending through Mandrill, you need to verify ownership
of your sending domain and update your DNS records.
```

## P5 · Dashboard  `https://mandrillapp.com/`

```
No Sending Domains
You don't have any sending domains set up yet. To start sending through Mandrill, you
need to verify ownership of your sending domain and update your DNS records.
```

---

## Contraste con la API (mismo día, cuenta propia)

`POST https://mandrillapp.com/api/1.0/users/info` → HTTP 200:

```json
{"username":"31644777","created_at":"2026-09-16 10:16:34.82112",
 "public_id":"W-1vniwilLzrhCW3f3KPgA","reputation":0,"hourly_quota":25,"backlog":0, …}
```

Dos superficies del mismo proveedor coinciden en el tope horario: el panel escribe
`Email sends this hour 0 of 25` y la API devuelve `"hourly_quota":25`. **No es una
discrepancia.** La `reputation: 0` de la API y el `Reputation: Unknown` del panel son la
misma cosa en dos codificaciones: el 0 es el valor que la API usa para «aún sin
reputación», y el panel lo escribe en palabras.

## Lo que el panel NO enseña

- El precio por bloque ni la escalera de volúmenes: esta cuenta está en prueba gratuita y
  la pantalla de compra no se abrió (es facturación).
- Ningún rate de peticiones a la API (req/s o req/min). El único tope de velocidad que el
  panel publica es de **envíos por hora**, no de peticiones.
- El tamaño máximo de mensaje ni el de adjunto.
- El máximo de destinatarios por llamada a `/messages/send`.
- Ningún registro de errores 429.
