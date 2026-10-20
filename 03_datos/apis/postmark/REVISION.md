# Revisión — Postmark · rate adoptado en ámbar, D-024 (2026-09-07, noche)

- el autor (chat): «adopta los 5.000 req/s en ámbar». `max_power` deja de estar vacío:
  `rate_request_rest` 5.000 requests / 1 SECOND, 🟡, referenciado desde los cuatro planes con
  `rate:` (D2, un solo rate no condicionado al plan) y no repetido en los endpoints (abierta 13).
- Por qué ámbar y no verde: la cabecera y el sondeo de caudal [E4] prueban que el contador
  existe, es por segundo y vale 5.000; nadie ha forzado el 429. CRITERIOS D6 ampliada.
- Cambios: `max_power`, cuatro `rate:`, `not_found[0]`, dos líneas de provenance. DISC-02
  cerrada en ámbar. Semáforo del fichero: 28 🟢 / 9 🟡 / 4 🔴 (el 🟡 extra es la cabecera de comentario de `max_power`; los 🔴 que quedan: `/email/bulk`
  sin tope ×4). PM-36, PM-82, PM-97 en ámbar; PM-98 nuevo.
- Consecuencia en el cap. 5: el motor ya no trata el rate de Postmark como infinito. Las P se
  reejecutan (`prime4api_ejecucion_d024/`) y §5.3, §5.5 y §5.6 se ajustan.

---

# Revisión — Postmark · sondeo de caudal inocuo, [E4] (2026-09-07, noche)

- el autor preguntó qué ámbar y rojo se cierran con las cuentas gratis. Para el rate REST (🔴
  `max_power`) solo cabe un sondeo inocuo: 200 peticiones en 4,6 s con destinatario de
  dominio no verificado (412, nada sale). Resultado: el contador de la cabecera es por segundo
  y se repone cada segundo; límite 5.000; el 429 no se alcanza. Detalle en `fuentes.md` [E4].
- Cambios: [E4], DISC-02 actualizada, una línea en `data_provenance`. **Ningún semáforo
  cambia**: adoptar 5.000 req/s en `max_power` (🟡) es decisión del autor porque altera P-04 y
  las ocho preguntas de RQ3 del cap. 5 que hoy tratan el rate de Postmark como infinito.
- PM-97 nuevo en `hechos_postmark.md`.

---

# Revisión — Postmark · lote de 500 verificado, [E3] (2026-09-07)

- el autor eligió sondear en vez de igualar semáforos a mano (abierta 9). Script
  `probe_postmark_batch_500.sh BT`, ejecutado por él a las 21:47 UTC; diseño a coste 0
  (destinatarios de dominio no verificado, la cuenta rechaza cada mensaje sin enviar).
- Resultado: 500 entra (HTTP 200, 500 × ErrorCode 412) y 501 no (HTTP 422, ErrorCode 410,
  `"You may only send up to 500 messages in a single batched request."`), en `/email/batch`
  y en `/email/batchWithTemplates`.
- Cambios: `max: 500` de `/email/batch` 🟡 → 🟢 en los cuatro planes (4 campos); descripciones
  de los dos endpoints de lote; dos líneas en `data_provenance`. Semáforo del fichero:
  28 🟢 / 7 🟡 / 5 🔴 (antes 24 / 11 / 5). `max_power` sigue vacío: las cabeceras de rate se
  registran en [E3] sin adoptar (D-020).
- Abierta 9 cerrada. PM-51, PM-52 y PM-93 actualizados en `hechos_postmark.md`; PM-95 y PM-96
  nuevos. Cap. 5 §5.2.1 y §5.5 ajustados (ya no «ámbar documental» ni «cifra sin verificar»).

---

# Revisión — Postmark · captura de test mode retirada (2026-09-07)

- Decidido por el autor (chat, 2026-09-07): `evidencias/panel_testmode_setup_2026-08-03_redactado.png`
  se retira porque mostraba su correo sin tapar (solo el token estaba redactado). Movida con
  `git mv` a `_to_delete/panel_testmode_setup_2026-08-03_SIN_REDACTAR.png`; sigue en el
  historial de git.
- Lo que respaldaba: el aviso de test mode de [F11] (`"While your account is in test mode, you
  can only send and process 100 emails…"`; PM-29 en `05_salida/_cap5/hechos_postmark.md`).
  El hecho se mantiene con la transcripción literal de [F11] y la cita de `data_provenance`
  del YAML; [E2] (2026-09-06) confirma que la cuenta seguía en test mode. Queda sin evidencia
  gráfica: pendiente de recaptura redactada.
- Tocado: `fuentes.md` ([F11], nota de retirada), `hechos_postmark.md` (cabecera y PM-29) y
  este fichero. `panel_escalera_volumen_2026-08-03.png` no cambia. `datasheet.yaml` no se
  toca: huella `8b99a09d032e127f`, la misma que dejó D-020 (bitácora 102). Su diff frente al
  último commit (538a3f3, bundle del 2026-09-03) es la suma de las entradas 89 y 102, previas
  a esta retirada.

---

# Revisión — Postmark · DISC-02 registrada (2026-09-07, D-020)

- Decidido por el autor (chat, 2026-09-07, ficha C5-2): la cabecera `ratelimit-limit: 5000`
  de la respuesta 422 de [E2] **se registra como valor observado y no se adopta**. Alta de
  DISC-02 en `fuentes.md`, `not_found` ampliado y `NOTA` en `data_provenance`.
  `max_power` sigue `{}` y en 🔴. Solo se ha tocado `metadata`; ningún campo de capacidad
  cambia de valor ni de semáforo. Cerrar DISC-02 exigiría un sondeo de caudal inocuo
  (CRITERIOS D6, F2), no previsto.

---

# Revisión — Postmark · segunda tanda empírica (2026-09-06)

- **[E2]** `/email/withTemplate` con 51 en To → 422/300 `"Maximum of 50 recipients allowed
  per email message."`: los cuatro `max: 50` del endpoint pasan de 🟡 a 🟢.
- **Provenance limpiado**: las 14 líneas sin cita literal llevan ahora la cita de su fuente
  (sobrecostes, add-ons, 429, autenticación, 410, tamaños, bulk, plantillas, retención,
  SMTP, escalera de volumen, tiers, test mode, Swagger). Validación: **12 ok / 5 avisos /
  0 errores**, y los 5 avisos son los huecos deliberados (`max_power` vacío por F-01 y
  `workload.max` de `/email/bulk` por F-06).
- **Sigue pendiente y con su motivo:** rate REST y concurrencia (nadie los publica; medirlos
  es campaña de carga, fuera del encargo), `/email/batch` 500 (caso B no lanzado por
  riesgo de cuota), `/email/bulk` (sin tope numérico), precios de Pro y Platform por
  volumen (exigen cuenta aprobada, no clave).

---

# Revisión — Postmark (pasada 3: documentación completa + observación de panel)

**Estado:** pendiente de tu revisión — canal: estación de revisión (`revision-datasheets-tfm`)
**Construido:** 2026-08-02 · **Ampliado:** 2026-08-03 (pasada 2 docs · pasada 3 panel [F11][F12]) · **Validado contra v0.3:** sí

La estación de revisión muestra cada campo con su fuente, su cita literal y su
semáforo, y este fichero recoge las preguntas que no puede responder la documentación.
Marca cada punto con `[OK]`, `[NO] + motivo` o `[DUDA]` — desde la estación o aquí.

---

## 🔴 Prioridad alta — decisiones que no puedo tomar yo

### Q1 · Clasificación `type` (= D-003) — ✅ DECIDIDA por el autor (chat, 2026-08-03)
**`api_first`**, con la matriz panel↔API como respaldo. Criterio D-003 pendiente de tutores.

Sigue en `api_first`. La guía del repo distingue Caso A (SaaS puro), Caso B
(API-First / Partial SaaS) y Caso C (no comercial); Postmark es claramente Caso B, y
dentro de él he optado por `api_first` porque toda la funcionalidad de envío es
consumible por API y el panel es auxiliar. Propuesta ya formulada en el borrador de
correo a tutores.

`[ ]` →

### Q2 · Máximo de destinatarios por petición — ✅ RESUELTA empíricamente [E1]
**50 destinatarios TOTALES por mensaje** (50 se acepta, 51 falla en cualquier
reparto; error 300 literal). La lectura "por campo" de la doc queda desmentida →
DISC-01. El `max: 50` pasa a 🟢. Queda un fleco menor para la fase con token real:
confirmar que el CÓMPUTO de cuota es 1 email por destinatario (1 envío a 2
direcciones y mirar el contador).

### Q3 · Normalización del `overage_cost` (= D-002) — ✅ DECIDIDA por el autor (chat)
**Unitario.** Coincide con el precedente de Ramón; en el correo a tutores como
propuesta de criterio general.

### Q6 · Serialización de `/email/bulk` con `max` vacío (F-06) — representación OK; test imposible con token de pruebas
El sondeo [E1] demostró que el token de pruebas **solo** funciona en `/email`
(403/10), así que bulk no se puede validar gratis: queda para la fase empírica con
token real y cuenta aprobada. La representación (max vacío + comentario) se
mantiene.

El endpoint no tiene tope numérico de mensajes — la cota real es 50 MB de payload.
He dejado `workload.max` **vacío con comentario** en vez de inventar un número o
poner los 500 del batch. Alternativa descartada: omitir el endpoint (peor: es el más
potente de la API). ¿De acuerdo con la representación?

`[ ]` →

### Q7 · Endpoints de consulta con RPR no serializable (F-05) — ✅ ACLARADA
RPR *es* adaptable al modelo — serializarla es exactamente la propuesta C-02 (vía
PR/tutores). Lo que no hacemos es inventar el campo unilateralmente en una
datasheet v0.3: dejaría de ser conforme y las herramientas no lo leerían. Se
mantiene en description + provenance + F-05.

He incluido `GET /messages/outbound` y `GET /messages/inbound` con
`workload: requests 1..1` y la dimensión RPR (Max 500, tope 10.000) descrita en
`description` + `data_provenance`, porque v0.3 no tiene campo para ella. Alternativa
descartada: no incluir los endpoints (ocultaría la dimensión). ¿De acuerdo?

`[ ]` →

### Q9 · Proyección del producto tier × volumen en `plans` (F-08) — ✅ DECIDIDA: opción A + C al cierre
Marco fijado por el autor (chat, 2026-08-03; ver D-008): conformidad estricta con v0.3
hoy (opción A del apoyo gráfico `apoyo_q9_tier_volumen.html`), y las extensiones
como propuestas consolidadas al cierre del dominio. 

El panel [F11] revela que Basic/Pro/Platform son **tiers funcionales** y el volumen
va aparte, en escalera. La datasheet mantiene la proyección "3 planes = 3 tiers, con
la cuota del escalón mínimo" y documenta la escalera en provenance/F-02. Alternativa
descartada: enumerar las ~18 combinaciones tier×escalón como planes. ¿De acuerdo con
la proyección? (Buena pregunta también para el tutor: afecta a cómo se comparen
proveedores con estructura cartesiana.)

`[ ]` →

### Q10 · Endpoints exclusivos de tier (F-08) — ✅ CERRADA por el marco D-008
Se mantienen fuera del YAML (conformidad v0.3); su pertenencia por tier queda en
provenance y F-08, y entra en el paquete de propuestas si el patrón se repite en
≥2 APIs del dominio (criterio de recurrencia del autor).

*"Stats & Open/Link Tracking APIs"* solo existen desde Pro [F11]. Los endpoints
`/stats/*` y `/messages/outbound/{opens,clicks}` **no están modelados** en la
datasheet (no publican límites de consumo propios más allá del RPR genérico) y su
pertenencia por tier está registrada en provenance y F-08. ¿Los dejamos así o los
añadimos como endpoints solo de pro/platform?

`[ ]` →

---

## 🟡 Prioridad media — verifica si puedes

### Q4 · `window_type` de las cuotas mensuales — RESUELTA para free [F11]
El panel muestra *"Your 100 free emails will renew on Sep 4, 2026"* con alta el
2026-08-03 → ciclo de cuenta, no mes natural. `fixed_billing_cycle` pasa a 🟢 en la
cuota free. En los planes de pago sigue 🟡 (presumiblemente igual, sin confirmar).

`[ ]` →

### Q5 · El "Starting at 10,000 emails/month" (F-02) — RESUELTA por panel [F11]
La escalera completa está capturada: 10k/$15 · 50k/$55 · 125k/$115 · 300k/$245 ·
700k/$455 · 1,5M/$775, con overage $1.80→$1.70 desde 300k y tramo negociado por
encima. Pendiente-empírico: el reprecio de la escalera al cambiar de tier (no
observable hasta que aprueben la cuenta).

`[ ]` →

### Q8 · Disponibilidad de `/email/bulk` por plan
El Bulk API está **en acceso anticipado** y la documentación no dice en qué planes
está disponible. Lo he incluido en los cuatro planes con el caveat en el comentario.
¿Lo dejamos así o lo restringimos?

`[ ]` →

---

## 🔴 Lo que no existe y hay que medir

### Rate limits de la API REST (F-01)
Sin cambios tras la pasada 2: **ningún umbral numérico publicado**, y en bulk el
proveedor declara que el ritmo lo gestiona él ("optimize the sending speed for you").
`max_power` sigue vacío a propósito. Primer candidato a `datasheet-usage-testing`.

### Concurrencia (F-04)
Solo el dato SMTP (10 conexiones/IP, sin enforcement). Para REST, nada.

---

## Matriz panel↔API (test de D-003, verificada 2026-08-03 [F11])

| Funcionalidad de producto | Panel | API |
|---|---|---|
| Enviar (individual/lote/plantillas/bulk) | ✗ (no hay "componer") | ✓ Sending + Bulk |
| Tracking (open/link) | ✓ Server Settings | ✓ `PUT /server` (TrackOpens/TrackLinks) |
| SMTP on/off | ✓ Server Settings | ✓ `SmtpApiActivated` |
| Streams | ✓ | ✓ Message Streams API |
| Suppressions | ✓ | ✓ (verificado por el autor en el explorer) |
| Webhooks | ✓ | ✓ (verificado por el autor en el explorer) |
| Dominios / firmas (DKIM, SPF) | ✓ | ✓ Domains + Sender Signatures |
| Actividad / estadísticas / bounces | ✓ | ✓ Messages + Stats + Bounces |
| Plantillas (CRUD, validar, migrar) | ✓ (editor visual) | ✓ Templates API |
| Facturación, tiers, add-ons, usuarios, aprobación | ✓ solo panel | ✗ — **administración**, excluida del criterio |

**Veredicto D-003: `api_first`** — toda la funcionalidad de producto tiene
equivalente API; lo exclusivo del panel es administración de cuenta. El único paso
humano (clic de confirmación de sender signature) es verificación de propiedad.

## Resumen de la pasada 3

| | |
|---|---|
| Fuentes | 12 (F1–F10 documentación · F11 panel con cuenta · F12 spec Swagger), todas con cita literal y fecha |
| Endpoints modelados | 7 por plan: /email, /email/withTemplate, /email/batch, /email/batchWithTemplates, /email/bulk, /messages/outbound, /messages/inbound |
| Fricciones | 8: F-01 rate inobservable · F-02 escalera con overage por escalón · F-03 CRF multiplicativo · F-04 límites no aplicados · F-05 RPR no serializable · F-06 workload acotado por MBs · F-07 add-ons que tocan capacidad · **F-08 tier×volumen y superficie de API por tier (nueva)** |
| Observaciones de repo (PR candidatas) | 2 (O-01 workload lista/objeto, O-02 naming del ejemplo) |
| Resueltas por panel | Q4 (ventana free = ciclo de cuenta) · Q5 (escalera completa) · matriz D-003 |
| Pendiente empírico | rate REST (F-01) · concurrencia REST · reprecio de escalera por tier · tope conjunto de destinatarios (Q2) |

**Cobertura:** todos los campos del esquema v0.3 están **tratados** — con valor y
fuente, o con hueco explícito y trazable. Lo que falta no es búsqueda: es información
que el proveedor no publica o que exige cuenta aprobada, y pasa a la fase empírica.

## Actualización 2026-09-14 · test de `type` completo (C2/D9)

Las cinco operaciones no eliminatorias (4 a 8) seguían sin comprobar y dejaban el `type` en
🟡 por D9. Comprobadas hoy contra la referencia de API, con cita por operación en [F13]:
credenciales adicionales (`POST /servers`, cuya respuesta trae `ApiTokens`), webhooks
(`/webhooks` con GET, POST, PUT, DELETE, verify y statistics), inbound routing
(`/triggers/inboundrules` y el bypass/retry de `/messages/inbound`), supresiones y rebotes
(`/message-streams/{stream_id}/suppressions` y `/bounces`) y actividad
(`/messages/outbound`, details, dump, opens y clicks).

**Ninguna operación del dominio del correo queda solo en el panel**: el `type` sigue siendo
`api_first` y su color pasa a 🟢 —verde de cobertura del test, no del valor (D9)—. Semáforo
**29 🟢 / 8 🟡 / 4 🔴**. Validador **12 ok / 4 avisos / 0 errores**, igual que antes.

**Carencia anotada, no eliminatoria (operación 4).** La referencia no publica cómo *rotar* el
token de un servidor ya creado —el overview lo sitúa en la pestaña API Tokens del panel—, y
el listado de códigos de error anuncia una familia `SMTP TOKENS` (1450–1460) que no tiene
página en el índice. Como la 4 no es eliminatoria, se anota y no mueve el `type`.

### Escalón 2 del test C2 — panel recorrido el 2026-09-14

El mismo día se recorrió el panel con cuenta propia contra la lista de ocho ([F14], volcado en
`evidencias/panel_operaciones_c2_2026-09-14.md`). Cuatro operaciones están en los dos lados
(webhooks, inbound, supresiones, actividad). **La 4 no**: el panel genera y borra tokens de un
servidor ya creado y la API no publica cómo, así que es una operación del dominio del correo que
solo se puede hacer desde la web. Como la 4 **no es eliminatoria** (C2), el `type` sigue
`api_first` en 🟢 y la asimetría se registra como fricción nueva **F-22**, medida en 1 de 4 APIs:
las otras tres sí exponen la gestión de credenciales por API.
