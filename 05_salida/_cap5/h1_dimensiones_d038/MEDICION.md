# H1 medido por dimensiones: qué convierte el motor y qué no (D-038)

Fecha: 2026-09-14, contra el **PRIME4API que despliega SPHERE en local** (`localhost:8003`,
contenedor `prime4api-sphere`), con `medir_dimensiones.py` de esta misma carpeta. Motivo: la
**abierta 14** de `05_salida/_cap5/abiertas.md` pedía llevar al capítulo 6 la discusión de
unidades del hallazgo **H1**, y antes de clasificarla hacía falta saber qué hace el motor.

Caso: **MailerSend Hobby `/v1/email`**, alias `healthy_reputation`. Es la única Datasheet del
catálogo con cuotas en dos unidades —ninguna de las otras tres declara una sola `quota` en
`requests`—, y su `workload` va de $k = 1$ a $k = 70$ correos por petición.

## La matriz de conversiones

| Límite declarado | Pedido en `requests` | Pedido en `emails` |
|---|---|---|
| `rate` 120 peticiones/min | 120 (nativo) | **120 × k**: 4.320 a $k = 36$, 8.400 a $k = 70$ |
| `quota` 5.000 correos/mes | **5.000 / k**: 5.000, 138 y 71 | 5.000 (nativo) |
| `quota` 1.000 peticiones/día | 1.000 (nativo) | **no aparece** |

De las tres conversiones que el CRF permite, el motor hace **dos**. La que falta es la cuota
nativa en peticiones llevada a correos, y es la que sostiene H1.

**La formulación anterior de H1 queda corregida.** No es que el motor «no cruce las
dimensiones»: las cruza con el mismo CRF del `workload`, y lo hace en el caudal y en la cuota
mensual. Lo que hay es un hueco concreto, y el esquema no tiene parte en él: el CRF que haría
falta ya está declarado en la Datasheet y el motor lo usa dos veces de tres.

**El hueco cambia la respuesta.** Con $k = 1$ la curva en correos sube a 5.000 en 41 minutos
(punto de inflexión en 2.460 s); con la cuota diaria son 1.000 al día y los 5.000 llegan el
quinto día (346.080 s). El consumidor que pregunte en la dimensión del dominio —correos— se
lleva la cifra optimista, y la distancia son dos órdenes de magnitud en el tiempo.

## Lo que ve quien no filtra

El endpoint de **datos** no oculta nada: sin `capacity_unit` devuelve las dos dimensiones por
cada CRF del rango (1, 36 y 70), seis series. El **renderizador** sí: sin filtrar sirve cuatro
figuras, **las cuatro de correos**, y la dimensión de peticiones solo aparece con
`show_derived_requests=true`, que el endpoint expone con valor por defecto `False` y la
descripción *"Hidden by default because it is usually redundant with a native requests limit"*.
En MailerSend no es redundante: esa serie es la única que lleva la cuota diaria del plan.

## Salida verbatim

```
== 1. Una dimensión cada vez (data/inflection)
   capacity_unit=emails   k=1   dim=emails   rates: 120 emails/1min | quotas: 5000 emails/30day
      puntos: [(0.0, 120.0), (2400.0, 4920.0), (2460.0, 5000.0), (2592000.0, 5000.0)]
   capacity_unit=emails   k=70  dim=emails   rates: 8400 emails/1min | quotas: 5000 emails/30day
      puntos: [(0.0, 5000.0), (2592000.0, 5000.0)]
   capacity_unit=requests k=1   dim=requests rates: 120 requests/1min | quotas: 1000 requests/1day, 5000 requests/30day
      puntos: [(0.0, 120.0), (420.0, 960.0), (480.0, 1000.0), (86400.0, 1000.0), (86820.0, 1960.0), (86880.0, 2000.0), (172800.0, 2000.0), (173220.0, 2960.0), (173280.0, 3000.0), (259200.0, 3000.0), (259620.0, 3960.0), (259680.0, 4000.0), (345600.0, 4000.0), (346020.0, 4960.0), (346080.0, 5000.0), (2592000.0, 5000.0)]
   capacity_unit=requests k=70  dim=requests rates: 120 requests/1min | quotas: 1000 requests/1day, 71 requests/30day
      puntos: [(0.0, 71.0), (86400.0, 142.0), (2592000.0, 142.0)]
== 2. Sin capacity_unit (data/inflection): el motor devuelve todas
   dim=requests k=1.0  rates: 120 requests/1min | quotas: 1000 requests/1day, 5000 requests/30day
   dim=emails   k=1.0  rates: 120 emails/1min | quotas: 5000 emails/30day
   dim=requests k=36.0 rates: 120 requests/1min | quotas: 1000 requests/1day, 138 requests/30day
   dim=emails   k=36.0 rates: 4320 emails/1min | quotas: 5000 emails/30day
   dim=requests k=70.0 rates: 120 requests/1min | quotas: 1000 requests/1day, 71 requests/30day
   dim=emails   k=70.0 rates: 8400 emails/1min | quotas: 5000 emails/30day
== 3. El documento del renderizador (chart/inflection)
   sin filtro, por defecto                    HTTP 200   39456 bytes  figuras=4  dimensiones=emails
   sin filtro, show_derived_requests=true     HTTP 200   75208 bytes  figuras=8  dimensiones=emails, requests
   capacity_unit=requests, por defecto        HTTP 200    3449 bytes  figuras=0  dimensiones=ninguna
   capacity_unit=requests, show_derived_requests=true HTTP 200   40214 bytes  figuras=4  dimensiones=requests
```

Los tamaños de los documentos varían en unos pocos bytes entre pasadas, porque el motor da un
identificador aleatorio a cada contenedor. Los 3.445 bytes que registró D-036 y los 3.449 de
esta pasada son el mismo documento sin figuras.

## Un detalle menor que no se lleva al capítulo

La cuota mensual convertida a peticiones se redondea a la baja: 5.000 / 70 = 71,43 da 71, y
5.000 / 36 = 138,9 da 138. Son 30 y 32 correos por debajo del contrato. No cambia ningún
veredicto y no aparece en la memoria.

## Reproducción

```
python3 05_salida/_cap5/h1_dimensiones_d038/medir_dimensiones.py
```

Con SPHERE levantado. El script deja un JSON por llamada de datos en esta carpeta y solo usa la
biblioteca estándar.
