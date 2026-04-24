---
name: api-design
description: >
  REST and gRPC API design guidance for backend services. Use when designing new
  endpoints, reviewing API contracts, creating OpenAPI specs, or evaluating API
  versioning strategies.
---

# API Design

## Trigger

Activate this skill when the user:

- Is designing a new REST or gRPC endpoint
- Asks for API contract review or feedback on endpoint design
- Needs to create or update an OpenAPI / Swagger specification
- Wants guidance on API versioning, pagination, or error format
- Is modeling resources and choosing HTTP methods or gRPC service definitions

## Workflow

### 1. Understand the Domain

- Ask what resource(s) the API will expose and what operations callers need.
- Identify the consumers: is this a public API, internal microservice boundary, or BFF (backend-for-frontend)?
- Determine the transport: REST (HTTP/JSON), gRPC (protobuf), or both.

### 2. Define the Resource Model

- Name resources as **plural nouns** (e.g., `/users`, `/orders`, `/invoices`).
- Use kebab-case for multi-word resource names (e.g., `/line-items`, `/payment-methods`).
- Model relationships via nesting only for strong ownership (`/users/{id}/addresses`). Use top-level resources with filters for loose associations.
- Identify sub-resources vs. independent resources. A sub-resource's lifecycle is bound to its parent.

### 3. Choose HTTP Methods

Map operations to standard HTTP methods:

| Operation | Method | Example | Success Code |
|-----------|--------|---------|--------------|
| List | GET | `GET /users` | 200 |
| Get one | GET | `GET /users/{id}` | 200 |
| Create | POST | `POST /users` | 201 |
| Full replace | PUT | `PUT /users/{id}` | 200 |
| Partial update | PATCH | `PATCH /users/{id}` | 200 |
| Delete | DELETE | `DELETE /users/{id}` | 204 |

For non-CRUD actions, use a verb sub-resource: `POST /orders/{id}/cancel`.

### 4. Design Request and Response Schemas

**Requests:**
- Define required vs. optional fields explicitly.
- Use strong types: enums for fixed sets, ISO 8601 for dates, UUIDs for identifiers.
- Validate all input at the boundary — reject invalid requests with 400 or 422.

**Responses:**
- Wrap single resources in a consistent envelope or return them directly — pick one style and stick with it.
- Use camelCase for JSON field names.
- Include `id`, `createdAt`, and `updatedAt` on all mutable resources.
- Omit internal-only fields (database IDs, internal flags) from public APIs.

**Example response:**

```json
{
  "id": "usr_a1b2c3",
  "email": "user@example.com",
  "displayName": "Jane Doe",
  "role": "admin",
  "createdAt": "2025-03-15T10:30:00Z",
  "updatedAt": "2025-06-01T14:22:00Z"
}
```

### 5. Add Validation

- Validate request body fields: type, format, length, range.
- Validate path parameters: format (UUID, slug) and existence (return 404 if not found).
- Validate query parameters: allowed values, defaults, maximum page size.
- Return a structured error on validation failure:

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Request validation failed",
  "details": [
    { "field": "email", "issue": "must be a valid email address" },
    { "field": "role", "issue": "must be one of: admin, member, viewer" }
  ]
}
```

### 6. Implement Pagination

All list endpoints **must** support pagination.

**Cursor-based (preferred for most cases):**

```
GET /users?limit=20&cursor=eyJpZCI6MTAwfQ
```

Response includes a `nextCursor` field. Clients pass it as `cursor` on the next request. Advantages: stable under concurrent writes, efficient on indexed columns.

**Offset-based (use only when random page access is required):**

```
GET /users?limit=20&offset=40
```

Response includes `total` count. Disadvantage: unstable when data changes between pages.

Include pagination metadata in the response:

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

### 7. Define the Error Format

Use a consistent error response across all endpoints:

```json
{
  "code": "NOT_FOUND",
  "message": "User with ID usr_xyz not found",
  "requestId": "req_abc123"
}
```

- `code`: machine-readable error code (UPPER_SNAKE_CASE).
- `message`: human-readable explanation.
- `requestId`: correlation ID for tracing (propagated from the `X-Request-Id` header or generated).
- `details` (optional): array of field-level errors for validation failures.

Map error codes to HTTP status codes consistently. See the REST conventions reference for the full mapping.

### 8. Plan Versioning

Choose a versioning strategy before the first release:

- **URL path versioning** (`/v1/users`): simple, visible, easy to route. Preferred for public APIs.
- **Header versioning** (`Accept: application/vnd.myapi.v2+json`): keeps URLs clean. Better for internal APIs with controlled clients.

Rules:
- Additive changes (new optional fields, new endpoints) do **not** require a new version.
- Breaking changes (removed fields, changed types, changed semantics) **require** a new version.
- Support the previous version for at least 6 months after deprecation notice.

### 9. gRPC-Specific Guidance

When designing gRPC APIs:

- Use `service` and `rpc` definitions that mirror the REST resource model.
- Follow the [Google API Design Guide](https://cloud.google.com/apis/design) naming conventions.
- Use `google.protobuf.FieldMask` for partial updates.
- Define standard `List`, `Get`, `Create`, `Update`, `Delete` methods per resource.
- Use `google.rpc.Status` for error responses with detail types.
- Define pagination with `page_size` and `page_token` fields.

### 10. Document with OpenAPI

- Write an OpenAPI 3.x spec for every REST API.
- Include descriptions for every endpoint, parameter, and schema.
- Add examples for request and response bodies.
- Define reusable components for common schemas (pagination, error response, standard headers).
- Validate the spec with a linter (e.g., Spectral, `redocly lint`).

## Guardrails

- **Always use plural nouns for resource collections.** `/user` is wrong; `/users` is correct.
- **Require pagination on all list endpoints.** Never return unbounded collections.
- **Use standard HTTP status codes.** Do not invent custom codes or overload 200 for errors.
- **Include request IDs.** Every response must include a `requestId` for tracing.
- **Do not expose internal identifiers.** Use external-facing IDs (prefixed UUIDs, slugs) instead of auto-increment database IDs.
- **Validate at the boundary.** Never trust input from clients — validate in the handler before business logic.
- **Be consistent.** Field naming, error format, pagination style, and envelope structure must be uniform across all endpoints.

## See Also

- **`team-workflow`** — When ready to implement the API, the team workflow handles the full build lifecycle (requirements through testing). The architect phase (Phase 2) consumes the API design produced here.
- **`code-review`** — After implementation, this skill reviews the code against quality, security, and API design standards.
- **`documentation`** — Use this skill to write user-facing API documentation or an OpenAPI reference guide.

## References

- [REST Conventions](references/rest-conventions.md) — detailed URL patterns, status codes, error formats, pagination, and versioning reference
