# Matriz funcional — SendGrid (D-019, CRITERIOS G)

Construida **a posteriori** el 2026-09-07 desde `fuentes.md` y sin fuentes nuevas.
Regla G2: celda «—» donde ninguna fuente registrada lo dice; nada se infiere de otro plan.
Escalón: **doc** = documentación pública ([F1] pricing del Email API, [F4] referencia de
`mail/send`, [F13] SMTP, [F16] Email Activity Feed, [F17] validación) · **panel** =
observación de panel con cuenta propia ([F12], 2026-09-06; cuenta Free Trial, caduca el
2026-11-05). Producto modelado: Email API (Free Trial / Essentials / Pro / Premier);
Marketing Campaigns se contrata aparte. Fecha de validez: 2026-09-06.

## Features por plan

| Feature | Free Trial | Essentials | Pro | Premier | Fuente · escalón |
|---|---|---|---|---|---|
| Webhooks de eventos (Event Webhook) | `"1 included"` | `"2 included"` | `"5 included"` | `"5 included"` | [F1] doc |
| IP dedicada | — (`"No Access to Dedicated IPs"`) | — (ídem) | `"1 included*"` (`"Dedicated IP Included"`) | `"1 included*"` | [F1] doc · [F12] panel; add-on `"Additional Dedicated IP Addresses — $30/month* each"` [F12] |
| Retención de actividad (Searchable Email Activity) | `"3 days included"` | `"3 days included"` | `"7 days of history"` | `"7 days of history*"` (`"*Not available to Premier 100M and above"`) | [F1] doc; add-on `"Additional Email Activity History — Available for purchase"` sin precio, hasta `30 days` [F1] [F16] |
| Dominios | — | — | — | — | (ninguna fuente registrada cifra dominios autenticados por plan) |
| Usuarios (teammates) | `"1 teammate"` | `"1 teammate"` | `"1,000 teammates"` | `"1,000 teammates"` | [F1] doc |
| Entrada de correo (Inbound Parse) | — | — | — | — | documentado sin condición de plan (tope de `30 MB` por mensaje) [F3]; si consume cuota, no encontrado (`not_found`) |
| SMTP | sí (`"via web API or SMTP per day"`) | — | — | — | [F7] doc; límites `"5k messages per SMTP connection"`, `"10k concurrent connections from a single server"` sin condición de plan [F13] doc |
| Plantillas (Dynamic Templates) | `"Editor"` | `"Editor"` | `"Editor and testing"` | `"Editor and testing"` | [F1] doc (D17, DISC-03); [F12] panel dice `"Dynamic Template Editor"` en los cuatro planes y no nombra el *testing* (incoherencia del pricing) |

## Otras features registradas

| Feature | Free Trial | Essentials | Pro | Premier | Fuente · escalón |
|---|---|---|---|---|---|
| Validación de direcciones | — (`"No Access to Email Validation"`) | — | `"2,500 free validations included"` | `"5,000 free validations included"` | [F1] doc · [F12] panel · [F17] doc (`"Pro and Premier level accounts only"`, `"limit of 50 sources"`) |
| Residencia de datos en la UE | `"No Regional Data Residency"` | ídem | `"Regional Data Residency"` (`api.eu.sendgrid.com`) | ídem | [F4] doc · [F12] panel |
| Gestión de subusuarios | `"No Subuser Management"` | ídem | `"Subuser Management"` | ídem | [F12] panel |
| Email Testing | `"No Access to Email Testing"` | ídem | `"60 credits/mo (more for purchase)"` | ídem | [F1] doc · [F12] panel; el panel da `"500 Email Testing Credits"` en Premier, incoherencia del pricing (D17, DISC-02) |
| Soporte | `"Ticket Support"` | `"Ticket & Chat Support"` | `"Guaranteed Response Times on Ticket, Chat, & Phone Support"` | — | [F12] panel |

## Preguntas de clase L instanciadas

- **PI-E01** «¿Incluye la prueba de SendGrid webhooks de eventos?» → **sí**, 1 Event
  Webhook [F1].
- **PI-E02** «¿Qué API me da IP dedicada al menor precio para 200.000 correos al mes?» →
  SendGrid: la IP va incluida desde Pro. Pro 100K (`$89.95/mo`) más 100.000 correos de
  sobrecoste a `$0.0011` = **199,95 USD/mes** (dentro del tope de 10 veces el plan,
  F-16), o Pro 300K a `$249.00/mo` sin sobrecoste. Resend queda en 190 USD (su
  `features.md`).

## Huecos

Dominios por plan, disponibilidad de Inbound Parse y de plantillas por plan, y SMTP en
los planes de pago: ninguna fuente registrada lo cifra por plan.
