# Python + FastAPI Starter

Opinionated scaffold for a Python backend service using FastAPI.

## Versions

- **Python:** 3.12+
- **Dependency management:** `pyproject.toml` with **uv** (preferred) or Poetry
- **ASGI server:** Uvicorn

## Directory Structure

```
├── app/
│   ├── __init__.py
│   ├── main.py               # FastAPI app factory, lifespan, middleware
│   ├── api/
│   │   ├── __init__.py
│   │   ├── deps.py           # Shared dependencies (DB session, current user)
│   │   └── v1/
│   │       ├── __init__.py
│   │       └── routes/
│   │           └── health.py
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py         # pydantic-settings based config
│   │   ├── security.py       # Auth helpers
│   │   └── database.py       # SQLAlchemy engine + session factory
│   ├── models/               # SQLAlchemy ORM models
│   │   └── __init__.py
│   ├── schemas/              # Pydantic request/response schemas
│   │   └── __init__.py
│   └── services/             # Business logic layer
│       └── __init__.py
├── migrations/
│   ├── env.py
│   └── versions/
├── tests/
│   ├── conftest.py
│   ├── unit/
│   └── integration/
├── pyproject.toml
├── alembic.ini
├── Dockerfile
├── .env.example
├── .gitignore
└── README.md
```

## `pyproject.toml` Core Dependencies

```toml
[project]
name = "project-name"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = [
    "fastapi>=0.115.5",
    "uvicorn[standard]>=0.32.1",
    "sqlalchemy[asyncio]>=2.0.36",
    "asyncpg>=0.30.0",
    "pydantic>=2.10.2",
    "pydantic-settings>=2.6.1",
    "alembic>=1.14.0",
    "python-jose[cryptography]>=3.3.0",
    "passlib[bcrypt]>=1.7.4",
    "httpx>=0.28.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.3.4",
    "pytest-asyncio>=0.24.0",
    "pytest-cov>=6.0.0",
    "httpx>=0.28.0",
    "ruff>=0.8.1",
    "mypy>=1.13.0",
    "pre-commit>=4.0.1",
]
```

## Configuration (`app/core/config.py`)

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    app_name: str = "project-name"
    debug: bool = False
    database_url: str
    secret_key: str
    allowed_origins: list[str] = ["http://localhost:3000"]
```

## Test Setup

- **Framework:** pytest + pytest-asyncio
- **HTTP client:** httpx `AsyncClient` against the FastAPI `TestClient`
- **Fixtures:** shared in `conftest.py` — app instance, async DB session, authenticated client
- **Integration:** Testcontainers or a disposable Docker PostgreSQL
- **Naming:** `test_*.py` files, `test_` prefixed functions
- **Scripts:** `test` (pytest), `test:cov` (pytest --cov), `lint` (ruff check + mypy)

## `.gitignore` Entries

```
__pycache__/
*.pyc
.venv/
.env
dist/
*.egg-info/
.mypy_cache/
.pytest_cache/
.ruff_cache/
coverage.xml
htmlcov/
.DS_Store
```
