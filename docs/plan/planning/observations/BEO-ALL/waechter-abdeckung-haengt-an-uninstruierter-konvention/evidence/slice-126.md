**Vorgang:** slice-126
**Fund:** Der neue Commit-Message-Wächter hängt am PreToolUse-Kanal und greift nur, wenn der Lauf
die Repo-Konvention *Commit via Message-Datei* (`git commit -F <datei>`) befolgt. Getragen wird sie
von den drei Dateien unter [`.claude/commands/`](../../../../../../../.claude/commands/); **vier von
sechs** `.claude/agents/*.md` nennen weder die Commit-Form noch zeigen sie auf `commands/`, und
[`.harness/skills/reviewer.md`](../../../../../../../.harness/skills/reviewer.md) ebenfalls nicht.
Ein Subagenten-Lauf, der zum Committen beauftragt wird, hat in seinem Anweisungssatz damit keinen
Grund, `-F` statt `-m` zu wählen — dann greift der Wächter nie, und weder Lauf noch Repo bemerken
es. Kein Gate liest Rollen-Anweisungssätze auf diese Eigenschaft.
