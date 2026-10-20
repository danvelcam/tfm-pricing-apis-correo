# Matriz funcional — Mailchimp Transactional / Mandrill (D-019, CRITERIOS G)

Construida el 2026-09-21 desde `fuentes.md`, dentro del ciclo de recolección (G1). Regla G2:
celda «—» donde ninguna fuente registrada lo dice; nada se infiere de otro plan ni de otra
API. Escalón: **doc** = documentación pública · **panel** = observación de panel con cuenta
propia ([F18], 2026-09-21, cuenta trial). Producto modelado: transaccional (Mailchimp
Transactional / Mandrill, add-on sobre cuenta Mailchimp Standard/Premium/Heredada).

## Fricción de partida (F-08 candidata)

Mailchimp Transactional **no tiene planes con nombre**. No hay filas ni tarjetas tipo
Free/Basic/Pro en la página de precios ([F3]): hay una única superficie de producto, vendida
por bloques de 25.000 correos con precio degresivo por volumen (F-02), como add-on sobre una
cuenta Mailchimp Standard, Premium o Heredada de pago. La premisa de G1 —«matriz funcional
por plan»— no tiene planes que columnar. Esta matriz usa en su lugar las dos superficies que
sí distingue la evidencia recogida: la **cuenta de prueba (demo/trial)**, observada por panel
y API el mismo día, y **la cuenta de pago**, que es un único nivel sin variación funcional
documentada por volumen — el volumen solo mueve el precio, nunca qué endpoints o features
están disponibles (A4: ninguna fuente ata un endpoint a un tramo de bloques). Se deja
constancia explícita: esto no es una matriz por plan, es la matriz de un producto único con
dos estados de cuenta, y la fricción F-08 se anota para el consejo.

## Features por estado de cuenta

| Feature | Cuenta demo / trial | Cuenta de pago | Fuente · escalón |
|---|---|---|---|
| Webhooks de eventos | — (no observado en esta pasada de panel) | disponible por API: `"Add a new webhook"` (`POST /webhooks/add`) | [F2] doc |
| IP dedicada | enlace visible en el panel, `"You don't have any dedicated IPs. Manage Dedicated IPs"`, sin poder confirmar si se puede contratar desde trial | add-on opcional, `"Agrega una IP exclusiva por $29.95 al mes (opcional)"` — sin requisito de volumen mínimo publicado | [F18] panel · [F3] doc |
| Retención de actividad | 30 días: `"Your transactional email history is stored for only 30 days."` | — (el número de la cuenta de pago no lo publica ninguna fuente revisada) | [F15] doc |
| Dominios (de envío/firma) | `"No sending domains yet. To start sending through Mandrill, you need to verify ownership of your sending domain and update your DNS records."`; alta y verificación también por API (`senders/add-domain`, `senders/verify-domain`) | mismo mecanismo; sin tope de número de dominios publicado | [F18] panel · [F2] doc |
| Usuarios | — | — | ninguna fuente registrada (ver Huecos) |
| Entrada de correo (inbound) | — (no observado en panel) | disponible por API: `"Add inbound domain"` (`inbound/add-domain`), rutas con `inbound/add-route`; límite demo de recepción `"receive up to 100 inbound emails per day"` | [F2] doc · [F15] doc (límite demo) |
| SMTP | credenciales visibles desde el trial: `"Host smtp.mandrillapp.com Port 587"`, usuario y contraseña derivados de la API key | mismo host/puerto; tope de destinatarios `"up to 1,000 recipients at a time"` | [F18] panel · [F4] doc |
| Plantillas | — (no observado en panel esta pasada) | disponible por API: `"Creates a new email template with the specified content and settings."` (`templates/add`) | [F2] doc |

## Otras features registradas

| Feature | Cuenta demo / trial | Cuenta de pago | Fuente · escalón |
|---|---|---|---|
| Franquicia de envío incluida | `"Free trial sends — 0 of 500"`; `"You can send up to 500 transactional emails to any email address on your verified domain"`, sin caducidad (`"do not expire or renew"`) | no aplica (franquicia es solo del arranque de la cuenta, no recurrente) | [F18] panel · [F3] doc · [F15] doc |
| Cuota horaria | `25` — `"Email sends this hour — 0 of 25"` (panel) y `"hourly_quota":25` (API); coincide con `"Demo accounts are limited to a fixed hourly quota of 25 emails"` | sin cifra publicada: depende de reputación y volumen histórico, `"very different"` entre cuentas | [F18] panel · [E1] sondeo · [F6] doc · [F15] doc |
| SMS transaccional (fuera de alcance, A1) | `"SMS credits — 0 of 0"` | add-on de pago, sin cifra de precio recogida en esta pasada | [F18] panel · [F3] doc |
| Estado de reputación | `"Reputation: Unknown"` / `reputation: 0` por API, recién creada la cuenta | escala `"Excellent, Good or Poor"`, sin cifras que la liguen a la cuota horaria concreta | [F18] panel · [E1] sondeo |
| Caducidad y contador de uso de la API key | columnas `"Expires"` y `"Remaining"` visibles en el panel, ambas vacías en esta cuenta | mismo mecanismo (no observado con clave caducada) | [F18] panel |
| Rate limit propio de un endpoint | `/messages/search`: `"20 searches per minute"`, 429 al superarlo, reposición a los 60 s de la primera petición | mismo (rate de endpoint, no de plan — B8) | [F7] doc · [F10] doc |

## Preguntas de clase L instanciadas

- **PI-E01** «¿Mailchimp Transactional ofrece retención de actividad configurable, como el
  add-on de Postmark (`"Custom Activity Retention — Starts at $5/month"`)?» → **configurable
  no; fijo y publicado, sí, y solo para la cuenta de prueba**. La página de ayuda de la demo
  cifra la retención en treinta días —`"Your transactional email history is stored for only
  30 days. After that, you will not be able to see the contents of the transactional emails
  or to whom the emails were sent."`, transcrita con navegador el 2026-09-21—. Para la cuenta
  de pago ninguna fuente revisada publica número, y ahí la matriz sigue respondiendo «no
  consta», que no es «no».
- **PI-E02** «¿Qué add-on de IP dedicada es más barato para una cuenta que envía 300.000
  correos al mes: el de Mailchimp Transactional o el de Postmark?» → **Mailchimp
  Transactional**, `"$29.95 al mes"` sin requisito de volumen mínimo publicado [F3], frente a
  Postmark, `"Starts at $50/month per IP"` con el requisito `"sending 300,000 emails per
  month or more"` (`postmark/fuentes.md` [F1]). A igualdad de volumen, el add-on de Mailchimp
  es ~40 % más barato y no exige alcanzar un mínimo de envío para contratarlo.

## Huecos

No hay columnas de plan con nombre porque el producto no las tiene (F-08 candidata, ver
arriba). Dentro de las dos columnas que sí hay, quedan vacías: la retención de la cuenta de pago (la
de la demo sí está cifrada, treinta días), usuarios/equipo (no se buscó ni se observó), y tres
features —webhooks, inbound y plantillas— que están confirmadas **por API** pero no se
comprobaron en el panel en esta pasada, así que su columna de panel queda sin dato aunque la
de API sí lo tenga. No es que la cuenta demo carezca de ellas: es que ninguna fuente
registrada las observó ahí todavía.
