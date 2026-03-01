#!/usr/bin/env bash
# apply-project-config.sh — Substitute identity values from project.env into
# all files that embed the project name, package name, image name, or description.
#
# Run this script once after forking the template to rename the project.
# It is idempotent: safe to run multiple times.
#
# Usage:
#   bash scripts/apply-project-config.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${REPO_ROOT}/project.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "ERROR: project.env not found at ${ENV_FILE}" >&2
  exit 1
fi

# Load variables from project.env
while IFS='=' read -r key value; do
  [[ -z "${key}" || "${key}" == \#* ]] && continue
  declare "${key}=${value}"
done < "${ENV_FILE}"

# Substitution helper: replace $1 with $2 in file $3 (in-place).
substitute() {
  local from="$1"
  local to="$2"
  local file="$3"
  if grep -qF "${from}" "${file}" 2>/dev/null; then
    sed -i "s|${from}|${to}|g" "${file}"
    echo "  updated: ${file}"
  fi
}

echo "Applying project config from ${ENV_FILE}..."

# pyproject.toml — package name, project name, description, wheel path
echo "pyproject.toml"
substitute "transmission-mcp" "${PROJECT_NAME}" "${REPO_ROOT}/pyproject.toml"
substitute "transmission_mcp" "${PACKAGE_NAME}" "${REPO_ROOT}/pyproject.toml"
substitute "mcp-base" "${PROJECT_NAME}" "${REPO_ROOT}/pyproject.toml"
substitute "mcp_base" "${PACKAGE_NAME}" "${REPO_ROOT}/pyproject.toml"
substitute "Bare-bones FastMCP server template" "${PROJECT_DESCRIPTION}" "${REPO_ROOT}/pyproject.toml"

# .claude/rules/repository-overview.md — Docker image name
echo ".claude/rules/repository-overview.md"
substitute "sesopenko/mcp-base" "${DOCKER_IMAGE}" "${REPO_ROOT}/.claude/rules/repository-overview.md"

# .claude/rules/readme-docker-compose.md — Docker image name
echo ".claude/rules/readme-docker-compose.md"
substitute "sesopenko/mcp-base" "${DOCKER_IMAGE}" "${REPO_ROOT}/.claude/rules/readme-docker-compose.md"

# README.md — Docker image name, MCP server name
echo "README.md"
substitute "sesopenko/mcp-base" "${DOCKER_IMAGE}" "${REPO_ROOT}/README.md"
substitute "mcp-base" "${MCP_SERVER_NAME}" "${REPO_ROOT}/README.md"

# repository-overview.md — Docker image name
echo "repository-overview.md"
substitute "sesopenko/mcp-base" "${DOCKER_IMAGE}" "${REPO_ROOT}/repository-overview.md"

echo "Done."
