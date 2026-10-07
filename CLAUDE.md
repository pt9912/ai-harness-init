# Claude Code Einstieg — ai-harness-init

@AGENTS.md

Zwei Hooks unter `.claude/hooks/` greifen in jeder Sitzung: Der **PreToolUse-Guard**
(`pretooluse-command-guard.sh`) blockt Host-Toolchains in der Befehlsposition und schlägt
bei Parse-Zweifel fail-closed zu. Der **Stop-Hook** (`stop-require-gates.sh`) bindet an den
Commit: er hält ein Turn-Ende auf, sobald HEAD seit dem letzten grünen `make gates`-Lauf ein
neuer ist und dessen Inhalt nicht gedeckt ist; ein Turn-Ende ohne neuen Commit geht frei, sofern
ein grüner Lauf HEAD gestempelt hat (Stempel `gates-passed.head` aus `record-gates`), das Netz
dort ist CI auf dem Push — fehlt der Stempel (erster Turn nach dem Update, Klon vor dem ersten
grünen Lauf), gilt der strenge Zweig. Streng — jedes Turn-Ende mit ungedecktem Arbeitsbaum — ist er,
wenn `.harness/stop-gate-streng` liegt oder `STOP_GATE_STRENG=1` gesetzt ist
([ADR-0083](docs/plan/adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)).
