# Go Starter

Opinionated scaffold for a Go backend service.

## Versions

- **Go:** 1.22+
- **Module:** `github.com/<org>/<project>`

## Directory Structure

```
├── cmd/
│   └── server/
│       └── main.go          # Entrypoint — wires dependencies and starts server
├── internal/
│   ├── handler/             # HTTP handlers (thin — parse request, call service, write response)
│   ├── service/             # Business logic
│   ├── repository/          # Database access (pgx queries)
│   ├── model/               # Domain types
│   ├── middleware/           # Auth, logging, recovery, CORS
│   └── config/              # Env-based config loading
├── pkg/                     # Importable library code (use sparingly)
├── api/
│   └── openapi.yaml         # OpenAPI spec (source of truth for endpoints)
├── configs/
│   ├── dev.env
│   └── prod.env
├── migrations/              # SQL migration files
├── scripts/
│   └── seed.sh
├── Makefile
├── Dockerfile
├── go.mod
├── go.sum
├── .gitignore
└── README.md
```

## Key Dependencies

```go
// go.mod
require (
    github.com/go-chi/chi/v5   v5.1.0    // HTTP router
    github.com/jackc/pgx/v5    v5.7.1    // PostgreSQL driver
    go.uber.org/zap            v1.27.0   // Structured logging
    github.com/caarlos0/env/v11 v11.2.2  // Config from env vars
)

// Test dependencies
require (
    github.com/stretchr/testify v1.9.0
    github.com/testcontainers/testcontainers-go v0.34.0
)
```

## Makefile Targets

```makefile
APP_NAME := server
BUILD_DIR := bin

.PHONY: build test lint run docker-build clean

build:
	go build -o $(BUILD_DIR)/$(APP_NAME) ./cmd/server

run:
	go run ./cmd/server

test:
	go test ./... -race -cover

lint:
	golangci-lint run ./...

docker-build:
	docker build -t $(APP_NAME) .

clean:
	rm -rf $(BUILD_DIR)
```

## Error Handling

- Define domain errors in `internal/model/errors.go` using `errors.New` / custom types
- Wrap with `fmt.Errorf("operation: %w", err)` to preserve the chain
- Map domain errors to HTTP status codes in handlers, not in services
- Never silently discard errors — log or return them

## Test Setup

- **Table-driven tests** as the default pattern
- **testify** for assertions and mocks
- **httptest** for handler-level tests
- **Testcontainers** for integration tests against a real PostgreSQL instance
- **Naming:** `*_test.go` in the same package (white-box) or `_test` package (black-box)
- **Build tag:** `//go:build integration` to separate slow tests

## `.gitignore` Entries

```
bin/
*.exe
*.test
*.out
.env
vendor/
coverage.out
tmp/
.DS_Store
```
