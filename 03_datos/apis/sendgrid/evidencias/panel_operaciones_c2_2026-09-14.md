# Panel de SendGrid — operaciones 4 a 8 del test C2

- **Fecha:** 2026-09-14
- **Cuenta:** cuenta propia del autor, **Free Trial** (`"Your free trial ends on November 5th,
  2026."`), sin identidad de remitente creada. Modo lectura: no se creó, editó ni borró ninguna
  clave; no se compró el add-on; no se pulsó `Upgrade`. Se cerró un modal informativo de
  «Email Logs» para poder leer la página de debajo.
- **Redacción:** no se transcriben correo, nombre de la clave ni su identificador.

## Superficie del panel

`Dashboard` · `Email API` (Dynamic Templates, Legacy Templates, Integration Guide) · `Marketing`
· `Design Library` · `Stats` · **`Activity`** (Email Logs, Activity Feed) · `Validation` ·
**`Suppressions`** (Global Unsubscribes, Group Unsubscribes, Bounces, Spam Reports, Blocks,
Invalid) · `Settings` (Account Details, Alert Settings, **API Keys**, Data Residency, **Inbound
Parse**, IP Access Management, IP Addresses, **Mail Settings**, Sender Authentication, SSO,
Subuser Management, Teammates, Tracking, 2FA).

## Literales relevantes

- Settings → API Keys: `"Create API Key"`, `"Edit API Key"`, `"Delete API Key"`; la clave se
  muestra enmascarada.
- Settings → Mail Settings → Webhook Settings: `"Event Webhooks"`, `"Allows notifications for
  events, such as bounces, clicks, and opens to be POSTed to a specified URL."`
- Activity → Activity Feed: `"Retrieve information about every email you've sent in the past 3
  days by clicking \"Search\"."` y `"Up to 30 days of history is available for purchase."`

## Lectura para el test C2

| Op | Panel | API | Resultado |
|---|---|---|---|
| 4 credenciales adicionales | sí (`Create API Key`, `Edit`, `Delete`) | sí (`POST /v3/api_keys`) | simétrica |
| 5 webhooks | sí (`Event Webhooks`) | sí (`POST /v3/user/webhooks/event/settings`) | simétrica |
| 6 inbound routing | sí (`Inbound Parse`) | sí (`POST /v3/user/webhooks/parse/settings`) | simétrica |
| 7 supresiones y rebotes | sí (seis listas) | sí (`/v3/asm/suppressions/global`, `/v3/suppression/bounces`) | simétrica |
| 8 actividad y logs | **sí, con 3 días incluidos en el plan** | sí, **pero de pago**: la Email Activity Feed API exige comprar el histórico | **asimétrica** → fricción (no eliminatoria), F-08 |
