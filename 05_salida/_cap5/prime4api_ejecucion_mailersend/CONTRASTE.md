# Contraste: PRIME4API (servicio de SPHERE, local) frente al cálculo a mano, MailerSend

> **Reejecutado el 2026-09-10.** Después de que la Datasheet adoptara los tres aliases de estado
> (D-025), las diez preguntas P se repitieron contra el mismo servicio en
> `../prime4api_ejecucion_mailersend_2026-09-10/`. Las cifras de este fichero **no cambian**: lo
> que cambia es que cada fila del motor llega etiquetada con su alias. Esta carpeta conserva la
> ejecución del 2026-09-08, que es la que contrasta el motor con el cálculo a mano llamada a
> llamada; la nueva solo contrasta las dos ejecuciones entre sí.

Ejecución del 2026-09-08 (19:35 UTC) contra el PRIME4API que despliega SPHERE en la máquina del autor
(localhost:8003, imagen `rgavira123/prime4api`), llamado desde su navegador con el plan de
`ejecutar_prime4api_PI.py plan mailersend` e importado con `importar` (origen en `ORIGENES.json`).
Datasheet: `03_datos/apis/mailersend/datasheet.yaml` del 2026-09-08 (sin el bloque `metadata`, que el
motor no lee). Cada fila remite al JSON con la petición y la respuesta íntegras.

Las 15 respuestas se han reproducido en el contenedor con el clon de `~/.cache/atf/prime4api`
(commit `8e6011c4`, el mismo código que la imagen según los hashes anotados en
`../prime4api_ejecucion/CONTRASTE.md`): `BoundedRate`, `BudgetService.compute_recommendation`,
`DemandEvaluatorService.evaluate` y `DatasheetEvaluatorService.get_curve_scenarios` sobre el YAML.
Las 15 coinciden cifra a cifra con lo que devolvió SPHERE, así que las convenciones que siguen se
han leído en el código y no se infieren de la salida.

## Datos de partida (lo que dice la Datasheet)

- `/v1/email`: rate 120 peticiones/min en los cuatro planes (`rate_request_email_*`). Workload 1–70
  correos por petición (🟡, suma aritmética de 50 to + 10 cc + 10 bcc). k = 1 y k = 70.
- Cuotas de correos en `/v1/email`, ventana de 30 días (`fixed_billing_cycle`): Free 500 sin
  sobrecoste, Hobby 5.000 a 7 USD con 0,0015 USD/correo, Starter 50.000 a 35 USD con 0,0013,
  Professional 50.000 a 110 USD con 0,0013.
- Cuota diaria de peticiones a nivel de plan (`plans.<plan>.quota`, unidad `requests`, medianoche
  UTC): Free 100, Hobby 1.000, Starter 100.000, Professional 500.000. A k = 1 acota Hobby a 1.000
  correos/día (30.000 al mes) y a k = 70 a 70.000 correos/día.
- El `/*` a 60/min es otro endpoint y no interviene. `quota_email_daily_free` (100 correos/día, 🟡) no
  se referencia desde ningún plan y el motor no la ve, por decisión de la Datasheet.
- Convenciones del motor ya conocidas (CONTRASTE anterior): la primera ráfaga se cuenta en t = 0; el
  instante final de un intervalo abre la ventana siguiente; sin `max_budget` la cuota es dura; la
  cuota expandida por presupuesto se aplica a cada ventana; el plan y el endpoint heredan y suman.

## Resultado por llamada

Columna «a mano»: la respuesta que sale de la Datasheet con todos sus límites. Cuando la cuota
diaria de peticiones cambia la respuesta se da la cifra con ella y, entre paréntesis, la que sale del
par rate–cuota mensual solo (que es lo que el motor evalúa: hallazgo H1).

| # | PI | Qn | Llamada | Cálculo a mano desde la Datasheet | Motor | Veredicto |
|---|---|---|---|---|---|---|
| 1 | A06 | Q1 | `/min-time` 100.000, Hobby, k = 1 | Con sobrecoste la cuota mensual no para: 100.000 peticiones a 120/min son 833 min (13 h 53 min). La cuota diaria de 1.000 peticiones acota a 1.000 correos/día: **99 días y 8 min** (100 días). | **570 d 41 min** | **Difiere por convención**: sin `max_budget` el motor trata la cuota de 5.000 como dura aunque tenga `overage_cost` (19 renovaciones × 30 d = 570 d, más los 5.000 restantes a 120/min = 41 min). Misma convención que dio «30 d + …» en Resend y SendGrid. El sobrecoste solo entra por `max_budget` (`_process_node` → `expand_quotas`); `/min-time` admite el parámetro y no se pidió. Además H1: la cuota diaria no cuenta |
| 2 | A06 | Q1 | `/min-time` 100.000, Hobby, k = 70 | 1.429 peticiones a 120/min: 11 min por rate. Con 70.000 correos/día de cuota diaria: **1 d 3 min** (2 días). | **570 d** | **Difiere por convención** (la misma): 19 renovaciones y los 5.000 restantes caben en la ráfaga de t = 0 (8.400 ≥ 5.000). H1 |
| 3 | A07 | Q3 | `/capacity-at` 7 d, Free, k = 1 | Cuota dura de 500 en 30 días: **500**. La diaria (100 peticiones) daría 700 en 7 días y no muerde. | **500** | **Coincide**. En t = 7 d no se abre ventana nueva (30 d), así que aquí no aparece la ráfaga siguiente que se vio en Resend y SendGrid |
| 4 | B01 | Q6 | `/budget/recommendation` 40.000, todos los planes | Starter 35 (cuota 50.000 cubre). Hobby 7 + 35.000 × 0,0015 = **59,5**. Professional 110. Free inalcanzable: 500 sin sobrecoste. Más barato: **Starter, 35 USD**. | Starter **35** < Hobby **59,5** < Professional **110**; Free `unreachable`, `rate_limit` | **Coincide**. Con todos los planes no falla (no hay precio `custom` ni rate vacío: Enterprise no está modelado). La etiqueta `rate_limit` del Free es la convención de etiquetas (H4): la causa es la cuota sin sobrecoste. La fila Hobby dice alcanzable en 5 h 33 min (333 min = ⌈40.000/120⌉ − 1); a k = 1 la cuota diaria lo deja en 30.000 al mes y 40.000 exige k ≥ 2 (H1). La recomendación no cambia |
| 5 | B01 | Q6 | `/budget/recommendation` 40.000, planes calculables | Igual que #4. | Igual que #4 | **Coincide** (la segunda llamada solo existía por si la primera fallaba, como en Resend y SendGrid) |
| 6 | B02 | Q7 | `/quotas` con `max_budget` 50 | Dos cuotas por plan, la del plan y la del endpoint: Free 100 pet./día y 500; Hobby 1.000 pet./día y 5.000 (0,0015); Starter 100.000 pet./día y 50.000 (0,0013); Professional 500.000 pet./día y 50.000 (0,0013). | Las mismas ocho cuotas, sin expandir | **Coincide**. Muestra la herencia (la cuota del plan aparece junto a la del endpoint). La ruta `/quotas` no acepta `max_budget` y devuelve las cuotas del YAML: la expansión hay que leerla en `/capacity-at` (#7) |
| 7 | B02 | Q7 | `/capacity-at` 1 mes, `max_budget` 50, k = 1 | Free: **500** (sin sobrecoste, los 50 USD no compran nada). Hobby: 5.000 + (50 − 7)/0,0015 = **33.666** si k ≥ 2; a k = 1 la cuota diaria lo deja en **30.000** (44,5 USD). Starter: 50.000 + (50 − 35)/0,0013 = **61.538**. Professional: **no asequible** (110 > 50). | Free **620** · Hobby **33.786,67** · Starter **61.658,46** · Professional **50.120** | **Difiere por convención** en Free, Hobby y Starter: en t = 1 mes = 30 d el motor abre la ventana siguiente y suma su primera ráfaga (+120 = R × 1 min): 620 = 500 + 120, 33.786,67 = 33.666,67 + 120, 61.658,46 = 61.538,46 + 120. Professional es **hallazgo nuevo** (H2): con el presupuesto por debajo del precio del plan el motor devuelve la cuota base más la ráfaga en vez de señalar que el plan no es asequible. Hobby a k = 1 también H1 |
| 8 | B03 | Q10 | `/budget/recommendation` 12.000 | Hobby 7 + 7.000 × 0,0015 = **17,5** < Starter 35 < Professional 110. Free inalcanzable. Sobrecoste gana a subir de plan. A k = 1, 12.000 son 12 días de cuota diaria: cabe. | Hobby **17,5** < Starter **35** < Professional **110**; Free `rate_limit` | **Coincide** (1 h 39 min = 99 min = ⌈12.000/120⌉ − 1) |
| 9 | B05 | Q5 | `/demand-evaluation` 20.000 en 1 h, k = 1 | 20.000/h = 333,3 peticiones/min > 120/min: **NO en los cuatro planes por rate** (a k = 1 el máximo es 7.200/h; haría falta k ≥ 3). Primera violación: 5,556 × ⌊t + 1⌋ > 120 a partir de t = 21 s. | **NO** × 4, `rate_exceeded`, primera violación a 21,6 s (122,22 > 120) | **Coincide**, y aquí la etiqueta `rate_exceeded` dice la causa real. Los 21.643 ms de Free y Hobby frente a 21.632 ms de Starter y Professional son la malla de muestreo (2.000 puntos más los instantes críticos de cada cuota), no una diferencia de límites |
| 10 | D01 | Q5 | `/quotas` Hobby | 1.000 peticiones/día (plan) y 5.000 correos/30 d con 0,0015 (endpoint). | Las dos | **Coincide** |
| 11 | D01 | Q5 | `/min-time` 5.000, Hobby, k = 1 | Al rate: 5.000/120 = 41,67 min (41 min con la ráfaga en t = 0). La cuota mensual se agota mucho antes de los 30 días: manda la cuota. Pero antes se agota la diaria: 1.000 peticiones a 120/min son **8 min 20 s**, y los 5.000 tardan **4 d 8 min** de calendario (5 días a 1.000/día). | **41 min** | **Coincide** en el veredicto (la cuota se agota antes que la ventana, el rate no es la restricción activa) y en la cifra del par rate–cuota mensual. La cuota que se agota primero en Hobby es la diaria y el motor no la ve (H1) |
| 12 | D02 | Q5 | `/rates` Hobby, k = 1 | 120 peticiones/min (el plan no tiene rate propio; `/*` es otro endpoint). | 120 requests/1min | **Coincide** |
| 13 | D02 | Q5 | `/capacity-at` 1 mes, `max_budget` 10⁹, Hobby, k = 1 | R · W · k = 120 × 43.200 min = **5.184.000** por rate. Con la cuota diaria: 1.000 × 30 = **30.000** (a k = 70: 2.100.000). | **5.184.120** | **Coincide** con el techo por rate (+120 de la ráfaga de la ventana siguiente; la cuota expandida a 6,7 · 10¹¹ supera lo que el rate da en 30 días y `BoundedRate` la omite, así que solo queda el rate). El techo real de Hobby es 173 veces menor por la cuota diaria (H1) |
| 14 | D03 | Q9 | `/quota-exhaustion-threshold` Hobby, sin CRF | k = 1: (5.000 − 120)/120 = 40,67 → **41 min**. k = 36: 4.320/min, 2 ráfagas → **1 min**. k = 70: 8.400 ≥ 5.000 → **0 s**. k\* (agotar 5.000 justo en 30 d) = 5.000/(120 × 43.200) = **0,00096**: para todo k ≥ 1 la cuota mensual se agota antes que la ventana. Con la diaria: 1.000 a 120/min se agotan en 8 min para k = 1. | k = 1 **41 min** · k = 36 **1 min** · k = 70 **0 s** | **Coincide**. Sin `capacity_request_factor` el motor evalúa tres escenarios del workload (`_build_scenarios`): mínimo 1, medio round((1 + 70)/2) = round(35,5) = **36** (redondeo al par de Python, como el 26 de Resend con 1–50) y máximo 70. Como en las otras APIs, k\* se deriva a mano: el motor da el tiempo de agotamiento por CRF, no el CRF que iguala cuota y ventana |
| 15 | G02 | Q10 | `/budget/recommendation` 25.000, Hobby | 7 + 20.000 × 0,0015 = **37 USD** (más que Starter a 35, que ya cubre 25.000). A k = 1 son 25 días de cuota diaria: cabe. | **37** (30 de sobrecoste), 3 h 28 min | **Coincide** (208 min = ⌈25.000/120⌉ − 1) |

**Recuento:** 15 llamadas. **12 coinciden** con el cálculo a mano (#3, #4, #5, #6, #8, #9, #10,
#11, #12, #13, #14, #15). **3 difieren por convención** conocida del motor y se explican (#1 y #2,
cuota con sobrecoste tratada como dura sin `max_budget`; #7, ráfaga de la ventana siguiente en
t = 30 d). **2 hallazgos nuevos** sobre el motor (H1, la cuota diaria de peticiones del plan no
entra en la dimensión `emails`, y afecta a la lectura de #1, #2, #4, #7, #11 y #13 sin cambiar
ningún veredicto de plan más barato; H2, `/capacity-at` con presupuesto menor que el precio del plan,
visible en #7). Ninguna respuesta contradice el capítulo: los tres veredictos de precio (Starter 35,
Hobby 17,5, Hobby 37) y los dos de demanda (NO por rate, cuota antes que rate) son los del cálculo a
mano.

## Hallazgos sobre el motor con MailerSend

**H1. La cuota de plan en `requests` se hereda pero no se convierte a la unidad de workload.**
`_get_node_scenarios` parte de los límites del plan y añade los del endpoint (la regla «hereda y
suma» de SendGrid), y `/quotas` lo muestra: las dos cuotas de Hobby aparecen (#6, #10). Pero
`_build_scenarios` (`datasheet_evaluator_service.py`, líneas 122–161) construye la dimensión
`emails` así: rates en `emails` tal cual, rates en `requests` multiplicados por w (120 → 120 · k),
cuotas en `emails` tal cual, y las cuotas en `requests` **no se añaden** (`sc_quotas_wl =
list(quotas_wl)`). La dimensión `requests` sí recibe las dos (la mensual pasa a ⌊5.000/k⌋
peticiones), pero las diez preguntas P piden `capacity_unit=emails` y la ruta de presupuesto descarta
las filas `requests`. Reproducido con `get_curve_scenarios` sobre el YAML: para Hobby `/v1/email`,
k = 1, la dimensión `requests` lleva `[1000 req/1day, 5000 req/1month]` y la dimensión `emails`
solo `[5000 emails/1month]`. En SendGrid no se notó porque plan y endpoint repiten la misma cuota en
`emails` (dos cuotas iguales); en Resend solo se repite la cuota. MailerSend es la primera API del
catálogo cuya cuota de plan tiene otra unidad que la del endpoint, y es la restricción activa de
Hobby a k = 1: 1.000 peticiones al día se agotan en 8 min a 120/min y el resto del día queda
ocioso, de modo que el techo mensual son 30.000 correos y no los 5.184.000 del rate (#13) ni los
33.666 del presupuesto (#7). Con k = 70 la diaria sube a 70.000 correos/día y deja de morder frente
a la mensual de 5.000. Reejecutando `BoundedRate` con la cuota diaria convertida (1.000 · k
correos/día) salen las cifras «a mano» de la tabla: 99 d 8 min y 1 d 3 min para 100.000 correos con
sobrecoste, 4 d 8 min para agotar los 5.000, 30.120 al mes a k = 1. Asimetría de diseño (el
docstring de `_build_scenarios` solo contempla «req-rates multiplied by w»), no un error de
cálculo. Candidato a issue en `prime4api`; comprobar antes si existe (regla del 2026-08-10). Para
el capítulo: la relación límites–rates de MailerSend tiene tres límites en juego (rate por minuto,
cuota diaria de peticiones, cuota mensual de correos con sobrecoste) y el motor razona con dos.

**H2. `/capacity-at` con `max_budget` menor que el precio del plan devuelve la cuota base.**
`expand_quotas` devuelve `(quotas, 0.0, False)` cuando `max_budget − price < 0`, y `_process_node`
descarta la bandera (`quotas, _, _ = …`). Professional con 50 USD responde 50.120 (#7): la cuota de
50.000 más la ráfaga, como si el plan costase 50 USD o menos. `/budget/recommendation` sí lo marca
(`affordable: false`, `budget_limit`) porque la bandera se lee en `compute_recommendation`. Para
las tres APIs anteriores pasó lo mismo con SendGrid Pro (89,95 USD) en B02: `PI-B02_sendgrid.json`
devuelve 110.000 (100.000 de cuota más la ráfaga de 10.000) con 50 USD, y no se anotó. Al leer
B02 hay que cruzar `/capacity-at` con el precio del plan. Candidato a issue; comprobar antes.

**H3 (convención, confirmada en código). Sin `max_budget` la cuota con sobrecoste es dura.** El 570 d
41 min de A06 y el 52,5 USD de sobrecoste de B01 son el mismo motor por dos puertas: `/min-time` sin
presupuesto construye el `BoundedRate` con la cuota tal cual y espera 19 renovaciones;
`/budget/recommendation` expande la cuota justo hasta la demanda (`expand_quota(q, cost_at(q,
desired))`) y luego mide el tiempo. Para que A06 responda «con sobrecoste» hay que pasar
`max_budget` a `/min-time`, que lo admite. Ya se vio en Resend y SendGrid («30 d + …»); aquí, con una
cuota más pequeña, el efecto es de 570 días y se lee mejor.

**H4 (convención, explicada). `unreachable_reason: rate_limit` cuando la causa es una cuota sin
sobrecoste.** `_reachable_in_period` solo distingue `budget_limit` (alcanzable si se expandieran las
cuotas **con** `overage_cost`) de todo lo demás, que etiqueta `rate_limit`. El Free tiene la cuota
sin sobrecoste, así que no se expande, sigue sin alcanzarse y cae en `rate_limit` (#4, #5, #8). No
existe una etiqueta de «cuota dura». Completa el punto 6 del CONTRASTE anterior con la línea de
código que lo produce. En `/demand-evaluation` la etiqueta se decide comparando la capacidad en el
primer periodo del rate (`rate_exceeded` si la demanda ya supera al plan en el primer minuto), y en
B05 es correcta: 333/min contra 120/min.

**H5 (convención). Sin CRF, tres escenarios del workload: mínimo, medio y máximo.** El 36 de D03 es
round((1 + 70)/2) con el redondeo al par de Python (35,5 → 36), igual que el 26 de Resend (1–50). El
escenario medio no responde a nada de la Datasheet y no se usa en el capítulo.

**Observaciones menores.** (a) B01 con todos los planes no falla en MailerSend: los cuatro planes
tienen precio numérico y rate, y Enterprise no está modelado (precio no publicado); la llamada
duplicada sobra aquí y se conserva por simetría con las otras APIs. (b) Las diferencias de 11 ms en
`first_violation_at_ms` entre planes (B05) vienen de la malla de muestreo, no de los límites. (c) El
`wl_max_eff` de `_build_scenarios` acota el workload máximo a la cuota más pequeña en `emails`
(70 < 500): no interviene en MailerSend, pero intervendría en una API con cuota gratuita menor que
el lote.

## Curvas de capacidad (servicio de SPHERE)

Series de `POST /capacity-curves/data/inflection` (Hobby, `/v1/email`, `time_interval` 1 mes) y
figura de `/chart/inflection` extraída en el navegador (`png/mailersend_hobby_k{1,70}.json`; las
notas `.NOTA.txt` explican por qué el HTML no se archivó íntegro). PNG en
`02_overleaf/proyecto/fig/capacidad_mailersend_hobby_k{1,70}.png`.

**Lo que dibuja el servicio.** k = 1: `rates = [120 emails/1min]`, `quotas = [5000 emails/30day
(0,0015)]`, puntos (0 s, 120), (40 min, 4.920), (41 min, 5.000), (30 d, 5.000). Es 120 · (⌊t/1 min⌋
+ 1) hasta tocar 5.000 en el minuto 41 y meseta el resto del mes. El PNG (`Time (h)`, eje 0–1 h,
título «CRF = 1.0») muestra la rampa hasta 5.000 en t ≈ 0,68 h y la meseta hasta la hora; el
`<title>` del HTML dice «1 hour», que es el intervalo pedido al `chart` (los puntos sobre 30 días
son los del `data`). k = 70: `rates = [8400 emails/1min]`, misma cuota, puntos (0 s, 5.000) y (30 d,
5.000): la ráfaga de t = 0 (8.400) ya supera la cuota y la curva es una recta en 5.000; el PNG
(`Time (min)`, eje 0–1 min, «CRF = 70.0») la muestra plana. Las dos coinciden con el cálculo a mano
del par rate–cuota mensual: t de agotamiento 41 min (k = 1) y 0 s (k = 70), los mismos de D03.

**Lo que falta en la serie (H1).** Las series llevan un rate y una cuota. La cuota de plan (1.000
peticiones/día) no está, por la asimetría de `_build_scenarios`. Compárese con SendGrid Essentials
k = 1 (`sendgrid_essentials_k1_data.json`): dos rates iguales y dos cuotas iguales, porque plan y
endpoint repiten los límites en `emails`; y con Resend Pro: un rate y dos cuotas iguales. En
MailerSend la cuota heredada existe pero en `requests`, y desaparece al pasar a `emails`. Con ella,
la curva de k = 1 sería una escalera: (0, 120) → (8 min, 1.000) → meseta hasta medianoche UTC →
+1.000 cada día → 5.000 en el día 5 (4 d 8 min) → meseta hasta los 30 días. Sobre el eje de una hora
del PNG, la curva real se aplana en 1.000 al minuto 8 en vez de subir hasta 5.000 en el minuto 41.
La de k = 70 no cambia (70.000/día > 5.000). Consecuencia para la Figura 5.1: el panel Hobby k = 1
representa el par rate–cuota mensual que el motor evalúa, no la capacidad de Hobby a k = 1, y el pie
o la prosa tienen que decirlo. Si se quiere la curva con los tres límites hay dos caminos, y ninguno
es del carril verde: declarar la cuota diaria también en `emails` en el endpoint (falsearía la
unidad que publica el proveedor) o dibujarla con `BoundedRate` a mano fuera del servicio (dejaría de
ser «la figura que devuelve SPHERE»). Se anota como pregunta para el autor, no se decide.

**Comprobación de coherencia con las otras APIs.** Misma plantilla Plotly que Resend
(`layout.template` con el mismo sha256 canónico, según las notas), mismo tipo de curva
(`inflection`), mismos ejes. La ventana «1 month» del motor son 30 días exactos
(`TimeUnit.MONTH = 2.592.000.000 ms`), que coincide con el «resets every 30 days» de MailerSend: es
la única API del catálogo donde la ventana de la Datasheet y el «mes» del motor son literalmente la
misma cosa.

## Qué cambia en el capítulo

- §5.2.4 (MailerSend): las 10 P ejecutadas con el servicio de SPHERE, 15 llamadas, 12 coinciden,
  3 por convención, 2 hallazgos. Las cifras de precio (Starter 35 para 40.000; Hobby 17,5 para
  12.000; Hobby 37 para 25.000, con Starter a 35 más barato) y de demanda (NO a 20.000/h por rate)
  son las del motor y del cálculo a mano.
- §5.3: MailerSend aporta el caso de tres límites con dos unidades (rate/min en peticiones, cuota
  diaria en peticiones, cuota mensual en correos con sobrecoste), en el que la restricción activa
  de Hobby a k = 1 es la cuota diaria (8 min de envío al día) y no el rate ni la mensual. El motor
  ve dos de los tres (H1). Figura 5.1, panel Hobby k = 1: decir qué par representa.
- §5.5: H3 explica por qué A06 devuelve 570 días y B01 acepta el sobrecoste, sin contradicción.
- Cap. 6: H1 es un caso para la discusión de unidades (la Datasheet declara `consumption_units`
  requests, emails y MBs y el motor solo cruza rates entre unidades); anotar como fricción de
  herramienta, no de esquema, salvo que el autor decida otra cosa. H2 y H1 candidatos a issue en
  `prime4api`, comprobar antes.
- Preguntas para el autor: (1) si la Figura 5.1 de Hobby k = 1 se deja como la devuelve SPHERE con
  nota, o se genera una segunda con los tres límites; (2) si A06 se reejecuta con `max_budget` para
  tener también la respuesta «con sobrecoste» del motor (13 h 53 min por rate).
