# Recuento de recurrencia sobre las ocho APIs

**Fecha:** 2026-09-23. **Revisado el 2026-10-18:** D17 cerró DISC-11 en peticiones y F-17, sin
ninguna otra ocurrencia, se retiró por B17. La tabla y las cifras de (b) ya lo recogen: 35
filas, 280 celdas. La celda de F-38 en MailerSend pasa de ⏸ a ❌. Los apartados (c) y (d) se
conservan como se escribieron el 2026-09-23, con una nota donde citan a F-17.

**Qué es.** Es el recuento de recurrencia de las 35 fricciones vivas del catálogo sobre las ocho
APIs cerradas. Hay una fila por fricción y una columna por API, en el orden Postmark, Resend,
SendGrid, MailerSend, Brevo, Amazon SES, Mailchimp y Mailgun. La última columna da el veredicto
con su recuento.

**De dónde sale.** Reúne tres entradas de esta unidad de revisión. La primera es el catálogo de
F-01 a F-38 (`catalogo.md`). F-19 no aparece porque la absorben F-11 y F-18; F-20 tampoco, porque se retiró a O-11, ni
F-17, que se retiró por B17 el 2026-10-18. La segunda son las ocho columnas por API (`<api>/columna.md`). La
tercera son las 36 filas arbitradas (`filas/F-nn.md`). Cuando el escéptico corrige una fila, vale
su versión. Las cuentas se hacen sobre esta tabla y se comprueban dos veces, a mano y con un
script que las recalcula a partir de las celdas.

**Lo que no es.** No sustituye a los tableros por API de `03_datos/apis/*/fricciones.md`, que
siguen siendo la fuente de cada celda que tiene fila en ellos. Veinticinco celdas con ocurrencia
no la tienen. Su fuente es la columna de su API (`<api>/columna.md`) con la fila arbitrada
(`filas/F-nn.md`), más el apartado (d) si la celda se verificó en esta pasada (E25): Postmark F-11,
F-13, F-18, F-28 y F-34; Resend F-09, F-10, F-18 y F-38; SendGrid F-18, F-26, F-28, F-31 y F-34;
MailerSend F-23, F-24, F-26, F-28, F-34, F-37 y F-38; Brevo F-34 y F-37; SES F-34 y F-37. Aquí
solo se juntan en una tabla. Donde un tablero por API
dice algo distinto, se indica en el apartado (c) o en las incoherencias finales. Este fichero no
corrige ningún tablero.

## Recuento de recurrencia

| # | Fricción | Postmark | Resend | SendGrid | MailerSend | Brevo | Amazon SES | Mailchimp | Mailgun | Vía · veredicto (D-008 · D-042) |
|---|---|---|---|---|---|---|---|---|---|---|
| F-01 | Un rate que existe y cuyo valor no se publica | ✅ | ⚠️ parcial | ⚠️ parcial | ⚠️ parcial | ⚠️ parcial | ✅ | ✅ | ✅ | **PROMOVIBLE** (4/8) · recurr. · P-04 |
| F-02 | Volumen contratado con precio y sobrecoste propios | ✅ | ✅ | ✅ | ✅ | ⚠️ variante que no suma | ❌ | ❌ | ✅ | **PROMOVIBLE** (5/8) · recurr. · P-01 |
| F-03 | CRF multiplicativo entre dimensiones anidadas | ✅ | ✅ | ⚠️ acotada | ⚠️ acotada | ⚠️ acotada | ✅ | ❌ | ❌ | **PROMOVIBLE** (3/8) · recurr. · P-02 |
| F-04 | Restricciones declaradas que el proveedor admite no aplicar o que la respuesta no refleja | ✅ | ❌ | ❌ | ⚠️ variante que suma | *(verificar)* | ✅ | ✅ | *(verificar)* | **PROMOVIBLE** (3 + 1 variante = 4/8) · recurr. · discus. |
| F-05 | Results Per Request documentada y no serializable | ✅ | *(verificar)* | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | **PROMOVIBLE** (7/8) · recurr. |
| F-06 | Workload acotado por una métrica distinta de la suya | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | **PROMOVIBLE** (8/8) · recurr. · P-03 |
| F-07 | Add-ons que modifican dimensiones de capacidad | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | **PROMOVIBLE** (8/8) · recurr. |
| F-08 | El plan real es tier × volumen contratado | ✅ | ⚠️ parcial | ✅ | ✅ | ✅ | ⚠️ variante que no suma | ⚠️ variante que no suma | ⚠️ variante que no suma | **PROMOVIBLE** (4/8) · recurr. |
| F-09 | El documento caduca entero, y sus datos caducan uno a uno | *(verificar)* | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ parcial | ❌ | **PROMOVIBLE** (5/8) · recurr. |
| F-10 | Dos productos de precio con unidades de consumo distintas | ❌ | ✅ | ✅ | ⚠️ parcial | ⚠️ variante que no suma | ⚠️ variante que no suma | ✅ | ⚠️ variante que no suma | **PROMOVIBLE** (3/8) · recurr. |
| F-11 | Límites de recursos por plan, que no son consumo | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ variante que no suma | ❌ | ✅ | **PROMOVIBLE** (6/8) · recurr. |
| F-12 | La recepción consume la cuota de envío | *(verificar)* | ✅ | *(verificar)* | ✅ | *(verificar)* | *(verificar)* | *(verificar)* | *(verificar)* | **PROMOVIBLE** (2/8) · recurr. |
| F-13 | El sobrecoste es opcional y no existe en el plan gratuito | ✅ | ✅ | ✅ | ✅ | ⚠️ variante que no suma | ❌ | ⚠️ variante que no suma | ✅ | **PROMOVIBLE** (5/8) · recurr. |
| F-14 | El plan tiene fecha de caducidad | ❌ | ❌ | ✅ | ✅ | ❌ | ⚠️ variante que no suma | ❌ | ⚠️ variante que no suma | **PROMOVIBLE** (2/8) · recurr. |
| F-15 | Dos canales, dos workload distintos para la misma cuota | *(verificar)* | *(verificar)* | ✅ | ✅ | ✅ | ⚠️ variante que no suma | ✅ | ✅ | **PROMOVIBLE** (5/8) · recurr. |
| F-16 | El sobrecoste tiene un tope que impone el proveedor | *(verificar)* | *(verificar)* | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | **PROMOVIBLE** (1/8) · traza · P-07 |
| F-18 | La capacidad depende del estado de la cuenta, no del plan | ✅ | ✅ | ⚠️ parcial | ✅ | ⚠️ variante que no suma | ✅ | ✅ | ✅ | **PROMOVIBLE** (6/8) · recurr. · P-06 |
| F-21 | Un cupo de destinatarios distintos que se gasta al probar | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | **PROMOVIBLE** (1/8) · traza · P-08 |
| F-22 | Una credencial que solo se gestiona desde la web | ✅ | ❌ | ❌ | ❌ | ✅ | ⚠️ variante que suma | ✅ | *(verificar)* | **PROMOVIBLE** (3 + 1 variante = 4/8) · recurr. |
| F-23 | Un comodín de prefijo con excepción | ❌ | ❌ | ❌ | ⚠️ variante que no suma | ✅ | ⚠️ variante que no suma | ❌ | ❌ | Sin promover (1/8) · L3 |
| F-24 | Una cuota superada que retiene hasta un número fijo de envíos y deja de entregar los siguientes | ❌ | ❌ | ❌ | ⚠️ variante que no suma | ✅ | ❌ | ❌ | ❌ | **PROMOVIBLE** (1/8) · traza |
| F-25 | Un endpoint, dos modos de envío y una carga que depende de otro campo | ❌ | ❌ | ❌ | ❌ | ✅ | ⚠️ variante que no suma | ❌ | ❌ | Sin promover (1/8) · L3 |
| F-26 | Un precio que depende de la geografía y una sola divisa en el fichero | ❌ | ❌ | ⚠️ parcial | ✅ | ✅ | ⚠️ variante que no suma | ⚠️ variante que no suma | ✅ | **PROMOVIBLE** (3/8) · recurr. |
| F-27 | Un exceso que cambia el plan en vez de pagarse por unidad, disparado por otra dimensión | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | Sin promover (1/8) · L2 |
| F-28 | Una lista de IP autorizadas decide si la llamada entra | ⚠️ parcial | *(verificar)* | ⚠️ parcial | ✅ | ✅ | *(verificar)* | ✅ | ⚠️ parcial | **PROMOVIBLE** (3/8) · recurr. |
| F-29 | Un precio por unidad sin cuota incluida de la que colgarlo | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | Sin promover (1/8) · L3 |
| F-30 | Precio por tramos marginales sobre el mismo consumo | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | Sin promover (1/8) · L2 y L3 |
| F-31 | La unidad de gobierno es el par cuenta × región | *(verificar)* | ❌ | ⚠️ variante que no suma | ❌ | ❌ | ✅ | ❌ | ⚠️ variante que no suma | Sin promover (1/8) · L2 |
| F-32 | Precio unitario degresivo sin planes que lo sostengan | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | Sin promover (1/8) · L2 |
| F-33 | Una franquicia que no caduca ni se renueva: la cuota sin ventana | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | Sin promover (1/8) · L2 |
| F-34 | Dos topes de tamaño sobre la misma llamada, uno del mensaje y otro de la petición | ⚠️ variante que no suma | *(verificar)* | ⚠️ variante que no suma | ⚠️ parcial | ⚠️ parcial | ⚠️ variante que no suma | ✅ | ✅ | **PROMOVIBLE** (2/8) · recurr. |
| F-35 | El literal de un tope trae una cifra fraccionaria y el máximo de un workload es entero | *(verificar)* | *(verificar)* | ❌ | *(verificar)* | *(verificar)* | *(verificar)* | *(verificar)* | ✅ | Sin promover (1/8) · L2 y L3 |
| F-36 | Dos contadores sobre la misma ventana, y un solo caudal por nodo | *(verificar)* | ❌ | *(verificar)* | ❌ | ❌ | ❌ | ❌ | ✅ | Sin promover (1/8) · L2 |
| F-37 | Un tope de capacidad que fija el cliente, no el proveedor | *(verificar)* | *(verificar)* | *(verificar)* | ⚠️ variante que no suma | ⚠️ variante que suma | ⚠️ variante que no suma | *(verificar)* | ✅ | **PROMOVIBLE** (1 + 1 variante = 2/8) · recurr. |
| F-38 | Dos cuotas concurrentes de la misma unidad | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ⏸ | Sin promover (1/8) · L2 |

## (a) Leyenda

| Símbolo | Significado | Suma |
|---|---|---|
| ✅ | Ocurrencia plena: el enunciado se cumple entero en esa API | 1 |
| ⚠️ variante que suma | Pasa V1 (el enunciado entero, con otro mecanismo) y V2 (no cuenta ya como plena en otra fricción). Regla B10 | 1 |
| ⚠️ variante que no suma | Variante que falla V1, V2 o las dos | 0 |
| ⚠️ parcial | Solo se cumple una parte del enunciado. B10 no se aplica a esta marca | 0 |
| ⚠️ acotada | El mecanismo existe, pero con un tope que lo reduce a otra fricción o a un caso ya contado | 0 |
| ❌ | Se comprobó y no está | 0 |
| *(verificar)* | No hay fuente que lo afirme ni que lo niegue. Por G2 la celda se deja vacía y no se marca con raya | 0 |
| ⏸ | En suspenso: depende de una discrepancia abierta (DISC-nn) | 0 |

**Columna de veredicto.** Primero va el recuento, plenas más variantes que suman, sobre 8.
Después va la vía de B9: `recurr.` si el patrón aparece en 2 APIs o más, `traza` si una sola API
cumple L1, L2 y L3, y, si no promueve, la condición que falla. Al final va la propuesta P-nn,
cuando la hay. «discus.» es la etiqueta que la fila de F-04 ya lleva en el Capítulo 6 y no es una
P-nn.

**De la tabla a la notación del Capítulo 6.** ✅ se escribe «sí». ⚠️ variante que suma también
se escribe «sí», por la decisión 1 del apartado (c). ⚠️ variante que no suma se escribe «var.»,
parcial «parc.», acotada «acot.», ❌ «---», *(verificar)* «n/v» y ⏸ «susp.».

**Símbolo de ausencia.** Algunos tableros por API marcan la ausencia comprobada con «—» y otros
con ❌. Aquí se usa siempre ❌. Ninguna raya se ha copiado tal cual. Cada una se volvió a leer en
su fila y acabó como ❌ o como *(verificar)*, según tuviera ancla o no.

## (b) Cifras de resumen

Todas se cuentan sobre la tabla de arriba.

- **Fricciones vivas:** 35. Son F-01 a F-38, sin F-19, que se absorbe, ni F-20 y F-17, que se retiraron.
- **Promueven:** 24.
  - **Por recurrencia:** 21. Son F-01 a F-15, F-18, F-22, F-26, F-28, F-34 y F-37.
  - **Por traza:** 3. Son F-16, F-21 y F-24.
- **En suspenso:** ninguna. F-17 lo estuvo hasta el 2026-10-18 y se retiró por B17.
- **Sin promover:** 11, todas con 1/8. Se agrupan por la condición de L que falla:
  - **Solo L3** (L1 y L2 cumplidas): 3. Son F-23, F-25 y F-29.
  - **L2** (sin ejecución archivada que muestre el efecto): 6. Son F-27, F-31, F-32, F-33, F-36 y F-38. En F-32 y F-33, L3 tampoco tiene veredicto escrito. En F-38, L3 está en disputa.
  - **L2 y L3:** 2. Son F-30 y F-35. En F-35 falla además L1 en la mitad de la ventana.
- **Presentes en las ocho APIs:** 2, F-06 y F-07, con 8/8 plenas. Le sigue F-05, con 7/8, porque Resend está en *(verificar)*.
- **Con propuesta P-nn:** 7 de las 24 promovidas: F-01 (P-04), F-02 (P-01), F-03 (P-02), F-06 (P-03), F-18 (P-06), F-16 (P-07) y F-21 (P-08). Las 17 restantes no tienen P-nn. F-04 lleva «discus.». P-05 no sale de ninguna fricción, sino de DV-03.
  - **Adenda 2026-09-25 (P-09).** Con la propuesta P-09 formulada por D-058 (CERRADA 2026-09-23) sobre F-24 (`02_overleaf/proyecto/sections/06_EvolucionEsquema.tex` línea 243, fila F-24 «traza & P-09»; fuente: `05_salida/DECISIONES.md` D-058), son 8 de las 24 promovidas las que tienen P-nn, y 16 las que no. Las ocho son F-01 (P-04), F-02 (P-01), F-03 (P-02), F-06 (P-03), F-18 (P-06), F-16 (P-07), F-21 (P-08) y F-24 (P-09).
  - **Por la vía de su fricción:** P-01, P-02, P-03, P-04 y P-06 van por recurrencia. P-07 y P-08 van por traza. P-05 sale de DV-03.
- **Variantes que suman:** 3 celdas, en tres filas: F-04 en MailerSend, F-22 en SES y F-37 en Brevo. F-37 promueve solo gracias a la suya.
- **Celdas:** 280, de 35 filas por 8 APIs. Se reparten así: ✅ 102, ⚠️ variante que suma 3, ⚠️ variante que no suma 27, ⚠️ parcial 14, ⚠️ acotada 3, ❌ 99, *(verificar)* 31 y ⏸ 1.
- **Celdas sin verificar:** 31.
  - **Postmark:** 8. F-09, F-12, F-15, F-16, F-31, F-35, F-36 y F-37.
  - **Resend:** 7. F-05, F-15, F-16, F-28, F-34, F-35 y F-37.
  - **SendGrid:** 3. F-12, F-36 y F-37.
  - **MailerSend:** 1. F-35.
  - **Brevo:** 3. F-04, F-12 y F-35.
  - **Amazon SES:** 3. F-12, F-28 y F-35.
  - **Mailchimp:** 3. F-12, F-35 y F-37.
  - **Mailgun:** 3. F-04, F-12 y F-22.
- **Celdas en suspenso:** 1, que no cuenta entre las 31: F-38 en Mailgun, por DISC-03. Las dos de MailerSend (F-17 y F-38) dependían de DISC-11 y salen con su cierre.

**Qué movería una celda sin verificar.** Si una sola celda *(verificar)* pasara a ✅, cambiaría
la vía de cuatro filas. F-31 (por Postmark), F-35 y F-36 pasarían de sin promover a `recurr.`.
F-16 pasaría de `traza` a `recurr.`, y seguiría promovida. En las otras nueve filas con
*(verificar)*, que ya promueven por recurrencia, la vía no cambia. Además, F-38 pasaría a
`recurr.` si DISC-03 se cerrara con la lectura de dos topes.

## (c) Qué cambia respecto a tab:recurrencia del Capítulo 6

**Cambios que afectan a toda la tabla.**

- Pasa de cuatro columnas de API a ocho, y de 20 filas a 36. El pie dice «cuatro APIs
  construidas» y hay que cambiarlo a ocho.
- La leyenda dice «n/v: no verificada en esa API, porque la fricción apareció después de cerrar
  su pasada». Ya no cubre todos los casos. Hay n/v de APIs que se construyeron después de que
  naciera la fricción (Mailgun en F-04 y F-12, Brevo en F-04, SES en F-28). En todos, el motivo es
  el de G2: no hay literal ni medida. La leyenda tiene que decir «sin fuente que lo afirme ni lo
  niegue».
- «alcance» deja de usarse como vía, porque F-07 pasa a `recurr.`.
- Desaparece el paréntesis de «(P-06)», porque F-18 promueve. Con él cae la frase del pie «F-18
  lleva su propuesta entre paréntesis porque está formulada y no promovida».
- Hay que añadir a la leyenda «var.» (variante que no suma). Si las filas no promovidas llevan la
  condición en la celda de vía, también hay que añadir «L2» y «L3».

**Fila por fila.** Hay 20 filas actuales. Primero van los cambios en las cuatro columnas que ya
existen. Después, las cuatro columnas nuevas, en el orden Brevo, SES, Mailchimp, Mailgun.

| F | Columnas actuales (Post., Res., Send., Mail.) | Vía y propuesta | Columnas nuevas (Brevo, SES, Mailchimp, Mailgun) |
|---|---|---|---|
| F-01 | Sin cambio | **traza → recurr.** · P-04 | parc. · sí · sí · sí |
| F-02 | Sin cambio | Sin cambio (recurr. · P-01) | var. · --- · --- · sí |
| F-03 | Sin cambio | Sin cambio (recurr. · P-02) | acot. · sí · --- · --- |
| F-04 | Sin cambio (MailerSend sigue «sí», ahora como variante que suma) | Sin cambio (recurr. · discus.) | n/v · sí · sí · n/v |
| F-05 | **Resend --- → n/v** | Sin cambio (recurr. · ---) | sí · sí · sí · sí |
| F-06 | Sin cambio | Sin cambio (recurr. · P-03) | sí · sí · sí · sí |
| F-07 | Sin cambio | **alcance → recurr.** · --- | sí · sí · sí · sí |
| F-08 | Sin cambio | Sin cambio (recurr. · ---) | sí · var. · var. · var. |
| F-09 | **Postmark --- → n/v** | Sin cambio (recurr. · ---) | sí · sí · parc. · --- |
| F-10 | Sin cambio (Postmark queda en ---, ahora verificada) | Sin cambio (recurr. · ---) | var. · var. · sí · var. |
| F-11 | Sin cambio | Sin cambio (recurr. · ---) | sí · var. · --- · sí |
| F-12 | **SendGrid --- → n/v** | Sin cambio (recurr. · ---) | n/v · n/v · n/v · n/v |
| F-13 | **Postmark n/v → sí** | Sin cambio (recurr. · ---) | var. · --- · var. · sí |
| F-14 | Sin cambio | Sin cambio (recurr. · ---) | --- · var. · --- · var. |
| F-15 | **Postmark --- → n/v; Resend --- → n/v** | Sin cambio (recurr. · ---) | sí · var. · sí · sí |
| F-16 | Sin cambio | Sin cambio (traza · P-07) | --- · --- · --- · --- |
| F-17 | Sin cambio | **--- → susp.** (ver decisión 3). *Retirada el 2026-10-18 por B17* | --- · --- · --- · --- |
| F-18 | **Postmark n/v → sí; Resend n/v → sí** | **--- → recurr.; (P-06) → P-06** | var. · sí · sí · sí |
| F-21 | **Postmark, Resend y SendGrid n/v → ---** | Sin cambio (traza · P-08) | --- · --- · --- · --- |
| F-22 | Sin cambio | **--- → recurr.** · --- | sí · sí (variante que suma) · sí · n/v |

**Filas nuevas.** Son 16. Las celdas van en el orden de las ocho columnas y terminan en «vía ·
propuesta». Para las filas que no promueven, la vía se da de las dos formas posibles (ver la
decisión 2).

| F | Celdas | Vía · propuesta |
|---|---|---|
| F-23 | --- · --- · --- · var. · sí · var. · --- · --- | --- (L3) · --- |
| F-24 | --- · --- · --- · var. · sí · --- · --- · --- | traza · --- |
| F-25 | --- · --- · --- · --- · sí · var. · --- · --- | --- (L3) · --- |
| F-26 | --- · --- · parc. · sí · sí · var. · var. · sí | recurr. · --- |
| F-27 | --- · --- · --- · --- · sí · --- · --- · --- | --- (L2) · --- |
| F-28 | parc. · n/v · parc. · sí · sí · n/v · sí · parc. | recurr. · --- |
| F-29 | --- · --- · --- · --- · --- · sí · --- · --- | --- (L3) · --- |
| F-30 | --- · --- · --- · --- · --- · sí · --- · --- | --- (L2 y L3) · --- |
| F-31 | n/v · --- · var. · --- · --- · sí · --- · var. | --- (L2) · --- |
| F-32 | --- · --- · --- · --- · --- · --- · sí · --- | --- (L2) · --- |
| F-33 | --- · --- · --- · --- · --- · --- · sí · --- | --- (L2) · --- |
| F-34 | var. · n/v · var. · parc. · parc. · var. · sí · sí | recurr. · --- |
| F-35 | n/v · n/v · --- · n/v · n/v · n/v · n/v · sí | --- (L2 y L3) · --- |
| F-36 | n/v · --- · n/v · --- · --- · --- · --- · sí | --- (L2) · --- |
| F-37 | n/v · n/v · n/v · var. · sí (variante que suma) · var. · n/v · sí | recurr. · --- |
| F-38 | --- · sí · --- · susp. · --- · --- · --- · susp. | --- (L2) · --- |

**Decisiones tomadas en nombre del autor** (aplicación de reglas, no carril rojo).

1. **La variante que suma se escribe «sí» en el Capítulo 6.** Así, el número de «sí» de cada fila
   coincide con su recuento. Es lo que la tabla ya hace con F-04 en MailerSend, y lo que el
   escéptico propone para Brevo en F-37. *Alternativa descartada:* escribir «var.», como hace el
   árbitro de F-22 para SES. Con esa opción, «var.» significaría dos cosas, una que suma y otra
   que no, y el lector no podría contar la fila.
2. **Celda de vía de las no promovidas: la tabla da las dos formas y no elige.** B9 dice «el
   veredicto va a la columna Vía: recurr., traza o la condición que falla», y según eso tocaría
   «L2» o «L3». Todos los árbitros del lote escribieron «---», que es la convención actual de la
   tabla (F-17, F-18, F-22). El escéptico de F-32 señala que dos filas en el mismo estado no se
   escriben igual. Aplicar B9 no es carril rojo. Lo que no puede pasar es mezclar las dos formas:
   la que elija el redactor se aplica a las once. *Alternativa descartada:* imponer aquí «---»
   para todas, porque contradice el texto de B9.
3. **F-17 lleva «susp.» en la celda de vía.** Es lo que hacen los tableros de datos, que escriben
   «En suspenso» en la columna «Vía · veredicto». *Alternativa descartada:* mantener «---», como
   hoy en el Capítulo 6. Así se confundiría con las once que no promueven. El escéptico de F-17
   recuerda que B9 no incluye «susp.» entre sus valores. Por eso la leyenda tiene que definirlo.
   *Nota 2026-10-18:* F-17 se retiró por B17 y «susp.» queda solo en la celda de F-38 en Mailgun.

## (d) Celdas verificadas en esta pasada

Se dan con el valor final, después del árbitro y del escéptico. Las rutas de API son relativas a
`03_datos/apis/`, los `hechos_*.md` están en `05_salida/_cap5/`, `CRITERIOS.md` está en `03_datos/`
y `BITACORA.md` en `05_salida/`.

**Postmark**
- F-10 ❌. `postmark/fuentes.md` [F5]: «Every message sent through the Bulk API counts toward your monthly email limit, just like any other message.»
- F-13 ✅. `postmark/fuentes.md` [F1]: Free «No overages allowed in this plan» y Basic «Extra emails @ $1.80 / 1,000».
- F-14 ❌. `postmark/fuentes.md` [F11]: «Your 100 free emails will renew on Sep 4, 2026». [F1]: «Basic — "$15.00/mo"».
- F-17 ❌. `postmark/datasheet.yaml`: cuatro cuotas en `capacity`, una por plan (`quota_email_included_free` a `_platform`), y ninguna cuota de endpoint.
- F-18 ✅. `postmark/fuentes.md` [F11]: «While your account is in test mode, you can only send and process 100 emails» y «You can update your plan once you've submitted an account approval request».
- F-21 ❌. `postmark/fuentes.md` [E3]: «While your account is pending approval, all recipient addresses must share the same domain». Es una restricción por dominio, no un cupo de destinatarios distintos.
- F-26 ❌, en la mitad de la divisa. `hechos_postmark.md` PM-01: «La moneda de la página de precios es USD.». La mitad de los impuestos no se ha verificado.
- F-29 ❌. `postmark/fuentes.md` [F1]: los cuatro planes traen volumen incluido, como «Starting at 10,000 emails/month» con «Extra emails @ $1.80 / 1,000».
- F-34 ⚠️ variante que no suma. El redactor la dio por ✅ y el escéptico la corrigió: `postmark/fuentes.md` [F2] dice «The request exceeded Postmark's size limit of 10 MB for our Email API» y «50 MB total payload size for our Batch Email API». Son dos topes de petición en dos endpoints, no dos topes sobre la misma llamada.
- F-35 *(verificar)*. El redactor la dio por ❌ y el árbitro la corrigió: [E4] mide la ventana con la resolución de un segundo de la cabecera `date`, y el tamaño publicado (10 MB y 50 MB, [F2]) no se midió.
- F-36 *(verificar)*. El redactor la dio por ❌ y el árbitro la corrigió. `postmark/evidencias/probe_batch_500_2026-09-07.json` da «"ratelimit-remaining": "4999"» tras un lote de 500, y el sondeo filtra las cabeceras por nombre (`probe_postmark_batch_500.sh`: «any(s in k for s in ("ratelimit", …»).
- F-38 ❌. `postmark/datasheet.yaml`: una cuota por plan, todas con `unit: MONTH`. `postmark/fuentes.md` [F1]: «100 emails/month».

**Resend**
- F-14 ❌. `resend/evidencias/paginas/2026-09-01/resend_com_pricing_md.txt`: «| Free | $0/mo | 3,000 | — |», y los demás planes tienen precio `/mo`.
- F-18 ✅. `resend/evidencias/paginas/2026-09-01/resend_com_docs_api_reference_rate_limit.txt`: «This number can be increased for trusted senders upon request.»
- F-21 ❌. `resend/evidencias/probe_ventana_destinatarios_2026-09-06.json`: B1 y B2 devuelven 422 sin gastar cuota, y B3 devuelve «"x-resend-daily-quota": "1"». `resend/fuentes.md` [E1]: «Monthly limit 2 / 3000».
- F-29 ❌. `resend_com_pricing_md.txt`: «The overage rate applies only to emails sent beyond the included volume.»
- F-34 *(verificar)*. El redactor la dio por ❌ y el escéptico la corrigió: `resend/fuentes.md` [F5] publica un solo tope («max 40MB per email»), [F6] dice «The attachments field is not supported yet.», y no se sondeó el tamaño.
- F-36 ❌. `resend_com_docs_api_reference_rate_limit.txt`: «The Resend API enforces three types of limits: rate limits …, email quotas …, and contact quotas».
- F-38 ✅. `resend/datasheet.yaml`: el plan `free` lleva «quota: quota_email_transactional_monthly_free», y `/emails` y `/emails/batch` llevan «quota: quota_email_transactional_daily_free».

**SendGrid**
- F-17 ❌. `sendgrid/datasheet.yaml` tiene una referencia de cuota por plan. `sendgrid/REVISION.md` recoge «Regla B8 aplicada el 2026-09-14 (D-035)».
- F-21 ❌. `sendgrid/fuentes.md` [E1] da «"reset_frequency": "daily"» y «"total": 100, "used": 0».
- F-29 ❌. `hechos_sendgrid.md` SG-77: «50.000 emails/month + $0.00133 per additional email».
- F-31 ⚠️ variante que no suma. `…/2026-09-06/www_twilio_com_docs_sendgrid_api_reference_mail_send_mail_send.txt`: «Regional Email sending in the European Union (EU) is available for Twilio SendGrid Pro plan or above».
- F-34 ⚠️ variante que no suma. `sendgrid/fuentes.md` [F3]: «The total size of your email, including attachments, must be less than 30MB.» [E2] mide el error: «JSON de 31.457.281 bytes … → HTTP 413».
- F-35 ❌. `sendgrid/fuentes.md` [E2]: «31.457.280 bytes (30 MiB» con un byte más da 413. [E1]: «20:47:00 y 20:48:00 UTC».
- F-38 ❌. `hechos_sendgrid.md` SG-25: «"total": 100» y «"reset_frequency": "daily"». Hay un solo contador.

**MailerSend**
- F-34 ⚠️ parcial. El redactor la dio por variante que no suma y la fila corregida la deja en parcial, igual que Brevo. La base es `mailersend/fuentes.md` [F21]: «Total size of the JSON payload | 50MB», con el tope por adjunto «Max size of 25MB. After decoding Base64».
- F-36 ❌. `mailersend/fuentes.md`: «API requests to v1/email | 120 requests to v1/email per minute». [F20]: «Every request is counted against the quota and is reset daily at midnight UTC.»
- F-37 ⚠️ variante que no suma (falla V2). `mailersend/fuentes.md` [F40]: «If you reach the billing limit, your transactional messages will stop sending». El tablero propio ya la cuenta en F-13: «✅ *(y tope voluntario del cliente)*».
- F-38 ⏸. `mailersend/fuentes.md` [F2]: «with a daily limit of 100 emails» frente a [F6]: «Free plan: 100 requests per day». DISC-11 sigue abierta. *(2026-10-18: D17 la cierra en peticiones; la celda pasa a ❌.)*

**Brevo**
- F-04 *(verificar)*. El redactor la dio por ✅ y el árbitro la corrigió. `brevo/evidencias/probe_brevo_a_caudal_por_clave_2026-09-17_224916.json`: el `x-sib-ratelimit-remaining` más bajo es «4994», así que ninguna lectura cruzó los 100 por hora. `brevo/fuentes.md` [E4]: «registrado, no adoptado, por **D6**».
- F-21 ❌. `brevo/fuentes.md` [F24]: «The daily limit resets every day, and unused emails do not roll over to the next day.» [E3]: «'credits: 300'» → «'credits: 298'».
- F-29 ❌. `hechos_brevo.md` BR-42: «Starter | Up to 100,000 emails per month». BR-40: «packs ranging from 5,000 to 1 million emails».
- F-31 ❌. `brevo/evidencias/swagger_definition_v3_2026-09-18.yml`: «servers: - url: https://api.brevo.com/v3», un único servidor. [F5]: «Data hosting | France and Germany (EU-based servers)».
- F-36 ❌. `brevo/fricciones.md` O-15: «el RPH es exactamente el RPS por 3.600».
- F-37 ⚠️ variante que suma. El redactor la dio por variante que no suma y el escéptico la corrigió. `brevo/evidencias/swagger_definition_v3_2026-09-18.yml`, ruta `/corporate/subAccount/{id}/plan`: «you can set an unlimited number of credits in your sub-organization» y `credits.email`: «Pass the value -1 for unlimited».
- F-38 ❌. `hechos_brevo.md` DISC-07: «9.000 es la aritmética de 300×30, no un segundo tope». [F25]: «It includes no daily sending limit».

**Amazon SES**
- F-03 ✅. `ses/evidencias/sesv2_service-2_2026-09-18.json`: `BulkEmailEntryList` «A list of BulkEmailEntry objects.» y `Destination` «consisting of To:, CC:, and BCC: fields.». `ses/fuentes.md` [F3]: «Sending quotas are based on recipients rather than on messages.»
- F-10 ⚠️ variante que no suma. `ses/evidencias/paginas/2026-09-18/aws_amazon_com_ses_pricing.txt`: «Volume tiers apply independently to outbound emails sent and inbound emails processed via Mail Manager.»
- F-14 ⚠️ variante que no suma. `ses/fuentes.md` [F41]: «the SES-specific free tier (3,000 email message charges per month for your first 12 months after first SES use) is no longer available for new customers.»
- F-16 ❌. `hechos_ses.md` SE-143: «No hay sobrecoste de correos, porque no hay cuota de correos incluida». SE-145: «Ningún `overage_cost` aparece en el fichero».
- F-17 ❌. `ses/datasheet.yaml`: `capacity` tiene una sola entrada, `quota_email_daily_sandbox`, y `not_found` no registra ninguna cuota excluida por B7.
- F-25 ⚠️ variante que no suma. `sesv2_service-2_2026-09-18.json`, `SendEmailRequest.Content`: «You can send either a Simple message, Raw message, or a Templated message.». `hechos_ses.md` SE-108: «Las dos cifras coinciden, así que la carga no cambia de valor.»
- F-26 ⚠️ variante que no suma. `hechos_ses.md` SE-19: «El precio saliente à la carte es idéntico en las **30 localizaciones**».
- F-35 *(verificar)*. El redactor la dio por ❌ y el árbitro la corrigió. `hechos_ses.md` SE-109: «40 MB per message (after base64 encoding).», con 🟢 por el literal y sin sondeo. [E1] da «"Max24HourSend": 200.0, "MaxSendRate": 1.0», que son valores de la cuenta y no bordes medidos.
- F-36 ❌. El redactor la dejó en ⏸ y el escéptico la corrigió. `ses/fuentes.md` [F1]: «All actions (except for SendEmail, SendRawEmail, and SendTemplatedEmail) are throttled at one request per second.» Con cualquiera de las dos lecturas de DISC-05, los dos contadores quedan en ámbitos distintos, y v0.3 puede escribir los dos (B8: «se declara **en el plan**»).
- F-37 ⚠️ variante que no suma. `sesv2_service-2_2026-09-18.json`, `PutAccountSendingAttributes`: «Enable or disable the ability of your account to send email.». Es un interruptor sin cifra.
- F-38 ❌. `sesv2_service-2_2026-09-18.json`, `SendQuota`: «information about the per-day and per-second sending limits». Son una cuota y un caudal, no dos cuotas.

**Mailchimp**
- F-22 ✅. `mailchimp/evidencias/paginas/2026-09-21/identificacion-03.txt`: «Users Get information about your account, or ping Transactional.». `errores-01.txt`: «Go to the Settings page and edit the key to allow the endpoint(s)».
- F-35 *(verificar)*. El redactor la dio por ❌ y el árbitro la corrigió. `mailchimp/fuentes.md` [F4] publica «must be less than 10MB» y «cannot exceed 25MB». `evidencias/sondeo_a_preflight_2026-09-21.md` M3 dice «El umbral está entre 10 y 11, exacto.», pero eso es un recuento de destinatarios, y el barrido de tamaño no encontró el borde.
- F-36 ❌. `mailchimp/evidencias/panel_mandrill_2026-09-21.md`: «Email sends this hour» / «0 of 25». El escéptico cambia el ancla que sostiene el «no» a `mailchimp/fuentes.md` [F4]: «The number of messages you can send in a given time is determined by your pricing plan as well as your hourly quota».
- F-38 ❌. `mailchimp/datasheet.yaml`: «NOTA el tope horario se modela como caudal y no como cuota porque contiene la velocidad sin rechazar».

**Mailgun**
- F-07 ✅. El tablero propio la tenía en *(verificar)*. `mailgun/fuentes.md` [F1]: «you can add additional IPs to your account for $59/IP/month» y «Access at 50k, included at 100K+ volumes». Está volcado en `mailgun/evidencias/paginas/2026-09-21/features-01.txt`.
- F-28 ⚠️ parcial. El tablero propio la tenía en *(verificar)*. `mailgun/evidencias/paginas/2026-09-21/limites-05.txt`, índice de la referencia: «Keys … Credentials … IP Allowlist … Users».

**Celdas de los tableros por API que el árbitro o el escéptico corrigieron** (sin contar las de
arriba).

- F-03 Brevo, de ✅ a ⚠️ acotada. `brevo/fuentes.md` DISC-03: «CERRADA el 2026-09-21 por E5, supuesto (1)». El volcado del 2026-09-21 dice «Maximum 2000 total recipients per API request».
- F-05 SES, de ❌ a ✅. `ses/evidencias/sesv2_service-2_2026-09-18.json`, `ListEmailIdentities.PageSize`: «The value you specify has to be at least 0, and can be no more than 1000.»
- F-08 SES, de ✅ a ⚠️ variante que no suma. El tablero propio dice «✅ **el caso extremo**». La mitad del tier falla: en `ses/features.md` ninguna fila niega una función a un plan, porque todas son «✓» o «Add-on».
- F-09 Mailchimp, de ✅ a ⚠️ parcial. `mailchimp/fuentes.md` [F17]: «ninguna cambia una cifra de rate o cuota».
- F-09 Mailgun, de ✅ a ❌. `mailgun/fuentes.md` [F22]: las entradas del último año sobre límites son de Mailgun Optimize, «(no aplica E3)». El tablero propio dice «hay changelog público».
- F-10 Mailgun, de ✅ a ⚠️ variante que no suma. La segunda unidad transcrita, las validaciones, cuelga del catálogo de Send y no del de Optimize. `mailgun/evidencias/paginas/2026-09-21/pricing-01.txt`, en la tarjeta Basic: «Extra emails & validations: "from $1.80 / 1,000 emails" / "from $1.20 / 100 validations"». Ningún fichero transcribe la unidad de Optimize ni la de Inspect, así que ninguno sostiene la mitad «unidades de consumo distintas». Falla V1.
- F-12 SendGrid, de ❌ a *(verificar)*. `sendgrid/fuentes.md`, «Fuentes buscadas y NO encontradas», no lo resuelve. Aplica G2.
- F-12 Mailchimp, de ❌ a *(verificar)*. El literal «receive up to 100 inbound emails per day» [F15] cubre solo la cuenta demo («The Mailchimp Transactional demo includes the following limitations:»).
- F-15 SES, de ✅ a ⚠️ variante que no suma. `ses/fuentes.md` [F1] da «40 MB per message» para v2 y SMTP y «10 MB per message» para v1. Falla V1.
- F-18 SendGrid, de ⚠️ variante a ⚠️ parcial. `mailersend/fricciones.md`: «**SendGrid** bloquea por peticiones malformadas sin umbral (parcial)».
- F-26 Resend, de *(verificar)* a ❌. `hechos_resend.md` RS-08: «Moneda de todos los precios: dólares (`$`).»
- F-28 SES, de ❌ a *(verificar)*. El ❌ de `ses/fricciones.md` («el control de acceso es de IAM y no del producto de correo») no cita ningún literal.
- F-30 Postmark, Resend y MailerSend, de ⚠️ variante a ❌ (la suma sigue en 0). `CRITERIOS.md` B10: «el caso de Postmark en F-30 falla V2: su escalera ya cuenta como ocurrencia plena en F-02».
- F-31 Resend, de *(verificar)* a ❌. `resend_com_docs_api_reference_rate_limit.txt`: «This limit applies across all API keys associated with your team.»
- F-38 Mailgun, de ✅ a ⏸. `mailgun/fuentes.md` [F1]: «100 emails/day included» y [F24]: «3000 emails per month». Que se apliquen a la vez es DISC-03, que sigue abierta.
- F-04 Mailgun, de ✅ a *(verificar)*. `mailgun/evidencias/sondeo_a_preflight_2026-09-21.txt`, T3: «adjunto=10MB → HTTP 403», «adjunto=25MB → HTTP 403», «adjunto=26MB → HTTP 403». El 403 oculta el tope publicado.

## Incoherencias que este tablero no resuelve

1. **F-27 deja de promover.** Con B9 aplicado tal como está escrito, pasa a 1/8 sin promover por
   L2. Pero `BITACORA.md` 207 dice «Brevo: F-24 y F-27 promueven, VALIDADO por Dani (chat,
   2026-09-21)». Esto deshace un estado que el autor validó. El escéptico de F-27 lo remite a una
   ficha o a la cadena del mandato. **Aplicado el 2026-09-23 (D-058):** F-27 entra en el
   Capítulo 6 sin promover, por L2, porque la validación se apoyó en una L2 que el consejo del
   pulido de §5.2 (T4) ya había mostrado que no distingue un muro de un cambio de plan, y el
   Capítulo 5 lo dice así. Es aplicación de B9, no cambio de criterio. *Alternativa descartada:*
   conservar la promoción validada, que obligaba al Capítulo 6 a sostener una L2 que el
   Capítulo 5 niega. Se señala al autor para que la revierta si no está de acuerdo.
2. **F-37 promueve solo por una variante que suma** (Brevo, plan de subcuenta Corporate). B10 es
   una regla provisional. Si B10 cambiara, F-37 volvería a 1/8.
3. **La variante que suma no se escribe igual en las filas.** El árbitro de F-22 pone «var.».
   F-04 y F-37 ponen «sí». Aquí se unifica a «sí» (decisión 1).
4. **F-34 en MailerSend.** El árbitro la describe como variante en la tabla de celdas y la marca
   «parc.» en la fila. Aquí se sigue la fila corregida. La suma es 0 en los dos casos.
5. **La condición L3 no se nombra igual en filas que están en el mismo estado.** F-30 dice «por
   L2 y L3» y F-32 y F-33 dicen «por L2 (L3 sin veredicto escrito)». En las tres, L3 está sin
   comprobar. Aquí se cuenta lo que dice cada fila. Si se unificara, las cifras de (b) pasarían
   a 4 por solo L2 y 4 por L2 y L3.
6. **Los tableros por API no están alineados con este recuento.** *(Alineados el 2026-09-25 por D-060 salvo las viñetas sin marca; F-21 de Brevo, F-22 de Mailchimp y seis celdas de SES, no listadas aquí, se alinearon el 2026-09-28.)* Estas son las diferencias:
   - SES, Mailchimp y `docs/07-estado.md` siguen poniendo F-01 «por traza». *(resuelto el 2026-09-25, D-060)*
   - B11 dice «seis» para F-02.
   - Mailchimp da «6/7» para F-11.
   - F-08 en SES sigue en ✅ (SE-191). *(resuelto el 2026-09-25, D-060)*
   - Mailchimp y Mailgun conservan el ✅ de F-09. *(resuelto el 2026-09-25, D-060)*
   - Mailgun tiene F-07 en *(verificar)*. *(resuelto el 2026-09-25, D-060)*
   - `ses/fricciones.md` y `docs/07-estado.md` dan «L2 cumplida» para F-31.
   - `docs/07-estado.md` dice «Su vía sigue siendo traza» para F-23.
   - Mailgun dice «las cuatro cruzan por traza». *(resuelto el 2026-09-25, D-060)*
7. **El recuento global no cuadra.** `docs/07-estado.md` da 21 o 23 promovibles, según el
   párrafo. Aquí salen 24 de 36.
8. **Brevo no tiene fila BR-nn ni celda F-37** en sus artefactos, y el escéptico la cuenta como
   variante que suma. L1 de esa celda pide la fila en `hechos_brevo.md`.
9. **Autoría.** La forma que proponen F-36 y F-38 (una lista de caudales o de cuotas) es el issue
   #1 de `prime4api` (`03_datos/DISCREPANCIAS_v03.md`: «#1 «Soportar listas de rates y cuotas en
   datasheet», de rgavira»). No puede presentarse como propuesta propia.
10. **Tensión entre F-22 y F-28 en SES.** F-22 suma como variante en SES porque el mecanismo vive
    en IAM, y su V2 se apoya en el ❌ de F-28 en SES. Ese ❌ ahora es *(verificar)*. V2 se sigue
    cumpliendo, porque *(verificar)* no cuenta como plena. Pero el escéptico de F-28 avisa de que,
    si IAM cuenta para F-22, no se puede excluir en F-28. No cambia ningún recuento.
