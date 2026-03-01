# Requirements

## Intent Analysis

- **User Request**: Strip the existing `transmission_mcp` project down to a reusable bare-bones MCP server template for building future MCP servers.
- **Request Type**: Refactoring / Removal — deleting domain-specific functionality to produce a clean scaffold
- **Scope Estimate**: System-wide — affects all source modules, tests, configuration, documentation, and CI/CD
- **Complexity Estimate**: Moderate — intent is clear; mostly deletions with targeted repurposing of infrastructure

---

## Functional Requirements

### FR-01: Package renamed to `mcp_base`
The Python package directory and all internal references must be renamed from `transmission_mcp` to `mcp_base`. The installable project name in `pyproject.toml` must be `mcp-base`.

### FR-02: Remove all MCP tools
All `@mcp.tool()` registrations in `server.py` and the entire `tools.py` file must be deleted. The resulting server registers zero tools.

### FR-03: Remove Transmission integration
- Delete the `transmission-rpc` dependency from `pyproject.toml`
- Delete all `transmission_rpc` imports from `server.py`
- Delete the `_client` global and `TransmissionClient` initialization in `main()`
- Delete `TransmissionConfig` from `config.py` and remove the `[transmission]` section from config loading

### FR-04: Strip configuration to server + logging only
`config.py` retains `ServerConfig`, `LoggingConfig`, `AppConfig`, and `load_config()`. `TransmissionConfig` is removed. `config.toml.example` updated to contain only `[server]` and `[logging]` sections.

### FR-05: Remove Transmission-specific tests
Delete the following test files:
- `tests/unit/test_add_torrent.py`
- `tests/unit/test_management_tools.py`
- `tests/unit/test_get_torrent.py`
- `tests/unit/test_list_torrents.py`
- Entire `tests/integration/` directory
- `docker-compose.test.yml`

Strip `TransmissionConfig` test cases from `tests/unit/test_config.py`, retaining `ServerConfig` and `LoggingConfig` coverage.

### FR-06: Remove `docs/` directory
Delete the entire `docs/` directory including `docs/ratios-explained.md`.

### FR-07: README rewritten as developer guide
The `README.md` must be rewritten to serve as a developer guide for the template. It must cover:
- What the template is and what it provides
- The architecture (server/config/logging separation pattern)
- How to add tools (the `server.py` + `tools.py` split pattern)
- How to run the server locally and via Docker
- How to run the tests
- Configuration reference (`[server]` and `[logging]` sections)
- The Acknowledgement section must be preserved (per project rules)

### FR-08: `repository-overview.md` rewritten for template
Rewritten for Docker Hub visitors describing the template rather than Transmission-specific tools. The Available Tools table and Example System Prompt are removed (no tools exist). The Acknowledgement section must be preserved.

### FR-09: Publish workflow updated with configurable image name
`.github/workflows/publish.yml` is kept but the Docker Hub image name is driven by GitHub repository variables (not hardcoded), so users who fork or copy the template can configure their own Docker Hub destination without editing the workflow file.

### FR-10: `MAINTAINERS.md` updated
Remove any commands or references that are no longer valid after stripping (integration test commands, Docker test commands referencing Transmission). Retain all generic commands.

---

## Non-Functional Requirements

### NFR-01: No new functionality introduced
This is purely a removal project. No new features, tools, or business logic are added.

### NFR-02: Code quality tooling preserved
`ruff`, `mypy`, `pre-commit`, and all dev dependencies remain. The template ships with the same quality gates as the source project.

### NFR-03: All remaining code must pass quality gates
After stripping, `uv run ruff format .`, `uv run ruff check .`, and `uv run mypy src/` must all pass with zero errors.

### NFR-04: Remaining tests must pass
`uv run pytest tests/unit/` must pass after stripping.

### NFR-05: Docker build must succeed
`docker build` must complete successfully against the stripped codebase.

---

## Extension Configuration

| Extension | Enabled | Decided At |
|---|---|---|
| security/baseline | No | Requirements Analysis (Q6 — template/scaffold project) |

---

## Out of Scope

- Adding any new MCP tools
- Changing the FastMCP version or transport mechanism
- Adding authentication to the MCP endpoint
- Any changes to the AI-DLC workflow tooling (`.aidlc-rule-details/`, `.claude/`)
