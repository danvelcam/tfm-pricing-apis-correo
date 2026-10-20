# Fricciones con ACM2YAML v0.3 — Mailgun

Octava API del catálogo, y la primera en la que el sondeo desmiente el tope publicado por
un factor de dos. El proveedor escribe 25 MB por mensaje en tres páginas distintas [F12]
[F15][F20]; un adjunto de 48 MB atraviesa la comprobación de tamaño y solo cae después,
por permisos. El rechazo real llega en 52,4 MiB y es de la petición entera.

Es también la primera cuyo caudal se midió y salió **fraccionario en las dos magnitudes**:
la ventana dura 9,85 y 9,87 segundos, y el tope de tamaño es 52,4 MiB. El esquema tipa las
dos cosas como enteros, así que el fichero redondea y la cifra exacta vive en el
provenance. De ahí sale la **F-35** de esta lista.

Pasada 1 · **2026-09-21**: veinticuatro frentes documentales, escalón 2 con cuenta propia
([F24]) y escalón 3 el mismo día — doce mediciones contra el dominio sandbox, más una
segunda pasada del propio 2026-09-21 con tres mediciones más ([E1]): quince en total.
Evidencias en `03_datos/apis/mailgun/evidencias/`.

Una regla nueva sale de esta API: **E13** (consejo del 2026-09-21, clase MG-3), que obliga a
rendir con navegador la página bloqueada cuando es la única fuente del dominio para una
cifra. Su caso originario es [F15], `www.mailgun.com/ai-info/`.

---

## Recuento de recurrencia

Columna de Mailgun sobre el catálogo de treinta y cuatro fricciones. Las ocho del piloto van
desarrolladas más abajo; del resto se anota el veredicto y su literal. **G2**: sin fuente
registrada la celda queda en *(verificar)*, no en ❌.

| # | Fricción | Mailgun | Veredicto |
|---|---|---|---|
| F-01 | Un rate que existe pero no tiene valor | ✅ | **RECURRE** — ver §F-01 |
| F-02 | Volumen contratado con sobrecoste variable | ✅ | **RECURRE** — ver §F-02 |
| F-03 | CRF multiplicativo entre dimensiones | ❌ *(un solo eje: 1.000 destinatarios por petición y ningún lote de mensajes que los multiplique)* | No recurre |
| F-04 | Restricciones declaradas y no aplicadas | *(verificar)* *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: el 403 de preflight oculta el tope publicado; antes: ✅ medida)* | **RECURRE** — ver §F-04 |
| F-05 | RPR no serializable | ✅ | **RECURRE** — ver §F-05 |
| F-06 | Workload acotado por otra métrica | ✅ **variante triple** | **RECURRE** — ver §F-06 |
| F-07 | Add-ons que modifican capacidad | ✅ *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: IP adicional por $59/mes y acceso en 50k o incluida en 100k+ volúmenes; antes: verificar con ninguna fuente registrada publica un extra de pago que mueva una dimensión de consumo; la retención de mensajes cambia por plan y no por add-on [F24])* | **RECURRE** *(la columna sigue a la celda de Mailgun; antes: Sin dato)* |
| F-08 | El plan es un producto cartesiano | ⚠️ **variante en duda** | Ver §F-08 |
| F-09 | La datasheet no dice qué parte sigue vigente | ❌ *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: los cambios son de Mailgun Optimize, no aplica a E3; antes: ✅ con hay changelog público, `www.mailgun.com/releases/` [F22], y precisamente por eso el hueco se ve: la documentación se mueve —varias páginas de la referencia devolvieron 404 durante la recolección— y el fichero no tiene dónde declarar contra qué versión se leyó)* | No recurre *(la columna sigue a la celda de Mailgun; antes: **RECURRE**)* |
| F-10 | Varios productos, varias unidades de consumo | ⚠️ variante que no suma *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: la segunda unidad (validaciones) cuelga del catálogo de Send, no de Optimize; falla V1; antes: ✅ con el panel muestra `"Mailgun Optimize"` y `"Mailgun Inspect"` bajo la misma cuenta, los dos en `"No subscription"` [F24], y Optimize publica caudal propio: `"API calls are subject to a rate limit of 500 requests every 10 seconds"` [F16])* | Variante *(la columna sigue a la celda de Mailgun; antes: **RECURRE**)* |
| F-11 | Límites de recursos por plan | ✅ *(`"can contain up to 3 URLs per event type"` [F14]; y en la página de precios, `"2 API keys"` en Free y en Basic y `"Free plans are limited to 1 user per account."` [F1])* | **RECURRE** |
| F-12 | La recepción consume la cuota de envío | *(verificar)* | Sin dato |
| F-13 | El sobrecoste es opcional y no existe en Free | ✅ *(las tres tarjetas de pago publican sobrecoste y la de Free no publica ninguno)* | **RECURRE** |
| F-14 | El plan tiene fecha de caducidad | ⚠️ **variante que falla V1** *(Foundation y Scale anuncian `"Free for 1 month, then"`: caduca la promoción de captación, no el plan)* | Variante |
| F-15 | Dos canales, dos workloads para la misma cuota | ✅ *(`"1,500 API requests per second per client IP"` y `"1,500 SMTP requests per second per client IP"`, y el horizonte de programación difiere por canal: `"you can schedule messages up to 3 or 7 days in advance"`)* | **RECURRE** |
| F-16 | El sobrecoste tiene tope del proveedor | ❌ *(el único tope del exceso lo fija el titular, y eso es F-37)* | No recurre |
| F-17 | Un tercer tope sin nivel de enganche | ❌ *(los dos topes del plan Free sí tienen nivel; lo que falla es que son concurrentes → F-38)* | No recurre |
| F-18 | La capacidad depende del estado de la cuenta | ✅ *(`"gradually increases sending rates"` [F17] y `"automatically queues your email and sends them at rates that makes the ESPs happy, increasing those rates as your sending reputation grows"` [F18], sin una sola cifra; y el 403 del plan Free nombra el estado de la cuenta, no el dominio)* | **RECURRE** |
| F-19 | Cuota de cardinalidad | ❌ *(la restricción del Free es por dirección autorizada, no por número de direcciones distintas)* | No recurre |
| F-20 | La cuota no cuenta lo que dice | *(verificar)* | Sin dato |
| F-21 | Un cupo que se gasta con intentos que no envían nada | ❌ **medido** *(el contador —`accepted.outgoing`, `delivered.smtp`— no se movió tras un 400 por exceder los 1.000 destinatarios y un 403 por destinatario no autorizado; un rechazo previo a la entrega no descuenta cuota)* | **No recurre** |
| F-22 | Una credencial que solo se gestiona desde la web | *(verificar)* | Sin dato |
| F-23 | Un comodín de prefijo con excepción | ❌ | No recurre |
| F-24 | Cuota blanda que absorbe y luego descarta | ❌ | No recurre |
| F-25 | Un endpoint, dos modos excluyentes | ❌ | No recurre |
| F-26 | Un precio por geografía y una sola divisa | ✅ *(mitad divisa: la misma página sirve la lista en tres divisas a un cambio casi constante, y el fichero declara la de dólares. Foundation vale $35, €32 y £28 en su tramo mínimo. Son tres divisas, no tres precios por geografía)* | **RECURRE** |
| F-27 | El exceso cambia el plan y lo dispara otra dimensión | ❌ *(el exceso se paga por unidad en las tres tarjetas de pago)* | No recurre |
| F-28 | Una lista de IP autorizadas decide si la llamada entra | ⚠️ parcial *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: IP Allowlist en referencia pero sin literal del efecto; antes: verificar)* | Sin dato |
| F-29 | El precio unitario sin cuota incluida | ❌ *(las cuatro tarjetas traen volumen incluido)* | No recurre |
| F-30 | Precio por tramos marginales sobre el mismo consumo | ❌ *(la escalera reprecia el plan entero, no el tramo; eso es F-02)* | No recurre |
| F-31 | La unidad de gobierno no es la cuenta | ⚠️ **variante, y por debajo de la cuenta** *(el caudal publicado se acota `"per client IP"`, así que una cuenta con N salidas obtiene N veces el tope; y la base de la API se bifurca por región, `api.mailgun.net` y `api.eu.mailgun.net`. La propuesta de F-31 —un eje de ámbito— cubre las dos mitades)* | Variante |
| F-32 | Precio unitario degresivo sin planes | ❌ *(hay cuatro planes con nombre)* | No recurre |
| F-33 | Una franquicia sin ventana | ❌ *(las dos cuotas del Free tienen periodo; lo que falta es el ancla del reinicio)* | No recurre |
| F-34 | Dos topes de tamaño sobre la misma llamada | ✅ **el caso medido** *(25 MB por mensaje publicado frente a 52,4 MiB de petición aplicados)* | **RECURRE** |
| **F-35** | **Un tope fraccionario donde el esquema solo admite enteros** | ✅ **nueva** | Ver §F-35 |
| **F-36** | **Dos contadores sobre la misma ventana, y un solo caudal por nodo** | ✅ **nueva** | Ver §F-36 |
| **F-37** | **Un tope de capacidad que fija el cliente, no el proveedor** | ✅ **nueva** | Ver §F-37 |
| **F-38** | **Dos cuotas concurrentes de la misma unidad, y un `quota` por nivel** | ⏸ *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: aplicación simultánea abierta en DISC-03; antes: ✅ nueva. Desde el 2026-10-18 la diaria va en 🟢 por D17; la concurrencia sigue abierta)* | Ver §F-38 |

Cuatro fricciones nuevas. *(alineado el 2026-09-25 con RECURRENCIA_2026-09-23.md: F-35 sin promover (L2 y L3), F-36 sin promover (L2), F-37 promueve por recurr. (1 + 1 variante), F-38 sin promover (L2); antes: Las cuatro cruzan por traza)* Ninguna alcanza todavía el umbral de recurrencia de D-008, que pide dos APIs. Se anotan para volver a mirarlas cuando el catálogo escale a diez o doce APIs.

---

## F-01 · Un rate que existe pero no tiene valor — RECURRE ✅

**Qué pasa.** La documentación de la API describe el mecanismo entero y no publica ningún
umbral: *"Mailgun APIs include the following headers to indicate rate limiting state for the
current API being called: X-RateLimit-Limit... X-RateLimit-Remaining... X-RateLimit-Reset..."*
y *"Time windows may vary by API depending on resource usage."* [F2]. El manual lo reconoce
y tampoco lo cifra: *"Mailgun does have rate limits in place to protect our system. In the
unlikely case you encounter them and need them raised, please reach out to our support
team."* [F12]. La única cifra publicada, *"1,500 API requests per second per client IP"*
[F15], mide otra cosa: el techo de una IP, no el de la cuenta ni el del plan.

**Qué hace v0.3.** Lo mismo que en Postmark: `max_power` admite el caudal con valor o no lo
admite. No hay forma de decir que el caudal existe, que el proveedor lo confirma por escrito
y que su valor por cuenta es desconocido. Aquí el hueco es peor porque hay **una** cifra
publicada de otro ámbito, y el esquema no tiene dónde declarar el ámbito.

**Consecuencia.** El fichero lleva 1.500 peticiones por segundo en ámbar, y esa cifra se
lee como tope de la cuenta cuando es tope de una IP. Un consumidor con cuatro salidas tiene
seis mil, y un consumidor detrás de un NAT compartido tiene menos. La cifra no es falsa: es
inatribuible, que para una comparación entre proveedores es el mismo problema.

**Propuesta.** La de Postmark —`status: documented | undocumented | provider_managed |
measured`— más el ámbito del caudal como campo propio: cuenta, plan, IP de cliente, clave.
Sin él, dos cifras iguales de dos proveedores no son comparables.

---

## F-02 · Volumen contratado con sobrecoste variable — RECURRE ✅

**Qué pasa.** Las tarjetas dicen *"Starting at"* y el precio real lo fija un selector de la
misma página, *"How many emails do you want to send per month?"*, con nueve posiciones desde
10.000 hasta *"More"* [F1]. Foundation va de $35 con 50.000 correos a $75 con 100.000. Scale
va de $90 con 100.000 a $1,250 con 2.500.000. Y el sobrecoste se mueve con el volumen:
Scale lo baja de $1.10 por mil a $0.40 por mil al cruzar la escalera entera.

**Qué hace v0.3.** Una cuota tiene un `value` escalar y un `overage_cost` único. El fichero
declara el tramo mínimo de cada tarjeta y la escalera completa se queda en dos notas del
provenance.

**Consecuencia.** La comparación de precios sale sesgada contra Mailgun: el fichero lleva
$0.0011 por correo en Scale, que es su tarifa más cara, y el cliente que contrata 2,5
millones paga $0.0004. El error relativo entre lo declarado y lo real llega a 2,75 veces
dentro del mismo plan.

**Propuesta.** La misma que en Postmark: escalones con precio y sobrecoste propios dentro de
la cuota. Mailgun añade el argumento de recurrencia, que era lo que D-008 pedía.

---

## F-04 · Restricciones declaradas y no aplicadas — RECURRE ✅, y medida

**Qué pasa.** El proveedor publica el mismo tope en tres sitios: *"The maximum message size
Mailgun supports is 25MB"* [F12], *"The maximum size is 25 MB per message on Mailgun."* [F15]
y, en los términos legales, *"an individual email message not exceeding the per-message size
limit (including attachments) of 25MB or it may be permanently lost."* [F20]. El sondeo del
2026-09-21 subió adjuntos de 30, 35, 40, 45 y 48 MB: los cinco atravesaron la comprobación
de tamaño y cayeron después, por los permisos de la cuenta. El único tope que la API aplica
en el borde llega en 52 MB, con `413 "request size exceeds 52.4MiB limit"`.

**Qué hace v0.3.** Nada distinto de Postmark: el esquema registra el valor y no su
exigibilidad. Aquí la diferencia es que el caso está **medido**, no declarado por el
proveedor: en Postmark el propio proveedor admitía no aplicar el límite SMTP; en Mailgun lo
desmiente el sondeo.

**Consecuencia.** Un fichero que declarase los 25 MB publicados describiría una capacidad
que no es la de la API, por defecto y en el sentido que perjudica al cliente: le haría
partir mensajes que caben. El fichero declara los 52 MiB medidos y los 25 MB publicados
quedan en el provenance, que es la lectura contraria a la de Mailchimp con el mismo patrón.

**Propuesta.** Distinguir en el esquema el límite publicado del límite aplicado, con la
fuente de cada uno. Es la misma pregunta conceptual que Postmark dejó para el tutor —si la
capacidad contractual incluye lo que el proveedor no hace cumplir—, y con dos casos medidos
deja de ser conceptual: hay que elegir cuál de los dos números va al fichero.

---

## F-05 · Results Per Request no serializable — RECURRE ✅

**Qué pasa.** `GET /v3/{domain_name}/events` publica *"The number of entries to return (300
max)"* [F8], y el sondeo lo confirmó con el rango en el propio error: `limit=300` devuelve
200 y `limit=301` devuelve 400 con *"Invalid parameter: limit=[\"301\"], Number out of range
[1, 300]"*. Es la dimensión RPR, con su tope exacto y verificado.

**Qué hace v0.3.** RPR sigue fuera del alcance de la serialización. El fichero declara el
endpoint con `workload: requests 1..1` y mete las 300 entradas en la descripción.

**Consecuencia.** La capacidad de consulta queda invisible para las herramientas, igual que
en Postmark, SendGrid, MailerSend, Brevo y Mailchimp. Con seis de las ocho APIs, esto ya no es una
carencia de una API: es una dimensión del ACM que la serialización no cubre.

**Segunda pasada, 2026-09-21.** Se buscó también la otra mitad de la RPR, el tope
acumulado: paginar con `paging.next` hasta que deje de devolver. La cuenta Free retiene
un día de eventos, y con solo 42 registrados la segunda página ya volvió con 0 items y el
enlace `next` todavía presente. No hay volumen para tropezar con un tope de profundidad,
y el resultado queda negativo por eso, no por falta de intento.

**Propuesta.** Serializar RPR, que era trabajo futuro declarado de v0.3 (C-02). Mailgun no
añade un requisito nuevo: añade el sexto caso, y con él la evidencia de que el hueco es del
dominio y no del muestreo.

---

## F-06 · Un workload acotado por otra métrica — RECURRE ✅, en variante triple

**Qué pasa.** Una llamada a `/v3/{domain_name}/messages` está acotada por tres magnitudes a
la vez, y las tres tienen literal. Destinatarios: *"Maximum 1,000 recipients per batch."*
[F5], con el 400 medido en la petición 1001. Tamaño de la petición: 52,4 MiB, medidos.
Parámetros de opciones: *"Send options (parameters starting with o:, h:, v:, or t:) are
limited to 16KB total"* (referencia del endpoint de envío), con 17 kB rechazados en el sondeo.

**Qué hace v0.3.** `workload` admite la lista de cargas, así que el fichero aloja dos —los
destinatarios en `emails` y el tamaño en `MiBs`— y el tercer tope no tiene unidad de consumo
donde colgarse: los 16 kB de opciones no son una unidad que se consuma, son una cota sobre
un trozo de la petición.

**Consecuencia.** El tope que primero se alcanza depende del contenido, y el fichero no
puede decir cuál manda. Un envío con plantilla y muchas variables choca con los 16 kB antes
que con los 1.000 destinatarios; uno con adjuntos choca con los 52 MiB. El motor lee dos
cotas independientes y responde con la más laxa.

**Propuesta.** Cargas multi-métrica con la relación entre ellas declarada —conjunción, no
alternativa— y un lugar para las cotas que acotan una parte de la petición sin ser unidades
de consumo. Emparenta con F-34, que pide lo mismo desde el otro lado.

---

## F-08 · El plan como producto cartesiano — variante en duda ⚠️

**Qué pasa.** La matriz comparativa de la página de precios marca *"Email Templates"*
incluido en las cuatro columnas. En esa misma página, la tarjeta de Foundation se titula
*"Everything on Basic plus..."* y enumera *"Email template builder and API"* [F1]. Las dos
estructuras del mismo documento dicen cosas distintas sobre si el endpoint de plantillas
existe en Free y en Basic. Estaba registrado como DISC-02, y se cerró midiendo el
2026-09-21: `POST /v3/{domain_name}/templates` responde en el plan Free, y ningún literal
separa a Basic de Free (ver `fuentes.md`).

**Qué hace v0.3.** `plans` es una lista plana y sí puede declarar endpoints distintos por
plan. El problema no es de expresividad: es que la fuente no permite saber qué declarar.

**Consecuencia.** El fichero lleva el endpoint de plantillas en los cuatro planes, por el
literal de la matriz, y la medición del 2026-09-21 confirmó la atribución en el plan
Free. Si la lectura buena hubiera sido la de los bullets, dos planes habrían declarado un
endpoint que no tenían.

**Propuesta.** Ninguna al esquema por este caso. Lo que Mailgun aporta a F-08 es una
observación sobre el método: la superficie de la API por plan se publica en prosa comercial
y no en la referencia técnica, así que es un dato que la recolección documental no puede
cerrar. Se mide o se pregunta al proveedor.

---

## F-35 · Un tope fraccionario donde el esquema solo admite enteros — NUEVA

**Qué pasa.** Las dos cifras que el sondeo midió en el borde de la API salieron
fraccionarias. El tamaño: el 413 dice *"request size exceeds 52.4MiB limit"*, y 52,4 MiB no
es un entero de MiB. La ventana del caudal: doce envíos en dos tandas comparten exactamente
dos instantes de reposición, y la ventana dura 9,85 y 9,87 segundos, no diez.

**Qué hace v0.3.** El README tipa `workload.min` y `workload.max` como `integer` (§3.4.2), y
el periodo de un caudal como un `value` entero con su unidad. Ninguno de los dos campos
admite la cifra medida. El fichero baja el tamaño a 52 MiB —el mayor entero que la API
acepta— y redondea la ventana a diez segundos, y las dos cifras exactas pasan al provenance
con su nota en `metadata.not_found`.

**Consecuencia.** El fichero pierde precisión en la dirección segura y no puede declarar que
la ha perdido. Los 0,4 MiB que se dejan fuera son el 0,8 % de la cota, y los 0,14 segundos
de la ventana son el 1,4 %: con un caudal de 80.000 peticiones, esa diferencia son 1.120
peticiones por ventana que el modelo no sabe si existen. Y el error va siempre en el mismo
sentido, porque redondear a la baja es lo único honesto cuando el tope se aplica.

**Consecuencia añadida, y es la que importa para el catálogo:** dos proveedores con el mismo
entero en el fichero pueden tener cotas reales distintas, y la comparación no lo ve.

**Propuesta.** Tipar como `number` los campos que expresan una magnitud física medida
—tamaño, tiempo— y dejar `integer` para los que cuentan unidades discretas, que es donde
tiene sentido. Alternativa más barata: un campo de precisión junto al valor, que declare si
la cifra es exacta o un redondeo y en qué dirección.

---

## F-36 · Dos contadores sobre la misma ventana, y un solo caudal por nodo — NUEVA

**Qué pasa.** Un POST aceptado a `/v3/{domain_name}/messages` devuelve dos topes con el
mismo instante de reposición: `x-ratelimit-limit: 80000` y `x-recipient-limit: 2000000`. Son
la misma ventana y dos unidades distintas, peticiones y destinatarios. Los dos se agotan por
separado y el primero que caiga corta el envío.

**Qué hace v0.3.** `max_power` cuelga de un endpoint un caudal, con un valor, una unidad y
un periodo. Es uno. El fichero declara el de peticiones y el de destinatarios se queda en
`metadata.not_found`.

**Consecuencia.** El contador que primero se agota depende del perfil de envío, y el fichero
declara el que no manda en el caso interesante. Con 25 destinatarios de media por petición,
los dos topes caen a la vez; por encima de eso, el que corta es el de destinatarios, y ese
es justo el perfil de quien usa la API de lotes. El motor construye una curva de capacidad
con el techo equivocado.

**Propuesta.** Que `max_power` admita varios caudales concurrentes sobre el mismo nodo,
compartiendo ventana, igual que `workload` ya admite varias cargas. El paralelismo es
exacto: si una petición consume en varias unidades, también puede estar limitada en varias.

---

## F-37 · Un tope de capacidad que fija el cliente, no el proveedor — NUEVA

**Qué pasa.** La API expone un endpoint para que el titular se ponga su propio techo: *"The
custom message limit imposes a hard limit on how many messages your account can send during
a calendar month."*, con *"The timeframe for which the limit applies - m for months, d for
days, h for hours"* [F7]. Lo fija, lo consulta y lo borra él, con una llamada, sin coste y
sin aprobación del proveedor. Es una cuota real —corta envíos— y su valor no está en ningún
plan.

**Qué hace v0.3.** El esquema describe lo que el proveedor ofrece: planes, cuotas, caudales.
No tiene ningún sitio para una cota que el consumidor se impone, y menos para una que se
cambia en caliente. El fichero modela el endpoint sin cuota ni caudal asociados y la
capacidad declarada ignora el mecanismo.

**Consecuencia.** La capacidad efectiva de una cuenta puede ser menor que la del plan por
configuración del propio cliente, y el fichero no lo declara ni puede declararlo. Para una
herramienta que responda *¿cuánto puedo enviar?* la respuesta correcta es el mínimo entre la
cuota del plan y este tope, y hoy el segundo término no existe en el modelo.

**Propuesta.** Un bloque de límites configurables por el consumidor, con la dimensión que
tocan, el rango admitido y el canal por el que se fijan. No es capacidad contractual, y por
eso no va dentro de `capacity`: es una cota superpuesta, y el esquema gana declarando cuáles
de sus dimensiones se pueden estrechar desde fuera.

---

## F-38 · Dos cuotas concurrentes de la misma unidad, y un `quota` por nivel — NUEVA

**Qué pasa.** El plan Free publica su volumen en dos periodos y en dos sitios: *"100
emails/day included"* en la página pública [F1] y *"3000 emails per month"* en el panel de
la cuenta propia [F24]. Ninguna fuente dice si son el mismo tope leído dos veces o dos topes
que corren a la vez. La aritmética no los concilia —100 al día son 3.000 al mes solo en un
mes de treinta días— y el bullet del plan Basic, *"No daily email limit"*, trata el tope
diario como propio de otro plan, lo que empuja hacia la lectura de dos topes concurrentes.
Desde el 2026-10-18 la cifra diaria va en 🟢 por D17, porque es literal de la página de
precios; la mensual sigue en 🟡. El color no resuelve la fricción: la pregunta de si se
aplican a la vez sigue abierta en DISC-03.

**Qué hace v0.3.** Un plan referencia **una** clave de `capacity` con `quota:`, y un
endpoint dentro del plan referencia otra. El fichero usa esos dos niveles para alojar las dos
cuotas: la mensual cuelga del plan y la diaria del endpoint de envío. Cabe, pero dice algo
que no es verdad: coloca el tope diario como si fuera propio de ese endpoint, cuando es de la
cuenta entera.

**Consecuencia.** La proyección es legible para un humano y engañosa para una herramienta.
Un motor que lea el fichero entenderá que otro endpoint de envío no estaría sujeto al tope
diario, y que la cuota diaria se repone por endpoint. Las dos lecturas son falsas, y las dos
salen de haber usado la jerarquía como almacén en vez de como semántica.

**Propuesta.** Que un plan pueda referenciar varias cuotas de la misma unidad con periodos
distintos, declarando que se aplican en conjunción. Es el hermano de F-36 en el eje del
volumen: allí son dos caudales sobre la misma ventana, aquí dos cuotas sobre la misma
unidad, y el esquema tiene el mismo hueco en los dos sitios.

---

## Observaciones sobre el propio repositorio (candidatas a PR)

**O-01 · `workload` inconsistente entre la guía y el ejemplo canónico.** Ya registrada en
Postmark, y esta datasheet la usa: los dos topes del envío se serializan como **lista** de
objetos, la forma del ejemplo canónico, no como el objeto único que define el README. Sin la
lista, F-06 no tendría dónde alojar ni siquiera dos de sus tres cotas. Mailgun es el
argumento de que la lista es la forma buena.

**O-12 · El caudal solo se lee gastando una unidad de cuota.** Las cabeceras de estado
aparecen **únicamente** en un POST aceptado: un GET devuelve 200 sin ninguna, y un POST
rechazado por permisos tampoco las trae. No es carencia del esquema sino del método de
recolección, y condiciona la escalera de validación: en Mailgun el escalón 3 no puede leer
el caudal sin consumir, así que la observación de un caudal y la medición de una cuota no
son separables. Va a la guía de `sondeo-empirico`, no a un PR del esquema.
