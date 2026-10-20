# Selección de APIs para el catálogo — consulta a la IA (fuente 3)

**Fecha:** 2026-09-01 · **Modelo:** `claude-fable-5-1` (Anthropic), en la sesión de
trabajo del TFM · **Decisión que lo ampara:** D-014 · **Destino:** anexo de uso de IA.

El criterio de selección fijado por los tutores es la unión de tres fuentes: (1) las APIs
del TFM del año pasado, (2) las que tengan Ramón y Daniel, y (3) una consulta a una IA con
prompt y criterio documentados. La fuente 1 no está disponible (el TFM no se ha
facilitado ni está depositado en idUS a fecha de hoy), y se sustituye por la fuente 3.
La fuente 2 aporta SendGrid y MailerSend, presentes en el TFM de Gavira Sánchez
(anexos C y E). Ya construidas por este trabajo: Postmark y Resend.

## Prompt literal

> Actúa como analista de APIs SaaS. Necesito seleccionar cuatro APIs de correo
> electrónico transaccional para completar un catálogo de ocho, destinado a un Trabajo
> Fin de Máster sobre Pricing Intelligence que modela la **capacidad contractual** de
> cada API (cuotas, rates, volumen contratado, sobrecoste) en Datasheets ACM2YAML v0.3 y
> las analiza con PRIME4API. Ya están en el catálogo: Postmark, Resend, SendGrid y
> MailerSend. Excluye esas cuatro.
>
> Criterios, por orden de peso:
> 1. **Diversidad del modelo de precios.** El catálogo debe cubrir formas distintas de
>    cobrar: planes por volumen mensual, pago por uso puro, producto vendido como añadido
>    de otro, y planes con límite diario además del mensual. Prioriza las que añadan una
>    forma que aún no esté cubierta.
> 2. **Documentación pública y sin registro** de precios y de límites (rate limits,
>    tamaños máximos, destinatarios por petición). Sin esto la datasheet no se puede
>    construir con trazabilidad.
> 3. **Adopción real** en producción, para que la comparación tenga interés práctico.
> 4. **Rasgo diferenciador** para el análisis de la relación entre límites de uso y rates:
>    rate publicado por endpoint, caudal negociado no publicado, límite diario, etc.
> 5. **Diversidad geográfica y de tamaño de proveedor**, con al menos una europea.
>
> Devuelve exactamente cuatro APIs seleccionadas y cuatro de reserva, ordenadas, y para
> cada una: modelo de precios (tipo), qué aporta al catálogo que las demás no, y el
> riesgo principal para construir su datasheet. No inventes cifras: describe el tipo de
> modelo, no los precios; los precios se verificarán contra la documentación al
> construir cada datasheet.

## Respuesta íntegra

### Seleccionadas

1. **Amazon SES** — *Pago por uso puro, sin planes ni cuotas mensuales.* Es la única forma
   de cobro que el catálogo no cubre todavía y la que más tensiona el esquema: no hay
   «volumen contratado», el coste es lineal y los límites (cuota de envío diaria y tasa
   máxima por segundo) se asignan por cuenta y crecen con la reputación. Adopción máxima
   en producción. Riesgo: los límites son por cuenta y no por plan, así que la datasheet
   tendrá que documentar el valor inicial publicado y el mecanismo de ampliación.
2. **Mailgun** — *Planes por volumen mensual con rate limits publicados por endpoint y
   sobrecoste por exceso.* Aporta el caso limpio de rate documentado, que es justo la
   relación límite-rate que el trabajo quiere caracterizar, y es la candidata natural al
   sondeo empírico. Riesgo: el catálogo de planes ha cambiado varias veces; hay que fijar
   fecha de captura.
3. **Brevo** (antes Sendinblue) — *Planes por volumen mensual con límite diario en el plan
   gratuito.* Añade la combinación cuota diaria + cuota mensual, que obliga a modelar dos
   ventanas de tiempo sobre la misma métrica. Europea (Francia). Riesgo: el producto
   mezcla marketing y transaccional; hay que acotar la datasheet a la API transaccional,
   como se hizo con Resend (Q1).
4. **Mailchimp Transactional (Mandrill)** — *Producto vendido como añadido de otro:* solo
   se contrata con un plan de pago de Mailchimp y se cobra por bloques de envíos. Es una
   forma de cobro que ninguna otra del catálogo tiene y que pone a prueba el campo `type`
   (D-003) y la noción de volumen contratado. Riesgo: la dependencia del plan base
   complica el cálculo del coste total.

### Reserva, por orden

5. **Mailjet** — planes por volumen con rate documentado; europea; mismo grupo que
   Mailgun (Sinch), por lo que aporta menos diversidad que Brevo.
6. **Zoho ZeptoMail** — cobro por créditos prepagados, otra forma de pago por uso.
7. **SparkPost** (Bird) — planes por volumen, muy documentada; menos adopción reciente.
8. **SMTP2GO** — planes por volumen con límites diarios, proveedor pequeño; útil como
   caso de diversidad de tamaño si cae alguna de las anteriores.

### Cobertura de modelos de precio resultante (8 APIs)

| Modelo de precios | APIs |
|---|---|
| Planes por volumen mensual | Postmark, SendGrid, MailerSend, Mailgun |
| Planes por volumen con caudal negociado no publicado | Resend |
| Planes por volumen con límite diario adicional | Brevo |
| Pago por uso puro | Amazon SES |
| Añadido de otro producto, por bloques | Mailchimp Transactional |

## Cómo se aplica

El catálogo es **mutable** (D-014): se parte de estas ocho y, si una datasheet no se puede
construir con trazabilidad suficiente, entra la primera de reserva y se anota aquí la
sustitución con fecha y motivo. Cada datasheet se construye con el ciclo del capítulo 4 y
se valida contra PRIME4API; los precios y límites que esta respuesta describe por tipo se
verifican contra la documentación del proveedor en el momento de la captura.
