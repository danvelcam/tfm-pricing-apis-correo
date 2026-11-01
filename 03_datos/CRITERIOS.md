# Criterios de modelado del catálogo — libro de reglas

Lo ya decidido, escrito como regla para que **no se vuelva a preguntar**. Una datasheet
nueva se construye aplicando esto. Cada regla lleva la decisión que la origina, y si se
decide una regla nueva se añade aquí en la misma tanda.

**Quién puede escribir reglas aquí (D-047, 2026-09-17).** Dos orígenes, y la procedencia se
declara en la regla:

- **el autor**, con su marca `*(D-nnn)*` de siempre. Es el único origen válido para la
  **sección A**, alcance y selección, que es carril rojo.
- **El consejo**, en las secciones **B…H**, con la marca `*(consejo aaaa-mm-dd)*` y el caso
  que la originó. Antes de D-047 lo que el libro no cubría se le preguntaba al autor por
  tandas; ahora lo resuelve el consejo y su veredicto entra aquí como regla. El
  procedimiento está en `docs/08-mandato.md` §La cadena de decisión.

Una regla del consejo se veta como cualquier acción del carril verde: el autor la tumba en su
lectura y la bitácora permite revertir la clase entera con su huella.

## A. Alcance y selección
- **A1 · Producto modelado.** Cuando un proveedor vende varios productos bajo la misma
  cuenta (transaccional / marketing), se modela **el transaccional**. El otro se
  documenta en `fuentes.md` y se registra como fricción (F-10). *(Q1, 2026-09-01)*
- **A2 · Catálogo mutable.** Ocho APIs de partida (D-014.1). Si una no se puede
  documentar con trazabilidad, entra la primera de reserva y la sustitución se anota en
  `SELECCION_APIS_2026-09-01.md` con fecha y motivo. *(D-014)*
- **A3 · Qué plan entra en `plans`.** Entra el plan que la página de precios del
  proveedor, que es su lista oficial, muestra con fila o tarjeta, aunque su precio o su
  cuota digan «Custom»: va `custom`, en 🟢 por literal. El plan que solo existe como
  «contact us» o en texto de ayuda, sin fila ni tarjeta, queda fuera de `plans`, y sus
  límites publicados van al provenance, a `metadata.not_found` y a `features.md`. La regla
  describe lo ya modelado: Resend Enterprise y SendGrid Premier entran (fila «Custom»), y
  el tramo de Postmark por encima de 1,5 M y el Enterprise de MailerSend quedan fuera (sin
  fila). *(Q2 MailerSend, D-026, 2026-09-14)*
- **A4 · Qué endpoints expone cada plan.** La página de precios, que es la lista oficial,
  decide también qué endpoints tiene cada plan. Un caudal o un tope que otra página publica
  para un plan al que la lista no atribuye el endpoint **no lo crea**: va al provenance, a
  `metadata.not_found` y a la fricción F-08. MailerSend: `/v1/bulk-email` se omite en Free
  aunque el artículo de rate limits publique «Free plan: 10 API calls/min». *(Q3 MailerSend,
  D-027, 2026-09-14)*

## B. Conformidad con el esquema
- **B1 · Esquema al dedillo.** La datasheet solo contiene lo que ACM2YAML v0.3 acepta y
  PRIME4API ejecuta. Nada de formas inventadas (`not_found` como valor, campos extra).
  Lo que no cabe → fricción numerada + `metadata.not_found` + provenance. *(D-014.2, DV-02)*
- **B2 · Sin `base_uri`.** No es campo de cabecera de v0.3. *(Q7)*
- **B3 · Límites de recursos (dominios, webhooks, usuarios, servidores, claves,
  créditos) NO son cuotas.** No van a `capacity`. Van al provenance con cifra y cita, y
  a la fricción F-11 (recurrente: promovible al cap. 6). *(Q6)*
- **B4 · Políticas (retención de datos, etc.) NO son cuotas.** Provenance, no
  `capacity`. *(Q4)*
- **B5 · `workload` es una lista** de cargas, no un mapa. *(DV-01)*
- **B6 · `overage_cost` unitario:** `price` por 1 unidad, no por lote. *(D-002)*
- **B7 · Cuota que ningún plan puede referenciar.** Una cuota publicada que el esquema no
  puede enlazar sin duplicar otra ya modelada **no se define en `capacity`**. Va al provenance
  con su literal, a `metadata.not_found` con la razón y a la fricción. Es B1 aplicado a la
  capacidad: una entrada definida y no referenciada es peso muerto que el motor no evalúa.
  MailerSend: el tope diario de 100 emails del Free, que cuatro fuentes expresan en peticiones
  (DISC-11) y que el plan ya lleva como `quota_request_daily_free`. *(Q5 MailerSend, D-029,
  2026-09-14)*
- **B8 · Cada límite se declara una sola vez.** Una `quota` o un `rate` que vale para todos
  los endpoints del plan se declara **en el plan**; uno propio de un endpoint, **en ese
  endpoint**. Un endpoint —o el comodín `/*`, o un alias de estado— no repite la referencia
  que ya declara su plan. PRIME4API hereda la del plan y le concatena la del endpoint sin
  deduplicar (`_get_node_scenarios`), así que la repetición cuenta dos veces: en SendGrid
  Essentials la curva a 30 días daba 100.000 correos donde el proveedor publica 50.000
  (DV-05). Un límite distinto del que declara el plan no es repetición y se queda: la cuota
  diaria del Free de Resend convive con la mensual del plan. El validador v0.3 lo comprueba
  y falla con error. *(abierta 13, D-035, 2026-09-14)*
- **B9 · Una fricción se promueve por recurrencia o por caso medido.** Recurrencia: el patrón
  reaparece en ≥ 2 APIs del catálogo (D-008 §3, intacta). Caso medido: **una sola API basta** si
  la fricción cumple las tres condiciones del listón, y las tres se comprueban abriendo un
  fichero. **L1 · Hecho, no juicio:** la carencia descansa en un literal citado o en un sondeo
  ejecutado, con su fila en `hechos_*.md` y su fichero en `evidencias/`. **L2 · Consecuencia
  ejecutada sobre el consumidor de referencia:** PRIME4API, con la Datasheet del catálogo
  delante y **sin manipularla**, devuelve un valor falso o deja sin responder lo que respondería
  si el esquema expresara la carencia; con la ejecución archivada y un caso de control que
  demuestre que el motor sabe responder bien. **L3 · La carencia es del esquema:** ningún
  mecanismo ya existente del README de Gavira y Ruiz la absorbe, y no se explica por un defecto
  del motor ya inventariado como DV-nn. El veredicto va a la columna Vía del inventario:
  `recurr.`, `traza` o la condición que falla. *(abierta 22, D-042, 2026-09-15)*

- **B10 · Cuándo una variante suma recurrencia.** B9 cuenta ocurrencias y no dice qué vale
  una celda ⚠️ **variante**, que hasta hoy se resolvía caso a caso. Una variante suma **1**
  si pasa dos cláusulas, y las dos se comprueban abriendo un fichero. **V1 · Enunciado
  entero, mecanismo distinto.** El caso sostiene las dos mitades del enunciado y solo cambia
  el mecanismo por el que ocurre; si se le cae una mitad, no suma. **V2 · Una evidencia, una
  fila.** El mismo hecho no suma dos veces en el tablero: si ya cuenta como ocurrencia plena
  en otra fricción, aquí no cuenta. V2 se comprueba **sobre el tablero y no sobre la
  prosa**, porque manda dónde está contada esa evidencia y no lo que declare un párrafo de
  contraste. La celda escribe qué cláusula cumple o falla, con la frase que lo decide, y
  reescribir el enunciado de una fricción obliga a repasar su fila entera. Estrenar el test
  obliga además a pasarlo por las celdas *(verificar)* de esa fila en la misma pasada. El
  resultado se escribe aunque promueva la fricción: un test que solo ratifica lo ya sabido
  no está probado. La marca ⚠️ **parcial** es otra cosa y esta regla no la toca.

  **Los tres casos que la originan.** MailerSend F-04 suma, por ser *«el mismo tercer estado
  —expuesta pero no real en el momento de la petición— con otro mecanismo»*. Brevo F-02 no
  suma, porque *«le falta la mitad del enunciado: no hay sobrecoste que varíe, porque no hay
  sobrecoste»*. Y el caso de Postmark en F-30 falla V2: su escalera ya cuenta como
  ocurrencia plena en F-02. SendGrid F-03 **no** es precedente de esta regla, porque su
  motivo escrito es de valor y no de estructura —*«forzar el recuento le quitaría valor»*—,
  y se queda como está.

  **Lo que la regla admite de sí misma.** V1 nace de un único caso positivo, que es menos de
  lo que el propio B9 exige para promover. Por eso se estrena **provisional**: el primer
  veredicto no precalculado se anota en su ficha, y si dos APIs más pasan sin producirlo, la
  clase se reabre. Revertirla cuesta borrar la anotación de cláusula de las celdas ⚠️
  variante y el veredicto de F-30, y ningún `datasheet.yaml` cambia. No arrastra los
  veredictos ya escritos de F-04 ni de Brevo F-02, F-13 y F-18, que llevan su propio motivo,
  y sí cae la promoción que se apoye solo en ella. *(caso SES F-30, consejo 2026-09-18)*

- **B11 · Selector de volumen dentro de una tarjeta: los tramos son F-02, no planes ni
  aliases.** Cuando la página de precios mueve precio, volumen incluido y sobrecoste con un
  selector que comparte tarjeta con el plan, ningún tramo entra en `plans`. **A3** ya lo
  decide: entra la tarjeta, que es una, y los tramos no tienen fila propia. Tampoco es alias
  de **D7**, que la ampliación de Brevo ciñe al `rate` de un endpoint y no al precio ni a la
  cuota del plan; estirarlo ahí inventa forma y cae en **B1**. Lo que entra en `capacity` y en
  `price` es el **tramo mínimo de la tarjeta**, con el `overage_cost` de ese mismo tramo en
  unidad por 1 (**B6**), y la escalera entera va al provenance citada. Es el modelado ya
  cerrado en SendGrid, cuyo selector llega a nombrar los tramos —`"Essentials 50k"`, `"Pro
  300k"`, `"Pro 2.5M"`, con precio propio— y cuya datasheet modela cuatro planes. La escalera
  es la fricción **F-02**, que ya recurre en cinco APIs del catálogo *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: F-02 recuenta en 5/8 plenas en Postmark, Resend, SendGrid, MailerSend, Mailgun; antes: seis APIs)*, y se cuenta allí; no se
  modela ad hoc por API.

  **El mecanismo se verifica con el bloque de datos, no con el clic.** Una herramienta que no
  ejecuta JavaScript no impide decidir. Si el volcado trae el bloque de datos que el propio
  selector lee, ahí están las posiciones con su precio y su cuota, y eso es literal de fuente
  oficial por **D1**: verde, sin escalón 2 ni 3. Mailgun lo trae entero en `pricingData`, con
  `priceQty` y `valueQty` indexados por `activeQty`, así que la nota de `fuentes.md` que daba
  el mecanismo por indeterminado quedó desmentida por una evidencia de su misma fecha, y se
  corrige apuntando al volcado. Una nota de ese tipo describe el límite de la herramienta, no
  el estado de la evidencia, y antes de darla por buena se abre la carpeta `evidencias/` de esa
  fecha. Sin bloque de datos y sin navegador, el tramo mínimo se modela igual, y lo que va a
  `metadata.not_found` es si el selector repriza — nunca el precio.

  **Por qué el mínimo y no la posición por defecto.** Las dos coinciden en Mailgun:
  `defaultQty` es `"2"`, que cae en el primer tramo tanto de Foundation como de Scale, así que
  el caso no las separa. Manda el mínimo, por dos motivos. Es el precedente ya aplicado en una
  datasheet cerrada, y no depende del estado con que sirvan la página: una posición por
  defecto puede moverse con la geolocalización o con la divisa, y entonces el dato deja de ser
  reproducible por quien abra la misma URL.

  **Un nombre de plan suelto no crea plan.** El que solo aparece en FAQ o en bullets de venta,
  sin fila ni entrada en el bloque de datos, queda fuera por **A3** y se registra como
  discrepancia. Mailgun publica `"One dedicated IP is included with Foundation 100k, Growth and
  Scale plans."`, y de los tres nombres solo uno es huérfano: `"Foundation 100k"` es un tramo y
  está literal dentro de `pricingData`, en el tooltip de sobrecoste de Foundation; `"Scale"` es
  una tarjeta; queda `"Growth"`. *(caso Mailgun MG-5, consejo 2026-09-21)*

- **B12 · Producto sin planes con nombre.** Cuando la página de precios no publica planes con
  nombre sino una tabla de tramos de volumen del mismo producto —bloques, créditos, escalones
  de precio—, A3 no tiene a qué aplicarse: no hay fila de plan que incluir ni excluir, y la
  pregunta deja de ser de alcance y pasa a ser de esquema. `plans` lleva **una sola entrada**,
  con el nombre que el proveedor da al producto, y la tabla de tramos completa va al provenance
  con su literal y a la fricción de precio degresivo —**F-02** si le vale el enunciado entero,
  y si no la que mande **B13**—, nunca repartida en una entrada por tramo: seis entradas con el
  mismo rate, los mismos endpoints y las mismas features son peso muerto por B1 y B7, y
  PRIME4API las recorre seis veces sin añadir un escenario distinto. La regla describe lo ya
  modelado: SES declara `plans: a_la_carte:`, entrada única, sin que ninguna regla lo dijera
  hasta hoy. **La condición es que el tramo solo mueva el precio.** Un tramo que suba un rate o
  abra un endpoint, atribuido por la lista oficial (A4), no es esto y reabre la clase. Un
  estado de la cuenta sin fila ni tarjeta que publique cifras propias —demo, prueba, sandbox—
  **no entra por aquí**: entra como alias por **D7**, que ya dispara con que el proveedor
  publique cifras distintas por estado y nunca exigió que ese estado tenga fila. Mailchimp
  Transactional: entrada única del producto, los seis tramos de [F3] al provenance, y el alias
  `demo` con 25 envíos/hora en 🟢 por literal ([F15] doc, [F18] panel, [E1] sondeo, sin
  discrepancia), 500 de franquicia sin caducidad y 100 inbound/día. *(caso Mailchimp MC-1,
  consejo 2026-09-21)*

- **B13 · Precio unitario degresivo sin planes que lo sostengan.** Cuando el proveedor
  vende el producto por unidades prepagadas (bloques, créditos, paquetes) a un precio
  unitario que decrece con el volumen comprado, y la página de precios **no publica filas
  ni tarjetas de plan** que A3 pueda usar —el supuesto de **B12**—, la escalera no se
  convierte en planes ni en cuotas. La datasheet declara **un único plan representativo**:
  `price` = el coste de una unidad prepagada en el tramo de entrada, con el `period` de
  facturación publicado, en **🟡** porque el literal es un precio por unidad y el campo es el
  precio del plan, y ese mapeo lleva interpretación (D13); `quota` = una `capacity` con el tamaño
  de la unidad, en 🟢 si es literal; y **sin `overage_cost`**, porque agotar la unidad
  prepagada no es exceso tarificado (B6 no aplica). La escalera completa va al provenance como
  `NOTA` con su cita, y a `metadata.not_found` van el tramo sin cifra publicada y el mecanismo
  de facturación que la fuente no aclare. Una promoción temporal con requisitos de
  elegibilidad **no es precio de lista**: provenance, nunca `plans` (B4, D1). Que la fuente no
  diga si el precio del tramo alcanzado es marginal o plano **no abre `DISC-nn`**: no hay dos
  literales excluyentes, hay un dato no publicado, que es 🔴 y hallazgo (D11, E5).

  **No suma recurrencia, y por qué.** El caso se registra como **fricción propia** de la
  API. No es ocurrencia de F-02 —«cuotas por escalón, **y con overage por escalón**»: sin
  sobrecoste se le cae la mitad del enunciado, que es el caso Brevo ya escrito en B10 · V1—
  ni de F-27 de Brevo, cuyo enunciado exige que el exceso cambie el plan y lo dispare otra
  dimensión, y cuyos paquetes prepago ya cuentan dentro de ella (V2). Caso originario:
  Mailchimp Transactional, tabla de seis tramos de $20 a $10 por bloque de 25.000 correos
  [F3], 2026-09-21. *(caso Mailchimp MC-2, consejo 2026-09-21)*

- **B14 · Tope que el titular levanta solo no es `capacity`; el que exige aprobación del
  proveedor sí.** El test no es quién escribe la cifra, es quién tiene que aprobar que cambie.
  Si el titular la fija, la sube o la borra con una llamada del propio endpoint, sin coste, sin
  soporte y sin relación con el plan contratado, no hay compromiso comparable entre
  proveedores: el endpoint se modela en `endpoints` **sin cuota ni caudal asociados**, la cifra
  y el mecanismo van al provenance con su cita literal y a `metadata.not_found` con la razón, y
  el caso abre **fricción propia** —no es F-11, que cuenta recursos y no volumen de envío, ni
  B4, que son políticas—. Si en cambio subir la cifra pasa por el proveedor —soporte, solicitud
  o cambio de plan—, sigue en `capacity` aunque el proveedor la llame ajustable: así se modela
  ya `quota_email_daily_sandbox` de SES, cuyo aumento exige la solicitud de acceso a producción
  de AWS. Es B7 aplicado al origen del número en vez de a la duplicación: una cuota que ningún
  plan puede referenciar no se define en `capacity`. Caso originario: Mailgun [F7],
  `PUT/GET/DELETE /v5/accounts/limit/custom/monthly`, «The custom message limit imposes a hard
  limit on how many messages your account can send during a calendar month». La promoción de
  esa fricción al capítulo 6 no la toca esta regla: sigue las vías de D-008 §3 y B9. *(caso
  Mailgun F7 / MG-4, consejo 2026-09-21)*

- **B15 · Gobernanza cruzada entre productos hermanos no se presume por compartir cuenta o
  credencial.** A1 excluye del modelado el producto hermano y basta con documentarlo en
  `fuentes.md` como fricción (F-10) mientras «los dos productos no se toquen». Que se toquen
  **no se infiere** de compartir cuenta de facturación, panel o clave de API: eso es la forma
  normal en que una plataforma organiza el acceso a varios productos. Se comprueba con **un
  literal citado que declare el contador compartido**, o con **un sondeo de F2 que lo mida**
  —por ejemplo, la misma cabecera `X-RateLimit-*` devuelta a los dos, o un 429 del producto
  excluido disparado por tráfico del modelado—. Es B9·L1 aplicado a la frontera entre
  productos: sin literal ni sondeo, el rate o la cuota del producto excluido se queda con su
  cifra y su cita en `fuentes.md`, **no entra en `capacity` ni como alias**, y **no abre
  fricción de esquema por «contador compartido»**. La ausencia se registra donde van las
  ausencias de la recolección —la sección «Fuentes buscadas y NO encontradas» de `fuentes.md`
  y, si toca un campo del esquema, `metadata.not_found` (D-004)—, no como sospecha modelada.
  **No se invoca G2 aquí**: G2 vacía una celda de `features.md` y esto no es una celda, como
  D14 deja escrito en el mismo lote de reglas.

  **Lo que pasa cuando sí se confirma.** Confirmado el contador compartido por literal o por
  sondeo, el caso **no estrena fricción nueva**: pasa a la variante inversa de F-10 ya escrita
  en Brevo —cuota que no pertenece al producto modelado y que el consumidor del producto
  modelado agota igual—, con la misma consecuencia de esquema que allí se registró. Brevo la
  sostiene sobre cita literal (`"you can use your email credits to send both marketing and
  transactional emails"`); ese es el listón.

  **El caso que la origina.** Mailgun: Optimize publica `"API calls are subject to a rate limit
  of 500 requests every 10 seconds"` [F16] y Send no publica umbral [F2], bajo la misma cuenta
  [F24]. Se propuso tratarlo como contador compartido y no hay fuente que lo diga: [F2] apunta
  a lo contrario (`"Time windows may vary by API depending on resource usage"`), el panel
  muestra namespaces separados (`/mg/` frente a `/mgo/`) y Optimize sin suscripción, y el
  propio `fuentes.md` admite que no se buscó más. *(caso Mailgun MG-6, consejo 2026-09-21)*

- **B16 · Campo obligatorio de una cuota que el producto no tiene: vacío, en 🔴 y dentro de
  `capacity`.** Una cuota puede tener el valor publicado y aun así carecer de un campo que v0.3
  exige, porque el producto no tiene esa dimensión. No es un dato sin publicar: es que no existe
  tal cosa, y el proveedor lo dice. El campo se deja vacío, en 🔴, con el comentario que da la
  razón, y la ausencia va a `metadata.not_found` (D-004) y a una fricción numerada. La cuota
  **no sale de `capacity`**. Sacarla sería B7, y B7 pide otra condición: que ningún plan pueda
  referenciarla. Aquí sí la referencian, y quitarla deja ese estado con caudal y sin ningún tope
  de volumen, que se lee como capacidad ilimitada. Un error de validación es ruidoso y se ve; un
  tope borrado por omisión no se ve. Rellenar el campo con la forma que menos mienta tampoco
  cabe, ni siquiera en ámbar: B1 prohíbe la forma inventada, y el color no convierte en dato lo
  que la fuente niega. La forma que le falta al esquema se propone en la memoria, nunca dentro
  del `datasheet.yaml`.

  **El trato no distingue `period` de `window_type`.** Los dos carecen del mismo literal y se
  justifican con la misma cita. Que el validador marque uno como error duro y el otro como aviso
  es severidad de la herramienta, no criterio de modelado, y esa asimetría se corrige **en la
  herramienta**. El capítulo de metodología ya declara el criterio de salida —«cero errores, con
  los huecos deliberados señalizados como avisos justificados»— y `gen_datasheet_viewer.py` ya lo
  cumple para la cuota sin `value` y para el `window_type` ausente, con un aviso cuyo texto exige
  🔴 y entrada en `not_found`. El `period` ausente de una cuota es el único caso que se salía del
  patrón, y se alinea con esos dos. El aviso se concede solo dentro de `capacity` y solo al hueco
  justificado: en `max_power` y en `plans` el periodo ausente sigue siendo error, porque ahí nada
  lo declara deliberado.

  **El caso que la origina.** Mailchimp Transactional, los 500 correos de franquicia de la cuenta
  de prueba, que el proveedor publica y declara sin caducidad ni renovación —`"The emails
  included with the demo do not expire or renew"`—. Es la fricción F-33. *(consejo 2026-09-21)*

- **B17 · Elemento sin ocurrencias: se retira, no queda en 0/8.** Si la única ocurrencia de un
  elemento del inventario cae cuando se cierra la discrepancia de la que dependía, y la regla que
  la cierra impide reabrirla, el elemento sale del inventario. No cuenta como vivo ni como «sin
  promover». Un 0 de 8 no es un estado: las once que no promueven son casos reales que no llegan
  al umbral, y un 0/8 sería una hipótesis refutada en la misma columna. La retirada sigue la
  forma de F-19 y F-20. Su número no se reutiliza, la ficha se conserva marcada como refutada, el
  caption de `tab:recurrencia` nombra la discrepancia y la regla que la cerraron, y las cifras
  agregadas se recalculan en la misma tanda. Si la vía de reapertura sigue abierta, el elemento
  se queda en suspenso. Si la discrepancia vuelve a abrirse, el elemento nace con número nuevo.

  **El caso que la origina.** F-17 («un tercer tope sin nivel de enganche») tenía su única
  celda, en suspenso, en MailerSend, y dependía de DISC-11. D17 cerró DISC-11 con la página de
  precios: 100 *requests* diarias en Free. La propia ficha decía que, en peticiones, «la
  consecuencia enunciada es falsa». Inventario: 36 → 35; 24 promueven y 11 no. Votación 5–0.
  *Si resulta equivocada:* se repone la fila de F-17 en suspenso y se vuelve a 36 elementos en
  los mismos pasajes que tocó la retirada. *(caso MailerSend DISC-11, consejo 2026-10-18)*

- **B18 · La unidad de un límite es la que el motor puede casar en cada nodo que lo referencia,
  y la que publica el proveedor, si es otra, se documenta.** Un proveedor puede contar un
  caudal o una cuota en una unidad de carga (correos, destinatarios). Si algún endpoint que
  referencia ese límite no declara `workload` en esa unidad, el límite se queda en `requests`.
  PRIME4API descarta sin aviso, nodo a nodo, el límite cuya unidad no está en su `workload`.
  Cambiar la unidad dejaría ese endpoint sin tope, y nadie lo vería: es el error que B16 no
  admite. Si todos los nodos que lo referencian declaran esa carga, se declara la unidad
  publicada, como Mailchimp `rate_email_hourly_demo` en `emails`. En los dos casos la unidad
  publicada va al provenance, con su literal y su efecto en la curva, y la
  diferencia va a `metadata.not_found`. Si dos literales discrepan sobre qué cuenta el límite,
  se abre `DISC-nn` (D11, D12) y manda E7. La regla no salva el color. Si ninguna fuente dice
  la unidad declarada, la cifra no mapea sin interpretación y va en 🟡 por D1 (D13). La marca
  va en la línea de la cifra, porque `unit` no lleva marca (E15).

  **El caso.** SES `rate_request_send_sandbox` declara 1 por segundo en `requests`. [F2] y [F3]
  lo cuentan en mensajes, [F1] en destinatarios, y ninguna fuente en peticiones. En `emails`,
  el envío por lotes, con `workload` solo en `MBs`, se queda sin límite en PRIME4API (medido el
  2026-10-31: `{"value":[]}`). El consejo votó 5 a 0 dejar `requests` con la explicación en el provenance, `not_found`
  y DISC-21 por la rama F2 de E7, y descartó `emails` porque cambiaba un valor y rompía el lote.
  El color se votó 5 a 0 en segunda ronda, a 🟡. El 🟢 de la cuota con DISC-02 abierta, que dos
  asientos daban por precedente, es de e46637c, anterior a E7 (cc90013), y no obliga.
  *Si resulta equivocada:* se retiran la explicación del provenance, la entrada de `not_found` y DISC-21, y el 1
  vuelve a 🟢. Ningún valor del YAML había cambiado. *(caso SES DISC-21, consejo 2026-10-31)*

## C. `type`
- **C1 · Se juzga sobre el producto modelado.** `api_first` si toda la funcionalidad de
  envío del producto modelado es programática; `partial_saas` si el panel envía algo
  que la API no. Que el panel de *otro* producto (marketing) envíe no cuenta.
  *(D-003, Q5 — Postmark y Resend: `api_first`)*. **Su test lo sustituye C2 desde el
  2026-09-14**; sigue vigente lo del producto modelado.

- **C2 · Test de `type`: operar, no solo enviar.** Sustituye al test de C1, que solo miraba el
  envío. `partial_saas` si **alguna** de estas tres operaciones del dominio del correo existe en
  el panel y no en la API: (1) enviar, individual o en lote; (2) crear o editar una plantilla;
  (3) añadir un dominio de envío y disparar su verificación. Las otras cinco —(4) rotar o crear
  credenciales adicionales estando ya autenticado; (5) webhooks de eventos; (6) inbound routing;
  (7) supresiones y rebotes; (8) actividad y logs— se comprueban igual y se anotan como fricción,
  pero **no** cambian el `type`. Quedan fuera del test cuenta, contraseña, 2FA, facturación,
  equipo y soporte: no son dominio del correo. **La primera credencial no cuenta en (4)**: ningún
  producto puede exponerla por API sin romper el arranque de la autenticación, así que su
  ausencia no dice nada del producto. Se comprueba contra la referencia de API del proveedor, con
  cita `[Fn]` por operación, más el panel con cuenta propia. El color lo fija D9.
  *(Q6 MailerSend, D-031, 2026-09-14)*

## D. Semáforo
- **D1 · Verde** = valor respaldado: literal en la fuente de verdad sin validar, o fijado por
  panel con cuenta propia o por sondeo (D4, D5). **Ámbar** = interpretado: hay texto, pero el
  valor exige una lectura que la fuente no hace literal, o dos literales oficiales chocan
  (D11). **Rojo** = no publicado (es un hallazgo). El color mide respaldo, no procedencia: la
  procedencia la fija D18. *(D-075, 2026-10-23; antes: «Verde = literal en fuente oficial.
  Ámbar = inferido o ambiguo»)*
- **D2 · Rate por defecto único.** Si el proveedor publica un solo rate «por equipo/
  cuenta» sin condicionarlo al plan, ese valor va en **verde** en todos los planes que
  no lo contradigan; el caudal negociado (Enterprise, *trusted senders*) va en **rojo**
  y a `not_found`. *(Q3)*
- **D3 · Ventana de una cuota.** Solo verde si la fuente dice literalmente cómo se
  reinicia. «wait until 24 hours» → `rolling` en ámbar. Ciclo de facturación interpretado
  → `fixed_billing_cycle` en ámbar. Nada → sin valor y aviso justificado.
- **D5 · Precisión: manda el panel** *(acotada por D17 desde el 2026-10-18)*. Si el panel
  con cuenta propia publica el mismo dato con más decimales que **otra fuente que no sea la
  página de precios**, va el valor del **panel en verde** y la otra cifra al provenance.
  Cuando el otro lado es la página de precios, manda D17 y gana la página: SendGrid DISC-01
  ($0.00133 en el panel, $0.0013 en la página), que D5 cerró a favor del panel el
  2026-09-06, se reabre y se cierra con $0.0013. *(SendGrid Q1, DISC-01, 2026-09-06;
  acotada por D-068)*
- **D4 · Un tope declarado en un solo campo** (p. ej. `to: Max 50` sin `cc`/`bcc`) se
  modela con ese valor en **ámbar** y la ambigüedad en `not_found`; solo el sondeo lo
  sube a verde. *(Q2, DISC-04)*
- **D6 · Cabecera aparecida en un sondeo de otro propósito.** Un valor que la API
  devuelve en cabecera (`ratelimit-limit`, `x-ratelimit-*`) durante un sondeo que no se
  diseñó para medirlo **se registra siempre y no se adopta**: DISC-nn si contradice o
  completa lo publicado, la entrada de `not_found` con el valor y su origen (fichero de
  evidencia, fecha, endpoint, código de respuesta), y una línea `NOTA` en el provenance.
  El campo (`max_power`) sigue vacío y en rojo hasta que un sondeo de caudal lo confirme
  (F2). *(D-020, Postmark `ratelimit-limit: 5000`, 2026-09-07)*
- **D7 · Aliases de estado.** El catálogo usa los aliases de v0.3 cuando el proveedor
  publica cifras distintas por estado de la cuenta para el mismo plan. El nombre del
  alias sale del vocabulario de estados del proveedor, no de la tabla de escenarios del
  README §3.4.3, que enumera casos de uso típicos y no un vocabulario cerrado. Un estado
  sin cifras publicadas no genera alias: va a `not_found`; si se mide, el alias lleva la
  medición con su fuente y su color, nunca archivada bajo el nombre de otro estado. Un
  valor de estado que no depende del plan se declara con clave sin sufijo de plan y se
  referencia desde cada bloque; la repetición que el esquema obliga se anota en el
  provenance como `NOTA`. Sustituye a la aplicación de D2 en las APIs que publiquen
  cifras por estado; D2 sigue vigente para el rate por defecto único. *(Q1 MailerSend,
  D-025, 2026-09-10)*

  **Ampliación: el disparador no es solo el estado.** El README §3.4.3 define el alias por
  «la forma en que el usuario consume el endpoint», y su tabla de casos típicos trae tres
  filas, no una: estado de la cuenta, método HTTP y modo de operación. Dos de las tres son
  elecciones de quien llama. Así que el alias cubre también la **banda comercial** elegible
  por plan, con el nombre que le dé el proveedor. Cuando un plan es elegible de más de una y
  ninguna fuente dice cuál rige, **se declaran todas las elegibles** y la indeterminación va
  a `not_found`, igual que O-12 hace con el disparador de estado en MailerSend. Un plan
  elegible de una sola banda no lleva alias.

  Dos condiciones de forma, las dos medidas el 2026-09-17 contra el motor: el `rate` va
  **entero dentro de cada alias** y no compartido en el endpoint, porque un `rate` compartido
  más aliases cae en **DV-05** y concatena en vez de sustituir; y el `workload` común sí se
  declara **una sola vez en el endpoint**, porque el motor lo inyecta en el alias que no
  traiga el suyo. Los aliases son **un solo eje**: dos ejes independientes sobre el mismo
  endpoint —banda y modo de consumo— no componen sin su producto cartesiano, y eso queda
  como fricción, no como modelado. *(Q1 Brevo, consejo 2026-09-17)*

- **D8 · Periodicidad no es ancla.** Una frase que declara cada cuánto se repite una ventana
  (`"resets every 30 days"`) **no** determina su tipo; lo determina el **ancla** del reinicio.
  Con ancla de facturación (`"reset on your next billing day"`) → `fixed_billing_cycle` en
  **verde**, y la frase de periodicidad se cita en el provenance como `NOTA` sin restarle color:
  no contradice el tipo de ventana, solo deja abierto el día exacto, que va a `not_found`. Sin
  ancla publicada → **ámbar** por D3, aunque la periodicidad sí esté escrita. MailerSend: Hobby,
  Starter y Professional en 🟢 por [F40][F41]; el Free en 🟡, que solo dice `"within the 30-day
  usage period"` (DISC-12 sigue abierta). *(Q7 MailerSend, D-030, 2026-09-14)*
- **D9 · Campos de juicio: el color mide cobertura, no literalidad.** Un campo que el esquema
  exige y que **ningún proveedor publica** —`type` es el caso— no puede cumplir D1: no hay
  literal que citar porque el dato no existe en la fuente, se emite al modelar. Solo en esos
  campos el semáforo cambia de significado: **verde** = el test del campo se aplicó entero, con
  cita por comprobación; **ámbar** = alguna comprobación quedó sin hacer; **rojo** no se usa. La
  excepción se declara en el provenance del campo, con la lista de lo comprobado y lo que falta.
  *(Q6a MailerSend, D-031, 2026-09-14)*

- **D10 · Total literal que es producto de topes por campo.** Cuando una fuente publica un
  total y ese total solo se explica como **producto** de topes por campo citados en la misma
  frase, la aritmética se anota en el provenance como `NOTA` y **no sube el color de los
  factores** mientras la **unidad del total** no esté confirmada: la identidad depende de qué
  cuenta el total, y eso suele ser otro hueco. Confirmada la unidad, los factores suben a verde
  sin más trámite. MailerSend: `"500 individual email objects … each containing up to 50 TO
  recipients, 10 CC, and 10 BCC, for a total of 35,000 emails"` [F49] es 500 × 70, así que el
  `max: 70` sigue 🟡 y sube a 🟢 en cuanto el sondeo de Q9 confirme que «emails» son
  destinatarios. *(Q8 MailerSend, D-032, 2026-09-14)*
- **D11 · Un literal que otro literal oficial contradice va en 🟡.** D1 da verde al literal en
  fuente oficial y ámbar a lo interpretado o ambiguo, y no dice cuál de las dos cláusulas manda
  cuando el proveedor publica **dos cifras incompatibles para el mismo campo**. Manda el ámbar,
  mientras la `DISC-nn` siga abierta. El color mide el respaldo del dato, no si alguien lo
  escribió, y un campo con dos cifras publicadas es justo donde hay que gastar la revisión. La
  contradicción tiene que ser **excluyente**: dos literales que no pueden ser ciertos a la vez
  sobre el mismo campo del mismo objeto. Varios valores que conviven no bajan el color, que es el
  caso de las ocho divisas de Brevo (Q8). Si la contradicción recae sobre la **atribución** —a qué
  plan alcanza un valor— baja el color de la atribución y no el del valor. **Tres excepciones, y
  son las reglas que ya ordenan fuentes:** **D5**, acotada desde el 2026-10-18, el panel sobre
  otra fuente que no sea la página de precios con el mismo contenido; **D17**, la página de
  precios sobre cualquier otra fuente; y **E4**, el desglose por plan sobre el «por defecto».
  Donde una de esas manda, el color es el que ella diga. D17 no ordena dos lecturas de la propia
  página de precios: ese par sigue aquí, en 🟡. **Cerrar la discrepancia no sube el color por sí solo**: lo sube la
  regla que la cierra, si lo admite, y una cabecera leída no lo sube nunca porque **D6** registra y
  no adopta — Brevo DISC-17 quedó arbitrada midiendo y su campo siguió en 🟡 ese día.
  **Corrección del 2026-09-18, tarde:** ese ejemplo ya no describe el caso. El campo de
  DISC-17, `rate_request_activity_general`, está hoy en 🟢, y no por la cabecera: un sondeo
  posterior **alcanzó el 429** y confirmó límite, ventana y reposición, que es lo que la
  ampliación **D-024** de §E pide para el verde. La cláusula de arriba **no cambia** —una
  cabecera leída sigue sin subir color— y lo que caduca es el ejemplo. Se deja escrito en vez
  de borrarlo, porque una regla cuyo caso trabajado es falso se aplica mal. Brevo: los tres `rate`
  del envío vuelven a 🟡 mientras DISC-01 enfrente las 1.000 peticiones por segundo de [F6] con las
  6.000 por hora de [F13] sobre el mismo endpoint. *(caso Brevo DISC-01, consejo 2026-09-18)*

- **D12 · El lado de una discrepancia es la unidad entera registrada, no el recorte.** D11
  exige que dos literales sean **excluyentes** y no dice qué texto se compara. Se compara la
  unidad que el bloque [Fn] registra entera, con sus condiciones dentro, y no el fragmento
  que la entrada transcribe. La condición es justo lo que el recorte se come: «However», «If
  you are accessing», «If you encounter a throttling error». El recorte se queda como ayuda
  de lectura, y donde el veredicto cambie la entrada se reescribe con la unidad entera. SES
  DISC-04 es el caso: el lado B arrancaba en la segunda frase de [F14], y la primera —`"You
  can enable your account-level suppression list if your account is in the SES sandbox."`—
  es la que decide.

  **Qué es la unidad cuando la fuente no es prosa.** Una frase no existe en una tabla. Allí
  la unidad es la **celda con el encabezado o el título que la gobierna**, y se registran
  las dos. La regla general: la unidad es la más pequeña que lleva su propia condición. Si
  la frase arranca apuntando a la anterior —«this number», «these quotas»—, la anterior
  entra también, porque sin su antecedente no lleva nada. La entrada declara qué unidad usó,
  y esa elección se audita como cualquier otra.

  **Una entrada no está lista mientras un lado no tenga su unidad registrada**, y tampoco si
  la cita lleva elipsis. Una entrada no lista no decide nada: ni cierra la discrepancia ni
  mueve el color, que se queda donde estaba. Un lado que sea interpretación, resumen o ausencia
  comprobada no es literal y no dispara D11: el lado B de SES DISC-05 presupone lo que
  afirma. Registrar lo que falta es obligatorio cuando la entrada gobierna un campo del
  esquema o una celda declarada de `features.md`; en lo demás la entrada espera marcada. Si
  el texto ya está en `fuentes.md` dentro de la propia discrepancia, se mueve al bloque [Fn]
  con su atribución y no hay viaje a la página. E2 no exige volcado y SES no tiene ninguno,
  así que el viaje es el precio de esta regla y por eso se acota.

  **Lo que la unidad entera no compra.** Una exclusividad que necesita un paso no publicado
  no es exclusividad. En DISC-04, [F14] deja habilitar la lista en el entorno de pruebas y
  exceptúa dos operaciones; [F2] deshabilita `"all SES API calls related to suppression list
  management"`. Para que choquen hay que añadir que habilitar sea una llamada de API, y eso
  no lo publica nadie. Por **E5** la entrada queda **acotada y no cerrada**, con el paso que
  falta escrito dentro. D12 sube el listón de **E1** solo para los lados de una `DISC-nn`:
  el resto del provenance sigue con su texto literal corto. *(caso SES DISC-04, consejo
  2026-09-18)*

- **D13 · Salir de D11 por E5 (1) no es entrar en verde: es volver a D1.** D11 gobierna el
  color mientras dos literales excluyentes siguen vivos, y su cláusula de cierre solo deja
  subir el color a la regla que cierra, si lo admite: **D5**, **D17** y **E4**. **E5 (1)** no arbitra
  entre dos lados, cierra porque una cita no dice lo que el registro le atribuía o no habla de
  la misma magnitud. El lado que cae nunca fue el segundo literal que D11 exige. Si D11 nunca
  llegó a aplicarse, tampoco se aplica su cláusula de cierre: el campo sale de D11 y entra en
  **D1** sobre lo único que queda registrado.

  **Entrar en D1 no es entrar en verde.** D1 da verde al literal en fuente oficial y ámbar a
  lo interpretado o ambiguo, y la ambigüedad no depende de que la cita sea clara: depende de que
  **mapee sin interpretación al campo del esquema**. Un literal que sobrevive intacto puede seguir
  topando con D1 por otro motivo —unidad, alcance, punto de medida, denominador—, y ese choque
  no lo resuelve esta regla. Lo resuelve D1 aplicado al campo, con su propia evidencia. Cada
  campo que sale de D11 por esta vía **se reevalúa entero**: no asciende por defecto.

  **El caso, que ilustra el mecanismo y las dos mitades.** `DISC-16` de Brevo bajaba a 🟡 los
  cinco `max: 20` de `unit: MBs` por D11, con [F27] frente a [F5]. Cerrada el 2026-09-21 por
  E5 (1) —[F5] acota el adjunto y no el correo entero, y no era el segundo lado—, el campo sale
  de D11. Y **se queda en 🟡**, ahora por D1: el README de v0.3 define `workload` por petición
  y [F27] acota por correo, en un endpoint que admite lote de 2.000, así que el mapeo es
  interpretación; y la base de medida —decodificado o base64, MB decimal o MiB, validación o
  entrega— no está medida. El consejo escribió esta regla con el color de su propio caso
  puesto en verde, y lo corrigió al medir la premisa.

  **Reversión.** Las entradas afectadas se identifican solas: **E5** ya obliga a que el cierre
  lleve supuesto, fecha y prueba dentro de la propia `DISC-nn`. Se reabre la discrepancia y el
  campo vuelve al color y a la cláusula de D11 que tenía antes. No hay artefacto nuevo que
  deshacer.

  **Lo que el consejo NO escribe, y conviene que conste.** Se deliberó también obligar al
  comentario del campo a declarar qué regla o qué `DISC-nn` lo baja, y **se retira**. Dos
  medidas la tumban. Las tres únicas marcas del catálogo que ya nombran causa llevan **tres de
  tres de desincronía en setenta y dos horas**, así que la regla se pudre antes de servir. Y el
  capítulo 4 ya documenta el formato contrario, *«la etiqueta se serializa como comentario YAML
  con el color y nada más»*, con el respaldo de cada dato viviendo en el provenance. La
  necesidad de fondo —saber qué campos toca un cierre— ya la cubre E5 sin artefacto nuevo.
  *(caso Brevo DISC-16, consejo 2026-09-21)*

- **D14 · Un lado disuelto por D12 devuelve el campo a D1, y la ausencia en un bloque de
  bullets pesa según esté enmarcada o no.** D12 dice cuándo un lado no dispara D11, y no dice
  adónde va el campo después. Va a **D1**, igual que en D13: el literal superviviente se
  reevalúa entero sobre su propia unidad, sin ámbar por defecto y sin verde por defecto. Y
  antes de disolver hay que clasificar la ausencia, porque no todas son la misma:

  **Ausencia plana.** El bloque del plan no menciona la feature y ningún otro plan de la misma
  tabla lo enmarca como incorporación respecto a ese plan. Es la «ausencia comprobada» de D12:
  no es literal, no dispara D11. El literal superviviente gobierna la celda por D1 —verde si
  mapea sin interpretación— y la omisión se escribe como `NOTA` en el provenance, nunca como «—»
  ni como discrepancia viva.

  **Ausencia enmarcada.** Un plan superior de la misma tabla enumera la feature bajo un
  encabezado que apunta al plan inferior: `"Everything on <plan> plus…"`, `"Additional to
  <plan>…"` o equivalente. Esa frase es un literal **sobre el plan inferior**, dicho por la
  propia fuente sobre sí misma, y no es la suposición desde otro plan que G2 prohíbe. Entra en
  la unidad del lado por D12 —la frase apunta a la anterior, así que la anterior entra— y
  cuenta como segundo lado de D11: el campo se queda en 🟡 y la `DISC-nn` sigue abierta hasta
  medir o disolver por E5. La entrada de `fuentes.md` debe transcribir esa frase dentro de la
  unidad del lado que la usa.

  Una entrada que meta bajo un mismo veredicto planes de los dos tipos **no está lista** por
  D12 y se separa por plan.

  **En `features.md`, G2 se aplica por estructura y no por documento.** «Lo que la fuente no
  dice se deja vacío» se lee sobre la estructura que declara esa celda —la fila de la matriz
  comparativa, con su condición por columna—, no sobre la página entera. El silencio de una
  estructura distinta y no exhaustiva por naturaleza (un resumen de venta tipo `"Features
  include:"`) no vacía la celda ni abre `DISC-nn`, salvo que niegue explícitamente o que sea
  ausencia enmarcada. Aplicar G2 al documento entero vaciaría cualquier celda sobre la que
  callara cualquier pasaje de la página, que es media matriz de cada API.

  **El caso.** Mailgun DISC-02, «Email Templates»: la matriz de [F1] marca `cols: true` y los
  bullets de Free y de Basic no la mencionan. Se separa. **Free** lleva bloque plano
  `"Features include:"` y entra en 🟢 por D1 con la omisión anotada como `NOTA`. **Basic** no:
  la tarjeta de Foundation, en la misma página, se titula `"Everything on Basic plus..."` y
  lista `"Email template builder and API"` — se queda en 🟡 y DISC-02 sigue abierta para esa
  columna hasta que un panel de cuenta Basic o un sondeo confirmen si la API de plantillas es
  accesible desde ese plan. *(caso Mailgun MG-2, consejo 2026-09-21)*

- **D15 · Oficial lo fija quién mantiene el artefacto, no el dominio que lo sirve ni el nombre
  del repositorio.** D1 da verde al literal en fuente oficial y no define «oficial». Para un
  artefacto técnico alojado fuera del dominio del producto —contrato máquina
  (OpenAPI/Swagger, modelo de servicio tipo `service-2.json`), SDK, changelog en
  repositorio— el dominio de entrega no decide: `raw.githubusercontent.com` es transporte, no
  autoría, y la ausencia del fichero en el dominio del producto no lo degrada. Tampoco decide
  que el nombre del repositorio o de la organización coincida con el del proveedor. Cuenta
  como **fuente propia del proveedor** cuando consta una **señal positiva** de que el
  proveedor lo mantiene como suyo, y basta una de estas tres:

  1. el repositorio pertenece a la organización del proveedor (`github.com/mailersend/…`,
     `github.com/mailchimp/…`);
  2. una página del dominio del producto lo nombra o lo enlaza como artefacto propio
     (`developers.mailersend.com/sdk.html` → `github.com/mailersend/…`);
  3. el repositorio es la herramienta o el SDK que el proveedor declara oficial, aunque su
     organización lleve otro nombre (`boto/botocore` para los SDK de AWS).

  **La señal se transcribe, no se narra.** Va en `fuentes.md` como cita literal con URL y fecha
  de acceso, igual que cualquier otro dato de D1 y por la misma E1. Una frase del tipo «la
  página de referencia remite a este fichero» sin el literal que lo demuestre no acredita nada,
  y el artefacto se queda con las señales que sí estén transcritas. El **silencio no
  acredita**: que ninguna fuente desautorice el repositorio no es señal positiva. Sin ninguna
  de las tres —fork comunitario, espejo, reescritura de terceros como
  `APIs-guru/openapi-directory` o `elasticio/mandrill-api`— el artefacto no es fuente oficial
  aunque el contenido coincida palabra por palabra, y el campo que dependa solo de él se queda
  en 🟡.

  **Ser fuente oficial no es afirmar dónde se sirve.** D15 gobierna si el artefacto puede
  citarse en verde y describirse en la memoria como especificación oficial del proveedor. No
  autoriza a afirmar que el proveedor publica esa especificación en su propio dominio: esa es
  una afirmación de hecho distinta, necesita su propia cita, y donde esté abierta sigue abierta
  — es la segunda mitad de DISC-01 en Mailchimp, que D15 no cierra. D15 tampoco fuerza cierres:
  una discrepancia viva sigue con D11 y E5. *(caso Mailchimp DISC-01 · [F2]
  `transactional.openapi.json`, con los precedentes ya vivos de SES [F33][F34] `boto/botocore`
  y MailerSend [F35] `mailersend/mailersend-php`; consejo 2026-09-21)*

- **D16 · La comprobación que no puede mover el veredicto no retiene el color, y cuál puede se
  mide.** D9 da verde cuando el test del campo se aplicó entero, y no dice si «entero» son
  todos los pasos enumerados o solo los que pueden cambiar el resultado. Manda lo segundo. C2
  declara `partial_saas` únicamente si una operación existe **en el panel y no en la API**, así
  que una operación que la API ya tiene no puede volverse exclusiva del panel, y observarla en
  el panel no aporta información que el veredicto pueda usar. En ese caso D9 marca **verde**
  sin esa observación, y el provenance del campo anota `NOTA: operación N confirmada por API
  [Fn]; panel no comprobado por no ser decisivo (D16)`. La exención exige las tres condiciones;
  si falla una, el panel vuelve a ser obligatorio.

  1. **La cita cubre la operación entera, no un endpoint suelto.** La operación 2 de C2 es
     «crear **o editar** una plantilla», y la 3 es «añadir un dominio **y disparar su
     verificación**». MailerSend documenta `POST /v1/templates` y aun así es `partial_saas`,
     porque editar una plantilla creada en el panel devuelve 404 —`"templates created in the
     MailerSend app return 404"`—. Mientras la referencia no cubra también la edición, y no
     publique que los objetos nacidos en el panel se operan igual, la API no ha decidido nada.
  2. **La fuente no está discutida.** Si el único respaldo de la operación es una fuente con
     una `DISC-nn` abierta sobre su oficialidad, no cuenta como confirmación de API a estos
     efectos. Mailchimp Transactional: `templates/add` solo aparece en [F2], el OpenAPI de
     DISC-01, y las páginas humanas [F8] y [F9] documentan enviar y enviar-con-plantilla, no
     crearla. Su `type` sigue 🟡 y el panel de plantillas sigue pendiente.
  3. **Alcanza solo a las operaciones 1-3.** Las 4-8 no fijan `type`, pero se comprueban igual
     en el panel porque ahí la asimetría tiene contenido propio: F-22 en Postmark y F-08 en
     SendGrid salieron de esa comparación.

  No obliga a rehacer ninguna datasheet cerrada —las que están en 🟢 recorrieron las ocho
  operaciones—: solo evita gastar el escalón 2 donde no puede mover nada. *(caso `type`
  Mailchimp MC-7, consejo 2026-09-21)*

- **D17 · El pricing define la verdad.** Cuando la página de precios del proveedor —con su
  FAQ y, en SES, la Price List API— publica un dato y otra fuente publica otro valor para
  ese mismo dato, **gana la página de precios** y su valor va al YAML. La otra fuente puede
  ser documentación, ayuda, blog, panel, sondeo o terceros. El otro valor no se descarta: se
  anota en `fuentes.md` como **incoherencia del pricing**, con las dos citas.

  - **Alcance.** Pares con el pricing en un lado y el mismo dato: precio, cuota, tope de
    envío, qué incluye cada plan. Si la página calla, D17 no aplica y siguen D5, D11 y E4.
  - **Sin excepción por precisión.** Un panel con más decimales o un adjetivo más no gana:
    el valor modelado es el que publica la página, aunque sea un redondeo. La cifra precisa
    va al provenance. Es la lectura estricta de la decisión del autor del 2026-10-18.
  - **Sondeo por debajo de lo prometido.** Si la medida da menos que la página, el valor
    modelado sigue siendo el de la página y la medida se anota como incoherencia del
    pricing, no como corrección (`acta.md` F13).
  - **Pricing contra pricing.** Si la página se contradice a sí misma, D17 no elige. Sigue
    D11: 🟡 mientras la DISC esté abierta.
  - **Color.** El valor de la página en un par resuelto por D17 va en 🟢 si es literal (D1).
  - **Datasheets cerradas.** D17 sí reabre valores: un campo cerrado con otra fuente frente
    a la página se corrige al valor de la página. El inventario de los pares afectados y su
    efecto está en `05_salida/reunion_tutor_2026-10-15/divergencias.md`.

  *(D-068, 2026-10-18; acta del 2026-10-15 F13/T7)*

- **D18 · Procedencia del dato, eje aparte del color.** Cada valor tiene una de cinco
  procedencias. **Publicado**: literal de la página del fabricante. **Interpretado**: hay
  texto y el modelador decide qué significa. **Calculado**: función reproducible de valores
  publicados o medidos; se guardan fórmula y entradas, no el resultado (B1). **Medido**:
  sondeo o panel con cuenta propia, citado en `data_provenance`. **Inferido por agente**:
  conclusión que ninguna fuente afirma ni ninguna fórmula devuelve, producida por un LLM o una
  skill; cita sus fuentes de partida, la skill y su versión. El color lo siguen decidiendo las
  reglas de §D, con dos topes: lo inferido por agente no pasa de 🟡 hasta que lo respalde un
  valor publicado o medido, y lo calculado toma el peor color de sus entradas. En las
  Datasheets cerradas la procedencia no se escribe en el YAML: se deduce de `data_provenance`
  y se muestra en la maqueta.

  - **Con D17.** D17 decide qué valor entra en el YAML cuando la página de precios choca con
    otra fuente. D18 no lo cambia: para Antonio el pricing es una página más del árbol de
    fuentes y sus incoherencias se analizan, y eso es lo que D17 ya hace al anotar el otro
    valor como incoherencia del pricing. Son compatibles.
  - **En las ocho Datasheets no hay ningún valor inferido por agente.** Los ámbar son
    interpretaciones del modelador sobre un texto citado. La clase tiene casos en la maqueta:
    tipo, propósito y modelo de pricing de cada interfaz, salidos de las skills de Daniel Ruiz.
  - **Derivado es el paraguas de interpretado, calculado e inferido por agente**: todo lo que
    no está tal cual en una fuente ni se ha medido. Publicado y medido no son derivados. En la
    maqueta, lo derivado sale de la pestaña Pricing y va a la sección «Derivado». En este libro
    y en la memoria, «inferencia» se reserva para lo inferido por agente: la lectura del
    modelador es interpretación, y lo que se saca de una medida o de dos literales se dice
    «se deduce». *(D-078, 2026-10-23)*

  *(D-075, 2026-10-23; reunión con Antonio, 3:05–3:24 y 33:29–36:05)*

- **D19 · Un mercado de APIs es otra vía de contratar el servicio.** *Caso:* RapidAPI,
  comprobación del 23-10 sobre las ocho APIs (`05_salida/reunion_tutor_2026-10-23/verificaciones/rapidapi_ocho.md`).
  Una lista de RapidAPI, o de otro mercado, que da acceso al servicio de un proveedor es otra
  vía de contratar ese servicio, con sus propias condiciones. No se clasifica en oficial o de
  terceros. Sus valores no entran en la Datasheet del proveedor directo ni cuentan como fuente
  suya. Si algún día se modela, va como pricing aparte de esa vía, y se anota si la lista pide
  además la clave del proveedor. *Si resulta equivocada:* solo cambian la nota de la
  comprobación y la frase de trabajo futuro; ninguna Datasheet depende de esto.
  *(El autor, 2026-10-23; D-081)*

## E. Trazabilidad
  **Ampliación (D-024, 2026-09-07):** un sondeo diseñado para medir caudal que confirme el
  contador (límite, ventana y reposición) permite adoptar el valor en **ámbar**, con la
  cabecera como fuente en el provenance; **verde** solo si el sondeo alcanza la respuesta de
  rechazo (429). Postmark: `rate_request_rest` 5.000/s 🟡 tras [E4]. Si el sondeo mide
  **menos** de lo que publica la página de precios, no corrige el campo: manda **D17** y la
  medida se anota como incoherencia del pricing.
- **E1 · Cita = URL + fecha de consulta + texto literal corto.** Toda línea de
  `data_provenance` lleva la cita literal entre comillas simples y la URL; la fecha de
  consulta va en la entrada `[Fn]` de `fuentes.md`. Sin cita literal, la línea no es
  verificable y el validador avisa. Las notas que no son datos empiezan por `NOTA`.
- **E2 · Volcado recomendado, no exigido.** Guardar el texto de la página en
  `evidencias/paginas/<fecha>/<url normalizada>.txt` al leerla es recomendable cuando
  sea barato: permite que `verificar_citas.py` compruebe las citas sin red. No es
  condición de cierre: una Datasheet se cierra sin volcados y SIN-PAG es informativo.
  Las webs cambian; la cita con URL y fecha de consulta basta. *(D-023, 2026-09-07)*
- **E3 · Cambios de oferta entre capturas** (DISC-02/03/05 en Resend) se registran con
  las dos fechas; no son discrepancias entre fuentes, son evidencia de F-09.
- **E4 · La página del endpoint manda sobre la general que dice «default».** Cuando la
  página general publica un valor y lo declara por defecto (`"default rate limit"`), y la
  referencia del endpoint o el artículo específico lo desglosan por plan, **manda el desglose**
  y el valor va en **verde**: un valor declarado por defecto no contradice una tabla por plan.
  La palabra literal que declara el defecto se cita en el provenance como `NOTA`. MailerSend:
  el caudal del lote, 15 en Starter y 30 en Professional (DISC-08, cerrada). *(Q4 MailerSend,
  D-028, 2026-09-14)*
- **E5 · Una discrepancia se cierra midiendo o disolviéndola, nunca eligiendo.** La regla de
  partida estaba en la skill y no en el libro, y aquí queda escrita: cuando dos fuentes se
  contradicen **no se elige**, se abre la `DISC-nn` con las dos citas y se sube por la escalera de
  validación. Esta regla dice lo único que la cierra sin subir un peldaño, y son tres supuestos
  que **eliminan un lado** en vez de arbitrar entre ellos. **(1) Cae una cita.** Se vuelve a la
  fuente y no dice lo que el registro le atribuía, o no habla de la misma magnitud: MailerSend
  DISC-07 al releer el volcado, y Brevo DISC-10 al ver que el `"unlimited log retention"` de [F1]
  no declara ninguna duración mientras el panel sí, de 1 a 24 meses. **(2) Manda una regla ya
  escrita**, cuyo disparador está en el propio literal y existía antes del caso: E4 cerró
  MailerSend DISC-08, y D17 cerró SendGrid DISC-01 con los $0.0013 de la página, donde D5 la había
  cerrado antes a favor del panel. Un criterio inventado para el caso no vale, y el
  precedente está medido: «manda la fuente cuyo asunto es el campo» cayó por unanimidad porque la
  misma fuente ganaba y perdía el mismo día (Brevo Q6, D-048). D17 sí es una regla escrita y no un
  criterio del caso: la escribió el autor el 2026-10-18 (D-068), y la prohibición de elegir de este
  párrafo sigue valiendo para lo que D17 no cubre. **(3) El esquema aloja las dos.**
  Las citas describen escenarios distintos y el modelado los expresa por separado, como Brevo
  DISC-04 con los aliases de tramo. Fuera de los tres supuestos la discrepancia **sigue abierta**,
  que no cuesta nada: el valor ya está modelado con la lectura conservadora y las dos citas están
  registradas. No cierran nada la fuente más específica, la más reciente, la más oficial ni la más
  numerosa, y **una tercera fuente que repite una de las dos cifras tampoco**: es un literal
  repetido, no una fuente más (Q4 Brevo). La evidencia que estrecha sin decidir deja la
  discrepancia **acotada y no cerrada**, con lo acotado escrito dentro. El cierre se escribe en la
  propia entrada de la discrepancia, con el supuesto, la fecha y la prueba; sin esa línea no está
  cerrada. Y una discrepancia abierta **no bloquea el cierre de la Datasheet**: bloquea el verde de
  su campo (D11). *(caso Brevo, consejo 2026-09-18)*

- **E6 · Una discrepancia abierta declara su efecto dentro de su entrada.** E5 ya dice que
  fuera de sus tres supuestos la discrepancia **sigue abierta** y que eso «no cuesta nada»,
  y D11 ya le niega efecto de color a la que no es excluyente. Lo que faltaba no es
  criterio, es que se lea. Un inventario de veinte entradas abiertas, sin más marca que su
  número, se lee como veinte tareas pendientes o como un cierre bloqueado. Así que cada
  `DISC-nn` lleva una línea **`Efecto declarado:`** con dos campos: si la contradicción es
  **excluyente** por D11, y qué le hace al color del campo afectado —`no excluyente · sin
  efecto sobre el color`, o el color que baje—. Cuando el campo no existe en el fichero se
  escribe así, `campo sin valor`, y el segundo campo no se rellena. Es línea nueva y de
  formato fijo: la prosa de `**Efecto:**` que ya traen algunas entradas se queda, porque
  dice qué **decide** la discrepancia y no qué **hace** hoy. La cabecera de la sección no
  puede prometer un efecto único para todas: el efecto es de cada entrada, y una cabecera
  que generaliza miente en cuanto una entrada se sale de la generalización.

  **Segunda cláusula, y es de forma.** Una atribución conjunta `[Fa] y [Fb]` en la que solo
  una de las dos fuentes contiene el literal transcrito, mientras la otra publica la misma
  magnitud con otras palabras, es **defecto de forma de la cita y no lado caído**. Se
  corrige escribiendo el literal propio de cada fuente, y el lado se mantiene entero. No es
  el supuesto (1) de E5, que exige volver a la fuente y no encontrar allí la magnitud. Si el
  registro no guarda el literal de la segunda fuente, el defecto no se arregla desde la
  mesa: o se vuelve a la fuente, o la atribución se queda con la fuente que sí lo trae. Esto
  extiende **E1** desde el `data_provenance` a las entradas de `fuentes.md`, que hasta hoy
  solo prometían literalidad en su propia cabecera.

  **Reapertura.** La clase queda decidida mientras el esquema no aloje el lado que hoy no
  cabe. Si **DV-02** prospera como **P-04** y el esquema aprende a decir que un valor existe
  y no se publica, esta discrepancia pasa a cerrarse por **E5 (3)** y la línea de efecto se
  sustituye por la de cierre. No es un sello final, es un sello con condición escrita.

  SES DISC-03: fuera del entorno de pruebas la cuota no tiene cifra publicada, y la única
  que existe es de un blog de 2014. El campo `max_power` no está en el fichero, y el lado A
  se atribuía a [F1] y [F9] con el literal de [F1]. *(caso SES DISC-03, consejo 2026-09-18)*

- **E7 · La unidad de un contador se mide, y su discrepancia bloquea el cierre.** E5 deja
  abierta la discrepancia que no cae en sus tres supuestos, y eso «no cuesta nada» porque el
  valor ya lleva la lectura conservadora y **D11** le quita el verde. Con la **unidad** de
  un contador sí cuesta. La unidad es la premisa del CRF, de las curvas y de cualquier
  comparación entre APIs. Un número con la unidad equivocada no está en ámbar, está mal, y
  el motor no lo ve porque une por cadena. Así que una `DISC-nn` sobre la unidad de un
  contador queda **fuera de esa cláusula** y **bloquea el cierre de la Datasheet**, no solo
  el verde de su campo. Si la escalera permite medir la unidad, **medirla es condición de
  cierre**, y el cierre se escribe en la entrada de la discrepancia con el fichero de
  `evidencias/` que lo demuestra. La medida tiene que separar las dos lecturas **por
  construcción**: un delta que las dos predicen no mide nada. Si la escalera no lo permite
  —sin identidad verificada, sin destinatario en la lista blanca de D-046 o sin contador que
  leer—, manda **F2** y el dato se queda en **ámbar documentado**. Esa rama no es un atajo:
  la entrada nombra el impedimento concreto y dice cuál de las dos ramas se aplicó. E7 va en
  §E detrás de E5, que es la cláusula que excepciona. SES: DISC-02 enfrenta la cuota contada
  en correos de [F1] con `"Sending quotas are based on recipients rather than on messages"`
  de [F3], y mientras viva, SES no pasa a «cerrada» en el tablero. *(caso SES DISC-02,
  consejo 2026-09-18)*

- **E8 · Tumbar una cita exige el artefacto; E5(1) no se invoca a pelo.** E5 cierra una
  discrepancia cuando **cae una cita**, y no dice contra qué se comprueba esa caída. Aquí
  queda escrito: el supuesto (1) solo se invoca con el artefacto archivado en `evidencias/`
  —volcado de la página o contrato máquina— o con **dos lecturas fechadas de la misma
  versión**. Sin una de las dos cosas, la relectura no distingue «el registro se equivocó»
  de «la página cambió», y lo segundo es **E3**: se anotan las dos fechas y es evidencia de
  **F-09**, no caída. **La fuente que desaparece va por el mismo carril.** Si la URL
  responde 404, o si la versión citada ya no se puede recuperar, la cita no cae: se queda
  con su segunda fecha y con la nota de la relectura fallida. La condición es de uso, no de
  cierre. **E2 y D-023 quedan intactos**: el volcado sigue sin ser condición para cerrar una
  Datasheet, y solo pasa a serlo para tumbar una cita. La asimetría se declara aquí porque
  la tiene: abrir una discrepancia solo bloquea el verde de su campo (**D11**), mientras que
  cerrarla mueve una cifra que la memoria presenta como hallazgo. Los supuestos (2) y (3) de
  E5 no piden artefacto, porque no tumban ninguna cita: la mandan a otro sitio. SES
  **DISC-20**: el tramo de IP administrada de Estocolmo, diez veces más caro que el de las
  otras 28 localizaciones, sale del tarifario máquina y de la versión `20260911124507`, que
  la propia cita nombra. La URL es `current/`, así que una relectura de hoy trae otra
  versión y no puede desmentir aquella. *(caso SES DISC-20, consejo 2026-09-18)*

- **E9 · Dos superficies que publican precio con selector no son dos lados mientras no se
  lean en la misma posición del selector.** **D5** ordenaba el panel sobre la página pública
  cuando las dos publican el mismo dato con distinta precisión —desde el 2026-10-18, si esa
  página es la de precios, **D17** invierte el orden—, y el caso que trajo esta
  regla parecía el siguiente escalón: panel en euros contra página en dólares. **Medido, no
  lo era.** La página pública también sirve las ocho divisas y geolocaliza, así que una cifra
  en euros y otra en dólares suelen ser la misma página leída dos veces. Antes de abrir o de
  mantener una discrepancia de precio, y antes de aplicar **D17**, se igualan la **divisa** y la
  **periodicidad de facturación**, y el estado del selector entra en la cita como parte de ella. Sin esa
  igualación no hay contradicción que declarar, y una `DISC-nn` abierta sobre lados
  desiguales está mal abierta. Igualadas, si las cifras siguen sin coincidir, la discrepancia
  es real y se trata como cualquier otra: D11 para el color, E5 para el cierre. **Ninguna
  cifra se convierte al cambio**, ni para compararlas ni para elegir: las ocho listas de
  Brevo no son conversiones entre sí, así que un importe convertido no lo publica nadie. La
  cabecera `currency` se queda con la divisa que el fichero ya declaraba, que es elección del
  modelador y se dice en el provenance.

  **Qué NO es esta regla, y qué hacer con lo ya registrado.** No duplica a **D11**: D11 dice
  qué le pasa al color cuando hay dos lados; E9 dice **cuándo hay dos lados**, y va antes. Y
  no obliga a releer el catálogo: las citas de precio ya registradas en las otras cinco APIs
  **se quedan como están**, porque su discrepancia se abrió antes de esta regla. E9 se aplica
  desde hoy a lo que se abra o se vuelva a tocar, y una entrada vieja solo pide relectura si
  alguien la usa para decidir algo.

  **Lo que el consejo NO escribe, y conviene que conste.** No se escribe regla de precedencia
  entre panel y página. *(Superado el 2026-10-18: esa precedencia existe ya como **D17**, escrita
  por el autor y no por el consejo; E9 sigue obligando a igualar divisa y periodicidad **antes** de
  aplicarla, porque sin esa igualación no hay par.)* El razonamiento del consejo fue este:
  **E5** prohíbe cerrar eligiendo fuente, y ese criterio ya cayó por unanimidad una vez —«manda la fuente cuyo asunto es el campo», D-048 Q6—. Tres asientos
  votaron una regla de disolución, uno votó no escribir ninguna y el quinto solo la
  redacción. Lo que desatascó el empate no fue el voto: fue medir la premisa.

  **El caso, que hizo falta leer tres veces.** Brevo DISC-08 enfrentaba `"€9.00 per month"`
  del panel con `"$10.80"` de la página de precios y `"$9"` del centro de ayuda, y lo llamaba
  artefacto de divisa. Leída la página en EUR el 2026-09-18 dio **`"€8.10 per month"`**, y se
  escribió que en la misma divisa seguían sin coincidir. Esa lectura llevaba el conmutador en
  `"Yearly (-10%)"`, que es como la página carga. Puesto en `"Monthly"`, da **`"€9.00 per
  month"`**, `"€29.00"` y `"€59.00"`: **las tres exactas del panel**, capturado con
  `"Billed monthly"`. Igualadas divisa y periodicidad, el lado del panel **no era un lado**, y
  cae por **E5 (1)**. Queda el par original en dólares, pendiente de leerse con el mismo
  control. *(caso Brevo DISC-08, consejo 2026-09-18)*

- **E10 · Un fichero de `evidencias/` vale como artefacto solo si transcribe la fuente.**
  E2 y D-023 quedan intactos: el volcado sigue sin ser condición de cierre. Pero cuando se
  hace, tiene que ser el texto tal como la fuente lo sirve, la respuesta cruda de la descarga
  o el texto ya renderizado del navegador. La síntesis de una herramienta que lee la página y
  la cuenta con sus propias palabras no vale. Omite sin avisar, y entonces deja de distinguir
  que la fuente no lo diga de que la copia se lo comiera. El daño es medible:
  `verificar_citas.py` devuelve `CAMBIO` cuando hay volcado propio y la cita no aparece, así
  que un resumen fabrica un hallazgo de F-09 que nadie buscó. No sirve ni para el «fichero en
  `evidencias/`» que pide **B9 · L1** ni para el artefacto de **E8**. Caso: veinticuatro
  volcados de Brevo del 2026-09-21 salieron resumidos, y el de la página de caudal perdió la
  fila del comodín bajo `/v3/smtp/{…}` con su excepción, que es el hecho que sostiene F-23.
  *(consejo 2026-09-21)*

- **E11 · Una fuente que se contradice a sí misma abre `DISC-nn` igual que dos fuentes
  distintas.** E5 abre el procedimiento «cuando dos fuentes se contradicen», y esa palabra ha
  hecho dudar de si una sola página que se desdice queda fuera. Queda dentro. **D11** no exige
  dos bloques `[Fn]`: exige **dos literales excluyentes sobre el mismo campo del mismo
  objeto**, y **D12** ya mide cada lado como «la unidad que el bloque `[Fn]` registra entera»,
  en singular, sin pedir un bloque por lado. El sujeto de la contradicción es el literal, no el
  fichero que lo aloja. Cuando dos cláusulas de la misma frase, dos elementos de la misma
  página o una viñeta y la tabla que la sigue dan lecturas que no pueden ser ciertas a la vez
  sobre el mismo campo, se abre `DISC-nn` con el formato completo: lado A y lado B con su
  unidad entera (**D12**) y su cita literal corta con URL y fecha (**E1**), `Nota` que explica
  la incompatibilidad, vía de cierre y línea `Efecto declarado:` (**E6**). Entra en el
  inventario y sube por la escalera de **F2** si no cierra por los tres supuestos de E5. No se
  despacha como D1/D3 en ámbar sin entrada: eso pierde el recuento del inventario y el `Efecto
  declarado` que E6 exige.

  **La proximidad no sustituye a la exclusividad.** Dos magnitudes distintas que conviven en la
  misma página no abren nada, aunque se rocen: el tope de payload por llamada (<10MB) y el tope
  de mensaje con adjuntos (≤25MB) de Mailchimp [F4] miden objetos distintos, así que D11 no se
  activa y quedan como fricción anotada. Tampoco abre una frase meramente vaga: si hace falta
  **inferir** para leer un segundo valor, no hay segundo literal, y es D1/D3 en ámbar liso.
  Casos que la originan: **Mailchimp DISC-02**, la misma frase de [F5] con dos anclas de
  reinicio del límite de modo de pruebas —«resets at midnight» contra «24 hours after that
  limit is hit»—, y **Brevo DISC-15** refundada, la viñeta del tramo Advanced de [F6] contra el
  distintivo «Available in» que encabeza su propia tabla. **SES DISC-04 no es precedente de
  esto**: sus dos lados son [F2] y [F14], y lo que D12 resuelve allí es qué unidad se registra
  dentro de un lado. *(caso Mailchimp MC-3, consejo 2026-09-21)*

- **E12 · El periodo de un contador no es su unidad: E7 no se extiende por analogía.** E7
  bloquea el cierre de la Datasheet cuando dos literales discrepan sobre **qué cuenta** un
  contador —correos o destinatarios, que es SES DISC-02—, porque esa ambigüedad viaja dentro
  de un solo campo y el motor la une por cadena sin verla. Una discrepancia sobre **cada
  cuánto se reinicia** ese contador, o sobre **cuántos contadores independientes** publica el
  proveedor para el mismo recurso, no hereda ese bloqueo. No es que importe menos: el periodo
  es premisa del CRF y de las curvas igual que la unidad. Es que el periodo tiene campo
  propio. Dos granularidades viven en dos claves distintas —`quota_email_daily` y
  `quota_email_monthly`—, y el tipo de ventana ya se ve en el color por **D3**. Lo que E7
  corrige es un error invisible; esto se lee en el fichero.

  **Qué regla gobierna entonces.** **D3** fija el color de la ventana: sin ancla publicada,
  ámbar. **D1** fija el del valor, que es literal de alcance ambiguo mientras no se sepa si es
  la única cuota o una de varias concurrentes. **D11 solo entra si los dos periodos son
  excluyentes** sobre el mismo contador, y dos topes aritméticamente compatibles no lo son.
  **B8** ya tiene el precedente de que conviven, con la cuota diaria del Free de Resend junto
  a la mensual del plan. Cada magnitud se modela por separado, con su fuente y su color, y la
  relación entre ambas —si la diaria compone la mensual o son topes independientes— se dice
  `not_found` con su fricción mientras ninguna fuente la aclare.

  **Medir es la vía de salida, no la condición de cierre.** El sondeo de escalón 3 que separe
  las dos lecturas por construcción sube el color cuando la escalera lo permita, y esa
  separación se exige igual que en E7; pero la Datasheet cierra sin ella. Cerrar por **E5 (3)**
  pide además que alguna fuente diga que son escenarios distintos: que el esquema tenga sitio
  para las dos no es alojarlas, y mientras eso no conste la `DISC-nn` sigue abierta.

  **El caso, y las dos lecturas que corrige.** Mailgun DISC-03 enfrenta `"100 emails/day
  included"` de [F1] con los `"3000 emails per month"` del panel [F24]. Su entrada ya declara
  el efecto —no excluyente, aritméticamente compatibles y no confirmado— y deja
  `quota_email_daily_free` y `quota_email_monthly_free` en 🟡 **por D1**, no por D11, que no
  se dispara sin exclusión. *(Actualizado el 2026-10-18: la diaria es literal de la página de
  precios y pasa a 🟢 por **D17**; la mensual solo la publica el panel y sigue en 🟡 por D1. La
  discrepancia queda acotada, no cerrada.)* Y no está cerrada por E5 (3): la propia entrada lo descarta. Esta
  regla confirma esa lectura y le quita a la clase el bloqueo de E7. *(caso Mailgun DISC-03,
  consejo 2026-09-21)*

- **E13 · Una cifra tras una página bloqueada no tiene color, y el render solo es obligatorio
  si esa página es la fuente única.** Cuando la página del proveedor devuelve 403 o exige
  JavaScript —Cloudflare, muro de render— y la herramienta solo trae el resumen de lo que leyó,
  no hay literal. E1 pide texto literal y E10 ya niega ese resumen como artefacto de
  `evidencias/`; el mismo defecto invalida la línea de `data_provenance`, así que la cifra no
  entra ni en 🟢 ni en 🟡. **Tampoco en 🔴**, y esta es la mitad que faltaba escribir: D1 hace
  del rojo una afirmación de no-publicación, y esa afirmación no se puede hacer sobre una
  página que nadie ha leído. Por B9 · L1, sin literal citado ni sondeo ejecutado no hay hecho,
  así que tampoco cabe un cuarto estado «pendiente de lectura». El hueco va a
  `metadata.not_found` con la razón técnica —código, herramienta, fecha— y sin color, hasta que
  una lectura válida lo resuelva.

  **El intento de render es obligatorio solo bajo exclusividad**, el mismo criterio que usa E7:
  la página bloqueada es la única fuente del dominio del proveedor para una cifra que iría a
  `not_found` o que sostiene una `DISC-nn` abierta, y ningún escalón más barato —otra página
  pública, el panel con cuenta propia— da el mismo dato. Fuera de esa condición el 403 se anota
  en `not_found` sin intento y no bloquea el cierre de la Datasheet: obligar el navegador en
  cada bloqueo del catálogo gasta sesión en páginas que ni siquiera ganarían en la jerarquía de
  D17-E4-E5-E7. Si el render se intenta y también falla —login, CAPTCHA, que es acción prohibida, o
  la página sigue sin servir el texto—, el hueco se queda en `not_found` con constancia del
  intento y no se convierte en rojo por agotamiento.

  Rendida la página, la transcripción sigue **E10**: el texto tal como lo sirve el navegador,
  con el método declarado en la cabecera del fichero. La entrada `[Fn]` de `fuentes.md` anota
  **método: navegador renderizado**, para que una relectura por WebFetch que vuelva a dar 403
  no se confunda con caída de cita (**E8**) ni dispare **E3**. A partir de ahí el literal es uno
  cualquiera: lo colorea **D1**, puede ser lado de una `DISC-nn` y le aplican **D11** y **E5**
  con normalidad. **E2 y D-023 quedan intactos**: el volcado sigue sin ser condición de cierre;
  lo que esta regla fija es el método de lectura, no si se archiva.

  **No es retroactiva.** Las seis APIs cerradas se quedan como están: donde ya se leyó con
  navegador la cita vale —Brevo, las tres de `help.brevo.com`, que da 403 a `curl` y a
  WebFetch—, y donde el hueco quedó sin cifra por un 403 sin renderizar sigue así, igual que E9
  no obligó a releer las discrepancias de precio ya registradas. Aplica desde hoy a lo que se
  construya o se toque. Caso originario: Mailgun [F15], `www.mailgun.com/ai-info/`, única
  fuente del dominio con una cifra de caudal, rendida el 2026-09-21. Piden intento por el mismo
  criterio `help.mailgun.com/hc/en-us/articles/115001124753` y el artículo de consumo por
  destinatario de `mandrill.zendesk.com`, hoy anotados como huecos sin haberlo intentado.
  *(caso Mailgun MG-3, consejo 2026-09-21)*

- **E14 · El corchete que delimita no invalida; el que sustituye no se cita; y una nota de
  ausencia exige volcado íntegro.** E10 pide que un fichero de `evidencias/` transcriba la
  fuente, y no dice qué pasa con las marcas que el recolector añade encima. Aquí queda escrito,
  en tres cláusulas.

  **(1) Delimitar no invalida.** Un encabezado de sección entre corchetes en su propia línea, o
  cualquier marca que solo señale dónde empieza un bloque de la fuente, no descalifica el
  fichero ni la línea que precede. La condición es que el cuerpo, leído sin los corchetes, siga
  siendo copia palabra por palabra. E8 y **B9 · L1** se aplican entonces línea a línea, no al
  fichero entero.

  **(2) Sustituir no se cita.** Un corchete que reemplaza texto de la fuente por la glosa del
  recolector —traducirlo, resumirlo, decir «según el fetch»— deja esa línea fuera de
  `fuentes.md` y fuera del artefacto de E8, aunque el resto del fichero valga. La marca no la
  rescata: lo que se pierde es el literal. Mailchimp `errores-03.txt` lleva una así, `"Emails
  with more than 10 recipients [se procesan de forma asíncrona; encolados]"`.

  **(3) Una ausencia se acredita, no se afirma.** Una nota que dice que la fuente no menciona
  algo —un código HTTP, una cabecera, una cifra— es una afirmación sobre la página, y un `grep`
  sobre el volcado no la prueba: prueba la copia. Si el volcado es parcial, la nota confunde
  «la fuente no lo dice» con «la copia se lo comió», que es el daño que motivó E10. Así que la
  nota de ausencia solo vale si el fichero es la página entera, y el fichero lo dice: qué se
  descargó, con qué herramienta, y que no hay recorte. Sin eso, la nota no sostiene una
  fricción ni cierra una discrepancia; sirve de indicio y el campo se queda en ámbar.

  **Lo que no cambia.** E2 y D-023 siguen intactos: el volcado no es condición de cierre. Un
  fichero que declara en su cabecera o en sus notas que el texto citado procede de un resumen
  de herramienta —y no de la descarga cruda ni del render del navegador— cae entero por E10 sin
  invocar E14, con comillas o sin ellas. Mailchimp `endpoints-03.txt`, `endpoints-04.txt` y
  `features-01.txt` son de esos, y el propio recolector ya los marcó.

  **El caso, medido.** `errores-02.txt` y `errores-03.txt` son transcripción real con
  encabezados entre corchetes, y por (1) valen. Pero cierran con `"verificado por grep sobre el
  volcado íntegro"` sobre un volcado que no lo es: el literal de [F6] sobre el umbral del 0,1 %
  de quejas está en `fuentes.md` y no aparece en ningún volcado de la carpeta. Esa nota sostiene
  la ausencia de 429 y 403, que es la fricción F-08. *(caso Mailchimp MC-5, consejo 2026-09-21)*

- **E15 · Detrás del emoji no va nada, y la única excepción es el hueco deliberado.** La
  convención del `datasheet.yaml` ya lo dice: el comentario de un campo es **exclusivamente** el
  emoji. D13 lo confirmó al retirar la propuesta de que el comentario nombrara la regla o la
  `DISC-nn` que baja el color. Y el capítulo 4 lo afirma ante el tribunal, «la etiqueta se
  serializa como comentario YAML con el color y nada más». Esta regla no cambia el criterio: fija
  la frontera de forma que un `grep` la compruebe, y dice qué se hace con lo que ya está escrito.

  **La frontera.** Detrás del emoji no va nada. Vale igual para el comentario que cierra un campo
  y para el que encabeza un bloque. Cuando el color no tiene campo escalar donde posarse, el
  comentario se queda en el emoji solo. Fuera quedan los índices `[Fn]`, los `DISC-nn`, los
  números de regla, las citas literales, las fechas de consulta y los resultados de test. `# ídem`
  queda prohibido por partida doble: la propia convención ya lo veta en su apartado de «idéntico
  al plan X». Un comentario sin color y con prosa no existe: o es la línea del hueco, o sale del
  fichero.

  **La única excepción, y su alcance.** Es la línea que justifica un hueco deliberado, y cubre por
  igual el bloque que queda en `{}` y el campo que se deja sin valor —`window_type` en SES,
  `period` en Mailchimp—. Dice qué falta y remite a `metadata.not_found`. No cubre el comentario
  que acota valores presentes, que es una afirmación sobre el dato y va al provenance.

  **No se abre una segunda excepción, y la premisa que la pedía es falsa.** Se propuso admitir el
  resultado de un test que no viviera en ningún otro campo, con la cabecera de `type` como primer
  caso. Medido sobre el catálogo: esa cabecera está en cinco APIs y no en las ocho, y las cinco
  guardan ya la nota entera en `data_provenance` bajo «NOTA Test de type». El comentario resume
  algo que ya está dentro del documento. Además, una lista de casos admitidos crece por analogía:
  el siguiente revisor defenderá su `DISC-nn` con el mismo argumento de utilidad. Si una nota
  parece necesaria y no cabe en ningún campo, la pregunta no es si el comentario la admite, es qué
  campo falta en el esquema.

  **El orden importa, y es lo que evita el daño.** Primero se comprueba que la afirmación vive en
  `data_provenance` con su literal y su URL, en `not_found` o en la entrada de la `DISC-nn`. Si no
  está, se escribe allí. Solo entonces se recorta el comentario. Recortar antes convierte una
  limpieza en una pérdida. Cuando una línea mezcla las dos cosas se parte en dos.

  **La memoria no se toca.** `04_Propuesta.tex` describe justo lo que esta regla restaura, y hoy
  es falsa contra los ficheros. Lo que se corrige es el catálogo.

  **El caso que la origina.** El catálogo entero: veintitrés comentarios con texto sobre las ocho
  datasheets, contados el 2026-09-21, más dos bloques de Brevo sin color ninguno. Ocho justifican
  un hueco deliberado y se quedan; quince se recortan. La limpieza no mueve el tablero, porque el
  conteo de semáforos busca el emoji dentro de la línea y el emoji se conserva.
  *(consejo 2026-09-21)*

- **E16 · Un eje que la Datasheet no declara no se sustituye: se ejecuta lo declarado y se
  rotula con lo que contestó.** Las preguntas de clase **P** se instancian sobre tres ejes —el
  plan gratuito, el primer plan de pago y el estado nominal de la cuenta— que presuponen la
  forma de oferta más común, un plan con nombre y con volumen incluido. Las plantillas no
  nombran ninguno: piden `{{CONFIGURATION}}`, y los tres ejes son convención de comparación,
  escrita en las tablas `FREE`, `PAGO`, `KMAX`, `CALCULABLES`, `CUOTA_PAGO` y `ALIAS_POR_API` de
  `ejecutar_prime4api_PI.py`. Cuando el proveedor no tiene esa forma, el eje se queda sin
  instancia. Cuatro cláusulas.

  **(1) No se sustituye por el más parecido.** Es lo que **D7** prohíbe en su última frase,
  «nunca archivada bajo el nombre de otro estado», y lo que **D-025** ya descartó porque vuelve
  el error indetectable. Además suele ser indecidible: SES empata dos planes en `price: 0.00` 🟢,
  `a_la_carte` y `essentials`, y ningún campo desempata. Cuando la definición del eje admite más
  de una instancia se **ejecutan todas y se publican todas**, igual que **D-037** publica los dos
  regímenes en vez de inventarse un punto intermedio.

  **(2) Se ejecuta sin filtro de alias, y rotula el motor.** PRIME4API devuelve `plan`,
  `endpoint` y `alias` en cada fila sin que nadie se lo pida, así que el rótulo es salida del
  motor y no glosa del redactor. El rótulo va **en la celda**, con el vocabulario del proveedor y
  entre corchetes —`sí [sandbox]`, `sí [demo]`—, nunca en una nota al pie: una tabla de cobertura
  se escanea, y un «sí» cuya salvedad vive en el pie se lee como un «sí» sobre el eje pedido. El
  corchete **no lleva semáforo**: el color mide la fiabilidad del dato (**D1**) y dos dudas
  distintas no comparten glifo.

  **(3) Antes de rotular se mide si el eje informa, y eso se publica.** Si todos los planes
  devuelven la misma cifra, el eje no discrimina y se dice con los números puestos. SES: los
  cuatro planes dan 200 correos al día, 1 petición por segundo y 1.401 correos en siete días,
  medido el 2026-09-21 contra `localhost:8003`. Un eje que no informa es hallazgo publicable, no
  hueco de cobertura.

  **(4) La respuesta que el esquema no sabe decir se rotula o se calla.** El
  `total_cost: 105.0` de SES es la suscripción del plan y no el precio de enviar, porque el
  precio por destinatario no cabe en v0.3 y está en `not_found`. Publicarlo a secas afirma que
  40.000 correos por SES cuestan 0,00 USD, que es lo que devuelve `a_la_carte`. Se rotula la
  magnitud, no solo el estado.

  **Lo que no se toca, porque es del autor.** La clase **D/P/H/L/X** de una pregunta no se mueve:
  mide con qué se responde la pregunta y no qué publica cada proveedor (**D-041**). Tampoco se
  mueve el denominador de 32 ni el juego de filas de `tab:cobertura-pi`: `docs/08-mandato.md`
  mete los tres en el carril rojo. El recuento aparte de las respondidas sobre otro eje va en la
  prosa de `analisis.md` §(d) y en el `RESULTADOS.md` de la tanda; si además ha de ser fila de la
  tabla del capítulo, lo decide él.

  **Lo que esta regla NO cubre.** Un plan que existe y que el motor rechaza no es eje inexistente:
  es fallo del instrumento, sale «no» con el error verbatim y va a `DISCREPANCIAS_v03.md`. Son el
  400 `could not convert string to float: 'custom'` del Enterprise de Brevo (**DV-03**) y las
  catorce de diecisiete llamadas de Mailchimp que devuelven `500 float() argument must be a string
  or a real number, not 'NoneType'`, causadas por dos huecos que **E15** y **B16** admiten por su
  nombre, el `max` vacío del workload y el `period` vacío de la franquicia.

  **El caso que la origina.** La segunda tanda de preguntas PI sobre las cuatro APIs nuevas, el
  2026-09-21. Brevo y Mailgun tienen los tres ejes y no la necesitan. SES no tiene plan gratuito
  —y su capa gratuita está en discrepancia registrada, no ausente— ni plan que ligue volumen, y
  contesta las diez preguntas desde el alias `sandbox`. Mailchimp tiene un solo plan y su escalón
  gratuito es el alias `demo` (**B12**), que además llega con la cuota del bloque de pago
  concatenada.
  *(consejo 2026-09-21)*

- **E17 · Un capítulo se nombra por `\ref`, nunca por su número literal; y un capítulo
  declarado sin cuerpo no se saca de la cadena de `\input`.** El número de capítulo es una
  cifra derivada del orden de `\input` de `TFG.tex`: escribirlo a mano en otro fichero lo
  copia, y eso es lo que prohíbe la fuente única. Además no es un identificador, así que
  ninguna herramienta lo valida: LaTeX avisa de un `\ref` sin `\label` —sale «??» y el log
  trae `undefined references`—, pero de un «Capítulo~8» tecleado no avisa nunca. Y el
  capítulo que está planificado y aún sin escribir **se queda en la cadena** y declara su
  estado en una línea; sacarlo del `\input` borra una entrada del índice, y el índice es
  carril rojo. *(consejo 2026-09-22)*
  Caso: la introducción prometía un Capítulo 7 de evaluación y un Capítulo 8 de conclusiones
  (`01_introduccion.tex:236` y `:238`) que el documento no compila, y `02_Gestion.tex:92`
  mandaba al «Capítulo~8» para hablar de Conclusiones, que es el séptimo `\input`. Los tres
  compilaban sin una sola advertencia.

- **E18 · Una cifra de bibliografía se mide sobre el texto sin comentarios y con las citas
  multilínea unidas, nunca línea a línea.** El recuento de entradas, de claves citadas y de
  citas rotas se obtiene así: se toman los `\input` no comentados de `TFG.tex`, se borran los
  comentarios `%` —incluido el salto de línea que comentan— y se buscan los `\cite*{...}`
  sobre el texto resultante. `\citep{a,%` seguido de `b}` es **una** cita de dos claves:
  quien cuenta por líneas pierde la segunda y declara huérfana una entrada que el PDF sí
  imprime. Antes de proponer borrar una entrada por huérfana se re-mide con este
  procedimiento y se pega el output. Corolario de redacción: las claves de un `\cite` no se
  parten entre líneas. *(consejo 2026-09-22)*
  Caso: el 2026-09-22 se abrió deliberación para borrar `mailtrap2026comparativa` y
  `mailslurp2026comparativa` por huérfanas. El recuento correcto da 54 entradas, 54 citadas,
  0 rotas: las dos sostienen el hueco de investigación en `03_EstadoDelArte.tex`. Borrarlas
  habría dejado dos citas rotas impresas en el PDF.

- **E19 · Un campo vacío no dice por qué está vacío: la memoria toma su lectura del literal,
  no de su forma.** En ACM2YAML v0.3 la misma forma —el campo presente y sin valor— sirve a
  tres lecturas: el límite existe y no tiene cifra publicada (**D1**, fricción **F-01**); el
  proveedor niega el tope en esa unidad (**F-06**); la dimensión no existe en ese plan
  (**B16**). Ni el color del semáforo, ni **E15**, ni un `not_found` las distinguen. Por eso:
  1. Antes de atribuir una lectura en la memoria, se abre el literal del `data_provenance` o
     de `fuentes.md` y la celda del tablero de la API; el comentario `%` del pasaje lleva ese
     literal. Si el literal niega el límite, la prosa lo dice así. Sin un literal que lo
     niegue se escribe «no publicado», nunca «no existe».
  2. Un caso mal leído no se retira ni se sustituye: se cuenta en el lado que le toca. Un
     sustituto tendría que tener la misma forma y la misma traza, y un `not_found` no es un
     campo presente y vacío.
  3. Una agrupación del tipo «en los N casos» vale solo si la fuente de cada campo la
     sostiene; si no, se parte. La corrección alcanza a toda frase que repita la lectura, en
     cualquier capítulo.
  4. Recurrencia y traza no se prestan la lectura: que una fricción recurra no dice qué
     significa su hueco en una API concreta.
  5. No se toca la Datasheet (**B16**, **E15**), ni la forma de la propuesta P-nn, ni
     `tab:propuestas`: la regla corrige la lectura, no el dato ni la extensión.
  *(consejo 2026-09-25)*
  Caso: P-04 en el Capítulo 6 contaba el `max` vacío de destinatarios por llamada de
  Mailchimp Transactional como «el límite existe y su valor no se conoce», y la fuente dice
  lo contrario: *«Via the API, there's no recipient limitation»* [F4]. Postmark estaba en el
  mismo lado equivocado: su `/email/bulk` no tiene tope de mensajes, y P-03 ya lo cuenta así.
  Solo Resend es un límite que existe sin cifra. El consejo votó 4 a 1 reescribir el caso con
  las dos lecturas sobre la misma forma, que es justo la distinción que pide P-04; el voto
  discrepante solo difería en Postmark, y su literal lo desmiente. Si resultara equivocada, se
  revierten los bloques de P-04 del Capítulo 6 que la aplicaron y se retira esta regla; el
  coste es que el Capítulo 6 vuelve a contradecir al 5 (Apartado de Mailchimp) y a P-03.

- **E20 · Una tabla que retrata una Datasheet en una fecha pasada es una sola foto, y su
  corte se nombra por el hito que la cierra.** Semáforos, recuento de fuentes y avisos del
  validador salen de la misma revisión (`REVISION.md` o commit). El corte se redacta con el
  suceso que delimita esa foto, no con una decisión posterior. Si la prosa de alrededor cita
  un dato de después, se corrige la prosa y se remite con `\ref` al apartado del estado al
  cierre. Una celda suelta no se pone al día. *(consejo 2026-09-28)*
  Caso: `04_Propuesta.tex` fechaba la lectura del piloto «antes de que se adoptara su
  \textit{rate}, el 7 de septiembre» y dejaba en ámbar el lote de 500. El sondeo [E3] lo pasó
  a verde ese mismo día, antes de la adopción, y dos párrafos después el texto lo daba por
  «acotado con evidencia». Las trece fuentes y los cinco avisos de la página son de la foto
  del 06-09 (bitácora 228). El consejo votó 5 a 0 conservar el ámbar y fechar el corte
  «antes de los sondeos del 7 de septiembre». Si resultara equivocada, la celda pasa a
  verde y en el mismo cambio se actualizan las fuentes, los sondeos y el 12 ok / 5 avisos a
  la revisión posterior a [E3].

- **E21 · Un aviso local no justifica un cambio global del preámbulo.** Codificación de
  fuente, familia o `microtype` cambian la tipografía y los cortes de palabra de todo el PDF.
  Los Overfull y los avisos de fuente se corrigen en su línea (`\-`, `\char`, ancho de
  columna, reformulación). Del preámbulo solo se retira lo duplicado. El cambio global entra
  si el log demuestra que reduce el total de avisos sin abrir ninguno nuevo.
  *(consejo 2026-09-28)*
  Caso: la memoria compila en OT1 y no parte palabras con tilde (Overfull de 11,7 pt en la
  introducción), y `\{` dentro de `\texttt` cae a `OMS/cmsy`. Añadir `[T1]{fontenc}` y
  `lmodern` los quitaba, pero abría un Overfull en el Capítulo 5 y cambiaba los cortes de
  las 162 páginas a días de la lectura completa del autor. El consejo votó 3 a 2 los arreglos
  locales. Si resultara equivocada, se revierten los cortes locales, se añaden `fontenc` y
  `lmodern` a `etc/pkgs.tex` y se tratan los Overfull nuevos.

- **E22 · Un sondeo cuya salida ya se cita queda congelado: su huella es el commit que lo
  ejecutó.** No se reescribe, ni siquiera para cerrar un defecto de seguridad que solo se
  manifiesta al ejecutarlo. El defecto se documenta en la cabecera de la librería que lo
  resuelve, con la lista de los sondeos que no migraron y el motivo. Si hay que volver a
  ejecutarlo, antes se migra en un script nuevo con su test previo, y el resultado entra
  como evidencia nueva con fecha propia. *(consejo 2026-09-28)*
  Caso: cuatro sondeos de Brevo (`probe_brevo_a_429_rps.sh`, `_ventana_y_reset.sh`,
  `_caudal_solo_lectura.sh` y `_caudal_por_clave.sh`) pasan la clave en el argv de `curl`,
  lo que `lib_curl_brevo.sh` se creó para evitar, y su cabecera daba por migrados los diez.
  Su salida está citada en `brevo/fuentes.md` y en la Datasheet. El consejo votó 5 a 0
  congelarlos y corregir la cabecera. Si resultara equivocada, se migran los cuatro a
  `curl_brevo` con un test que falle si la clave aparece en el argv, y la bitácora anota el
  commit de la versión que produjo cada evidencia citada.

- **E23 · Las cifras de voz de D-043 no se recalculan con otra herramienta, y la compuerta no
  deja prosa sin medir.** La referencia de D-043 (22,3 · 37 · 6,4 %) sale de
  `comparar_voz.py` sobre `TFG_cuerpo.txt`, con la segmentación de `detectar_ia.py`, y no se
  recalcula. `medir_frases.py` es la compuerta, con su propia segmentación. Sobre el mismo
  TFG da 27,8 · 45 · 13,3 %, así que es más estricta que la referencia, y la diferencia queda
  documentada, no corregida. Calcula el p90 por rango más cercano (ceil): un error de cálculo
  no se congela como definición. La prosa de `description` y `mdframed` se mide en una fila
  aparte, con los mismos techos y sin entrar en la media, y la compuerta la aplica.
  *(consejo 2026-09-28, desempate De Bono)*
  Caso: el medidor tomaba el p90 por floor, un rango por debajo en muestras pequeñas, y
  borraba enteros el objetivo, las RQ, los OBJ y las contribuciones de la introducción, que
  son lo primero que lee el tribunal. La primera ronda quedó 1-2-2. En la segunda, cinco
  sombreros de seis votaron el bloque aparte. El blanco votó recalibrar y aportó el dato que
  esta regla recoge: la referencia nunca se midió con `medir_frases.py`. Si resultara
  equivocada, se retira la fila aparte y se vuelve al floor. Ninguna cifra histórica se
  mueve, porque cada medida de la bitácora lleva su fecha.

- **E24 · Las cifras de un sondeo se citan del volcado archivado, con su hora, y de ningún
  otro sitio.** Si la ejecución que se recuerda se sobrescribió antes de llegar a git, todas
  las copias de la cifra (`fuentes.md`, `hechos_*.md`, `REVISION.md`, memoria) pasan a la
  hora y las cifras del volcado archivado. La ejecución perdida queda como nota de una línea,
  sin cifras. Los veredictos que no dependen de esas cifras se conservan. Si el veredicto
  cambia, se aplica E22: el sondeo no se reescribe y se ejecuta de nuevo como evidencia con
  fecha propia. *(consejo 2026-09-28)*
  Caso: [E2] de Brevo citaba 19:24–19:33 UTC, `remaining` 4997 y `reset` 1630 para
  `GET /v3/account`. El único volcado, `probe_brevo_caudal_solo_lectura_2026-09-17.json`,
  entró en un solo commit (b3647b8, 20:52 UTC) y dice 20:50:01, 4999 y 601. El script escribe
  en una ruta fija, así que la ejecución de las 20:50 pisó la anterior. Los veredictos (limit
  5000, 400 con cabeceras, 200 sin ellas) son iguales en las dos. El consejo votó 5 a 0. Si
  resultara equivocada, se restauran en [E2], BR-110 y `REVISION.md` las cifras de las 19:24
  marcadas como «lectura sin volcado», y el fichero de las 20:50 pasa a segunda ejecución.

- **E25 · Un recuento transversal declara la fuente real de cada celda.** Donde la
  ocurrencia tiene fila en el tablero de su API, la fuente es esa fila. Donde no la tiene, la
  fuente es el origen que el propio recuento declara, con su cita literal (en `RECURRENCIA`,
  la columna por API y la fila arbitrada de la unidad de revisión, más el apartado (d) si la
  celda se verificó allí), y la cabecera enumera esas celdas. Los tableros de Datasheets
  cerradas no se amplían para cuadrar con el recuento: el alta en el tablero solo entra si se
  reabre esa API, con su evidencia. *(consejo 2026-09-28)*
  Caso: la cabecera de `RECURRENCIA_2026-09-23.md` decía que los tableros por API «siguen
  siendo la fuente de cada celda», y 25 celdas con ocurrencia no tienen fila en el
  `fricciones.md` de su API (Postmark 5, Resend 4, SendGrid 5, MailerSend 7, Brevo 2, SES 2).
  Darlas de alta copiaba cada literal a mano en dos sitios y reabría tableros cerrados. El
  consejo votó 5 a 0 corregir la cabecera. Al aplicarla se comprobó que el apartado (d) solo
  cubre 14 de las 25, y que las 25 tienen línea en `<api>/columna.md` y en `filas/F-nn.md` de
  `revision_externa/unidades/w1/`: esa es la fuente que se declara. Si resultara equivocada,
  se dan de alta las 25 filas en el `fricciones.md` de cada API citando su columna y su fila
  arbitrada, y la cabecera vuelve a declarar los tableros como fuente única.

- **E26 · Una cita de alcance respalda el objeto que nombra, no a su hermano.** A veces una
  fuente da la misma cifra a dos objetos parecidos (plantillas de cuenta y de dominio, API v1 y
  v2) y el fichero modela solo uno. La cifra y su alcance se citan entonces de la frase que
  nombra el objeto modelado. Si esa frase toma la cifra de otra («same limit», «these quotas»),
  se citan las dos juntas: es el antecedente de D12 fuera de las `DISC-nn`, porque lo que se
  afirma es el alcance. No abre discrepancia, porque las frases hablan de objetos distintos. El
  producto por número de instancias (100 por dominio, por N dominios) no se escribe como dato,
  porque la fuente no lo publica. Y antes de escribir en `fuentes.md` que un alcance «no tiene
  cita», se lee entero el párrafo de la cita que ya se tiene.

  **El caso.** Mailgun modela `/v3/{domain_name}/templates`, el endpoint de plantillas de
  dominio, y describía el tope «en la cuenta» con la frase de las plantillas de cuenta, que
  viven en `/v4/templates`. La frase siguiente da el mismo tope por dominio de envío,
  `"Domain-scoped templates have same limit set on a per sending domain basis."`, y ya estaba
  en la captura de Wayback del 2026-06-12. [F9] y MG-136 daban ese alcance por no citado.
  Votación 5 a 0. *Si resulta equivocada:* se repone «en la cuenta» en las cuatro `description`
  y la cita de una sola frase. No se movió ningún valor. *(caso Mailgun [F9], consejo
  2026-10-31)*

## F. Escalera de validación
- **F1 · Escalón 2 (panel) en todas las APIs** (simetría, decisión 2026-08-05). El alta
  la hace el autor; la observación la hace el agente en modo lectura, con capturas
  redactadas (correo y tokens tapados).
- **F2 · Escalón 3 (sondeo): primero el que no gasta envío**, y con lo que la cuenta permita
  (dominio verificado, token de pruebas). Desde **D-046** el envío real está permitido si el
  destinatario está en la lista blanca de `docs/08-mandato.md`, con el presupuesto declarado en
  el script. Si ni lo uno ni lo otro, el dato se queda en ámbar documentado. *(Q2)*

- **F3 · Lo que pasa después del aborto.** F2 dice con qué se lanza un sondeo; esta regla dice
  qué se hace cuando el sondeo, ya lanzado, produce el efecto que declaraba imposible. Tres
  obligaciones y una prohibición.

  **(1) El «coste cero» se predica de lo ejecutado, no de lo planeado.** Un sondeo que se
  detiene porque el proveedor aceptó, encoló o programó lo que la cabecera daba por descartado
  **no se cita como coste cero**: se cita como abortado, con la cifra real. La cola cuenta. Los
  contadores de `backlog` o `queued` son el coste aunque `sent` sea 0 y aunque la cola drene
  hacia rechazos. La parte anterior al disparo conserva su semáforo normal y sigue siendo
  citable.

  **(2) La guarda no autoriza a continuar a mano.** Completar el barrido que la guarda no llegó
  a ejecutar, o explorar variantes nuevas —volumen, tamaño, destinatarios—, es un **sondeo
  nuevo a todos los efectos**: pide su propio script, con su comprobación de destinatario y su
  presupuesto declarado (F2, D-046). Una ejecución manual de comandos sueltos que se salte la
  guarda no es una continuación del sondeo original y no se cita como tal.

  **(3) El fichero crudo no es el cierre.** El fichero que el script dejó en `evidencias/` se
  conserva íntegro y sin editar. El cierre es una sección **«Lo que costó»** en el documento
  del sondeo, con los contadores del proveedor que prueban el coste —`sent`, `rejects`,
  `bounces`, `backlog`— y qué tandas se lanzaron después de la primera parada, automáticas o a
  mano. Sin esa sección, un fichero que se autocontradice no es citable.

  **(4) No queda huérfano.** El sondeo se referencia desde `fuentes.md` con su propio `[En]`,
  aunque no cierre ningún campo, y desde `hechos_<api>.md` con su fila, que es lo que **B9 ·
  L1** exige y lo que falta aquí. Si el desvío cambia una fricción o el veredicto de una
  pregunta abierta, entra además en `DECISIONES.md` con la forma de **D-033**, que es el
  precedente: allí un sondeo «correcto en lo que decía medir» consumió un cupo no declarado y
  se cerró como hallazgo, no enterrado en el fichero crudo.

  **El mensaje de la guarda se corrige en el script.** El caso lo destapa: `guarda_entrega` en
  `probe_mandrill_a_preflight.sh` imprime «Mandrill ACEPTO el mensaje para entrega y este
  sondeo se declara de coste cero» de forma incondicional, así que fabrica la contradicción
  sola y la repetirá en cualquier API. La guarda anota el aborto y el estado que lo disparó, y
  **no declara coste**. Caso: Mandrill, `sondeo_a_preflight_2026-09-21`, donde la guarda paró
  bien en n=100 y las tandas manuales posteriores acumularon ~7.600 destinatarios encolados.
  *(caso Mailchimp MC-6, consejo 2026-09-21)*

## G. Matriz funcional (D-019)
- **G1 · Cada API lleva `features.md`** con la matriz de features por plan: webhooks de
  eventos, IP dedicada, retención de actividad, dominios, usuarios, entrada de correo
  (inbound), SMTP y plantillas. Se captura **dentro del ciclo de recolección** (paso 1),
  desde la página de precios y el panel, con las mismas fuentes `[Fn]` de `fuentes.md`.
  Presupuesto: media hora por API. *(D-019)*
- **G2 · Celda = valor literal + fuente + escalón.** Lo que la fuente no dice se deja
  vacío («—»), nunca se supone a partir de otro plan ni de otra API. Un add-on se anota con su
  precio y su condición (plan mínimo, volumen). *(D-019; regla 1 del pipeline)*
- **G3 · La matriz no entra en el YAML** (B1). Responde a las preguntas de clase **L** del
  catálogo (PI-E01, PI-E02): «respondible por lectura de la matriz funcional, fuera del
  esquema v0.3». La retención (PI-E03) se recoge en la matriz pero la pregunta sigue en X:
  es un límite no consumible que pertenece al esquema (F-09). *(D-019)*
- **G4 · El kiviat de condiciones de uso mide lo que publica el proveedor, no lo que captura
  el esquema.** Hay un eje por cada categoría de A2, nueve en total. Cada celda API × categoría
  recibe una nota de especificidad, puntuada desde `fuentes.md` y las capturas archivadas.
  Nunca se puntúa desde el YAML. La página de precios manda en los API products (D17).
  - **0**: ninguna fuente archivada la menciona.
  - **1**: se menciona, pero sin cifra ni enunciado concreto.
  - **2**: hay cifra solo para una parte de los planes o endpoints a los que aplica, o hay una
    DISC abierta sobre ella.
  - **3**: hay cifra para todos los planes y endpoints a los que aplica, sin contradicción
    entre fuentes. En *ventanas* y *qué pasa al superar*, «cifra» se lee como enunciado
    explícito: la duración y el tipo de la ventana, o la respuesta (código, cabecera, bloqueo
    o cobro).

  El 3 no exige ventana ni comportamiento en las demás categorías, porque esas dos tienen eje
  propio y se contarían dos veces. Si el producto no tiene el objeto (por ejemplo, ningún
  endpoint de lote), la celda es «n/a»: no vale 0 y se dibuja como hueco. Puntúan dos lectores
  independientes. Si discrepan, gana la nota menor, y la concordancia (kappa ponderada) se
  publica con la figura. La tabla 9 × 8 va siempre bajo el gráfico, con el grado de A2 como
  columna de contraste. La distancia entre una nota alta y una «fricción» es lo que el esquema
  no sabe expresar. La escala es ordinal: no se calculan áreas, medias ni sumas. Los
  diagramas polares por dimensión son de Daniel Ruiz (acta T4). Aquí se aplican y no se
  proponen. En la evolución de una API (R17) se usa la misma escala, pero solo en los ejes
  que cubre la página seguida, con un polígono por versión. Los demás ejes no se dibujan,
  porque dibujarlos como constantes afirmaría una estabilidad que nadie observó.

  **El caso que la origina.** Con la matriz de A2, 48 de 72 celdas son «parcial» y caudal,
  cuota y destinatarios lo son en las ocho APIs. Un kiviat de grados de A2 sale casi plano y
  mide el esquema, no lo que el tutor pidió (acta F11): qué componentes de las condiciones de
  uso están más o menos desarrollados. Votación para R28: 5–0 por la especificidad. Para R17,
  los asientos se partieron entre nueve ejes y solo los observados. Se resolvió midiendo la
  premisa: `versiones_mailersend.md` sigue cuatro apartados, que cubren caudal, cuota,
  ventanas y qué pasa al superar el límite. Puntuados con la regla, solo uno de sus ocho
  cambios mueve la nota: el caudal pasa de 2 a 3 cuando MS42903 deja de contradecir la tabla.
  Los demás cambian cifras, no cuánto se concreta.
  *Si resulta equivocada:* las figuras están fuera de la memoria (R19 es rojo) y salen de un
  CSV con un script. Se cambia la escala, se vuelve a puntuar y se regeneran. Nada más
  depende de ellas. *(caso kiviat R28/R17, consejo 2026-10-18)*

## H. Maqueta de la colección

- **H1 · Propósito y coste de una interfaz de la maqueta van por separado.**
  *Caso:* reunión del 23-10, preguntas 1, 2 y 5 del guion sin plantear a Antonio. La Web UI,
  el correo entrante y las 17 interfaces pendientes de SES.

  1. El propósito sale del tipo de interfaz, con la tabla de la maqueta. API REST, SMTP e
     integración no-code son Consumo. Web UI y asistente del panel son Administrativa.
     Webhook, flujo de eventos y correo entrante son Integración. CLI y servidor MCP son
     Consumo y administración. La tabla es una propuesta del TFM y no sale de las skills de
     Daniel Ruiz.
  2. Una Web UI pasa a Consumo y administración solo si una cita dice que su panel envía
     correo que gasta la cuota del plan. Un correo de prueba no basta mientras no conste que
     gasta cuota. La excepción se anota en esa interfaz y la tabla no cambia.
  3. El coste se rellena aparte del propósito. Si la datasheet tiene evidencia de que una
     interfaz de Integración gasta cuota o tiene límite propio, se muestra ese valor con su
     fuente. Sin evidencia se escribe «sin verificar», no «sin cargo propio».
  4. Una interfaz que el analizador de Daniel Ruiz deja en `pending` no se dibuja como
     interfaz. El servicio muestra «N confirmadas de M» y una lista plegada con el nombre y el
     motivo de cada pendiente.
  5. Si el TFM no está de acuerdo con la salida de las skills, la corrige en la maqueta, la
     marca como reclasificación del TFM y se la manda a Daniel Ruiz como feedback. Las skills
     no se tocan.
  6. Una interfaz de un producto de marketing sigue en el árbol, marcada «fuera de alcance
     (marketing)», porque el alcance es el servicio transaccional (sección A).

  SendGrid «Inbound Parse Webhook» y Mailgun «Inbound routing» también reciben correo, pero
  van como Webhook y como Flujo de eventos; el caso no las incluyó y no se mueven.
  *Si resulta equivocada:* se cambia la tabla de la maqueta y los valores de coste de esas
  interfaces. Ninguna datasheet ni la memoria dependen de esto. Anticipada, no validada por
  Antonio: se le confirma en el correo que envía el autor. *(D-076; consejo 2026-10-23)*
