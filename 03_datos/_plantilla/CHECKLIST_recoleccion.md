# Checklist de recolección por API

El orden importa: cada paso acota el siguiente. Marca lo que encuentres y **registra
también lo que buscaste y no estaba** — la ausencia documentada es un dato, la ausencia
silenciosa es un descuido.

## 1. Identificación
- [ ] Nombre del servicio y proveedor
- [ ] Clasificación: `full_saas` / `partial_saas` / `api_first`
- [ ] `base_uri` de la API
- [ ] ¿Se distribuye también por marketplace (RapidAPI)? El pricing puede ser distinto

## 2. Pricing comercial
- [ ] Página de pricing oficial → planes, precios, período
- [ ] ¿Precios mensuales y anuales?
- [ ] Moneda
- [ ] Volumen incluido por plan
- [ ] Coste de exceso (overage) por plan
- [ ] ¿El volumen es fijo o escalonado/paramétrico? *(ver fricción F-02)*
- [ ] Add-ons

## 3. Límites de capacidad — el núcleo de tu TFM
- [ ] **Cuotas** (volumen por ventana): valor, unidad, período
- [ ] Tipo de ventana: `rolling` / `fixed_utc_midnight` / `fixed_billing_cycle`
- [ ] **Rates** (velocidad): valor, unidad, período
- [ ] ¿Los rates varían por plan, por endpoint, o por estado de la cuenta (aliases)?
- [ ] Concurrencia *(fuera de v0.3 — anótalo igual en fricciones)*
- [ ] Límite de tamaño por petición
- [ ] Máximo de destinatarios o registros por petición

## 4. Endpoints y consumo
- [ ] Endpoints relevantes (envío simple, envío por lotes, consulta de estado)
- [ ] **CRF**: cuántas unidades consume cada petición, mínimo y máximo
- [ ] ¿Hay consumo compuesto (N mensajes × M destinatarios)? *(ver fricción F-03)*

## 4b. Matriz funcional → `features.md` *(D-019, con las mismas fuentes; media hora)*
- [ ] Webhooks de eventos por plan (número de endpoints, o «todos»)
- [ ] IP dedicada: incluida o add-on, precio y condición (plan mínimo, volumen)
- [ ] Retención de actividad o logs por plan, y add-on si lo hay
- [ ] Dominios por plan (verificados / de firma), y add-on si lo hay
- [ ] Usuarios o teammates por plan
- [ ] Entrada de correo (inbound / parse) por plan
- [ ] SMTP: disponible por plan y límites del canal (conexiones, mensajes por conexión)
- [ ] Plantillas por plan (o por servidor)
- [ ] Otras features que el proveedor publique por plan (soporte, SSO, validación, región)
- [ ] Celda vacía («—») donde ninguna fuente lo dice; nada inferido de otro plan
- [ ] PI-E01 y PI-E02 instanciadas al final del fichero

## 5. Dónde mirar cuando el pricing no basta
La info de capacidad casi nunca está en la página de precios. Por orden de utilidad:

1. Documentación de desarrollador → sección *rate limits* o *limits*
2. Especificación OpenAPI (busca `/openapi.json`, `/swagger.json`, repos en GitHub)
3. Artículos del centro de soporte (aquí aparecen los límites informales)
4. Códigos de error 429 / 403 → suelen describir el límite que los dispara
5. Términos de servicio y política de uso aceptable
6. Changelog o release notes → cambios de límites con fecha

## 6. Cierre
- [ ] Toda fuente en `fuentes.md` con URL, fecha de acceso y **cita literal**
- [ ] Volcado de la página en `evidencias/paginas/<fecha>/` si es barato (E2, recomendado;
      no bloquea el cierre, D-023)
- [ ] Sección "buscadas y NO encontradas" rellena
- [ ] Semáforo puesto en cada campo del YAML
- [ ] Fricciones anotadas *en el momento*, no al final
- [ ] `features.md` rellena, con cada celda citando su `[Fn]`
