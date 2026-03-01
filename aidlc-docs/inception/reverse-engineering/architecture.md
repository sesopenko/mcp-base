# System Architecture

> **IMPORTANT — REMOVAL PROJECT**: Diagrams and descriptions below show the **current state**. Items marked **[REMOVE]** will be deleted. Items marked **[KEEP]** or **[REPURPOSE]** form the template skeleton.

---

## Current Architecture (annotated for removal)

```
+-----------------------------------------------------------------------+
|  AI Application (Claude, etc.)                                        |
|                                                                       |
|  MCP Client ---- HTTP POST /mcp ---->  FastMCP Server (port 8080)    |
+-----------------------------------------------------------------------+
                                                 |
                          +----------------------+
                          |  transmission_mcp    |  [RENAME to mcp_server or similar]
                          |                      |
                          |  server.py           |  [REPURPOSE — keep skeleton, remove tool registrations]
                          |  - FastMCP instance  |  [KEEP]
                          |  - Tool registrations|  [REMOVE — all 7 tools]
                          |  - main() entrypoint |  [KEEP]
                          |         |            |
                          |  tools.py            |  [REPURPOSE — health_check() placeholder]
                          |  - health_check()    |
                          |         |            |
                          |  config.py           |  [REPURPOSE — remove [transmission] section]
                          |  - TOML loading      |
                          |         |            |
                          |  logging.py          |  [KEEP — generic, no domain logic]
                          |  - JSON stdout log   |
                          +----------+-----------+
                                     |
                              Transmission RPC    [REMOVE — entire integration]
                              (HTTP port 9091)
                                     |
                          +----------+-----------+
                          |  Transmission Client |  [REMOVE]
                          |  (BitTorrent)        |
                          +----------------------+
```

## Target Architecture (after stripping)

```
+-----------------------------------------------------------------------+
|  AI Application (Claude, etc.)                                        |
|                                                                       |
|  MCP Client ---- HTTP POST /mcp ---->  FastMCP Server (port 8080)    |
+-----------------------------------------------------------------------+
                                                 |
                          +----------------------+
                          |  mcp_server (renamed)|
                          |                      |
                          |  server.py           |
                          |  - FastMCP instance  |
                          |  - No tools yet      |
                          |  - main() entrypoint |
                          |         |            |
                          |  config.py           |
                          |  - [server] section  |
                          |  - [logging] section |
                          |         |            |
                          |  logging.py          |
                          |  - JSON stdout log   |
                          +----------------------+
```

## Component Descriptions

### server.py — REPURPOSE
- **Current**: FastMCP instance + 7 Transmission tool registrations + `main()`
- **After**: FastMCP instance + no tools + `main()` — clean starting point for new tools
- **Remove**: `_client` global, `TransmissionClient` import, all `@mcp.tool()` handlers, `tools` import

### tools.py — REPURPOSE
- **Current**: All Transmission-specific tool logic, validation, helpers
- **After**: Single `health_check()` function returning `{"status": "ok"}`; serves as example and home for future tools

### config.py — REPURPOSE
- **Current**: `AppConfig` with `TransmissionConfig`, `ServerConfig`, `LoggingConfig`
- **After**: `AppConfig` with `ServerConfig` and `LoggingConfig` only; `[transmission]` section and `TransmissionConfig` removed

### logging.py — KEEP AS-IS
- Generic structured JSON logger; no domain dependencies; fully reusable

### __main__.py — KEEP AS-IS
- Generic `python -m` entry; no changes needed

## Integration Points

### Current (to remove)
- Transmission RPC HTTP API (port 9091)

### Target
- None — bare template has no external integrations

## Infrastructure Components (all KEEP)
- **Deployment Model**: Single Docker container; config mounted at `/config/config.toml`
- **Transport**: Streamable HTTP MCP on port 8080
- **Networking**: LAN design; no authentication on MCP endpoint
