# Code Structure

> **IMPORTANT — REMOVAL PROJECT**: Each file below is annotated with its disposition: **REMOVE**, **KEEP**, or **REPURPOSE**. This is a map of what to delete vs. what forms the template skeleton.

---

## Build System
- **Type**: uv + hatchling
- **Configuration**: `pyproject.toml` — **REPURPOSE** (rename package, remove `transmission-rpc` dependency)

## File Inventory with Disposition

### Application Source

| File | Disposition | Notes |
|---|---|---|
| `src/transmission_mcp/__init__.py` | KEEP | Empty package marker; rename package directory |
| `src/transmission_mcp/__main__.py` | KEEP | Generic `python -m` entry; no changes |
| `src/transmission_mcp/server.py` | REPURPOSE | Keep FastMCP init + `main()`; delete all `@mcp.tool()` registrations, `_client` global, `TransmissionClient` import, `tools` import |
| `src/transmission_mcp/tools.py` | REPURPOSE | Remove all Transmission logic; replace with `health_check()` returning `{"status": "ok"}` as a placeholder example |
| `src/transmission_mcp/config.py` | REPURPOSE | Keep `ServerConfig`, `LoggingConfig`, `load_config()`; delete `TransmissionConfig`, `[transmission]` parsing |
| `src/transmission_mcp/logging.py` | KEEP | Fully generic; no domain code |

### Tests

| File | Disposition | Notes |
|---|---|---|
| `tests/unit/test_config.py` | REPURPOSE | Remove `TransmissionConfig` test cases; keep `ServerConfig`/`LoggingConfig` tests |
| `tests/unit/test_logging.py` | KEEP | Tests logging.py; fully generic |
| `tests/unit/test_add_torrent.py` | REMOVE | Transmission-specific |
| `tests/unit/test_management_tools.py` | REMOVE | Transmission-specific |
| `tests/unit/test_get_torrent.py` | REMOVE | Transmission-specific |
| `tests/unit/test_list_torrents.py` | REMOVE | Transmission-specific |
| `tests/integration/conftest.py` | REMOVE | Transmission Docker container fixture |
| `tests/integration/test_connection.py` | REMOVE | Transmission-specific |
| `tests/integration/test_list_torrents.py` | REMOVE | Transmission-specific |
| `tests/integration/test_list_torrents_smoke.py` | REMOVE | Transmission-specific |
| `tests/integration/test_add_torrent.py` | REMOVE | Transmission-specific |
| `tests/integration/test_get_torrent.py` | REMOVE | Transmission-specific |
| `tests/integration/test_management_tools.py` | REMOVE | Transmission-specific |

### Infrastructure and Config

| File | Disposition | Notes |
|---|---|---|
| `pyproject.toml` | REPURPOSE | Rename project, remove `transmission-rpc` dep, update package path |
| `Dockerfile` | KEEP | Generic Python/uv build; no domain references |
| `config.toml.example` | REPURPOSE | Remove `[transmission]` section; keep `[server]` and `[logging]` |
| `repository-overview.md` | REPURPOSE | Rewrite for template audience |
| `README.md` | REPURPOSE | Rewrite for template audience |
| `MAINTAINERS.md` | KEEP / minor update | Developer commands stay valid |
| `scripts/` | KEEP | Generic git hooks and CI helpers |
| `.github/workflows/ci.yml` | KEEP | Generic CI |
| `.github/workflows/publish.yml` | REPURPOSE | Update image name for template repo |
| `docker-compose.test.yml` | REMOVE | Transmission test container fixture |

---

## Design Patterns Worth Preserving in Template

### Separation of Concerns (server.py / tools.py)
- **Keep the pattern**: FastMCP wiring in `server.py`; business logic in a separate module
- **Template action**: Remove `tools.py` content but document the pattern in README — template users should follow the same split

### Typed Config Dataclasses (config.py)
- **Keep**: The dataclass + `load_config()` pattern is generic and valuable

### Structured JSON Logging (logging.py)
- **Keep as-is**: Fully generic; ready for any MCP server

---

## Critical Dependency Changes

| Dependency | Action |
|---|---|
| `fastmcp>=2.0` | KEEP — core MCP framework |
| `transmission-rpc==7.0.11` | REMOVE — domain-specific |
