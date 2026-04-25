# [FEATURE NAME] — API Endpoint Specification

## Problem Statement

[PLACEHOLDER: Describe the problem this endpoint solves and why it is needed now.]

## Scope

| In scope | Out of scope |
|----------|--------------|
| [PLACEHOLDER] | [PLACEHOLDER] |

## Endpoint Overview

| Field | Value |
|-------|-------|
| Method | `[GET / POST / PUT / PATCH / DELETE]` |
| Path | `/api/v[N]/[resource]` |
| Description | [PLACEHOLDER: One-sentence summary] |
| Idempotent | Yes / No |

## Authentication & Authorization

| Field | Value |
|-------|-------|
| Auth method | [PLACEHOLDER: Bearer token / API key / OAuth2 / None] |
| Required roles | [PLACEHOLDER: e.g., `admin`, `editor`, or "any authenticated user"] |
| Scopes (OAuth2) | [PLACEHOLDER: e.g., `read:resource`, `write:resource`] |

## Request Schema

### Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | Yes | `Bearer <token>` |
| `Content-Type` | Yes | `application/json` |
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| [PLACEHOLDER] | `string` | [PLACEHOLDER] |

### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| [PLACEHOLDER] | `string` | — | [PLACEHOLDER] |

### Request Body

```json
{
  "[field]": "[type] — [PLACEHOLDER: description]",
  "[field]": "[type] — [PLACEHOLDER: description]"
}
```

## Response Schemas

### Success Response

**Status:** `[200 / 201 / 204]`

```json
{
  "[field]": "[type] — [PLACEHOLDER: description]",
  "[field]": "[type] — [PLACEHOLDER: description]"
}
```

### Error Responses

| Status | Code | Message | Trigger |
|--------|------|---------|---------|
| 400 | `INVALID_REQUEST` | [PLACEHOLDER] | [PLACEHOLDER: validation failure] |
| 401 | `UNAUTHORIZED` | [PLACEHOLDER] | Missing or invalid token |
| 403 | `FORBIDDEN` | [PLACEHOLDER] | Insufficient permissions |
| 404 | `NOT_FOUND` | [PLACEHOLDER] | Resource does not exist |
| 429 | `RATE_LIMITED` | [PLACEHOLDER] | Exceeded rate limit |
| 500 | `INTERNAL_ERROR` | [PLACEHOLDER] | Unexpected server failure |

## Rate Limiting

| Field | Value |
|-------|-------|
| Limit | [PLACEHOLDER: e.g., 100 requests / minute] |
| Scope | [PLACEHOLDER: per-user / per-API-key / global] |
| Header | `X-RateLimit-Remaining` |

## Pagination *(if applicable)*

| Field | Value |
|-------|-------|
| Strategy | [PLACEHOLDER: cursor-based / offset-limit] |
| Default page size | [PLACEHOLDER: e.g., 20] |
| Max page size | [PLACEHOLDER: e.g., 100] |
| Cursor parameter | `?cursor=[opaque_token]` |

## Example Request / Response

### Request

```
[METHOD] /api/v1/[resource]/[id] HTTP/1.1
Host: [PLACEHOLDER]
Authorization: Bearer [PLACEHOLDER]
Content-Type: application/json

{
  "[field]": "[value]"
}
```

### Response

```
HTTP/1.1 [STATUS]
Content-Type: application/json

{
  "[field]": "[value]"
}
```

## Versioning Strategy

| Field | Value |
|-------|-------|
| Versioning scheme | [PLACEHOLDER: URL path (`/v1/`) / header (`Accept-Version`) / query param] |
| Current version | [PLACEHOLDER: e.g., v1] |
| Deprecation policy | [PLACEHOLDER: e.g., 6-month sunset after next major version] |

## Requirements

| ID | Description | Acceptance Criteria | Priority |
|----|-------------|---------------------|----------|
| REQ-001 | [PLACEHOLDER] | [PLACEHOLDER] | Must |

## Dependencies

| Dependency | Type | Status | Owner |
|------------|------|--------|-------|
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

## Handoff Checklist

- [ ] Spec reviewed and approved
- [ ] Request/response schemas validated with consuming teams
- [ ] Auth requirements confirmed with security team
- [ ] Rate limits agreed with platform team
- [ ] Open questions resolved
