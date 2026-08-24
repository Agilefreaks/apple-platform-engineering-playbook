#!/usr/bin/env bash
# Verifies this checkout can read the Apple Platform Engineering Playbook.
#
# A browser `blob/` URL is still not a readable reference: it returns an HTML page, not the
# document, so an agent handed one has the AGENTS.md summary and nothing else — which is how a
# project ends up diverging from a standard it names as authority. This check confirms the
# architecture standard is fetchable at the pinned commit and prints a command that returns
# document text: through the GitHub CLI when one is installed and authenticated (which also
# covers a private fork of the playbook), and over plain HTTPS when it is not.
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

standard_path="docs/architecture/AppleTeamArchitectureStandard.md"

# The ref goes in the query string, not as a `-f` field: `gh api -f` forces the request to
# POST, which the contents endpoint answers with 404.
ref_query=""
raw_ref="HEAD"
ref_note="the default branch"
if [[ -n "${commit}" ]]; then
  ref_query="?ref=${commit}"
  raw_ref="${commit}"
  ref_note="pinned commit ${commit:0:8}"
fi

raw_url="https://raw.githubusercontent.com/${source_slug}/${raw_ref}/${standard_path}"

echo "Playbook: ${source_slug} (package ${package:-unknown}, ${ref_note})"

gh_recipe() {
  if [[ -n "${commit}" ]]; then
    echo "  gh api 'repos/${source_slug}/contents/<path>?ref=${commit}' --jq .content | base64 -d"
  else
    echo "  gh api 'repos/${source_slug}/contents/<path>' --jq .content | base64 -d"
  fi
}

https_recipe() {
  echo "  curl -fsSL https://raw.githubusercontent.com/${source_slug}/${raw_ref}/<path>"
}

paths_worth_knowing() {
  echo
  echo "Paths worth knowing:"
  echo "  ${standard_path}"
  echo "  docs/delivery/AppleTeamDeliveryLoopStandard.md"
  echo "  docs/architecture/AppleTeamHandbook.md"
}

# Preferred route: the GitHub CLI, when it is installed and authenticated. It is the only route
# that works if the playbook has been forked into a private repository.
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  if gh api "repos/${source_slug}/contents/${standard_path}${ref_query}" \
       --jq '.size' >/dev/null 2>&1; then
    echo "OK: the architecture standard is readable through the GitHub CLI."
    echo
    echo "Read any playbook document with:"
    echo
    gh_recipe
    paths_worth_knowing
    exit 0
  fi
  echo "gh is authenticated but could not read ${standard_path}; trying plain HTTPS." >&2
fi

# Fallback: the playbook is public, so a raw URL needs no CLI and no authentication.
if ! command -v curl >/dev/null 2>&1; then
  echo "NO ACCESS: neither an authenticated 'gh' nor 'curl' is available." >&2
  echo "Install the GitHub CLI (https://github.com/cli/cli#installation) or curl." >&2
  exit 1
fi

if ! curl -fsSL -o /dev/null "$raw_url" 2>/dev/null; then
  cat >&2 <<MSG
NO ACCESS: cannot read ${standard_path} from ${source_slug}.

Checked: ${raw_url}

Either the pinned commit is not reachable, the playbook has moved or become private, or this
machine has no network route to raw.githubusercontent.com. If the repository is private, install
the GitHub CLI and authenticate — 'gh auth login' is interactive, so run it yourself, a
subprocess cannot complete it — then run this check again.
MSG
  exit 1
fi

echo "OK: the architecture standard is readable over plain HTTPS."
echo
echo "Read any playbook document with:"
echo
https_recipe
paths_worth_knowing
