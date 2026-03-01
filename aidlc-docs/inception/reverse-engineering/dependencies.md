# Dependencies

> **REMOVAL PROJECT**: The `transmission-rpc` dependency and all its usages are removed. The dependency graph below shows current state with removal annotations.

---

## Internal Dependencies — Current (annotated)

```
transmission_mcp/
  server.py
    -> tools.py         [REMOVE — tools module deleted]
    -> config.py        [KEEP — repurposed]
    -> logging.py       [KEEP]
    -> transmission_rpc [REMOVE — direct import removed]
  tools.py              [REMOVE — entire file]
    -> logging.py       [n/a — file removed]
    -> transmission_rpc [REMOVE]
  __main__.py
    -> server.py        [KEEP]
```

## Internal Dependencies — Target

```
mcp_server/
  server.py
    -> config.py        [KEEP]
    -> logging.py       [KEEP]
  __main__.py
    -> server.py        [KEEP]
```

---

## External Dependencies

### fastmcp
- **Version**: >=2.0
- **Action**: KEEP
- **Purpose**: MCP protocol server; Streamable HTTP transport; `@mcp.tool()` registration

### transmission-rpc
- **Version**: 7.0.11
- **Action**: REMOVE
- **Reason**: Transmission-specific; has no place in a generic MCP template

---

## Dev Dependencies (all KEEP)

| Dependency | Version | Purpose |
|---|---|---|
| pytest | >=8.0 | Test runner |
| pytest-asyncio | >=0.24 | Async test support |
| pytest-cov | >=5.0 | Coverage reporting |
| ruff | >=0.8 | Linting and formatting |
| mypy | >=1.11 | Static type checking |
| pre-commit | >=4.0 | Git hook management |
