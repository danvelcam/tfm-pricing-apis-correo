# Contraste tras D-035: PRIME4API sobre SendGrid y Resend, con el límite declarado una sola vez

Fecha: 2026-09-14, contra el **PRIME4API que despliega SPHERE en local** (`localhost:8003`,
contenedor `prime4api-sphere`), con `ejecutar_prime4api_PI.py plan|importar`. Motivo: **D-035**
adopta la regla **B8** —cada límite se declara una sola vez— y retira las ocho líneas que SendGrid
repetía en `/v3/mail/send` y las diez que Resend repetía en el comodín `/*` y en sus dos endpoints
de envío. El motor hereda los límites del plan y les concatena los del endpoint sin deduplicar
(**DV-05**), así que la repetición los contaba dos veces.

Columnas: «antes» = `../prime4api_ejecucion/PI-*_<api>.json` (D-022, 2026-09-07); «después» =
los `PI-*_<api>.json` de esta carpeta. La latencia (`ms`) varía entre ejecuciones y no cuenta
como cambio. Postmark y MailerSend no se tocan: ninguna de las dos repetía nada.

## Qué se movió

| API | Llamadas | Idénticas | Distintas | Qué cambia en las distintas |
|---|---|---|---|---|
| SendGrid | 15 | 10 | 5 (B02, B05, D01, D02, D03) | El duplicado desaparece del listado: donde había dos cuotas o dos caudales idénticos queda uno. **Un solo número cambia**: el umbral de violación del Free Trial en B05, de 18.000 a 18.027 ms |
| Resend | 15 | 12 | 3 (B02, D01, D03) | El duplicado desaparece del listado. **Ningún valor cambia** |

**PI-A06 no se mueve en ninguna de las dos.** La pregunta del tiempo mínimo —100.000 correos en
el primer plan de pago— sigue respondiendo `30day4s` en SendGrid Essentials: el duplicado no
entraba en ese cálculo.

**Los veredictos de B05 tampoco.** El pico de 20.000 correos en una hora sigue siendo NO en Free
Trial —por cuota— y SÍ en Essentials y Pro. Lo único que se desplaza es el instante de la primera
violación, 27 ms, porque el motor deja de evaluar la misma cuota dos veces.

## Dónde sí se notaba: la curva

La capacidad no se pregunta en las diez P, se dibuja. Con la repetición, el `capacity-curves` del
mismo servicio devolvía para SendGrid Essentials `capacity` = **100.000 correos a 30 días** con
$k = 1.000$ —el doble de los 50.000 que publica el proveedor— y con $k = 1$ una meseta falsa en el
primer segundo. Sin ella, 50.000 y la curva limpia. Resend repetía solo la cuota y su curva no se
movía, porque el techo lo fijaba el mismo valor duplicado.

Los dos paneles de SendGrid que devuelve ahora el servicio
(`../capacidad_figs/sphere/sendgrid_essentials_k1*.json`) son **byte a byte iguales** a la variante
`_sin_reiteracion` con la que se venía dibujando la Figura 5.1 a mano. La figura del capítulo no
cambia: pasa a ser la que el motor devuelve sobre la Datasheet, sin variante.
