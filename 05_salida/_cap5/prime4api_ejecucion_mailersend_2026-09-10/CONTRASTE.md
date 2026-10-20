# Contraste: reejecución del 2026-09-10 frente a la ejecución del 2026-09-08, MailerSend

Esta carpeta repite las diez preguntas P de MailerSend contra el mismo PRIME4API de SPHERE
(`localhost:8003`, imagen `rgavira123/prime4api` del compose de `docker/testing`) después de que la
Datasheet adoptara los tres aliases de estado de cuenta (D-025: `healthy_reputation`,
`under_review_reputation`, `unapproved_account`). La ejecución anterior sigue íntegra en
`../prime4api_ejecucion_mailersend/`, y su `CONTRASTE.md` —el que compara el motor con el cálculo a
mano, llamada a llamada— **sigue vigente sin un solo cambio de cifra**: lo que sigue es solo el
contraste entre las dos ejecuciones.

## Cómo se hizo

```
python3 05_salida/_herramientas/ejecutar_prime4api_PI.py plan mailersend plan_mailersend.json \
        --base http://localhost:8003/api/v1/datasheet          # 15 llamadas, alias en el cuerpo
# las 15 POST contra localhost:8003 desde la misma máquina (requests), respuestas en orden
python3 05_salida/_herramientas/ejecutar_prime4api_PI.py importar mailersend respuestas.json \
        05_salida/_cap5/prime4api_ejecucion_mailersend_2026-09-10/ --origen "…"
```

Diferencias de procedimiento con la del 2026-09-08, ninguna de ellas sobre el motor: aquellas
llamadas salieron del navegador del autor y con el `datasheet_source` sin el bloque `metadata`; estas
salen de `requests` en la misma máquina y mandan el `datasheet.yaml` íntegro, `metadata` incluida,
que el motor no lee. Las 15 respondieron HTTP 200, igual que las 15 anteriores.

## Qué cambia

1. **Cada fila de resultado lleva ahora `"alias": "healthy_reputation"`.** Antes el motor devolvía
   `alias` vacío porque el endpoint no declaraba ninguno. Es la única diferencia estructural.
2. **El cuerpo de las 15 peticiones lleva `"alias": "healthy_reputation"`.** Sin ese filtro el motor
   devuelve tres filas por endpoint, una por estado, y quien lea la respuesta tiene que elegir. El
   valor por defecto está fijado y documentado en `ejecutar_prime4api_PI.py` (constante `ALIAS`), y
   se cambia con `--alias`.
3. **Los enteros salen como decimales** (`1` → `1.0`, `500` → `500.0`). Es cómo serializa Python
   frente a cómo serializaba el `JSON.stringify` del navegador en la captura anterior; el número es
   el mismo.

## Qué no cambia

Las 15 respuestas coinciden **cifra a cifra** con las del 2026-09-08 una vez se descuenta la
etiqueta `alias` y la representación de los números. Comparación campo a campo de los diez JSON:
0 diferencias reales de 15 llamadas.

| # | PI | Llamada | Valor del motor (las dos ejecuciones) | Veredicto |
|---|---|---|---|---|
| 1 | A06 | `/min-time` 100.000, Hobby, k = 1 | `570day41min` | igual |
| 2 | A06 | `/min-time` 100.000, Hobby, k = 70 | `570day` | igual |
| 3 | A07 | `/capacity-at` 7 d, Free, k = 1 | 500 correos | igual |
| 4 | B01 | `/budget/recommendation` 40.000, todos los planes | Starter 35 < Hobby 59,5 < Professional 110; Free inalcanzable | igual |
| 5 | B01 | `/budget/recommendation` 40.000, planes calculables | lo mismo que #4 | igual |
| 6 | B02 | `/quotas` con `max_budget` 50 | ocho cuotas, sin expandir (100/500, 1.000/5.000, 100.000/50.000, 500.000/50.000) | igual |
| 7 | B02 | `/capacity-at` 1 mes, k = 1, `max_budget` 50 | Free 620 · Hobby 33.786,67 · Starter 61.658,46 · Professional 50.120 | igual |
| 8 | B03 | `/budget/recommendation` 12.000 | Hobby 17,5 < Starter 35 < Professional 110; Free inalcanzable | igual |
| 9 | B05 | `/demand-evaluation` pico 20.000 en 1 h | `NO` · `rate_exceeded` en los cuatro planes (120 frente a 122,22) | igual |
| 10 | D01 | `/quotas` Hobby | 1.000 peticiones/día y 5.000 correos/30 d con sobrecoste 0,0015 | igual |
| 11 | D01 | `/min-time` 5.000, Hobby, k = 1 | `41min` | igual |
| 12 | D02 | `/rates` Hobby | 120 peticiones/min | igual |
| 13 | D02 | `/capacity-at` 1 mes, `max_budget` 10⁹ | 5.184.120 correos | igual |
| 14 | D03 | `/quota-exhaustion-threshold` Hobby | k = 1 → `41min`; k = 36 → `1min`; k = 70 → `0s` | igual |
| 15 | G02 | `/budget/recommendation` 25.000, Hobby | 7 + 30 = 37 USD, alcanzable en 3 h 28 min | igual |

Las cifras que el capítulo 5 cita de esta ejecución —41 minutos para agotar los 5.000 de Hobby,
570 días y 41 minutos para 100.000, 5.184.120 correos al mes con presupuesto sin tope y 33.786,67
con 50 USD— salen idénticas. La Figura 5.1 tampoco se mueve: los dos paneles de MailerSend pedidos
al mismo servicio con el filtro `healthy_reputation` devuelven una sola serie y los mismos puntos
que los archivados en `../capacidad_figs/sphere/mailersend_hobby_k*_data.json`
(`(0 s, 120)`, `(2.400 s, 4.920)`, `(2.460 s, 5.000)`, `(2.592.000 s, 5.000)` con k = 1).

## Por qué `healthy_reputation` y no otro

Sin filtro, el motor contesta con los tres estados. Las mismas dos llamadas de arriba, pedidas con
`--alias ""`:

- `/rates` Hobby: `healthy_reputation` 120/min · `under_review_reputation` 10/min ·
  `unapproved_account` 10/min.
- `/min-time` 5.000 correos, Hobby, k = 1: `41min` · `8h19min` · `1470day9min`.
- `/min-time` 100.000 correos, Hobby, k = 1: `570day41min` · `570day8h19min` · `29970day9min`.

El capítulo 5 describe el estado nominal de una cuenta en un plan, que es `healthy_reputation`; los
otros dos son los estados degradados y aparecen en el capítulo como tales, no como el límite del
plan. De ahí el valor por defecto.

## Artefacto del motor que conviene tener anotado

Con `unapproved_account` el muestreo de CRF colapsa: el `workload` de ese alias va de 1 a 2, y el
motor emite el caso `crf = 2.0` **dos veces** (`get_curve_scenarios` sobre Hobby `/v1/email`
devuelve 18 escenarios: 6 de `healthy_reputation`, 6 de `under_review_reputation` y 6 de
`unapproved_account`, de los cuales cuatro son dos parejas repetidas). Los dos escenarios repetidos
llevan los mismos rates y las mismas cuotas, así que no cambian ninguna cifra; es cosa del muestreo
del motor, no del YAML, y no toca ninguna figura del capítulo, que solo usa `healthy_reputation`
con k = 1 y k = 70.
