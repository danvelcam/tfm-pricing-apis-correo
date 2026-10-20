# F-16 ante L2: reejecución tras D-068 (D17)

**Por qué se repite.** La ejecución del 2026-09-15 (`../tope_sobrecoste/`) leyó la
Datasheet de SendGrid con 0,00133 USD por correo extra, la cifra del panel. D-068 (regla
D17) da prioridad a la página de precios, y el YAML declara ahora 0,0013. Las dos cifras de
P-07 en la memoria salían de ese precio, y por eso hay que repetir la ejecución. No se
recalculan a mano.

**Ejecución.** 2026-10-18, mismo servicio (`prime4api-sphere`, `http://localhost:8003`),
mismas once llamadas con los mismos parámetros y cuerpos. Solo cambia `datasheet_source`:
`03_datos/apis/sendgrid/datasheet.yaml` tal cual está en la rama, sha256
`dc265bcad7c60936eab50cfbf6da5df6c6def1febd6c7e62788aad41d143c243`. La carpeta del
2026-09-15 se conserva sin tocar.

## Qué cambia

| # | Llamada | 2026-09-15 (0,00133) | 2026-10-18 (0,0013) |
|---|---|---|---|
| 01–05 | `min-time` | 210 d / 330 d / 39 s / 59 s / 0 s | igual |
| 06 | `budget/recommendation` 400.000 | 19,95 + 465,50 = 485,45 USD, 39 s | 19,95 + 455,00 = **474,95 USD**, 39 s |
| 07 | `budget/recommendation` 600.000 | 19,95 + 731,50 = 751,45 USD, 59 s | 19,95 + 715,00 = **734,95 USD**, 59 s |
| 08 | `capacity-at` 1 mes | 25.920.010.000 | igual |
| 09–10 | `quotas` | 50.000 / 30 días, 0,00133 | 50.000 / 30 días, **0,0013** |
| 11 | control, `max_budget` 100 | `unreachable: true`, `budget_limit` | igual, sobre 734,95 |

## Lectura

El veredicto de L2 no cambia. Por encima del tope de 500.000 el motor sigue respondiendo con
la misma forma lineal que por debajo: 600.000 correos cuestan 734,95 USD y se alcanzan en
59 segundos, aunque el proveedor no admite esa cantidad en Essentials. El control de la
llamada 11 muestra que `unreachable` sí se activa, pero solo por presupuesto, no por el tope.
