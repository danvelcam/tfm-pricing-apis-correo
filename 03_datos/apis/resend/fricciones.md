# Fricciones con ACM2YAML v0.3 — Resend

Segunda API del catálogo. Lo que importa aquí no es solo qué falla, sino **qué vuelve a
fallar**: el marco D-008 promueve una propuesta al esquema cuando la fricción recurre en
**≥2 APIs**. Desde **D-042** hay una segunda vía: basta una sola API si la consecuencia
está ejecutada sobre PRIME4API y archivada (listón L1/L2/L3, regla B9). Con esta pasada,
cuatro fricciones del piloto cruzan ese umbral.

Pasada 1 · 2026-08-05. Pasada 2 (panel, escalón 2) · 2026-09-01.

---

## Recuento de recurrencia

| # | Fricción | Postmark | Resend | Vía · veredicto (D-008 · D-042) |
|---|---|---|---|---|
| F-01 | Rate que existe sin valor | ✅ | ⚠️ parcial | **PROMOVIBLE por traza** → P-04 (no por recurrencia: ver abajo) |
| F-02 | Volumen contratado con sobrecoste variable | ✅ | ✅ | **PROMOVIBLE** |
| F-03 | CRF multiplicativo | ✅ | ✅ | **PROMOVIBLE** |
| F-04 | Restricciones declaradas y no aplicadas | ✅ | — | Sin promover |
| F-05 | RPR no serializable | ✅ | — *(no verificado)* | Sin promover |
| F-06 | Workload acotado por otra métrica | ✅ | ✅ | **PROMOVIBLE** |
| F-07 | Add-ons que modifican capacidad | ✅ | ✅ | **PROMOVIBLE** |
| F-08 | El plan es un producto cartesiano | ✅ | ⚠️ parcial | Ver abajo |
| F-11 | Límites de recursos por plan (no son consumo) | ✅ | ✅ | **PROMOVIBLE** |
| F-12 | La recepción consume la cuota de envío | *(verificar)* | ✅ | Pendiente de 2.ª API |
| F-13 | El sobrecoste es opcional y no existe en Free | *(verificar)* | ✅ | Pendiente de 2.ª API |

Nuevas en esta API: **F-09**, **F-10** y, tras el panel, **F-11**, **F-12** y **F-13**.
Nueva observación de repositorio: **O-04**. Familia aparte, no capacitaria: ver el final.

---

## F-01 · Un rate que existe pero no tiene valor — recurrencia PARCIAL

**Qué pasa.** Resend hace justo lo contrario que Postmark en tres de sus cuatro planes:
publica el caudal, *"The default maximum rate limit is 10 requests per second per team"*
[F4]. La fricción reaparece, pero acotada a dos sitios: el plan **Enterprise**, cuyas
condiciones son negociadas, y el caudal concedido a un *trusted sender* —
*"This number can be increased for trusted senders upon request"* [F4] — sin umbral ni
valor publicados.

**Por qué no se promueve todavía.** El caso de Postmark es «existe un rate y su valor es
inobservable»; el de Resend es «existe un valor por defecto y un procedimiento para
cambiarlo». No es la misma carencia, así que **no cuenta como segunda ocurrencia**.
Anotarlo así, y no forzarlo, es lo que hace que el recuento signifique algo.

**Lo que sí aporta.** El contraste es un resultado del dominio por sí mismo: dos
proveedores del mismo mercado, uno publica el caudal y el otro no. Es el tipo de
observación que el capítulo 4 necesita para sostener que la opacidad no es universal.

---

## F-02 · Cuotas por volumen contratado, con sobrecoste variable — RECURRE ✅

**Qué pasa.** El plan no fija un volumen: lo fija el volumen que se contrata dentro del
plan, y **el sobrecoste baja al subir** [F2]. Pro va de 50.000/$20 a 100.000/$35, los dos
a $0,90 por 1.000. Scale recorre seis volúmenes, de 100.000/$90 a 2.500.000/$1.150, con
el sobrecoste bajando de $0,90 a $0,46 por 1.000.

**La diferencia con Postmark, y es la que da valor a la recurrencia.** En Postmark esta
estructura **no era observable sin cuenta**: hubo que verla en el panel. En Resend está
**publicada en la página de precios**. La carencia del esquema es idéntica en los dos
casos, pero en Resend se demuestra sin necesidad de acceso privilegiado — lo que la
convierte en el caso citable para defender la propuesta.

**Qué hace v0.3.** Una cuota tiene un `value` escalar y un `overage_cost` único. Se ha
modelado el volumen mínimo de cada plan y la lista completa vive en el *provenance*.

**Consecuencia.** La datasheet dice que Scale son 100.000 emails a $0,90 el millar
excedido. Es cierto solo en el primer peldaño: en el último, el mismo plan son 2,5
millones a $0,46. Comparar Resend con un proveedor de volumen fijo usando ese único
número **falsea la comparación**.

**Propuesta.** Permitir que una cuota declare una lista de volúmenes contratables, cada
uno con su precio y su sobrecoste, más una entrada `custom` para el tramo negociado.
Con dos APIs que lo exhiben, la propuesta deja de ser una hipótesis.

---

## F-03 · CRF multiplicativo entre dimensiones — RECURRE ✅

**Qué pasa.** `/emails/batch` acepta *"Trigger up to 100 batch emails at once"* [F6] y
cada mensaje admite hasta 50 direcciones en `to` [F5][F6]. Y Resend **documenta por
escrito lo que Postmark nunca declaró**: *"Multiple To, CC, or BCC recipients count as
separate emails"* [F7]. El consumo de una llamada es el producto, y esta vez está dicho.

**Qué hace v0.3.** `workload` admite una terna `unit / min / max`. Se ha puesto `max: 100`,
que es el número de mensajes, no el de emails consumidos.

**Consecuencia — y aquí es peor que en Postmark.** En Postmark el número plausible y
equivocado se deducía; en Resend **la propia documentación del proveedor demuestra que el
valor serializado es falso**. Una herramienta que lea esta datasheet calculará 100 y el
consumo real puede llegar a 5.000. No es una imprecisión: es un dato que se puede refutar
con una cita del proveedor.

**Propuesta.** Que `workload` admita composición entre dimensiones —mensajes por llamada
× destinatarios por mensaje— en vez de una terna escalar. Con dos APIs y una cita
explícita del proveedor, es la fricción mejor sostenida del catálogo.

---

## F-06 · Un workload acotado por otra métrica — RECURRE ✅

**Qué pasa.** Los adjuntos van *"max 40MB per email, after Base64 encoding of the
attachments"* [F5]: el tope efectivo de una petición no está en emails ni en peticiones,
sino en MBs, y medidos **después** de codificar. Es el mismo mecanismo que el payload de
50 MB de Postmark, y con la misma trampa de la codificación.

**Qué hace v0.3.** `workload.max` es un entero en la unidad del workload. La cota en MBs
no tiene dónde ir; queda en el *provenance*.

**Consecuencia.** La restricción que de verdad limita los envíos con adjuntos es
invisible para las herramientas en las dos APIs modeladas.

**Propuesta.** `max_by: {unit: MBs, value: 40}` junto al `max` en la unidad propia. Va de
la mano de F-03: las dos piden que el CRF deje de ser un escalar.

---

## F-07 · Add-ons que modifican dimensiones de capacidad — RECURRE ✅

**Qué pasa.** La IP dedicada cuesta *"$30 / mo"* y está condicionada por dos cosas a la
vez: superar 3.000 emails al día **y** estar en el plan Scale [F1]. Postmark tenía el
mismo patrón con otros números — $50/mes y 300.000 emails al mes, solo desde Pro.

**Qué hace v0.3.** La Datasheet no tiene bloque de add-ons; el esquema los deriva a
Pricing2YAML, que este TFM no modela por D-001.

**Consecuencia.** Dos proveedores de dos mercados distintos condicionan capacidad por
add-on con la misma forma —precio + umbral de volumen + plan mínimo— y en ninguno de los
dos casos cabe en el canal API.

**Propuesta.** Anotar en Trabajo Futuro como argumento para el mecanismo de vinculación
iPricing↔Datasheet que Ramón dejó abierto. **No resolverlo aquí**: sigue fuera de D-001.

---

## F-08 · El plan como producto cartesiano — recurrencia PARCIAL

**Qué recurre.** Los límites de recursos por plan (dominios verificados). Desde el
2026-09-01 tienen fricción propia, **F-11**, y salen del YAML (decisión Q6 del autor).

**Qué NO recurre.** En Postmark la **superficie de la API dependía del tier**: había
endpoints que solo existían desde Pro. En Resend no está documentado que ningún endpoint
desaparezca por plan; lo que cambia son los topes. Es una diferencia real y conviene no
diluirla: la parte grave de F-08 sigue apoyada en un solo caso.

---

## F-09 · Una datasheet no puede decir qué parte de ella sigue vigente — NUEVA

**Qué pasa.** El propio repositorio de la guía tiene a Resend modelada a fecha
2026-02-24 [F8]. Cinco meses después, dos de sus valores ya no son ciertos: el caudal
pasó de 2 a 10 peticiones por segundo (DISC-02) y la retención dejó de escalar por plan
para quedarse en 30 días en todos (DISC-03). El resto del fichero sigue siendo válido.

**Qué hace v0.3.** Hay un `date` **a nivel de documento**. O el fichero entero está
vigente o el fichero entero está caducado, y ninguna de las dos cosas es verdad: lo que
caduca son datos sueltos, cada uno a su ritmo.

**Consecuencia.** Un consumidor de la datasheet no puede distinguir el dato que se
verificó ayer del que lleva cinco meses sin tocarse. Y el coste de mantener un catálogo
de 12 APIs depende exactamente de eso: sin granularidad, revalidar significa rehacerlo
todo.

**Propuesta.** Fecha de verificación **por afirmación** en `data_provenance` —el formato
autocontenido que este TFM ya usa la lleva de hecho en las observaciones de panel y en las
verificaciones empíricas— y elevarla a convención del esquema. Opcionalmente, una marca de
volatilidad por dimensión: los precios cambian más despacio que los caudales.

**Por qué importa para el TFM.** Es la fricción que justifica la exigencia metodológica
del capítulo 4 —URL, fecha de acceso y cita literal en cada dato— con evidencia obtenida
del propio ecosistema, no con un argumento de principio.

---

## F-10 · Un SaaS con dos productos de precio y dos unidades de consumo — NUEVA

**Qué pasa.** Resend vende dos productos con catálogos independientes: el transaccional,
facturado por emails, y el de marketing, del que la propia página dice *"Marketing plans
are not limited by the number of emails sent — only by the number of contacts"* [F2]. La
misma API, la misma cuenta, dos unidades de consumo distintas y dos listas de precios
paralelas.

**Qué hace v0.3.** La cabecera tiene un `associated_saas` y el documento tiene una lista
de `plans`. Los dos catálogos no caben a la vez: o se modela uno, o los planes de ambos
se mezclan en una lista plana donde `price` deja de ser comparable.

**Consecuencia.** Esta pasada modela **solo el transaccional** (lectura conservadora del
alcance, Q1). La decisión queda registrada, pero significa que la datasheet de Resend
describe una parte del servicio sin poder declarar que lo es.

**Propuesta.** Permitir varios catálogos por servicio, cada uno con su unidad de consumo
dominante; o un campo en la cabecera que acote explícitamente qué producto se modela. Lo
segundo es barato y resolvería la honestidad del documento aunque no la expresividad.

---

## F-11 · Límites de recursos por plan, que no son consumo — RECURRE ✅

**Qué pasa.** Resend acota por plan cuántos dominios verificados puede tener la cuenta:
1 / 10 / 1.000 según el pricing [F2] y **3 en Free según el panel** [F9] (DISC-05). Un
dominio no se consume ni se repone: es un recurso que se tiene o no se tiene, y acota la
capacidad *alcanzable* (sin dominio no se envía a terceros) sin ser una dimensión de
capacidad. Además se vende como add-on: `"Domains - $20 / Mo — Adds 100 domains"`, solo
para planes de pago [F9] (cruza con F-07).

**Dónde recurre.** Postmark: usuarios 4 / 6 / ∞, servers 5 / 10 / ∞, streams 15 / 30 / ∞ y
dominios de firma por plan (`postmark/fricciones.md`, F-08). En el propio Resend, además
de los dominios: `"Webhook endpoints 1 / 5 / 10"` y `"AI credits 5 / 100 / 500"` (pricing,
2026-09-01). Dos APIs: **promovible**.

**Qué hace v0.3.** No tiene dónde declararlos. El repositorio de la guía los fuerza como
cuotas de `records` con periodo mensual (O-04), y esta datasheet lo hacía igual hasta la
pasada 2. Le miente al motor: PRIME4API lo lee como un consumo que se reinicia.

**Consecuencia.** Desde el 2026-09-01 **salen de `capacity`** y viven en el provenance,
con la cifra y la cita. La datasheet pierde el dato como campo; lo conserva como hecho.

**Propuesta.** Un bloque `resources` en el plan, paralelo a `quota` y `rate`, con
entradas `{name, value, unit}` sin periodo. No entra en las curvas de capacidad; sí en la
comparación entre planes y en el cálculo del coste total cuando hay add-on.

---

## F-12 · La recepción consume la cuota de envío — NUEVA

**Qué pasa.** El panel desglosa los dos contadores del plan Free (`"Monthly limit 0 /
3000"`, `"Daily limit 0 / 100"`) en `"Sending"` y `"Receiving"` [F9]: un correo entrante
gasta la misma cuota que uno saliente. El 2026-08-05 ninguna fuente documental lo decía;
el 2026-09-01 la página de límites ya afirma `"Both sent and received emails count towards
these quotas"` y la knowledge base `"based on the number of emails sent and received"`.
Matiz añadido por la página de errores: un entrante por encima de cuota **se recibe pero
no se puede leer** (`email_above_quota`, 403).

**Qué hace v0.3.** Una cuota tiene una `unit` (`emails`) y un periodo; no distingue en
qué operaciones se consume. En la datasheet la cuota cuelga de `/emails` y
`/emails/batch`; el endpoint de recepción (webhook entrante) no está modelado y, si se
modelara, tendría que apuntar a la **misma** cuota, que v0.3 permite pero no obliga a
declarar como compartida.

**Consecuencia.** Las curvas de capacidad de envío sobrestiman lo disponible en cualquier
cuenta que reciba correo. Se anota en provenance; no se altera la datasheet.

**Recurrencia.** Pendiente de verificar en Postmark (tiene *inbound*; no se comprobó si
descuenta del plan) y en las siguientes.

---

## F-13 · El sobrecoste es opcional y no existe en Free — NUEVA

**Qué pasa.** El pay-as-you-go es un interruptor, apagado por defecto y marcado `"Paid
feature"`: `"When enabled, you will continue sending … beyond your quota"` [F9]. En Free
no se puede activar, y la knowledge base lo confirma a fecha 2026-09-01 (`"Overage Not
available"`). Es decir: la cuota de Free es un **tope duro**, y en los planes de
pago el sobrecoste solo existe si el cliente lo enciende; si no, también es tope duro.

**Qué hace v0.3.** `overage_cost` es un atributo del plan: está o no está. No puede decir
«existe pero desactivado por defecto», ni «no disponible en este plan aunque el precio
esté publicado». La datasheet de Resend lleva sobrecoste en Pro y Scale y ninguno en
Free, que es correcto por casualidad: el esquema no puede expresar el matiz.

**Consecuencia.** Para el análisis, un plan con pay-as-you-go apagado se comporta como
uno sin sobrecoste. La comparación de coste entre planes depende de un ajuste que no
está en el pricing.

**Propuesta.** Un atributo `overage_mode: {automatic, opt_in, unavailable}` en el plan.

---

## Familia aparte: características no capacitarias (decisión Q6, 2026-09-01)

No son fricciones de v0.3 porque no son capacidad: son rasgos del dominio que el encargo
(«datasheets, no solo pricing») pide tener en cuenta y que ningún proveedor publica como
cifra contractual. Se registran por API y se tratan en el capítulo 6 como límite de
expresividad distinto de las fricciones.

| Rasgo | Resend [F9] | Postmark | Qué es |
|---|---|---|---|
| Entregabilidad | Medida en *Metrics* (`"Deliverability rate"`, `"Bounce rate"`, `"Complain rate"`) por dominio | — | Resultado observado, no contratado |
| Reputación / warm-up | La IP dedicada `"Resend will provision, warm up, monitor and auto-scale"`; el rate se amplía `"for trusted senders upon request"` [F4] | `"Separate IPs, separate reputation"` en el add-on de IP dedicada | Afecta al techo real de envío sin cifra publicada |
| IP dedicada | Add-on $30/mes, solo Scale o superior | Add-on de pago | Ya cubierto como F-07 en lo que toca al precio |
| Canal SMTP | `smtp.resend.com`, misma clave, misma cuota | — | Canal alternativo; no cambia la capacidad |

## Observaciones sobre el propio repositorio (candidatas a PR)

**O-04 · Dimensiones que no son de consumo, modeladas como cuotas.** En
`resend_v01.yaml` [F8] los días de retención se serializan como
`quota_log_retention_days_free: value: 1, unit: records, period: 1 month`. Ni son
`records`, ni se consumen, ni se reinician al mes. El fichero de esta pasada comete el
mismo forzamiento con los dominios verificados, porque v0.3 no ofrece alternativa. Es
evidencia directa para la familia de «límites de recursos» de F-08.

**O-05 · Los ficheros de `resend-transactional/datasheet/` no validan contra ninguna
versión.** Usan `Assoaciated SaaS` (con la errata en el original), `maxPower`,
`coolingPeriod` y `segmentation` — vocabulario anterior a la sintaxis. Conviven en `main`
con `datasheets/resend/resend_v01.yaml`, que sí sigue el esquema. Preguntar antes de abrir
PR: puede que sean material de trabajo deliberadamente conservado.

**Recordatorio de O-01.** Sigue sin resolverse si `workload` es objeto o lista. Esta
pasada lo serializa como objeto, según el README.

---

## Nota de herramienta (no es fricción del esquema)

El validador de la estación avisaba «Endpoint sin `workload`» para la clave comodín `/*`,
que el README documenta en §3.4.1 como mecanismo de valores por defecto del plan. Es un
falso positivo del validador, no del fichero: se ha corregido para que reconozca el
comodín. Con el arreglo, esta datasheet queda en **0 errores y 1 aviso** —el hueco
deliberado del `window_type` diario— y Postmark se mantiene sin cambios en 0 errores y 5
avisos. Pendiente del visto bueno del autor.

## Observación del sondeo [E1] (2026-09-06), sin fricción nueva

- **F-03 (CRF multiplicativo) matizada:** la API aplica el tope de 50 a la **suma** de `to`,
  `cc` y `bcc` (`"The total number of recipients cannot exceed 50."`), igual que Postmark
  (DISC-01). Es la segunda API donde la documentación declara el tope en un campo y la API
  lo aplica a la petición: refuerza F-03 y la necesidad de que `workload.max` se lea como
  tope por petición, no por campo.
- **Deduplicación no documentada:** 50 direcciones idénticas consumen 1 unidad de cuota.
  v0.3 no distingue «destinatarios» de «destinatarios distintos». Se anota como observación;
  solo sería fricción si otra API hiciera lo contrario o lo documentara.
- **Cabeceras de cuota:** `x-resend-daily-quota` y `x-resend-monthly-quota` exponen el consumo
  en cada respuesta. Es un mecanismo de observabilidad de la cuota que v0.3 no modela
  (tampoco lo hace para el `ratelimit-*`); candidato a familia no capacitaria, no a fricción.
