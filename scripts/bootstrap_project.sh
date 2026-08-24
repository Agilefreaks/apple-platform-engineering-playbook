#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/new-app-repository" >&2
  exit 2
fi

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_dir="$1"

if [[ ! -d "$target_dir" ]]; then
  echo "Target directory does not exist: $target_dir" >&2
  exit 2
fi

destinations=(
  "$target_dir/AGENTS.md"
  "$target_dir/CLAUDE.md"
  "$target_dir/.claude/rules/git-workflow.md"
  "$target_dir/.claude/settings.json"
  "$target_dir/.mcp.json"
  "$target_dir/scripts/check_playbook_access.sh"
  "$target_dir/tooling/skills.yml"
  "$target_dir/tooling/tools.yml"
  "$target_dir/tooling/examples/tapia/mcp.example.json"
  "$target_dir/tooling/examples/tapia/tapia.flows.example.yaml"
  "$target_dir/docs/adr/0000-template.md"
  "$target_dir/delivery/schema/delivery.schema.json"
  "$target_dir/.apple-playbook-version"
)

for destination in "${destinations[@]}"; do
  if [[ -e "$destination" ]]; then
    echo "Refusing to overwrite existing file: $destination" >&2
    exit 1
  fi
done

if [[ -d "$target_dir/delivery/templates" ]] &&
   [[ -n "$(find "$target_dir/delivery/templates" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
  echo "Refusing to copy into non-empty delivery/templates" >&2
  exit 1
fi

mkdir -p \
  "$target_dir/.claude/rules" \
  "$target_dir/scripts" \
  "$target_dir/tooling" \
  "$target_dir/tooling/examples/tapia" \
  "$target_dir/docs/adr" \
  "$target_dir/delivery/schema" \
  "$target_dir/delivery/templates" \
  "$target_dir/delivery/items"

cp "$root_dir/templates/project/AGENTS.template.md" "$target_dir/AGENTS.md"
cp "$root_dir/templates/project/CLAUDE.template.md" "$target_dir/CLAUDE.md"
cp "$root_dir/templates/project/.claude/rules/git-workflow.md" \
  "$target_dir/.claude/rules/git-workflow.md"
# Agent capability belongs to the repository, not to whoever set it up locally: the settings
# file declares which skills the project expects and approves its MCP server, and .mcp.json
# carries that server's pinned configuration.
cp "$root_dir/templates/project/.claude/settings.json" "$target_dir/.claude/settings.json"
cp "$root_dir/templates/project/.mcp.json" "$target_dir/.mcp.json"
cp "$root_dir/templates/project/scripts/check_playbook_access.sh" \
  "$target_dir/scripts/check_playbook_access.sh"
chmod +x "$target_dir/scripts/check_playbook_access.sh"
cp "$root_dir/templates/project/tooling/skills.yml" "$target_dir/tooling/skills.yml"
cp "$root_dir/templates/project/tooling/tools.yml" "$target_dir/tooling/tools.yml"
cp "$root_dir/templates/project/tools/tapia/mcp.example.json" \
  "$target_dir/tooling/examples/tapia/mcp.example.json"
cp "$root_dir/templates/project/tools/tapia/tapia.flows.example.yaml" \
  "$target_dir/tooling/examples/tapia/tapia.flows.example.yaml"
cp "$root_dir/templates/project/docs/adr/0000-template.md" "$target_dir/docs/adr/0000-template.md"
cp "$root_dir/schemas/delivery.schema.json" "$target_dir/delivery/schema/delivery.schema.json"
cp "$root_dir"/templates/delivery/* "$target_dir/delivery/templates/"
# The commit is recorded as well as the package version: reading a private document through the
# API needs a ref, and "whatever main says today" is not a pinned adoption unit.
playbook_commit="$(git -C "$root_dir" rev-parse HEAD 2>/dev/null || echo "")"
{
  printf 'repository_package=0.3.0\n'
  printf 'source=Agilefreaks/apple-platform-engineering-playbook\n'
  if [[ -n "$playbook_commit" ]]; then
    printf 'playbook_commit=%s\n' "$playbook_commit"
  fi
} > "$target_dir/.apple-playbook-version"

echo "Apple project contract installed in: $target_dir"
echo
echo "Next:"
echo "  1. scripts/check_playbook_access.sh   # confirm the standard is readable"
echo "  2. Replace every <PLACEHOLDER>, including <EVALUATED_VERSION> in .mcp.json and the"
echo "     skill versions in tooling/skills.yml and AGENTS.md."
echo "  3. Define the project commands, then commit intentionally."
