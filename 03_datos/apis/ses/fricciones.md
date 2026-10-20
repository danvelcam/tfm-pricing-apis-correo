# Fricciones con ACM2YAML v0.3 — Amazon SES

Sexta API del catálogo, y la primera que **rompe el eje del esquema**. En las cinco
anteriores la capacidad cuelga de un plan: eliges plan, sabes tu cuota. En SES la capacidad
cuelga del par **cuenta × región**, el plan es de ese mismo par, y el estado de la cuenta
—entorno de pruebas o acceso de producción— también. Tres ejes donde v0.3 tiene uno.

Y es la primera cuyo **precio no cabe en el fichero**. No porque esté oculto: está publicado
al céntimo, en la página de precios y en un tarifario legible por máquina. No cabe porque
v0.3 ata el precio unitario al exceso sobre una cuota incluida, y ningún plan de SES incluye
correos. Otras unidades del mismo producto sí traen volumen dentro —mil inquilinos por cuenta
y región, 2.500 validaciones de API en Pro— y esas caben sin pelea. El hueco es de la unidad
que paga el cliente, no del plan entero.

Pasada 1 · **2026-09-18**, cuatro lentes documentales, escalón 2 con cuenta propia y
**escalón 3 el mismo día**. El escalón 3 deja cuatro sondeos contra la API —cuatro correos
enviados, cinco destinatarios— y la ejecución de PRIME4API que mide la condición L2. Todo
en `03_datos/apis/ses/evidencias/`.

---

## Recuento de recurrencia

| # | Fricción | Postmark | Resend | SendGrid | MailerSend | Brevo | **SES** | Vía · veredicto (D-008 · D-042) |
|---|---|---|---|---|---|---|---|---|
| F-01 | Rate que existe sin valor | ✅ | ⚠️ parcial | ⚠️ parcial | ⚠️ parcial | ⚠️ parcial | ✅ *(el caudal de producción existe y no tiene cifra: «varies based on your specific use case»)* | **PROMOVIBLE por recurr. (4/8) · P-04** *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: PROMOVIBLE (4/8) · recurr. · P-04; antes: PROMOVIBLE por traza → P-04)* |
| F-02 | Volumen contratado con sobrecoste variable | ✅ | ✅ | ✅ | ✅ | ⚠️ variante *(B10: falla V1 — «no hay sobrecoste que varíe, porque no hay sobrecoste»)* | ❌ *(no hay volumen contratado: el precio es marginal por tramos y no hay nada incluido)* | **PROMOVIBLE** (4/6 + 1 variante) |
| F-03 | CRF multiplicativo | ✅ | ✅ | ⚠️ acotado | ⚠️ acotado | ✅ | ✅ *(alineado el 2026-09-28 con RECURRENCIA_2026-09-23.md: BulkEmailEntryList; antes: (verificar))* | **PROMOVIBLE** (3/8 · alineado el 2026-09-28 con RECURRENCIA_2026-09-23.md; antes: 3/5 + 2 variantes) |
| F-04 | Restricciones declaradas y no aplicadas | ✅ | — | — | ✅ | *(verificar)* | ✅ **medida** *([F1]: `"All actions (except for SendEmail, SendRawEmail, and SendTemplatedEmail) are throttled at one request per second."` — doce peticiones secuenciales a `GetAccount` a **5,7 por segundo** y doce 200, ninguna rechazada; `evidencias/probe_ses_caudal_lectura_2026-09-18_100218.json`)* | **PROMOVIBLE** (3/6) |
| F-05 | RPR no serializable | ✅ | — | ✅ | ✅ | ✅ | ✅ *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: máximo 1000 entradas por petición en ListEmailIdentities; antes: ❌ con nota no recurre en lo recolectado. El tope que se buscaba, el máximo de entradas por llamada al envío por lotes, no se publica. Es una ausencia y no un tope documentado sin campo. Ningún hecho registra un tope de resultados por petición)* | **PROMOVIBLE** (4/5) |
| F-06 | Workload acotado por otra métrica | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ *(40 MB por mensaje, y por encima de 10 MB el proveedor limita el ancho de banda a 40 MB/s)* | **PROMOVIBLE** (6/6) |
| F-07 | Add-ons que modifican capacidad | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ *(IP dedicada, VDM y Mail Manager, cada uno con su tarifa y su ámbito de región)* | **PROMOVIBLE** (6/6) |
| F-08 | El plan es un producto cartesiano | ✅ | ⚠️ parcial | ✅ | ✅ | ✅ | ⚠️ variante que no suma *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: la mitad del tier falla en ses/features.md; antes: ✅ el caso extremo con plan × región × estado de la cuenta)* | **PROMOVIBLE** |
| F-09 | La datasheet no dice qué parte sigue vigente | — | ✅ | ✅ | ✅ | ✅ | ✅ **el caso extremo** *(dos entradas de blog de 2012 y 2014 siguen publicadas y contradicen al tarifario de 2026; la FAQ no lleva fecha)* | **PROMOVIBLE** |
| F-10 | Dos productos, dos unidades de consumo | — | ✅ | ✅ | ⚠️ parcial | ⚠️ **variante inversa** | ⚠️ variante que no suma *(alineado el 2026-09-28 con RECURRENCIA_2026-09-23.md; antes: (verificar))* | **PROMOVIBLE** (Resend, SendGrid) |
| F-11 | Límites de recursos por plan | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ **variante del eje** *(identidades, plantillas y configuration sets tienen tope, pero por región y no por plan; B10: falla V1, cae la mitad «por plan»)* | **PROMOVIBLE** (5/6 + 1 variante) |
| F-12 | La recepción consume la cuota de envío | *(verificar)* | ✅ | — | ✅ | *(verificar)* | *(verificar)* | **PROMOVIBLE** (2/5) |
| F-13 | El sobrecoste es opcional y no existe en Free | *(verificar)* | ✅ | ✅ | ✅ | ⚠️ variante *(B10: falla V2 — el mismo hecho ya cuenta en su F-02 y en su F-27)* | ❌ *(no existe sobrecoste en ningún plan, y tampoco existe plan gratuito vigente)* | **PROMOVIBLE** |
| F-14 | El plan tiene fecha de caducidad | — | — | ✅ | ✅ | — | ⚠️ variante que no suma *(ídem)* | **PROMOVIBLE** (2/5) |
| F-15 | Dos canales, dos workloads para la misma cuota | — | — | ✅ | ✅ | ✅ | ⚠️ variante que no suma *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: v1 con 10 MB, v2 y SMTP con 40 MB; falla V1; antes: ✅ con la API v1 admite 10 MB y la v2 y SMTP 40 MB, sobre la misma cuota de cuenta)* | **PROMOVIBLE** (4/6) |
| F-16 | El sobrecoste tiene tope del proveedor | *(verificar)* | *(verificar)* | ✅ | — | — | ❌ *(ídem)* | **PROMOVIBLE por traza** → P-07; 1 API |
| F-17 | Un tercer tope sin nivel de enganche | — | — | — | ⏸ DISC-11 | — | ❌ *(ídem)* | En suspenso |
| F-18 | La capacidad depende del estado de la cuenta, no del plan | *(verificar)* | *(verificar)* | ⚠️ *(B10: falla V1 — «403 por peticiones malformadas, sin cifra»: no hay capacidad que dependa del estado)* | ✅ | ⚠️ variante *(B10: falla V1 — el caudal depende del tramo, no del estado de la cuenta)* | ✅ **literal y doble** *(entorno de pruebas frente a producción, y el estado es del par cuenta × región)* | **PROMOVIBLE** (2/6 + 2 variantes) |
| F-19 | Cuota de cardinalidad | — | — | — | absorbida | — | *(verificar)* | — |
| F-20 | La cuota de peticiones no cuenta lo que dice | — | — | — | retirada → O-11 | — | *(verificar)* | — |
| F-21 | Un cupo que se gasta con intentos que no envían nada | — | — | — | ✅ | *(verificar)* | ❌ *(la cuota diaria no es un cupo de destinatarios distintos. Tiene periodo de 24 horas y cuenta destinatarios sin fundir repeticiones. Lo que el proveedor publica es otra cosa: un mensaje aceptado hacia la lista de supresión descuenta cuota aunque no se entregue, y un envío fallido no se factura)* | **PROMOVIBLE por traza** → P-08 |
| F-22 | Una credencial que solo se gestiona desde la web | ✅ | ❌ | ❌ | ❌ | ✅ | ⚠️ **variante** *(no es la web: las credenciales SMTP se crean en otro servicio, IAM, y la API de SES no tiene ni una acción de credenciales en sus 116; B10: cumple V1 —la credencial existe y la API del producto no la gestiona, solo cambia dónde vive— y V2, porque ninguna otra fila cuenta este hecho)* | **PROMOVIBLE** (3/6, y la tercera es la variante de SES: por **B10** una variante que pasa V1 y V2 suma) |
| **F-23** | **Un comodín de prefijo con excepción, que el esquema no puede escribir** | ❌ *(no hay caudal por ruta ni comodín: el 429 existe y ningún umbral se publica)* | ❌ *(un solo caudal global sin excepciones: `"The default maximum rate limit is 10 requests per second per team."`)* | ❌ *(caudal por endpoint sin comodín ni exclusión, y sin cifras publicadas)* | ⚠️ **variante que falla V1** *(comodín global con exclusión —`"All API requests (excluding v1/email) \| 60 requests per minute"`— pero el esquema SÍ la escribe: `/*` más el endpoint explícito, y el README resuelve la herencia; se le cae la mitad «que el esquema no puede escribir»)* | ✅ **nueva** | ⚠️ **variante, V1 en duda** *(`"All actions (except for SendEmail, SendRawEmail, and SendTemplatedEmail) are throttled at one request per second."`: la excepción nombra tres operaciones de v1 mientras el fichero modela v2, así que lo inescribible es el **alcance** de la lista y no la forma del comodín — DISC-05)* | Sin promover — **L1 completa desde el 2026-09-21** (fila en `05_salida/_cap5/hechos_brevo.md` y volcado verbatim de su página en `evidencias/paginas/2026-09-21/`) y **L2 cumplida**, pero **L3 sigue caída**: con las 207 rutas de [F29] archivadas, `/*` más entrada explícita por ruta sí lo escribe, que es el rasero con el que se descartó la celda de MailerSend. La exclusión que publica la tabla de caudal es notación del proveedor, no semántica que el esquema no tenga |
| **F-24** | **Cuota blanda: superada, absorbe hasta N y luego descarta en silencio** | ❌ *(el test mode es un muro y no una franja: `"you can only send and process 100 emails"`, y del 101 no dice nada; el Free lleva `"No overages allowed in this plan"`)* | ❌ *(o se factura por unidad o no existe: `"Overage Not available"`)* | ❌ *(muro explícito: `"You can’t exceed these limitations."`)* | ⚠️ **variante que falla V1** *(el mecanismo exacto —`"all future emails will be queued for 7 days maximum, after which they will be erased from our servers and won’t be sent."`— pero lo dispara una **pausa manual del dominio** y el tope es temporal, no una cuota superada ni un N de unidades)* | ✅ **nueva** | ❌ **refutada con literal** *(`"the call fails with a throttling error and the email is dropped. Amazon SES does not queue the emails and send them later."`; fuente editorial de 2012, que es material de F-09)* | **PROMUEVE por traza** (B9, caso medido, una API) — **L2 y L3 cumplidas** (el motor escribe la cuota blanda con la misma forma que un muro, y ni un `overage_cost` con precio 0 expresa el tope de 1.000 ni el descarte); **L1 completa desde el 2026-09-21** (fila en `05_salida/_cap5/hechos_brevo.md` y volcado verbatim de su página en `evidencias/paginas/2026-09-21/`), con el literal entero de la cola de reintento. Era lo único que faltaba. Precedente: F-16 y F-21 |
| **F-25** | **Un endpoint, dos modos excluyentes, y una carga que depende de otro campo** | ❌ *(el lote vive en otro endpoint: `/email` y `/email/batch`)* | ❌ *(ídem: `/emails` y `/emails/batch`)* | ❌ *(endpoint único, pero sin modos excluyentes y con **un** tope al total: `"The total number of recipients must be no more than 1,000"`; además **V2** lo bloquea, porque esa evidencia ya cuenta en F-03)* | ❌ *(dos rutas y dos caudales: `"POST /v1/email: 120 requests/minute"` y `"POST /v1/bulk-email: 10 requests/minute"`)* | ✅ **nueva** | ❓ **DUDA declarada** *(un endpoint con tres tipos de mensaje y dos unidades de tope —`"50 recipients per message."` y `"50 destinations."`— pero falta el literal de exclusión mutua y las dos cifras coinciden, así que la carga no cambia de valor)* | Sin promover — **L1 completa desde el 2026-09-21** (fila en `05_salida/_cap5/hechos_brevo.md` y volcado verbatim de su página en `evidencias/paginas/2026-09-21/`) y **L2 cumplida**, pero **L3 sigue caída**: el README documenta `batch` como caso de alias y el eje está libre en tres de los cinco planes; aguanta solo la mitad de la carga condicionada |
| **F-26** | **Un precio por geografía y una sola divisa en el fichero** | — | — | ⚠️ | ✅ | ✅ **nueva** | ⚠️ variante que no suma *(ídem)* | **PROMOVIBLE** — mitad divisa 2/5 (Brevo y MailerSend), mitad impuestos 3/5; cruza por recurrencia, L2 y L3 no hacen falta por esa vía |
| **F-27** | **El exceso no se paga por unidad: cambia el plan, y lo dispara otra dimensión** | ❌ *(precio por unidad: `"Extra emails @ $1.80 / 1,000"`)* | ❌ *(`"The overage rate applies only to emails sent beyond the included volume."`)* | ❌ **y en la dirección contraria** *(`"you will be charged a small overage fee on a per-email basis"`, y además `"Upgrading your account doesn’t negate incurred overage charges."`: subir de plan **no** sustituye al sobrecoste)* | ❌ *(`"we bill extra emails at a set rate per 1,000 on your next invoice"`, y el proveedor niega por escrito el ascenso automático)* | ✅ **nueva** | ❌ *(no hay nada incluido, así que no hay exceso: `"you pay only for what you use with no minimum fees"` y tramos marginales)* | **PROMUEVE por traza** (B9, caso medido, una API) — **L2 y L3 cumplidas** (coste plano frente a un control que crece, y el cambio de plan no tiene campo); **L1 completa desde el 2026-09-21** (fila en `05_salida/_cap5/hechos_brevo.md` y volcado verbatim de su página en `evidencias/paginas/2026-09-21/`). Era lo único que faltaba. Precedente: F-16 y F-21 |
| F-28 | Una lista de IP autorizadas decide si la llamada entra | ⚠️ | — | ⚠️ | ✅ | ✅ | *(verificar)* *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: sin literal que afirme ni niegue; antes: ❌ con el control de acceso es de IAM y no del producto de correo)* | **PROMOVIBLE** (2/6) |
| **F-29** | **El precio unitario no tiene campo cuando su unidad no tiene cuota incluida** | — | — | — | — | — | ✅ **nueva** *(el correo no tiene cuota incluida; inquilinos y validaciones sí, y esos sí caben)* | Sin promover — **L2 cumplida** *(coste plano a las tres demandas, con control)*; **L3 pendiente** |
| **F-30** | **Precio por tramos marginales sobre el mismo consumo** | ❌ *(falla V2: su escalera ya cuenta como ocurrencia plena en F-02)* | ❌ *(falla V2: ídem, F-02 plena)* | ❌ *(falla V2: el volumen por plan ya es F-02 plena)* | ❌ *(falla V2: los ocho peldaños ya son F-02 plena)* | ❌ *(falla V1: la escalera del configurador es volumen contratado y sin sobrecoste)* | ✅ **nueva** *(tres precios por plan para el mismo correo, y dos escaleras independientes: saliente y entrante)* | Sin promover — **1/6** por B10; **L2 y L3 pendientes** |
| **F-31** | **La unidad de gobierno no es la cuenta, es el par cuenta × región** | — | — | — | — | — | ✅ **nueva** | Sin promover — **L2** *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: L2 es la condición que falla según B9; antes: L2 cumplida con el motor lee tres ejes y ninguno es la región)* · **L3 pendiente** |

---

## F-29 · El precio unitario no tiene campo cuando su unidad no tiene cuota incluida — NUEVA

**Qué pasa.** SES publica su precio al céntimo y por dos vías. En la página de precios:
*"Outbound email | $0.10 / 1,000 emails"* a la carta, y tres tramos por plan que van de
*"$0.16 per 1,000 emails"* a *"$0.11 per 1,000 emails"*. Y en el tarifario legible por
máquina, con más precisión todavía: `"Charged for each email sent to an external recipient"`,
unidad `Count`, `USD 0.0001000000`. Lo que **no** publica es una cuota de correos incluida:
ningún plan trae correos dentro, y el propio proveedor lo dice —*"you pay only for what you
use with no minimum fees or mandatory service usage"*—.

**Hasta dónde llega el enunciado, y no más.** La carencia es de la dimensión «correo», no del
plan entero. El comparador de planes, capturado el 2026-09-18, publica volumen incluido con
precio de exceso para otras dos unidades:

- inquilinos, nota 6 de [F39] — `"1,000 tenants included per account per region;
  $0.005/month/tenant for additional tenants"`;
- validaciones de API, nota 4 — `"Pro plan includes 2,500 API validations/account/region/month
  and Enterprise plan includes 5,000 API validations/account/region/month; Extra API
  validations at $0.01/validation"`.

Eso es cuota incluida más `overage_cost`, que es justo la forma que v0.3 sabe expresar, y entra
en el fichero sin pelea. La fricción no cae, porque el precio del correo sigue sin campo, pero
su premisa era más ancha que el hecho: no es que SES no incluya volumen, es que no lo incluye
**en la unidad que factura el producto**.

**Qué hace v0.3.** El precio del consumo vive en `overage_cost`, y `overage_cost` es un
atributo **de una cuota**: el precio de lo que se pasa de lo incluido. El campo de v0.2 que
sí describía esto, `cost_per_request`, **se eliminó en v0.3** y se sustituyó por `workload`,
que describe la carga de una petición y no su coste.

**Consecuencia.** El precio de SES no tiene dónde ir. Las salidas posibles son las dos malas:
inventar una cuota de cero correos para colgar de ella el precio unitario —un valor que
ninguna fuente publica— o dejar el único precio del producto fuera del fichero legible por
máquina. La datasheet elige la segunda, que es la honesta, y el resultado es que **una
herramienta que calcule coste desde este fichero no puede calcular el coste de SES**: ve
cuatro planes cuyo `price` es la cuota fija mensual, 0, 0, 105 y 500 dólares, y ni un céntimo
del gasto real, que es todo el gasto de quien no paga cuota fija.

**Propuesta.** Que el precio unitario del consumo sea un atributo del **plan** y no de la
cuota: un `unit_cost` con su unidad y su moneda, aplicable exista o no volumen incluido.
`overage_cost` sigue siendo lo que es —el precio de pasarse— y el pago por uso deja de
modelarse como un exceso perpetuo sobre una cuota que nadie publica.

**Listón D-042.** **L1 cumplida**: los tres literales, los dos de la página de precios y el
del tarifario máquina. **L2 cumplida el 2026-09-18, y con caso de control.** PRIME4API, con
esta datasheet delante y sin tocarla, devuelve el **mismo coste a un correo, a cien mil y a
diez millones**: 0, 0, 105 y 500 dólares para à la carte, Essentials, Pro y Enterprise. Es la
cuota fija del plan y nada más, porque los cuatro planes salen con `cuotas_elasticas: 0` y no
hay consumo que cobrar. El control es MailerSend, que sí tiene `overage_cost`: su plan Hobby
devuelve 7, 149,5 y 14.999,5 a esas tres demandas, con dieciocho cuotas elásticas. El motor
sabe responder; lo que no encuentra es dónde leer el precio. Ejecución archivada en
`evidencias/l2_prime4api_2026-09-18.json`. **L3 pendiente**: la comprobación formal contra
`readme0.3.md` está hecha en lo esencial —`cost_per_request` figura como eliminado en la
tabla de cambios de la versión— pero no se ha contrastado con el resto del esquema.

---

## F-30 · Precio por tramos marginales sobre el mismo consumo — NUEVA

**Qué pasa.** Cada plan de SES tiene **tres precios** para el mismo correo, según el volumen
acumulado del mes: Essentials cobra *"$0.16 per 1,000 emails"* hasta 10 millones,
*"$0.14"* entre 10 y 100, y *"$0.11"* por encima. Y son **marginales**, con el proveedor
diciéndolo para que no haya duda: *"Tiered rates are applied marginally — each rate applies
only to the emails within that tier, not to your entire volume."* AWS publica hasta la
aritmética del ejemplo: 50 millones en Enterprise son *"10M × $0.23/1K + 40M × $0.18/1K"*.

Y hay un segundo eje, en la frase que sigue a esa en el mismo párrafo: *"Volume tiers apply
independently to outbound emails sent and inbound emails processed via Mail Manager."* Son
**dos escaleras, no una**. Quien envía y recibe atraviesa las dos por separado, y el tramo que
alcanza en una no mueve el de la otra.

**Qué hace v0.3.** Un plan tiene un `price` y, si acaso, un `overage_cost` con un precio por
unidad. Uno. No hay forma de declarar que el precio unitario **cambia con el consumo
acumulado**, ni de declarar dónde están los cortes. Tampoco de declarar que hay dos escaleras
sobre unidades distintas, que es lo que el segundo literal añade.

**Consecuencia.** El coste de SES no es lineal y el fichero solo puede describirlo como si lo
fuera. Cualquier lectura que tome el primer tramo sobreestima el gasto de un cliente grande
en un 50 %, y cualquiera que tome el último lo subestima en la misma proporción. Es el mismo
territorio que **F-02**, la escalera de volumen, pero al revés: allí el cliente **contrata**
un escalón y aquí lo **atraviesa** sin firmar nada.

**Propuesta.** Que el precio unitario admita una lista de tramos con su corte y su precio, y
una marca de si el tramo es marginal o de reemplazo. La lista cuelga de la **unidad**, no del
plan, para que saliente y entrante lleven la suya. Con eso, F-02 y F-30 se modelan con la
misma estructura y el esquema deja de necesitar que el cliente firme un escalón para poder
describirlo.

**Listón D-042.** **L1 cumplida**. **Recurrencia comprobada, y es negativa: 1/6.** Las cinco
APIs anteriores tienen escalera de volumen, y las cinco la cobran sobre volumen **contratado**,
que es F-02 y no esto. Por **B10** ninguna suma, y no por el mismo motivo. Postmark, Resend,
SendGrid y MailerSend fallan **V2**: esa misma escalera ya cuenta como ocurrencia plena en su
fila de F-02, y una evidencia no cuenta dos veces en el tablero. Brevo falla **V1**: su
escalera es de volumen contratado y sin sobrecoste, así que ni sostiene el enunciado entero.
El veredicto se lee en el tablero, no en la prosa. No se apoya en el párrafo de contraste de
arriba —el que dice que F-02 es el mismo territorio al revés—, que ilustra la diferencia y no
la decide. Sin recurrencia, **F-30 necesita L2 y L3**, y las dos siguen pendientes.

---

## F-31 · La unidad de gobierno no es la cuenta, es el par cuenta × región — NUEVA

**Qué pasa.** En SES casi todo lo que decide la capacidad está atado a la región, y el
proveedor lo dice sin rodeos: *"SES quotas are for each AWS Region that you use in your AWS
account."* Y no es solo la cuota. Va por región el **estado** de la cuenta —*"The sandbox
status for your account is unique per each AWS Region"*—, el **plan** desde julio de 2026
—*"Plans apply for each account and each AWS Region"*—, la **verificación** de cada identidad,
las **credenciales** del canal SMTP y la **lista de supresión**. Medido en el panel: la misma
cuenta está en pruebas en Irlanda y sin estrenar en Estocolmo.

**Qué hace v0.3.** Un documento describe un servicio, y dentro tiene planes. El plan es la
única dimensión por la que la capacidad puede variar. No hay región, ni la hay como alias,
porque los aliases nombran estados dentro de un plan y aquí la región está **por encima** del
plan: un cliente puede tener Pro en Irlanda y pago por uso en Fráncfort al mismo tiempo.

**Consecuencia.** La datasheet de SES describe, en rigor, **una** región, y no dice cuál.
Peor: no puede decirlo, porque no hay campo. Un consumidor que la lea no sabe si los 200
correos al día son de su cuenta o de su cuenta en una región concreta, y las dos respuestas
llevan a planificaciones distintas. Con 29 regiones con endpoint, el fichero cubre el 3 % de
lo que el cliente puede contratar y no lo declara.

**Propuesta.** Que el documento admita un eje de **ámbito** por encima de los planes, con su
vocabulario tomado del proveedor —región, proyecto, organización—, de modo que un mismo
fichero pueda declarar qué parte del modelo se replica por ámbito y qué parte es global. Es
más que un alias: los aliases eligen entre variantes dentro de un plan, y esto multiplica el
plan entero.

**Listón D-042.** **L1 cumplida**, con cinco literales de cinco páginas distintas más la
observación de panel. **L2 cumplida el 2026-09-18**, en la misma ejecución que F-29. PRIME4API
lee este documento y le encuentra tres ejes —cuatro planes, cuatro endpoints y un alias,
`sandbox`— y ninguno es la región. Los cuatro planes devuelven la misma cuota, 200 correos al
día, que es la de **una** región que el fichero no nombra. El control es MailerSend, cuya cuota
sí es de la cuenta: allí el motor devuelve una cifra distinta por plan, 100 peticiones al día
en Free y 1.000 en Hobby. Ejecución archivada en `evidencias/l2_prime4api_2026-09-18.json`.
**L3 pendiente**.

---

## Observaciones

**O-01 · SES no publica ninguna cabecera de caudal, y está comprobado por ausencia.** Sobre
el contrato máquina archivado, `sesv2` versión 2019-09-27: cero apariciones de `ratelimit`,
`rate-limit`, `retry-after`, `x-amz-retry` y `remaining`, y la enumeración de miembros con
destino de cabecera sale **vacía**, así que las trece excepciones de la versión 2 no llevan
más campo que el mensaje. La vía documentada para conocer los límites vigentes es preguntar
por `GET /v2/email/account`, o sea *polling*. Es el reverso de lo que hacen Brevo y MailerSend,
que los publican en cada respuesta, y refuerza el argumento de O-16 de Brevo: el régimen de
límites vive fuera del contrato máquina.

**O-02 · El proveedor se contradice consigo mismo diecinueve veces, y esa es la aportación.**
De las veinte discrepancias de `fuentes.md`, **diecinueve son de AWS contra AWS**: la guía de
producto contra la referencia de API, la referencia contra el contrato máquina, y una página
contra sí misma dos párrafos después. La única que se sale es `DISC-15`, cuyo lado B no es una
página del proveedor sino la ausencia de ella. El caso más limpio es el error de caudal, que
tiene tres nombres —`ThrottlingException` en la página monográfica, `TooManyRequestsException` con 429 en
la referencia de la operación, y **ninguno** en el modelo de servicio—. Ninguna otra API del
catálogo se contradice tanto, y es precisamente la más usada en producción de las seis.

**O-03 · Una anomalía de precio que solo existe en el tarifario máquina.** El tramo de IP
administrada por encima de 100 millones cuesta `USD 0.0000040000` por destinatario en 28
localizaciones y `USD 0.0000400000` en Estocolmo, diez veces más, en el mismo fichero y la
misma versión `20260911124507`. La página de precios no lo desmiente porque ahí ese tramo no
tiene cifra: dice *"Contact us"*. No se abre fricción —es un defecto del proveedor y no del
esquema— pero queda registrada porque es el tipo de dato que solo aparece cuando se lee el
contrato máquina entero.

**O-04 · La premisa de selección caducó seis semanas antes de escribirse.** El documento del
2026-09-01 eligió SES por ser *«pago por uso puro, sin planes ni cuotas mensuales»*. Los
planes existen desde el **2026-07-21**, cuarenta y dos días antes. La API sigue siendo la elección correcta —cubre el
pago por uso y ahora también el caso mixto— pero el capítulo que justifica el catálogo
describe un producto que ya no es. Es **F-09** aplicado al propio trabajo, y conviene contarlo
así en la memoria en vez de corregirlo en silencio.

**O-05 · El 429 llega sin `retry-after`, y ya van dos APIs.** El sondeo de caudal en lectura
sacó nueve rechazos de treinta peticiones concurrentes, lanzadas a 140,8 por segundo. Los nueve
traen `x-amzn-errortype: TooManyRequestsException` y el cuerpo `{"message": "Rate exceeded"}`,
y **ninguno trae `retry-after`**. La ausencia está comprobada, no supuesta: el sondeo archiva
toda cabecera cuyo nombre contenga `retry`, `rate` o `errortype`, y de las tres familias solo
aparece la última. MailerSend ya traía el mismo hueco en su `DISC-19`, así que el patrón va por
dos APIs. La premisa no es la misma en las dos, y conviene decirlo. MailerSend **publica** la
cabecera en su documentación y luego no la manda; SES no la promete en ninguna parte, y O-01 lo
comprueba por ausencia sobre el contrato máquina. Recurre lo que recibe el cliente, cambia si el
proveedor se contradice al dárselo. **No se abre fricción**, y el motivo ya está escrito en el
catálogo: MailerSend dejó registrado que una cabecera ausente no tiene *«consecuencia en el
YAML: v0.3 no serializa cabeceras»*. Sin carencia del esquema que enunciar no hay nada que
promover, por mucho que la recurrencia esté.

**O-06 · El caso inverso de F-22: lo exclusivo es de la API, y lo dice la consola.** F-22 cuenta
credenciales que solo se gestionan desde la web. SES le da la vuelta al caso con las plantillas.
La consola tiene su página —`#/email-templates`— pero solo lista, y manda al cliente a la API
con dos frases suyas. Para crear: *"Para crear una plantilla de correo electrónico, utilice la
operación de la API CreateEmailTemplate"*. Para leer una: *"Para ver el contenido de una
plantilla de correo electrónico específica, utilice la operación GetEmailTemplate en la API de
Amazon SES"*. El proveedor declara en su propio panel que la operación no está ahí. Para el test **C2** esto no mueve nada:
pregunta por lo exclusivo de la **web**, y de la web no hay nada exclusivo, así que `api_first`
se sostiene con las tres operaciones comprobadas. Lo que enseña es que la exclusividad tiene dos
sentidos y el catálogo solo mide uno. Observado en la **segunda pasada de panel del
2026-09-18**, que todavía no tiene fichero en `evidencias/` ni bloque propio en `fuentes.md`.
