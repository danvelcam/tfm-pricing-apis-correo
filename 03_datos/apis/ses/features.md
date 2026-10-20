# Matriz funcional — Amazon SES (D-019, CRITERIOS G)

Celda = valor literal + fuente. Donde ninguna fuente registrada lo dice, la celda es «—», y
eso es un hueco declarado, no una omisión.

**Una advertencia que condiciona la tabla entera.** En SES la función no cuelga solo del
plan: cuelga del plan, de la **región** y del **estado de la cuenta**. Una fila con cuatro
columnas es, en rigor, una proyección. Donde el eje real es otro, la celda lo dice.

**El comparador de planes, ya capturado (2026-09-18).** La tabla `"Compare plans"` de [F39]
llena las tres columnas de pago: `"✓"` es incluido y `"Add-on"` es aparte. El volcado está en
`evidencias/paginas/2026-09-18/aws_amazon_com_ses_pricing.txt`, y cada celda de abajo se
comprobó contra él. Tres precisiones sobre lo que el comparador **no** trae. Solo tiene tres
columnas, así que la de à la carte sigue saliendo de la tabla `"À la carte pricing"` de la
misma página. Sus trece filas no son las de esta matriz, que se construyó por tarifa: donde el
comparador parte una función en varias, aquí hay varias filas. Y las cantidades incluidas no
están en la tabla, sino en sus notas al pie.

**Las notas al pie se numeran tres veces en la misma página.** La tabla de planes va de la 1 a
la 3, el comparador de la 1 a la 10 y el tarifario à la carte de la 1 a la 5. Abajo se cita
siempre con el bloque delante: la nota 3 del comparador no es la nota 3 de la tabla de planes.

**La nota 7 no cuelga de ninguna fila, sino del rótulo `"Enterprise"`.** Dice `"The Enterprise
plan includes one annual expert deliverability assessment with actionable recommendations for
Enterprise customers subscribed 12+months with 6B+ trailing emails"`, con dos condiciones de
elegibilidad. Es capacidad del plan y no de una función, así que se registra aquí y no en una
fila.

## Features por plan

| Feature | À la carte | Essentials | Pro | Enterprise | Fuente · escalón |
|---|---|---|---|---|---|
| Cuota fija mensual | `"-"` | `"-"` | `"$105"` | `"$500"` | [F39] doc, fila `"Per account per region per month"`; **por cuenta y por región** |
| Precio por correo, primer tramo | `"$0.10 / 1,000 emails"` | `"$0.16 per 1,000 emails"` | `"$0.22 per 1,000 emails"` | `"$0.23 per 1,000 emails"` | [F39] doc. **No entra en el YAML**: v0.3 no tiene campo para el precio unitario sin cuota incluida (F-29) |
| Volumen incluido | ninguno de correos | ninguno de correos | ninguno de correos | ninguno de correos | [F39] doc (`"you pay only for what you use with no minimum fees"`). Es el hallazgo: el catálogo no tenía ningún proveedor sin volumen **de correos** contratado. **La unidad importa, y el comparador la matiza:** en inquilinos, validaciones de API, dominios, IP, pruebas de lista semilla y endpoint de entrada abierto sí hay cantidad incluida con precio de exceso, cada una en su fila. Lo que ningún plan incluye son correos |
| Sobrecoste por exceso | no existe en correos | no existe en correos | no existe en correos | no existe en correos | [F39] doc: los tramos son marginales, no hay recargo ni corte. **En las otras unidades sí lo hay:** `"$0.005/month/tenant for additional tenants"` (nota 6 del comparador), `"Extra API validations at $0.01/validation"` (nota 4), `"$50 per endpoint per month"` (nota 9) y `"Overages: $25/domain, $12.50/IP, $10/seed list test"` del tarifario à la carte |
| Correo saliente (`"Outbound Email"`) | `"$0.10 / 1,000 emails"` | incluido (`"✓"`) | incluido (`"✓"`) | incluido (`"✓"`) | [F39] doc, comparador, bloque `"Outbound sending"`. Nota 1 del comparador: `"Could be an email sent using SES Outbound (charged per recipient) or additional recipients beyond the first when using the 'Send to Internet' rule action in Mail Manager."` — el proveedor vuelve a escribir que **se cobra por destinatario** (DISC-02). Adjuntos aparte (`"Additional charges of $0.12 per gigabyte (GB) of data in the attachments you send"`) y simulador al mismo precio (`"Mailbox Simulator emails will be billed at the same rate as Outbound Email"`) |
| API transaccional | sí | sí | sí | sí | [F19] doc (116 acciones en la versión 2) |
| SMTP | sí | sí | sí | sí | [F7] doc. **No en 10 de las 29 regiones con endpoint de API** |
| Plantillas almacenadas | sí | sí | sí | sí | [F19] doc (`CreateEmailTemplate`); tope de `"20,000"` por región y `"500 KB"` por plantilla [F1] |
| Entrada de correo (inbound) | sí | sí | sí | sí | [F20] doc (16 acciones de recepción, solo en la versión 1) · [F21] doc (Mail Manager es otra API). **No en las dos regiones de GovCloud** |
| Eventos | destinos, no webhooks | ídem | ídem | ídem | [F19] doc: `CloudWatch`, `EventBridge`, `Kinesis Firehose`, `Pinpoint` y `SNS`; **cero coincidencias de `Webhook` o `Http`** en las 116 acciones |
| Lista de supresión | sí | sí | sí | sí | [F14] doc. En entorno de pruebas, las operaciones de alta y de importación están deshabilitadas |
| IP dedicada (estándar) | `"$24.95 / month / IP"` | add-on (`"Add-on"`) | add-on (`"Add-on"`) | add-on (`"Add-on"`) | [F39] doc. Tope de `"50"` grupos de IP por región [F1]. El comparador **no la separa de BYOIP**: una sola fila, `"Dedicated IPs - Standard/BYOIP"`, add-on en los tres planes |
| BYOIP (IP propia) | `"$24.95 / month / IP"` | add-on (`"Add-on"`) | add-on (`"Add-on"`) | add-on (`"Add-on"`) | [F39] doc, misma fila del comparador que la IP estándar. Mínimo de entrada: `"The minimum number of addresses you can bring is 256 which creates a minimum cost of $24.95 x 256 = $6,387.20 per month."` |
| IP dedicada (administrada) | `"$15 / month / account"` + tarifa por correo | add-on (`"Add-on"`) · `"Essentials plan customers pay $1,250 per month (includes 5 domains, 12 DIPs, and 25 seed list test)"` | incluido (`"✓"`) · `"Pro includes 1 domain, 1 DIPs and 5 seedlist tests"` | incluido (`"✓"`) · `"Enterprise includes 5 domains, 12 DIPs, and 25 seed list tests"` | [F39] doc. El tramo por encima de 100 M dice `"Contact us"` en la página y sí tiene cifra en el tarifario máquina (O-03). Las cantidades de las tres celdas salen de la **nota 3 del comparador**, que cuelga de esta fila; qué describen de verdad no está cerrado (punto 3 de abajo) |
| Virtual Deliverability Manager · entregabilidad de SES | `"Per-email fee + query fee"` | incluido (`"✓"`) | incluido (`"✓"`) | incluido (`"✓"`) | [F39] doc, comparador `"Virtual Deliverability Manager - SES deliverability"`, **sin nota al pie**. Escalera propia y consultas: `"$0.07/1,000 emails (0–10M emails per month), $0.05/1,000 emails (10–100M emails per month), $0.02/1,000 emails (>100M emails per month). Queries: $0.0005/1,000 queries (first 5K queries/month are free)"` |
| Virtual Deliverability Manager · entregabilidad global | `"$1,250 / month"` | add-on (`"Add-on"`) | incluido (`"✓"`) | incluido (`"✓"`) | [F39] doc. `"$1,250 / month"` la variante global, **no disponible en GovCloud ni en la nube soberana europea** (nota 2 del comparador). Paquete à la carte: `"Per region per account. Includes 5 domains, 12 IPs, and 25 seed list tests/month. Overages: $25/domain, $12.50/IP, $10/seed list test."` |
| Global Endpoints | `"$0.03 / 1,000 emails"` | add-on (`"Add-on"`) | add-on (`"Add-on"`) | incluido (`"✓"`) | [F39] doc. Se suma al precio base y solo al enrutar: `"On top of base sending price, only when sent through multi-region endpoint ID"`. Nota 5 del comparador: `"Not available in AWS European Sovereign Cloud. Global Endpoints requires multi-region routing, which is not supported in partitions with a single region."` |
| Validación de correo | `"$0.01 per validation"` | add-on (`"Add-on"`) | incluido (`"✓"`) · `"2,500 API validations/account/region/month"` | incluido (`"✓"`) · `"5,000 API validations/account/region/month"` | [F39] doc. Nota 4 del comparador: `"Includes Auto Validation for all emails sent."` y `"Extra API validations at $0.01/validation"`. Lo incluido son **validaciones por API**, por cuenta, región y mes |
| Tenants | `"$0.005 / month / tenant + $0.005 / 1,000 emails"` | add-on (`"Add-on"`) | add-on (`"Add-on"`) | incluido (`"✓"`) | [F39] doc. Tope de `"10,000"` por región [F7], que es otra magnitud que la incluida. Nota 6 del comparador: `"1,000 tenants included per account per region; $0.005/month/tenant for additional tenants"`, **sin distinguir plan**, mientras el comparador sí lo distingue; ninguna fuente registrada dice cómo se combinan |
| Mail Manager · procesamiento de correo | `"$0.15 / 1,000 emails"` | incluido (`"✓"`) | incluido (`"✓"`) | incluido (`"✓"`) | [F39] doc, comparador `"Email Processing"`, bloque `"Inbound processing and routing (Mail Manager)"`. Nota 8: `"$0.09/1000 incoming email chunks and $0.10/1000 recipients beyond the first recipient when using the 'Send to Internet' rule action."` |
| Mail Manager · endpoint de entrada autenticado | sin cargo (`"complimentary"`) | incluido (`"✓"`) | incluido (`"✓"`) | incluido (`"✓"`) | [F39] doc, comparador `"Authenticated Ingress Endpoint"`, **sin nota al pie**. La gratuidad la dice el tarifario à la carte: `"we provide a complimentary authenticated ingress endpoint that only accepts emails from credentialed senders"` |
| Mail Manager · endpoint de entrada abierto | `"$50 / month / endpoint"` | add-on (`"Add-on"`) · `"$50 per endpoint per month"` | add-on (`"Add-on"`) · `"$50 per endpoint per month"` | incluido (`"✓"`) · `"1 Open Ingress Endpoint per account per region"` | [F39] doc, comparador `"Open Ingress Endpoint"` y nota 9. El cargo no para al cerrarlo: `Charges apply even when endpoint status is "Closed." Delete the endpoint to stop charges. Pro-rata billing.` |
| Mail Manager · complementos de correo | `"Trend Micro Virus Scanning: $0.1875/1,000 emails; SpamHaus IP Reputation: $0.125/1,000 emails; Abusix Guardian Mail: $0.125/1,000 emails; Vade Advanced Email Security: $0.415/1,000 emails"` | add-on (`"Add-on"`) | incluido (`"✓"`) · `"Pro plan includes Trend Micro"` | incluido (`"✓"`) · `"Enterprise includes Trend Micro and Spamhaus"` | [F39] doc, comparador `"Email Add-Ons"` y nota 10, que la nota 9 repite palabra por palabra. Los demás siguen costando: `"Additional add-ons are chargeable."` |
| Mail Manager · archivado | `"$2 per GB of emails ingested; $0.19 per GB per month for storage and search"` | add-on (`"Add-on"`) | add-on (`"Add-on"`) | add-on (`"Add-on"`) | [F39] doc, comparador `"Archiving"`, única fila del bloque `"Outbound sending & Inbound processing and Email routing (Mail Manager)"` y **sin nota al pie**. Es una de las dos filas que son add-on en los tres planes; la otra es `"Dedicated IPs - Standard/BYOIP"` |
| Plan gratuito | **en discrepancia** | ídem | ídem | ídem | [F43] lo ofrece en presente, [F41] lo declara retirado el 2026-07-21 y [F39] no lo menciona (DISC-18) |

## Límites de recurso, que en SES son por región y no por plan

| Recurso | Tope | Ámbito | Fuente |
|---|---|---|---|
| Identidades verificadas | `"10,000 identities per AWS Region."` | región | [F1] doc |
| Plantillas | `"20,000"` | región | [F1] doc |
| Configuration sets | `"10,000"` | región | [F1] doc *(ajustable según [F7] y no ajustable según [F1]: DISC-01)* |
| Tenants | `"10,000"` | región | [F7] doc |
| Grupos de IP dedicada | `"50"` | región | [F1] doc |
| Conjuntos de reglas de recepción | `"40"` | **cuenta** | [F1] doc *(y conviven con los de región sin que ninguna fuente explique el criterio: DISC-06)* |
| Filtros de IP | `"100"` | **cuenta** | [F1] doc |
| Listas de contactos | `"Only one contact list is allowed per AWS account."` | **cuenta** | [F15] doc |

## Lo que esta matriz no puede cerrar sin otra pasada

1. **Qué cambia con el acceso de producción** más allá de los dos límites. La documentación
   enumera cinco restricciones del entorno de pruebas y ninguna lista de lo que se gana.
2. **Si el tope de 10.000 identidades o de 20.000 plantillas cambia por región**, que solo se
   vería con otra región activada.
3. **De qué habla la nota 3 del comparador** *(hueco nuevo, de esta pasada)*. El marcador
   cuelga de `"Dedicated IPs - Managed"`, y su contenido —dominios, pruebas de lista semilla y
   `"$1,250 per month"`— repite cifra por cifra el paquete que el tarifario à la carte vende
   como `"Virtual Deliverability Manager – Global deliverability"`. O el marcador está mal
   puesto, o las dos funciones comparten paquete. La página no lo dice y esta matriz no lo
   decide: es candidata a discrepancia en `fuentes.md`.
