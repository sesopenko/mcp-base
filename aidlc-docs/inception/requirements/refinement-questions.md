# Requirements Refinement Questions

Please answer each question by filling in a letter after the `[Answer]:` tag.
For "Other" answers, write your response on the same line after the tag.

---

## Question 1 — FR-09 / FR-12: Config file format

FR-12 requires a single committed project configuration file that CI/CD workflows, Claude rules, and documentation all read from. The format determines how every consumer reads it.

A) Shell env file (`project.env`) — one `KEY=value` per line; GitHub Actions can load it with `source project.env` or the `dotenv` step; bash-friendly for scripts
B) TOML section in `pyproject.toml` (e.g. `[tool.mcp-project]`) — keeps identity metadata in the same file that already owns package metadata; CI reads it with `tomli`/`python -c`
C) Standalone TOML file (e.g. `project.toml`) — dedicated file, human-readable, requires a TOML parser in CI
D) Other (please describe after [Answer]: tag below)

[Answer]: A

It can work for github actions, the python project, etc.  And it's simple.

---

## Question 2 — FR-09 vs original Q5 answer: GitHub repo variables

The original Q5 answer said: *"introduce variables to be set in the github repo so that it can be easily changed"*.

FR-09 (written after Q5) explicitly says the image name must come from the **committed config file**, NOT from GitHub repository variables, because "requiring a separate GitHub variable would create a second place to maintain the image name."

These two positions conflict. Which takes precedence?

A) FR-09 wins — use only the committed config file; no GitHub repo variable for image name (GitHub secrets for Docker Hub credentials are still required)
B) Q5 wins — use a GitHub repository variable for the image name (simpler for forks)
C) Both — committed config file is canonical; CI also accepts an override from a GitHub variable (committed file is the default/fallback)

[Answer]: D other

committed config file is canonical, with opinions.  security secrets are to be in github variables (ie: dockerhub api key).

---

## Question 3 — FR-12 + `pyproject.toml`: static metadata limitation

`pyproject.toml` project metadata (name, description, version) is static — standard hatchling cannot read values from another file at build time. FR-12 says `pyproject.toml` values "must read from this file rather than hardcoding them."

How should this be resolved?

A) Accept manual coordination — the config file is the canonical source; a developer customising the template must update both `project.env` (or equivalent) and `pyproject.toml`; a README note explains this
B) Add a setup script (`scripts/apply-project-config.sh`) that reads the config file and rewrites `pyproject.toml` and other files in one command; the README instructs template users to run it once
C) Put all identity values directly in `pyproject.toml` under a custom section (e.g. `[tool.mcp-project]`) so there is only one file to edit — CI and Claude rules all read from `pyproject.toml`
D) Other (please describe after [Answer]: tag below)

[Answer]: B

---

## Question 4 — FR-02 vs FR-08: `health_check` tool in `repository-overview.md`

FR-02 introduces a `health_check` tool as a working placeholder example.

FR-08 says the Available Tools table is **removed** from `repository-overview.md` with the note "(no tools exist)".

These conflict. `health_check` is a real registered MCP tool — AI clients will see it. Should it appear in `repository-overview.md`?

A) Exclude it — `repository-overview.md` is for Docker Hub visitors evaluating real functionality; `health_check` is a template placeholder, not a user-facing feature; omit it (FR-08 stands as written)
B) Include it — it is a real registered tool; Docker Hub visitors should know the image exposes it; add a single-row Available Tools table noting it is a template placeholder
C) Other (please describe after [Answer]: tag below)

[Answer]: B

---

## Question 5 — FR-02: unit tests for `health_check`

FR-02 places `health_check` in `tools.py` as a working example. FR-05 removes all Transmission tests. No requirement explicitly mentions creating a new test file for `health_check`.

Should a `tests/unit/test_tools.py` be created to test the `health_check` function?

A) Yes — `health_check` should have a test; it demonstrates the testing pattern for template users and keeps NFR-04 meaningful
B) No — `health_check` is trivial (`return {"status": "ok"}`); the existing `test_config.py` and `test_logging.py` are sufficient coverage for the template
C) Other (please describe after [Answer]: tag below)

[Answer]: A

---

## Question 6 — FR-11: how Claude rules reference the config file

FR-11 says two Claude rule files must stop hardcoding `sesopenko/transmission_client_mcp` and instead "reference the project image name variable." The mechanism for referencing a shell/TOML file from a markdown rule file is not self-evident.

A) Replace the hardcoded image name in each rule with the config file path and key, e.g.: *"use the `DOCKER_IMAGE` value from `project.env`"*
B) Replace the hardcoded name with a placeholder token, e.g. `<DOCKER_IMAGE>`, and add a note at the top of the rule file explaining the token is resolved from the config file
C) Remove the specific image name from the rule text entirely; rewrite the rule to say "use the published image name as configured for this project" without citing a specific value
D) Other (please describe after [Answer]: tag below)

[Answer]: use the script mentioned above, in this file, scripts/apply-project-config.sh.  This should be a mandatory, early step, when using this base as a scaffold.
