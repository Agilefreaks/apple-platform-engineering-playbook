@AGENTS.md

## Claude Code notes

Claude Code loads `CLAUDE.md` only; it does not read `AGENTS.md` natively. The
`@AGENTS.md` import on the first line pulls the project contract into every session.
Keep all project facts and commands in `AGENTS.md` — never duplicate them here.

Add below only Claude-specific workflow notes, for example: generated-project rules
(edit the generator manifest, never the generated `.xcodeproj`), the preferred local
verification simulator, or plan-mode preferences.
