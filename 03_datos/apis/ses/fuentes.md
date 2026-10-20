# Fuentes — Amazon SES

Recolección: **2026-09-18**, pasada 1, cuatro lentes documentales (capacidad, superficie de
la API, contrato de rechazo y precio) más **escalón 2 ejecutado el mismo día**, antes de cerrar la
recolección y no después. El motivo es del proveedor: en SES los límites no los publica una
tabla por plan, los tiene la cuenta, así que el panel no confirma la documentación sino que
trae el único valor vigente. Toda cita es literal.

**Marca de frescura de la documentación**, al pie de las referencias de API:
`"This document was last published on September 17, 2026."`

**El eje que hay que tener delante todo el rato.** En SES la unidad de gobierno no es el plan
ni la cuenta: es el par **cuenta × región**. Está escrito así en la fuente canónica de cuotas
—`"SES quotas are for each AWS Region that you use in your AWS account."` [F1]— y el panel lo
confirma con dos regiones de la misma cuenta en estados distintos [F38]. Y desde el
2026-07-21 **también el plan** es de ese par: `"Plans apply for each account and each AWS
Region"` [F42].

**Aviso sobre la premisa de selección.** Esta API entró en el catálogo el 2026-09-01 por ser
«pago por uso puro, sin planes ni cuotas mensuales». Seis semanas antes de esa frase, el
2026-07-21, SES estrenó **tres planes** con cuota fija mensual [F41]. La selección sigue en
pie —el pago por uso existe y ahora se llama *à la carte*—, pero la justificación escrita ya
no describe el producto, y eso es carril del autor.

---

## Documentación de límites

## [F1] Developer Guide — Service quotas in Amazon SES

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/quotas.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"SES quotas are for each AWS Region that you use in your AWS account."`
  - `"Some quotas can be increased, while others can't. To determine whether you can request an increase for a quota, refer to the Adjustable column."`
  - Cabecera de la tabla de envío: `"Quotas are based on the number of recipients, rather than on the number of messages."`
  - `"If your account is in the sandbox, you can send up to 200 emails per 24-hour period."` · fuera del sandbox: `"this number varies based on your specific use case."` · **Adjustable: Yes**
  - `"If your account is in the sandbox, you can send 1 email per second."` · fuera del sandbox: `"this rate varies based on your specific use case."` · **Adjustable: Yes**
  - `"Using the SES v1 API - Maximum message size (including attachments)"` → `"10 MB per message (after base64 encoding)."` · Adjustable: `"No (For workloads with message sizes in excess of 10MB, consider migrating to the SES v2 API.)"`
  - `"Using the SES v2 API or SMTP - Maximum message size (including attachments)"` → `"40 MB per message (after base64 encoding)."` · Adjustable: No
  - `"Messages larger than 10MB are subject to bandwidth throttling, and depending on your sending rate, you may be throttled to as low as 40MB/s."`
  - `"Maximum number of recipients per message"` → `"50 recipients per message."`, con `"A recipient is any \"To\", \"CC\", or \"BCC\" address."` · Adjustable: **No**
  - `"Maximum number of identities that you can verify"` → `"10,000 identities per AWS Region."` · Adjustable: `"Please contact your AWS Account Manager to discuss your use case."`
  - `"Maximum number of email templates in each AWS Region"` → `"20,000"` · `"Maximum template size"` → `"500 KB"` · `"Maximum number of recipients for each templated email"` → `"50 destinations."`
  - `"Maximum number of configuration sets"` → `"10,000"` · **Adjustable: No** *(ver DISC-01)*
  - `"Maximum number of tenants"` → `"10,000"` · Adjustable: Yes
  - `"Maximum number of dedicated IP pools (inclusive of both managed and standard IP pools)"` → `"50"` · No
  - **Caudal de las operaciones que no son de envío:** `"All actions (except for SendEmail, SendRawEmail, and SendTemplatedEmail) are throttled at one request per second."` · Adjustable: **No** *(ver DISC-05)*
  - `"MIME parts"` → `"500"` · No
  - Por cuenta y no por región: `"Maximum number of receipt rule sets per AWS account"` → `"40"` · `"Maximum number of IP address filters per AWS account"` → `"100"` *(ver DISC-06)*

## [F2] Developer Guide — Request production access (moving out of the sandbox)

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/request-production-access.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"We place all new accounts in the Amazon SES sandbox. The sandbox status for your account is unique per each AWS Region."`
  - `"You can only send mail to verified email addresses and domains, or to the Amazon SES mailbox simulator."`
  - `"You can send a maximum of 200 messages per 24-hour period."` · `"You can send a maximum of 1 message per second."`
  - `"For account-level suppression, bulk actions and SES API calls related to suppression list management are disabled."` *(ver DISC-04)*
  - Salida del sandbox, **por solicitud y no automática**: `"Complete the procedures in this section to request that your account be removed from the sandbox and placed into production."`
  - `"When your account has moved out of the sandbox and into production, you can send email to any recipient, regardless of whether the recipient's address or domain is verified."`
  - SLA declarado: `"The AWS Support team provides an initial response to your request within 24 hours."`
  - Vía programática: `aws sesv2 put-account-details --production-access-enabled --mail-type TRANSACTIONAL ...`

## [F3] Developer Guide — Managing your Amazon SES sending limits

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/manage-sending-quotas.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"Sending quota—The maximum number of emails that you can send in a 24-hour period. This quota is calculated on a rolling time period. Every time you try to send an email, Amazon SES determines the number of emails that you sent in the previous 24 hours."` *(ver DISC-10)*
  - `"If sending a message would exceed the daily maximum for your account, your call to Amazon SES is rejected."`
  - `"Sending rate—The maximum number of emails that Amazon SES can accept from your account each second. You can exceed this quota for short bursts, but not for sustained periods of time."`
  - `"The rate at which Amazon SES accepts your messages can be less than the maximum send rate for your account."`
  - `"Your Amazon SES sending quotas are separate for each AWS Region."`
  - `"Sending quotas are based on recipients rather than on messages. For example, an email that has 10 recipients counts as 10 against your quota."`

## [F4] Developer Guide — Increasing your Amazon SES sending quotas

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/manage-sending-quotas-request-increase.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"Your account has the following quotas per your current region that can be increased."` con `"Sending quota | 200"` y `"Sending rate | 1"`
  - `"When your account is out of the sandbox and you're sending high-quality production email, we might automatically increase the sending quotas for your account."`
  - Criterio, sin umbral numérico: `"You send near your current quota – To qualify for an automatic quota increase, your daily email volume should regularly approach the daily maximum for your account without exceeding it."`
  - `"Increase requests for either of these can be submitted through the AWS Service Quotas console."`
  - `"We reserve the right not to grant your request if your use case doesn't align with our policies."`

## [F5] Developer Guide — Errors related to the sending quotas

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/manage-sending-quotas-errors.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"Amazon SES drops the message and doesn't attempt to redeliver it."`
  - `"the API produces a ThrottlingException error. The error message includes one of the following messages:"` → `"Daily message quota exceeded"` / `"Maximum sending rate exceeded"` *(ver DISC-07)*
  - `"If you encounter a throttling error, you should program your application to wait for an interval of up to 10 minutes, and then retry the send request."` *(ver DISC-09)*
  - SMTP: `"454 Throttling failure: Maximum sending rate exceeded"` / `"454 Throttling failure: Daily message quota exceeded"`

## [F6] Developer Guide — Monitoring your Amazon SES sending quotas

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/manage-sending-quotas-monitor.html
- **Fecha de acceso:** 2026-09-18
- **Cita literal:** `"The Amazon SES API provides the GetSendQuota action, which returns your sending quotas."`, con `"Number of emails you have sent during the past 24 hours"`, `"Sending quota for the current 24-hour period"` y `"Maximum send rate"`.

## [F7] AWS General Reference — Amazon SES endpoints and quotas

- **URL:** https://docs.aws.amazon.com/general/latest/gr/ses.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:** tabla de Service Quotas publicada, con código de cuota:
  - `"Configuration set count | Each supported Region: 10,000 | Adjustable: Yes"` (`L-10E24536`) *(ver DISC-01)*
  - `"Sending quota | Each supported Region: 200 per 24 hours | Adjustable: Yes"` (`L-804C8AE8`), descrita como `"The maximum number of emails that you can send in a 24-hour period for this account in the current Region."`
  - `"Sending rate | Each supported Region: 1 per second | Adjustable: Yes"` (`L-CDEF9B6B`)
  - `"Tenant count | Each supported Region: 10,000 | Adjustable: Yes"` (`L-E7F21B4C`)
  - Cobertura: **29 regiones** con endpoint `email.<region>.amazonaws.com`; `"SMTP endpoints are not currently available in Africa (Cape Town), Asia Pacific (Hyderabad), Asia Pacific (Jakarta), Europe (Milan), Europe (Zurich), Israel (Tel Aviv), Middle East (Bahrain), Middle East (UAE), Canada West (Calgary), Asia Pacific (Malaysia)."`
  - `"Amazon SES does not support email receiving in the following Regions: AWS GovCloud (US-West) and AWS GovCloud (US-East)."`

## [F8] API Reference v2 — tipo `SendQuota`

- **URL:** https://docs.aws.amazon.com/ses/latest/APIReference-V2/API_SendQuota.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"An object that contains information about the per-day and per-second sending limits for your Amazon SES account in the current AWS Region."`
  - `Max24HourSend`: `"The maximum number of emails that you can send in the current AWS Region over a 24-hour period. A value of -1 signifies an unlimited quota."`
  - `MaxSendRate`: `"The maximum number of emails that you can send per second in the current AWS Region. This value is also called your maximum sending rate or your maximum TPS (transactions per second) rate."`
- **Nota de modelado:** existe **centinela documentado de cuota ilimitada**, `-1`. Ninguna otra API del catálogo publica uno.

## [F9] API Reference v2 — `GetAccount`

- **URL:** https://docs.aws.amazon.com/ses/latest/APIReference-V2/API_GetAccount.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"Obtain information about the email-sending status and capabilities of your Amazon SES account in the current AWS Region."` · `GET /v2/email/account`
  - `ProductionAccessEnabled`: `"If the value is false, then your account is in the sandbox... The sending quota and maximum sending rate for your account vary based on your specific use case."`
  - `EnforcementStatus`: `"HEALTHY – There are no reputation-related issues that currently impact your account."` / `"PROBATION – We've identified potential issues with your Amazon SES account."` / `"SHUTDOWN – Your account's ability to send email is currently paused because of an issue with the email sent from your account."`

## [F10] API Reference v2 — `SendEmail`

- **URL:** https://docs.aws.amazon.com/ses/latest/APIReference-V2/API_SendEmail.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"Sends an email message. You can use the Amazon SES API v2 to send the following types of messages: Simple... Raw... Templated..."`
  - `"TooManyRequestsException — Too many requests have been made to the operation. HTTP Status Code: 429"`
  - `"LimitExceededException — There are too many instances of the specified resource type. HTTP Status Code: 400"`
  - `"SendingPausedException — The message can't be sent because the account's ability to send email is currently paused. HTTP Status Code: 400"`
  - `"AccountSuspendedException — The message can't be sent because the account's ability to send email has been permanently restricted. HTTP Status Code: 400"`
  - `"MessageRejected — The message can't be sent because it contains invalid content. HTTP Status Code: 400"` *(ver DISC-14)*
  - `"It's possible for Amazon SES to accept a message without sending it."`
  - **El tope de 50 destinatarios NO aparece en esta página**: solo en [F1].

## [F11] API Reference v2 — `SendBulkEmail`

- **URL:** https://docs.aws.amazon.com/ses/latest/APIReference-V2/API_SendBulkEmail.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:** `"Composes an email message to multiple destinations."` · `BulkEmailEntries`: `"The list of bulk email entry objects."`, `"Type: Array of BulkEmailEntry objects"`, `"Required: Yes"`
- **Hueco:** la página **no publica `Array Members: Maximum number of items`**, así que el tope de entradas por llamada no está documentado.

## [F12] Developer Guide — Regions and Amazon SES

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/regions.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"The sandbox status for your account can differ between AWS Regions."`
  - `"Sending limits can also be different depending on the AWS Region. For example, if your account is able to send 10 messages per second in the Europe (Ireland) region, you might be able to send more or fewer messages in other regions."`
  - `"The verification status of email addresses and domains also differs across AWS Regions."`
  - `"Your SES account-level suppression list applies to your AWS account only in the current AWS Region."`
  - `"The credentials that you use to send email through the SES SMTP interface are unique to each AWS Region."`

## [F13] FAQ de producto — Amazon SES FAQs

- **URL:** https://aws.amazon.com/ses/faqs/
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"When your account is in the sandbox, you can only send email to verified identities."` · `"Additionally, when your account is in the sandbox, there are limits to the volume of email you can send each day, and to the number of messages you can send each second."` **(sin cifras)**
  - `"Sending quota—the maximum number of recipients that you can send email to in a 24-hour period."` *(ver DISC-02)*
  - `"In each AWS Region, you can verify up to 10,000 email addresses and domains, in any combination."`
  - `"If we determine that the email you send is of poor or questionable quality... we reserve the right to pause your ability to send email."`

## [F14] Developer Guide — Account-level suppression list

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/sending-email-suppression-list.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"There's no limit to the number of addresses that you can add to your account-level suppression list, but there is a bulk add limit of 100,000 addresses in an Amazon S3 object per API call."`
  - `"SES counts the messages that you send to addresses on your account-level suppression list toward your daily sending quota."`
  - `"You can enable your account-level suppression list if your account is in the SES sandbox. However, you can't use the PutSuppressedDestination or CreateImportJob operation until your account is removed from the sandbox."` *(ver DISC-04)*
  - `"If your account's ability to send email is paused, SES automatically deletes the addresses in your account-level suppression list after 90 days."`

## [F15] Developer Guide — List management (contact lists)

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/sending-email-list-management.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:** `"Only one contact list is allowed per AWS account."` *(ver DISC-06)* · `"A list can have a maximum of 20 topics."` · `"You can add up to 1 million contacts to a contact list per ImportJob."`

## [F16] Developer Guide — Troubleshooting SMTP issues

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/troubleshoot-smtp.html
- **Fecha de acceso:** 2026-09-18 · **Volcado:** `evidencias/paginas/2026-09-18/docs_aws_amazon_com_ses_latest_dg_troubleshoot-smtp.txt`
- **Citas literales:**
  - `"421 Too many concurrent SMTP connections | Amazon SES can't process the request because there are currently too many connections to the SMTP server."` **sin número publicado**
  - `"454 Throttling failure: Daily message quota exceeded"` · `"454 Throttling failure: Maximum sending rate exceeded"` · `"552 Message is too long."`
  - `"You should retry SMTP requests that receive 400 errors. We recommend that you implement a system that retries requests with progressively longer wait times (for example, wait 5 seconds before retrying, then wait 10 seconds, and then wait 30 seconds). If the third retry doesn't succeed, wait 20 minutes, and then repeat the process."` *(ver DISC-09, DISC-13)*
- **Desglosado el 2026-09-18, y el desglose decide una discrepancia.** Hasta hoy este bloque
  llevaba dos URL y ninguna cita decía de cuál salía, así que el «esa misma página» del lado B
  de DISC-13 era indecidible. Releídas las dos páginas y volcadas las dos, el reparto no admite
  duda: **los seis códigos de tres dígitos —`421`, `451`, `454`, `530`, `535` y `552`— y la
  prosa que habla de errores «400» y «500» están en esta página y solo en esta**. La cita del
  puerto 25 es de la otra, y se va a [F47]. El «esa misma página» de DISC-13 queda demostrado.

## [F17] Developer Guide — Warming up dedicated IP addresses (standard)

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/dedicated-ip-warming.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:** `"Automatic IP warmup is a time-based process. The warmup percentage steadily increases over 45 days, independently from your sending volume."` · `"After you warm up a dedicated IP address, you should send around 1,000 emails every day to each email provider..."`
- **Nota:** es capacidad **efectiva** limitada por un proceso temporal, no por una cuota. v0.3 no tiene dónde escribirlo.

## [F18] Blog de AWS — All about SES daily quota *(editorial, 2014)*

- **URL:** https://aws.amazon.com/blogs/messaging-and-targeting/all-about-ses-daily-quota/
- **Fecha de acceso:** 2026-09-18 · **Fecha de publicación: 08 MAY 2014**
- **Citas literales:**
  - `"Brand-new accounts in the sandbox have a quota of 200 messages per day. Once you have asked for and been granted production access, the default quota is 50,000 messages per day..."` *(ver DISC-03)*
  - `"It is a rolling 24-hour period. We're always looking at the 24 hours immediately prior to the current moment."`
  - `"The quota limit is based on the number of recipients, not the number of emails."`
- **Estatus de la fuente:** doce años de antigüedad y **cero menciones a regiones** en todo el artículo, cuando la región es hoy el eje del producto. No se adopta ningún valor suyo.

---

## Superficie de la API

## [F19] API Reference v2 — Actions

- **URL:** https://docs.aws.amazon.com/ses/latest/APIReference-V2/API_Operations.html
- **Fecha de acceso:** 2026-09-18 · **116 acciones**, contadas sobre la lista literal
- **Citas literales por operación del test C2:**
  - `CreateEmailTemplate`: `"Creates an email template. Email templates enable you to send personalized email to one or more destinations in a single API operation."`
  - `CreateEmailIdentity`: `"Starts the process of verifying an email identity... When you verify a domain without specifying the DkimSigningAttributes object, this operation provides a set of DKIM tokens... This verification method is known as Easy DKIM."`
  - `CreateConfigurationSetEventDestination`: `"Create an event destination. Events include message sends, deliveries, opens, clicks, bounces, and complaints."`, con destinos `CloudWatchDestination`, `EventBridgeDestination`, `KinesisFirehoseDestination`, `PinpointDestination` y `SnsDestination`
  - `PutSuppressedDestination`: `"Adds an email address to the suppression list for your account or for a specific tenant."`
  - `BatchGetMetricData`: `"Retrieves batches of metric data collected based on your sending activity."` · `GetMessageInsights`: `"Provides information about a specific message..."`
  - `PutAccountVdmAttributes`: `"Update your Amazon SES account VDM attributes"`
- **Ausencias comprobadas por búsqueda sobre la lista literal:** cero coincidencias de `Credential`, `AccessKey`, `Smtp`, `Password` y `Key` en las 116 acciones; cero de `Webhook` y `Http`; y **cero acciones `*Receipt*`**, o sea que el *inbound routing* no existe en v2.

## [F20] API Reference v1 (2010-12-01) — Actions

- **URL:** https://docs.aws.amazon.com/ses/latest/APIReference/API_Operations.html
- **Fecha de acceso:** 2026-09-18 · **71 acciones**
- **Citas literales:** `CreateReceiptRule`: `"Creates a receipt rule."`, con la familia `CreateReceiptRuleSet`, `SetActiveReceiptRuleSet`, `CreateReceiptFilter`, `ReorderReceiptRuleSet` y `UpdateReceiptRule` — **16 acciones `*Receipt*`**. También `SendBounce`, sin homólogo en v2.
- **Ausencias comprobadas:** cero coincidencias de credenciales ni de webhooks, igual que en v2.

## [F21] Mail Manager API — Actions

- **URL:** https://docs.aws.amazon.com/sesmailmanager/latest/APIReference/API_Operations.html
- **Fecha de acceso:** 2026-09-18
- **Nota:** es **otra API** (`sesmailmanager`), con `CreateIngressPoint`, `CreateTrafficPolicy`, `CreateRuleSet`, `CreateRelay` y `CreateArchive`. El camino nuevo del correo entrante vive aquí y no en SES v2.

## [F22] Developer Guide — Obtaining Amazon SES SMTP credentials

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/smtp-credentials.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"SES SMTP credentials are created by using IAM. Your IAM policy must allow you to perform the following IAM actions: iam:CreateUser, iam:CreateGroup, iam:PutGroupPolicy, iam:AddUserToGroup, and iam:CreateAccessKey."`
  - `"If you have a user that you set up using the IAM interface, you can derive the user's SES SMTP credentials from their AWS credentials"`
  - Rotación: `"If you want to change your SMTP password, delete your existing SMTP user in the IAM console."`
  - Consola: `"Choose Create SMTP Credentials in the upper-right corner - the IAM console will open."`

## [F23] Developer Guide — Creating and verifying identities

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:** `"if you verify a domain in the US West (Oregon) region, you can't use that domain to send email in the US East (N. Virginia) region until you complete the verification process again for that region."` · plantillas de verificación personalizada: `"To use this feature, your Amazon SES account has to be out of the sandbox."`, con error `ProductionAccessNotGranted`.

## [F24] Developer Guide — Sending test emails desde la consola

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/send-an-email-from-console.html
- **Fecha de acceso:** 2026-09-18
- **Cita literal:** `"To send a test email message from the Amazon SES console"`, con `"Email Format"` en **Formatted** o **Raw**.

## [F25] Developer Guide — Plantillas con la API de SES

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/send-personalized-email-api.html
- **Fecha de acceso:** 2026-09-18
- **Cita literal:** `"this section will show you how to use the CreateEmailTemplate SES v2 API operation to create the template"`, con `aws sesv2 create-email-template`.
- **Hueco:** no se encontró en la documentación oficial ningún procedimiento de consola para plantillas almacenadas *(ver DISC-15)*.

## [F26] Developer Guide — Mail Manager

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/eb.html · https://docs.aws.amazon.com/ses/latest/dg/eb-getting-started.html
- **Fecha de acceso:** 2026-09-18
- **Cita literal:** `"an onboarding wizard in the Amazon SES console will walk you through the steps of enabling Mail Manager for your account"`.

## [F27] Developer Guide — Virtual Deliverability Manager

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/vdm.html
- **Fecha de acceso:** 2026-09-18
- **Hueco:** la página no cifra ni el coste ni la disponibilidad por región.

---

## Contrato de rechazo

## [F28] API Reference v2 — Common Errors

- **URL:** https://docs.aws.amazon.com/ses/latest/APIReference-V2/CommonErrors.html
- **Fecha de acceso:** 2026-09-18
- **Cita literal:** `"ThrottlingException — Your request rate is too high. The AWS SDKs automatically retry requests that receive this exception. Reduce the frequency of requests. HTTP Status Code: 400"` *(ver DISC-07)*

## [F29] API Reference v1 — Common Errors

- **URL:** https://docs.aws.amazon.com/ses/latest/APIReference/CommonErrors.html
- **Fecha de acceso:** 2026-09-18
- **Cita literal:** `"ThrottlingException — Your request rate is too high... HTTP Status Code: 400"`

## [F30] API Reference v2 — `BulkEmailEntryResult`

- **URL:** https://docs.aws.amazon.com/ses/latest/APIReference-V2/API_BulkEmailEntryResult.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales**, y es el único sitio donde el rechazo por límite viaja **dentro de una respuesta correcta**:
  - `"ACCOUNT_THROTTLED: The number of emails you can send has been reduced because your account has exceeded its allocated sending limit."`
  - `"ACCOUNT_DAILY_QUOTA_EXCEEDED: You have reached or exceeded the maximum number of emails you can send from your account in a 24-hour period."`
  - `"ACCOUNT_SENDING_PAUSED"` · `"ACCOUNT_SUSPENDED"` · `"TRANSIENT_FAILURE"`
- *(ver DISC-11: la prosa de la página y su propio bloque de valores válidos no coinciden)*

## [F31] API Reference v1 — `SendEmail`

- **URL:** https://docs.aws.amazon.com/ses/latest/APIReference/API_SendEmail.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:** `"AccountSendingPaused — Indicates that email sending is disabled for your entire Amazon SES account."` (400) · `"MessageRejected — Indicates that the action failed, and the message could not be sent."` (400)
- **Ausencia comprobada:** la v1 **no lista ningún error de tasa ni de cuota** a nivel de operación.

## [F32] Developer Guide — Amazon SES email sending errors

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/troubleshoot-error-messages.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"If you have exceeded your daily quota, you will have to wait until the next 24-hour period before you can send more email."` *(ver DISC-10)*
  - `"Account is paused — Your account's ability to send email is paused."`
  - `"When your call to Amazon SES to send an email fails, you are not billed for that email."`
  - Identidad no verificada: `MessageRejected` con `"Email address is not verified. The following identities failed the check in region..."` *(ver DISC-14)*
  - `"Maximum SigV2 SMTP sending rate exceeded — You are attempting to send messages using SMTP credentials created before January 10, 2019"`

## [F33] Modelo de servicio `sesv2` 2019-09-27 *(contrato máquina)*

- **URL:** https://raw.githubusercontent.com/boto/botocore/develop/botocore/data/sesv2/2019-09-27/service-2.json
- **Fecha de acceso:** 2026-09-18
- **Citas literales:** `TooManyRequestsException` con `{"httpStatusCode": 429}`; `LimitExceededException`, `AccountSuspendedException`, `SendingPausedException` y `MessageRejected` con `400`.
- **Ausencias comprobadas, y son el dato:** **no existe la forma `ThrottlingException` en el modelo v2** *(DISC-07)*; cero apariciones de `ratelimit`, `rate-limit`, `retry-after`, `x-amz-retry` y `remaining`; y la enumeración de miembros con binding `"location": "header"` sale **vacía**, o sea que **SES no publica ninguna cabecera de caudal**.

## [F34] Modelo de servicio `ses` 2010-12-01 *(contrato máquina)*

- **URL:** https://raw.githubusercontent.com/boto/botocore/develop/botocore/data/ses/2010-12-01/service-2.json
- **Fecha de acceso:** 2026-09-18
- **Cita literal:** `AccountSendingPausedException` con `{"code": "AccountSendingPausedException", "httpStatusCode": 400, "senderFault": true}` *(ver DISC-12)*
- **Ausencia comprobada:** tampoco existe forma `Throttling` en el modelo v1; es error genérico del protocolo Query.

## [F35] AWS SDKs and Tools Reference — Retry behavior

- **URL:** https://docs.aws.amazon.com/sdkref/latest/guide/feature-retry-behavior.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:** `"Some AWS services include an x-amz-retry-after header in error responses. The header value is a delay in milliseconds."`, **sin decir si SES es uno de ellos** · `"Standard mode retries failed requests using exponential backoff with jitter."`

## [F36] Blog de AWS — Cómo tratar el error «Throttling – Maximum sending rate exceeded» *(editorial, 2013)*

- **URL:** https://aws.amazon.com/blogs/messaging-and-targeting/how-to-handle-a-throttling-maximum-sending-rate-exceeded-error/
- **Fecha de acceso:** 2026-09-18 · **Publicado el 01 FEB 2013**
- **Cita literal**, del código de ejemplo: `if ("Throttling".equals(e.getErrorCode()) && "Maximum sending rate exceeded.".equals(e.getMessage()))` — con punto final dentro del mensaje.

## [F37] Blog de AWS — Qué pasa cuando alcanzas tus límites de envío *(editorial, 2012)*

- **URL:** https://aws.amazon.com/blogs/messaging-and-targeting/what-happens-when-you-reach-your-sending-limits/
- **Fecha de acceso:** 2026-09-18 · **Publicado el 04 DEC 2012**
- **Citas literales:** `"If you are accessing the Amazon SES API through the Amazon SES HTTP interface directly, you will receive an HTTP status code of 400 with an error of type Throttling."` *(ver DISC-08)* · `"the call fails with a throttling error and the email is dropped. Amazon SES does not queue the emails and send them later."` · `"if your send rate quota is one message per second, and you send a message to five recipients at once, Amazon SES lets you do that. For the next five seconds, though, Amazon will return errors for all send attempts."`

---

## Panel

## [F38] Observación de panel con cuenta propia — 2026-09-18

- **Fecha de acceso:** 2026-09-18 · **Cuenta:** la del proyecto, región **Europa (Irlanda)**, `eu-west-1`
- **Evidencia:** `evidencias/panel_ses_2026-09-18.md` · **Consola en español**, los literales van como se muestran
- **Citas literales:**
  - `"La cuenta de Amazon SES se encuentra en el entorno de pruebas en Europa (Irlanda)"` — el estado **nombra la región**
  - `"Cuota de envío diaria"` → `"200 correos electrónicos por periodo de 24 horas"`
  - `"Tasa máxima de envío"` → `"1 correo electrónico por segundo"`
  - `"Estado"` → `"En buen estado"` · `"Envíos restantes 200"` · `"Cuota de envío utilizada 0.00%"`
  - Service Quotas, con el valor aplicado y el **predeterminado de AWS coincidiendo**: `"Sending quota | 200 per 24 horas | 200 per 24 horas | 0 per hour | Nivel de cuenta"` y `"Sending rate | 1 por segundo | 1 por segundo | 0 por segundo | Nivel de cuenta"`
  - Identidades: una, `"Dirección de correo electrónico"`, `"Verificado"`
  - IP dedicadas: `"Las IP dedicadas (administradas) están disponibles por una tarifa mensual estándar (independientemente de la cantidad de IP necesarias) y un cargo por uso de mensajes."`
- **Lo que solo da el panel:** que el valor aplicado y el predeterminado **coinciden**, y que las cuatro cuotas salen como `"Capacidad de ajuste: Nivel de cuenta"`. La documentación dice que son ajustables; el panel enseña que el valor de arranque no es de esta cuenta, es de cualquiera.

## [F45] Panel con cuenta propia — segunda pasada: test C2 y el plan de precios de la consola

- **Fecha de acceso:** 2026-09-18 · **Cuenta:** la del proyecto, **consola en español**, región **Europa (Irlanda)**, `eu-west-1`
- **Evidencia: pendiente de volcar.** `evidencias/panel_ses_2026-09-18.md` recoge la primera
  pasada y no menciona plantillas. Los literales de abajo salen de la observación de esta
  segunda y **todavía no tienen fichero propio en `evidencias/`**. Es hueco de registro y se
  declara aquí en vez de dejarlo implícito.
- **Qué añade a [F38]:** la primera pasada recorrió el estado de la cuenta y las cuotas. Esta
  va a las páginas donde vive cada operación del test C2, y al plan de precios.
- **Citas literales:**
  - Plantillas (`#/email-templates`), página de **solo listado**: `"Para crear una plantilla de correo electrónico, utilice la operación de la API CreateEmailTemplate"` · `"Para ver el contenido de una plantilla de correo electrónico específica, utilice la operación GetEmailTemplate en la API de Amazon SES"` *(ver DISC-15)*
  - Identidades: `"Crear identidad"` · Envío: `"Enviar correo electrónico de prueba"`
  - Plan de precios, nota al pie 1: `"Puede tratarse de un correo electrónico enviado mediante SES para mensajes salientes (se cobra por destinatario)"` *(ver DISC-02)*
  - Plan de precios, nota al pie 8: `"Se cobra a 0.09 USD por 1000 fragmentos de correo electrónico entrantes y 0.1 USD por 1000 destinatarios más allá del primer destinatario cuando se utiliza la acción de la regla 'Enviar a Internet'"`
  - Uso diario del correo electrónico: `"Correos electrónicos enviados"` → **5** · `"Envíos restantes"` → 195 · `"Cuota de envío utilizada"` → `2.50%`
  - Ficha de plan: `"Plan: Essentials"` junto a `"Región: Europa (Irlanda)"`, en la misma ficha
- **Test C2, completo.** `CreateEmailIdentity` existe en la API **y** en la consola.
  `SendEmail`, también en las dos. `CreateEmailTemplate` existe en la API y **no** en la
  consola, que remite a la API. Ninguna es exclusiva de la web, que es lo que C2 pregunta. Y
  aparece el **caso inverso de F-22**: aquí lo exclusivo es de la API, y el proveedor lo dice
  en su propio panel.
- **El panel se contradice con su propio número.** La cuenta envió **cuatro** mensajes y la
  fila marca `"Correos electrónicos enviados"` → **5**. La consola usa «correos» para una
  cuenta que son destinatarios, igual que hace la documentación. Es la ambigüedad de DISC-02,
  ahora en la interfaz.
- **F-31 corroborado:** el plan es del par **cuenta × región**, y la ficha lo enseña poniendo
  `"Plan: Essentials"` y `"Región: Europa (Irlanda)"` juntos.
- **Lo que no se tocó, y por qué.** La ficha de plan tiene `"Cancelar plan"` y `"Cambiar
  plan"`: eso es facturación, carril rojo. Tampoco se pulsó `"Enviar correo electrónico de
  prueba"`, porque un botón de panel no declara presupuesto ni comprueba la lista blanca. Para
  eso está el sondeo por script.

## [E1] Sondeo empírico — la cuenta contada por la propia API

- **Fecha:** 2026-09-18, 09:41 UTC · **Ejecutado por:** el agente en la máquina del autor, con
  las credenciales de `~/.config/tfm/.env` firmadas con SigV4. Script
  `05_salida/_herramientas/probe_ses_cuota_caudal.py`, llamada `GET /v2/email/account` en
  `eu-west-1`. **Coste 0 envíos.**
- **Evidencia:** `evidencias/probe_ses_cuota_caudal_2026-09-18_094142.json`, con el número de
  cuenta de AWS y el nombre del usuario de IAM redactados.
- **Resultado literal:** `"SendQuota": {"Max24HourSend": 200.0, "MaxSendRate": 1.0,
  "SentLast24Hours": 0.0}` · `"ProductionAccessEnabled": false` · `"EnforcementStatus":
  "HEALTHY"` · `"SendingEnabled": true` · `"PricingAttributes": {"CurrentPlan": "ESSENTIALS",
  "NextPlan": null}` · `"SuppressionAttributes": {"SuppressedReasons": ["BOUNCE",
  "COMPLAINT"]}` · `"DedicatedIpAutoWarmupEnabled": true`.
- **Qué añade a lo documental.** Tres cosas que ninguna página publica de esta cuenta. Los dos
  topes del entorno de pruebas los dice **la API**, no solo el manual, y coinciden al decimal
  con [F1] y [F2]. El campo `PricingAttributes` demuestra que **los planes de precio son una
  propiedad de la cuenta que la API expone**, con el nombre `ESSENTIALS` en mayúsculas, y con
  un `NextPlan` que deja ver que el cambio de plan se programa. Y la lista de supresión
  arranca con dos motivos, `BOUNCE` y `COMPLAINT`, que el manual describe como configurables.
- **Lo que no toca:** ningún semáforo. Los dos topes ya estaban en 🟢 por literal documental,
  y esto los corrobora sin cambiar el color (D1 no distingue grados de verde).

## [E2] Sondeo empírico — el envío no llega a intentarse: falta el permiso de IAM

- **Fecha:** 2026-09-18, 09:41 UTC · **Ejecutado por:** el agente, mismo script y misma
  pasada que [E1]. Cuatro llamadas `POST /v2/email/outbound-emails`: dos seguidas contra
  `sondeo@example.invalid` para provocar el caudal sin gastar nada, y dos contra la dirección
  verificada de la lista blanca de D-046, una con un destinatario y otra con la misma
  dirección en `to` y en `cc`. **Presupuesto declarado: 2 envíos. Salidos: 0.** El JSON
  escribe `"envios_gastados": 2` porque el script fija ese campo en el código y no lo cuenta;
  manda el registro de los cuatro pasos, que son cuatro rechazos.
- **Resultado literal**, idéntico en las cuatro: HTTP **403**, cabecera
  `x-amzn-errortype: AccessDeniedException`, y el cuerpo
  `"User 'arn:aws:iam::<cuenta>:user/<principal>' is not authorized to perform 'ses:SendEmail'
  on resource 'arn:aws:ses:eu-west-1:<cuenta>:identity/<direccion>'"`. El contador
  `SentLast24Hours` se queda en `0.0` en las cuatro lecturas.
- **Qué mide de verdad.** Que en SES **la autorización se resuelve antes que el caudal y antes
  que la identidad**: dos peticiones consecutivas con un tope publicado de una por segundo no
  producen ningún error de caudal, porque IAM las rechaza primero.
- **El hallazgo que aguanta: el recurso del permiso lleva la dirección de DESTINO.** Lo que
  el error nombra no es una acción, es un ARN de identidad construido con una dirección de
  correo. En esta pasada las cuatro traen el mismo ARN y además redactado, así que [E2] por sí
  sola no dice qué dirección lo construye. Lo dice [E3]: con el permiso ya concedido sobre la
  identidad verificada, los dos intentos contra `sondeo@example.invalid` siguen en 403
  nombrando `identity/sondeo@example.invalid`, y los dos a la dirección verificada salen en
  200. **El ARN que decide lleva la dirección de destino.**
  **Y eso cierra por construcción la vía preferente del mandato.** La condición 3 de D-046
  prefiere el rechazo al envío: si el dato sale del cuerpo de un error, no se gasta cuota. En
  SES ese cuerpo no llega. Todo destinatario que el proveedor fuera a rechazar es un
  destinatario que IAM no autoriza, así que el error que sale es el de permisos y nunca el del
  producto. Para tocar el caudal hay que enviar de verdad. → afecta a la condición 3 de D-046
  y pide línea en `docs/08-mandato.md`.
- **Y es la medición de la variante de F-22 en SES.** Lo que la documentación decía —que la
  API de SES no tiene ni una acción de credenciales en sus 116, y que el control de acceso es
  de IAM— aquí se toca: el permiso que falta no se llama `ses:algo` dentro del producto de
  correo, es una política de **otro servicio** la que decide si la llamada entra.
- **Lo que no cierra, y por qué.** Esta pasada no decide nada de DISC-02, DISC-07, DISC-08 ni
  DISC-14: ninguna llamada de envío llegó al producto. **La frase que este bloque traía —que
  las cuatro eran carril rojo, porque conceder `ses:SendEmail` es tocar claves— quedó caduca el
  mismo día.** El permiso se concedió sobre la identidad verificada, y [E3], [E4] y [E5] miden
  tres de las cuatro. La que se queda sin vía es DISC-14, y por el hallazgo de arriba: exige un
  destinatario no verificado, que es justo el que IAM no autoriza.

## [E3] Sondeo empírico — cuatro mensajes, cinco destinatarios, con el permiso ya concedido

- **Fecha:** 2026-09-18, 09:58 UTC · **Ejecutado por:** el agente en la máquina del autor, con
  las credenciales de `~/.config/tfm/.env` firmadas con SigV4 y el permiso `ses:SendEmail` ya
  concedido sobre la identidad verificada. Script
  `05_salida/_herramientas/probe_ses_cuota_caudal.py`, región `eu-west-1`, mismo diseño de
  ocho pasos que [E2]. **Presupuesto declarado: 2 envíos. Salidos: 2.**
- **Evidencia:** `evidencias/probe_ses_cuota_caudal_2026-09-18_095842.json`, con el número de
  cuenta de AWS y el nombre del usuario de IAM redactados.
- **Resultado literal**, paso a paso:
  - `account.antes` → HTTP 200, `"SentLast24Hours": 0.0` sobre `"Max24HourSend": 200.0`
  - `rechazo.1` y `rechazo.2`, contra `sondeo@example.invalid` → HTTP **403**,
    `x-amzn-errortype: AccessDeniedException`, `"...is not authorized to perform
    'ses:SendEmail' on resource
    'arn:aws:ses:eu-west-1:<cuenta>:identity/sondeo@example.invalid'"`
  - `envio_A`, un destinatario → HTTP **200**,
    `"MessageId": "010201a0b3f41697-0614508d-848c-42c5-a21c-9e8b6aeb7d53-000000"`
  - `envio_B`, la misma dirección en `to` y en `cc` → HTTP **200**,
    `"MessageId": "010201a0b3f427f4-d4a80eda-c4cc-4676-aa5c-c85832d09e2a-000000"`
  - las tres lecturas posteriores del contador → `"SentLast24Hours": 0.0`, sin moverse
- **Qué añade, y qué no.** Añade los envíos y el ARN del destinatario, que es lo que sostiene
  el hallazgo de [E2]. **No añade la lectura que buscaba**, y el motivo es de diseño: el script
  lee el contador cuatro segundos después de cada envío (`time.sleep(4)`) y el contador de SES
  tarda más en moverse. Los cuatro deltas salen a cero. El fallo no fue el destinatario ni el
  permiso, fue la espera. La lectura buena la da [E5].
- **Lo que no toca:** ningún semáforo por sí solo.

## [E4] Sondeo empírico — dos envíos seguidos contra un tope publicado de uno por segundo

- **Fecha:** 2026-09-18, 10:00 UTC · **Ejecutado por:** el agente, script
  `05_salida/_herramientas/probe_ses_caudal.py`, región `eu-west-1`. Dos peticiones
  `POST /v2/email/outbound-emails` sin pausa entre ellas, un destinatario cada una: la
  dirección verificada de la lista blanca de D-046. **Presupuesto declarado: 2 envíos.
  Salidos: 2.**
- **Evidencia:** `evidencias/probe_ses_caudal_2026-09-18_100041.json`
- **Resultado literal:** la API publica `"MaxSendRate": 1.0` en la misma pasada, y las dos
  peticiones salen a **0,257 s** y **0,518 s** del inicio, las dos en HTTP **200** con
  `MessageId`. Ningún error de caudal, ninguna cabecera de espera.
- **Lo que cierra y lo que no.** No cierra DISC-07 ni DISC-08: no hubo rechazo que nombrar.
  Mide otra cosa, y es la buena. **Dos envíos dentro del mismo segundo pasan contra un tope
  publicado de uno por segundo.** Es una repetición y no fija ningún techo, así que se registra
  como evidencia de **F-04**, restricciones declaradas y no aplicadas, y **no se adopta ningún
  valor** en `max_power`. Buscar el caudal real es medición formal, que el encargo deja
  preparada y no comprometida.

## [E5] Sondeo empírico — el caudal de una ruta de lectura, y el contador ya movido

- **Fecha:** 2026-09-18, 10:02 UTC · **Ejecutado por:** el agente, script
  `05_salida/_herramientas/probe_ses_caudal_lectura.py`, región `eu-west-1`. Dos pasadas sobre
  `GET /v2/email/account`, de menos a más: doce peticiones secuenciales y treinta concurrentes.
  **Presupuesto declarado: 0 envíos. Salidos: 0.**
- **Evidencia:** `evidencias/probe_ses_caudal_lectura_2026-09-18_100218.json`
- **Resultado literal:**
  - contador de la cuenta: `"SentLast24Hours": 5.0` sobre `"Max24HourSend": 200.0`
  - pasada secuencial, **5,7 peticiones por segundo**: doce de doce en HTTP 200, cero rechazos
  - pasada concurrente, **140,8 peticiones por segundo**: `{"429": 9, "200": 21}`, con
    `x-amzn-errortype: TooManyRequestsException` y cuerpo `{"message": "Rate exceeded"}` en las
    nueve. **Ninguna respuesta trae `retry-after`.**
  - veredicto que escribe el propio sondeo: `"rechazo alcanzado"`
- **Lo que cierra: DISC-02, la unidad de la cuota.** Los cuatro mensajes que [E3] y [E4]
  dejaron aceptados llevaban **cinco destinatarios** —uno, dos y dos más—, y el contador marca
  **5,0** partiendo de `0,0`. Cinco descarta las dos lecturas rivales por construcción:
  «mensajes» daría cuatro, y deduplicar la dirección repetida de `envio_B` también daría
  cuatro. Manda el lado B, **destinatarios**. → línea de cierre dentro de `### DISC-02`.
- **Lo que acota sin cerrar: DISC-07 y DISC-08.** El nombre y el código están medidos, pero
  sobre `GET /v2/email/account`, que es una **ruta de lectura** y no el endpoint de envío. Las
  dos entradas preguntan por el caudal de la API v2 sin decir de qué ruta, así que lo medido
  estrecha y no decide. → líneas de acotación dentro de sus entradas.
- **El tercero, que no estaba en ninguna pregunta: el contador va con retraso.** [E3] lo leyó
  cinco segundos de reloj después de su último envío y seguía en `0,0`. Esta pasada, fechada a las 10:02
  y con el último envío de [E4] a las 10:00:41, ya cuenta los cinco. El retraso queda **acotado
  entre cinco segundos y minuto y medio largo**, y no se ha medido más fino. El sondeo pendiente
  de DISC-10 —leer el contador cada hora durante 24 h— tiene que contar con esa latencia.
- **Y uno que ya recurre:** un 429 sin `retry-after`. MailerSend tenía DISC-19 exactamente por
  esto. Con SES son dos APIs, así que es candidato a fricción por recurrencia. → `fricciones.md`.

---

# Discrepancias

**Veinte**, y conviene decir desde el principio lo que las hace distintas de las de las cinco
APIs anteriores: **casi todas son de AWS contra AWS**. No son un proveedor cuya página de
precios no cuadra con su centro de ayuda, sino una documentación de producto que se
contradice con su propia referencia de API, y las dos con el contrato máquina que genera los
SDK. Ninguna se arbitra aquí: por **E5** una discrepancia se cierra midiendo o disolviéndola,
nunca eligiendo.

**El efecto es de cada entrada, no de la sección.** Por eso cada `DISC-nn` lo declara dentro,
en una línea `Efecto declarado:` con dos campos: si la contradicción es **excluyente** por
**D11**, y qué le hace al color del campo afectado (**E6**). Una cabecera que prometiera 🟡
para las veinte mentiría en cuanto se abre el fichero. Hay entradas que no son excluyentes,
hay ámbar y rojo que ponen **D1** y **D3** y no D11, y hay campos que no existen en el
`datasheet.yaml`. **Dos cierran**, DISC-02 y DISC-15, con el supuesto, la fecha y la prueba
escritos dentro de su entrada; las demás siguen abiertas, y las que la medición estrecha lo
dicen dentro.

### DISC-01 · Los *configuration sets*: ¿ajustables o no?

- **A —** [F1]: `"Maximum number of configuration sets"` → `"10,000"` · **Adjustable: No**. *(Se retira el localizador «tabla de *event publishing*»: era hit único del fichero y el bloque [F1] no lo respalda. El literal sigue en pie.)*
- **B —** [F7], tabla de Service Quotas: `"Configuration set count | Each supported Region: 10,000 | Adjustable: Yes"`, con código de cuota `L-10E24536`
- **Efecto en la datasheet:** ninguno **sobre el semáforo**, porque `data_provenance` no lleva color. Decide si el techo es del producto o del contrato. Por **B3** un límite de recurso no va a `capacity`: va al provenance con cifra y cita, y esa línea hoy falta en `datasheet.yaml`. **Vía de cierre intentada el 2026-10-18:** `GetServiceQuota` sobre `L-10E24536` devuelve `AccessDeniedException`, porque el usuario IAM del sondeo no tiene `servicequotas:GetServiceQuota` (`evidencias/probe_ses_cuota_config_sets_2026-10-18_222220.json`). Darle ese permiso es decisión del autor; con él, una lectura cierra la entrada.
- **Efecto declarado:** excluyente · campo sin valor

### DISC-02 · La unidad de la cuota: ¿correos o destinatarios? — **CERRADA**

- **A —** [F7], tabla de Service Quotas: `"The maximum number of emails that you can send in a 24-hour period for this account in the current Region."` · [F8], campo `Max24HourSend`: `"The maximum number of emails that you can send in the current AWS Region over a 24-hour period. A value of -1 signifies an unlimited quota."` · [F1], fila de sandbox: `"If your account is in the sandbox, you can send up to 200 emails per 24-hour period."`
- **B —** [F1], cabecera de esa misma tabla: `"Quotas are based on the number of recipients, rather than on the number of messages."` · [F3]: `"Sending quotas are based on recipients rather than on messages. For example, an email that has 10 recipients counts as 10 against your quota."` · [F13]: `"Sending quota—the maximum number of recipients that you can send email to in a 24-hour period."`
- **Retirada de una cita sin respaldo (E1).** El lado A se apoyaba en un título de fila, `"Number of emails that can be sent per 24-hour period"`, que **no está entre los literales de [F1]** ni en ningún volcado de `evidencias/paginas/`. Se retira y en su sitio van los tres literales de arriba, que sí están registrados. Fuera de esta constancia y de la equivalente en `REVISION.md`, la cita ya no aparece en ningún fichero del catálogo.
- **La misma página sostiene las dos**, que es lo más difícil de defender: la cabecera de la tabla de [F1] cuenta destinatarios y su fila de sandbox cuenta correos.
- **Cierre (E5, midiendo · 2026-09-18 · [E3], [E4] y [E5]).** Cuatro mensajes aceptados con cinco destinatarios —uno, dos con la misma dirección en `to` y en `cc`, y dos más— dejan `SentLast24Hours` en **5,0** partiendo de `0,0`. Cinco separa las dos lecturas por construcción: contar mensajes daría cuatro, y deduplicar la dirección repetida daría cuatro también. **Manda el lado B: destinatarios.** Ficheros: `evidencias/probe_ses_cuota_caudal_2026-09-18_095842.json`, `evidencias/probe_ses_caudal_2026-09-18_100041.json` y `evidencias/probe_ses_caudal_lectura_2026-09-18_100218.json`.
- **Segunda vía, independiente de la medición:** el proveedor lo escribe en su propio panel [F45], nota al pie de la página de plan de precios — `"Puede tratarse de un correo electrónico enviado mediante SES para mensajes salientes (se cobra por destinatario)"`.
- **Efecto en la datasheet:** decide el `unit` de la cuota y, con él, el significado del CRF. **El cierre no mueve ningún color**, y conviene decir por qué: `capacity.quota_email_daily_sandbox.unit` nunca llevó marca de semáforo, así que no había 🟡 que levantar. Lo que el cierre fija es el significado: la unidad medida es el destinatario. El campo conserva `emails` a propósito, por las dos razones escritas en su provenance —la guía de v0.3 no trae `recipients` entre las unidades, y PRIME4API casa unidades por igualdad de cadena—, y el recuento de `verificar_estado.py` se queda igual.
- **Por E7 esta entrada bloqueaba el cierre de la Datasheet**, porque una discrepancia sobre la unidad de un contador sale de la cláusula «no cuesta nada» de E5. Con el cierre escrito, deja de bloquearlo.

### DISC-03 · El valor por defecto al salir del sandbox

- **A —** [F1], fila de la cuota de envío, fuera del sandbox: `"this number varies based on your specific use case."`, sin cifra · [F9], campo `ProductionAccessEnabled`, que publica la misma magnitud con otras palabras: `"The sending quota and maximum sending rate for your account vary based on your specific use case."`
- **B —** [F18], blog de 2014: `"the default quota is 50,000 messages per day"`
- **Efecto en la datasheet:** es la cuota de 24 h de una cuenta con acceso de producción. **No es `max_power`**, que es el bloque de los caudales: sería `capacity.quota_email_daily_production`, y esa clave **no existe en el fichero**. La lectura conservadora deja el hueco sin valor, hoy registrado en `metadata.not_found`, porque la única cifra publicada tiene doce años.
- **Efecto declarado:** no excluyente · campo sin valor · sin efecto sobre el color

### DISC-04 · Qué se deshabilita en el sandbox sobre la lista de supresión

- **A —** [F2]: `"For account-level suppression, bulk actions and SES API calls related to suppression list management are disabled."` (todas las llamadas de gestión)
- **B —** [F14], la unidad entera que registra su bloque y no el recorte que arrancaba en «However» (**D12**): `"You can enable your account-level suppression list if your account is in the SES sandbox. However, you can't use the PutSuppressedDestination or CreateImportJob operation until your account is removed from the sandbox."` La primera frase es la que decide.
- **Acotada y no cerrada (E5).** Con la unidad entera delante, la exclusión **necesita un paso que nadie publica**: que habilitar la lista sea una llamada de API. [F14] deja habilitarla dentro del entorno de pruebas y exceptúa dos operaciones; [F2] deshabilita `"all SES API calls related to suppression list management"`. Para que choquen hay que añadir ese paso, y no lo publica ninguna fuente. El contrato máquina lista **siete** operaciones de supresión —`PutAccountSuppressionAttributes`, `PutConfigurationSetSuppressionOptions`, `PutTenantSuppressionAttributes`, `PutSuppressedDestination`, `GetSuppressedDestination`, `ListSuppressedDestinations` y `DeleteSuppressedDestination`—, y `CreateImportJob` no está entre ellas: desborda el alcance que enuncia A *(`evidencias/sesv2_service-2_2026-09-18.json`)*.
- **Efecto en la datasheet:** ninguno sobre el semáforo. El comodín `/*` de los cuatro planes ya modela las siete rutas de supresión. Lo que falta es la línea de `metadata.not_found` que diga qué queda sin saber sobre la supresión en sandbox, y eso es cambio de `datasheet.yaml`.
- **Efecto declarado:** no excluyente mientras falte el paso no publicado · campo sin valor

### DISC-05 · El alcance del tope de una petición por segundo

- **A —** [F1]: `"All actions (except for SendEmail, SendRawEmail, and SendTemplatedEmail) are throttled at one request per second."` Leído literal, **`SendBulkEmail` y el `SendEmail` de v2 quedarían capados a 1 req/s**, porque la lista exime nombres de v1.
- **B — no es un literal rival, es una inferencia del recolector** sobre dos literales bien transcritos: [F7] `"Sending rate | Each supported Region: 1 per second | Adjustable: Yes"` (`L-CDEF9B6B`) y [F4] `"Your account has the following quotas per your current region that can be increased."`, con `"Sending rate | 1"`. De ahí se dedujo que las operaciones de envío no están bajo un tope fijo de 1 req/s. Ninguna de las dos fuentes lo dice.
- **Y [F8] llama TPS a esa misma tasa:** `"This value is also called your maximum sending rate or your maximum TPS (transactions per second) rate."`, lo que mantiene viva la lectura de que es el mismo dato contado dos veces.
- **Acotada y no cerrada (E5 · 2026-09-18 · [E4] y [E5]).** El tope publicado no es el que se aplica. [E5] hizo **doce peticiones secuenciales a 5,7 por segundo contra `GET /v2/email/account`, sin un solo rechazo**, y esa operación es una de «todas las demás acciones» que el literal de [F1] capa a una por segundo. [E4] hizo **dos envíos en 0,52 s con `MaxSendRate: 1.0` publicado**, los dos aceptados. El techo real **no se busca**: es medición formal y no está en el encargo.
- **Efecto en la datasheet:** decide si el catálogo declara un `rate` para el resto de endpoints o si el 1 por segundo es el mismo dato contado dos veces. Como el lado B nunca fue literal, **D11 no fundó este ámbar**: el 🟡 de `max_power.rate_request_other` lo sostiene **D1**, por ambigüedad del alcance, que es lo que ya dice su provenance.
- **Efecto declarado:** no excluyente, porque el lado B es inferencia y no literal · sin efecto sobre el color, que lo pone D1

### DISC-06 · El eje: ¿cuenta o región?

- **A —** [F1]: `"SES quotas are for each AWS Region that you use in your AWS account."`
- **B —** [F15]: `"Only one contact list is allowed per AWS account."` · [F1], con su literal entero y no el recorte: `"Maximum number of receipt rule sets per AWS account"` → `"40"` y `"Maximum number of IP address filters per AWS account"` → `"100"`. El registro se había comido «Maximum number of» y usaba barra donde la fuente usa flecha.
- **Y [F3] refuerza A para la cuota de envío:** `"Your Amazon SES sending quotas are separate for each AWS Region."`
- **Efecto en la datasheet:** ninguna fuente explica por qué unas cuotas son por región y otras por cuenta. Es el eje entero del proveedor y está sin declarar. Queda establecido lo que dicen los dos literales y el alcance fila a fila; falta el criterio, que es hueco de `metadata.not_found` y no campo con color.
- **Efecto declarado:** no excluyente · los dos alcances conviven sobre objetos distintos · campo sin valor

### DISC-07 · El nombre del error de caudal en la API v2

Cuatro fuentes de AWS y dos nombres, con la versión sin decidir:

- **A —** [F5], la página monográfica: `"the API produces a ThrottlingException error"`
- **B —** [F10], la referencia de `SendEmail`: `"TooManyRequestsException — Too many requests have been made to the operation. HTTP Status Code: 429"`. *(Se retira [F11] de esta atribución: su bloque registra `"Composes an email message to multiple destinations."`, `BulkEmailEntries` y el hueco de `Array Members`, y ni `TooManyRequests` ni `429`.)*
- **C —** [F33], el contrato máquina: `ThrottlingException` **no figura entre las trece formas de excepción del modelo v2**, un contenedor que sí tiene sitio para ella porque cada forma lleva su `httpStatusCode`. Es ausencia medida, no hueco de cobertura.
- **D —** [F28] y [F29], las páginas *Common Errors*, que publican `ThrottlingException` con 400 y existen idénticas en v2 y en v1: [F28] `"ThrottlingException — Your request rate is too high. The AWS SDKs automatically retry requests that receive this exception. Reduce the frequency of requests. HTTP Status Code: 400"`, [F29] la misma frase con elipsis. La página de errores comunes **no desambigua la versión**, que es el asunto entero de la entrada.
- **Acotada y no cerrada (E5 · 2026-09-18 · [E5]).** El nombre está medido: `x-amzn-errortype: TooManyRequestsException`, cuerpo `{"message": "Rate exceeded"}` y sin `retry-after`, en nueve de treinta peticiones concurrentes. `ThrottlingException` no apareció. **Pero se midió sobre `GET /v2/email/account`, que es una ruta de lectura y no el endpoint de envío.** La entrada pregunta por el caudal de la API v2 sin decir de qué ruta, así que lo medido **estrecha y no decide**. Cierra cuando se repita contra el envío. Fichero: `evidencias/probe_ses_caudal_lectura_2026-09-18_100218.json`.
- **Efecto en la datasheet:** ninguno sobre el semáforo. Ningún campo del esquema guarda el nombre de un error. Decide qué espera un sondeo de caudal.
- **Efecto declarado:** excluyente · campo sin valor

### DISC-08 · El código HTTP del caudal

- **A —** [F37], blog de 2012, con la condicional que la entrada truncaba (**D12**): `"If you are accessing the Amazon SES API through the Amazon SES HTTP interface directly, you will receive an HTTP status code of 400 with an error of type Throttling."` La condición acota A a la interfaz HTTP directa de 2012, y **refuerza la Nota en vez de desmentirla**.
- **B —** [F10]: `"TooManyRequestsException ... HTTP Status Code: 429"`
- **Los dos códigos conviven dentro de la v2:** 400 para `ThrottlingException` en [F28], 429 para `TooManyRequestsException` en [F10] y [F33].
- **Nota:** es plausible que sea la diferencia entre v1 y v2, pero **ninguna fuente lo enuncia así**, así que no se adopta esa lectura. Los dos ejes siguen vivos —la versión y el nombre del error— y ninguno está decidido.
- **Acotada y no cerrada (E5 · 2026-09-18 · [E5]).** El código medido es **429**, nueve veces de treinta peticiones concurrentes. **Se midió sobre `GET /v2/email/account`, una ruta de lectura y no el envío**, así que estrecha sin decidir, igual que DISC-07. Fichero: `evidencias/probe_ses_caudal_lectura_2026-09-18_100218.json`.
- **Efecto en la datasheet:** ninguno sobre el semáforo. Ningún campo guarda el código de un error.
- **Efecto declarado:** excluyente · campo sin valor

### DISC-09 · Cuánto esperar antes de reintentar

Dos recomendaciones incompatibles, las dos oficiales:

- **A —** [F5], sin distinguir canal: `"If you encounter a throttling error, you should program your application to wait for an interval of up to 10 minutes, and then retry the send request."`
- **B —** [F16], con el paréntesis entero y sin elipsis (**D12**): `"You should retry SMTP requests that receive 400 errors. We recommend that you implement a system that retries requests with progressively longer wait times (for example, wait 5 seconds before retrying, then wait 10 seconds, and then wait 30 seconds). If the third retry doesn't succeed, wait 20 minutes, and then repeat the process."` Los 5/10/30 van **dentro** del paréntesis y son ejemplo; los **20 minutos quedan fuera**, y son prescriptivos.
- **Lado C retirado (E1).** Se le atribuía a [F36] un retroceso exponencial de 10 ms a 5.000 ms hasta diez reintentos. [F36] **no contiene ninguna de las tres cifras**: su única cita literal es la condición Java que detecta el error. Comprobado también contra `evidencias/`.
- **Lo que queda en pie:** el techo de `"up to 10 minutes"` de [F5] contra el `"wait 20 minutes"` prescrito de [F16]. Dos cifras incompatibles para la misma decisión.
- **Efecto en la datasheet:** ninguno. v0.3 no tiene campo para la espera recomendada de un reintento, así que la colisión vive solo en el registro.
- **Efecto declarado:** excluyente · campo sin valor

### DISC-10 · La ventana de la cuota diaria: ¿deslizante o fija?

- **A —** [F3]: `"This quota is calculated on a rolling time period. Every time you try to send an email, Amazon SES determines the number of emails that you sent in the previous 24 hours."`
- **B —** [F32]: `"you will have to wait until the next 24-hour period before you can send more email"`
- **Efecto en la datasheet:** decide el `window_type` de la cuota, que es campo del esquema. Con **D3** una ventana que no se declara literalmente no sube a verde.
- **Y el panel mezcla las dos ventanas en la misma fila** [F38]: `"Cuota de envío diaria"` → `"200 correos electrónicos por periodo de 24 horas"`. Si entra, entra del lado del **periodo** y no del `rolling`, y **D5** es excepción reconocida por D11: conviene mirarlo antes de mover nada.
- **Vía de cierre, coste cero envíos:** leer `GET /v2/email/account` cada hora durante 24 h y ver si `SentLast24Hours` baja continuo o de golpe. [E5] añade una cautela de diseño: el contador va con retraso.
- **Efecto declarado:** excluyente · `window_type` sin valor y en 🔴 por la cuarta cláusula de D3, no por D11

### DISC-11 · `BulkEmailEntryResult` se contradice consigo misma

- **A —** la prosa de [F30] enumera `CONFIGURATION_SET_DOES_NOT_EXIST`, `TEMPLATE_DOES_NOT_EXIST` e `INVALID_PARAMETER_VALUE`
- **B —** el bloque `"Valid Values"` de esa **misma página** enumera `CONFIGURATION_SET_NOT_FOUND`, `TEMPLATE_NOT_FOUND` e `INVALID_PARAMETER`. [F33] confirma los segundos con el enum entero: `"BulkEmailStatus"` → `SUCCESS`, `MESSAGE_REJECTED`, `MAIL_FROM_DOMAIN_NOT_VERIFIED`, `CONFIGURATION_SET_NOT_FOUND`, `TEMPLATE_NOT_FOUND`, `ACCOUNT_SUSPENDED`, `ACCOUNT_THROTTLED`, `ACCOUNT_DAILY_QUOTA_EXCEEDED`, `INVALID_SENDING_POOL_NAME`, `ACCOUNT_SENDING_PAUSED`, `CONFIGURATION_SET_SENDING_PAUSED`, `INVALID_PARAMETER`, `TRANSIENT_FAILURE`, `FAILED` *(`evidencias/sesv2_service-2_2026-09-18.json`)*
- **Hueco de registro, declarado (E1).** Los seis literales de la web —los tres de la prosa y los tres de `"Valid Values"`— **no constan en el bloque [F30]**, que registra otros cinco valores. Mientras no consten, los dos lados se apoyan en texto que este fichero no guarda. Se arregla registrándolos en [F30] al releer la página. **No** reatribuyendo el lado A al contrato máquina: eso sería eliminar un lado por sustitución de fuente, y E5 no lo admite.
- **Efecto en la datasheet:** ninguno. El enum del resultado de un lote no tiene campo en v0.3.
- **Efecto declarado:** excluyente · campo sin valor

### DISC-12 · El nombre de cable del error de cuenta pausada

- **A —** [F31]: `"AccountSendingPaused"`
- **B —** [F34]: `"code": "AccountSendingPausedException"`
- **Efecto en la datasheet:** ninguno. DISC-12 es de la **v1** y el producto modelado es la **v2**, donde [F33] publica `SendingPausedException`. Ese nombre no dirime el de la v1.
- **Los dos lados archivados el 2026-10-18, y la entrada sigue abierta.** El modelo está en `evidencias/botocore_ses_2010-12-01_service-2_2026-10-18.json`, con `"error": {"code": "AccountSendingPausedException", "httpStatusCode": 400, "senderFault": true}`. La página v1 está en `evidencias/paginas/API_SendEmail_v1_2026-10-18.html` y sigue diciendo `AccountSendingPaused`. Las dos citas aguantan. Solo queda provocar el error, y eso exige pausar el envío de la cuenta con `UpdateAccountSendingEnabled`: no compensa para un campo que no existe.
- **Efecto declarado:** excluyente · campo sin valor

### DISC-13 · «400» y «500» en un canal que no los tiene

- **A —** [F16]: `"You should retry SMTP requests that receive 400 errors"` y, dos frases después, `"If you receive a 500 error, you have to revise your request to correct an issue before you submit the request"`.
- **B —** la tabla de esa misma página solo publica códigos SMTP de tres dígitos: `"421 Too many concurrent SMTP connections"`, `"451 Temporary service failure"`, `"454 Throttling failure"`, `"530 Authentication required"`, `"535 Authentication Credentials Invalid"` y `"552 Message is too long."`
- **Restituido el 2026-09-18 con el volcado delante.** Una pasada anterior retiró el literal del «500» y los códigos `451`, `530` y `535` porque no constaban en el bloque [F16]: era lo que **E1** obliga a hacer con una cita sin registrar. Volcada la página, los seis códigos y las dos frases están ahí, así que se restituyen con su literal. El recorte no era del proveedor, era nuestro.
- **«Esa misma página» ya no es indecidible.** El bloque [F16] llevaba dos URL y no decía de cuál salía cada cita. Desglosado el 18-09, las dos frases de clase y los seis códigos están **en `troubleshoot-smtp.html` y solo ahí**; lo de [F47] es el puerto 25 de EC2. La contradicción es de una sola página, y ahora se puede demostrar.
- **Nota:** por contexto se deduce que habla de las clases 4xx y 5xx, pero el literal dice otra cosa y un sondeo no puede apoyarse en una deducción.
- **Efecto en la datasheet:** ninguno. Ningún campo guarda los códigos del canal SMTP.
- **Efecto declarado:** excluyente · campo sin valor

### DISC-14 · Qué significa `MessageRejected`

- **A —** [F10]: `"The message can't be sent because it contains invalid content."`
- **B —** [F32]: el rechazo **por identidad no verificada** llega como `MessageRejected` con `"Email address is not verified. The following identities failed the check in region..."`, que no es contenido inválido
- **Acotada y no cerrada (E5).** A está verificada verbatim contra el contrato máquina —forma `MessageRejected`, `"The message can't be sent because it contains invalid content."`, 400—, pero **A no es exhaustiva**: no dice «only», así que no excluye a B y **D11 no se activa**. `SendEmail` de la v2 lista ocho formas de error y ninguna cubre al **destinatario** sin verificar, porque `MailFromDomainNotVerifiedException` es del dominio remitente. Y la v1 glosa el mismo nombre mucho más ancho: `"MessageRejected — Indicates that the action failed, and the message could not be sent."` [F31].
- **Lo que falta, dicho para que nadie lo deduzca:** el emparejamiento nombre-mensaje del lado B queda **fuera de las comillas**, y no hay volcado de [F32] en `evidencias/`. Se resuelve releyendo la página y guardando el volcado, no interpretando la puntuación del registro.
- **Sin vía de medición desde esta cuenta, y el motivo está medido.** Haría falta un destinatario no verificado, que es justo el que IAM no autoriza: [E2] y [E3] enseñan que el permiso se evalúa sobre el ARN del destinatario. No es carril rojo, es una vía cerrada por construcción.
- **Efecto en la datasheet:** ninguno sobre el semáforo. Decide qué lectura espera un sondeo, y ese sondeo hoy no tiene camino.
- **Efecto declarado:** no excluyente, porque A no dice «only» · campo sin valor

### DISC-15 · Las plantillas almacenadas en la consola — **CERRADA**

- **A —** [F25]: la documentación **solo** describe el camino de API y de CLI para crear plantillas
- **B —** ninguna página oficial encontrada describe el camino de consola. *(La segunda mitad de este lado, «y una fuente de terceros afirma que existe», se retira por **E1**: era hit único del fichero, sin URL, sin fecha y sin literal. Sin ella el lado B es un hueco documental y no una fuente rival.)*
- **Cierre (E5, midiendo · 2026-09-18 · escalón 2, [F45]).** La consola **sí tiene** página de plantillas, `#/email-templates`, y es de solo listado. Lo dice ella misma: `"Para crear una plantilla de correo electrónico, utilice la operación de la API CreateEmailTemplate"` y `"Para ver el contenido de una plantilla de correo electrónico específica, utilice la operación GetEmailTemplate en la API de Amazon SES"`. **Manda el lado A:** para crear una plantilla hay que ir a la API, y el proveedor lo escribe en su propio panel.
- **Efecto en la datasheet:** toca el test C2, operación 2. `CreateEmailTemplate` existe en la API y **no** en la consola, así que ninguna de las tres operaciones del test es exclusiva de la web y el `type` no se mueve hacia `partial_saas` por esta vía. El 🟡 de `type` lo sostiene **D9**, no esta entrada.

### DISC-16 · Las regiones con endpoint SMTP — **CERRADA**

- **A —** [F7]: diez regiones **sin** endpoint SMTP, entre ellas Europa (Milán)
- **B —** el script oficial de derivación de credenciales de [F22] incluye `eu-south-1` (Milán) en su lista `SMTP_REGIONS`, y omite `us-west-1`, `ap-northeast-3` y `eu-west-3`. *(Este segundo tramo **no tiene literal registrado**: la cobertura de [F7] es un recuento —«29 regiones con endpoint `email.<region>.amazonaws.com`»— y no registra ni un código de región. Que no consten como listados no los desmiente: tampoco están entre las diez excluidas de `"SMTP endpoints are not currently available in Africa (Cape Town)…"`.)*
- **Nota:** el propio [F22] se cubre —`"the list of SMTP_REGIONS is simply an example"`—, pero el código lanza excepción para esas tres.
- **Cierre (E5, midiendo · 2026-10-18).** Los dos lados están archivados: `evidencias/paginas/gr_ses_2026-10-18.html` mantiene a Milán entre las diez sin SMTP y su tabla da endpoint a `us-west-1`, `ap-northeast-3` y `eu-west-3`; `evidencias/paginas/smtp-credentials_2026-10-18.html` mantiene el script con 15 regiones, `eu-south-1` dentro y esas tres fuera. Lo dirime la red: `email-smtp.eu-south-1.amazonaws.com` no resuelve, y las otras tres responden en el 587 con `220 email-smtp.amazonaws.com ESMTP SimpleEmailService`, sin autenticar ni enviar (`evidencias/probe_ses_smtp_regiones_2026-10-18.json`). **Manda el lado A** en los cuatro puntos. El script se equivoca en los dos sentidos, y su propia salvedad lo cubre.
- **Efecto en la datasheet:** ninguno. La disponibilidad de SMTP por región no tiene campo en v0.3.
- **Efecto declarado:** excluyente · campo sin valor

---

# Fuentes buscadas y NO encontradas

Lo que no está publicado es dato, y en SES el patrón tiene forma: **lo que falta es siempre
lo de fuera del sandbox**.

1. **La cuota de envío fuera del sandbox.** [F1] dice `"this number varies based on your specific use case."`, y [F9] publica la misma magnitud con otras palabras: `"The sending quota and maximum sending rate for your account vary based on your specific use case."` — **`vary`**, no `varies`, así que la atribución conjunta anterior no era literal de las dos. La única cifra es de un blog de 2014 (DISC-03).
2. **La tasa de envío fuera del sandbox.** Ídem. El `"10 messages per second"` de [F12] es un **ejemplo hipotético**, no un valor.
3. **El techo del producto.** No hay máximo publicado ni para cuota ni para tasa. Lo más cercano es el centinela `-1` = `"unlimited quota"` de [F8], sin condiciones publicadas para alcanzarlo.
4. **La fórmula del incremento automático.** Solo criterios cualitativos [F4]: ni porcentaje, ni escalón, ni periodo.
5. **El caudal por operación de la API v2.** La única cifra enumera **nombres de v1** [F1]; no hay tabla por operación de v2, ni ráfaga, ni cubo de fichas.
6. **El tope de `BulkEmailEntries` por llamada.** [F11] no publica `Array Members: Maximum`.
7. **El número de conexiones SMTP concurrentes.** Existe el error `421` [F16] y **ningún número**.
8. **El número máximo de adjuntos por mensaje.** Solo el tamaño total y `"MIME parts | 500"` [F1].
9. **Cualquier cuota de envío por identidad.** No existe: todo el eje de capacidad es cuenta × región.
10. **Diferencias numéricas reales entre regiones.** [F7] publica el mismo valor para todas; [F12] afirma que los concedidos difieren, **sin un solo ejemplo**.
11. **Si SES emite `x-amz-retry-after`.** Ni afirmado ni negado [F35]; el contrato máquina no declara **ninguna** cabecera [F33].
12. **La forma del cuerpo de error de v2.** La referencia no documenta el JSON del error ni el nombre de su campo de mensaje.
13. **Qué devuelve `SendBulkEmail` cuando el estrangulamiento afecta a la llamada entera**, frente a marcar entradas con `ACCOUNT_THROTTLED` [F30].
14. **El tamaño y la duración de la ráfaga permitida.** `"short bursts"` sin cifra [F3].
15. **El coste y la disponibilidad regional de VDM** [F27].
16. **Si Mail Manager sustituye a las *receipt rules* o convive con ellas.** Tres superficies de entrada —v1, Mail Manager y v2 sin ninguna— y ninguna página que las reconcilie.

---

## Precio y facturación

## [F39] Página de precios de Amazon SES

- **URL:** https://aws.amazon.com/ses/pricing/
- **Fecha de acceso:** 2026-09-18
- **Citas literales, y las dos primeras se contradicen a dos párrafos de distancia:**
  - `"Amazon Simple Email Service (SES) is a pay-as-you-go service based on the volume of emails sent and received. There are no contract negotiations and no upfront commitments."`
  - `"Amazon SES offers three pricing plans to choose from, each designed to match your email needs at every stage of growth."`
  - Tabla de planes, con tres tramos marginales por volumen mensual: `"0 – 10M emails / month"` → Essentials `"$0.16 per 1,000 emails"`, Pro `"$0.22 per 1,000 emails"`, Enterprise `"$0.23 per 1,000 emails"`; `"10 – 100M emails / month"` → `"$0.14"`, `"$0.17"`, `"$0.18"`; `"> 100M emails / month"` → `"$0.11"`, `"$0.12"`, `"$0.13"`
  - Cuota fija: `"Per account per region per month"` → Essentials `"-"`, Pro `"$105"`, Enterprise `"$500"`
  - `"Tiered rates are applied marginally — each rate applies only to the emails within that tier, not to your entire volume."`
  - À la carte: `"With Amazon SES à la carte pricing, you pay only for what you use with no minimum fees or mandatory service usage."` · `"Outbound email | $0.10 / 1,000 emails | $0.12 per GB of attachment data sent"`
  - Asignación automática: `"New SES accounts and account x region combinations with no metered SES activity since June 1, 2025 will start on the Essentials plan beginning July 21, 2026. You can upgrade or switch to à-la-carte pricing at any time."`
  - Add-ons: `"Dedicated IPs – Standard | $24.95 / month / IP"` · `"Dedicated IPs – Managed | $15 / month / account + per-email fee"` · `"Open / mTLS Ingress Endpoints | $50 / month / endpoint"` · VDM global `"$1,250 / month"` · `"Email Validation | $0.01 per validation"` · `"Tenants | $0.005 / month / tenant + $0.005 / 1,000 emails"`
  - Tarifa por correo de la IP administrada, registrada contra el volcado archivado [F46]: `"Per email fee: $0.08/1,1000 emails (0–10M emails per month), $0.04/1,000 emails (10–50M emails per month), $0.02/1,000 emails (50–100M emails per month), Contact us (>100M emails per month)"` — el `"1,1000"` es errata del proveedor y se cita tal cual *(ver DISC-20)*
  - Capa gratuita, sin mencionar la de SES: `"New AWS customers will receive up to $200 in AWS Free Tier credits... The free plan will be available for 6 months after account creation."`

## [F40] AWS Price List Bulk API — servicio `AmazonSES` *(tarifario máquina)*

- **URL:** https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonSES/current/index.json
- **Fecha de acceso:** 2026-09-18 · **Versión `20260911124507`**, `"publicationDate": "2026-09-11T12:45:07Z"`
- **Citas literales:**
  - La unidad real de cobro **es el destinatario**: SKU `P7V48X5R37626GSK`, `"Charged for each email sent to an external recipient"`, `"unit": "Count"`, `"USD 0.0001000000"`, `"Cost per recipient of SendEmail or SendRawEmail EUW1"`
  - Cuotas fijas de plan en Irlanda: `"$105.00 per Mo for Pro-Plan-Hours in EU (Ireland)"` · `"$500.00 per Mo for Enterprise-Plan-Hours in EU (Ireland)"`
  - Tramos por destinatario en Irlanda: Essentials `0.00016 / 0.00014 / 0.00011`; Pro `0.00022 / 0.00017 / 0.00012`; Enterprise `0.00023 / 0.00018 / 0.00013`
  - Estructura de tramo sin recargo ni techo: `beginRange`/`endRange` en `[0-10000000]`, `[10000000-100000000]`, `[100000000-Inf]`
  - Adjuntos `"GB USD 0.12"` · entrante `"USD 0.0001"` por mensaje y `"USD 0.00009"` por trozo de 256 KB · IP dedicada `"Mo USD 24.95"`
- **Lo que solo da el tarifario máquina:** el precio saliente à-la-carte es **idéntico en las 30 localizaciones**, `USD 0.0001000000` por destinatario, comprobado una a una *(ver DISC-20 para la única excepción del catálogo de tarifas)*.
- **Artefacto archivado (E8), 2026-10-18:** `evidencias/pricelist_AmazonSES_2026-10-18.json`, 2,7 MB, la **misma versión `20260911124507`**, así que no hay E3. Cada literal de esta entrada aparece en el fichero, y también los de DISC-19 y DISC-20.

## [F41] Blog de AWS — Introducing Amazon SES pricing plans

- **URL:** https://aws.amazon.com/blogs/messaging-and-targeting/introducing-amazon-simple-email-service-ses-pricing-plans/
- **Fecha de acceso:** 2026-09-18 · **Publicado el 21 JUL 2026**
- **Citas literales:**
  - `"Starting July 21, 2026, all new SES accounts begin on the Essentials plan. Returning customers who have not sent or processed email through SES since June 1, 2025 also begin on the Essentials plan."`
  - `"Customers who have sent or processed email through SES on or after June 1, 2025 remain on à-la-carte pricing and can switch to a plan anytime."`
  - `"As of July 21, 2026, the SES-specific free tier (3,000 email message charges per month for your first 12 months after first SES use) is no longer available for new customers."` *(ver DISC-18)*
  - `"Pick a plan, and the right capabilities are already included at up to 22% less than purchasing them individually."`

## [F42] Developer Guide — Pricing plans

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/pricing-plans.html
- **Fecha de acceso:** 2026-09-18
- **Citas literales:**
  - `"If you do not have a plan, you are on à la carte pricing (pay-per-use pricing for individual features)."`
  - `"Plans apply for each account and each AWS Region, so you manage your plan separately in each Region where you use Amazon SES."`
  - `"Upgrades take effect immediately when you submit the request."` · `"All other downgrades or cancellations take effect at the start of your next billing cycle."`
  - `"With Amazon Simple Email Service (SES) pricing plans, you get simpler billing, packaged features, and volume discounts."`

## [F43] FAQ de producto — §Pricing and Billing

- **URL:** https://aws.amazon.com/ses/faqs/
- **Fecha de acceso:** 2026-09-18 · **La página no publica fecha de revisión**, así que su literal no se puede fechar frente al del blog
- **Citas literales:**
  - `"New customers can send emails for free through Amazon SES using the AWS Free Tier."` · `"Receive up to 3,000 message charges for free each month for the first 12 months after you start using SES."` *(ver DISC-18)*
  - `"we do charge you for each message you send to the mailbox simulator, just as if they were messages you sent to actual customers"`
  - Sin tarifa publicada: `"To learn about pricing for Deliverability Expert Services, open a ticket with AWS Support..."`

## [F44] Blog de AWS — The Amazon SES Free Tier *(editorial, 2012, aún publicado)*

- **URL:** https://aws.amazon.com/blogs/messaging-and-targeting/the-amazon-ses-free-tier/
- **Fecha de acceso:** 2026-09-18 · **Publicado el 27 SEP 2012**
- **Cita literal:** `"You can send 2,000 messages per day for free if you use Amazon SES from Amazon EC2 (or via AWS Elastic Beanstalk)."`
- **Estatus de la fuente:** es la **única página viva de AWS** que sostiene la capa gratuita condicionada a EC2. Catorce años. Se cita para marcar el hueco, no como fuente vigente *(ver DISC-19)*.

## [F46] Volcado archivado de la página de precios — el comparador de planes

- **URL:** https://aws.amazon.com/ses/pricing/ — la misma de [F39]
- **Fecha de acceso:** 2026-09-18
- **Cómo se obtuvo:** descarga con `curl` de la página, que es HTML estático: la tabla del comparador viaja dentro del propio documento y no la monta ningún script.
- **Fichero:** `evidencias/paginas/2026-09-18/aws_amazon_com_ses_pricing.txt` · **18.842 bytes** · 18.715 caracteres · 520 líneas · sha256 `5beebe6ec88b108f14c4b46dff5b5d572cb961bdd0b9539d4f57a5ac908cd62b`
- **Por qué se abre como fuente propia.** [F39] es la misma URL leída el mismo día, pero sin
  artefacto detrás. Este es el **primer volcado archivado de SES**: con él las citas de precio
  se comprueban sin red, y por **E8** es además lo único que permitiría tumbar alguna.
- **El comparador `"Compare plans"`, fila a fila**, que es lo que faltaba para rellenar las
  tres columnas vacías de `features.md`:
  - `✓` en los tres planes: `"Outbound Email"` · `"Virtual Deliverability Manager - SES deliverability"` · `"Email Processing"` · `"Authenticated Ingress Endpoint"`
  - `Add-on` en Essentials y `✓` en Pro y Enterprise: `"Virtual Deliverability Manager - Global deliverability"` · `"Dedicated IPs - Managed"` · `"Email Validation"` · `"Email Add-Ons"`
  - `Add-on` en Essentials y Pro, `✓` en Enterprise: `"Global Endpoints"` · `"Tenants"` · `"Open Ingress Endpoint"`
  - `Add-on` en los tres: `"Dedicated IPs - Standard/BYOIP"` · `"Archiving"`
- **Volúmenes incluidos con precio de exceso**, en las notas al pie del comparador:
  - `"1,000 tenants included per account per region; $0.005/month/tenant for additional tenants."`
  - `"Pro plan includes 2,500 API validations/account/region/month and Enterprise plan includes 5,000 API validations/account/region/month; Extra API validations at $0.01/validation."`
  - `"Pro includes 1 domain, 1 DIPs and 5 seedlist tests; Enterprise includes 5 domains, 12 DIPs, and 25 seed list tests; Essentials plan customers pay $1,250 per month (includes 5 domains, 12 DIPs, and 25 seed list test)."`
  - `"Enterprise plan includes 1 Open Ingress Endpoint per account per region. Customers on Essentials and Pro plans pay additional $50 per endpoint per month for Open Ingress Endpoint."`
- **Los tramos marginales, con la segunda frase que [F39] no recogía:** `"Tiered rates are applied marginally — each rate applies only to the emails within that tier, not to your entire volume. Volume tiers apply independently to outbound emails sent and inbound emails processed via Mail Manager."` Son **dos escaleras independientes**, saliente y entrante, y el modelado tendría que expresar dos y no una.
- **Precios à la carte que faltaban, con su escalera propia:**
  - IP administrada: `"Per email fee: $0.08/1,1000 emails (0–10M emails per month), $0.04/1,000 emails (10–50M emails per month), $0.02/1,000 emails (50–100M emails per month), Contact us (>100M emails per month)"` — el `"1,1000"` es errata del proveedor y se cita tal cual *(ver DISC-20)*
  - VDM: `"Per email fee: $0.07/1,000 emails (0–10M emails per month), $0.05/1,000 emails (10–100M emails per month), $0.02/1,000 emails (>100M emails per month). Queries: $0.0005/1,000 queries (first 5K queries/month are free)"`
  - BYOIP: `"The minimum number of addresses you can bring is 256 which creates a minimum cost of $24.95 x 256 = $6,387.20 per month."`
- **El disparador del plan por defecto, fechado:** `"New SES accounts and account x region combinations with no metered SES activity since June 1, 2025 will start on the Essentials plan beginning July 21, 2026. You can upgrade or switch to à-la-carte pricing at any time."` Explica por qué esta cuenta sale en `ESSENTIALS` sin haberlo elegido [E1], y refuerza **F-31** con el par **cuenta × región** literal.
- **Lo que este volcado obliga a acotar, y es de `fricciones.md`:** **F-29** dice que SES no
  incluye volumen en ningún plan. Es cierto **solo para la dimensión de correos**. Las notas
  al pie publican volúmenes incluidos con precio de exceso para tenants, validaciones,
  dominios y endpoints, que es justo la forma cuota-incluida más `overage_cost` que v0.3 sí
  sabe expresar. El enunciado debe decir **«sin cuota de correos incluida»**. La fricción no
  cae —el precio por correo sigue sin campo—, pero su premisa estaba de más.

## [F47] Developer Guide — Connecting to an Amazon SES SMTP endpoint

- **URL:** https://docs.aws.amazon.com/ses/latest/dg/smtp-connect.html
- **Fecha de acceso:** 2026-09-18 · **Volcado:** `evidencias/paginas/2026-09-18/docs_aws_amazon_com_ses_latest_dg_smtp-connect.txt`
- **Citas literales:**
  - `"Amazon Elastic Compute Cloud (Amazon EC2) throttles email traffic over port 25 by default."`
- **Por qué nace hoy.** Sale de partir [F16], que llevaba dos URL sin decir qué cita venía de
  cuál. Releídas y volcadas las dos, esta página aporta **una sola** de las siete citas que
  compartían bloque: el tope del puerto 25. Las otras seis son de [F16].
- **Y el tope no es de SES.** Lo impone EC2 sobre el tráfico saliente de una instancia, así que
  acota la capacidad alcanzable sin ser un límite del producto de correo. No entra en
  `capacity` por **B3** y se queda aquí como contexto del canal.

---

### DISC-17 · ¿SES es pago por uso o tiene planes?

- **A —** [F39], primer párrafo, con la transcripción corregida —la fuente escribe el nombre completo (**E1**)—: `"Amazon Simple Email Service (SES) is a pay-as-you-go service based on the volume of emails sent and received. There are no contract negotiations and no upfront commitments."`
- **B —** [F39], dos párrafos después: `"Amazon SES offers three pricing plans to choose from"`, con cuota fija de `"$105"` y `"$500"` al mes por cuenta y región
- **Nota:** no es una contradicción que haya que arbitrar para modelar —las dos cosas conviven, y [F42] lo explica: `"If you do not have a plan, you are on à la carte pricing"`—, pero **sí tumba la premisa con la que esta API entró en el catálogo**, que era el pago por uso puro sin planes. Queda registrada porque el capítulo de selección se apoya en ella.
- **Y deja un hallazgo de esquema que ningún cierre debe borrar:** v0.3 tiene un solo contenedor, `plans`, y **ninguna forma de decir «modo de cobro»**. Un producto que vende por uso y por plan a la vez no cabe. Eso va al capítulo de evolución del esquema, no a un cierre de discrepancia.
- **Efecto en la datasheet:** los cuatro `plans[].price` siguen 🟢, porque los dos modos conviven y **D11 no aplica**. La premisa de selección es carril rojo del autor.
- **Efecto declarado:** no excluyente · los dos modos de cobro conviven · sin efecto sobre el color

### DISC-18 · La capa gratuita de SES: ¿viva o retirada?

- **A —** [F43], consultada hoy y en presente: `"Receive up to 3,000 message charges for free each month for the first 12 months after you start using SES."`
- **B —** [F41], con fecha y con el paréntesis que la entrada elidía (**D12**): `"As of July 21, 2026, the SES-specific free tier (3,000 email message charges per month for your first 12 months after first SES use) is no longer available for new customers."` El paréntesis es justo lo que prueba que A y B hablan de la misma magnitud.
- **C —** [F39] no menciona la capa gratuita **de SES**. Lo que registra es la de AWS: `"New AWS customers will receive up to $200 in AWS Free Tier credits... The free plan will be available for 6 months after account creation."` Otra magnitud y otra ventana.
- **Efecto en la datasheet:** decide si existe un plan gratuito que modelar. La lectura conservadora es que **no lo hay para una cuenta nueva**, y el motivo no es la recencia —cerrar por recencia es lo que E5 prohíbe—. Es que no se afirma un beneficio en disputa, y **A3 deja la capa gratuita fuera de `plans`** la diga viva quien la diga.
- **Efecto declarado:** excluyente · sin plan gratuito modelado por A3 · sin efecto sobre el color

### DISC-19 · El condicionante de EC2 en la capa gratuita

- **A —** [F44], 2012: `"2,000 messages per day for free if you use Amazon SES from Amazon EC2"`
- **B —** [F40], 2026: el único tramo gratuito con EC2 es `[0–62000]` y está atado al simulador —`"Monthly free outgoing emails from AmazonEC2 to Amazon SES Mailbox Simulator"`—, mientras que el envío real desde EC2 se cobra desde el primer correo, `USD 0.0001`.
- **La duda de trazabilidad (E1) quedó resuelta el 2026-10-18 con el fichero archivado.** El literal del simulador es el `groupDescription` del uso `Global-Recipients-MailboxSim-EC2`, con tramo `0`–`62000` a `0.0000000000`. `"Charged for each email sent from AmazonEC2 to an external recipient"` es la `description` de un producto aparte, con `"origin": "Amazon EC2"` y uso `Recipients-EC2`, a `0.0001` desde el primer destinatario. Aparece 31 veces, una por localización. No había inserción: son dos productos distintos.
- **Nota:** las dos cifras son la misma magnitud en ventanas distintas: 2.000 al día por 31 días dan 62.000 al mes, exacto.
- **Efecto en la datasheet:** ninguno. Una franquicia condicionada a EC2 no tiene campo en v0.3.
- **Cerrada por D17 (D-068, 2026-10-18).** En SES la página de precios incluye la Price List
  API, así que [F40] es el lado del pricing y gana: no hay franquicia gratuita para el envío real
  desde EC2, solo el tramo del simulador. Los 2.000 diarios del blog de 2012 [F44] quedan como
  **incoherencia del pricing**. **La salvedad de trazabilidad se levantó el 2026-10-18:** el
  `index.json` de la versión citada está archivado en `evidencias/` y contiene «AmazonEC2» y
  «62000» con los literales de B. El cierre ya descansa en un artefacto que se puede
  releer.
- **Efecto declarado:** excluyente · cerrada por D17 · campo sin valor

### DISC-20 · El precio de la IP administrada en Estocolmo

- **A —** [F40], 28 localizaciones: tramo `[100000000-Inf]` de `Recipients-DIP-Managed` a `USD 0.0000040000`
- **B —** [F40], **EU (Stockholm)**: `USD 0.0000400000`, diez veces más, en el **mismo fichero y la misma versión**
- **C —** [F39] no publica ese tramo. Su escalera de IP administrada, ahora con el literal entero archivado en [F46], termina en `"Contact us (>100M emails per month)"`, y la tarifa por correo del add-on se declara sin cifra: `"Dedicated IPs – Managed | $15 / month / account + per-email fee"`.
- **Nota:** es la **única divergencia de precio entre regiones** de todo el tarifario de SES. Un factor diez que solo aparece en el contrato máquina, y que la página de precios no puede desmentir porque ahí ese tramo no tiene cifra.
- **Confirmada contra el artefacto (E8), 2026-10-18.** El fichero archivado de [F40], versión `20260911124507`, da `EUN1-Recipients-DIP-Managed` en `[100000000-Inf]` a `0.0000400000`, frente a `0.0000040000` en las otras 28 localizaciones. Ojo: en Estocolmo el último tramo cuesta el doble que el anterior (`0.0000200000`), así que la escalera deja de bajar. Las dos citas aguantan y la divergencia es real, no un error de transcripción.
- **Efecto en la datasheet:** ninguno. Ningún campo depende de esta entrada.
- **Efecto declarado:** no excluyente · A y B son dos regiones distintas, y D11 no baja color por valores que conviven · campo sin valor
