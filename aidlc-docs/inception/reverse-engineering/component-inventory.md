# Component Inventory

> **REMOVAL PROJECT**: Components are annotated by disposition — REMOVE, KEEP, or REPURPOSE.

---

## Application Package

| Component | Disposition |
|---|---|
| `transmission_mcp` package (directory + __init__.py) | REPURPOSE — rename to generic name |
| `server.py` — FastMCP init + main() | KEEP skeleton |
| `server.py` — 7 tool registrations | REMOVE |
| `tools.py` — Transmission logic | REMOVE |
| `tools.py` — `health_check()` placeholder | ADD |
| `config.py` — ServerConfig + LoggingConfig + load_config() | KEEP |
| `config.py` — TransmissionConfig | REMOVE |
| `logging.py` | KEEP |
| `__main__.py` | KEEP |

## Infrastructure

| Component | Disposition |
|---|---|
| `Dockerfile` | KEEP |
| `config.toml.example` | REPURPOSE — remove [transmission] section |
| `.github/workflows/ci.yml` | KEEP |
| `.github/workflows/publish.yml` | REPURPOSE — update image name |
| `scripts/` (all) | KEEP |

## Test Packages

| Component | Disposition |
|---|---|
| `tests/unit/test_logging.py` | KEEP |
| `tests/unit/test_config.py` | REPURPOSE — remove TransmissionConfig tests |
| `tests/unit/test_*.py` (torrent tools) | REMOVE (4 files) |
| `tests/integration/` (entire directory) | REMOVE |
| `docker-compose.test.yml` | REMOVE |

## Documentation

| Component | Disposition |
|---|---|
| `README.md` | REPURPOSE — rewrite for template |
| `MAINTAINERS.md` | KEEP with minor updates |
| `repository-overview.md` | REPURPOSE — rewrite for template |

---

## Total Count

| Category | Current | After Stripping |
|---|---|---|
| Source modules | 6 | 6 (tools.py repurposed, not removed) |
| Unit test files | 6 | 2 (test_logging.py + reduced test_config.py) |
| Integration test files | 7 | 0 |
| External runtime deps | 2 | 1 (fastmcp only) |
