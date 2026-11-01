# Revisión — SendGrid · tamaño 30 MiB verificado, [E2] (2026-09-07, noche)

- el autor preguntó qué ámbar se cierran con las cuentas gratis; el 30 MB era el primero.
  Sandbox mode, coste 0. Bisección por bytes del JSON: 31.457.280 (30 MiB exactos) → 200;
  31.457.281 → 413 de nginx. Detalle en `fuentes.md` [E2].
- Cambios: `max: 30` (MBs) 🟡 → 🟢 en los cuatro planes; descripción; una línea de
  `data_provenance`. Q6 (¿`<` o `≤`?) se cierra por medida: es `≤ 30 MiB`. Semáforo del
  fichero: 29 🟢 / 1 🟡 / 0 🔴 (queda Premier `fixed_billing_cycle`).
- SG-62 actualizado y SG-116 nuevo en `hechos_sendgrid.md`. Cap. 5 §5.2.3 ya no dice «queda
  en ámbar».

---

# Revisión — SendGrid · PASADA DOCUMENTAL 2 (2026-09-06, noche): los ámbar

El autor preguntó cómo subir los ámbar a verde. Se hizo la búsqueda documental (escalón 1)
antes de medir nada. Resultado, **aplicado y no validado**:

| Campo | Antes | Después | Fuente |
|---|---|---|---|
| `window_type` del límite diario de la prueba | 🟡 | 🟢 `fixed_utc_midnight`: `"please wait until the next day (UTC time) for the credit count to reset"` | [F18] |
| `window_type: fixed_billing_cycle` Essentials y Pro | 🟡 | 🟢: `"sending limit for the current billing period"` [F19] + `"throughout the month"` [F18] + `"within a given billing period"` [F1] | [F18][F19] |
| `window_type: fixed_billing_cycle` Premier | 🟡 | 🟡 se queda: condiciones a medida, ninguna fuente lo dice para Premier | — |
| `max: 30` MBs (×4) | 🟡 | 🟡 se queda: es el esquema, no el dato. Lo cierra un criterio tuyo (Q6), no una fuente | — |

**Lo que la búsqueda destapó de propina — F-16, nueva:** el sobrecoste **tiene tope**.
Desde el 2026-03-26, Essentials y Pro no pueden pasar de **10 × el volumen contratado**
(Essentials 50K → 500.000 al mes); las cuentas de reseller, de 2,5 ×. Está en un artículo
de resolución de errores, no en el pricing. v0.3 no puede expresarlo: `overage_cost` es un
precio unitario abierto. Hay que revisar si Postmark y Resend tienen tope antes de darla
por única.

Validación: **12 ok / 0 avisos / 0 errores** · 140 citas OK · Semáforo **25 🟢 · 5 🟡 · 0 🔴**
(recontado 2026-09-07 con `grep -c '# 🟢'` sobre el YAML, sin la línea de leyenda; antes decía 29 🟢)
(los cinco ámbar: Premier y el 30 MB ×4). Dos decisiones si quieres apurar: Q6 (el 30 MB
en verde por criterio) y si aceptas los tres verdes de ventana con las citas de arriba.

---

# Revisión — SendGrid · CIERRE (2026-09-06, noche)

El autor cerró las tres preguntas por chat (D-017: sin estación, lista de no-verdes en el chat):

| | Decisión del autor (chat, 2026-09-06) | Aplicado |
|---|---|---|
| Q1 | **El sobrecoste del panel, en verde.** Regla nueva D5 en `CRITERIOS.md` | `quota_email_monthly_essentials.overage_cost.price: 0.00133` 🟢; DISC-01 resuelta; público en el provenance. **Revertido el 2026-10-18 por D17 (D-068):** `0.0013` 🟢, el de la página; el panel queda como incoherencia del pricing |
| Q2 | **`period: 1 MONTH` + F-14.** La vigencia no cabe en v0.3 | Sin cambios; F-14 se queda como fricción nueva |
| Q3 | **Tarea pendiente para otra pasada.** | Anotado en `ESTADO.md` y en el proyecto como pasada 2 ([F20]: contraste con el `sendgrid_v03.yaml` del repositorio y con el anexo del TFM de Gavira) |

Q4–Q6 se quedan como están aplicadas (no las tocó). Validación final: **12 ok / 0 avisos /
0 errores** · 133 citas OK · PRIME4API 8 OK / 13 ERR (DV-03; 20/20 sin Premier).
Semáforo: ~~🟢 27 · 🟡 6 · 🔴 0~~ (recontado 2026-09-07: el YAML vigente tiene 25 🟢 · 5 🟡 · 0 🔴;
las cifras de esta pasada y de la de [E1] salieron de otro criterio de conteo que no se reconstruye).
Los ámbar de aquel momento eran deliberados y no se cerraban con nada
barato: hora y zona de la ventana diaria, los tres `fixed_billing_cycle` inferidos del
«billing period», y el 30 MB estricto (×4 planes cuentan como uno).

**SendGrid queda cerrada.** Pendiente para otra pasada: Q3 (contraste con el modelado
previo). La cuenta caduca el 2026-11-05.

---

# Revisión — SendGrid · SONDEO [E1] (2026-09-06, 20:46 UTC)

El autor ejecutó `probe_sendgrid_sandbox.sh BCD` con la clave de la cuenta Free Trial. Todo en
sandbox: **coste cero** (`"used": 0` después). Resultado:

| Pregunta | Antes | Después | Evidencia |
|---|---|---|---|
| Tope de destinatarios por petición | 🟢 documental (`max: 1000`) | 🟢 **verificado**: 1.000 pasa; 1.001 falla en un sobre, en dos sobres (500+501) y en `to`+`cc` (500+501): `"There is a limit of 1000 total recipients (to + cc + bcc) per mail/send request."` | [E1] B1–B5 |
| Tope de sobres | 🟢 documental | 🟢 verificado: 1.001 sobres → `"The personalization block is limited to 1000 personalizations per API request."` | [E1] B6 |
| Ventana del límite diario | 🔴 vacío | 🟡 `fixed_utc_midnight`: la API dice `"reset_frequency": "daily"` con fechas sin hora; no es *rolling*. Hora y zona siguen sin publicarse, y las fechas que devuelve están desactualizadas | [E1] D1 |
| Rate de los endpoints de lectura (F-01) | 🔴 no publicado | **medido**: 600/min (ventana fija de un minuto) en 6 endpoints; 6 por ventana en `/v3/messages`. En el provenance, no en `max_power` (no son endpoints modelados) | [E1] C1–C5, D1–D2 |
| Caudal de `/v3/mail/send` (10.000 rps) | 🟢 documental | 🟢 documental, **no observable**: la respuesta no trae cabeceras X-RateLimit | [E1] B0–B6 |
| Tope duro de la prueba (F-13) | documental | confirmado por la API: `"is_hard_limit": true` | [E1] D1 |

Dos hallazgos que no estaban previstos: `x-ratelimit-reset` cambia de unidad según el
endpoint (**O-07**), y `/v3/messages` responde `200` a la cuenta de prueba pese a [F15]
(**candidato a F-04**). Validación tras los cambios: **12 ok / 0 avisos / 0 errores**;
citas 133 OK; PRIME4API sin cambios (DV-03).

~~**Lo que queda para el autor:** Q1, Q2, Q3.~~ Cerradas la misma noche (ver cabecera de CIERRE).

---

# Revisión — SendGrid · PASADA 1 (2026-09-06)

Tercera API del catálogo; la primera construida con el ciclo completo de
`docs/10-revision-automatica.md` en un solo día: documentación pública, panel con cuenta
propia (la creó el autor esa tarde), verificador adversarial independiente (D-013) y las tres
comprobaciones mecánicas. Lo que sigue es **solo lo que el libro de criterios no resuelve**.

## Estado de las comprobaciones

| Comprobación | Resultado |
|---|---|
| Formato (`gen_datasheet_viewer.py`) | **12 ok / 0 avisos / 0 errores** tras [E1] (en la pasada documental: 1 aviso, el `window_type` vacío del límite diario, que el sondeo subió a 🟡) |
| Citas (`verificar_citas.py`) | **133 OK · 0 CAMBIO · 0 SIN-PAG · 0 SIN-CITA** sobre 21 volcados (20 páginas + las respuestas de la API en [E1]) en `evidencias/paginas/2026-09-06/` |
| PRIME4API (`verificar_prime4api.py`) | **8 OK / 13 ERR**, los trece por `price: custom` de Premier (**DV-03**, ya registrada). Sin Premier: **20 OK / 0 ERR** |
| Panel (escalón 2) | Observado. Dos capturas (`panel_planes_freetrial`, `panel_escalera_volumen`); en otras dos pantallas la captura falló por un cuelgue de la extensión y la evidencia es el volcado de texto. Sin datos personales a la vista: no hizo falta redactar |
| Verificador adversarial | Informe archivado abajo. **0 datos refutados**; 5 páginas nuevas incorporadas |

Semáforo tras [E1]: ~~🟢 26 · 🟡 7 · 🔴 0~~ (recontado 2026-09-07 sobre el YAML vigente, ya con la pasada documental 2: 25 🟢 · 5 🟡 · 0 🔴).

---

## 🔴 Alta — decisiones que no están en `CRITERIOS.md`

### Q1 · DISC-01: ¿qué sobrecoste lleva la datasheet, el público o el del panel?

La página de precios publica `$0.0013` (Essentials 50K) y el panel, para el mismo plan,
`$0.00133`; lo mismo en cuatro peldaños de Pro (`$0.0009` / `$0.00091`, `$0.0008` /
`$0.00078`, `$0.0006` / `$0.00059`, `$0.0005` / `$0.00047`). Las dos fuentes son
oficiales; la pública redondea a cuatro decimales. Diferencia de hasta un 6 %.

**Aplicado:** el valor **público** en 🟡, el del panel en el provenance.
**Propuesta:** el del **panel** en 🟢 —es el que se factura, y el panel es fuente oficial
igual que la página— con el público en el provenance. Regla nueva para el libro: «cuando
el panel publica el mismo dato con más precisión que la página, va el del panel».
**Si dices que no:** se queda como está y la regla se escribe al revés.

*(2026-10-18: D17, «el pricing define la verdad», da la vuelta a esta decisión. Va el
`$0.0013` de la página en 🟢 y el del panel queda como incoherencia del pricing; D5 se acota
a los pares sin la página de precios.)*

### Q2 · F-14: ¿cómo se serializa un plan que caduca?

La prueba es *"$0/mo for 60 days"*. **Aplicado:** `price: 0.00`, `period: 1 MONTH`
(literal: el precio es mensual) y los 60 días en el provenance y en F-14. El verificador
lo señaló como «error de modelado» y propondría `period: 60 DAY`.
**Propuesta:** mantener `1 MONTH`. Poner 60 días en `period` haría que PRIME4API tratara la
prueba como un plan bimestral recurrente, que es exactamente el número plausible y falso
que F-14 denuncia. La vigencia no cabe en v0.3 y que se vea es el hallazgo.
**Si dices que no:** se cambia a `60 DAY` y F-14 se reescribe como «el esquema confunde
ciclo y vigencia».

### Q3 · ¿Se contrasta ya con el modelado previo de Ramón y del repositorio?

La Fase 0 pedía construirla **sin mirar la solución**, y así se ha hecho. Con la datasheet
cerrada, mirar el `sendgrid_v03.yaml` del repositorio y el anexo del TFM de Gavira daría
(a) el DISC del plan Free retirado en 2025 que F-09 anticipa, y (b) el dato de cuánto
cambió el proveedor en un año.
**Propuesta:** hacerlo en la pasada 2, como [F20], igual que se hizo con Resend ([F8]).
**Si dices que no:** F-09 se queda en «previsible» y se anota como pregunta al tutor.

---

## 🟡 Media — inferencias que conviene que mires

### Q4 · 10.000 peticiones por segundo en verde en los cuatro planes

La FAQ [F5] lo publica una vez, sin condicionarlo al plan; la regla D2 lo pone en 🟢 en
todos los planes que no lo contradigan. El verificador objeta que la página oficial de
rate limits [F2] **ni menciona** `mail/send` y que no se dice si es por cuenta, por clave
o por subusuario. **Aplicado:** 🟢 por D2, con la segmentación en `not_found`. Si prefieres
🟡 por «publicado solo en una FAQ», es un cambio de una línea y un matiz nuevo para D2.

### Q5 · SMTP fuera del YAML

El canal SMTP tiene topes propios (10.000 destinatarios por mensaje, 5.000 mensajes por
conexión, 10.000 conexiones concurrentes) [F13][F14]. **Aplicado:** no se inventa un
endpoint `smtp://` (regla B1, conformidad estricta); va al provenance y a **F-15**. Si
quieres verlo dentro del YAML, es una extensión que hay que proponer antes.

*2026-10-31:* los 10.000 destinatarios son de la cabecera X-SMTPAPI, no del relé. El relé
publica 5.000 mensajes por conexión y 10.000 conexiones concurrentes [F13]. F-15 se
sostiene con esos dos topes.

### Q6 · `max: 30` MBs en ámbar y `min: 1` sin fuente

*"less than 30MB"* es estricto y el esquema no distingue `<` de `≤`; por eso 🟡. El `min: 1`
es convención del catálogo (Postmark y Resend igual). Si prefieres 🟢 con la nota en la
descripción, dilo.

---

## ~~🔴 Lo que no existe y hay que medir~~ — HECHO el 2026-09-06 (ver cabecera [E1])

SendGrid tiene **modo sandbox** [F10]: valida la petición sin entregar y *"No Credits
will be consumed"*. Eso hace el sondeo inocuo (regla F2) y sin dominio verificado. Tres
sondeos posibles, todos con la clave de API que crees tú:

1. **Tope de destinatarios.** `POST /v3/mail/send` con `sandbox_mode: {enable: true}` y
   1.001 direcciones repartidas entre `to`, `cc` y `bcc` en varias *personalizations*
   → esperado 400 con el mensaje del límite; con 1.000 → 200. Cerraría en verde el
   `max: 1000` **y** confirmaría que el tope es total, no por campo (O-06: la OpenAPI
   deja `to` sin `maxItems`).
2. **Rate limits de los otros endpoints.** Una sola llamada `GET` a cada endpoint de
   lectura (`/v3/user/profile`, `/v3/api_keys`, `/v3/templates`, `/v3/messages`…) y leer
   `X-RateLimit-Limit` y `X-RateLimit-Reset` de la respuesta. **Sin consumo, sin
   escritura.** Cerraría F-01 para SendGrid con valores medidos, y `X-RateLimit-Reset`
   daría la duración del *refresh period*.
3. **Cabeceras de `mail/send` en sandbox.** Si la respuesta 200 del sandbox trae
   `X-RateLimit-Limit`, sale el valor real del caudal del endpoint y se contrasta con
   los 10.000 de la FAQ (Q4).

Se preparan con la skill `sondeo-empirico` cuando lo autorices. Lo que no se puede
medir sin gastar: la ventana del límite diario (haría falta enviar de verdad y leer el
contador al día siguiente, como con Resend).

---

## Informe del verificador adversarial (D-013) — 2026-09-06

Agente independiente con acceso solo al `datasheet.yaml`; reabrió cada URL pública con
su propio lector y contrastó cita a cita.

- **35 líneas con URL pública: 34 COINCIDEN literalmente, 0 CAMBIÓ, 1 NO ENCONTRADA** (la
  del selector de volumen: contenido que solo aparece al ejecutar el JavaScript de la
  página; el panel la corrobora). **8 líneas de `app.sendgrid.com`: no verificables sin
  cuenta.**
- **Ningún valor modelado refutado**: 100/día, 60 días, $19.95, $89.95, tabla de
  sobrecostes, 10.000 rps, 1.000 destinatarios, 1.000 sobres, 30 MB, 10.000 bytes, 10
  categorías, 72 h.
- **Semáforos discutibles**, y qué se hizo con cada uno:
  - `window_type: fixed_utc_midnight` 🟡 sin fuente → **vaciado** (regla D3). Aviso
    justificado.
  - `max: 30` MBs 🟢 con cota estricta → **a 🟡** (Q6).
  - 10.000 rps 🟢 ×4 → **se mantiene** por D2 (Q4).
  - `period: 1 MONTH` en una prueba de 60 días → **se mantiene** (Q2, F-14).
  - `overage_cost` Essentials 🟡 frente a Pro 🟢 con la misma fuente → es DISC-01: Pro
    100K coincide en las dos fuentes, Essentials 50K no (Q1). *(Desde el 2026-10-18,
    `0.0013` 🟢 por D17.)*
- **Lo que el constructor no vio**, incorporado en la misma tanda: límites SMTP [F13],
  10.000 destinatarios por SMTP [F14] (→ **F-15**; *2026-10-31:* son de la cabecera
  X-SMTPAPI, no del relé), Email Activity Feed API tras add-on
  [F15][F16], validación solo Pro/Premier y 50 fuentes [F17], quinto paquete de créditos
  con errata `"$40.000 USD"`, 150 sustituciones por sobre, el ejemplo 429 con
  `X-RateLimit-Limit: 150`, y la especificación OpenAPI con `to` sin `maxItems` (→ O-06).
- **`not_found` revisado**: todos los huecos se mantienen; uno se matiza (el caudal de
  «otros endpoints» sí está publicado para SMTP) y uno se añade (tamaño máximo por SMTP).

Informe íntegro: `evidencias/verificador_adversarial_2026-09-06.md`.

---

## Lo que queda abierto

- Q1–Q3 (tuyas). Q4–Q6 si quieres tocarlas; si no, se quedan como están aplicadas.
- ~~Escalón 3~~ hecho [E1]. Solo la ventana diaria exacta (hora y zona) exigiría enviar de verdad y leer el contador al día siguiente; no compensa.
- Contraste con el modelado previo (Q3) → pasada 2.
- La cuenta caduca el **5 de noviembre de 2026**: cualquier observación de panel posterior
  la tendrá que hacer una cuenta nueva, y eso también es un dato (F-14).

## Actualización 2026-09-14 · test de `type` completo (C2/D9)

Las cinco operaciones no eliminatorias (4 a 8) estaban sin comprobar y dejaban el `type` en 🟡
por D9. Comprobadas contra la referencia, con cita por operación en [F21]: `POST /v3/api_keys`,
`POST /v3/user/webhooks/event/settings`, `POST /v3/user/webhooks/parse/settings` (Inbound
Parse), `POST /v3/asm/suppressions/global` con `GET /v3/suppression/bounces`, y
`GET /v3/messages`.

**Ninguna operación del dominio del correo queda solo en el panel**: el `type` sigue siendo
`api_first` y su color pasa a 🟢 por cobertura del test (D9). Semáforo **29 🟢 / 1 🟡 / 0 🔴**
—el ámbar que queda es el `window_type` de Premier—. Validador **12 ok / 0 avisos / 0
errores**; citas **140 OK · 0 CAMBIO · 1 SIN-PAG · 0 SIN-CITA**.

**El matiz de la operación 8, no eliminatorio.** La actividad existe en la API, pero cobrada
aparte: `"To gain access to the Email Activity Feed API, purchase additional email activity
history."` [F15], mientras el panel da 3 días dentro del plan [F16]. No es fricción nueva —es
**F-08** ya registrada aquí, el endpoint entero detrás de un add-on—, y no cambia el `type`
porque la 8 no es eliminatoria.

### Escalón 2 del test C2 — panel recorrido el 2026-09-14

Panel con cuenta propia recorrido contra la lista de ocho ([F22], volcado en
`evidencias/panel_operaciones_c2_2026-09-14.md`). API Keys, Event Webhooks, Inbound Parse y las
seis listas de Suppressions están en los dos lados. **La 8 no**: el panel da la actividad con
`"Retrieve information about every email you've sent in the past 3 days by clicking "Search"."`
y `"Up to 30 days of history is available for purchase."`, mientras la Email Activity Feed API
exige comprar el histórico [F15]. Con esta cuenta, por tanto, **la operación existe en la web y
no en la API** — la forma que C2 castiga, pero en una operación **no eliminatoria**: el `type`
sigue `api_first` en 🟢 y la asimetría refuerza **F-08**.

### Regla B8 aplicada el 2026-09-14 (D-035)

El `datasheet.yaml` declaraba `quota` y `rate` en el plan **y** los repetía dentro de
`/v3/mail/send`, en los cuatro planes: ocho líneas. PRIME4API hereda del plan y concatena sin
deduplicar, así que el escenario salía con dos cuotas y dos caudales idénticos y la curva a 30
días daba **100.000 correos con $k = 1.000$** donde el proveedor publica 50.000 (**DV-05**).
Retiradas las ocho líneas, el validador sigue en **12 ok / 0 avisos / 0 errores**, el semáforo no
se mueve (**29 🟢 / 1 🟡 / 0 🔴**: las líneas no llevaban marca) y `verificar_prime4api.py` da los
mismos **8 OK / 13 ERR** de antes, todos DV-03. Las curvas del servicio salen ahora byte a byte
iguales a la variante «sin reiteración» que la Figura 5.1 ya usaba. De las 15 llamadas P
reejecutadas (`05_salida/_cap5/prime4api_ejecucion_d035/`), **10 son idénticas y 5 pierden el
duplicado del listado**; el único número que cambia es el umbral de violación del Free Trial en
PI-B05, de 18.000 a 18.027 ms, con los tres veredictos iguales.
