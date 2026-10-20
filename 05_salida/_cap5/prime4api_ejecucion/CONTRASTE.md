# Contraste: PRIME4API (servicio, local) frente al cálculo a mano del capítulo 5

Ejecución del 2026-09-07 con `ejecutar_prime4api_PI.py` (servicio REST arrancado con uvicorn
sobre el clon de PRIME4API, commit en `RESULTADOS.md`). Cálculo a mano: `analisis.md` §(d)
y §5.3/§5.5 del capítulo. Cada fila remite al JSON con la petición y la respuesta íntegras.

## Resultado por pregunta

| PI | Qn | Endpoint del motor | Postmark (motor / a mano) | Resend (motor / a mano) | SendGrid (motor / a mano) | Veredicto |
|---|---|---|---|---|---|---|
| A06 | Q1 | `/min-time` (100.000, k = 1 y k máx) | **270 días** en Basic con cualquier k / «no: sin rate» | **30 d + 1 h 23 min 19 s** (k = 1), **30 d + 1 min 39 s** (k = 50) / 10.000 s y 200 s «exige cuota Scale o Pro 100k» | **30 d + 4 s** (k = 1), **30 d** (k = 1.000) / 10 s y 0,01 s «cuota Pro 100K» | Coincide en el tramo de *rate* (4.999 ≈ 5.000 s; 99 ≈ 100 s; 4 ≈ 5 s por la ráfaga en t = 0). El motor añade lo que a mano se dijo en prosa: 100.000 no cabe en la cuota de un mes y hay que esperar la renovación. **Postmark: sin rate el motor responde como si el rate fuese infinito** (270 días = 9 renovaciones de 10.000) |
| A07 | Q3 | `/capacity-at` (7 días, plan gratuito) | **100** / ≤ 100 | **710** / 700 | **800** / 700 | Coincide salvo la convención del instante final: en t = 7 días el motor abre la ventana siguiente y suma su primera ráfaga (Resend: +10, el rate; SendGrid: +100, el día entero porque 10.000/s lo cubre) |
| B01 | Q6 | `/budget/recommendation` (40.000/mes) | **Platform 54 < Pro 55,5 < Basic 69 USD** / 54, 55,50, 69 | **Pro 20 USD** / Pro 20 | **Essentials 19,95 USD** / 19,95 | Coincide. Los planes gratuitos salen `unreachable` (etiqueta `rate_limit`, aunque la causa es la cuota). **Con todos los planes falla**: Resend 500 (Enterprise con rate vacío 🔴) y SendGrid 400 (`custom`, DV-03); hay que filtrar planes |
| B02 | Q7 | `/quotas` + `/capacity-at` (1 mes, presupuesto 50 USD) | **58.889 / 71.538 / 73.333** (Basic/Pro/Platform) / 29.444 / 35.769 / 36.666 | **83.343** en Pro / 116.666 | **82.594** en Essentials / 116.722 | Postmark: el motor devuelve **exactamente el doble** (58.888,9 = 2 × 29.444,4): en t = 1 mes cuenta la ventana siguiente entera porque sin rate la cuota expandida se consume al instante. Resend y SendGrid: el motor solo conoce el primer volumen de cada plan (F-02), de ahí 83.333 = 50.000 + (50 − 20)/0,0009 y 72.594 = 50.000 + (50 − 19,95)/0,00133, más la ráfaga de la ventana siguiente (+10 y +10.000). A mano se usó el segundo volumen (Pro 100K a 35 USD, Essentials 100K a 34,95), que no está en el YAML. **Las dos respuestas son correctas para lo que cada uno ve** |
| B03 | Q10 | `/budget/recommendation` (12.000/mes) | **Basic 18,6 < Pro 19,1 < Platform 20,4** / 18,60 < 19,10 | **Pro 20** / Pro 20 (degenerada) | **Essentials 19,95** / 19,95 (degenerada) | Coincide |
| B05 | Q5 | `/demand-evaluation` (20.000 en 1 h) | **NO en los cuatro planes** (Basic: viola a los 1.800 s, 10.005 > 10.000) / «parcial: supera el arranque de 10.000» | **Pro y Scale YES; Free NO** (cuota, a los 18 s) / sí en Pro | **Essentials y Pro YES; Trial NO** / sí en Essentials | Coincide. En Postmark la etiqueta dice `rate_exceeded` pero el detalle es de cuota (sin rate en la Datasheet) |
| D01 | Q5 | `/quotas` + `/min-time` (cuota entera, k = 1) | **0 s** para 10.000 / «no: sin rate» | **1 h 23 min 19 s** / 83,3 min | **4 s** / 5 s | Coincide en Resend y SendGrid (cuota se agota antes que la ventana). **Postmark: 0 s = el motor lee «sin rate» como «sin límite»**; es la respuesta que P-04 quiere evitar |
| D02 | Q5 | `/rates` + `/capacity-at` (1 mes, presupuesto ∞) | rates `[]`; **1,1 · 10¹²** (acotado solo por el presupuesto) / «no» | rate 10/s; **25.920.010** / 25.920.000 | rate 10.000/s; **25.920.010.000** / 2,592 · 10¹⁰ | Coincide (+ la ráfaga de la ventana siguiente). Postmark: sin rate, la capacidad al mes solo la acota el presupuesto |
| D03 | Q9 | `/quota-exhaustion-threshold` | `[]` (sin rate) / «no» | **t de agotamiento por CRF**: 1 h 23 min (k = 1), 3 min 12 s (26), 1 min 39 s (50) / k* = 0,0019 | 4 s (k = 1), … / k* = 1,9 · 10⁻⁶ | **El motor no calcula k\***: su operación devuelve el tiempo en que cada cuota se agota para cada CRF; k* se deriva a mano de esos tiempos (k* es el CRF cuyo t de agotamiento iguala la ventana). Q9 tal como la define Gavira es sobre dos cuotas; aquí se traslada al par rate–cuota |
| G02 | Q10 | `/budget/recommendation` (25.000, primer plan de pago) | **Basic 42 USD** / 42 | **Pro 20** / 20 | **Essentials 19,95** / 19,95 | Coincide |

**Recuento:** 10 preguntas P × 3 APIs = 30 instancias. 26 coinciden con el cálculo a mano
o lo completan; 3 difieren por convención del motor y se explican (A07 ventana siguiente,
B02 doble en Postmark, B02 volumen del YAML en Resend y SendGrid); 1 el motor no la
calcula directamente (D03, k\* derivado). Ninguna contradice el capítulo.

## Lo que la ejecución enseña (y el cálculo a mano no)

1. **«Sin rate» es «sin límite» para el motor.** Con `max_power` vacío (Postmark, 🔴) el
   motor responde t_min = 0 s, 270 días para 100.000 correos y una capacidad mensual
   acotada solo por el presupuesto. No se equivoca: hace lo que el esquema le deja hacer.
   Es exactamente la confusión que la propuesta P-04 del cap. 6 (distinguir «no publicado»
   de «sin límite») quiere impedir, ahora demostrada ejecutando.
2. **Los planes «custom» y los rates vacíos rompen las operaciones de presupuesto y
   demanda cuando se piden todos los planes** (SendGrid Premier: `could not convert string
   to float: 'custom'`, DV-03; Resend Enterprise: `float() argument must be … not
   'NoneType'`). Con `plan_names` filtrado funcionan. Ya estaba registrado como DV-03 en
   `DISCREPANCIAS_v03.md`; la ejecución lo confirma en dos operaciones más.
3. **Tres convenciones del motor** que hay que conocer para leer sus cifras: la primera
   ráfaga se cuenta en t = 0 (4.999 s frente a 5.000); el instante final de un intervalo
   abre la ventana siguiente (capacidad en «1 mes» incluye la ráfaga del mes siguiente); y
   la cuota expandida por presupuesto se aplica a cada ventana.
4. **El motor solo ve el primer volumen de cada plan** (F-02). Donde el cálculo a mano
   usó el segundo volumen (Pro 100K de Resend, Essentials 100K de SendGrid) el motor da
   otra cifra, correcta para el YAML. Es el argumento de P-01 con números.
5. **Q9 no tiene endpoint**: el umbral de agotamiento se da por CRF y k\* se deriva.
6. Las etiquetas `unreachable_reason: rate_limit` y `reason: rate_exceeded` aparecen
   cuando la causa real es la cuota. Candidato a issue en `prime4api` (comprobar antes si
   existe, regla del 2026-08-10).

## Añadido el 07-09 (noche): el servicio de SPHERE y la herencia de límites

Con SPHERE levantado en la máquina del autor, su PRIME4API (`rgavira123/prime4api`, hashes de
`capacity_curve_service.py`, `plotly_renderer.py` y `datasheet_evaluator_service.py` idénticos al
clon) devuelve para los cuatro paneles de la Figura 5.1 las mismas trazas que la ejecución como
biblioteca (`gen_fig_capacidad.py servicio`). Dos observaciones nuevas:

- **Herencia aditiva.** `_get_node_scenarios` parte de los límites del plan y añade los del
  endpoint. SendGrid repite `quota` y `rate` en `/v3/mail/send`, así que el motor ve dos rates y
  dos cuotas iguales. Dos cuotas iguales no cambian nada; dos rates iguales sí: con k = 1 la curva
  hace meseta en el primer segundo ((0, 10.000), (1, 10.000), (5, 50.000)) y con k = 1.000 los puntos a 30 días (`data/inflection`) llegan a
  100.000, el doble de la cuota (la gráfica sobre 5 s, `chart/inflection`, se queda en 50.000: los dos
  endpoints no coinciden entre sí). Sin la repetición coincide con el cálculo a mano. Resend solo
  repite la cuota y por eso no se ve afectado. Abierta 13 de `abiertas.md`.
- **`/capacity-curves/data/inflection` con dos rates iguales no responde** (más de 12 s en tres
  intentos; con uno responde al instante). Candidato a issue, comprobar antes.

## Qué cambia en el capítulo

- §5.4: las 10 P pasan de «clasificadas por especificación» a **ejecutadas**; la
  cobertura del 75 % deja de ser declarada. Las 4 H siguen sin ejecutar (HARVEY4API exige
  el despliegue y una clave de OpenAI).
- §5.3: la Figura 5.1 pasa de «biblioteca porque el servicio no es accesible» a «biblioteca y
  después el servicio que despliega SPHERE, trazas iguales»; párrafo del motor con la regla de
  herencia (07-09, noche).
- §5.3 y §5.5: el cálculo a mano se mantiene como está y se dice que el motor lo
  reproduce, con las tres convenciones.
- §5.6: la reserva «PRIME4API no se ha ejecutado» se reescribe.
- Cap. 6: P-04 gana la evidencia del punto 1; F-02/P-01 la del punto 4.

Reejecución tras D-024 (rate de Postmark adoptado en ámbar): `../prime4api_ejecucion_d024/CONTRASTE.md`
