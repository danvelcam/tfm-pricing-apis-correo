# Revisión — Brevo · PASADA 1 (2026-09-16)

**Estado:** **cerrada el 2026-09-17 por consejo (D-048)**, primer uso real de D-047. Los
**dieciocho** puntos del fichero llevan veredicto: diez del bloque de prioridad alta —cuatro
aplicadas sin convocar nada, una muda, una que no era criterio, tres deliberadas y una
tumbada—, tres de la corrección (Q11–Q13) y cinco del paquete A (Q-A1–Q-A5). **Q11 la cerró
[E2], y Q-A2 y Q-A4 se midieron después**, con [E3] y [E4]. Ficha en modo registro; el autor la
veta en su lectura si no le gusta, y entonces se revierte la clase entera.
**Construido:** 2026-09-16 (documentación pública por tres lentes: capacidad, precio y
contrato de rechazo) · **Escalón 2 (panel):** ejecutado el 2026-09-17, volcado en
`evidencias/panel_brevo_2026-09-17.md`, **incorporado en los veredictos de Q5, Q8, Q9 y
Q10**, y con la **segunda pasada del 18-09** [F30] cierra el test C2 y **DISC-10**; **DISC-08**, los precios de los add-ons, ya no espera al panel: la cerró D17 el 2026-10-18 con la página en USD y `"Monthly"` ·
**Escalón 3 (sondeo): seis pasadas** — [E1] preflight abortado en su segundo caso (1
destinatario), [E2] cabeceras por lectura (0), [E3] unidad de la cuota con envío real (2) y
[E4] caudal por clave (0), el sondeo de unidad del 18-09 que no bastó (0) y **[E5] el rechazo
por caudal, en dos pasadas (0)**, que cierra DISC-13 y sube a 🟢 el caudal de
`GET /v3/smtp/emails`. Presupuesto de envíos **agotado, 3 de 3**. Quedan **siete** scripts sin
ejecutar, y solo uno gasta: `probe_brevo_b_tamano_entrega.sh`, que declara hasta 2
destinatarios y por eso hoy no puede correr · **Validado contra
v0.3:** sí, 0 errores

La estación muestra cada campo con su fuente, su cita literal y su semáforo. Este fichero
recoge lo que la documentación no puede responder. Marca cada punto con `[OK]`,
`[NO] + motivo` o `[DUDA]` — desde la estación o aquí.

**Lo que hay que saber antes de leer el resto.** Brevo es la API del catálogo que **mejor
publica su caudal** —tres tramos, con nueve, cinco y seis filas, changelog fechado— y la que **peor
publica lo que pasa cuando te pasas**: cero precios de exceso en cinco planes. Esas dos
cosas gobiernan casi todas las preguntas de abajo.

---

## Estado de las comprobaciones

| Comprobación | Resultado | Dónde |
|---|---|---|
| Formato v0.3 (`gen_datasheet_viewer.py`) | **16 ok / 1 aviso / 0 errores** (re-ejecutado el 2026-09-17) | el aviso es el hueco deliberado: `capacity.quota_email_daily_free` sin `window_type`, justificado con 🔴 y con entrada en `not_found`. La pasada 1 anotó **17 ok**; la misma ejecución sobre la versión del fichero anterior a la medición da también **16 ok**, así que la diferencia no la trae esta pasada y queda dicha en vez de arreglada por encima |
| Conformidad con PRIME4API (`verificar_prime4api.py`, motor local) | **9 OK / 13 ERR** | los trece son el mismo, `could not convert string to float: 'custom'`, del plan Enterprise. Es **DV-03**, conocido: SendGrid da 8 OK / 13 ERR con los mismos trece mensajes. Salida archivada en `evidencias/verificar_prime4api_2026-09-16.txt`; detalle en `fricciones.md`, O-17 |
| Citas (`verificar_citas.py`) | **no ejecutada** | sin volcados en `evidencias/`. Las citas de [F24] a [F27] no son comprobables sin red: `help.brevo.com` devuelve 403 a todo lo que no sea un navegador. Por **D-023** esto no bloquea el cierre |

**Semáforo del fichero:** **19 🟢 · 17 🟡 · 1 🔴**, contado por `verificar_estado.py`, que
cuenta las marcas `# 🟢` de campo y descarta la leyenda de cabecera. El recorrido del día tiene cuatro
etapas, y una fue una corrección: 16/18/1 hasta D-048; 20/16/1 con los aliases y el `type`
cerrado; 18/18/1 cuando D11 devolvió a 🟡 los tres `rate` del envío; y **19/17/1 con el 429
de [E5]**. Ese verde no lo da la cabecera: **D6** la
registra y no la adopta. Lo da el rechazo, que es lo que **D-024** exige y ningún sondeo de
Brevo había alcanzado. Ese verde **nunca se
deliberó**: la ficha de Q1 argumenta aliases, motor y el literal del autor en D-025, y no
menciona el color ni una vez; las marcas se voltearon de rebote al aplicar los aliases y la
entrada de DISC-01 no se tocó. Corregirlo no anula D-048, corrige su aplicación. Los 17 🟡 son
los tres `rate` del envío (DISC-01 y DISC-15), los cinco `max: 2000` y los cinco `max: 20`
(los diez ya por **D1** y la regla **D13**, cerradas DISC-04 y DISC-16 por E5 (1)), **uno** de los dos `rate` de lectura, el `window_type` de la cuota
mensual del Enterprise y las dos atribuciones por plan de `/v3/inbound/events`. De los dos
`rate` de lectura, el de `GET /v3/smtp/emails` pasó a verde; `rate_request_other_general`
sigue ámbar porque su rechazo exigiría miles de peticiones. El 🔴 es la línea que
justifica la ventana diaria vacía del Free.

**`features.md` construida en la corrección del 2026-09-16** (regla **G1**), desde
`fuentes.md` y sin fuentes nuevas, y **puesta al día con el panel del 18-09**. De las ocho
filas que esperaban escalón 2 quedan **tres**, y no por falta de observación: esta cuenta
Free no enseña el número de webhooks por plan, ni los límites del canal SMTP, ni el escalón
`"More"` de los deslizadores. Cerrada una: el periodo de retención, de 1 a 24 meses [F30].
**Acotadas cuatro** sin cifra por plan: dominios, plantillas, claves de API y SMTP, y el
precio de los add-ons, que el panel da en euros. PI-E01 y PI-E02 instanciadas, y **PI-E03
respondida el 18-09 por el panel**, que es lo que ninguna fuente documental publica.

---

## 🔴 Prioridad alta — decisiones que no están en `CRITERIOS.md`

Las diez llevan **lectura conservadora aplicada** y el valor en ámbar. Ninguna paró el
trabajo. Si dices que no a alguna, se rehace en bloque en las cinco datasheets.

### Q1 · ¿Qué tramo de caudal lleva un plan que es elegible de más de uno?

Brevo publica el caudal en tres tramos que **no son los cinco planes**: General
(*"Available to all account types (Free, Starter, Standard, Professional, and
Enterprise)"*), Advanced (*"Available to Professional and Enterprise accounts"*) y Extended
(*"Available to Enterprise accounts"*) [F6]. Professional es elegible de dos, Enterprise de
tres, y **ninguna fuente dice cuál se aplica por defecto ni si hay que solicitarlo**. Para
el mismo endpoint de envío: 1.000, 2.000 o 6.000 peticiones por segundo.

**Lectura aplicada (conservadora):** los cinco planes referencian el tramo **General**, que
es el único atribuido literalmente a todos, y los tres `rate` van en **🟡**. Advanced y
Extended van al provenance y a `not_found` con sus cifras.

**Lo que asumo al hacerlo, dicho sin adornos:** el fichero declara **1.000 peticiones por
segundo** en el envío para Professional y para Enterprise, cuando el proveedor les atribuye
literalmente 2.000 y 6.000. Legible por máquina, la datasheet subestima el caudal publicado
de esos dos planes en 2× y 6×, y la cifra real solo vive en prosa (`not_found`).

**La otra lectura, que es concreta y hay que nombrarla: aliases.** El mecanismo de aliases
de v0.3 **sí expresa** el caso —`general`, `advanced` y `extended` son vocabulario del
propio proveedor, que es lo que **D7** exige—: definir `rate_request_send_advanced` (2.000
RPS) y `rate_request_send_extended` (6.000 RPS) en `max_power` y colgar de `/v3/smtp/email`
los aliases que correspondan a cada plan, con el `workload` compartido a nivel de endpoint
(README §3.4.3). Lo que los aliases **no** expresan es cuál de los tres está vigente, que
es justo lo que ninguna fuente publica; por eso la lectura conservadora se quedó con el
aplanado. Si dices que sí a los aliases, `nav.aliases` deja de ser `null` y el fichero pasa
a declarar tres caudales por plan en vez de uno.

**Por qué no lo cubre el libro:** **D2** resuelve el caso de «un solo rate por cuenta no
condicionado al plan», y aquí hay tres condicionados al tipo de cuenta. **D7** resuelve el
caso de «cifras distintas por estado de la cuenta», y el tramo no es un estado: es una
banda del acuerdo comercial. **A4** decide qué endpoints tiene un plan, no a qué caudal
van.

**La otra lectura:** que *"Available to Professional and Enterprise accounts"* signifique
que esos planes **tienen** el Advanced, con lo que Professional iría a 2.000 y Enterprise
quedaría igualmente indeterminado entre tres. El blog oficial la contradice (DISC-15).

**RESUELTA por consejo (D-048).** Aliases de tramo: `general` y `advanced` en professional, más `extended` en enterprise, con el `rate` dentro de cada alias y el `workload` compartido en el endpoint. Regla: **D7 ampliada**. El aplanado subestimaba 2× y 6×.

### Q2 · Dos unidades para el mismo caudal: ¿cuál se serializa?

El proveedor publica RPS y RPH a la vez y obliga a respetar los dos (*"When both apply, you
must respect both simultaneously."* [F6]). B8 exige declarar cada límite una sola vez y
v0.3 admite un `rate` por endpoint.

**Lectura aplicada:** se serializa el **RPS**, después de comprobar fila a fila que en las
**diez** filas que publican las dos unidades el RPH es **exactamente el RPS por 3.600**
(tabla completa en `fricciones.md`, O-15). La segunda cifra no restringe nada, así que no
se pierde información; va al provenance como `NOTA`. Las filas que publican **solo** RPH
—el comodín de `/v3/smtp/` a 300 y `"All other endpoints"` a 100— sí son topes
independientes y se serializan en `HOUR`.

**Por qué importa que lo veas:** el material de recolección traía esto marcado como
**fricción candidata de primer orden**, y la medición la retiró. Si prefieres que una
candidata retirada siga contando como fricción abierta, se reabre; mi lectura es que un
resultado negativo medido vale más que una fricción de más.

**Regla candidata para el libro (D11):** «un límite publicado dos veces en dos unidades,
cuya identidad aritmética se comprueba, se serializa en la unidad más fina y la otra va al
provenance como `NOTA`».

**RESUELTA por consejo, tras segunda ronda de De Bono (D-048).** No entra D11: el patrón existe **solo en Brevo** y el análogo de MailerSend está en disputa, no verificado. La identidad aritmética se queda en la `NOTA` del provenance y la comprobación pasa al validador, donde no depende de que nadie recuerde leerla.

### Q3 · El comodín de prefijo con excepción: ¿qué lleva `/*`?

Brevo publica tres niveles: dos rutas con caudal propio, el **prefijo** `/v3/smtp/{…}` a
300 por hora *con una exclusión explícita de esas dos rutas*, y `"All other endpoints"` a
100 por hora [F6]. v0.3 admite endpoints enumerados y **un** comodín, `/*`.

**Lectura aplicada (conservadora):** `/*` lleva los **100 por hora**, que es la cifra menor
y no sobrestima. El nivel intermedio de 300 no se modela: va al provenance, a `not_found` y
a la fricción nueva **F-23**.

**Consecuencia asumida:** la datasheet **subestima por tres** el caudal de la familia
`/v3/smtp/` salvo los dos endpoints dedicados.

**La otra lectura:** poner 300 en `/*`, que acierta en la familia `/smtp/` y **triplica** el
del resto de la API. Descartada por no sobrestimar.

**Lo que esta corrección añade y Q3 no veía.** La nota al pie del prefijo exime a **dos**
rutas y `GET /v3/smtp/emails` **no es ninguna de las dos**, pese a tener fila propia igual
que ellas. Si el prefijo la alcanza, su tope son 300 por hora y no los 7.200 de su fila:
`rate_request_activity_general` estaría sobrestimando **24 veces**. No se arbitra —es
**DISC-17**, con las dos citas— y el valor se queda en 🟡 con su hueco en `not_found`. La
lectura alternativa sería bajarlo a 300/HORA, que nunca sobrestima; no se aplica porque la
regla 3 del encargo manda registrar la contradicción antes que resolverla, y porque el
sondeo de cabecera la cierra sin gastar un envío.

**RESUELTA por consejo (D-048).** Sin regla nueva; F-23 se queda como fricción. DISC-17 acotada por el sondeo de lectura hacia la fila propia (`limit: 2`). Y el conservador de `rate_request_other_general` sale **medido 50× por debajo**: `GET /v3/account` da 5000 donde [F6] publica 100/hora. Por D6 se registra y no se adopta.

### Q4 · `workload[].max` del envío cuando hay tres cifras y todas son correctas

Sobre `POST /v3/smtp/email` hay tres topes publicados que no se pueden reconciliar: **2.000
destinatarios** por petición y 99 por versión [F10]; **1.000 mensajes** por llamada [F13];
y **99 destinatarios si la petición lleva adjunto** [F27]. Las dos primeras se contradicen
(DISC-03: 1.000 × 99 son 99.000, no 2.000) y la tercera depende de la forma del cuerpo
(DISC-04).

**Lectura aplicada:** `max: 2000` en **🟡**, que es el caso general. La cifra procede de
**una sola redacción** —la descripción de `messageVersions`—, replicada palabra por palabra
en las dos especificaciones ([F20] y [F21] lo dicen así) y parafraseada en el blog [F28],
que es contenido editorial y del que *"nada suyo se adopta"*. Es un literal repetido, no
tres fuentes que coincidan. La
condicionalidad del adjunto va a `not_found`, al provenance y a la fricción nueva **F-25**.

**Por qué no lo cubre el libro:** **D4** resuelve «un tope declarado en un solo campo»
(`to: Max 50` sin `cc`/`bcc`). Aquí el problema no es el campo: es que hay **dos topes
correctos** según la forma del cuerpo, y el esquema solo tiene sitio para uno.

**La otra lectura:** `max: 99`, que nunca sobrestima. Descartada porque sería falsa en el
caso común por un factor de veinte y dejaría la datasheet diciendo que Brevo no admite
lotes.

**RESUELTA por consejo (D-048).** La premisa de la convocatoria era falsa —esta pregunta no aplanó al mínimo, eligió el caso general— y el tribunal la tumbó por eso. `max: 2000` se mantiene. DISC-03 sigue siendo F-03. DISC-04 no es contradicción entre fuentes: son dos escenarios, y su alias **no compone** con el de tramo sobre el mismo endpoint. Ahí está la fricción.

### Q5 · `window_type` de una cuota diaria con periodicidad publicada y sin ancla

La cuota del plan gratuito dice *"The daily limit resets every day, and unused emails do not
roll over to the next day."* [F24][F26]. Periodicidad sí; hora y huso, no.

**Lectura aplicada:** campo **vacío y en 🔴**, con la línea de comentario que lo justifica y
su entrada en `not_found`. Es el único aviso del validador.

**Por qué:** `rolling` lo contradice (el proveedor dice que se reinicia, no que sea
ventana móvil), y `fixed_utc_midnight` **afirmaría un huso que nadie publica** — y Brevo es
francesa, con los datos alojados en Francia y Alemania [F5], así que UTC no es ni siquiera
la suposición natural. Por **D3**, «nada → sin valor y aviso justificado».

**Por qué no lo cubre el libro:** **D8** dice que sin ancla se va a ámbar *por D3*, pero el
caso que resolvió era mensual y el ámbar recaía en `fixed_billing_cycle`. Para una ventana
**diaria** los tres valores del enum son o falsos o inventados, así que el ámbar no tiene
dónde posarse.

**APLICADA sin consejo (D-048).** La cubre **D3**: «nada → sin valor y aviso justificado», que es lo aplicado. El panel del 17-09 acota que la ventana **no es rolling** —le pone fecha de fin— y deja solo el huso sin publicar.

### Q6 · Con una DISC abierta, ¿qué número entra en el YAML?

La regla 3 del encargo dice que dos fuentes que se contradicen **no se arbitran**. Pero el
campo exige un número. Esta pasada tiene tres casos y en los tres he aplicado el mismo
criterio, que **me he inventado**:

> manda **la fuente cuyo asunto es el campo**.

- **Caudal del envío** (DISC-01: 3.600.000/h en la página de caudal frente a 6.000/h en la
  guía de lotes) → la página de caudal, que es la dedicada. Resulta ser la cifra **mayor**.
- **Tamaño del correo** (DISC-16: 20 MB en el centro de ayuda frente a 25 MB en una página
  de producto) → el centro de ayuda, que es el que habla del envío por API. Resulta ser la
  **menor**.
- **Destinatarios** (DISC-04) → la referencia del endpoint, no el centro de ayuda.

En los tres el valor va en **🟡** y la DISC queda abierta con las dos citas.

**Por qué no lo cubre el libro:** **E4** es lo más cercano, pero solo actúa cuando la
página general **se declara «por defecto»**, y ninguna de las tres lo hace.

**Lo que te pido:** o bendecir el criterio como ampliación de E4, o decir que con DISC
abierta el campo se queda vacío y en 🔴 — que haría perder tres valores publicados y
dejaría la datasheet con menos capacidad descrita que la que el proveedor documenta.

**TUMBADA por consejo, por unanimidad (D-048).** `[F27]` es la fuente A en esta pregunta y en DISC-16: gana en una y pierde en la otra el mismo día con el mismo enunciado. Y no hacía falta ninguna regla: DISC-01 la gobierna D6, DISC-16 la lectura conservadora, y DISC-04 se disuelve con aliases.

### Q7 · `type` con el test C2 incompleto

Sin panel y sin referencia completa, de las tres operaciones que deciden el `type` solo he
podido comprobar la primera: enviar, que es programática en los cinco planes [F2][F10]. Las
otras dos —crear o editar una plantilla, y añadir un dominio y disparar su verificación— no
tienen literal en el material de esta pasada.

**Lectura aplicada:** `api_first` en **🟡**, con la `NOTA` de D9 en el provenance
enumerando qué se comprobó y qué no.

**Por qué no lo cubre el libro:** **D9** define el ámbar como «alguna comprobación quedó
sin hacer», y no dice **cuántas** pueden faltar antes de que el valor no deba emitirse. Aquí
faltan dos de tres.

**El valor que está en juego, dicho claro:** el otro es `partial_saas`. Con dos de tres
operaciones sin comprobar, **ninguno de los dos está demostrado**. `api_first` se elige
porque `partial_saas` exige evidencia **positiva** de que una operación existe en el panel
y no en la API, y esa evidencia no existe: el panel no se ha mirado. No es que `api_first`
sea la lectura conservadora —es que la alternativa afirmaría un hecho que nadie ha medido.
Si el escalón 2 encuentra la creación de plantillas o el alta de dominio solo en la web, el
valor **se invierte** y la inversión se anota en la bitácora.

**La otra lectura:** dejar el campo sin decidir hasta el escalón 2. Descartada porque
`type` es obligatorio en v0.3 y un campo vacío tumbaría el fichero.

**NO ERA CRITERIO (D-048).** Es recolección sin hacer: la referencia nunca se recogió para crear plantillas ni para añadir dominios —cero apariciones en las 28 fuentes—, y el panel solo recorrió las páginas de claves. `type` se queda en `api_first` 🟡 por D9, sin inversión.

**Mitad hecha el 2026-09-18, y el color no se mueve.** El contrato máquina descargado y archivado ese día ([F29], 1.162.191 bytes) trae las dos operaciones eliminatorias que faltaban: `'operationId: createSmtpTemplate'` con `'summary: Create an email template'` (l. 24949) y `'operationId: updateSmtpTemplate'` (l. 25112) para la 2, y `'Create a new sender domain'` (l. 4028) más `'Authenticate a sender domain'` (l. 4455) para la 3. Con la 1 ya comprobada, **las tres que deciden el `type` existen en la API**, así que `api_first` deja de estar en duda como valor. Las otras cinco también están localizadas: webhooks `GET`/`POST /webhooks` (l. 4908 y 4995), *inbound routing* con `POST /webhooks` de `type: inbound` (l. 5092) y `GET /inbound/events` (l. 12578), supresiones `GET /smtp/blockedContacts` (l. 23126), `DELETE /smtp/blockedContacts/{email}` (l. 23251), `GET`/`POST /smtp/blockedDomains` (l. 23272 y 23303) y `POST /smtp/deleteHardbounces` (l. 23356), y actividad `GET /smtp/emails` (l. 23980). La **4 es la que no está**: la API solo publica `/corporate/subAccount/key`, que crea claves de una **subcuenta** de un plan Corporate, y la clave propia se genera desde el panel — es **F-22**, y ahora recurre con Postmark.

**Cerrado el 2026-09-18 con la segunda pasada de panel, y el color sube a 🟢.** Faltaban dos cosas y las dos están hechas. La primera, la mitad de panel: `"Create Template"` en `app.brevo.com/templates/listing`, `"Add a domain"` en `app.brevo.com/senders/domain/list`, `"Webhook — Each event … will be sent in real time to your server"` y `"Blocked or unsubscribed contacts"` en `app.brevo.com/transactional/email/settings`, y los registros en `app.brevo.com/transactional/email/logs`. Con eso, **las tres operaciones que deciden el valor existen en la API y también en el panel**, así que ninguna es exclusiva de la web y `api_first` queda demostrado en vez de elegido por defecto. La 6, el *inbound routing*, **no tiene página de panel**: solo se configura por API, que es lo contrario de lo que invertiría el valor. La 4, las credenciales, es la única exclusiva del panel y no decide el `type`: es **F-22**, que con esto recurre con Postmark. La segunda cosa era el reparo de A1, y se resuelve mirando: la spec troceada de la Email API declara **21 rutas** y **no** trae ni `/senders/domains` ni `/webhooks`, así que las operaciones 3 y 5 se citan del contrato de plataforma. Eso no cambia el veredicto, porque el test pregunta si la operación existe en la API, y existe; queda dicho en el provenance para que se vea de dónde sale cada cita. **`type: api_first` 🟢 por D9, con el test entero.**

### Q8 · La divisa, cuando el proveedor publica ocho y no son conversiones

La página sirve ocho divisas y **geolocaliza**: desde España da Starter 7 EUR, Standard 15
EUR, Professional 499 EUR, frente a 9, 18 y 499 USD. No es un tipo de cambio: son precios
distintos [F1]. Ninguna fuente declara cuál es la de referencia.

**Lectura aplicada:** `currency: USD` en **🟢**, porque `"priceCurrency": "USD"` es literal
y todo el fichero está en esa divisa. La multiplicidad va al provenance, a `not_found` y a
la fricción nueva **F-26**.

**Lo que asumo al hacerlo:** la comparación del catálogo en USD sitúa a Brevo un 15 % por
encima de lo que le costaría a un comprador español. Y los precios están publicados **sin
impuestos** [F25], lo que añade otra dependencia geográfica sobre el mismo número.

**Lo que la corrección ha precisado sin cambiar el color:** el provenance lleva ya una
`NOTA` que dice qué cubre ese verde — el literal `"priceCurrency": "USD"` de **una** de las
ocho ofertas, y **no** la elección de USD como divisa canónica, que es del modelador. Sin
esa nota, el color de un dato publicado estaba respaldando una decisión de modelado.

**La otra lectura:** ámbar, para que el color avise de que el precio depende del comprador.
Descartada porque el dato *es* literal y el ámbar del catálogo significa «inferido», no
«incompleto».

**APLICADA sin consejo (D-048).** La cubre **D1**: el dato es literal y el ámbar del catálogo significa «inferido», no «incompleto». El panel del 17-09 lo confirma sin descubrir nada nuevo.

### Q9 · ¿Cuenta Brevo como recurrencia de F-18?

F-18 es «la capacidad depende del **estado de la cuenta**, no del plan», y hoy tiene una
sola API (MailerSend). En Brevo la capacidad depende de un eje que tampoco es el plan —el
tramo de caudal—, pero ese eje **no es un estado**: es la banda del acuerdo comercial. Y el
único estado real, la cuenta sin aprobar, **no publica cifras**, así que por **D7** ni
genera alias ni entra.

**Lectura aplicada (conservadora):** **no se promueve**. Se anota como variante y el
recuento de F-18 **no cambia**.

**Por qué no lo cubre el libro:** **B9** dice «el patrón reaparece en ≥ 2 APIs» y no dice
con qué anchura se lee el patrón. Con la lectura estricta Brevo no recurre; con la amplia
—«la capacidad depende de un eje que no es el plan»— sí, y F-18 pasaría a 2/5 y cruzaría el
umbral.

**Dato que orienta la decisión:** el mecanismo de aliases de v0.3 **sí podría expresar** el
caso (los nombres `general`, `advanced` y `extended` son vocabulario del proveedor, que es
lo que D7 exige). Lo que no expresa es **cuál es el vigente**. Así que aunque promoviera por
recurrencia, la condición L3 de D-042 fallaría.

**MUDA (D-048).** Discutible en teoría, sin efecto en la práctica: la condición **L3** de D-042 falla igual con la lectura amplia que con la estricta, así que no promueve y el recuento de F-18 no cambia.

### Q10 · Una cuota que pertenece a los dos productos

Brevo cobra un solo saldo para marketing y transaccional: *"Yes, you can use your email
credits to send both marketing and transactional emails."* [F26], y el propio configurador
rotula el deslizador `"Monthly email volume (campaigns & transactional)"` [F1].

**Lectura aplicada:** se modela igualmente, con la `NOTA` de provenance que dice que es
compartida. No hay otra cuota que modelar.

**Por qué no lo cubre el libro:** **A1** manda modelar el transaccional y documentar el otro
producto en `fuentes.md` como F-10, pero **presupone que el producto modelado tiene cuota
propia**. Aquí el campo más importante de la datasheet —`quota_email_monthly_starter:
5000`— pertenece a la cuenta, no al producto: el marketing se lo come igual, y una
herramienta calculará 5.000 correos transaccionales al mes cuando el valor real es *lo que
sobre*.

**La otra lectura:** dejar la cuota vacía y en 🔴 porque el producto modelado no tiene
ninguna. Descartada: perdería el único dato de volumen que Brevo publica y haría la
datasheet incomparable con las otras cuatro.

**APLICADA sin consejo (D-048) y luego MEDIDA ([E3], 2026-09-17).** El panel ya la resolvía con literal: `"300 / 300 Marketing & Transactional emails left"`, un solo contador para los dos productos. El sondeo lo sube de escalón 2 a escalón 3: la cuenta expone **una sola** entrada de correo, `sendLimit:free`, y es la que se movió al enviar un transaccional. Así que el transaccional consume el saldo de la cuenta y no uno propio. Lo que sigue sin medir es que la campaña salga de esa misma entrada, que solo está publicado.

---

## 🟡 Prioridad media — lo que verificaría yo y no he podido cerrar

No son decisiones tuyas: son cosas que cierro en cuanto tenga panel o pueda ejecutar un
sondeo. Están aquí para que sepas qué falta y por qué.

1. ~~**`features.md` (G1).** No construida.~~ **Construida el 2026-09-16.** Lo que le falta
   es escalón 2, no materia prima.
2. **Volcados de página (E2).** Ninguno en `evidencias/`. `help.brevo.com` da 403 a todo
   cliente que no sea navegador, así que las citas de [F24] a [F27] —entre ellas los 20 MB
   y la cola de reintento de 1.000— **solo son verificables con red y con navegador**.
   Merece la pena capturarlas antes de que cambien.
3. **Las diecisiete DISC.** **Diez** se cierran con un sondeo que **no gasta envío**
   (DISC-01, 02, 03, 04, 12, 13, 14, 15, 16 y **17**, lista abajo). **DISC-05, 06, 07 y 11**
   son documentales: se cierran leyendo fuentes, no midiendo. **DISC-08** la cierra el panel
   (escalón 2) y **DISC-10 ya la cerró**, el 18-09: la retención la fija el cliente entre 1 y
   24 meses. **DISC-09 la cerró [E3] el 17-09**: el periodo viaja en
   `planVerticals[]` y no en `plan[]`, donde el script lo buscaba, con treinta días exactos
   del 16-09 al 16-10.
   **DISC-04 y DISC-16** pasan a envío real **solo si** el sondeo en sandbox no las decide.

   **Dos correcciones del recuento, del 2026-09-17.** La primera: **DISC-17 no es
   documental**, es de sondeo, y estaba en los dos sitios a la vez. Su vía es una lectura de
   `x-sib-ratelimit-limit` sobre `GET /v3/smtp/emails` —el mismo sondeo que DISC-01 y
   DISC-15—, que es lo que este fichero llama dos veces «el cierre más barato de la pasada,
   cero envíos». La segunda: **DISC-09 sale de la lista de coste cero.** Su vía
   (`startDate`/`endDate` de `GET /v3/account`) exige una cuenta **con suscripción**. Esta
   está en Free y no la tiene, y la medición y el panel del 2026-09-17 coinciden en eso
   (`evidencias/panel_brevo_2026-09-17.md`: «No es medible en esta cuenta»). Queda **no
   medible sin contratar un plan de pago**, que es carril rojo. Las dos correcciones se
   compensan y el total sigue siendo **diez**, pero la pertenencia cambia: una pregunta que
   solo responde una cuenta de pago estaba clasificada como cerrable con la gratuita.

   **Y de esos diez, tres se han quedado sin instrumento:** DISC-03, DISC-04 y DISC-16 se
   cerraban con una bisección cuya guarda la medición ha tumbado, así que hoy no hay vía de
   coste cero para ellas (Q-A1). **Vía viva: cinco** (DISC-01, 02, 12, 13 y 15). DISC-14 la cerró [E3] y DISC-17 [E2].
4. ~~**El test C2**~~ **cerrado el 18-09** (Q7): las ocho operaciones con cita, contra el
   contrato máquina [F29] y contra el panel [F30], y `type: api_first` en 🟢.
5. **F-25 y F-26 podrían promover por recurrencia** sin ejecutar nada: hay que mirar si
   SendGrid (`personalizations`) tiene el mismo patrón de modos excluyentes, y si SendGrid
   y MailerSend publican precios por geografía. Son dos ficheros que ya están en el repo.

---

## 🔴 Lo que no existe y hay que medir

**Los dos escalones van en serie y fuera de este workflow.** Brevo es, con diferencia, la
API del catálogo **más barata de sondear**: publica un modo sandbox por cabecera
(`X-Sib-Sandbox: drop`, *"No emails are sent to recipients"* [F16]) y devuelve las tres
cabeceras `x-sib-ratelimit-*` **en toda respuesta, no solo en el 429** [F7]. Con esas dos
cosas, casi todo lo abierto se cierra sin gastar un solo correo. **La segunda promesa la
desmiente [E2]**: las cabeceras vienen en el `400` de `GET /v3/smtp/emails` y en el `200` de
`GET /v3/account`, y **no vienen** en los `200` de `/v3/smtp/templates` ni de `/v3/senders`.
No va por éxito frente a error: va por endpoint, así que el coste cero hay que comprobarlo
endpoint a endpoint.

**Medido el 2026-09-17, y conviene leerlo antes que las listas: la premisa del coste cero
era una suposición, no un hecho.** El preflight [E1] mandó una petición cuyo remitente y
cuyo destinatario estaban en `example.invalid`, con `X-Sib-Sandbox: drop`, y Brevo la
**aceptó** con `201` y `messageId`. Las dos propiedades son independientes: que el
destinatario no pueda recibir no implica que la petición se rechace. No contradice a [F16]
—sandbox *"only validates the API request format"* y devuelve *"a success response"*— pero
tumba la guarda sobre la que se montaron tres de los sondeos de abajo. El coste cero se
demuestra midiendo; no se elige poniendo un destinatario inentregable.

### Escalón 2 — solo lo abre el panel, con cuenta propia

1. **Ancla del reinicio diario del Free** (el 🔴 del fichero). El panel muestra el contador
   y su fecha de renovación, como hizo Postmark con *"Your 100 free emails will renew on
   Sep 4, 2026"*.
2. **Día del ciclo de facturación** de la cuenta, en claro (DISC-09).
3. **Estado de aprobación de la cuenta** y qué topes rigen mientras está pendiente: ni las
   cifras ni el disparador están publicados, y por D7 no generan alias hasta tener número.
4. **Precio de exceso, si existe dentro de la cuenta.** Es el hallazgo central de esta
   pasada: cero sobrecostes publicados en cinco planes. Si el panel enseña uno, manda el
   panel (**D5**) y F-27 cambia de forma.
5. **Escalera de volumen y precio como la ve un cliente identificado**, incluido el escalón
   `"More"` que la web pública deja sin cifra.
6. **Si el panel ofrece o indica el tramo de caudal** (Advanced / Extended). Cerraría Q1 de
   un vistazo.
7. ~~**Precio real de los add-ons** dentro de la cuenta (DISC-08: $10.80 frente a $9).~~ **Retirado el 2026-09-21.** No era una lectura de panel: el par estaba mal enfrentado, anual contra mensual, y lo que faltaba era leer la página pública en dólares con los dos conmutadores. Hecho ese día (**E9**).
8. **Periodo de retención configurable** y su rango (DISC-10).
9. **Cuántas claves de API y SMTP** admite la cuenta.
10. **Las ocho operaciones del test C2** panel↔API, para cerrar Q7.

### Escalón 3 — sondeos que NO gastan envío (la vía preferente, D-046 condición 3)

**Diez** de las diecisiete DISC se cierran aquí, y ninguno de estos sondeos entrega un
correo. Son DISC-01, 02, 03, 04, 12, 13, 14, 15, 16 y 17: **DISC-17 entra** —su vía es la
misma lectura de cabecera que DISC-01 y DISC-15— y **DISC-09 sale**, porque su vía exige una
cuenta con suscripción y esta no la tiene (punto 3 del bloque de prioridad media).

**Estado tras las pasadas del 17-09: dos de los diez quedaron cerrados.** El preflight [E1]
abortó, pero [E2] cerró DISC-17 (volcado archivado de las 20:50 UTC, E24) y [E3] cerró DISC-14 y DISC-09 a las 21:29. Tres de esos diez —DISC-03, DISC-04 y DISC-16—
además se quedan sin instrumento, porque su bisección dependía de la guarda que la
medición ha tumbado (Q-A1), así que **con vía viva quedan siete**. Lo que cada DISC gana o
pierde está anotado DISC a DISC en `fuentes.md`; el resumen, en «Resultado del paquete A».

- **DISC-01, DISC-02, DISC-15 y DISC-17 (caudal).** Leer `x-sib-ratelimit-limit` sobre
  `POST /v3/smtp/email` en sandbox y sobre `GET /v3/smtp/emails`. Devuelve el tope vigente
  de esta cuenta y su tramo, y la lectura sobre `GET /v3/smtp/emails` decide de paso si a
  esa ruta la alcanza el prefijo de 300 por hora o su fila propia de 7.200 (DISC-17, que
  hasta el 2026-09-17 estaba clasificada como documental por error).
- **DISC-03 (1.000 mensajes o 2.000 destinatarios).** Bisección en sandbox, con clave de
  idempotencia distinta por intento (TTL de 30 minutos, [F15]).
- **DISC-04 (99 con adjunto).** La misma petición con y sin adjunto, en sandbox.
- **DISC-12 (cuerpo del 429).** Forzar el 429 en el endpoint más barato —`"All other
  endpoints"` está a 100 por hora, así que se alcanza rápido— y capturar `code` y `message`.
- **DISC-13 (unidad de `reset`).** Leer la cabecera en un endpoint declarado por segundo y
  en otro declarado solo por hora.
- ~~**DISC-14 (qué devuelve `GET /v3/account`).**~~ **Cerrada con [E3] el 17-09:** manda B,
  el endpoint devuelve trece campos y ninguno es de límite ni de consumo.
- ~~**DISC-09 (día del ciclo).** `startDate` y `endDate` de esa misma llamada.~~ **Fuera de
  esta lista desde el 2026-09-17:** esos dos campos solo traen fechas si la cuenta tiene
  suscripción, y la de este TFM está en Free sin ninguna. No es que el sondeo no se haya
  ejecutado; es que en esta cuenta **no hay nada que leer**. Contratar un plan es carril
  rojo. **Y aun así se midió, el mismo 17-09 con [E3]:** el periodo no vive en `plan[]` sino en
  `planVerticals[]`, que sí lo trae en esta cuenta Free —del 2026-09-16T09:48:13Z al
  2026-10-16T09:48:13Z, treinta días exactos—. El «no medible» era un defecto del script, no
  de la cuenta. Lo que sigue sin medir es si un plan de pago ancla en el mismo sitio.
- **DISC-16 (20 o 25 MB).** Bisección en sandbox con adjunto sintético creciente, **con la
  reserva** de que sandbox *"only validates the API request format"* [F16]: si el tamaño se
  aplica en la entrega, este sondeo no lo verá.
- **Segmentación del caudal** (hueco 8 de `fuentes.md`): dos claves de la misma cuenta en
  paralelo, en sandbox, y ver si los contadores suman o son independientes.
- **Caudal efectivo del Free** (hueco 27): si el tramo General de 1.000 por segundo aplica
  de verdad a una cuenta con tope de 300 al día.

### Escalón 3 — sondeos que SÍ exigen envío real a la lista blanca

Cinco cosas no se pueden medir sin que salga correo, porque sandbox no crea registros ni
descuenta saldo. Todas van a las tres direcciones de D-046 y con presupuesto declarado.

**El presupuesto va en DESTINATARIOS, no en peticiones** (corregido el 2026-09-17). Una
petición con dos destinatarios gasta dos, y la unidad vieja hacía que el tope vigilase una
cifra distinta de la que se gasta. El tope de esta pasada son **3 destinatarios**, escrito
en `lib_presupuesto_brevo.sh`; D-046 exige presupuesto declarado y no fija ninguna cifra.
Con esa unidad, los cuatro tramos que entregan piden **6** y hay que dejar caer dos:

| Tramo | Pide | En esta pasada |
|---|---|---|
| sondeo 1, brazo de sandbox | 2 | **se cae** |
| sondeo 1, envío real | 2 | se ejecuta |
| sondeo 3, escalera (primer peldaño aceptado) | 1 | se ejecuta |
| sondeo 3, peldaño de control de entrega | 1 | **se cae** (no queda margen) |

**El orden dentro del paquete B importa y está comprobado, no solo escrito.** El sondeo 1
va primero. Si el peldaño de control del sondeo 3 corriese antes, se llevaría un
destinatario del margen y el envío real del sondeo 1 —que cuesta 2— ya no cabría: se
perdería la pregunta principal para quedarse con la accesoria. `fase_control` mira el libro
y no se ejecuta hasta que el envío real del sondeo 1 esté pagado.

1. **La unidad de la cuota: ¿descuenta por petición o por destinatario?** Es el sondeo que
   más paga por lo que cuesta. Leer `credits` en `GET /v3/account`, enviar **un** correo
   con **dos** destinatarios de la lista blanca, y volver a leer. Presupuesto:
   **2 destinatarios**. Cierra la unidad del CRF de toda la datasheet.
   El **brazo de sandbox** de ese mismo sondeo —la misma petición con `X-Sib-Sandbox: drop`,
   que separaría «la petición cobra» de «la entrega cobra» y cerraría el otro lado de
   DISC-14— pedía otros 2 y **se retira**. No es una preferencia: su reserva solo se podía
   liberar leyendo el saldo cuatro segundos después del `POST`, cuando el propio sondeo
   exige treinta como mínimo para la lectura que mide, porque el contador va con retardo.
   Liberar ahí devuelve al margen dos destinatarios que Brevo quizá ya cobró. Y sin liberar
   no caben los dos brazos. Queda **sin medir** y vuelve como pregunta.
2. **Si el saldo es de verdad único entre marketing y transaccional (F-10, Q10).** El mismo
   sondeo lo enseña: si el transaccional descuenta del mismo `credits` que la campaña.
   Presupuesto: **0 destinatarios adicionales**.
3. **Si el tope de tamaño se aplica en validación o en entrega (DISC-16).** Presupuesto:
   **1 destinatario** para el primer peldaño aceptado de la escalera —los rechazos son
   gratis y por eso la escalera baja de mayor a menor— más **1** para el peldaño de
   control, que es la fase declarada prescindible y que con este tope **no se ejecuta**. Lo
   que se pierde al dejarla caer: la prueba de que esta cuenta entrega, y con ella la
   lectura de «no consta entregado» en el peldaño grande.
4. **Si el tope de 99 destinatarios con adjunto se aplica en entrega (DISC-04).** Solo si el
   sondeo en sandbox no lo decide. Presupuesto: **1 envío**, pero **con el problema de que
   la lista blanca solo tiene tres direcciones** y el tope está en 99: la bisección no se
   puede hacer contra destinatarios reales. Probablemente **no medible** dentro de D-046.
5. **La cola de reintento de 1.000 del plan gratuito (F-24).** Es el hallazgo más
   interesante de esta API y **no es medible con presupuesto razonable**: exigiría agotar
   los 300 del día y llegar al correo 1.301 para ver el descarte silencioso. Más de 1.300
   envíos a tres buzones del autor. **Se anota como no ejecutable** y la fricción se queda
   con evidencia documental (L1) de dos fuentes independientes. Lo único barato es el borde
   bajo: comprobar que el correo 301 **no** devuelve 402 y entra en cola — y aun eso cuesta
   301 envíos.

---

## Corrección del 2026-09-16 (segunda lectura)

Un verificador adversarial devolvió 34 hallazgos sobre la pasada 1. Lo que se aplicó, lo
que no y por qué:

**Lo que cambió el fichero legible por máquina.**

1. **`/v3/inbound/events` no tenía `rate`.** Era el único de los cinco endpoints sin él, y
   el comodín **no lo cubre**: el README §3.4.1 dice que `/*` alcanza a los endpoints «que
   no aparezcan explícitamente», y PRIME4API ni siquiera implementa esa herencia. Medido:
   `limits` devolvía solo la cuota y `min_time(1000)` devolvía **lista vacía**; con
   `rate: rate_request_other_general` devuelve `Rate(100 requests/1h)` y **9h**. Ejecución
   en `evidencias/`. Aplicado.
2. **Las claves de endpoint perdían el segmento de versión.** El proveedor publica
   `POST /v3/smtp/email` y la base es `https://api.brevo.com/v3/`; el catálogo escribe la
   ruta como el proveedor la publica (MailerSend `/v1/email`, SendGrid `/v3/mail/send`).
   Renombradas a `/v3/smtp/email`, `/v3/smtp/emails`, `/v3/smtp/blockedContacts` y
   `/v3/inbound/events` en los cinco planes. El comodín `/*` se queda.
3. **«Cada destinatario consume una unidad» se afirmaba sin cita** en las cinco
   descripciones del envío, y a la vez figuraba como sondeo pendiente número 1. Los dos
   literales más cercanos son del saldo prepago, no del volumen del plan. Marcado como
   inferencia en las cinco, con `NOTA` de provenance y entrada en `not_found`.
4. **Cuatro huecos nuevos en `not_found`**: el reparto de la fila compartida de caudal, el
   alcance del prefijo sobre `GET /v3/smtp/emails` (DISC-17), la unidad de descuento de la
   cuota y la atribución por plan de `/v3/inbound/events`, que además pasa a 🟡.
5. **Un hueco retirado**: el tope de tamaño en entrada de correo se afirmaba citando
   `"Estimated size of the attachment"` **sin `[Fn]`, sin URL y sin fecha**, contra E1.
   Ninguna de las 28 páginas leídas es documentación de *inbound*. Pasa a «no buscado».

**Lo que cambió el recuento.** El inventario ya tenía **F-22** (la credencial que solo se
gestiona desde la web, Postmark), así que las cinco fricciones nuevas se **renumeran a
F-23…F-27** en los cuatro ficheros. La tabla de recurrencia gana la fila de F-22 con Brevo
en *(verificar)*, que B9 exige. Y el umbral D-008 se queda en **catorce** —no dieciséis—:
Brevo no promueve ninguna nueva por recurrencia, y F-15 ya había cruzado con MailerSend.
La celda de F-13 baja a variante, porque el mismo hecho (que no exista sobrecoste) ya
cuenta en F-02 y en F-27; las de F-04 y F-12 pasan a *(verificar)*, porque sin sondeo no se
puede decir «comprobada y ausente».

**Lo que cambió porque una cifra no salía.** Las once filas por tramo de [F6] son **nueve,
cinco y seis**. Las ocho *platform quotas* de F-11 son **cuatro** con literal. Las tres
fuentes independientes del `max: 2000` son **una redacción replicada** más un blog del que
el propio expediente dice que nada se adopta. Los tres add-ons discrepantes de DISC-08 son
**cuatro** (falta el asiento de marketing); desde el 2026-10-18 los cierra D17 con la página. Las trece DISC cerrables sin envío son **diez**.
Y los «tres órdenes de magnitud» de DISC-01 son un factor **600**.

**Y el recuento de diez se volvió a tocar el 2026-09-17, sin cambiar la cifra.** Entra
DISC-17, que estaba clasificada como documental cuando su vía es una lectura de cabecera, y
sale DISC-09, cuya vía exige una cuenta con suscripción que esta no tiene. Diez siguen
siendo diez; lo que cambió es cuáles, y ese era el error que importaba.

### Preguntas nuevas que esta corrección devuelve

- **Q11 · `GET /v3/smtp/emails`, ¿7.200 por hora o 300?** La nota al pie de [F6] exime del
  prefijo a dos rutas y esta no está, pese a tener fila propia igual que ellas. Aplicada la
  regla 3 (**DISC-17**, sin arbitrar) y el valor sigue en 🟡 a 2 por segundo. La lectura
  alternativa es bajarlo a 300/HORA por conservadurismo, que dejaría el fichero 24 veces
  por debajo si la exención sí la alcanzaba. Lo cierra el sondeo de cabecera, sin gastar
  envío. **RESUELTA midiendo (D-048, [E2]).** `GET /v3/smtp/emails` devuelve `x-sib-ratelimit-limit: 2`, que es su **fila propia** de [F6] (2/s = 7.200/h), no los 300/h del prefijo. El valor de la datasheet era el bueno; la lectura alternativa de bajarlo a 300/HORA queda descartada, y con ella el riesgo de 24× que esta pregunta temía.
- **Q12 · La fila compartida de caudal, ¿cubo o por ruta?** [F6] publica 1.000 por segundo
  en una sola fila para `POST /v3/smtp/email` y `GET /v3/smtp/blockedContacts`. La
  datasheet los declara por ruta, que es lo único que el esquema admite, y el motor agrega
  **2.000 por segundo** donde el proveedor publica una cifra. Registrado en `not_found`; no
  hay forma de decirlo en el esquema. ¿Se abre fricción o basta el hueco? **RESUELTA por consejo (D-048): NO se abre fricción, y la premisa de la pregunta era falsa.** El enunciado decía que «el motor agrega 2.000 por segundo», y la ejecución lo desmiente: `op.limits` del plan free devuelve **cuatro entradas independientes**, con 1.000 en cada una de las dos rutas y ninguna suma (`evidencias/prime4api_fila_compartida_2026-09-17.json`). Sin valor falso del motor, la condición **L2** de B9 no se cumple, así que no promociona. La frase falsa queda corregida en el `not_found` y en el provenance. Lo que sí es cierto y se queda escrito: v0.3 ata el `rate` a un endpoint y no a un grupo de rutas, así que el fichero declara 1.000 dos veces y **quien sume las dos filas obtiene el doble de lo que el proveedor concede**. El riesgo es de quien suma, no del motor.
- **Q13 · Dos formas del catálogo fuera de v0.3, sin declarar hasta hoy.** `MBs` no está en
  el enum de `unit` del §4 del README, y `metadata.not_found` no está entre los campos que
  el §3.5 define. Las llevan las **cinco** datasheets y **B1** exige declararlas. Quedan
  declaradas en `fricciones.md` (F-06 y O-19); falta su entrada en el inventario de
  propuestas del capítulo 6, que es carril de la memoria. **APLICADA en lo que es mío (D-048).** `MBs` y `metadata.not_found` quedan declaradas en `fricciones.md` (F-06, O-19), que es lo que B1 exige. La entrada en el inventario de propuestas del capítulo 6 es prosa, carril verde por D-016, y se escribe al retocar ese capítulo; no bloquea el cierre de esta datasheet.

---

## Resultado del paquete A — pasada del 2026-09-17 (abortada)

**Lo que se ejecutó:** un script de ocho, y dentro de él dos casos de ocho. El preflight
`probe_brevo_a_preflight_rechazo.sh` mandó `p1_sender_ausente` (400) y `p2_sender_sumidero`
(201), y abortó poniendo la PARADA. La cita literal, el coste y las cabeceras están en
**[E1]** de `fuentes.md`. **No se ejecutaron** los otros siete sondeos: cuenta, unidad de
`reset`, caudal, destinatarios, tamaño, segmentación y cuerpo del 429. No es solo criterio
mío: los ocho llaman a `parada_comprobar`, y en los tres que inspeccioné la llamada va muy
por delante de la primera petición —L95 contra L351 en cuenta, L85 contra L276 en
unidad_reset, L104 contra L340 en cuerpo_429—, así que habrían salido con código 5 sin
emitir nada.

**Ninguna de las trece preguntas se cierra con esto.** Q1 a Q13 siguen abiertas y ningún
campo sube de color: el semáforo del fichero sigue en **16 🟢 · 18 🟡 · 1 🔴**. La medición
es de una cuenta **Free**, y Starter, Standard, Professional y Enterprise no se han
contratado ni medido; el provenance lo dice así en vez de extrapolar. Donde solo se probó el
lado rechazado, el valor sigue siendo cota documental y se queda en ámbar.

**RESUELTAS: dos, y las dos son de instrumento, no de la datasheet.**

1. **¿Rechaza Brevo en validación una petición cuyo remitente y cuyo destinatario están en
   un dominio sin MX, con `X-Sib-Sandbox: drop`? No: la acepta.** `201` con
   `{"messageId":"<202609171534.72501669544@smtp-relay.mailin.fr>"}`. La guarda
   `sender_sumidero` no se sostiene, el paquete A deja de ser de coste cero y su invariante
   queda ROTA. **La cierra la medición del 2026-09-17**, caso `p2_sender_sumidero`.
2. **De las dos guardas candidatas, la única con vara de medir es `sender_ausente`**, que
   devolvió `400` con `{"code":"missing_parameter","message":"sender is missing"}`. Lo que
   cierra es la **elección del instrumento**, no un campo del fichero: un rediseño del
   paquete A parte de ahí y tiene que medir su precedencia antes de nada.

**El libro de cuentas, con la cifra exacta —y es la que manda.** 1 destinatario, movimiento
`GASTO`, tramo `p2_sender_sumidero`, `http 201`, `2026-09-17T15:34:52Z`. Comprometido **1 de
3**, margen restante **2**. **Ojo al citar la evidencia:** el JSON archivado dice
`"envios_reales": 0` en su primer campo, y eso es un defecto del instrumento —el campo
estaba escrito a mano, ver más abajo—, no una medición. La cifra válida es **1**. El destinatario era `sonda-00001@example.invalid` —TLD reservado por RFC
2606— y la petición llevaba la cabecera de sandbox, así que **ningún buzón humano recibió
nada y ninguna dirección de la lista blanca se tocó**. Lo que el libro cuenta como gasto es
la **aceptación**. Si descontó crédito no está medido y no se afirma en ninguna dirección.

**Lo que esto le hace a la premisa del carril verde de D-046.** El mandato declara verdes
los «sondeos que el proveedor rechaza antes de entregar, incluidos los dirigidos a
direcciones que no pueden recibir». Medido: las dos propiedades son **independientes**. Que
un destinatario no pueda recibir no implica que la petición se rechace. No invalida la lista
blanca —que se cumplió— ni el carril rojo. Lo que refina es el motivo por el que el libro de
cuentas tiene que existir **aunque el paquete se declare de cero envíos**: es justo lo que
hoy lo ha cazado. El texto vive en `docs/08-mandato.md`, que es carril tuyo: se anota aquí y
no se toca allí.

### Preguntas que esta pasada devuelve

- **Q-A1 · El paquete A se ha quedado sin guarda: ¿se rediseña o esos tres valores se
  quedan en ámbar?** Con `sender_sumidero` aceptada, la bisección por error discriminante
  pierde el instrumento de DISC-03, DISC-04 y DISC-16. Las dos opciones son rediseñarlo
  sobre `sender_ausente`, midiendo primero su precedencia frente a un tope de carga, o
  declarar esos tres **no medibles a coste cero** y dejarlos en ámbar. No la decido:
  `CRITERIOS.md` no tiene regla para esto y cambia qué mide el paquete. Dato que orienta:
  con el tope de la pasada en 3 destinatarios, los casos de tope del preflight —2.001 y 100
  destinatarios— no caben, así que la precedencia tampoco era medible hoy aunque el script
  hubiera seguido. **FUERA DEL CONSEJO (D-048): es instrumento, no criterio.** Tres razones y la tercera decide: `CRITERIOS.md` es un libro sobre cómo se modela un dato y la palabra «instrumento» no aparece en él; la guarda no se prefiere, se **mide** (`lib_guarda_preflight_brevo.sh`); y no generaliza, porque depende del orden interno de validación de Brevo, así que MailerSend y Postmark necesitarán la suya. No hay regla que extraer, y el paso 4 de la cadena no tendría dónde aterrizar. Lo decide quien rediseñe el script, dentro de `sondeo-empirico`, midiendo primero la precedencia. Aviso del tribunal que hay que respetar: **no subir el tope de la pasada** para medirla — la unidad de gasto es un destinatario de una petición aceptada, y una petición de 2.001 destinatarios que Brevo acepte por sorpresa gastaría 2.001 contra los 2 que quedan. El tope de 3 es la reserva exacta del escenario que ya ocurrió hoy.
- **Q-A2 · ¿Descontó crédito la petición aceptada?** Sin medir, **y sin línea base**. El
  contraste es entre **dos** lecturas de `GET /v3/account`, y la primera no existe: en
  `evidencias/` no hay ninguna lectura archivada de ese endpoint. Lo que el panel dejó el
  2026-09-17 son **dos saldos distintos** —`"Emails"` → `"300 left out of 300"`, que es la
  cuota diaria, y `"Prepaid credits"` → `"0 credits left"` (`panel_brevo_2026-09-17.md`,
  líneas 70-71)—, y el propio volcado los separa en su §4. Cuál de los dos es el campo
  `credits` del endpoint **es DISC-14**, que sigue abierta. En esta cuenta Free el prepago
  está a 0 y no puede decrementar, así que **leer `credits` no responde la pregunta**: lo que
  hay que mirar es el contador de la **cuota diaria**. Y «0 logs» no sirve de control, porque
  sandbox declara que **no crea registros**. La vía, entonces: leer y **archivar** el saldo
  antes de la siguiente petición y volver a leerlo después —`probe_brevo_a_cuenta.sh`—, que
  exige borrar la PARADA a mano, y `lib_presupuesto_brevo.sh` reserva eso al operador.
  Comparar contra el 300 del panel no vale. **MEDIDA el 2026-09-17 ([E3]), con el autor autorizando la PARADA y el destinatario.** Y la respuesta es **no descontó**: el `201` de las 15:34 llevaba un destinatario y el contador seguía en 300 seis horas después. Lo que lo hace concluyente es el otro brazo: la petición real de las 21:30, con dos destinatarios y **sin** la cabecera de sandbox, descontó **2**. Si la unidad es el destinatario —y ahora está medido que lo es—, aquel envío debería haber consumido 1. La única exención presente era `X-Sib-Sandbox: drop`. **Límite de lo anterior, y hay que decirlo:** es un contraste entre dos peticiones separadas por horas, no un brazo controlado. El brazo de sandbox estaba retirado de la pasada por presupuesto, así que ese lado de DISC-14 sigue sin medirse de forma limpia. Lo que sí queda medido, y era el objetivo real del sondeo: **la cuota se descuenta por destinatario**, par de bisección 0 en reposo y 2 en el envío.
- **Q-A3 · ¿Abre fricción que Brevo acepte, EN SANDBOX, un envío con remitente no verificado
  en un dominio inexistente, sin validarlo en la petición?** **L1** se cumple —cuerpo
  literal más fichero en `evidencias/`—, pero la promoción es **B9/D-042** y no es mía.
  Lectura conservadora aplicada: **no se abre F-28**. Va como observación **O-20** en
  `fricciones.md`. Y el enunciado lleva el «en sandbox» a propósito: lo medido es la
  validación de **formato**, que es lo único que sandbox declara comprobar, así que el
  hueco del remitente en `not_found` sigue **abierto**. La celda de Brevo de **F-21** pasa a
  *(verificar)* con una **instancia ya medida**: el `400` de p1 volvió con
  `x-sib-ratelimit-remaining: 999` de `limit 1000`, o sea que una petición **rechazada**
  consume unidad del bucket de caudal. Lo que sigue sin medir es si la **aceptación**
  descontó cuota de correo, que es Q-A2. Cruza con el hallazgo del panel —la cuenta es un
  Free real que entrega a donde se le diga— y con que la clave llamada «Sandbox» sea solo el
  nombre que le puso el autor, no un modo de cuenta. **LECTURA CONSERVADORA MANTENIDA (D-048).** La promoción es B9/D-042 y no cambia: no se abre F-28, queda como O-20. Lo que sí queda medido es que una petición **rechazada** consume unidad del cubo de caudal —el `400` de p1 volvió con `x-sib-ratelimit-remaining: 999` de `limit 1000`—, así que la celda de Brevo de **F-21** pasa a *(verificar)* con instancia medida.
- **Q-A4 · La segunda clave de API.** El hueco 8 —si el caudal se cuenta por cuenta o por
  clave— necesita dos claves de la misma cuenta, y `~/.config/tfm/.env` solo define
  `BREVO_API_KEY`. Alta y rotación de claves es carril rojo. **CERRADA midiendo ([E4], 2026-09-17 22:49 UTC).** El autor creó la segunda clave a las 00:27 del 18-09 y con ella el hueco 8 dejó de ser carril rojo. Seis `GET /v3/account` alternando las dos claves dan **una sola serie descendente** —4999, 4998 y 4997 con la primera, **4996 con la segunda**, 4995 de vuelta con la primera y 4994 con la segunda—, y el `reset` acompaña de 643 a 637, que es la misma ventana corriendo. **El cubo es de la cuenta: crear claves no multiplica el caudal.** Cero envíos. Sigue en `not_found` si la segmentación cambia por IP de origen o por sub-organización, que una cuenta Free no puede responder.
- **Q-A5 · La regla de la skill es la que fabricó la cita que se queda vieja.** El paso 1 de
  «Al recibir el resultado» de `sondeo-empirico` manda guardar el volcado como
  `evidencias/probe_<pregunta>_<fecha>.json`, que **no es el nombre que escribe ningún
  script**: los `probe_brevo_*.sh` escriben `probe_brevo_a_<sondeo>_<fecha>_<HHMMSS>.json`.
  De ahí salió la copia a mano que el `datasheet.yaml` citaba, y que ninguna herramienta
  lee, refresca ni comprueba —`guarda_elegida()` solo busca el patrón del script—. Las
  citas ya apuntan al nombre del script, así que el problema de esta datasheet está
  resuelto; lo que sigue abierto es **la regla**. Dos opciones: cambiar el paso 1 para que
  cite el nombre que el script escribe, o que los scripts publiquen ellos mismos un alias
  estable al final de `resumir()`. No la decido porque toca la skill **instalada** en
  `~/.claude/skills/`, fuera del repo, y su `.skill` empaquetado en `05_salida/_skills/`:
  los dos tendrían que cambiar a la vez y eso es más que aplicar un hallazgo. Lo mismo para
  añadirle las dos convenciones nuevas del volcado —registrar la petición y **calcular** el
  coste en vez de declararlo—, que hoy solo viven en los ocho scripts y en sus tests. **ARREGLADA (D-048).** El paso 1 de `sondeo-empirico` pedía guardar el volcado como `probe_<pregunta>_<fecha>.json`, que ningún script escribe. Ahora pide **el nombre que el script escribe**, con el motivo dentro para que nadie lo revierta, y añade que la redacción cubre también direcciones, nombre y dirección postal del titular, que es lo que devuelven `/senders` y `/account`. Skill actualizada en `~/.claude/skills/` y reempaquetada en `05_salida/_skills/`.

### Cuatro defectos del instrumento: tres arreglados el mismo día, uno pendiente

Viven en `05_salida/_herramientas/`, que no es carril de este fichero. Pero los tres
primeros tocaban a la **evidencia citable**, no al script, así que se arreglaron el
2026-09-17, con test en rojo antes del arreglo. El JSON archivado es anterior y se cita como
lo que es: el volcado de un instrumento defectuoso.

1. **El coste del JSON estaba escrito a mano. ARREGLADO.** El resumen declaraba
   `"envios_reales": 0` en el mismo objeto en el que declaraba `"invariante_cero_envios":
   "ROTA"`, `"peticiones_aceptadas_2xx": ["p2_sender_sumidero"]` y `http 201`, mientras el
   libro anotaba `GASTO` de 1. El campo era el literal `0` en el código, y **lo mismo en los
   otros siete sondeos**, así que habría dicho `0` aunque los ocho casos hubieran vuelto con
   `201`. **El único sitio que dice cero es la evidencia**: el libro dice 1 y `fuentes.md`
   dice 1. Hoy se calcula sumando los destinatarios de las peticiones aceptadas, que es la
   unidad con la que el libro reserva y gasta, y `test_v_ningun_sondeo_cablea_el_coste` lo
   sujeta en los ocho.
2. **La petición no se registraba. ARREGLADO.** El volcado guardaba la respuesta y, de la
   petición, solo `bytes_peticion`. Así que la garantía central de D-046 —ninguna dirección
   de la lista blanca se tocó— **no era verificable desde la evidencia**: había que leer
   `tos()` en el script. Lo mismo con el remitente y con `X-Sib-Sandbox: drop`, que el
   `datasheet.yaml` cita como literales. Hoy cada caso lleva `peticion` con las cabeceras
   enviadas, el remitente y los destinatarios con su dominio.
3. **El sumidero no llegaba al redactor. ARREGLADO.** El prefijo de entorno pasaba
   `SUMIDERO="$SUMIDERO"` cuando `SUMIDERO` es `readonly`, y bash contesta `SUMIDERO:
   variable de sólo lectura`. Comprobado en esta máquina con un caso mínimo: la orden **sí**
   se ejecuta y las otras cuatro asignaciones llegan. Lo que no llegaba era el sumidero, así
   que el redactor **sobre-redactaba** toda dirección suelta, incluidas las sintéticas que
   la evidencia debería poder leer. No hubo fuga: el JSON no contiene el patrón de la clave.
   Hoy la variable del prefijo se llama `SUMIDERO_RED` y, si llegara vacía, el resumen lo
   dice en `defecto_del_instrumento`.
   De paso se corrigió la **cabecera** del script, que declaraba *«COSTE EN ENVIOS: 0 envios
   ENTREGADOS»* y *«Ninguna puede ser aceptada»* —lo que esta medición refutó— y el rótulo
   del presupuesto, que imprimía la misma promesa al arrancar.
4. **`probe_brevo_a_cuerpo_429.sh`, conflicto de orden. PENDIENTE.** Su cabecera exige que
   el **paquete B completo** esté corrido antes, porque agota hasta 3.600 s el bucket de
   `"All other endpoints"` (100 por hora). Ahí vive `GET /v3/account`, que es la medición
   entera del sondeo que gasta correo irreversible. El orden recibido lo pone último del
   paquete A, o sea antes del B, y no tiene guarda ejecutable: solo el comentario. Sin daño
   esta vez porque no se ejecutó. No se toca aquí porque cambia **qué mide** el paquete, y
   eso es Q-A1.

---

## Lo que queda abierto

- **Ninguna de las dieciocho preguntas sigue abierta.** Trece las cerró el consejo (D-048),
  **Q11** la cerró [E2] con la lectura de cabecera que la PARADA había dejado sin hacer, y
  **Q-A2** y **Q-A4** se midieron con [E3] y [E4].
- **La pasada del 2026-09-21 devolvió un hallazgo mayor que sus dos cierres: ocho de las
  once abiertas no estaban listas por D12.** Se arbitraron con dos escépticos de lente
  distinta por entrada, y ocho volvieron como entrada no lista: registran el recorte que la
  entrada transcribe en vez de la unidad entera con su condición dentro. D12 es del 18-09 y
  estas entradas se escribieron antes. Una entrada no lista **no decide nada**, así que esas
  ocho nunca fueron arbitrables, y eso explica la tanda del 18-09 mejor que ninguna otra
  cosa. Reescribir cada lado con su unidad entera es documental, sobre volcados ya
  archivados, y no cuesta ni un envío.
- **Reescritas las nueve esa misma tarde, tres cerraron y tres se confirmaron.** Cerraron
  **DISC-04**, **DISC-05** y **DISC-11**, las tres por **E5 (1)**. En DISC-04 los dos lados
  acotan objetos distintos: el adjunto y el parámetro `messageVersions`. El 99 que la entrada
  enfrentaba al 2.000 estaba en la misma frase que el 2.000. En DISC-05 y DISC-11 los lados
  son **ausencias cruzadas**, y una ausencia comprobada no es literal.
  Se confirmaron **DISC-02** y **DISC-06**, mal registradas pero bien abiertas, y **DISC-08**
  con su cuarto add-on medido (cerrada el 2026-10-18 por D17). **DISC-15 se refunda**: cae su lado del blog, que no nombra el
  tramo Advanced ni una vez, y entra una contradicción interna a [F6]. **Ningún cierre mueve
  el semáforo**, y los cinco `max: 2000` siguen en 🟡 por **D1** y la regla **D13**.
- De las **diecisiete DISC** de `fuentes.md` quedan **cinco abiertas** desde el 2026-10-18, una
  de ellas acotada (eran seis hasta que D17 cerró DISC-08). **Doce están cerradas**, y cada una con su línea de cierre dentro de
  su entrada, que es lo que **E5** exige. **DISC-03** y **DISC-16** cerraron el 2026-09-21
  por **E5 (1)**: en las dos, los lados acotaban magnitudes distintas, y en DISC-03 el
  volcado prueba que [F13] publica él mismo el 2.000 que la entrada atribuía al lado
  contrario. **DISC-09** y **DISC-14** con [E3]. **DISC-17** con
  [E2]: `GET /v3/smtp/emails` devuelve `x-sib-ratelimit-limit: 2`, su fila propia.
  **DISC-10** en el panel del 18-09, con la retención configurable de 1 a 24 meses.
  **DISC-07** por **E5**, porque las dos citas no hablan de la misma magnitud. Y **DISC-13**
  con [E5], midiendo el `reset` en un endpoint horario.

  **DISC-04 no está en esa lista, y hasta hoy se contaba como si lo estuviera.** Dos
  documentos la dan por «disuelta con los aliases de Q1», y su entrada en `fuentes.md`
  **no tiene línea de cierre**: termina en «Estado tras [E1]: sin datos». E5 es explícita:
  sin esa línea no está cerrada. Además los aliases de Q1 son los tres tramos de caudal, y
  DISC-04 enfrenta dos topes de destinatarios según la petición lleve adjunto, que es otro
  eje. Queda **abierta** y sin arbitrar hasta que alguien escriba el cierre en su entrada o
  retire la afirmación. La **acotada** es DISC-12, por el cuerpo del 429. DISC-08 dejó de
  estarlo el 2026-09-21: leída la página en dólares con los dos conmutadores (**E9**), el
  lado A resultó ser la columna anual, `Sales Essentials` coincide en `$31` y cae, y los
  otros dos quedan **bien abiertos por primera vez**. El 2026-10-18 D17 cierra la entrada: vale la
  página en USD y `"Monthly"`, y el centro de ayuda queda como incoherencia del pricing. La pasada de E5 sobre las doce
  abiertas **cerró una**, que es lo que el consejo declaró antes de intentarlo.
  **El 2026-09-18 se intentó arbitrar las trece y no se cerró ninguna**: cada propuesta pasó
  por un escéptico y las trece cayeron, casi siempre por lo mismo —una premisa citada donde
  no estaba, un color leído del sitio equivocado, evidencia que el registro no conocía—. Lo
  que sobrevive de esa tanda son las correcciones, no los cierres, y están aplicadas aquí y
  en `fuentes.md`.
- Las **seis fricciones nuevas** (F-23 a F-28). **F-26 y F-28 cruzan por recurrencia**, que
  es la primera vía de B9 y no pide listón. Las otras cuatro solo pueden ir por traza, y el
  18-09 se midió cuánto les falta: **L2 está cumplida en las cuatro**, contra PRIME4API y con
  caso de control, en `evidencias/l2_prime4api_2026-09-18.json`; **L3 aguanta en F-24 y F-27
  y se cae en F-23 y F-25**; y **L1 les faltaba a las cuatro por lo mismo**, que no existía
  `hechos_brevo.md` y no había volcados. **Los dos artefactos existen desde el 2026-09-21**,
  así que **F-24 y F-27 promueven por traza** (validado por el autor, chat, 2026-09-21) y F-23 y
  F-25 siguen sin promover, ahora por **L3** y no por L1. La comprobación barata que quedaba
  pendiente se hizo el 18-09, una a una contra las cuatro Datasheets cerradas, y **promueve
  tres**: **F-22** (2/5, con Postmark), **F-26** (2/5 en la mitad de la divisa y 3/5 en la de
  los impuestos) y **F-28**, nueva, la lista de IP autorizadas (2/5, con MailerSend, que la
  documenta como rechazo `#MS40305` y la condiciona al plan). **F-25 no recurre**: 1/5, solo
  Brevo.
- Los **volcados de página** (E2) se hicieron el **2026-09-21**: veintiocho ficheros en
  `evidencias/paginas/2026-09-21/`, cuatro de ellos un estado distinto del configurador de
  precios, porque una página con conmutador sirve un estado por volcado. Con ellos el punto 3
  del checklist se pudo correr **por primera vez** en Brevo, donde antes devolvía
  `SIN-PAG 114`: hoy da **OK 100 · CAMBIO 0 · F-09 1 · SIN-CITA 0**. El único F-09 es la guía
  de lotes, que el 16-09 cerraba con `"the request will fail"` y hoy cierra con `"it is
  ignored in favor of the recipients defined in messageVersions"`; sin volcado de aquel día
  manda **E8** y la cita no cae. Lo que ya
  había en `evidencias/` son las dos ejecuciones del motor: `verificar_prime4api_2026-09-16.txt`
  (9 OK / 13 ERR, DV-03) y `prime4api_inbound_sin_rate_2026-09-16.txt` (el antes y el
  después del `rate` que faltaba en `/v3/inbound/events`).
- **DV-03 reaparece** con el plan Enterprise, exactamente como en SendGrid. No se toca: la
  regla **A3** obliga a incluirlo porque tiene tarjeta y precio literal en la lista oficial,
  y el 13 ERR es del motor, no del modelado (`fricciones.md`, O-17).

## Informe del verificador adversarial (D-013) — 2026-10-31

Un agente independiente, con acceso solo al `datasheet.yaml`, leyó cada URL dos veces, sin y con
JavaScript, y fechó con Wayback lo que no encontró.

- **Resultado: 73 entradas con URL, 56 coinciden.** Ningún valor modelado queda refutado y ningún
  semáforo se mueve: **19 🟢 · 17 🟡 · 1 🔴**.
- **Cambios del proveedor (aplicados como relecturas fechadas, E3).** El artículo de planes de la
  ayuda se reescribió después del 2026-10-05.
  - El asiento de marketing pasa de 9 a 12 USD y cae esa parte de la incoherencia de DISC-08.
    Quedan el logo y Sales Advanced.
  - Desaparecen la equivalencia de un crédito por destinatario y la frase de las funciones de
    Starter.
  - Las líneas del YAML conservan la cita antigua con sus dos fechas.
- **La guía de lotes y el 2.000 (aplicado).** El verificador leyó como cambio que la guía publique
  `"Maximum 2000 total recipients per API request"`. No lo es: ya estaba en el volcado del
  2026-09-21, y por eso DISC-03 cerró ese día. Lo que estaba mal era la NOTA del YAML, que seguía
  diciendo que la guía contradice el tope. Ya está corregida. El 2.000 sigue en 🟡 por D1, por el
  alcance sin versiones (BR-163), y no por una contradicción.
- **Errores del dato sin efecto en valores (aplicados).**
  - **Línea 347:** son catorce filas con RPS y RPH, no diez. Se corrige también en [F6] y en O-15.
  - **Línea 364:** la URL de la NOTA del 202 pasa a `/openapi/email-api.json`.
- **Sin aplicar, fuera de la lista aprobada:** línea 353, línea 401 y los 1.000 USD de
  Enterprise que da la API pública de precios. Están en el informe.
- **`verificar_citas.py`.**
  - Da `F-09` en las tres relecturas fechadas.
  - Da un `CAMBIO` falso en los topes de las consultas: el literal es de la referencia
    renderizada y el script lo busca en el JSON. Está explicado en el `LEEME` de los volcados.

Informe íntegro: `evidencias/verificador_adversarial_2026-10-31.md`. Volcados:
`evidencias/paginas/2026-10-31/`.
