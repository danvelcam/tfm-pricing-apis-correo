# Modelo conceptual

Por qué la skill es así. Nada de este fichero cambia un recuento.

## Qué se pidió y qué no

El tutor quiere la información de consumo de cada proveedor en bruto y versionada, como
iCan guarda términos y políticas. No pidió que se interprete. Título y enlace bastan, no
hay taxonomía de nombres y se admite la redundancia: una misma condición puede estar en
la página de precios, en una de ayuda y en el blog, y las tres entran.

La Datasheet sigue siendo el sitio donde se lee e interpreta. Esta skill es la capa de
debajo: el archivo de lo que el proveedor publicó, con fecha y huella, para que un
cambio de condiciones se pueda detectar sin depender de cuándo lo miró alguien.

## Por qué dos fases

Descubrir es barato y se puede juzgar a ojo: una lista de URLs con su motivo se lee en
minutos. Extraer es más lento, escribe ficheros y acumula tamaño. Separarlas deja
revisar el conjunto antes de descargarlo, repetir solo la segunda cuando una página
falla, y parar en la primera si el tiempo se acaba.

## Por qué un árbol y no un modelo

Que una página sea o no «de consumo» es borroso. Un árbol de patrones sobre la ruta da
siempre la misma respuesta y explica cada descarte, a costa de dejar fuera páginas con
una ruta poco clara y de meter alguna que sobra. Con redundancia permitida, meter de más
cuesta poco. Dejar fuera una página de límites cuesta mucho. Por eso los temas son
amplios y el filtro duro es el ámbito oficial.

El texto del enlace sirve de segunda oportunidad: una ruta `/support/article/1056-...`
no dice nada, pero el enlace que apunta a ella puede decir «rate limits».

## Por qué el ámbito va aparte

El mayor riesgo de una recogida automática es salirse. Las páginas citan redes sociales,
repositorios, agregadores y copias en archivo web, y un dominio compartido (Twilio,
Mailchimp) mezcla el correo transaccional con todo lo demás. `proveedores.json` es una
lista explícita de dominios y rutas, y lo que no está en ella no se pide.

## Por qué el texto no se publica

El permiso para copiar el texto de páginas de terceros no está resuelto. Un repositorio
público con enlace, título, fecha y huella demuestra qué se capturó y cuándo sin
redistribuir el contenido. El texto vive aparte, con el nombre de su huella, y la huella
del índice permite comprobar que es el mismo que se capturó.

## Qué no resuelve

- No ve lo que el navegador pinta con JavaScript.
- No distingue «el proveedor cambió el texto» de «el proveedor cambió la plantilla de la
  página». La huella es de los bytes, y cualquier cambio la mueve.
- No sabe si una página incluida habla del servicio de correo o de otro producto del
  mismo proveedor, salvo por el ámbito y los temas.

## Por qué una puerta de calidad y una evidencia por tema (0.3)

Hasta la 0.2 el validador comprobaba la forma de la salida y nada más. Una recogida con la
mitad de las páginas caídas por la red, o que no hubiera encontrado ninguna página de
precios, salía con `ok`. Las skills de Daniel Ruiz separan las dos cosas: el fichero no
miente sobre lo que hizo, y lo que hizo llega a un mínimo. La 0.3 copia esa separación con
dos códigos de salida, 1 para lo primero y 2 para lo segundo.

La evidencia por tema es la versión de esta skill de su «extracto literal». Aquí no puede
ser un extracto, porque el texto de terceros no se publica (A4). Por eso es un término
corto y su posición, que el validador busca en la página. Prueba que la página trata el
tema, no qué dice de él: eso sigue siendo trabajo de la Datasheet.
