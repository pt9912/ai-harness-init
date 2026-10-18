# Relativer Import am Python-hexslice-Ziel nicht gefahren

**Sub-Area:** `*` (gesamtes Repo)

a-check extrahiert einen relativen Import nicht (Hinweis, Exit 0); gebunden ist er allein über ruff `TID252`
(`ban-relative-imports = "all"`). Die lint-Stage des flachen Python-Ziels färbt ihn rot; am hexslice-Ziel fährt keine
Stufe und kein Fall einen relativen Import, die Abdeckungs-Zeile nennt ihn unter NICHT gemessen
([`AGENTS.md`](../../../../../../AGENTS.md) §3.6).
