# Enterprise PII Guardrails - REST API Reference Specification (v2.0.4)

The **Enterprise PII Guardrail Studio** exposes an ultra-low-latency RESTful API designed for seamless integration into high-throughput LLM pipelines, microservices, and workflow orchestrators (e.g. LangChain, LlamaIndex, n8n, Airflow).

---

## 🔐 Authentication

All runtime endpoints (`/mask`, `/unmask`) require a valid API Key passed via the `X-API-Key` HTTP header.

```http
X-API-Key: sk-live-your-enterprise-key-here
```

API keys can be generated and managed directly via the **Settings > Secure API Keys** tab in the web dashboard or programmatically via administrative endpoints.

---

## 1. Core Endpoints

### `POST /mask`
Detects and scrubs configured Personally Identifiable Information (PII) from the supplied prompt, replacing detected values with deterministic, reversible tokens.

#### Request Headers
| Header | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `Content-Type` | `string` | **Yes** | Must be `application/json` |
| `X-API-Key` | `string` | **Yes** | Your active API Key |

#### Request Body
```json
{
  "text": "Hello Dr. Martinez, patient John Doe (SSN: 123-45-6789, DOB: 04/12/1982) was admitted to St. Jude Memorial. Contact him at john.doe@email.com or +1 (555) 234-5678. Transaction billed $450.00 to Visa card 4532-7589-2341-9012."
}
```

#### Response (`200 OK`)
```json
{
  "masked_text": "Hello Dr. Martinez, patient <PERSON_1> (SSN: <SSN_1>, DOB: <DATE_OF_BIRTH_1>) was admitted to St. Jude Memorial. Contact him at <EMAIL_1> or <PHONE_1>. Transaction billed $450.00 to Visa card <CREDIT_CARD_1>.",
  "mapping": {
    "<PERSON_1>": "John Doe",
    "<SSN_1>": "123-45-6789",
    "<DATE_OF_BIRTH_1>": "04/12/1982",
    "<EMAIL_1>": "john.doe@email.com",
    "<PHONE_1>": "+1 (555) 234-5678",
    "<CREDIT_CARD_1>": "4532-7589-2341-9012"
  },
  "interception_counts": {
    "PERSON": 1,
    "SSN": 1,
    "DATE_OF_BIRTH": 1,
    "EMAIL": 1,
    "PHONE": 1,
    "CREDIT_CARD": 1
  }
}
```

---

### `POST /unmask`
Restores placeholder tokens in the LLM's response back to their original entity values for authorized consumers.

#### Request Body
```json
{
  "text": "We verified patient <PERSON_1> (SSN: <SSN_1>). Notification sent to <EMAIL_1>.",
  "mapping": {
    "<PERSON_1>": "John Doe",
    "<SSN_1>": "123-45-6789",
    "<EMAIL_1>": "john.doe@email.com"
  }
}
```

#### Response (`200 OK`)
```json
{
  "unmasked_text": "We verified patient John Doe (SSN: 123-45-6789). Notification sent to john.doe@email.com."
}
```

---

### `GET /health`
Liveness and readiness probe for load balancers (Kubernetes, AWS ALB, Nginx).

#### Response (`200 OK`)
```json
{
  "status": "ok"
}
```

---

## 2. Administrative Endpoints

### `POST /api/login`
Authenticates an administrator and returns a session token.

#### Request Body
```json
{
  "username": "admin",
  "password": "YourSecurePassword"
}
```

#### Response (`200 OK`)
```json
{
  "token": "4f67c00e-2708-4ba2-a279-88062ec71556",
  "role": "admin",
  "username": "admin"
}
```

---

### `GET /api/keys`
Lists all active, expired, and revoked API access keys. Requires administrative bearer token.

#### Response (`200 OK`)
```json
{
  "keys": [
    {
      "key": "sk-7a91...",
      "owner": "Production EMR Pipeline",
      "is_active": true,
      "expires_at": null,
      "requests_count": 48120,
      "rate_limit_per_minute": 0
    }
  ],
  "global_limit": "Unlimited"
}
```

---

## 3. Error Codes & Payloads

| Status Code | Reason | Description |
| :---: | :--- | :--- |
| `400 Bad Request` | `Payload too large` | Request exceeds configured `MAX_PAYLOAD_LENGTH`. |
| `403 Forbidden` | `Missing or invalid API Key` | The `X-API-Key` header was omitted, expired, or revoked. |
| `403 Forbidden` | `Threat Intercepted` | Client IP or payload domain/email matches an active Threat Intelligence IoC rule. |
| `429 Too Many Requests` | `Rate limit exceeded` | Per-minute request quota for the key or license tier was exceeded. |
| `500 Internal Error` | `Processing error` | Server error during regex compilation or NLP evaluation. |
