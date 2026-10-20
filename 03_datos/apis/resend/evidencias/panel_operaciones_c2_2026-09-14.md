# Panel de Resend — operaciones 4 a 8 del test C2

- **Fecha:** 2026-09-14
- **Cuenta:** cuenta propia del autor, plan Free, sin dominios dados de alta. Modo lectura: no se
  creó, reveló ni borró nada.
- **Redacción:** no se transcriben correo ni identificadores.

## Superficie del panel

`Emails` · `Broadcasts` · `Automations` · `Templates` · `Audience` · `Metrics` · `Domains` ·
`Logs` · **`API keys`** · **`Webhooks`** · `Settings`. Dentro de `Settings`: `Usage` · `Billing`
· `Team` · `SMTP` · `Integrations` · `Unsubscribe page` · `Documents`.

## Literales relevantes

- Página Domains, con la cuenta vacía: `"No domains yet"`, `"Verify a domain by adding a DNS
  record and start sending and receiving emails from your own address."`

## Lectura para el test C2

| Op | Panel | API | Resultado |
|---|---|---|---|
| 4 credenciales adicionales | sí (`API keys`) | sí (`POST /api-keys`) | simétrica |
| 5 webhooks | sí (`Webhooks`) | sí (`POST /webhooks`) | simétrica |
| 6 inbound routing | sí (recepción atada al dominio: MX en el DNS del usuario) | sí (`GET /emails/receiving` + webhook `email.received`) | simétrica |
| 7 supresiones | **no hay sección** en el panel | sí (`POST /suppressions`, List, Remove, batch) | asimétrica **a favor de la API**: no afecta al `type`, que solo mira lo que está en la web y no en la API |
| 8 actividad y logs | sí (`Logs`, `Emails`, `Metrics`) | sí (`GET /logs`) | simétrica |
