# Contraste tras D-037: PI-A06 con la cuota dura y con presupuesto que no limita

Fecha: 2026-09-14, contra el **PRIME4API que despliega SPHERE en local** (`localhost:8003`,
contenedor `prime4api-sphere`), con `ejecutar_prime4api_PI.py plan|importar` sobre las cuatro
Datasheets. Motivo: **D-037**. La convención H3 —sin `max_budget` el motor trata como dura una
cuota que tiene `overage_cost`— gobierna la respuesta de A06 en **las cuatro APIs**, no solo en
MailerSend, y el capítulo citaba una sola de las dos cifras posibles.

## Las dos respuestas de A06

Objetivo: 100.000 correos en el primer plan de pago, con $k = 1$ y con el $k$ máximo de cada API.

| API y plan | k | Cuota dura | Presupuesto que no limita |
|---|---|---|---|
| Postmark Basic | 1 | 270 d 1 s | 19 s |
| Postmark Basic | 50 | 270 d | 0 s |
| Resend Pro | 1 | 30 d 1 h 23 min 19 s | 2 h 46 min 39 s |
| Resend Pro | 50 | 30 d 1 min 39 s | 3 min 19 s |
| SendGrid Essentials 50K | 1 | 30 d 4 s | 9 s |
| SendGrid Essentials 50K | 1.000 | 30 d | 0 s |
| MailerSend Hobby | 1 | 570 d 41 min | 13 h 53 min |
| MailerSend Hobby | 70 | 570 d | 11 min |

Sin presupuesto el motor construye el `BoundedRate` con la cuota tal cual y espera renovaciones,
así que el tiempo se mide en meses. Con presupuesto, `expand_quotas` la agranda con su
`overage_cost` antes de medir, y el tiempo lo fija el caudal. **Las dos cifras son del
proveedor**: el sobrecoste lo publica él.

## El presupuesto no es un número elegido

La respuesta **satura en el coste del propio objetivo**, medido en Hobby, donde 100.000 correos
cuestan 7 + 95.000 × 0,0015 = **149,50 USD**:

```
budget=149.0 -> 30day2min
budget=149.4 -> 30day
budget=149.5 -> 13h53min     <- el coste exacto del objetivo
budget=200.0 -> 13h53min
budget=10^6  -> 13h53min
```

Por eso las llamadas archivadas usan `max_budget: 1e9`, el mismo «presupuesto muy alto» que ya
usaba PI-D02: cualquier valor por encima del coste devuelve lo mismo. El régimen intermedio
—50 USD, que compra parte del sobrecoste y deja el resto en renovaciones— **no se publica**:
mezcla los dos y obligaría a justificar el 50.

## Qué más se movió

Ninguna otra respuesta. Las **15 llamadas** que ya existían por API se reejecutaron y son
**idénticas** a las del archivo anterior de cada una (`prime4api_ejecucion_d024` en Postmark,
`prime4api_ejecucion_d035` en Resend y SendGrid,
`prime4api_ejecucion_mailersend_2026-09-10` en MailerSend); las **2 nuevas** por API son las de
A06 con presupuesto. Total: 17 llamadas por API, 68 en el archivo.

## Lo que queda para el capítulo 6

La distancia entre las dos columnas llega a **tres órdenes de magnitud**, y el esquema no dice
cuál de los dos regímenes describe el plan: la cuota lleva su `overage_cost`, pero nada declara
si el proveedor lo aplica solo, lo exige aprobar o lo tapa un tope —que es F-13 y F-16 vistas
desde el motor—. Quien pregunte «cuánto tardo en enviar 100.000 correos» recibe una respuesta u
otra según un parámetro que la Datasheet no gobierna.
