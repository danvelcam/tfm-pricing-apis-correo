# Matriz funcional — Postmark (D-019, CRITERIOS G)

Construida **a posteriori** el 2026-09-07 desde `fuentes.md` y sin fuentes nuevas.
Regla G2: celda «—» donde ninguna fuente registrada lo dice; nada se infiere de otro plan.
Escalón: **doc** = documentación pública · **panel** = observación de panel con cuenta
propia ([F11], 2026-08-03). Producto modelado: transaccional (Free / Basic / Pro /
Platform, cuenta en modo de prueba). Fecha de validez: la de las fuentes citadas.

## Features por plan

| Feature | Free | Basic | Pro | Platform | Fuente · escalón |
|---|---|---|---|---|---|
| Webhooks de eventos | — | — | `"All Event Webhooks"` | `"All Event Webhooks"` | [F11] panel (tarjetas de tier) |
| IP dedicada | — | — (add-ons `"Pro and Platform plans only"`) | add-on `"Starts at $50/month per IP"`, requisito `"sending 300,000 emails per month or more"`; en el panel `$50 per month` por solicitud (`"Request a dedicated IP"`) | ídem Pro | [F1] doc · [F11] panel |
| Retención de actividad | 45 días (`"45 (Default, Free)"`) | 45 días | 45 días por defecto; add-on `"Custom Activity Retention — Starts at $5/month"`, de 7 a 365 días | ídem Pro | [F9] doc · [F1] doc · [F11] panel (pasos `Don't store content · 7 · 28 · 45 · 90 · 180 · 365`) |
| Dominios (de firma) | — | `"Up to 5 signature domains"` | `"Up to 10 signature domains"` | `"Unlimited signature domains"` | [F11] panel |
| Usuarios | — | `"Up to 4 users"` | `"Up to 6 users"` | `"Unlimited users"` | [F11] panel |
| Entrada de correo (inbound) | disponible en modo de prueba (`"Inbound processing doesn't have any domain restrictions"`) | — | `"Inbound email processing"` | `"Inbound email processing"` | [F1] doc · [F11] panel |
| SMTP | — | `"SMTP & REST API"` | — | — | [F11] panel; límite recomendado `"10 concurrent connections, per IP"`, no aplicado (`"We do not have any systems in place to enforce these limits"`) [F10] doc |
| Plantillas | hasta 100 por servidor (`"a Server may have up to 100 templates"`) | `"Email templates"`; 100 por servidor | 100 por servidor | 100 por servidor | [F7] doc · [F11] panel |

## Otras features registradas

| Feature | Free | Basic | Pro | Platform | Fuente · escalón |
|---|---|---|---|---|---|
| Servidores | hasta 10 creados en la cuenta gratuita (observado) | `"Up to 5 servers"` | `"Up to 10 servers"` | `"Unlimited servers"` | [F11] panel (F-08: el observado supera el declarado) |
| Streams | — | `"Up to 15 streams"` | `"Up to 30 streams"` | `"Unlimited streams"` | [F11] panel |
| Stats y tracking APIs | — | — | `"Stats & Open/Link Tracking APIs"` | — | [F11] panel |
| DMARC Monitoring | — | — | add-on `"Starts at $14/month per domain"` | ídem | [F1] doc · [F11] panel (solo Pro y Platform) |

## Preguntas de clase L instanciadas

- **PI-E01** «¿Incluye el plan Free de Postmark webhooks de entrega?» → **no declarado
  para Free**: el panel enumera `"All Event Webhooks"` solo en Pro y Platform [F11]. La
  matriz responde «no consta», no «no».
- **PI-E02** «¿Qué API me da IP dedicada al menor precio para 200.000 correos al mes?» →
  Postmark **no elegible**: el add-on exige `"300,000 emails per month or more"` [F1].

## Huecos

Free no tiene tarjeta de tier en el panel (solo el aviso de modo de prueba), y por eso su
columna queda casi vacía. No es que Free carezca de SMTP o de dominios: es que ninguna
fuente registrada lo cifra.
