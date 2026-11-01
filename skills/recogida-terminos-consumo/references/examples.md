# Ejemplos

Inventados, para dar intuición. No son fuente ni clave de respuestas. El proveedor es
ficticio y el dominio es `ejemplo-mail.test`.

Ámbito: `ejemplo-mail.test/`. Semilla: `https://ejemplo-mail.test/pricing`.

## Cómo cae cada URL en el árbol

| URL | Resultado | Por qué |
|---|---|---|
| `https://ejemplo-mail.test/pricing` | incluida, `semilla` | Paso 4. |
| `https://github.com/ejemplo-mail/sdk` | no es candidata | Paso 1: fuera del ámbito. |
| `https://ejemplo-mail.test/assets/logo.png` | descartada, `no_pagina` | Paso 2: extensión de imagen. |
| `https://ejemplo-mail.test/es/precios` | descartada, `idioma` | Paso 3: `/es/`. |
| `https://ejemplo-mail.test/careers` | descartada, `ruido` | Paso 5. |
| `https://ejemplo-mail.test/blog/we-raised-our-limits` | descartada, `novedades` | Paso 6, aunque hable de límites. |
| `https://ejemplo-mail.test/docs/rate-limits` | incluida, `limites_cuotas` | Paso 7: la ruta casa. |
| `https://ejemplo-mail.test/help/article/1056` | incluida, `limites_cuotas` | Paso 7: la ruta no dice nada, pero un enlace con el texto «Rate limits» apunta a ella. |
| `https://ejemplo-mail.test/docs/sdk-install` | descartada, `sin_tema` | Paso 8. |

Si el blog `we-raised-our-limits` fuera una semilla, el paso 4 la incluiría. Que no pase
por el filtro de novedades es intencionado: alguien la citó como fuente.

## Una fila de `extraccion.paginas`

```yaml
- id: P-004
  url: https://ejemplo-mail.test/docs/rate-limits
  url_final: https://ejemplo-mail.test/docs/rate-limits
  titulo: Rate limits | Ejemplo Mail Docs
  fecha_captura: '2026-10-23T15:00:43Z'
  sha256: '0000000000000000000000000000000000000000000000000000000000000000'
  sha256_texto: '1111111111111111111111111111111111111111111111111111111111111111'
  bytes: 48213
  content_type: text/html; charset=utf-8
  http: 200
  estado: capturada
  error: null
  aviso: null
  interfaz: API
  motivo: limites_cuotas
  temas:
  - limites_cuotas
  cuelga_de:
  - https://ejemplo-mail.test/pricing
  fichero_texto: ejemplo/0000000000000000.html
```

Las huellas son de relleno. Una real tiene 64 caracteres hexadecimales distintos.

## Dos registros de cobertura

```yaml
- tema: limites_cuotas
  estado: con_evidencia
  paginas: 6
  con_evidencia: 4
  evidencia:
    pagina: P-004
    termino: rate limit
    posicion: 212
  motivo_hueco: null
- tema: webhooks
  estado: hueco
  paginas: 0
  con_evidencia: 0
  evidencia: null
  motivo_hueco: ninguna_incluida
```

El primero dice que en la página P-004, a partir del carácter 212 de su texto normalizado,
pone «rate limit». No dice cuál es el límite. El segundo dice que esta pasada no incluyó
ninguna página de webhooks: puede que el proveedor los documente en una ruta que el árbol
no reconoce.

## Una fila fallida

Un proveedor que manda `/legal/terms` a `/es/legal/terms` por geolocalización: la
ejecución pide `/en/legal/terms`, y si responde en inglés es la captura, con
`aviso: "via_prefijo_en"`. Si el servidor insiste en el español, la fila queda
`fallida` con `error: "redirige_fuera_ambito"` y se cuenta en el recuento de fallidas.

## Qué dice un informe y qué no

Bien: «Resend: 10 semillas, 643 candidatas, 107 incluidas, 107 capturadas, 0 fallidas
(`cifras.md`); puerta de calidad: pasa».

Mal: «Resend publica un límite de 2 peticiones por segundo». Eso es leer e interpretar, y
lo hace la Datasheet con su fuente. La skill no lo afirma.
