# Catálogo de preguntas de Pricing Intelligence sobre APIs de correo

Versión 0.1.1 · 2026-09-07 (D-019: clase L) · fuente máquina: `catalogo.yaml` · resumen reproducible:
`python3 05_salida/_herramientas/resumen_preguntas.py`

## Para qué sirve

Es la contribución C-04 (método de comparación sistemática) y la respuesta operativa a
RQ4. El tutor pidió en mayo dos cosas que este fichero cubre a la vez: comparar las APIs
«comparando las datasheets y también con prompts preparados en H4A», y «aportar
preguntas interesantes sobre APIs de correo al catálogo de preguntas que están
construyendo». Para que lo segundo sea posible, las preguntas nacen con la gramática del
paper de Pricing Intelligence (Cavero et al., CAiSE 2026, tabla 1): plantillas con
*placeholders* SAAS, CONFIGURATION, FEATURE, USAGE LIMIT, ACTION, PRICE y YEAR.

## Cómo se construyó

1. Cada pregunta es una plantilla más un ejemplo instanciado sobre el catálogo.
2. Cada una se clasifica por **con qué se responde hoy**: D (leyendo la Datasheet), P
   (PRIME4API, con la operación Qn de Gavira Sánchez que la ejecuta), H (HARVEY4API, que
   orquesta varias Datasheets u operaciones), L (por lectura de la matriz funcional
   `features.md` de cada API, fuera del esquema y sin instrumento, D-019) o X (no
   respondible; se dice qué falta).
3. La proporción de preguntas respondibles es la **cobertura**, la misma métrica que el
   paper usa para medir el alcance de las herramientas (54 % sobre su banco de 56
   plantillas). Aquí sale sobre nuestro dominio y nuestro instrumental.
4. Las X no se tiran: son evidencia. Cada una señala un campo que la v0.3 no serializa,
   un canal fuera del alcance (D-001) o una operación que el motor no tiene. Varias
   coinciden con fricciones ya numeradas (F-03, F-06, F-09) y con propuestas del cap. 6
   (P-01, P-04).

## Qué no es

No repite el catálogo Q1–Q10 de Gavira Sánchez, que son operaciones sobre un plan o un
pricing. Aquí las preguntas son las de un consumidor eligiendo API de correo, y cada
una remite a la Qn que la resuelve cuando hay una. Las preguntas funcionales (categoría
E) son del canal web: desde D-019 dos de ellas se responden leyendo la matriz funcional
de cada API (clase L), y la tercera (retención) sigue en X porque es un límite no
consumible que pertenece al esquema (F-09).

## Estado (v0.1.1)

32 preguntas, 25 respondibles hoy con el canal API (78 %): 11 con solo la Datasheet, 10
con PRIME4API, 4 con H4A. Dos más (PI-E01, PI-E02) se responden por lectura de la matriz
funcional (clase L, D-019): 27 de 32 (84 %) contando la matriz. Las 5 X se reparten
entre concurrencia (1), límites no consumibles (1, la retención), vigencia (1), diff
entre pricings (1) y comportamiento al exceder (1). PI-D05, los límites por reputación,
era la sexta X hasta **D-041** (2026-09-15) y ahora es D: los aliases de estado de la
Datasheet de MailerSend declaran el caudal de cada estado con su cifra.

| Cat. | Nombre | D | P | H | L | X | Total |
|---|---|---|---|---|---|---|---|
| A | Lectura de la capacidad contractual de una API | 5 | 2 | 0 | 0 | 1 | 8 |
| B | Selección de suscripción para una necesidad | 1 | 4 | 0 | 0 | 0 | 5 |
| C | Comparación entre APIs | 1 | 0 | 3 | 0 | 1 | 5 |
| D | Relación entre límites de uso y rates (RQ3) | 2 | 3 | 0 | 0 | 1 | 6 |
| E | Necesidades funcionales (canal web; matriz funcional) | 0 | 0 | 0 | 2 | 1 | 3 |
| F | Evolución y vigencia | 1 | 0 | 0 | 0 | 1 | 2 |
| G | Operación y riesgo | 1 | 1 | 1 | 0 | 0 | 3 |

Las 10 P están `comprobada` sobre **las ocho Datasheets**. Primera tanda el 2026-09-07,
contra PRIME4API arrancado como servicio REST en local sobre Postmark, Resend y SendGrid:
30 instancias en `05_salida/_cap5/prime4api_ejecucion/`, con 26 que coinciden o completan el
cálculo a mano, 3 que difieren por convención del motor y 1 que se deriva. MailerSend después,
contra el PRIME4API que despliega SPHERE. Segunda tanda el 2026-09-21 sobre Brevo, Amazon SES,
Mailgun y Mailchimp Transactional: 40 instancias y 68 llamadas en
`05_salida/_cap5/prime4api_ejecucion_2026-09-21/`, de las que el motor contesta 30 y ninguna
difiere del cálculo a mano. Son **80 instancias** en total, 10 preguntas por 8 APIs.

Dos de las cuatro nuevas no tienen los ejes sobre los que estas preguntas se instancian —el plan
gratuito, el primer plan de pago y el estado nominal de la cuenta—. La regla **E16** de
`CRITERIOS.md`, salida del consejo del 2026-09-21, dice qué hacer: no se sustituye el eje por el
más parecido, se ejecuta lo que la Datasheet declara y la respuesta se rotula con el alias que
devuelve el motor. **No mueve la clase de ninguna pregunta** (D-041), ni el denominador de 32. Las dos L están `comprobada por lectura` (cada `features.md`). Las D, H y X
siguen en `borrador`: las H exigen HARVEY4API desplegado.

## Lo que falta para cerrarlo

- ~~Ejecutar las P sobre Postmark y Resend con PRIME4API~~ hecho el 2026-09-07 en local
  sobre las tres. Queda ejecutarlas en el despliegue del ecosistema y las H con HARVEY4API.
- Los ejemplos citan cifras del catálogo de memoria; se verifican contra la Datasheet al
  instanciar. Ninguna cifra de aquí va a la memoria sin esa verificación.
- Decidir con los tutores si las categorías E y F entran en su catálogo o se quedan como
  trabajo futuro. La E ya tiene respuesta por lectura (D-019); lo que falta es el
  instrumento (vínculo iPricing–Datasheet).
- ~~Segunda tanda cuando haya cuatro Datasheets~~ hecha el 2026-09-21 sobre las ocho, con las
  cuatro nuevas. Las preguntas de comparación (C) crecen con el catálogo y ya se responden sobre
  ocho columnas.
- Mailchimp Transactional deja diez instancias sin respuesta del motor: catorce de sus diecisiete
  llamadas caen con `float() argument must be a string or a real number, not 'NoneType'`. No es
  hueco del catálogo ni de la Datasheet, es **DV-02**, y sus celdas lo dicen con el error verbatim.
