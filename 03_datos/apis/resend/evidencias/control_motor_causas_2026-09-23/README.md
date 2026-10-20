# Control del motor sobre la Datasheet de Resend (2026-09-23)

Separa las dos causas de los trece errores que PRIME4API da sobre `datasheet.yaml` de Resend:
el caudal vacío de Enterprise (P-04) y las cadenas `custom` del precio y de la cuota de
Enterprise (P-05). `03_datos/DISCREPANCIAS_v03.md` reparte los errores como «5 de DV-02 y 8 de
DV-03»; ese reparto es el error que informa cada comprobación, no su causa.

Tres variantes, verificadas con `05_salida/_herramientas/verificar_prime4api.py` en un
contenedor `python:3.12-slim` desechable:

| Variante | Cambio sobre `datasheet.yaml` | Resultado |
|---|---|---|
| tal cual | ninguno (idéntico al `datasheet.yaml` del repo el 23-09) | 8 OK / 13 ERR: cinco con `'NoneType'`, ocho con `'custom'` |
| `resend_sin_nulo.yaml` | línea 83, `value:` vacío → `value: 10` | 8 OK / 13 ERR: las trece con `'custom'` |
| `resend_sin_custom.yaml` | líneas 54 y 204, `custom` → `1000000` y `1000` | 9 OK / 12 ERR: las doce con `'NoneType'` |

Cada causa basta por sí sola para tumbar las comprobaciones que el reparto atribuye a la
otra. El precio va por plan: `pricing[free]`, `[pro]` y `[scale]` dan OK y solo
`pricing[enterprise]` falla. Salida completa en `salida_control.txt`.

Lo cita el Capítulo 6 (P-04 y P-05, fila de Resend y párrafo de la verificación).
