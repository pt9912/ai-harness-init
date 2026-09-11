**Stand:** offen

Ein Wächter besteht, trifft aber nicht: `.claude/hooks/pretooluse-command-guard.sh` hält die
Befehlsposition gegen eine Namensliste (`grep -n '^BLOCKED=' .claude/hooks/pretooluse-command-guard.sh`)
und sieht ein Toolchain-Wort hinter `docker run` nicht. Er hängt zudem an einem Agenten —
`.codex/hooks.json` führt allein den SessionStart-Injektor. Ob die Argumentposition eines
Container-Aufrufs dazugehört, ist eine Verschärfung des Guard-Vertrags und damit Norm-Arbeit
([`AGENTS.md`](../../../../../../AGENTS.md) §3.8); bis dahin trägt der Abschnitt §3.9 allein.
