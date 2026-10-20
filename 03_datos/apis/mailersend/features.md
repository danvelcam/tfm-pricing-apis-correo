# Matriz funcional — MailerSend (D-019, CRITERIOS G)

Construida el 2026-09-08 dentro del ciclo de recolección, desde `fuentes.md` y sin fuentes
nuevas. Regla G2: celda «—» donde ninguna fuente registrada lo dice; nada se infiere de
otro plan. Escalón: **doc** = documentación pública ([F1] pricing, [F2] «Plans, features and
limits», [F3] add-ons, [F6] SMTP, [F21] referencia de `/v1/email`, [F39] cc/bcc, [F43] logs,
[F17] novedades) · **panel** = observación de panel con cuenta propia ([F53], 2026-09-08;
cuenta en Sandbox sin dominio propio, sin suscripción). Producto modelado: Email API
(Free / Hobby / Starter / Professional); **Enterprise** se lista porque varias fuentes
publican sus límites, pero no tiene precio ni tarjeta y no está en el YAML. Los ticks (✓/—)
de la tabla comparativa de /pricing **no son capturables por texto** ([H8]): donde solo
existe un tick, la celda queda «—» salvo que otra fuente lo diga en prosa. Fecha de
validez: 2026-09-08.

## Features por plan

| Feature | Free | Hobby | Starter | Professional | Enterprise | Fuente · escalón |
|---|---|---|---|---|---|---|
| Webhooks de eventos | `1` (`"Webhooks Unlimited* 50 1 1"`; `"Webhooks \| 1 \| 5 \| 50 \| 5,000"`) | `1` [F1], por D17; el `"5 webhooks"` de [F2] es incoherencia del pricing (DISC-05, cerrada en esta parte) | `50` (`"50 webhooks, SMTP users (5 users/domain), and API tokens"`) | `"Unlimited*"` [F1] = `"5,000 webhooks"` [F2] | — | [F1] doc · [F2] doc; en el panel `"Add webhook"` disponible en Sandbox [F53] panel |
| IP dedicada | — | — | — (D17: la página de precios la reserva a Enterprise; `"available for Starter and above plans"` [F9] es incoherencia del pricing, DISC-04 cerrada) | — (ídem; `"available to Professional (excluding the Professional trial) and Enterprise plans"` y `"$50/month per IP"` [F3], y el requisito `"Send 500,000 or more emails per month."` [F10], son incoherencia del pricing) | `"Enterprise plans also have 1 dedicated IP included"` [F3]; `"Dedicated IPs are available for Enterprise accounts that send over 100K emails/week."` [F1] | [F3] doc · [F9] doc · [F10] doc · [F1] doc |
| Retención de actividad | `"1 day"` (`"24 hours"` [F2]) | `"1 day"` (`"24 hours"` [F2]) | `"7 days"` | `"30 days"` | `"30 days"` [F3] | [F1] doc (`"Email activity data retention 30 days 7 days 1 day 1 day"`) · [F2] doc · [F3] doc; add-on hasta `"365 days"` por volumen contratado (`"50,000 $5 $10 $12.50 $15"` … `"2,500,000 $250 $375 $500 $625"`), `"Starter, Professional (excluding the Professional trial), and Enterprise plans"` [F3] [F4] |
| Retención de logs API/SMTP | — | — | — | `"7 days"` (`"7-days API logs retention"`) | `"14 days"` [F43] | [F1] doc · [F2] doc (`"Log retention \| - \| - \| - \| 7 days"`) · [F43] doc; panel: `"SMTP & API logging is a Professional feature"` [F53] panel |
| Dominios (de envío) | `1` | `1` | `10` | `"Unlimited*"` [F1] = `"1,000 sending domains"` [F2] | `5,000` [F3] | [F1] doc (`"Sending domains Unlimited* 10 1 1"`) · [F2] doc · [F3] doc; add-on `"Domain spaces"` `"$4.00"` por dominio, `"up to 50 additional domains"`, `"Starter plans and above"` [F1] [F3] |
| Usuarios (seats) | `"1 user seat + 1 accountant role"` | `5` | `5` | `"Unlimited*"` [F1] = `"1,000 users"` [F2] | `"unlimited user seats"` (FAQ 7) | [F1] doc (`"User seats Unlimited* 5 5 1 user seat + 1 accountant role"`) · [F2] doc |
| Entrada de correo (inbound routing) | `"Inbound routes: 1"` en la tabla y prosa `"inbound routing"` entre las features del Free [F2]; en el panel Sandbox el botón es `"Upgrade plan"` [F53] — DISC-05 | `"1 inbound route"` [F2] | `50` (`"5 inbound routes/domain"`) [F2] | `"100,000 inbound routes (5,000/domain)"` [F2] | — | [F2] doc · [F53] panel; los ticks de la fila `Inbound routing` de [F1] no son capturables. El entrante consume la cuota de envío (`"One forward is equivalent to one sent email."`) [F7] |
| SMTP | sí (`"Email API and SMTP relay"`); `1` usuario SMTP; `5` conexiones concurrentes | sí; `1` usuario; `5` conexiones | sí; `50` usuarios (`"5 users/domain"`); `5` conexiones | sí; `"1,000"` usuarios (`"20 users/domain"`); `50` conexiones | `"1,000"` usuarios; `50` conexiones | [F1] doc · [F2] doc (`"SMTP users \| 1 \| 1 \| 50 \| 1,000"`) · [F6] doc (`"That limit is 5 for Sandbox, Free, Hobby and Starter accounts, and 50 for Professional (including the professional trial) and Enterprise."`); caudal `"SMTP relay requests: Up to 120 requests per minute."` [F6] |
| Plantillas | `1` | `10` (de `3` a `10` el `"Aug 24, 2026"`) | `250` | `"Unlimited*"` [F1] = `"5,000 templates"` [F2] | — | [F1] doc (`"Branded templates Unlimited* 250 10 1"`) · [F2] doc · [F17] doc |

## Otras features registradas

| Feature | Free | Hobby | Starter | Professional | Enterprise | Fuente · escalón |
|---|---|---|---|---|---|---|
| Envío por lotes (`/v1/bulk-email`) | — (no nombrado; `"All in Free, plus:"` … `"Bulk emailing"` en la tarjeta Hobby; error `"This feature requires a Hobby plan or higher"`) | `"Access to the bulk email endpoint"`; `500` objetos; `10`/min | `500` objetos; `15`/min | `500` objetos; `30`/min | `500` objetos; `60`/min | [F1] doc · [F2] doc · [F21] doc · [F31] doc (que sí publica `"Free plan: 10 API calls/min"`) · [F20] doc; Sandbox `5` objetos [F21] |
| Peticiones diarias (API + SMTP) | `100` | `1,000` | `100,000` | `500,000` | `500,000` | [F1] [F2] [F6] [F20] [F31] doc; panel `"Daily requests 100"` en Sandbox [F53] panel |
| API tokens | `1` | `3` | `50` | `1,000` | — | [F2] doc (`"API tokens \| 1 \| 3 \| 50 \| 1,000"`); panel: el token observado lleva fecha de caducidad (`"Expires at: 30 Sep 2026"`) [F53] panel; la API de creación no tiene parámetro de expiración [F22], así que no se sabe si es obligatoria |
| Sender identities | `-` | `-` | `50` | `5,000` | — | [F2] doc (`"Sender Identities \| - \| - \| 50 \| 5,000"`); tarjeta Starter `"Sender identities"` [F1] |
| cc / bcc por objeto | `Max 10` / `Max 10` | ídem | ídem | ídem | `Max 50` / `Max 50` | [F21] doc · [F39] doc (`"cc object [ ] No Max 10 Max 50"`); sin aprobar `1` y `1` [F39] [F20] |
| Cabeceras personalizadas (`headers`, `list_unsubscribe`) | — | — | — | `"available to Professional and Enterprise accounts only"` | ídem | [F21] doc; `"Custom header support"` [F2] |
| Hilos (`in_reply_to`, `references`) | sí: `"Email threads support"` en la tarjeta [F1], por D17; `"available to paid plan accounts only"` [F21] es incoherencia del pricing (DISC-16, cerrada) | sí (de pago) | sí | sí | — | [F1] doc · [F21] doc |
| SMS API | — | — | `"100 SMS /month"` (50K; hasta `"7,000 SMS /month"` en 1M) | `"150 SMS /month"` (50K; hasta `"15,000 SMS /month"` en 2M) | número de prueba (`"All Starter, Professional, and Enterprise accounts come with a complimentary trial phone number"`) | [F1] doc · [F12] doc · [F48] doc; sobrecoste `"$1.40 per 100 SMS messages"` [F48]; producto aparte (A1, F-10) |
| WhatsApp API | — | `"Add-on available"` | `"Add-on available"` | `"Add-on available"` | — | [F1] doc (tres celdas); `"$5.00"` por `"1,000 messages"`, `"$0.0050 per message"`, `"Extra usage: $2.50/1,000"` [F1]; lanzado `"Sep 1, 2026"` [F17] |
| Verificación de direcciones (créditos incluidos) | `10` | `100` | `100` | `400` | `400` | [F2] doc · [F3] doc; add-on desde `"$0.01 per credit"` (`"2,500 credits"` por `"$25.00"`), compra mínima `"1,000 credits"` desde Hobby [F1] [F3] |
| DMARC monitoring | — | — | `"1 domain (30-day free trial)"` | `"10 domains"` | — | [F1] doc; add-on `"$2.00"` por dominio [F1] [F3] |
| Blocklist monitoring | — | `"2 monitors"` | `"64 monitors"` | `"256 monitors"` | — | [F1] doc |
| Quitar el logo de MailerSend | — | — | `"Remove MailerSend logo"` | ídem (`"All in Starter, plus:"`) | — | [F1] doc |
| Soporte | `"Limited"` | `"Email support"` | `"Email support"`, `"Live chat support"` | `"Priority email support"`, `"Live chat support"`, `"Onboarding assistance"`; `"Dedicated Account manager"`, `"Deliverability consultation"` | — | [F1] doc; panel Sandbox `"Live chat support 14 days left"` [F53] panel |
| SLA, IP allowlisting, 2FA forzado, MCP server, translations, split testing, custom tracking branding | — | — | — | — | — | filas de [F1] cuyos ticks no son capturables por texto ([H8]); `"99.5% guaranteed uptime SLA"` solo como rótulo [F1] |
| Pago anual | — | `"$ 6.30 /month"`, `"$75.60 billed yearly"` | `"$ 31.50 /month"`, `"$378.00 billed yearly"` (50K) | `"$99.00 /month"`, `"$1,188.00 billed yearly"` (50K) | — | [F1] doc (`"Save 10%"`); descuento nonprofit `30%` no acumulable [F1] |
| Estados previos al plan | Sandbox: `"100 emails a month, with a cap of 100 API requests a day"`, `"any 2 recipients"`; Professional trial: `"500 emails a month and 100 API requests a day"`, 14 días, cae a Free | | | | | [F37] doc · [F53] panel (cuenta en Sandbox) |

## Preguntas de clase L instanciadas

- **PI-E01** «¿Incluye el plan Free de MailerSend webhooks de eventos?» → **sí**, 1 webhook
  [F1] (`"Webhooks Unlimited* 50 1 1"`) y [F2] (`"Webhooks | 1 | 5 | 50 | 5,000"`); en el
  panel, `"Add webhook"` está disponible ya en Sandbox [F53].
- **PI-E02** «¿Qué API me da IP dedicada al menor precio para 200.000 correos al mes?» →
  MailerSend **sale de la comparación**. Por D17 manda la página de precios, que reserva la IP
  dedicada a `"Enterprise accounts that send over 100K emails/week"` [F1], y Enterprise no
  publica precio. Con Starter o Professional no hay cálculo posible. Las cifras de antes del
  2026-10-18 (Starter 250K + 50 = 212,50 USD/mes según [F9]; Professional 250K + 50 = 325
  USD/mes según [F3]) quedan como historia: salían de dos fuentes que la página contradice
  (DISC-04, incoherencia del pricing). Resend queda en 190 USD y SendGrid en 199,95 USD (sus
  `features.md`).

## Huecos

Ticks de la tabla comparativa de /pricing (inbound por plan, SLA, IP allowlisting, 2FA,
MCP server, translations, split testing, custom tracking branding): sin fuente textual.
Inbound en Free y Hobby (DISC-05, abierta en esa parte: la fila de [F1] no se captura);
Enterprise sin precio, volumen ni webhooks/plantillas publicados. Los webhooks de Hobby, el
plan mínimo de la IP dedicada y los hilos en Free se cerraron por D17 el 2026-10-18.
