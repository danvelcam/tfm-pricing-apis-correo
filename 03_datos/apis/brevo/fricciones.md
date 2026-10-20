# Fricciones con ACM2YAML v0.3 — Brevo

Quinta API del catálogo y la primera cuyo producto modelado **no tiene cuota propia**: el
transaccional y el de marketing gastan el mismo saldo, y el propio proveedor lo escribe
(*"you can use your email credits to send both marketing and transactional emails"*
[F26]). Con cinco APIs son **diecisiete las fricciones que cruzan el umbral D-008**
(recurrencia en ≥ 2 APIs). Eran catorce con cuatro APIs, y las **tres que entran lo hacen
con Brevo dentro**: **F-22**, la credencial que solo se gestiona desde la web, que pasa a
2/5 con Postmark —las otras tres publican endpoint de claves y no recurren—; **F-26**, el
precio por geografía, que llega a 2/5 con MailerSend en la mitad de la divisa y a 3/5 con
SendGrid en la de los impuestos; y **F-28**, nueva, la lista de IP autorizadas, que nace ya
en 2/5 porque MailerSend la tiene documentada como rechazo (`#MS40305`) y condicionada al
plan. Con las tres que entran por traza (F-01, F-16 y F-21, D-042) el total de promovibles
es **veinte**. F-15 **refuerza** su promoción al pasar de 2/4 a 3/5 —cruzó el umbral con
MailerSend, no aquí— y F-06, F-07 y F-11 llegan a 5/5.

**Las tres promociones son del 2026-09-18** y salen de comprobar la recurrencia una por una
en las cuatro Datasheets cerradas, que era el paso barato que quedaba pendiente. Ninguna
necesita L2: B9 promueve por recurrencia **o** por caso medido, y estas van por la primera
vía.

La pasada añade **cinco fricciones nuevas** —F-23, F-24, F-25, F-26 y F-27— y **retira una
candidata**. La numeración arranca en **F-23** porque el último número usado del inventario
es **F-22** (la credencial que solo se gestiona desde la web, Postmark), y los retirados
—F-19 y F-20— no se reutilizan. La candidata retirada importa tanto como las nuevas: el material de
recolección marcó «dos caudales simultáneos sobre el mismo endpoint (RPS y RPH)» como
fricción de primer orden, porque el proveedor obliga a respetar los dos y v0.3 solo admite
un `rate`. **Comprobado fila a fila, no es una carencia**: en las diez filas que publican
las dos unidades, el RPH es exactamente el RPS por 3.600. La segunda cifra no añade
restricción, así que serializar el RPS no pierde nada. Queda como observación **O-15**, y
su número de fricción no se abre. Dos de las cinco nuevas (F-24 y F-27) son del mismo
territorio y salen del mismo sitio: **qué pasa cuando te pasas**. Brevo es la primera API
del catálogo que no publica **ningún** precio de exceso en **ningún** plan.

Pasada 1 · **2026-09-16** (documentación pública por tres lentes: capacidad, precio y
contrato de rechazo). El escalón 2 se recorrió el 17-09 y el escalón 3 lleva cuatro pasadas,
[E1] a [E4], y el 18-09 se suma [E5]; lo que se apoya en ellos va marcado caso por caso.

**L2, medida el 2026-09-18 en las cuatro fricciones sin recurrencia.** F-23, F-24, F-25 y
F-27 tenían la evidencia documental (L1) y les faltaba la ejecutada. Las cuatro ejecuciones
van con su caso de control y están archivadas en el mismo fichero,
`evidencias/l2_prime4api_2026-09-18.json`; el apartado «Listón D-042» de cada una dice qué
devolvió el motor. Les queda **L3**, el contraste formal contra el README de la guía. La otra
ejecución archivada es la de O-18, que no es de una fricción nueva sino del `rate` que
faltaba en `/v3/inbound/events`.

**Añadido el 2026-09-17.** El escalón 3 arrancó y abortó en su segundo caso: el sondeo [E1]
de `fuentes.md` midió que Brevo **acepta** con `201` una petición cuyo remitente y cuyo
destinatario están en un dominio inexistente. **No abre fricción nueva** —la numeración se
queda en F-27— y va como observación **O-20**, con la promoción devuelta al autor porque es
carril B9/D-042 (Q-A3 de `REVISION.md`). Dos celdas de la tabla cambian de marca: F-04 y
F-21, las dos a *(verificar)*, sin que ningún recuento se mueva. El escalón 2 sí tiene
volcado del mismo día en `evidencias/panel_brevo_2026-09-17.md`, y **este fichero todavía no
lo ha incorporado**: hay evidencia de panel esperando en F-07, F-15 y F-26.

---

## Recuento de recurrencia

| # | Fricción | Postmark | Resend | SendGrid | MailerSend | **Brevo** | Vía · veredicto (D-008 · D-042) |
|---|---|---|---|---|---|---|---|
| F-01 | Rate que existe sin valor | ✅ | ⚠️ parcial | ⚠️ parcial | ⚠️ parcial | ⚠️ parcial *(los endpoints sí tienen cifra; el canal SMTP y la segmentación no)* | **PROMOVIBLE por traza** → P-04 |
| F-02 | Volumen contratado con sobrecoste variable | ✅ | ✅ | ✅ | ✅ | ⚠️ **variante sin sobrecoste** *(escalera de 10 a 14 volúmenes por plan y ni un precio de exceso)* | **PROMOVIBLE** (4/5 + 1 variante) |
| F-03 | CRF multiplicativo | ✅ | ✅ | ⚠️ acotado | ⚠️ acotado | ⚠️ acotada *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: acotada por máximo 2000 destinatarios por petición; antes: ✅ con 1.000 versiones × 99 destinatarios, y el total publicado los contradice)* | **PROMOVIBLE** (3/5 + 2 variantes) |
| F-04 | Restricciones declaradas y no aplicadas | ✅ | — | — | ✅ | *(verificar)* *(el sondeo del 2026-09-17 abortó en su segundo caso y no llegó a medirlo: O-20)* | **PROMOVIBLE** (2/5) |
| F-05 | RPR no serializable | ✅ | — | ✅ | ✅ | ✅ *(siete topes de paginación en la spec y una ventana de 90 días)* | **PROMOVIBLE** (4/5) |
| F-06 | Workload acotado por otra métrica | ✅ | ✅ | ✅ | ✅ | ✅ *(20 MB por correo; 100 KB por objeto `params` y 1.000 KB acumulados)* | **PROMOVIBLE** (5/5) |
| F-07 | Add-ons que modifican capacidad | ✅ | ✅ | ✅ | ✅ | ✅ *(el crédito prepago levanta la cuota diaria de otro plan y arrastra sus funciones)* | **PROMOVIBLE** (5/5) |
| F-08 | El plan es un producto cartesiano | ✅ | ⚠️ parcial | ✅ | ✅ | ✅ *(inbound solo en Professional y Enterprise, y tres tramos de caudal ortogonales al plan)* | **PROMOVIBLE** |
| F-09 | La datasheet no dice qué parte sigue vigente | — | ✅ | ✅ | ✅ | ✅ *(changelog con fecha: caudales dedicados añadidos endpoint a endpoint)* | **PROMOVIBLE** |
| F-10 | Dos productos, dos unidades de consumo | — | ✅ | ✅ | ⚠️ parcial | ⚠️ **variante inversa** *(dos productos y UNA sola unidad compartida: el modelado no tiene cuota propia)* | **PROMOVIBLE** (Resend, SendGrid) |
| F-11 | Límites de recursos por plan | ✅ | ✅ | ✅ | ✅ | ✅ *(cuatro `platform quotas` citadas, y el tope de contactos acoplado al escalón de correos)* | **PROMOVIBLE** (5/5) |
| F-12 | La recepción consume la cuota de envío | *(verificar)* | ✅ | — | ✅ | *(verificar)* *(no documentado y sin medir)* | **PROMOVIBLE** (2/5) |
| F-13 | El sobrecoste es opcional y no existe en Free | *(verificar)* | ✅ | ✅ | ✅ | ⚠️ **variante** *(no existe en ningún plan, ni opcional ni en los de pago; el mismo hecho ya cuenta en F-02 y en F-27, así que no suma ocurrencia plena)* | **PROMOVIBLE** (3/5 + 1 variante) |
| F-14 | El plan tiene fecha de caducidad | — | — | ✅ | ✅ | — | **PROMOVIBLE** (2/5) |
| F-15 | Dos canales, dos workloads para la misma cuota | — | — | ✅ | ✅ | ✅ *(el relay SMTP no admite lote y la API sí, sobre la misma cuota)* | **PROMOVIBLE** (3/5) |
| F-16 | El sobrecoste tiene tope del proveedor | *(verificar)* | *(verificar)* | ✅ | — | — | **PROMOVIBLE por traza** → P-07; 1 API |
| F-17 | Un tercer tope sin nivel de enganche | — | — | — | ⏸ DISC-11 | — | En suspenso |
| F-18 | La capacidad depende del estado de la cuenta, no del plan | *(verificar)* | *(verificar)* | ⚠️ | ✅ | ⚠️ **variante del eje** *(el caudal depende del tramo, no del plan; el estado de aprobación no publica cifras y por D7 no genera alias)* | Sin promover — **L2 no cumplida** (el fallo es del motor, no del esquema); 1 API (+2 parciales, +2 a verificar). Lectura del patrón pendiente de decisión — ver nota bajo la tabla |
| F-19 | Cuota de cardinalidad | — | — | — | absorbida | — | — |
| F-20 | La cuota de peticiones no cuenta lo que dice | — | — | — | retirada → O-11 | — | — |
| F-21 | Un cupo que se gasta con intentos que no envían nada | — | — | — | ✅ | ❌ *(alineado el 2026-09-28 con RECURRENCIA_2026-09-23.md: no hay cupo de destinatarios distintos, [F24] y [E3] credits 300 → 298 por entrega; antes: (verificar))* *(una forma del patrón está **medida**: el `400` de p1 —`"sender is missing"`, ningún correo— volvió con `x-sib-ratelimit-remaining: 999` de `limit 1000`, o sea que la petición rechazada consumió unidad del bucket de **caudal**. Dos muestras no fijan la lectura: haría falta ver el contador caer con pausas conocidas. Y sigue sin medir la otra forma, la de la **cuota de correo**: la petición de sonda fue ACEPTADA con 201 en sandbox y si eso descuenta crédito es este patrón exacto: O-20, Q-A2)* | **PROMOVIBLE por traza** → P-08 |
| F-22 | Una credencial que solo se gestiona desde la web | ✅ | ❌ *(`POST /api-keys`)* | ❌ *(`POST /v3/api_keys`)* | ❌ *(`POST /v1/token`)* | ✅ *(la API solo crea claves de una **subcuenta** Corporate; la propia se genera con el botón `"Generate API key"` del panel)* | **PROMOVIBLE** (2/5) — cruza por recurrencia, que es la primera vía de B9; **L2 sigue fallando por naturaleza** y no hace falta |
| **F-23** | **Un comodín de prefijo con excepción, que el esquema no puede escribir** | ❌ *(no hay caudal por ruta ni comodín: el 429 existe y ningún umbral se publica)* | ❌ *(un solo caudal global sin excepciones: `"The default maximum rate limit is 10 requests per second per team."`)* | ❌ *(caudal por endpoint sin comodín ni exclusión, y sin cifras publicadas)* | ⚠️ **variante que falla V1** *(comodín global con exclusión —`"All API requests (excluding v1/email) \| 60 requests per minute"`— pero el esquema SÍ la escribe: `/*` más el endpoint explícito, y el README resuelve la herencia; se le cae la mitad «que el esquema no puede escribir»)* | ✅ **nueva** | Sin promover — **L1 completa desde el 2026-09-21** (fila en `05_salida/_cap5/hechos_brevo.md` y volcado verbatim de su página en `evidencias/paginas/2026-09-21/`) y **L2 cumplida**, pero **L3 sigue caída**: con las 207 rutas de [F29] archivadas, `/*` más entrada explícita por ruta sí lo escribe, que es el rasero con el que se descartó la celda de MailerSend. La exclusión que publica la tabla de caudal es notación del proveedor, no semántica que el esquema no tenga |
| **F-24** | **Cuota blanda: superada, absorbe hasta N y luego descarta en silencio** | ❌ *(el test mode es un muro y no una franja: `"you can only send and process 100 emails"`, y del 101 no dice nada; el Free lleva `"No overages allowed in this plan"`)* | ❌ *(o se factura por unidad o no existe: `"Overage Not available"`)* | ❌ *(muro explícito: `"You can’t exceed these limitations."`)* | ⚠️ **variante que falla V1** *(el mecanismo exacto —`"all future emails will be queued for 7 days maximum, after which they will be erased from our servers and won’t be sent."`— pero lo dispara una **pausa manual del dominio** y el tope es temporal, no una cuota superada ni un N de unidades)* | ✅ **nueva** | **PROMUEVE por traza** (B9, caso medido, una API) — **L2 y L3 cumplidas** (el motor escribe la cuota blanda con la misma forma que un muro, y ni un `overage_cost` con precio 0 expresa el tope de 1.000 ni el descarte); **L1 completa desde el 2026-09-21** (fila en `05_salida/_cap5/hechos_brevo.md` y volcado verbatim de su página en `evidencias/paginas/2026-09-21/`), con el literal entero de la cola de reintento. Era lo único que faltaba. Precedente: F-16 y F-21 |
| **F-25** | **Un endpoint, dos modos excluyentes, y una carga que depende de otro campo** | ❌ *(el lote vive en otro endpoint: `/email` y `/email/batch`)* | ❌ *(ídem: `/emails` y `/emails/batch`)* | ❌ *(endpoint único, pero sin modos excluyentes y con **un** tope al total: `"The total number of recipients must be no more than 1,000"`; además **V2** lo bloquea, porque esa evidencia ya cuenta en F-03)* | ❌ *(dos rutas y dos caudales: `"POST /v1/email: 120 requests/minute"` y `"POST /v1/bulk-email: 10 requests/minute"`)* | ✅ **nueva** | Sin promover — **L1 completa desde el 2026-09-21** (fila en `05_salida/_cap5/hechos_brevo.md` y volcado verbatim de su página en `evidencias/paginas/2026-09-21/`) y **L2 cumplida**, pero **L3 sigue caída**: el README documenta `batch` como caso de alias y el eje está libre en tres de los cinco planes; aguanta solo la mitad de la carga condicionada |
| **F-26** | **Un precio por geografía y una sola divisa en el fichero** | — | — | ⚠️ *(solo la mitad b: precio publicado sin impuestos)* | ✅ *(tres divisas en `/pricing`, con canónica declarada, y «Taxes may apply»)* | ✅ **nueva** *(ocho divisas geolocalizadas, sin canónica, y precios sin impuestos)* | **PROMOVIBLE** — mitad divisa 2/5 (Brevo y MailerSend), mitad impuestos 3/5; cruza por recurrencia, L2 y L3 no hacen falta por esa vía |
| **F-27** | **El exceso no se paga por unidad: cambia el plan, y lo dispara otra dimensión** | ❌ *(precio por unidad: `"Extra emails @ $1.80 / 1,000"`)* | ❌ *(`"The overage rate applies only to emails sent beyond the included volume."`)* | ❌ **y en la dirección contraria** *(`"you will be charged a small overage fee on a per-email basis"`, y además `"Upgrading your account doesn’t negate incurred overage charges."`: subir de plan **no** sustituye al sobrecoste)* | ❌ *(`"we bill extra emails at a set rate per 1,000 on your next invoice"`, y el proveedor niega por escrito el ascenso automático)* | ✅ **nueva** | **PROMUEVE por traza** (B9, caso medido, una API) — **L2 y L3 cumplidas** (coste plano frente a un control que crece, y el cambio de plan no tiene campo); **L1 completa desde el 2026-09-21** (fila en `05_salida/_cap5/hechos_brevo.md` y volcado verbatim de su página en `evidencias/paginas/2026-09-21/`). Era lo único que faltaba. Precedente: F-16 y F-21 *(alineado el 2026-09-28 con RECURRENCIA_2026-09-23.md: Sin promover (1/8) · L2, D-058 con B9 tal como está escrita; carril rojo W1 de rojo.md, el autor puede revertir; antes: PROMUEVE por traza)* |
| **F-28** | **Una lista de IP autorizadas decide si la llamada entra** | ⚠️ *(mecanismo nombrado en panel, sin literal del efecto)* | — | ⚠️ *(`IP Access Management` en la página de precios)* | ✅ *(`"Your IP address is not allowlisted. #MS40305"`, y la función va por plan)* | ✅ **nueva** *(dos interruptores, uno por familia de credencial)* | **PROMOVIBLE** (2/5) — cruza por recurrencia; L2 y L3 pendientes |

**Nota sobre F-18 y el recuento.** Brevo publica el caudal en tres tramos —General,
Advanced y Extended— que **no son los cinco planes**: Professional es elegible a la vez
del General y del Advanced, Enterprise de los tres, y ninguna fuente dice cuál se aplica
por defecto [F6]. Es decir, la capacidad depende de algo que no es el plan. Bajo la
lectura **estricta** de F-18 («el estado de la **cuenta**») Brevo **no** recurre: el tramo
no es un estado, es una banda del acuerdo comercial, y el único estado real —la cuenta sin
aprobar— **no publica cifras**, así que por **D7** ni genera alias ni entra. Bajo la
lectura **amplia** («la capacidad depende de un eje que no es el plan») sí recurre y F-18
pasaría a 2/5. **No se promueve por recurrencia en esta pasada**: la elección entre las dos
lecturas es criterio de inventario y va como pregunta en `REVISION.md`. Lo que sí queda
escrito es que el **mecanismo de aliases de v0.3 absorbería la expresión** del caso —los
nombres `general`, `advanced` y `extended` son vocabulario del propio proveedor, que es lo
que exige D7— y lo que **no** absorbe es cuál de los tres es el vigente. Por eso la
condición L3 fallaría y la vía de traza tampoco prospera.

**Lo que esta API mueve en el recuento:** F-15 pasa de 2/4 a **3/5**, que **refuerza** una
promoción que ya tenía —cruzó el umbral con MailerSend, y así consta en su tabla y en el
inventario—; F-06, F-07 y F-11 llegan a **5/5**, las tres únicas del catálogo presentes en
todas las APIs. F-02 recurre por quinta vez pero **en una variante que le quita la mitad**: hay
escalera de volumen contratado y no hay sobrecoste, así que el caso de Brevo refuerza el
primer término de la propuesta (`tiers`) y no el segundo.

---

## F-01 · Un rate que existe pero no tiene valor — recurrencia PARCIAL

**Qué pasa.** Brevo es, con diferencia, la API **más generosa del catálogo publicando
caudal**: tres tramos —nueve filas en General, cinco en Advanced y seis en Extended— y
hasta un changelog que fecha cuándo se añadió el de cada endpoint [F6][F22]. Los endpoints modelados tienen cifra. Lo que no
tiene valor es (a) el caudal del **canal SMTP**, del que [F17] solo publica los puertos, y
(b) la **segmentación**: ni [F6] ni [F7] dicen si el contador va por cuenta, por clave, por
IP o por sub-organización, así que no se sabe si dos claves suman o comparten un mismo
tope de 1.000 peticiones por segundo.

**Por qué es parcial.** Igual que en Resend, SendGrid y MailerSend: para los endpoints
modelados hay valor. Lo que falta es un canal y una dimensión de reparto, no el rate.

**Un matiz que solo da Brevo.** El caudal está publicado en prosa HTML y **en ningún otro
sitio**. La búsqueda literal sobre la especificación completa —1.162.191 bytes y 207 rutas,
descargada y archivada el 18-09— de `"rate limit"`, `"RPS"`, `"RPH"`, `"per hour"`,
`"per second"` y `"x-sib"` devuelve **cero coincidencias** [F29], igual que sobre la captura
más corta del 16-09 [F21]. Un cliente generado desde el contrato máquina no sabe que existe un
caudal, ni con qué unidad, ni qué cabecera leer. No es fricción del esquema —es del
proveedor— pero es el argumento más directo que ha dado el catálogo a favor de un modelo de
*pricing* legible por máquina. Se detalla en la observación **O-16**.

---

## F-02 · Cuotas por volumen contratado, con sobrecoste variable — RECURRE ⚠️ (variante)

**Qué pasa.** El configurador `"Customize your plan"` reescribe las tarjetas: **diez**
volúmenes en Starter (5.000 → 100.000, $9 → $82), **catorce** en Standard (5.000 →
500.000, $18 → $429) y **doce** en Professional (150.000 → 10.000.000, $499 → $4.543)
[F1]. El precio no es lineal ni dentro de un plan ni entre planes: 100.000 correos cuestan
$82 en Starter y $139 en Standard. Y cada escalón fija además el tope de contactos
almacenados, en los dos sentidos: *"If you have more contacts than the limit allowed for a
given tier, you won't be able to select that lower tier."* [F26].

**Qué hace v0.3.** Un `value` y un `overage_cost` por cuota. La datasheet modela el
**volumen de entrada** (5.000, 5.000 y 150.000) y la escalera entera vive en el provenance,
como en SendGrid y MailerSend.

**Consecuencia.** La misma de siempre —treinta y seis combinaciones volumen-precio
invisibles para cualquier herramienta— con un agravante propio: el último escalón de los
tres deslizadores se llama `"More"` y **no publica ni volumen ni precio**, así que ni
enumerando se podría completar la escalera.

**Propuesta.** La ya formulada (`tiers` con precio propio y un escalón `custom`). Brevo
añade que el `tier` tiene que poder llevar también el **límite de recurso acoplado** (los
contactos), porque aquí el escalón de correos y el de contactos son el mismo escalón.

**Por qué es variante y no ocurrencia plena.** Le falta la mitad del enunciado: **no hay
sobrecoste que varíe, porque no hay sobrecoste**. Ver F-27.

---

## F-03 · CRF multiplicativo entre dimensiones — RECURRE ✅

**Qué pasa.** El lote se hace con `messageVersions` sobre el mismo `POST /v3/smtp/email`:
hasta **1.000 versiones** por llamada [F13], cada una con hasta **99 destinatarios** [F10].
Una petición consume N × M correos.

**Qué hace v0.3.** `workload` tiene una única terna `unit/min/max`. La datasheet declara
`max: 2000`, que es el total que publica la referencia.

**Consecuencia, y es peor que en MailerSend.** Allí el proveedor publicaba el total
(35.000 = 500 × 70) y la aritmética cerraba. **Aquí no cierra**: 1.000 × 99 son 99.000,
casi cincuenta veces los 2.000 que publica la referencia, y el titular de la propia guía
(*"6,000,000 email versions per hour"*) se calcula suponiendo las 1.000 versiones. El
esquema produce **un número plausible y probablemente equivocado**, sin dejar rastro de
que los factores no cuadran. Es la situación que la regla **D10** anticipa —un total que
solo se explica como producto— con la diferencia de que aquí el producto **contradice** al
total en vez de explicarlo (DISC-03).

**Propuesta.** La ya formulada: que el CRF deje de ser una terna escalar y admita
dimensiones compuestas. Brevo añade un requisito: si el fichero pudiera declarar los
factores, la incoherencia entre `1000 × 99` y `2000` sería **detectable por máquina**, y
hoy solo se ve leyendo dos páginas y multiplicando.

---

## F-05 · Results Per Request no serializable — RECURRE ✅

**Qué pasa.** Siete endpoints de consulta con tope por petición, **serializados en la
propia especificación**: `GET /smtp/emails` máx. 1.000 (def. 500), `GET
/smtp/emailStatus/{identifier}` máx. 500, `GET /smtp/templates` máx. 1.000, `GET
/smtp/blockedContacts` máx. 100, `GET /inbound/events` máx. 500, `GET
/smtp/statistics/events` máx. 5.000 y `GET /smtp/statistics/reports` máx. 30 [F20]. Y una
segunda estructura encima: la **ventana consultable**, un mes en los registros [F11] y
noventa días en las estadísticas [F20].

**Qué hace v0.3.** No serializa RPR. La datasheet lleva `workload: unit requests, min 1,
max 1` en las tres consultas modeladas y el tope real en la `description`.

**Consecuencia.** Toda la capacidad de **consulta** queda invisible para las herramientas,
y aquí con un matiz que no había aparecido: es la única dimensión de capacidad de Brevo
que **sí está en el contrato máquina**. La spec serializa los topes de paginación con
`maximum` y `default`, y no serializa ni un `maxItems` de destinatarios, ni el 429, ni las
cabeceras de caudal [F20][F21]. El formato OpenAPI no es el obstáculo —la spec de contactos
usa `maxItems`—: lo que falta es la decisión de publicarlo.

---

## F-06 · Un workload acotado por otra métrica — RECURRE ✅ (5/5)

**Qué pasa.** El tope del envío no es un entero de correos: es **20 MB por correo,
contenido más adjuntos** [F27]. Y dentro de la misma petición hay dos cotas más en una
tercera unidad: *"Individual `params` objects must not exceed 100 KB. Cumulative `params`
across all versions must not exceed 1000 KB."* [F10].

**Qué hace v0.3.** La datasheet declara dos entradas en la lista de `workload` (`emails` y
`MBs`) y las dos cotas en KB se quedan en el provenance, porque `params` es una parte del
cuerpo y no una dimensión del consumo.

**Consecuencia.** Quinta de cinco APIs. La propuesta `max_by: {unit: MBs, value: 20}` sigue
en pie; Brevo añade que las cotas pueden ser **anidadas** (por objeto y acumuladas), que es
un grado más de lo que la propuesta cubre.

**Y la unidad misma es una extensión, que hay que declarar (B1).** `MBs` **no está** en la
lista de `unit` del README: el §4 la cierra en `requests · emails · sms · tokens · records ·
gb · hours · minutes`, y la única unidad de tamaño documentada es `gb`, en minúscula. El
catálogo usa `MBs` desde Postmark —SendGrid y Brevo la heredan, y está en la lista blanca
`KNOWN_UNITS` del validador propio, por lo que no salta ningún aviso— porque pasarla a `gb`
obligaría a escribir 0,02 y perdería legibilidad. Se deja como está y queda **declarada
aquí como extensión** del catálogo sobre el enum de v0.3. Falta la entrada equivalente en el
inventario de propuestas del capítulo 6, que es carril de la memoria y no de esta pasada.

**Y un hallazgo sobre dónde está el dato.** Los 20 MB **no están en la documentación de
desarrollador**. Ni en la referencia del endpoint, ni en la guía de lotes, ni en ninguna de
las dos specs: están en un artículo del centro de ayuda que además devuelve 403 a cualquier
cliente que no sea un navegador [F27]. La otra cifra publicada, 25 MB, está en una página
de marketing y es mayor que el total del correo (DISC-16).

---

## F-07 · Add-ons que modifican dimensiones de capacidad — RECURRE ✅ (5/5)

**Qué pasa.** Brevo tiene el caso más agudo del catálogo. El **crédito prepago** no añade
volumen a un plan: *"Purchase credits to send emails with no daily sending limit"* [F3] —o
sea, **levanta la cuota diaria del plan gratuito**— y encima *"Prepaid email credits give
you access to all Starter plan features and the Remove Brevo logo add-on. The limit of
2,000 contacts in automations also applies."* [F25]. Un complemento de pago que **sustituye
el plan efectivo**. Junto a él, los de siempre: IP dedicada a $251/año, solo Professional
[F4]; asientos de marketing a $10.80/mes con tope de dos [F1].

**Qué hace v0.3.** No hay bloque de add-ons; v0.3 los deriva a Pricing2YAML, que este TFM
no modela (D-001).

**Consecuencia.** En las cuatro APIs anteriores el add-on movía **una** dimensión
(retención, IP, cuota). Aquí mueve **el plan entero**, y con él la cuota, la ventana y el
conjunto de funciones. Un lector de la datasheet ve `quota_email_daily_free: 300` y no
tiene forma de saber que existe un complemento que la borra.

**Propuesta.** Sigue siendo Trabajo Futuro, pero Brevo justifica una precisión: el add-on
no siempre es aditivo; puede ser **sustitutivo**, y eso no se arregla con un bloque de
extras que sume.

---

## F-08 · El plan como producto cartesiano — RECURRE ✅

**Qué pasa.** Dos ejes, no uno. El primero es el de siempre: la **superficie de la API
depende del plan**. La lista oficial niega los webhooks de entrada a Free, Starter y
Standard y se los da a Professional y Enterprise [F2], que es el corte que la datasheet
aplica por **A4**. El segundo es nuevo y es de caudal: los tres tramos General, Advanced y
Extended [F6].

**Qué hace v0.3.** `plans` es una lista plana. Un plan tiene un conjunto de endpoints y,
por endpoint, un `rate`.

**Consecuencia, reescrita el 2026-09-17 (D-048).** El segundo eje **sí cabe**, y la lectura
que decía lo contrario duró un día. El consejo adoptó los **aliases de v0.3** con el
vocabulario del proveedor —`general`, `advanced`, `extended`—, y con eso Professional declara
sus dos tramos elegibles y Enterprise sus tres, en vez de aplanar a 1.000. La datasheet deja
de subestimar 2× el caudal de Professional y 6× el de Enterprise, y los tres `rate` pasan a
verde. Lo que los aliases **no** expresan sigue siendo cuál rige por defecto, y eso va a
`not_found` igual que O-12 hace en MailerSend con el disparador de estado.

**Propuesta, acotada por lo que se midió.** Ya no es «que `plans` gane ejes»: el eje existe.
Lo que falta es más estrecho y más defendible. Primero, que el fichero pueda decir **cuál de
los tramos elegibles está vigente** — sin eso el motor devuelve un resultado por alias y quien
compara no sabe cuál usar. Y segundo, que **dos ejes independientes compongan**: los aliases
son un mapa plano, así que la banda de caudal y el modo de consumo por petición —con adjunto
o sin él, que es DISC-04— no pueden coexistir sobre el mismo endpoint sin escribir su producto
cartesiano. Medido contra el motor el 2026-09-17: `evaluate()` devuelve un resultado por
alias, y el `workload` propio de un alias sustituye al del endpoint en vez de combinarse.

---

## F-09 · Una datasheet no puede decir qué parte sigue vigente — RECURRE ✅

**Qué pasa.** El changelog publica, con fecha, que el régimen de caudal se amplía endpoint
a endpoint: *"Added dedicated rate limits for the following endpoints: `POST
/v3/orders/status` `POST /v3/products`"* [F22].

**Qué hace v0.3.** La datasheet tiene un `date` de fichero y nada más.

**Consecuencia.** El `date: 2026-09-16` dice cuándo se construyó el fichero entero, no
cuándo se comprobó cada campo. Si mañana Brevo añade un caudal dedicado a
`POST /v3/smtp/email` distinto, nada en el fichero lo señala, y el `date` seguirá diciendo
que todo se miró el mismo día. La cuarta API que lo pide.

---

## F-10 · Varios productos y varias unidades de consumo — recurrencia ⚠️ (variante inversa)

**Qué pasa, y es al revés que en Resend y SendGrid.** Allí el problema era que un mismo
SaaS vendía dos productos con **dos unidades**. Aquí hay dos productos y **una sola
unidad**: *"Can I use my emails to send both marketing and transactional emails?" "Yes, you
can use your email credits to send both marketing and transactional emails."* [F26], y el
configurador rotula el deslizador `"Monthly email volume (campaigns & transactional)"`
[F1]. Además cuelgan de la misma cuenta el SMS transaccional, con caudal propio publicado
(150 peticiones por segundo [F6]), y WhatsApp, que solo existe en Professional y Enterprise
[F2].

**Qué hace v0.3.** La datasheet declara `quota_email_monthly_starter: 5000 emails`
referenciada desde el plan.

**Consecuencia — y por qué es de esquema y no de modelado.** Ese 5.000 **no es la cuota del
producto modelado**: es la de la cuenta, y el marketing se la come igual. Aplicar **A1**
(modelar el transaccional) deja una datasheet cuyo campo más importante pertenece a otra
cosa. El esquema no tiene dónde decir «esta cuota es compartida con un producto que este
fichero no describe», así que una herramienta calculará la capacidad transaccional de una
cuenta Starter como 5.000 correos al mes cuando el valor real es *lo que sobre de 5.000*.
El caso de Brevo es más incómodo que el de Resend, donde las dos suscripciones eran
independientes y se veían por separado en el panel.

**Y un detalle que lo agrava.** El producto **no modelado** está mejor documentado: el
envío de campaña declara en la spec la verificación previa de *"send limit and credit
balance"* y su 402 literal; el envío transaccional, que gasta los mismos créditos, no
declara ninguno de los dos [F21].

**Propuesta.** Marcar la cuota como compartida y nombrar con qué. Mientras no exista, la
línea del provenance es lo único que avisa.

---

## F-11 · Límites de recursos por plan, que no son consumo — RECURRE ✅ (5/5)

**Qué pasa.** Brevo los llama *quotas* y los publica en una página propia: *"Quotas limit
the number of objects you can create via the API, UI, or other integrations."* Las cuatro
filas transcritas con literal son *"10,000 email campaigns | 50,000 email campaigns"*,
*"5M stored contacts | 900M stored contacts"*, *"300 created lists | 600 created lists"* y
*"50 active workflows | 500 active workflows"* [F8]. La tabla de la página tiene más filas
—carpetas, atributos, campañas programadas, biblioteca de medios— que **no se
transcribieron** en esta pasada y de las que, por tanto, esta datasheet no afirma ninguna
cifra. A eso se suman los de la lista de precios: usuarios
(`"Single user | Single user | Up to 3 (add-on) | 10 included | Unlimited"`) y contactos
(`"Up to 100K | Up to 500K | Up to 500K | Up to 2M | Unlimited"`) [F2].

**Qué hace v0.3.** Nada: por **B3** no son cuotas y no van a `capacity`. Van al provenance.

**Consecuencia.** Quinta de cinco. Lo específico de Brevo es la **granularidad**: las
*platform quotas* distinguen **dos** tramos (`"General quota"` y `"Enterprise quota"`),
el caudal distingue **tres** y los planes son **cinco**, y la página no dice a qué planes
corresponde `"General"` [F8]. Tres particiones distintas del mismo catálogo comercial,
publicadas en tres páginas, sin un mapa entre ellas.

---

## F-13 · El sobrecoste es opcional y no existe en Free — RECURRE ✅ (llevado al extremo)

**Qué pasa.** En Resend el sobrecoste era un interruptor de pago; en SendGrid y MailerSend,
una opción. En Brevo **no existe en ningún plan**: la página de precios lo niega —*"There
are no hidden fees with Brevo. Sign up for a plan or purchase credits as you need them,
there are no additional fees."* [F1]— y no hay un solo precio por correo excedido en las
cuatro páginas comerciales y los dos artículos del centro de ayuda que tratan el tema.

**Qué hace v0.3.** `overage_cost` es opcional. La datasheet de Brevo **no lleva ninguno**.

**Consecuencia.** Un fichero sin `overage_cost` se lee como «esta cuota es un muro». Para el
plan gratuito es casi cierto (F-24 matiza el «casi»); para los de pago **no se sabe**,
porque el proveedor no publica qué ocurre al agotar el volumen mensual. Y el esquema no
distingue las tres situaciones: *no hay sobrecoste*, *lo hay y no se publica*, y *el exceso
se resuelve de otra forma*. Las tres se serializan igual: con el bloque ausente. Es F-01
—«existe pero sin valor» frente a «no existe»— aplicada a la dimensión del coste, y por eso
la propuesta `status:` de F-01 debería alcanzar también a `overage_cost`.

---

## F-15 · Dos canales, dos workloads para la misma cuota — RECURRE ✅ (3/5)

**Qué pasa.** Brevo ofrece API REST y relay SMTP sobre la **misma cuenta y la misma
cuota**, y los dos canales **no tienen la misma capacidad por operación**: *"The SMTP relay
does not support batch sending. Use the batch sending API endpoints for batch operations.
The SMTP relay is designed for transactional emails."* [F17]. Por API, una petición puede
llevar 2.000 destinatarios; por SMTP, el lote sencillamente no existe.

**Qué hace v0.3.** `workload` cuelga del endpoint. El canal SMTP no es un endpoint y no
tiene dónde colgar.

**Consecuencia.** La datasheet describe la capacidad del canal REST y **calla la del otro
canal de la misma cuota**. Quien integre por SMTP verá un `max: 2000` que no le aplica.
Tercera de cinco. El umbral ya lo cruzó con MailerSend (2/4); esta pasada lo refuerza.

**Propuesta.** Que el `workload` pueda declararse por canal, no solo por endpoint. Brevo
añade que la asimetría puede ser **cualitativa** (existe o no existe el lote) y no solo
numérica, que es como se presentaba en SendGrid y MailerSend.

---

## F-23 · Un comodín de prefijo con excepción, que el esquema no puede escribir — NUEVA

**Qué pasa.** Brevo publica el caudal en **tres niveles de especificidad** sobre la misma
familia de rutas:

1. **tres** rutas con caudal propio bajo `/v3/smtp/` — `POST /v3/smtp/email` y
   `GET /v3/smtp/blockedContacts` a 1.000 peticiones por segundo, y `GET /v3/smtp/emails`
   a 7.200 por hora;
2. el **prefijo** `/v3/smtp/{…}` a 300 por hora, con una excepción escrita al pie que
   nombra **solo dos** de esas tres: *"\*Excludes `POST /v3/smtp/email` and
   `GET /v3/smtp/blockedContacts`, which have dedicated limits."* [F6];
3. `"All other endpoints"` a 100 por hora.

**Y la excepción deja fuera a una ruta que sí tiene fila propia.** `GET /v3/smtp/emails`
tiene caudal dedicado igual que las otras dos y **no aparece** en la nota al pie. Si el
prefijo la alcanza, su tope son 300 por hora y no los 7.200 de su fila, un factor de 24.
La fuente no lo resuelve y no se arbitra: va como **DISC-17**, con las dos citas
enfrentadas, y el hueco está en `metadata.not_found`. Es la misma carencia vista desde
dentro: sin exclusión declarable, ni el proveedor consigue escribir sin ambigüedad a quién
alcanza su propio prefijo.

**Qué hace v0.3.** Un plan admite endpoints enumerados y **un** comodín, `/*`. No hay
comodín de prefijo y no hay forma de declarar una exclusión.

**Consecuencia — medida sobre esta datasheet.** El nivel 2 **no se puede escribir**. Las
salidas posibles son tres y las tres son malas: enumerar todas las rutas bajo `/v3/smtp/`
(el proveedor no publica la lista, y el changelog demuestra que cambia [F22]); usar `/*`
para los 300 por hora y **triplicar** el caudal real del resto de la API, que son 100;
o usar `/*` para los 100 y **dividir por tres** el de la familia `/smtp/`, que es lo que
hace la datasheet por ser la lectura conservadora. El fichero, por tanto, **subestima** el
caudal de toda la familia `/v3/smtp/` salvo los dos endpoints dedicados, y no hay ningún
sitio donde decirlo salvo el provenance, que ninguna herramienta lee.

**Propuesta.** Dos piezas, y la segunda es la que no existe en ningún otro sitio del
esquema: (a) comodines de **prefijo** además del global —`/smtp/*` junto a `/*`—, con la
regla de que gana el más específico; (b) una lista de **exclusión** por comodín, porque el
proveedor publica el límite en esa forma y no en otra. Sin (b), (a) no basta: un
`/smtp/*` a 300 por hora seguiría atrapando a los dos endpoints que están fuera.

**Listón D-042.** **L1 cumplida** (literal citado de la fuente canónica). **L2 CUMPLIDA,
medida el 2026-09-18** con la Datasheet delante y sin tocarla. Preguntado por
`/v3/smtp/statistics/events`, una ruta real del prefijo de 300 por hora, el motor **no
responde**: `KeyError: "Endpoint '/v3/smtp/statistics/events' not found in plan 'free'. Valid
endpoints are: ['/*', '/v3/smtp/email', '/v3/smtp/emails', '/v3/smtp/blockedContacts']"`. El
**caso de control** es la misma consulta sobre `/v3/smtp/emails`, que sí está declarada y sí
contesta: `[{'value': 2.0, 'unit': 'requests', 'period': '1s'}, {'value': 300.0, 'unit':
'emails', 'period': '1day', 'overage_cost': None}]`. El motor responde cuando el esquema se
lo permite. Y la única respuesta que el fichero puede dar para esa familia de rutas también
está medida: preguntado por `/*`, devuelve `[{'value': 100.0, 'unit': 'requests', 'period':
'1h'}, …]`, **tres veces por debajo** de las 300 por hora que el proveedor publica para el
prefijo. **L3 NO cumplida, y el intento del 2026-09-18 se cayó en la revisión.** Lo
documental es cierto: el único comodín que el esquema documenta es el global, *"`/*` actúa
como \"catch-all\". Cualquier endpoint que no aparezca explícitamente hereda los valores de
`/*`"* (§3.4.1), y la tabla de versiones no trae ninguna otra forma. Pero de ahí no sale que
el nivel intermedio **no se pueda escribir**. Sale que no se puede escribir **en corto**: con
`/*` a 100 por hora más una entrada explícita por cada ruta del prefijo, el mecanismo
existente lo expresa. Y la lista de rutas **existe y está archivada**, [F29], donde
`swagger_definition_v3_2026-09-18.yml` trae 207 rutas y dieciocho cuelgan de `/smtp/`. El
argumento que se había escrito —que el proveedor no publica la lista— es falso contra el
propio expediente. **Y aplicarlo así sería doble rasero**: la celda de MailerSend de esta
misma fila se descartó por exactamente esto, «el esquema SÍ la escribe: `/*` más el endpoint
explícito». Lo que sí se pierde por enumerar es concisión y robustez ante un changelog que
mueve rutas, y ese es otro enunciado, más débil, que habría que reformular antes de volver a
intentar la traza. Lo que sigue en pie: ningún defecto del motor lo explica —**DV-01** a
**DV-05** son otra cosa—. **L1 completa desde el 2026-09-21.** Lo que B9 pedía —«un literal citado o un sondeo ejecutado, **con su fila en `hechos_*.md` y su fichero en `evidencias/`**»— está entero: la fila vive en `05_salida/_cap5/hechos_brevo.md` y el volcado verbatim de la página en `evidencias/paginas/2026-09-21/`. **Lo que bloquea a F-23 ya no es L1, es L3**, y por lo dicho arriba: con las 207 rutas de [F29] archivadas, `/*` más una entrada explícita por ruta sí escribe el comodín con excepción.

---

## F-24 · Cuota blanda: superada, absorbe hasta N y luego descarta en silencio — NUEVA

**Qué pasa.** Al agotar los 300 correos diarios del plan gratuito, Brevo **no rechaza**:
*"Transactional emails: once you reach your daily limit, up to 1,000 additional emails are
held in a retry queue. Emails beyond this queue are not delivered."* [F24]. El mismo
contenido aparece en un segundo artículo del **mismo centro de ayuda** [F26], con una
diferencia de encabezado —[F24] lo restringe a *"Transactional emails:"* y [F26] no—, así
que no son dos fuentes independientes sino una repetida. O sea: entre el correo 301 y el 1.300 la
petición se acepta y el correo espera; a partir del 1.301 se descarta **sin entregar y sin
que el literal mencione ningún error**.

**Qué hace v0.3.** Una cuota tiene `value`, `period`, `window_type` y, opcionalmente,
`overage_cost`. Dos comportamientos posibles en el borde: muro, o exceso facturado.

**Consecuencia.** Este es un **tercero**, y el esquema no solo no lo expresa: lo
**contradice**. La datasheet declara `quota_email_daily_free: 300` sin `overage_cost`, que
se lee como muro duro, y la realidad publicada es que la capacidad efectiva del día llega a
1.300 con entrega degradada y sin coste. Un consumidor que dimensione con 300 se queda
corto por un factor de 4,3; uno que cuente con la cola no tiene dónde leer que existe. Y la
franja de absorción tiene consecuencias que el modelo tampoco ve: el correo 1.301 se pierde
**en silencio**, que es peor que un 429, porque el 429 se puede reintentar.

**Propuesta.** Un `overflow` en la cuota con tres campos: `capacity` (cuántas unidades
absorbe), `behavior` (`queued` | `degraded` | `dropped`) y `cost`. Con eso, «muro duro» es
`overflow` ausente, «sobrecoste» es `behavior: billed` con precio, y el caso de Brevo se
escribe tal cual. Emparenta con la propuesta `status:` de F-01: las dos piden que el
esquema distinga **qué clase de límite** es, y no solo su número.

**Listón D-042.** **L1 cumplida** con el literal de [F24], que es el que acota el
comportamiento al transaccional; [F26] lo repite sin ese encabezado y es del mismo centro
de ayuda, así que **no** cuenta como segunda fuente independiente. **L2 CUMPLIDA, medida el
2026-09-18**. El motor devuelve para el Free de Brevo `{'value': 300.0, 'unit': 'emails',
'period': '1day', 'overage_cost': None}`. Es **la misma forma exacta** con la que devuelve el
muro del Free Trial de SendGrid, `{'value': 100.0, 'unit': 'emails', 'period': '1day',
'overage_cost': None}`. El mismo caso de control enseña los dos comportamientos que v0.3 sí
distingue: los planes de pago de SendGrid vuelven con `overage_cost: {'price': 0.0013,
'value': 1.0}` y `{'price': 0.0011, ...}`. Muro y exceso facturado caben en el esquema. El
tercero no. **Una cuota que absorbe 1.000 y luego descarta en silencio queda escrita como un
muro seco**, y quien dimensione con ella se queda corto por un factor de 4,3: 300 frente a
los 1.300 que el proveedor llega a entregar.
**L3 comprobada contra `readme0.3.md` el 2026-09-18, y en pie.** Una cuota
tiene cinco campos y ninguno describe una franja: *"`value`"*, *"`unit`"*, *"`period` |
Ventana temporal"*, *"`window_type` | Tipo de reinicio"* y *"`overage_cost` | _(opcional)_
Coste por exceso | Objeto con `price` y `value`"* (§3.2). El único campo del borde presupone
que el exceso se cobra. **El absorbente que hay que descartar, y se descarta escribiéndolo:**
un `overage_cost` con `price: 0` sería una escritura legal —**B6** solo exige que el precio
sea unitario— y diría «el exceso es gratis». No dice ni que se absorban **1.000** ni que a
partir de ahí se **descarte en silencio**, que son las dos mitades del enunciado. Tampoco lo
explica ningún defecto del motor: **DV-01** a **DV-05** no tocan la forma de la cuota. **La fricción PROMUEVE por traza** (B9, caso medido, una API). **L1 completa desde el 2026-09-21.** Lo que B9 pedía —«un literal citado o un sondeo ejecutado, **con su fila en `hechos_*.md` y su fichero en `evidencias/`**»— está entero: la fila vive en `05_salida/_cap5/hechos_brevo.md` y el volcado verbatim de la página en `evidencias/paginas/2026-09-21/`. Era lo único que faltaba. Precedente de promoción por traza con una sola API: F-16 y F-21.

---

## F-25 · Un endpoint, dos modos excluyentes, y una carga que depende de otro campo — NUEVA

**Qué pasa.** Dos cosas, y las dos sobre `POST /v3/smtp/email`:

- **Dos modos con perfiles de carga distintos.** El envío simple usa `to`; el lote usa
  `messageVersions`, con 2.000 destinatarios por petición y 99 por versión. El 2026-09-16
  la guía leída decía que mezclarlos rompe la petición: *"Do not pass an outer `to`
  parameter. … If you include an outer `to` parameter, the request will fail."* [F13].
  **Releída el 2026-09-21, la misma frase cierra de otra manera**: *"… it is ignored in
  favor of the recipients defined in messageVersions."* No había volcado del 16, así que la
  relectura no distingue si el registro se equivocó o si el proveedor cambió la página, y
  **E8** resuelve el caso: se anotan las dos fechas, la cita no cae y esto es evidencia de
  **F-09**. Lo que cambia es el adjetivo, no la fricción: «excluyentes» describe un rechazo
  y el literal de hoy describe una precedencia, pero los dos modos siguen consumiendo el
  endpoint de formas distintas y el esquema sigue sin poder decirlo. Cuál de las dos frases
  describe la API **está sin medir**, y la medida existe: el caso `p7_to_y_messageversions`
  de `probe_brevo_a_preflight_rechazo.sh` manda las dos formas a la vez en modo sandbox y
  nunca se ha ejecutado.
- **Una carga condicionada a la presencia de un campo.** *"If you add an attachment in your
  API script, you can only send your transactional email to a maximum of 99 recipients."*
  [F27]. El mismo endpoint, el mismo modo: el tope cae de 2.000 a 99 **según haya adjunto o
  no**.

**Qué hace v0.3.** `workload` es una lista de dimensiones —`emails`, `MBs`— de **una**
petición. No hay condicionales, y una segunda entrada con la misma `unit` se leería como
otra dimensión, no como otro modo.

**Consecuencia.** El fichero tiene que elegir **un** número y el elegido es falso en la
mitad de los casos. Con `max: 2000` (lo que lleva la datasheet) se sobrestima veinte veces
el envío con adjunto; con `max: 99` se subestima el caso común. No es como F-03, donde el
número sale de un producto mal cerrado: aquí **hay dos números correctos** y el esquema
solo tiene sitio para uno. Y no es como F-06, donde la cota vive en otra métrica: la métrica
es la misma, lo que cambia es **la forma del cuerpo**.

**La misma carencia muerde también en `MBs`, y se anotó el 2026-09-21.** Hasta hoy esto se
instrumentaba solo en la dimensión `emails`, con los 2.000 y los 99. Al cerrar **DISC-16** se
vio que el tope de tamaño tiene el mismo problema un eje más allá: el README titula su §3.4.2
*"`workload` — Carga de trabajo por petición"* y [F27] acota *"transactional emails"*, por
correo, en un endpoint que admite 2.000 destinatarios por petición. Fuera del envío simple los
dos denominadores no coinciden, y «20 MB por cada uno de los N» no tiene forma en el fichero.
**No se numera fricción nueva**: por **V2 de B10** ese literal ya cuenta como ocurrencia plena
en **F-06**, que lo escribe como «20 MB por correo», y el mismo hecho no suma dos veces. Y el
veredicto de F-25 no se retoca: sigue sin promover por L3, por el mismo medio mecanismo.

**Propuesta.** Permitir varios `workload` alternativos por endpoint, cada uno con una
`condition` legible —`has: attachment`, `mode: messageVersions`— y la regla de que se
aplica el primero que case. Es menos que un lenguaje de condiciones: basta con que el
fichero pueda decir «este endpoint tiene dos perfiles de carga y estos los distinguen».
La dimensión `MBs` entra en la misma propuesta sin cambiarla: lo que hace falta es que el
perfil pueda declarar su denominador.

**Listón D-042.** **L1 cumplida** (los dos literales). **L2 CUMPLIDA, medida el
2026-09-18: no hay campo donde hacer la pregunta.** El motor no devuelve un número falso. Su
petición tiene seis campos —`datasheet_source`, `plan_names`, `endpoint_path`, `alias`,
`operation` y `operation_params`—, y el único que podría llevar la condición «con adjunto» es
`alias`. En esta Datasheet ese eje **ya está gastado**: `get_aliases` devuelve `['general',
'advanced', 'extended']`, los tres tramos de caudal. Los dos datos están en el volcado, que
los archiva desde la segunda pasada: la primera los comprobó a mano y la afirmación remitía a
una ejecución que no los contenía. Lo que el volcado **no** trae es ninguna cifra de carga:
los doce escenarios de `/v3/smtp/email` traen `workload_unit` —seis en `emails` y seis en
`MBs`— y ningún máximo, así que el tope de 2.000 se lee del fichero y no de la ejecución. **L3 NO cumplida, y el intento del 2026-09-18 se cayó en la revisión por dos
sitios.** Primero, el README **sí documenta** el mecanismo para la mitad de los modos: su
tabla de casos típicos de alias trae la fila *"Modo de operación | `sync` · `async` ·
`batch`"* (§3.4.3), que es exactamente «un endpoint, dos modos». Y segundo, la evidencia
archivada desmiente que el eje esté gastado en este fichero: en
`evidencias/l2_prime4api_2026-09-18.json` los doce escenarios de `/v3/smtp/email` salen con
`"alias": "None"` en **free, starter y standard**, y solo professional trae `general` y
`advanced`. `get_aliases` agrega el fichero entero, no el endpoint por plan. Lo que sí sigue
en pie, y es la mitad que no se cae: **ninguna línea del README documenta un `workload` propio
por alias** —la sobreescritura que sí documenta es la de `quota`—, así que la carga
condicionada no tiene dónde ir aunque el modo sí lo tenga. Con media carencia absorbida, L3
no se cumple como está y el enunciado hay que partirlo antes de reintentarlo. Lo de abajo se
conserva porque describe la mitad que aguanta.

**Lo que decía el intento, conservado:** El esquema sí tiene un eje condicional, los aliases, y el
README dice para qué sirve: *"Un mismo endpoint puede tener **diferentes comportamientos o
límites** según la forma en que el usuario lo consume"* (§3.4.3). Pero lo que un alias puede
sobreescribir está documentado y es **la cuota**, no la carga: la sección dedica dos
apartados a *"Posición de `quota` cuando hay aliases"*, con el caso mixto en el que *"el
alias diferente la sobreescribe con la suya dentro de su bloque"*, y en los cinco ejemplos el
`workload` se queda **a nivel de endpoint, por encima de los aliases**. Ninguna línea
documenta un `workload` propio por alias. El matiz, que es lo que impide cantar victoria: si
se admitiera esa sobreescritura, el mecanismo existiría para una API con el eje libre, y en
Brevo no lo está —los aliases los gastan los tres tramos de caudal— porque los aliases son un
mapa plano y dos condiciones independientes no componen, que es **F-08**. **Las tres
condiciones están: PROMUEVE por `traza`**, y la propuesta se escribe sobre el eje que el
README ya tiene, no sobre uno nuevo.
Nota sobre SendGrid: `personalizations` **ya está inventariado** como variante acotada de
F-03, medida con [E1], y allí el proveedor publica el tope total (1.000) sin que existan
dos modos excluyentes. Marcarlo aquí como ocurrencia contaría la misma evidencia dos
veces, así que la celda va *(verificar)*: lo que hay que comprobar es si **además** existen
dos modos excluyentes, no si existe el producto N×M.

---

## F-26 · Un precio por geografía y una sola divisa en el fichero — NUEVA

**Qué pasa.** La página de precios sirve **ocho divisas** —`"EUR (Euro)"`, `"USD (US
Dollar)"`, `"GBP (British Pound)"`, `"BRL (Brazilian Real)"`, `"INR (Indian Rupee)"`,
`"CAD (Canadian Dollar)"`, `"AUD (Australian Dollar)"`, `"CHF (Swiss Franc)"`— y
**geolocaliza**: desde España sirve EUR por defecto, con Starter 7, Standard 15 y
Professional 499. El bloque JSON-LD publica la oferta en cada divisa. Y las cifras **no son
conversiones**: 9 USD frente a 7 EUR no es un tipo de cambio, es otro precio [F1]. Ninguna
fuente declara cuál es la de referencia.

**Qué hace v0.3.** `currency` es **un** campo de cabecera, uno por datasheet. La de Brevo
declara USD, que es la divisa del JSON-LD y la del centro de ayuda.

**Consecuencia.** La datasheet describe **una** de las ocho ofertas comerciales del
proveedor, y no dice que lo es. Una comparación entre APIs del catálogo hecha en USD sitúa
a Brevo en $9 cuando para el autor de este TFM, que compra desde España, el precio es 7 €
—unos 7,60 $ al cambio del día, un 15 % menos—. Las curvas de coste salen desplazadas y
nada en el fichero avisa. El caso no se arregla con una nota: es que el precio **depende del
comprador**, y el esquema modela el precio como propiedad del producto. Añádase que los
precios están publicados **sin impuestos** (*"The prices shown in this article and on our
pricing page are exclusive of taxes."* [F25]), lo que abre una segunda dependencia
geográfica sobre el mismo número.

**Propuesta.** Dos piezas. (a) Que `price` admita una **lista de ofertas** con su divisa, y
que `currency` pase a ser la divisa de referencia declarada en vez de la única posible.
(b) Un campo que diga si el precio es con o sin impuestos, que hoy no existe y que cambia
la cifra entre el 0 % y el 27 % según el país.

**Listón D-042.** La fricción **cruza por recurrencia** —2 de 5 en la mitad de la divisa y
3 de 5 en la de los impuestos—, que es la primera vía de **B9**, así que el listón no le hace
falta. Aun así, **L3 queda comprobada contra `readme0.3.md` el 2026-09-18** y conviene
tenerla escrita: la divisa es **un campo de cabecera y uno solo**, *"`currency` | Divisa
utilizada en todos los precios del documento | `USD` · `EUR` · `GBP`"*, el precio del plan no
lleva divisa propia —*"`price` | Precio del plan (numérico o `custom`), en la divisa declarada
en `currency`"*— y la tabla de cambios la estrena así en v0.3: *"`currency` | — | — |
**Nuevo** — divisa global del documento"*. **L2 sigue pendiente** y no bloquea nada. Nota: es la fricción de esta tanda con más probabilidad de recurrir —
cualquier proveedor con página de precios localizada la tiene—, así que antes de intentar
la traza conviene mirar SendGrid y MailerSend, marcadas *(verificar)*.

---

## F-27 · El exceso no se paga por unidad: cambia el plan, y lo dispara otra dimensión — NUEVA

**Qué pasa.** Brevo **no publica ningún precio por correo excedido**, en ninguno de los
cuatro planes de pago. Lo que publica son otras tres cosas:

1. **Auto-ascenso disparado por contactos, no por correos.** *"If you reach or exceed that
   limit, we will automatically upgrade your plan to the next tier."* y *"The cost of your
   subscription will increase accordingly."* [F25]. El ejemplo del proveedor es explícito:
   1.501 contactos en un Starter de 1.500 sube el plan entero al escalón siguiente.
2. **Cambio de escalón prorrateado.** *"When adding emails to your plan, you are charged
   immediately, with a pro-rated charge from the date of your purchase to your next billing
   date."* [F26].
3. **Créditos prepago.** *"One credit equals one email sent to one contact."* [F25], en
   siete paquetes de 5.000 a 1.000.000 [F3].

**Qué hace v0.3.** `overage_cost` es un precio **por unidad de la propia cuota**, dentro
del propio plan.

**Consecuencia.** Ninguno de los tres mecanismos cabe. El (3) es lo más parecido a un
sobrecoste y **no lo es**: es una compra a granel, con precio decreciente por paquete, que
además cambia el plan efectivo (F-07). El (2) no es exceso, es renegociación. Y el (1) es
el que no tiene precedente en el catálogo: **el disparador y el efecto viven en
dimensiones distintas**. Se rebasa un límite de **contactos** —que por **B3** ni siquiera
es una cuota, es un límite de recurso que no va a `capacity`— y el efecto es que **sube el
precio del plan**. Es decir, una dimensión que el esquema excluye por no ser consumo tiene
la consecuencia económica más automática de todo el modelo comercial de Brevo. Una
herramienta que calcule el coste a doce meses desde esta datasheet no puede ver la subida,
porque el número que la dispara no está en el fichero.

**Propuesta.** Que el exceso deje de ser un solo precio y pase a ser un **mecanismo
declarado**: `on_exceed` con `billed` (precio por unidad, lo de hoy), `upgrade` (a qué
escalón y disparado por qué dimensión), `prepaid` (paquetes con su precio) y `blocked`. Y,
para el caso (1), que un límite de recurso pueda declararse como **disparador** aunque no
sea una cuota: es la grieta que B3 deja abierta y que hasta ahora no había hecho daño.

**Listón D-042.** **L1 cumplida** (los tres literales). **L2 CUMPLIDA, medida el
2026-09-18**. El motor devuelve un **coste plano** para Brevo a las tres demandas: 1, cien
mil y diez millones de correos. Free 0, Starter 9, Standard 18 y Professional 499 dólares, la
misma cifra en las tres, con cero cuotas elásticas. El **caso de control** es MailerSend, que
sí tiene `overage_cost`: 7 → 149,5 → 14.999,5 en Hobby, 35 → 100 → 12.970 en Starter y 110 →
175 → 13.045 en Professional. El Enterprise de Brevo no entra en la medida: falla con `could
not convert string to float: 'custom'`, que es **DV-03**. Por eso cada plan se consulta
aislado: preguntando por todos a la vez, ese fallo se llevaba la consulta entera. **L3 CUMPLIDA, comprobada contra `readme0.3.md` el 2026-09-18.**
El único campo de exceso del esquema es *"`overage_cost` | _(opcional)_ Coste por exceso |
Objeto con `price` y `value`"* (§3.2), y cuelga de la cuota que se rebasa. Eso fija dos cosas
que el caso de Brevo rompe: el exceso se paga **por unidad de esa misma cuota**, y el
disparador **es** esa cuota. Aquí el efecto es un **cambio de plan**, y para eso no hay campo en
ningún sitio del esquema. El argumento del disparador, en cambio, **se retira**: se apoyaba en
**B3**, que es regla de este catálogo y no del README, y además su lista —dominios, webhooks,
usuarios, servidores, claves, créditos— no nombra los contactos. El README deja `unit` abierta
y admite `records`, así que una cuota de contactos **sí** se podría declarar. La carencia es el
efecto, no el disparador. `tiers`, la propuesta de F-02, tampoco lo absorbe: describe la escalera
de precios, no la regla de transición entre escalones. Y no lo explica ningún defecto del
motor: **DV-03** tumba el plan `custom`, pero los otros cuatro planes contestaron y el coste
salió plano. **La fricción PROMUEVE por traza** (B9, caso medido, una API). **L1 completa desde el 2026-09-21.** Lo que B9 pedía —«un literal citado o un sondeo ejecutado, **con su fila en `hechos_*.md` y su fichero en `evidencias/`**»— está entero: la fila vive en `05_salida/_cap5/hechos_brevo.md` y el volcado verbatim de la página en `evidencias/paginas/2026-09-21/`. Era lo único que faltaba. Precedente de promoción por traza con una sola API: F-16 y F-21.

---

## F-28 · Una lista de IP autorizadas decide si la llamada entra — NUEVA, y recurre

**Qué pasa.** El proveedor mantiene un registro de direcciones IP y, con el interruptor
puesto, rechaza la petición que no venga de una de ellas. En el panel de Brevo, el
2026-09-17: *"Unauthorized IP addresses are not blocked for your API keys"*, *"To secure
your account and API keys, activate blocking of unauthorized IP addresses for API keys to
restrict API calls to authorized IP addresses only."* y *"Before activating, confirm that
your calling IP addresses are listed under Security → Authorized IPs"*
(`evidencias/panel_brevo_2026-09-17.md`). El control es **por familia de credencial**: hay
un interruptor para las claves de API y otro para las SMTP.

**Recurre, y la segunda ocurrencia es más fuerte que la primera.** MailerSend no lo ofrece
como opción de panel: lo tiene **documentado como rechazo**, *"Your IP address is not
allowlisted. #MS40305"*, en la tabla de errores de su referencia, y además **condicionado
al plan** —`IP allowlisting` aparece solo en las dos columnas altas de su matriz—. Postmark
y SendGrid nombran el mecanismo en su panel y en su página de precios (`IP Allowlist`, `IP
Access Management`) sin literal del efecto, así que cuentan como parciales. Resend no lo
tiene.

**Qué hace v0.3.** Nada. El esquema declara qué se puede consumir y cuánto, y da por hecho
que la petición bien formada y autenticada entra. No hay campo para una condición de
admisión que no dependa ni del plan ni del consumo.

**Consecuencia.** Dos clientes del mismo plan, con la misma cuota y el mismo caudal,
tienen capacidad efectiva distinta: uno responde y el otro recibe un rechazo que ninguna
cifra del fichero predice. Y en MailerSend la puerta **es del plan**, así que la
capacidad alcanzable cambia con el tier sin que ninguna cifra de `capacity` se mueva —es
la familia de F-08, pero por la vía del control de acceso y no por la de la superficie—.

**Propuesta.** Que las condiciones de admisión ajenas al consumo sean declarables: una
lista de `access_conditions` a nivel de plan o de credencial, con su disparador y su
efecto, que una herramienta pueda leer antes de prometer capacidad.

**Listón D-042.** **Cruza por recurrencia (2/5 plenas, B9 primera vía)**: Brevo y
MailerSend con literal, Postmark y SendGrid parciales. **L2 pendiente** y **L3 pendiente**:
por esta vía no hacen falta, pero la propuesta no se ha contrastado formalmente contra
`readme0.3.md`.

---

## Familia aparte: características no capacitarias (decisión Q6, 2026-09-01)

| Rasgo | Brevo | Qué es |
|---|---|---|
| Entregabilidad | IP dedicada $251/año, solo Professional; incluida en Enterprise [F4][F2] | F-07 |
| Aprobación de cuenta | *"Once we approve your account for sending"* [F1] y el código `account_under_validation` [F9], sin cifras ni criterios | Puerta previa a la capacidad; sin cifras no genera alias (D7) |
| Canal SMTP | Puertos 587, 2525 y 465; misma cuota, sin lote, sin límites numéricos [F17] | F-15 |
| Modo sandbox | `X-Sib-Sandbox: drop`, valida sin entregar ni registrar [F16] | Vía de sondeo a coste cero |
| Retención de registros | `"unlimited log retention"` frente a `"Customized log retention"`, sin periodo en ninguna [F1][F2]; el panel la fija entre 1 y 24 meses [F30] | Política (B4); DISC-10 cerrada por E5 (1) |
| Idempotencia | Clave UUID con TTL de 30 minutos [F15][F5] | Ventana que no es de capacidad, pero condiciona el sondeo |
| Programación | Hasta 72 horas y desfase declarado de 5 minutos [F14][F10] | Límite temporal no consumible |
| Webhooks agrupados | Hasta 500 eventos por lote, ventana de 5 minutos [F19] | Capacidad de salida del proveedor, fuera de v0.3 |
| Alojamiento de datos | *"France and Germany (EU-based servers)"* [F5] | Cumplimiento, no capacidad |

---

## Observaciones sobre el proveedor y sobre el método

**O-15 · Los «dos caudales simultáneos» son uno solo publicado dos veces — CANDIDATA
RETIRADA.** El material de recolección propuso como fricción de primer orden que Brevo
declara RPS y RPH a la vez y obliga a respetar los dos (*"When both apply, you must respect
both simultaneously."* [F6]), mientras B8 exige declarar cada límite una vez y v0.3 admite
un solo `rate` por endpoint. **Comprobado fila a fila, la carencia se disuelve**: en las
**diez** filas de [F6] que publican las dos unidades, el RPH es exactamente el RPS por
3.600.

| Tramo · ruta | RPS | RPH publicado | RPS × 3.600 |
|---|---|---|---|
| General · `POST /v3/smtp/email`, `GET /v3/smtp/blockedContacts` | 1.000 | 3.600.000 | 3.600.000 |
| General · `GET /v3/smtp/emails` | 2 | 7.200 | 7.200 |
| General · `/v3/contacts/{…}` | 10 | 36.000 | 36.000 |
| General · `POST /v3/transactionalSMS/send` | 150 | 540.000 | 540.000 |
| General · `POST /v3/events` | 10 | 36.000 | 36.000 |
| General · `POST /v3/orders/status` | 5 | 18.000 | 18.000 |
| General · `POST /v3/products` | 2 | 7.200 | 7.200 |
| Advanced · `POST /v3/smtp/email`, `GET /v3/smtp/blockedContacts` | 2.000 | 7.200.000 | 7.200.000 |
| Advanced · `GET /v3/smtp/emails` | 3 | 10.800 | 10.800 |
| Advanced · `/v3/contacts/{…}` | 20 | 72.000 | 72.000 |

Diez de diez. El RPH es el RPS sostenido durante la hora entera, así que **no restringe
nada que el RPS no restrinja ya**: serializar el RPS y anotar el RPH en el provenance no
pierde información. Las filas que publican **solo** RPH —`/v3/smtp/{…}` a 300, `"All other
endpoints"` a 100— sí son topes independientes (300 por hora son 0,083 por segundo, que
ningún RPS publicado impone) y se serializan como tales.

La fricción se reabriría el día que una fila rompa la identidad. Se deja escrito porque el
resultado negativo también es resultado: la carencia aparente se midió y no estaba, y eso
es exactamente lo que el listón L1 pide —hecho, no juicio— aplicado en la dirección
contraria.

**O-16 · El contrato máquina no menciona el caudal ni una sola vez.** Búsqueda literal
sobre `swagger_definition_v3.yml` **completo y archivado**, 1.162.191 bytes y 207 rutas
[F29]: `"rate limit"`, `"rate-limit"`, `"requests per"`, `"RPS"`, `"RPH"`, `"per hour"`,
`"per minute"`, `"per second"` y `"x-sib"` → **cero coincidencias**. La observación nació
el 16-09 sobre una captura de 145.561 bytes que nadie guardó [F21], y el 18-09 se repitió
sobre el fichero entero: **el hallazgo aguanta y la cifra de bytes era falsa**. Ni el caudal, ni sus unidades, ni las tres
cabeceras que la documentación dice que vienen en **todas** las respuestas [F7]. Y dentro
del mismo fichero hay una asimetría que descarta la excusa del formato: `/transactionalSMS/sms`
**sí** declara `402` y `429` con mensaje literal, y `/smtp/email` declara solo `201`, `202`
y `400`. La especificación troceada es aún más pobre: omite el `202` (DISC-05) y tampoco
contiene la cadena `"429"` en ninguna de sus 21 rutas [F20].

Es la tercera API del catálogo donde la vía «OpenAPI primero» del checklist daría una
datasheet peor que la prosa (**recurrencia de O-06**, con SendGrid y MailerSend). Pero
Brevo lo lleva más lejos que las dos: allí la spec iba *por detrás* de la prosa; aquí el
régimen de límites **no existe en el contrato**. Para el capítulo 6 es el argumento más
limpio que ha dado el catálogo a favor de un modelo de *pricing* legible por máquina: el
proveedor documenta el caudal con esmero —tres tramos, con nueve, cinco y seis filas, y
changelog fechado— y lo publica **solo** en HTML para humanos.

**O-17 · DV-03 se reproduce en Brevo, y no es culpa de esta datasheet.** Ejecutado
`verificar_prime4api.py` contra el PRIME4API local el 2026-09-16, con los cinco planes:
**9 OK / 13 ERR** (salida archivada en `evidencias/verificar_prime4api_2026-09-16.txt`), y
los trece errores son el mismo, `ValueError: could not convert string to float: 'custom'`,
del plan Enterprise. Las doce operaciones que fallan —curvas,
presupuesto y las siete operaciones de límites— **no son del plan Enterprise**: son del
fichero entero, que queda inutilizable por un plan de cinco. SendGrid, con `premier` y la
misma forma, da **8 OK / 13 ERR** con los mismos trece mensajes. Es decir: **el resultado
es el conocido DV-03**, no un defecto de Brevo ni de esta pasada, y la regla **A3** obliga
a incluir Enterprise porque tiene tarjeta en la lista oficial. Se anota para que la
ejecución quede fechada y para que nadie lea el «NO CONFORME» como un fallo de modelado.
La navegación básica sí pasa: `nav.plans` devuelve los cinco, `nav.endpoints` los cinco
—`/*`, `/v3/smtp/email`, `/v3/smtp/emails`, `/v3/smtp/blockedContacts` y
`/v3/inbound/events`—,
`nav.capacity_units` las tres y `nav.aliases` `null`. Ese `null` **describe** el fichero,
no lo valida: era la consecuencia de la lectura conservadora de Q1. **Desde D-048 ya no
aplica:** el consejo adoptó los aliases —`general`, `advanced` y `extended`, vocabulario del
proveedor, que es lo que D7 ampliada exige—, así que `nav.aliases` devuelve los dos tramos de
Professional y los tres de Enterprise. Comprobado contra el motor el 2026-09-17. En Enterprise
el alias queda declarado y **no ejercitable**, porque su `price: custom` tumba toda consulta
del plan: es DV-03, no un defecto del alias.

**O-18 · El caudal del comodín y el del plan no son el mismo objeto, y v0.3 los confunde.**
La datasheet declara el caudal de `"All other endpoints"` en el comodín `/*` y **no** al
nivel del plan, por la misma razón que MailerSend: ese 100 por hora es *"All **other**
endpoints"*, o sea, expresamente **no** el de los endpoints con caudal propio. Declararlo
como `rate` del plan diría que el plan entero va a 100 por hora, lo que `/v3/smtp/email`
(1.000 por segundo) desmiente, y PRIME4API concatena el del plan con el del endpoint sin
deduplicar (DV-05). Segunda API del catálogo en la que el literal del proveedor
—«todos los demás»— obliga a dejar vacío un campo que el esquema ofrece. No es fricción
nueva: es F-23 vista desde el otro lado, y se anota aquí para que la ausencia del `rate` de
plan no se lea como un olvido.

**Y con una consecuencia que esta pasada tuvo que corregir.** Si el `rate` no está en el
plan, tampoco llega al endpoint: el README §3.4.1 dice que `/*` alcanza a los endpoints
*"que no aparezca[n] explícitamente"*, y PRIME4API ni siquiera implementa esa herencia
—cero ocurrencias de `/*` en `datasheet_evaluator_service.py`; en `_process_node` un
endpoint solo hereda `plan_rates` y `plan_quotas`—. `/v3/inbound/events` estaba enumerado
sin `rate`, así que el motor lo evaluaba **sin ningún tope de caudal**: `limits` devolvía
solo la cuota y `min_time(capacity_goal=1000)` devolvía **lista vacía**, es decir, no
respondía. Declarado `rate: rate_request_other_general` —los 100 por hora que [F6] publica
para *"All other endpoints"*, y que no choca con B8 porque el plan no declara ninguno—,
`limits` devuelve `Rate(100 requests/1h)` y `min_time` devuelve **9h**. Las dos ejecuciones
están en `evidencias/prime4api_inbound_sin_rate_2026-09-16.txt`. Sirve además de caso de
control para la L2 de F-23: el motor sabe responder bien cuando el caudal está donde lo
lee.

**O-19 · Dos formas del catálogo que v0.3 no define, declaradas.** No son hallazgos de
Brevo —las llevan las cinco datasheets— pero **B1** exige que lo que no cabe en el esquema
se diga, y hasta ahora no estaban dichas en ningún `fricciones.md`. (a) La unidad `MBs`,
fuera del enum del §4 del README (detalle en F-06). (b) El campo `metadata.not_found`: el
§3.5 del README solo declara `sources_visited` y `data_provenance`, así que `not_found` es
un campo extra. Está sancionado por el proyecto —aparece en
`03_datos/_plantilla/datasheet.template.yaml` y lo invocan B1, B3, B7, A3, A4 y D6 de
`CRITERIOS.md`—, y su razón de ser es que **la ausencia documentada sea un dato y no un
silencio**, que es media tesis del TFM. Las dos se proponen para el esquema; mientras el
inventario del capítulo 6 no las recoja, las cinco datasheets llevan dos formas fuera de
esquema, ahora al menos declaradas.

**O-20 · El coste cero de un sondeo es una propiedad medida, no una propiedad del
destinatario.** El paquete A de sondeos se diseñó sobre una guarda: toda petición lleva un
defecto que el proveedor tiene que rechazar, así que ninguna llega a entregar y la cifra
sale del cuerpo del error. Medido el 2026-09-17 en [E1], **la guarda no se sostiene**. Con
remitente `sonda-remitente@example.invalid`, destinatario `sonda-00001@example.invalid` y la
cabecera `X-Sib-Sandbox: drop`, `POST /v3/smtp/email` devolvió `201` y
`{"messageId":"<202609171534.72501669544@smtp-relay.mailin.fr>"}`. El libro de cuentas lo
anotó como gasto —1 destinatario de un tope de 3— y puso la PARADA que dejó siete sondeos
sin ejecutar.

**Y no es una contradicción del proveedor.** [F16] dice exactamente eso: `"Sandbox mode only
validates the API request format"` y `"You receive a success response indicating the API
endpoint is working correctly"`. La documentación se cumplió. Lo que falló fue la inferencia
de quien montó el sondeo, que dio por rechazada una petición por llevar un destinatario
inentregable. Las dos propiedades —«no se puede entregar» y «se rechaza»— son
independientes, y en Brevo se separan.

**Por qué no abre fricción.** No hay carencia del esquema a la vista: v0.3 no promete nada
sobre qué acepta un endpoint. Y la carencia parecida que sí está inventariada —**F-21**, un
cupo que se gasta con intentos que no envían nada— **necesita saber si la aceptación
descontó crédito**, y eso no se ha medido. La vía era, además, más estrecha de lo que resultó ser:
se daba por hecho que **sandbox no crea registros**, y el panel del 2026-09-18 lo desmiente
—la petición de la sonda tiene **dos filas** en `Transactional → Logs`, `Sent` y `Error`, con
su asunto y su remitente sintético—. Lo que el panel no distingue es si la cabecera se
respetó, porque el destinatario estaba en un dominio inexistente y el `Error` se explica
igual de las dos maneras. La lectura del saldo antes y después de `GET /v3/account` sigue
siendo la vía buena, y el `credits: 300` que se le atribuía al panel no existe: el panel
publica 300 correos diarios y 0 créditos prepago, que son saldos distintos (DISC-14). Su celda de Brevo queda en
*(verificar)*, y la promoción, que es carril B9/D-042, va devuelta en `REVISION.md` (Q-A2 y
Q-A3).

**O-21 · Tres topes que pone el cliente, y el fichero no tiene dónde escribirlos.** El
panel del 2026-09-18 enseña dos límites que **configura el titular**, no el proveedor:
la **retención** de registros —`"The logs will be deleted after [ ] months"`, un control con
`min="1"` y `max="24"`— y la **cadencia de envío** —`"Activate frequency cap"`,
`"Set the maximum number of emails your contacts can receive during the below-defined
period."`, esta además detrás de un `"Upgrade"`—. El tercero está ya inventariado en otra
API: el tope de gasto voluntario de MailerSend, que se cuenta dentro de **F-13**.

Los tres tienen la misma forma: **el valor efectivo de un límite depende de una decisión del
cliente que ninguna fuente publica y que el fichero no puede declarar**. Una herramienta que
lea la Datasheet ve la capacidad del plan y no ve el tope que el propio cliente se puso.

**No se abre número todavía, y el motivo es el de siempre:** la recurrencia hay que medirla
antes, no suponerla. Hace falta comprobar en Postmark, Resend y SendGrid si existe un control
equivalente —retención configurable, tope de gasto, cap de frecuencia— con **cita literal**, y
distinguirlo de F-13, que es sobre el sobrecoste y no sobre la capacidad. Hecha esa
comprobación, o cruza el umbral de B9 o se queda como observación.

**Lo que sí quedó medido de F-21, y conviene no perderlo.** El cupo de **caudal** se gastó
con un intento que no envió nada: la respuesta del caso rechazado —p1, `400`,
`"sender is missing"`— trae `x-sib-ratelimit-limit: 1000` y
`x-sib-ratelimit-remaining: 999`. Una petición que el proveedor rechazó consumió unidad del
bucket, que es el enunciado literal de F-21. Con dos muestras no es firme —haría falta ver
el contador caer con pausas conocidas— pero el dato está en la evidencia y hay que
distinguirlo de lo que sigue abierto, que es la **cuota de correo**. Los dos cupos son
distintos y solo uno está medido.

**Qué se lleva el método, que es lo que vale para el capítulo 4.** El libro de cuentas en
disco tiene que existir **aunque el paquete se declare de cero envíos**: es lo que cazó este
caso y lo que dejó la cifra exacta —1 destinatario, `GASTO`, margen 2 de 3— en vez de una
sospecha. Y el listón **L1** se cumple en la dirección contraria, igual que en O-15: el
resultado negativo se midió, así que se escribe.

**Lo que esta pasada deja sin evidencia ejecutada.** Las cinco fricciones nuevas cumplen
L1 y ninguna ha pasado por L2, porque el encargo de la tanda era documental. Antes de
intentar la vía de traza con cualquiera de ellas hay dos cosas más baratas: **F-25 y F-26
podrían promover por recurrencia** si SendGrid y MailerSend resultan tener el mismo patrón
—las dos están marcadas *(verificar)* en la tabla—, y eso se comprueba abriendo dos
ficheros, no ejecutando el motor.
