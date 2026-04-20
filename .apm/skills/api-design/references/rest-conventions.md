# REST API Conventions Reference

Canonical reference for REST API design across backend services.

---

## URL Naming Conventions

### Rules

1. Use **plural nouns** for collections: `/users`, `/orders`, `/invoices`
2. Use **kebab-case** for multi-word names: `/payment-methods`, `/line-items`
3. Use **path parameters** for resource identity: `/users/{userId}`
4. Use **query parameters** for filtering, sorting, pagination: `/users?role=admin&sort=createdAt`
5. Nest sub-resources only for strong ownership: `/users/{userId}/addresses/{addressId}`
6. Use verb sub-resources for non-CRUD actions: `POST /orders/{orderId}/cancel`
7. Keep URLs lowercase — never use camelCase or PascalCase in paths

### Examples

| Good | Bad | Why |
|------|-----|-----|
| `GET /users` | `GET /user` | Collections are plural |
| `GET /payment-methods` | `GET /paymentMethods` | Kebab-case in URLs |
| `POST /orders/{id}/cancel` | `POST /cancelOrder/{id}` | Verb as sub-resource |
| `GET /users?status=active` | `GET /users/active` | Filter via query param |
| `GET /users/{id}/orders` | `GET /getUserOrders/{id}` | RESTful nesting |

---

## HTTP Method Semantics

### GET — Read

- **Safe**: no side effects.
- **Idempotent**: multiple identical requests yield the same result.
- Never use GET to modify state.
- Request body should be empty (ignored by most servers).

### POST — Create

- **Not idempotent**: each call may create a new resource.
- Returns **201 Created** with the created resource and a `Location` header.
- Use for actions that don't map to CRUD: `POST /reports/generate`.

### PUT — Full Replace

- **Idempotent**: sending the same PUT repeatedly has the same effect.
- Client sends the **complete** resource representation.
- Missing fields are set to null/default — this is intentional.
- Returns **200 OK** with the updated resource.

### PATCH — Partial Update

- **Not necessarily idempotent** (depends on the patch format).
- Client sends **only the fields to change**.
- Use JSON Merge Patch (`application/merge-patch+json`) or JSON Patch (`application/json-patch+json`).
- Returns **200 OK** with the full updated resource.

### DELETE — Remove

- **Idempotent**: deleting an already-deleted resource returns 204 or 404 (pick one convention).
- Returns **204 No Content** on success (no body).
- For soft-delete, consider `PATCH /users/{id}` with `{"status": "archived"}` instead.

---

## Status Code Guide

### Success (2xx)

| Code | Name | When to Use |
|------|------|-------------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST that creates a resource |
| 204 | No Content | Successful DELETE, or PUT/PATCH with no response body |

### Client Errors (4xx)

| Code | Name | When to Use |
|------|------|-------------|
| 400 | Bad Request | Malformed request syntax, invalid JSON |
| 401 | Unauthorized | Missing or invalid authentication credentials |
| 403 | Forbidden | Authenticated but lacks permission for this resource/action |
| 404 | Not Found | Resource does not exist at this URL |
| 409 | Conflict | State conflict (duplicate creation, concurrent edit, version mismatch) |
| 422 | Unprocessable Entity | Well-formed request but semantic validation failed (invalid field values) |
| 429 | Too Many Requests | Rate limit exceeded — include `Retry-After` header |

### Server Errors (5xx)

| Code | Name | When to Use |
|------|------|-------------|
| 500 | Internal Server Error | Unhandled exception — never intentionally return this |
| 502 | Bad Gateway | Upstream service returned an invalid response |
| 503 | Service Unavailable | Maintenance or overloaded — include `Retry-After` header |
| 504 | Gateway Timeout | Upstream service timed out |

### Decision Tree

```
Is the request malformed (bad JSON, wrong content type)?
  → 400 Bad Request

Is the caller unauthenticated?
  → 401 Unauthorized

Is the caller authenticated but not authorized?
  → 403 Forbidden

Does the target resource not exist?
  → 404 Not Found

Is there a business rule or validation violation?
  → 422 Unprocessable Entity

Is there a state conflict (duplicate, version mismatch)?
  → 409 Conflict

Was a rate limit exceeded?
  → 429 Too Many Requests

Did something unexpected break on the server?
  → 500 Internal Server Error
```

---

## Standard Error Response Format

All error responses use this JSON structure:

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Request validation failed",
  "requestId": "req_a1b2c3d4",
  "details": [
    {
      "field": "email",
      "issue": "must be a valid email address"
    },
    {
      "field": "age",
      "issue": "must be between 0 and 150"
    }
  ]
}
```

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `code` | string | Yes | Machine-readable error code in UPPER_SNAKE_CASE |
| `message` | string | Yes | Human-readable summary of the error |
| `requestId` | string | Yes | Correlation ID for tracing and support |
| `details` | array | No | Field-level errors for validation failures |

### Standard Error Codes

| Code | HTTP Status | Meaning |
|------|-------------|---------|
| `BAD_REQUEST` | 400 | Malformed request |
| `UNAUTHORIZED` | 401 | Missing or invalid credentials |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource does not exist |
| `CONFLICT` | 409 | State conflict |
| `VALIDATION_ERROR` | 422 | Input validation failed |
| `RATE_LIMITED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Unexpected server error |

---

## Pagination Patterns

### Cursor-Based (Preferred)

Best for feeds, timelines, and any list where data changes frequently.

**Request:**
```
GET /users?limit=20&cursor=eyJpZCI6MTAwfQ
```

**Response:**
```json
{
  "data": [...],
  "pagination": {
    "limit": 20,
    "nextCursor": "eyJpZCI6MTIwfQ",
    "hasMore": true
  }
}
```

**Rules:**
- `cursor` is an opaque, base64-encoded token. Clients must not parse it.
- `limit` has a default (e.g., 20) and a maximum (e.g., 100).
- `hasMore` indicates whether more pages exist.
- Omit `nextCursor` when `hasMore` is false.

**Advantages:**
- Stable under concurrent inserts and deletes
- Efficient with indexed columns (no OFFSET scan)

### Offset-Based

Use only when clients need random page access (e.g., "jump to page 5").

**Request:**
```
GET /users?limit=20&offset=40
```

**Response:**
```json
{
  "data": [...],
  "pagination": {
    "limit": 20,
    "offset": 40,
    "total": 253
  }
}
```

**Disadvantages:**
- Rows can be skipped or duplicated when data changes between pages
- Performance degrades with large offsets (database scans past skipped rows)

---

## Versioning Strategies

### URL Path Versioning (Recommended for Public APIs)

```
GET /v1/users
GET /v2/users
```

- Simple, explicit, easy to route at the load balancer level.
- Downside: URL changes when version bumps, breaking bookmarks.

### Header Versioning (Recommended for Internal APIs)

```
GET /users
Accept: application/vnd.myapi.v2+json
```

- Keeps URLs clean and stable.
- Downside: harder to test casually (can't just change the URL in a browser).

### What Counts as a Breaking Change

| Breaking (new version required) | Non-breaking (same version) |
|---------------------------------|-----------------------------|
| Removing a field from response | Adding a new optional field |
| Renaming a field | Adding a new endpoint |
| Changing a field's type | Adding a new query parameter |
| Changing endpoint URL structure | Adding a new enum value |
| Making an optional field required | Relaxing a validation constraint |

### Deprecation Policy

1. Announce deprecation with `Deprecation` and `Sunset` headers.
2. Support the old version for at least 6 months.
3. Log usage of deprecated versions to track migration progress.
4. Communicate timeline via changelog, API docs, and direct notification.

---

## Rate Limiting Headers

Include these headers on **every** response (not just 429s):

| Header | Description | Example |
|--------|-------------|---------|
| `X-RateLimit-Limit` | Max requests allowed in the window | `1000` |
| `X-RateLimit-Remaining` | Requests remaining in current window | `742` |
| `X-RateLimit-Reset` | Unix timestamp when the window resets | `1719500400` |
| `Retry-After` | Seconds to wait (on 429 responses only) | `30` |

### Rate Limit Response

```
HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1719500400
Retry-After: 30

{
  "code": "RATE_LIMITED",
  "message": "Rate limit exceeded. Retry after 30 seconds.",
  "requestId": "req_xyz789"
}
```

---

## Standard Request Headers

| Header | Purpose | Example |
|--------|---------|---------|
| `X-Request-Id` | Client-provided correlation ID (server generates if absent) | `req_a1b2c3` |
| `Authorization` | Bearer token or API key | `Bearer eyJ...` |
| `Content-Type` | Request body format | `application/json` |
| `Accept` | Desired response format | `application/json` |
| `Idempotency-Key` | Prevent duplicate POST operations | `idem_xyz123` |

## Standard Response Headers

| Header | Purpose | Example |
|--------|---------|---------|
| `X-Request-Id` | Echo or generate correlation ID | `req_a1b2c3` |
| `Location` | URL of created resource (on 201) | `/v1/users/usr_abc` |
| `Content-Type` | Response body format | `application/json` |
| `Cache-Control` | Caching directives | `no-store` |
