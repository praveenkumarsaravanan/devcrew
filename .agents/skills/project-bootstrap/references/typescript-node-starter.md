# TypeScript Node Starter

Opinionated scaffold for server-side TypeScript/Node projects. Use this for Express, Fastify, NestJS, API routes, workers, scheduled jobs, and queue consumers. Ask the user which runtime style they want before scaffolding.

## Versions

- **Node:** 20+ LTS
- **TypeScript:** strict mode enabled
- **Package manager:** npm, pnpm, or yarn based on user preference
- **Validation:** Zod, Valibot, TypeBox, or the project's preferred runtime schema library
- **Logging:** pino, winston, OpenTelemetry-compatible logging, or project equivalent

## Runtime Options

| Option | Use when |
|--------|----------|
| Express or Fastify | Lightweight HTTP API or service |
| NestJS | Larger service with dependency injection and modules |
| Next.js / Remix server routes | Fullstack app with server-side API routes |
| Worker or queue consumer | Event-driven service or background processing |
| Scheduled job | Cron-style processing or batch work |

## Directory Structure

```text
+-- src/
|   +-- index.ts              # Runtime entrypoint
|   +-- app.ts                # App/server factory when HTTP is used
|   +-- config/
|   |   +-- env.ts            # Typed env validation; only process.env reader
|   +-- schemas/              # Runtime validation schemas
|   +-- routes/               # HTTP route registration
|   +-- controllers/          # Transport parsing and response mapping
|   +-- services/             # Business operations
|   +-- repositories/         # Database access
|   +-- clients/              # External service clients with timeouts
|   +-- workers/              # Queue consumers and event handlers
|   +-- jobs/                 # Scheduled jobs and batch processors
|   +-- observability/        # Logger, metrics, tracing
|   +-- errors/               # Structured domain/application errors
+-- tests/
|   +-- unit/
|   +-- integration/
|   +-- fixtures/
+-- package.json
+-- tsconfig.json
+-- Dockerfile
+-- .env.example
+-- .gitignore
+-- README.md
```

## `package.json` Baseline

```json
{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc -p tsconfig.json",
    "start": "node dist/index.js",
    "typecheck": "tsc -p tsconfig.json --noEmit",
    "lint": "eslint .",
    "test": "vitest run",
    "test:watch": "vitest",
    "audit": "npm audit"
  },
  "dependencies": {
    "zod": "^3.25.0",
    "pino": "^9.0.0"
  },
  "devDependencies": {
    "@types/node": "^22.0.0",
    "typescript": "^5.8.0",
    "tsx": "^4.0.0",
    "vitest": "^3.0.0",
    "eslint": "^9.0.0",
    "typescript-eslint": "^8.0.0"
  }
}
```

Add framework-specific dependencies only after choosing the runtime:

- Express: `express`, `@types/express`, `helmet`, `cors`, `supertest`.
- Fastify: `fastify`, `@fastify/helmet`, `@fastify/cors`.
- NestJS: `@nestjs/core`, `@nestjs/common`, `@nestjs/platform-express`.
- Queue workers: queue client, test doubles, and dead-letter tooling used by the platform.

## `tsconfig.json` Key Settings

```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "dist",
    "rootDir": "src",
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "skipLibCheck": true
  }
}
```

## Required Starter Patterns

- `src/config/env.ts` validates environment variables at startup and exports typed config.
- Runtime validation schemas exist for every HTTP route, worker payload, webhook, and external API response touched by the starter.
- HTTP apps export an app/server factory for integration tests.
- External clients set explicit timeouts and centralize retry behavior.
- Workers persist or check an idempotency key before side effects.
- Logger is configured with redaction for tokens, cookies, authorization headers, passwords, API keys, and PII.

## Test Setup

- **Unit:** service logic, schema parsing, error mapping, retry decision helpers.
- **Integration:** API routes with Supertest/Fastify inject/Nest testing module and realistic persistence where feasible.
- **Worker tests:** duplicate delivery, idempotency, retry exhaustion, dead-letter behavior.
- **Job tests:** empty input, partial failure, checkpoint/resume, overlap prevention.
- **Naming:** match project convention; default to `*.test.ts`.

## `.gitignore` Entries

```text
node_modules/
dist/
.env
coverage/
*.tsbuildinfo
.DS_Store
```
