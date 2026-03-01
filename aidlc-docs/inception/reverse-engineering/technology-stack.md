# Technology Stack

## Programming Languages
- Python — 3.13+ — Application code

## Frameworks
- fastmcp — >=2.0 — MCP protocol implementation and HTTP transport
- transmission-rpc — 7.0.11 — Typed Transmission JSON-RPC client

## Infrastructure
- Docker — Container packaging and deployment
- GitHub Actions — CI/CD (ci.yml, publish.yml)

## Build Tools
- uv — Latest — Dependency management and virtual environment
- hatchling — Latest — Python build backend (wheel packaging)

## Testing Tools
- pytest — >=8.0 — Test runner
- pytest-asyncio — >=0.24 — Async test support
- pytest-cov — >=5.0 — Coverage reporting

## Code Quality Tools
- ruff — >=0.8 — Linting and formatting (replaces black + flake8 + isort)
- mypy — >=1.11 — Static type checking
- pre-commit — >=4.0 — Git hook management

## Standard Library Usage
- tomllib — TOML config parsing
- dataclasses — Typed configuration models
- pathlib — File path handling
- json, sys — Structured logging
- argparse — CLI argument parsing
- datetime, timedelta — Torrent date and ETA formatting
- urllib.parse — Magnet link and URL validation
