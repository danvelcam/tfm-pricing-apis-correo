# Contraste tras D-024: PRIME4API sobre Postmark, antes y después de adoptar el rate

Fecha: 2026-09-07 (reejecución `2026-09-08T00:18:41`, mismo commit de PRIME4API `8e6011c48e90`,
servicio REST local con `ejecutar_prime4api_PI.py`). Motivo: **D-024** adopta en `max_power` el rate
de Postmark, `rate_request_rest` = 5.000 requests / 1 SECOND en 🟡, desde la cabecera
`ratelimit-limit: 5000` medida en el sondeo de caudal [E4] ([PM-97], [PM-98]). Hasta entonces
`max_power` estaba vacío y el motor respondía como si el rate fuese infinito (D-022,
`../prime4api_ejecucion/CONTRASTE.md`). Solo cambia la Datasheet de Postmark: Resend y SendGrid
no se tocan y sus filas siguen siendo las de la ejecución anterior.

Columnas: «antes» = `../prime4api_ejecucion/PI-*_postmark.json` (D-022); «después» =
`PI-*_postmark.json` de esta carpeta (D-024); «a mano» = `analisis.md` §(b) con R = 5.000 req/s,
W = 2.592.000 s, plan Basic (Q = 10.000) salvo donde se dice otro. Los milisegundos de latencia
(`ms`) varían entre ejecuciones y no cuentan como cambio.

## Postmark, las 10 preguntas P

| PI | Qn | Endpoint del motor | Antes (D-022, `max_power` vacío) | Después (D-024, 5.000 req/s 🟡) | A mano | Veredicto |
|---|---|---|---|---|---|---|
| A06 | Q1 | `/min-time` (100.000 correos, Basic, k = 1 y k = 50) | `270day` con k = 1 y con k = 50 | `270day1s` (k = 1); `270day` (k = 50) | 9 renovaciones de 10.000 = 270 días, más 10.000/5.000 = **2 s** (k = 1) o 10.000/250.000 = **0,04 s** (k = 50) | Coincide con la convención de la primera ráfaga en t = 0 (1 s frente a 2 s; 0,04 s se trunca a 0). Antes el tramo de rate no existía |
| A07 | Q3 | `/capacity-at` (7 días, Free, k = 1) | 100 | 100 | ≤ 100 (cuota de Free) | Sin cambio: solo depende de la cuota |
| B01 | Q6 | `/budget/recommendation` (40.000/mes, cuatro planes) | Platform 54 < Pro 55,5 < Basic 69 USD; `time_to_capacity` **0 s**; Free `unreachable`, `unreachable_reason: rate_limit` | Mismos importes; `time_to_capacity` **7 s**; Free igual | 54 / 55,50 / 69 USD; 40.000/5.000 = **8 s** | Importes sin cambio. El tiempo hasta la capacidad pasa de 0 s (rate infinito) a 7 s (8 a mano, primera ráfaga). La etiqueta `rate_limit` del Free se mantiene aunque la causa es la cuota: ese defecto de etiqueta no dependía del rate vacío |
| B02 | Q7 | `/quotas` + `/capacity-at` (1 mes, presupuesto 50 USD) | Basic **58.889** / Pro **71.538** / Platform **73.333**; Free 200 | Basic **34.444** / Pro **40.769** / Platform **41.667**; Free 200 | 29.444 / 35.769 / 36.666 | Antes el motor daba **exactamente el doble** del cálculo a mano: sin rate, en t = 1 mes la cuota expandida de la ventana siguiente se consumía entera al instante. Ahora da el cálculo a mano **más la ráfaga inicial de la ventana siguiente (+5.000)**, la misma convención que Resend (+10) y SendGrid (+10.000). Free no cambia: 100 + min(5.000, 100) = 200 |
| B03 | Q10 | `/budget/recommendation` (12.000/mes, cuatro planes) | Basic 18,6 < Pro 19,1 < Platform 20,4 USD; `time_to_capacity` 0 s | Mismos importes; `time_to_capacity` 2 s | 18,60 < 19,10 < 20,40 USD; 12.000/5.000 = 2,4 s | Importes sin cambio; tiempo 0 → 2 s (2,4 truncado) |
| B05 | Q5 | `/demand-evaluation` (pico de 20.000 en 1 h, cuatro planes, k = 1) | **NO** en los cuatro; `reason: rate_exceeded`; Basic viola a los 1.800.901 ms (10.005,56 > 10.000) | **NO** en los cuatro; `reason: quota_exceeded`; Basic viola a los 1.800.000 ms | 20.000 > 10.000: la cuota. El rate sobra: 5,56 correos/s frente a 5.000 req/s | Veredicto igual. La etiqueta se corrige: con `max_power` vacío el motor atribuía al rate una violación de cuota. El instante de violación pasa de 1.800,9 s a 1.800,0 s |
| D01 | Q5 | `/quotas` + `/min-time` (agotar 10.000, Basic, k = 1) | **0 s** | **1 s** | 10.000/5.000 = **2 s** | Coincide con la primera ráfaga en t = 0. El 0 s era la lectura «sin rate = sin límite» que P-04 quiere impedir |
| D02 | Q5 | `/rates` + `/capacity-at` (1 mes, presupuesto 10⁹ USD, k = 1) | `rates: []`; **1.111.111.114.444** correos | `rates: [{5000 requests / 1s}]`; **12.960.005.000** correos | R·W = 5.000 × 2.592.000 = **12.960.000.000**; el motor añade la ráfaga inicial de la ventana siguiente (+5.000) | Coincide. Antes la capacidad la acotaba solo el presupuesto, contado en dos ventanas: 2 × (10.000 + (10⁹ − 15)/0,0018) |
| D03 | Q9 | `/quota-exhaustion-threshold` (Basic; k = 1, 26, 50) | `[]` para los tres k | `exhaustion_threshold`: 1 s (k = 1), 0 s (k = 26), 0 s (k = 50), sobre la cuota de 10.000 | Q/(R·k): 2 s, 0,077 s, 0,04 s. k* = Q/(R·W) = 10.000/1,296·10¹⁰ = **7,7·10⁻⁷** | Devuelve valores donde antes devolvía vacío, truncados al segundo. k* se deriva a mano, igual que en Resend y SendGrid: ningún k ≥ 1 iguala los dos límites |
| G02 | Q10 | `/budget/recommendation` (25.000, Basic) | 42 USD; `time_to_capacity` 0 s | 42 USD; `time_to_capacity` 4 s | 42 USD; 25.000/5.000 = 5 s | Importe sin cambio; tiempo 0 → 4 s (primera ráfaga) |

**Recuento:** de las 10 instancias de Postmark, 9 cambian en algo y 1 no (A07). Cambian el valor
principal 4 (A06 con k = 1, D01, D02, D03), cambian solo un detalle 5 (B01, B03 y G02 en
`time_to_capacity`; B02 en la capacidad a un mes; B05 en la etiqueta y el instante). Los importes de
las cuatro preguntas de presupuesto (B01, B02 en `/quotas`, B03, G02) no se mueven. Tras D-024 las
10 coinciden con el cálculo a mano o lo completan, con la convención de la primera ráfaga.

## Tres lecturas

(1) **El vacío se leía como infinito.** Con `max_power` vacío el motor respondía t_min = 0 s, 270 días
justos para 100.000 correos, capacidad mensual acotada solo por el presupuesto y, en B02, el doble
del cálculo a mano. No se equivocaba: hacía lo que el esquema le dejaba. Es la confusión entre «no
publicado» y «sin límite» de la propuesta P-04, demostrada ejecutando, y se conserva como evidencia
(D-022). (2) **Con el valor adoptado el motor coincide con el cálculo a mano**, salvo la convención de
la primera ráfaga en t = 0 (1 s frente a 2 s en D01; 7, 2 y 4 s frente a 8, 2,4 y 5 s en B01, B03 y
G02) y la de abrir la ventana siguiente en el instante final (+5.000 en D02 y B02). Son las mismas
convenciones que ya explicaban las cifras de Resend y SendGrid; el «doble» de B02 no era una
convención más, era un efecto del rate vacío. (3) **La etiqueta `rate_exceeded` con rate vacío era un
defecto de etiqueta**, no de cálculo, y desaparece: B05 dice ahora `quota_exceeded` en los cuatro
planes con el mismo veredicto. Queda en pie el `unreachable_reason: rate_limit` del plan Free en B01
y B03, cuya causa es la cuota con rate declarado: sigue siendo candidato a issue en `prime4api`
(comprobar antes si existe, regla del 2026-08-10).

## Qué cambia en el capítulo (aplicado el 2026-09-07)

- §5.2.1: la cabecera pasa de «registrada sin adoptar» a «medida en el sondeo de caudal y adoptada en
  ámbar»; verde solo si un sondeo alcanza el 429.
- §5.3: Postmark entra en la Tabla de límites–rates con dos filas (Free y Basic); el párrafo del motor
  conserva el hallazgo del vacío (D-022) y añade la reejecución.
- §5.6: la reserva sobre la cabecera se reescribe.
- §5.1, §5.4 (Tabla de cobertura) y §5.5: con el criterio (d) de `analisis.md` («sí (🟡)» cuenta), Postmark
  pasa de 11 a **18** respondidas (A06, A07, B05, C04, D01, D02 y D03 entran; D04 pasa de «no» a «parcial»;
  A04 y F01 siguen sin respuesta). Las tres a la vez: 11 → 18. Resend 22 y SendGrid 20 no cambian.
