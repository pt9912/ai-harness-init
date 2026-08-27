# Claude Code Einstieg — ai-harness-init

@AGENTS.md

Zwei Hooks unter `.claude/hooks/` greifen in jeder Sitzung: Der **PreToolUse-Guard**
(`pretooluse-command-guard.sh`) blockt Host-Toolchains in der Befehlsposition und schlägt
bei Parse-Zweifel fail-closed zu. Der **Stop-Hook** (`stop-require-gates.sh`) lässt keinen
Abschluss zu, dessen Arbeitsbaum nicht von einem aufgezeichneten `make gates`-Lauf gedeckt
ist.
