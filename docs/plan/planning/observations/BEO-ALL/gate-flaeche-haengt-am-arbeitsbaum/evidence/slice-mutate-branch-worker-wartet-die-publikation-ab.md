**Vorgang:** slice-mutate-branch-worker-wartet-die-publikation-ab
**Fund:** Ein für die Wirkungs-Probe angelegter Wegwerf-Worktree unter `.harness/state/wt-wegwerf/` lag im Prüfbereich von `make docs-check` (13222 Befunde, alle unter diesem Pfad) und färbte `make gates` rot, bis er entfernt war; kein Byte des Repos hatte sich geändert.
