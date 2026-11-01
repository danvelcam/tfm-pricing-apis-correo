# Glosario

Términos tal como los usa la skill. Si el `SKILL.md` dice otra cosa, gana el `SKILL.md`.

| Término | Significado aquí |
|---|---|
| Términos de consumo | Lo que fija cuánto se puede usar del servicio de correo y en qué condiciones: precios y planes, límites, cuotas, uso aceptable, restricciones de SMTP, reglas de webhooks, códigos de error de límite. |
| Bruto | Tal como llegó. Sin extraer, resumir ni limpiar. |
| Semilla | URL del ámbito que el repositorio ya cita como fuente. |
| Candidata | URL del ámbito que sale de una semilla, un sitemap o un `llms.txt`. |
| Incluida / descartada | Resultado del árbol de decisión sobre una candidata. |
| Interfaz | Superficie del servicio de la que cuelga la página: SMTP, Webhooks, API... |
| Tema | Una de las ocho familias de `patrones.json` que casa con la ruta o con el texto de un enlace. |
| Ruido | Rutas que no son términos: privacidad, cookies, empleo, clientes, registro, glosario, vídeos. |
| Novedades | Blog, changelog, release notes. Dicen qué cambió, no qué rige. |
| Ámbito | Dominio oficial y prefijo de ruta del servicio de correo, en `proveedores.json`. |
| Captura | El cuerpo de una respuesta HTTP tal como se recibió. |
| Huella | sha256 en hexadecimal de los bytes de la captura. En nombres de fichero y en `indice.md`, los 16 primeros caracteres. |
| Huella del texto | `sha256_texto`: sha256 del texto normalizado, el que lee una persona. Es la que se compara entre rondas. |
| Evidencia | Término de 40 caracteres como mucho, con su posición, que casa con el patrón `evidencia` de un tema en el texto normalizado de una página. |
| Cobertura | Por tema: páginas capturadas, cuántas tienen evidencia y estado (`con_evidencia`, `solo_ruta`, `hueco`). |
| Puerta de calidad | Las seis medidas de `SKILL.md` con sus umbrales. El validador sale con 2 si alguna no se cumple. |
| Fallo pasajero | Uno de red, un 403, un 429 o un 5xx: otra pasada puede no tenerlo. El 403, desde la 0.3.1. |
| `soft_404` | Página que responde 200 y se presenta como «no encontrada». |
| Fase 1, descubrir | Semillas, enlaces, sitemaps y `llms.txt` hasta un conjunto de URLs con su motivo. |
| Fase 2, extraer | Una petición por URL incluida, y título, fecha, huellas y texto de cada una; después, cobertura y puerta. |
