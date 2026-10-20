# Matriz funcional — Mailgun (D-019, CRITERIOS G)

Construida **a posteriori** el 2026-09-21 desde `fuentes.md` y sin fuentes nuevas.
Regla G2: celda «—» donde ninguna fuente registrada lo dice; nada se infiere de otro
plan ni de otra API. Escalón: **doc** = documentación pública (página de precios y
developer docs) · **panel** = observación de panel con cuenta propia ([F24],
2026-09-21, plan Free). Producto modelado: transaccional (**Mailgun Send**; Mailgun
Optimize y Mailgun Inspect quedan fuera por A1). Planes: Free / Basic / Foundation /
Scale. El plan **Custom/Enterprise no tiene fila ni tarjeta propia** (`"Request a
quote"`) y queda fuera de la matriz por A3. Fecha de validez: la de las fuentes
citadas.

## Features por plan

| Feature | Free | Basic | Foundation | Scale | Fuente · escalón |
|---|---|---|---|---|---|
| Webhooks de eventos | incluido (`cols: true`) | incluido | incluido | incluido | [F1] doc; hasta `"3 URLs per event type"`, no condicionado a plan [F14] doc |
| IP dedicada | — (`false`) | — (`false`) | `"Access at 50k, included at 100K+ volumes"` | `"One Dedicated IP Included"` | [F1] doc. Add-on en todos los planes: `"$59/IP/month"` |
| Retención de actividad (logs) | `"1 day log retention"` | `"1 day log retention"` | `"5 days log retention"` | `"30 days log retention"` | [F1] doc · confirmado en panel para Free: `"1 day of log retention"` [F24] |
| Retención de bounce classification | `"1 day of bounce classification"` | `"1 day of bounce classification"` | `"5 days of bounce classification"` | `"30 days of bounce classification"` | [F1] doc (dimensión distinta de la retención de logs, misma tabla) |
| Retención de mensajes (message retention) | — (`false`, sin cifra) | — (`false`, sin cifra) | `"1 day message retention"` | `"Up to 7 days"` (`"defaults to 3 days ... increased to 7 days on a per domain basis"`) | [F1] doc · confirmado en panel para Free: `"Message retention is unavailable for your plan"` [F24] |
| Dominios de envío (custom sending domains) | `1` | `1` | `1,000` | `1,000` | [F1] doc |
| Usuarios | `"limited to 1 user per account"` | excluido de «tantos como necesites», sin cifra propia publicada | `"as many users as you need... at no additional cost"` | `"as many users as you need... at no additional cost"` | [F1] doc |
| Entrada de correo (inbound routing) | `"1 inbound route"` | `"5 inbound routes"` | `"Full access to inbound routing"` (sin cifra) | hereda de Foundation (sin cifra propia) | [F1] doc |
| SMTP | incluido (`"RESTful email APIs and SMTP relay"`) | incluido (ídem) | incluido (`"Full access to RESTful email APIs and SMTP relays"`) | incluido (`cols: true`, `"SMTP Relays"`) | [F1] doc; puertos `25/465/587/2525` no condicionados a plan [F13] doc |
| Plantillas | incluido, **medido** el 2026-09-21: `POST /v3/{dominio}/templates` desde la cuenta Free devuelve `"template has been stored"` | incluido; ninguna fuente distingue Basic de Free en este endpoint | `"Email template builder and API"` | hereda de Foundation (`"Everything on Foundation plus..."`, no repite el bullet) | [F1] doc · [E1] sondeo · API de plantillas confirmada disponible en general por [F4] doc |

## Otras features registradas

| Feature | Free | Basic | Foundation | Scale | Fuente · escalón |
|---|---|---|---|---|---|
| Multi-user Access (matriz) | no (`false`) | no (`false`) | sí (`true`) | sí (`true`) | [F1] doc |
| RBAC API Keys | no (`false`) | no (`false`) | sí (`true`) | sí (`true`) | [F1] doc |
| SAML SSO | no (`false`) | no (`false`) | no (`false`) | sí (`true`) | [F1] doc |
| Garantía de uptime (SLA) | no (`false`) | no (`false`) | sí (`true`) | sí (`true`) | [F1] doc |
| API keys (cantidad) | `2` | `2` | — | — | [F1] doc |
| Dedicated IP pools | — (`false`) | — (`false`) | — (`false`) | solo Scale (`true`) | [F1] doc |
| Send Time Optimization (STO) | — | — | — | solo Scale | [F1] doc |
| Validación de email (add-on) | — (`false`) | `"Available as add-on"` | `"Available as add-on"` | `"5,000 email validations included"` | [F1] doc |
| Soporte | `"Ticket support"` (panel: `"24/7 ticket support"`, incoherencia del pricing; manda la página por D17) | `"Ticket support"` | `"Ticket support"` | `"Live phone & chat support"` (Chat/Phone exclusivos de Scale) | [F1] doc · [F24] panel |
| Región de datos (US/EU) | elegible, no condicionado por plan | elegible | elegible | elegible | [F1] doc |
| Programación anticipada (deliver-by) | — | 3 o 7 días según plan (sin atribución exacta, D4) | — | — | [F13] doc |
| Subaccounts | fila global `false`, sin desglose por plan | — | — | — | [F1] doc |

## Preguntas de clase L instanciadas

- **PI-E01** «¿Incluye el plan Free de Mailgun webhooks de entrega?» → **sí**: la fila
  `"Webhooks"` de la matriz comparativa marca `cols: true` para las cuatro columnas
  (Free incluida) y la fuente no lo condiciona a plan [F1]. A diferencia de Postmark,
  donde la matriz no declara webhooks para su plan Free (no consta, no es «no»).
- **PI-E02** «¿Qué API me da IP dedicada al menor precio para 200.000 correos al mes?»
  → **no respondible con precisión hoy.** A 200.000 correos/mes, Mailgun da **acceso**
  a IP dedicada desde el volumen de 50k (dentro de Foundation, `$35/mo` base) y la
  **incluye sin coste adicional** a partir de 100k+ (Scale, `$90/mo` base) [F1]. Pero
  el precio exacto que correspondería a 200.000 correos/mes no es determinable: el
  selector `"How many emails do you want to send per month?"` de la página de precios
  puede recalcular la tarjeta mostrada y no se ha podido verificar su mecánica con
  WebFetch estático (F-02/E9, pendiente de navegador) [F1].

## Huecos

- El **plan Custom/Enterprise** no tiene fila ni tarjeta propia (`"Request a quote"`,
  A3): no aparece en esta matriz, y su ausencia no es «celda vacía», es plan fuera de
  alcance.
- La cuenta observada en panel es **Free** (dominio sandbox). Ninguna celda de Basic,
  Foundation o Scale sale de panel — todas son de la página pública [F1]. La
  escalera de volumen (más allá del plan base) no es observable sin contratar un plan
  de pago, según el propio panel: `"Pricing details"` no abrió panel interno [F24].
- **DISC-02 se cerró midiendo el 2026-09-21** y la celda de Plantillas ya no lleva las
  dos lecturas. La matriz tenía razón: el endpoint responde en Free. Basic no se midió
  y hereda la conclusión porque ninguna fuente lo distingue de Free en este punto.
- El plan `"Growth"` que menciona la FAQ de IP dedicada de [F1] no aparece en ninguna
  columna de esta matriz porque no está en la tabla de precios ni en el bloque
  `pricingData.plans`; queda fuera hasta confirmar si es alias, histórico u otro
  producto.
