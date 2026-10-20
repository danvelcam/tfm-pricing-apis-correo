# F-18 contra la condición L2 de D-042 — ejecución del 2026-09-15

> ## ⛔ VEREDICTO REVOCADO — 2026-09-15, verificación adversarial
>
> **El «L2 CUMPLIDA» de la sección 5 de este informe no vale. El veredicto final es
> L2 NO CUMPLIDA**, y es el que recoge la ficha D-042. F-18 **no se promueve**; P-06 queda
> formulada y sin promover.
>
> Tres razones, las tres sobre los hallazgos de este mismo informe:
>
> 1. **El valor falso de los 70 destinatarios es defecto del motor, no del esquema.** Sale de
>    `nav/crf-ranges`, y su `NavRequest` **no tiene campo `alias`**: el filtro de estado se
>    descarta en silencio, así que el canal no puede responder por estado aunque la Datasheet
>    lo declare. Lo que L2 pide es un valor falso imputable al documento.
> 2. **El segundo candidato ya está inventariado.** Las dos cuotas mensuales sin desempate
>    —500 del plan y 100 del estado— son **DV-05** en `03_datos/DISCREPANCIAS_v03.md`: la
>    herencia concatena el límite del plan y el del nodo sin deduplicar. Un defecto del motor
>    ya inventariado como DV-nn no sirve para L2, por la propia definición del listón.
> 3. **Los canales de cálculo leen bien lo que la Datasheet declara.** `capacity-at` devuelve
>    `capacity_request_factor: 2.0` para `unapproved_account` —40 correos en el primer minuto,
>    120 en 30 días— frente a los 36 y 70 del estado sano. Donde el motor calcula, el estado
>    entra y el resultado es el que la Datasheet dice.
>
> La objeción ya estaba escrita al final de la sección 5 de este informe, como matiz. La
> verificación la convirtió en el veredicto.

**Lo que sigue es el informe de la primera pasada, conservado íntegro y desmentido en su
veredicto por el bloque de arriba.**

**Qué se comprueba.** L2 pide que PRIME4API, con la Datasheet del catálogo delante, devuelva un
valor falso o deje sin responder lo que respondería si el esquema expresara la carencia. La
evidencia que D-042 usaba era O-12, medida sobre dos copias contaminadas con una clave `trigger`.
Esta ejecución la sustituye por otra medida sobre la Datasheet **sin tocar**.

**La Datasheet que se usó.** `03_datos/apis/mailersend/datasheet.yaml`, sha256
`3dff58bf0d8be28bd66de9a5b669f07d5afdc4624c8da141ccdd32626b9227bd`, sin modificación local
(`git status --porcelain` vacío antes y después de las diez llamadas). El YAML crudo viaja como
`datasheet_source` en cada petición.

**El servicio.** PRIME4API de SPHERE en local, `http://localhost:8003/api/v1/datasheet`. Diez
llamadas, todas 200, una por fichero `L2-NN_mailersend.json` en esta carpeta.

---

## 1 · Qué se preguntó

| # | Pregunta al motor | Endpoint |
|---|---|---|
| L2-01 | Cuántos destinatarios admite una petición a `/v1/email` en el plan `free` | `POST /nav/crf-ranges` |
| L2-02 | La misma, acotada al estado `unapproved_account` | `POST /nav/crf-ranges` |
| L2-03 | La misma en el lote de Hobby, donde el alias declara `max: 5` y el endpoint 35.000 | `POST /nav/crf-ranges` |
| L2-04 | Qué límites tiene `/v1/email` del plan `free` para una cuenta sin aprobar | `POST /limits` |
| L2-05 | La misma por el canal MCP, que es el que consume un agente | `POST /mcp/evaluate` |
| L2-06 | Contraste: los mismos límites en el estado sano | `POST /limits` |
| L2-07 | Cuándo agota la cuota de correos una cuenta sin aprobar | `POST /quota-exhaustion-threshold` |
| L2-08 | Cuántos correos caben en el primer minuto sin aprobar | `POST /capacity-at` |
| L2-09 | Lo mismo a 30 días | `POST /capacity-at` |
| L2-10 | En qué estado está una cuenta recién creada | `POST /nav/aliases` |

La pregunta de la hipótesis es la primera: **el tope de destinatarios por petición en el estado no
aprobado**. La Datasheet lo declara dentro del alias, `workload[emails].max: 2`, en los siete
bloques de endpoint.

---

## 2 · Qué respondió el motor

**El tope por petición sale 70, no 2** (L2-01 y L2-02):

```
{"plans": ["free"], "endpoint": "/v1/email",
 "crf_ranges": [{"unit": "emails", "min": 1.0, "max": 70.0,
   "description": "Envío individual; hasta 50 destinatarios en to más 10 en cc y 10 en bcc, …"}]}
```

`nav/crf-ranges` es el único canal del motor que responde el tope por petición. Su esquema de
petición (`NavRequest`) **no declara el campo `alias`**: acepta `plan_names` y `endpoint_path` y
nada más. El `alias: unapproved_account` enviado en L2-02 se descarta en silencio y la respuesta
es idéntica a la de L2-01, byte a byte. Así que el `max: 2` del estado no aprobado **no sale por
ningún canal de listado**, y lo que sale en su lugar es el 70 del estado sano, con la descripción
del estado sano copiada literal. Lo mismo en el lote de Hobby (L2-03): 35.000, con el alias
declarando 5.

**Los canales de listado mezclan la cuota del plan con la del estado** (L2-04, L2-05, L2-07).
Preguntado por los límites de `unapproved_account`, el motor devuelve dos cuotas mensuales de
correos: la del plan, **500 / 30 días**, y la del estado, **100 / 30 días**, sin nada que diga
cuál manda. `mcp/evaluate` las sirve en la misma lista plana, y ninguna de las dos respuestas
lleva el `workload`. `quota-exhaustion-threshold` las calcula las dos: umbral `120day4min` para la
de 500 y `4min` para la de 100.

**El estado por defecto no se puede preguntar** (L2-10). `nav/aliases` enumera
`healthy_reputation`, `under_review_reputation` y `unapproved_account`, en plano, sin marca de
cuál describe una cuenta recién creada. No hay otro canal que lo responda.

**Lo que el motor sí hace bien, y conviene decirlo** (L2-08, L2-09). El canal de cálculo **sí**
usa el `workload` del alias: `capacity-at` devuelve `capacity_request_factor: 2.0` para
`unapproved_account` —40 correos en el primer minuto, 120 en 30 días— frente a los 36 y 70 del
estado sano. El valor falso está en el canal que lista, no en el que calcula.

---

## 3 · Qué dice la medición real

El sondeo [E1], tanda 2, del 2026-09-10, sobre la cuenta propia Sandbox no aprobada:

> `errors.to`: `"The to recipient limit is exceeded. #MS42205"`

en los cinco casos `B2_to_2`, `B2_to_3`, `B2_to_5`, `B2_to_6` y `B2_to_9`. Con el `to = 1` que sí
pasa la validación de destinatarios en la tanda 1 (`B_cc_1`, que solo devuelve `#MS42207` por el
dominio del remitente), el tope de `to` sin aprobar queda acotado en **exactamente 1**. La mayor
combinación que pasa es `to` 1 más `cc` 1, o sea **2**.

- Fichero de evidencia: `03_datos/apis/mailersend/evidencias/probe_sandbox_limites_t2_2026-09-10.json`
  (casos `B2_to_*`), y `evidencias/probe_sandbox_limites_2026-09-09.json` para el `B_cc_1`.
- Fila de hechos: **MS-178** en `05_salida/_cap5/hechos_mailersend.md`, con MS-167 y MS-168 de la
  tanda 1.
- Discrepancia: **DISC-18** en `03_datos/apis/mailersend/fuentes.md`, abierta, con la hipótesis
  del tipo de cuenta que fijó D-040.

La cuota mensual de 100 correos del estado no aprobado es literal de [F39]; la de 500 es la del
plan Free, que ese estado no alcanza.

---

## 4 · El contraste, en una tabla

| Magnitud, estado no aprobado | Motor, con la Datasheet limpia | Medido en la cuenta real |
|---|---|---|
| Destinatarios por petición, `/v1/email` | **70** (L2-01, L2-02) | **1** en `to`; **2** como mayor combinación válida |
| Cuota mensual de correos | **500 y 100**, sin desempate (L2-04, L2-05, L2-07) | 100 publicada [F39]; no medida |
| Estado de una cuenta recién creada | no se responde (L2-10) | la cuenta que se abrió está sin aprobar |

---

## 5 · Veredicto de la primera pasada: **L2 CUMPLIDA** — ⛔ REVOCADO (ver cabecera)

1. El motor, con la Datasheet del catálogo sin tocar, responde **70 destinatarios por petición**
   para el estado no aprobado; la medición del 2026-09-10 da **1** en `to` y 2 como mayor
   combinación válida, con su `#MS42205` y su fichero de evidencia.
2. El `max: 2` que la Datasheet declara para ese estado no aparece en ninguna respuesta de
   listado: el canal que responde el tope por petición no admite el estado como filtro, así que
   sirve el valor del estado sano como si fuera el único.
3. Preguntado por los límites de ese estado, el motor devuelve además la cuota mensual del plan
   (500 correos) junto a la del estado (100), y no responde cuál de los tres estados describe una
   cuenta recién creada.

**La objeción que hay que dejar escrita.** El 70 sale de un canal cuyo esquema de petición no
tiene campo `alias`, y el canal de cálculo sí resuelve el estado. Un lector puede leer eso como
límite de la implementación y no del esquema. El segundo valor falso no admite esa lectura: el
alias **suma** sus límites a los del endpoint en vez de sustituirlos, y v0.3 no tiene forma de
decir que la cuota de un estado reemplaza la del plan, así que el motor devuelve las dos porque
la Datasheet no dice otra cosa. Para la atribución al esquema sigue valiendo L3, que ya está
comprobada contra el README de Gavira y Ruiz.
