# Contraste: PRIME4API frente al cálculo a mano — segunda tanda, cuatro APIs nuevas

Ejecución del 2026-09-21 contra el PRIME4API que despliega SPHERE en local
(`localhost:8003`, imagen `rgavira123/prime4api`, contenedor `prime4api-sphere`), con
`ejecutar_prime4api_PI.py` en modo `plan` + `importar`. Las mismas diez preguntas de clase P
que la tanda del 2026-09-07, ahora sobre Brevo, Amazon SES, Mailgun y Mailchimp Transactional.
Cada fila remite al JSON con la petición y la respuesta íntegras.

**El eje de instanciación se resolvió por E16** (consejo del 2026-09-21): donde la Datasheet no
declara el eje que la pregunta nombra, no se sustituye por el más parecido; se ejecuta lo
declarado y la respuesta se rotula con el `alias` que devuelve el propio motor. Muerde en dos
de las cuatro:

- **SES** no tiene plan gratuito —su capa gratuita está en discrepancia registrada, ni
  confirmada ni desmentida— y empata dos planes en `price: 0.00`, `a_la_carte` y `essentials`.
  Ningún campo desempata, así que PI-A07 se ejecuta sobre **los dos**. Y ningún plan de SES liga
  volumen: las diez preguntas las contesta el alias `sandbox`, que es el estado restringido.
- **Mailchimp** tiene un solo plan y su escalón gratuito es el alias `demo`. Gratuito y primer
  plan de pago son el mismo nombre.

Brevo y Mailgun tienen los tres ejes y no necesitan la regla.

## Resultado por pregunta

| PI | Qn | Endpoint del motor | Brevo (motor / a mano) | SES (motor / a mano) | Mailgun (motor / a mano) | Mailchimp | Veredicto |
|---|---|---|---|---|---|---|---|
| A06 | Q1 | `/min-time` (100.000, k = 1 y k máx, sin y con presupuesto) | **570 d 4 s** (k = 1), **570 d** (k = 2.000) en Starter / 19 renovaciones de 5.000 más 5 s de caudal, 4 s tras la ráfaga = 570 d 4 s. **Con `max_budget` no cambia nada** | **499 d 3 min 19 s** (k = 1), **499 d 3 s** (k = 50) en Pro `[sandbox]` / 499 renovaciones de 200 más 200 s a 1 req/s, 3 min 19 s tras la ráfaga. **Con presupuesto tampoco cambia** | **270 d 6 s** (k = 1), **270 d** (k = 1.000) en Basic; **con presupuesto baja a 1 min 6 s y a 0 s** / 9 renovaciones de 10.000 más 6,67 s; con la cuota expandida manda el caudal, 100.000/1.500 = 66,7 s | **500** ×4 | Coinciden las tres. El contraste entre ellas es el hallazgo: **el presupuesto solo expande la cuota que tiene `overage_cost`**. Mailgun lo tiene y pasa de 270 días a un minuto; Brevo y SES no lo tienen y no se mueven. Son los dos primeros casos negativos de D-037 en el catálogo |
| A07 | Q3 | `/capacity-at` (7 días, gratuito) | **2.400** en Free / 7 × 300 = 2.100 más la ráfaga de 300 | **1.401** en `a_la_carte` **y** 1.401 en `essentials`, las dos `[sandbox]` / 7 × 200 = 1.400 más la ráfaga de 1, que el rate de 1 req/s acota | **800** en Free / 7 × 100 = 700 más 100; la cuota mensual de 3.000 no ata a siete días | **500** | Coinciden, con la convención ya conocida del instante final. SES: **los dos planes que empatan a 0,00 devuelven la misma cifra**, que es la medida de que el eje de plan no informa |
| B01 | Q6 | `/budget/recommendation` (40.000/mes) | Con los cinco planes **400 `could not convert string to float: 'custom'`**; con los cuatro calculables **Professional 499 USD**, en dos filas, `[general]` a 39 s y `[advanced]` a 19 s / solo Professional (150.000/mes) llega | **200 con todos los planes**: `a_la_carte` **0,00** · `essentials` **0,00** · Pro 105 · Enterprise 500, los cuatro `[sandbox]` / ninguno incluye volumen, así que el coste que devuelve es la suscripción y no el envío | **200 con todos los planes**: Foundation 35 < Basic 69 (15 + 30.000 × 0,0018) < Scale 90; Free `unreachable` / idéntico | **500** | Mailgun es la **segunda API del catálogo** cuya B01 responde con todos los planes sin filtrar, tras Postmark. Brevo repite DV-03. **SES devuelve 0,00 USD para 40.000 correos y esa cifra es falsa**: el precio por destinatario no cabe en v0.3 y está en `not_found` |
| B02 | Q7 | `/quotas` + `/capacity-at` (1 mes, 50 USD) | Free **9.300** · Starter **6.000** · Standard **6.000** / 30 × 300 + 300 y 5.000 + 1.000 de ráfaga | **6.001** en los cuatro `[sandbox]` / 30 × 200 + 1; el presupuesto no expande nada | Free **3.100** · Basic **30.944,44** / 10.000 + (50 − 15)/0,0018 = 29.444,4 más 1.500 de ráfaga | `/quotas` **200**, `/capacity-at` **500** | Coinciden. Brevo deja el hallazgo más incómodo: **con 50 USD el plan gratuito da más correos al mes que el primer plan de pago**, 9.300 contra 6.000, porque 300 al día acumulados baten a 5.000 al mes. Y Starter y Standard, a 9 y 18 USD, devuelven la misma cifra |
| B03 | Q10 | `/budget/recommendation` (12.000/mes) | **Professional 499 USD**; Starter y Standard `unreachable` / ninguno de los baratos llega a 12.000 | `a_la_carte` **0,00** `[sandbox]` / misma reserva que B01 | **Basic 18,60 USD** (15 + 2.000 × 0,0018) / idéntico | **500** | Coinciden. En Brevo la pregunta se degenera al revés que en Resend o SendGrid: no es que el plan barato cubra, es que **ninguno cubre hasta el de 499** |
| B05 | Q5 | `/demand-evaluation` (20.000 en 1 h) | **NO** en Free (viola a los 54 s), Starter y Standard (a los 900 s); **YES** en Professional con los dos aliases / la cuota es la que corta, no el caudal | **NO en los cuatro**, `rate_exceeded`, **primera violación en t = 0**, `plan_capacity` 1,0 contra `demand_capacity` 5,56 / 1 petición por segundo no sostiene 5,56 correos por segundo | **NO** en Free (18 s) y Basic (1.800 s); **YES** en Foundation y Scale / la cuota corta | **500** | Coinciden. **SES es la primera API del catálogo donde la demanda viola en el instante cero y por el caudal**, no por la cuota: el rate del entorno de pruebas es 1 req/s |
| D01 | Q5 | `/quotas` + `/min-time` (cuota entera, k = 1) | Starter 5.000/30día, t_min **4 s** / idéntico | Pro 200/1día `[sandbox]`, t_min **3 min 19 s** / 200 s menos la ráfaga | Basic 10.000/30día, t_min **6 s** / 10.000/1.500 = 6,67 s | `/quotas` **200**, `/min-time` **500** | Coinciden. En las tres la cuota se agota antes que su ventana por varios órdenes de magnitud. La fila de Mailchimp que sí responde trae **las dos cuotas concatenadas** dentro de `[demo]`, 25.000/30día y 500 sin periodo: es DV-05 un nivel más arriba |
| D02 | Q5 | `/rates` + `/capacity-at` (1 mes, presupuesto ∞) | rate 1.000/1s; capacidad **6.000** / la cuota dura manda, el caudal no llega a limitar | rate **1/1s** `[sandbox]`; capacidad **6.001** / ídem | rates **1.500/1s y 80.000/10s** a la vez; capacidad **3.888.001.500** / 1.500 × 2.592.000 más la ráfaga | `/rates` **200**, `/capacity-at` **500** | Coinciden. Mailgun es la única de las cuatro donde el presupuesto libera la cuota y el caudal pasa a ser el límite. El `/rates` de Mailchimp devuelve **25 correos por hora**, no peticiones: es la única API del catálogo cuyo caudal está declarado en la unidad de la cuota |
| D03 | Q9 | `/quota-exhaustion-threshold` | Starter: 4 s (k = 1), 0 s (k = 1.000 y 2.000) | Pro `[sandbox]`: 3 min 19 s (k = 1) y los dos CRF siguientes | Basic: 6 s (k = 1), 0 s (k = 500 y 1.000) | **500** | Coinciden. Igual que en la tanda anterior, el motor da el tiempo de agotamiento por CRF y k\* se deriva a mano |
| G02 | Q10 | `/budget/recommendation` (25.000, primer plan de pago) | Starter **9 USD** y **`unreachable: true`** con `unreachable_reason: rate_limit` / la causa real es la cuota de 5.000 | Pro **105 USD** y `unreachable` / **105 no es el precio de enviar 25.000 correos**, es la suscripción | Basic **42 USD** (15 + 15.000 × 0,0018) / idéntico, y **la misma cifra exacta que Postmark Basic** | **500** | Coinciden. La etiqueta `rate_limit` con causa de cuota **recurre por tercera vez**: estaba en Postmark y Resend en la tanda de tres, y vuelve en Brevo y SES |

**Recuento.** 10 preguntas × 4 APIs = 40 instancias, 68 llamadas. Por HTTP: **Brevo 16 de 17**
(el 400 de B01 con `enterprise` es DV-03 y es resultado esperado, no avería), **Mailgun 17 de
17**, **SES 17 de 17**, **Mailchimp 3 de 17**. De las 30 instancias que el motor contesta,
**ninguna difiere del cálculo a mano**: las diferencias que aparecen son las tres convenciones
del motor ya documentadas en la tanda anterior —la ráfaga en t = 0, el instante final que abre
la ventana siguiente y la cuota expandida por ventana—. Diez instancias no tienen respuesta del
motor, todas de Mailchimp y todas por el mismo defecto de contrato.

## Lo que la ejecución enseña, y el cálculo a mano no

1. **El presupuesto solo expande la cuota que declara sobrecoste, y ahora hay casos negativos.**
   En Mailgun Basic, `max_budget` alto baja el tiempo de 100.000 correos de 270 días a 1 min 6 s.
   En Brevo Starter y en SES Pro la misma llamada no mueve un segundo, porque sus cuotas no
   tienen `overage_cost`. D-037 se escribió con un caso positivo; estos son los dos primeros
   negativos, y muestran que el régimen no es una convención del motor sino una propiedad del
   pricing.
2. **El eje de plan no informa en SES.** Los cuatro planes devuelven 200 correos al día, 1
   petición por segundo, 1.401 correos en siete días y 6.001 al mes. Todo lo que el motor mide
   cuelga del alias `sandbox`. Es la primera API del catálogo donde el plan no modula ni la
   cuota ni el caudal, y tensiona directamente la afirmación C-2 de `analisis.md` §(c), «el rate
   no es una variable del plan; la cuota sí»: en SES no lo es ninguna de las dos.
3. **Dos cifras del motor son correctas y no son respuesta a la pregunta.** `a_la_carte`
   devuelve 0,00 USD para 40.000 correos y Pro devuelve 105 USD para 25.000. Las dos son el
   precio de la suscripción, y SES cobra por destinatario en tramos marginales que v0.3 no sabe
   declarar: `overage_cost` es el precio del exceso sobre una cuota incluida, y SES no incluye
   volumen en ningún plan. Es el argumento de P-01 con una cifra que engaña, no con un hueco.
4. **Un hueco deliberado tiene factura medible.** Mailchimp declara vacíos el `max` del workload
   de envío y el `period` de la franquicia de 500 correos, los dos justificados y admitidos por
   B1, B16 y E15. Cuestan catorce de diecisiete llamadas. Aislado por sustitución en memoria:
   rellenar solo el `max` cambia el error de `NoneType` a `division by zero`, y rellenar además
   el periodo devuelve 200. Es DV-02 con una tercera API y un tercer campo.
5. **El filtro de alias no sirve para comparar planes.** Pedir `alias: general` en Brevo con los
   cinco planes devuelve 400, porque el primer plan que no lo declara aborta la consulta entera.
   Es DV-06, nueva. Sin filtro el motor responde y rotula cada fila, que es lo que E16 aprovecha.
6. **Brevo cobra 9 y 18 USD por la misma cuota de envío.** Starter y Standard declaran 5.000
   correos al mes los dos, y el motor los devuelve con idéntica capacidad y distinto precio. Lo
   que separa los planes no es capacidad.
7. **Con 50 USD el gratuito de Brevo bate a su primer plan de pago**, 9.300 correos al mes contra
   6.000. Una cuota diaria acumulada sobre treinta días supera a una mensual pequeña, y es la
   primera vez que el catálogo lo mide.
8. **La etiqueta `unreachable_reason: rate_limit` con causa de cuota recurre.** Aparecía en
   Postmark y Resend; vuelve en Brevo y en SES. Cuatro APIs de ocho. Sigue siendo candidata a
   incidencia en el repositorio del motor, y sigue pendiente el rastreo previo de issues.

9. **`/capacity-at` no comprueba si el plan es asequible, y eso recurre.** Brevo Professional
   cuesta 499 USD al mes y con `max_budget` de 50 el motor devuelve igualmente 151.000 y 152.000
   correos. La operación aplica el presupuesto a la expansión de la cuota y no al precio del
   plan. Es el hallazgo H2 de la tanda de MailerSend, ahora en una segunda API.
10. **El alias solo asoma en el término de la ráfaga.** Esas dos cifras de Professional son la
   misma capacidad con dos aliases: 150.000 de cuota más 1.000 con `general` y más 2.000 con
   `advanced`, que son sus caudales. El estado de la cuenta no cambia el volumen del mes; cambia
   cuántos correos caben en el primer segundo de la ventana siguiente.

## Qué cambia en el capítulo

- §5.4: la cobertura de las P pasa de ejecutada sobre cuatro APIs a ejecutada sobre ocho, con
  40 instancias nuevas y 68 llamadas archivadas.
- §5.5: el contraste gana dos casos negativos de D-037 y el primer caso de violación en t = 0.
- Cap. 6: P-01 gana la evidencia del punto 3, que es más fuerte que la anterior porque el motor
  no falla, acierta y engaña; F-01 y la propuesta P-04 ganan la del punto 4, con la factura
  medida; DV-06 es defecto nuevo del motor y DV-02 suma su tercera API.
- `analisis.md` §(c): C-2 necesita la excepción de SES.
