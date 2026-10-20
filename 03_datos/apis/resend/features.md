# Matriz funcional — Resend (D-019, CRITERIOS G)

Construida **a posteriori** el 2026-09-07 desde `fuentes.md` y sin fuentes nuevas.
Regla G2: celda «—» donde ninguna fuente registrada lo dice; nada se infiere de otro plan.
Escalón: **doc** = documentación pública ([F1] pricing, [F2] `pricing.md`, reverificación
2026-09-01) · **panel** = observación de panel con cuenta propia ([F9], 2026-09-01).
Producto modelado: transaccional (Free / Pro / Scale / Enterprise). Fecha de validez:
2026-09-01 (los dominios de Free pasaron de 1 a 3 entre el 08-05 y el 09-01, DISC-05).

## Features por plan

| Feature | Free | Pro | Scale | Enterprise | Fuente · escalón |
|---|---|---|---|---|---|
| Webhooks de eventos | incluidos (`"All plans include: … webhooks"`); `1` endpoint | incluidos; `5` endpoints | incluidos; `10` endpoints | incluidos; `"Flexible"` | [F2] doc (`"Webhook endpoints 1 / 5 / 10 / Flexible"`, reverificación 2026-09-01) |
| IP dedicada | — | — | add-on `"Dedicated IPs — $30 / mo"`, `"Available on the Scale plan to customers exceeding 3,000 emails sent per day"` | add-on (`"Scale plan or higher"`) | [F1] doc · [F9] panel (el panel solo cita el plan, no el volumen) |
| Retención de datos | `"30-day data retention"` | 30 días | 30 días | `"flexible data retention"` | [F1] [F2] doc (DISC-03: el repositorio de 2026-02 decía 1 / 3 / 7) |
| Dominios | `3` | `10` | `1,000` | `"Set by contract"` | [F1] doc · [F9] panel (`"Domains 0 / 3"`); add-on `"Domains - $20 / Mo — Adds 100 domains"` en planes de pago [F9] |
| Usuarios | — | — | — | — | (ninguna fuente registrada cifra usuarios por plan) |
| Entrada de correo (inbound) | incluida (`"inbound emails"`) | incluida | incluida | incluida | [F2] doc (`"All plans include"`) |
| SMTP | incluido (`"SMTP relay"`); `smtp.resend.com:465`, usuario `resend`, contraseña = clave de API | incluido | incluido | incluido | [F2] doc · [F9] panel |
| Plantillas | — | — | — | — | (React Email figura en `"All plans include"`, pero no es un gestor de plantillas por plan) |

## Otras features registradas

| Feature | Free | Pro | Scale | Enterprise | Fuente · escalón |
|---|---|---|---|---|---|
| Soporte | `"Ticket support"` | — | `"Slack & ticket support"` / `"Dedicated Slack channel"` | `"Priority support"`, `"99.99% uptime SLA"` | [F1] doc |
| Single Sign-On | — | — | add-on `"$150 / Mo"` (`"Scale plan or higher"`) | `"included on Enterprise plans"` | [F9] panel · [F2] doc |
| Multi-región, SDKs, batch, tracking, DKIM/SPF/DMARC, MFA, permisos de clave | incluidos en todos los planes | ídem | ídem | ídem | [F2] doc (`"All plans include"`) |
| AI credits | `5` | `100` | `500` | `"Flexible"` | [F2] doc · [F9] panel |

## Preguntas de clase L instanciadas

- **PI-E01** «¿Incluye el plan Free de Resend webhooks?» → **sí**, con 1 endpoint [F2].
- **PI-E02** «¿Qué API me da IP dedicada al menor precio para 200.000 correos al mes?» →
  Resend: Scale con volumen de 200.000 (`$160/mo`, [F2]) más el add-on (`$30 / mo`,
  [F1]) = **190 USD/mes**; cumple el requisito de `3,000` correos al día (200.000 / 30 =
  6.667). La comparación con SendGrid está en `05_salida/_cap5/analisis.md` y en §5.5.

## Huecos

Usuarios por plan y gestor de plantillas: ninguna fuente registrada lo cifra.
