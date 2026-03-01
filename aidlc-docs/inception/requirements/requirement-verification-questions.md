# Requirements Clarification Questions

Please answer each question by filling in a letter after the `[Answer]:` tag.
For "Other" answers, write your response on the same line after the tag.

---

## Question 1
What should the Python package and project be named in the template?

The current name `transmission_mcp` / `transmission-mcp` is domain-specific and must change.

A) `mcp_base` / `mcp-base` — matches the repository name
B) `mcp_server` / `mcp-server` — describes what it is generically
C) Other (please describe after [Answer]: tag below)

[Answer]: A

---

## Question 2
What should the README say once the Transmission content is stripped?

A) Minimal placeholder — just enough to explain "this is a bare-bones FastMCP server template; add your tools in server.py"
B) Developer guide — explain the architecture (server/config/logging split), how to add tools, and how to run/test it
C) Other (please describe after [Answer]: tag below)

[Answer]: B

---

## Question 3
After removing all Transmission-specific tests, two unit test files remain (`test_logging.py`, and a stripped `test_config.py`). What should happen to the integration test infrastructure?

A) Remove entirely — delete the `tests/integration/` directory and `docker-compose.test.yml`; keep only `tests/unit/`
B) Keep the directory structure but empty it — leave `tests/integration/__init__.py` as a placeholder for future integration tests
C) Other (please describe after [Answer]: tag below)

[Answer]: A

---

## Question 4
The `docs/` directory contains only `docs/ratios-explained.md`, which is entirely Transmission-specific. What should happen to it?

A) Delete the entire `docs/` directory — templates don't need it
B) Keep `docs/` but empty it — reserve the directory for future template documentation
C) Other (please describe after [Answer]: tag below)

[Answer]: A

---

## Question 5
The `.github/workflows/publish.yml` workflow publishes a Docker image to Docker Hub on merge to main. Should it be kept in the template?

A) Keep it — update the image name so the template itself publishes a usable base image
B) Remove it — a template repo shouldn't auto-publish; leave CI only
C) Other (please describe after [Answer]: tag below)

[Answer]: C

Keep it, but introduce variables to be set in the github repo so that it can be easily changed to use other dockerhub
image repos as a destination.

---

## Question 6: Security Extension
Should the security extension rules (SECURITY-01 through SECURITY-15) be enforced as blocking constraints for this project?

These rules cover encryption, access control, logging, input validation, etc. They are designed for production-grade applications.

A) Yes — enforce all SECURITY rules as blocking constraints (recommended for production-grade applications)
B) No — skip all SECURITY rules (suitable for PoCs, prototypes, and template/scaffold projects)
C) Other (please describe after [Answer]: tag below)

[Answer]: B, skip all security rules.
