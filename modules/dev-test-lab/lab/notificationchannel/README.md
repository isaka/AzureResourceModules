# DevTest Lab Notification Channels `[Microsoft.DevTestLab/labs/notificationchannels]`

This module deploys a DevTest Lab Notification Channel.

Notification channels are used by the schedule resource type in order to send notifications or events to email addresses and/or webhooks.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.DevTestLab/labs/notificationchannels` | [2018-09-15](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DevTestLab/2018-09-15/labs/notificationchannels) |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`events`](#parameter-events) | array | The list of event for which this notification is enabled. |
| [`name`](#parameter-name) | string | The name of the notification channel. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`emailRecipient`](#parameter-emailrecipient) | string | The email recipient to send notifications to (can be a list of semi-colon separated email addresses). Required if "webHookUrl" is empty. |
| [`labName`](#parameter-labname) | string | The name of the parent lab. Required if the template is used in a standalone deployment. |
| [`webHookUrl`](#parameter-webhookurl) | string | The webhook URL to which the notification will be sent. Required if "emailRecipient" is empty. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`description`](#parameter-description) | string | Description of notification. |
| [`enableDefaultTelemetry`](#parameter-enabledefaulttelemetry) | bool | Enable telemetry via a Globally Unique Identifier (GUID). |
| [`notificationLocale`](#parameter-notificationlocale) | string | The locale to use when sending a notification (fallback for unsupported languages is EN). |
| [`tags`](#parameter-tags) | object | Tags of the resource. |

### Parameter: `description`

Description of notification.
- Required: No
- Type: string
- Default: `''`

### Parameter: `emailRecipient`

The email recipient to send notifications to (can be a list of semi-colon separated email addresses). Required if "webHookUrl" is empty.
- Required: No
- Type: string
- Default: `''`

### Parameter: `enableDefaultTelemetry`

Enable telemetry via a Globally Unique Identifier (GUID).
- Required: No
- Type: bool
- Default: `True`

### Parameter: `events`

The list of event for which this notification is enabled.
- Required: No
- Type: array
- Default: `[]`

### Parameter: `labName`

The name of the parent lab. Required if the template is used in a standalone deployment.
- Required: Yes
- Type: string

### Parameter: `name`

The name of the notification channel.
- Required: Yes
- Type: string
- Allowed: `[autoShutdown, costThreshold]`

### Parameter: `notificationLocale`

The locale to use when sending a notification (fallback for unsupported languages is EN).
- Required: No
- Type: string
- Default: `'en'`

### Parameter: `tags`

Tags of the resource.
- Required: No
- Type: object
- Default: `{object}`

### Parameter: `webHookUrl`

The webhook URL to which the notification will be sent. Required if "emailRecipient" is empty.
- Required: No
- Type: string
- Default: `''`


## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the notification channel. |
| `resourceGroupName` | string | The name of the resource group the notification channel was created in. |
| `resourceId` | string | The resource ID of the notification channel. |

## Cross-referenced modules

_None_
