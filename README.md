# mcp-base

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](LICENSE.txt)
[![Python 3.13+](https://img.shields.io/badge/python-3.13%2B-blue)](https://www.python.org/downloads/)

A bare-bones [FastMCP](https://github.com/jlowin/fastmcp) server template. Fork this repository to build your own MCP server without starting from scratch.

[MCP (Model Context Protocol)](https://modelcontextprotocol.io/) is an open standard that lets AI assistants call external tools and services. This template implements MCP over HTTP so any MCP-compatible AI application can reach your server.

---

## Architecture

The template follows a clean three-layer separation:

| File | Purpose |
|---|---|
| `src/mcp_base/tools.py` | Pure Python functions — one function per tool, no framework coupling |
| `src/mcp_base/server.py` | FastMCP wiring — registers tool functions with `@mcp.tool()` and runs the server |
| `src/mcp_base/config.py` | TOML config loading — typed dataclasses for `[server]` and `[logging]` sections |
| `src/mcp_base/logging.py` | Structured logger factory |

### Adding a tool

1. Add a function to `src/mcp_base/tools.py` with a Google-style docstring and full type annotations.
2. Import the function in `src/mcp_base/server.py` and register it with `@mcp.tool()`.
3. Add a unit test in `tests/unit/`.
4. Add a row to the **Available Tools** table in this README.

---

## Customising the Template

After forking, run the setup script to substitute the template identity values (image name, package name, project name) throughout the repository:

```bash
bash scripts/apply-project-config.sh
```

Edit `project.env` first to set your own values, then run the script. It is idempotent — safe to run multiple times.

---

## Prerequisites

- **Docker** — for the Docker Compose deployment path
- **uv** — for the source deployment path (see [Installing uv](https://docs.astral.sh/uv/getting-started/installation/))

---

## Quick Start

### Option A — Docker Compose

1. Create a `docker-compose.yml`:

   ```yaml
   services:
     mcp-base:
       image: sesopenko/mcp-base:latest
       ports:
         - "8080:8080"
       volumes:
         - ./config.toml:/config/config.toml:ro
       restart: unless-stopped
   ```

2. Copy the example config and edit it:

   ```bash
   cp config.toml.example config.toml
   ```

3. Start the server:

   ```bash
   docker compose up -d
   ```

### Option B — Run from Source

1. Install [uv](https://docs.astral.sh/uv/getting-started/installation/) if you haven't already.

2. Install dependencies:

   ```bash
   uv sync
   ```

3. Copy the example config and edit it:

   ```bash
   cp config.toml.example config.toml
   ```

4. Start the server:

   ```bash
   uv run python -m mcp_base
   ```

---

## Configuration

Create a `config.toml` in the working directory (or pass `--config <path>`):

```toml
[server]
host = "0.0.0.0"
port = 8080

[logging]
level = "info"
```

### [server]

| Key | Default | Description |
|---|---|---|
| `host` | `"0.0.0.0"` | Address the MCP server listens on. `0.0.0.0` binds all interfaces. |
| `port` | `8080` | Port the MCP server listens on. |

### [logging]

| Key | Default | Description |
|---|---|---|
| `level` | `"info"` | Log verbosity. One of: `debug`, `info`, `warning`, `error`. |

---

## Running Tests

```bash
uv run pytest tests/unit/
```

---

## Connecting an AI Application

Point your MCP-compatible AI application at the server's MCP endpoint:

```
http://<host>:<port>/mcp
```

For example, if the server is running on `192.168.1.10` with the default port:

```
http://192.168.1.10:8080/mcp
```

Consult your AI application's documentation for how to register an MCP server.

---

## Example System Prompt

XML is preferred over markdown for system prompts because explicit named tags give unambiguous semantic meaning — the AI always knows exactly what each block contains. Markdown headings require inference and are more likely to be misinterpreted.

Copy and adapt this prompt to give your AI assistant clear guidance on using the tools.

```xml
<system>
  <role>
    You are a helpful assistant with access to an MCP server. Use the available
    tools to fulfil user requests accurately and efficiently.
  </role>
  <tools>
    <tool name="health_check">Check that the MCP server is running and reachable.</tool>
  </tools>
  <guidelines>
    <item>Call health_check if the user asks whether the server is available.</item>
  </guidelines>
</system>
```

---

## Available Tools

| Tool | Description |
|---|---|
| `health_check` | Returns `{"status": "ok"}` to confirm the server is running. |

> Tools are documented here as they are implemented.

---

## Security

This server has **no authentication** on its MCP endpoint. It is designed for LAN use only.

**Do not expose this server directly to the internet.**

If you need to access it remotely, place it behind a reverse proxy that handles TLS termination and access control. Configuring a reverse proxy is outside the scope of this project.

---

## Contributing / Maintaining

See [MAINTAINERS.md](MAINTAINERS.md) for setup, development commands, and how to run tests.

---

## License

Copyright (c) Sean Esopenko 2026

This project is licensed under the [GNU General Public License v3.0](LICENSE.txt).

---

## Acknowledgement: Riding on the Backs of Giants

This project was built with the assistance of [Claude Code](https://claude.ai/code), an AI coding assistant developed by Anthropic.

AI assistants like Claude are trained on enormous amounts of data — much of it written by the open-source community: the libraries, tools, documentation, and decades of shared knowledge that developers have contributed freely. Without that foundation, tools like this would not be possible.

In recognition of that debt, this project is released under the [GNU General Public License v3.0](LICENSE.txt). The GPL ensures that this code — and any derivative work — remains open source. It is a small act of reciprocity: giving back to the commons that made it possible.

To every developer who ever pushed a commit to a public repo, wrote a Stack Overflow answer, or published a package under an open license — thank you.
