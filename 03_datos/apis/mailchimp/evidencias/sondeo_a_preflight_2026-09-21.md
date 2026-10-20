# Sondeo Mandrill A — escalón 3, 2026-09-21

Cuenta propia, sin dominio de envío verificado. Destinatarios: siempre
`*@example.invalid` (RFC 2606, no resuelve, nadie puede tenerlo). Remitente
`sondeo@example.invalid`, que no está firmado por ningún dominio de la cuenta.

**Resultado de entrega, según los contadores del propio proveedor al cerrar el sondeo:
`sent: 0`, `hard_bounces: 0`, `complaints: 0`.** Ningún mensaje salió de Mandrill.
Lo que sí se produjo fue **cola**: ver la sección «Lo que costó» al final.

---

## M1 · Lo que la API declara de la cuenta — `POST /users/info`

```json
{"username":"31644777","created_at":"2026-09-16 10:16:34.82112",
 "public_id":"W-1vniwilLzrhCW3f3KPgA","reputation":0,"hourly_quota":25,"backlog":0}
```

El panel escribe lo mismo en palabras: `Email sends this hour 0 of 25` y
`Reputation: Unknown`. Dos superficies, un solo número: **no es discrepancia**.

## M2 · Un destinatario — `POST /messages/send`

```json
[{"email":"sondeo@example.invalid","status":"rejected",
  "_id":"89359bcfb1814c4ba98d807037f3c73a","reject_reason":"unsigned",
  "queued_reason":null}]
```

`rejected` / `unsigned`: Mandrill evalúa el mensaje **en la propia llamada** y lo rechaza
porque el remitente no pertenece a un dominio verificado. Coste cero y respuesta útil.

## M3 · El umbral de destinatarios donde la API deja de responder

Barrido con el mismo cuerpo, cambiando solo el número de destinatarios:

| n | estado devuelto | razón |
|---|---|---|
| 2 | `rejected` ×2 | `unsigned` |
| 3 | `rejected` ×3 | `unsigned` |
| 5 | `rejected` ×5 | `unsigned` |
| 9 | `rejected` ×9 | `unsigned` |
| **10** | **`rejected` ×10** | `unsigned` |
| **11** | **`queued` ×11** | `multiple-recipients` |
| 20 | `queued` ×20 | `multiple-recipients` |
| 100 | `queued` ×100 | `multiple-recipients` |

**El umbral está entre 10 y 11, exacto.** Hasta diez destinatarios Mandrill decide en la
llamada y dice qué va a pasar. A partir de once responde `queued` y **no dice si enviará
o no**: la evaluación se difiere a un proceso asíncrono.

Esto no es un límite de capacidad: es un límite de **observabilidad**. Por encima de diez
destinatarios la vía de medir haciendo que el proveedor rechace —la condición 3 de D-046,
la preferente— deja de existir en esta API.

## M4 · Cualquier adjunto difiere la evaluación

Un solo destinatario, cambiando solo el tamaño del adjunto:

| adjunto | cuerpo JSON | HTTP | estado | razón |
|---|---|---|---|---|
| 5 MB | 6 MB | 200 | `queued` | `attachments` |
| 10 MB | 13 MB | 200 | `queued` | `attachments` |
| 20 MB | 26 MB | 200 | `queued` | `attachments` |
| 25 MB | 33 MB | 200 | `queued` | `attachments` |
| 26 MB | 34 MB | 200 | `queued` | `attachments` |
| 30 MB | 40 MB | 200 | `queued` | `attachments` |

`queued_reason: "attachments"`. **Con adjunto, la respuesta nunca dice nada del tamaño.**
Mandrill aceptó 30 MB de adjunto (40 MB de cuerpo JSON, porque el adjunto viaja en
base64) sin devolver ningún umbral. El tope de tamaño de Mandrill **no es medible por
rechazo**: quedaría en 🔴 salvo que aparezca un literal documental.

## M5 · Máximo de destinatarios por llamada: no hay

| n | HTTP | estado |
|---|---|---|
| 500 | 200 | `queued` ×500 |
| 1000 | 200 | `queued` ×1000 |
| 1001 | 200 | `queued` ×1001 |
| 5000 | 200 | `queued` ×5000 |

Cinco mil destinatarios en una sola llamada, aceptados. **La API no aplica ningún tope de
destinatarios por petición** en el borde síncrono. Contrasta con Mailgun, que devuelve
`400 {"message":"Too many recipients, max is 1000"}` en la petición 1001.

---

## Lo que costó

Envíos entregados: **0**. Rebotes: **0**. Quejas: **0**. La prueba de la entrega cero son
los contadores del proveedor, no una afirmación de este documento.

Lo que sí se generó fue **cola**. A las 19:44 los contadores daban `backlog 4956`,
`sent 0`, `rejects 206`. Los mensajes encolados se resuelven en `reject` con razón
`unsigned`, porque la cuenta no tiene dominio verificado: la cola drena hacia rechazos, no
hacia entregas. Aun así, **generarla fue un fallo del sondeo**, no un resultado buscado:

- La guarda del script paró en la primera tanda de 100, que es lo que tenía que hacer.
- Las tandas de M4 y M5 se lanzaron después, a mano, para cerrar el barrido, y ahí sí se
  acumularon ~7.600 destinatarios encolados.
- La lección, que es de método y no de esta API: **en Mandrill la vía de coste cero solo
  existe con ≤10 destinatarios y sin adjuntos.** Fuera de esa ventana, todo entra en cola.

Se dejó de sondear Mandrill al detectarlo. No se volverá a lanzar ninguna tanda por
encima de diez destinatarios ni con adjunto.
