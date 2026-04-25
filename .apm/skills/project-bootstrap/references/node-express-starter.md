# Node.js + Express / NestJS Starter

Opinionated scaffold for a Node.js backend service. Ask the user: **Express** (lightweight) or **NestJS** (batteries-included).

## Versions

- **Node:** 20+ (LTS)
- **TypeScript:** strict mode enabled
- **Package manager:** npm or pnpm

## Directory Structure — Express

```
├── src/
│   ├── index.ts              # Server bootstrap
│   ├── app.ts                # Express app factory, middleware
│   ├── routes/
│   │   └── health.route.ts
│   ├── controllers/          # Parse request, call service, send response
│   ├── services/             # Business logic
│   ├── middleware/            # Auth, error handler, request logger
│   ├── models/               # Prisma schema or TypeORM entities
│   ├── validators/           # Zod schemas for request validation
│   └── config/               # Env loading, constants
├── prisma/
│   └── schema.prisma
├── tests/
│   ├── unit/
│   └── integration/
├── package.json
├── tsconfig.json
├── Dockerfile
├── .env.example
├── .gitignore
└── README.md
```

## Directory Structure — NestJS

```
├── src/
│   ├── main.ts
│   ├── app.module.ts
│   └── modules/
│       └── health/
│           ├── health.controller.ts
│           ├── health.service.ts
│           └── health.module.ts
├── prisma/
│   └── schema.prisma
├── test/
│   ├── app.e2e-spec.ts
│   └── jest-e2e.json
├── package.json
├── tsconfig.json
├── nest-cli.json
├── Dockerfile
├── .env.example
├── .gitignore
└── README.md
```

## `package.json` Core Dependencies (Express variant)

```json
{
  "dependencies": {
    "express": "^4.21.1",
    "zod": "^3.23.8",
    "prisma": "^6.0.1",
    "@prisma/client": "^6.0.1",
    "helmet": "^8.0.0",
    "cors": "^2.8.5",
    "dotenv": "^16.4.7",
    "pino": "^9.5.0",
    "pino-pretty": "^13.0.0"
  },
  "devDependencies": {
    "typescript": "^5.6.3",
    "@types/express": "^5.0.0",
    "@types/node": "^22.10.1",
    "tsx": "^4.19.2",
    "jest": "^29.7.0",
    "ts-jest": "^29.2.5",
    "@types/jest": "^29.5.14",
    "supertest": "^7.0.0",
    "@types/supertest": "^6.0.2",
    "eslint": "^9.15.0",
    "@typescript-eslint/eslint-plugin": "^8.16.0",
    "@typescript-eslint/parser": "^8.16.0"
  }
}
```

## Configuration (`tsconfig.json` key settings)

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
    "skipLibCheck": true
  }
}
```

## Docker Setup

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npx prisma generate && npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

## Test Setup

- **Unit:** Jest + ts-jest for service-layer isolation
- **Integration:** Supertest against the Express/NestJS app with an in-memory SQLite or Testcontainers PostgreSQL
- **Naming:** `*.test.ts` for unit, `*.e2e-spec.ts` for e2e (NestJS convention)
- **Scripts:** `test` (jest), `test:e2e` (jest --config jest-e2e.json), `test:cov` (jest --coverage)

## `.gitignore` Entries

```
node_modules/
dist/
.env
coverage/
*.tsbuildinfo
.DS_Store
```
