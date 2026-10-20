# Panel de Postmark — operaciones 4 a 8 del test C2

- **Fecha:** 2026-09-14
- **Cuenta:** cuenta propia del autor, plan Free, **Test mode** activo (la cabecera ofrece
  `"Request approval"`). Modo lectura: no se pulsó nada con consecuencias — ni generar, ni
  revelar, ni borrar tokens; ni crear servidores, webhooks ni plantillas.
- **Redacción:** no se transcriben correo, identificadores de cuenta, de servidor ni de token.

## Superficie del panel

- Nivel cuenta: `Servers` · `Sender Signatures` · `Users` · `Account`.
- Dentro de un servidor: `Message Streams` · `Templates` · **`API Tokens`** · `IP Allowlist` ·
  `Settings`.
- Dentro de un stream: `Activity` · `Suppressions` · `Webhooks` · `Settings`. Los streams del
  servidor son `broadcast`, `outbound` (Default Transactional Stream) e **`inbound`**.

## Literales relevantes

- Pestaña API Tokens: `"Server API tokens"`, con los controles **`"Generate another token"`** y
  **`"Delete"`**, más un enlace al `"account API token"`.
- Pestaña Webhooks del stream transaccional: `"Add webhook"`.
- Cabecera de cuenta: `"Test mode"`, `"Request approval"`.

## Lectura para el test C2

| Op | Panel | API | Resultado |
|---|---|---|---|
| 4 credenciales adicionales | **sí** (`Generate another token`, `Delete`) | **no** publicada para un servidor ya creado; solo `POST /servers`, que devuelve los tokens del servidor nuevo | **asimétrica** → fricción (no eliminatoria) |
| 5 webhooks | sí (`Add webhook`) | sí (`/webhooks`) | simétrica |
| 6 inbound routing | sí (stream `inbound`) | sí (`/triggers/inboundrules`) | simétrica |
| 7 supresiones y rebotes | sí (pestaña `Suppressions`) | sí (`/message-streams/{id}/suppressions`, `/bounces`) | simétrica |
| 8 actividad y logs | sí (pestaña `Activity`) | sí (`/messages/outbound`) | simétrica |
