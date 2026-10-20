# Revisión — Resend · CIERRE (2026-09-06) + sondeo [E1]

El autor autorizó y ejecutó el sondeo la misma tarde (`probe_resend_ventana_destinatarios.sh AB`,
18:36 UTC). Resultado:

| Pregunta | Antes | Después | Evidencia |
|---|---|---|---|
| DISC-04, tope de destinatarios | 🟡 `max: 50`, ambiguo entre campo y petición | 🟢 **50 en total** por petición: `"The total number of recipients cannot exceed 50."` (misma forma que DISC-01 de Postmark) | [E1] |
| Caudal del plan Free | 🟢 documental + panel | 🟢 verificado en cabeceras: `ratelimit-policy: 10;w=1` | [E1] |
| Cabeceras de cuota | documentadas | observadas: `x-resend-daily-quota` / `x-resend-monthly-quota` devuelven el consumo previo a la petición | [E1] |
| Deduplicación | no documentada | 50 direcciones idénticas cuentan como 1 (panel `2 / 100`). No prueba nada sobre destinatarios distintos | [E1] + panel |
| Ventana del límite diario | 🟡 `rolling` | **pendiente**: leer el contador el 07-09 hacia las 18:06 UTC (si sigue en 2/100, 24 h desde el envío) y hacia las 18:40 UTC (si baja a 0, `rolling` confirmado) | — |

Validación tras los cambios: **16 ok / 0 avisos / 0 errores**; provenance con cita literal
en todas las líneas nuevas. Resend queda **cerrada** salvo la ventana diaria, que se
resuelve mañana sin coste.

---

# Revisión — Resend · PASADA 2 (2026-09-01): panel observado y ocho preguntas cerradas

El autor cerró las ocho preguntas de la pasada 1 en la sesión del 1 de septiembre, pregunta a
pregunta, y a continuación se hizo la **observación de panel con cuenta propia** (escalón
2, fuente [F9], cuatro capturas redactadas en `evidencias/`). Estado por pregunta:

| | Decisión del autor | Aplicado | Evidencia |
|---|---|---|---|
| Q1 | Solo el transaccional; el producto de marketing se documenta en dos frases en el cap. 4 | F-10 se mantiene; **pendiente el párrafo del cap. 4** | Panel: dos suscripciones independientes, 3.000 emails / 1.000 contactos [F9] |
| Q2 | Sin dominio disponible (2026-09-01): **queda en 🟡 documentado**, `max: 50` con la ambigüedad citada en `not_found`. Cerrada | El panel no tiene formulario de envío: no observable sin API [F9] |
| Q3 | 🟢 valor por defecto, 🔴 el negociado | `rate_request_team_pro/scale` → 🟢; Enterprise 🔴 | `"Rate limit 10 req/s"` en el panel [F9] |
| Q4 | Fuera de `capacity`, al provenance | Ya estaba fuera; línea de provenance añadida | [F1] |
| Q5 | Juzgar por el panel | **`type: api_first`** 🟢: sin formulario de envío transaccional, el panel solo envía *broadcasts* (marketing) | [F9] |
| Q6 | Fuera del YAML + fricción recurrente + familia no capacitaria | Cuotas `quota_domain_verified_*` eliminadas; `/domains` sin cuota; **F-11** (recurre con Postmark: promovible); familia no capacitaria al final de `fricciones.md` | `"Domains 0 / 3"` [F9] → DISC-05 |
| Q7 | Quitar `base_uri` de las dos | Quitado en Resend y en Postmark; Anexo A regenerado; **Anexo A2 de Resend creado** (no incluido aún en `TFG.tex`: carril rojo) | — |
| Q8 | Validado | — | — |

**Lo que el panel añadió y no estaba en ninguna fuente documental:**
- **F-12** la recepción consume la cuota de envío (`Sending` / `Receiving` bajo el mismo contador).
- **F-13** el sobrecoste es un interruptor opt-in, `"Paid feature"`, no disponible en Free: la cuota de Free es tope duro.
- **DISC-05** Free incluye 3 dominios según el panel y 1 según el pricing.
- La ventana del límite diario **tampoco es observable**: el panel muestra el contador sin fecha de reposición. Solo sondeo.

**Lo que sigue abierto:** solo el párrafo del cap. 4 sobre el producto de marketing (Q1),
que entra con la pasada de voz del capítulo. Validación de formato tras los cambios: pendiente de
republicar la estación.

---

# Revisión — Resend (pasada 1: documentación pública + modelado previo del repo)

Segunda API del catálogo, y la primera construida con la skill `datasheet-api`.

**Encuadre que conviene tener presente al revisar:** Resend **ya estaba modelada en el
repositorio de la guía** (`resend_v01.yaml`, sintaxis 0.1, febrero de 2026). Esta pasada
no la descubre: la migra a v0.3, la verifica contra fuente y encuentra que dos de sus
valores han caducado. Eso encaja con el encargo —aplicar y extender, nunca proponer lo
ajeno— pero conviene que quede dicho en el capítulo 4 cuando se redacte el epígrafe.

**Validación de formato:** 0 errores · 1 aviso (el hueco deliberado del `window_type`
diario). Postmark sin regresión: 0 errores · 5 avisos.

---

## 🔴 Prioridad alta — decisiones que no puedo tomar yo

### Q1 · ¿Modelamos solo el producto transaccional? (nueva, alcance)

Resend vende dos catálogos independientes bajo la misma cuenta: transaccional (facturado
por emails) y marketing (facturado por contactos, *"not limited by the number of emails
sent"* [F2]). No caben los dos en un `plans` plano sin que `price` deje de ser comparable.

**Lo aplicado, por lectura conservadora:** solo el transaccional, que es lo que hace
comparable a Resend con Postmark y con el resto del catálogo. La otra mitad queda
registrada como F-10.

**Lo que necesito de ti:** confirmarlo, y decidir si la limitación se declara en el
capítulo o solo en fricciones. Si en algún proveedor futuro el producto de marketing es
el principal, este criterio hay que tenerlo cerrado antes.

### Q2 · El tope de destinatarios por petición (DISC-04)

`to` declara *"Max 50"*; `cc` y `bcc` no declaran nada [F5]. Y la cuota se consume por
destinatario [F7]. Si el tope de 50 es del campo o de la petición **no está resuelto**.
Aplicado: `max: 50` en 🟡.

Es la misma forma que DISC-01 de Postmark, que se cerró con sondeo empírico. **Aquí no lo
he sondeado**, y la razón importa: Resend exige dominio verificado para enviar y no
publica un token de pruebas equivalente al `POSTMARK_API_TEST`. Sondearlo significaría
usar tu clave real contra tu cuota.

**Lo que necesito de ti:** si quieres que prepare el sondeo —gastaría unos pocos envíos
de los 100 diarios del plan Free— o si lo dejamos en 🟡 documentado. Ninguna de las dos
es mala: el 🟡 con la ambigüedad citada también es un resultado.

### Q3 · El caudal del plan Enterprise y el de los *trusted senders* (F-01 parcial)

La documentación da un valor por defecto —10 rps por equipo— y dice que
*"can be increased for trusted senders upon request"* [F4], sin umbral ni valor.
Aplicado: `rate_request_team_enterprise` con valor vacío en 🔴 y entrada en `not_found`;
Pro y Scale con el valor por defecto en 🟡, porque la documentación no afirma que varíe
por plan pero tampoco lo niega.

**Lo que necesito de ti:** ¿te vale ese 🟡, o prefieres 🔴 en Pro y Scale? Es la
diferencia entre «inferido de que solo se publica un valor» y «no documentado por plan», y
con 12 APIs por delante conviene fijar el criterio ahora.

---

## 🟡 Prioridad media — verifica si puedes

### Q4 · La retención dejó de discriminar por plan (DISC-03)

El repo la modelaba como 1 / 3 / 7 días por plan; hoy la página dice 30 días en Free, Pro
y Scale por igual [F1][F2]. Aplicado: **no se modela como cuota**, porque ya no distingue
planes y no es una dimensión de consumo. Queda en el *provenance*.

### Q5 · `type: partial_saas` (D-003)

Aplicado `partial_saas` en 🟡. Hay dos apoyos: el criterio que propusimos a los tutores
—no toda la funcionalidad de envío es programática, el panel envía *broadcasts*— y que el
propio README de la guía cita a Resend como ejemplo del Caso B. Coincide además con el
`resend_v01.yaml` del repo.

### Q6 · Los dominios verificados, modelados como cuota de `records`

1 / 10 / 1.000 dominios [F2] no son consumo: son un límite de recursos. Los he metido en
`capacity` con `unit: records` porque v0.3 no ofrece otro sitio, igual que hace el
`resend_v01.yaml` con los días de retención (O-04).

**Es forzar el esquema, y lo digo antes de que lo veas tú.** La alternativa era dejarlos
fuera y perder el dato. ¿Los dejamos, o los sacamos del YAML y viven solo en el
*provenance*?

---

## 🟢 Baja — consistencia

### Q7 · `base_uri` no está en la cabecera de v0.3

El README §3.1 lista siete campos de cabecera y `base_uri` no es uno. El piloto de
Postmark lo lleva y está aprobado, así que aquí lo he mantenido **por consistencia**.
Bajo D-008 (conformidad estricta) es un campo de más. Se queda o se quita en las dos a la
vez; dime cuál.

### Q8 · Arreglo del validador — aplicado, pendiente de tu OK

El validador daba «Endpoint sin `workload`» para la clave comodín `/*`, que el README
documenta en §3.4.1 como el mecanismo de valores por defecto de un plan. Era un falso
positivo. Lo he corregido en `gen_datasheet_viewer.py` para que lo reconozca como correcto
en vez de avisar.

**No lo elegiste tú**, así que lo marco como aplicado y no validado. Postmark sigue dando
exactamente lo mismo que antes (0 errores, 5 avisos), así que el arreglo no toca nada de
lo aprobado. Si prefieres revertirlo, es una línea.

---

## 🔴 Lo que no existe y hay que medir

### Ventana del límite diario del plan Free

100 emails al día [F2], sin decir si el contador se reinicia a medianoche UTC o por ciclo
de cuenta. Es el único aviso del validador y es un hueco deliberado. Observable con cuenta
propia sin gastar cuota: basta mirar cuándo se repone el contador en el panel.

### Cooling period tras un 429

Solo se documenta la cabecera `retry-after` [F4]. El valor lo fija el servidor en cada
respuesta, así que no es un dato del proveedor sino del momento — que es en sí una forma
de límite que v0.3 no representa, y que el modelado previo del repo ya anotó como
`coolingPeriod: TBD` [F8].

---

## Resumen de la pasada 1

| | |
|---|---|
| Fuentes | 8 ([F1]–[F8], incluido el modelado previo del repo) |
| Discrepancias | 3 (DISC-02 caudal, DISC-03 retención, DISC-04 destinatarios) |
| Fricciones que recurren | **F-02, F-03, F-06, F-07** → promovibles bajo D-008 |
| Fricciones parciales | F-01 y F-08, anotadas como parciales para no inflar el recuento |
| Fricciones nuevas | F-09 (vigencia por dato) y F-10 (dos productos, dos unidades) |
| Observaciones de repo | O-04, O-05 |
| Validación | 0 errores · 1 aviso |
| Cobertura | Alta en transaccional; el producto de marketing queda fuera por Q1 |

## Actualización 2026-09-14 · test de `type` completo (C2/D9)

El test C2 dejó el `type` en 🟡 el mismo día por un defecto de método, no de dato: las
operaciones 4 a 8 se leyeron del **índice agregado** (`/docs/llms.txt`) y no de la referencia
de cada endpoint. Releídas una a una, con cita por operación en [F10]: `POST /api-keys`,
`POST /webhooks`, `GET /emails/receiving` con el webhook `email.received` para el enrutado,
`POST /suppressions` y `GET /logs`.

**Ninguna operación del dominio del correo queda solo en el panel**: el `type` sigue siendo
`api_first` y vuelve a 🟢 por cobertura del test (D9). Semáforo **26 🟢 / 5 🟡 / 1 🔴**.
Validador **16 ok / 0 avisos / 0 errores**; citas **31 OK · 1 CAMBIO · 41 SIN-PAG · 0
SIN-CITA**.

**El CAMBIO es anterior a esta pasada y no lo toca.** Es la línea que cita `'Domains 0 / 3'`
—literal del panel— con la URL de `pricing.md` al lado: el verificador la contrasta contra el
volcado del *pricing*, donde ese literal no está. Es un defecto de redacción de la cita, no un
dato caído; queda anotado para que el autor decida si se separa la observación de panel de la
documental.

### Escalón 2 del test C2 — panel recorrido el 2026-09-14

Panel con cuenta propia recorrido contra la lista de ocho ([F11], volcado en
`evidencias/panel_operaciones_c2_2026-09-14.md`). **Ninguna operación queda solo en el panel.**
La única asimetría va **a favor de la API**: el menú no tiene sección de supresiones y la API sí
las gestiona. C2 solo castiga lo contrario, así que el `type` no se mueve: `api_first` en 🟢 con
las ocho comprobadas por los dos lados.

### Regla B8 aplicada el 2026-09-14 (D-035)

El `datasheet.yaml` repetía el caudal del plan en el comodín `/*` de los cuatro planes y la cuota
mensual del plan en `/emails` y `/emails/batch` de Pro, Scale y Enterprise: diez líneas. La cifra
de la curva no se movía —el techo lo fijaba el mismo valor duplicado—, pero el motor arrastraba el
duplicado en cada listado (**DV-05**). **La cuota diaria del Free se queda**: es un límite
distinto del mensual del plan, no una repetición, y B8 solo prohíbe repetir. Retiradas las diez
líneas, el validador queda en **12 ok / 0 avisos / 0 errores** —baja de 16 `ok` porque
desaparecen los cuatro comodines, que el validador contaba como comprobación correcta—, el
semáforo no se mueve (**26 🟢 / 5 🟡 / 1 🔴**) y `verificar_prime4api.py` da los mismos **8 OK /
13 ERR**; el único cambio es que `nav.endpoints` deja de listar `/*`. De las 15 llamadas P
reejecutadas (`05_salida/_cap5/prime4api_ejecucion_d035/`), **12 son idénticas y 3 pierden el
duplicado**, sin que cambie ningún valor.
