# Análisis comparativo — las ocho APIs del catálogo (capítulo 5)

Fecha: 2026-09-21, versión de ocho APIs. Las versiones anteriores, de tres (2026-09-07) y de
cuatro (2026-09-08, con el sondeo de MailerSend del 2026-09-09), están recogidas en §(e) y no se
han borrado: lo que cambió y por qué es material del capítulo.

Entradas, y no se ha leído ninguna otra fuente:

- Las ocho fichas de hechos: `hechos_postmark.md`, `hechos_resend.md`, `hechos_sendgrid.md`,
  `hechos_mailersend.md`, `hechos_brevo.md`, `hechos_ses.md`, `hechos_mailgun.md` y
  `hechos_mailchimp.md`. Toda cifra de este documento lleva el id del hecho que la sostiene.
- `03_datos/preguntas/{PREGUNTAS.md,catalogo.yaml}` (v0.1.1, con la clase L) y
  `03_datos/apis/<api>/features.md`, este último solo para las dos preguntas de clase L.
- Las ejecuciones de PRIME4API en local: `prime4api_ejecucion/` y `prime4api_ejecucion_d024/`
  (las cuatro primeras APIs, 2026-09-07), `prime4api_ejecucion_mailersend/` (2026-09-08) y
  `prime4api_ejecucion_2026-09-21/` (Brevo, SES, Mailgun y Mailchimp, con su `CONTRASTE.md`).
- `docs/01-ecosistema.md`, solo para la definición de Q1–Q10.

Convenciones:

- `[PM-nn]` Postmark · `[RS-nn]` Resend · `[SG-nn]` SendGrid · `[MS-nn]` MailerSend ·
  `[BR-nn]` Brevo · `[SE-nn]` Amazon SES · `[MG-nn]` Mailgun · `[MC-nn]` Mailchimp Transactional.
  Si el hecho lleva 🟡 o 🔴 en la Datasheet, la celda lo dice. «no en YAML» = el hecho existe en
  las fichas (provenance, `not_found`, evidencias) pero el campo no está serializado.
- «no publicado [id]» = existe una fila de «lo que el proveedor no publica». «sin fila» = ninguna
  ficha lo trata.
- Mes = 30 días = 2 592 000 s; día = 86 400 s. Con 31 días los cocientes cambian un 3,3 % y ninguna
  conclusión se mueve. En MailerSend la ventana mensual es literalmente «resets every 30 days»
  [MS-32]: la ventana de su Datasheet y el «mes» del motor son la misma cosa. Brevo también, y medido:
  `GET /v3/account` devuelve treinta días exactos anclados al alta [BR-113, BR-17]. En las otras seis el «mes»
  del motor y la ventana del fichero no coinciden necesariamente.
- Las operaciones P se calcularon a mano y después se ejecutaron contra PRIME4API como servicio REST
  en local (D-022, D-024): las P están medidas, las H siguen clasificadas por especificación
  (HARVEY4API no ejecutado). De Q1–Q10 solo se conoce la definición de Q8, Q9 y Q10; para las demás
  se usa la descripción del propio catálogo.
- **Tres convenciones del motor**, medidas y no supuestas, que explican casi todas las diferencias
  entre el cálculo a mano y la respuesta de PRIME4API: la ráfaga se cuenta en t = 0; el instante
  final de un intervalo abre la ventana siguiente; y la cuota expandida por presupuesto se aplica a
  cada ventana, no al total del horizonte.
- Las cuatro APIs nuevas entraron con sondeo ejecutado el mismo día de su cierre. Donde una respuesta
  depende de un valor medido y no publicado, la celda lo dice; el semáforo no baja por un sondeo (D6).

---

## (a) Capacidad por API y plan

Entradas de esta sección: `hechos_postmark.md`, `hechos_resend.md`, `hechos_sendgrid.md`,
`hechos_mailersend.md`, `hechos_brevo.md`, `hechos_ses.md`, `hechos_mailgun.md`,
`hechos_mailchimp.md` y `analisis.md` (versión de cuatro APIs, modelo de formato). Prefijos:
`[PM-nn]` Postmark · `[RS-nn]` Resend · `[SG-nn]` SendGrid · `[MS-nn]` MailerSend · `[BR-nn]`
Brevo · `[SE-nn]` Amazon SES · `[MG-nn]` Mailgun · `[MC-nn]` Mailchimp Transactional. Las
dieciséis primeras filas son las del fichero modelo, sin cambios: ningún hecho de las cuatro
APIs nuevas contradice una cifra de Postmark, Resend, SendGrid o MailerSend.

| API · plan | Cuota (valor, ventana) | Rate (valor, ventana) | Destinatarios por petición | Otros topes por petición | Sobrecoste | Vigencia / caducidad | Precio |
|---|---|---|---|---|---|---|---|
| **Postmark · Free** | 100 emails / 1 mes [PM-24 🟢]; ventana = ciclo de cuenta, renueva el 2026-09-04 [PM-28 🟢, PM-80]. En *test mode* 100 en total y solo a dominios verificados [PM-29, no en YAML] | **no publicado** [PM-82 🟡, PM-36 🟡]. La respuesta del sondeo [E2] trae `ratelimit-limit: 5000` y `x-ratelimit-limit-second: 5000` [PM-40, sin semáforo, discrepancia abierta] | 50 en total To+Cc+Bcc [PM-43…PM-48 🟢 sondeo]; la doc dice «Max 50» por campo [PM-42 🟢, DISC-01] | 10 MB por mensaje [PM-54, no en YAML]; `/email/batch` 500 mensajes [PM-51 🟡, PM-52 🟡, PM-93 🟡] y 50 MB [PM-55]; `/email/batchWithTemplates` 500 [PM-53 🟢]; `/email/bulk` sin tope numérico, 50 MB [PM-58 🔴, PM-59] | no admitido [PM-65, no en YAML] | mensual, sin planes anuales [PM-90]; Datasheet 2026-08-03 [PM-72] | $0.00/mo [PM-02 🟢], USD [PM-01 🟢] |
| **Postmark · Basic** | «Starting at 10,000 emails/month» [PM-25 🟡]; escalera del panel 10 000 · 50 000 · 125 000 · 300 000 · 700 000 · 1 500 000 [PM-07 🟡, PM-08…PM-12 no en YAML]; ventana no explicitada [PM-86 🟡] | ídem Free: **no publicado** [PM-82 🟡]; [PM-40] sin leer | ídem: 50 [PM-43…PM-48 🟢] | ídem Free | $1.80 / 1 000 [PM-66 🟢]; $1.70 desde el escalón 300 000 [PM-70, no en YAML] | mensual [PM-03]; el cambio de plan exige aprobación de la cuenta [PM-23] | $15.00/mo [PM-03 🟢]; $55 (50k) … $775 (1,5M) [PM-08…PM-12, no en YAML] |
| **Postmark · Pro** | «Starting at 10,000» [PM-26 🟡]; ventana [PM-86 🟡]; precio × volumen no observable [PM-87] | **no publicado** [PM-82 🟡] | 50 [PM-43…PM-48 🟢]; también en `/email/withTemplate` [PM-50 🟢] | ídem + `/messages/inbound` [PM-06]; 35 MB adjuntos de entrada [PM-56] | $1.30 / 1 000 [PM-67 🟢] | mensual [PM-04]; [PM-23] | $16.50/mo [PM-04 🟢] |
| **Postmark · Platform** | «Starting at 10,000» [PM-27 🟡]; ventana [PM-86 🟡]; [PM-87] | **no publicado** [PM-82 🟡] | 50 [PM-43…PM-48 🟢] | ídem Pro | $1.20 / 1 000 [PM-68 🟢] | mensual [PM-05]; [PM-23] | $18.00/mo [PM-05 🟢] |
| **Resend · Free** | 3 000 emails / 1 mes [RS-20 🟢] **y** 100 / 1 día [RS-21 🟢]; ventana diaria *rolling* [RS-25 🟡, RS-100 🟡, lectura pendiente RS-98 🟡]; ventana mensual sin fecha de ciclo [RS-101 🟡]; enviados y recibidos cuentan [RS-29, RS-30, no en YAML] | 10 requests / 1 s por equipo [RS-50 🟢 doc; RS-54 🟢 panel; RS-55 🟢 sondeo]; compartido por todas las claves [RS-52] | 50 en total to+cc+bcc [RS-62…RS-64 🟢 sondeo]; la doc solo lo pone en `to` [RS-60 🟢, DISC-04] | `/emails/batch` 100 mensajes [RS-65 🟢], tope conjunto sin aclarar [RS-106]; adjuntos 40 MB tras base64 [RS-67, no en YAML]; batch sin adjuntos [RS-68] | no admitido [RS-83, no en YAML] | sin fecha de ciclo [RS-97]; Datasheet 2026-09-01 [RS-90] | $0/mo [RS-01 🟢], USD [RS-08 🟢] |
| **Resend · Pro** | 50 000 / 1 mes [RS-22 🟢]; sin límite diario [RS-27]; ventana [RS-101 🟡]; 100 000 a $35 [RS-03, no en YAML] | 10 / s, mismo valor por defecto (decisión Q3) [RS-51 🟢, RS-104]; ampliable «upon request» [RS-53] | 50 [RS-62…RS-64 🟢] | ídem Free | $0.90 / 1 000 [RS-80 🟢]; interruptor PAYG apagado por defecto [RS-84] | mensual [RS-02]; [RS-90] | $20/mo [RS-02 🟢] |
| **Resend · Scale** | 100 000 / 1 mes [RS-23 🟢]; escalera 200k · 500k · 1M · 1,5M · 2,5M [RS-05, no en YAML]; ventana [RS-101 🟡] | 10 / s por decisión Q3 [RS-51 🟢, RS-104] | 50 [RS-62…RS-64 🟢] | ídem Free | $0.90 / 1 000 [RS-80 🟢], baja hasta $0.46 a 2,5M [RS-81, no en YAML] | mensual [RS-04] | $90/mo [RS-04 🟢]; $160 … $1 150 [RS-05, no en YAML]; IP dedicada $30 [RS-11] |
| **Resend · Enterprise** | Custom [RS-24 🟢]; «3M+ emails/month» [RS-07] | **no publicado** [RS-102 🔴, RS-53 🔴, RS-58 🔴] | 50 [RS-62…RS-64 🟢] | ídem Free | Custom [RS-85] | sin fila | Custom [RS-06 🟢] |
| **SendGrid · Free Trial** | 100 / 1 día [SG-22 🟢, SG-23, SG-25 🟢 sondeo], tope duro `is_hard_limit: true` [SG-24, SG-25]; ventana medianoche UTC [SG-26 🟢], hora exacta no publicada [SG-103] | 10 000 requests / 1 s en `/v3/mail/send` [SG-46 🟢], publicado una vez en una FAQ sin condición de plan [SG-113]; sin cabeceras en `mail/send` [SG-54]; 600 y 6 leídos en otros endpoints [SG-51, SG-52, no en YAML] | 1 000 en total to+cc+bcc [SG-57 🟢, SG-59 🟢 sondeo en sandbox] | 1 000 personalizations [SG-60 🟢, SG-61 🟢]; 30 MB [SG-62 🟡]; custom_args 10 000 bytes [SG-65]; `send_at` ≤ 72 h [SG-67]; SMTP 10 000 direcciones [SG-71] | no admitido [SG-24, SG-80] | 60 días [SG-87]; termina el 2026-11-05 [SG-89]; después capacidad cero [SG-88]; Datasheet 2026-09-06 [SG-86] | $0/mo for 60 days [SG-01 🟢] |
| **SendGrid · Essentials** | 50 000 / 1 mes [SG-29 🟢]; 100 000 a $34.95 [SG-30, SG-06, no en YAML]; ventana *billing period* [SG-34 🟢] | 10 000 / s [SG-46 🟢, SG-113] | 1 000 [SG-57 🟢, SG-59 🟢] | ídem Trial | $0.00133 por email (panel) [SG-77 🟢]; $0.0013 en la web [SG-76, DISC-01]; **tope 10× el plan** = 500 000 [SG-81, no en YAML] | mensual, pagado por adelantado [SG-41]; [SG-86] | $19.95/mo [SG-02 🟢] |
| **SendGrid · Pro** | 100 000 / 1 mes [SG-31 🟢]; escalera 300k · 700k · 1,5M · 2,5M [SG-32, no en YAML]; ventana [SG-34 🟢] | 10 000 / s [SG-46 🟢] | 1 000 [SG-57 🟢, SG-59 🟢] | ídem Trial + gzip a petición [SG-64] | $0.0011 [SG-77 🟢], baja hasta $0.00047 a 2,5M [SG-77]; tope 10× [SG-81] | mensual [SG-03] | $89.95/mo [SG-03 🟢]; $249 … $1 099 [SG-06, SG-08, no en YAML]; 1 IP incluida [SG-11] |
| **SendGrid · Premier** | Custom [SG-33 🟢]; ventana [SG-34 🟡] | 10 000 / s [SG-46 🟢] | 1 000 [SG-57 🟢] | ídem Pro | Custom [SG-76]; tope no publicado [SG-104] | sin fila | Custom [SG-04 🟢, SG-107] |
| **MailerSend · Free** | 500 emails / 30 días [MS-27 🟢], ventana `fixed_billing_cycle` en 🟡 [MS-32, MS-29]; tope duro, «sendings will be paused» [MS-29]; **y** 100 emails / 1 día [MS-28 🟡 valor, 🔴 ventana; DISC-11: cuatro fuentes dicen 100 *requests*]; **y** 100 peticiones / 1 día a medianoche UTC, común a API y SMTP [MS-35 🟢, MS-34 🟢]; los entrantes reenviados cuentan [MS-40, no en YAML]; exige tarjeta y aprobación [MS-02]; antes de aprobar, Sandbox: 100/mes y 2 destinatarios [MS-89, MS-90] | 120 requests / 1 min en `/v1/email` [MS-45 🟢]; 60 / min en el resto [MS-44 🟢]; 10 / min «under review» [MS-48, no en YAML]; el sondeo [E1] midió 10 / min con 429 en la cuenta Sandbox sin aprobar [MS-163], no el 120 | 70 = 50 to + 10 cc + 10 bcc, suma no publicada como total [MS-59 🟡, MS-113 🟡]; sin aprobar 10 + 1 + 1 [MS-60, no en YAML] | text/html 2 MB y 25 MB por adjunto, sin tope total de mensaje [MS-68, MS-121]; subject 998, 5 tags, `send_at` ≤ 72 h [MS-69]; `/v1/bulk-email` no nombrado en Free [MS-67, no en YAML] | no admitido [MS-81] | ventana 30 días o «next billing day» [MS-32, DISC-12]; Datasheet 2026-09-08 [MS-88]; sin changelog [MS-99] | $0 [MS-01 🟢], USD [MS-08 🟢] |
| **MailerSend · Hobby** | 5 000 / 30 días [MS-30 🟢, MS-32 🟢]; **y** 1 000 peticiones / 1 día [MS-35 🟢] | 120 / min [MS-45 🟢]; lote `/v1/bulk-email` 10 / min [MS-46 🟢]; «newly upgraded accounts may have a lower rate limit» sin cifra [MS-49, no en YAML] | 70 [MS-59 🟡] | ídem Free; lote 500 objetos, 35 000 correos y 50 MB [MS-63 🟢, MS-64 🟢, MS-65] | $1.50 / 1 000 [MS-78 🟢]; tope de gasto lo fija el cliente [MS-82, no en YAML]; tope del proveedor no publicado [MS-83, MS-126] | mensual [MS-32]; anual $6.30 [MS-07, no en YAML]; sin escalera de volumen [MS-03] | $7.00/mo [MS-03 🟢] |
| **MailerSend · Starter** | 50 000 / 30 días al primer peldaño [MS-31 🟢]; escalera 100K $68 · 250K $162.50 · 500K $325 · 1M $600 [MS-19, no en YAML]; tope 500 000 o 1 000 000 según la página [MS-22, MS-125, DISC-06]; **y** 100 000 peticiones / 1 día [MS-35 🟢] | 120 / min [MS-45 🟢]; lote 15 / min [MS-46 🟢, DISC-08 cerrada por E4] | 70 [MS-59 🟡] | ídem Hobby | $1.30 / 1 000 [MS-79 🟢] → $1.10 (250K–500K) → $1.00 (1M) [MS-80, no en YAML] | mensual [MS-32]; anual $31.50 [MS-07, MS-21]; solo legible con JavaScript [MS-23] | $35.00/mo [MS-04 🟢] |
| **MailerSend · Professional** | 50 000 / 30 días al primer peldaño [MS-31 🟢]; escalera 100K $140 · 250K $275 · 500K $525 · 1M $1 000 · 1.5M $1 350 · 2M $1 600 [MS-20, no en YAML]; **y** 500 000 peticiones / 1 día [MS-35 🟢] | 120 / min [MS-45 🟢]; lote 30 / min [MS-46 🟢, DISC-08 cerrada por E4] | 70 [MS-59 🟡]; Enterprise sube cc y bcc a 50 [MS-61, no en YAML] | ídem Hobby; `headers` y `list_unsubscribe` solo aquí [MS-70] | $1.30 [MS-79 🟢] → $1.00 (250K) → $0.80 (500K) → $0.60 (1M–1.5M) → $0.50 (2M) [MS-80, no en YAML] | mensual [MS-32]; anual $99 [MS-07]; IP dedicada $50 con requisito 500 000/mes [MS-108, DISC-04] | $110.00/mo [MS-05 🟢] |
| **Brevo · Free** | 300 emails / 1 día [BR-08 🟢, BR-62 🟢]; equivalente «9 000/mes» es aritmética (300×30), no un segundo tope, DISC-07 cerrada [BR-30 🟡, BR-31]; ventana sin hora ni huso declarados, 🔴 [BR-71 🔴, BR-156 🔴] | Tramo General, común a los cinco planes: `POST /v3/smtp/email` 1 000 RPS / 3 600 000 RPH [BR-82 🟡]; `GET /v3/smtp/emails` 2 RPS medido y verde [BR-110 🟢, BR-119 🟢]; ventana de 1 s anclada al reloj, medida [BR-118 🟢, DISC-17 cerrada] | 2 000 en total (to+cc+bcc, vía `messageVersions`) sin adjunto [BR-107 🟡, BR-121, BR-122]; baja a 99 por petición si hay adjunto [BR-70 🟢, condición 2 de F-25] | correo entero ≤ 20 MB, adjuntos incluidos, 🟡 por denominador (D1/D13) [BR-145 🟡]; adjunto de plantilla ≤ 4 MB [BR-146]; idempotencia 30 min [BR-131]; lote (`messageVersions`) hasta 1 000 mensajes/llamada, caudal propio 100/min ≈ 6 000/h, en discrepancia con la tabla general (DISC-01/02 abiertas) [BR-127, BR-128] | no admitido, «there are no additional fees» [BR-14, BR-147, F-27]; créditos prepago disponibles como *add-on*, no como recargo [BR-26, BR-40] | mensual, 30 días exactos anclados al alta (`startDate`/`endDate`) [BR-113 🟢, DISC-09 resuelta]; Datasheet 2026-09-16 [BR-149] | $0/mo [BR-01 🟢], USD [BR-32 🟢] |
| **Brevo · Starter** | «From 5,000 emails per month» [BR-07 🟢, BR-33 🟢]; escalera 5k…100k [BR-09, no en YAML]; sin tope diario [BR-33 🟢] | ídem Free (tramo General) [BR-82 🟡] | ídem Free: 2 000 sin adjunto / 99 con adjunto [BR-107 🟡, BR-70 🟢] | ídem Free | ídem Free; auto-ascenso de plan disparado por contactos, no por correos [BR-41] | mensual [BR-17, BR-36]; [BR-41] | $9.00/mo [BR-02 🟢]; escalera $9,00…$82,00 [BR-09, no en YAML] |
| **Brevo · Standard** | «From 5,000… up to 500,000» [BR-34 🟢]; la misma página da «Up to 1M» en otra tabla, discrepancia abierta sin efecto de color (DISC-06) [BR-20, BR-34] | ídem Free (tramo General) [BR-82 🟡] | ídem Free | ídem Free | ídem Free | mensual [BR-17, BR-36] | $18.00/mo [BR-03 🟢]; escalera $18,00…$429,00 [BR-10, no en YAML] |
| **Brevo · Professional** | «From 150,000 monthly email sends»; hasta 10 M [BR-35 🟢] | Tramo General **y** Advanced: `POST /v3/smtp/email` 2 000 RPS / 7 200 000 RPH [BR-84 🟡]; activación (al contratar o bajo demanda) sin publicar [BR-160 🟡] | ídem Free | ídem Free | ídem Free | mensual [BR-17, BR-36] | $499.00/mo [BR-04 🟢]; escalera $499,00…$4 543,00 [BR-11, no en YAML] |
| **Brevo · Enterprise** | Custom [BR-05 🟢]; suelo de volumen solo en el panel, «From 1 million emails per month» — la doc pública no lo cifra [BR-48, no en YAML] | Tramo General + Advanced + Extended: `POST /v3/smtp/email` 6 000 RPS [BR-85 🟡] | ídem Free | ídem Free | Custom [BR-05 🟢] | mensual [BR-17, BR-36] | Custom, «Talk to sales» [BR-05 🟢] |
| **SES · à la carte** | 200 emails / 24 h, entorno de pruebas, compartida por los cuatro planes del fichero (`plan_verticals`) [SE-50 🟢, SE-137]; ventana sin ancla horaria declarada, 🔴 [SE-58 🔴, SE-169 🔴]; **no es cuota de plan**: el gobierno real es el par cuenta × región, y la cuota de producción no tiene cifra publicada para ningún plan [SE-61, SE-152, SE-09] | 1 req/s en pruebas, ídem cuota [SE-80 🟢, SE-137]; medido 5,7 req/s sin rechazo y 140,8 req/s con 429 en otra ruta de lectura [SE-102 🟡, SE-103]; caudal de producción no publicado [SE-104, SE-153 🔴] | 50 por mensaje, to+cc+bcc [SE-106 🟢, SE-107 🟢]; igual en correo con plantilla [SE-108] | 40 MB tras base64 (API v2/SMTP) [SE-109 🟢]; sobre 10 MB, estrangulado hasta 40 MB/s [SE-111 🟢]; 500 partes MIME [SE-112]; tope de entradas de `SendBulkEmail` no publicado [SE-115 🟢 solo MBs, SE-157] | Sin campo: el precio real por correo existe y es marginal por tramo ($0,10/1 000 + $0,12/GB de adjunto en à la carte), pero v0.3 solo tiene `overage_cost` sobre una cuota incluida que aquí no existe [SE-15, SE-47, SE-168] | upgrades inmediatos, downgrades al siguiente ciclo [SE-21]; sin capa gratuita modelada, discrepancia DISC-18 abierta, regla A3 [SE-172] | $0.00/mo de cuota fija [SE-02 🟢]; es el estado por defecto sin plan elegido [SE-08 🟢] |
| **SES · Essentials** | ídem à la carte (cuota compartida del entorno de pruebas) [SE-137] | ídem à la carte [SE-137] | ídem à la carte [SE-106 🟢] | ídem à la carte | Sin campo; tarifa real marginal $0,16 / $0,14 / $0,11 por 1 000 según tramo [SE-10, SE-47] | ídem à la carte | $0.00/mo de cuota fija («-» en la tabla de precios) [SE-03 🟢] |
| **SES · Pro** | ídem à la carte [SE-137] | ídem à la carte [SE-137] | ídem à la carte | ídem à la carte | Sin campo; tarifa real $0,22 / $0,17 / $0,12 por 1 000 [SE-11, SE-47] | ídem à la carte | $105.00/mo de cuota fija [SE-04 🟢] |
| **SES · Enterprise** | ídem à la carte [SE-137] | ídem à la carte [SE-137] | ídem à la carte | ídem à la carte | Sin campo; tarifa real $0,23 / $0,18 / $0,13 por 1 000 [SE-12, SE-47] | ídem à la carte | $500.00/mo de cuota fija [SE-05 🟢] |
| **Mailgun · Free** | 100 emails / 1 día [MG-33 🟡] **y** 3 000 / 1 mes en el panel [MG-34 🟡]; ninguna fuente dice si la diaria compone la mensual (DISC-03 abierta) [MG-35 🟡]; sin ancla de reinicio, 🔴 [MG-41 🔴] | 1 500 API requests/s por IP de cliente, único umbral publicado [MG-50 🟡, MG-51 🟡]; medido en el envío: `x-ratelimit-limit: 80000` sobre una ventana de ~10 s [MG-58 🟡, MG-60 🟡]; ventana anclada a la primera petición, no rodante, y **no encaja en ningún `window_type` de v0.3** [MG-61, MG-62, MG-109]; 429 no alcanzado, ámbar por D6 [MG-67 🟡] | 1 000 por lote, medido: 1 001 devuelve 400 [MG-69 🟢, MG-71 🟢]; el recuento se aplica antes que los permisos de cuenta [MG-73] | tamaño publicado de 25 MB no se aplica; el único tope real medido es el de la petición entera, 52 MiB (413) [MG-74, MG-76, MG-77 🟡]; parámetros `o:`/`h:`/`v:`/`t:` 16 KB [MG-79, MG-80 medido]; segundo contador de 2 000 000 destinatarios/ventana sin nodo donde colgarse [MG-59, MG-108] | ninguno publicado para Free [MG-101] | mensual; `window_type` de los planes de pago es inferido, Free se queda sin ancla [MG-15, MG-40 🟡, MG-41 🔴]; dominio de pruebas no puede enviar a terceros [MG-49] | $0/mo [MG-02 🟢], USD [MG-01 🟢] |
| **Mailgun · Basic** | 10 000 / 1 mes [MG-37 🟢]; «No daily email limit» [MG-36] | ídem Free; el caudal medido viene de una cuenta Free y se referencia igual a los cuatro planes por falta de atribución [MG-64 🟡] | ídem Free: 1 000 [MG-69 🟢] | ídem Free | $1.80 / 1 000 [MG-98 🟢] | mensual, `window_type` inferido [MG-40 🟡] | $15.00/mo [MG-03 🟢] |
| **Mailgun · Foundation** | 50 000 / 1 mes en el escalón mínimo [MG-38 🟢]; escalera hasta 100k a $75 [MG-07, no en YAML] | ídem Free [MG-64 🟡] | ídem Free | ídem Free; IP dedicada incluida desde 100k [MG-16] | $1.30 / 1 000 en el mínimo [MG-99 🟢]; baja a $1.10 en 100k [MG-102, no en YAML] | mensual; «Free for 1 month, then $35» es promoción, no precio de lista [MG-04, MG-12] | $35.00/mo [MG-04 🟢] |
| **Mailgun · Scale** | 100 000 / 1 mes en el escalón mínimo [MG-39 🟢]; escalera hasta 2,5M [MG-08, no en YAML] | ídem Free [MG-64 🟡] | ídem Free | ídem Free; IP dedicada y 5 000 validaciones incluidas [MG-16, MG-17] | $1.10 / 1 000 declarado en el mínimo, baja a $0.40 en el escalón de 2,5M — 2,75 veces de distancia dentro del mismo plan [MG-100 🟢, MG-103] | mensual; «Free for 1 month, then $90» es promoción [MG-05, MG-12] | $90.00/mo [MG-05 🟢] |
| **Mailchimp · Transactional (bloque, cuenta de pago)** | 25 000 emails por bloque, 1 mes [MC-03 🟢, MC-25 🟢]; `window_type` inferido, día de reinicio no publicado [MC-26 🟡, MC-98 🟡]; sin plan con nombre, entrada única `plans.transactional_email` [MC-02, F-32] | Cuota horaria existe y no tiene cifra para cuenta de pago: depende de la reputación, «their hourly quotas will be very different» [MC-49, no en YAML]; el único caudal numérico de toda la API es `/messages/search`, 20 req/min [MC-55 🟢, MC-56 🟢] | Sin tope publicado ni medido por rechazo: «no recipient limitation» y 5 000 destinatarios aceptados en una sola llamada [MC-60 🔴, MC-129 🔴] | payload de la llamada < 10 MB [MC-61 🟢]; tamaño del mensaje entregado ≤ 25 MB, magnitud distinta y conjuntamente inalcanzable con el payload [MC-62, MC-63]; medido: ~40 MB de payload sin rechazo [MC-127, MC-128 🟢]; sin *endpoint* de lote, el array `to` va dentro de la misma llamada [MC-65] | no hay recargo por unidad excedida: el modelo es prepago por bloques y agotar el bloque detiene el envío [MC-84, MC-27]; el sobrecoste lo sustituye la compra del siguiente bloque, a precio degresivo [MC-85] | mensual, sin arrastre de saldo [MC-27]; día de reinicio no publicado [MC-98 🟡] | $20.00/bloque/mes en el tramo de entrada, 1-20 bloques (hasta 500k correos/mes), precio en ámbar por ser precio de unidad prepagada y no de plan [MC-04 🟡, MC-11]; escalera hasta $10,00/bloque en 161+ bloques; sin cifra por encima [MC-09, MC-12, MC-107] |
| **Mailchimp · demo (cuenta de prueba)** | 500 envíos totales, sin ventana: «no expire or renew», hueco declarado, 🔴 [MC-18 🟢, MC-29 🟢, MC-30 🔴, MC-31 🔴]; una sola vez por cuenta [MC-32] | 25 emails/hora, confirmado en documentación, panel y API medida (`hourly_quota: 25`) [MC-42 🟢, MC-44 🟢, MC-45 🟢] | Sin tope medible por rechazo: 5 000 destinatarios aceptados en una llamada [MC-129 🔴]; entre 10 y 11 destinatarios la API deja de confirmar el envío (pasa a `queued` async) [MC-125 medido, MC-126] | payload < 10 MB publicado, medido sin aplicarse hasta ~40 MB [MC-61 🟢, MC-127, MC-128 🟢]; entrada de correo 100/día, sin *endpoint* que lo referencie [MC-35]; modo de pruebas aparte, 10 000/día, no modelado mientras la ventana esté en discrepancia (DISC-02 abierta) [MC-36] | no aplica: la demo no admite compra | sin ventana declarada, 🔴 [MC-30 🔴]; termina al agotar los 500 envíos o por revocación [MC-31] | $0, incluido en la franquicia de la cuenta [MC-18, MC-22] |

Mailgun no modela un plan Enterprise: la página solo ofrece «Request a quote» sin volumen ni
precio, y queda fuera por la regla A3 [MG-10, MG-121], igual que Enterprise de MailerSend en el
fichero modelo.

Tres cosas rompen la forma de la tabla y hay que decirlo aquí, no dejarlas en una celda muda.
Amazon SES no gobierna la capacidad por plan: la gobierna el par cuenta × región, así que las
cuatro filas comparten la misma cuota y el mismo caudal —los del entorno de pruebas— porque es
lo único que el proveedor cifra; la cuota y el caudal de producción no se publican para ningún
plan [SE-09, SE-137, SE-61, SE-104]. Y el precio real de SES, el que paga el cliente por correo,
tampoco tiene columna: existe al céntimo en dos tarifarios, pero v0.3 solo admite `overage_cost`
sobre una cuota incluida, y ningún plan de SES incluye correos [SE-15, SE-47, SE-168]. Mailchimp
Transactional no tiene planes con nombre: vende tramos de bloques prepago sobre una sola entrada
del esquema, y el único estado con cifras duras y medidas es la cuenta de prueba —500 envíos y
25/hora—, mientras que la cuenta de pago no publica ninguna cifra de caudal, solo el mecanismo
por reputación [MC-02, MC-49, MC-42…MC-45]. Y Mailgun publica un caudal de envío que sí midió el
sondeo —80 000 peticiones cada aproximadamente diez segundos, anclado a la primera petición de
la ventana— pero cuya ventana no rodante y no fija no encaja en ninguno de los tres
`window_type` de v0.3 [MG-60, MG-61, MG-62, MG-109].

Lectura rápida de la tabla. Son 31 filas. Veintitrés traen rate y cuota numéricos: las catorce
del fichero de cuatro APIs, las cuatro de Brevo con plan cerrado, las cuatro de Mailgun y la fila
`demo` de Mailchimp. Dos traen rate y no cuota, SendGrid Premier y Brevo Enterprise, las dos
«Custom». Una trae cuota y no rate, el bloque de pago de Mailchimp, cuyo caudal se describe y no
se cifra. Y una no trae ninguna de las dos, Resend Enterprise. Suman 27, que son las filas que no
son de SES.

Las cuatro de SES no caben en ese recuento. Sus números son numéricos y no son del plan que
encabeza la fila: son del entorno de pruebas, el único estado que el proveedor cifra, y lo cifra
para el par cuenta × región.

---

## (b) Relación límites–rates observada

Notación: R = rate publicado (req/s), W = ventana de la cuota en segundos, Q = cuota (emails), k = destinatarios
por petición. La restricción activa es la del umbral menor. Para un consumo uniforme a caudal medio c (emails/s):

- la cuota restringe si c > Q/W;
- el rate restringe si c > R·k.

El cociente R·W·k/Q dice cuántas veces cabría la cuota en la ventana al rate máximo. El tiempo mínimo para
agotar la cuota es Q/(R·k). El umbral k\* = Q/(R·W) es el número de destinatarios por petición a partir del cual
manda el rate y no la cuota.

Con ocho APIs esa notación se queda corta en tres sitios, y los tres salen de las cuatro nuevas:

- **Mailgun publica dos contadores sobre el mismo nodo y la misma ventana**, uno de peticiones y otro de
  destinatarios [MG-58 🟡, MG-59]. Hay entonces dos términos de rate, R en peticiones y R_d en destinatarios, y
  el que corta depende de k. El esquema admite un solo caudal por nodo, así que el segundo no está en la
  Datasheet [MG-108].
- **Mailchimp declara su caudal en correos por hora y no en peticiones** [MC-42 🟢]. Ahí k no multiplica nada:
  la fórmula c > R·k se reduce a c > R.
- **Mailchimp deja una cuota sin ventana** [MC-30 🔴]. Sin W no hay cociente R·W/Q que formar, y la franquicia
  de 500 correos es un saldo que se gasta una vez y termina la cuenta de prueba [MC-31 🔴].

La unidad de la cuota es por destinatario en Resend [RS-28 🟢] y SendGrid [SG-35], y está **medida** en Brevo
[BR-112 🟢] y en SES [SE-182 🟢]. En las otras cuatro no lo está: sin confirmar en Postmark [PM-92], modelada y no
publicada en MailerSend [MS-39, MS-114], inferencia declarada en Mailgun [MG-148] y no verificable en Mailchimp,
porque la página que lo trataría devuelve 403 [MC-110]. Cuatro de las ocho sostienen la unidad con documentación o con medición; las
otras cuatro la arrastran como supuesto, y es el supuesto que multiplica todo lo demás por k.

Mes = 30 días = 2 592 000 s; día = 86 400 s. En MailerSend la ventana mensual es literalmente
«resets every 30 days» [MS-32], y en Brevo el sondeo midió `startDate` y `endDate` a treinta días exactos
anclados al alta [BR-113 🟢], con el literal `"the subscription period is 30 days"` detrás [BR-17 🟢]. Son **dos**
las APIs del catálogo donde la ventana de la Datasheet y el mes del motor son la misma cosa, no una; la versión
de cuatro APIs decía que MailerSend era la única y eso deja de valer.

---

### Postmark — R = 5 000 req/s adoptado en ámbar [PM-97, PM-98]; k ≤ 50 [PM-43…PM-48 🟢]

El rate REST no está publicado [PM-82 🟡, PM-36 🟡]; solo existe el 429 sin umbral. El valor con el que se
calcula es la cabecera `ratelimit-limit: 5000` / `ratelimit-reset: 1`, vista en el sondeo [E2] [PM-40] y medida en
el sondeo de caudal [E4] [PM-97]. Fueron 200 peticiones en 4,57 s: el contador baja dentro de cada segundo y se
repone al siguiente, con el 429 no alcanzado. D-024 la adopta en `max_power` en 🟡, un solo valor para los cuatro planes
[PM-98]; verde solo si un sondeo alcanza el 429.

**Free, ventana mensual (ciclo de cuenta)** [PM-24 🟢, PM-28 🟢]:

- 5 000 req/s × 2 592 000 s = **12 960 000 000 req/mes** (1,296·10¹⁰) frente a **100 emails/mes** → el rate permite
  129 600 000 veces la cuota (k = 1); con k = 50, 6,48·10⁹ veces.
- Umbral de la cuota: 100/2 592 000 = **0,0000386 emails/s** (uno cada 7,2 h). Umbral del rate: 5 000 emails/s
  (k = 1) o 250 000 emails/s (k = 50).
- **Restricción activa: la cuota.** Se agota en 100/5 000 = **0,02 s** (k = 1) o 100/250 000 = **0,0004 s** (k = 50).

**Basic, ventana mensual** [PM-25 🟡, ventana PM-86 🟡]:

- 12 960 000 000 frente a **10 000 emails/mes** → **1 296 000 veces** (k = 1); 64 800 000 veces (k = 50).
- Umbral de la cuota: 10 000/2 592 000 = **0,00386 emails/s** (uno cada 259 s).
- **Restricción activa: la cuota**, por seis órdenes de magnitud. Agotamiento en 2 s (k = 1) o 0,04 s (k = 50).
  El motor responde 1 s con k = 1 (`prime4api_ejecucion_d024/PI-D01_postmark.json`).
- Último escalón del panel, 1 500 000 [PM-12, no en YAML]: 8 640 veces; umbral 0,579 emails/s; agotamiento 300 s
  (k = 1) o 6 s (k = 50). Pro y Platform parten de la misma cuota de 10 000 [PM-26 🟡, PM-27 🟡] y dan las mismas
  cifras que Basic.

Reservas propias de Postmark. El rate está medido y no publicado, y el 429 no se ha forzado. `/email/batch`
admite 500 mensajes por llamada [PM-95 🟢, PM-51]. Ningún hecho dice si los 50 por mensaje y los 500 por lote se
combinan, así que no se multiplica. En `/email/bulk` el ritmo lo fija el proveedor [PM-37 🔴]: ahí el rate no
es siquiera un parámetro del consumidor.

### Resend — R = 10 req/s por equipo [RS-50 🟢, RS-54 🟢, RS-55 🟢]; k ≤ 50 [RS-62…RS-64 🟢]

**Free, ventana diaria** [RS-21 🟢]:

- 10 req/s × 86 400 s = **864 000 req/día** frente a **100 emails/día** → 8 640 veces (k = 1); 432 000 veces (k = 50).
- Umbral de la cuota: 100/86 400 = **0,001157 emails/s** (uno cada 14,4 min). Umbral del rate: 10 emails/s (k = 1)
  o 500 emails/s (k = 50).
- **Restricción activa: la cuota.** La cuota diaria se agota en 10 s (k = 1) o en 0,2 s (k = 50). La ventana diaria
  está en 🟡 [RS-25 🟡, RS-100 🟡]: si fuese fija en vez de *rolling* cambiaría el momento de reposición, no el
  cociente.

**Free, ventana mensual** [RS-20 🟢]:

- 25 920 000 req/mes frente a **3 000 emails/mes** → 8 640 veces (k = 1).
- Umbral: 3 000/2 592 000 = **0,001157 emails/s**, exactamente el mismo que el diario, porque 3 000/30 = 100. La
  cuota diaria no añade capacidad ni la quita; **prohíbe adelantar consumo**. Ventana mensual en 🟡 [RS-101 🟡].

**Pro, 50 000/mes** [RS-22 🟢], sin límite diario [RS-27]:

- 25 920 000 frente a 50 000 → **518,4 veces** (k = 1); 25 920 veces (k = 50).
- Umbral de la cuota: 50 000/2 592 000 = **0,01929 emails/s** (uno cada 51,8 s).
- **Restricción activa: la cuota.** Agotamiento al rate máximo: **83,3 min** (k = 1) o **100 s** (k = 50).
- El rate de Pro es el valor por defecto asignado por decisión Q3, no una cifra por plan [RS-51 🟢, RS-104].
- Con el segundo volumen (100 000 a $35 [RS-03, no en YAML]): 259,2 veces; 2,78 h (k = 1); 200 s (k = 50).

**Scale, 100 000/mes** [RS-23 🟢]: 259,2 veces (k = 1); umbral 0,0386 emails/s; agotamiento 2,78 h o 200 s.
Último escalón, 2 500 000/mes [RS-05, no en YAML]: **10,37 veces** (k = 1); umbral 0,9645 emails/s; agotamiento
69,4 h ≈ 2,9 días (k = 1) o 83,3 min (k = 50).

**Enterprise**: cuota Custom [RS-24 🟢] y rate no publicado [RS-102 🔴] → **no se calcula**. Acotación: la página
sitúa a Enterprise en «3M–500M+ emails/month» [RS-07]. Con el rate por defecto de 10 req/s, 25 920 000 req/mes
cubrirían 500 000 000 emails solo con k ≥ 19,3 de media. El único plan donde el rate podría ser la restricción
activa es justo el que no lo publica [RS-58 🔴].

Efecto de k y de la unidad de cuota: k multiplica la capacidad por hasta 50 y divide por 50 el tiempo de
agotamiento, sin cambiar cuál es la restricción activa en ningún plan publicado. Los correos **recibidos** gastan
la misma cuota [RS-29, RS-30, RS-31], así que la cuota puede agotarse sin que el consumidor haga ninguna
petición, cosa que el rate no gobierna. `/emails/batch` (100 mensajes por llamada [RS-65 🟢]) elevaría k, pero el
tope conjunto no se aclara [RS-106].

### SendGrid — R = 10 000 req/s en `/v3/mail/send` [SG-46 🟢]; k ≤ 1 000 [SG-57 🟢, SG-59 🟢]

Reserva que aplica a todos los cálculos. El 10 000 está publicado una sola vez, en una FAQ, sin condición de plan
[SG-113], y la Datasheet lo copia a los cuatro planes. `mail/send` no devuelve cabeceras de rate [SG-54] y el
caudal real «no es observable» [SG-100]. Es un 🟢 documental, no medido.

**Free Trial, 100/día** [SG-22 🟢], tope duro [SG-24, SG-25 🟢]:

- 864 000 000 req/día frente a **100 emails/día** → 8 640 000 veces (k = 1).
- Umbral 100/86 400 = **0,001157 emails/s**. **Activa: la cuota.** Agotamiento en **0,01 s** (k = 1).
- Con k = 1 000 una **sola petición** lleva diez veces la cuota diaria. El sondeo que verificó los 1 000 se hizo en
  *sandbox*, que no consume créditos [SG-40, SG-59].

**Essentials 50K, 50 000/mes** [SG-29 🟢], ventana *billing period* [SG-34 🟢]:

- 25 920 000 000 req/mes (2,592·10¹⁰) frente a **50 000** → **518 400 veces** (k = 1); 5,184·10⁸ veces (k = 1 000).
- Umbral 0,01929 emails/s. **Activa: la cuota, por cinco órdenes de magnitud.** Agotamiento en 5 s (k = 1) o en
  50 peticiones, 0,005 s (k = 1 000).
- Con el tope de sobrecoste 10× = 500 000/mes [SG-81, no en YAML]: umbral 0,193 emails/s; agotamiento 50 s.
- Essentials 100K [SG-30, no en YAML]: 259 200 veces; umbral 0,0386 emails/s; 10 s.

**Pro 100K, 100 000/mes** [SG-31 🟢]: 259 200 veces (k = 1); umbral 0,0386; agotamiento 10 s (k = 1) o 0,01 s
(k = 1 000). Pro 2.5M [SG-32, no en YAML]: **10 368 veces**; umbral 0,9645; 250 s o 0,25 s.

**Premier**: cuota Custom [SG-33 🟢] → **no se calcula**. Acotación: el pie «Premier 100M and above» [SG-33] da
100 000 000/2 592 000 = 38,6 emails/s, todavía 259 veces por debajo de 10 000 req/s con k = 1. **En SendGrid ningún
volumen publicado hace que el rate sea la restricción a consumo uniforme**: haría falta una cuota superior a
2,592·10¹⁰ emails/mes con k = 1.

Efecto de k: el volumen mensual entero de Essentials 50K cabe en 50 peticiones y el de Pro 2.5M en 2 500. Lo que
ata al consumidor es la cuota en emails, consumida por destinatario incluso si el correo se difiere o va a spam
[SG-35], contando «Processed + Dropped» [SG-36].

### MailerSend — R = 120 req/min = 2 req/s en `/v1/email` [MS-45 🟢]; k ≤ 70 [MS-59 🟡, MS-113 🟡]

Además del rate y de la cuota mensual hay una **cuota diaria de peticiones** a nivel de plan (Q_d, W_d = 86 400 s,
reposición a medianoche UTC [MS-34, MS-35, MS-36]). La cuota diaria y el rate están en la **misma unidad**, así
que su comparación no depende de k: el rate permite R·W_d = **172 800 peticiones al día**. Q_d es 100 en Free,
1 000 en Hobby, 100 000 en Starter y 500 000 en Professional [MS-35]. En tres de los cuatro planes Q_d < 172 800:
la cuota diaria es más estricta que el rate para cualquier k, y el rate por minuto solo manda a nivel de petición
en Professional (500 000/172 800 = 2,89).

Reservas. El 120/min es el valor por defecto de una cuenta sana, no una cifra por plan [MS-45, MS-117]. La cuenta
recién ascendida tiene «a lower rate limit» sin cifra [MS-49]. El sondeo [E1] midió 10/min con 429 en la cuenta
Sandbox sin aprobar [MS-163], que es otro estado. Y k = 70 es suma aritmética 🟡 [MS-113], mientras la unidad de la
cuota mensual está modelada y no publicada [MS-39, MS-114].

**Free, 500/30 días** [MS-27 🟢], Q_d = 100 [MS-35 🟢]: R·W = **5 184 000 req/mes** frente a 500 → 10 368 veces
(k = 1). Umbral mensual 500/2 592 000 = **0,000193 emails/s**. **Activa: la cuota mensual**, tope duro sin
sobrecoste [MS-29, MS-81]. Agotamiento al rate solo, 250 s; con la diaria de 100 peticiones, **4 días y 50 s**.
Con k = 70, 8 peticiones y ≈ 4 s.

**Hobby, 5 000/30 días** [MS-30 🟢], Q_d = 1 000 [MS-35 🟢]: **1 036,8 veces** (k = 1). Umbral mensual
**0,001929 emails/s**; diario 0,01157·k; rate 2·k. **Activa: la cuota mensual**, y detrás la diaria. Pero la
mensual tiene sobrecoste [MS-78] y el **techo duro** es la diaria: 30 000 correos/mes a k = 1. El motor da
5 184 000, 173 veces el techo real (H1, CONTRASTE MailerSend #13). Agotamiento: 41,7 min al rate, **4 días y 8 min**
con la diaria, 36 s con k = 70.

**Starter, 50 000/30 días** [MS-31 🟢], Q_d = 100 000 [MS-35 🟢]: **103,7 veces** (k = 1). Umbral mensual
**0,01929 emails/s**, el mismo que Resend Pro y SendGrid Essentials 50K. **Activa: la cuota mensual.** Agotamiento
6 h 57 min (k = 1) o ≈ 6 min (k = 70). Último peldaño, 1 000 000/mes [MS-19, no en YAML]: **5,18 veces**; umbral
0,386; **10 días** a k = 1 por la diaria.

**Professional, 50 000/30 días** [MS-31 🟢], Q_d = 500 000 [MS-35 🟢]: mismas cifras que Starter en el primer
peldaño. Umbral diario 5,787·k > 2·k: es el **único plan del catálogo donde el rate es más estricto que la cuota
diaria de peticiones**. Último peldaño, 2 000 000/mes [MS-20, no en YAML]: **2,59 veces** (k = 1), el cociente más
bajo de los ocho catálogos; umbral 0,772; agotamiento **11,6 días** (k = 1) o ≈ 4 h (k = 70).

**Estado «under review», R = 10 req/min** [MS-48, no en YAML; MS-50; MS-118]: R·W = **432 000 req/mes**, y seis de
los doce peldaños publicados la superan [MS-19, MS-20]. Starter 1M: 432 000/1 000 000 = **0,43** → el rate es la
restricción activa a k = 1, y hace falta k ≥ 3 para que vuelva a mandar la cuota. Professional 2M: 0,216, k ≥ 5.
Es el primer caso del catálogo en que R·W < Q para un volumen publicado. Y no aparece al subir de plan, sino al
cambiar el estado de la cuenta, que disparan «increased error rates» [MS-50]. Alcanzar un límite es lo que
estrecha el siguiente [MS-51].

k conecta aquí **tres contadores**: el rate por minuto, la cuota diaria de peticiones y la mensual de correos. Una
petición a `/v1/bulk-email` consume 1 de la diaria y hasta 35 000 de la mensual [MS-36, MS-64]. Y el motor razona
con dos de los tres, porque `_build_scenarios` no convierte a `emails` las cuotas de plan en `requests` (H1).

### Brevo — R = 1 000 req/s en `POST /v3/smtp/email` [BR-82 🟡]; k ≤ 2 000 [BR-107 🟡, BR-121 🟡]

Brevo es la primera API del catálogo que **publica caudales por tramo**: General para todas las cuentas, Advanced
para Professional y Enterprise, Extended para Enterprise [BR-81 🟡], con 1 000, 2 000 y 6 000 RPS en el endpoint de
envío [BR-82, BR-84 🟡, BR-85 🟡]. La atribución está en DISC-15: el distintivo que encabeza las tablas de Advanced
y Extended enumera los cinco planes, Free incluido, y en el DOM son enlaces a precios sin `role="tab"`, así que
afirman en vez de filtrar [BR-103b]. Por eso los tres valores están en 🟡.

**La segunda unidad no añade restricción.** Brevo declara RPS y RPH y exige respetar los dos a la vez [BR-80]. Cinco
filas publican las dos unidades, tres del tramo General y dos del Advanced. En las cinco el RPH es exactamente el
RPS por 3 600: 3 600 000/1 000, 7 200/2 y 36 000/10 [BR-82], 7 200 000/2 000 y 10 800/3 [BR-84]. Sostener el RPS
durante una hora entera agota justo el RPH, y el RPS prohíbe además la ráfaga, así que es estrictamente el más
estricto. Donde sí manda el RPH es en las filas que **no** publican RPS: el comodín `/v3/smtp/*` con 300 RPH, «all
other endpoints» con 100 RPH [BR-82] y las dos filas de Extended, 18 000 y 1 800 RPH [BR-85]. Ahí no hay cota por
segundo publicada, y el sondeo [E5] midió que `GET /v3/account`, declarado solo por hora, devuelve un
`x-sib-ratelimit-reset` que baja 12 unidades en 12,306 s: la unidad del contador es el segundo [BR-119 🟢].

**Free, 300 emails/día** [BR-62 🟢, BR-08 🟢]:

- 1 000 req/s × 86 400 s = **86 400 000 req/día** frente a **300 emails/día** → **288 000 veces** (k = 1).
- Umbral de la cuota: 300/86 400 = **0,003472 emails/s** (uno cada 288 s). Umbral del rate: 1 000 emails/s (k = 1) o
  2 000 000 emails/s (k = 2 000).
- **Restricción activa: la cuota.** Agotamiento en 300/1 000 = **0,3 s** (k = 1). Con k = 2 000 **la cuota entera del
  día no llena una sola petición**: una llamada al máximo lleva 6,7 veces los 300 correos.
- El Free no es muro seco: pasados los 300, hasta 1 000 correos más quedan en cola de reintento y lo que exceda no
  se entrega [BR-63 🟢]. La Datasheet no puede expresar muro más cola, y por eso F-24 vive [BR-63].
- El ancla del reinicio diario es el único 🔴 del panel [BR-71 🔴]: el contador dice «300 left out of 300 until
  17/09/2026» y ninguna fuente fecha la reposición.

**Starter y Standard, 5 000 emails/mes** [BR-07 🟢, BR-33 🟢, BR-34 🟢]:

- 1 000 × 2 592 000 = **2 592 000 000 req/mes** frente a **5 000** → **518 400 veces** (k = 1).
- Umbral: 5 000/2 592 000 = **0,001929 emails/s**, el mismo que MailerSend Hobby por tener la misma cuota
  [MS-30 🟢]. Agotamiento **5 s** (k = 1) o tres peticiones con k = 2 000.
- Los dos planes serializan el mismo valor de entrada y se separan solo en el techo publicado: Starter «Up to
  100,000 emails per month» y Standard «Up to 500,000» [BR-42 🟢]. Con el techo de Starter el cociente baja a
  25 920 y el umbral sube a 0,0386 emails/s, el mismo que Resend Scale y SendGrid Pro 100K.

**Professional, 150 000 emails/mes** [BR-35 🟢, BR-07 🟢]:

- 2 592 000 000 frente a 150 000 → **17 280 veces** (k = 1). Umbral **0,05787 emails/s**; agotamiento **150 s**.
- Con el tramo Advanced, si le corresponde, R·W = 5 184 000 000 → 34 560 veces y 75 s. El cociente se duplica y la
  restricción activa no se mueve: sigue siendo la cuota.
- Techo publicado, 10 000 000/mes [BR-42 🟢, no en YAML]: **259,2 veces** con el tramo General; umbral
  **3,858 emails/s**; agotamiento 10 000 s = **2 h 47 min**. Es el volumen publicado más alto de las ocho APIs y
  aun así el rate queda 259 veces por encima.

**Enterprise**: cuota custom [BR-05 🟢] → **no se calcula**. Acotación: el panel pone el suelo en «From 1 million
emails per month» [BR-48], dato que la documentación pública no da; con los 6 000 RPS del tramo Extended
[BR-85 🟡], 1,5552·10¹⁰ req/mes frente a 1 000 000 son 15 552 veces.

Reservas propias de Brevo:

- **El caudal es de la cuenta, no de la clave.** Seis lecturas alternando dos claves de la misma cuenta devuelven
  una serie única, 4999 · 4998 · 4997 · 4996 · 4995 · 4994 [BR-115]: crear claves no multiplica el caudal [BR-116].
- **La ventana del caudal se ancla al reloj del servidor.** Tras el 429 la reposición llegó 0,426 s después del
  rechazo y 0,702 s desde la primera petición de la serie, sondeando cada 250 ms [BR-118 🟢]. Es una ventana de un
  segundo fija, no rodante desde la primera petición.
- **k cae por veinte con un adjunto.** El tope general es 2 000 destinatarios por petición y 99 por versión de
  mensaje [BR-107 🟡, BR-122 🟡], pero «if you add an attachment… a maximum of 99 recipients» [BR-70 🟢]. El
  `workload` guarda un número y el proveedor publica dos, atados a una condición del cuerpo (F-25).
- **DISC-01 sigue abierta y es de factor 600.** El régimen general da 1 000 RPS, es decir 60 000 peticiones por
  minuto [BR-82]. La página de lote dice que el endpoint se ejecuta «up to 6000 times per hour (100 times per
  minute)», con 1 000 versiones por llamada y 6 000 000 de versiones por hora [BR-128]. Los dos números son del
  mismo proveedor y del mismo envío.

### Amazon SES — R = 1 req/s [SE-80 🟢, SE-81 🟢, SE-83 🟢]; k ≤ 50 [SE-106 🟢]; Q = 200 destinatarios/24 h [SE-51 🟢]

SES es la única de las ocho donde **el par cuota–rate no pertenece a ningún plan**. Los planes son cuatro
—à la carte, Essentials, Pro y Enterprise [SE-02…SE-05 🟢]— y PRIME4API lee los cuatro y devuelve la misma cuota,
`{'value': 200.0, 'unit': 'emails', 'period': '1day'}` [SE-137]. Los dos límites pertenecen al **estado** de la
cuenta y se modelan como alias `sandbox` colgado de las dos rutas de envío [SE-127 🟢]. Y el eje real es otro:
«Plans apply for each account and each AWS Region» [SE-09], con cuotas separadas por región [SE-63] y ninguna
cuota por identidad [SE-160]. La capacidad se gobierna por cuenta y región, no por plan.

**Entorno de pruebas**:

- 1 req/s × 86 400 s = **86 400 req/día** frente a **200 destinatarios/24 h** → **432 veces** (k = 1); con k = 50,
  4 320 000 destinatarios/día, 21 600 veces.
- Umbral de la cuota: 200/86 400 = **0,002315 emails/s** (uno cada 432 s). Umbral del rate: 1 emails/s (k = 1) o
  50 emails/s (k = 50).
- **Restricción activa: la cuota.** Agotamiento en 200/1 = **200 s** (k = 1) o **4 s** (k = 50).
- **432 es el cociente R·W/Q más bajo de todas las filas serializadas del catálogo.** Los siguientes son
  MailerSend Starter (103,7 veces con Q_d) y Resend Pro (518,4). Solo lo bajan dos escalones que no están en
  ningún YAML, MailerSend Starter 1M (5,18) y Professional 2M (2,59). Lo interesante no es el valor, es de dónde
  sale: SES tiene a la vez la cuota más pequeña y el caudal más pequeño de las ocho, y por eso el cociente se
  estrecha sin que la restricción activa cambie.

**La unidad es el destinatario, y está medida.** La cabecera de la tabla de cuotas lo dice —«Quotas are based on
the number of recipients, rather than on the number of messages»— mientras la fila de al lado cuenta
`emails` [SE-54, SE-55]. El sondeo lo cerró: cuatro mensajes aceptados con cinco destinatarios dejan el contador en
`"SentLast24Hours": 5.0` sobre `"Max24HourSend": 200.0` [SE-182 🟢]. Cinco descarta el mensaje como unidad, que
habría dado cuatro, y descarta la deduplicación, que también habría dado cuatro.

**Producción: los dos términos en rojo.** Ni la cuota ni el caudal de una cuenta con acceso de producción se
publican, con la misma fórmula en las dos páginas, «this number varies based on your specific use case»
[SE-61, SE-152, SE-153 🔴]. La única cifra que existe, 50 000 al día, es de un blog de 2014 y no se adopta
[SE-62]. Para los cuatro planes de pago **la relación límite–rate no se puede formar**: no es que el cociente
salga alto o bajo, es que no hay numerador ni denominador.

**Lo medido contra lo publicado.** Dos envíos consecutivos salen a 0,257 s y 0,518 s del inicio, los dos en 200,
contra un tope publicado de uno por segundo [SE-101]. Doce lecturas de `GET /v2/email/account` a 5,7 por segundo
dan doce 200 y cero rechazos, contra la frase que capa «todas las demás» operaciones a una por segundo
[SE-102 🟡, SE-84 🟡]. Treinta peticiones concurrentes a 140,8 por segundo sí alcanzan el rechazo:
`{"429": 9, "200": 21}` con `x-amzn-errortype: TooManyRequestsException`, ninguna con `retry-after` [SE-103]. El
rechazo se alcanzó en una ruta de lectura, así que acota y no decide.

**Y la ventana de la cuota está sin declarar por contradicción del proveedor.** Una página la describe rodante
—«This quota is calculated on a rolling time period»— [SE-59 🔴] y otra fija —«you will have to wait until the
next 24-hour period»— [SE-60 🔴]. La consola mezcla las dos en la misma fila, con la utilización «0 per hour» y la
cuota «per 24 horas» [SE-74 🔴]. El campo se deja vacío a propósito [SE-58 🔴, SE-169 🔴].

Un detalle de método que la relación límite–rate hereda: en SES la autorización se resuelve **antes** que el
caudal y antes que la identidad, así que el destinatario que el proveedor fuera a rechazar es el que IAM no
autoriza [SE-176]. La vía de medir sacando el dato del cuerpo de un error queda cerrada por construcción.

### Mailgun — R = 80 000 req / 10 s = 8 000 req/s [MG-58 🟡]; R_d = 2 000 000 destinatarios en la misma ventana [MG-59]; k ≤ 1 000 [MG-69 🟢, MG-71 🟢]

**La ventana de Mailgun no cabe en el esquema, y es el hallazgo más limpio de las cuatro APIs nuevas.** El caudal
del envío reparte 80 000 peticiones y 2 000 000 de destinatarios sobre una ventana **medida** de 9,852 s y 9,870 s
[MG-60 🟡], con un solo instante de reposición para los dos contadores [MG-59]. No es rodante: once peticiones en
dos tandas comparten exactamente dos valores de `reset`, uno por tanda, y en una ventana rodante cada petición
desplazaría el horizonte [MG-61]. Y no se ancla al calendario: la abre la **primera petición**, y al superarla el
contador vuelve entero al tope sin decaer [MG-62]. Ninguno de los tres `window_type` de v0.3 describe eso
[MG-109 🟡]. El periodo declarado, diez segundos, es un redondeo del 1,4 %. Con 80 000 peticiones esa diferencia
son 1 120 peticiones por ventana que el modelo no sabe si existen [MG-158].

**Dos contadores sobre el mismo nodo, y el que corta es el que la Datasheet no declara.** El punto de cruce es
exacto: 2 000 000/80 000 = **25 destinatarios por petición** [MG-159]. Por debajo de 25 manda el contador de
peticiones; por encima, el de destinatarios, que es el perfil de quien usa la API de lotes. El efecto se ve
mejor en el extremo. Con k = 1 000 el tope de destinatarios deja pasar 2 000 peticiones por ventana en vez de
80 000: **200 peticiones por segundo en vez de 8 000**, cuarenta veces menos que el caudal publicado. El esquema
admite un solo caudal por nodo, así que ese segundo contador está en `metadata.not_found` [MG-108].

**Y la Datasheet declara dos caudales para Mailgun, no uno.** El de arriba, 8 000 req/s, es el del nodo del
envío y está medido en la cabecera [MG-58 🟡]. El del plan es otro: 1 500 peticiones por segundo, documental y
acotado `"per client IP"` [MG-50, MG-51 🟡]. PRIME4API resuelve con el segundo como caudal sostenido y deja el
primero como ráfaga del endpoint, y por eso sus respuestas a PI-A06, PI-D01 y PI-G02 salen de 100 000/1 500 y
no de 100 000/8 000. Se publican los dos regímenes en vez de elegir uno (D-037). Los cocientes de este bloque
y los de §(c) están calculados con el 8 000, así que con el 1 500 se dividen por 5,3 y ningún veredicto se
mueve: el menor de los márgenes de Mailgun, el de Scale, pasa de 207 360× a 39 125× y sigue siendo de cuatro
órdenes de magnitud. Lo que no existe en ninguno de los dos es el caudal **de la cuenta**: el 1 500 es el techo
de una salida de red y el 8 000 el de un endpoint [MG-113 🟡, MG-156].

**Free** [MG-33 🟡, MG-34 🟡]: dos cuotas, 100 emails/día en la página pública y 3 000 emails/mes en el panel.

- Diaria: 8 000 × 86 400 = **691 200 000 req/día** frente a 100 → **6 912 000 veces** (k = 1). Umbral
  100/86 400 = **0,001157 emails/s**. Agotamiento **0,0125 s**; con k = 1 000 una sola petición lleva diez veces la
  cuota del día.
- Mensual: 8 000 × 2 592 000 = **2,0736·10¹⁰ req/mes** frente a 3 000 → **6 912 000 veces**, y umbral
  **0,001157 emails/s**. Los dos umbrales coinciden porque 3 000 = 100 × 30, como en Resend Free.
- La diferencia con Resend es que ahí la composición está publicada y aquí no: DISC-03 sigue abierta porque
  ninguna fuente dice si la cifra diaria compone la mensual o si son dos topes concurrentes [MG-35 🟡, MG-110 🟡].
  El bullet de Basic, «No daily email limit» [MG-36], empuja hacia la lectura de dos topes a la vez.
- Y ninguna de las dos tiene ancla de reposición: las dos `window_type` del Free están vacías [MG-41 🔴, MG-112 🔴].

**Basic, 10 000/mes** [MG-37 🟢]: **2 073 600 veces** (k = 1). Umbral **0,003858 emails/s**, el mismo que Postmark
Basic por tener la misma cuota [PM-25 🟡]. Agotamiento 1,25 s (k = 1) o 0,05 s (k = 1 000).

**Foundation, 50 000/mes** [MG-38 🟢]: **414 720 veces**. Umbral **0,01929 emails/s**, el mismo que Resend Pro,
SendGrid Essentials 50K y MailerSend Starter. Agotamiento 6,25 s o 0,25 s.

**Scale, 100 000/mes** [MG-39 🟢]: **207 360 veces**. Umbral **0,0386 emails/s**. Agotamiento 12,5 s o 0,5 s.
Último escalón, 2 500 000/mes [MG-08, no en YAML]: **8 294,4 veces**; umbral 0,9645 emails/s; agotamiento 312,5 s
(k = 1) o 12,5 s (k = 1 000). Obsérvese que k = 1 000 solo acelera 25 veces y no 1 000: el tope de destinatarios
se come el resto.

**Restricción activa: la cuota en los cuatro planes.** Con un matiz que ninguna de las otras siete tiene. En una
campaña de lotes, el tope que el consumidor alcanza antes no es ni la cuota ni el caudal declarado: es el
contador de destinatarios, que no está en el fichero.

Reservas propias de Mailgun:

- La única cifra de caudal que publica el proveedor, 1 500 req/s, está acotada **por IP de cliente**
  [MG-50 🟡, MG-51 🟡]. El esquema no tiene dimensión de ámbito, así que esa cifra es el techo de una salida de
  red y no el de la cuenta ni el del plan. Una cuenta con N salidas obtiene N veces el tope [MG-156].
- La documentación de la API describe las tres cabeceras `X-RateLimit-*` y el 429 **sin publicar ningún umbral**
  [MG-54 🔴, MG-55], y añade que las ventanas varían por API [MG-54]. DISC-01 sigue abierta entre esas dos fuentes
  oficiales [MG-106 🟡].
- **El caudal no se puede leer sin gastar un envío**: las cabeceras solo aparecen en un POST aceptado, y ni un GET
  ni un POST rechazado por permisos las traen [MG-63]. Observar el caudal y consumir la cuota no son separables
  en esta API [MG-146].
- El 429 del envío no se alcanzó, y por eso el caudal se adopta en 🟡: forzarlo son 80 000 peticiones en diez
  segundos, que es una campaña de carga y no un sondeo [MG-67 🟡]. La rampa de lectura llegó a 303 peticiones por
  segundo con cero 429, y ese techo es del cliente y no de la API [MG-65, MG-66].
- Ninguna fuente atribuye caudales por plan, y el valor se midió desde una cuenta Free [MG-64 🟡, MG-113 🟡].
- Que cada destinatario consuma una unidad de la cuota es **inferencia declarada**, no literal: ninguna fuente lo
  dice y el sondeo no llegó a enviar lo suficiente para comprobarlo [MG-148].

### Mailchimp Transactional — la relación no se puede formar, y eso es el resultado

Mailchimp es la única de las ocho donde **no hay caudal en peticiones**. El rate de la API REST general no está
publicado [MC-99]; el único endpoint con caudal propio es la búsqueda de mensajes, 20 peticiones por minuto
[MC-55 🟢, MC-56 🟢], que no envía nada. Lo que gobierna el envío es una **cuota horaria en correos**: 25 correos
a la hora en la cuenta de prueba [MC-42 🟢], confirmada en tres superficies y medida en la cuarta, `"hourly_quota":25`
en la respuesta de `POST /users/info` [MC-43 🟢, MC-44 🟢, MC-45 🟢]. Para la cuenta de pago no hay cifra: la fija
la reputación, y el proveedor lo escribe sin número, «their hourly quotas will be very different»
[MC-49, MC-95].

Eso rompe la notación por los dos lados:

- **k no multiplica.** El caudal ya está en correos, así que c > R·k se reduce a c > R. En las otras siete APIs k
  multiplica la capacidad entre 50 y 2 000 veces; aquí multiplica por uno. Y no es que k sea pequeño. La API
  aceptó **5 000 destinatarios en una sola llamada** sin cota alcanzada [MC-129, MC-102 🔴]. Mailgun, en cambio,
  rechaza la petición 1 001 con `{"message":"Too many recipients, max is 1000"}` [MG-71 🟢].
- **La franquicia no tiene ventana.** Los 500 correos de la cuenta de prueba «do not expire or renew» [MC-30 🔴],
  y el fin de la demo lo dispara el consumo, «You send 500 emails» [MC-31 🔴]. Sin W no hay R·W/Q. La única cifra
  que el par sí da es el tiempo: 500/25 = **20 horas** para agotar la franquicia a caudal máximo.

**Y de ahí sale el único caso de las ocho en que el caudal es la restricción activa en un estado sano.** Sobre
cualquier periodo sostenido, el tope que muerde en la cuenta de prueba es 25 correos/hora = **0,006944 emails/s**.
Es el caudal absoluto más bajo del catálogo. Queda 144 veces por debajo del entorno de pruebas de SES, que a
1 req/s con k = 1 da 3 600 correos a la hora [SE-81 🟢]. El otro caso del catálogo donde manda el rate es MailerSend bajo
revisión [MS-48], que es un estado degradado y no publicado.

**Para la cuenta de pago la relación queda sin poder evaluarse.** La cuota del bloque es 25 000 correos al mes
[MC-25 🟢], umbral **0,009645 emails/s**; el caudal que habría que comparar contra ese umbral no existe como
cifra [MC-49]. No se escribe una restricción activa porque los hechos no la sostienen.

**Mailchimp mide su cola, no su rechazo, y eso es un hallazgo sobre la relación y no una anécdota del sondeo.**
Hasta diez destinatarios la API evalúa en la propia llamada y responde `"status": "rejected"` con
`"reject_reason": "unsigned"`; desde once responde `"status": "queued"` con `"queued_reason": "multiple-recipients"`,
y el borde es exacto [MC-125]. Por encima de ese umbral la API **deja de decir si enviará** [MC-126]. Lo mismo
pasa con cualquier adjunto, que encola desde el primer byte [MC-167]. Las consecuencias son tres:

1. El exceso de envío no se rechaza: se encola y se reprocesa en la hora siguiente [MC-47, MC-48]. La tabla
   oficial de errores no tiene 429 ni 403 [MC-58, MC-101].
2. **Encolar no consume**: unos 7 600 destinatarios en cola y los tres contadores del panel siguen a cero dos
   horas después [MC-130, MC-132].
3. La vía de sondeo que este TFM usa en las otras siete —hacer que el proveedor rechace y leer el umbral en el
   cuerpo del error— **no existe aquí por encima de diez destinatarios y sin adjuntos** [MC-126]. El límite es de
   observabilidad, y cae justo sobre el régimen que interesa medir, el de lote.

Un dato más que conviene dejar dicho: el tope de tamaño de llamada que el proveedor publica, «less than 10MB»
[MC-61 🟢], se midió y **no se aplica**: ~40 MB de cuerpo JSON pasaron con HTTP 200 y ninguna respuesta habló de
tamaño [MC-128]. El campo se queda en 🟢 porque un sondeo no baja un literal oficial (D6).

---

### Resumen numérico

| API · plan | R·W (req por ventana) | Q (emails) | R·W/Q (k = 1) | Restricción activa | Umbral de la cuota (emails/s) | Tiempo mínimo para agotar Q (k = 1 / k = máx) | Datos en 🟡/🔴 implicados |
|---|---|---|---|---|---|---|---|
| Postmark · Free | 1,296·10¹⁰ | 100 [PM-24] | 129 600 000 | cuota | 0,0000386 | 0,02 s / 0,0004 s | rate medido, no publicado 🟡 [PM-97, PM-98] |
| Postmark · Basic | 1,296·10¹⁰ | 10 000 [PM-25 🟡] | 1 296 000 | cuota | 0,00386 | 2 s / 0,04 s | rate 🟡; cuota y ventana 🟡 [PM-25, PM-86] |
| Resend · Free (día) | 864 000 | 100 [RS-21] | 8 640 | cuota | 0,001157 | 10 s / 0,2 s | ventana diaria 🟡 [RS-25] |
| Resend · Free (mes) | 25 920 000 | 3 000 [RS-20] | 8 640 | cuota | 0,001157 | 300 s / 6 s (estirado a 30 días por el diario) | ventana mensual 🟡 [RS-101] |
| Resend · Pro | 25 920 000 | 50 000 [RS-22] | 518,4 | cuota | 0,01929 | 83,3 min / 100 s | rate por decisión Q3 [RS-51] |
| Resend · Scale | 25 920 000 | 100 000 [RS-23] | 259,2 | cuota | 0,0386 | 2,78 h / 200 s | ídem |
| Resend · Scale 2,5M | 25 920 000 | 2 500 000 [RS-05] | 10,37 | cuota | 0,9645 | 69,4 h / 83,3 min | escalón no en YAML |
| Resend · Enterprise | no calculable | Custom [RS-24] | — | — | — | — | rate 🔴 [RS-102] |
| SendGrid · Trial | 864 000 000 | 100 [SG-22] | 8 640 000 | cuota | 0,001157 | 0,01 s / 1 petición | rate no observable [SG-100] |
| SendGrid · Essentials 50K | 2,592·10¹⁰ | 50 000 [SG-29] | 518 400 | cuota | 0,01929 | 5 s / 0,005 s | ídem |
| SendGrid · Pro 100K | 2,592·10¹⁰ | 100 000 [SG-31] | 259 200 | cuota | 0,0386 | 10 s / 0,01 s | ídem |
| SendGrid · Pro 2.5M | 2,592·10¹⁰ | 2 500 000 [SG-32] | 10 368 | cuota | 0,9645 | 250 s / 0,25 s | escalón no en YAML |
| SendGrid · Premier | 2,592·10¹⁰ | Custom [SG-33] | — | — | — | — | cuota custom; ventana 🟡 [SG-34] |
| MailerSend · Free | 5 184 000 | 500 [MS-27] | 10 368 | cuota mensual (la diaria de 100 peticiones [MS-35] marca 5 días) | 0,000193 | 4 d 50 s / ≈ 4 s | ventana Free 🟡 [MS-32]; 100 emails/día 🟡/🔴 [MS-28]; k = 70 🟡 [MS-113] |
| MailerSend · Hobby | 5 184 000 | 5 000 [MS-30] | 1 036,8 | cuota: la diaria antes que la mensual a k = 1 (techo duro 30 000/mes) | 0,001929 | 4 d 8 min / 36 s | k = 70 🟡; unidad de cuota no publicada [MS-114] |
| MailerSend · Starter | 5 184 000 | 50 000 [MS-31] | 103,7 | cuota | 0,01929 | 6 h 57 min / ≈ 6 min | ídem; lote 15/min 🟢 [MS-46] |
| MailerSend · Starter 1M | 5 184 000 | 1 000 000 [MS-19] | 5,18 | cuota (la diaria estira a 10 d a k = 1) | 0,386 | 10 d / ≈ 2 h | escalón no en YAML; tope en discrepancia [MS-125] |
| MailerSend · Professional | 5 184 000 | 50 000 [MS-31] | 103,7 | cuota; único plan con rate más estricto que la diaria | 0,01929 | 6 h 57 min / ≈ 6 min | ídem; lote 30/min 🟢 [MS-46] |
| MailerSend · Professional 2M | 5 184 000 | 2 000 000 [MS-20] | 2,59 | cuota, por menos de un orden de magnitud | 0,772 | 11,6 d / ≈ 4 h | escalón no en YAML |
| MailerSend · Starter 1M «under review» | 432 000 | 1 000 000 [MS-19] | 0,43 | **rate** (k = 1); cuota solo con k ≥ 3 | 0,386 | no cabe en 30 d con k = 1 / ≈ 24 h (k = 70) | rate bajo revisión no en YAML [MS-48] |
| Brevo · Free (día) | 86 400 000 | 300 [BR-62] | 288 000 | cuota | 0,003472 | 0,3 s / menos de una petición | rate 🟡 [BR-82]; ancla del reinicio diario 🔴 [BR-71]; muro + cola de 1 000 [BR-63] |
| Brevo · Starter | 2,592·10⁹ | 5 000 [BR-07] | 518 400 | cuota | 0,001929 | 5 s / 3 peticiones | rate 🟡; k = 2 000 🟡 [BR-107]; k = 99 con adjunto [BR-70] |
| Brevo · Standard | 2,592·10⁹ | 5 000 [BR-34] | 518 400 | cuota | 0,001929 | 5 s / 3 peticiones | ídem |
| Brevo · Professional | 2,592·10⁹ | 150 000 [BR-35] | 17 280 | cuota | 0,05787 | 150 s / 75 peticiones | ídem; tramo Advanced en DISC-15 [BR-103b] |
| Brevo · Professional 10M | 2,592·10⁹ | 10 000 000 [BR-42] | 259,2 | cuota | 3,858 | 2 h 47 min / 5 000 peticiones | escalón no en YAML |
| Brevo · Enterprise | 1,5552·10¹⁰ (Extended [BR-85 🟡]) | Custom [BR-05] | — | — | — | — | suelo de 1M solo en el panel [BR-48] |
| Amazon SES · sandbox | 86 400 | 200 [SE-51] | 432 | cuota | 0,002315 | 200 s / 4 s | ventana de la cuota 🔴 [SE-58]; unidad = destinatario, medida [SE-182] |
| Amazon SES · producción (los cuatro planes) | no calculable | no publicada [SE-152] | — | — | — | — | cuota 🔴 [SE-152] y caudal 🔴 [SE-153]; el plan no es el eje [SE-137] |
| Mailgun · Free (día) | 691 200 000 | 100 [MG-33 🟡] | 6 912 000 | cuota | 0,001157 | 0,0125 s / menos de una petición | DISC-03 [MG-110]; ancla 🔴 [MG-41] |
| Mailgun · Free (mes) | 2,0736·10¹⁰ | 3 000 [MG-34 🟡] | 6 912 000 | cuota | 0,001157 | 0,375 s / menos de una petición | ídem |
| Mailgun · Basic | 2,0736·10¹⁰ | 10 000 [MG-37] | 2 073 600 | cuota | 0,003858 | 1,25 s / 0,05 s | ventana del caudal fuera del esquema 🟡 [MG-109] |
| Mailgun · Foundation | 2,0736·10¹⁰ | 50 000 [MG-38] | 414 720 | cuota | 0,01929 | 6,25 s / 0,25 s | ídem; caudal no atribuido por plan 🟡 [MG-113] |
| Mailgun · Scale | 2,0736·10¹⁰ | 100 000 [MG-39] | 207 360 | cuota | 0,0386 | 12,5 s / 0,5 s | ídem |
| Mailgun · Scale 2,5M | 2,0736·10¹⁰ | 2 500 000 [MG-08] | 8 294,4 | cuota; el contador de destinatarios corta desde k = 25 [MG-159] | 0,9645 | 312,5 s / 12,5 s | escalón no en YAML; segundo contador fuera del fichero [MG-108] |
| Mailchimp · demo | no formable (cuota sin ventana [MC-30 🔴]) | 500 [MC-29] | — | **el caudal**, 25 correos/h [MC-42] | — | 20 h / 20 h (k no multiplica) | k sin tope 🔴 [MC-102]; franquicia sin periodo 🔴 [MC-30] |
| Mailchimp · bloque de pago | no formable (caudal sin cifra [MC-49]) | 25 000 [MC-25] | — | no determinable | 0,009645 | — | cuota horaria de pago sin publicar [MC-95]; ventana del bloque 🟡 [MC-26] |

---

### ¿Hay relación entre el tamaño de la cuota y el del caudal?

La pregunta solo se puede plantear donde existen los dos términos, y con ocho APIs **existen en seis**. SES no
publica cuota de producción [SE-152] y Mailchimp no publica caudal en peticiones [MC-99]: las dos ausencias son
del proveedor, no del esquema, y las dos caen en APIs cuyo eje de capacidad es el estado de la cuenta y no el
plan [SE-127, MC-151].

Sobre esas seis, el volumen publicado más alto de cada una frente a su caudal de envío:

| API | R (req/s) | Volumen mensual más alto publicado | Fuente del par |
|---|---|---|---|
| MailerSend | 2 | 2 000 000 | [MS-45 🟢], [MS-20 no en YAML] |
| Resend | 10 | 2 500 000 | [RS-50 🟢], [RS-05 no en YAML] |
| Brevo | 1 000 | 10 000 000 | [BR-82 🟡], [BR-42 🟢] |
| Postmark | 5 000 | 1 500 000 | [PM-97 🟡], [PM-12 no en YAML] |
| Mailgun | 8 000 | 2 500 000 | [MG-58 🟡], [MG-08 no en YAML] |
| SendGrid | 10 000 | 2 500 000 | [SG-46 🟢], [SG-32 no en YAML] |

El coeficiente de rangos de Spearman sobre esos seis pares sale **0,2**, con tres empates en el volumen de
2 500 000. Con seis puntos y tres empates ese número describe, no contrasta: lo que decide la respuesta son las
filas directas, y hay tres.

**Cuatro APIs publican exactamente 50 000 correos al mes con caudales que van de 2 a 10 000 peticiones por
segundo.** Resend Pro [RS-22 🟢], SendGrid Essentials [SG-29 🟢], MailerSend Starter y Professional [MS-31 🟢] y
Mailgun Foundation [MG-38 🟢] declaran la misma cuota; sus rates son 10 [RS-50 🟢], 10 000 [SG-46 🟢], 2
[MS-45 🟢] y 8 000 [MG-58 🟡]. Factor 5 000 entre el menor y el mayor, con el mismo volumen contratado.

**Cuatro publican 100 000 al mes, con rates de 10 a 10 000.** Resend Scale [RS-23 🟢], SendGrid Pro [SG-31 🟢],
Mailgun Scale [MG-39 🟢] y el techo de Brevo Starter [BR-42 🟢], con 10, 10 000, 8 000 y 1 000 peticiones por
segundo.

**Y tres publican 2 500 000 al mes, con rates de 10, 8 000 y 10 000.** Resend [RS-05], Mailgun [MG-08] y SendGrid
[SG-32].

La respuesta es que **no hay relación**: el tamaño de la cuota y el del caudal son ejes independientes, y se
sostiene sobre las seis APIs que admiten el par, con la evidencia más limpia sobre cuatro de las ocho. Las dos
que no admiten el par no la contradicen; la refuerzan por otro lado, porque en ellas el caudal ni siquiera
depende del plan.

**Lo que sí se mueve con el plan es la cuota, y solo la cuota.** En **siete de las ocho** el caudal publicado no
varía entre planes:

- Postmark: un solo valor para los cuatro planes [PM-98 🟡].
- Resend: valor por defecto asignado por decisión Q3, no cifra por plan [RS-51 🟢, RS-104].
- SendGrid: publicado una vez en una FAQ y copiado a los cuatro planes [SG-113].
- MailerSend: 120/min para todos los planes; lo que lo cambia es el estado de la cuenta, 120 → 10 bajo revisión
  [MS-45 🟢, MS-48].
- Amazon SES: 1 req/s en el entorno de pruebas, sin cifra en producción; el alias es de estado, no de plan
  [SE-82, SE-127 🟢].
- Mailgun: ninguna fuente atribuye caudales por plan y el valor se midió desde una cuenta Free
  [MG-64 🟡, MG-113 🟡].
- Mailchimp: la cuota horaria la fija la reputación, y en la cuenta de pago no tiene cifra [MC-52, MC-49].

La octava es Brevo, y es la única que publica tramos de caudal atados a clases de plan [BR-81 🟡]. Su propia
página los contradice: el distintivo de Advanced y Extended enumera los cinco planes, Free incluido [BR-103b], y
por eso los tres valores están en 🟡 y DISC-15 sigue abierta. El caso más favorable a la hipótesis de que el
caudal escala con el plan es también el único donde el proveedor se desmiente a sí mismo.

**En cambio el caudal sí se mueve con el estado de la cuenta, y con cifra, en tres de las ocho.** MailerSend baja
de 120 a 10 por minuto bajo revisión [MS-48], SES da 1 req/s en pruebas y nada en producción [SE-82], y Mailchimp
da 25 correos/hora en la demo y nada al pasar a pago [MC-42 🟢, MC-49]. Mailgun describe la rampa de una cuenta
nueva sin una sola cifra [MG-48], y Brevo publica un error `account_under_validation` sin umbral [BR-97]. El eje
que gobierna el caudal no es el que el esquema modela.

### Las cuatro formas en que la ventana no cabe

Con cuatro APIs la ventana era un campo con un color dudoso. Con ocho hay cuatro modos de fallo distintos, y los
cuatro los aportan las nuevas:

1. **Ventana sin forma en el vocabulario.** La de Mailgun dura 9,85 s, no es rodante y la ancla la primera
   petición: ninguno de los tres `window_type` de v0.3 la describe [MG-60, MG-61, MG-62, MG-109 🟡].
2. **Ventana sin ancla publicada.** Brevo Free [BR-71 🔴] y las dos cuotas del Free de Mailgun [MG-41 🔴] tienen
   valor y periodo, y nadie fecha la reposición.
3. **Ventana en contradicción del proveedor.** SES describe la misma cuota como rodante en una página [SE-59 🔴]
   y como fija en otra [SE-60 🔴], y su consola mezcla las dos unidades en la misma fila [SE-74 🔴]. El campo se
   deja vacío a propósito [SE-169 🔴].
4. **Cuota sin ventana ninguna.** La franquicia de Mailchimp no caduca ni se renueva [MC-30 🔴], y v0.3 exige
   periodo en toda cuota [MC-104 🔴].

El único sitio donde la ventana quedó bien cerrada fue el que se midió. En Brevo el sondeo leyó `startDate` y
`endDate` a treinta días exactos anclados al alta [BR-113 🟢], y midió la ventana del caudal en un segundo
anclado al reloj del servidor [BR-118 🟢].

### Coincidencias que salen de la tabla y no de ninguna fuente

- **El umbral de 0,001157 emails/s lo comparten cuatro APIs**: Resend Free [RS-21], SendGrid Trial [SG-22] y las
  dos cuotas del Free de Mailgun [MG-33, MG-34], todas con 100 correos al día o su equivalente mensual. En
  Resend y en Mailgun la mensual es la diaria por treinta, y la diferencia es que Resend publica cómo componen
  [RS-20, RS-21] y Mailgun no [MG-110 🟡].
- **El umbral de 0,01929 emails/s lo comparten cuatro**: Resend Pro [RS-22], SendGrid Essentials 50K [SG-29],
  MailerSend Starter y Professional [MS-31] y Mailgun Foundation [MG-38], con rates de 2 a 10 000 req/s sin que
  eso cambie la restricción activa.
- **El de 0,001929 emails/s lo comparten MailerSend Hobby [MS-30] y Brevo Starter y Standard [BR-07, BR-34]**,
  los tres con 5 000 correos al mes.
- **En tres APIs una sola petición al máximo de destinatarios supera la cuota entera del día**: SendGrid Trial,
  1 000 frente a 100 [SG-57, SG-22]; Mailgun Free, 1 000 frente a 100 [MG-69, MG-33]; y Brevo Free, 2 000 frente
  a 300 [BR-107, BR-62]. Con cuatro APIs el caso era solo de SendGrid.
- **El caudal en tres unidades distintas.** Seis de las ocho lo publican en peticiones; Mailgun lo publica en
  peticiones **y** en destinatarios sobre la misma ventana [MG-58, MG-59]; Mailchimp lo publica en correos por
  hora [MC-42]. Es la clasificación que decide si k multiplica: sin tope en seis, hasta k = 25 en Mailgun
  [MG-159], y nunca en Mailchimp.

### Lo que la base de hechos no permite afirmar

- **Qué cuota y qué caudal tiene una cuenta de SES en producción.** Los dos están en 🔴 [SE-152, SE-153], y los
  cuatro planes de pago quedan fuera de todo cálculo de esta sección.
- **Qué caudal tiene una cuenta de pago de Mailchimp.** Sin cifra [MC-49, MC-95], no se escribe restricción
  activa para el bloque de 25 000.
- **Si la cuota diaria de Mailgun compone la mensual o son dos topes concurrentes.** DISC-03 abierta
  [MG-35 🟡, MG-110 🟡]; el cociente y el umbral coinciden en las dos lecturas, pero el techo real del mes no.
- **A qué planes corresponden los tramos Advanced y Extended de Brevo.** DISC-15 abierta [BR-81 🟡, BR-103b], así
  que todo cálculo de Professional y de Enterprise con esos caudales es acotación y no valor.
- **Cuál de los dos caudales de envío de Brevo manda.** DISC-01 abierta, con factor 600 entre 1 000 RPS [BR-82] y
  las 100 llamadas por minuto del lote [BR-128].
- **Si cada destinatario consume una unidad de cuota en Postmark [PM-92], MailerSend [MS-114], Mailgun [MG-148] y
  Mailchimp [MC-110].** Es el supuesto que multiplica por k toda la columna de agotamiento, y en cuatro de las
  ocho no está sostenido.
- **El techo de destinatarios por petición de Mailchimp.** No publicado y **no medible por rechazo**: 5 000
  pasaron sin cota alcanzada [MC-102 🔴, MC-129], y por encima de diez destinatarios la API deja de decir qué va
  a hacer [MC-126].
- **Cuántas peticiones caben de verdad en la ventana de Mailgun.** El redondeo de 9,85 s a 10 s deja 1 120
  peticiones por ventana sin decidir [MG-158], y los 0,4 MiB del tope de tamaño no tienen dónde declararse
  [MG-111 🟡].

---

## (c) Afirmaciones transversales sobre RQ3

RQ3: «¿Cómo se relacionan los límites de uso y los rates en las APIs de correo, y qué
implicaciones tiene esa relación para el consumidor?»

Prefijos de id: PM Postmark · RS Resend · SG SendGrid · MS MailerSend · BR Brevo ·
SE Amazon SES · MG Mailgun · MC Mailchimp Transactional.

### Criterio de recuento (se declara porque el recuento es evidencia del capítulo 6)

Cada afirmación se cuenta sobre ocho APIs, no sobre planes ni sobre filas de tarifa. Una API
**cumple** una afirmación cuando los hechos de su ficha contienen el dato que la afirmación
necesita y ese dato va en la dirección que la afirmación enuncia. Tres estados más:

- **No cumple**: la ficha tiene el dato y apunta en contra. Es contraejemplo y se nombra.
- **No comprobable**: la afirmación tiene sentido en esa API pero el dato no existe en ningún
  hecho. Cuenta aparte y nunca a favor.
- **No aplica**: la afirmación presupone una estructura que esa API no tiene (por ejemplo,
  planes en Mailchimp [MC-02] o cuota incluida en SES [SE-143]). Se separa de «no comprobable»
  porque el hueco no es del proveedor ni del recolector: es del enunciado.

Los denominadores se escriben siempre como *a favor / en contra / no comprobable / no aplica*
sobre ocho. Un margen se calcula a k = 1 y con el rate publicado o adoptado de la ficha; k solo
lo multiplica, así que el margen a k = 1 es cota inferior. El semáforo del dato que sostiene un
recuento viaja con el id, y una afirmación sostenida solo por datos en 🟡 lo dice en su línea.

Dos convenciones heredadas: mes = 30 días = 2 592 000 s, día = 86 400 s. Ninguna conclusión de
esta sección se mueve al cambiar 30 por 31 días; los cocientes varían un 3,3 % y ningún signo
cambia.

---

### C-1. Donde hay rate y cuota con valor, la cuota es la restricción activa por entre 2,6 veces y ocho órdenes de magnitud; el rate no limita el volumen en ningún plan publicado con la cuenta en estado sano.

**Recuento sobre ocho: 6 a favor / 0 en contra / 1 no comprobable / 1 no aplica.**

- Sostienen (seis). Postmark Free 1,296·10⁸× y Basic 1 296 000× con el rate adoptado en ámbar
  [PM-24, PM-25, PM-98]. Resend Free 8 640×, Pro 518× y Scale 2,5M 10,4× [RS-21, RS-22, RS-05,
  RS-50, RS-51]. SendGrid Trial 8,6·10⁶×, Essentials 518 400× y Pro 2.5M 10 368× [SG-22, SG-29,
  SG-32, SG-46]. MailerSend Free 10 368×, Hobby 1 037×, Starter y Professional 104×, y
  Professional 2M 2,6× [MS-27, MS-30, MS-31, MS-20, MS-45]. **Brevo** entra con el rate general
  de 1 000 peticiones por segundo [BR-82 🟡]: Free 288 000× sobre los 300 correos al día
  [BR-62 🟢], Starter 25 920× sobre 100 000 al mes, Standard 5 184× sobre 500 000 y Professional
  259× sobre 10 millones [BR-42 🟢]. **Mailgun** entra con el rate medido de 80 000 peticiones
  por diez segundos [MG-58 🟡]: Free 6,9·10⁶× sobre 3 000 al mes [MG-34 🟡], Basic 2,07·10⁶×
  sobre 10 000 [MG-37 🟢], Foundation 414 720× y Scale 207 360× [MG-38, MG-39].
- No comprobable (una): **Amazon SES**. Fuera del entorno de pruebas el proveedor no publica ni
  la cuota ni el caudal, con la misma fórmula en las dos páginas, «this number varies based on
  your specific use case» [SE-61, SE-152, SE-153 🔴]. Lo único con cifra es el estado de pruebas,
  200 correos por 24 horas contra 1 petición por segundo [SE-51 🟢, SE-81 🟢], que da 432× y no
  es un plan: los cuatro planes del fichero devuelven esa misma cuota [SE-137].
- No aplica (una): **Mailchimp Transactional**. No tiene planes [MC-02], y su caudal de cuenta de
  pago tampoco tiene cifra [MC-49, MC-95]. En la cuenta de prueba el signo **se invierte**: la
  franquicia son 500 correos sin ventana declarada [MC-29, MC-30 🔴] y el tope horario son 25
  correos [MC-42 🟢], así que agotarla lleva veinte horas y lo único que pone tiempo es el
  caudal. El cociente R·W/Q ni siquiera está definido, porque la cuota no tiene W.
- **Veredicto: sigue en pie y cambia de alcance.** El rango no se mueve: el margen mínimo sigue
  siendo 2,6× en MailerSend Professional 2M [MS-20] y el máximo sigue siendo Postmark Free
  [PM-24], ocho órdenes de magnitud. Lo que se estrecha es el enunciado. «En ningún plan
  publicado» era una afirmación sobre el catálogo entero cuando las cuatro APIs publicaban las
  dos cifras. Con ocho hay que decir **en las seis APIs que publican rate y cuota atribuibles a
  un plan**, porque dos no lo hacen y en una de esas dos el caudal manda.
- Matizan. Cinco de los seis márgenes descansan en un rate que no está publicado como tal:
  Postmark lo adopta de una cabecera [PM-97, PM-98], Resend lo asigna por decisión en Pro y Scale
  [RS-51, RS-104], SendGrid lo toma de una FAQ no observable [SG-113, SG-100], Brevo lo lleva en
  ámbar con una discrepancia interna abierta [BR-81 🟡, DISC-15] y Mailgun lo midió sin alcanzar
  el 429, que exigiría 80 000 peticiones en diez segundos [MG-67 🟡]. El único margen calculado
  con un rate documentado, panel y cabecera de acuerdo es el de Resend [RS-50, RS-54, RS-55].
- Implicación. Para dimensionar volumen el consumidor puede seguir ignorando el rate, pero solo
  en seis de las ocho APIs y con la cuenta sana. En SES la pregunta no se puede contestar antes
  de abrir la cuenta, porque los dos números llegan con el acceso de producción. En Mailchimp la
  pregunta se contesta al revés que en el resto del catálogo.

### C-2. El rate no es una variable del plan; la cuota sí. Se compra volumen, no velocidad.

**Primera mitad (el rate no varía por plan): 6 a favor / 1 en contra / 0 no comprobable / 1 no aplica.
Segunda mitad (la cuota sí varía por plan): 6 a favor / 0 en contra / 0 no comprobable / 2 no aplica.**

- Sostienen la primera mitad (seis). Postmark no publica ningún rate en ninguno de sus cuatro
  planes [PM-82 🟡] y la cabecera medida se adopta como valor único [PM-98]. Resend publica un
  valor por equipo que no hace variar [RS-50, RS-51, RS-104]. SendGrid publica un 10 000 sin
  condición de plan [SG-46, SG-113]. MailerSend publica 120 por minuto en los cuatro planes para
  el envío individual [MS-45 🟢]. **Mailgun** no atribuye caudal a ningún plan en ninguna fuente
  y el valor del fichero, medido desde una cuenta Free, se referencia desde los cuatro [MG-64,
  MG-113]; su única cifra documental acota además por IP de cliente y no por cuenta [MG-50,
  MG-51 🟡]. **Mailchimp** no tiene plan del que el caudal pueda depender: lo fija la reputación
  [MC-49, MC-151].
- **No cumple (una): Brevo, y es el contraejemplo que la versión de cuatro APIs no tenía.** La
  documentación publica tres tramos de caudal para el mismo endpoint de envío, con cifra y con
  destinatario: General 1 000 peticiones por segundo para todos los tipos de cuenta, Advanced
  2 000 «available to Professional and Enterprise accounts» y Extended 6 000 para Enterprise
  [BR-81, BR-82, BR-84, BR-85, todos 🟡]. Lo remata una viñeta de invitación, «upgrade to an
  Enterprise plan for increased rate limits» [BR-89]. Es la primera API del catálogo donde
  subir de plan multiplica por seis el caudal del envío individual.
- El contraejemplo no está cerrado, y eso también se cuenta. DISC-15 está abierta porque la misma
  página se contradice: la viñeta restringe Advanced a Professional y Enterprise, y el distintivo
  que encabeza esa misma tabla enumera «Available in · Free · Starter · Standard · Professional ·
  Enterprise» [BR-103b]. Los tres valores viven en 🟡 [BR-81] y ninguna fuente dice si los tramos
  se aplican al contratar o hay que pedirlos [BR-160]. El sondeo lo roza sin cerrarlo: la cabecera
  del envío devolvió `x-sib-ratelimit-limit: 1000` en la cuenta Free [BR-108], que es el valor del
  tramo General y no desempata la atribución de los otros dos.
- **No aplica a la primera mitad (una): SES.** El caudal no pertenece al plan sino al par cuenta
  y región [SE-09], y dentro de eso al estado: el fichero solo tiene cifra para el entorno de
  pruebas [SE-80 🟢] y declara hueco el bloque de producción [SE-105 🔴]. PRIME4API lo confirma
  leyendo el documento: encuentra cuatro planes y ninguno cambia la capacidad [SE-137].
- Sostienen la segunda mitad (seis). Lo que escala con el precio es la cuota en Postmark
  [PM-07…PM-12], Resend [RS-02…RS-05], SendGrid [SG-06, SG-08], MailerSend [MS-19, MS-20],
  Brevo, de 300 al día a 10 millones al mes [BR-42 🟢], y Mailgun, de 3 000 a 100 000 mensuales
  [MG-34, MG-37, MG-38, MG-39].
- **No aplica a la segunda mitad (dos), y esto es nuevo.** En SES el plan no compra volumen:
  no hay cuota incluida que comprar, «you pay only for what you use with no minimum fees»
  [SE-143], y los cuatro planes devuelven la misma cuota de 200 [SE-137]. Lo que el plan compra
  son funciones y tramos de precio unitario [SE-10, SE-11, SE-12]. En Mailchimp no hay planes:
  lo que se compra es la propia unidad de volumen, el bloque de 25 000 correos, con precio
  degresivo de 20 a 10 dólares [MC-03, MC-04…MC-09].
- **Veredicto: se debilita en las dos mitades, por motivos distintos.** La primera pasa de 4/4 a
  6/8 con un contraejemplo documentado en ámbar. La segunda pasa de 4/4 a 6/8 porque dos APIs no
  venden capacidad en planes. La frase «se compra volumen, no velocidad» deja de valer como
  regla del dominio: en Brevo se compran las dos cosas, en SES no se compra ninguna y en
  Mailchimp lo único que hay que comprar es volumen, sin plan alrededor.
- Implicación. La pregunta PI-D04, «¿sube el rate al subir de plan?», tenía cuatro noes y ahora
  tiene seis noes y un sí en ámbar. La pregunta PI-B05, «¿qué plan necesito para sostener un
  pico?», sigue reduciéndose a cuota en seis APIs, se reduce a cuota más tramo de caudal en
  Brevo y no tiene respuesta previa a la cuenta en SES.

### C-3. El rate publicado y el rate observado no coinciden; la señal fiable para el consumidor es la cabecera de respuesta, no la documentación.

**Primera mitad (publicado y observado no coinciden): 4 a favor / 3 en contra / 1 no comprobable.
Segunda mitad (la cabecera es la señal fiable): 5 a favor / 2 en contra / 1 con reserva.**

- Sostienen la primera mitad (cuatro). Postmark no publica rate y devuelve `ratelimit-limit: 5000`
  en cada respuesta [PM-36 🟡, PM-40, PM-97]. SendGrid publica 10 000 para un endpoint que no
  devuelve cabeceras, y devuelve 600 y 6 en endpoints de lectura que ninguna página documenta
  [SG-46, SG-54, SG-51, SG-52]. MailerSend publica 120 por minuto y el sondeo midió 10, porque la
  cuenta no está aprobada [MS-45, MS-163]. **Mailgun** documenta las tres cabeceras y no publica
  ningún umbral [MG-54 🔴]; lo medido en la cabecera es 80 000 por diez segundos [MG-58], y la
  única cifra que el proveedor sí publica, 1 500 por segundo por IP de cliente [MG-50], es otra
  magnitud con otro ámbito.
- **No cumplen (tres), y es la novedad de las ocho.** Resend ya coincidía en documentación, panel
  y cabecera [RS-50, RS-54, RS-55]. Se le suman dos. **Brevo**: la cabecera del endpoint de envío
  devolvió `x-sib-ratelimit-limit: 1000` [BR-108], exactamente el valor publicado en la tabla
  General [BR-82]; y en el endpoint de actividad la cabecera devolvió 2, que es el valor de su
  fila propia y no el del prefijo, con el 429 alcanzado en la tercera petición del segundo
  [BR-110, BR-117]. **Mailchimp**: tres superficies documentales y una medición dan el mismo 25
  por hora, sin discrepancia [MC-42, MC-43, MC-44, MC-45].
- No comprobable (una): SES. El caudal de producción no se publica [SE-153 🔴], así que no hay
  nada publicado que contrastar; y el caudal del entorno de pruebas, 1 por segundo, no se
  contrastó por rechazo, porque dos envíos seguidos a 0,257 s y 0,518 s salieron los dos en 200
  sin error de caudal [SE-101].
- **Veredicto de la primera mitad: se cae como afirmación universal.** Pasa de «no coinciden» a
  cuatro casos de desajuste y tres de coincidencia exacta. Con cuatro APIs el desajuste parecía
  el estado natural del dominio. Con ocho es algo más estrecho: **el rate publicado y el observado
  coinciden cuando el proveedor publica el valor por endpoint**, como hacen Resend, Brevo y
  Mailchimp, y divergen cuando lo publica en una FAQ, en una página general o en ninguna parte.
- Sostienen la segunda mitad (cinco): Postmark [PM-40], Resend [RS-55], SendGrid en los endpoints
  de lectura [SG-51, SG-52], MailerSend, con la documentación más completa del catálogo sobre la
  señal [MS-52, MS-37, MS-56], y Brevo [BR-90, BR-91, BR-92].
- **No cumplen (dos): las dos APIs que no emiten ninguna cabecera de caudal.** En SES la búsqueda
  sobre el contrato máquina da cero apariciones de `ratelimit`, `rate-limit`, `retry-after` y
  `remaining`, y la enumeración de miembros con `"location": "header"` sale vacía [SE-91]; las
  nueve respuestas 429 que sí se midieron tampoco traen `retry-after` [SE-103]. En Mailchimp no
  aparece ninguna cabecera de caudal en ninguna página oficial revisada ni en las respuestas del
  sondeo [MC-59], y la tabla oficial de errores no incluye ni 429 ni 403 [MC-58, MC-101].
- Con reserva (una): **Mailgun emite la cabecera y no se puede leer gratis.** Un `GET /v4/domains`
  devuelve 200 sin ninguna cabecera de caudal, y el POST rechazado con 403 tampoco las trae: solo
  aparecen en un POST aceptado [MG-63]. Leer el caudal cuesta un envío, así que observar el
  caudal y medir la cuota dejan de ser separables en esa API.
- **Veredicto de la segunda mitad: se debilita y cambia de sujeto.** La señal fiable ya no es la
  cabecera, porque dos de ocho no la tienen y una la cobra. Lo que ocho APIs dejan ver es otra
  cosa, y va como afirmación propia en C-6.
- Matizan. La documentación miente sobre su propia señal en dos sitios. Brevo afirma que las
  cabeceras llegan en todas las respuestas y el sondeo lo desmiente, porque llegaron en un 400 y
  no en dos 200 [BR-93, BR-111]. MailerSend lleva `x-ratelimit-limit: 60` en la cabecera de su
  propio ejemplo de 429 y «120 requests/min» en el mensaje de ese mismo ejemplo [MS-52]. Y dos
  proveedores devuelven el 429 sin instrucción de espera: Brevo lo devuelve sin cuerpo, sin
  `Content-Type` y sin `Retry-After` [BR-117], y las 429 de MailerSend no traen `retry-after` ni
  `x-ratelimit-*` [MS-166].

### C-4. El tope de destinatarios por petición es el factor que conecta rate (en peticiones) y cuota (en correos), y la documentación lo publica peor de lo que la API lo aplica.

**Primera mitad (k conecta las dos unidades): 7 a favor / 1 en contra.
Segunda mitad (la doc lo publica peor de lo que la API lo aplica): 5 a favor / 2 en contra / 1 no aplica.**

- Sostienen la primera mitad (siete): 50 en Postmark [PM-43…PM-48 🟢], 50 en Resend
  [RS-62…RS-64 🟢], 1 000 en SendGrid [SG-57, SG-59 🟢], 70 en MailerSend [MS-59 🟡, MS-113 🟡],
  **2 000 por petición en Brevo, con 99 por versión de mensaje** [BR-107 🟡, BR-121, BR-122],
  **50 en SES** [SE-106 🟢] y **1 000 por lote en Mailgun** [MG-69, MG-70 🟢].
- **No cumple (una): Mailchimp, y el proveedor lo escribe en la misma frase.** «Via the API,
  there's no recipient limitation, but the JSON provided per API call must be less than 10MB»
  [MC-60 🔴]. No hay k que conecte nada: la cota de una llamada está en megabytes y no en
  destinatarios. El sondeo lo confirma por arriba sin encontrar techo, con 5 000 destinatarios
  aceptados en una sola llamada [MC-102, MC-129].
- Sostienen la segunda mitad (cinco). Postmark declara «Max 50» por campo y lo aplica a la suma
  [PM-42, DISC-01]; Resend solo lo pone en `to` y lo aplica a los tres campos [RS-60, DISC-04];
  SendGrid no lleva `maxItems` en `to` [SG-72]; MailerSend da 50, 10 y 10 por campo y ninguna
  frase da el total [MS-59, MS-113]. **Brevo publica el 2 000 dentro de la descripción de
  `messageVersions`**, y ni `to` ni `cc` ni `bcc` llevan `maxItems` en ninguna de sus dos
  especificaciones [BR-163 🟡]; además el mismo endpoint cambia de tope según la petición lleve
  adjunto, 2 000 sin él y 99 con él [BR-70].
- **No cumplen (dos), y las dos son casos nuevos donde la documentación acierta.** **SES** publica
  el tope como suma y con la definición explícita: «50 recipients per message», con «a recipient
  is any "To", "CC", or "BCC" address» [SE-106 🟢]. Es el único literal del catálogo que resuelve
  por escrito la ambigüedad que en Postmark, Resend y MailerSend hubo que medir. **Mailgun**
  publica 1 000 en dos páginas distintas [MG-69, MG-70] y la medición devuelve exactamente eso:
  1 001 destinatarios dan `400 {"message":"Too many recipients, max is 1000"}` [MG-71].
- No aplica (una): Mailchimp. No hay tope publicado que pueda estar mal publicado, y la API
  tampoco aplica ninguno. Documentación y comportamiento coinciden en la ausencia.
- **Veredicto: la primera mitad sigue en pie con una excepción; la segunda se cae.** «La
  documentación lo publica peor de lo que la API lo aplica» era 4 de 4. Ahora es 5 de 8, con dos
  contraejemplos limpios. Lo que queda no es una ley del dominio sino un reparto: los proveedores
  que publican el tope por campo lo aplican a la suma, y los que lo publican como suma lo cumplen.
- Matizan. Solo cinco de los siete topes están verificados por sondeo: Postmark, Resend y
  SendGrid en la versión de cuatro [PM-43…PM-48, RS-62…RS-64, SG-59], más Mailgun [MG-71] y el
  contorno del estado no aprobado de MailerSend [MS-167, MS-168]. Brevo no tiene sondeo de
  destinatarios y sus cinco `max: 2000` siguen en 🟡 [BR-163]; en SES el 50 no se midió, y el
  tope tampoco aparece en la referencia de la operación, solo en la página de cuotas [SE-107].
  En Mailgun el tope publicado es el del lote: el del envío individual no se publica [MG-114].
- Implicación. En SES una petición de 50 destinatarios consume 50 de los 200 diarios del entorno
  de pruebas, un cuarto de la cuota [SE-51, SE-106], porque la cuota cuenta destinatarios y no
  mensajes [SE-54, SE-182]. En Brevo una petición de 2 000 destinatarios agota casi siete veces la
  cuota diaria del plan Free [BR-62, BR-107]. En Mailchimp la pregunta no se puede formular.

---

### Afirmaciones que solo son visibles con ocho APIs

### C-5. El caudal por cuenta con cifra atribuible a un plan no se publica en siete de las ocho APIs, y la única excepción está en ámbar y con la discrepancia abierta.

**Recuento: 7 cumplen la carencia / 1 excepción.**

- La carencia es el caso general. Postmark no publica rate en ningún plan [PM-82 🟡]. Resend
  publica un único valor por equipo, no por plan [RS-50, RS-51, RS-104]. SendGrid publica un
  único 10 000 sin condición de plan, y en una FAQ [SG-46, SG-113]. MailerSend publica un único
  120 por minuto en los cuatro planes [MS-45]. SES no publica el caudal de producción y el que
  publica es del estado y del par cuenta y región [SE-153 🔴, SE-09]. Mailgun no atribuye caudal
  a ningún plan y su única cifra documental acota por IP de cliente [MG-113, MG-50 🟡].
  Mailchimp lo ata a la reputación, sin cifra para cuentas de pago [MC-49, MC-95].
- La excepción es Brevo, con los tres tramos ya descritos en C-2 [BR-81, BR-84, BR-85, todos 🟡]
  y la contradicción interna de DISC-15 [BR-103b]. **La afirmación que el encargo proponía como
  candidata, «ningún proveedor publica el caudal por cuenta con cifra atribuible a un plan», no
  se sostiene tal cual: hay uno.** Lo que sí se sostiene es el recuento 7 a 1, y que el único
  que lo publica no ha conseguido publicarlo sin contradecirse en la misma página.
- Consecuencia para el esquema. En seis de las siete APIs que no lo publican, el hueco está
  declarado en el fichero como `not_found` o como caudal común a todos los planes. Ninguna de las
  seis lo declara igual, y ahí es donde el capítulo 6 tiene material: SES lo declara como hueco
  de bloque entero [SE-105], Mailgun como valor único referenciado desde los cuatro planes
  [MG-64], MailerSend como valor por defecto bajo la regla D2, y Mailchimp como alias de estado
  repetido en tres endpoints porque el tope es de la cuenta y no del endpoint [MC-57].

### C-6. La señal fiable del caudal vigente no es la cabecera: es el endpoint de introspección, y solo la tienen cuatro de las ocho.

**Recuento: 4 con endpoint de introspección / 4 sin él. De los cuatro, tres devuelven el límite
en vigor y uno devuelve solo el saldo y el periodo.**

- Devuelven el límite en vigor tres. SES publica los dos topes de la cuenta en un `GET` que no
  gasta cuota: `"SendQuota": {"Max24HourSend": 200.0, "MaxSendRate": 1.0, "SentLast24Hours": 0.0}`
  [SE-76 🟢], y su propia documentación señala ese endpoint como la vía para conocer los límites
  vigentes, precisamente porque no devuelve ninguna cabecera [SE-91]. Mailchimp devuelve
  `"hourly_quota":25` junto a la reputación y el tamaño de la cola en `POST /users/info`
  [MC-122 🟢, MC-81]. MailerSend ofrece `GET /v1/api-quota`, que tampoco consume cuota [MS-38].
- Devuelve menos uno. Brevo tiene `GET /v3/account`, y lo medido acota qué sirve: devuelve el
  saldo de correos y el periodo exacto del ciclo, `startDate` y `endDate` en Unix, treinta días
  anclados al alta [BR-112, BR-113 🟢], pero **ninguno de sus campos es de límite ni de consumo**;
  la búsqueda por `limit`, `usage`, `used`, `consum` y `quota` sobre las claves reales sale vacía
  [BR-114]. La documentación afirmaba lo contrario y la medición la corrige [DISC-14].
- No lo tienen cuatro: Postmark, Resend, SendGrid y Mailgun. En Mailgun el efecto es el más duro
  del catálogo, porque la cabecera existe y solo llega en un POST aceptado [MG-63]: no hay ninguna
  vía de coste cero para leer el caudal vigente.
- Por qué importa para RQ3. La relación entre límite y caudal que el consumidor puede **verificar
  antes de enviar** existe en la mitad del catálogo. En la otra mitad el consumidor conoce su
  capacidad real después de gastarla, o no la conoce. El escalón 3 del método hereda la misma
  asimetría. Donde hay endpoint de introspección el sondeo cuesta cero envíos y devuelve el dato
  en una lectura [SE-76, MC-122, BR-113]. Donde no lo hay, medir el caudal exige forzar el
  rechazo o gastar un envío, y en Mailgun las dos cosas a la vez [MG-63, MG-67].

### C-7. La ventana no se declara. Está en rojo en cuatro APIs, en ámbar en las otras cuatro y en verde en ninguna, y en un caso lo medido no cabe en el esquema.

**Ventana de la cuota, clasificando cada API por el peor color que lleva alguna de sus cuotas:
🔴 en cuatro (Brevo, SES, Mailgun, Mailchimp) / 🟡 en cuatro (Postmark, Resend, MailerSend,
SendGrid) / 🟢 en ninguna. SendGrid es la que más se acerca: solo la ventana de Premier va en
ámbar [SG-34]. Ventana del caudal: ninguna de las ocho la declara; dos la midieron y dan
resultados opuestos para el esquema.**

- La ventana de la cuota, API por API. Postmark la fija en el ciclo de cuenta para Free [PM-28 🟢]
  y la deja sin explicitar en los tres planes de pago [PM-86 🟡]. Resend la lleva en ámbar en las
  dos ventanas, diaria y mensual [RS-25 🟡, RS-101 🟡]. SendGrid la tiene publicada, medianoche
  UTC y periodo de facturación [SG-26 🟢, SG-34 🟢 en Essentials y Pro, 🟡 en Premier], sin la
  hora exacta [SG-103]. MailerSend la
  lleva en ámbar con DISC-12 abierta [MS-32]. Brevo la tiene **resuelta midiendo** en la mensual
  [BR-113 🟢] y **vacía en la diaria del Free**, que es el único 🔴 de todo su panel [BR-71, BR-156].
  SES la deja vacía por discrepancia entre dos páginas del propio proveedor, una que la describe
  deslizante y otra que la describe fija [SE-58 🔴, SE-59, SE-60, SE-169]. Mailgun deja vacías las
  dos del Free [MG-41 🔴, MG-112] e infiere las tres de pago de una frase que habla del cobro y no
  del contador [MG-40 🟡]. Mailchimp infiere la del bloque de que el saldo no se arrastra
  [MC-26 🟡] y **deja la de la franquicia sin ventana ninguna**, porque el proveedor escribe que
  no caduca ni se renueva [MC-30 🔴, MC-104].
- La ventana del caudal no la declara ninguna de las ocho. Dos la midieron, y dan resultados
  opuestos para el esquema. En Brevo la ventana repone 0,426 s después del rechazo y 0,702 s desde
  la primera petición de la serie: es una ventana de un segundo anclada al reloj del servidor, no
  rodante, y esa forma **sí** cabe [BR-118 🟢]. En Mailgun la ventana medida dura 9,852 s y 9,870 s,
  se ancla en la primera petición que la abre, no es rodante y el contador vuelve entero al tope:
  **ninguno de los tres `window_type` de v0.3 la describe**, y los diez segundos que declara el
  fichero son un redondeo [MG-60 🟡, MG-61, MG-62, MG-109].
- **La candidata que el encargo proponía se reformula.** No es que la ventana del caudal «casi
  nunca se declare de forma que el esquema la pueda expresar»: es que **no se declara nunca**. El
  problema de expresividad aparece solo cuando alguien la mide, y ha aparecido en la primera de las
  dos veces que se ha medido contra un rechazo real.
- Consecuencia para el consumidor. Saber cuántos correos entran no basta para saber cuándo entran.
  En cuatro APIs el ancla del contador no existe en ninguna fuente, así que el consumidor no puede
  calcular el instante en el que su cuota vuelve a cero sin observarlo en su propia cuenta.

### C-8. El estado de la cuenta explica más de la capacidad observada que el plan.

**Recuento: 6 de las 8 publican al menos un estado de cuenta que condiciona la capacidad; 3 de
esas 6 publican una cifra distinta por estado; en 3 la capacidad medida es la del estado y no la
del plan.**

- Estados con cifra propia, tres. MailerSend baja de 120 a 10 por minuto con la cuenta «under
  review», y el lote de 10 a 1 [MS-46, MS-48]. SES publica los dos topes del entorno de pruebas, 200 al
  día y 1 por segundo [SE-51, SE-81], y no publica los de producción [SE-152, SE-153]; además
  documenta tres valores de `EnforcementStatus`, Healthy, Probation y Shutdown [SE-134].
  Mailchimp fija 25 correos por hora en la cuenta de prueba y ata la de pago a la reputación
  [MC-42, MC-49], que su propio panel codifica como Unknown, Excellent, Good o Poor [MC-53].
- Estados sin cifra, tres más. Brevo condiciona el envío a una aprobación previa, «once we
  approve your account for sending», y no publica ni topes ni disparador de ese estado previo
  [BR-16, BR-176]. Mailgun describe el arranque de una cuenta nueva sin una sola cifra, «gradually
  increases sending rates» [MG-48], y su plan Free no puede enviar a nadie fuera de una lista de
  autorizados [MG-49]. Postmark condiciona el cambio de plan a la aprobación de la cuenta [PM-23].
- **La capacidad medida es la del estado y no la del plan en tres de las ocho.** En MailerSend el
  sondeo midió 10 por minuto y 1 en el lote, que son los del estado no aprobado [MS-163, MS-164].
  En SES todo lo medido es del entorno de pruebas [SE-76]. En Mailchimp todo lo medido es de la
  cuenta demo [MC-122]. Son tres de las cuatro APIs nuevas o recientes del catálogo, y en las tres
  el escalón 3 produjo un número correcto que **no responde a la pregunta del plan**.
- Por qué es una afirmación y no una observación de método. Con cuatro APIs esto era un rasgo de
  MailerSend. Con ocho, el eje que gobierna la capacidad realmente observable no es el plan: es el
  estado. El esquema lo nota: SES modela el estado como alias con el vocabulario del proveedor,
  `sandbox`, colgado de las dos rutas de envío en los cuatro planes [SE-127], y Mailchimp repite
  el alias `demo` en sus tres endpoints de envío porque el tope es de la cuenta y no del endpoint
  [MC-57]. Dos APIs distintas llegan a la misma forma por el mismo motivo.
- Implicación. La pregunta PI-D05, «¿cambian los límites con la reputación?», tenía una respuesta
  afirmativa con cuatro APIs. Ahora tiene tres afirmativas con cifra y tres más afirmativas sin
  cifra. Lo que ninguna de las seis publica es el umbral que dispara el cambio de estado
  [MS-118, SE-155, MC-116, MG-134].

### C-9. El sobrecoste deja de ser universal: tres de las ocho no tienen precio de exceso, y cada una pone algo distinto en su lugar.

**Recuento: 5 con sobrecoste / 3 sin él.**

- Con sobrecoste, cinco, y decreciente con el volumen en las cinco: Postmark $1.80 → $1.70
  [PM-69, PM-70], Resend $0.90 → $0.46 [RS-80, RS-81], SendGrid $0.00133 → $0.00047 [SG-77],
  MailerSend $1.30 → $0.50 [MS-79, MS-80] y **Mailgun $1.80 → $0.40** [MG-98, MG-99, MG-100,
  MG-102].
- Sin sobrecoste, tres, por tres motivos distintos. **Brevo** no publica ninguna cifra de exceso
  en ninguna de las cuatro páginas buscadas, y lo más cercano es la negación «there are no
  additional fees» [BR-147]; lo que ocupa su lugar es un ascenso automático de plan disparado por
  el número de contactos, que no es una cuota de correo [BR-41]. **SES** no tiene sobrecoste
  porque no tiene cuota incluida: ningún `overage_cost` aparece en el fichero y los tramos de
  precio bajan al subir de volumen sin corte ni penalización [SE-143, SE-144, SE-145]. **Mailchimp**
  convierte el agotamiento en un muro, «el sistema dejará de enviar correos electrónicos cuando se
  te acaben los bloques» [MC-27], y lo que ocupa el lugar del sobrecoste es comprar otro bloque
  del mismo producto [MC-84, MC-85].
- El borde de la cuota tiene ya tres comportamientos distintos, y los tres están documentados.
  Rechazo inmediato: SES descarta el mensaje y no lo reintenta, «Amazon SES drops the message and
  doesn't attempt to redeliver it» [SE-68, SE-69, SE-77]. Muro: SendGrid con `is_hard_limit: true`
  [SG-24], MailerSend con «sendings will be paused» [MS-29] y Mailchimp con el bloque agotado
  [MC-27]. Cola: Brevo retiene hasta 1 000 correos y descarta en silencio lo que pasa de ahí
  [BR-63], y Mailchimp encola por caudal horario y **sí** reprocesa, «we'll begin processing the
  backlog in the next hour» [MC-48].
- El caso que junta las dos formas es Mailchimp: su cuota es muro y su caudal es cola, en la misma
  cuenta [MC-27, MC-48]. Ninguna otra API del catálogo tiene los dos comportamientos a la vez.
- Consecuencia para la comparación. El coste de pasarse de la cuota solo es comparable entre cinco
  APIs. En las otras tres la pregunta cambia de forma: en Brevo es «¿cuántos contactos tengo?», en
  SES no existe y en Mailchimp es «¿cuántos bloques compro?».

### C-10. La unidad de la cuota se confirma midiendo o no se confirma: cuatro de ocho tienen respaldo, y dos de esos cuatro salieron del escalón 3.

**Recuento: 4 con respaldo / 4 sin él.**

- Con respaldo documental, dos: Resend dice que cada destinatario consume una unidad [RS-28 🟢] y
  SendGrid también [SG-35].
- Con respaldo medido, dos, y los dos son de la tanda de ocho. **Brevo**: el saldo de la cuenta
  bajó de 300 a 298 tras una petición con dos destinatarios, y se mantuvo estable noventa segundos
  después [BR-112 🟢]. **SES**: el contador marcó `"SentLast24Hours": 5.0` tras cuatro mensajes
  aceptados con cinco destinatarios, uno de ellos con la misma dirección en `to` y en `cc`
  [SE-182 🟢]. Ese cinco descarta a la vez el mensaje como unidad y la deduplicación de
  direcciones, que habrían dado cuatro las dos. SES además lo publica por escrito en tres páginas
  y en su propio panel [SE-54, SE-55, SE-56, SE-57].
- Sin respaldo, cuatro. Postmark no confirma el cómputo por destinatario [PM-92]. MailerSend lo
  tiene modelado y no confirmado, «sin artículo propio» [MS-39, MS-114]. **Mailgun** lleva la
  frase en la descripción del campo y es inferencia: ninguna fuente lo dice y el sondeo no pudo
  comprobarlo porque no llegó a enviar a nadie [MG-148]. **Mailchimp** lo declara no verificable:
  el artículo del proveedor que lo trataría devolvió HTTP 403 en la pasada [MC-110].
- Por qué es transversal y no un detalle. Si la unidad de la cuota no está confirmada, el factor k
  de C-4 no conecta nada: multiplica peticiones por destinatarios para obtener correos, y en
  cuatro APIs no consta que un destinatario sea un correo a efectos de contador. La cadena entera
  de RQ3 descansa en un dato que la mitad del catálogo no publica y que solo se cierra midiendo.

---

### Qué cambia respecto a la versión de cuatro APIs

Una línea por afirmación, con lo que dejó de valer.

- **C-1 sigue en pie y estrecha su alcance.** De «en ningún plan publicado» a «en las seis APIs
  que publican rate y cuota atribuibles a un plan». El rango numérico no se mueve, 2,6× [MS-20] a
  ocho órdenes [PM-24]; lo que aparece es una API donde el caudal manda, Mailchimp en su cuenta de
  prueba [MC-42, MC-29], y otra donde la pregunta no se puede contestar antes de abrir la cuenta,
  SES [SE-152, SE-153].
- **C-2 se debilita en las dos mitades.** «El rate no es una variable del plan» pasa de 4/4 a 6/8
  con un contraejemplo en ámbar, los tres tramos de Brevo [BR-81, BR-84, BR-85]. «La cuota sí»
  pasa de 4/4 a 6/8 porque SES no vende cuota [SE-143] y Mailchimp no tiene planes [MC-02]. La
  frase «se compra volumen, no velocidad» deja de valer como regla y pasa a ser el caso mayoritario.
- **C-3 se cae en su primera mitad y cambia de sujeto en la segunda.** El desajuste entre rate
  publicado y observado pasa de universal a 4 de 8: Brevo [BR-108, BR-82] y Mailchimp [MC-45]
  coinciden, como ya coincidía Resend [RS-55]. Y la cabecera deja de ser la señal fiable, porque
  SES [SE-91] y Mailchimp [MC-59] no emiten ninguna y Mailgun cobra la suya con un envío [MG-63].
- **C-4 conserva su primera mitad y pierde la segunda.** k conecta las dos unidades en 7 de 8, con
  Mailchimp fuera porque no tiene tope de destinatarios [MC-60]. «La documentación lo publica peor
  de lo que la API lo aplica» pasa de 4/4 a 5/8: SES lo publica como suma y con definición
  [SE-106] y Mailgun lo publica dos veces y lo aplica exactamente [MG-69, MG-70, MG-71].
- **Deja de valer la lectura de que el catálogo describe un dominio homogéneo.** Con cuatro APIs
  las cuatro tenían planes, cuota mensual, sobrecoste decreciente y tope de destinatarios. Con
  ocho, una no tiene planes [MC-02], una no tiene cuota incluida [SE-143], tres no tienen
  sobrecoste [BR-147, SE-145, MC-84] y una no tiene tope de destinatarios [MC-60]. Las cuatro
  primeras no eran el dominio: eran su parte regular.

### Lo que este recuento no permite afirmar

- Nada sobre el caudal de producción de SES, ni sobre la cuota: los dos son huecos declarados del
  proveedor [SE-152, SE-153 🔴].
- Nada sobre el caudal de una cuenta de pago de Mailchimp: solo está el mecanismo, sin cifra
  [MC-49, MC-95].
- Nada sobre si los tramos Advanced y Extended de Brevo se aplican al contratar el plan o hay que
  pedirlos [BR-160], ni sobre cuál de los dos lados de DISC-15 manda [BR-103b].
- Nada sobre si el tope diario de Mailgun compone el mensual o son concurrentes [MG-35, MG-110,
  DISC-03], y por tanto nada sobre cuál de las dos cuotas del plan Free es la activa.
- Nada sobre el consumo por destinatario en Postmark, MailerSend, Mailgun y Mailchimp
  [PM-92, MS-114, MG-148, MC-110].

---

## (d) Cobertura del catálogo PI sobre las ocho APIs

Criterio: «sí» = los hechos dan la cifra, o la respuesta determinada («custom», «no publicado»)
cuando la propia pregunta lo admite; «parcial» = solo una parte de la pregunta; «no» = falta el
dato; «X·hechos» = la clase X del catálogo se mantiene —la Datasheet no lo serializa— pero las
fichas de hechos sí contienen la respuesta, fuera del YAML; «L» = clase L del catálogo v0.1.1
(D-019), respondible leyendo la matriz funcional `features.md`, sin instrumento. En las preguntas
de comparación (C) «sí» significa que la API aporta su lado de la comparación.

**Las clases y el denominador no se mueven al añadir APIs.** La clase mide con qué se responde la
pregunta, no qué publica cada proveedor (D-041), así que las 32 plantillas siguen repartidas en 25
del canal API (D+P+H), 2 de matriz (L) y 5 fuera del esquema (X) para las ocho columnas. Lo que
cambia de una API a otra es el veredicto de la celda, nunca la fila.

**Los corchetes de la celda son salida del motor, no glosa (E16).** Cuando el eje que la pregunta
presupone —plan gratuito, primer plan de pago, estado nominal— no existe en el proveedor, la
respuesta no se archiva bajo el nombre del eje más parecido: se ejecuta lo que la Datasheet declara
y se rotula con lo que PRIME4API contestó, con el vocabulario del proveedor y entre corchetes. En
esta tanda son `sí [sandbox]` en SES, que es el único estado con cifra en su ficha, y `sí [demo]`
en Mailchimp, que no tiene planes. El corchete no lleva semáforo: el color mide la fiabilidad del
dato (D1) y dos dudas distintas no comparten glifo.

La tabla va partida en dos mitades de cuatro columnas por anchura, no por criterio: mismas 32 filas,
mismo orden del catálogo, mismo criterio de celda. El recuento de abajo es único y abarca las ocho.

### Las cuatro primeras APIs

| id | clase | Postmark | Resend | SendGrid | MailerSend |
|---|---|---|---|---|---|
| PI-A01 | D | **sí** (🟡): Basic 10 000/mes [PM-25 🟡] + $1.80/1 000 [PM-66]; Free 100 sin sobrecoste [PM-24, PM-65] | **sí**: Pro 50 000/mes [RS-22] + $0.90/1 000 con PAYG apagado por defecto [RS-80, RS-84]; Free 3 000 sin sobrecoste [RS-20, RS-83] | **sí**: Essentials 50 000/mes [SG-29] + $0.00133/email [SG-77] hasta 10× el plan [SG-81]; Trial 100/día tope duro [SG-22, SG-24] | **sí**: Hobby 5 000/30 días [MS-30] + $1.50/1 000 [MS-78]; Starter 50 000 + $1.30 [MS-31, MS-79]; Free 500 tope duro sin sobrecoste [MS-27, MS-29, MS-81]; tope de gasto lo fija el cliente [MS-82], el del proveedor no publicado [MS-83] |
| PI-A02 | D | **sí, sin cifra**: «no publicado» [PM-82 🟡] (la nota del catálogo lo da por respuesta válida); cabecera 5 000/s sin leer [PM-40] | **sí**: 10 req/s por equipo [RS-50]; Enterprise no publicado [RS-102 🔴] | **sí**: 10 000 req/s en `mail/send` [SG-46], solo FAQ y no observable [SG-113, SG-100] | **sí**: 120 req/min en `/v1/email` en los cuatro planes [MS-45]; 60/min en el resto [MS-44]; es el valor «por defecto» de una cuenta sana: 10/min bajo revisión [MS-48], «lower» sin cifra recién ascendida [MS-49]; el sondeo midió 10/min en la cuenta sin aprobar [MS-163], no el 120 |
| PI-A03 | D | **parcial**: 50 destinatarios [PM-43…PM-48]; si cuentan uno a uno, sin confirmar [PM-92] | **sí**: 50 [RS-62…RS-64]; cuentan por destinatario [RS-28]; idénticos deduplicados [RS-34] | **sí**: 1 000 [SG-59]; cuentan por destinatario, incluso diferidos [SG-35] | **parcial**: 50 to + 10 cc + 10 bcc por campo [MS-59 🟡], total 70 no publicado [MS-113 🟡]; si cuentan uno a uno, sin artículo propio [MS-39, MS-114]; sin aprobar 10 + 1 + 1 [MS-60] |
| PI-A04 | D | **no**: sin fila de límite diario (PM-29 es el total del *test mode*, no un diario) | **sí**: Free 100/día [RS-21] además de 3 000/mes [RS-20]; Pro sin diario [RS-27] | **parcial**: Trial solo diario 100 [SG-22]; Essentials/Pro solo mensual [SG-29, SG-31], sin fila de diario en pago | **sí**: cuota diaria de **peticiones** en los cuatro planes, 100 / 1 000 / 100 000 / 500 000 a medianoche UTC [MS-34, MS-35], además de la mensual de emails [MS-27, MS-30, MS-31]; en Free, además, 100 emails/día con valor 🟡 y ventana 🔴 [MS-28, MS-115, DISC-11]. Dos métricas, no una |
| PI-A05 | D | **sí** (no en YAML): 10 MB por mensaje [PM-54], 50 MB en batch [PM-55], medido tras base64 [PM-57] | **sí** (no en YAML): 40 MB de adjuntos tras base64 [RS-67] | **sí** (🟡): 30 MB [SG-62 🟡] | **parcial**: sin tope total de mensaje publicado [MS-121]; solo por partes: text/html 2 MB, 25 MB por adjunto tras base64 [MS-68]; lote 50 MB de JSON [MS-63] |
| PI-A06 | P (Q1) | **sí** (🟡): 100 000/(5 000×50) = 0,4 s con k = 50, 20 s con k = 1 [PM-98, PM-43…PM-48]; exige el escalón 125 000 del panel [PM-09, no en YAML] o 9 renovaciones de 10 000 [PM-25 🟡] (motor: 270 días y 1 s) | **sí**: 100 000 correos = 100 000/(10×50) = 200 s con k = 50, 10 000 s (2,78 h) con k = 1 [RS-50, RS-62]; exige cuota Scale [RS-23] o Pro 100k [RS-03] | **sí**: 100 000/(10 000×1 000) = 0,01 s con k = 1 000, 10 s con k = 1 [SG-46, SG-57]; cuota Pro 100K [SG-31]; rate no observable [SG-100] | **sí** (🟡): Hobby al rate 100 000/120 = 833 min = 13 h 53 min con k = 1, 1 429 peticiones = 11,9 min con k = 70 (11 min con la ráfaga en t = 0) [MS-45, MS-59]; la cuota diaria de 1 000 peticiones lo estira a 100 días (k = 1) o 2 días (k = 70) [MS-35]; la mensual de 5 000 no para por el sobrecoste [MS-78]. Motor: 570 d 41 min y 570 d (cuota dura sin `max_budget`, H3, y H1). Con Starter (100 000 peticiones/día) el rate manda: 13 h 53 min |
| PI-A07 | P (Q3) | **sí** (🟡 por el rate): Free 100 en el ciclo [PM-24]; 5 000×604 800 = 3,02·10⁹ req no limita [PM-98]; motor 100 | **sí** (🟡): Free en una semana 7×100 = 700 [RS-21], por debajo de 3 000 [RS-20]; 10×604 800 = 6 048 000 req no limita [RS-50]; ventana diaria 🟡 [RS-25] | **sí**: Trial 7×100 = 700 [SG-22], ventana UTC [SG-26] | **sí** (🟡 por la ventana del Free): 500 en 30 días, tope duro [MS-27, MS-29, MS-32 🟡]; 7×100 = 700 peticiones/semana ≥ 500 no limita [MS-35]; 120×10 080 = 1 209 600 req tampoco [MS-45]; motor 500 |
| PI-A08 | X | **no**: REST no publicado [PM-83]; SMTP 10 conexiones/IP no aplicadas [PM-38, PM-39] | **no**: sin fila | **no**: REST sin fila; SMTP 10 000 conexiones [SG-55] | **no**: REST sin fila; SMTP 5 conexiones (Free–Starter) y 50 (Professional) [MS-55] |
| PI-B01 | P (Q6) | **sí** (🟡, panel): 40 000/mes → Platform $18 + 30 000×$1.20/1 000 = $54 [PM-05, PM-27 🟡, PM-68] < escalón Basic 50 000 $55 [PM-08, no en YAML] < Pro $16.50+$39 = $55.50 [PM-67] < Basic $15+$54 = $69 [PM-66]; cruce tier×volumen no observable [PM-87] | **sí**: Pro $20 cubre 40 000 [RS-02, RS-22] | **sí**: Essentials 50K $19.95 [SG-02, SG-29] | **sí**: Starter $35 cubre 40 000 [MS-04, MS-31] < Hobby $7 + 35 000×$1.50/1 000 = $59.50 [MS-03, MS-30, MS-78] < Professional $110 [MS-05]; Free inalcanzable [MS-27, MS-81]; motor: Starter 35 < Hobby 59,5 < Professional 110. Hobby a k = 1 solo llega a 30 000/mes por la diaria [MS-35] (H1) |
| PI-B02 | P (Q7) | **sí** (🟡): $50 → Platform $18 + $32/$1.20 = 26 666 extra → 36 666 [PM-05, PM-27 🟡, PM-68]; Basic 29 444 [PM-66]; Pro 35 769 [PM-67]; el escalón 50 000 cuesta $55 [PM-08] | **sí**: Pro 100 000 a $35 [RS-03, no en YAML] más $15 de sobrecoste. El panel cobra por bloques enteros, `"Resend will automatically charge $0.90 for each additional bucket of 1,000 emails"` [RS-84], así que $15 compran 16 bloques y sobran $0.60: **116 000**. Sin bloquear, la división daría 116 666 [RS-80]. Motor **83 343,33**, porque la escalera de volumen no está serializada y solo conoce el Pro base de 50 000 a $20 (`PI-B02_resend.json`): (50 − 20)/0,0009 = 33 333 más la cuota y la ráfaga | **sí**: Essentials 100K $34.95 [SG-06, SG-30, no en YAML] + $15.05/$0.0009 = 16 722 → 116 722 [SG-77]; tope 10× no alcanzado [SG-81] | **sí**: Starter $35 + $15/$1.30 = 11 538 extra → **61 538** [MS-04, MS-31, MS-79]; Hobby $7 + $43/$1.50 = 28 666 → 33 666, pero a k = 1 la diaria lo deja en 30 000 [MS-35]; Professional no asequible ($110 > $50) [MS-05]; el peldaño Starter 100K cuesta $68 [MS-19]. Motor: 61 658,46 / 33 786,67 (ráfaga de la ventana siguiente) y Professional 50 120 (H2: no marca inasequible) |
| PI-B03 | P (Q10) | **sí** (🟡): 12 000 → sobrecoste Basic $15 + 2 000×$1.80/1 000 = $18.60 [PM-03, PM-25 🟡, PM-66] < Pro $16.50 + $2.60 = $19.10 [PM-67] < escalón 50 000 $55 [PM-08] | **sí** (degenerada): Free no admite sobrecoste [RS-83] y 100/día [RS-21]; Pro $20 cubre [RS-22] | **sí** (degenerada): Trial tope duro [SG-24]; Essentials $19.95 cubre [SG-29] | **sí**: 12 000 → Hobby $7 + 7 000×$1.50/1 000 = **$17.50** [MS-03, MS-30, MS-78] < Starter $35 [MS-04]: el sobrecoste gana; a k = 1 son 12 días de cuota diaria, cabe [MS-35]; motor 17,5 < 35 < 110 |
| PI-B04 | D | **parcial**: Free 100/mes [PM-24], rate no publicado [PM-82], en *test mode* solo a dominios verificados [PM-29]; features = canal web | **parcial**: 3 000/mes y 100/día [RS-20, RS-21], 10/s [RS-50], sin dominio verificado solo a la propia dirección [RS-71]; 3 dominios [RS-38] es canal web | **parcial**: 100/día durante 60 días [SG-22, SG-87], después cero [SG-88], identidad verificada obligatoria [SG-20]; features = canal web | **parcial**: Free 500/mes tope duro [MS-27, MS-29], 100 peticiones/día [MS-35], 120/min [MS-45]; pero exige tarjeta y aprobación de hasta 48 h [MS-02, MS-94], dominio propio verificado para enviar [MS-76] y para subir de plan [MS-140]; antes de aprobar, Sandbox 100/mes a 2 destinatarios [MS-89, MS-90] y 10 + 1 + 1 [MS-60]; 1 dominio y 1 webhook [MS-103] es canal web |
| PI-B05 | P (Q5) | **sí** (🟡): el rate lo permite, 5 000×3 600 = 18 000 000 ≥ 20 000 con k = 1 [PM-98]; la cuota no: supera el arranque de 10 000 [PM-25 🟡] → sobrecoste o escalón 50 000 [PM-08]; motor NO en los cuatro planes, `quota_exceeded` | **sí**: 10×3 600 = 36 000 req/h ≥ 20 000 con k = 1 [RS-50]; Free no (100/día [RS-21]); Pro [RS-22] | **sí**: 10 000×3 600 = 36 000 000 [SG-46]; Trial no [SG-22]; Essentials 50K [SG-29] | **sí**: 120×60 = 7 200 peticiones/h < 20 000 → **NO en los cuatro planes a k = 1, por el rate** [MS-45]; motor NO × 4, `rate_exceeded`, primera violación a 21,6 s. Con k ≥ 3 (6 667 peticiones) el rate lo permite, pero Free (100/día) y Hobby (1 000/día) caen por la diaria [MS-35] y por la mensual [MS-27, MS-30]: Starter [MS-31]. Primera API donde la respuesta a un pico la da el rate |
| PI-C01 | H | **sí** (panel): 50 000/mes → escalón Basic $55 [PM-08, no en YAML]; por sobrecoste Platform $66, Pro $68.50, Basic $87 [PM-66…PM-68] | **sí**: Pro $20 [RS-02] | **sí**: Essentials 50K $19.95 [SG-02] | **sí**: Starter $35 cubre justo 50 000 [MS-04, MS-31]; Hobby por sobrecoste $7 + 45 000×$1.50/1 000 = $74.50 [MS-78]. Comparación: SG $19.95 < RS $20 < MS $35 < PM $55 |
| PI-C02 | H | **sí** (🟡): 10 000/$15 = 667 correos por dólar [PM-25 🟡, PM-03] | **sí**: 50 000/$20 = 2 500 [RS-22, RS-02] | **sí**: 50 000/$19.95 = 2 506 [SG-29, SG-02] | **sí**: primer tier de pago Hobby 5 000/$7 = 714 [MS-30, MS-03] (Starter daría 1 429 [MS-31, MS-04]). SG 2 506 ≈ RS 2 500 > MS 714 > PM 667 |
| PI-C03 | D | **sí**: no publica [PM-82 🟡]; la API sí lo devuelve [PM-40] | **sí**: publica [RS-50] | **sí**: publica, solo en una FAQ [SG-46, SG-113] | **sí**: publica, en tres páginas [MS-45], pero como valor por defecto ligado al estado de la cuenta [MS-48, MS-117], no por plan |
| PI-C04 | H | **sí** (🟡): 100 000 en 0,4 s (k = 50) o 20 s (k = 1) [PM-98, PM-43…PM-48] | **sí**: 100 000 en 200 s (k = 50) [RS-50, RS-62] | **sí**: 100 000 en 0,01 s (k = 1 000) [SG-46, SG-57] | **sí** (🟡): 100 000 en 13 h 53 min (k = 1) o ≈ 12 min (k = 70) al rate, en Starter o Professional [MS-45, MS-59, MS-35]; en Hobby la diaria lo lleva a 100 días / 2 días. A k = 1 por rate: SG 10 s < PM 20 s < RS 2,78 h < MS 13 h 53 min (los 0,01 s de SendGrid son con k = 1 000, no con k = 1). Comparación posible en las ocho |
| PI-C05 | X | **no**: sin operación de diff | **no** | **no** | **no** |
| PI-D01 | P (Q5) | **sí** (🟡): Basic, la cuota (1 296 000× de margen) [PM-25 🟡, PM-98]; t_min 2 s a mano, 1 s en el motor; ver (b) | **sí**: Free, la cuota (8 640× de margen) [RS-21, RS-50]; ver (b) | **sí**: Trial, la cuota (8,6·10⁶×) [SG-22, SG-46] | **sí** (🟡): Hobby, la cuota (1 037× de margen sobre la mensual) [MS-30, MS-45]; pero a k = 1 la que se agota antes es la **diaria de peticiones** (8 min 20 s), luego la mensual (4 d 8 min), nunca el rate [MS-35]; motor 41 min (par rate–mensual, H1); ver (b) |
| PI-D02 | P (Q5) | **sí** (🟡): el rate solo sería el límite por encima de 5 000×2 592 000 = 12 960 000 000 correos/mes con k = 1 [PM-98]; el mayor volumen del panel es 1 500 000 [PM-12]; motor `rates: [5000/1s]`, capacidad 12 960 005 000 | **sí**: el rate solo sería el límite por encima de 10×2 592 000 = 25 920 000 correos/mes con k = 1 [RS-50]; ningún plan publicado llega [RS-05]; la premisa de la pregunta se invierte: el rate empieza a limitar al subir el volumen, no deja de hacerlo | **sí**: por encima de 2,592·10¹⁰/mes [SG-46]; nadie llega [SG-33] | **sí**: por encima de 120×43 200 = **5 184 000**/mes con k = 1 [MS-45]; el mayor peldaño es 2 000 000 (Professional) [MS-20], a 2,6× de distancia; bajo revisión (10/min) el umbral baja a 432 000 y seis peldaños lo superan [MS-48, MS-19, MS-20]. Antes que el rate acota la diaria: Hobby 30 000/mes, Starter 3 000 000/mes a k = 1 [MS-35]. Motor: rate 120/1min, capacidad 5 184 120 (H1) |
| PI-D03 | P (Q9) | **sí** (🟡): k* = 10 000/1,296·10¹⁰ = 7,7·10⁻⁷ en Basic [PM-25 🟡, PM-98] → ningún k ≥ 1; motor 1 s / 0 s / 0 s para k = 1, 26, 50 | **sí**: k* = Q/(R·W) = 50 000/25 920 000 = 0,0019 en Pro [RS-22, RS-50] → ningún k ≥ 1 iguala los dos límites | **sí**: 50 000/2,592·10¹⁰ = 1,9·10⁻⁶ en Essentials [SG-29, SG-46] → ninguno | **sí** (🟡): k* = 5 000/5 184 000 = 0,00096 en Hobby [MS-30, MS-45] → ningún k ≥ 1; motor 41 min / 1 min / 0 s para k = 1, 36, 70. Frente a la diaria, k*_d = 5 000/30 000 = 0,167. Bajo revisión, Starter 1M: k* = 2,31, el primer k* ≥ 1 del catálogo [MS-48, MS-19] |
| PI-D04 | D | **parcial**: no publicado en ningún plan [PM-82 🟡]; el 5 000 adoptado es un solo valor para los cuatro planes por decisión de modelado (D2), no observado plan a plan [PM-98] | **sí**: un solo valor por defecto, la doc «no afirma ni niega» que varíe [RS-50, RS-51, RS-104]; Enterprise sin cifra [RS-58 🔴] | **sí**: un solo valor sin condición de plan [SG-46, SG-113] | **sí**: el de `/v1/email` no sube, 120 en los cuatro [MS-45]; el del lote sí, 10 / 15 / 30 (Enterprise 60) [MS-46 🟢, DISC-08 cerrada por E4], y la cuota diaria de peticiones también, 100 → 500 000 [MS-35]; lo que baja el rate es el estado de la cuenta, no el plan [MS-48] |
| PI-D05 | D (era X hasta D-041) | **no**: sin fila | **no**: «trusted senders upon request» sin umbral [RS-53, RS-103] | **no**: `reputation: 100` en la cuenta [SG-95] y gzip «some high volume accounts» [SG-64, SG-111], sin cifra | **sí**: cambian con la reputación, y con cifra: 120 → 10/min en `/v1/email`, lote 60 → 1 bajo revisión [MS-48]; «lower» sin cifra tras subir de plan [MS-49]; cuatro estados [MS-50]; cuota de cuenta a medida por cumplimiento [MS-41]; sin aprobar 10 + 1 + 1 y 100/mes [MS-60, MS-42]. Los umbrales no [MS-118]. Primera API con respuesta a esta X |
| PI-D06 | X | **X·hechos**: 429 «Rate Limit Exceeded» [PM-36] | **X·hechos**: 429 + `retry-after` fijado por el servidor [RS-56, RS-57, RS-105] | **X·hechos**: 429 y bloqueo el resto del *refresh period* [SG-49, SG-50] | **X·hechos**: 429 con dos causas y cabeceras distintas (`x-apiquota-*` para la diaria, `x-ratelimit-*` y `retry-after` para el rate) [MS-37, MS-52, MS-56]; el SDK reintenta con backoff [MS-57]; al agotar el Free, 202 con `x-send-paused: true` [MS-75] |
| PI-E01 | L | **sí** (matriz; canal web, panel): «All Event Webhooks» solo en Pro y Platform [PM-16, PM-17] → Free no | **sí** (matriz): webhook endpoints 1 / 5 / 10 por plan [RS-38] → Free 1 | **sí** (matriz): event webhook 1 / 2 / 5 / 5 [SG-42] → Trial 1 | **sí** (matriz): Free 1 webhook [MS-103]; Hobby 1 o 5 según la página (DISC-05) [MS-105]; «Add webhook» disponible ya en Sandbox [MS-143] |
| PI-E02 | L | **sí** (matriz): 200 000/mes no alcanza el requisito de 300 000 para IP dedicada [PM-18] → no elegible | **sí** (matriz): Scale 200 000 $160 [RS-05] + IP $30 [RS-11] = $190 (6 667/día > 3 000) | **sí** (matriz): Pro incluye 1 IP [SG-11]; Pro 100K $89.95 + 100 000×$0.0011 = $199.95 [SG-03, SG-31, SG-77] o Pro 300K $249 [SG-06] | **sí** (matriz): **no elegible** a 200 000/mes, el requisito publicado es 500 000/mes [MS-108]; si lo fuera, Starter 250K $162.50 + $50 = $212.50 [MS-19, MS-108] o Professional 250K $275 + $50 = $325 [MS-20] según el plan mínimo (DISC-04). RS $190 < SG $199.95; PM y MS no elegibles; mezcla canales |
| PI-E03 | X | **X·hechos**: 45 días por defecto [PM-33], 7–365 con add-on [PM-34, PM-35] | **X·hechos**: 30 días en Free, Pro y Scale [RS-35] | **X·hechos**: 3 / 3 / 7 / 7 días [SG-43] | **X·hechos**: 1 / 1 / 7 / 30 días de actividad [MS-106]; logs solo Professional, 7 días [MS-106, MS-112]; add-on hasta 365 días cotizado por volumen contratado [MS-26] |
| PI-F01 | D | **no**: sin Datasheet previa en las fichas [PM-73] | **sí**: rate 2 → 10 req/s [RS-59, RS-92]; retención 1/3/7 → 30 días [RS-93]; dominios Free 1 → 3 [RS-94] | **parcial**: modelado previo no consultado [SG-98]; cambios fechados por el proveedor: tope 10× desde 2026-03-26 [SG-81, SG-94], Free retirado 2025-05-27 [SG-92] | **sí**: dos Datasheets fechadas (2026-03-19 y 2026-09-08) difieren en precio 5.60 / 28 / 88 → 7 / 35 / 110, sobrecoste 1.20 / 0.95 → 1.50 / 1.30, ventana `rolling` → `fixed_billing_cycle` y rate del lote 10 × 4 → 10 / 15 / 30 [MS-86, MS-101]; en cuota y rate de `/v1/email`, sin cambio. El proveedor no fecha ningún cambio [MS-99, MS-100] y sirve hoy las dos ofertas [MS-15, MS-16]: qué parte es cambio y qué parte lectura del precio anual no se decide (DISC-03) |
| PI-F02 | X | **X·hechos**: [F1]–[F3] re-verificadas el 2026-08-03 [PM-74] | **X·hechos**: reverificación 2026-09-01, «ningún valor modelado ha cambiado» [RS-91] | **X·hechos**: verificador mismo día, 34 coinciden / 0 cambian / 1 no encontrado [SG-97] | **X·hechos**: verificación independiente el mismo día, 30 hallazgos, «ningún valor modelado refutado» [MS-155]; citas 210 OK / 0 cambio sobre 16 volcados [MS-156]; Términos actualizados el 2026-08-31 [MS-97] |
| PI-G01 | H | **parcial**: cuota 10 000 🟡 [PM-25] pero el ejemplo no fija volumen inicial; sin tope de sobrecoste publicado | **parcial**: cuota 50 000 [RS-22]; sin volumen inicial; PAYG sin tope publicado [RS-84] | **parcial**: cuota 50 000 [SG-29]; el punto en que hay que cambiar sí es duro: 10× = 500 000 [SG-81] | **parcial**: cuota 5 000 (Hobby) o 50 000 (Starter) [MS-30, MS-31]; sin volumen inicial; tope de sobrecoste del proveedor no publicado [MS-83, MS-126], solo el voluntario del cliente [MS-82]; el punto duro lo pone la diaria: 30 000·k/mes en Hobby [MS-35] |
| PI-G02 | P (Q10) | **sí** (🟡): 25 000 en Basic = $15 + 15 000×$1.80/1 000 = $42 [PM-03, PM-25 🟡, PM-66] | **sí**: Free imposible [RS-83, RS-21]; Pro $20 cubre [RS-22] | **sí**: Trial imposible [SG-24]; Essentials $19.95 cubre [SG-29] | **sí**: 25 000 en Hobby = $7 + 20 000×$1.50/1 000 = **$37** [MS-03, MS-30, MS-78], más que Starter $35 que ya cubre [MS-04]; a k = 1 son 25 días de diaria, cabe [MS-35]; motor 37 |
| PI-G03 | D | **sí** (no en YAML): escalera 10k…1,5M a $15…$775 elegida aparte del tier [PM-07…PM-14] | **sí** (no en YAML): Pro 100k $35 [RS-03]; Scale 200k…2,5M $160…$1 150 [RS-05] | **sí** (no en YAML): Essentials 100K $34.95, Pro 300K…2,5M $249…$1 099 [SG-06, SG-08, SG-30, SG-32] | **sí** (no en YAML): Starter 50K…1M a $35…$600 y Professional 50K…2M a $110…$1 600 con un selector [MS-18, MS-19, MS-20]; Hobby sin escalera [MS-03]; anual −10 % [MS-21]; tope de Starter 500K o 1M en discrepancia [MS-22, MS-125]; solo con JavaScript [MS-23] |

### Las cuatro APIs nuevas

| id | clase | Brevo | Amazon SES | Mailgun | Mailchimp |
|---|---|---|---|---|---|
| PI-A01 | D | **parcial**: la cuota sí, en los cinco planes — Free 300/día [BR-08, BR-62], Starter y Standard desde 5 000/mes [BR-07, BR-34], Professional desde 150 000 [BR-07], Enterprise `custom` [BR-158 🟢]; el comportamiento al superarla solo está documentado en el Free: cola de 1 000 correos y descarte silencioso a partir del 1 301, sin error legible [BR-63]. En los tres planes de pago **no está documentado** [BR-148], y **no hay precio de exceso en ninguno**: la página de precios lo niega, `"there are no additional fees"` [BR-147]. Lo que sí hay es un ascenso automático disparado por contactos, no por correos [BR-41] | **sí [sandbox]**: **ningún plan incluye correos**. Los cuatro —`a_la_carte` 0,00, `essentials` 0,00, `pro` 105 y `enterprise` 500 USD/mes [SE-02 🟢, SE-03 🟢, SE-04 🟢, SE-05 🟢]— cobran por destinatario y no traen volumen, «you pay only for what you use with no minimum fees» [SE-15, SE-143]. Por eso tampoco hay sobrecoste: ningún `overage_cost` en el fichero [SE-145]. La única cuota con cifra es la del entorno de pruebas, **200 correos / 24 h** [SE-50 🟢, SE-51 🟢, SE-52 🟢, SE-67 🟢], y al superarla hay rechazo, no cola: `ThrottlingException` con «Daily message quota exceeded», el mensaje se descarta y no se reintenta [SE-68, SE-69, SE-77]; lo fallido no se factura [SE-79]. La cuota de producción no se publica, «this number varies based on your specific use case» [SE-61, SE-152]. Lo que sí cuesta enviar —$0.10/1.000 à la carte, $0.16/$0.22/$0.23 por 1.000 en los tres planes, en tramos marginales [SE-15, SE-10, SE-11, SE-12, SE-13]— **no cabe en v0.3 y vive en `not_found`** [SE-47, SE-168] | **sí** (🟡 en Free): Basic 10 000/mes [MG-37 🟢] + $1.80/1 000 [MG-98 🟢]; Foundation 50 000 + $1.30 [MG-38, MG-99]; Scale 100 000 + $1.10 [MG-39, MG-100]; Free **sin sobrecoste** [MG-101] y con su volumen publicado en dos periodos que nadie concilia, 100/día [MG-33 🟡] y 3 000/mes [MG-34 🟡] (DISC-03, F-38 [MG-35, MG-110]). Las cuatro cifras son del **tramo mínimo de cada tarjeta**: la escalera de volumen y la del sobrecoste viven en el provenance [MG-09, MG-07, MG-08, MG-102, MG-103]. Sin tope de exceso del proveedor [MG-105]; el único lo levanta el titular [MG-42] | **sí** (🟡): un solo plan, `transactional_email` [MC-02], con un bloque de **25.000 correos/mes** [MC-25 🟢] a **$20,00/bloque** [MC-04, MC-11 🟡]. Al superarlo no pasa nada, porque no se puede superar: **no hay sobrecoste** [MC-84] y el bloque es muro, `"el sistema dejará de enviar correos electrónicos cuando se te acaben los bloques"` [MC-27]. Lo que ocupa el lugar del sobrecoste es comprar otro bloque en una escalera degresiva de seis tramos, $20 → $10 [MC-04…MC-09], de la que el fichero solo serializa el de entrada [MC-11] y por eso **encarece al proveedor barato** [MC-88]; por encima de 161 bloques no hay cifra [MC-12, MC-107] y si el precio del tramo alcanzado es marginal o plano no consta [MC-87, MC-106]. El único tope de gasto lo pone el cliente, con la auto-compra [MC-28, MC-86]. En el estado `demo`, 500 correos de franquicia y tampoco sobrecoste [MC-18, MC-29] |
| PI-A02 | D | **sí** (🟡): 1 000 RPS y 3 600 000 RPH en `POST /v3/smtp/email`, tramo General, declarado para los cinco tipos de cuenta [BR-81 🟡, BR-82 🟡]; Advanced 2 000 RPS y Extended 6 000 RPS [BR-84 🟡, BR-85 🟡]. El 🟡 tiene dos causas: DISC-01, porque la página de lotes publica 6 000 llamadas/hora sobre el mismo endpoint, un factor 600 [BR-128]; y DISC-15, porque la misma página se contradice —la viñeta restringe Advanced a Professional y Enterprise, y el distintivo `"Available in"` que encabeza su tabla lo anuncia en los cinco [BR-103b]—, sin decir si el tramo se activa al contratar [BR-160]. Una cuenta Free devolvió `x-sib-ratelimit-limit: 1000` en el endpoint de envío, sin ventana declarada, registrado sin adoptar [BR-108, BR-177]. En consulta sí está medido: 2 RPS con 429 alcanzado [BR-110 🟢, BR-117 🟢] | **sí [sandbox]**: **1 petición por segundo**, y no es del plan sino del estado de la cuenta [SE-80 🟢, SE-81 🟢, SE-83 🟢]. Lo publican cuatro superficies que coinciden: la doc [SE-82 🟢], Service Quotas y el panel («Tasa máxima de envío → 1 correo electrónico por segundo») [SE-99 🟢], la página de aumento de límites [SE-67 🟢] y la propia API, `"MaxSendRate": 1.0` [SE-76 🟢, SE-100 🟢]. Fuera del entorno de pruebas **no hay cifra**, «this rate varies based on your specific use case» [SE-82, SE-153 🔴]; el único ejemplo de producción es hipotético [SE-104]. El resto de operaciones va a 1/s en 🟡, porque el literal exceptúa tres nombres de la v1 y el fichero modela la v2 [SE-84 🟡, SE-156 🟡, DISC-05]. Y el tope declarado no se aplica: dos envíos a 0,257 s y 0,518 s del inicio, los dos en 200 [SE-101]; doce lecturas a 5,7/s sin un rechazo [SE-102 🟡] (F-04 medida) | **sí** (🟡): **dos caudales sobre el mismo envío**. La cuenta lleva 1 500 req/s [MG-50 🟡], única cifra publicada y acotada `"per client IP"`, no por cuenta [MG-51]; el endpoint de envío lleva 80 000 req/10 s = 8 000/s, **medido**, no publicado [MG-58 🟡]. Manda el menor: el publicado es 5,3 veces más restrictivo que el medido, y es justo el que el esquema no sabe acotar por ámbito [MG-51, MG-106]. La documentación de desarrollador describe cabeceras y 429 y no publica ningún umbral [MG-54 🔴, MG-57] (DISC-01, abierta). Ningún caudal se atribuye por plan: la misma clave cuelga de los cuatro [MG-64 🟡, MG-113] | **sí [demo]**: **25 correos por hora** [MC-42 🟢], con cuatro superficies que dan el mismo número y ninguna discrepancia: dos páginas de documentación [MC-42, MC-43], el panel [MC-44] y una medición contra `POST /users/info`, `"hourly_quota":25` [MC-45 🟢]. Dos cosas la separan del resto de la tabla. La unidad **no es peticiones, son correos** [MC-42, MC-46], y el motor la devuelve así, `{"value": 25.0, "unit": "emails", "period": "1h"}`. Y para la cuenta de **pago no hay cifra ninguna**, con literal que lo dice —`"their hourly quotas will be very different"` [MC-49, MC-95]—, que es la respuesta «no publicado» que la propia pregunta admite. El caudal general de la API REST tampoco está publicado [MC-99]; el único endpoint con caudal propio es la búsqueda, 20 peticiones/min [MC-55 🟢, MC-56] |
| PI-A03 | D | **sí** (🟡 el tope, 🟢 el cómputo): 2 000 destinatarios por petición y 99 por versión de mensaje [BR-107 🟡, BR-121, BR-122]; con adjunto el tope baja a 99 en el mismo endpoint y el mismo modo [BR-70]. Cuentan uno a uno y está **medido**: una petición con dos destinatarios dejó el saldo en 298 de 300, estable 90 s después [BR-112 🟢]. El 🟡 es de la cifra, no del cómputo: los 2 000 viven dentro de la descripción de `messageVersions` y ninguna de las dos specs pone `maxItems` en `to`, `cc` ni `bcc` [BR-163] | **sí**: **50 destinatarios por mensaje**, «A recipient is any "To", "CC", or "BCC" address», Adjustable: No [SE-106 🟢]; el tope no aparece en la referencia de la operación, solo en la página de cuotas [SE-107 🟢, F-05]. Y **cuentan uno a uno**, medido: cuatro mensajes con cinco destinatarios dejan el contador en `"SentLast24Hours": 5.0` sobre `"Max24HourSend": 200.0` [SE-182 🟢]. Cinco descarta el mensaje como unidad y descarta la deduplicación; las dos habrían dado cuatro. Es el cierre de DISC-02, que enfrentaba «emails» en la fila con «Quotas are based on the number of recipients» en la cabecera de esa misma tabla [SE-54, SE-55, SE-56]. **Única API del catálogo que lo cierra sobre el contador de la cuenta.** Reserva: el correo con plantilla lleva su propia unidad, «50 destinations», con la misma cifra [SE-108]; el lote no publica el máximo de entradas por llamada [SE-115 🟢, SE-157] | **parcial**: 1 000 destinatarios por lote en dos páginas [MG-69 🟢, MG-70] y **medido** el 2026-09-21 (1 001 → 400 `"Too many recipients, max is 1000"`) [MG-71]; el recuento se aplica antes que los permisos, y por eso se pudo medir desde una cuenta que no puede enviar [MG-73]. Falta la otra mitad: el máximo del **envío individual**, fuera del lote, no está publicado [MG-114], y «cada destinatario consume una unidad de cuota» es **inferencia del fichero, no literal del proveedor** — el sondeo no llegó a enviar y no lo comprobó [MG-148, MG-147] | **parcial**: la primera mitad la contesta el proveedor negando el tope —`"Via the API, there's no recipient limitation, but the JSON provided per API call must be less than 10MB"` [MC-60 🔴, MC-61 🟢]— y el sondeo lo confirma: 500, 1.000, 1.001 y **5.000 destinatarios** en una sola llamada devuelven HTTP 200 `queued`, sin cota superior alcanzada [MC-129, MC-102]. La segunda mitad no tiene respuesta: si N destinatarios gastan N unidades del bloque **no es verificable**, porque el artículo del proveedor que lo trata devolvió **HTTP 403** en esta pasada [MC-110]. Vía SMTP sí hay entero, 1.000 destinatarios, y no se modela [MC-64] |
| PI-A04 | D | **sí**: no coexisten, se sustituyen. El Free tiene diaria y solo diaria, 300/día [BR-08, BR-62]; los de pago tienen mensual y **ninguna diaria**, y el proveedor escribe la negación tres veces: `"Upgrade to remove daily sending limit"` [BR-08], `"It includes no daily sending limit"` [BR-33], `"To remove the daily limit or send more emails, upgrade…"` [BR-65]. Los `"9,000/month"` que acompañan a los 300/día son la aritmética 300×30 y no un segundo tope: DISC-07, cerrada [BR-30, BR-62] | **sí [sandbox]**: la pregunta se invierte. **Solo hay diaria y no hay mensual en ningún plan**: la única cuota del fichero es 200 correos / 1 DAY [SE-50 🟢, SE-53 🟢], y ningún plan liga volumen mensual [SE-143, SE-145]. Una métrica, no dos. El motor lo confirma plan a plan: los cuatro devuelven `{'value': 200.0, 'unit': 'emails', 'period': '1day'}` [SE-137; `PI-B02_ses.json`]. Lo que queda abierto no es la existencia sino **la ventana**: `window_type` vacío y en 🔴 por DISC-10, con «This quota is calculated on a rolling time period» [SE-59 🔴] contra «you will have to wait until the next 24-hour period» [SE-60 🔴], y el panel mezclando las dos en una fila, utilización «0 per hour» y cuota «per 24 horas» [SE-74 🔴, SE-169 🔴] | **sí** (🟡): Free lleva las dos ventanas sobre la misma métrica, 100 emails/día [MG-33 🟡] y 3 000 emails/mes [MG-34 🟡]; los de pago solo la mensual [MG-37, MG-38, MG-39], y Basic lo dice con literal propio, `"No daily email limit"` [MG-36]. **Ninguna fuente concilia las dos del Free**: si la diaria compone la mensual o son concurrentes es hueco declarado [MG-35, MG-110] y ámbar abierto (DISC-03, F-38 [MG-161]). El fichero aloja la mensual en el plan y la diaria en el endpoint de envío: cabe y dice algo falso [MG-89, MG-161]. Además, ninguna de las dos tiene ancla de reinicio [MG-41 🔴, MG-112] | **no**: no hay fila de límite diario sobre el envío. Las dos ventanas del producto son la horaria del caudal [MC-42] y la mensual del bloque [MC-25], y ninguna fuente publica una diaria. Las dos cifras diarias de las fichas son de otra cosa: 100 correos **entrantes** al día [MC-35], que ningún endpoint puede referenciar porque recibir no es una llamada [MC-105], y 10.000 mensajes al día de **modo de pruebas** [MC-36], que no se modela mientras viva DISC-02 —la misma frase da dos anclas incompatibles, `"This limit resets at midnight"` y `"or if they hit the limit, 24 hours after that limit is hit"`—. Lo que Mailchimp sí tiene es lo contrario de esta pregunta: una segunda cuota **sin ventana ninguna**, los 500 de la franquicia [MC-30 🔴, MC-104], y el motor devuelve las dos **concatenadas en la misma fila** `[demo]`: `[{"value": 25000.0, "unit": "emails", "period": "30day"}, {"value": 500.0, "unit": "emails", "period": ""}]` |
| PI-A05 | D | **sí** (🟡): 20 MB por correo, contenido más adjuntos [BR-145 🟡]. La otra cifra publicada, `"25 MB per email"`, acota el **adjunto** y no el correo [BR-29]: DISC-16, cerrada el 2026-09-21, con la rareza de que el tope del adjunto es mayor que el del correo que lo lleva. El hueco que queda: ninguna fuente da el tamaño **por petición**, que es la unidad del `workload` [BR-166]; y la vía de plantilla añade un tope de 4 MB por adjunto que no se sabe si alcanza a la API [BR-146] | **sí**: **40 MB por mensaje tras base64**, adjuntos incluidos, en la API v2 y en SMTP, Adjustable: No [SE-109 🟢]. Por encima de 10 MB el tope se convierte en ancho de banda, «you may be throttled to as low as 40MB/s» [SE-111 🟢]. La v1 admite solo 10 MB sobre la misma cuota [SE-110] (F-15). Lo que no se publica es el número máximo de adjuntos; lo más cercano son 500 partes MIME [SE-112, SE-159]. En SMTP el exceso llega como «552 Message is too long.» [SE-118]. Los adjuntos se cobran aparte, $0.12 por GB [SE-114] | **sí** (🟡), y es la única respuesta del catálogo **refutada por medición**: el proveedor publica 25 MB por mensaje en tres páginas independientes [MG-74] y no los aplica — adjuntos de 30, 35, 40, 45 y 48 MB atraviesan la comprobación [MG-76]. El único tope del borde es HTTP 413, `"request size exceeds 52.4MiB limit"`, y es de la **petición entera**, no del mensaje [MG-77 🟡]; el fichero declara 52 MiB porque el esquema tipa el máximo como entero [MG-78 🟡, MG-111]. Comprimir no lo esquiva [MG-75]; el 413 no está documentado en ninguna parte [MG-130] y el tope por mensaje no llega al YAML [MG-115] | **sí** (no en YAML): **25 MB por mensaje**, adjuntos incluidos y sin tope por adjunto individual —`"Mailchimp Transactional allows attachments, but the total message size cannot exceed 25MB. There is no specific limit for individual attachments, just the total size of the message."` [MC-62]—. El que entra en el esquema es otro, el de la llamada: `"the JSON provided per API call must be less than 10MB"` [MC-61 🟢]. Los dos conviven en la misma página y son **conjuntamente inalcanzables**, porque 25 MB en base64 no caben en menos de 10 MB: no abren DISC y se registran como F-34 [MC-63, MC-166]. Medido: adjuntos de 5, 10, 20, 25, 26 y **30 MB**, y ~40 MB de cuerpo JSON, todos HTTP 200 `queued`, sin que ninguna respuesta devuelva umbral de tamaño [MC-127, MC-128, MC-103]. El literal se queda en 🟢 porque un sondeo no baja un literal oficial (D6) |
| PI-A06 | P (Q1) | **sí** (🟡): al caudal, 100 000/1 000 = **100 s** con k = 1 [BR-82 🟡] y 0,05 s con k = 2 000 [BR-107 🟡]; manda la cuota. En el escalón de entrada de Starter (5 000/mes [BR-07]) hacen falta 20 ventanas de 30 días: motor **570 día 4 s** con k = 1 y **570 día** con k = 2 000. Con `max_budget` de 10⁹ **no cambia nada**, porque la cuota de Brevo no tiene `overage_cost` que el presupuesto pueda expandir [BR-147, BR-148]. Comprando el escalón de 100k del deslizador [BR-09] la cuota deja de estorbar y quedan los 100 s | **sí [sandbox]**: 100.000 correos en `pro` = **499 d 3 min 19 s** con k = 1 y **499 d 3 s** con k = 50 (`PI-A06_ses.json`, alias `sandbox` en las cuatro filas). A mano: 499 renovaciones de la cuota de 200 más 200 s a 1 req/s, y los 3 min 19 s son esos 200 s menos la ráfaga de t = 0 [SE-50 🟢, SE-80 🟢]. **Con `max_budget` de 1e9 no cambia ni un segundo**, porque ninguna cuota de SES declara `overage_cost` [SE-145]: es uno de los dos primeros casos negativos de D-037 en el catálogo. La cifra es del estado declarado; en producción no se publican ni cuota ni caudal [SE-152, SE-153 🔴], así que fuera del entorno de pruebas la pregunta **no tiene entrada** | **sí** (🟡): Basic, 100 000 correos. Con la cuota dura de 10 000/mes [MG-37] son diez ciclos → **270 días**; el sobrecoste de $1.80/1 000 [MG-98] la expande y entonces manda el caudal: 100 000/1 500 = **66,7 s** con k = 1 [MG-50], y con k = 1 000 [MG-69] son 100 peticiones, por debajo del segundo. Motor: `270day6s` y `270day` sin presupuesto (k = 1 y k = 1 000), `1min6s` y `0s` con `max_budget` de 1e9 — la ejecución que separa la cuota del caudal. El caudal que decide es el de 1 500/s acotado **por IP** [MG-51], no el de 80 000/10 s medido en el envío [MG-58] | **sí [demo]** (🟡): 100.000 correos al único caudal publicado, 25 por hora, son **4.000 horas = 166 días 16 h** [MC-42]. Y es la misma cifra **para cualquier k**: el caudal está en correos, no en peticiones [MC-46], así que los 5.000 destinatarios por llamada que el sondeo aceptó [MC-129] no dividen el tiempo, lo dejan igual. La cuota no llega a atar: 25/h son 18.000 correos en 30 días, por debajo del bloque de 25.000 [MC-25], y comprar cuatro bloques ($80, tramo 1 [MC-04]) no acelera nada; la ventana del bloque es inferida y sin ancla de reinicio publicada [MC-26 🟡, MC-98]. Motor: las **cuatro** llamadas en `HTTP 500 {"detail": "float() argument must be a string or a real number, not 'NoneType'"}`, con y sin `max_budget` — la respuesta existe en los hechos y lo que falla es el instrumento (**DV-02**) |
| PI-A07 | P (Q3) | **sí** (🔴 por el ancla): Free, 300/día × 7 = **2 100** [BR-62]; el tope es duro y no acumula, `"unused emails do not roll over"` [BR-62]. Motor **2 400**: cuenta ocho ventanas, la del instante final incluida. El 🔴 es del ancla — `"resets every day"` no dice hora ni huso [BR-156 🔴], y el panel tampoco lo cierra [BR-71 🔴]. Los 1 000 de la cola de reintento no son capacidad: se entregan con retraso y solo en el Free [BR-63] | **sí [sandbox]**: SES **no tiene plan gratuito** —su capa gratuita está en discrepancia registrada, ni confirmada ni desmentida [SE-172, SE-41, SE-42, SE-43; DISC-18]— y empata dos planes en `price: 0.00`, `a_la_carte` y `essentials`, sin campo que desempate [SE-02 🟢, SE-03 🟢]. Por E16 se ejecutan **los dos**, y los dos devuelven **1.401** correos en siete días (`PI-A07_ses.json`). A mano: 7 × 200 = 1.400 más la ráfaga de 1, que el caudal de 1 req/s acota. Que las dos instancias den la misma cifra **es la medida de que el eje de plan no informa**, no una coincidencia | **sí** (🟡): Free, siete días. 7 × 100/día = 700 [MG-33 🟡]; motor **800**, porque concede una ráfaga inicial del tamaño del contador, 100 × (7 + 1). La mensual de 3 000 [MG-34 🟡] no ata en esa ventana y **ninguna fuente dice si las dos actúan a la vez** [MG-35, MG-110]. Ninguna de las dos publica ancla de reinicio [MG-41 🔴, MG-112]. Y la capacidad contractual no es capacidad efectiva: el Free solo envía a destinatarios autorizados, `"Free accounts are for test purposes only"` (403 **medido**) [MG-49], y la lista no se publica ni se ve en el panel [MG-120] | **sí [demo]**: **500**, y no son 500 por semana, son 500 en total. La franquicia no caduca ni se renueva —`"The emails included with the demo do not expire or renew."` [MC-30 🔴]— y la demo termina al agotarla, `"You immediately lose access to the demo if: … You send 500 emails."` [MC-31]; se concede una sola vez por cuenta [MC-32]. El caudal daría 25 × 168 = 4.200 correos en la ventana [MC-42], ocho veces más de lo que la franquicia permite: los 500 se agotan en **20 horas**. Es la única columna donde la respuesta a «cuánto acumula en siete días» no depende de los siete días. Motor: `HTTP 500 {"detail": "float() argument must be a string or a real number, not 'NoneType'"}` (**DV-02**) |
| PI-A08 | X | **no**: ninguna página publica conexiones simultáneas, peticiones en vuelo ni ventana de ráfaga; solo RPS y RPH [BR-167]. El canal SMTP tampoco: puertos y nada más, ni conexiones ni mensajes por conexión, ni si los RPS de la API alcanzan al relay [BR-168]. Junto con Resend, la más vacía de las cinco: Postmark (10 conexiones/IP), SendGrid (10 000) y MailerSend (5 y 50) al menos publican el lado SMTP | **no**: en REST no hay cifra de concurrencia. En SMTP el proveedor publica el **rechazo sin el número**: «421 Too many concurrent SMTP connections» y ninguna cantidad [SE-95, SE-158]. Es el caso inverso de Postmark, SendGrid y MailerSend, que sí publican la cifra SMTP (10, 10.000 y 5/50) aunque Postmark reconozca no aplicarla. Falta el dato, no el canal | **X·hechos**: `"There are no concurrent connection or simultaneous request limits."` [MG-53], y ninguna otra fuente la contradice [MG-128]. **Única columna de la tabla con respuesta a esta X**: el dato existe y lo que falta es sitio en el esquema, que no serializa concurrencia | **no**: concurrencia no publicada, ninguna cifra en `fundamentals/` ni en `outbound-email/` [MC-100]. Lo más cercano es de SMTP y tampoco trae número: `"simultaneous and subsequent connections are permitted"` [MC-64] |
| PI-B01 | P (Q6) | **parcial**: el plan sí, el precio no. Starter llega a 100 000/mes [BR-42] y su deslizador tiene marca de 40k [BR-09], así que la suscripción más barata para 40 000 es un escalón de Starter; de esa escalera los hechos solo cifran los extremos, `"$9.00"` … `"$82.00"` [BR-09], y lo mismo en Standard, `"$18.00"` … `"$429.00"` [BR-10]. Professional arranca en 150 000 por 499 USD [BR-07, BR-04]. El motor, que solo lee el escalón de entrada serializado, responde **Professional 499 USD** en dos filas —alias `general` (39 s) y `advanced` (19 s)— y deja `free`, `starter` (9 USD) y `standard` (18 USD) en `unreachable` con la etiqueta `rate_limit`, cuando lo que falla es la cuota. Con los cinco planes devuelve **HTTP 400**, `could not convert string to float: 'custom'`, por el precio de Enterprise [BR-05] | **sí [sandbox]**: para 40.000 correos al mes el más barato es **à la carte: 0,00 de suscripción + 40.000 × $0.10/1.000 = 4,00 USD** [SE-15, SE-16, SE-19, SE-02 🟢]; Essentials 0,00 + $0.16/1.000 = 6,40 [SE-03 🟢, SE-10]; Pro 105 + 8,80 = 113,80 [SE-04 🟢, SE-11]; Enterprise 500 + 9,20 = 509,20 [SE-05 🟢, SE-12]. **Ninguna de esas cuatro cifras sale del fichero** (no en YAML): el precio por destinatario no cabe en v0.3 y está en `not_found` [SE-47, SE-168]. El motor responde 200 con todos los planes y devuelve `0,00 · 0,00 · 105 · 500`, que **son las suscripciones y no el precio de enviar** (`PI-B01_ses.json`): publicarlo a secas afirma que 40.000 correos por SES cuestan 0,00 USD. Y los cuatro salen `unreachable: true` con `unreachable_reason: rate_limit`, cuya causa real es la cuota: 200/día son 6.000 al mes [SE-50 🟢] | **sí**: 40 000/mes → Foundation $35 [MG-04, MG-38] < Basic $15 + 30 000 × $0.0018 = **$69** [MG-03, MG-37, MG-98] < Scale $90 [MG-05]; Free inalcanzable [MG-33, MG-34]. Motor: los mismos tres importes, ningún plan `custom` ni ningún rate vacío, y `free` `unreachable` con etiqueta `rate_limit` — que es etiqueta del motor, porque el caudal es idéntico en los cuatro planes [MG-64] y lo que la deja fuera es la cuota. Los tres de pago dan el **mismo** `time_to_capacity`, 26 s, por la misma razón. El veredicto vale para los tramos mínimos: la escalera del selector reprecia dentro del plan [MG-07, MG-08, MG-102] | **sí** (🟡): 40.000 correos al mes son **dos bloques, $40** —25.000 por bloque [MC-25] y $20/bloque en el tramo de 1 a 20 [MC-04, MC-11 🟡]— y no hay alternativa que comparar: un solo plan [MC-02], sin sobrecoste [MC-84] y con la franquicia demo inalcanzable a ese volumen [MC-29, MC-31]. La cifra está **incompleta y el esquema no sabe decirlo**: el transaccional solo existe como complemento de una cuenta Mailchimp Standard o Premium de pago [MC-16], cuyo coste no es capacidad y no se modela. Motor: `HTTP 500 {"detail": "float() argument must be a string or a real number, not 'NoneType'"}` en las dos llamadas, con y sin `plan_names` (**DV-02**) |
| PI-B02 | P (Q7) | **parcial**: con 50 USD, el escalón de Starter que cabe está entre el de 5 000 y el de 100 000 y **no tiene precio publicado** [BR-09]. Lo cifrado es esto: el Free acumula 300×30 = 9 000/mes sin pagar [BR-62, BR-30], y el prepago da 5 000 por 32 USD y 10 000 por 59 USD, que ya no cabe en 50 [BR-27]. Motor: `free` **9 300**, `starter` **6 000**, `standard` **6 000**; `professional` sale con 151 000 y 152 000 sin marcar que sus 499 USD no son asequibles. El orden del motor es el hallazgo: **el plan gratuito da más correos al mes (9 300) que el primer plan de pago (6 000)** | **sí [sandbox]**: con 50 USD al mes, **6.001 correos en los cuatro planes** (`PI-B02_ses.json`), que es 30 × 200 más la ráfaga de 1. **El dinero no es la restricción**: a la tarifa à la carte 50 USD compran 500.000 destinatarios ($0.0001 cada uno [SE-16, SE-19]) y en Essentials 312.500 [SE-10], pero el estado declarado solo deja enviar 6.001 [SE-50 🟢]. El presupuesto no expande nada porque no hay `overage_cost` [SE-145]. Pro y Enterprise quedan además fuera del presupuesto por la suscripción (105 y 500 > 50) [SE-04 🟢, SE-05 🟢] y el motor no lo marca. Primera API del catálogo donde la respuesta a «¿cuántos correos por X dinero?» la fija la capacidad y no el precio | **sí**: con $50 al mes → Foundation **61 538** correos (50 000 + $15/$0.0013) [MG-04, MG-38, MG-99] > Basic **29 444** (10 000 + $35/$0.0018) [MG-03, MG-37, MG-98] > Free 3 000 [MG-34 🟡]; Scale no es asequible, $90 > $50 [MG-05]. Motor: 63 038,46 / 30 944,44 / **3 100** / 101 500, cada uno con la ráfaga inicial sumada. Dos observaciones del motor: no marca inasequible a Scale, y devuelve **3 100 en Free, cien por encima de su propia cuota mensual de 3 000**, porque acumula la diaria treinta veces sin aplicar la mensual como techo — que es F-38 [MG-161] visto desde el motor | **sí [demo]** (🟡): **18.000 correos**, y los pone el caudal, no el dinero. Con $50 se compran dos bloques —$40, 50.000 de cuota [MC-04, MC-25]— y sobran $10, porque el tercero cuesta $60; pero la cuenta de pago que los compra no tiene caudal publicado [MC-49, MC-95]. Con los 25 correos/hora de la cuenta de prueba, 25 × 720 h son 18.000 [MC-42], y ese tope dejaría sin enviar 32.000 de la cuota, cuyo saldo no se arrastra: `"Los correos electrónicos no utilizados de un bloque no se transfieren de un mes a otro"` [MC-26 🟡]. Para la cuenta de pago la respuesta queda sin cifra. Motor: `/quotas` sí contesta, HTTP 200 con la fila `[demo]` y las dos cuotas concatenadas —25.000/30día y 500 con `period` vacío—, y `/capacity-at` cae con `HTTP 500 {"detail": "float() argument must be a string or a real number, not 'NoneType'"}` (**DV-02**) |
| PI-B03 | P (Q10) | **sí** (degenerada): no hay sobrecoste que comparar. Ninguna fuente publica precio de exceso en ningún plan y la de precios lo niega [BR-147]; en los de pago ni siquiera se documenta qué ocurre al agotar el volumen [BR-148]. La única vía para 12 000 es subir de escalón, y el de 15k o 20k de Starter lo cubre [BR-09, BR-33], con precio no cifrado. Motor: solo `professional` 499 USD alcanzable; `starter` (9 USD) y `standard` (18 USD) en `unreachable` por `rate_limit`, cuando la causa es la cuota de 5 000 | **sí (degenerada) [sandbox]**: la pregunta no tiene sus dos opciones, porque **SES no tiene sobrecoste** —no hay cuota de correos incluida de la que excederse [SE-143, SE-145]— y tampoco tiene «siguiente plan» que dé más volumen. Lo que cambia al subir de plan es la **tarifa por correo, y sube**: 12.000 correos cuestan 1,20 USD à la carte, 1,92 en Essentials, 107,64 en Pro (105 + 2,64) y 502,76 en Enterprise (500 + 2,76) [SE-15, SE-10, SE-11, SE-12, SE-04 🟢, SE-05 🟢], ninguna cifra en el YAML [SE-168]. Motor: `a_la_carte` **0,00** `[sandbox]`, con la misma reserva que B01 (`PI-B03_ses.json`). Y a 200/día, 12.000 al mes tampoco son alcanzables [SE-50 🟢] | **sí**: 12 000/mes → Basic $15 + 2 000 × $0.0018 = **$18.60** [MG-03, MG-37, MG-98] < Foundation $35 [MG-04] < Scale $90 [MG-05]. Gana el sobrecoste. Motor: 18,6 < 35 < 90, `free` `unreachable`. Con un solo tramo de sobrecoste en Basic [MG-102], el resultado no depende de la escalera | **sí** (🟡, degenerada por una razón nueva): 12.000 correos al mes caben en **un bloque, $20** [MC-04, MC-11 🟡, MC-25]. La pregunta compara el sobrecoste contra el plan siguiente y en Mailchimp **no existe ninguno de los dos términos**: no hay sobrecoste [MC-84, MC-27] ni plan al que subir [MC-02]; lo que hay es comprar otro bloque del mismo producto [MC-85]. En Resend y SendGrid se degenera porque el plan barato cubre; aquí, porque la alternativa no existe. A 25 correos/hora, 12.000 son 480 h = 20 días, y caben en el mes [MC-42]. Motor: `HTTP 500 {"detail": "float() argument must be a string or a real number, not 'NoneType'"}` (**DV-02**) |
| PI-B04 | D | **parcial**: la parte del canal API sí — Free 300/día [BR-08, BR-62] y el mismo caudal de envío que los de pago, porque el tramo General cubre los cinco tipos de cuenta [BR-81, BR-82]. Y **sin tarjeta**: `"forever free, no credit card required"` [BR-30]; con 9 000 correos al mes es el gratuito más grande del catálogo. Lo que no está en el canal: el estado de aprobación previo —`"Once we approve your account for sending"` [BR-16], con código de error propio `account_under_validation` [BR-97]—, cuyos topes y disparador no se publican y van a `not_found` [BR-176]; y las features, que son canal web: un solo usuario [BR-66], logo de Brevo salvo add-on de 9 USD/mes [BR-39], sin IP dedicada ni A/B testing [BR-67] | **parcial [sandbox]**: la parte de límites se responde y la de «gratis» no. **No hay plan gratuito modelado**: la FAQ lo ofrece en presente, el blog del 21 de julio de 2026 lo declara retirado para clientes nuevos y la página de precios no lo menciona [SE-41, SE-42, SE-43, SE-172; DISC-18]. Se empieza **sin elegir**: las cuentas nuevas caen en Essentials desde esa misma fecha [SE-20] y la cuenta del proyecto lo confirma, `"CurrentPlan": "ESSENTIALS"` sin haberlo pedido [SE-22, SE-174]. La suscripción es 0,00 [SE-03 🟢] pero se paga desde el primer correo [SE-16, SE-19]. Lo que limita es el estado: 200/24 h [SE-50 🟢], 1 req/s [SE-80 🟢], entrega solo a identidades verificadas [SE-184] y las operaciones de alta e importación de la lista de supresión deshabilitadas [SE-170; DISC-04]. Las features son del canal web [features.md] | **parcial**: la cuota y el caudal salen del fichero —100/día y 3 000/mes [MG-33 🟡, MG-34 🟡], sin sobrecoste [MG-101], el mismo caudal que los planes de pago [MG-64]— y lo demás es canal web: 1 dominio [MG-22], 1 usuario [MG-25], 1 ruta de entrada [MG-26], 2 claves [MG-24], 1 día de retención [MG-18] y sin retención de mensajes [MG-20, MG-21]. Y el límite que de verdad decide no es ni cuota ni caudal: el Free **no puede enviar a nadie** salvo a direcciones autorizadas, `"Free accounts are for test purposes only"`, 403 **medido** [MG-49], con la lista de autorizados sin publicar [MG-120] | **parcial [demo]**: sí se empieza gratis, y el escalón gratuito **no es un plan, es el alias `demo`**: 500 correos de franquicia que no caduca [MC-18, MC-29, MC-30 🔴], 25 correos/hora [MC-42…MC-45], una sola vez por cuenta [MC-32], 30 días de retención [MC-37], sin seguimiento de clics [MC-38] y 100 correos entrantes al día [MC-35]. Lo que limita de verdad está fuera del canal API: hace falta una cuenta Mailchimp activa, `"can be free or paid, but cannot be paused or have a billing or compliance hold"` [MC-34]; el producto es complemento de Standard o Premium **de pago** [MC-16] y `"El plan Essentials no es elegible"` [MC-15]; y sin dominio verificado con DKIM y DMARC no sale ni un correo [MC-71], medido —todo devuelve `"status":"rejected"` con `"reject_reason":"unsigned"` [MC-124]— |
| PI-B05 | P (Q5) | **sí**: el caudal lo permite con holgura —1 000 × 3 600 = 3 600 000 correos/h ≥ 20 000 con k = 1 [BR-82]— y lo decide la cuota. Free no (300/día [BR-62]); Starter y Standard no en su escalón de entrada (5 000/mes [BR-07, BR-34]); Professional sí (150 000/mes [BR-07]). Motor: **NO** en free (primera violación a los 54 s), starter y standard (a los 900 s), las tres por `quota_exceeded`; **YES** en professional con los dos aliases | **sí [sandbox]**: **NO en los cuatro planes**, `rate_exceeded`, con `plan_capacity` 1,0 contra `demand_capacity` 5,56 y **primera violación en t = 0** (`PI-B05_ses.json`). Un pico de 20.000 correos en una hora son 5,56 correos por segundo y el caudal declarado es 1 petición por segundo [SE-80 🟢]. Ningún plan lo arregla, porque el caudal **no es variable del plan** sino del estado [SE-127 🟢, SE-137]. **Primera API del catálogo donde la demanda viola en el instante cero, y por el caudal**: en MailerSend el rate también cortaba, pero a los 21,6 s. En producción el caudal no se publica [SE-153 🔴], así que fuera del entorno de pruebas la pregunta no tiene respuesta | **sí**: pico de 20 000 en 1 h. El caudal sobra —1 500/s × 3 600 = 5 400 000 ≥ 20 000 con k = 1 [MG-50]— y decide la cuota: **NO** en Free (100/día [MG-33]) y en Basic (10 000/mes [MG-37]), **YES** en Foundation [MG-38] y Scale [MG-39]. Motor: `quota_exceeded` con primera violación a 18 s en Free y a 1 800 s en Basic, `YES` en los otros dos. Sin `max_budget` el motor no expande la cuota de Basic con su sobrecoste [MG-98], como sí hace en A06: con él, Basic sostendría el pico pagando $18 de exceso | **sí [demo]**: **no, y por 800 veces**. El pico pide 20.000 correos en una hora y el caudal publicado da 25 [MC-42]; no hay plan al que subir [MC-02] ni cifra de caudal para la cuenta de pago [MC-49, MC-95]. Y k no lo arregla, porque el caudal está en correos [MC-46]: es la única columna donde agrupar destinatarios **no mueve la respuesta a un pico**. El veredicto se lee además distinto que en las otras cuatro, porque el exceso **no se rechaza**: `"If you exceed your quota, unsent messages will be placed in the backlog"` [MC-47] y `"We'll begin processing the backlog in the next hour"` [MC-48], con un 5 % del caudal reservado para los mensajes `important` [MC-50]. El pico entra; lo que tarda 800 horas es salir. Motor: `HTTP 500 {"detail": "float() argument must be a string or a real number, not 'NoneType'"}` (**DV-02**) |
| PI-C01 | H | **parcial**: aporta el plan y una horquilla, no el precio. Starter tiene marca de 50k en su deslizador [BR-09] y llega a 100 000 [BR-42], así que cubre los 50 000 por algo entre 9 y 82 USD, sin cifrar [BR-09]; Standard, entre 18 y 429 [BR-10]. La única cifra publicada para ese volumen es el prepago, `"$165.00"` por 50 000 [BR-27], que no es una suscripción y es la vía más cara. Frente a SG 19,95 < RS 20 < MS 35 < PM 55, Brevo no entra con número | **sí**: para 50.000 correos al mes SES aporta **5,00 USD** — à la carte, 50.000 × $0.0001 por destinatario, sin suscripción [SE-15, SE-16, SE-19, SE-02 🟢]; Essentials 8,00 [SE-10]; Pro 105 + 11,00 = 116,00 [SE-04 🟢, SE-11]. Comparación: **SES 5,00 < SG 19,95 < RS 20 < MS 35 < PM 55**, un orden de magnitud por debajo del catálogo. Dos reservas que la celda no esconde: la cifra sale de los hechos y **no del fichero**, que devolvería 0,00 [SE-47, SE-151, SE-168]; y con la capacidad declarada 50.000 al mes son inalcanzables, 200/día son 6.000 [SE-50 🟢] | **sí**: 50 000/mes → Foundation $35 cubre justo la cuota [MG-04, MG-38]; por sobrecoste, Basic $15 + 40 000 × $0.0018 = $87 [MG-03, MG-98]; Scale $90 [MG-05]. Comparación: SG $19.95 < RS $20 < **MG $35 = MS $35** < PM $55. Empata con MailerSend en el importe y por vía distinta: allí es la cuota del plan, aquí la del tramo mínimo de una tarjeta con escalera [MG-07, MG-09] | **sí** (🟡): 50.000 correos al mes son dos bloques exactos, **$40** [MC-04, MC-11 🟡, MC-25]. Comparación con las cuatro columnas de la tabla: SG $19.95 < RS $20 < MS $35 < **MC $40** < PM $55. Dos reservas: el importe **no incluye la cuenta Mailchimp de pago** que el producto exige por debajo [MC-16], y esa cuenta de pago no tiene caudal publicado [MC-49, MC-95]: el único, 25 correos/hora, es el de la cuenta de prueba [MC-42], con el que 50.000 correos tardarían 2.000 h, 83 días |
| PI-C02 | H | **sí**: Starter, primer tier de pago, 5 000 correos por 9 USD [BR-07, BR-02] = **556 por dólar**. Es el peor del catálogo: SG 2 506 ≈ RS 2 500 > MS 714 > PM 667 > **BR 556**. Dos matices que solo Brevo obliga a hacer: el precio unitario no es lineal —el escalón de 100k de Starter cuesta 82 USD [BR-09], 1 220 por dólar, y el unitario no se publica [BR-174]— y **Standard cobra 18 USD por la misma cuota de entrada de 5 000 que Starter cobra a 9** [BR-03, BR-34 frente a BR-02, BR-33] | **sí [à la carte]**: el eje «primer tier de pago» **no tiene instancia con volumen incluido**, así que el cociente cuota/precio de las otras cuatro no se puede construir: numerador cero en los cuatro planes [SE-143, SE-145]. La magnitud homóloga es el precio unitario, y da **10.000 correos por dólar à la carte** ($0.10/1.000 [SE-15, SE-16]) y 6.250 en Essentials ($0.16/1.000 [SE-10]). Comparación: **SES 10.000 > SG 2.506 ≈ RS 2.500 > MS 714 > PM 667**. En SES la capacidad por dólar **no depende del plan**; lo que depende del plan es su empeoramiento, porque la tarifa sube al subir de plan: 0,10 < 0,16 < 0,22 < 0,23 por 1.000 en el primer tramo [SE-15, SE-10, SE-11, SE-12] | **sí**: primer tier de pago, Basic 10 000/$15 = **667 correos por dólar** [MG-37, MG-03]. Es la **misma cifra exacta que Postmark Basic**, y por la misma aritmética: $15 de base y $1.80/1 000 de sobrecoste en los dos. SG 2 506 ≈ RS 2 500 > MS 714 > MG 667 ≈ PM 667 | **sí** (🟡): **1.250 correos por dólar** en el único tier de pago, 25.000/$20 [MC-25, MC-04, MC-11 🟡]. SG 2.506 ≈ RS 2.500 > **MC 1.250** > MS 714 > PM 667. Es la única columna cuyo cociente **se mueve dentro del mismo producto**: en el último tramo de la escalera son 25.000/$10 = 2.500 por dólar [MC-09], que empataría con Resend. Y el divisor está incompleto, por la cuenta base [MC-16] |
| PI-C03 | D | **sí**: publica, y es la que más publica. Página dedicada con tabla por endpoint y tres tramos —General 1 000 RPS / 3 600 000 RPH en el envío, Advanced 2 000, Extended 6 000 [BR-79, BR-80, BR-81, BR-82, BR-84, BR-85]—, tres cabeceras documentadas [BR-90, BR-91, BR-92] y hasta un ejemplo de reparto [BR-87]. El contraste es el hallazgo: ese régimen **no existe en el contrato máquina**. Ni `"rate limit"`, ni RPS, ni RPH, ni `x-sib` aparecen una sola vez en las dos specs, comprobado sobre 145 561 y sobre 1 162 191 bytes [BR-105, BR-106, BR-165], y el 429 no está declarado en el endpoint de envío [BR-164] | **sí [sandbox]**: publica el caudal **del estado de pruebas y no el de producción**. El de pruebas sale en cuatro superficies que coinciden: doc [SE-81 🟢], Service Quotas con código `L-CDEF9B6B` [SE-83 🟢], panel [SE-99 🟢] y la propia API, `"MaxSendRate": 1.0` [SE-76 🟢, SE-87 🟢]. **Es la primera API del catálogo que publica su rate por la API misma.** El de producción es `not_found` con fórmula, «varies based on your specific use case» [SE-153 🔴, SE-104]. Y **no publica ninguna cabecera de caudal**: cero apariciones de `ratelimit`, `retry-after` y `remaining` sobre el contrato máquina, con la enumeración de miembros `"location": "header"` vacía [SE-91] (O-01). La vía documentada es consultar `GET /v2/email/account` [SE-128] | **sí**, y con el matiz más caro de la tabla: **publica**, pero la única cifra está en una página escrita para asistentes de IA y blindada contra las herramientas que un asistente usaría [MG-50, MG-51]; la documentación de desarrollador describe cabeceras y 429 y **no publica ningún umbral** [MG-54 🔴, MG-55, MG-57], y las dos son fuentes oficiales del mismo dominio (DISC-01, abierta). Lo publicado acota por IP de cliente [MG-51], no por cuenta ni por plan [MG-106, MG-113], y el caudal que el fichero usa para el envío es **medido** [MG-58] | **sí [demo]**: publica el caudal del estado de prueba y **no el de pago**. Los 25 correos/hora están en tres superficies documentales y una medición [MC-42…MC-45]; para la cuenta de pago no hay ninguna cifra y el proveedor lo dice por escrito, `"an account that sends 1 million messages per week and an account that sends 100 messages per week could both have excellent reputations, but their hourly quotas will be very different."` [MC-49, MC-95]. Ni caudal general de la API REST [MC-99], ni cabecera de rate limit en ninguna página ni en el sondeo [MC-59], ni 429 en la tabla oficial de errores [MC-58, MC-101]. El único caudal con cifra de toda la API es de un endpoint, `"This method may be called up to 20 times per minute."` [MC-55, MC-56]. Y lo publicado está en **correos**, no en peticiones [MC-42, MC-46] |
| PI-C04 | H | **sí**: al caudal del tramo General, 100 000/1 000 = **100 s** con k = 1 [BR-82 🟡]; 50 s en Advanced (2 000 RPS) [BR-84] y 16,7 s en Extended (6 000) [BR-85]; con k = 2 000, 0,05 s [BR-107]. A k = 1 por caudal: SG 10 s < PM 20 s < **BR 100 s** < RS 2,78 h < MS 13 h 53 min. Pero solo Professional tiene cuota para 100 000 en un mes [BR-07]; en el escalón de entrada de Starter el motor da 570 día 4 s | **sí [sandbox]**: 100.000 correos en **499 d 3 min 19 s** (k = 1) o **499 d 3 s** (k = 50), con la cuota de 200/día mandando (`PI-A06_ses.json`). Solo por caudal, sin cuota, serían 100.000 s = **27 h 46 min 40 s** a 1 req/s con k = 1 [SE-80 🟢]. Las dos cifras dejan a SES el último del catálogo por los dos lados. A k = 1 y solo por rate, con el valor que cada columna declara en su propia A06: SG 10 s < PM 20 s < RS 2,78 h < MS 13 h 53 min < **SES 27 h 47 min**. Contando la cuota, 499 días frente a los 100 días peores de MailerSend. La comparación es posible en las cinco, pero en SES es del estado y no del plan, y en producción no hay cifras que comparar [SE-152, SE-153 🔴] | **sí** (🟡): 100 000 correos en **66,7 s** con k = 1 al caudal de cuenta [MG-50], o en menos de un segundo con k = 1 000 [MG-69]; motor `1min6s` y `0s` con presupuesto. A k = 1 por rate, Mailgun se coloca entre Postmark y Resend: SG 10 s < PM 20 s < **MG 1 min 7 s** < RS 2,78 h < MS 13 h 53 min. Con la cuota dura de Basic, 270 días [MG-37] | **sí [demo]**: 100.000 correos en **166 días 16 h**, la misma cifra con cualquier k [MC-42, MC-46]. A k = 1 por rate: SG 10 s < PM 20 s < RS 2,78 h < MS 13 h 53 min < **MC 166 d 16 h**, 288 veces más lento que la penúltima. (El 10 s de SendGrid es el de su propia celda A06 para k = 1; la celda C04 de MailerSend escribe ahí 0,01 s, que es su valor con k = 1 000 — incoherencia de la tabla actual, no de esta columna.) Y es la única de la tabla que **no mejora al subir k**: en las otras cuatro el factor de destinatarios divide el tiempo —hasta 1.000 en SendGrid [SG-57]—, aquí no divide nada |
| PI-C05 | X | **no**: sin operación de diff | **no**: sin operación de diff en el motor, como en las otras siete | **no**: sin operación de diff | **no**: sin operación de diff |
| PI-D01 | P (Q5) | **sí**: en Starter manda la cuota, y por mucho. 5 000/30 día frente a 1 000 RPS [BR-07, BR-82 🟡]: el caudal entregaría 2 592 000 000 en la misma ventana, **518 400×** la cuota. t_min 5 s a mano; motor **4 s**, por la ráfaga del instante cero | **sí [sandbox]**: se agota antes **la cuota**, y por 432 veces. La cuota es 200 correos/día y el caudal 1 req/s = 86.400 peticiones/día: 86.400/200 = 432× de margen a k = 1 [SE-50 🟢, SE-80 🟢]. Motor: cuota `200/1día` `[sandbox]` y t_min **3 min 19 s** (`PI-D01_ses.json`); a mano 200 s menos la ráfaga de t = 0. Es el margen **más estrecho del catálogo** entre cuota y caudal —Postmark Basic tenía 1.296.000×, MailerSend Hobby 1.037×— y se estrecha porque el caudal es el más bajo medido, no porque la cuota sea grande. En el lote la atadura al mismo alias de caudal **es inferencia, no literal** [SE-171 🟡, DISC-05] | **sí** (🟡): Basic, la **cuota**, y por un margen de 388 800× —10 000/mes [MG-37] frente a 1 500 req/s [MG-50]—. Motor: t_min **6 s** para agotarla entera con k = 1. Leído al revés: la cuota mensual del primer plan de pago se agota en menos de siete segundos al caudal publicado. El caudal que entra en la cuenta es el de cuenta, no el medido en el envío [MG-58] | **sí [demo]** (🟡): la **velocidad**, con un resultado que el catálogo no había dado: al caudal publicado **la cuota mensual no se puede agotar**. 25 correos/hora son 18.000 en 30 días [MC-42], por debajo de los 25.000 del bloque [MC-25], y lo que no sale no se arrastra [MC-26 🟡]: el 28 % del bloque caduca sin enviarse. El margen es **0,72×**, el segundo por debajo de 1 del catálogo tras el 0,43× de MailerSend bajo revisión [MS-48], y el primero al que **k no puede dar la vuelta**. Agotar el bloque entero costaría 1.000 h = 41 d 16 h. Motor: `/quotas` HTTP 200 con la fila `[demo]` y las dos cuotas concatenadas, 25.000/30día y 500 con `period` vacío —**DV-05 un nivel más arriba**, porque la fila de la cuenta de prueba afirma tener además el bloque de pago—, y `/min-time` con `HTTP 500 {"detail": "float() argument must be a string or a real number, not 'NoneType'"}` (**DV-02**) |
| PI-D02 | P (Q5) | **sí**: por encima de 1 000 × 2 592 000 = **2 592 000 000** correos/mes con k = 1 [BR-82 🟡]. El mayor escalón publicado es 10M en Professional [BR-42], a 259× de distancia, y ni con Extended (6 000 RPS, solo Enterprise [BR-85]) se acerca nadie. Motor: `rates: [1000 requests/1s]` y capacidad a 1 mes con presupuesto de 10⁹ = **6 000** — la cuota dura manda, porque sin `overage_cost` el presupuesto no la expande [BR-147] | **sí [sandbox]**: el caudal solo sería el límite por encima de 1 × 2.592.000 = **2.592.000 correos al mes** con k = 1, o 129.600.000 con k = 50 [SE-80 🟢]. **Ningún plan publica volumen con el que comparar ese umbral** [SE-143], así que la premisa de la pregunta no se puede instanciar sobre el eje que nombra. Con lo declarado, la cuota manda con 432× de margen y el motor lo mide: `rate 1/1s` y capacidad al mes **6.001** aun con presupuesto infinito (`PI-D02_ses.json`), porque sin `overage_cost` el presupuesto no expande la cuota [SE-145] | **sí** (🟡): por encima de 1 500 × 2 592 000 = **3 888 000 000** correos/mes con k = 1 [MG-50]. El mayor peldaño publicado son 2 500 000 (Scale) [MG-08], a **1 555 veces** de distancia: la mayor de la tabla. Motor: `rates: [1500/1s, 80000/10s]`, los dos a la vez sobre el mismo endpoint, y capacidad a 1 mes con presupuesto enorme de **3 888 001 500** (el caudal por el mes más la ráfaga). Con el caudal medido del envío el umbral subiría a 2,07·10¹⁰ [MG-58]. Y el umbral es **por IP de cliente** [MG-51], así que una cuenta con N salidas lo multiplica por N [MG-156]: la pregunta no tiene respuesta única por cuenta | **sí [demo]** (🟡): a partir de **18.000 correos al mes**, que es R·W con R = 25 correos/hora y W = 30 días [MC-42, MC-26 🟡]. La cifra es **menor que la cuota del propio bloque**, 25.000 [MC-25]: el rate es el límite efectivo desde el primer bloque comprado, no desde un volumen alto. En las cuatro columnas anteriores el umbral cae entre 5,2·10⁶ (MailerSend) y 2,6·10¹⁰ (SendGrid) correos/mes y ningún plan lo alcanza; aquí lo cruza el producto de entrada. Y **R·W no se multiplica por k**, porque el caudal está en correos [MC-46]: el techo son 18.000 sea cual sea el agrupamiento. Motor: `/rates` HTTP 200 con `{"value": 25.0, "unit": "emails", "period": "1h"}` y alias `demo` —única fila de caudal del catálogo cuya unidad no es `requests`—, y `/capacity-at` con `HTTP 500 {"detail": "float() argument must be a string or a real number, not 'NoneType'"}` (**DV-02**) |
| PI-D03 | P (Q9) | **sí**: k* = Q/(R·W) = 5 000/2 592 000 000 = **1,93·10⁻⁶** en Starter [BR-07, BR-82 🟡] → ningún k ≥ 1 iguala los dos límites, y el tope de destinatarios por petición (2 000 [BR-107 🟡]) queda nueve órdenes por encima del equilibrio. Motor: umbral de agotamiento 4 s con k = 1 y 0 s con k = 1 000 y k = 2 000 | **sí [sandbox]**: k\* = Q/(R·W) = 200/86.400 = **0,0023** → ningún k ≥ 1 iguala los dos límites [SE-50 🟢, SE-80 🟢]; el tope de 50 destinatarios por petición [SE-106 🟢] queda cuatro órdenes por encima del punto de equilibrio. Motor: 3 min 19 s (k = 1), 7 s (k = 26) y 3 s (k = 50), los tres `[sandbox]` (`PI-D03_ses.json`). Mismo signo que las cuatro anteriores: la cuota se agota mucho antes que el caudal | **sí** (🟡): k* = Q/(R·W) = 10 000/20 736 000 000 = **4,8·10⁻⁷** en Basic con el caudal medido del envío, el de la tabla de (b) [MG-37, MG-58 🟡]; con el 1 500/s por IP documentado sería 10 000/3 888 000 000 = 2,6·10⁻⁶ [MG-50 🟡, DISC-01] → ningún k ≥ 1 iguala cuota y caudal, y el tope de destinatarios es 1 000 [MG-69]. Motor: umbral de agotamiento 6 s con k = 1 y 0 s con k = 500 y k = 1 000. Pero Mailgun sí tiene un k* ≥ 1, **entre otro par de límites**: la misma ventana lleva dos contadores, 80 000 peticiones y 2 000 000 de destinatarios [MG-58, MG-59], y con **k = 25** los dos caen a la vez [MG-159]. Ese segundo contador no cabe en el fichero: el esquema admite un solo caudal por nodo [MG-108] | **sí [demo]**: **ninguno, y por una razón que no se había visto**. La pregunta presupone que el proveedor cobra por correo y limita por petición; Mailchimp cobra por correo [MC-25] y **limita por correo** [MC-42, MC-46], así que la ecuación Q = R·W·k no tiene incógnita: k no aparece en ella. La aritmética que daría k\* = 25.000/18.000 = 1,39 —el primer k\* ≥ 1 del catálogo— solo vale si el caudal está en peticiones, y aquí no lo está. En las otras cuatro columnas la respuesta «ningún k ≥ 1» sale de que k\* vale entre 7,7·10⁻⁷ y 0,0019; aquí sale de que la pregunta se queda sin variable. Motor: `HTTP 500 {"detail": "float() argument must be a string or a real number, not 'NoneType'"}` (**DV-02**) |
| PI-D04 | D | **sí** (🟡): **sube, y es la primera del catálogo en la que sube el caudal del endpoint de envío**. General 1 000 RPS para los cinco planes, Advanced 2 000 en Professional y Enterprise, Extended 6 000 en Enterprise [BR-81, BR-82, BR-84, BR-85], y la Datasheet lo serializa con aliases por plan. El 🟡 es DISC-15: dentro de la misma página, la viñeta que restringe Advanced y el distintivo `"Available in"` que encabeza su propia tabla se contradicen [BR-103b], y no se publica si el tramo se activa al contratar o hay que pedirlo [BR-160] | **sí [sandbox]**: **no sube, y además no es del plan**. Los cuatro planes devuelven el mismo `rate 1/1s` y la misma cuota `200/1día`, todos bajo el alias `sandbox` [SE-137; `PI-D02_ses.json`, `PI-B02_ses.json`]. Es la respuesta más limpia del catálogo a esta pregunta: en las otras cuatro se apoya en que el proveedor publica un valor único, y aquí el motor la ejecuta plan a plan y devuelve la misma cifra cuatro veces. Lo que mueve el caudal es el estado de la cuenta —salir del entorno de pruebas [SE-82, SE-52]— y esa segunda cifra no se publica [SE-153 🔴] | **sí** (🟡): **no sube**. Ninguna fuente atribuye caudales por plan y la misma clave se referencia desde los cuatro [MG-64]; la única cifra publicada no lleva condición de plan [MG-50] y si varía es hueco declarado [MG-113]. La respuesta descansa en ausencia de mención, no en una frase del proveedor, y el valor del envío se midió sobre una cuenta **Free** [MG-58, MG-64]. Lo que sí varía es el arranque de una cuenta nueva, y va con el estado, no con el plan [MG-48] | **sí**: no sube, porque **no hay planes que subir**. Uno solo [MC-02], y el tramo de volumen mueve el precio y nada más: ninguna fuente ata un endpoint, una cuota ni un caudal a un tramo de bloques [MC-121]. Lo que mueve el caudal es el estado de la cuenta —`"Demo accounts are limited to a fixed hourly quota of 25 emails. Once you upgrade to a paid account, you'll be switched to the standard reputation and quota system."` [MC-42]— y la reputación dentro de él [MC-52, MC-53]; la cifra de ese estado no se publica [MC-49, MC-95]. Es el eje de plan **medido y declarado sin información** (E16 §3), no un hueco de cobertura |
| PI-D05 | D (era X hasta D-041) | **no**: no hay estados de reputación con cifra. Los tres tramos de caudal dependen del **tipo de cuenta**, es decir del plan [BR-81], no del comportamiento de la cuenta. Lo único parecido es un estado previo de aprobación —`"Once we approve your account for sending"` [BR-16], con su código de error `account_under_validation` [BR-97]—, cuyos topes y disparador no publica ninguna fuente, así que por D7 va a `not_found` [BR-176] | **parcial [sandbox]**: la mitad cualitativa sí, la cifra no. **Los límites son del estado de la cuenta y no del plan**: el entorno de pruebas da 200/día y 1 req/s [SE-50 🟢, SE-80 🟢], y al salir «varies based on your specific use case» [SE-61, SE-82]. Hay incremento automático con criterio publicado pero **sin porcentaje, escalón ni periodo** —«your daily email volume should regularly approach the daily maximum»— [SE-66, SE-155], un `EnforcementStatus` con tres valores, `HEALTHY` / `PROBATION` / `SHUTDOWN` [SE-134], y hasta un centinela de cuota ilimitada, `Max24HourSend: -1`, sin condiciones para alcanzarlo [SE-65, SE-154]. Falta lo que MailerSend sí da: la cifra del estado superior [SE-152, SE-153 🔴] | **parcial**: el literal contesta el «o» de la pregunta —`"gradually increases sending rates"` y `"increasing those rates as your sending reputation grows"` [MG-48]—, así que en Mailgun los límites **crecen con la reputación**. Falta todo lo que la haría legible en la Datasheet: ni estados, ni cifras, ni plazos [MG-119]; el artículo de soporte que cuantificaría el tope por hora de las cuentas nuevas devuelve 403 y no se ha rendido [MG-118]; y el umbral de 100 mensajes/hora de *account probation* que citan terceros no está en fuente oficial [MG-134]. Los únicos umbrales con cifra son de la política de uso aceptable —rebotes 5 %, quejas 0,08 %, bajas 1,4 %, bloqueos 20 % [MG-45]— y se aplican `"at our sole discretion"` [MG-46]: son política, no capacidad | **sí**: crecen con la reputación, y aquí es el **caso extremo, porque no hay plan del que puedan depender** [MC-151]. El literal lo dice entero: `"The number of messages you can send in a given time is determined by your pricing plan as well as your hourly quota, which is based on your sending reputation."` [MC-47]. La escala tiene nombres, `"Excellent, Good or Poor"` más `"Unknown"` al arrancar [MC-53]; también baja, `"…and Mailchimp Transactional will lower your hourly quota as a result."` [MC-52]; y el salto del estado de prueba al sistema de reputación está escrito [MC-42]. Medido en la cuenta propia: `"Reputation"` → `"Unknown"` y `"reputation":0`, que no son dos valores distintos [MC-54]. Lo que falta es la cifra —ninguna para el estado de pago [MC-49, MC-95]— y el umbral, como en MailerSend [MS-118]; a diferencia de MailerSend, aquí **ningún estado tiene caudal con número** salvo el fijo de la demo |
| PI-D06 | X | **X·hechos**: dos comportamientos distintos, uno por cada límite. Al caudal, 429 con `x-sib-ratelimit-limit/remaining/reset` [BR-86, BR-90, BR-91, BR-92]; **medido**, ese 429 llega **sin cuerpo**, sin `Content-Type` y sin `Retry-After`, 0 bytes [BR-117], y la ventana repone 0,426 s después del rechazo [BR-118]. La cabecera va por endpoint y no por éxito: llega en un 400 y no llega en dos 200 [BR-110, BR-111], lo que desmiente a la documentación [BR-93]. A la cuota, en el Free, ni 429 ni error: cola de 1 000 y descarte silencioso [BR-63] | **X·hechos**: rechazo, ni cola ni degradación. «If sending a message would exceed the daily maximum... your call to Amazon SES is rejected» y el mensaje se descarta, «does not queue the emails and send them later» [SE-68, SE-69, SE-77]. El error tiene **tres nombres**: `ThrottlingException` con 400 en la página monográfica [SE-89], `TooManyRequestsException` con 429 en la referencia de la operación [SE-88], y **ninguno en el contrato máquina de la v2**, donde la forma `ThrottlingException` no existe [SE-90] (DISC-07, DISC-08). Medido: 9 de 30 peticiones concurrentes devuelven 429 con `{"message": "Rate exceeded"}` y **ninguna trae `retry-after`** [SE-103, SE-181] (O-05). En SMTP llega como «454 Throttling failure» [SE-70]; en el lote el rechazo viaja **dentro de una respuesta correcta**, `ACCOUNT_THROTTLED` [SE-78] | **X·hechos**: 429 `"Rate limits exceeded. Retry as defined in response headers"` [MG-55], con `X-RateLimit-Limit`, `-Remaining` y `-Reset` en milisegundos Unix y `"Time windows may vary by API"` [MG-54]; **no hay `Retry-After`**, Mailgun usa nombre propio [MG-56]. Medido: las cabeceras **solo aparecen en un POST aceptado** —ni un GET ni un 403 las traen [MG-63]— y el 429 no se alcanzó, porque forzarlo son 80 000 peticiones en diez segundos [MG-67 🟡]. La ventana medida dura 9,85–9,87 s, no es rodante y se ancla en la primera petición [MG-60 🟡, MG-61, MG-62] | **X·hechos**, y es la única de la tabla cuya respuesta no es rechazo: es **cola**. `"If you exceed your quota, unsent messages will be placed in the backlog"` [MC-47] y `"Hourly quota exhausted - You've sent all the emails your hourly quota allows. We'll begin processing the backlog in the next hour."` [MC-48], sin descarte [MC-156], con un 5 % del caudal reservado para los mensajes marcados `important` [MC-50, MC-51]. La tabla oficial de errores **no tiene 429 ni 403** [MC-58, MC-101] y no hay cabecera de rate limit en ninguna página oficial ni en las respuestas del sondeo [MC-59]; el único 429 de la API es el de `/messages/search` [MC-55]. Medido: ~7.600 destinatarios en cola y los tres contadores del panel a cero dos horas después — **encolar no consume** [MC-130, MC-132] |
| PI-E01 | L | **sí** (matriz): los **salientes**, en los cinco planes, Free incluido —`"outbound webhooks"` en la respuesta de la página de precios [BR-13] y `"Webhook support"` en la del producto [BR-31]—; los **entrantes**, no: cruz en Free, Starter y Standard, marca en Professional y Enterprise [BR-21 🟡]. Cuántos admite cada plan no lo publica nadie, así que la respuesta es binaria y no numérica | **sí (matriz)**: **no hay webhooks en ningún plan**, y no por precio sino por diseño: los eventos salen por destinos —`CloudWatch`, `EventBridge`, `Kinesis Firehose`, `Pinpoint`, `SNS`— con cero coincidencias de `Webhook` y `Http` en las 116 acciones de la v2 [SE-132; features.md]. El comparador sí reparte funciones por plan, con `✓` e `"Add-on"` en las tres columnas de pago [SE-24, SE-25, SE-26, SE-27], y el plan gratuito **no existe como columna que instanciar** [SE-172]. Lectura sin instrumento, como las otras cuatro | **sí** (matriz): webhooks de eventos **incluidos en las cuatro columnas** (`cols: true`), sin condicionar a plan, con `"up to 3 URLs per event type"` [MG-27]. Es la única columna de la tabla cuyo plan gratuito no lleva recorte de webhooks por plan (PM no los declara en Free, RS 1 endpoint, SG 1, MS 1) | **sí** (matriz) **[demo]**: la matriz responde «no consta». El panel de la demo no expone los webhooks de eventos y la documentación sí da el endpoint, `"Add a new webhook"` (`POST /webhooks/add`) [MC-82]. **Ninguna fuente publica tope de webhooks** [MC-114, MC-144]: es la primera API del catálogo donde ningún tope de recursos está publicado. Y la pregunta no se puede condicionar a plan, porque no hay planes [MC-121] |
| PI-E02 | L | **sí** (matriz): **cualifica y pierde**. El add-on de IP dedicada es el más barato de los cifrados, `"$251.00"` `"per year per dedicated IP"` [BR-28] ≈ 20,92 USD/mes, pero solo existe en Professional [BR-23], que arranca en 150 000 correos/mes por 499 USD [BR-07, BR-04] y cuyo escalón de 250 000 no está cifrado en los hechos [BR-11]. Para 200 000/mes el suelo es ≈ 520 USD/mes, contra RS 190 y SG 199,95; PM y MS no son elegibles. El add-on barato con el peaje caro: comparar solo los 251 USD daría la respuesta al revés | **sí (matriz)**: **elegible sin umbral de volumen**, y la más barata. IP dedicada estándar `"$24.95 / month / IP"`, add-on en los tres planes y tarifa à la carte [SE-28; features.md]; para 200.000 correos al mes, 200.000 × $0.0001 = 20,00 de envío + 24,95 = **44,95 USD** [SE-16, SE-19]. Comparación: **SES 44,95 < RS 190 < SG 199,95**; PM (exige 300.000/mes) y MS (500.000/mes) no elegibles. SES es la **primera del catálogo sin requisito mínimo de volumen** para IP dedicada. Reservas: la IP administrada va incluida en Pro, que sale a 105 + 44 = 149 USD [SE-04 🟢, SE-11; features.md]; BYOIP exige 256 direcciones, 6.387,20 USD/mes [SE-31]; y 200.000 al mes son inalcanzables con 200/día [SE-50 🟢] | **no**: el precio a 200 000 correos/mes **no es determinable**. La feature sí está —acceso a IP dedicada desde el volumen de 50k en Foundation, incluida a partir de 100k+ en Scale, y add-on a $59/IP/mes en cualquier plan [MG-16]—, pero **200 000 no es una posición del selector**: las posiciones publicadas son 10 000, 50 000, 100 000, 250 000, 500 000, 750 000, 1 000 000, 2 500 000 y `"More"` [MG-06]. Y la mecánica del selector no está verificada: el provenance usa la escalera como dato y la ficha de la fuente la da por no comprobada con navegador [MG-07, MG-08], discrepancia abierta. Lo más cercano con cifra es Scale 250 000 a $215 con una IP incluida [MG-08, MG-16]. Falta: el importe del tramo de 200 000 | **sí** (matriz, 🟡): a 200.000 correos al mes, **$189.95** — ocho bloques a $20 [MC-04, MC-11 🟡, MC-25] más la IP dedicada, `"Agrega una IP exclusiva por $29.95 al mes (opcional)"`, **sin requisito de volumen mínimo publicado** [MC-17]. Con eso: **MC $189.95** < RS $190 < SG $199.95; PM y MS no elegibles por sus mínimos de 300.000 y 500.000 [PM-18, MS-108]. Gana por cinco céntimos, y las dos reservas se lo comen: el importe no incluye la cuenta Mailchimp de pago obligatoria [MC-16], y esa cuenta no tiene caudal publicado [MC-49, MC-95]: con los 25 correos/hora de la cuenta de prueba [MC-42], 200.000 correos tardarían 8.000 h, 333 días. Es la comparación más ajustada de la tabla, y la que peor aguanta lo que el esquema no serializa |
| PI-E03 | X | **X·hechos**: **el periodo lo fija el cliente**, 1 a 24 meses — el control del panel lleva `min="1"` y `max="24"`, con el aviso `"Transactional logs are stored only for a limited time…"` [BR-75, BR-76]. La página de precios dice `"unlimited log retention"` [BR-13], que no es una duración: DISC-10, resuelta a favor del panel. Medido solo en la cuenta Free, y los dos artículos del centro de ayuda que lo cifran devolvieron 403 [BR-173]. Único caso del catálogo en que el periodo lo pone el cliente y no el proveedor | **no**: **ninguna fuente registrada publica retención de registros**, ni por plan ni por cuenta. Lo más cercano es el archivado de Mail Manager, que es add-on en los cuatro y se tarifa por volumen y no por días, `"$2 per GB of emails ingested; $0.19 per GB per month for storage and search"` [SE-40; features.md]. Es la **primera API del catálogo sin respuesta a esta X**: las otras cuatro la tenían en los hechos (45, 30, 3–7 y 1–30 días). El dato no está en otro sitio del esquema: no está en ninguno | **X·hechos**: **tres** retenciones distintas en la misma tabla, no una. Logs 1 / 1 / 5 / 30 días [MG-18]; clasificación de rebotes 1 / 1 / 5 / 30, dimensión aparte [MG-19]; retención de mensajes ausente en Free y Basic, 1 día en Foundation y `"Up to 7 days"` con `"defaults to 3 days"` por dominio en Scale [MG-20], confirmado en el panel para Free [MG-21] | **X·hechos [demo]**: **30 días** en la cuenta de prueba, `"Your transactional email history is stored for only 30 days. After that, you will not be able to see the contents of the transactional emails or to whom the emails were sent."` [MC-37]. Para la cuenta de pago **ninguna fuente revisada publica un número** [MC-113]: es la única de las cinco columnas cuya respuesta a esta X cubre un solo estado. Tampoco hay tope de recursos publicado en ninguna dimensión —dominios, webhooks, usuarios—, primera API del catálogo en la que ocurre [MC-114, MC-41] |
| PI-F01 | D | **parcial**: no hay Datasheet anterior de Brevo con la que comparar; la única fechada es la de este trabajo, `date: 2026-09-16` [BR-149]. Lo que sí está fechado es del proveedor y no toca ni la cuota ni el caudal de envío: el changelog anuncia `"Added dedicated rate limits"` para `POST /v3/orders/status` y `POST /v3/products` [BR-99]. Y hay un cambio de literal **dentro de la propia recolección**: la página de lotes decía el 16-09 que la petición falla y el 21-09 que el parámetro se ignora, con las dos fechas anotadas [BR-129] | **parcial**: **no hay Datasheet previa** que comparar —esta es la primera de SES—, pero el proveedor **sí fecha sus propios cambios**, que es más de lo que hace MailerSend. Dos con fecha explícita: la asignación automática de plan, «will start on the Essentials plan beginning July 21, 2026» [SE-20], y la retirada de la capa gratuita, «As of July 21, 2026... no longer available for new customers» [SE-43]. En cuota y caudal del entorno de pruebas no hay cambio registrado. El coste de esa fecha lo pagó este trabajo: la premisa con la que SES entró al catálogo —«pago por uso puro, sin planes ni cuotas mensuales»— **caducó 42 días antes de escribirse** [SE-197] (O-04, F-09) | **parcial**: no hay Datasheet previa de Mailgun con la que comparar. Del lado del rate hay un **resultado negativo de búsqueda**: el changelog del proveedor no registra ningún cambio numérico del caudal de la API REST transaccional, y lo del último año sobre límites es de Optimize o de IP dedicada [MG-135]. Eso no es prueba de estabilidad. La única pareja de versiones comparada es la de la política de uso aceptable, que declara los mismos umbrales que la vigente [MG-47], y no es pricing. De cuota y precio, nada | **no**: no hay Datasheet previa con la que comparar, porque la de Mailchimp es del mismo día [MC-89], ni changelog propio del producto: el índice general hay que filtrarlo, `https://mailchimp.com/help/about-mandrill/` devuelve **HTTP 404** y el producto vive con dos nombres, Mandrill y Mailchimp Transactional [MC-93]. Lo único parecido a un resultado son dos citas de ese índice, agregadas por resumen de herramienta y en ámbar hasta releerlas una por una, de las que consta que **ninguna cambia una cifra** [MC-92]; eso no prueba estabilidad |
| PI-F02 | X | **X·hechos**: reverificación datada y con hallazgos. Segunda pasada documental y de panel el 2026-09-18, con la spec histórica creciendo de 145 561 a 1 162 191 bytes y 207 rutas entre el 16 y el 18 [BR-153]; un revisor tumbó tres afirmaciones de la primera pasada de [E5], que se archivó [BR-154]; y una fuente cambió de literal entre dos lecturas [BR-129]. Lo que no se puede reverificar sin red: `help.brevo.com` devuelve 403 y no tiene volcado, así que las citas de cuatro fuentes no las comprueba el verificador [BR-178] | **X·hechos**: reverificación del mismo día con **24 filas, 16 ok / 1 aviso / 0 errores** (el aviso es el `window_type` vacío); conformidad PRIME4API **20 OK / 1 ERR**, y el único fallo es `curve.accumulated` con `TypeError`, que es el defecto de motor DV-04 y SES su segundo reproductor [SE-186]. Marca de frescura al pie de la doc, «This document was last published on September 17, 2026» [SE-202], y tarifario máquina en la versión `20260911124507` [SE-203]. **La parte incómoda, que no se maquilla**: las citas salen **0 OK · 3 CAMBIO · 21 SIN-PAG** con un solo volcado archivado [SE-186], y [F45] no tiene fichero en `evidencias/` pese a sostener el cierre de DISC-15 [SE-205]. Es la única de las cinco cuya verificación de citas devuelve CAMBIO | **X·hechos**: toda la pasada es del **mismo día**, 2026-09-21 (recolección, panel y sondeo), así que la vigencia no se ha puesto a prueba con el tiempo — pero sí contra la propia API. Contraste medido frente a publicado: los 25 MB por mensaje no se aplican [MG-74 vs MG-76, MG-77], el caudal del envío no está publicado y se midió [MG-58], y DISC-02 se cerró midiendo [MG-141, MG-143]. Lo explícitamente no verificado: `type: api_first` en ámbar por el test C2 sin recorrer [MG-92 🟡], el fichero OpenAPI existe y no se ha descargado [MG-97, MG-126], la escalera del selector se usa como dato mientras la ficha de su fuente la da por no verificada [MG-06, MG-07], y el recuento de endpoints del cierre (tres) no cuadra con los seis del fichero [MG-88] | **X·hechos**: toda la pasada es del mismo día —siete lentes documentales, panel y sondeo, 2026-09-21 [MC-89, MC-90, MC-91]—, así que la vigencia no se ha probado contra el tiempo, pero sí contra la propia API: el 25/hora coincide en tres superficies y una medición [MC-42…MC-45], el `"less than 10MB"` por llamada **no se aplica** (~40 MB con HTTP 200 y ningún rechazo por tamaño) [MC-128], el tope de destinatarios no se alcanza a 5.000 [MC-129] y encolar no consume [MC-132]. Lo explícitamente no verificado: la cuota horaria de pago [MC-95], el cómputo por destinatario con su fuente en HTTP 403 [MC-110], el ancla de reinicio del bloque [MC-98], DISC-02 abierta con dos anclas incompatibles en la misma frase, el nombre de `/messages/send-template`, que no es literal de ninguna de las dos páginas que publican la operación, y `features.md` sin actualizar tras la segunda pasada de navegador |
| PI-G01 | H | **parcial**: la cuota de entrada sí (Starter 5 000/mes [BR-07]), el volumen inicial no lo fija el enunciado, y el punto de cambio es **duro**: sin sobrecoste [BR-147, BR-148], al llegar al techo hay que saltar de escalón [BR-09]. El matiz que solo Brevo añade: el ascenso puede dispararlo el proveedor por una dimensión que no es el correo — `"If you reach or exceed that limit, we will automatically upgrade your plan to the next tier"`, y ese límite es de **contactos** [BR-41], que además impide bajar de escalón [BR-46] | **parcial [sandbox]**: sin volumen inicial la pregunta no se instancia, como en las otras cuatro. Pero en SES el motivo es más fuerte: **crecer nunca obliga a cambiar de plan**, porque ningún plan liga volumen [SE-143, SE-145]. Lo único que el volumen cambia es el tramo marginal, con cortes duros y publicados en **10M y 100M correos al mes** [SE-10, SE-18] — dos órdenes por encima de cualquier peldaño del catálogo. El punto duro real es otro y no es de precio: la cuota de 200/día del estado [SE-50 🟢] y el trámite de salir del entorno de pruebas, cuyo resultado no se publica [SE-152, SE-153 🔴] | **parcial**: la cuota está —10 000 / 50 000 / 100 000 [MG-37, MG-38, MG-39]— y el ejemplo no fija volumen inicial. Además, en Mailgun **el punto duro de cambio de plan no existe**: el proveedor no publica ningún tope del exceso [MG-105, MG-104] y el único que hay lo levanta el titular con una llamada [MG-42, MG-117]. Y «cambiar de plan» y «subir de tramo» son dos cosas distintas: la escalera reprecia cuota y sobrecoste dentro del mismo plan [MG-07, MG-08, MG-102] y el fichero solo declara el tramo mínimo [MG-09, MG-103] | **parcial**: la cuota está —25.000 por bloque [MC-25]— y el ejemplo no fija volumen inicial, como en las otras cuatro columnas. Lo propio de Mailchimp es que **no hay plan que cambiar** [MC-02]: lo que cambia es el número de bloques, y el punto sí es duro —al agotarlo el envío se detiene [MC-27], sin sobrecoste [MC-84]—, pero el único automatismo es la auto-compra con tope del cliente [MC-28, MC-86]. El escalón de precio siguiente llega a los 21 bloques, $18 [MC-05], y vive fuera del YAML [MC-11, MC-88]. Y antes que la cuota ata el caudal: 18.000 correos al mes [MC-42], el 72 % del bloque |
| PI-G02 | P (Q10) | **parcial**: no hay precio de exceso que calcular [BR-147, BR-148], así que «sin cambiar de plan» los 25 000 no salen del escalón de entrada de Starter (5 000 [BR-07]), y el escalón del deslizador que los cubriría no está cifrado [BR-09]. Motor: `base_cost` 9 USD y **`unreachable: true`** con `unreachable_reason: rate_limit`, cuando la causa real es la cuota mensual de 5 000 | **sí [sandbox]**: 25.000 correos al mes en `pro` cuestan **105 + 25.000 × $0.22/1.000 = 110,50 USD** [SE-04 🟢, SE-11], y en à la carte 2,50 [SE-15, SE-16]. El motor devuelve **105 USD** y `unreachable` con etiqueta `rate_limit` (`PI-G02_ses.json`): **los 105 son la suscripción, no el precio de enviar** [SE-47, SE-168]. La etiqueta también miente en la causa, que es la cuota —200/día son 6.000 al mes [SE-50 🟢]— y no el caudal: cuarta aparición de `unreachable_reason: rate_limit` con causa de cuota en el catálogo. Y «primer plan de pago» es aquí una convención: à la carte y Essentials cobran sin suscripción [SE-02 🟢, SE-03 🟢, SE-15] | **sí**: 25 000 en Basic = $15 + 15 000 × $0.0018 = **$42** [MG-03, MG-37, MG-98]; motor 42. Es la **misma cifra exacta que Postmark Basic**, por la misma base y el mismo sobrecoste | **sí** (🟡): 25.000 correos son exactamente un bloque, **$20** [MC-04, MC-11 🟡, MC-25], sin sobrecoste que sumar [MC-84]. La cifra tiene dos agujeros que el esquema no sabe decir: no incluye la cuenta Mailchimp de pago que el producto exige [MC-16], y **el mes no da para enviarlos** —a 25 correos/hora, 25.000 correos son 1.000 h, 41 días 16 h [MC-42]—, y lo que no sale no se arrastra [MC-26 🟡]. Se paga capacidad que el caudal no puede entregar. Motor: `HTTP 500 {"detail": "float() argument must be a string or a real number, not 'NoneType'"}` (**DV-02**) |
| PI-G03 | D | **sí** (no en YAML): se puede, y por dos vías. El deslizador de cada plan es exactamente eso —Starter 5k…100k, Standard 5k…500k, Professional 150k…10M [BR-09, BR-10, BR-11]—, con cobro prorrateado al añadir y efecto en la siguiente factura al quitar [BR-45]. Y los créditos prepago, la única escalera de Brevo **completamente cifrada**: 5 000 → 32 USD, 10 000 → 59, 20 000 → 95, 50 000 → 165, 100 000 → 275, 500 000 → 940, 1M → 1 600 USD, sin caducidad [BR-27, BR-40]. De los deslizadores los hechos solo traen los extremos, y el escalón `"More"` no tiene ni volumen ni precio [BR-159] | **sí (no en YAML)**: **no se puede contratar volumen, porque no existe volumen que contratar**. Ningún plan tiene escalera de volumen [SE-143, SE-145]; el precio baja solo por consumo, en tramos marginales que se aplican «only to the emails within that tier» [SE-13]: 0,16 / 0,14 / 0,11 en Essentials, 0,22 / 0,17 / 0,12 en Pro, 0,23 / 0,18 / 0,13 en Enterprise y 0,10 plano à la carte, con cortes en 10M y 100M [SE-10, SE-11, SE-12, SE-15, SE-18]. Y son **dos escaleras independientes**, saliente y entrante [SE-14]. Respuesta determinada y opuesta a la del resto del catálogo: es el contraejemplo de P-01, que existe para declarar volúmenes contratados. Sí hay cantidad incluida con precio de exceso **en otras unidades** —1.000 inquilinos, 2.500 y 5.000 validaciones, dominios, IP y pruebas de lista semilla [SE-32, SE-33, SE-34, SE-35]—: lo que ningún plan incluye son correos | **sí** (no en YAML): sí se contrata más volumen sin cambiar de plan, con un selector de nueve posiciones [MG-06]. Foundation va de $35 con 50 000 a $75 con 100 000 [MG-07]; Scale, $90/100 000, $215/250 000, $400/500 000, $550/750 000, $700/1 000 000 y $1 250/2 500 000 [MG-08]. Free y Basic **no se mueven en ninguna posición** [MG-07]. Lo propio de Mailgun: la escalera reprecia también el **sobrecoste** dentro del plan —Foundation $1.30 → $1.10, Scale $1.10 → $0.40 [MG-102]—, y el fichero declara el del tramo mínimo, hasta 2,75 veces más caro que el real [MG-103]. La mecánica del selector sigue sin verificar [MG-06, MG-07] | **sí** (no en YAML): es lo único que se puede hacer, porque no hay plan que cambiar. La escalera va por **total de bloques comprados** —`"TOTAL BLOCKS \| EMAILS PER MONTH \| PRICE PER BLOCK"` [MC-10]— con seis tramos: 1–20 $20, 21–40 $18, 41–80 $16, 81–120 $14, 121–160 $12 y 161+ $10 [MC-04…MC-09]; por encima de 161 bloques la página remite a contacto comercial [MC-12, MC-107]. Tres cosas que el fichero no serializa: los cinco tramos altos, que viven en el provenance [MC-11]; si el precio del tramo alcanzado es marginal o plano [MC-87, MC-106]; y el descuento del 50 % para cuentas de menos de 90 días `"in select countries"` sin lista, que es promoción y no precio de lista [MC-13, MC-14, MC-109]. No hay tabla de precio anual [MC-19, MC-108] |

### Recuento

| | Postmark | Resend | SendGrid | MailerSend | Brevo | Amazon SES | Mailgun | Mailchimp | Las ocho a la vez |
|---|---|---|---|---|---|---|---|---|---|
| Respondible con los hechos («sí») sobre las 25 del canal API (D+P+H) | **18** | **22** | **20** | **21** | **16** | **21** | **20** | **20** | **12** |
| Respondible por lectura de la matriz («sí», clase L, 2) | 2 | 2 | 2 | 2 | 2 | 2 | 1 | 2 | 1 |
| Respondible sobre 27 (canal API + matriz) | **20** | **24** | **22** | **23** | **18** | **23** | **21** | **22** | **13** |
| Parcial | 4 | 2 | 4 | 4 | 8 | 4 | 5 | 3 | — |
| No respondible (entre D+P+H+X) | 5 | 3 | 3 | 2 | 3 | 3 | 1 | 4 | — |
| No respondible de clase L | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | — |
| X del catálogo con respuesta en los hechos (sobre las 5 X) | 3 | 3 | 3 | 3 | 3 | 2 | 4 | 3 | 2 |
| Total | 32 | 32 | 32 | 32 | 32 | 32 | 32 | 32 | 32 |

- El catálogo declara 25 respondibles con el canal API (D+P+H) y 27 contando la matriz funcional
  (L), desde que D-041 (2026-09-15) pasa PI-D05 de X a D. Sobre los hechos: Resend 22 de 25
  (24 de 27), SES y MailerSend 21 (23), SendGrid, Mailgun y Mailchimp 20 (22, 21 y 22), Postmark
  18 (20) y Brevo 16 (18). Tres de las cuatro APIs nuevas quedan por delante de Postmark, que
  fue el piloto. Aun así, la media de las cuatro nuevas es de 19,25 preguntas, un punto por
  debajo de las 20,25 de las cuatro primeras.
- **Las comunes a todas caen de 17 a 12, y las cinco que caen son las cinco de Brevo.** Son
  PI-A01, B01, B02, C01 y G02, todas de cuota, precio y sobrecoste, y en las otras siete APIs
  siguen respondidas. Brevo las deja en parcial por el mismo motivo en las cinco: sus tres planes
  de pago no documentan qué pasa al superar la cuota y la página de precios niega que exista
  precio de exceso, así que el término de sobrecoste de la pregunta no tiene valor que poner.
  Las 12 que quedan son PI-A02, A06, A07, B03, B05, C02, C03, C04, D01, D02, D03 y G03. Con la
  matriz son 13: PI-E01 se responde en las ocho y PI-E02 no, porque Mailgun no la responde.
- **Brevo no es la columna más floja por falta de documentación.** Sus 8 parciales son el máximo
  del catálogo, y salen de dos cosas medidas: el sobrecoste que no existe en ningún plan de pago
  y la discrepancia DISC-15 sobre los tres tramos de caudal, que ninguna fuente atribuye a un
  plan sin contradecirse. Las dos son huecos del proveedor, no del método.
- **Las 5 X dejan de repartirse igual en todas las APIs, y eso es nuevo.** Con cuatro APIs las
  cinco se repartían 3 con respuesta en los hechos y 2 sin ella, idéntico en las cuatro columnas.
  Con ocho se rompe por los dos lados. **Mailgun sube a 4** porque es la única que contesta
  PI-A08, la concurrencia, y lo hace con literal: no hay límite de conexiones simultáneas
  [MG-53]. **SES baja a 2** porque ninguna de sus fuentes publica retención de registros; lo que
  tarifa es el archivado de Mail Manager, y va por gigabytes y no por días. Es el primer «no» del
  catálogo a PI-E03. La única X que sigue sin respuesta en las ocho es PI-C05, el diff de
  pricings.
- **La clase L tiene su primer «no», y también es de Mailgun.** PI-E02 pide la IP dedicada más
  barata para 200.000 correos al mes, y en Mailgun esa cifra no es una posición del selector de
  volumen [MG-06]. Las otras siete la responden. `tab:cobertura-pi` no tiene fila para un «no» de
  clase L, y el juego de filas de esa tabla es carril rojo (E16): el 1 de Mailgun va a la fila
  «respondible en el catálogo, sin respuesta en los hechos», cuyo rótulo lo admite tal cual, y el
  pie de la tabla dice que ese 1 es de clase L.
- **El recuento aparte que pide E16: cuántas respuestas descansan en un eje que no es el pedido.**
  En SES son **17 de sus 21 «sí»**; dieciséis llevan `[sandbox]`, porque su cifra es la del estado
  de la cuenta y no la de un plan, y PI-C02 lleva `[à la carte]`, porque la pregunta nombra el
  primer tier de pago y ese eje no tiene instancia con volumen incluido. En Mailchimp son **10 de
  20**, todas `[demo]`, y con el rótulo puesto también en tres celdas que no son «sí». En las
  otras seis APIs son cero: el eje que la pregunta presupone existe y se instancia. Ese 17 de 21
  no es cobertura perdida, es cobertura sobre otro eje, y por eso se cuenta aparte en vez de
  descontarse de la columna.
- **Diez «sí» de Mailchimp están calculados a mano y sin confirmación del motor.** Son las diez de
  clase P, y la causa está medida: catorce de diecisiete llamadas devuelven
  `HTTP 500 {"detail": "float() argument must be a string or a real number, not 'NoneType'"}`,
  siempre el mismo texto, por dos huecos de la Datasheet que el esquema admite (DV-02). Siete no
  obtuvieron ninguna respuesta y tres solo la llamada descriptiva. Es la única columna del
  catálogo cuyas P no están contrastadas contra PRIME4API, y la celda lo dice en cada caso.
- **La carga de ámbar, contada igual en las ocho.** Definición: celdas «sí» cuya respuesta se
  apoya en al menos un hecho marcado 🟡. Mailgun 12 de 20, Postmark 13 de 18, Mailchimp 10 de 20,
  Brevo 9 de 16, MailerSend 7 de 21, SES 2 de 21, Resend 1 de 22 y SendGrid 1 de 20. La versión
  de cuatro APIs publicaba «14 de 18» para Postmark con otra definición, que sumaba además la
  celda apoyada en un escalón del panel sin 🟡 (PI-C01); con la definición uniforme son 13.
  Resend y SendGrid responden casi todo en verde, y eso no es virtud del método: es que publican
  más.
- **PI-D05 deja de tener una sola respuesta.** Hasta ahora solo MailerSend ataba el caudal a estados de
  reputación con nombre; ahora también Mailchimp (Excellent, Good, Poor y Unknown [MC-53]), que no
  tiene planes y donde la reputación es lo único que mueve el caudal [MC-151]. Solo MailerSend les
  pone cifra: en Mailchimp la cuenta de pago no la tiene [MC-49]. Son 2 de 8. Mailgun la deja en parcial: dice que los
  caudales suben con la reputación [MG-48], pero sin estados ni cifras.
- **Ejecución de las P.** 60 llamadas en las cuatro primeras APIs (45 el 2026-09-07, sobre 30
  instancias, y 15 el 2026-09-08) y 68 en las cuatro nuevas el 2026-09-21, sobre 40 instancias.
  En total, 128 llamadas. De las 68, Mailgun y
  SES contestaron 17 de 17, Brevo 16 de 17 —el 400 del plan Enterprise es DV-03, con el precio
  `custom` que el motor no convierte— y Mailchimp 3 de 17. De las 30 instancias de esa tanda que el motor sí
  resuelve, **ninguna difiere del cálculo a mano**: las diferencias que aparecen son las tres
  convenciones ya documentadas y dos hallazgos sobre el propio motor, que están en
  `prime4api_ejecucion_2026-09-21/CONTRASTE.md`.

---

## (e) Cambios respecto al análisis anterior

Esta sección tiene dos entradas. La primera documenta el salto de cuatro a ocho APIs
(2026-09-21): Postmark, Resend, SendGrid y MailerSend siguen siendo la base, y entran Brevo,
Amazon SES, Mailgun y Mailchimp Transactional. La segunda, debajo, es el salto de tres a
cuatro (2026-09-07 → 2026-09-08) y se conserva tal cual estaba.

### De cuatro a ocho (2026-09-21)

Entradas nuevas: `hechos_brevo.md`, `hechos_ses.md`, `hechos_mailgun.md`, `hechos_mailchimp.md`.
Prefijos de id, comprobados abriendo cada fichero y no supuestos: `BR-nn` (Brevo), `SE-nn`
(Amazon SES), `MG-nn` (Mailgun), `MC-nn` (Mailchimp Transactional). Título del fichero modelo
«Postmark · Resend · SendGrid · MailerSend» → «las ocho APIs del catálogo». «Cuatro APIs» →
«ocho» en todo el texto que sigue.

**Reserva general que precede a todo lo demás.** La base de hechos no es homogénea entre las
ocho, y esta sección lo trata como dato y no como ruido. De las cuatro API nuevas, Brevo lanza
cinco sondeos, E1 a E5 [BR-152], y alcanza un 429 real en el quinto [BR-117, BR-119]; Amazon SES
lanza también cinco, E1 a E5 [SE-173, SE-175, SE-177, SE-179, SE-180], y lo alcanza en el quinto
[SE-103]; Mailgun mide tres topes reales por rechazo —destinatarios [MG-71], tamaño de
petición [MG-77] y longitud de opciones [MG-80]— pero **no** fuerza el 429 del envío, que queda
adoptado en ámbar por decisión (D6) y no por medición [MG-67]; Mailchimp lanza el sondeo, la guarda aborta
en la primera tanda de cien, y las tandas siguientes se lanzan a mano sin que salga un solo
correo —`sent: 0`— dejando unos 7.600 destinatarios en cola sin consumir nada [MC-130, MC-131].
De las cuatro originales, Postmark nunca fuerza el 429 de su caudal [PM-97, PM-98]; SendGrid
sondea en *sandbox*, que no gasta crédito ni prueba el rechazo real [SG-40, SG-59]; MailerSend sí
fuerza un 429, pero sobre el estado de cuenta no aprobada y no sobre el rate del plan [MS-163,
MS-164]; solo Resend confirma su cifra con cabeceras sin necesitar forzar el rechazo [RS-50,
RS-54, RS-55]. El reparto limpio «cuatro cerradas con escalón 3, cuatro sin él» no se sostiene
con esta granularidad: lo que sí se sostiene, con cita, es que **tres** de las ocho alcanzan un
429 real de caudal (SES, Brevo, MailerSend —este último sobre el estado y no sobre el plan—),
**una** mide varios topes reales sin llegar al de caudal (Mailgun), **una** mide con cabeceras sin
forzar rechazo (Resend), y **tres** no llegan a ninguna medición de rechazo real del envío
(Postmark, SendGrid, Mailchimp). El capítulo no puede presentar las ocho columnas como si las
ocho estuvieran medidas igual; tiene que decir, fila a fila, cuál de estos cinco casos es cada
una.

#### Sección (a): capacidad por API y plan

- Filas de la tabla: 16 → 30 (+ 5 de Brevo: Free, Starter, Standard, Professional, Enterprise
  [BR-01…BR-05]; + 4 de Amazon SES: à la carte, Essentials, Pro, Enterprise [SE-02…SE-05]; + 4
  de Mailgun: Free, Basic, Foundation, Scale [MG-02…MG-05]; + 1 de Mailchimp, que no tiene
  planes con nombre y entra como fila única [MC-02]).
- Planes sin fila propia en `plans`: 1 (MailerSend Enterprise [MS-06, MS-124]) → 2 (+ Mailgun
  Enterprise, «Request a quote» sin tarjeta ni volumen [MG-10]).
- Rate publicado más bajo del catálogo: 2 req/s (MailerSend, 120/min [MS-45]) → **1 req/s**
  (Amazon SES en el entorno de pruebas, `"You can send 1 email per second."` [SE-80…SE-83]).
  El de producción de SES no tiene cifra: `"this rate varies based on your specific use case"`
  [SE-82], en 🔴 [SE-105].
- Primera API sin planes con nombre: Mailchimp. La página de precios no publica filas ni
  tarjetas, solo una unidad de venta —el bloque de 25.000 correos— y seis precios por bloque
  según cuántos se compren, de $20 a $10 [MC-02, MC-04…MC-09].
- Primera API donde el rate publicado **sí** escala con el plan, y no solo con el estado de la
  cuenta: Brevo declara tres tramos —General (todos los planes, 1.000 RPS en el envío),
  Advanced (Professional y Enterprise, 2.000 RPS) y Extended (solo Enterprise, 6.000 RPS)—
  [BR-81, BR-82, BR-84, BR-85]. Hasta ahora el catálogo solo conocía rate que varía por estado
  de cuenta (MailerSend [MS-48]) o que no varía en absoluto (Postmark, Resend, SendGrid,
  Mailgun); Brevo es la primera vez que sube con el plan igual que la cuota.
- Primera API donde la cuota de los planes de pago **no** escala y es la del entorno de pruebas
  compartida por los cuatro: Amazon SES. Essentials, Pro y Enterprise cuestan $0, $105 y $500 al
  mes [SE-03…SE-05], pero la única cuota serializada en el fichero es la del *sandbox*, 200
  correos/día, y PRIME4API confirma que los cuatro planes devuelven exactamente el mismo valor
  [SE-137]. Lo que compra el plan es un precio marginal por destinatario más bajo (tres tramos
  de volumen por plan, de $0,16 a $0,11 por 1.000 en Essentials [SE-10]) y acceso a funciones
  —VDM, endpoints dedicados, inquilinos—, no más correos ni más velocidad [SE-24…SE-28].
- Primera API cuya unidad de gobierno no es el plan sino el par cuenta × región: Amazon SES.
  El plan se fija «per account and each AWS Region» [SE-09]; el 2026-07-21 las cuentas sin
  actividad empiezan a asignarse a Essentials automáticamente [SE-20]; PRIME4API encuentra tres
  ejes (plan, endpoint, alias `sandbox`) y ninguno es la región [SE-137].
- Primera API sin tope de destinatarios por petición, ni publicado ni alcanzado por rechazo:
  Mailchimp. `"Via the API, there's no recipient limitation, but the JSON provided per API call
  must be less than 10MB"` [MC-60]; medido el 2026-09-21, 500, 1.000, 1.001 y 5.000
  destinatarios devuelven 200 sin ningún rechazo [MC-129]. El factor k que en las siete APIs
  anteriores conecta rate y cuota no tiene techo en esta.
- Primera API donde el exceso no se rechaza sino que se encola sin descartar: Mailchimp. La
  cuota horaria de la cuenta gratuita, 25 correos/hora [MC-42…MC-45], no genera 429 al
  superarse: `"unsent messages will be placed in the backlog"` y `"We'll begin processing the
  backlog in the next hour"` [MC-47, MC-48]. Es el único mecanismo del catálogo que no rechaza.

#### Sección (b): relación límites–rates

Esta sección no se recalcula entera para las treinta filas nuevas —exigiría rehacer el
capítulo—; lo que sigue son los puntos donde el patrón de las cuatro API originales deja de
valer o se extrema con las cuatro nuevas, cada uno con su cifra.

- El margen mínimo del catálogo (cociente R·W/Q con la cuenta sana) seguía en 2,59×
  (MailerSend Professional 2M [MS-20]). Ninguna de las cuatro nuevas lo baja: en Brevo Free,
  1.000 RPS del envío por 86.400 s frente a 300 correos/día da 288.000× [BR-08, BR-82]; en SES
  *sandbox*, 1 req/s por 86.400 s frente a 200/día da 432× [SE-50, SE-80]; en Mailgun Free (cuota
  mensual, 3.000 [MG-34]) frente al caudal medido de envío, 80.000 peticiones/10 s [MG-58], el
  cociente supera 10⁶. La cuota sigue siendo, con mucho, la restricción más apretada que
  MailerSend bajo revisión.
- La ventana medida del caudal de envío de Mailgun **no cabe en v0.3**: 9,852 s y 9,870 s en dos
  tandas, ancladas a la primera petición de cada una y no al reloj [MG-60, MG-61]; ninguno de los
  tres `window_type` del esquema —fijo, deslizante, por ciclo de facturación— la describe
  [MG-62]. El fichero declara diez segundos por redondeo. Es el primer caso del catálogo donde
  la ventana medida es un hueco de esquema y no solo un valor sin publicar.
- La misma respuesta que trae ese caudal trae un **segundo contador sobre el mismo nodo y el
  mismo instante de reposición**: `x-recipient-limit: 2000000` junto a `x-ratelimit-limit:
  80000`, con idéntico `reset` [MG-59]. v0.3 admite un solo caudal por endpoint, así que el tope
  de destinatarios de la ventana se queda fuera del fichero [MG-108]; de ahí sale **F-36**, dos
  contadores sobre una ventana y un solo caudal por nodo.
- En Mailgun el tope real de la petición no es el de destinatarios declarado en dos páginas
  —1.000 [MG-69, MG-70]— sino el del cuerpo entero: 1.001 destinatarios da 400 [MG-71], pero el
  límite que de verdad frena la petición es 52,4 MiB de JSON, medido por 413 [MG-77]; el tamaño
  de mensaje que el proveedor publica en tres fuentes, 25 MB [MG-74], **no se aplica**: adjuntos
  de hasta 48 MB pasan la comprobación de tamaño y solo caen por el 403 de la cuenta [MG-76].
- En Amazon SES el techo de lectura se mide por rechazo, no por documentación: doce peticiones
  secuenciales a 5,7/s pasan enteras [SE-102], pero treinta peticiones concurrentes a 140,8/s
  devuelven nueve 429 de treinta [SE-103], sin `retry-after` en ninguna. SES es la primera API
  del catálogo que **no publica ninguna cabecera de caudal** —cero apariciones de `ratelimit`,
  `retry-after` o `remaining` en las 116 acciones de su contrato máquina [SE-91]—, así que el
  429 medido es la única señal que existe.

#### Sección (c): afirmaciones transversales sobre RQ3

**C-1** (la cuota es la restricción activa; el rate no limita el volumen con la cuenta sana) se
sostiene en las ocho, y se extrema en dos direcciones. Sube el margen máximo: Brevo Free llega a
288.000× [BR-08, BR-82], muy por encima del 1,296·10⁸× de Postmark Free que sostenía el techo
anterior [PM-24, PM-98]. Y se extiende a una API donde ni siquiera se puede calcular fuera del
entorno de pruebas: en SES la única cuota y el único rate serializados son los del *sandbox*
[SE-50, SE-80]; producción no publica ninguno de los dos [SE-61, SE-104, SE-105], así que C-1
para SES solo es verificable en un punto, no en una escalera de planes. En Mailchimp la propia
noción de «restricción activa con k fijo» deja de aplicar: sin tope de destinatarios [MC-60,
MC-129], un k arbitrariamente grande agota el bloque de 25.000 [MC-03, MC-25] o la franquicia de
500 [MC-18, MC-29] en una sola llamada, así que la cuota gana con un margen que ni siquiera
tiene sentido acotar por k.

**C-2** (el rate no es variable del plan; la cuota sí — se compra volumen, no velocidad) deja de
sostenerse como universal. Brevo es el primer caso donde el rate **sí** escala con el plan
—General/Advanced/Extended atado a qué planes pueden pedirlo [BR-81, BR-82, BR-84, BR-85]—, y
Amazon SES es el primer caso donde **ni el rate ni la cuota** escalan con el plan: lo único que
compra Essentials, Pro o Enterprise es un precio marginal más bajo y acceso a funciones [SE-04,
SE-05, SE-10…SE-12, SE-24…SE-28], no más capacidad de envío. En Mailchimp la pregunta no tiene
sujeto: no hay plan del que la capacidad pueda depender [MC-02], y lo que se compra son bloques
del mismo producto a precio degresivo [MC-04…MC-09], no un peldaño de capacidad distinto.

**C-3** (el rate publicado y el observado no coinciden; el escalón 3 es la única fuente de rates
reales) se refuerza con matices nuevos. SES lleva la ausencia de señal a su extremo: no publica
ninguna cabecera de caudal en ninguna de sus 116 acciones [SE-91], así que el 429 medido en el
sondeo es la única vía de conocer el rechazo [SE-102, SE-103]. Mailgun documenta el mecanismo de
cabeceras entero y no publica un solo umbral fuera del genérico de 1.500 req/s por IP de
cliente [MG-50, MG-54]; medido, el caudal de envío es 80.000 peticiones por ventana [MG-58], dos
órdenes de magnitud por encima de lo único publicado. Brevo aporta el caso inverso: publica
cabeceras completas (`x-sib-ratelimit-limit`, `-remaining`, `-reset` [BR-90…BR-92]) y el sondeo
las confirma con precisión —la unidad es el segundo, medida en −12 en 12,306 s [BR-119]—, así
que es la primera API del catálogo donde documentación y sondeo coinciden en la granularidad
de la cabecera de caudal y no solo en el valor. Mailchimp queda fuera de esta afirmación por
completo: no hay cabecera de caudal en ninguna página ni en el sondeo [MC-59], y tampoco hay 429
que instrumentar [MC-58, MC-101].

**C-4** (el tope de destinatarios conecta rate y cuota, y la documentación lo publica peor de lo
que la API lo aplica) se refuerza en Mailgun —1.000 medido por rechazo, frente a las dos páginas
que ya lo publicaban correctamente [MG-69…MG-71]— y en SES —50 por mensaje, sin discrepancia
entre las tres fuentes que lo repiten [SE-106, SE-107]—. Brevo es un caso distinto: el 2.000
total está publicado con exactitud, solo que enterrado en la descripción de otro parámetro
(`messageVersions`) y no como tope propio [BR-107, BR-121, BR-122]; no es un caso de
subpublicación como en Postmark, Resend o SendGrid, es un caso de mala ubicación. Mailchimp
**rompe** C-4: no hay tope que conecte nada, porque no hay tope [MC-60, MC-129]. Lo que sustituye
al tope de destinatarios en Mailchimp es un **límite de observabilidad**, no de capacidad,
medido con precisión el 2026-09-21: hasta diez destinatarios la API evalúa en la propia llamada y
devuelve `rejected` o `unsigned`; desde once, devuelve `queued` y deja de decir si va a enviar
[MC-125]. El borde es exacto —10 frente a 11— y cualquier adjunto, desde 5 MB, produce el mismo
efecto desde el primer byte [MC-127]. Es una clase de hallazgo nueva: no mide cuánto admite el
proveedor, mide hasta dónde el proveedor **dice** algo.

#### Sección (d): cobertura del catálogo PI

Extender la tabla de 32 preguntas a ocho columnas exigía recorrer cada `PI-nn` contra los cuatro
ficheros de hechos nuevos, fila a fila, con la misma disciplina que las cuatro anteriores. Ese
recorrido está hecho y es lo que hay en §(d), con la tabla partida en dos mitades de cuatro
columnas y un solo recuento para las ocho. Tres cosas cambian respecto a la versión de cuatro
APIs. Las preguntas comunes caen de 17 a 12, y las cinco que caen son las cinco de Brevo. Las 5
preguntas de clase X dejan de repartirse igual en todas las columnas, porque Mailgun sube a
cuatro con respuesta y SES baja a dos. Y aparece el primer «no» de clase L del catálogo, también
de Mailgun. Por preguntas concretas: PI-D04 («¿sube el rate al subir de plan?») pasa a tener
respuesta afirmativa también en Brevo —el tramo Advanced y el Extended son, literalmente, rate
mayor a partir de cierto plan [BR-81, BR-82, BR-84, BR-85]—, frente a MailerSend, que la
respondía por estado de cuenta y no por plan. PI-A03 (destinatarios por petición) queda en
parcial en Mailchimp: el proveedor declara por escrito que no hay tope [MC-60] y el sondeo llegó
a 5 000 destinatarios en una sola llamada sin rechazo [MC-129], pero si cada destinatario
consume una unidad de la franquicia no se puede verificar. Y PI-A02 (rate publicado del plan)
queda sin cifra en SES fuera del entorno de pruebas [SE-61, SE-105], como en Postmark, pero sin
ninguna cabecera que dé una cifra de sustitución [SE-91]: Postmark tenía la cabecera de PM-40;
SES no tiene nada equivalente.

#### Qué cambia en la comparación con ocho APIs

- **C-1 se mantiene y se extrema.** Margen máximo 1,296·10⁸× (Postmark Free) → 288.000×
  (Brevo Free) sigue por debajo del máximo, pero SES añade un caso donde el cálculo solo existe
  en un punto (*sandbox*) y Mailchimp uno donde k no tiene techo.
- **C-2 deja de ser universal.** Brevo es la primera API con rate que escala por plan; SES es la
  primera donde ni rate ni cuota escalan por plan, solo el precio marginal; Mailchimp no tiene
  plan del que nada pueda depender.
- **C-3 se refuerza y gana un extremo en cada sentido**: SES sin ninguna cabecera de caudal
  publicada, Brevo con cabeceras que el sondeo confirma en su propia granularidad.
- **C-4 se sostiene en Mailgun y SES, se matiza en Brevo (mala ubicación, no subpublicación) y se
  rompe en Mailchimp**, donde aparece un límite de observabilidad que no es el mismo objeto que
  un límite de capacidad.

Hallazgos nuevos y sin precedente con cuatro APIs, cada uno con el hecho que lo sostiene:
1. **Una ventana medida que no cabe en los tres `window_type` de v0.3** (Mailgun, anclada a la
   primera petición de cada ventana de ~9,86 s y no al reloj) [MG-60, MG-61, MG-62].
2. **Dos contadores sobre el mismo nodo y el mismo instante de reposición** (Mailgun,
   `x-ratelimit-*` y `x-recipient-*` en la misma respuesta) [MG-59, MG-108], fricción **F-36**.
3. **Gobierno por el par cuenta × región, no por plan** (Amazon SES) [SE-09, SE-20, SE-137].
4. **Un producto sin planes con nombre** y su límite de observabilidad medido con precisión
   —10 frente a 11 destinatarios— (Mailchimp) [MC-02, MC-125, MC-126].
5. Rate que escala por plan y no por estado de cuenta (Brevo) [BR-81, BR-82, BR-84, BR-85].
6. Un mecanismo de exceso que encola en vez de rechazar, sin 429 en el catálogo de errores del
   proveedor (Mailchimp) [MC-46, MC-48, MC-58, MC-101].
7. Ausencia total de cabeceras de caudal, comprobada sobre el contrato máquina completo del
   proveedor (Amazon SES, 116 acciones, cero coincidencias) [SE-91].


### De tres a cuatro (2026-09-07 → 2026-09-08)

Lista exacta de lo que cambia en este fichero al entrar MailerSend. Sirve para propagar los recuentos al capítulo 5
(donde el texto diga «tres», ahora dice «cuatro»; las 19 marcas `% [REGENERAR con 8 APIs]` se conservan).

Cabecera y convenciones:
- Título «Postmark · Resend · SendGrid» → «Postmark · Resend · SendGrid · MailerSend». Fecha 2026-09-07 → 2026-09-08.
- Entradas: + `hechos_mailersend.md`, + `03_datos/apis/mailersend/features.md` (solo E01/E02), + `prime4api_ejecucion_mailersend/`.
- Ids: `[PM-nn]`, `[RS-nn]`, `[SG-nn]` → + `[MS-nn]`.
- Catálogo v0.1.0 (E01/E02 en X) → v0.1.1 (E01/E02 en clase L, D-019).
- «tres APIs» → «cuatro APIs» en todo el fichero.
- Nueva reserva general: el sondeo de MailerSend mide el estado no aprobado y no el plan [MS-158, MS-175]; k = 70 🟡 sin alcance desde Sandbox [MS-170]; unidad de cuota mensual no publicada [MS-114].

Sección (a):
- Filas de la tabla: 12 → 16 (+ MailerSend Free, Hobby, Starter, Professional).
- «10 tienen rate y cuota numéricos» → 14; «1 rate con cuota custom» (SendGrid Premier) y «1 sin rate ni cuota» (Resend Enterprise) sin cambio.
- Planes sin fila por no estar en `plans`: 0 → 1 (MailerSend Enterprise [MS-06, MS-124]).
- Rate publicado más bajo del catálogo: 10 req/s (Resend) → 2 req/s (MailerSend, 120/min [MS-45]).
- Primer plan con dos cuotas de unidades distintas (emails/mes + peticiones/día): ninguno → los cuatro de MailerSend [MS-35].
- Primer rate publicado por minuto y no por segundo: MailerSend [MS-45]. Primer rate que cambia por estado de cuenta: MailerSend [MS-48].

Sección (b):
- Subsecciones por API: 3 → 4. Notación: dos umbrales (Q/W, R·k) → tres (Q/W, Q_d·k/W_d, R·k).
- Filas del resumen numérico: 13 → 20 (+ Free, Hobby, Starter, Starter 1M, Professional, Professional 2M, Starter 1M «under review»).
- Cociente R·W/Q mínimo en plan publicado con la cuenta sana: 10,37 (Resend Scale 2,5M) → 2,59 (MailerSend Professional 2M [MS-20]).
- Cociente R·W/Q < 1 en un volumen publicado: ninguno → 0,43 (MailerSend Starter 1M bajo revisión [MS-48, MS-19]), 0,216 (Professional 2M).
- k* máximo: 0,0019 (Resend Pro) → 0,386 (Professional 2M, cuenta sana) y 4,63 (Professional 2M bajo revisión): primeros k* ≥ 1 del catálogo.
- Umbral 50 000/mes = 0,01929 emails/s compartido: 2 APIs (Resend Pro, SendGrid Essentials 50K) → 3 (+ MailerSend Starter y Professional [MS-31]).
- «Dos coincidencias que salen de la tabla» → «Tres coincidencias».
- Llamadas al motor: 30 → 45. Contraste: «26 coinciden o completan, 3 por convención, 1 se deriva» → + «12 coinciden, 3 por convención, 2 hallazgos (H1, H2)».
- Restricción activa: siempre «cuota» → «cuota» en 15 filas y **«rate»** en 1 (Starter 1M bajo revisión). En Hobby a k = 1: «cuota» → «cuota diaria de peticiones antes que la mensual» (H1).
- Origen del motor: «PRIME4API como servicio REST en local (D-022)» → + «PRIME4API de SPHERE en local, llamado desde el navegador» (MailerSend).

Sección (c):
- C-1: «entre uno y ocho órdenes de magnitud» → «entre 2,6 veces y ocho órdenes de magnitud»; «en ningún plan publicado» → «en ningún plan
  publicado con la cuenta en estado sano». Matices: 1 (Resend Enterprise) → 3 (+ Professional 2M a 2,6×; + estado «under review»; + cuota diaria como tercer límite).
- C-2: rate único de envío en 3 de 3 → 4 de 4; sobrecoste unitario decreciente en 3 de 3 → 4 de 4; nuevo matiz: capacidad en peticiones que sí escala
  con el plan (cuota diaria 100 → 500 000 [MS-35]; rate de lote 10 → 30 [MS-46]). PI-B05 «se reduce a cuota en las tres» → «en tres de cuatro; en
  MailerSend la responde el rate (NO × 4 a k = 1)». PI-D04 «sin respuesta afirmativa en ninguna» → «sin respuesta afirmativa para el envío individual
  en ninguna; afirmativa para el lote y la cuota diaria en MailerSend».
- C-3: «rates observados en dos de las tres APIs» → «en dos de las cuatro» para el rate de envío del plan (MailerSend observa 10/min del estado no
  aprobado, no el 120 del plan [MS-163]); «Resend es la única de las tres donde doc, panel y cabecera coinciden» → «la única de las cuatro sondeadas». Nuevo: MailerSend documenta cabeceras de cuota y `GET /v1/api-quota` [MS-37, MS-38, MS-56]
  y su ejemplo de 429 lleva 60 en la cabecera y 120 en el mensaje [MS-52].
- C-4: «en las tres APIs la documentación lo publica peor» → «en las cuatro»; topes por sondeo 3 de 3 → 3 de 4 (MailerSend 70 = suma 🟡, fuera del alcance del
  sondeo sin cuenta aprobada [MS-113, MS-170]); factor k: «50 en Resend y 1 000 en SendGrid» → + «70 (🟡) en MailerSend»; contadores que k conecta: 2 → 3 [MS-36, MS-64].
  Q9 «ninguno ≥ 1 en todos los planes publicados» → «… con la cuenta sana; k* = 2,31 en Starter 1M bajo revisión».
- Nueva subsección «Qué cambia en la comparación con cuatro APIs»: 4 líneas de refuerzo/matiz de C-1…C-4 y 6 puntos nuevos (cuota diaria de
  peticiones con cuota mensual de emails; rate por estado de cuenta; escalera con sobrecoste decreciente y distinto por tier; modelado previo
  desfasado sin cambio fechado; dos ofertas en la misma URL según JavaScript; tres estados gratuitos con aprobación).

Sección (d):
- Columnas de la tabla: 3 → 4. Clase de PI-E01 y PI-E02: X → L (y «X·hechos» → «sí (matriz)» en las tres columnas previas).
- Recuento «sí» sobre 24: 18 / 22 / 20 → **18 / 22 / 20 / 20**. Sobre 26 (con la matriz): nuevo, **20 / 24 / 22 / 22**.
- «Las tres a la vez 18» → «Las cuatro a la vez **17**» (cae PI-A05: MailerSend sin tope total de mensaje [MS-121]). Con la matriz: 19 comunes sobre 26.
- «18 comunes: 11 de cuota/precio/sobrecoste + 7 del rate» → «17 comunes: 10 + 7» (sale A05 del primer grupo).
- Parcial: 4 / 2 / 4 → 4 / 2 / 4 / **4**. No respondible: 5 / 3 / 3 → 5 / 3 / 3 / **2**.
- «X con respuesta en los hechos 5 / 5 / 5 / 5» → «3 / 3 / 3 / **4** sobre las 6 X» + fila L «2 / 2 / 2 / 2».
- «Las 3 X sin respuesta en ningún sitio: A08, C05, D05» → «2 X sin respuesta en ninguna: A08, C05; D05 tiene respuesta en MailerSend [MS-48]».
- PI-A04 con «sí»: 1 API (Resend) → 2 (+ MailerSend, con dos métricas [MS-35]).
- PI-F01 con «sí»: 1 API (Resend) → 2 (+ MailerSend, modelado previo 2026-03-19 [MS-86, MS-101]).
- PI-D05: «no» × 3 → «no» × 3 + «X·hechos» × 1.
- PI-B05: «sí, la cuota decide» × 3 → + «sí, el rate decide» × 1 (primera vez).
- PI-C01: «SG $19.95 < RS $20 < PM $55» → «SG $19.95 < RS $20 < **MS $35** < PM $55».
- PI-C02: «SG ≈ RS, 3,8 veces PM» → «SG 2 506 ≈ RS 2 500 > **MS 714** > PM 667».
- PI-C04: comparación a k = 1 «SG 0,01 s < PM 20 s < RS 2,78 h» → «… < **MS 13 h 53 min**»; «posible en las tres desde D-024» → «en las cuatro».
- PI-E02: «RS $190 < SG $199.95» → «RS $190 < SG $199.95; **PM y MS no elegibles**» (MS exige 500 000/mes [MS-108]).
- PI-E03: retención «45 / 30 / 3–7 días» → + «1 / 1 / 7 / 30 días [MS-106]».
- Ejecución de las P: 30 llamadas → 45; «3 APIs» → «4 APIs».

## Corrección del 2026-10-31 (PI-E02 en Mailgun, decisión del autor en la revisión del capítulo 7)

- PI-E02 en Mailgun pasa de **no** a **sí (matriz)**: Foundation de 100 000 correos a 75 USD [MG-07], con la IP
  dedicada incluida desde 100k [MG-16, MG-31], más 100 000 × 1,10 USD/1 000 de sobrecoste del tramo
  `"Foundation 100k $1.10"` [MG-102] = **185 USD**. Mismo método que la Tabla 7.4 de la memoria (caso de los
  100 000 correos), que ya usa la escalera del selector. Orden: SES 44,95 < **MG 185** < MC 189,95 < RS 190 <
  SG 199,95 < BR ≈ 620; PM y MS no elegibles.
- Respondible sobre 27: Mailgun 21 → **22**. Preguntas comunes a las ocho con la matriz: PI-E02 entra (la memoria
  pasa de 17 a 18; su recuento lleva además Brevo corregido a 22 por la escalera de Starter del provenance).
- `tab:cobertura-pi`: Mailgun «sin respuesta en los hechos» 1 → 0, fila L 1 → 2, «Las ocho» de L 1 → 2.
  El «primer no de clase L» de la sección (d) deja de existir.
