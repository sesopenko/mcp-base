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

### FR-02: Replace all MCP tools with a single placeholder health-check tool
All Transmission-specific `@mcp.tool()` registrations in `server.py` and all Transmission-specific logic in `tools.py` must be deleted. `tools.py` is **not** deleted — it is repurposed as the home for tool implementations, containing a single `health_check` tool that returns a fixed response (e.g. `{"status": "ok"}`). The `@mcp.tool()` registration for `health_check` lives in `server.py`, following the existing server/tools separation pattern. This serves as a working example for template users adding their own tools.

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
- An **Example System Prompt** section containing:
  - A brief explanation of why XML is preferred over markdown or plain text for system prompts — XML provides explicit named tags that give agents unambiguous semantic meaning (a `<role>` tag is unambiguously a role; a `<tool>` tag with a `name` attribute is unambiguously a tool descriptor), whereas markdown headings and plain text require the agent to infer structure and intent from formatting conventions
  - A concrete XML-formatted example system prompt referencing the `health_check` tool, following the same `<system>`, `<role>`, `<tools>`, `<tool name="...">`, and `<guidelines>` structure used in the existing README
- The Acknowledgement section must be preserved (per project rules)

### FR-08: `repository-overview.md` rewritten for template
Rewritten for Docker Hub visitors describing the template rather than Transmission-specific tools. The Available Tools table and Example System Prompt are removed (no tools exist). The Acknowledgement section must be preserved.

### FR-09: Publish workflow reads image name from the committed configuration file
`.github/workflows/publish.yml` is kept but must read the Docker Hub image name from the committed configuration file established by FR-12 — not from hardcoded values and not from GitHub repository variables. Requiring a separate GitHub variable would create a second place to maintain the image name, introducing human error risk. Changing the Docker Hub destination must be a single committed file edit with no out-of-band configuration required.

### FR-10: `MAINTAINERS.md` updated
Remove any commands or references that are no longer valid after stripping (integration test commands, Docker test commands referencing Transmission). Retain all generic commands.

---

## Non-Functional Requirements

### NFR-01: No new functionality beyond the placeholder tool
This is primarily a removal project. The only new code introduced is the `health_check` tool defined in FR-02. No other new features, tools, or business logic are added.

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

### FR-11: Remove hardcoded project-identity references from Claude rules
Two Claude rule files contain the hardcoded image name `sesopenko/transmission_client_mcp` from the source project. These must not simply be replaced with another hardcoded name — they must instead reference the project configuration file established by FR-12:

- `.claude/rules/repository-overview.md` — two occurrences; update to reference the project image name variable
- `.claude/rules/readme-docker-compose.md` — one occurrence; update to reference the project image name variable

The remaining 8 rule files (`readme-acknowledgement.md`, `llm-ignores.md`, `maintainers.md`, `no-autocommit.md`, `docstrings.md`, `commit-messages.md`, `ai-dlc-workflow-main.md`, `readme-tools.md`) are fully generic and require no changes.

### FR-12: Single committed project configuration file as the template customisation point
A dedicated project configuration file must be committed to the repository. This is the **only** file a developer needs to edit when using this template as a base for a new MCP server. It defines all project-identity values that would otherwise be scattered across multiple files and require coordinated manual changes.

The file must contain at minimum:

| Key | Purpose | Example |
|---|---|---|
| `DOCKER_IMAGE` | Docker Hub image name (org/repo) | `sesopenko/mcp-base` |
| `PROJECT_NAME` | Python package and pyproject.toml project name | `mcp-base` |
| `PACKAGE_NAME` | Python package directory name (underscored) | `mcp_base` |
| `MCP_SERVER_NAME` | Name passed to `FastMCP(...)` — shown to AI clients | `mcp-base` |
| `PROJECT_DESCRIPTION` | Short description for pyproject.toml and README | `Bare-bones FastMCP server template` |

All project files that reference any of these values must read from this file rather than hardcoding them. This includes:
- CI/CD workflows (image name, project name)
- Claude rules (image name)
- `pyproject.toml` (project name, package name, description)
- `README.md` and `repository-overview.md` (image name, server name, description)

GitHub repository secrets for Docker Hub credentials (username, token) are still required as they cannot be committed — but no project-identity value belongs in GitHub variables or secrets.

---

## Out of Scope

- Adding any new MCP tools
- Changing the FastMCP version or transport mechanism
- Adding authentication to the MCP endpoint
- Any changes to the AI-DLC workflow tooling (`.aidlc-rule-details/`, `.claude/`)
