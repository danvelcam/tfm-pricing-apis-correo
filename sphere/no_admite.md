# Lo que Pricing2YAML no admite en las ocho APIs de correo (R27)

Pricing2YAML y SPHERE son del grupo ISA; este documento los aplica y señala dónde se quedan cortos
para ocho APIs de correo. La sintaxis de referencia es la 3.0 que lee pricing4ts 0.10.4, la versión
que usa SPHERE. Cada entrada sigue el mismo orden: caso real, limitación del modelo y extensión
propuesta. Las referencias `DS:n` apuntan a la línea de la Datasheet de la API que se nombra delante
(`03_datos/apis/<api>/datasheet.yaml`), y las del tipo `sendgrid.yaml:n` al YAML de esta carpeta.
Un `:n` suelto repite el último fichero citado.

Salen **20 limitaciones**. Las 16 de R21 salieron de MailerSend y Resend, y todas reaparecen en al
menos otra API. Cuatro son nuevas (L17 a L20): cada una nace de un caso que no encaja en ninguna de
las 16. Las seis primeras afectan a la forma de los límites y de la 7 a la 12 al precio y al consumo.
De la 13 a la 16 son condiciones que la sintaxis no tiene dónde poner, y las cuatro nuevas tratan la
clave del contador, el plazo y la divisa.

| Limitación | MailerSend | Resend | SendGrid | Brevo | Mailchimp | Mailgun | Postmark | SES |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| L1. Límite de la operación | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| L2. Caudal frente a cuota | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| L3. Tipo de ventana | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| L4. Tope por petición | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| L5. Ilimitado, no aplicable, cero | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| L6. Valor a medida | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| L7. Sobrecoste frente a add-on | ✓ | ✓ | ✓ | — | — | ✓ | ✓ | — |
| L8. Precio según volumen | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| L9. Consumo múltiple | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| L10. Add-on por volumen y plazo | ✓ | — | ✓ | ✓ | — | — | ✓ | ✓ |
| L11. Agotamiento de la cuota | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| L12. Descuentos condicionados | ✓ | — | — | — | ✓ | — | — | — |
| L13. Estado de la cuenta | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| L14. Umbral de uso | ✓ | ✓ | ✓ | — | — | — | ✓ | — |
| L15. Dos productos | — | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| L16. Procedencia del dato | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| L17. Precio por uso sin volumen incluido | — | — | — | — | — | — | — | ✓ |
| L18. Contador por región o por IP | ✓ | — | — | — | — | ✓ | — | ✓ |
| L19. Plan o precio con plazo | ✓ | — | ✓ | — | — | ✓ | — | ✓ |
| L20. Una sola divisa | — | — | — | ✓ | — | ✓ | — | — |

Un «—» dice que no se encontró un caso en la Datasheet o en el YAML, no que la API esté libre de la
limitación. Las columnas de MailerSend y Resend salen de los casos de R21, más el Enterprise de MailerSend en L6.

## A. La forma del límite

### L1. El límite es de la operación, no de la funcionalidad

- **Caso real.** MailerSend fija 60 peticiones por minuto para los endpoints generales, 120 para
  `POST /v1/email` y entre 10 y 30 para `POST /v1/bulk-email` según el plan (DS:100-165). En la
  Datasheet cada caudal cuelga de su ruta, con el comodín `/*` para el resto (DS:198-219).
- **Limitación.** Un `usageLimit` solo se enlaza a *features* con `linkedFeatures`. Para escribirlo
  hubo que crear una *feature* por endpoint y un límite por caudal (`mailersend.yaml:130`, `:144`,
  `:155`). El comodín no tiene equivalente: el caudal general se enlazó a cuatro *features* de gestión
  elegidas a mano. Tampoco se puede decir si una petición a `/v1/email` cuenta también contra los 60
  generales.
- **Extensión propuesta.** Un ámbito opcional en el límite, `scope: {operations: [...]}`, con
  patrones de ruta y una regla de precedencia entre el patrón específico y el comodín.
- **En las otras APIs.** SendGrid solo publica el caudal del envío, y en los endpoints de lectura se
  midieron 600 peticiones (DS:203, DS:241). Brevo comparte una fila entre varios endpoints y da un
  prefijo con excepción (DS:351-353). Mailgun separa 1.500 peticiones por segundo de API y 80.000 cada
  10 segundos de envío (DS:69-81). SES fija un caudal para todas las acciones salvo las de envío
  (DS:218). En Mailchimp el tope de la cuenta se repite en tres endpoints (DS:162), y las búsquedas
  van a 20 por minuto (DS:39-44).

### L2. Caudal y cuota se escriben igual

- **Caso real.** Resend limita a 10 peticiones por segundo por equipo y a 3.000 emails al mes en Free
  (DS:62-80, DS:23-29). El primero protege la infraestructura; el segundo es lo que se paga.
- **Limitación.** Los dos son `RENEWABLE` con un `period`, el primero de un segundo
  (`resend.yaml:104`) y el segundo de un mes (`resend.yaml:78`). La analítica de SPHERE los cuenta
  igual: los tres límites renovables de Resend mezclan dos naturalezas. El ACM sí las separa, en
  `max_power` y `capacity`.
- **Extensión propuesta.** Un atributo `kind: rate | quota` en el límite renovable, o un bloque
  `rates` aparte, para que la analítica no compare un caudal con una cuota.
- **En las otras APIs.** El mismo `RENEWABLE` escribe una cuota mensual y un caudal por segundo en
  SendGrid (`sendgrid.yaml:96` frente a `:121`), Brevo (`brevo.yaml:93` frente a `:117`) y Mailgun
  (`mailgun.yaml:141` frente a `:165`). Lo mismo pasa en Postmark (`postmark.yaml:136` frente a
  `:152`) y SES (`ses.yaml:121` frente a `:134`). En Mailchimp el tope horario no rechaza, encola
  (DS:161), y aun así se escribe como la cuota (`mailchimp.yaml:98` frente a `:105`).

### L3. No hay tipo de ventana

- **Caso real.** La cuota diaria de MailerSend se repone a medianoche UTC (DS:73, DS:479). La
  mensual sigue el ciclo de facturación (DS:30). La diaria de Resend pide esperar 24 horas sin decir
  desde cuándo (DS:22, DS:277).
- **Limitación.** `period` solo tiene `unit` y `value` (`mailersend.yaml:117`, `resend.yaml:92`). Una
  ventana fija de calendario, una anclada al alta y una deslizante se escriben igual. La diferencia
  importa: con ventana deslizante, el usuario no puede gastar el cupo de dos días seguidos en el cambio
  de fecha.
- **Extensión propuesta.** `period.window: calendar | billing_cycle | rolling`, con un ancla
  opcional para el primer caso (`anchor: '00:00Z'`).
- **En las otras APIs.** SendGrid repone la cuota diaria al cambio de día UTC (DS:246). SES describe
  su cuota como deslizante en una página y como periodo fijo en otra (DS:217). Mailgun ancla una
  ventana de 9,85 segundos a la primera petición (DS:329, DS:363). Postmark sigue el ciclo de la
  cuenta (DS:298). Brevo da la fecha de facturación en una fuente y 30 días en otra (DS:340, DS:342).
  Mailchimp tiene dos anclas distintas en su modo de prueba (DS:177).

### L4. El tope por petición se confunde con un stock de cuenta

- **Caso real.** MailerSend acepta hasta 70 destinatarios por petición a `/v1/email` y 35.000 por
  llamada al lote, con un cuerpo de 50 MB (DS:215-219, DS:267-275). Resend admite 50 destinatarios en
  total entre `to` y `cc` (DS:103, DS:284).
- **Limitación.** Lo único disponible es un `NON_RENEWABLE` con `trackable: false`
  (`mailersend.yaml:166`, `:175`; `resend.yaml:117`). Es la misma forma que los diez dominios de un
  plan (`mailersend.yaml:211`), que sí son un stock de la cuenta. Tampoco cabe el mínimo, ni una
  carga con dos unidades a la vez, emails y MB.
- **Extensión propuesta.** `kind: workload` con `min` y `max` por petición, como el `workload` del
  ACM, y la posibilidad de declarar varias unidades sobre la misma operación.
- **En las otras APIs.** SendGrid admite 1.000 destinatarios y 30 MiB por petición (DS:209-211).
  Brevo, 2.000 destinatarios o 99 con adjunto y 20 MB (DS:361, DS:366). Mailchimp limita el mensaje a
  10 MB sin tope de destinatarios (DS:168). Mailgun pone 1.000 destinatarios, 52 MiB y 16 kB de
  opciones (DS:98, DS:102, DS:341). Postmark declara 50 por campo y midió 50 en total, con 10 o 50 MB
  según la API (DS:282-284). SES admite 40 MB en la versión 2 y 10 MB en la 1 (DS:220).

### L5. Ilimitado, no aplicable y cero se escriben con números

- **Caso real.** Los planes de pago de Resend no tienen límite diario (DS:280). En MailerSend, Free no
  tiene el endpoint de lote (DS:507).
- **Limitación.** Lo ilimitado se escribe con el centinela 100.000.000 que el parser usa como techo
  (`resend.yaml:180`, `:194`). Lo no aplicable tuvo que ser 0: con 35.000 en Free la analítica rechazó
  el fichero, porque el límite no tenía ninguna *feature* disponible en ese plan (`validacion.txt`).
  El parser no lo detectó; un fichero que pasa el parser puede fallar al subirse.
- **Extensión propuesta.** Valores reservados `unlimited` y `not_applicable` en los límites
  `NUMERIC`, y la misma comprobación de coherencia en el parser y en la analítica.
- **En las otras APIs.** El centinela vuelve en la cuota mensual de la prueba de SendGrid y en la
  diaria de sus planes de pago (`sendgrid.yaml:94`, `:252`). También en el valor por defecto de Brevo
  (`brevo.yaml:101`) y en el Basic de Mailgun (`mailgun.yaml:291`, DS:322). Platform de Postmark
  lleva seis (`postmark.yaml:317-323`, DS:297). SES usa su propio centinela, -1 en `Max24HourSend`
  (DS:232). Mailchimp no pone tope de destinatarios (DS:168) y su máximo está en rojo (DS:61).

### L6. El valor «a medida» no cabe en un límite numérico

- **Caso real.** Resend Enterprise publica precio, cuota y caudal como *Custom* (DS:53-59, DS:82-87,
  DS:251). En la Datasheet se escribe `value: custom` y el semáforo lo marca verde.
- **Limitación.** El precio sí admite una cadena, pero un límite `NUMERIC` no. Un plan sin valores
  hereda los de Free, que son falsos para Enterprise. Por eso el plan no se escribió (`resend.yaml:197`).
- **Extensión propuesta.** Un valor reservado `custom` en los límites numéricos, distinto de
  `unlimited`, que la analítica excluya del espacio de configuración.
- **En las otras APIs.** MailerSend tiene un Enterprise a medida sin precio publicado (DS:453). Ese
  plan tampoco se escribió en SendGrid (Premier, DS:262; `sendgrid.yaml:287`), Brevo (DS:246;
  `brevo.yaml:228`) ni Mailgun (DS:319; `mailgun.yaml:348`). Mailchimp pide contacto por encima de
  161 bloques (DS:154). La cuota de producción de SES «varía» según la cuenta (DS:230).

## B. Precio y consumo

### L7. El sobrecoste se paga después; el add-on se compra antes

- **Caso real.** Hobby de MailerSend cobra 1,50 USD por cada 1.000 emails por encima de 5.000
  (DS:24-33). Resend cobra 0,90 USD por bloque de 1.000 en Pro y Scale (DS:38-40, DS:271).
- **Limitación.** Lo más cercano es un add-on escalable de 1.000 emails (`mailersend.yaml:402`,
  `resend.yaml:200`). Pero un add-on se contrata antes del mes y el sobrecoste se factura al cerrarlo.
  La analítica cuenta un único paquete: el precio máximo de MailerSend sale 115,3 USD
  (`validacion.txt`), cifra que no corresponde a ningún mes real.
- **Extensión propuesta.** Un bloque `overage` en el plan con el límite al que se aplica, el precio y
  el tramo (`per: 1000`), facturado sobre el consumo real.
- **En las otras APIs.** SendGrid cobra el exceso de Essentials y Pro (DS:198; `sendgrid.yaml:289`) y
  lo corta en diez veces la cuota del plan (DS:248). Mailgun y Postmark tienen el mismo esquema
  (Mailgun DS:316, `mailgun.yaml:350`; Postmark DS:276, `postmark.yaml:325`). En Mailchimp el bloque
  se paga antes, así que el add-on sí encaja (DS:155). Brevo no publica sobrecoste (DS:383). SES no
  tiene cuota incluida que superar, y su caso pasa a L17.

### L8. El precio del plan depende del volumen elegido

- **Caso real.** Starter de MailerSend cuesta 35, 68, 162,50, 325 o 600 USD según se contraten
  50.000, 100.000, 250.000, 500.000 o un millón de emails. El sobrecoste baja de 1,30 a 1,00
  (DS:465, DS:467). Professional tiene siete escalones y Resend seis entre Pro y Scale (DS:466,
  DS:252).
- **Limitación.** Un plan tiene un precio y un valor por límite. Se escribió el primer escalón
  (`mailersend.yaml:320`). La alternativa, un plan por escalón, da 12 planes de pago en MailerSend.
  Esos planes son el mismo con otro número, y la analítica los contaría como oferta distinta.
- **Extensión propuesta.** `volumeTiers` dentro del plan: una lista de tripletas de volumen, precio y
  sobrecoste, con un único plan visible.
- **En las otras APIs.** SendGrid publica siete volúmenes por plan (DS:197) y Mailchimp seis tramos
  (DS:153). Mailgun y Postmark tienen escaleras parecidas (Mailgun DS:315; Postmark DS:296). Brevo
  liga cada escalón de volumen a un tope de contactos (DS:329-332). En su YAML hizo falta un límite
  de parche, `contractableMonthlyVolume`, para dejar constancia de la escalera (`brevo.yaml:163`).

### L9. Una operación consume varias unidades a la vez

- **Caso real.** Una llamada a `/v1/email` de MailerSend con diez destinatarios gasta una petición de
  la cuota diaria y diez emails de la mensual (DS:546, DS:216-219). En Resend cuenta cada destinatario
  y también el correo recibido (DS:254, DS:278). En MailerSend el entrante consume la cuota de envío
  (DS:535).
- **Limitación.** `linkedFeatures` dice qué *features* gastan un límite, pero no cuánto por uso
  (`mailersend.yaml:103`, `:117`). La cuota mensual y la diaria parecen iguales aunque una se gaste
  por destinatario y la otra por llamada.
- **Extensión propuesta.** Una función de consumo por *feature*, del tipo
  `consumes: {emailsPerMonth: recipients, apiRequestsPerDay: 1}`.
- **En las otras APIs.** SendGrid cuenta por destinatario y factura también los correos descartados
  (DS:202, DS:250). SES mide la cuota por destinatario (DS:210, DS:216). Mailgun lleva un segundo
  contador de 2 millones de destinatarios (DS:332). En Postmark el envío masivo gasta la misma cuota
  mensual (DS:292). Brevo no publica la unidad (DS:388), y en Mailchimp no se pudo verificar (DS:202).

### L10. El precio del add-on depende del volumen y del plazo

- **Caso real.** MailerSend amplía la retención de actividad hasta 365 días. El precio va de 5 USD a
  625 USD al mes según el volumen contratado y el plazo (DS:529).
- **Limitación.** Un add-on tiene un precio. Las fórmulas de precio solo leen `variables` globales,
  no el volumen del plan elegido. El add-on no se escribió (`mailersend.yaml:447`).
- **Extensión propuesta.** Precio de add-on como tabla indexada por un límite del plan, o fórmulas
  que puedan leer los valores del plan contratado.
- **En las otras APIs.** SendGrid vende 30, 60 o 500 créditos de prueba al mes por 18, 30 o 200 USD
  (DS:219; `sendgrid.yaml:331`). Postmark publica la retención y el DMARC como «Starts at», sin la
  escala (DS:278; `postmark.yaml:374`). Los créditos prepago de Brevo cambian el plan al comprarlos
  (DS:386-387; `brevo.yaml:254`). SES dejó sin escribir la IP administrada, cuyo precio va por tramos
  de volumen (`ses.yaml:361-364`).

### L11. Qué pasa al agotar la cuota

- **Caso real.** El Free de MailerSend pausa el envío al agotarse (DS:458). En Resend el
  pay-as-you-go viene apagado y en Free no existe (DS:271, DS:280). MailerSend deja al cliente fijar
  un tope de gasto sobre el sobrecoste (DS:478).
- **Limitación.** El límite dice cuánto, no qué ocurre al cruzarlo. Bloquear, cobrar o frenar se
  escriben igual. La descripción del plan es el único sitio para decirlo (`mailersend.yaml:284`,
  `resend.yaml:163`).
- **Extensión propuesta.** `onExhaustion: block | overage | throttle` en el límite, y un tope de
  gasto opcional que fije el cliente.
- **En las otras APIs.** SendGrid corta el envío en diez veces la cuota (DS:248). Brevo retiene 1.000
  correos en cola y descarta el resto (DS:338), o sube de plan solo al crecer los contactos (DS:384).
  Mailchimp para el envío y ofrece la compra automática (DS:155), y encola lo que pasa del tope
  horario (DS:161). El Free de Postmark no admite exceso (DS:274). Mailgun deja que el
  cliente fije su propio tope (DS:344).

### L12. Descuentos con condiciones y no acumulables

- **Caso real.** MailerSend rebaja un 10 % el pago anual y un 30 % a las entidades sin ánimo de lucro.
  Los dos descuentos no se suman (DS:470, DS:544).
- **Limitación.** `billing` cubre el anual (`mailersend.yaml:14`). El descuento por tipo de cliente no
  tiene sitio, ni la regla que impide acumularlos.
- **Extensión propuesta.** Un bloque `discounts` con condición de elegibilidad y una marca
  `stackable`.
- **En las otras APIs.** Mailchimp rebaja un 50 % los doce primeros meses a partir de un millón de
  correos, con requisitos de elegibilidad (DS:157). El descuento anual de Brevo sí cupo en `billing`
  (`brevo.yaml:14`).

## C. Condiciones fuera del plan

### L13. Los límites cambian con el estado de la cuenta

- **Caso real.** En MailerSend, una cuenta sin aprobar tiene 100 emails al mes y 10 peticiones por
  minuto. Con la reputación en revisión, el caudal de envío baja a 10 por minuto (DS:57-65,
  DS:166-189). La Datasheet lo escribe con tres alias por endpoint (DS:203-208).
- **Limitación.** En Pricing2YAML un valor depende del plan y de los add-ons, nada más. Estos estados
  no se escribieron. Un usuario de Hobby recién dado de alta ve en el YAML 120 peticiones por minuto
  y obtiene 10.
- **Extensión propuesta.** Estados de cuenta con nombre que sobrescriben valores del plan, al modo de
  los alias del ACM.
- **En las otras APIs.** SES arranca en sandbox con 200 correos al día y otro caudal (DS:212-215;
  `ses.yaml:114`, `:127`). Postmark tiene un modo de prueba (DS:299). Mailchimp limita la cuenta demo
  a 500 correos y 25 por hora (DS:24-37), y frena por reputación (DS:165-166). En Mailgun el Free solo
  envía a destinatarios autorizados (DS:345), y el envío arranca de forma gradual (DS:352). En SendGrid el
  tope de la prueba sigue hasta que se cobra la subida de plan (DS:251). Las cuentas de Heroku y de
  revendedor tienen sus propias reglas (DS:201, DS:249). Brevo exige aprobación previa (DS:391) y
  cambia de tramo entre Advanced y Extended (DS:348).

### L14. Disponibilidad sujeta a un umbral de uso

- **Caso real.** La IP dedicada de Resend exige Scale y más de 3.000 emails al día (DS:265). La de
  MailerSend pide 500.000 emails al mes en una página de ayuda, y tres páginas oficiales dan tres
  planes mínimos distintos (DS:531-532). Con D17 manda la página de precios, que la deja en
  Enterprise; como Enterprise no se escribe, el add-on tampoco (`mailersend.yaml:443`).
- **Limitación.** `availableFor` solo lista planes (`resend.yaml:228`). El umbral queda en la
  descripción.
- **Extensión propuesta.** Una condición `requires` sobre el consumo, del tipo
  `emailsPerMonth >= 500000`.
- **En las otras APIs.** La IP dedicada de Postmark pide 300.000 correos al mes (DS:278). SendGrid
  reserva la compresión gzip a «some high volume accounts», sin cifra (DS:214).

### L15. Dos productos bajo la misma cuenta

- **Caso real.** Resend vende el correo de marketing por contactos y no por envíos. El panel muestra
  dos suscripciones independientes en la misma cuenta (DS:266-267).
- **Limitación.** Un fichero describe un `saasName`. El marketing iría en otro YAML, sin forma de
  decir que comparten cuenta ni que la recepción gasta la cuota del transaccional.
- **Extensión propuesta.** Un nivel de producto dentro del pricing, o una referencia entre ficheros
  de la misma cuenta.
- **En las otras APIs.** SendGrid vende Email API y Marketing Campaigns por separado (DS:224). Brevo
  comparte la cuota de correo entre marketing y transaccional (DS:343), y vende el SMS aparte
  (DS:396). Mailchimp ofrece el transaccional como complemento de Standard o Premium (DS:158).
  Mailgun añade Optimize e Inspect (DS:353; `mailgun.yaml:407`). SES dejó fuera Mail Manager
  (`ses.yaml:363`).

### L16. No hay procedencia ni fiabilidad del dato

- **Caso real.** Cada valor de la Datasheet lleva semáforo y fuente fechada. La cuota diaria de
  MailerSend sale de cuatro fuentes (DS:479-482). El límite de 100 emails al día del Free solo lo da
  una, y no se modela (DS:457, DS:572).
- **Limitación.** Pricing2YAML no tiene campo para la fuente ni para la confianza. Aquí la línea de la
  Datasheet va en la `description` de cada elemento, que SPHERE muestra como texto libre.
- **Extensión propuesta.** Un campo opcional `provenance` con URL, fecha de consulta y nivel de
  confianza, que la analítica pueda filtrar.
- **En las otras APIs.** SendGrid da en el panel un sobrecoste de 0,00133 que la página de precios
  publica como 0,0013 (DS:200), y 500 créditos de prueba donde la página dice 60 (DS:222). Brevo resolvió el
  precio del asiento por DISC-08 (DS:390) y dejó en ámbar los 2.000 destinatarios (DS:365). En Mailgun
  el soporte 24/7 del Free sale del panel de la cuenta propia (DS:320). Mailchimp tiene el máximo en rojo (DS:61). El
  límite de 5.000 de Postmark solo consta por cabecera (DS:286). SES deja la ventana sin declarar
  porque sus fuentes discrepan (DS:217).

## D. Clave, plazo y divisa

### L17. Precio por uso en tramos marginales, sin volumen incluido

- **Caso real.** SES no incluye ningún correo en sus planes. Cada bloque de 1.000 se paga con una
  tarifa que baja por tramos marginales de volumen (DS:209, DS:211, DS:234).
- **Limitación.** Un plan necesita un precio y unos límites con valor. Se escribió un límite a 0
  (`ses.yaml:101`) y un add-on escalable por cada plan con la tarifa del primer tramo (`ses.yaml:245-247`).
  La analítica cuenta así dos planes gratuitos, cuando en SES nada sale gratis. Los tramos
  siguientes no caben, porque el add-on tiene un solo precio. No es L7: aquí no hay cuota que superar.
- **Extensión propuesta.** Un plan con `price: usage` y una tabla de tramos marginales sobre el
  límite facturado, que la analítica lea como coste variable y no como plan gratuito.
- **En las otras APIs.** No aparece: las otras siete incluyen volumen en el precio del plan.

### L18. El contador no es de la cuenta

- **Caso real.** En SES el plan y el sandbox van por cuenta y región: una cuenta en dos regiones
  tiene dos cuotas (DS:208, DS:215). Mailgun limita a 1.500 peticiones por segundo por IP de cliente
  (DS:324). MailerSend aplica el caudal SMTP por IP, sin dar la cifra (DS:534).
- **Limitación.** Un límite de Pricing2YAML es de la suscripción, sin clave. No se puede decir que el
  contador se multiplica por región o por IP de origen, y el YAML da un solo valor.
- **Extensión propuesta.** Un atributo `key: account | region | client_ip` en el límite, que la
  analítica use para no sumar contadores independientes.

### L19. Plan o precio con plazo

- **Caso real.** La prueba de SendGrid dura 60 días, y después la cuenta deja de enviar (DS:188). La de Professional en MailerSend dura
  14 días y cae al Free (DS:514). Foundation y Scale de Mailgun anuncian un primer mes gratis antes del precio
  (DS:317). La capa
  gratuita de SES duraba doce meses y una fuente posterior la da por retirada (DS:240).
- **Limitación.** `freeTrial` es un número de días en el plan (`sendgrid.yaml:237`), sin destino al
  caducar. Un precio promocional con fecha no tiene sitio, ni el plan al que se pasa después.
- **Extensión propuesta.** Un bloque `term` en el plan o en el precio, con duración y plan de
  destino, que la analítica separe del precio estable.

### L20. Una sola divisa

- **Caso real.** Mailgun publica USD, EUR y GBP con un cambio casi constante (DS:318). Brevo publica
  ocho divisas por geolocalización, y sus precios no son conversiones entre sí (DS:335).
- **Limitación.** El fichero tiene un único `currency`. Las ocho listas de Brevo exigirían ocho
  ficheros, sin forma de decir que son la misma oferta.
- **Extensión propuesta.** Precios indexados por divisa en cada plan y add-on, con una marca que diga
  si son conversión o lista propia.
- **En las otras APIs.** MailerSend muestra EUR y GBP solo como referencia y factura en USD (DS:523),
  así que cabe con un `currency`.

## Lo que sí cupo

Planes, precios, cuotas mensuales y diarias, recursos por plan, funcionalidades que cambian con el
plan y add-ons de precio fijo pasaron sin pérdida en las ocho APIs. El descuento anual también. El
parser y la analítica de SPHERE aceptan los ocho ficheros (`validacion.txt`).
