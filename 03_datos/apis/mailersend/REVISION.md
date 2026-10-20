# Revisión — MailerSend · PASADA 1 (2026-09-08)

Cuarta API del catálogo y segunda de las que ya estaban en el repositorio de la guía
(`mailersend_v03.yaml`, 2026-03-19). Construida en un día con el ciclo de
`docs/10-revision-automatica.md`: documentación pública leída por cuatro lentes, volcados de
16 páginas con el navegador, panel con cuenta propia (el autor la creó esa tarde; estado
Sandbox), contraste con el modelado previo, las tres comprobaciones mecánicas y, la misma
noche, la **verificación independiente** (tres verificadores + corrector; tabla al final).
**Sondeo [E1] ejecutado el 2026-09-09, dos veces** (cuenta Sandbox no aprobada, coste cero; 18
casos a las 19:02 UTC y 19 a las 19:13 UTC; sección «Sondeo [E1]» abajo): ningún semáforo cambia,
tres discrepancias nuevas (DISC-17 a DISC-19) de las que la segunda ejecución **resuelve DISC-17**
a favor de la documentación; F-04 recurre, F-18 con evidencia medida, F-20 abierta como candidata
por la primera ejecución y **retirada** por la segunda (→ O-11); tanda 2 preparada, y ejecutada
al día siguiente (párrafo de abajo). Lo que sigue
es **solo lo que el libro de criterios no resuelve**.

**Tanda 2 del sondeo ejecutada el 2026-09-10** (13 casos, 11:24:08–11:26:36 UTC, misma cuenta y
mismo diseño a coste cero; sección «Tanda 2 — ejecutada» abajo): acota **DISC-18** —el tope de
`to` sin aprobar es 1, no los 10 publicados—, prueba **F-04** con el estado final de los dos
lotes, fija el tope de 5 objetos del lote con un 422 de validación en vez de un 429, y mide
`tags` y `subject` por primera vez. **Reformula DISC-19**: las cabeceras de caudal sí existen, en
los 422 y en los 200; faltan justo en el 429.

**Q1 respondida el 2026-09-10.** El autor decidió que el catálogo **adopta** los aliases de estado de
v0.3 y añade un tercero, `unapproved_account`, para la cuenta no aprobada: ficha **D-025**, regla
**D7** en `CRITERIOS.md`. La datasheet los aplica en sus siete bloques de endpoint, y el semáforo
se mueve por eso, no por el sondeo.

**Q2 respondida el 2026-09-14.** El autor decidió que el Enterprise de MailerSend **se queda fuera**
de `plans`: ficha **D-026**, regla **A3** en `CRITERIOS.md` (entra el plan con fila o tarjeta en
la página de precios, aunque diga «Custom»). La datasheet no cambia.

**Q3, Q4 y Q5 respondidas el 2026-09-14, en la misma tanda.** Las tres eligen la propuesta.
**Q3** (ficha **D-027**, regla **A4**): `/v1/bulk-email` se queda fuera del plan Free, porque la
lista oficial de precios decide qué endpoints tiene cada plan y el caudal que [F31] publica para
el Free no lo crea. **Q4** (ficha **D-028**, regla **E4**): el caudal del lote de Starter y
Professional sube a 🟢, porque una página que se declara `"default"` no contradice una tabla por
plan; **DISC-08 queda cerrada**. **Q5** (ficha **D-029**, regla **B7**): `quota_email_daily_free`
sale de `capacity`, porque ningún plan puede referenciarla sin duplicar la cuota diaria de
peticiones; su literal se queda en el provenance y el hueco en `not_found`. Semáforo tras las
Semáforo tras las tres: **48 🟢 · 15 🟡 · 1 🔴**; al completarse el test de `type` (D-031, 14-09) **49 🟢 · 14 🟡 · 1 🔴**. **Con esto MailerSend queda cerrada.**

## Estado de las comprobaciones

| Comprobación | Resultado |
|---|---|
| Formato (`gen_datasheet_viewer.py`) | **16 ok / 1 aviso / 0 errores** (tras la corrección). El aviso es el `window_type` vacío de `quota_email_daily_free` (regla D3: ninguna fuente dice cómo se repone el tope diario de 100 emails del Free; justificado en `not_found`) |
| Citas (`verificar_citas.py`) | **210 OK · 0 CAMBIO · 54 SIN-PAG · 0 SIN-CITA** sobre 16 volcados en `evidencias/paginas/2026-09-08/` (tras la corrección; antes 50 SIN-PAG: las cuatro nuevas son los literales de `activity.html`, sin volcado). Los SIN-PAG son citas de páginas leídas solo con `WebFetch` (informativo, D-023) |
| PRIME4API (`verificar_prime4api.py`) | **20 OK / 1 ERR**. El fallo (`curve.accumulated`, `TypeError` en `RateEvaluator.capacity_at`) es un defecto del motor con un rate solo y sin cuota: **DV-04**, registrada hoy en `03_datos/DISCREPANCIAS_v03.md`. Sin el workload en `MBs` del lote pasa 21/21; no se ha quitado (F-06). Con `rate` a nivel de plan también pasaría 21/21 (comprobado en la verificación) y tampoco se ha puesto: el 60/min excluye los endpoints de email y no es «caudal global del plan». Enterprise fuera del YAML (Q2, cerrada el 2026-09-14): con `price: custom` y la cuota mensual vacía quedaría en 9 OK / 13 ERR sobre 22 comprobaciones (DV-03 y DV-02, medido en una copia) |
| Panel (escalón 2) | Observado en modo lectura. Una captura redactada (`panel_dashboard_sandbox_2026-09-08_redactado.jpg`); el resto por texto. La escalera de precios interna, «Usage» y «Set billing limit» están **detrás de un muro** (dominio propio aprobado): no observables en Sandbox |
| Verificador adversarial | **Hecho** (D-013, 2026-09-08): tres verificadores (adversarial, criterios, fricciones), 30 hallazgos, tabla «Verificación independiente» al final. Ningún valor modelado refutado |
| Sondeo [E1] | **Ejecutado el 2026-09-09, dos veces: 19:02 UTC** (`probe_mailersend_sandbox.sh`, 18 casos; `evidencias/probe_sandbox_limites_2026-09-09.json`) **y 19:13 UTC** (mismo script, 19 casos, con la lectura final de la cuota; `evidencias/probe_sandbox_limites_2026-09-09_tanda1b.json`), cuenta Sandbox no aprobada, coste cero. Ningún semáforo cambia; DISC-17/18/19 nuevas con la primera, **DISC-17 resuelta** con la segunda (la cuota descuenta cada petición; el contador expuesto va por lotes y con retardo), DISC-18 y DISC-19 reproducidas; F-20 retirada → O-11; tanda 2 preparada (`probe_mailersend_sandbox_t2.sh`, ajustada) **y ejecutada el 2026-09-10**, fila siguiente. Ver la sección «Sondeo [E1]» |
| Sondeo [E1] · tanda 2 | **Ejecutada el 2026-09-10, 11:24:08–11:26:36 UTC** (`probe_mailersend_sandbox_t2.sh`, 13 casos, misma cuenta Sandbox no aprobada, coste cero; `evidencias/probe_sandbox_limites_t2_2026-09-10.json`, volcado aplanado en `evidencias/paginas/2026-09-10/`). Ningún semáforo cambia con ella: DISC-18 acotada en 1 y abierta, DISC-19 reformulada, F-04 probada con el estado final, tope del lote y topes de cuerpo medidos. Ver «Tanda 2 — ejecutada» |
| Comprobaciones tras el sondeo (2026-09-09, tras la segunda ejecución) | Formato **16 ok / 1 aviso / 0 errores** (mismo aviso) · citas **210 OK · 0 CAMBIO · 63 SIN-PAG · 0 SIN-CITA** contra `2026-09-08/` (los seis SIN-PAG nuevos son las citas de las dos líneas del provenance con URL `https://api.mailersend.com/v1/api-quota`, que salen **12 OK 1.00** contra el volcado `2026-09-09/api_mailersend_com_v1.txt`, ya con las dos tandas; las NOTA no se comprueban). Contra `2026-09-09/` el verificador da además **8 CAMBIO que no lo son**: las líneas #33, #44 y #50 citan literales de developers que contienen una URL `https://api.mailersend.com/v1/...`, el script la toma como fuente y contrasta esos literales con el volcado del sondeo; las mismas citas salen OK contra `2026-09-08/`, que es su volcado. Ya ocurría antes de la segunda tanda; se anota, no se toca el verificador · PRIME4API **20 OK / 1 ERR** (DV-04, sin cambio) |
| Comprobaciones tras los aliases (2026-09-10, con la datasheet de D-025) | Formato **16 ok / 2 avisos / 0 errores** (el aviso conocido de `quota_email_daily_free` y uno nuevo, el `window_type` vacío de `quota_email_monthly_unapproved`: la reposición de la cuota de la cuenta no aprobada no está publicada, hueco deliberado en 🔴) · citas **215 OK · 0 CAMBIO · 70 SIN-PAG · 0 SIN-CITA** contra `evidencias/paginas/2026-09-08/` (los SIN-PAG nuevos son los literales del sondeo, informativos por D-023) · PRIME4API **20 OK / 1 ERR** (DV-04, sin cambio: el motor ve los tres aliases, `nav.aliases` los lista) · `verificar_estado.py` **0 descuadres, 0 avisos, exit 0** |
| Comprobaciones tras Q3–Q5 (2026-09-14, con la datasheet de D-027, D-028 y D-029) | Formato **16 ok / 1 aviso / 0 errores**: desaparece el aviso de `quota_email_daily_free` al salir la entrada de `capacity` (D-029) y queda el hueco deliberado de `quota_email_monthly_unapproved` (D-025) · citas **215 OK · 0 CAMBIO · 70 SIN-PAG · 0 SIN-CITA** contra `evidencias/paginas/2026-09-08/`, sin cambio: las dos líneas nuevas del provenance son `NOTA` y no se comprueban · PRIME4API **20 OK / 1 ERR** (DV-04, sin cambio: la entrada retirada no la evaluaba ningún plan) · `verificar_estado.py` **0 descuadres, 0 avisos, exit 0** |

Semáforo del YAML (`grep -c` sobre `# 🟢` / `# 🟡` / `# 🔴`), **tras la verificación
independiente: 40 🟢 · 9 🟡 · 1 🔴** (antes de ella, provisional: 38 · 11 · 1). Los 9 ámbar
son: `type` (1), `window_type: fixed_billing_cycle` del Free (1), el valor del tope diario de
100 emails del Free (1, bajado de 🟢 por DISC-11), rate del lote en Starter y Professional (2) y
`max: 70` de `/v1/email` en los cuatro planes (4). Subieron a 🟢 los tres `fixed_billing_cycle`
de los planes de pago (D3, literal en dos fuentes). El rojo es la ventana del tope diario de
100 emails del Free. **Tras el sondeo [E1] (2026-09-09): 40 · 9 · 1, sin cambio.** Dos 🟢 quedan
además medidos (la reposición a medianoche UTC de la cuota diaria de peticiones y el 60/min
general en cabecera); el `max: 70` sigue 🟡 porque la cuenta no aprobada no puede sondear
50/10/10; el 120/min y el 10/min del plan siguen 🟢 por D2 aunque esta cuenta devuelva 10 y 1
(NOTA en el provenance). Ninguno sube: la regla E ampliada da verde **al dato medido**, que es el
del estado no aprobado, no al del plan. **Tras la segunda ejecución (19:13 UTC): 40 · 9 · 1, sin
cambio.** DISC-17 se resuelve a favor de la documentación (`quota_request_daily_*` ya era 🟢 por
literal; la regla «cada petición cuenta 1» queda además medida, incluidas 422, 429 y 202) y
ninguna regla del libro pide tocar un color por ello.

**Tras los aliases (D-025, 2026-09-10): 46 🟢 · 18 🟡 · 2 🔴.** El recuento lo fija
`verificar_estado.py` contra `docs/07-estado.md`, que es el tablero; aquí se transcribe, no se
calcula. Los **seis 🟢 nuevos** son la cuota mensual de 100 emails del estado no aprobado, los dos
caudales publicados de `under_review_reputation` (10/min y 1/min, literales en [F31]) y **tres
copias del mismo dato**: la carga en MBs del lote que los tres bloques de `unapproved_account`
repiten del endpoint, porque el motor no mezcla la carga del endpoint con la del alias. Los
**nueve 🟡 nuevos** son los siete `max` de `unapproved_account` y los dos caudales medidos. Los
siete: cuatro de `/v1/email`, **máximo por petición** de dos destinatarios sumando `to`, `cc` y
`bcc`; y tres del lote, `max: 5` en unidad `emails`, que son cinco objetos con un destinatario en
`to` cada uno —el tope que mide `MS42229` es de **objetos**, y son emails porque el `to` sin
aprobar solo admite una dirección—.

**Los dos que valen 2 no son el mismo tope, y conviene no leerlos como uno solo.** El que el alias
declara es el **máximo por petición**, la mayor combinación que pasa la validación (`to` 1 más
`cc` 1). El tope de dos destinatarios **únicos por cuenta** (`#MS42225`, `"any 2 recipients"` en
Sandbox [F37]) es **otra dimensión y no se modela**: ningún campo de v0.3 lo recoge y vive en
`not_found`. Las dos cifras valen 2 porque la cuenta medida no había gastado ninguno de sus dos
destinatarios únicos, no porque sean lo mismo. Dicho igual en `fricciones.md` (F-18, punto iv) y
en las cuatro descripciones del alias en el YAML.

Van en ámbar y no en
verde por decisión del 2026-09-10: la ampliación de D-024 da verde **al dato medido**, y el dato
medido es el de **una** cuenta Sandbox, no el de los cuatro planes a los que el valor se replica;
los caudales del mismo sondeo ya estaban en 🟡 por lo mismo, y darles verde a las cargas sería
asimétrico saliendo las dos cosas del mismo 429. El **🔴 nuevo** es la ventana de reposición de esa
cuota mensual, no publicada: hueco deliberado, como el del tope diario del Free.

**Tras Q4 y Q5 (D-028 y D-029, 2026-09-14): 48 🟢 · 15 🟡 · 1 🔴.** Los **dos 🟢 nuevos** son el
caudal del lote de Starter (15) y de Professional (30), que suben de 🟡 por la regla E4. Los
**dos que desaparecen** son la entrada `quota_email_daily_free` entera: su valor (🟡) y su
ventana (🔴), que sale de `capacity` por la regla B7. El único 🔴 que queda es la ventana de
reposición de la cuota mensual de la cuenta no aprobada, y el único aviso del validador es ese
mismo hueco. Los quince 🟡 restantes son los siete `max` de `unapproved_account`, los dos
caudales medidos, el `max: 70` de `/v1/email` en los cuatro planes, `type` y el
`window_type: fixed_billing_cycle` del Free.

### Comprobador mecánico — ronda 1 (2026-09-08)

Reejecución independiente de las tres comprobaciones sobre el YAML tal cual: **16 ok / 1
aviso / 0 errores** · **210 OK · 0 CAMBIO · 50 SIN-PAG · 0 SIN-CITA** · PRIME4API **20 OK /
1 ERR** (`curve.accumulated`, cubierto por DV-04). El único aviso corresponde a la entrada de
`not_found` sobre la ventana del tope diario de 100 emails del Free. Recuento de semáforo
confirmado (38 🟢 · 11 🟡 · 1 🔴); 91 líneas de provenance y 23 de `not_found`; ningún
comentario del YAML lleva más que el color salvo la línea admitida del hueco deliberado; sin
índices `[Fn]` ni `DISC-nn` en el YAML. **No se ha tocado ningún fichero de datos.** Las 210
citas con volcado coinciden al 100 % (ratio 1.00), también las de menos de 12 caracteres que
`verificar_citas.py` no mira.

Observación informativa, fuera del alcance de los tres scripts: contrastando por el mismo
método las citas `"…"` de `fuentes.md` contra los 16 volcados, 477 coinciden y 198 no son
literales tal cual. Casi todas son de tres tipos que el propio `fuentes.md` documenta: celdas
de tabla transcritas con `|` o `:` (p. ej. `"Sandbox: 100"`, `"Trial | 100"`), mensajes
`#MSnnnnn` escritos con el código detrás cuando el volcado lo lleva delante, y lecturas
`[WebFetch]` de páginas cuyo volcado es parcial (F3, F6, F39, F44) o del bloque de precios
desactualizado de DISC-03. Ninguna afecta a un valor del YAML, cuyo provenance es el que se
verifica. **Resuelto en la verificación (2026-09-08):** la cabecera de `fuentes.md` distingue
ahora citas literales de las tres convenciones de transcripción (celdas unidas con `|`/`:`/espacio,
mensaje + `#MSnnnnn`, `…` de abreviatura) y se corrigió la única celda con texto distinto del
volcado (`1 domain (30-day free trial)`); un contraste del corrector limitado a las entradas con
volcado da 576 citas, de las que 165 no coinciden tal cual, todas de esas tres formas, de
lecturas de tanda 1 marcadas como tales, o de páginas con volcado parcial ([F3], [F39], [F44]).

---

## 🔴 Alta — decisiones que no están en `CRITERIOS.md`

### Q1 · ¿Se usan los aliases de reputación de v0.3? — **CERRADA (2026-09-10)**

El README de la guía (§3.4.3) tiene aliases `healthy_reputation` / `under_review_reputation`
**con MailerSend como ejemplo**, y el modelado previo los usa. El brief y `fuentes.md`
(fila 15 del contraste) los daban por ajenos a v0.3; no lo son (O-08). MailerSend publica
cifras para los dos estados: `/v1/email` 120 → 10 por minuto, lote 10/15/30 → 1 por minuto
[F31].

**Respuesta: se adoptan.** Y se añade un **tercer alias**, `unapproved_account`, para el estado
de cuenta no aprobada que el proveedor documenta y que el vocabulario de ejemplo del README no
recoge. Ficha **D-025** en `05_salida/DECISIONES.md`; regla **D7** en `03_datos/CRITERIOS.md`, que
sustituye a D2 en las APIs con cifras por estado y deja D2 vigente donde el rate por defecto es
único.

**Por qué el tercero, y no archivar la medición bajo el segundo.** El 10/min y el 1/min que la
cuenta no aprobada devuelve coinciden con los de *"Under review reputation"*. Guardarlos ahí por
coincidencia de cifras mezclaría dos estados distintos, y entonces un cambio futuro de tramos
sería indetectable: la datasheet no podría decir cuál de los dos se movió. D7 lo zanja — el nombre
del alias sale del vocabulario de estados del proveedor, no de la tabla de escenarios del README,
que enumera casos de uso típicos y no un vocabulario cerrado.

**Aplicado.** Los siete bloques de endpoint llevan los tres aliases. `healthy_reputation` conserva
el valor por defecto sin cambiar clave ni cifra, así que las cifras del capítulo 5 se reproducen
intactas contra el PRIME4API de SPHERE en local. Las 15 llamadas quedan archivadas en
`05_salida/_cap5/prime4api_ejecucion_mailersend_2026-09-10/`, y coinciden cifra a cifra con la
ejecución del 2026-09-08: `min-time` de 5.000 emails en Hobby con k = 1 → `41min` (PI-D01);
`min-time` de 100.000 → `570day41min` con k = 1 y `570day` con k = 70 (PI-A06); `capacity-at` a
1 mes en Hobby → 5.184.120 sin tope de presupuesto (PI-D02) y 33.786,67 con 50 USD (PI-B02).
`under_review_reputation` lleva el 10/min y el 1/min publicados, en 🟢 por literal.
`unapproved_account` lleva lo medido —caudales, cuota mensual de 100 emails y carga por petición—
**todo en 🟡**, por lo dicho en el recuento de semáforo. El comodín `/*` se queda sin aliases: su
caudal no cambia de estado. Los estados sin cifra (*Rebuilding*, *Sending paused*, «newly
upgraded») no generan alias y siguen en `not_found`, por D7.

**Lo que arrastra.** (a) Los dos scripts que consumen la datasheet fijan ahora el alias que leen
(`ALIAS = healthy_reputation`, cambiable con `--alias`), porque el motor devuelve una fila por
alias donde antes devolvía una sola. (b) Habrá que revisitar **Postmark** (capacidad por estado
publicada) y **Resend** (caudal por estado sin cifra) cuando toque: la uniformidad del catálogo se
recupera hacia adelante, no rehaciendo esta pasada; SendGrid no cabe (403 sin umbral). (c) F-18 se
reescribe: pasa de «v0.3 no lo expresa» a «lo expresa y llega hasta aquí», con cinco carencias
acotadas —disparador, estado por defecto, estados sin cifra, topes que no son por petición y la
réplica en siete bloques— y una observación nueva, **O-12**.

### Q2 · Enterprise fuera del YAML — **CERRADA (2026-09-14)**

No hay tarjeta Enterprise en la página de precios (`"no hay tarjeta Enterprise en la página"`
[F1]); solo `"contact us"` [F2]. Sí hay límites publicados: 500.000 peticiones al día [F6][F20]
[F31], 60 lotes por minuto [F21][F31], cc/bcc 50 [F39], 1 IP dedicada incluida y 5.000
dominios [F3], logs 14 días [F43]. Sin precio ni volumen mensual.
**Aplicado:** fuera de `plans`; todo en provenance, `not_found` y `features.md`.
**Propuesta:** dejarlo fuera. Con `price: custom` PRIME4API tumbaría las 13 operaciones de
los cuatro planes calculables (DV-03, como Premier en SendGrid y Enterprise en Resend), y aquí
ni siquiera hay una cuota `custom` que declarar: la cuota mensual sería un hueco 🔴.
**Si dices que no:** se añade con `price: custom`, `quota_email_monthly_enterprise` vacía en
🔴, `quota_request_daily_enterprise: 500000` 🟢 y `rate_request_bulk_enterprise: 60` 🟢 (literal
en dos fuentes, sin contradicción); el resultado de PRIME4API pasa a **9 OK / 13 ERR** sobre 22
comprobaciones, porque con cinco planes hay una comprobación de precio más *(corregido el
2026-09-14: decía 8 OK / 13 ERR sin haberlo medido; ver la respuesta)*.
**Objeción del verificador de criterios (2026-09-08):** el catálogo ya modeló el tier negociado
con `price: custom` en Resend y SendGrid y `fricciones-catalogo.md` pide aplicar cada propuesta
de forma uniforme para poder rehacerla en bloque; dejar Enterprise fuera es la opción no
uniforme, y no hay regla en `CRITERIOS.md` que lo cubra. Sea cual sea tu decisión, va al libro
(sección A o B) en la misma tanda.

**Respuesta: fuera.** El autor eligió dejar el Enterprise fuera de `plans` con una regla nueva,
**A3** en `CRITERIOS.md` (ficha **D-026**): entra el plan que la página de precios muestra con
fila o tarjeta, aunque diga «Custom»; el que solo existe como «contact us» o texto de ayuda
queda fuera, con sus límites en provenance, `not_found` y `features.md`. Pidió además que los
planes `custom` y las limitaciones del modelo queden documentados a título informativo, porque
una empresa puede necesitar comparar los planes negociados de varios proveedores.

**Por qué la objeción de uniformidad no se sostiene con A3.** El catálogo no estaba repartido
dos contra uno. Resend (`'| Enterprise | Custom | Custom | Custom |'`) y SendGrid (`'Premier
Custom'`) tienen fila en la página de precios con la palabra literal, y por eso su `custom` va
en 🟢. MailerSend no tiene tarjeta, y Postmark tampoco tiene fila para su tramo por encima de
1,5 M (`"Need a bigger plan? Email to discuss our high-volume plans."`), que ya estaba fuera.
A3 describe las cuatro datasheets tal como están y no obliga a rehacer ninguna.

**Cifra corregida de la rama descartada.** Medido el 2026-09-14 sobre copias de la datasheet
fuera del repositorio, con un Enterprise copiado de Professional: solo con `price: custom`,
**11 OK / 11 ERR**; con `price: custom` y la cuota mensual vacía, **9 OK / 13 ERR** sobre 22
comprobaciones. En la segunda, el fallo de DV-04 deja de verse porque el `NoneType` salta antes,
no porque se arregle.

**Aplicado.** Nada que tocar en `datasheet.yaml`: Enterprise ya estaba fuera. Queda abierta, en
diseño y sin decidir, la propuesta del autor de mantener dos versiones de cada datasheet (una
conforme a PRIME4API y otra con las mejoras que cubren los huecos registrados como DV); si se
adopta, A3 rige la conforme a v0.3.

### Q3 · `/v1/bulk-email` omitido en el plan Free — **CERRADA (2026-09-14)**

Ninguna fuente nombra el lote junto al Free. A favor de «Free sin lote»: la tarjeta Hobby
(`"All in Free, plus:"` … `"Bulk emailing"` [F1]), la lista de Hobby (`"Access to the bulk
email endpoint"` [F2]) y el error `"This feature requires a Hobby plan or higher"` [F20]. En
contra: el artículo de rate limits publica `"Free plan: 10 API calls/min"` para `v1/bulk`
[F31], y Sandbox (que no es Free) tiene `"Bulk emailing included"` con 5 objetos [F37][F21].
**Aplicado:** omitido en Free (F-08: la superficie depende del tier), con la duda en
`not_found`. La página de precios es la lista oficial de precios por Terms 2.2 [F44].
**Propuesta:** mantener la omisión. **Si dices que no:** se añade con `rate_request_bulk_free:
10` 🟢 (literal en [F31]) y workload `max: 350` 🟡 (5 objetos × 70, el «Otherwise» de [F49]).

**Respondida el 2026-09-14.** El autor eligió **mantener omitido**. Ficha **D-027**, regla **A4** en
`CRITERIOS.md`: la lista oficial de precios decide qué endpoints expone cada plan, y un caudal
publicado en otra página para un plan al que la lista no le atribuye el endpoint no lo crea. El
`datasheet.yaml` no cambia y el semáforo no se mueve. La entrada de `not_found` que ya registraba
el caso se mantiene: es la que sostiene F-08.

### Q4 · DISC-08: el rate del lote en Starter (15) y Professional (30) — **CERRADA (2026-09-14)**

Dos páginas lo publican por plan ([F21], la referencia del endpoint, y [F31]); otras dos
publican 10/min como `"default"` sin desglose ([F20], [F39]). La regla del pipeline es no
elegir; el brief pedía modelar 10/15/30/60.
**Aplicado:** 15 y 30 en 🟡; Hobby 10 en 🟢 (las cuatro coinciden). **Propuesta:** aceptar que
la referencia del endpoint prevalece sobre la página general cuando esta se declara
`"default"` → regla nueva para el libro («la página del endpoint manda sobre la general si
esta dice *default*»), y subir a 🟢. **Si dices que no:** se quedan en 🟡 hasta que una cuenta
Starter lea `x-ratelimit-limit` en `/v1/bulk-email` (escalón 3, requiere plan de pago).
**Objeción del verificador adversarial (2026-09-08):** dar 🟢 al 10 de Hobby y 🟡 al 15/30 de la
misma frase le parece incoherente; propone 🟢 los tres (general.html dice *default*, no
contradice una tabla por plan) o, si no, DISC y 🟡 los tres. El corrector lo ha dejado como
estaba, porque el semáforo es por dato y no por frase: el 10 de Hobby lo dicen las cuatro
fuentes; el 15 y el 30 los dicen dos y los contradicen dos (DISC-08 abierta, regla 4). Subirlos
exige la regla nueva que aquí se te pide.

**Respondida el 2026-09-14.** El autor eligió **sí, con regla nueva**. Ficha **D-028**, regla **E4**
en `CRITERIOS.md`: cuando la página general publica un valor y lo llama `"default"`, y la
referencia del endpoint o el artículo específico lo desglosan por plan, manda el desglose y el
valor va en verde. `rate_request_bulk_starter` (15) y `rate_request_bulk_professional` (30) pasan
de 🟡 a 🟢, **DISC-08 queda cerrada** a favor de la fuente específica, la entrada de `not_found`
que registraba el caso se retira y su razonamiento pasa al provenance como `NOTA`. La objeción
del verificador adversarial queda contestada por el otro lado del que él proponía: los tres
valores son verdes, no los tres ámbar. El 10 de Hobby no se toca.

### Q5 · El tope diario de 100 emails del Free (F-17, en suspenso) — **CERRADA (2026-09-14)**

Solo el centro de ayuda lo expresa en emails (`"with a daily limit of 100 emails"` [F2]);
todas las demás fuentes (cuatro) dicen **100 requests** (DISC-11), que la datasheet ya modela
como `quota_request_daily_free`. Está definido en `capacity` (`quota_email_daily_free`) y **no
referenciado** desde ningún plan.
**Aplicado (tras la verificación, 2026-09-08):** el valor baja de 🟢 a **🟡** (D1: ambigüedad de
unidad, una fuente contra cuatro; el 🟢 dependía de una sola fuente contradicha), la ventana
sigue 🔴 y la entrada sigue definida y sin referenciar; `quota_request_daily_free` en el plan y
`quota_email_monthly_free` en el endpoint. F-17 pasa a «en suspenso» hasta DISC-11.
**Las dos lecturas para ti:** (a) **retirarla de `capacity`** y dejarla en provenance y
`not_found` — es la lectura conservadora del libro (B1 / D-004: lo que el esquema no puede
enlazar va a fricción + `not_found` + provenance) y evita una entrada muerta que el motor no
evalúa y que, si DISC-11 se resuelve en peticiones, duplica la cuota de peticiones; (b)
**mantenerla en `capacity` sin referencia** — visible para el lector, y sería la regla nueva
«cuota publicada que el esquema no puede enlazar: en `capacity` sin referencia» para el libro y
para `convenciones-yaml.md`. Ninguna de las tres datasheets anteriores tiene una entrada así.
El sondeo (`GET /v1/api-quota` con cuenta Free, escalón 2/3) resolvería DISC-11 antes de
decidir. **Propuesta:** (a) si no se resuelve DISC-11 antes del cierre.

**Respondida el 2026-09-14.** El autor eligió **(a), retirarla de `capacity`**. Ficha **D-029**,
regla **B7** en `CRITERIOS.md`: una cuota publicada que ningún plan puede referenciar sin
duplicar otra ya modelada no se define. La entrada `quota_email_daily_free` sale del
`datasheet.yaml` con su valor (🟡) y su ventana (🔴); el literal de [F2] se queda en el provenance
con una `NOTA` que explica la ausencia, y la entrada de `not_found` se reescribe para decir que
el tope no se modela y por qué, no solo que falta su ventana. El aviso del validador baja de dos
a uno. El sondeo no se hace: exige cuenta Free, la del autor es Sandbox, y el dato seguiría sin
nivel de enganche aunque midiera «emails». **DISC-11 sigue abierta y F-17 sigue en suspenso**: la
decisión dice dónde vive el dato, no en qué unidad está publicado.

---

## 🟡 Media — **las cuatro cerradas el 2026-09-14**

El autor las decidió en una tanda (fichas **D-030**, **D-031** y **D-032**; reglas **C2**, **D8**,
**D9** y **D10** en `CRITERIOS.md`). **Q6** cambia el test de `type` y con él el valor: MailerSend
pasa a `partial_saas`. **Q7** confirma los colores y escribe la regla del ancla. **Q8** encadena el
`max: 70` al resultado de **Q9**, que se mide con un envío real que ejecuta el autor. Lo que sigue es
el estado en que estaban al preguntarlas, con el veredicto al principio de cada una.

### Q6 · `type` — **CERRADA (2026-09-14): pasa a `partial_saas`** (D-031, reglas C2 y D9)

**Veredicto.** El autor reformuló el test: no basta con mirar si el panel envía, cuenta cualquier
operación del dominio del correo que solo se pueda hacer desde la web. Con ese test la prueba no es
el editor de arrastrar y soltar, es la referencia de la API: `POST /v1/templates` existe, pero el
`PUT` avisa de que `"Only templates created via API"` pueden actualizarse y que
`"templates created in the MailerSend app return 404"`. Editar una plantilla nacida en el panel no
es posible por API, así que la operación 2 del test —eliminatoria— falla y el valor es
`partial_saas`, **en 🟢 por D9**: las ocho operaciones quedaron comprobadas el mismo día. La 7,
supresiones, costó tres 404 porque no tiene página propia y se documenta dentro de la de
Recipients ([F54]). El verde mide la cobertura del test, no el valor. Coincide con el modelado
previo de Ramón, de modo que la fila 23 deja de ser divergencia. Lo que sigue era el planteamiento
original:

El modelado previo decía `partial_saas`. Ninguna fuente dice que el panel envíe algo que la
API no pueda: el único envío desde la interfaz es la **prueba de una plantilla** (`"send a
test email"` [F51]) y la API hace lo mismo con `template_id`. En el panel Sandbox no se abrió
el editor (modo lectura). **Aplicado:** `api_first` 🟡 por C1 (lectura conservadora), con la
duda en `not_found`. Si prefieres `partial_saas` por el editor de arrastrar y soltar, dilo:
es un cambio de una línea y una divergencia más con el modelado previo (fila 23).

### Q7 · `fixed_billing_cycle` — **CERRADA (2026-09-14): los colores se quedan** (D-030, regla D8)

**Veredicto.** El autor eligió mantener 🟢 en Hobby, Starter y Professional y 🟡 en Free, y escribir la
regla que faltaba: una frase de periodicidad (`"resets every 30 days"`) no determina el tipo de
ventana, lo determina el ancla del reinicio. DISC-12 sigue abierta. Planteamiento original:

`"resets every 30 days"` [F1][F2] frente a `"reset on your next billing day"` [F41] y
`"until your next billing period begins"` [F40]; los términos hablan de `"one month for a
monthly plan or one year for a yearly plan"` [F44]. Ninguna fuente dice `rolling` (el
modelado previo lo tenía). **Aplicado en la pasada 1:** 🟡 en las cuatro por D3. **Corregido
tras la verificación (2026-09-08):** 🟢 en Hobby, Starter y Professional — D3 pide que la fuente
diga literalmente cómo se reinicia, y lo dice dos veces para los planes de pago (`"Your monthly
email quota will reset on your next billing day."` [F41], `"until your next billing period
begins and your limits are reset"` [F40]); el «cada 30 días» no contradice el *tipo* de ventana
(sigue siendo fija y ligada a la facturación), solo deja abierto el día exacto y el plan anual,
que quedan en `not_found`. Es el mismo criterio con que SendGrid subió a 🟢 con `"sending limit
for the current billing period"`. En Free se queda 🟡: solo `"within the 30-day usage period"`,
sin frase propia de día de facturación. Si prefieres 🟡 en las cuatro hasta cerrar DISC-12, es
un cambio de tres líneas.

### Q8 · `max: 70` — **CERRADA (2026-09-14): encadenada a Q9** (D-032, regla D10)

**Veredicto.** La pregunta estaba mal planteada: [F49] sí escribe la suma, en la misma oración que
los tres sumandos, porque 35.000 es 500 × 70. Pero esa identidad es también el único argumento de
Q9, así que las dos ámbar se sostenían mutuamente. El autor eligió encadenarlas: el 70 sube a 🟢 en
cuanto el sondeo de Q9 confirme que «emails» son destinatarios, y se queda 🟡 si lo refuta.
**Medirlo directamente no es posible**: exige cuenta aprobada, y el panel no ofrece ninguna vía de
aprobación (comprobado el 14-09; ver el hallazgo corregido más abajo). **Resuelto el mismo día en
ámbar**: Q9 resultó no medible (cupo de únicos agotado), así que la condición no se cumple y el 70
se queda 🟡 — no por criterio, sino por imposibilidad medida dos veces. Planteamiento original:

Los 70 son 50 + 10 + 10 por campo sin frase de total (D4 → 🟡). Los 35.000 son literales
(`"for a total of 35,000 emails"` [F49]), pero esa cifra es 500 × 70: el proveedor hace la
suma que no escribe para el envío simple. **Aplicado:** el literal en 🟢, la suma en 🟡. Si
quieres que la aritmética de [F49] suba el 70 a 🟢, es defendible. **El sondeo [E1] (2026-09-09)
no puede subirlo:** la cuenta Sandbox no está aprobada y `to` con 10, 11, 50 y 51 direcciones
responde 422 `"The to recipient limit is exceeded. #MS42205"`; el par 50/51 y el 10/11 de `cc`
y `bcc` exigen cuenta aprobada, y la aprobación exige dominio propio, que el autor no tiene (no
controla ningún DNS). Lo que sí midió: `cc = 1` sin aprobar (literal confirmado) y que el tope
de `to` sin aprobar es **menor que los 10 publicados** (DISC-18). **La tanda 2 (2026-09-10) lo
acotó en 1**: `to = 2` ya responde `#MS42205`. **El 70 sigue 🟡 y solo la aritmética de [F49] o el
proveedor lo suben.**

### Q9 · Unidad de la cuota mensual — **CERRADA (2026-09-14): NO MEDIBLE**

**Desenlace.** Se intentó y **no se pudo**. El cupo de destinatarios únicos de Sandbox estaba
agotado: `to` 1 + `cc` 1 con dos direcciones distintas dio **422** `"You have reached sandbox
account unique recipients limit. #MS42225"`, y la variante con la misma dirección repetida dio el
mismo error más dos `#MS42201` (`"is duplicated in the … recipients list"`, publicado en [F20] y
aquí medido). `GET /v1/recipients` devuelve **0**: el cupo no es consultable. Lo agotaron las
tandas 1 y 2 probando direcciones **sin enviar nada** → **F-21** y **O-13**. Coste de la tanda 3:
**cero correos del mes**, tres peticiones diarias. La unidad de la cuota se queda como estaba
aplicada —1 por destinatario, inferida de la aritmética de [F49]— y en `not_found`. Arrastra a
**Q8**: la condición de D-032 no se puede cumplir, así que el `max: 70` se queda 🟡 por
imposibilidad medida. Detalle completo en `fuentes.md`, «Tanda 3». Planteamiento y decisión:

**Veredicto de la decisión.** El autor autorizó el envío real. De su resultado cuelga también Q8 (D-032). La vía que
proponía esta pregunta —«enviar a 2 destinatarios»— **no sirve**: la tanda 2 midió `to` = 1 sin
aprobar. La que pasa la validación es `to` 1 más `cc` 1, que son 2 destinatarios distintos en una
sola petición, con el dominio de prueba `test-86org8e1dvzgew13.mlsender.net` como remitente
(`"Domain is verified and ready to use"`, 0 Sent). Si `"Emails sent"` marca 2, la unidad es el
destinatario y el 70 de Q8 sube a 🟢; si marca 1, no. **Pendiente de ejecución.** Planteamiento
original:

Sin artículo propio. Solo la aritmética de [F49] (35.000 «emails» = destinatarios) y el
contador `total_recipients_count` del lote [F21]. **Aplicado:** 1 unidad por destinatario
en las descripciones; en `not_found`. El sondeo inocuo (enviar a 2 destinatarios desde
Sandbox y leer `"Emails sent"`) **sí gasta** 2 de los 100 emails del mes: no está en el
script; decide si compensa. **Tras [E1] (2026-09-09):** sigue sin medirse (el sondeo fue a coste
cero: nada salió). Un dato lateral que no la resuelve pero la rodea: la cuota **diaria** se
declara en peticiones y su contador expuesto **se actualiza por lotes y con retardo** (DISC-17,
resuelta con la segunda ejecución: las 17 peticiones de la primera aparecieron descontadas 11
minutos después, y 14 de la segunda de golpe). Si algún día se gastan 2 emails para leer la
unidad de la cuota mensual, la lectura de `"Emails sent"` en el panel no puede hacerse en el
acto: hay que esperar y leer dos veces. Sigue abierta y a tu decisión.

---

## 🔴 Sondeo [E1] — Ejecutado el 2026-09-09 (dos veces) y el 2026-09-10 (tanda 2)

Script `05_salida/_herramientas/probe_mailersend_sandbox.sh` (bash + curl, clave en
`~/.config/tfm/.env`, nunca por el chat), ejecutado por el autor el **2026-09-09 a las 19:02 UTC**
(tanda 1, 18 casos; el caso final `A_api_quota_final` no llegó a ejecutarse) **y otra vez a las
19:13 UTC** (tanda 1b, 19 casos, con `A_api_quota_final`), con la cuenta Sandbox **no aprobada**.
**Diseño a coste cero:** cada `POST` lleva un remitente de dominio **no verificado**, así que la
validación devuelve `422 MS42207` y el correo no se envía; como la validación informa **todos**
los campos que fallan, el par N / N+1 del campo sondeado revela el tope sin consumir emails.
Evidencia: `evidencias/probe_sandbox_limites_2026-09-09.json` (tanda 1) y
`evidencias/probe_sandbox_limites_2026-09-09_tanda1b.json` (tanda 1b), y el volcado aplanado de
las dos en `evidencias/paginas/2026-09-09/api_mailersend_com_v1.txt`; registro completo con
literales en `fuentes.md` [E1].

**Reproducción.** La tanda 1b repite **exactamente** los veredictos de la tanda 1 en B, C, R y T:
mismos códigos y mensajes, mismo 429 a 10/min en la undécima petición a `/v1/email` y a 1/min en
el segundo lote, segundo lote de 5 aceptado con 202 (`bulk_email_id` `6aa1affd1e3217ac0dd87aa1`),
de nuevo `x-ratelimit-remaining` de 9 a 0 y de nuevo las cinco 429 sin `retry-after` ni
`x-ratelimit-*`. La tabla no se duplica: cada fila vale para las dos tandas salvo la A, que es la
que cambia y la que resuelve DISC-17.

| Caso | Resultado (literal) | Qué cerró / qué no |
|---|---|---|
| A `GET /v1/api-quota` (tanda 1, 19:02) | 200 `{"quota": 100, "remaining": 100, "reset": "2026-09-10T00:00:00Z"}`; `x-apiquota-reset: 2026-09-10T00:00:00Z` en las 18 respuestas y `x-apiquota-remaining: 100` en todas | **Cerró** la reposición a medianoche UTC (ya 🟢, ahora medida). **Abrió DISC-17**: el contador no bajó con ninguna de las 17 peticiones siguientes; F-20 candidata. `A_api_quota_final` **no se ejecutó** |
| A `GET /v1/api-quota` (tanda 1b, 19:13) | 200 `{"quota": 100, "remaining": 83, ...}`; después `x-apiquota-remaining: 83` en 14 respuestas seguidas, **69 en `T_tags_6`** (83 − 14) y en las dos siguientes; `A_api_quota_final` → `"remaining": 69` | **Cerró DISC-17**: las 17 de la tanda 1 (422, 429, 202 y 200 por igual) estaban descontadas 11 minutos después; de los 18 casos uno quedó por descontar o se descontó más tarde (por número, el propio `GET /v1/api-quota`, que la doc excluye). `"Every request is counted"` se sostiene; **el contador expuesto se actualiza con retardo y por lotes** (17 y 14), no por petición. **F-20 cae** → O-11 |
| B `to` 10/11, 50/51 | 422 `"The to recipient limit is exceeded. #MS42205"` en los cuatro | **No cerró** el 70 (cuenta no aprobada). **Abrió DISC-18:** el tope de `to` sin aprobar es < 10, contra el `"up to 10 TO"` de la doc; sin acotar |
| B `cc` 1/2 (y 10/11) | `cc = 1` → solo `#MS42207` (pasa); `cc = 2` → `"The cc recipient limit is exceeded. #MS42205"` + `#MS42225` en `to` | **Cerró** `cc = 1` sin aprobar (literal confirmado) y que el límite de 2 únicos de Sandbox suma `to + cc + bcc` |
| B `bcc` 10/11 | `"The bcc recipient limit is exceeded. #MS42205"` + `#MS42225` | `bcc ≤ 9`, no acotado (doc: 1; no se probó 1/2) |
| C 5/6 objetos en `/v1/bulk-email` | 5 → **202** `"The bulk email is being processed."`, `bulk_email_id 6aa1ad527e48ed427f18cf4e` (tanda 1) y `6aa1affd1e3217ac0dd87aa1` (tanda 1b), `x-ratelimit-limit: 1`; 6 → **429** `"rate limit of 1 requests/min"` en las dos | **Cerró:** Sandbox tiene el endpoint; el lote entra con remitente que `/v1/email` rechaza (validación diferida) → **F-04 recurre**, dos veces; caudal 1/min del estado no aprobado con 429. **No cerró** el tope 5/6 (el 6 no se validó) ni el estado de los dos lotes |
| R cabeceras | `/v1/email`: `x-ratelimit-limit: 10` (9 → 0 en diez 422); lote: `1`; `GET /v1/domains`: `60` | **Cerró** el 60/min en cabecera (D6, ya 🟢). Los de email y lote **no son** 120 y 10: son los del estado no aprobado → F-18 medida; los 🟢 del plan no se tocan (D2) |
| T `tags` 5/6, `subject` 998/999 | Los cuatro → **429** `"Your account reached its rate limit of 10 requests/min. Please wait before trying again. #MS42903"` | **No medidos** (las diez B agotaron el caudal). **Cerró** el 10/min del estado no aprobado con 429 alcanzado |
| (todas las 429) | Solo `date` y `x-apiquota-*`; sin `retry-after` ni `x-ratelimit-*` | **DISC-19** (publicadas, no observadas) |

**Balance (dos ejecuciones).** 0 semáforos cambiados (40 · 9 · 1); 2 verdes además medidos, y la
regla de descuento de la cuota diaria también; 3 discrepancias nuevas con la tanda 1 (DISC-17
cuota que no descuenta, DISC-18 `to` < 10 sin aprobar, DISC-19 cabeceras del 429), de las que la
tanda 1b **resuelve DISC-17** (descuenta todas, con retardo y por lotes) y **reproduce** DISC-18 y
DISC-19; F-04 pasa de candidato a recurrente (variante «aplicación diferida», dos lotes), F-18 con
evidencia medida y reproducida, F-20 abierta y retirada el mismo día (→ O-11). Lo que **no** se
pudo medir y por qué: los topes aprobados 50/10/10 y el 70 (cuenta no aprobada); `tags` y
`subject` (caudal de 10/min agotado por los diez casos B, que iban con `sleep 2`, en las dos
tandas); el sexto objeto del lote (caudal de 1/min dos o tres segundos después del lote de 5, en
las dos); el retardo del contador de la cuota y qué lo dispara (la tanda 1b cerró 7 s después de
la última petición con tres aún sin descontar). Sigue fuera de alcance desde Sandbox: el rate del
lote de Starter y Professional (Q4), la ventana mensual (Q7), la unidad de la cuota mensual sin
gastar (Q9), DISC-11 (la cuenta es Sandbox, no Free) y nada del estado «Under review».

### Hallazgo definitivo: el muro del panel y la cuenta no aprobada

**Corregido el 2026-09-14 con observación de panel.** La versión anterior de este párrafo decía
que la aprobación exige dominio propio y lo apoyaba en [F53]. Esa cita es el modal del botón
**Upgrade**, que es contratar plan, no aprobar la cuenta; y [F37] dice justo lo contrario sobre el
trámite: `"Get approved. Submit your account for approval from your dashboard, no payment method
needed, and the recipient limit lifts."`. Se miró el panel en modo lectura el 14-09: **no existe
banner ni botón «Get approved»**, ni en el dashboard —solo `"Upgrade now"`,
`"Try Professional for free"` y `"Choose plan"`— ni en Settings (Account, Security, Users, IP
allowlist). La conclusión se mantiene con mejor prueba: **el panel no ofrece ninguna vía de
aprobación**, con dominio o sin él. Queda sin comprobar si el banner aparece al completar el perfil
de empresa, hoy vacío; rellenarlo es decisión del titular. Lo que sigue es el razonamiento
anterior, que apuntaba al hecho correcto por la cita equivocada:

La aprobación de la cuenta —que levanta los topes 10/1/1, el límite de 2 destinatarios únicos y
los caudales de 10/min y 1/min— exige **añadir y verificar un dominio propio** (`"Add your domain
to upgrade — To get started, first add your own domain. Once approved…"` [F53]). **El autor no
controla ningún DNS**, así que no puede verificar un dominio, no puede pedir la aprobación y no
puede ver la escalera interna, «Usage» ni «Set billing limit». Lo que estaba anotado como
«bloqueado hoy» queda como **hallazgo definitivo** de esta datasheet: con cuenta propia sin
dominio, MailerSend solo deja medir el estado no aprobado. Eso es material del capítulo 5 (la
escalera de validación tiene un peldaño que el proveedor cierra a quien no tiene dominio) y de
F-18 (la cuenta que cualquiera abre hoy no es la que la datasheet describe). Escalón 2 y 3
quedan agotados con lo que hay; no se pide nada más al titular en ese frente.

### Tanda 2 — ejecutada (2026-09-10, 11:24:08–11:26:36 UTC, 13 casos)

`bash 05_salida/_herramientas/probe_mailersend_sandbox_t2.sh`, sin cambios respecto al plan:
mismo ejecutor, misma cuenta Sandbox no aprobada, mismo diseño a coste cero (remitente de dominio
no verificado), `sleep 7` entre llamadas para no pasar de 10 peticiones por minuto a `/v1/email`
—el error de la tanda 1— y 61 s de espera antes del lote. Evidencia:
`evidencias/probe_sandbox_limites_t2_2026-09-10.json`; volcado aplanado en
`evidencias/paginas/2026-09-10/api_mailersend_com_v1.txt`; registro con literales en `fuentes.md`
[E1]. Duración: 2 min 28 s, 13 peticiones de las ~66 que quedaban del día.

| Caso | Resultado (literal) | Qué cerró / qué no |
|---|---|---|
| A2 `GET /v1/api-quota` (11:24:08) | 200 `{"quota": 100, "remaining": 66, "reset": "2026-09-11T00:00:00Z"}` | Solo presupuesto del día, como estaba previsto. **Añade a O-11:** el `reset` ya apuntaba al día siguiente y el `remaining` seguía sirviendo el saldo del anterior, ya completo (las dos tandas del 09-09 hicieron 37 peticiones, cuentan 34 porque los tres `GET /v1/api-quota` no cuentan, y 100 − 34 = 66; al cerrar la 1b el contador daba 69, con seis sin descontar). `B2_to_2` volvió a leer 66 y el salto a **99** llegó en la tercera petición, `B2_to_3` (11:24:22). La reposición diaria también es perezosa |
| B2 `to` 2, 3, 5, 6, 9 | 422 en los cinco, `errors.to`: `"The to recipient limit is exceeded. #MS42205"` (más `#MS42207` en `from.email`) | **Acota DISC-18:** con el `to = 1` que pasa (B_cc_1, tanda 1), el tope sin aprobar es **exactamente 1**, contra el `"up to 10 TO"` publicado. La contradicción **no** se cierra: dos lecturas en `fuentes.md`, DISC-18 |
| C2 estado de los dos lotes (`6aa1ad527e48ed427f18cf4e`, `6aa1affd1e3217ac0dd87aa1`) | 200 los dos, idénticos salvo `id` y marcas de tiempo: `state: "completed"`, `total_recipients_count: 5`, `suppressed_recipients_count: 0`, **`validation_errors_count: 5`**; los cinco objetos con `"You have reached sandbox account unique recipients limit. #MS42225"` en `errors.to` y `#MS42207` en `errors.from.email` | **Cierra F-04** por el otro extremo: los dos lotes aceptados con 202 no enviaron nada, y el cliente solo se entera si pregunta |
| C2 lote de 6 objetos (tras 61 s) | **422**, no 429: `"The number of email objects must not be greater than 5. #MS42229"` en `errors.data` | **Cierra** el tope de 5 objetos por lote sin aprobar con una respuesta de validación real, la que las dos tandas anteriores no llegaron a provocar |
| T2 `tags` 5, `subject` 998 | 422 con **solo** `errors.from.email` `#MS42207` | Los dos valores documentados **pasan** la validación |
| T2 `tags` 6, `subject` 999 | 422, `errors.tags`: `"The tags must not have more than 5 items."`; `errors.subject`: `"The subject must not be greater than 998 characters."` | **Cierra** los dos topes de cuerpo, medidos por primera vez: en las dos tandas del 09-09 los cuatro casos T habían respondido 429 sin validar |
| (ningún 429 en toda la tanda) | 12 de las 13 respuestas traen `x-ratelimit-limit` y `x-ratelimit-remaining`; la única sin ellas es la lectura de `GET /v1/api-quota` | **DISC-19 sin tercera ventana** —los 61 s evitaron el choque de caudal— y **reformulada**: las cabeceras existen en los 422 y en los 200, y faltan justo en el 429 |

**Balance.** **Ningún semáforo cambia con la tanda 2**: los topes que mide ya estaban en el YAML
por literal, y los del estado no aprobado ya estaban en 🟡 por venir de una sola cuenta (los que
se mueven los mueve D-025, no el sondeo). Cierra tres cosas que estaban a medias —el tope de `to`,
el desenlace de los dos lotes y el tope del lote— y mide dos que nunca se habían medido, `tags` y
`subject`. Reformula DISC-19 y deja **DISC-18 acotada pero abierta**, porque la cifra ya no es un
rango y la contradicción sigue sin explicación.

**Un apunte que el recuento de huecos esconde.** Al cerrar la tanda 2, la entrada de `not_found`
que decía «el estado de los dos lotes con sus `validation_errors` no se ha consultado (tanda 2)»
dejó de ser cierta: eso ya está medido. La entrada no se borró, se reescribió en el mismo renglón
con el motivo que sí sigue vivo —v0.3 no tiene dónde decir que la respuesta que mide el consumo no
es la de la petición, que es F-04—. Dicho de otro modo: **`not_found` perdió un hueco de medición y
ganó uno de esquema**, y como el validador solo cuenta la longitud de la lista, el número se
conserva sin conservar el hecho. Queda escrito aquí para que el cambio no pase por continuidad.

Lo que **no** pudo medir, por lo mismo de siempre:
los topes aprobados 50/10/10 y el `max: 70` (D4), el 120/min por defecto, el rate del lote en
Starter y Professional (DISC-08, que acabó cerrándose por criterio y no por medición: regla E4,
D-028), la unidad de la cuota mensual (Q9) y el retardo exacto del
contador de la cuota diaria. Sigue haciendo falta cuenta aprobada, y para eso hace falta dominio
propio.

---

## Preguntas de criterio nuevas para el libro (acumuladas, tanda de cuatro; las cuatro resueltas)

1. ~~**Aliases de estado (Q1).**~~ **Resuelta el 2026-09-10:** el catálogo usa los aliases
   cuando el proveedor publica cifras por estado, y el nombre sale del vocabulario del proveedor.
   Es la regla **D7** de `CRITERIOS.md` (ficha D-025); D2 sigue vigente donde el rate por defecto
   es único. Queda en la lista como registro, no como pregunta.
2. ~~**La página del endpoint manda sobre la general (Q4).**~~ **Resuelta el 2026-09-14:**
   prevalece la del endpoint y el valor va en 🟢; una página que se declara *default* no
   contradice una tabla por plan. Es la regla **E4** de `CRITERIOS.md` (ficha D-028), y cierra
   DISC-08. Queda en la lista como registro, no como pregunta.
3. ~~**Plan sin precio ni cuota publicados (Q2).**~~ **Resuelta el 2026-09-14:** un plan entra
   en `plans` si la página de precios le da fila o tarjeta, aunque diga «Custom»; sin fila ni
   tarjeta queda fuera, con sus límites en provenance, `not_found` y `features.md`. Es la regla
   **A3** de `CRITERIOS.md` (ficha D-026), que sustituye a la formulación propuesta («si publica
   al menos precio o volumen»). Queda en la lista como registro, no como pregunta.
4. ~~**Cuota publicada y no referenciable (Q5).**~~ **Resuelta el 2026-09-14:** una cuota que
   ningún plan puede referenciar sin duplicar otra ya modelada **no se define en `capacity`**;
   va al provenance, a `not_found` y a la fricción. Es la regla **B7** de `CRITERIOS.md` (ficha
   D-029), lectura conservadora de B1 / D-004. Si DISC-11 se resuelve en emails, F-17 se reabre
   con ella. Queda en la lista como registro, no como pregunta.

---

## Lo que queda abierto

- ~~**Q1–Q5**~~ **cerradas.** Q1 el 2026-09-10 (D-025, regla D7); Q2, Q3, Q4 y Q5 el
  2026-09-14 (D-026 regla A3, D-027 regla A4, D-028 regla E4, D-029 regla B7).
- ~~**Q6–Q9**~~ **cerradas el 2026-09-14.** Q6 → D-031 (reglas C2 y D9): `type` pasa a
  `partial_saas` 🟡. Q7 → D-030 (regla D8): colores intactos. Q8 → D-032 (regla D10): el 70
  encadenado a Q9 y, al resultar Q9 no medible, **resuelto en 🟡**. Q9 → **no medible**, con el
  cupo de únicos agotado por las tandas anteriores (F-21, O-13); la unidad sigue inferida y en
  `not_found`.
- **Escalón 3 agotado de verdad.** Ya no queda sondeo posible con esta cuenta: lo que falta exige
  aprobación, la aprobación no tiene vía en el panel, y el cupo que permitía enviar está gastado.
  No se vuelve a pedir nada al titular en este frente.
- **Defecto de `verificar_citas.py`, sin arreglar y a decisión del autor.** La línea 78 acepta el
  volcado de una página padre como volcado de cualquier subruta, y eso produce un `CAMBIO` falso
  —el veredicto que significa «la web cambió»— cuando lo cierto es que no hay volcado de esa
  página. Aquí se esquivó guardando los volcados que faltaban. Corregirlo convierte 15 citas de
  SendGrid de OK en SIN-PAG (medido: 140 → 125 OK).
- ~~Verificador adversarial (D-013): pendiente.~~ Hecho el 2026-09-08 (tabla al final).
- ~~Sondeo [E1]: ejecutar `bash probe_mailersend_sandbox.sh`.~~ Hecho el 2026-09-09, dos veces.
  ~~**Tanda 2:** `probe_mailersend_sandbox_t2.sh`.~~ **Hecha el 2026-09-10**, 13 casos
  (`evidencias/probe_sandbox_limites_t2_2026-09-10.json`; sección «Tanda 2 — ejecutada» arriba).
  **No queda tanda pendiente**: lo que falta por medir exige cuenta aprobada, y la aprobación
  exige dominio propio.
- ~~DISC-17~~ **resuelta** por la segunda ejecución (cada petición cuenta 1; el contador expuesto
  va por lotes y con retardo → O-11; F-20 retirada). **DISC-18 acotada** por la tanda 2 —el tope
  de `to` sin aprobar es 1— y **abierta**: la contradicción con los 10 publicados admite dos
  lecturas, y una de ellas (Sandbox como estado propio) tumbaría la discrepancia entera; están
  escritas en `fuentes.md` y **la elección es tuya**. **DISC-19 reformulada** y abierta: las
  cabeceras de caudal salen en los 422 y en los 200 y faltan justo en el 429, y la tanda 2 no
  añadió la tercera ventana porque no provocó ningún 429.
- **Dominio propio:** el autor no controla ningún DNS → la aprobación de la cuenta, la escalera
  interna, «Usage» y «Set billing limit» quedan como hallazgo definitivo (sección arriba); no se
  vuelve a pedir.
- DV-04 registrada; el fallo de `curve.accumulated` no es de la datasheet.
- Discrepancias abiertas que solo cierra una cuenta con plan de pago o el proveedor: DISC-05
  (inbound en Free), DISC-10 (SMTP 120/min o por IP), DISC-11
  (100 emails o 100 requests; Q5 decide dónde vive el dato, no su unidad), DISC-12 (Q7),
  DISC-14 (lote del trial 500/5). **DISC-08 sale de esta lista:**
  la cierra la regla E4 (D-028), no una cuenta de pago. **Y el 2026-10-18 salen DISC-04,
  DISC-06, DISC-16 y la parte de webhooks de DISC-05:** las cierra D17 (D-068), porque la página
  de precios publica el dato (IP dedicada solo Enterprise, Starter hasta 1.000.000, hilos en
  Free, 1 webhook en Hobby). El inbound de DISC-05 sigue abierto: su fila en la página no se
  captura.
- La cuenta está en Sandbox sin caducidad; el token caduca el **30 de septiembre de 2026** y
  el dominio de prueba se borra a los 30 días sin uso: la tanda 2 conviene hacerla antes.
- **Cierre administrativo pendiente** (paso 5 de la skill): actualizar `03_datos/ESTADO.md`
  (fila MailerSend, cobertura, nº de fricciones) y `docs/07-estado.md` (tabla F-01…F-20:
  catorce promovibles con F-04 en 2/4, F-12 / F-14 / F-15 en 2/4, F-18 nueva y medida, F-17 en
  suspenso, F-19 absorbida, F-20 retirada → O-11, O-12 nueva). ~~Se hace tras tus respuestas a
  **Q3–Q5**.~~ **Hecho el 2026-09-14**, con Q1–Q5 cerradas: `docs/07-estado.md` es el tablero
  único desde el 2026-09-07 y `03_datos/ESTADO.md` un puntero, así que solo se actualiza el
  primero. **MailerSend queda cerrada.** El anexo LaTeX no se regenera: D-015 retiró las
  Datasheets de la memoria y la skill `datasheet-anexo` dejó de aplicarse.
- **Para el orquestador (navegador):** confirmar con `view-source:` que el HTML de `/pricing`
  contiene `$ 5.60` y `$67.20` (ya leído dos veces sin JavaScript; anotado en [F1], DISC-03 y en
  el provenance como NOTA); volcar `GeneralHelpers.php` del SDK ([F35], bloqueado para el
  verificador) y las pantallas `/api-tokens` y `/domains` del panel (hoy solo registro de texto).

---

## Verificación independiente (2026-09-08)

Tres verificadores independientes del constructor —**adversarial** (reabrió cada URL del
provenance con un lector sin JavaScript), **criterios** (contra `CRITERIOS.md`, el README v0.3 y
las tres datasheets anteriores) y **fricciones** (contra el recuento D-008 y los `fricciones.md`
de Postmark, Resend y SendGrid)— levantaron 30 hallazgos. El corrector los contrastó uno a uno
con los volcados de `evidencias/paginas/2026-09-08/`, `fuentes.md`, el README de la guía y el
`mailersend_v03.yaml`, y con dos lecturas nuevas (`/pricing` sin JavaScript y la referencia de
tokens). **Ningún valor modelado refutado.** Balance sobre 31 filas (un hallazgo venía en dos
partes): **25 aplicados · 1 aplicado en parte · 3 descartados con razón · 2 al autor** (Q2 y Q5,
ya planteadas, ahora con el argumento del verificador; **Q2 y Q5 cerradas el 2026-09-14**, con
D-026 y D-029; el descartado 4 deja su objeción en Q4, **cerrada el mismo día** con D-028, que la
contesta por el lado contrario al que él proponía: los tres valores verdes, no los tres ámbar).
Semáforo antes/después: 38 🟢 · 11 🟡 · 1 🔴 → **40 🟢 · 9 🟡 · 1 🔴**.

| # | Hallazgo (campo · tipo · origen) | Comprobación | Acción |
|---|---|---|---|
| 1 | Tarjetas y escalera de /pricing solo por JavaScript; precios 7/35/110 🟢 · fricción dudosa · adversarial | Cierto: el volcado `_escalera` es la única evidencia; la prosa de [F2] sostiene los tres precios | **Aplicado.** NOTA en el provenance (como la de SendGrid), nota en [F1] y en la sección de verificación de `fuentes.md`; 🟢 de `price` se mantienen |
| 2 | Citas de tarjeta compuestas de celdas adyacentes; DOM con tres monedas · cita no literal · adversarial | Cierto: el volcado lleva `Extra usage` / `$1.30` / `/1,000 emails` en líneas separadas | **Aplicado.** Anotado en [F1] y en la cabecera de `fuentes.md` (convención a, la misma de SendGrid); sin cambio de valor |
| 3 | 100 emails/día frente a 100 requests/día del Free; regla 4 pide DISC · fricción dudosa · adversarial | DISC-11 ya existía con las citas; lo que faltaba era el semáforo | **Aplicado en parte:** valor 🟢 → 🟡 (D1) y DISC-11 ampliada; **al autor** si se retira la entrada de `capacity` (Q5). *Cerrada el 2026-09-14: se retira, regla B7 (D-029)* |
| 4 | Rate del lote: 10 🟢 (Hobby) frente a 15/30 🟡 · semáforo mal · adversarial | El 10 de Hobby lo dicen las cuatro fuentes; el 15 y el 30 los dicen dos y los contradicen dos (DISC-08) | **Descartado con razón** (el semáforo es por dato, no por frase; regla 4); la objeción queda en Q4, que ya pedía la regla nueva → **al autor**. *Cerrada el 2026-09-14: el 15 y el 30 suben a 🟢 por la regla E4 (D-028), y el 10 de Hobby se queda en 🟢* |
| 5 | `fixed_billing_cycle` 🟡 en los planes de pago con literal de reposición · semáforo mal · adversarial | Cierto: `"reset on your next billing day"` [F41] y `"until your next billing period begins"` [F40]; mismo criterio que SendGrid | **Aplicado.** 🟢 en Hobby, Starter y Professional; Free sigue 🟡; DISC-12, `not_found` y Q7 actualizados |
| 6 | `'Min: 1, Max: 1000'` de activity.html es `page`, no el tope por petición · fricción dudosa · adversarial | Cierto ([F33]: `limit` `Min: 10, Max: 100`, `Default: 25`) | **Aplicado.** Línea reescrita con los tres parámetros y sus literales; F-05 ya llevaba el 100 por página |
| 7 | Cita de [F49] truncada (sin `"If you're on a Hobby, Starter or Professional plan"`) · cita no literal · adversarial | Cierto ([F49] completa en `fuentes.md`) | **Aplicado.** Cita ampliada en el provenance; `max: 35000` 🟢 se mantiene |
| 8 | IP dedicada: tres condiciones en cuatro páginas, sin DISC visible desde el YAML · criterio no aplicado · adversarial | DISC-04 ya existía con las tres citas y `features.md` la cita; faltaba el literal de [F3] en el provenance | **Aplicado.** Provenance con `"at least 100,000 emails per week"` y `"must meet the following criteria"`; DISC-04 reencuadrada (ver 20) |
| 9 | `GeneralHelpers.php` no verificable (raw de GitHub bloqueado) · no encontrado · adversarial | [F35] lo leyó en crudo (sin modelo intermedio); ningún semáforo depende de él; SIN-PAG es informativo (D-023) | **Descartado con razón** (no es error; la cita es literal); volcado pedido al orquestador en «Lo que queda abierto» |
| 10 | Citas de `/api-tokens` y `/domains` sin captura ni volcado · otro · adversarial | Cierto: solo `_recoleccion/panel_observacion.md` | **Aplicado.** Anotado en [F53]; captura pedida al orquestador |
| 11 | El HTML de /pricing sin JavaScript lleva `$5.60` / `$67.20` (precios de 2024) · otro · adversarial [VERBATIM DUDOSO] | **Confirmado** por el corrector con una segunda lectura sin JavaScript: `"$ 5.60 /month"`, `"$67.20 billed yearly"` presentes; `$6.30` y `$75.60` ausentes. La reatribución CD-01 a [F11] era errónea | **Aplicado.** NOTA en el provenance, [F1] y DISC-03 corregidas, F-09; `view-source:` pedido al orquestador para cerrarlo |
| 12 | `quota_email_daily_free.value` 🟢 con DISC-11 abierta · semáforo mal · criterios | Cierto (una fuente contra cuatro; D1) | **Aplicado.** 🟡; ventana sigue 🔴; `not_found` reescrito. *El 2026-09-14 la entrada entera sale de `capacity` con sus dos colores (D-029)* |
| 13 | F-17 declarada nueva y plena sobre la lectura minoritaria de DISC-11 · fricción dudosa · criterios | Cierto | **Aplicado.** F-17 «en suspenso (pendiente de DISC-11)» en tabla y texto (ver 24) |
| 14 | Entrada de `capacity` definida y no referenciada (B1 / D-004) · criterio no aplicado · criterios | Cierto que ninguna datasheet anterior la tiene; el validador la acepta; el libro no cubre el caso | **Al autor** (Q5, con las dos lecturas y la propuesta cambiada a «solo provenance» salvo que DISC-11 se resuelva en emails). *Cerrada el 2026-09-14: solo provenance y `not_found`, regla B7 (D-029)* |
| 15 | Enterprise ausente de `plans` frente a `custom` en Resend y SendGrid · criterio no aplicado · criterios | Cierto que es la opción no uniforme y que no hay regla | **Al autor** (Q2, con la objeción añadida; `rate_request_bulk_enterprise` sería 🟢, no 🟡). *Cerrada el 2026-09-14: fuera, regla A3 (D-026)* |
| 16 | `rate` ausente a nivel de plan (las otras tres lo declaran) · otro · criterios | Comprobado: con `rate` en el plan PRIME4API pasa 21/21. Pero el 60/min es `"excluding email endpoints"` [F20]: como «caudal global del plan» contradiría el 120/min de `/v1/email`; `/*` es la forma correcta | **Descartado con razón**; resultado anotado en DV-04 (`DISCREPANCIAS_v03.md`), en `fricciones.md` y en el estado de comprobaciones |
| 17 | 198 citas de `fuentes.md` no literales tal cual (celdas, `#MS`, comillas) · cita no literal · criterios | Cierto en la forma: son transcripciones de tabla y de código; una celda con texto distinto (`30-day trial`) | **Aplicado.** Cabecera de `fuentes.md` con las tres convenciones; celda corregida; recuento propio 576 / 165 con causa (ver ronda 1) |
| 18 | 38 🟢 provisionales sin verificador · criterio no aplicado · criterios | Cierto hasta esta verificación | **Aplicado.** Esta sección es el informe D-013; recuento actualizado; MailerSend no se marca cerrada hasta el sondeo y Q1–Q5 *(estado del 2026-09-08: el sondeo se hizo el 09-09 y el 10-09, Q1 se cerró el 10-09 y Q2–Q5 el 14-09; con eso MailerSend queda cerrada)* |
| 19 | F-14 cuenta el token que caduca sin saber si la fecha la impone el proveedor · fricción dudosa · criterios | Comprobado: la referencia de tokens no tiene parámetro de expiración ([F22], relectura 2026-09-08); el token lo creó el titular; no se puede saber | **Aplicado.** Token fuera de F-14 (a observaciones como recurso F-11); provenance y `features.md` reescritos; `not_found` nuevo |
| 20 | `features.md` presenta `"at least 100,000 emails per week"` como umbral · otro · criterios | Cierto: volcado de [F3] línea 56, `"best suited"` es recomendación; el requisito es [F10] | **Aplicado.** Celda reescrita (requisito / recomendación), DISC-04 reencuadrada como plan mínimo, PI-E02 ajustada |
| 21 | ESTADO.md y 07-estado.md sin MailerSend ni F-17…F-19 · otro · criterios | Cierto; no es incumplimiento sin cierre | **Aplicado** como tarea en «Lo que queda abierto» (tras sondeo y Q1–Q5). *Hecho el 2026-09-14: `docs/07-estado.md` al día; `03_datos/ESTADO.md` es un puntero desde el 07-09 y no se toca* |
| 22 | F-03 ✅ plena con el total publicado, frente a ⚠️ en SendGrid · criterio no aplicado · fricciones | Cierto: misma situación (`"for a total of 35,000 emails"`) | **Aplicado.** ⚠️ acotado; estado «PROMOVIBLE (2/4 + 2 variantes)»; texto reescrito con el matiz (lote con total, envío simple sin él) |
| 23 | F-10 ✅ plena cuando el SMS incluido cabe en v0.3 (ejemplo canónico) · fricción dudosa · fricciones | Cierto: `mailersend_v03.yaml` lleva `sms` en el plan; solo WhatsApp es catálogo aparte | **Aplicado.** ⚠️ parcial; texto separa «lo que v0.3 no expresa» (WhatsApp) de «lo que A1 excluye» (SMS) |
| 24 | F-17 no es nueva (Resend usó dos niveles), describe mal la carencia y la propuesta es el issue #1 de rgavira · fricción dudosa · fricciones | Cierto: `resend/datasheet.yaml` líneas 95 y 101; README §3.4; `DISCREPANCIAS_v03.md` | **Aplicado.** F-17 en suspenso, reformulada como «tercer tope sin nivel de enganche», propuesta atribuida a Gavira (issue #1); número no reutilizado |
| 25 | F-19 es una instancia de F-11 (+F-18); `#MS42222` no es cardinalidad; `period: none` es rediseño · fricción dudosa · fricciones | Cierto: `resend/fricciones.md` F-11 (`resources`); [F20] MS42222 = `"email quota limit"` | **Aplicado.** F-19 «absorbida por F-11 / F-18», entrada reescrita, ejemplo y propuesta retirados |
| 26 | F-18: el mecanismo (aliases) es de Gavira/Ruiz; Postmark y Resend tienen capacidad por estado; ítem 4 es por plan; cifras en [F31] no [F42] · fricción dudosa · fricciones | Cierto en los cuatro puntos (README §3.4.3; provenance de Postmark; [F4] de Resend; [F42] sin cifras) | **Aplicado.** Entrada reescrita (abre por los aliases, acota la carencia, ítem 4 → F-08, cita corregida); tabla con Postmark y Resend «(verificar)» |
| 27 | F-09: dos filas sin evidencia de cambio (rate del lote, `rolling`); «Cuatro de cuatro» es 3/4 · contradice · fricciones | Cierto: `mailersend_v03.yaml` define `rate_15_min` / `rate_30_min` sin usarlos (O-09); nadie dijo `rolling` | **Aplicado.** Filas retiradas de la tabla (quedan en el contraste de `fuentes.md`) con la explicación; «Tres de cuatro» |
| 28 | F-14: token y dominio de prueba no son caducidad del plan; el trial no está en `plans` · fricción dudosa · fricciones | Cierto | **Aplicado.** F-14 apoyada solo en el trial; token y dominio a observaciones (F-11); frase sobre DISC-13 añadida |
| 29 | F-01: `Rebuilding` y `Sending paused` no son «caudal sin cifra» ([F42] no lo sostiene) · cita no literal · fricciones | Cierto | **Aplicado.** Párrafo reescrito: dos caudales sin cifra (newly upgraded, SMTP) y dos estados sin información |
| 30 | O-08 (c): `v1/bulk` está en `mailersend_v03.yaml`, no en el README · contradice · fricciones | Cierto (`grep v1/bulk README.md` vacío) | **Aplicado.** O-08 (c) corregida |
| 31 | Cabecera de `fricciones.md`: «once» promovibles y «tres nuevas» · contradice · fricciones | Cierto: la tabla marca trece; tras la verificación queda una nueva | **Aplicado.** Cabecera reescrita («trece cruzan el umbral; una nueva, F-18; F-17 en suspenso, F-19 absorbida») |

Recuento: **25 aplicados** (1, 2, 5, 6, 7, 8, 10, 11, 12, 13, 17, 18, 19, 20, 21, 22, 23, 24,
25, 26, 27, 28, 29, 30, 31) · **1 aplicado en parte** (3: semáforo y DISC aplicados, la retirada
de `capacity` al autor) · **3 descartados con razón** (4, 9, 16; el 4 con su objeción registrada
en Q4) · **2 al autor** (14 → Q5, 15 → Q2, cerrada el 2026-09-14). Comprobaciones tras la corrección: formato **16 ok /
1 aviso / 0 errores** · citas **210 OK · 0 CAMBIO · 54 SIN-PAG · 0 SIN-CITA** · PRIME4API
**20 OK / 1 ERR** (DV-04, sin cambio).
