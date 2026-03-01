# Code Generation Plan — mcp-base

## Unit Context
- **Unit Name**: mcp-base (single unit, full repository)
- **Transformation Type**: Removal / Refactoring (brownfield)
- **Requirements Implemented**: FR-01 through FR-13, NFR-01 through NFR-05

## Group Sequence

All 8 change groups are executed in dependency order:
1. Deletions first — removes noise before modifications
2. Package rename — establishes new identity before source edits
3. Python source — edits the renamed package
4. Tests — strips obsolete test cases from the retained file
5. Config & CI — creates project.env; updates pyproject.toml, config.toml.example, publish.yml
6. Setup script — creates scripts/apply-project-config.sh
7. Documentation — rewrites README.md, repository-overview.md, MAINTAINERS.md
8. Claude rules — updates two rule files, creates one new rule file

---

## Group 1: Deletions

- [x] Step 1.1 — Delete `docs/` directory (FR-06)
  - Target: `docs/` (contains `ratios-explained.md`, `review-phase-9.xml`)
  - Action: Remove entire directory
- [x] Step 1.2 — Delete `tests/integration/` directory (FR-05)
  - Target: `tests/integration/` (conftest.py + 6 test files)
  - Action: Remove entire directory
- [x] Step 1.3 — Delete `docker-compose.test.yml` (FR-05)
  - Target: `docker-compose.test.yml`
  - Action: Delete file
- [x] Step 1.4 — Delete Transmission unit test files (FR-05)
  - Targets:
    - `tests/unit/test_add_torrent.py`
    - `tests/unit/test_management_tools.py`
    - `tests/unit/test_get_torrent.py`
    - `tests/unit/test_list_torrents.py`
  - Action: Delete each file

---

## Group 2: Package Rename

- [x] Step 2.1 — Rename package directory (FR-01)
  - Action: Rename `src/transmission_mcp/` → `src/mcp_base/`
  - All files inside move with the directory: `__init__.py`, `__main__.py`, `server.py`, `tools.py`, `config.py`, `logging.py`
- [x] Step 2.2 — Update `src/mcp_base/__main__.py` imports (FR-01)
  - Replace any `transmission_mcp` import references with `mcp_base`

---

## Group 3: Python Source

- [x] Step 3.1 — Rewrite `src/mcp_base/tools.py` (FR-02, FR-03, NFR-01)
  - Remove all Transmission tool implementations (`list_torrents`, `add_torrent`, `get_torrent`, `start_torrent`, `stop_torrent`, `remove_torrent`, `remove_torrent_and_delete_data`) and all private helpers
  - Remove all `transmission_rpc` imports
  - Add single `health_check()` function returning `{"status": "ok"}`
  - Apply Google-style docstring on `health_check`
  - Apply type annotation: `def health_check() -> dict[str, str]:`

- [x] Step 3.2 — Rewrite `src/mcp_base/server.py` (FR-02, FR-03, NFR-01)
  - Remove all `@mcp.tool()` registrations for the 7 Transmission tools
  - Remove `transmission_rpc` imports
  - Remove `_client` global variable
  - Remove `TransmissionClient` initialization in `main()`
  - Import `health_check` from `tools` and register it with `@mcp.tool()`
  - Update `FastMCP(...)` name argument to use `mcp-base` (from project.env default; hardcode the default for now — the setup script will substitute it)
  - Remove the `AppConfig.transmission` usage from `main()`

- [x] Step 3.3 — Rewrite `src/mcp_base/config.py` (FR-03, FR-04)
  - Remove `TransmissionConfig` dataclass
  - Remove `[transmission]` section parsing from `load_config()`
  - Remove any imports only used by `TransmissionConfig`
  - Retain `ServerConfig`, `LoggingConfig`, `AppConfig`, `load_config()`
  - Ensure `AppConfig` no longer has a `transmission` field

---

## Group 4: Tests

- [x] Step 4.1 — Strip `tests/unit/test_config.py` (FR-05)
  - Remove all test functions that reference `TransmissionConfig`
  - Remove any `TransmissionConfig` imports
  - Retain `ServerConfig` and `LoggingConfig` test coverage
  - Add a `health_check` unit test to `tests/unit/` (new file `test_tools.py`)
    - Verifies `health_check()` returns `{"status": "ok"}`

---

## Group 5: Config & CI

- [x] Step 5.1 — Create `project.env` (FR-12)
  - New file at repo root
  - Contents (KEY=value, no `export`, no quotes):
    ```
    DOCKER_IMAGE=sesopenko/mcp-base
    PROJECT_NAME=mcp-base
    PACKAGE_NAME=mcp_base
    MCP_SERVER_NAME=mcp-base
    PROJECT_DESCRIPTION=Bare-bones FastMCP server template
    ```

- [x] Step 5.2 — Update `pyproject.toml` (FR-01, FR-03, FR-12)
  - Change `name` from `transmission-mcp` to `mcp-base`
  - Change `description` to `Bare-bones FastMCP server template`
  - Remove `transmission-rpc==7.0.11` from dependencies
  - Update script entry point from `transmission-mcp` to `mcp-base` and from `transmission_mcp.server:main` to `mcp_base.server:main`
  - Update `[tool.hatch.build.targets.wheel]` package path from `src/transmission_mcp` to `src/mcp_base`

- [x] Step 5.3 — Update `config.toml.example` (FR-04)
  - Remove the `[transmission]` section entirely
  - Retain `[server]` and `[logging]` sections with existing example values

- [x] Step 5.4 — Update `.github/workflows/publish.yml` (FR-09)
  - Add a step before the Docker build steps in both `publish-latest` and `publish-release` jobs to source `project.env`
  - Use GitHub Actions dotenv syntax: add a step that reads `project.env` into `$GITHUB_ENV`
  - Replace hardcoded image name `sesopenko/transmission_client_mcp` with `${{ env.DOCKER_IMAGE }}`

---

## Group 6: Setup Script

- [x] Step 6.1 — Create `scripts/apply-project-config.sh` (FR-13)
  - Bash script sourcing `project.env` from repo root
  - Performs in-place `sed` substitutions for each identity value in:
    - `pyproject.toml` — `name`, `description`, package path
    - `.claude/rules/repository-overview.md` — Docker image name
    - `.claude/rules/readme-docker-compose.md` — Docker image name
    - `README.md` — Docker image name, MCP server name
    - `repository-overview.md` — Docker image name
  - Idempotent: safe to run multiple times
  - Prints a summary line for each file modified
  - Make executable (chmod +x)

---

## Group 7: Documentation

- [x] Step 7.1 — Rewrite `README.md` (FR-07)
  - Content must cover:
    - What the template is and what it provides
    - Architecture: server/config/logging separation pattern
    - How to add tools: server.py + tools.py split pattern
    - How to run locally and via Docker
    - How to run tests
    - Configuration reference: [server] and [logging] sections
    - **Customising the Template** section: documents `scripts/apply-project-config.sh` as the first step after forking
    - Example System Prompt section:
      - Brief explanation of why XML is preferred (explicit named tags give unambiguous semantic meaning; markdown requires inference)
      - Concrete XML example referencing `health_check`, using `<system>`, `<role>`, `<tools>`, `<tool name="...">`, `<guidelines>` structure
    - Available Tools table with single row: `health_check`
    - Docker Compose example using `sesopenko/mcp-base:latest`
    - Acknowledgement section (MUST be preserved per project rules)

- [x] Step 7.2 — Rewrite `repository-overview.md` (FR-08)
  - Docker Hub visitor-facing overview of the template
  - Available Tools table: single row for `health_check` with note that it is a placeholder
  - Docker Compose example using `sesopenko/mcp-base:latest`
  - Connecting an AI Application section (MCP endpoint on port 8080)
  - Configuration section: [server] and [logging] only, inline TOML comments on every key
  - Acknowledgement section (MUST be preserved per project rules)
  - No Example System Prompt (per FR-08)
  - No developer workflow steps

- [x] Step 7.3 — Update `MAINTAINERS.md` (FR-10, FR-13)
  - Remove any commands referencing integration tests, docker-compose.test.yml, or Transmission
  - Add **Customising the Template** section with:
    ```bash
    bash scripts/apply-project-config.sh
    ```

---

## Group 8: Claude Rules

- [x] Step 8.1 — Update `.claude/rules/repository-overview.md` (FR-11)
  - Replace two occurrences of `sesopenko/transmission_client_mcp` with `sesopenko/mcp-base`

- [x] Step 8.2 — Update `.claude/rules/readme-docker-compose.md` (FR-11)
  - Replace one occurrence of `sesopenko/transmission_client_mcp` with `sesopenko/mcp-base`

- [x] Step 8.3 — Create `.claude/rules/apply-project-config.md` (FR-13)
  - Documents every file that `scripts/apply-project-config.sh` touches
  - For each file: what substitution is performed
  - Instructs the LLM to update the script when a new file embedding identity values is added

---

## Success Criteria
- `uv run ruff format .` — zero changes
- `uv run ruff check .` — zero errors
- `uv run mypy src/` — zero errors
- `uv run pytest tests/unit/` — all pass
- `docker build` — succeeds
