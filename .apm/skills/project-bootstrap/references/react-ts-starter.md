# React + TypeScript Starter

Opinionated scaffold for a React frontend application with TypeScript.

## Setup Choice

Ask the user: **Vite** (SPA) or **Next.js** (SSR/SSG). Default to Vite for pure SPAs.

- **React:** 18+
- **TypeScript:** strict mode enabled
- **Node:** 20+ (LTS)

## Directory Structure

```
├── public/
├── src/
│   ├── components/
│   │   └── ui/              # Shared design-system primitives
│   ├── pages/               # Route-level components
│   ├── hooks/               # Custom React hooks
│   ├── utils/               # Pure helper functions
│   ├── types/               # Shared TypeScript types/interfaces
│   ├── services/            # API client modules
│   ├── styles/              # Global styles, Tailwind config
│   ├── App.tsx
│   └── main.tsx
├── tests/
│   ├── unit/
│   └── e2e/
├── package.json
├── tsconfig.json
├── vite.config.ts           # or next.config.ts
├── tailwind.config.ts
├── .eslintrc.cjs
├── .prettierrc
├── playwright.config.ts
├── .gitignore
└── README.md
```

## `package.json` Core Dependencies

```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.28.0"
  },
  "devDependencies": {
    "typescript": "^5.6.3",
    "tailwindcss": "^3.4.15",
    "postcss": "^8.4.49",
    "autoprefixer": "^10.4.20",
    "vite": "^6.0.1",
    "@vitejs/plugin-react": "^4.3.4",
    "eslint": "^9.15.0",
    "@typescript-eslint/eslint-plugin": "^8.16.0",
    "@typescript-eslint/parser": "^8.16.0",
    "prettier": "^3.4.1",
    "vitest": "^2.1.6",
    "@testing-library/react": "^16.1.0",
    "@testing-library/jest-dom": "^6.6.3",
    "@testing-library/user-event": "^14.5.2",
    "jsdom": "^25.0.1",
    "@playwright/test": "^1.49.0"
  }
}
```

## Configuration Files

### `tsconfig.json` (key settings)

```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "baseUrl": ".",
    "paths": { "@/*": ["src/*"] },
    "noUncheckedIndexedAccess": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

### `.prettierrc`

```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2
}
```

## Component Patterns

- **Functional components only** — no class components
- **Custom hooks** for reusable stateful logic (prefix with `use`)
- **Error boundaries** wrapping route-level components
- **Co-locate** component-specific styles and tests beside the component

## Test Setup

- **Unit/component:** Vitest + Testing Library — test behavior, not implementation
- **End-to-end:** Playwright — critical user flows
- **Naming:** `*.test.tsx` for unit, `*.spec.ts` for e2e
- **Scripts:** `test` (vitest), `test:e2e` (playwright), `test:coverage` (vitest --coverage)

## `.gitignore` Entries

```
node_modules/
dist/
.next/
.env
.env.local
*.tsbuildinfo
coverage/
test-results/
playwright-report/
.DS_Store
```
