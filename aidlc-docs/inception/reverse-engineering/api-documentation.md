# API Documentation

> **IMPORTANT — REMOVAL PROJECT**: All MCP tool definitions below are **documented as current state only** — they will be **completely removed**. The template target has zero registered tools. This document exists to ensure nothing is accidentally preserved.

---

## MCP Tools — Current (Transmission-specific, ALL TO BE REMOVED)

| Tool | Status |
|---|---|
| `list_torrents` | REMOVE |
| `add_torrent` | REMOVE |
| `get_torrent` | REMOVE |
| `start_torrent` | REMOVE |
| `stop_torrent` | REMOVE |
| `remove_torrent` | REMOVE |
| `remove_torrent_and_delete_data` | REMOVE |

## MCP Tools — Target (placeholder)

| Tool | Status | Description |
|---|---|---|
| `health_check` | ADD | Returns `{"status": "ok"}`. Placeholder example; home for future tools. |

`tools.py` is repurposed (not deleted) — Transmission logic replaced with `health_check()`. The `@mcp.tool()` registration moves to `server.py` following the existing pattern.

---

## Internal Python API — Disposition

| Module / Function | Disposition |
|---|---|
| `tools.list_torrents()` | REMOVE (with tools.py) |
| `tools.add_torrent()` | REMOVE (with tools.py) |
| `tools.get_torrent()` | REMOVE (with tools.py) |
| `tools.start_torrent()` | REMOVE (with tools.py) |
| `tools.stop_torrent()` | REMOVE (with tools.py) |
| `tools.remove_torrent()` | REMOVE (with tools.py) |
| `tools.remove_torrent_and_delete_data()` | REMOVE (with tools.py) |
| `config.load_config()` | KEEP |
| `config.AppConfig` | REPURPOSE (drop TransmissionConfig field) |
| `config.TransmissionConfig` | REMOVE |
| `config.ServerConfig` | KEEP |
| `config.LoggingConfig` | KEEP |
| `logging.Logger` | KEEP |
| `logging.make_logger()` | KEEP |

---

## Configuration — Target State

The `config.toml` after stripping will only contain:

```toml
[server]
host = "0.0.0.0"    # MCP server bind address
port = 8080          # MCP server listen port

[logging]
level = "info"       # Log level: trace/debug/info/warning/error/critical
```

The `[transmission]` section and all related config parsing are removed.

---

## Target Python API Surface (template)

After stripping, the public API is minimal:

| Function / Class | Module | Purpose |
|---|---|---|
| `load_config(path)` | `config` | Load `config.toml` -> `AppConfig` |
| `AppConfig` | `config` | Top-level config (server + logging) |
| `ServerConfig` | `config` | Bind address and port |
| `LoggingConfig` | `config` | Log level |
| `Logger` | `logging` | Structured JSON logger |
| `make_logger(level)` | `logging` | Factory for Logger |
| `main()` | `server` | CLI entrypoint; starts FastMCP |
