# Vendored agent skills

These skills are checked in, not installed. They are present the moment this repository is
cloned — no marketplace, no trust prompt, no network, and no per-machine state — so every
contributor and every headless agent run gets the same capability.

`.claude/skills/<name>` symlinks into this directory, which is what makes each skill a
project-scope skill for Claude Code. An agent that reads `AGENTS.md` rather than
`CLAUDE.md` finds the same files here.

Regenerate with the playbook's `scripts/vendor_skills.sh`. Do not edit these files in
place: a local edit is indistinguishable from upstream content and is lost on the next
re-vendor. Record project-specific rules in `AGENTS.md` instead.

| Skill | Upstream | Pinned commit | Version | Licence |
|---|---|---|---|---|
| `swift-concurrency-pro` | [twostraws/Swift-Concurrency-Agent-Skill](https://github.com/twostraws/Swift-Concurrency-Agent-Skill) | `bee3f69ba17142da148d3c5406f148ed62592b69` | 1.0 | MIT |
| `swift-testing-pro` | [twostraws/Swift-Testing-Agent-Skill](https://github.com/twostraws/Swift-Testing-Agent-Skill) | `2d6bba14a3c8bf3694f218b92fffe617c41ae43e` | 1.0 | MIT |
| `swiftui-pro` | [twostraws/SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill) | `be297ff80dddec529af1f9b1f1f114aab6c9d11c` | 1.1 | MIT |
