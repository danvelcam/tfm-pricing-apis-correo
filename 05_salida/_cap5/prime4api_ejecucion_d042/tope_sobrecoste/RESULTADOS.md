# F-16 ante la condición L2 del listón de D-042

**Fricción.** F-16 · El sobrecoste tiene un tope que impone el proveedor
(`03_datos/apis/sendgrid/fricciones.md` §F-16).

**Condición que se comprueba.** L2 de D-042: PRIME4API, con la Datasheet del catálogo
delante, devuelve un valor falso o deja sin responder lo que respondería si el esquema
expresara la carencia.

**Ejecución.** 2026-09-15, contra el PRIME4API que despliega SPHERE en local
(`http://localhost:8003/api/v1/datasheet`, contenedor `prime4api-sphere`, imagen
`rgavira123/prime4api`; salud `{"status":"ok"}`). Once llamadas, un JSON por llamada en
esta carpeta, con petición y respuesta íntegras. La undécima es el caso de control del
campo `unreachable`, ejecutada el mismo día a las 13:43 y archivada después de que la
verificación adversarial encontrara que la ficha lo citaba sin tenerlo.

**La Datasheet no se tocó.** Se envió `03_datos/apis/sendgrid/datasheet.yaml` tal cual
está en el catálogo, como `datasheet_source`. sha256
`a73d81c000dee8896e74cc816eda8e05203ddc13aaea670fd866ae27af99d597`. Repositorio en
`3c1d7b8`.

---

## Qué se preguntó

Plan **Essentials 50K**, endpoint `/v3/mail/send`, unidad `emails`. La prueba es un par:
un objetivo **por debajo** del tope real (400.000) y otro **por encima** (600.000). Si el
motor no distingue, las dos respuestas salen del mismo cálculo lineal.

| # | Fichero | Pregunta |
|---|---|---|
| 01 | `01_min-time_400k_cuota_dura.json` | `min-time` 400.000, k = 1, sin presupuesto |
| 02 | `02_min-time_600k_cuota_dura.json` | `min-time` 600.000, k = 1, sin presupuesto |
| 03 | `03_min-time_400k_presupuesto_amplio.json` | `min-time` 400.000, k = 1, `max_budget` 1e9 |
| 04 | `04_min-time_600k_presupuesto_amplio.json` | `min-time` 600.000, k = 1, `max_budget` 1e9 |
| 05 | `05_min-time_600k_k_maximo.json` | `min-time` 600.000, k = 1.000, `max_budget` 1e9 |
| 06 | `06_budget_recommendation_400k.json` | `budget/recommendation` 400.000 en Essentials |
| 07 | `07_budget_recommendation_600k.json` | `budget/recommendation` 600.000 en Essentials |
| 08 | `08_capacity-at_1mes_presupuesto_amplio.json` | `capacity-at` 1 mes, k = 1, `max_budget` 1e9 |
| 09 | `09_quotas_presupuesto_amplio.json` | `quotas` con `max_budget` 1e9 |
| 10 | `10_quotas_sin_presupuesto.json` | `quotas` sin presupuesto (control) |
| 11 | `11_control_budget_100usd.json` | `budget/recommendation` 600.000 en Essentials, `max_budget` 100 (control) |

## Qué respondió el motor

Las once llamadas devolvieron **HTTP 200**. Las diez primeras no avisaron de nada.

| Operación | 400.000 (bajo el tope) | 600.000 (sobre el tope) |
|---|---|---|
| `min-time`, cuota dura | `210day4s` | `330day4s` |
| `min-time`, presupuesto que no limita | **`39s`** | **`59s`** |
| `min-time`, k = 1.000, presupuesto que no limita | — | **`0s`** |
| `budget/recommendation` | 19,95 + 465,50 = **485,45 USD** | 19,95 + 731,50 = **751,45 USD** |
| … con `affordable` / `unreachable` | `true` / `false` | **`true` / `false`** |
| … con `time_to_capacity` | `39s` | `59s` |

Y el techo que el motor ve en un mes, con presupuesto que no limita
(`08_capacity-at_1mes_presupuesto_amplio.json`):

```
25 920 010 000 emails
```

Son **51.840 veces** el tope real de 500.000. La cifra es la del caudal: 10.000 req/s
durante 30 días. La cuota no la frena porque el sobrecoste la expande sin límite.

`quotas` devuelve lo mismo con presupuesto y sin él: `value: 50000` con
`overage_cost: {price: 0.00133, value: 1}`. No hay campo donde mirar un tope.

**El paso de 400.000 a 600.000 solo cambia la proporción.** El sobrecoste es lineal:
350.000 × 0,00133 = 465,50 y 550.000 × 0,00133 = 731,50. El motor cruza los 500.000 sin
que nada cambie de forma en la respuesta.

**Matiz sobre las dos primeras filas.** En el régimen de cuota dura (sin `max_budget`) el
motor reparte el volumen en renovaciones mensuales: 400.000 son ocho ciclos y 600.000 son
doce. Esas dos respuestas **no** las falsea F-16, porque ningún mes pasa de 500.000. Están
aquí como control: enseñan que la respuesta falsa aparece exactamente cuando entra en
juego el sobrecoste, que es lo que el esquema modela sin tope.

**El caso de control del campo `unreachable`** (`11_control_budget_100usd.json`). Misma
pregunta que la llamada 07 —600.000 correos en Essentials—, misma Datasheet, mismo sha256,
y `max_budget` en **100 USD**. El motor responde:

```
"affordable": false, "unreachable": true, "unreachable_reason": "budget_limit"
```

Los tres costes son idénticos a los de la llamada 07: 19,95 + 731,50 = 751,45 USD. Lo
único que cambia es el veredicto. Así que el `unreachable: false` de la llamada 07 **es
una afirmación viva del motor y no un campo muerto**: cuando el documento le da un motivo
para negarse, se niega, y además dice cuál. Lo que no tiene es un motivo por el tope del
sobrecoste, porque `overage_cost` solo admite `price` y `value`.

Nota sobre lo que el control **no** demuestra. La razón que emite es `budget_limit`, o sea
que el coste no cabe en el presupuesto, no que el volumen sea inalcanzable. El campo es el
mismo y el mecanismo también —una condición del documento que apaga el objetivo—, pero la
vía es otra: el motor tiene `no_overage`, que marca `unreachable` con razón
`overage_required`, y no tiene ninguna que mida un tope de sobrecoste.

## Qué publica el proveedor

> *"Starting March 26, 2026, a sending limit was applied to accounts under the Email API
> Essentials and Pro plans, capping their allotment to 10X times the plan. For example, if
> your account is under the Email API Essentials 50K plan, you can send up to 500,000
> requests to our server throughout the month."*

Fuente **[F18]**, Centro de soporte de SendGrid, *Understanding the "Maximum Credits
Exceeded" error*,
`https://support.sendgrid.com/hc/en-us/articles/35466138799899-Understanding-the-Maximum-Credits-Exceeded-error`,
acceso 2026-09-06. Ficha completa en `03_datos/apis/sendgrid/fuentes.md` §[F18]. Por
encima de esa cifra el envío no se cobra como sobrecoste: se rechaza con `Maximum credits
exceeded` ([F19], error 60603 de Twilio). El proveedor lo razona: *"it is in our
customer's best interest to upgrade to a higher volume plan than to continue paying
overages"*.

El tope está en un artículo de resolución de errores, no en la página de precios ni en el
artículo de sobrecostes [F8]. Una cuenta de reseller lo tiene en 2,5 × el plan.

Nota de unidad: el proveedor cuenta **requests** (`"Requests = Processed + Dropped"`) y la
Datasheet cuenta `emails`. Con k = 1 coinciden. Con k > 1 el tope real llega **antes** en
correos, así que el error del motor solo crece: la respuesta `0s` de la llamada 05 es la
más falsa de las tres.

## Veredicto

**L2 CUMPLIDA.**

1. El motor declara alcanzable un objetivo que el proveedor rechaza: 600.000 correos en
   **59 s** por **751,45 USD**, con `unreachable: false`, cuando el tope publicado son
   500.000 al mes.
2. Bajo el tope y sobre el tope responde con el mismo cálculo lineal, así que no es que
   yerre el número: es que no tiene dónde saber que hay una frontera.
3. El campo que expresaría la carencia **ya existe en la respuesta** (`unreachable`, hoy
   `false`): un `max` en `overage_cost` lo pondría en `true` y el motor dejaría de
   afirmar lo que afirma.
4. El control lo confirma con la misma Datasheet y la misma pregunta: con `max_budget` en
   100 USD el motor devuelve `unreachable: true` y su razón, `budget_limit`
   (`11_control_budget_100usd.json`). El `false` de la llamada 07 es entonces afirmación
   suya, no ausencia de cálculo.

Con L1 y L3 ya marcadas en D-042, F-16 pasa el listón del caso medido y se promueve por la
vía `traza`.
