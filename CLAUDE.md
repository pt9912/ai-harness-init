# Claude Code Einstieg — ai-harness-init

@AGENTS.md

**Claude-spezifisch**, weil es an `.claude/hooks/` hängt und in `AGENTS.md` nichts zu
suchen hat: Der **PreToolUse-Guard** (`pretooluse-command-guard.sh`) blockt Host-Toolchains
in der Befehlsposition und schlägt bei Parse-Zweifel fail-closed zu; der **Stop-Hook**
(`stop-require-gates.sh`) lässt keinen Abschluss zu, dessen Arbeitsbaum nicht von einem
aufgezeichneten `make gates`-Lauf gedeckt ist.

Alles Übrige — Source Precedence, Hard Rules, Quality Gates, der Workflow und die Lektüre
des vendored Regelwerks — steht in [`AGENTS.md`](AGENTS.md) und wird oben importiert.
