# Business Overview

> **IMPORTANT — REMOVAL PROJECT**: This reverse engineering documents the **current state** of a Transmission-specific MCP server that is being **stripped** into a reusable bare-bones MCP server template. The business transactions, integrations, and domain logic listed below are the **target of removal**, not preservation. The template will contain **no business logic and no tools**.

---

## Current State (to be removed)

The workspace currently implements a Transmission BitTorrent control MCP server. The following functionality will be **deleted** during this project:

### Business Transactions (ALL TO BE REMOVED)
- **List Torrents** — Query all active/queued torrents
- **Add Torrent** — Add a new torrent by magnet link or URL
- **Get Torrent** — Retrieve details for a specific torrent by name
- **Start Torrent** — Resume a paused torrent
- **Stop Torrent** — Pause an active torrent
- **Remove Torrent** — Delete a torrent record (keep files)
- **Remove Torrent and Delete Data** — Delete a torrent record and all downloaded data

### Integration (TO BE REMOVED)
- Transmission BitTorrent client connection via `transmission-rpc`
- Torrent-specific input validation, response formatting, and error handling

### Domain Terminology (CONTEXT ONLY — does not carry over to template)
- Torrent, Magnet Link, Transmission, MCP Tool

---

## Target State (what remains after stripping)

A bare-bones MCP server template with:
- **No tools registered**
- **No external service integrations**
- **No domain-specific business logic**
- A working server skeleton that a developer can clone and build on

### What Carries Over
- Server startup infrastructure (FastMCP instance, `main()`, CLI `--config` flag)
- TOML configuration loading (`[server]` and `[logging]` sections; `[transmission]` section removed)
- Structured JSON logging
- Dockerfile, docker-compose, CI/CD pipelines
- Code quality tooling (ruff, mypy, pre-commit, pytest)
- `README.md`, `MAINTAINERS.md` — rewritten for template use
- `repository-overview.md` — rewritten for template use

---

## Component Summary

| Component | Status |
|---|---|
| `server.py` tool registrations (7 tools) | REMOVE |
| `tools.py` (entire file) | REPURPOSE — replace Transmission logic with `health_check()` placeholder |
| `transmission-rpc` dependency | REMOVE |
| `[transmission]` config section | REMOVE |
| Transmission-specific unit tests | REMOVE |
| Transmission-specific integration tests | REMOVE |
| `server.py` skeleton (FastMCP init, main) | KEEP / REPURPOSE |
| `config.py` (server + logging sections) | KEEP / REPURPOSE |
| `logging.py` | KEEP |
| Dockerfile, docker-compose | KEEP |
| CI/CD workflows | KEEP |
| Code quality tooling | KEEP |
