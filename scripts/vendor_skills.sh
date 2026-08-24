#!/usr/bin/env bash

# Re-vendor the starter kit's agent skills from their upstream repositories at pinned commits.
#
# The skills are checked into templates/project/.agents/skills/ rather than declared as plugin
# marketplaces in .claude/settings.json. A marketplace declaration is an instruction to install:
# it needs the network, needs a trust prompt on first open, resolves to whatever the upstream
# default branch says that day, and leaves the result in per-machine state outside the project.
# A checked-in skill is present the moment the repository is cloned, identical for every
# contributor and every headless run, and changes only in a commit somebody reviewed.
#
# Run this to bump a pin: edit the table below, run the script, review the diff, commit.

set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest_dir="$root_dir/templates/project/.agents/skills"

# name|upstream repository|pinned commit|upstream version
skills=(
  "swift-concurrency-pro|twostraws/Swift-Concurrency-Agent-Skill|bee3f69ba17142da148d3c5406f148ed62592b69|1.0"
  "swift-testing-pro|twostraws/Swift-Testing-Agent-Skill|2d6bba14a3c8bf3694f218b92fffe617c41ae43e|1.0"
  "swiftui-pro|twostraws/SwiftUI-Agent-Skill|be297ff80dddec529af1f9b1f1f114aab6c9d11c|1.1"
)

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

mkdir -p "$dest_dir"

for entry in "${skills[@]}"; do
  IFS='|' read -r name repo commit _version <<<"$entry"

  checkout="$work_dir/$name"
  mkdir -p "$checkout"
  git -C "$checkout" init -q
  git -C "$checkout" remote add origin "https://github.com/$repo.git"
  # Fetching the commit itself rather than a branch is the point: a tag or branch name would make
  # the vendored content depend on when the script ran.
  git -C "$checkout" fetch -q --depth 1 origin "$commit"

  rm -rf "$dest_dir/$name"
  git -C "$checkout" archive FETCH_HEAD "$name" | tar -x -C "$dest_dir"
  # MIT requires the licence and copyright notice travel with the copy.
  git -C "$checkout" show "FETCH_HEAD:LICENSE" > "$dest_dir/$name/LICENSE"
  # The nested skills/ and .claude-plugin/ directories are the upstream repository's plugin
  # packaging, not the skill: they restate SKILL.md with ${CLAUDE_SKILL_DIR}-prefixed reference
  # paths, which would make a tool-agnostic copy Claude-specific.
  rm -rf "$dest_dir/$name/skills" "$dest_dir/$name/.claude-plugin"

  echo "vendored $name from $repo at ${commit:0:7}"
done

{
  echo "# Vendored agent skills"
  echo
  echo "These skills are checked in, not installed. They are present the moment this repository is"
  echo "cloned — no marketplace, no trust prompt, no network, and no per-machine state — so every"
  echo "contributor and every headless agent run gets the same capability."
  echo
  echo "\`.claude/skills/<name>\` symlinks into this directory, which is what makes each skill a"
  echo "project-scope skill for Claude Code. An agent that reads \`AGENTS.md\` rather than"
  echo "\`CLAUDE.md\` finds the same files here."
  echo
  echo "Regenerate with the playbook's \`scripts/vendor_skills.sh\`. Do not edit these files in"
  echo "place: a local edit is indistinguishable from upstream content and is lost on the next"
  echo "re-vendor. Record project-specific rules in \`AGENTS.md\` instead."
  echo
  echo "| Skill | Upstream | Pinned commit | Version | Licence |"
  echo "|---|---|---|---|---|"
  for entry in "${skills[@]}"; do
    IFS='|' read -r name repo commit version <<<"$entry"
    printf '| `%s` | [%s](https://github.com/%s) | `%s` | %s | MIT |\n' \
      "$name" "$repo" "$repo" "$commit" "$version"
  done
} > "$dest_dir/VENDORED.md"

echo "wrote $dest_dir/VENDORED.md"
