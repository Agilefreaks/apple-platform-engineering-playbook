#!/usr/bin/env bash
# Verifies this checkout can read the Apple Platform Engineering Playbook.
#
# The playbook repository is private, so its documents cannot be fetched by a plain HTTP
# request: a browser `blob/` URL returns 404 to anything without a session. An agent that
# only has such a URL therefore has the AGENTS.md summary and nothing else — which is how a
# project ends up diverging from a standard it names as authority.
#
# Read-only. Exits non-zero when the standard cannot be read, and says what to do about it.

set -euo pipefail

version_file="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.apple-playbook-version"

if [[ ! -f "$version_file" ]]; then
  echo "No .apple-playbook-version in this repository." >&2
  echo "This check belongs in a project bootstrapped from the playbook." >&2
  exit 2
fi

source_slug="$(sed -n 's/^source=//p' "$version_file" | head -1)"
commit="$(sed -n 's/^playbook_commit=//p' "$version_file" | head -1)"
package="$(sed -n 's/^repository_package=//p' "$version_file" | head -1)"

if [[ -z "${source_slug}" ]]; then
  echo "No 'source=' line in .apple-playbook-version." >&2
  exit 2
fi

# The ref goes in the query string, not as a `-f` field: `gh api -f` forces the request to
# POST, which the contents endpoint answers with 404.
ref_query=""
ref_note="the default branch"
if [[ -n "${commit}" ]]; then
  ref_query="?ref=${commit}"
  ref_note="pinned commit ${commit:0:8}"
fi

echo "Playbook: ${source_slug} (package ${package:-unknown}, ${ref_note})"

if ! command -v gh >/dev/null 2>&1; then
  cat >&2 <<'MSG'
MISSING: the GitHub CLI (gh) is not installed.

The playbook is a private repository. gh is how a developer or an agent reads it without a
browser session.

  macOS:          brew install gh
  Debian/Ubuntu:  sudo apt install gh
  Fedora:         sudo dnf install gh
  otherwise:      https://github.com/cli/cli#installation

Then authenticate. `gh auth login` is interactive, so run it yourself — a subprocess cannot
complete it.
MSG
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "NOT AUTHENTICATED: run 'gh auth login' yourself — it is interactive." >&2
  exit 1
fi

standard_path="docs/architecture/AppleTeamArchitectureStandard.md"

if ! gh api "repos/${source_slug}/contents/${standard_path}${ref_query}" \
     --jq '.size' >/dev/null 2>&1; then
  cat >&2 <<MSG
NO ACCESS: authenticated, but cannot read ${standard_path} from ${source_slug}.

Either the account lacks access to the private repository, or the pinned commit is not
reachable. Ask the playbook owner named in AGENTS.md for read access on the repository.
MSG
  exit 1
fi

echo "OK: the architecture standard is readable."
echo
echo "Read any playbook document with:"
echo
if [[ -n "${commit}" ]]; then
  echo "  gh api 'repos/${source_slug}/contents/<path>?ref=${commit}' --jq .content | base64 -d"
else
  echo "  gh api 'repos/${source_slug}/contents/<path>' --jq .content | base64 -d"
fi
echo
echo "Paths worth knowing:"
echo "  ${standard_path}"
echo "  docs/delivery/AppleTeamDeliveryLoopStandard.md"
echo "  docs/architecture/AppleTeamHandbook.md"
