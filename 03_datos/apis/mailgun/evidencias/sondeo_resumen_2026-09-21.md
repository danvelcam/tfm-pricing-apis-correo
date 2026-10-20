# Sondeos de Mailgun — escalón 3, 2026-09-21

Cuenta propia, plan **Free**, dominio **sandbox**
`sandboxcc7d3466734a4ff18c9247a488599261.mailgun.org`.

Presupuesto total del día: **13 envíos entregados** (1 del sondeo B + 12 del sondeo C),
todos al destinatario que devolvió la guarda de la lista blanca. Son el 0,43 % de los
3.000 emails/mes del plan. Todo lo demás se midió **sin gastar ningún envío**.

---

## A · Lo que se midió sin enviar nada  (`probe_mailgun_a_preflight.sh`)

### A1 · Restricción de la cuenta Free

`POST /v3/$dominio/messages` con `to=sondeo@example.invalid` → **HTTP 403**

```json
{"message":"Domain sandboxcc7d3466734a4ff18c9247a488599261.mailgun.org is not allowed
to send: Free accounts are for test purposes only. Please upgrade or add the address to
your authorized recipients."}
```

El texto nombra la **cuenta Free**, no el sandbox: el tope es del plan.

### A2 · Máximo de destinatarios por petición — **medido**

| n | HTTP | cuerpo |
|---|---|---|
| 100 | 403 | `not allowed to send: Free accounts are for test purposes only…` |
| 500 | 403 | ídem |
| 1000 | 403 | ídem |
| **1001** | **400** | `{"message":"Too many recipients, max is 1000"}` |
| 2000 | 400 | ídem |

**Máximo: 1.000 destinatarios por petición**, literal del proveedor.

Y hay un dato de orden que vale por sí solo: en 1001 el **400 gana al 403**. Mailgun
cuenta los destinatarios *antes* de comprobar si la cuenta puede enviar. Por eso este
número se puede medir desde una cuenta que no tiene permiso para enviar a nadie.

### A3 · Tope de tamaño — **medido**

| adjunto | HTTP | cuerpo |
|---|---|---|
| 10 MB | 403 | restricción de cuenta (el tamaño pasó) |
| 25 MB | 403 | ídem |
| 26 MB | 403 | ídem |
| 30 MB | 403 | ídem |
| **50 MB** | **413** | `{"message":"request size exceeds 52.4MiB limit"}` |

El tope es **de la petición entera, 52,4 MiB**, no del adjunto. Es F-06: el máximo del
`workload` no es un entero de su unidad, está acotado en otra métrica.

### A4 · Cabeceras de caudal en una lectura

`GET /v4/domains?limit=1` → HTTP 200 y **ninguna cabecera de caudal**. Tampoco las trae
el `POST` rechazado con 403: se comprobó expresamente.

---

## B · Un envío, para saber si el escalón 3 existe  (`probe_mailgun_b_envio.sh`)

`POST /v3/$dominio/messages` al destinatario de la lista blanca → **HTTP 200**

```json
{"id":"<20260921174726.3c6e512a1c5dbdaa@sandbox….mailgun.org>","message":"Queued. Thank you."}
```

Y en las cabeceras, lo que ni el GET ni el 403 traen:

```
x-ratelimit-limit: 80000       x-recipient-limit: 2000000
x-ratelimit-remaining: 79999   x-recipient-remaining: 1999999
x-ratelimit-reset: 1790012856315   x-recipient-reset: 1790012856315
```

`GET /v3/$dominio/stats/total` confirma la entrega: `accepted.outgoing: 1`,
`delivered.smtp: 1`, `failed.total: 0`.

**Conclusión operativa:** en Mailgun el caudal **no se puede leer sin gastar un envío**.
La condición 3 de D-046 pide preferir el rechazo «si la cifra se puede sacar» así; aquí
está comprobado que no se puede.

---

## C · La ventana del caudal  (`probe_mailgun_c_ventana.sh`, 12 envíos)

| petición | hora UTC | remaining / limit | reset |
|---|---|---|---|
| T1-1 | 17:48:37.879 | 79999 / 80000 | 1790012927731 |
| T1-2 | 17:48:38.484 | 79998 / 80000 | 1790012927731 |
| T1-3 | 17:48:39.086 | 79997 / 80000 | 1790012927731 |
| T1-4 | 17:48:39.690 | 79996 / 80000 | 1790012927731 |
| T1-5 | 17:48:40.271 | 79995 / 80000 | 1790012927731 |
| *pausa de 15 s* | | | |
| T2-1 | 17:48:55.836 | **79999** / 80000 | **1790012945706** |
| T3-1 | 17:48:56.431 | 79998 / 80000 | 1790012945706 |
| T3-2 | 17:48:57.052 | 79997 / 80000 | 1790012945706 |
| T3-3 | 17:48:57.639 | 79996 / 80000 | 1790012945706 |
| T3-4 | 17:48:58.224 | 79995 / 80000 | 1790012945706 |
| T3-5 | 17:48:59.054 | 79994 / 80000 | 1790012945706 |
| T3-6 | 17:48:59.609 | 79993 / 80000 | 1790012945706 |

`x-recipient-remaining` bajó en paralelo, de 1999999 a 1999993, con el **mismo reset**.

### Lo que la tabla demuestra

1. **El `reset` no se mueve dentro de la ventana.** Once peticiones repartidas en dos
   tandas comparten exactamente dos valores de reset, uno por tanda. No es una ventana
   rodante: en una rodante cada petición desplazaría el horizonte.
2. **La ventana dura ~9,86 s** y se ancla en la **primera petición** que la abre:
   17:48:37.879 → 17:48:47.731 (9,852 s) y 17:48:55.836 → 17:49:05.706 (9,870 s). El
   sondeo B, aislado, dio 10,315 s.
3. **Al superarla, el contador vuelve entero al tope** (79999 tras la primera petición de
   la ventana nueva), no decae gradualmente.
4. **Son dos contadores independientes con una sola ventana**: peticiones (80.000) y
   destinatarios (2.000.000), cada uno con su `limit`/`remaining` propio y un `reset`
   compartido.

### La fricción que sale de aquí

El `window_type` de ACM2YAML v0.3 admite tres valores: `rolling`,
`fixed_utc_midnight` y `fixed_billing_cycle`. **Esta ventana no es ninguno de los tres.**
Es fija en duración pero su origen lo fija el uso: nace con la primera petición y muere
~10 s después. Llamarla `rolling` sería falso —el reset no se desplaza— y los otros dos
anclan en un instante del calendario que aquí no interviene.

Se anota como fricción nueva en `fricciones.md`. Emparenta con F-01 en el diagnóstico
—v0.3 no puede decir la verdad sobre un límite que sí existe— pero es un defecto
distinto: F-01 es un rate **sin valor**, y esto es un rate **con valor y sin ventana
expresable**.

---

## D · Caudal contra un endpoint de lectura  (`probe_mailgun_d_caudal_lectura.sh`, 0 envíos)

Rampa de seis tandas contra `GET /v4/domains?limit=1`, 1.570 peticiones en total.

| tanda nominal | peticiones | segundos | tasa conseguida | 2xx | 429 |
|---|---|---|---|---|---|
| 10/s | 20 | 0,75 | 26,7 /s | 20 | 0 |
| 25/s | 50 | 0,75 | 66,7 /s | 50 | 0 |
| 50/s | 100 | 0,83 | 120,5 /s | 100 | 0 |
| 100/s | 200 | 1,00 | 200,0 /s | 200 | 0 |
| 200/s | 400 | 1,32 | 303,0 /s | 400 | 0 |
| 400/s | 800 | 4,30 | 186,0 /s | 800 | 0 |

**Resultado negativo, y se declara como tal.** No se alcanzó ningún 429. El techo de
303 peticiones por segundo es del **cliente**, no de la API: una sola máquina con TLS y
`xargs` no llega a las 1.500 que el proveedor publica. Subir de 200 a 400 procesos
concurrentes *bajó* la tasa conseguida, que es la firma de la saturación local.

Esto **no confirma ni refuta** el literal «1,500 API requests per second per client IP».
Lo que sí deja escrito es que el umbral publicado **no es alcanzable desde el banco de
pruebas de este TFM**, y eso es un dato sobre el método, no sobre Mailgun.

## E · Tres topes más, todos por rechazo y sin gastar envío

### E1 · Paginación de eventos: **300**

```
GET /v3/$dominio/events?limit=300  → HTTP 200
GET /v3/$dominio/events?limit=301  → HTTP 400
{"message":"Invalid parameter: limit=['301'], Number out of range [1, 300]"}
```

El rango completo viene en el propio error: `[1, 300]`. Es **F-05**, la capacidad de
consulta que v0.3 deja fuera de la serialización. Segunda API donde aparece.

### E2 · Parámetros de opciones: **16 kB en total**

```
v: de 16 KB  → HTTP 403 (restricción de cuenta: el tamaño pasó)
v: de 17 KB  → HTTP 400
{"message":"Send options (parameters starting with o:, h:, or v:) are limited to 16 kB total"}
```

El tope es **agregado sobre tres familias de parámetros** —`o:`, `h:` y `v:`— y está en
kilobytes. Ninguna de las dos cosas cabe en v0.3: ni un límite que suma familias
distintas, ni uno cuya unidad es el peso.

### E3 · Bisección del tope de petición: entre 48 MB y 52 MB

| adjunto | HTTP |
|---|---|
| 35 MB | 403 (pasó el tamaño) |
| 40 MB | 403 (pasó el tamaño) |
| 45 MB | 403 (pasó el tamaño) |
| **48 MB** | **403 (pasó el tamaño)** |
| **52 MB** | **413** `request size exceeds 52.4MiB limit` |

Un adjunto de **48 MB atraviesa la comprobación de tamaño**. El máximo publicado por el
proveedor es de 25 MB por mensaje. La distancia entre lo declarado y lo aplicado es de
23 MB, casi el doble del tope publicado: **F-04 no es una interpretación, es una medida**.

## Contadores al cerrar el día

```
GET /v3/$dominio/stats/total?duration=1d
accepted  {incoming: 0, outgoing: 13, total: 13}
delivered {smtp: 12, http: 0, optimized: 0, total: 12}
```

Trece aceptados: **1 del sondeo B y 12 del sondeo C**, que es exactamente el presupuesto
declarado de cada uno. Todo lo demás —los rechazos por destinatario, por número, por
tamaño y por opciones, y las 1.570 lecturas de la rampa— no aparece porque no gastó nada.
