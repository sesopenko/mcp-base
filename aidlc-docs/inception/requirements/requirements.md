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
Rewritten for Docker Hub visitors describing the template rather than Transmission-specific tools. The Example System Prompt is removed. The Available Tools table is retained but reduced to a single row for `health_check`, with a note in the description that it is a template placeholder — the starting point for adding real tools. The Acknowledgement section must be preserved.

### FR-09: Publish workflow reads image name from the committed configuration file
`.github/workflows/publish.yml` is kept but must read the Docker Hub image name from `project.env` (established by FR-12) — not from hardcoded values and not from GitHub repository variables. The workflow sources `project.env` to obtain `DOCKER_IMAGE`. Docker Hub credentials (username and token) remain in GitHub repository secrets as they cannot be committed. No project-identity value belongs in GitHub variables or secrets — only credentials do.

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
Two Claude rule files contain the hardcoded image name `sesopenko/transmission_client_mcp` from the source project. These occurrences must be replaced with the `sesopenko/mcp-base` template default value sourced from `project.env`. The setup script established by FR-13 is responsible for rewriting these files when a developer customises the template — the rule files in the committed template will hold the default value, and the script replaces it with whatever `DOCKER_IMAGE` is set to in `project.env`.

Files to update:
- `.claude/rules/repository-overview.md` — two occurrences
- `.claude/rules/readme-docker-compose.md` — one occurrence

The remaining 8 rule files (`readme-acknowledgement.md`, `llm-ignores.md`, `maintainers.md`, `no-autocommit.md`, `docstrings.md`, `commit-messages.md`, `ai-dlc-workflow-main.md`, `readme-tools.md`) are fully generic and require no changes.

### FR-12: Single committed project configuration file as the template customisation point
A shell env file named `project.env` must be committed to the repository. It uses `KEY=value` format (one key per line, no `export` prefix), compatible with both `source` in bash scripts and the GitHub Actions `dotenv` step. This is the **only** file a developer needs to edit when customising the template for a new MCP server; running the setup script (FR-13) propagates those values everywhere else.

The file must contain at minimum:

| Key | Purpose | Example |
|---|---|---|
| `DOCKER_IMAGE` | Docker Hub image name (org/repo) | `sesopenko/mcp-base` |
| `PROJECT_NAME` | Python package and pyproject.toml project name | `mcp-base` |
| `PACKAGE_NAME` | Python package directory name (underscored) | `mcp_base` |
| `MCP_SERVER_NAME` | Name passed to `FastMCP(...)` — shown to AI clients | `mcp-base` |
| `PROJECT_DESCRIPTION` | Short description for pyproject.toml and README | `Bare-bones FastMCP server template` |

**Consumers of `project.env`:**
- `.github/workflows/publish.yml` — sources `project.env` to read `DOCKER_IMAGE`
- `scripts/apply-project-config.sh` (FR-13) — sources `project.env` and rewrites all other files that embed identity values

`pyproject.toml`, Claude rule files, `README.md`, and `repository-overview.md` do **not** read `project.env` at runtime. Instead, they hold the current identity values as committed text; the setup script keeps them in sync when `project.env` changes.

GitHub repository secrets for Docker Hub credentials (username, token) are still required as they cannot be committed — but no project-identity value belongs in GitHub variables or secrets.

### FR-13: `scripts/apply-project-config.sh` — template setup script
A bash script at `scripts/apply-project-config.sh` must be created. It sources `project.env` and performs in-place text substitution to propagate identity values into all files that embed them:

- `pyproject.toml` — `name`, `description`, and the package path under `[tool.hatch.build.targets.wheel]`
- `.claude/rules/repository-overview.md` — replace the existing Docker image name with `$DOCKER_IMAGE`
- `.claude/rules/readme-docker-compose.md` — replace the existing Docker image name with `$DOCKER_IMAGE`
- `README.md` — replace the existing Docker image name with `$DOCKER_IMAGE`; replace the existing server name with `$MCP_SERVER_NAME`
- `repository-overview.md` — replace the existing Docker image name with `$DOCKER_IMAGE`

The script must be idempotent (safe to run multiple times). It must print a brief summary of each file it modified.

`README.md` must document this script as the **first step** a developer takes after forking or copying the template. `MAINTAINERS.md` must include the command under a "Customising the Template" section.

A Claude rule file must be created at `.claude/rules/apply-project-config.md` after the script is built and tested. Its purpose is to keep the script accurate as the project evolves: it enumerates every file the script touches and what substitution it performs in each, so that an LLM can recognise when a change to one of those files (or the addition of a new file that embeds identity values) requires a corresponding update to `apply-project-config.sh`.

---

## Out of Scope

- Adding any new MCP tools
- Changing the FastMCP version or transport mechanism
- Adding authentication to the MCP endpoint
- Any changes to the AI-DLC workflow tooling (`.aidlc-rule-details/`) or `.claude/` files other than the two rule files explicitly named in FR-11
