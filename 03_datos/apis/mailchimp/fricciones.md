# Fricciones con ACM2YAML v0.3 — Mailchimp Transactional (Mandrill)

Octava API del catálogo y la primera que **no tiene planes**. No es que tenga uno solo: la
página de precios no publica ni filas ni tarjetas, solo una tabla de seis tramos de precio
por bloque de 25.000 correos [F3]. Lo que en las siete anteriores era el eje del esquema
—eliges plan, sabes tu cuota— aquí no existe. La capacidad cuelga del **estado de la
cuenta**: demo o de pago, y dentro de la de pago, de la reputación.

Y es la primera cuyo **tope documentado se midió y no se aplicó**. El proveedor publica
menos de 10 MB de JSON por llamada [F4] y el sondeo del 2026-09-21 metió unos 40 MB sin
recibir un solo rechazo por tamaño.

Pasada 1 · **2026-09-21**: siete frentes documentales, escalón 2 con cuenta propia ([F18])
y escalón 3 el mismo día ([E1] y el sondeo A). Evidencias en
`03_datos/apis/mailchimp/evidencias/`.

**Dos reglas nuevas salen de esta API**, las dos del consejo del 2026-09-21: **B12**
(producto sin planes con nombre) y **B13** (precio unitario degresivo sin planes que lo
sostengan). B13 ordena expresamente que la escalera de Mailchimp **no cuente como F-02 ni
como F-27**, sino como fricción propia: es la **F-32** de esta lista.

---

## Recuento de recurrencia

Mailgun no tiene todavía `fricciones.md`, así que no lleva columna: el recuento de esta
tabla es sobre siete APIs cerradas, no sobre las ocho del catálogo.

| # | Fricción | Postmark | Resend | SendGrid | MailerSend | Brevo | SES | **Mailchimp** | Vía · veredicto (D-008 · D-042) |
|---|---|---|---|---|---|---|---|---|---|
| F-01 | Rate que existe sin valor | ✅ | ⚠️ parcial | ⚠️ parcial | ⚠️ parcial | ⚠️ parcial | ✅ | ✅ *(la cuota horaria de la cuenta de pago existe y no tiene cifra: «their hourly quotas will be very different» [F6]; y del resto de la API solo `/messages/search` publica caudal)* | **PROMOVIBLE por recurr.** *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: vía es recurr., no traza; antes: por traza)* → P-04 |
| F-02 | Volumen contratado con sobrecoste variable | ✅ | ✅ | ✅ | ✅ | ⚠️ variante | ❌ | ❌ *(hay escalera y no hay sobrecoste: el modelo es prepago y agotar el bloque para el envío. Se le cae la misma mitad que a Brevo, y **B13** manda que este caso vaya a fricción propia → F-32)* | **PROMOVIBLE** (4/7 + 1 variante) |
| F-03 | CRF multiplicativo | ✅ | ✅ | ⚠️ acotado | ⚠️ acotado | ✅ | *(verificar)* | ❌ *(no hay endpoint de lote [F8]: el envío múltiple ocurre dentro de una llamada a `/messages/send`, así que solo hay un eje y está acotado por MB → F-06. Si N destinatarios gastan N unidades del bloque sigue sin verificar: el artículo del proveedor que lo trata devolvió 403)* | **PROMOVIBLE** (3/7 + 2 variantes) |
| F-04 | Restricciones declaradas y no aplicadas | ✅ | — | — | ✅ | *(verificar)* | ✅ medida | ✅ **medida** *(«the JSON provided per API call must be less than 10MB» [F4] frente a 40 MB de cuerpo enviados con HTTP 200 y ningún rechazo por tamaño; `evidencias/sondeo_a_preflight_2026-09-21.md` §M4)* | **PROMOVIBLE** (4/7) |
| F-05 | RPR no serializable | ✅ | — | ✅ | ✅ | ✅ | *(verificar)* | ✅ *(`/rejects/list` «Returns up to 1000 results» [F11] y `/messages/search` «results within the last 7 days are returned» [F10]: tope por petición y ventana de profundidad, las dos fuera del esquema)* | **PROMOVIBLE** (5/7) |
| F-06 | Workload acotado por otra métrica | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ **el caso más literal del catálogo** *(«Via the API, there's no recipient limitation, but the JSON provided per API call must be less than 10MB» [F4]: el proveedor dice en la misma frase que no hay tope en la unidad del workload y que la cota está en otra métrica)* | **PROMOVIBLE** (7/7) |
| F-07 | Add-ons que modifican capacidad | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ *(IP dedicada, «Agrega una IP exclusiva por $29.95 al mes (opcional)» [F3], y créditos de SMS como línea aparte del panel [F18])* | **PROMOVIBLE** (7/7) |
| F-08 | El plan es un producto cartesiano | ✅ | ⚠️ parcial | ✅ | ✅ | ✅ | ✅ | ⚠️ **variante que falla V1** *(hay un segundo eje —el transaccional es complemento de una cuenta Standard, Premium o heredada, y «El plan Essentials no es elegible» [F3]— pero ninguna fuente ata un endpoint, una cuota ni un caudal a ese eje, así que se le cae la mitad «la superficie de la API depende del tier»)* | **PROMOVIBLE** |
| F-09 | La datasheet no dice qué parte sigue vigente | — | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ parcial *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: ninguna fila en el changelog niega una función a un plan; antes: ✅ con no hay changelog propio del producto: se filtra el índice general [F17], la página `/help/about-mandrill/` devuelve 404 y el producto se cita con dos nombres vivos, Mandrill y Mailchimp Transactional)* | **PROMOVIBLE** |
| F-10 | Dos productos, dos unidades de consumo | — | ✅ | ✅ | ⚠️ parcial | ⚠️ variante inversa | *(verificar)* | ✅ *(el panel lleva `"Free trial sends — 0 of 500"` y `"SMS credits — 0 of 0"` como contadores separados [F18], y el AUP prohíbe el masivo por Transactional [F12]: dos productos bajo la misma cuenta y dos unidades distintas)* | **PROMOVIBLE** (Resend, SendGrid) |
| F-11 | Límites de recursos por plan | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ variante del eje | ❌ *(ninguna fuente publica tope de dominios, webhooks ni usuarios; el panel expone columnas `"Expires"` y `"Remaining"` de la clave de API, las dos vacías [F18], que es el mecanismo sin la cifra)* | **PROMOVIBLE** (6/8) · recurr. *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: 6/8 · recurr. en el recuento; antes: 6/7 + 1 variante)* |
| F-12 | La recepción consume la cuota de envío | *(verificar)* | ✅ | — | ✅ | *(verificar)* | *(verificar)* | *(verificar)* *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: el literal «receive up to 100 inbound emails per day» solo aplica a demo, sin verificación del plan completo; antes: ❌ con la recepción tiene cuota propia y distinta: «receive up to 100 inbound emails per day» [F15], que no toca la de envío)* | **PROMOVIBLE** (2/7) |
| F-13 | El sobrecoste es opcional y no existe en Free | *(verificar)* | ✅ | ✅ | ✅ | ⚠️ variante | ❌ | ⚠️ **variante que falla V2** *(no existe sobrecoste en ninguna superficie, pero el mismo hecho ya cuenta entero en F-32)* | **PROMOVIBLE** |
| F-14 | El plan tiene fecha de caducidad | — | — | ✅ | ✅ | — | *(verificar)* | ❌ **y con literal en contra** *(«The emails included with the demo do not expire or renew» [F15]: la franquicia es lo contrario de una caducidad)* | **PROMOVIBLE** (2/7) |
| F-15 | Dos canales, dos workloads para la misma cuota | — | — | ✅ | ✅ | ✅ | ✅ | ✅ *(los dos literales en el mismo párrafo de [F4]: «Via the API, there's no recipient limitation» y «Via SMTP, you can send to up to 1,000 recipients at a time», sobre el mismo bloque y la misma cuota horaria)* | **PROMOVIBLE** (5/7) |
| F-16 | El sobrecoste tiene tope del proveedor | *(verificar)* | *(verificar)* | ✅ | — | — | *(verificar)* | ❌ *(no hay sobrecoste; el único tope es del cliente, «compre automáticamente bloques […] al llegar a tu límite predefinido» [F3])* | **PROMOVIBLE por traza** → P-07; 1 API |
| F-17 | Un tercer tope sin nivel de enganche | — | — | — | ⏸ DISC-11 | — | *(verificar)* | ❌ *(el tope de modo de pruebas, 10.000 mensajes al día [F5], sí tiene nivel: **D7** admite el modo de operación como disparador de alias. No se modela por DISC-02, que es contradicción del dato y no carencia del esquema)* | En suspenso |
| F-18 | La capacidad depende del estado de la cuenta, no del plan | *(verificar)* | *(verificar)* | ⚠️ | ✅ | ⚠️ variante | ✅ | ✅ **el caso extremo: no hay plan del que pueda depender** *(«Demo accounts are limited to a fixed hourly quota of 25 emails. Once you upgrade to a paid account, you'll be switched to the standard reputation and quota system» [F6], y en la cuenta de pago la cifra la fija la reputación, que es estado)* | **PROMOVIBLE** (3/7 + 2 variantes) |
| F-19 | Cuota de cardinalidad | — | — | — | absorbida | — | *(verificar)* | ❌ *(la franquicia demo se restringe por dominio, «to any email address on your verified domain» [F15], no por número de direcciones distintas)* | — |
| F-20 | La cuota de peticiones no cuenta lo que dice | — | — | — | retirada → O-11 | — | *(verificar)* | *(verificar)* | — |
| F-21 | Un cupo que se gasta con intentos que no envían nada | — | — | — | ✅ | *(verificar)* | *(verificar)* | ❌ **medida** *(dos horas después del sondeo A, el panel da «Free trial sends 0 of 500», «Sends This Month 0» y «Email sends this hour 0 of 25» sobre ~7.600 destinatarios en cola; la cola drena a rechazo sin tocar ningún contador de consumo, coherente con `sent: 0`. En Mandrill, encolar no consume)* | **PROMOVIBLE por traza** → P-08 |
| F-22 | Una credencial que solo se gestiona desde la web | ✅ | ❌ | ❌ | ❌ | ✅ | ⚠️ variante | ✅ *(alineado el 2026-09-28 con RECURRENCIA_2026-09-23.md: identificacion-03.txt y errores-01.txt; antes: (verificar) por G2)* | **PROMOVIBLE** (3 + 1 variante de SES = 4/7) |
| F-23 | Un comodín de prefijo con excepción | ❌ | ❌ | ❌ | ⚠️ variante que falla V1 | ✅ | ⚠️ V1 en duda | ❌ *(un solo caudal publicado y es de un endpoint concreto, sin comodín ni exclusión [F7][F10])* | Sin promover — L3 caída |
| F-24 | Cuota blanda que absorbe y luego descarta | ❌ | ❌ | ❌ | ⚠️ variante que falla V1 | ✅ | ❌ refutada | ❌ **y por las dos mitades** *(el bloque es muro, «el sistema dejará de enviar correos electrónicos cuando se te acaben los bloques» [F3]; y la cuota horaria es cola que **sí** se procesa, «We'll begin processing the backlog in the next hour» [F4], sin descarte)* | **PROMUEVE por traza** (Brevo) |
| F-25 | Un endpoint, dos modos excluyentes | ❌ | ❌ | ❌ | ❌ | ✅ | ❓ duda | ❌ *(tres rutas separadas para los tres modos de envío: `/messages/send`, `/messages/send-template` y `/messages/send-raw` [F8])* | Sin promover — L3 caída |
| F-26 | Un precio por geografía y una sola divisa | — | — | ⚠️ | ✅ | ✅ | *(verificar)* | ⚠️ **variante que falla V1** *(la página se sirve en dos idiomas por geolocalización con la misma cifra en USD, y la promoción del 50 % es elegible «en determinados países» sin lista [F3]: hay geografía en la elegibilidad, y no hay ni segunda divisa ni segundo precio, así que se le cae la mitad de la divisa)* | **PROMOVIBLE** — 2/7 la mitad divisa |
| F-27 | El exceso cambia el plan y lo dispara otra dimensión | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ *(no hay exceso: se compra otro bloque del mismo producto, y **B13** descarta expresamente esta lectura porque los paquetes prepago ya cuentan dentro de la F-27 de Brevo — V2)* | **PROMUEVE por traza** (Brevo) |
| F-28 | Una lista de IP autorizadas decide si la llamada entra | ⚠️ | — | ⚠️ | ✅ | ✅ | ❌ | ✅ *(está en la tabla oficial de errores: «401 IP does not have permission to use this key \| API keys can be limited by IP address […] edit the key to allow the IP address to make requests» [F5])* | **PROMOVIBLE** (3/7) |
| F-29 | El precio unitario no tiene campo sin cuota incluida | — | — | — | — | — | ✅ | ❌ *(aquí la unidad que se paga sí trae volumen dentro: «Cada bloque es un crédito por 25,000 correos electrónicos» [F3], y eso cabe en `capacity` + `price`)* | Sin promover — L3 pendiente |
| F-30 | Precio por tramos marginales sobre el mismo consumo | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ **falla V1 y V2** *(V1: no consta que los tramos sean marginales — la fuente no aclara si el precio del tramo alcanzado es marginal o plano, y por B13 eso es hallazgo y no DISC. V2: la escalera ya cuenta entera en F-32)* | Sin promover — 1/7 |
| F-31 | La unidad de gobierno es el par cuenta × región | — | — | — | — | — | ✅ | ❌ *(ninguna fuente publica regiones ni endpoints regionales)* | Sin promover — L3 pendiente |
| **F-32** | **Precio unitario degresivo sin planes que lo sostengan** | ❌ *(tres planes con nombre y sobrecoste por unidad)* | ❌ *(planes con nombre)* | ❌ *(planes con nombre y selector dentro de la tarjeta → B11)* | ❌ *(planes con nombre)* | ❌ *(cinco planes con nombre; su escalera vive dentro de la tarjeta)* | ❌ *(el comparador de planes sí publica filas con nombre —Standard, Pro y Enterprise, con volumen incluido y precio de exceso por unidad—, así que no se cumple el supuesto de B12; que su datasheet lleve una entrada única es otra cosa)* | ✅ **nueva** | **Sin promover — 1/7.** L1 completa ([F3], volcado del 2026-09-21); L2 y L3 pendientes de ejecutar |
| **F-33** | **Una franquicia que no caduca ni se renueva: la cuota sin ventana** | ❌ *(los 100 gratis del panel renuevan con fecha: «Your 100 free emails will renew on Sep 4, 2026»)* | ❌ *(cuota diaria y mensual, las dos con ventana)* | ❌ *(cuota diaria con reinicio a medianoche UTC)* | ❌ *(mensual con ciclo de facturación)* | ❌ *(diaria con ventana, aunque el ancla no se publique)* | ❌ *(diaria en el entorno de pruebas; lo que falta es el ancla, no el periodo)* | ✅ **nueva** | **Sin promover — 1/7.** L1 completa ([F15] y [F18]); L2 y L3 pendientes de ejecutar |
| **F-34** | **Dos topes de tamaño sobre la misma llamada, en magnitudes distintas** | ❌ *(un solo tope, 50 MB de payload en `/email/bulk`)* | *(verificar)* | *(verificar)* | *(verificar)* | ⚠️ *(20 MB por correo, y 100 KB por objeto `params` con 1.000 KB acumulados: son dos topes, pero de objetos distintos de la petición y no del mensaje entregado)* | ⚠️ *(10 MB en la API v1 y 40 MB en v2 y SMTP: dos topes del mismo objeto en canales distintos, que es F-15)* | ✅ **nueva** | **Sin promover — 1/7.** L1 completa ([F4], los dos literales en la misma página); L2 y L3 pendientes de ejecutar |

**Lo que esta API mueve en el recuento.** F-06 y F-07 llegan a **7/7**: son las dos únicas
del catálogo presentes en todas las APIs cerradas. F-18 pasa a **3/7** y refuerza una
promoción que ya tenía. F-28 pasa a **2/7** y **cruza el umbral de D-008**: la lista de IP
que decide si la llamada entra deja de ser cosa de MailerSend y Brevo. F-05 sube a 5/7 y
F-15 a 5/7. F-11 pierde universalidad: es la primera API donde ningún tope de recursos
está publicado.

**Lo que no suma y conviene que quede escrito.** F-02 no recurre aquí, y no por falta de
escalera sino porque no hay sobrecoste: es la segunda API, tras Brevo, que rompe el
enunciado por la misma mitad. Dos casos con la misma rotura ya no son una anécdota, y por
eso B13 abrió clase propia en vez de estirar F-02.

Tres fricciones nuevas: **F-32**, **F-33** y **F-34**. Observación nueva: **O-22**.

---

## F-32 · Precio unitario degresivo sin planes que lo sostengan — NUEVA

**Qué pasa.** Mailchimp Transactional no se vende por planes. La página de precios no
publica ni una fila ni una tarjeta: publica una unidad y una tabla. La unidad es el bloque,
*"Cada bloque es un crédito por 25,000 correos electrónicos"*, y la tabla da seis precios
para esa misma unidad según cuántas se compren: *"1 - 20 bloques | 1 - 500k emails |
$20/bloque · 21 - 40 bloques | 500k - 1M emails | $18/bloque · 41 - 80 bloques | 1M - 2M
emails | $16/bloque · 81 - 120 bloques | 2M - 3M emails | $14/bloque · 121 - 160 bloques |
3M - 4M emails | $12/bloque · 161+ bloques | 4M+ emails | $10/bloque"* [F3]. Por encima de
161 bloques no hay cifra: *"Contáctanos para obtener más información sobre nuestros precios
para grandes volúmenes."* Y no hay sobrecoste de ninguna clase, porque el modelo es prepago:
*"el sistema dejará de enviar correos electrónicos cuando se te acaben los bloques"*.

**Qué hace v0.3.** Un plan tiene un `price` escalar y una `quota`. Aquí el precio no es del
plan, es de la unidad, y cambia con cuántas unidades se compren. Las tres formas que el
esquema permite fallan las tres. Poner un plan por tramo da seis entradas con el mismo
caudal, los mismos endpoints y las mismas features, que es peso muerto por B1 y B7.
Poner el precio del tramo de entrada —lo que hace esta datasheet, `price: 20.00` en ámbar—
declara como precio de plan lo que es precio de unidad. Y usar `overage_cost` para la
escalera inventa un sobrecoste que el proveedor niega por escrito.

**Consecuencia.** El coste que PRIME4API calcula para un millón de correos sale del precio
de entrada, $20 por bloque, cuando el proveedor cobra $18. El error crece con el volumen y
va siempre en la misma dirección: **el fichero encarece al proveedor barato**. No es un
hueco visible, es una cifra plausible y alta. Y como el fichero tampoco dice si el precio
del tramo alcanzado es marginal o plano sobre todos los bloques del mes —ninguna página lo
aclara—, ni siquiera se sabe cuál de los dos errores se está cometiendo.

**Propuesta.** Separar el precio de la unidad del precio del plan: una `unit_price` con
tramos por volumen comprado, cada uno con su rango y su precio, y una bandera que diga si
el tramo es marginal o plano. Es pariente de la propuesta de F-02 —`tiers` con precio y
overage por escalón— pero sin la parte del overage, que aquí no existe. Un esquema que
tuviera las dos absorbería Mailchimp y Brevo con la misma forma.

---

## F-33 · Una franquicia que no caduca ni se renueva: la cuota sin ventana — NUEVA

**Qué pasa.** La cuenta de prueba trae 500 correos, y el proveedor dice dos cosas sobre
ellos en la misma página: *"You can send up to 500 transactional emails to any email address
on your verified domain"* y *"The emails included with the demo do not expire or renew."*
[F15]. El panel los escribe como contador, *"Free trial sends — 0 of 500"* [F18]. Es un
saldo: se gasta una vez, no vuelve, y no hay fecha en la que caduque lo que no se gastó.

**Qué hace v0.3.** `capacity` exige `period` —objeto con `value` y `unit`— y `window_type`
en toda cuota. Los dos campos describen un ciclo que aquí no existe. El esquema no tiene
forma de decir *"500 unidades, una sola vez, sin ventana"*, que es distinto de *"500 al
mes"* y distinto de *"500 al día"*. La datasheet deja `period` y `window_type` vacíos, con
el comentario y la entrada en `metadata.not_found`, que es lo que manda D-004 para una
dimensión sin valor publicado. Aquí el valor no es que falte: es que no existe.

**Consecuencia.** PRIME4API no puede situar la franquicia en ninguna curva. Sin periodo no
hay eje temporal en el que colocar las 500 unidades, así que la cuota que la cuenta de
prueba sí tiene queda inevaluable. Y la alternativa —quitarla del fichero— es peor: dejaría
el estado `demo` con caudal y sin ningún tope de volumen, que se lee como capacidad
ilimitada. Es la patología de F-01 trasladada a la cuota.

**Propuesta.** Un `window_type: none` o un `period` opcional cuando la cuota es un saldo y
no un ciclo, con la semántica explícita de que el contador no se repone. El esquema ya
distingue tres tipos de reinicio; le falta el cuarto caso, que es no reiniciarse nunca.

---

## F-34 · Dos topes de tamaño sobre la misma llamada, en magnitudes distintas — NUEVA

**Qué pasa.** La misma página publica dos topes de tamaño y no miden lo mismo [F4]. Uno es
de la petición: *"the JSON provided per API call must be less than 10MB"*. El otro es del
mensaje entregado: *"Mailchimp Transactional allows attachments, but the total message size
cannot exceed 25MB. There is no specific limit for individual attachments, just the total
size of the message."* No son excluyentes —por eso no abren DISC (D11)— y a la vez son
conjuntamente inalcanzables: un mensaje de 25 MB viaja en base64 dentro del JSON, así que
nunca cabría en una llamada de menos de 10 MB.

**Qué hace v0.3.** `workload` admite una lista de cargas por endpoint, una por unidad. Las
dos cifras están en MBs, así que el esquema solo puede alojar una: el fichero declara
`unit: MBs, max: 10`, que es el tope de la llamada, y los 25 MB del mensaje se quedan en el
provenance y en `metadata.not_found`. La unidad `MBs` no distingue qué se mide.

**Consecuencia.** El CRF de tamaño que lee el motor es el de la petición, no el del
artefacto. Para responder *¿cabe este correo con sus adjuntos?* el número correcto es el de
25 MB; para responder *¿entra esta llamada?* es el de 10 MB. Hoy el fichero solo responde la
segunda, y un consumidor que pregunte la primera recibe un límite dos veces y medio más
estrecho del que el proveedor publica.

**Propuesta.** Que la carga lleve el objeto medido además de la unidad —`request_body`
frente a `message`—, o unidades distintas para magnitudes distintas. Emparenta con F-06,
que pide lo contrario por el mismo motivo: allí el tope está en otra métrica y no cabe,
aquí hay dos topes de la misma métrica y solo cabe uno.

---

## Observación de método

**O-22 · Por encima de un umbral no publicado, la API deja de decir qué va a hacer.** El
sondeo del 2026-09-21 midió el borde exacto: hasta diez destinatarios `/messages/send`
devuelve `"status": "rejected"` con `"reject_reason": "unsigned"` y con eso se sabe que no
sale nada; desde once devuelve `"status": "queued"` con `"queued_reason":
"multiple-recipients"` y no dice si enviará. Con cualquier adjunto pasa lo mismo desde el
primer byte, `"queued_reason": "attachments"`. No es un límite de capacidad y no va al
esquema: es que **la vía de medir haciendo que el proveedor rechace —la condición 3 de
D-046, la preferente— deja de existir por encima de esa frontera**. Las tandas de M4 y M5
se lanzaron fuera de ella y dejaron unos 7.600 destinatarios en cola, que drenan hacia
rechazos porque la cuenta no tiene dominio verificado. La lección es de método: en esta API
la vía de coste cero solo existe con diez destinatarios o menos y sin adjuntos. Detalle en
`evidencias/sondeo_a_preflight_2026-09-21.md`.
