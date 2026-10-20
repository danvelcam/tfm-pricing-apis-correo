# Mailgun — lo publicado contra lo medido, 2026-09-21

Tres contrastes que solo existen porque hay sondeo. Cada uno con su literal y su medida.

## 1 · Tamaño máximo: 25 MB publicado, 52,4 MiB aplicado

| | |
|---|---|
| **Literal** | «The maximum size is 25 MB per message on Mailgun.» — `www.mailgun.com/ai-info/`, FAQ, renderizado 2026-09-21 |
| **Literal 2** | «The maximum message size Mailgun supports is 25MB» — `[F12]` |
| **Medido** | Adjunto de 30 MB → **HTTP 403** (rechazo por la cuenta Free, no por tamaño). Adjunto de 50 MB → **HTTP 413** `{"message":"request size exceeds 52.4MiB limit"}` |

Un mensaje de 30 MB, que supera en cinco megas el máximo publicado, **no se rechaza por
tamaño**: llega hasta la comprobación de permisos de la cuenta. El único tope que la API
aplica en el borde es de **52,4 MiB y es de la petición entera**, no del mensaje.

Esto es **F-04 recurrente**: «restricciones declaradas pero no aplicadas». F-04 salió del
piloto de Postmark y solo aparecía allí. Con Mailgun van dos APIs, que es el umbral que
el marco D-008 exige para promover una fricción a propuesta de esquema.

Y es además **F-06**: el tope que sí se aplica está en MiB de petición, no en un entero
de la unidad del `workload`.

## 2 · Caudal: 1.500 req/s por IP publicado, 80.000 por ventana de ~10 s medido

| | |
|---|---|
| **Literal** | «1,500 API requests per second per client IP» y «1,500 SMTP requests per second per client IP» — `www.mailgun.com/ai-info/`, renderizado 2026-09-21 |
| **Literal 2** | «Time windows may vary by API depending on resource usage.» — `[F2]`, documentación de la API, que describe las cabeceras y **no publica ningún umbral** |
| **Medido** | `x-ratelimit-limit: 80000`, ventana de 9,85–9,87 s anclada en la primera petición, y un segundo contador `x-recipient-limit: 2000000` con el mismo reset |

**No se contradicen: cuentan cosas distintas.** El literal acota por **IP de cliente** y
por segundo; la cabecera acota por **ventana de la API** y trae además una dimensión que
el literal no menciona, la de destinatarios. Un mismo cliente puede toparse antes con una
o con otra según cómo reparta el tráfico.

Lo que sí hace el literal es **tumbar el 🔴**: hasta hoy el caudal de Mailgun se daba por
no publicado, y sí está publicado, en una página del proveedor que las herramientas de
recolección no pueden leer porque Cloudflare las bloquea.

## 3 · Dominios por cuenta: 1.000 publicado

| | |
|---|---|
| **Literal** | «The default limit is 1,000 domains per Mailgun account.» — `www.mailgun.com/ai-info/`, renderizado 2026-09-21 |
| **Observado** | El panel de la cuenta muestra `1-1 of 1` dominios |

Límite de recurso, no de consumo: por la regla B3 no va a `capacity`. Entra en el
provenance y en `features.md`.

## Lo que esto dice del método

La única fuente del proveedor que publica un número de caudal está en una página
**escrita para asistentes de IA** y **blindada contra las herramientas que un asistente
usaría para leerla**. Tres recolectores documentales la dieron como síntesis no
transcribible y uno de los árbitros abrió una clase de decisión preguntando si esa cifra
podía usarse. La respuesta la dio el navegador con sesión propia, que es el escalón 2 de
la escalera aplicado a una página pública.
