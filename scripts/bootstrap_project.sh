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
  "$target_dir/tooling/skills.yml"
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
  "$target_dir/tooling" \
  "$target_dir/docs/adr" \
  "$target_dir/delivery/schema" \
  "$target_dir/delivery/templates" \
  "$target_dir/delivery/items"

cp "$root_dir/templates/project/AGENTS.template.md" "$target_dir/AGENTS.md"
cp "$root_dir/templates/project/tooling/skills.yml" "$target_dir/tooling/skills.yml"
cp "$root_dir/templates/project/docs/adr/0000-template.md" "$target_dir/docs/adr/0000-template.md"
cp "$root_dir/schemas/delivery.schema.json" "$target_dir/delivery/schema/delivery.schema.json"
cp "$root_dir"/templates/delivery/* "$target_dir/delivery/templates/"
printf 'repository_package=0.1.1\nsource=agilefreaks/apple-platform-engineering-playbook\n' \
  > "$target_dir/.apple-playbook-version"

echo "Apple project contract installed in: $target_dir"
echo "Next: replace every <PLACEHOLDER>, define project commands, and commit intentionally."
