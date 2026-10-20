# F-21 ante el listón de D-042: ¿cumple L2 el cupo de destinatarios únicos?

Ejecutado el 2026-09-15 contra el **PRIME4API que despliega SPHERE en local**
(`localhost:8003`, `PRIME4API 0.1.0`, `/docs` responde 200). Datasheet:
`03_datos/apis/mailersend/datasheet.yaml` **tal cual está en el catálogo**, sin ninguna
manipulación (sha256 `3dff58bf0d8be28bd66de9a5b669f07d5afdc4624c8da141ccdd32626b9227bd`; el
fichero no aparece modificado en `git status`). Endpoint `/v1/email`, alias
`unapproved_account`, que es el estado de cuenta donde vive el caso. Script reproducible:
`ejecutar_cupo_destinatarios.py`, en esta misma carpeta.

**Encargo.** Comprobar L2 del listón D-042: que el motor, con la Datasheet delante, devuelva
un valor falso o deje sin responder algo que respondería si el esquema expresara la carencia.
El veredicto provisional era que **F-21 no cumple L2**, porque su consecuencia documentada
—Q9 sin poder medirse— recayó sobre el investigador. Este fichero intenta refutarlo.

**Dónde vive hoy el cupo.** En ningún sitio que el motor lea. Está en
`metadata.not_found` (tres entradas) y en la descripción del `workload` `max: 2` de los
bloques `unapproved_account`. Ninguna de las dos las ingiere PRIME4API: son prosa.

## Qué se preguntó y qué respondió el motor

Las ocho primeras son preguntas del catálogo `03_datos/preguntas/catalogo.yaml`,
instanciadas sobre la cuenta sin aprobar. La novena es un control.

| Caso | Pregunta del consumidor | Llamada | Respuesta del motor |
|---|---|---|---|
| C1 | ¿Cuánta capacidad acumula en un mes una cuenta sin aprobar? (PI-A07 · Q3) | `/capacity-at` `1month` | **110 correos** con k = 1; **120** con k = 2 |
| C2 | Lo mismo en un día (PI-A07 · Q3) | `/capacity-at` `1day` | **100 correos**, con k = 1 y con k = 2 |
| C3 | ¿Cuánto tarda en enviar sus 100 correos de cuota? (PI-A06 · Q1) | `/min-time` `goal=100` | **9 min** con k = 1; **4 min** con k = 2 |
| C4 | ¿Cuánto tarda en llegar a 3 destinatarios? (PI-A06 · Q1) | `/min-time` `goal=3` | **0 s**, con k = 1 y con k = 2 |
| C5 | ¿Qué cuotas tiene? (PI-A01) | `/quotas` | 100 peticiones/día, 500 correos/30 d, **100 correos/30 d** |
| C6 | ¿A qué caudal? (PI-A02) | `/rates` | 10 peticiones/min |
| C7 | ¿Qué suscripción me vale para 3 destinatarios? (PI-B01 · Q6) | `/budget/recommendation` `3` | **Free, 0,00 USD**, `affordable: true`, **`unreachable: false`**, `time_to_capacity: 0s` |
| C8 | ¿Qué se agota antes, la cuota o el caudal? (PI-D01 · Q5) | `/quota-exhaustion-threshold` | La cuota de 100 correos, a los **9 min** (k = 1) |
| C9 | *Control*: ¿sabe el motor decir que no? | `/budget/recommendation` `100000` | **`unreachable: true`**, `unreachable_reason: "rate_limit"` |

Las nueve devuelven HTTP 200. Petición y respuesta íntegras, una por fichero, en
`C1…C9_*_mailersend.json`.

## Qué dice la medición

D-033, tanda 3 del sondeo [E1], ejecutada por el autor el 2026-09-14 entre las 16:39 y las 16:47
UTC, sobre la misma cuenta Sandbox de la que salen **todos** los valores del alias
`unapproved_account` (la propia Datasheet lo declara en su provenance). Filas **MS-190** y
**MS-192** de `05_salida/_cap5/hechos_mailersend.md`; evidencias
`03_datos/apis/mailersend/evidencias/probe_q9_unidad_*_2026-09-14_*.json`.

- Estado de partida limpio: cuota diaria **100/100** y panel `"Emails sent"` en **0**.
- Envío a dos direcciones distintas: **422** `"You have reached sandbox account unique
  recipients limit. #MS42225"`.
- La misma dirección en `to` y en `cc`, que es la mayor combinación válida: **el mismo 422**.
- `GET /v1/recipients` devuelve **0**: el cupo no es consultable.
- **No salió ningún correo y no se gastó cuota mensual.** Lo que bajó (100 → 97) fue la cuota
  diaria de peticiones, que es otra cosa.

Es decir: capacidad real de envío **cero**, con las dos cuotas que el modelo sí lleva intactas.

## El contraste

| | El motor responde | La medición devuelve |
|---|---|---|
| Correos en un mes, cuenta sin aprobar | 110 | 0 |
| Correos en un día | 100 | 0 |
| Tiempo hasta 3 destinatarios | 0 s | inalcanzable: 422 MS42225 |
| ¿Alcanzable con el plan gratuito? | `unreachable: false`, 0,00 USD | no, y no lo levanta ningún plan |

El motor no se equivoca por falta de datos ni por un campo mal puesto. Se equivoca porque
opera con las tres dimensiones que el esquema tiene —cuota, caudal y carga— y la que gobierna
el resultado no es ninguna de ellas. El control C9 cierra la lectura: el motor **sí sabe**
declarar un objetivo inalcanzable, con su razón (`rate_limit`), y con esta misma Datasheet
declara alcanzables tres destinatarios que la API rechaza.

## La objeción, y por qué no salva el veredicto provisional

**Objeción.** El motor describe un estado nominal; la cuenta medida ya había gastado su cupo.
Eso es saldo de una cuenta concreta, no carencia del esquema.

**Respuesta.** Tres cosas.

1. El alias `unapproved_account` no es nominal. La Datasheet declara en su provenance que
   *todos* sus valores —10 por minuto, 100 al mes, `max: 2`, `max: 5`— se midieron en esa
   única cuenta. El motor responde sobre ese estado con esos números, y para ese estado la
   respuesta es falsa.
2. Una cuota ordinaria gastada el consumidor la reconcilia solo, porque sabe cuánto envió.
   Este cupo, no: se gasta con peticiones que **no entregan nada**, no es consultable y no se
   repone. No hay información con la que corregir la respuesta del motor.
3. En el momento de la medición las entradas del motor eran correctas: cuota diaria y mensual
   intactas. La salida seguía siendo falsa por 110 a 0.

**Y qué tiene esto de F-21 y no del simple tope de dos destinatarios.** El tope publicado, por
sí solo, haría ambigua la cifra de 110 correos —caben 110 envíos a dos direcciones—. Lo que la
vuelve **falsa**, 110 frente a 0, es la propiedad que define F-21: el cupo se había agotado con
intentos que no enviaron un solo correo. Esa es la causa operativa del valor falso.

## Veredicto

**L2 CUMPLIDA.**

1. Con la Datasheet del catálogo sin tocar, el motor atribuye a la cuenta sin aprobar 110
   correos al mes y declara alcanzables tres destinatarios en 0 s y por 0,00 USD.
2. La medición del 2026-09-14 hizo cero envíos con las dos cuotas modeladas intactas: lo que
   lo impidió fue un cupo que ningún campo de la v0.3 recoge.
3. El falso no le ocurre al investigador, sino a quien pregunta PI-A06, PI-A07 o PI-B01 sobre
   ese estado, y el motor tiene campo para decir «no alcanzable» y dice lo contrario.

## L3, evaluada (2026-09-15, verificación adversarial)

La primera redacción de este fichero dejó L3 sin evaluar mientras la ficha D-042 ya la marcaba
✅. Se evalúa ahora. L3 pide dos cosas: que ningún mecanismo del README de Gavira y Ruiz
absorba la carencia, y que no la explique un defecto del motor ya inventariado como DV-nn.

**Qué se pudo consultar, y qué no.** El README de la guía del esquema (`readme/readme0.3.md`,
el que este catálogo cita por secciones §3.1, §3.4, §3.4.2 y §3.4.3) **no está en disco**. Lo
que hay en `~/.cache/atf/prime4api` es el repositorio del motor, y su `README.md` documenta
despliegue y endpoints REST, no el artefacto. Así que la comprobación se hace contra las dos
fuentes que sí están y que son más estrictas que la guía: la **implementación de referencia**,
que es la que fija qué campos existen de verdad, y las secciones del README ya transcritas en
`03_datos/apis/mailersend/fricciones.md`.

### 1 · Ningún mecanismo del esquema declara este cupo

El cupo tiene cuatro propiedades a la vez: es **de la cuenta**, **sin ventana**, en **unidad de
entidades distintas** y **consumido por el intento**. Los mecanismos de v0.3, uno por uno:

| Mecanismo | Qué declara | Por qué no lo absorbe |
|---|---|---|
| `quota` | volumen por ventana | El modelo `Quota` de la implementación exige `period`, y el parser solo acepta `ms, s, min, h, day, week, month, year`. **No hay forma de decir «no se renueva»** |
| `rate` | caudal por ventana | Mismo problema de ventana, y aquí el cupo ni siquiera es un ritmo |
| `workload` | tope **por petición**, por dimensión | El cupo no es por petición: dos peticiones de una dirección cada una lo agotan igual |
| *aliases* (§3.4.3) | cifras distintas **por estado de cuenta** | Es un selector: mete `rate`, `quota` y `workload` por estado, y no crea dimensión nueva. Sirve para decir que el cupo vale 2 sin aprobar; no para decir qué es |
| `max_power` | definiciones nombradas de `rate` y `quota` | Es el diccionario de definiciones; hereda la misma forma y los mismos campos |

Los campos que el evaluador lee de la Datasheet son `plans`, `endpoints`, `capacity`, `rate`,
`quota`, `workload`, `max_power`, `price`, `overage_cost`, `billing_period`, `currency` y
`description`. **Ninguno tiene ámbito de cuenta, ni marca de qué consume el límite.** `unit` sí
es una cadena libre, así que se podría escribir `unit: unique_recipients`; lo que no se puede
escribir es el `period`, que es obligatorio, ni la regla de que lo gaste el intento y no el
envío. Declararlo como cuota mensual sería repetir el error que F-11 ya documentó: le miente al
motor, que lo leería como un consumo que se reinicia.

**El candidato más cercano, y por qué tampoco vale.** El bloque `resources` que propone F-11
—`{name, value, unit}` sin periodo, para dominios, tokens y plantillas— tiene la forma sin
ventana que aquí hace falta. Dos cosas lo descartan. Primero, **no es un mecanismo del README**:
es una extensión que propone este catálogo, y L3 pregunta por lo que el esquema ya ofrece.
Segundo, aunque estuviera, no serviría: F-11 define sus recursos como algo que **se tiene o no
se tiene**, y por eso su propuesta dice explícitamente que *no entra en las curvas de
capacidad*. Este cupo **se gasta**, y gastándose es como falsea la capacidad. La entrada F-19
lo daba por absorbido por F-11, pero eso es anterior a la medición: el punto (iv) de F-18 lo
sacó de ahí con este mismo argumento y lo convirtió en caso propio, F-21.

### 2 · Ningún defecto inventariado lo explica

Las cinco discrepancias de `03_datos/DISCREPANCIAS_v03.md`, contra lo medido aquí:

| | Qué es | ¿Explica el 110 frente a 0? |
|---|---|---|
| DV-01 | `workload` mapa frente a lista; `TypeError` al navegar | No. Ninguna llamada de esta carpeta se rompió: todas devolvieron 200 |
| DV-02 | un valor ausente tumba la Datasheet (`float(None)`) | No. No hay campo vacío en juego; el cupo no tiene campo donde estar vacío |
| DV-03 | un precio `custom` tumba los demás planes | No. El plan Free tiene todas sus cifras |
| DV-04 | un rate solo y sin cuota rompe la curva acumulada | No. Es una excepción del motor, y aquí no hubo ninguna |
| DV-05 | la herencia concatena el límite del plan y el del nodo | No. Afecta a cuántas veces se cuenta un límite **declarado**; este no está declarado en ninguna parte |

Las cinco son fallos del motor al leer un documento. Aquí el motor **no falla**: calcula bien
110 correos al mes con las tres dimensiones que el documento le da. La respuesta es falsa
porque la dimensión que gobierna el resultado no está en el documento, y no está porque el
esquema no tiene dónde ponerla.

### Veredicto de L3

**L3 CUMPLIDA.** Ningún mecanismo de v0.3 —cuota, caudal, carga por petición, *aliases* o
`max_power`— puede declarar una cuota de ámbito de cuenta, sin ventana, en unidad de entidades
distintas y consumida por el intento; el `period` obligatorio de `Quota` basta para cerrar la
vía, y las cinco discrepancias inventariadas describen fallos del motor que aquí no ocurren.
La ficha D-042 marcaba L3 ✅ sin este contraste; ahora lo tiene.

## Alcance de esta comprobación

- L1 ya estaba: MS-190 y MS-192 en `hechos_mailersend.md`, con los tres ficheros de
  `evidencias/`. L2 es lo que ejecuta esta carpeta. L3 queda evaluada arriba, con la salvedad
  declarada de que el README de la guía no está en disco y la comprobación se hizo contra la
  implementación de referencia.
