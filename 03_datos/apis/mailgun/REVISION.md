# Revisión — Mailgun · construida y cerrada el 2026-09-21

**Estado:** construida, validada contra v0.3 y con el escalón 3 ejecutado el mismo día.
**Fuentes:** 24 (F1–F23 documentales · F24 panel con cuenta propia), todas con cita literal
y fecha. **Mediciones:** quince pruebas contra el dominio sandbox. Trece gastaron un envío
real cada una, todas a `persona-3@example.invalid`, que es la única dirección autorizada en el
sandbox y está en la lista blanca de `docs/08-mandato.md`; el contador del proveedor las
confirma entregadas, `accepted.outgoing 13` y `delivered.smtp 13`. Las demás no entregaron
nada, porque la cuenta Free rechaza a cualquier otro destinatario.

Desde **D-047** lo que el libro de reglas no cubre no sube al autor: lo resuelve el consejo. De
esta API salieron seis veredictos y seis reglas, ya escritas en `CRITERIOS.md`: **E12** (el
periodo de un contador no es su unidad), **D14** (un lado disuelto por D12 devuelve el campo a
D1), **E13** (rendir con navegador la página bloqueada cuando es la única fuente del dominio
para una cifra, aplicada a [F15]), **B14** (el tope que levanta el titular no es `capacity`),
**B11** (los tramos de un selector de volumen son F-02, no planes) y **B15** (la gobernanza
entre productos hermanos no se presume). Lo que queda aquí es **carril rojo** y lo que está
medido a medias.

**Segunda pasada, mismo día ([E1]).** Cerró tres frentes de esta revisión: DISC-02
(plantillas en Free y en Basic, midiendo), F-21 (el cupo tras un rechazo, medida y
negativa) y la profundidad de la paginación de eventos, con resultado negativo declarado
por falta de volumen. Las tres mediciones están abajo, donde vivían como pendientes.

---

## 🔴 Carril rojo — lo que solo puede decidir el autor

### R1 · La cuenta Free no puede enviar a nadie, y eso limita lo que se puede medir

La cuenta propia está en el dominio sandbox, y cualquier envío a una dirección no autorizada
devuelve 403 con *"Free accounts are for test purposes only. Please upgrade or add the
address to your authorized recipients."* Es lo que hace los sondeos gratuitos y lo que deja
cuatro cosas sin medir: el consumo real de cuota por destinatario, si la cola de reintento
descuenta, el reprecio de la escalera al cambiar de plan y el sobrecoste aplicado.

**Lo que hay que decidir:** si se autorizan en el panel las tres direcciones de la lista
blanca de `docs/08-mandato.md` para hacer envíos reales de bajo volumen, o si Mailgun se
cierra con estas cuatro cotas sin medir. Es alta de configuración de cuenta y envío real, así
que es tuyo. Las otras ocho APIs se cerraron con envío real solo donde la cuenta lo permitía
sin pagar.

`[ ]` →

### R2 · Ningún plan de pago es observable sin contratarlo

El selector de volumen publica la escalera entera, pero el reprecio al cambiar de tier, el
sobrecoste aplicado y la ventana de facturación real solo se ven con una cuenta de pago. El
plan Basic cuesta 15 $/mes. Ninguna otra API del catálogo se contrató, y la coherencia del
método dice que esta tampoco.

**Recomendación:** no contratar, y que los tres `window_type: fixed_billing_cycle` de los
planes de pago se queden en ámbar, que es lo que ya hacen. Lo anoto aquí porque es
facturación y no lo decido yo.

`[ ]` →

### R3 · Mailgun vende dos productos más bajo la misma cuenta, y quedan fuera

El panel muestra *"Mailgun Optimize"* y *"Mailgun Inspect"*, los dos en *"No subscription"*,
con espacio propio en la aplicación y documentación propia. Optimize publica su propio
caudal, *"API calls are subject to a rate limit of 500 requests every 10 seconds"* [F16], y
ninguna fuente dice si comparte contador o credencial con el producto transaccional.

Quedan fuera por **A1**, que es la regla de alcance: el catálogo son APIs de correo
transaccional. La anoto porque toca alcance y el alcance es tuyo. Si entrasen, Mailgun
dejaría de ser una API y pasaría a ser tres, y el mismo criterio abriría Brevo y Mailchimp.

`[ ]` →

---

## 🟡 Ámbares que alguien puede comprobar sin decidir nada

### A1 · Los dos topes del plan Free, 100 al día y 3.000 al mes

La página pública dice *"100 emails/day included"* [F1] y el panel de la cuenta dice *"3000
emails per month"* [F24]. Ninguna fuente los concilia y no cuadran: cien al día son tres mil
al mes solo si el mes tiene treinta días. El bullet del plan Basic, *"No daily email limit"*,
empuja hacia la lectura de dos topes concurrentes.

**Cómo se cierra sin decidir:** una consulta al soporte del proveedor, o un sondeo de envío
real que agote el tope diario y mire si el mensual sigue entero. Lo segundo necesita R1.
Mientras tanto las dos cifras están declaradas por separado, cada una con su fuente, y
ninguna sube a verde. Es la F-38. *(2026-10-18: la diaria sube a 🟢 por D17, porque es
literal de la página de precios; la mensual sigue en 🟡 y DISC-03 queda acotada, no
cerrada.)*

### A2 · El caudal del envío no alcanzó el rechazo

El sondeo confirmó el contador, la ventana y la reposición: 80.000 peticiones, ventana de
9,85 a 9,87 segundos anclada en la primera petición, y el contador vuelve entero al superarla.
Nadie forzó el 429, porque forzarlo son 80.000 peticiones en diez segundos y eso es una
campaña de carga, no un sondeo.

**Queda en ámbar por D6**, igual que el rate de Postmark: la cabecera prueba que el contador
existe y no prueba que el rechazo llegue ahí. Cerrarlo exige una campaña de carga, que está
fuera del encargo.

### A3 · Las 1.500 peticiones por segundo son de una IP, no de la cuenta

El literal está verificado con navegador desde hoy [F15], así que la reserva de método
desapareció. El ámbar que queda es de otra clase: el proveedor acota *"per client IP"* y el
esquema no tiene dimensión de ámbito, así que la cifra del fichero es el techo de una salida
de red y no el de la cuenta. Y [F2] dice que las ventanas varían por API, que es difícil de
conciliar con un número único.

**DISC-01 sigue abierta por ese flanco.** El sondeo de lectura no la desempata: alcanzó 303
peticiones por segundo y el techo era del cliente, no de la API. Cerrarla exige un cliente
capaz de saturar 1.500 por segundo desde una IP.

### A4 · Los tres `window_type: fixed_billing_cycle` de los planes de pago

Inferidos del *"Autopay on the 1st of each month"* del panel, que habla del cobro y no del
contador. En el plan Free el campo se dejó vacío porque ni eso hay. Verificable con una
cuenta de pago, es decir, con R2.

---

## 🔴 Lo que no existe y habría que medir

### El caudal por cuenta

Ninguna fuente publica un umbral por cuenta ni por plan. Lo que hay es el mecanismo descrito
sin cifra [F2], el reconocimiento sin cifra [F12] y una cifra de otro ámbito [F15]. Es la
F-01, y con Mailgun son cuatro de las ocho APIs del catálogo en pleno, y las otras cuatro
en variante.

### El consumo de cuota por destinatario

La descripción del fichero afirma que cada destinatario consume una unidad de la cuota, y esa
frase es inferencia, no literal: ninguna fuente de Mailgun lo dice y el sondeo no pudo
comprobarlo porque no llegó a enviar. Depende de R1.

### El tope de profundidad de la paginación de eventos

El tope por petición está medido —300, con el rango en el propio error. La otra mitad de la
RPR de Postmark, el tope de profundidad acumulada, se intentó medir en la segunda pasada
([E1]) paginando con `paging.next` hasta que dejara de devolver: con solo 42 eventos, la
retención de un día del plan Free, la segunda página ya volvió con 0 items y el enlace
`next` todavía presente. **Resultado negativo y declarado como tal:** falta volumen para
tropezar con el tope, no falta el intento. Sigue sin medirse, y solo se puede acotar con más
tráfico acumulado en la cuenta.

---

## Resumen de la pasada

| | |
|---|---|
| Fuentes | 24 · F1–F23 documentales, F24 panel con cuenta propia |
| Endpoints modelados | 3 por plan: `/v3/{domain_name}/messages`, `/v3/{domain_name}/events`, `/v4/domains` |
| Mediciones | 15, todas sobre el dominio sandbox · 13 envíos reales gastados, los trece a la dirección autorizada de la lista blanca; el resto sin entrega |
| Fricciones | 15 recurrentes y 4 nuevas: F-35 tope fraccionario · F-36 dos contadores en una ventana · F-37 tope que fija el cliente · F-38 dos cuotas concurrentes |
| Reglas nuevas | 6, de los seis consejos MG-1 a MG-6 del 2026-09-21: E12, D14, E13, B14, B11 y B15 |
| Discrepancias | DISC-01 abierta (caudal: ámbito y ventana) · DISC-02 cerrada midiendo el 2026-09-21 (plantillas por plan) |
| Carril rojo | 3 · autorizar destinatarios, contratar plan de pago, alcance de Optimize e Inspect |
| Conformidad con PRIME4API (`verificar_prime4api.py`, 2026-09-24) | **20 OK / 1 ERR**. El único fallo es `curve.accumulated`, `TypeError: unsupported operand type(s) for /: 'int' and 'TimeDuration'`, el mismo mensaje de DV-04 en MailerSend y SES. PRIME4API en `8e6011c` (la caché no se ha actualizado desde el clon). Salida en `evidencias/verificar_prime4api_2026-09-24.txt`. La ejecución del 2026-09-23 (BITACORA 240) dio el mismo 20/1 y no se archivó |
