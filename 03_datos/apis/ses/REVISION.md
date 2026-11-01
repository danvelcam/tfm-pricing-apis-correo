# Revisión — Amazon SES · PASADA 2 (2026-09-18)

**Estado:** **CERRADA el 18-09**. Las **siete** acciones de conformidad que el arbitraje declaraba
bloqueantes están hechas, la última con la relectura de las dos páginas de SMTP. Lo que queda
abierto no bloquea: dieciocho discrepancias que por **E5** no cuestan nada y dejan un solo campo
en ámbar, y un punto de carril rojo que es del autor —salir del entorno de pruebas—, sin el cual la
cuota y el caudal de producción no tienen vía de medición.
**Construido:** 2026-09-18, cuatro lentes documentales, **47 fuentes [F1]–[F47]**, **20
discrepancias** y 16 huecos declarados · **Validado contra v0.3:** 24 filas, **16 ok / 1 aviso /
0 errores**
**Escalón 2 (panel):** **dos pasadas** el 18-09, la primera volcada en
`evidencias/panel_ses_2026-09-18.md` y la segunda registrada en [F45] · **Escalón 3 (sondeo):**
**ejecutado** el 18-09, cinco bloques [E1]–[E5] sobre cuatro ficheros de `evidencias/`. El
presupuesto gastado son **cuatro envíos**, con cinco destinatarios, y todos fueron a la dirección
verificada de la lista blanca de D-046.

**Lo que la pasada 1 dejaba pendiente, y hoy está hecho.** Eran tres cosas. El **escalón 3**
midió la unidad de la cuota, el nombre y el código del error de caudal, y un tope publicado que
no se aplica. El **panel** completó el test C2 y cerró las plantillas. El **comparador de planes**
rellenó las tres columnas vacías de `features.md` y obligó a acotar F-29.

**Lo que no cambia, y gobierna el resto.** SES sigue siendo la primera API del catálogo cuyo
**precio no cabe en el fichero**, y la primera cuya capacidad no cuelga del plan sino del par
cuenta × región.

**Semáforo:** **22 🟢 · 1 🟡 · 2 🔴**, contado por `verificar_estado.py`. El recuento es el mismo
que antes del 2026-10-31, pero el ámbar ha cambiado de campo. El caudal del resto de operaciones
subió a 🟢 cuando el proveedor publicó su alcance. El caudal del entorno de pruebas bajó a 🟡
porque ninguna fuente lo cuenta en peticiones y la discrepancia sobre su unidad (DISC-21) no se
puede medir con la lista blanca. Eso lo deciden D1 y la rama F2 de E7, y lo votó el consejo del
2026-10-31. Los dos cambios se explican en el informe del verificador, abajo. Los 🔴 son la ventana de la cuota diaria, por la
cuarta cláusula de **D3**, y el bloque de caudales de producción, que no se publica. El `type`
subió a 🟢 al completarse el test C2.

---

## Estado de las comprobaciones

| Comprobación | Resultado | Dónde |
|---|---|---|
| Formato v0.3 (`gen_datasheet_viewer.py`) | 24 filas · **16 ok / 1 aviso / 0 errores** | el aviso es el hueco deliberado: `quota_email_daily_sandbox` sin `window_type`, con entrada en `not_found` |
| Conformidad con PRIME4API (`verificar_prime4api.py`) | **20 OK / 1 ERR** | el único fallo es `curve.accumulated`, `TypeError: unsupported operand type(s) for /: 'int' and 'TimeDuration'`. Es **DV-04**, defecto del motor, y SES es su **segundo reproductor** |
| Citas (`verificar_citas.py`) | **0 OK · 3 CAMBIO · 21 SIN-PAG** | un solo volcado, el del comparador de planes. Los tres CAMBIO no son deriva de la página: dos son fragmentos que el analizador recorta de la línea de los cuatro planes, y el tercero es la cita de los tramos marginales, a 0,91 del umbral 0,92 porque el YAML escribe guion donde la página escribe raya |
| Escalón 3 (sondeo) | **ejecutado**: [E1]–[E5] | cuatro ficheros en `evidencias/`, presupuesto declarado y cumplido: cuatro envíos |
| Test C2 (`type`) | **completo** | las tres operaciones con cita, contra la referencia de API y contra el panel de la cuenta |

---

## 🔴 Prioridad alta — lo que no puedo decidir yo

### 1 · Salir del entorno de pruebas, que es una solicitud al soporte de AWS

Es el único punto que necesita tu mano. El permiso de envío que concediste ya rindió: [E3] manda
dos correos con `HTTP 200` y `MessageId`, y con eso se midió la unidad de la cuota. Lo que sigue
sin vía es **producción**. La cuenta está en el entorno de pruebas —`"ProductionAccessEnabled":
false` [E1]— y ahí los dos topes son 200 mensajes cada 24 horas y uno por segundo.

Los de producción no se publican. [F9] lo dice así: *"The sending quota and maximum sending rate
for your account vary based on your specific use case."* Sin acceso de producción no hay nada que
medir, y conseguirlo es una solicitud al soporte que cambia el estado de la cuenta.

**Lo que cuesta dejarlo como está:** `max_power` se queda en 🔴 sin los caudales de producción,
`capacity` nunca llega a tener `quota_email_daily_production`, y **DISC-03** —el valor por defecto
al salir— se queda sin vía de cierre.

**La premisa de selección sigue en tu carril, pero ya no pide decisión para cerrar esto.** La
lectura conservadora está aplicada y registrada como **O-04** en `fricciones.md`: la datasheet
modela los cuatro modos y el cambio de julio queda como hallazgo fechado. Aplicado, no validado.

---

## 🟡 Prioridad media — lo que verificaría yo y no he podido cerrar

### 2 · El `type` sube a verde: el test C2, completo

El test C2 está **completo**. Las tres operaciones que deciden el valor existen en la API [F19],
y el panel del 18-09 las recorrió una a una [F45]. `CreateEmailIdentity` está también en la
consola, con el botón *"Crear identidad"*. `SendEmail` también, con *"Enviar correo electrónico de
prueba"*. `CreateEmailTemplate` **no** está: la consola tiene página de plantillas, es de solo
listado y remite a la API con su propio literal.

Ninguna de las tres es exclusiva de la web, que es lo que C2 pregunta, así que `api_first` no
está en duda. Y por **D9** el verde significa que el test se aplicó entero, que es justo lo que
pasó. **Aplicado:** `datasheet.yaml` pasa a `type: api_first # 🟢` y su provenance lleva ahora una
línea por comprobación, tres de API con la URL de cada una y una de panel con las tres operaciones
recorridas. El recuento queda en **22 🟢 · 1 🟡 · 2 🔴**, y `docs/07-estado.md` se tocó en la misma
pasada, así que `verificar_estado.py` cuadra.

Hay además un caso inverso que el test no sabe recoger y `fricciones.md` guarda como **O-06**:
aquí lo exclusivo es de la **API**, y lo dice el proveedor en su propia consola. F-22 cuenta lo
contrario, credenciales que solo se gestionan desde la web.

### 3 · La unidad de la cuota, cerrada midiendo, con el campo en `emails` a propósito

**DISC-02 cierra.** Cuatro mensajes con cinco destinatarios dejan `SentLast24Hours` en **5,0**
partiendo de `0,0`, con la misma dirección en `to` y en `cc` en uno de ellos. Cinco separa las dos
lecturas por construcción: contar mensajes daría cuatro, y deduplicar la dirección repetida daría
cuatro también. **Manda el destinatario.** El proveedor lo escribe además en su panel, *"(se cobra
por destinatario)"* [F45].

El campo se queda en `unit: emails`, y no es descuido. `recipients` no está en la lista de
unidades de la guía v0.3 ni en el validador, y PRIME4API casa cuota y carga por igualdad literal
de la cadena. Con `recipients` en la cuota y `emails` en el workload del envío, la cuota diaria
desaparecería de la curva. La unidad medida vive en el provenance, que es el mismo trato que
recibió Brevo el 17-09.

**Corrección de registro.** El título de fila *"Number of emails that can be sent per 24-hour
period"* se ha retirado de la entrada y del provenance: no está entre los literales de [F1] ni en
volcado alguno, y por **E1** no podía sostener la línea. La pasada 1 lo citaba en este mismo
punto; queda escrito para que no vuelva a entrar por copia.

### 4 · Las dos acciones de conformidad, hechas

- **`fuentes.md` · [F16] desglosado, y el desglose decide una discrepancia.** El bloque llevaba
  dos URL y ninguna cita decía de cuál salía. Releídas y volcadas las dos páginas, el reparto no
  admite duda: los seis códigos de tres dígitos y las dos frases que hablan de errores «400» y
  «500» están en `troubleshoot-smtp.html` y solo ahí; `smtp-connect.html` aporta una sola cita,
  el tope del puerto 25, y nace como **[F47]**. Con eso el *"esa misma página"* de **DISC-13**
  deja de ser indecidible y queda demostrado.
  **Y el volcado restituye lo que una pasada anterior había retirado.** El literal del «500» y
  los códigos `451`, `530` y `535` se habían quitado de DISC-13 por no constar en el bloque, que
  es lo que **E1** obliga con una cita sin registrar. Están en la página: vuelven con su literal.
  El recorte no era del proveedor, era nuestro.
- **`datasheet.yaml` · el provenance de los cuatro planes, refundado.** La línea abría con *"Los
  cuatro planes salen de la lista oficial"* y la lista oficial tiene **tres**. Ahora lo dice al
  revés y nombra lo que de verdad sostiene al cuarto: *"If you do not have a plan, you are on à
  la carte pricing"* [F42]. El plan à la carte no sale de una lista, sale de la ausencia de plan.

### 5 · El cierre de DISC-15 se apoya en una evidencia que no está en disco

La segunda pasada de panel sostiene dos cosas: el cierre de **DISC-15** y la segunda vía de
**DISC-02**. Está registrada como fuente [F45], pero **no tiene fichero en `evidencias/`**. El
volcado que hay, `panel_ses_2026-09-18.md`, es el de la primera pasada y no menciona las
plantillas. Un cierre apoyado en algo que no está en el repositorio es frágil, y por **D-023** no
bloquea, pero conviene volcarlo antes de que la cifra entre en la memoria.

### 6 · La ventana de la cuota, todavía en 🔴

Una página la describe deslizante y otra fija, y es **DISC-10**. Con **D3** una ventana que no se
declara literalmente no sube de color, y aquí ni siquiera se puede elegir cuál escribir. Se cierra
leyendo el contador cada hora durante 24 horas: **cero envíos**, solo espera.

### 7 · El techo de configuration sets, que B3 exigía y ya está registrado

**DISC-01** enfrenta dos páginas oficiales sobre si el techo se puede subir. La guía de cuotas lo
publica fijo: *"Maximum number of configuration sets"* con valor *"10,000"* y la columna
*Adjustable* en **No** [F1]. La referencia general publica la misma cifra como **ajustable**,
*"Configuration set count | Each supported Region: 10,000 | Adjustable: Yes"*, con código de cuota
`L-10E24536` [F7]. Por **B3** un límite de recursos no va a `capacity`: va al provenance con cifra
y cita, y a la fricción **F-11**. La línea está escrita en el YAML desde esta pasada, y queda
registrada aquí, que es lo que el arbitraje pedía.

---

## 🔴 Lo que no existe y hay que medir

El escalón 3 ya corrió, así que esto es la **segunda tanda**, y ninguna medición es cara.

1. **El caudal contra el endpoint de envío.** Lo medido —429 con
   `x-amzn-errortype: TooManyRequestsException` y cuerpo `{"message": "Rate exceeded"}`— salió de
   `GET /v2/email/account`, que es ruta de lectura. **DISC-07** y **DISC-08** preguntan por el
   caudal de la API v2 sin decir de qué ruta, así que lo medido acota y no decide. Repetirlo contra
   el envío las cierra. Coste: los envíos que consuma la ráfaga.
2. **La ventana de la cuota (DISC-10).** Leer el contador cada hora durante 24 horas. Coste cero.
   Aviso para quien lo programe: el contador expuesto **va por detrás** del aplicado, con un
   retraso acotado entre cinco segundos y minuto y medio largo. El `time.sleep(4)` de
   `probe_ses_cuota_caudal.py` lee antes de que se mueva, y ese fue el fallo de la pasada de las
   09:58, no el destinatario.
3. **La supresión en el entorno de pruebas (DISC-04).** Una llamada a
   `PutAccountSuppressionAttributes` desde esta cuenta decide si habilitar la lista es una llamada
   de API, que es el paso que nadie publica. Coste cero envíos.
4. ~~**El tarifario máquina de [F40].**~~ **Hecho el 2026-10-18:** archivado en `evidencias/`, la
   misma versión `20260911124507`. Confirma los literales de **DISC-19** y el factor diez de **DISC-20**.
5. **Una página por releer:** el volcado de [F32] para el emparejamiento nombre-mensaje de
   **DISC-14**. `smtp-credentials.html` ya está releída: **DISC-16** cerró midiendo el 2026-10-18.

**DISC-14 ya no es un punto para ti, y la pasada 1 nunca lo enrutó.** Lo que significa
`MessageRejected` necesitaría un destinatario no verificado, y ese es justo el que IAM no autoriza:
en SES el permiso `ses:SendEmail` se evalúa sobre un ARN construido con la dirección de **destino**.
Está medido en [E2] y [E3], y cierra por construcción la vía preferente de la condición 3 de D-046.
Merece una línea en `docs/08-mandato.md`.

**Lo que no se puede medir con esta cuenta** sigue siendo lo de producción, y es el punto 1.

---

## Lo que quedó sin aplicar en esta tanda, y por qué

Esto es lo que quedó fuera de esta tanda, con su motivo. Nada se omite en silencio.

**`fuentes.md`**

- **[F16] sin desglosar** y **[F30] sin los seis literales de la web** (DISC-11): las dos exigen
  releer páginas, que es escalón 1 fuera del encargo. La primera **bloquea**.
- **El `index.json` de [F40] sin descargar**, y **[F32] sin volcar**: son red, no registro.
- La marca *acotada y no cerrada* está escrita en **cinco** de las ocho entradas que el arbitraje
  acota: DISC-04, DISC-05, DISC-07, DISC-08 y DISC-14. En DISC-06, DISC-09 y DISC-13 está lo
  acotado sin la etiqueta, porque poner la marca sin el contenido es lo que **E5** no reconoce.

**`datasheet.yaml`**

- **El provenance de los cuatro planes**, sin refundar. **Bloquea**, y es el punto 4.
- **`unit: emails` no se renombró** a `recipients`, con las dos condiciones comprobadas y fallidas:
  la guía v0.3 no trae esa unidad y el motor casa por igualdad de cadena.
- **El `type` sigue en 🟡** con su provenance caducado. Es el punto 2.
- La `NOTA` del precio afirma *"SES no incluye volumen en ningun plan"*, y el comparador la
  desmiente en parte: hay volumen incluido con precio de exceso en inquilinos, validaciones de API
  y endpoint de entrada abierto. El enunciado correcto es **sin cuota de correos incluida**.
- La cita de los tramos marginales escribe guion donde la página escribe raya, y se queda a 0,91
  del umbral de `verificar_citas.py`. Es corrección **E1** mecánica.
- Falta el segundo literal de los tramos, el de las **dos escaleras independientes**.

**`features.md`**

- La celda `| Lista de supresión |` **no pasó a «en discrepancia»**, que es lo que pide D12 desde
  DISC-04. Dependía de cómo quedara la entrada, que es de otro fichero. **Si nadie la aplica, se
  pierde.**
- La nota 7 del comparador no se convirtió en fila: cuelga del rótulo *"Enterprise"* y no de
  ninguna fila, así que darle una exige inventarle rótulo.
- Tensión declarada con **E8** en la fila `| IP dedicada (administrada) |`: se rellenaron sus tres
  columnas vacías sin tocar la celda à la carte ni la nota que E8 protege. Si E8 quería congelar la
  fila entera, hay que revertirlo.
- **Candidata a DISC-21**: la nota 3 cuelga de *"Dedicated IPs - Managed"* y publica, cifra por
  cifra, el paquete que el tarifario à la carte vende como *"Virtual Deliverability Manager –
  Global deliverability"*. O el marcador está mal puesto o las dos funciones comparten paquete.

**`fricciones.md`**

- La nota 9 del comparador quedó fuera por lectura conservadora del encargo; sirve igual de bien
  como tercer ejemplo de cuota incluida con sobrecoste.
- **La columna Vía no se renumeró** en las filas con ⚠️ variante. El texto de **B10** dice que una
  variante que pasa V1 y V2 suma 1, y su aplicación inmediata dice por nombre que los recuentos no
  cambian. Se aplicó la instrucción explícita y la cláusula quedó anotada en cada celda.
- El contador que va por detrás es la **segunda evidencia** del disparador de reapertura que
  MailerSend dejó escrito en su O-11, y no se abrió como candidata: el encargo pedía dos
  observaciones y las nombraba.

**`CRITERIOS.md`**

- De cada bloque del consejo se pegó solo el texto de la regla. «Que se revierte» y «Aplicación
  inmediata» mandan trabajo sobre otros ficheros, y está repartido arriba.
- **E5 conserva intacta su última frase**, que **E7** excepciona sin reescribirla. Quien lea solo
  E5 no verá la excepción, y añadir el reenvío es cambio en regla existente.
- **D12** entró en §D aunque su paréntesis decía «(seccion E)». Manda el prefijo, que es la lectura
  conservadora; queda anotado por si el árbitro quería otra cosa.

**`DISCREPANCIAS_v03.md`**

- SES **no** se añadió a la tabla de «Estado actual»: sus ejes son el antes y el después de DV-01,
  y SES no tiene «antes». Esa tabla cubre hoy dos de seis Datasheets, y eso es un hallazgo.
- El radio del fallo de DV-04 —**52 escenarios de 84**— no se reproduce con un comando:
  `verificar_prime4api.py` aborta en el primer escenario que rompe.

**Fuera de la Datasheet**

- **`05_salida/DECISIONES.md` no tiene la entrada del consejo** con las cinco reglas y su huella.
  El preámbulo de `CRITERIOS.md` hace depender de ella la reversión de la clase entera, así que
  hoy las reglas están escritas y no son revertibles de una pasada. Última entrada: 195.
- **`docs/08-mandato.md`** necesita la línea del ARN de destino, que cierra la condición 3 de
  D-046 en esta API.
- **B10 tiene consecuencia fuera de SES**: el rechazo del caso de Postmark va a su §F-02, y la
  cláusula V1/V2 a las celdas ⚠️ variante de Brevo, MailerSend y SendGrid.
- **`evidencias/paginas/` sigue sin versionar**, y dos reglas citan ficheros de dentro.

---

## Informe del verificador adversarial (D-013) — 2026-10-31

Agente independiente con acceso solo al `datasheet.yaml`. Leyó cada URL dos veces, sin y con
JavaScript, y fechó con Wayback lo que no encontró.

- **21 entradas de procedencia: 12 COINCIDEN, 3 parciales, 2 CAMBIÓ, 2 NO ENCONTRADAS, 2 de
  consola.** Ningún valor modelado refutado.
- **CAMBIÓ, caudal del resto de operaciones.** La página de cuotas exceptúa hoy `"SendEmail and
  SendBulkEmail"`, las operaciones de envío de v2, y lleva aparte la lista de v1. La captura del
  23-10 trae el texto antiguo. **Aplicado:** `max_power.rate_request_other` 🟡 → 🟢 por D1, la
  línea del provenance con las dos fechas, `not_found` del lote reescrita como hueco que se cierra
  y la del caudal por operación sin la frase de v1. DISC-05 queda acotada solo por lo medido.
- **CAMBIÓ, configuration sets.** La guía de cuotas da hoy Adjustable **Yes**, como la referencia
  general (ya en la captura del 23-10). La contradicción de la línea del provenance y de F-11 ya
  no está en las páginas de hoy. **Sin aplicar:** no estaba en la lista aprobada y toca una
  fricción; anotado en [F1] de `fuentes.md`.
- **NO ENCONTRADAS, test del type, operaciones 2 y 3.** Error de atribución: los literales están en
  la página de cada operación, no en `API_Operations.html`. **Aplicado:** las dos URL reapuntadas,
  con nota en [F19].
- **Unidad del caudal del entorno de pruebas (consejo del 2026-10-31; aplicado).** Las fuentes lo
  cuentan en mensajes ([F2], [F3]) o en destinatarios ([F1], bajo su cabecera), y ninguna en
  peticiones. Se abre **DISC-21** por la rama F2 de E7: sin contador que leer, y la única medida
  que separa las dos lecturas usa el simulador de buzones, que está fuera de la lista blanca de
  D-046. `unit: requests` se queda por la regla nueva **B18**. En `emails`, PRIME4API dejaría sin
  tope el envío por lotes. El `value: 1` baja de 🟢 a 🟡. El provenance lo explica en la línea de los dos límites del entorno de pruebas, y `not_found` lleva una entrada.
  Ningún valor cambia. Abrir el simulador es decisión del autor.
- **Parciales, sin aplicar:** los tramos de precio de la línea 209, que solo
  describen Essentials; y la versión de la lista de precios, hoy `20261027230824` con los mismos
  valores.

Informe íntegro: `evidencias/verificador_adversarial_2026-10-31.md`. Volcados:
`evidencias/paginas/2026-10-31/`.

## Lo que queda abierto

- **Veintiuna discrepancias.** **Ninguna cerró por arbitraje**: los veinte arbitrajes fueron
  refutados por su escéptico, y el registro se quedó con las correcciones de cita que sí se
  sostienen. DISC-21, abierta el 2026-10-31, no pasó por arbitraje. **Dos cierran midiendo**,
  DISC-02 con el sondeo y DISC-15 con el panel, que es uno de los dos caminos que **E5** admite,
  junto con disolverlas. **Diecinueve siguen abiertas**, y ocho de ellas quedan acotadas.
- **Solo una de las diecinueve abiertas tiñe un campo:** DISC-21, el caudal del entorno de
  pruebas, en 🟡. El ámbar que **D11** fundaba antes era el `unit` de la cuota, y DISC-02
  cerró. La cabecera que prometía un 🟡 por discrepancia se ha corregido: el
  efecto lo declara cada entrada, en su línea.
- **El proveedor se contradice consigo mismo diecinueve veces**, y esa es la aportación de O-02. La
  única que no es AWS contra AWS es DISC-15, cuyo lado B no es una página del proveedor sino su
  ausencia. La cifra se recontó entrada por entrada, porque la pasada 1 decía dieciséis. Desde el
  2026-10-31 son **veinte**: DISC-21 también enfrenta páginas de AWS entre sí.
- **Tres fricciones nuevas.** **F-29** y **F-31** tienen ya **L2 medida con caso de control**:
  PRIME4API devuelve el mismo coste a un correo, a cien mil y a diez millones. **F-30 no recurre**:
  las escaleras de las otras cinco APIs son volumen contratado y caen por **B10**, así que se queda
  en 1/6 y necesita L2 y L3. La pasada 1 decía que podía cruzar por recurrencia sin medir nada, y
  eso queda desmentido.
- **Diez ocurrencias de fricciones ya conocidas**, ocho plenas y dos variantes. F-04 entra por
  medición: el tope de una petición por segundo no rechaza a 5,7.
- **Seis observaciones**, O-01 a O-06. Las dos nuevas son el 429 sin `retry-after`, que ya van dos
  APIs, y el caso inverso de F-22.
- **Los volcados de página**, con uno solo hecho. Por **D-023** no bloquean.
