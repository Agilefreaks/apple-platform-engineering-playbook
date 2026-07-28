@AGENTS.md

## Claude Code notes

Claude Code loads `CLAUDE.md` only; it does not read `AGENTS.md` natively. The
`@AGENTS.md` import on the first line pulls the project contract into every session.

**Keep all project facts and commands in `AGENTS.md`.** This file holds only behaviour
specific to running the project *through Claude Code*. A fact stated in both files is a
fact that will go stale in one of them.

The test: would this still be true with a different agent, or with a human reading the
repository? If yes, it belongs in `AGENTS.md`, and this file may *point* at the relevant
section but must not restate it.

Add below only Claude-runtime notes. For example:

- when to open the Simulator or preview panel, and that verification is Claude's job
  rather than something to ask the user to do;
- how to isolate a shared resource when Claude fans out subagents, referring to the
  project's own rule for the reasoning;
- which Claude Code skills to invoke for the work in this repository, where the canonical
  skill-to-runtime mapping stays in `AGENTS.md` and `tooling/skills.yml`;
- plan-mode or tool-permission preferences;
- the Claude-specific consequence of a project constraint — for instance, if the project
  is confidential, that nothing may go into a published Artifact or a web search.

Do **not** restate here: generated-file rules, the simulator destination, command tables,
paths, owners, or environment values. Those are project facts. Name the `AGENTS.md`
section instead, so there is one copy to keep correct.
