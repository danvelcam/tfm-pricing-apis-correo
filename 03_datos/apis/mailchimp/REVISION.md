# Revisión — Mailchimp Transactional (Mandrill) · pasada 1 (2026-09-21)

**Construido:** 2026-09-21 · documentación por siete frentes, panel con cuenta propia
([F18]) y escalón 3 el mismo día ([E1] y el sondeo A) · **Validado contra v0.3:** sí, con
los huecos deliberados de `fricciones.md`.

Desde **D-047** lo que el libro de reglas no cubre ya no se te pregunta: lo resuelve el
consejo y el veredicto se escribe en `CRITERIOS.md`. Esta pasada lo hizo dos veces y de ahí
salieron **B12** y **B13**. Así que aquí abajo solo hay **carril rojo**: gasto, alcance,
estado de tu cuenta y lo que llega a los tutores.

---

## 🔴 Lo que no puedo decidir yo

### R1 · El sondeo dejó cola en tu cuenta de Mandrill

Los contadores del proveedor al cerrar el sondeo dan `sent: 0`, `hard_bounces: 0` y
`complaints: 0`: **no salió ni un correo**. Lo que sí quedó fueron unos **7.600
destinatarios en cola**, que drenan hacia rechazos porque la cuenta no tiene dominio
verificado. La guarda del script paró en la primera tanda de 100, como debía; las tandas
de M4 y M5 se lanzaron después a mano para cerrar el barrido, y ahí se acumularon.

Fue un fallo del sondeo, no un resultado buscado, y está escrito como tal en
`evidencias/sondeo_a_preflight_2026-09-21.md`. Se dejó de sondear Mandrill al detectarlo.
Lo que no puedo decidir yo: si esa cola te importa para la reputación de la cuenta —está
en `Unknown` y no ha enviado nada— o si la damos por inocua y seguimos.

`[ ]` →

### R2 · Toda la capacidad de la cuenta de pago cuesta dinero

Mailchimp Transactional se vende **solo como complemento de una cuenta Mailchimp de pago**:
*"El correo electrónico transaccional está disponible como complemento de los planes
Standard y Premium de Mailchimp, o del plan mensual heredado"*, y *"El plan Essentials no es
elegible"* [F3]. La cuenta que tenemos es la de prueba.

Lo que queda sin cifra por esto, y no por falta de búsqueda:

- la **cuota horaria de una cuenta de pago**, que el proveedor declara variable por
  reputación y volumen histórico y no cifra en ninguna página;
- si el precio del tramo alcanzado es **marginal o plano** sobre todos los bloques del mes;
- si **N destinatarios en el array `to` gastan N unidades del bloque o una por llamada**.

Las tres son decisión de gasto. La opción conservadora es cerrar Mailchimp con la cuenta de
prueba, los ámbares declarados y estas tres en `not_found`, que es como está ahora.

`[ ]` →

### R3 · Una API del catálogo que no se puede usar suelta

Es la primera del catálogo que no es un producto independiente: sin una suscripción
Mailchimp Standard o Premium de pago por debajo, el transaccional no existe. El coste de
esa cuenta base no es capacidad y no se modela, y así está anotado en el provenance.

La pregunta es de **selección**, no de modelado: si el catálogo quiere una fila cuyo precio
comparable esté incompleto por diseño, o si conviene decirlo explícitamente en el capítulo
de selección para que el tribunal no lo lea como un descuido.

`[ ]` →

### R4 · Tres fricciones nuevas y dos reglas nuevas en una sola API

Salen **F-32** (precio unitario degresivo sin planes que lo sostengan), **F-33** (franquicia
que no caduca ni se renueva) y **F-34** (dos topes de tamaño en magnitudes distintas). Las
tres están en 1/7 y no promueven todavía. Y el consejo escribió **B12** y **B13** en
`CRITERIOS.md` el mismo día.

Lo que sí mueve el recuento: **F-28 cruza el umbral de D-008** (2/7, lista de IP
autorizadas), F-06 y F-07 llegan a **7/7**, y F-02 **no** recurre —es la segunda API tras
Brevo que rompe su enunciado por la misma mitad, la del sobrecoste—.

Va aquí porque es material del capítulo 6 y porque, si esto se cuenta a los tutores, la
frase que importa es que la escalera de Mailchimp abrió clase propia en vez de estirar
F-02. Tú decides si entra en la próxima comunicación o espera al cierre del dominio.

`[ ]` →

---

## 🟡 Ámbares que alguien puede cerrar sin gastar

Ninguno necesita tu decisión: es trabajo pendiente con la vía ya escrita.

- **Las dos citas de [F17]** (índice de release notes) se agregaron por resumen y se quedan
  en ámbar hasta releer cada nota por separado. Ninguna cambia una cifra.
- **`window_type: fixed_billing_cycle` del bloque de 25.000** es inferencia: lo único que
  dice la fuente es que el saldo no se arrastra de un mes a otro. Ningún día de reinicio
  publicado.

---

## 🔴 Lo que no existe y habría que medir

- **El tope de destinatarios por llamada no tiene cota superior alcanzada.** 5.000 se
  aceptaron en una sola llamada, sin rechazo. Subir más no es gratis: por encima de diez
  destinatarios la API encola en vez de rechazar (**O-22**).
- **El tamaño máximo no es medible por rechazo en esta API.** Cualquier adjunto difiere la
  evaluación a un proceso asíncrono; se llegó a 30 MB de adjunto y 40 MB de cuerpo JSON sin
  que ninguna respuesta devolviera umbral. El literal de <10MB por llamada [F4] se queda en
  🟢 —un sondeo no baja un literal oficial (D6)— y la medición queda escrita contra ese
  campo en el provenance.
- **DISC-02, el ancla de reinicio del modo de pruebas.** La misma frase da dos mecanismos
  incompatibles, medianoche y 24 horas desde que se agota. Cerrarlo exige agotar 10.000
  mensajes de prueba en un horario lejos de medianoche y esperar al reinicio: caro en tiempo,
  no ejecutado.
- **Cabeceras de rate limit.** No aparecen en ninguna página oficial revisada, y tampoco en
  las respuestas del sondeo. El único caudal con cifra de toda la API es el de
  `/messages/search`, 20 por minuto.

## Verificación por uso (2026-09-24)

`verificar_prime4api.py` da **8 OK / 10 ERR**, y los diez fallos son el mismo error de
conversión de un valor nulo: `TypeError: float() argument must be a string or a real number,
not 'NoneType'`. Es el defecto de P-04 del Capítulo 6. PRIME4API en `8e6011c` (la caché no se
ha actualizado desde el clon). Salida en `evidencias/verificar_prime4api_2026-09-24.txt`. Es la
primera ejecución archivada de la herramienta sobre esta Datasheet.

## Informe del verificador adversarial (D-013) — 2026-10-31

Un agente independiente, con acceso solo al `datasheet.yaml`, leyó cada URL dos veces, sin y con
JavaScript, y fechó con Wayback lo que no encontró.

- **Resultado: 35 entradas, 17 coinciden.** No se refutó ningún valor modelado ni cambió ningún
  semáforo: **11 🟢 · 2 🟡 · 4 🔴**.
- **Fuente reapuntada (aplicado).** El único caudal con cifra, 20 búsquedas por minuto, perdió sus
  dos URL con la migración de octubre. Sigue literal en el índice de notas de versión ([F17]),
  entrada `"Apr 10, 2023"`, y la línea lleva su relectura fechada (E3).
- **Errores del dato sin efecto en valores (aplicados).**
  - Por encima de 161 bloques sí hay precio, 10 USD por bloque.
  - El umbral asíncrono (más de 10 destinatarios) estaba publicado.
  - La retención de la cuenta de pago (30 días de contenido) estaba publicada.
  - La segunda fuente del 5 % no lo dice.
  - La cita inglesa de los términos era una retrotraducción.
  - Las tres entradas de `not_found` que se refutan se conservan corregidas.
- **Cambio del proveedor (aplicado).** Desde octubre sirve la especificación OpenAPI en su dominio.
  Se anota en DISC-01, que estaba disuelta y sigue igual.
- **Sin aplicar, fuera de la lista aprobada:** líneas 157, 176, 184, 190 y 193, detalles de cita
  recogidos en el informe.

Informe íntegro: `evidencias/verificador_adversarial_2026-10-31.md`. Volcados:
`evidencias/paginas/2026-10-31/`.
